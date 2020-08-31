

/*
Author : Vishwas Khanal
Desc   : Rewrote the SP for reminders and other Communication.
Dated  : 12.July.2009
*/
IF OBJECT_ID('[dbo].[spa_get_outstanding_control_activities_job]','p') IS NOT NULL
    DROP PROCEDURE [dbo].[spa_get_outstanding_control_activities_job]
GO

-- exec spa_get_outstanding_control_activities_job '08/14/2008'

CREATE PROCEDURE [dbo].[spa_get_outstanding_control_activities_job]
	@as_of_date DATETIME ,
	@risk_control_id INT = NULL,
	@message VARCHAR(1000) = NULL, -- The message to be displayed in the message board.
	@mailbody VARCHAR(MAX) = NULL,
	@source_id INT = NULL,
	@risk_control_activity_id INT = NULL,
	@process_table VARCHAR(400) = NULL
AS 
SET NOCOUNT ON
BEGIN
    DECLARE @std_as_of_date VARCHAR(20)
    
	SELECT  @std_as_of_date = @as_of_date

    IF ( SELECT var_value
         FROM   adiha_default_codes_values
         WHERE  instance_no = 1
                AND default_code_id = 24
                AND seq_no = 1
       ) = 0 
        BEGIN
            --PRINT 'Show outstanding values turned off.'
            RETURN
        END

	CREATE TABLE #pendingMessages
	(
		[user_login_id] [varchar](50) COLLATE DATABASE_DEFAULT  NOT NULL,
		[source] [varchar](50) COLLATE DATABASE_DEFAULT  NOT NULL,
		[description] [varchar](8000) COLLATE DATABASE_DEFAULT  NOT NULL,
		[url_desc] [varchar](8000) COLLATE DATABASE_DEFAULT  NULL,
		[url] [varchar](8000) COLLATE DATABASE_DEFAULT  NULL,
		[type] [char](1) COLLATE DATABASE_DEFAULT  NOT NULL,
		[job_name] [varchar](100) COLLATE DATABASE_DEFAULT  NULL,
		[as_of_date] [datetime] NULL,
		[create_ts] [datetime] NULL,
		[reminderDate] [varchar](8000) COLLATE DATABASE_DEFAULT  NULL,
		[communication_type] [int] NULL,	
		[instanceID] [int] NULL	
	
	) 
	
	DECLARE @source_id_varchar VARCHAR(200)
	SET @source_id_varchar = @source_id
		
	--NOTIFIED
	;WITH notifiedCTE(user_login_id,entity_name,as_of_date,reminderDate,controlStatus,source,instanceId,comments,communication_type,create_ts,errorStatus,source_id, risk_control_description)
	AS(
		SELECT DISTINCT
		       CASE 
		            WHEN prce.inform_role IS NULL THEN COALESCE(prce.inform_user, prc.perform_user, dbo.FNADBUser())
		            ELSE ISNULL(aru.user_login_id, dbo.FNADBUser())
		       END 'user_login_id',
		       dbo.FNAGetSubsidiary(prc.fas_book_id, 'n') entity_name,
		       --dbo.FNASQLDateformat(as_of_date)  +' ' + CONVERT(CHAR(8),getdate(),8) 'as_of_date',
		       @as_of_date 'as_of_date',
		       --dbo.FNAgetSQLStandardDate(as_of_date)+'-'+aru.user_login_id+'-'+'Notified'+':'+CAST(prca.risk_control_activity_id AS VARCHAR) reminderDate,
		       dbo.FNAgetSQLStandardDate(as_of_date) + '-' +
		       CASE 
		            WHEN prce.inform_role IS NULL THEN ISNULL(prce.inform_user, prc.perform_user)
		            ELSE aru.user_login_id
		       END
		       + '-' + 'Notified' + ':' + CAST(prca.risk_control_activity_id AS VARCHAR) 
		       reminderDate,
		       prca.control_status [controlStatus],
		       prca.source,
		       prca.risk_control_activity_id 'instanceId',
		       comments,
		       prce.communication_type,
		       prca.create_ts,
		       [status],
		       source_id,
		       prc.risk_control_description
		FROM   process_risk_controls prc
			INNER JOIN process_risk_controls_activities prca
				ON prc.risk_control_id = prca.risk_control_id
			LEFT OUTER JOIN process_risk_controls_email prce 
				ON prc.risk_control_id=prce.risk_control_id
				 AND prca.risk_control_id=prce.risk_control_id
				 AND prca.control_status = prce.control_status
			LEFT JOIN application_role_user aru 
				ON CAST(aru.role_id AS VARCHAR) LIKE 
					CASE WHEN prce.inform_role IS NULL AND prce.inform_user IS NULL
							THEN ISNULL(CAST(prc.perform_role AS VARCHAR),'%')
						 ELSE
							ISNULL(CAST(prce.inform_role AS VARCHAR),'%') END
				AND aru.user_login_id LIKE 
					CASE WHEN prce.inform_role IS NULL AND prce.inform_user IS NULL
							THEN ISNULL(prc.perform_user,'%') 
						 ELSE
							ISNULL(prce.inform_user,'%') END		
		WHERE prca.control_status = 732 AND
			prca.as_of_date =CAST(dbo.FNAgetSQLStandardDate(@as_of_date) AS DATETIME)--CAST(dbo.FNADateFormat(@as_of_date) as datetime)
			AND prce.communication_type in (757,751,752,750)
			AND prc.notificationOnly = 'y'					
			AND comments IS NOT NULL 	
			AND ((source_id = @source_id_varchar AND @source_id_varchar IS NOT NULL) OR @source_id_varchar IS NULL)
			AND ((prca.risk_control_activity_id = @risk_control_activity_id	AND @risk_control_activity_id IS NOT NULL) OR @risk_control_activity_id IS NULL)
	)			
			
	INSERT  INTO #pendingMessages
	(
	  user_login_id,
	  source,
	  [description],
	  url_desc,
	  url,
	  type,
	  job_name,
	  as_of_date,
	  reminderDate,
	  communication_type,
	  create_ts,
	  instanceID		  
	)
	SELECT  DISTINCT
			user_login_id,
			CASE 
				WHEN source IS NOT NULL AND source IN ('Deal','Deal.Notification','Import.Allowance','Import.Data','Import.Activity', 'HedgeRel.Approve', 'HedgeRel.Finalize') THEN x.source
				ELSE 'RiskControl.Notification'	
			END [source],
			CASE 
				WHEN source  IS NOT NULL AND source IN ('Deal','Deal.Notification','Import.Allowance','Import.Data','Import.Activity', 'HedgeRel.Approve', 'HedgeRel.Finalize') THEN x.comments
				ELSE 'Notification.' + risk_control_description
			END [description],			
			CASE  
				WHEN source IN ('Deal', 'Deal.Notification','Import.Data', 'HedgeRel.Approve', 'HedgeRel.Finalize') THEN NULL  --,  
				WHEN source  IN ('Import.Activity','Import.Allowance') THEN 'View..'					
				ELSE 'Detail...' 
			END,
			CASE  WHEN source IN ('Import.Activity','Import.Allowance') THEN 
				'dev/spa_html.php?__user_name__=' + user_login_id + '&spa=exec spa_get_import_process_status ''' + source_id + ''','''+user_login_id+''''+ ''
				ELSE
			( 'dev/spa_html_complaince_status_1.1.php?spa=exec spa_read_status_control_activities '''
			  + user_login_id + ''',
				''' +  SUBSTRING(x.reminderDate,1,10)
			  + ''',NULL,NULL,NULL,NULL,728,NULL,NULL,NULL,NULL,NULL,
				NULL,NULL,NULL,NULL,NULL,NULL,''n'',NULL,NULL,NULL,NULL,NULL,
			  NULL,NULL,NULL,''v'','+CAST(instanceId AS VARCHAR)+'&__user_name__=' + user_login_id ) 
			END, 
			errorstatus,
			NULL,
			x.as_of_date,
			x.reminderDate,
			x.communication_type,
			x.create_ts,
			x.instanceId           
	FROM   notifiedCTE x
	WHERE NOT EXISTS(SELECT  m.reminderDate FROM message_board m WHERE x.reminderDate = m.reminderDate)		

	-- Send it to mail.
	INSERT INTO [email_notes]
			   ([internal_type_value_id],[category_value_id],notes_object_name,notes_object_id,[send_status],active_flag
				,[notes_subject]
			   ,[notes_text]
			   ,[send_from]
			   ,[send_to]
	   )
	SELECT 3,4,'lll',1,'n','y',dbo.FNAReplaceTagInText('time', @message, 'y'),ISNULL(@mailbody,''),	'no-reply@pioneersolutions.us',user_emal_add 
	FROM #pendingMessages e 
		INNER JOIN application_users a
			ON e.user_login_id  = a.user_login_id
	WHERE user_emal_add IS NOT NULL
		AND communication_type in (750,752)		

	-- Send it to message board				
	INSERT INTO message_board
		(user_login_id,
		source,
		[description],
		url_desc,
		url,
		type,
		job_name,
		as_of_date,			
		reminderDate,
		source_id)
	SELECT 	user_login_id,
		source,
		[description],
		url_desc,
		url,
		type,
		job_name,
		create_ts,		
		reminderDate,
		'cmp-'+CAST(instanceId AS VARCHAR)
	FROM #pendingMessages	
	WHERE communication_type in (757, 751,752)						
	
	UPDATE process_risk_controls_activities
	SET control_status = 728
	FROM #pendingMessages pm
	INNER JOIN process_risk_controls_activities prca ON prca.risk_control_activity_id = pm.instanceID
		
	--OTHERS
	;WITH othersCTE(user_login_id,entity_name,as_of_date,reminderDate,controlStatus,requires_approval,create_ts,risk_control_activity_id,risk_control_description)
	AS(
		SELECT 
			DISTINCT 
			CASE 
				WHEN prce.inform_role IS NULL THEN ISNULL(prce.inform_user, prc.perform_user) ELSE aru.user_login_id 
			END 'user_login_id',
			dbo.FNAGetSubsidiary(prc.fas_book_id,'n') entity_name,
			dbo.FNADateformat(as_of_date) 'as_of_date',
			--dbo.FNAgetSQLStandardDate(as_of_date)+'-'+aru.user_login_id+'-'+
			dbo.FNAgetSQLStandardDate(as_of_date)+'-'+
			CASE 
				WHEN prce.inform_role IS NULL THEN ISNULL(prce.inform_user, prc.perform_user) ELSE aru.user_login_id 
			END
			+'-'+
			CASE prca.control_status 						
				 WHEN 726 THEN 'UnApproved'
				 WHEN 728 THEN 'Completed'
				 WHEN 729 THEN 'Approved'
				 WHEN 730 THEN 'Mitigated'
			END +'-'+CAST(risk_control_activity_id AS VARCHAR) reminderDate,
			prca.control_status [controlStatus],requires_approval,isnull(prca.update_ts,prca.create_ts),risk_control_activity_id,risk_control_description
		FROM 
			process_risk_controls prc
			INNER JOIN process_risk_controls_activities prca
				ON prc.risk_control_id = prca.risk_control_id
			INNER JOIN process_risk_controls_email prce 
				ON prc.risk_control_id=prce.risk_control_id
				AND prca.risk_control_id=prce.risk_control_id
				AND prca.control_status = prce.control_status
			LEFT JOIN application_role_user aru 
				ON CAST(aru.role_id AS VARCHAR) LIKE ISNULL(CAST(prce.inform_role AS VARCHAR),'%') 
			AND aru.user_login_id LIKE  ISNULL(prce.inform_user,'%') 
		WHERE prca.control_status IN(726,728,729,730) AND
				prca.as_of_date = CAST(dbo.FNAgetSQLStandardDate(@as_of_date) AS DATETIME)
				AND prce.communication_type in (751,752,756,750)					
		)	
		INSERT INTO message_board (
		    user_login_id,
		    source,
		    [description],
		    url_desc,
		    URL,
		    TYPE,
		    job_name,
		    as_of_date,
		    reminderDate,
		    source_id
		  )
		SELECT  DISTINCT
			user_login_id,
			CASE x.controlStatus 					
				 WHEN 726 THEN 'RiskControl.UnApproved'
				 WHEN 728 THEN 'RiskControl.Completed'
				 WHEN 729 THEN 'RiskControl.Approved'
				 WHEN 730 THEN 'RiskControl.Mitigated'							 
			END [source],
			'<i>'+risk_control_description +'</i>'+ 
			CASE x.controlStatus 						 
				 WHEN 726 THEN ' has been unapproved.'
				 WHEN 728 THEN	
				 			CASE x.requires_approval 
				 				WHEN 'y' THEN  ' has to be approved.' 
								ELSE ' has been completed.' 
				 			END															
				 WHEN 729 THEN ' has been approved.'
				 WHEN 730 THEN ' has been mitigated.'
			END [description],
			'Proceed...',
			( 'dev/spa_html_complaince_status_1.1.php?spa=exec spa_read_status_control_activities ''' + user_login_id + ''',
			''' + SUBSTRING(x.reminderDate,1,10)+ ''', NULL, NULL, NULL, NULL, ' 
			+ CAST(x.controlStatus AS VARCHAR) + ',NULL, NULL, NULL, NULL, NULL,
			NULL, NULL, NULL, NULL, NULL, NULL, ''n'', NULL, NULL, NULL, NULL, NULL,
			NULL, NULL, NULL, NULL, '
			+ CAST(x.risk_control_activity_id AS VARCHAR) + '&__user_name__=' + user_login_id ),
			'a',
			NULL,
			x.create_ts,
			x.reminderDate,
			'cmp-' + CAST(x.risk_control_activity_id  AS VARCHAR)           
		FROM  othersCTE x	
		WHERE NOT EXISTS(SELECT  m.reminderDate FROM message_board m WHERE x.reminderDate = m.reminderDate)		
END -- End of the procedure
								
