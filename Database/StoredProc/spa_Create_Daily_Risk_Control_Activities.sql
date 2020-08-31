

/****** Object:  StoredProcedure [dbo].[spa_Create_Daily_Risk_Control_Activities]    Script Date: 05/20/2012 16:53:11 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_Create_Daily_Risk_Control_Activities]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_Create_Daily_Risk_Control_Activities]
GO

/****** Object:  StoredProcedure [dbo].[spa_Create_Daily_Risk_Control_Activities]    Script Date: 05/20/2012 16:53:15 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROC [dbo].[spa_Create_Daily_Risk_Control_Activities]
    @as_of_date AS VARCHAR(20) = NULL,
    @risk_control_id VARCHAR(500) = NULL,
    @force_build CHAR(1) = NULL,
    @is_mitigate CHAR(1) = NULL,
    @multiple_instance CHAR(1) = NULL, -- If the instance to be created any time of a day, this will be passed as 'y'
									   -- Previously multiple instance on same day was not allowed.
									   -- When creating mitigation instance, pass 'y' (Mandatory)
	@mitigatedActivityInstanceId INT = NULL,
	@showOutput CHAR(1) = 'y',
	@createTrigger CHAR(1) = 'y', -- When 'n' it won't create the trigger activities even if the trigger is mentioned
	@process_id VARCHAR(200) = NULL,
	@process_table VARCHAR(400) = NULL,
	@source_table VARCHAR(400) = NULL,
	@primary_column VARCHAR(400) = NULL
AS 
SET NOCOUNT ON
BEGIN
	--Assign null to all the parameters if its blank
	IF @force_build = ''
	    SELECT @force_build = NULL
	
	IF @is_mitigate = ''
	    SELECT @is_mitigate = NULL
	
	IF @multiple_instance = ''
	    SELECT @multiple_instance = NULL
	
	IF @as_of_date = ''
	    SELECT @as_of_date = NULL
	
	IF @risk_control_id = ''
	    SELECT @risk_control_id = NULL

	DECLARE @stmt            VARCHAR(MAX),
	        @error           VARCHAR(1000),
	        @rowcount        INT,
	        @activitiesList  VARCHAR(8000),
	        @dependencyList  VARCHAR(8000),
	        @max             INT,
	        @min             INT,
	        @riskId_tmp      INT,
	        @list            VARCHAR(8000),
	        @threshold_days  INT,
	        @lastInstanceId  INT,
	        @instanceId      INT,
	        @date            DATETIME 

	
	
	SELECT @activitiesList = '',@dependencyList ='',@max = NULL,@min = NULL,@riskId_tmp = NULL,@list = NULL

	IF @as_of_date is null
		SELECT @as_of_date = dbo.fnagetsqlstandarddate(GETDATE())

	SELECT @date = CAST(@as_of_date AS DATETIME)

	-------------------------------------------Begin : Temproary table creation ----------------------------------
	-- The final ##instance table will hold all the activities which are ready for instance creation.
	SELECT @lastInstanceId = ISNULL(MAX(risk_control_activity_id),0) + 1 FROM process_risk_controls_activities WITH (NOLOCK)
	
	IF OBJECT_ID ('tempdb..##instance') IS NOT NULL 
		DROP TABLE ##instance

	SELECT @stmt = 
	'CREATE TABLE ##instance
	(
		[instanceId] INT IDENTITY('+CAST(@lastInstanceId AS VARCHAR)+',1),
		[riskControlId] INT,
		[nextInstanceCreationDate] DATETIME,
		[exceptionDate] DATETIME,
		[forceBuild] CHAR(1) COLLATE DATABASE_DEFAULT ,
		[parentInstanceId] INT,
		[comments] VARCHAR(MAX) COLLATE DATABASE_DEFAULT ,
		[source] VARCHAR(300) COLLATE DATABASE_DEFAULT ,
		[source_column] VARCHAR(300) COLLATE DATABASE_DEFAULT ,
		[source_id] INT,
		[notification_only] CHAR(1) COLLATE DATABASE_DEFAULT 
	)'
	
	--PRINT @stmt
	
	EXEC(@stmt)
	
	--#temp table used used for getting  the trigger activities for all the activities in the ##instance table.
	--Later the data from #temp table will be appened in the ##instance table.
--	CREATE TABLE #temp (SNO INT IDENTITY,riskID INT)
	-------------------------------------------End : Temproary table creation ----------------------------------

	IF @is_mitigate ='y'
	BEGIN	
		SELECT @threshold_days = a.threshold_days from dbo.process_risk_controls a (nolock)
		where  risk_control_id = (select mitigationActivity from dbo.process_risk_controls where risk_control_id = @risk_control_id)

--		INNER JOIN dbo.process_risk_controls b on a.mitigationActivity = b.risk_control_id
--		WHERE b.risk_control_id = @risk_control_id

	-- whenever the is_mitigated is as 'y', @risk_control_id should not be blank.
	-- whichever instance has been created as a result of mitigation plan, assign force_build as 'm'. 
		INSERT INTO ##instance (riskControlId,nextInstanceCreationDate,exceptionDate,forceBuild,parentInstanceId)
			SELECT  mitigationActivity ,
				dbo.FNANextInstanceCreationDate(mitigationActivity) ,
				DATEADD(dd,@threshold_days,@as_of_date),'m'	,@mitigatedActivityInstanceId
						FROM process_risk_controls(nolock)
					WHERE risk_control_id = @risk_control_id	
		

	END
	ELSE
	BEGIN
	-- Get all the activities and whose  next Instance creation date matches the @as_of_date 
	-- If risk for the one where risk_control_id =@risk_control_id.
		SELECT @stmt = 'INSERT INTO ##instance (
							 riskControlId,
							 nextInstanceCreationDate,
							 exceptionDate,
							 forceBuild,
							 comments,
							 source,
							 source_column,
							 source_id,
							 notification_only
						   )
						 SELECT risk_control_id,
								dbo.FNANextInstanceCreationDate(risk_control_id),
								DATEADD(dd, threshold_days, '''+@as_of_date+'''),
								'''+isnull(@force_build,'n')+''',
								' + CASE WHEN ISNULL(@process_table, '') <> '' THEN 'ISNULL(hyperlink1, '''') + '' '' + ISNULL(hyperlink2, '''') + '' '' + ISNULL(hyperlink3, '''') + '' '' + ISNULL(hyperlink4, '''') + '' '' + ISNULL(hyperlink5, '''')' ELSE 'NULL' END + ',
								' + CASE WHEN ISNULL(@process_table, '') <> '' THEN '' + ISNULL('''' + @source_table + '''', '') + '' ELSE 'NULL' END + ',
								' + CASE WHEN ISNULL(@process_table, '') <> '' THEN '' + ISNULL('''' + @primary_column + '''', '') + '' ELSE 'NULL' END + ',
								' + CASE WHEN ISNULL(@process_table, '') <> '' THEN '' + ISNULL(@primary_column, '') + '' ELSE 'NULL' END + ',
								notificationOnly
						 FROM   process_risk_controls(NOLOCK) prc'
			
			IF @process_table IS NOT NULL
			BEGIN
				SET @stmt = @stmt + ' CROSS APPLY ' + @process_table
			END
			
			SET @stmt = @stmt + ' WHERE  1 = 1 '
			
				
			IF @force_build IS NULL -- i.e if its created from SQL Job
				SELECT @stmt = @stmt + ' and dbo.FNADateFormat(dbo.FNANextInstanceCreationDate(risk_control_id)) = dbo.FNADateFormat('''+@as_of_date+''') 
				and prc.notificationOnly <> ''y'''
			
			IF @risk_control_id is not null and @force_build = 'y' -- i.e if its created forcefully
				SELECT @stmt = @stmt + ' and risk_control_id = '+ @risk_control_id

			--PRINT @stmt
			EXEC (@stmt)	
			
			
	END

			
	-- Get the list of all activities ready for instance creation.
	SELECT @activitiesList = @activitiesList+','+CAST(riskControlId AS VARCHAR) FROM ##instance
		
	-- If the list contains any activity then get the trigger and dependent activities for those activities
--	IF LEN(@activitiesList)>0
--	BEGIN
--					-------------- Begin : Insertion of Trigger and Dependent Activities in the ##instance Table ---------------------
--		INSERT INTO #temp  SELECT item FROM dbo.splitcommaSeperatedValues(@activitiesList)	
--		SELECT @min = MIN(sno),@max=MAX(sno) FROM #temp
--		WHILE (@min < = @max)
--		BEGIN
--			SELECT @riskId_tmp = riskID from #temp where sno = @min
--			
--			-- This CTE will traverse all the trigger activities to the nth level.
--			;WITH TriggerList(List,triggerActivity)
--			AS
--			(
--				SELECT CONVERT(VARCHAR(8000),p.risk_control_id ) [List],triggerActivity FROM process_risk_controls p WHERE risk_control_id  = @riskId_tmp
--				UNION ALL 
--				SELECT [List]+','+CAST(c.triggerActivity AS VARCHAR),p.triggerActivity
--				FROM TriggerList c
--				INNER JOIN process_risk_controls p
--				ON c.triggerActivity = p.risk_control_id
--			)
--			SELECT @activitiesList= List FROM TriggerList
--
--			-- If there is any trigger activities for each of the activity in the ##instance table, append the same to the ##instance table.
--			IF CHARINDEX(',',@activitiesList)>0
--			BEGIN
--				SELECT 	@activitiesList = SUBSTRING(@activitiesList,CHARINDEX(',',@activitiesList)+1,len(@activitiesList))
--
--				INSERT INTO ##instance (riskControlId,forceBuild)
--				SELECT item,'t' FROM dbo.splitcommaSeperatedValues(@activitiesList)
--			END
--			
--			SELECT @activitiesList = NULL	-- Assign NULL to @activitiesList before it gets into another loop.						
--
--			-- This will fetch all the dependent Activities.
--			INSERT INTO ##instance (riskControlId,forceBuild)
--				SELECT item,'d' FROM dbo.splitcommaSeperatedValues(dbo.FNADependencyHierarchy(@riskId_tmp))
--
--			SELECT @min = @min + 1		
--		END		
--					-------------- End : Insertion of Trigger and Dependent Activities in the ##instance Table ---------------------					
--
--		UPDATE a 
--		SET 
--				a.nextInstanceCreationDate = dbo.FNANextInstanceCreationDate(a.riskControlId)
--			   ,a.exceptionDate = DATEADD(dd,p.threshold_days,@as_of_date)
--			FROM ##instance a
--				INNER JOIN 
--			process_risk_controls p
--			ON a.riskControlId = p.risk_control_id 
--			WHERE forceBuild IN ('t','d')		
--	END


	IF EXISTS(SELECT 'X' FROM ##instance) 
	BEGIN
					-------------- Begin : Insertion of Trigger and Dependent Activities in the ##instance Table ---------------------
		SELECT @min = MIN(instanceId),@max=MAX(instanceId) FROM ##instance
		WHILE (@min < = @max)
		BEGIN
			SELECT @instanceId = instanceId,@riskId_tmp = riskControlId FROM ##instance WHERE instanceId = @min
			
			IF @createTrigger = 'y'
			BEGIN
				-- This CTE will traverse all the trigger activities to the nth level.
				;WITH TriggerList(List,triggerActivity)
				AS
				(
					SELECT CONVERT(VARCHAR(8000), p.risk_control_id) [List],
					       triggerActivity
					FROM   process_risk_controls p
					WHERE  risk_control_id = @riskId_tmp
					UNION ALL 
					SELECT [List]+','+CAST(c.triggerActivity AS VARCHAR),p.triggerActivity
					FROM TriggerList c
					INNER JOIN process_risk_controls p
					ON c.triggerActivity = p.risk_control_id
				)
				SELECT @activitiesList = List FROM TriggerList

				-- If there is any trigger activities for each of the activity in the ##instance table, append the same to the ##instance table.
				IF CHARINDEX(',',@activitiesList)>0
				BEGIN
					SELECT 	@activitiesList = SUBSTRING(@activitiesList,CHARINDEX(',',@activitiesList)+1,len(@activitiesList))

					INSERT INTO ##instance (riskControlId,forceBuild,parentInstanceId)
					SELECT item,'t',@instanceId FROM dbo.splitcommaSeperatedValues(@activitiesList)
				END
								
				SELECT @activitiesList = NULL	-- Assign NULL to @activitiesList before it gets into another loop.						
			END
			
			-- This will fetch all the dependent Activities.
			INSERT INTO ##instance (
			    riskControlId,
			    forceBuild,
			    parentInstanceId
			  )
			SELECT item,
			       'd',
			       @instanceId
			FROM   dbo.splitcommaSeperatedValues(dbo.FNADependencyHierarchy(@riskId_tmp))
			
			SELECT @min = @min + 1,@instanceId = NULL
		END		
					-------------- End : Insertion of Trigger and Dependent Activities in the ##instance Table ---------------------					

		UPDATE a 
		SET 
				a.nextInstanceCreationDate = dbo.FNANextInstanceCreationDate(a.riskControlId)
			   ,a.exceptionDate = DATEADD(dd,p.threshold_days,@as_of_date)
			FROM ##instance a
			INNER JOIN process_risk_controls p
			ON a.riskControlId = p.risk_control_id 
			WHERE forceBuild IN ('t','d')		
	END
	
			 			
	--At this point ##instance will have all the activities whose instance will be created.	
	SELECT @stmt = 
	'
	INSERT  INTO process_risk_controls_activities(
	  risk_control_activity_id,
	  risk_control_id,
	  as_of_date,
	  control_status,
	  exception_date,
	  force_build,
	  actualRunDate,
	  mitigatedActivityInstanceId,
	  process_id,
	  Comments,
	  source,
	  source_column,
	  source_id,
	  status
	)
	SELECT instanceId,
	       riskControlId,
	       ''' + @as_of_date + ''',
	       CASE WHEN notification_only = ''y'' THEN 732 ELSE 725 END,
	       exceptionDate,
	       forceBuild,
	       ISNULL(nextInstanceCreationDate, ''' + CAST(@as_of_date AS VARCHAR) + '''),
	       parentInstanceId,
	       ''' + ISNULL(@process_id, '') + ''',
		   Comments,
		   source,
		   source_column,
		   source_id,
		   CASE WHEN notification_only = ''y'' THEN ''c'' ELSE NULL END	       
	FROM  ##instance '
	
	SET @stmt = @stmt + ' WHERE  1 = 1 '
	
	SELECT @stmt  = @stmt + ' AND nextInstanceCreationDate IS NOT NULL '
	
	--PRINT(ISNULL(@stmt, 'is null'))
	EXEC(@stmt)
   
    SELECT @error = @@error,@rowcount = @@rowcount

	-- Post the outstanding messages into the message board
	EXEC spa_get_activities_info @date,'o',@process_table

	IF @showOutput = 'y'
	BEGIN
		IF @error <> 0 
			EXEC spa_ErrorHandler @error,
			     'Compliance Management',
			     'Instance Creation',
			     'DB Error',
			     'Activity Instance Creation Failed.',
			     ''
		ELSE 
		BEGIN
			IF @rowcount > 0
				EXEC spa_ErrorHandler 0,
				     'Compliance Management',
				     'Instance Creation',
				     'Success',
				     'Activity Instance Created Successfully.',
				     ''
			ELSE
				EXEC spa_ErrorHandler -1,
				     'Compliance Management',
				     'Instance Creation',
				     'Error',
				     'Instance can not be created. Activity out of range.',
				     ''
		END
	END
		
	-- Call spa for communication.
	EXEC spa_get_outstanding_control_activities_job @as_of_date = @as_of_date, @process_table = @process_table	
END

GO


