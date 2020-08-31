
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_update_process]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_update_process]

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Sishir Maharjan>
-- Create date: <07/15/2009>
-- Description:	<Updates Status of Activities>
--
-- =============================================


CREATE PROC [dbo].[spa_update_process]
	@user_name VARCHAR(200) = NULL,
    @risk_control_activity_id INT = NULL, 
	@approved INT = NULL, /*When status  'Submit Proof'' -  NULL , Approve = 1, Unapprove = 0, Others = -1*/ 
	@asOfDate DATETIME   = NULL,
	@process_table VARCHAR(400) = NULL,
	@action_type INT = NULL,
	@source_column VARCHAR(300) = NULL,
	@source_id INT = NULL
	
AS
SET NOCOUNT ON;
DECLARE @nextStatus           INT,
        @activityDescription  VARCHAR(500),
        @riskControlID        INT,
        @currentStatus        INT,
        @exception_date       DATETIME,
        @parentAct            INT,
        @control_flag         CHAR(1),
        @update_parent        CHAR(1),
        @activity_id          INT,
        @secondary_activity_id INT,
        @source				  VARCHAR(300)
        
DECLARE @primary_trigger INT
DECLARE @secondary_trigger INT

IF @asOfDate IS NULL
    SELECT @asOfDate = GETDATE()

IF @approved = 2
BEGIN
/* @approved is 2 when checking for the existence of the activity where current date is greater than the exception date.
This check is called from the SP spa_is_valid_user */
		SET @nextStatus = 731
		SET @activityDescription = 'Activity is Pending for Mitigation.'

		CREATE TABLE #tmp (sno INT IDENTITY,risk_control_id INT ,as_of_date DATETIME ,risk_control_activity_id INT, exception_date DATETIME, [source] VARCHAR(300) COLLATE DATABASE_DEFAULT, source_column VARCHAR(300) COLLATE DATABASE_DEFAULT, source_id INT)
		
		DECLARE @min INT, @max INT
		
		
		INSERT INTO #tmp
		SELECT prca.risk_control_id,
		       prca.as_of_date,
		       prca.risk_control_activity_id,
		       prca.exception_date,
		       prca.source,
		       prca.source_column,
		       prca.source_id
		FROM   process_risk_controls_activities prca
		JOIN dbo.process_risk_controls prc ON  prca.risk_control_id = prc.risk_control_id
		WHERE  @asOfDate > prca.exception_date
		       AND prca.control_status = 725
		       AND prc.mitigation_plan_required = 'y'
		       AND NOT EXISTS (
		               SELECT risk_control_id
		               FROM   process_risk_controls_activities_audit a
		               WHERE  a.risk_control_activity_id = @risk_control_activity_id
		               AND COALESCE(prca.source_column, '') = COALESCE(@source_column, '')
					   AND COALESCE(prca.source_id, '') = COALESCE(@source_id, '')
		           )

		SELECT @min = 0 , @max = 0		
												
		SELECT @min = MIN(sno),@max = MAX(sno) FROM #tmp
		
		WHILE (@min <= @max)
		BEGIN				
			
			SELECT 	
				@riskControlID = risk_control_id, 
				@asOfDate = as_of_date		, 
				@risk_control_activity_id = risk_control_activity_id,
				@exception_date = exception_date,
				@source = [source],
				@source_column = source_column,
				@source_id = source_id
			 FROM #tmp WHERE sno = @min
									
			UPDATE process_risk_controls_activities
			SET    control_status = @nextStatus
			WHERE  risk_control_id = @riskControlID
																		
			INSERT INTO process_risk_controls_activities_audit (
			    risk_control_id,
			    as_of_date,
			    control_prior_status,
			    control_new_status,
			    activity_desc,
			    risk_control_activity_id,
			    [source], 
			    source_column, 
			    source_id
			  )
			VALUES (
			    @riskControlID,
			    @asOfDate,
			    725,
			    @nextStatus,
			    @activityDescription,
			    @risk_control_activity_id,
			    @source,
			    @source_column,
			    @source_id
			  )
									
			SELECT @min = @min + 1					
		END	
					
		RETURN		
END
ELSE 
BEGIN 
	IF @approved IS NULL OR @approved NOT IN (1,0) 
	BEGIN 
		SELECT 
			@riskControlID = prca.risk_control_id, 
			@nextStatus = prcas.nextStatus,
			@currentStatus = prca.control_status,
			@source = prca.source,
			@source_column = prca.source_column,
			@source_id = prca.source_id	
		FROM process_risk_controls_activities prca
		JOIN process_risk_controls prc ON prc.risk_control_id = prca.risk_control_id 
		JOIN dbo.process_risk_controls_activities_status prcas ON prcas.activityStatus = prca.control_status 
		AND UPPER(prc.requires_approval) = UPPER(prcas.requiresApproval) AND UPPER(prc.requires_approval_for_late) = UPPER(prcas.requiresApprovalLate) 
		AND UPPER(prc.requires_proof) = UPPER(prcas.requiresProof) AND UPPER(prc.mitigation_plan_required) = UPPER(prcas.mitigationRequired)
		JOIN dbo.static_data_value sdv ON sdv.value_id = prcas.nextStatus
		WHERE prca.risk_control_activity_id = @risk_control_activity_id
		AND COALESCE(prca.source_column, '') = COALESCE(@source_column, '')
		AND COALESCE(prca.source_id, '') = COALESCE(@source_id, '')
		 
		IF @nextStatus = 725
			SELECT @activityDescription = 'Activity was re-processed.'
		ELSE IF @nextStatus = 728 
			SELECT @activityDescription = 'Activity was completed.'
		ELSE IF @nextStatus = 729 
			SELECT @activityDescription = 'Activity was approved.'
		ELSE IF @currentStatus = 731 AND @nextStatus = 730 
			SELECT @activityDescription = 'Mitigation activity was created.'	
			
		SELECT @activity_id = prc.action_type_on_complete
		FROM process_risk_controls_activities prca
		INNER JOIN process_risk_controls prc ON  prca.risk_control_id = prc.risk_control_id
		WHERE  prca.risk_control_activity_id = @risk_control_activity_id 
		AND COALESCE(prca.source_column, '') = COALESCE(@source_column, '')
		AND COALESCE(prca.source_id, '') = COALESCE(@source_id, '')
		
		SELECT @secondary_activity_id = prc.action_type_secondary
		FROM process_risk_controls_activities prca
		INNER JOIN process_risk_controls prc ON  prca.risk_control_id = prc.risk_control_id
		WHERE  prca.risk_control_activity_id = @risk_control_activity_id 
		AND COALESCE(prca.source_column, '') = COALESCE(@source_column, '')
		AND COALESCE(prca.source_id, '') = COALESCE(@source_id, '')
		
		SELECT @primary_trigger = prc.trigger_primary
		FROM process_risk_controls_activities prca
		INNER JOIN process_risk_controls prc ON  prca.risk_control_id = prc.risk_control_id
		WHERE  prca.risk_control_activity_id = @risk_control_activity_id 
		AND COALESCE(prca.source_column, '') = COALESCE(@source_column, '')
		AND COALESCE(prca.source_id, '') = COALESCE(@source_id, '')
		
		SELECT @secondary_trigger = prc.trigger_secondary
		FROM process_risk_controls_activities prca
		INNER JOIN process_risk_controls prc ON  prca.risk_control_id = prc.risk_control_id
		WHERE  prca.risk_control_activity_id = @risk_control_activity_id 
		AND COALESCE(prca.source_column, '') = COALESCE(@source_column, '')
		AND COALESCE(prca.source_id, '') = COALESCE(@source_id, '')
	END
	 
	ELSE IF @approved = 0		-- unapprove 
	BEGIN 
		SELECT @riskControlID = risk_control_id,
		       @nextStatus = 726,
		       @currentStatus = control_status,
		       @source = source,
		       @source_column = source_column,
		       @source_id = source_id
		FROM   dbo.process_risk_controls_activities
		WHERE  risk_control_activity_id = @risk_control_activity_id 
		
		SELECT @activityDescription = 'Activity was un-approved.'
		
		SELECT @activity_id = prc.action_type_on_approve
		FROM process_risk_controls_activities prca
		INNER JOIN process_risk_controls prc ON  prca.risk_control_id = prc.risk_control_id
		WHERE prca.risk_control_activity_id = @risk_control_activity_id  
		AND COALESCE(prca.source_column, '') = COALESCE(@source_column, '')
		AND COALESCE(prca.source_id, '') = COALESCE(@source_id, '')
	END 
	ELSE IF @approved = 1		-- approve 
	BEGIN 
		SELECT 
			@riskControlID = risk_control_id, 
			@nextStatus = 729,
			@currentStatus = control_status
		FROM dbo.process_risk_controls_activities WHERE risk_control_activity_id = @risk_control_activity_id 
		
		SELECT @activityDescription = 'Activity was approved.'
		
		SELECT @activity_id = prc.action_type_on_approve
		FROM process_risk_controls_activities prca
		INNER JOIN process_risk_controls prc ON  prca.risk_control_id = prc.risk_control_id
		WHERE prca.risk_control_activity_id = @risk_control_activity_id 
		AND COALESCE(prca.source_column, '') = COALESCE(@source_column, '')
		AND COALESCE(prca.source_id, '') = COALESCE(@source_id, '')
	END 

--	SELECT @riskControlID 'riskControlID', @currentStatus 'currentStatus', @nextStatus 'nextStatus', @activityDescription 'activityDescription'
	UPDATE process_risk_controls_activities
	SET    control_status = ISNULL(@nextStatus, 728)
	WHERE  risk_control_activity_id = @risk_control_activity_id
	
	IF @riskControlID IS NULL
		SELECT @riskControlID = risk_control_id FROM process_risk_controls_activities WHERE risk_control_activity_id = @risk_control_activity_id				
		
	INSERT INTO process_risk_controls_activities_audit (
	    risk_control_id,
	    as_of_date,
	    control_prior_status,
	    control_new_status,
	    activity_desc,
	    risk_control_activity_id,
	    create_user,
	    create_ts,
	    source, 
	    source_column, 
	    source_id
	  )
	VALUES (
	    @riskControlID,
	    @asOfDate,
	    ISNULL(@currentStatus,725),
	    ISNULL(@nextStatus, 728),
	    @activityDescription,
	    @risk_control_activity_id,
	    dbo.FNADBUser(),
	    GETDATE(),
	    @source,
	    @source_column,
	    @source_id
	  )
	

	/*Begin -  On the status change of Mitigated Activity Change the status of the parent Activity too*/	
		
	SELECT @parentAct = NULL,
		   @control_flag = 'n',
		   @update_parent = 'n'
	
	SELECT @parentAct = mitigatedActivityInstanceId , @update_parent  =  'y' FROM dbo.process_risk_controls_activities 
	WHERE risk_control_activity_id = @risk_control_activity_id
	AND control_status = 728

	IF @parentAct IS NOT NULL AND @update_parent = 'y' -- If mitigated Activity is changed to Completed set the Status of the parent to Outstanding
	BEGIN 
		UPDATE dbo.process_risk_controls_activities
		SET    control_status = 725
		WHERE  risk_control_activity_id = @parentAct	
		
		SELECT @activityDescription = 'Mitigation activity was performed.'
		
		INSERT INTO process_risk_controls_activities_audit (
		    risk_control_id,
		    as_of_date,
		    control_prior_status,
		    control_new_status,
		    activity_desc,
		    risk_control_activity_id,
		    source, 
		    source_column, 
		    source_id
		  )
		VALUES (
		    @riskControlID,
		    @asOfDate,
		    730,
		    725,
		    @activityDescription,
		    @parentAct,
		    @source,
		    @source_column,
		    @source_id
		  )		
	END 

		
	DECLARE @message_id INT	,@dbuser VARCHAR(100)	
--		
	SELECT  @message_id =message_id FROM message_board WHERE source_id = 'cmp-'+cast(@risk_control_activity_id AS VARCHAR) 
	SELECT  @dbuser = dbo.FNADBUser()
	--EXEC spa_message_board 'd', @dbuser, @message_id, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'n'
--	IF @parentAct IS NOT NULL AND @control_flag = 'y' -- If mitigated Activity is changed to Outstanding set the Status of the parent to Mitigated
--		UPDATE  dbo.process_risk_controls_activities SET control_status = 730 WHERE risk_control_activity_id = @parentAct	
		
	/*End  -  On the status change of Mitigated Activity Change the status of the parent Activity too*/	
	IF @approved = -1
		EXEC spa_get_activities_info @asOfDate,'O', @process_table, @source, @source_column, @source_id
	
	EXEC spa_get_outstanding_control_activities_job @as_of_date = @asOfDate, @process_table = @process_table	
	
	
	/*Added by Rajiv. Alert activity.*/
	DECLARE @alert_table VARCHAR(200)
	DECLARE @counterparty_id INT
	DECLARE @deal_id INT
	DECLARE @entity_id INT
	DECLARE @process_id VARCHAR(500)
	CREATE TABLE #temp_alert_workflow (id INT)
	CREATE TABLE #temp_alert_workflow_deal (id INT)
	
	
	IF ISNULL(@activity_id, 0) = 20801
	BEGIN
		SELECT @alert_table = 'adiha_process.dbo.nested_alert_' + prca.process_id + '_na'
		FROM process_risk_controls_activities prca
		WHERE prca.risk_control_activity_id = @risk_control_activity_id
		DELETE FROM #temp_alert_workflow
		
		EXEC('INSERT INTO #temp_alert_workflow SELECT id FROM ' + @alert_table)
		--print('INSERT INTO #temp_alert_workflow SELECT id FROM ' + @alert_table)
		--SELECT * FROM #temp_alert_workflow
		--EXEC('SELECT * FROM #temp_alert_workflow')
		DECLARE alert_workflow_cursor CURSOR FOR
		SELECT [id] FROM #temp_alert_workflow
		
		OPEN alert_workflow_cursor
		FETCH NEXT FROM alert_workflow_cursor 
		INTO @counterparty_id
		
		WHILE @@FETCH_STATUS = 0
		BEGIN
			EXEC spa_alert_activity	@counterparty_id, 20801, 'w', @alert_table, NULL	
			
			FETCH NEXT FROM alert_workflow_cursor 
			INTO @counterparty_id
		END
		CLOSE alert_workflow_cursor
		DEALLOCATE alert_workflow_cursor
	END
	ELSE IF @activity_id = 20803
	BEGIN
		SELECT  @alert_table = 'adiha_process.dbo.deal_validation_' + prca.process_id + '_dv'
		FROM   process_risk_controls_activities prca
		WHERE prca.risk_control_activity_id = @risk_control_activity_id
		
		DELETE FROM #temp_alert_workflow_deal
		EXEC('INSERT INTO #temp_alert_workflow_deal SELECT source_deal_header_id FROM ' + @alert_table)

		DECLARE alert_workflow_cursor_deal CURSOR FOR
		SELECT [id] FROM #temp_alert_workflow_deal
		
		OPEN alert_workflow_cursor_deal
		FETCH NEXT FROM alert_workflow_cursor_deal 
		INTO @deal_id
		
		WHILE @@FETCH_STATUS = 0
		BEGIN
			EXEC spa_alert_activity	@deal_id, 20803, 'w', @alert_table, NULL	
			
			FETCH NEXT FROM alert_workflow_cursor_deal 
			INTO @deal_id
		END
		CLOSE alert_workflow_cursor_deal
		DEALLOCATE alert_workflow_cursor_deal
	END
	
	IF ISNULL(@secondary_activity_id, 0) = 20801
	BEGIN
		SELECT  @alert_table = 'adiha_process.dbo.nested_alert_' + prca.process_id + '_na'
		FROM   process_risk_controls_activities prca
		WHERE prca.risk_control_activity_id = @risk_control_activity_id
		
		DELETE FROM #temp_alert_workflow
		EXEC('INSERT INTO #temp_alert_workflow SELECT id FROM ' + @alert_table)

		DECLARE alert_workflow_cursor CURSOR FOR
		SELECT [id] FROM #temp_alert_workflow
		
		OPEN alert_workflow_cursor
		FETCH NEXT FROM alert_workflow_cursor 
		INTO @counterparty_id
		
		WHILE @@FETCH_STATUS = 0
		BEGIN
			EXEC spa_alert_activity	@counterparty_id, 20801, 'w', @alert_table, NULL	
			
			FETCH NEXT FROM alert_workflow_cursor 
			INTO @counterparty_id
		END
		CLOSE alert_workflow_cursor
		DEALLOCATE alert_workflow_cursor
	END
	ELSE IF @secondary_activity_id = 20803
	BEGIN
		SELECT  @alert_table = 'adiha_process.dbo.deal_validation_' + prca.process_id + '_dv'
		FROM   process_risk_controls_activities prca
		WHERE prca.risk_control_activity_id = @risk_control_activity_id
		
		DELETE FROM #temp_alert_workflow_deal
		EXEC('INSERT INTO #temp_alert_workflow_deal SELECT source_deal_header_id FROM ' + @alert_table)
		DECLARE alert_workflow_cursor_deal CURSOR FOR
		SELECT [id] FROM #temp_alert_workflow_deal
		
		OPEN alert_workflow_cursor_deal
		FETCH NEXT FROM alert_workflow_cursor_deal 
		INTO @deal_id
		
		WHILE @@FETCH_STATUS = 0
		BEGIN
			EXEC spa_alert_activity	@deal_id, 20803, 'w', @alert_table, NULL	
			
			FETCH NEXT FROM alert_workflow_cursor_deal 
			INTO @deal_id
		END
		CLOSE alert_workflow_cursor_deal
		DEALLOCATE alert_workflow_cursor_deal
	END
	--- starts
	
	IF @activity_id IS NOT NULL AND @activity_id NOT IN (20801,20803)
	BEGIN
		SELECT @alert_table = 'adiha_process.dbo.workflow_table_' + prca.process_id,
			   @process_id = prca.process_id
		FROM process_risk_controls_activities prca
		WHERE prca.risk_control_activity_id = @risk_control_activity_id
		
		DELETE FROM #temp_alert_workflow_deal
		EXEC('INSERT INTO #temp_alert_workflow_deal SELECT id FROM ' + @alert_table)
		
		DECLARE alert_workflow_cursor CURSOR FOR
		SELECT DISTINCT [id] FROM #temp_alert_workflow_deal
		
		OPEN alert_workflow_cursor
		FETCH NEXT FROM alert_workflow_cursor 
		INTO @entity_id
		
		WHILE @@FETCH_STATUS = 0
		BEGIN
			EXEC spa_alert_activity	@entity_id, @activity_id, 'w', @alert_table, NULL, @process_id	
			
			FETCH NEXT FROM alert_workflow_cursor 
			INTO @entity_id
		END
		CLOSE alert_workflow_cursor
		DEALLOCATE alert_workflow_cursor
	END
	
	IF @secondary_activity_id IS NOT NULL AND @secondary_activity_id NOT IN (20801,20803)
	BEGIN
		SELECT @alert_table = 'adiha_process.dbo.workflow_table_' + prca.process_id,
			   @process_id = prca.process_id
		FROM  process_risk_controls_activities prca
		WHERE prca.risk_control_activity_id = @risk_control_activity_id
		
		DELETE FROM #temp_alert_workflow_deal
		EXEC('INSERT INTO #temp_alert_workflow_deal SELECT id FROM ' + @alert_table)
		
		DECLARE alert_workflow_cursor CURSOR FOR
		SELECT DISTINCT [id] FROM #temp_alert_workflow_deal
		
		OPEN alert_workflow_cursor
		FETCH NEXT FROM alert_workflow_cursor 
		INTO @entity_id
		
		WHILE @@FETCH_STATUS = 0
		BEGIN
			EXEC spa_alert_activity	@entity_id, @secondary_activity_id, 'w', @alert_table, NULL, @process_id	
			
			FETCH NEXT FROM alert_workflow_cursor 
			INTO @entity_id
		END
		CLOSE alert_workflow_cursor
		DEALLOCATE alert_workflow_cursor
	END
	
	IF @primary_trigger IS NOT NULL OR @secondary_trigger IS NOT NULL
	BEGIN
		SELECT @process_id = prca.process_id
		FROM  process_risk_controls_activities prca
		WHERE prca.risk_control_activity_id = @risk_control_activity_id
		
		UPDATE alert_output_status
		SET published = 'y'
		WHERE process_id = @process_id
		
		UPDATE alert_workflows
		SET workflow_trigger = 'y'
		WHERE alert_sql_id = @primary_trigger
		
		UPDATE alert_workflows
		SET workflow_trigger = 'y'
		WHERE alert_sql_id = @secondary_trigger
		
		IF @primary_trigger IS NOT NULL AND @action_type = 1
		BEGIN
			EXEC spa_insert_alert_output_status @primary_trigger, @process_id, NULL, NULL, NULL		
			EXEC spa_run_alert_sql @primary_trigger, @process_id, @process_table, @source_column, @source_id 
		END
				
		IF @secondary_trigger IS NOT NULL AND @action_type = 2
		BEGIN
			EXEC spa_insert_alert_output_status @secondary_trigger, @process_id, NULL, NULL, NULL
			EXEC spa_run_alert_sql @secondary_trigger, @process_id, @process_table, @source_column, @source_id
		END 
	END
		
	--##################
	-- Logic Added By: Anal Shrestha
	-- Date:03/14/20089
	-- When the activity is completed, update the related tasks defined in process_function_map 
	-- Call the SP to complete the tasks
	--##########################	

	-- First find out if all the dependent tasks are completed

--		if @riskControlID IS NOT NULL
--			BEGIN
--				EXEC spa_check_dependency_status @riskControlID,NULL,@table_name
--				
--				EXEC('INSERT INTO #check_error SELECT [Status] FROM '+@table_name)
--
--				IF EXISTS(SELECT ErrorCode FROM #check_error WHERE ErrorCode<>'Success') -- if all the activity is completed and dependent activity is competed
--					RETURN
--				ELSE
--					EXEC spa_complete_compliance_activities 'p',NULL,NULL,NULL,@riskControlID,@control_status_new,@requires_approval
--			END		

	--##########################	
	
		
	
	
	IF @@ERROR <> 0
	    EXEC spa_ErrorHandler @@ERROR,
	         "Maintain Compliance Activity Status",
	         "spa_update_process",
	         "DB Error",
	         "Insert of Maintain Compliance Activity Status data failed.",
	         ''
	ELSE
	    EXEC spa_ErrorHandler 0,
	         'Maintain Compliance Activity Status',
	         'spa_update_process',
	         'Success',
	         'Maintain Compliance Activity Status data successfully updated.',
	         @riskControlID
	
END 

	


	
