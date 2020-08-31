/************************************************************
 * Code formatted by SoftTree SQL Assistant © v4.6.12
 * Time: 9/3/2010 2:10:28 PM
 ************************************************************/

/****** Object:  StoredProcedure [dbo].[spa_read_status_control_activities]    Script Date: 04/14/2009 21:20:35 ******/
IF EXISTS (
       SELECT *
       FROM   sys.objects
       WHERE  OBJECT_ID = OBJECT_ID(N'[dbo].[spa_read_status_control_activities]')
              AND TYPE IN (N'P', N'PC')
   )
    DROP PROCEDURE [dbo].[spa_read_status_control_activities]
/****** Object:  StoredProcedure [dbo].[spa_read_status_control_activities]    Script Date: 04/14/2009 21:20:41 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

/*
		Modification History
		---------------------
		Modified By:Pawan KC
		Date:12/12/2008
		Modification:Added Parameter @is_dependent_act
*/


CREATE PROC [dbo].[spa_read_status_control_activities]
	@userId VARCHAR(200) = NULL, 	 
	@asOfDate VARCHAR(200) = NULL, 
    @subID VARCHAR(200) = NULL, 
    @frequencyID INT = NULL, 
    @riskPriorityID INT = NULL,
    @performRoleID  INT = NULL,      
    @activityStatus INT = NULL, 
    @process_number VARCHAR(200) = NULL, 
    @risk_description_id INT = NULL, 
    @activity_category_id INT = NULL, 
    @who_for INT = NULL, 
    @where INT = NULL, 
    @why INT = NULL, 
    @activity_area INT = NULL, 
    @activity_sub_area INT = NULL, 
    @activity_action INT = NULL, 
    @activity_desc VARCHAR(200) = NULL, 
    @control_type  INT = NULL, 
    @montetory_value_defined VARCHAR = NULL, 
    @process_owner VARCHAR(200) = NULL, 
    @risk_owner VARCHAR(200) = NULL, 
    @risk_control_id INT = NULL, 
    @strategy_id INT = NULL, 
    @book_id INT = NULL, 
    @asOfDateTo VARCHAR(200) = NULL,
	@is_dependent_act INT = NULL,
	@mitigatedActivityInstanceId INT = NULL,
	@flag AS CHAR(1) = NULL,									
	@risk_control_activity_id VARCHAR(MAX) = NULL,
	@process_table VARCHAR(400) = NULL,
	@source_column VARCHAR(300) = NULL,
	@source_id INT = NULL
                                
AS
   
DECLARE @sqlStmt VARCHAR(5000)

BEGIN
	SET @sqlStmt = 'EXEC spa_Get_Risk_Control_Activities_view ' + CAST(@userID AS VARCHAR) + ','	
	
	IF @asOfDate IS NOT NULL
	    SET @sqlStmt = @sqlStmt + '''' + CAST(@asOfDate AS VARCHAR) + ''','
	ELSE
	    SET @sqlStmt = @sqlStmt + 'NULL,'
	
	
	IF @subID IS NOT NULL
	    SET @sqlStmt = @sqlStmt + '''' + CAST(@subID AS VARCHAR) + '''' + ','
	ELSE
	    SET @sqlStmt = @sqlStmt + 'NULL,'
	
	IF @frequencyID IS NOT NULL
	    SET @sqlStmt = @sqlStmt + CAST(@frequencyID AS VARCHAR) + ','
	ELSE
	    SET @sqlStmt = @sqlStmt + 'NULL,'
	
	
	IF @riskPriorityID IS NOT NULL
	    SET @sqlStmt = @sqlStmt + CAST(@riskPriorityID AS VARCHAR) + ','
	ELSE
	    SET @sqlStmt = @sqlStmt + 'NULL,'
	
	
	IF @performRoleID IS NOT NULL
	    SET @sqlStmt = @sqlStmt + CAST(@performRoleID AS VARCHAR) + ','
	ELSE
	    SET @sqlStmt = @sqlStmt + 'NULL,'
	
	
	
	
	IF @activityStatus IS NOT NULL
	    SET @sqlStmt = @sqlStmt + CAST(@activityStatus AS VARCHAR) + ','
	ELSE
	    SET @sqlStmt = @sqlStmt + 'NULL,'
	
	SET @sqlStmt = @sqlStmt + '1,'
	SET @sqlStmt = @sqlStmt + '0,'
	
	IF @process_number IS NOT NULL
	    SET @sqlStmt = @sqlStmt + CAST(@process_number AS VARCHAR) + ','
	ELSE
	    SET @sqlStmt = @sqlStmt + 'NULL,'
	
	
	IF @risk_description_id IS NOT NULL
	    SET @sqlStmt = @sqlStmt + CAST(@risk_description_id AS VARCHAR) + ','
	ELSE
	    SET @sqlStmt = @sqlStmt + 'NULL,'
	
	
	IF @activity_category_id IS NOT NULL
	    SET @sqlStmt = @sqlStmt + CAST(@activity_category_id AS VARCHAR) + ','
	ELSE
	    SET @sqlStmt = @sqlStmt + 'NULL,'
	
	
	IF @who_for IS NOT NULL
	    SET @sqlStmt = @sqlStmt + CAST(@who_for AS VARCHAR) + ','
	ELSE
	    SET @sqlStmt = @sqlStmt + 'NULL,' 
	
	
	IF @where IS NOT NULL
	    SET @sqlStmt = @sqlStmt + CAST(@where AS VARCHAR) + ','
	ELSE
	    SET @sqlStmt = @sqlStmt + 'NULL,' 
	
	
	IF @why IS NOT NULL
	    SET @sqlStmt = @sqlStmt + CAST(@why AS VARCHAR) + ','
	ELSE
	    SET @sqlStmt = @sqlStmt + 'NULL,' 
	
	
	IF @activity_area IS NOT NULL
	    SET @sqlStmt = @sqlStmt + CAST(@activity_area AS VARCHAR) + ','
	ELSE
	    SET @sqlStmt = @sqlStmt + 'NULL,'
	
	
	IF @activity_sub_area IS NOT NULL
	    SET @sqlStmt = @sqlStmt + CAST(@activity_sub_area AS VARCHAR) + ','
	ELSE
	    SET @sqlStmt = @sqlStmt + 'NULL,'
	
	
	IF @activity_action IS NOT NULL
	    SET @sqlStmt = @sqlStmt + CAST(@activity_action AS VARCHAR) + ','
	ELSE
	    SET @sqlStmt = @sqlStmt + 'NULL,'
	
	
	IF @activity_desc IS NOT NULL
	    SET @sqlStmt = @sqlStmt + '''' + CAST(@activity_desc AS VARCHAR) + ''','
	ELSE
	    SET @sqlStmt = @sqlStmt + 'NULL,'
	
	
	IF @control_type IS NOT NULL
	    SET @sqlStmt = @sqlStmt + CAST(@control_type AS VARCHAR) + ','
	ELSE
	    SET @sqlStmt = @sqlStmt + 'NULL,'
	
	
	IF @montetory_value_defined IS NOT NULL
	    SET @sqlStmt = @sqlStmt + CAST(@montetory_value_defined AS VARCHAR) + ','
	ELSE
	    SET @sqlStmt = @sqlStmt + 'NULL,'	
	
	IF @process_owner IS NOT NULL
	    SET @sqlStmt = @sqlStmt + CAST(@process_owner AS VARCHAR) + ','
	ELSE
	    SET @sqlStmt = @sqlStmt + 'NULL,'	
	
	IF @risk_owner IS NOT NULL
	    SET @sqlStmt = @sqlStmt + CAST(@risk_owner AS VARCHAR) + ','
	ELSE
	    SET @sqlStmt = @sqlStmt + 'NULL,'
	
	
	IF @risk_control_id IS NOT NULL
	    SET @sqlStmt = @sqlStmt + CAST(@risk_control_id AS VARCHAR) + ','
	ELSE
	    SET @sqlStmt = @sqlStmt + 'NULL,'
	
	
	IF @strategy_id IS NOT NULL
	    SET @sqlStmt = @sqlStmt + CAST(@strategy_id AS VARCHAR) + ','
	ELSE
	    SET @sqlStmt = @sqlStmt + 'NULL,'
	
	
	IF @book_id IS NOT NULL
	    SET @sqlStmt = @sqlStmt + CAST(@book_id AS VARCHAR) + ','
	ELSE
	    SET @sqlStmt = @sqlStmt + 'NULL,'
	    
	IF @process_table IS NOT NULL
		SELECT @sqlStmt = @sqlStmt + '''' + @process_table + ''','
	ELSE 
		SET @sqlStmt = @sqlStmt + 'NULL,'
	
	SET @sqlStmt = @sqlStmt + 'NULL,'	
	
	IF @asOfDateTo IS NOT NULL
	    SET @sqlStmt = @sqlStmt + '''' + CAST(@asOfDateTo AS VARCHAR) + ''','
	ELSE
	    SET @sqlStmt = @sqlStmt + 'NULL,'
	
	IF @is_dependent_act IS NOT NULL
	    SET @sqlStmt = @sqlStmt + CAST(@is_dependent_act AS VARCHAR) + ','
	ELSE
	    SET @sqlStmt = @sqlStmt + 'NULL,'
	
	IF @mitigatedActivityInstanceId IS NOT NULL
	    SET @sqlStmt = @sqlStmt + CAST(@mitigatedActivityInstanceId AS VARCHAR)
	ELSE
	    SET @sqlStmt = @sqlStmt + 'NULL'
	
	IF @flag IS NOT NULL
	    SELECT @sqlStmt = @sqlStmt + ',NULL,' + @flag
	ELSE
	    SELECT @sqlStmt = @sqlStmt + ',NULL,NULL'
	
	IF @risk_control_activity_id IS NOT NULL
	    SET @sqlStmt = @sqlStmt + ',''' + @risk_control_activity_id + ''''
	ELSE 
		SET @sqlStmt = @sqlStmt + ',NULL'
		
	IF @source_column IS NOT NULL
		SET @sqlStmt = @sqlStmt + ',''' + @source_column + ''''
	ELSE 
		SET @sqlStmt = @sqlStmt + ',NULL'
		
	IF @source_id IS NOT NULL
		SET @sqlStmt = @sqlStmt + ',' + CAST(@source_id AS VARCHAR(20)) + ''
	ELSE 
		SET @sqlStmt = @sqlStmt + ',NULL'
		
	EXEC spa_print @sqlStmt
	EXEC (@sqlStmt)
END












