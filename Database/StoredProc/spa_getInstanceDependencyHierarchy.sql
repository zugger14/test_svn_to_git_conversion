

IF OBJECT_ID('[dbo].[spa_getInstanceDependencyHierarchy]','p') IS NOT NULL
DROP PROC [dbo].[spa_getInstanceDependencyHierarchy]
GO
/*
Author : Vishwas Khanal
Dated  : 14.Aug.2009
Desc   : This will get the instance dependency hierarchy when the instance Id is passed.
		 Triggered on click of '+' sign in the View Activity Status UI.
*/
--exec dbo.spa_getInstanceDependencyHierarchy 1
CREATE PROC [dbo].[spa_getInstanceDependencyHierarchy]
@instanceId					INT,
@as_of_date					VARCHAR(50) = NULL,
@as_of_date_to				VARCHAR(50) = NULL
AS
BEGIN
	
	DECLARE 
			@actDependency				VARCHAR(8000), 
			@insDependency				VARCHAR(8000),
			@activityName				VARCHAR(500) ,
			@activity					INT			 , 
			@min						INT			 , 
			@max						INT			 ,
			@risk_control_dependency_id INT
			
	IF @as_of_date IS NULL 
		SELECT @as_of_date = dbo.FNAGetSQLStandardDate('1900-01-01')

	IF @as_of_date_to IS NULL 
		SELECT @as_of_date_to = GETDATE()

	CREATE TABLE #tmp (sno INT IDENTITY(1,1),Item VARCHAR(500) COLLATE DATABASE_DEFAULT)

	CREATE TABLE #dependency 
	(
		dependency_id			INT			,
		instanceId				INT			,
		ActivityIdHierarchy     VARCHAR(500) COLLATE DATABASE_DEFAULT,
		risk_control_id			INT			,
		hierarchy				VARCHAR(500) COLLATE DATABASE_DEFAULT,
		[level]					INT			,		
		dependentDependencyId   INT			,
		haveRights				INT			,
		as_of_date				DATETIME	,
		status					VARCHAR(100) COLLATE DATABASE_DEFAULT,
		[nextAction]			VARCHAR(100) COLLATE DATABASE_DEFAULT
	)
	
	-- Get the activity Id dependent on the @activity @instanceId
	SELECT @insDependency = ISNULL(@insDependency+',','') + CAST(risk_control_activity_id AS VARCHAR) FROM dbo.process_risk_controls_activities WHERE mitigatedActivityInstanceId = @instanceId

	-- Get the activityId,activityName and risk_control_dependency_id for the passed instance Id.
	SELECT @activity = risk_control_id  FROM dbo.process_risk_controls_activities(nolock) WHERE risk_control_activity_id = @instanceId	
	SELECT @activityName = risk_control_description FROM dbo.process_risk_controls(nolock) WHERE risk_control_id = @activity
	SELECT @risk_control_dependency_id = risk_control_dependency_id 
				FROM dbo.process_risk_controls_dependency (nolock) 
					WHERE risk_control_id = @activity
					  AND risk_control_id_depend_on IS NULL
	

	INSERT INTO #dependency SELECT @risk_control_dependency_id,@instanceId,@activity,@activity,@activityName,0,NULL,1,NULL,NULL,NULL

	INSERT INTO #tmp SELECT @instanceId	
	INSERT INTO #tmp SELECT item FROM dbo.splitCommaSeperatedValues(@insDependency)
	
	SELECT @min = MIN(sno),@max = MAX(sno) FROM #tmp 	

	WHILE @min<=@max
	BEGIN
		SELECT @instanceId = Item FROM #tmp WHERE sno = @min
		SELECT @activity = risk_control_id FROM dbo.process_risk_controls_activities(nolock) WHERE risk_control_activity_id = @instanceId		

		;WITH CTE(DependencyId,ActivityId,ActivityIdHierarchy,List,dependson,Activity,Lvl)
		AS
		(
			SELECT a.risk_control_dependency_id [DependencyId],CONVERT(VARCHAR(8000),a.risk_control_id) 'ActivityId',
			CONVERT(VARCHAR(8000),a.risk_control_id) 'ActivityIdHierarchy',
			CONVERT(VARCHAR(8000),a.risk_control_id) AS [list],CONVERT(VARCHAR(8000),a.risk_control_id_depend_on) AS [dependson],CONVERT(VARCHAR(8000),p.risk_control_description) [Activity],0 as Lvl  
			FROM process_risk_controls_dependency  a 		
				INNER JOIN process_risk_controls p ON p.risk_control_id = a.risk_control_id 
					WHERE a.risk_control_id  = @activity AND risk_control_id_depend_on IS NOT NULL
			UNION ALL
			SELECT a.DependencyId [DependencyId],CONVERT(VARCHAR(8000),a.ActivityId) 'ActivityId',
			ActivityIdHierarchy+','+CONVERT(VARCHAR(8000),b.risk_control_id) 'ActivityIdHierarchy',
			[List]+','+ CONVERT(VARCHAR(8000),b.risk_control_id) AS [list] ,CONVERT(VARCHAR(8000),b.risk_control_id_depend_on) as [dependson],[Activity] + ','+ CONVERT(VARCHAR(8000),risk_control_description) [Activity], Lvl + 1
				FROM process_risk_controls_dependency b 
				INNER JOIN process_risk_controls p ON p.risk_control_id = b.risk_control_id 
				INNER JOIN CTE a ON  a.[dependson] = CAST(b.risk_control_dependency_id AS VARCHAR)
				WHERE risk_control_id_depend_on IS NOT NULL
		)
			INSERT INTO #dependency 
				SELECT DependencyId,@instanceId,ActivityIdHierarchy,ActivityId,Activity,Lvl,NULL,1,null,NULL,NULL FROM CTE c											
					WHERE dependson IS NULL
						--ORDER BY ActivityIdHierarchy ASC

		SELECT @min = @min + 1
	END
							
	-- Update the dependent dependencyId for all the instances.
	UPDATE  d 
		SET dependentDependencyId = risk_control_id_depend_on
			FROM #dependency d 
				INNER JOIN process_risk_controls_dependency prcd
			ON d.dependency_id = prcd.risk_control_dependency_id 
				WHERE risk_control_id_depend_on IS NOT NULL
	
	-- Update #dependency.as_of_date for all the instances.
	UPDATE  d 
			SET as_of_date = prca.as_of_date
				FROM #dependency d 
					INNER JOIN process_risk_controls_activities prca
				ON d.instanceId = prca.risk_control_activity_id

	-- Update #dependency.status of all the instances.					
	UPDATE  d
			SET status = sdv.code
				FROM #dependency d
					INNER JOIN process_risk_controls_activities prca
				ON d.instanceId = prca.risk_control_activity_id
					INNER JOIN static_data_value sdv
				ON sdv.type_id = 725	
					AND sdv.value_id = prca.control_status

	-- dependency is traversed from bottom to top. This has to be reversed to show it in the top to bottom format.
	UPDATE #dependency SET hierarchy = REPLACE(dbo.FNAReverseCommaSeparatedString(hierarchy),',','|')+'|'
	UPDATE #dependency SET ActivityIdHierarchy = REPLACE(dbo.FNAReverseCommaSeparatedString(ActivityIdHierarchy),',','|')+'|'
	
	
	-- Output
	SELECT dependency_id as 'risk_control_dependency_id',			
		   dbo.FNAComplianceHyperlink('f',10101125,hierarchy,'333',CAST(risk_control_id AS VARCHAR),1,DEFAULT,DEFAULT,@as_of_date,@as_of_date_to) as 'entity_name', 
		   haveRights 'have_rights',
		   [level],
		   dependentDependencyId as 'risk_control_id_depend_on',
		   dbo.FNAComplianceHyperlink('b',367,status, CAST(risk_control_id AS VARCHAR),dbo.FNADateFormat(as_of_date),default,default,default,default,default) AS [Status], 
		   dbo.FNAComplianceActivityStatus(instanceId,'y',@as_of_date, @as_of_date_to, [level]) 'action'
		FROM #dependency ORDER BY ActivityIdHierarchy ASC
			
END
