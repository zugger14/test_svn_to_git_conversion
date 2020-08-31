
/*
Author : Vishwas Khanal
Desc   : This SP will fetch the info about reminders,activities which exceeded threshold days and Pending mitigation activities
Dated  : 11.March.2010
*/
IF OBJECT_ID('[dbo].[spa_get_activities_info]','p') IS NOT NULL
    DROP PROCEDURE [dbo].[spa_get_activities_info]
GO
-- exec spa_get_activities_info '08/14/2008'
CREATE PROCEDURE [dbo].[spa_get_activities_info]
	@as_of_date DATETIME, -- VARCHAR(20),
	@flag CHAR(1) = NULL, -- 'o' - outstanding(called from spa_Create_Daily_Risk_Control_Activities)
	@process_table VARCHAR(400) = NULL,
	@source VARCHAR(300) = NULL,
	@source_column VARCHAR(300) = NULL,
	@source_id INT = NULL

AS 
BEGIN
--	DECLARE @activityId INT
--	SELECT @activityId = 64

    DECLARE @std_as_of_date VARCHAR(20)
	SELECT  @std_as_of_date = @as_of_date

    IF (SELECT var_value FROM   adiha_default_codes_values WHERE  instance_no = 1 AND default_code_id = 24 AND seq_no = 1) = 0
    BEGIN
        --PRINT 'Show outstanding values turned off.'
        RETURN
    END
    
	CREATE TABLE #pendingMessages (
		[user_login_id] [varchar](50) COLLATE DATABASE_DEFAULT NOT NULL,
		[source] [varchar](50) COLLATE DATABASE_DEFAULT NOT NULL,
		[description] [varchar](8000) COLLATE DATABASE_DEFAULT NOT NULL,
		[url_desc] [varchar](8000) COLLATE DATABASE_DEFAULT NULL,
		[url] [varchar](500) COLLATE DATABASE_DEFAULT NULL,
		[type] [char](1) COLLATE DATABASE_DEFAULT NOT NULL,
		[job_name] [varchar](100) COLLATE DATABASE_DEFAULT NULL,
		[as_of_date] [datetime] NULL,
		[create_ts] [datetime] NULL,
		[reminderDate] [varchar](8000) COLLATE DATABASE_DEFAULT NULL,
		[communication_type] [int] NULL,	
		[instanceID] [int] NULL	
	)
	
	DECLARE @sql VARCHAR(MAX)
	
	IF @flag = 'o' 
	BEGIN
		-- OUTSTANDING
		SET @sql = ';WITH othersCTE(user_login_id,entity_name,as_of_date,reminderDate,controlStatus,risk_control_description,create_ts,risk_control_activity_id,risk_control_id,activity_type, source, source_column, source_id)
					 AS(
						SELECT DISTINCT ISNULL(aru.user_login_id, au.user_login_id) [user_login_id],
						       dbo.FNAGetSubsidiary(prc.fas_book_id, ''n'') 
						       entity_name,
						       dbo.FNADateformat(as_of_date) ''as_of_date'',
						       dbo.FNAgetSQLStandardDate(as_of_date) + ''-'' + ISNULL(aru.user_login_id, au.user_login_id)
						       + ''-'' +
						       ''Outstanding-'' + CAST(prca.risk_control_activity_id AS VARCHAR) 
						       [reminderDate],
						       control_status [controlStatus],
						       (risk_control_description + '' '' + ISNULL(prca.Comments, '''')) risk_control_description,
						       prca.create_ts,
						       prca.risk_control_activity_id,
						       prc.risk_control_id,
						       prc.activity_type,
						       prca.source,
						       prca.source_column,
						       prca.source_id
						FROM   process_risk_controls prc
						INNER JOIN process_risk_controls_activities prca
						    ON  prc.risk_control_id = prca.risk_control_id
						LEFT JOIN application_role_user aru
				            ON  CAST(aru.role_id AS VARCHAR) LIKE ISNULL(CAST(prc.perform_role AS VARCHAR), ''%'')
				            AND aru.user_login_id LIKE ISNULL(prc.perform_user, ''%'')
				        LEFT JOIN application_users au ON au.user_login_id = ISNULL(prc.perform_user, dbo.FNADBUser())
						WHERE prca.control_status = 725 
						AND prca.as_of_date = CAST(dbo.FNAgetSQLStandardDate(''' + CONVERT(VARCHAR(10), @as_of_date, 120) + ''') AS DATETIME) -- time not required from @as_of_date												
						AND prc.notificationOnly = ''n''
						AND ' + CASE WHEN @source IS NOT NULL THEN ' prca.source = ''' + @source + ''' AND prca.source_column = ''' + @source_column + ''' AND prca.source_id = ''' + CAST(@source_id AS VARCHAR(10)) + ''''
						             ELSE ' 1 = 1 '
						        END + '  				
					)

					INSERT INTO message_board (user_login_id, source, [description], url_desc, URL, TYPE, job_name, as_of_date, reminderDate, source_id)
					SELECT  DISTINCT
							user_login_id,
							''RiskControl.Outstanding'' [source],					
							risk_control_description,
							CASE x.activity_type
							     WHEN 13700 THEN dbo.FNAComplianceHyperlink(
							              ''n'',
							              10232700,
							              ''Import Data File'',
							              DEFAULT,
							              DEFAULT,
							              DEFAULT,
							              DEFAULT,
							              DEFAULT,
							              DEFAULT,
							              DEFAULT
							          )
							     WHEN 13701 THEN dbo.FNAComplianceHyperlink(
							              ''n'',
							              10131500,
							              ''Import Allowance File'',
							              DEFAULT,
							              DEFAULT,
							              DEFAULT,
							              DEFAULT,
							              DEFAULT,
							              DEFAULT,
							              DEFAULT
							          )
							     ELSE ''Proceed...''
							END ,				
							CASE 
							     WHEN x.activity_type IN (13700, 13701) THEN NULL
							     ELSE (''dev/spa_html_complaince_status_1.1.php?spa=exec spa_read_status_control_activities '''''' + user_login_id + '''''','''''' + + x.as_of_date + 
										'''''',NULL,NULL,NULL,NULL,725,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,''''n'''',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'' + CAST(x.risk_control_activity_id AS VARCHAR) + '',' + COALESCE('''''' + @process_table + '''''', 'NULL') + ','' + COALESCE('''''''' + x.source_column + '''''''', ''NULL'') + '','' + COALESCE(x.source_id, ''NULL'') + ''&__user_name__='' + user_login_id)
							END,
							''a'',
							NULL,
							x.create_ts,
							x.reminderDate,  
							''cmp-''+CAST(x.risk_control_activity_id  AS VARCHAR)         						
					FROM  othersCTE x
					WHERE NOT EXISTS(SELECT  m.reminderDate FROM message_board m WHERE x.reminderDate = m.reminderDate)	'
			--PRINT(@sql)
			EXEC(@sql)
	END
	ELSE
	BEGIN
		-- REMINDER
		;WITH reminderCTE(user_login_id,entity_name,as_of_date,reminderDate,no_of_days,risk_control_id)
		 AS(
			SELECT DISTINCT
				   ISNULL(aru.user_login_id, au.user_login_id) [user_login_id],
				   dbo.FNAGetSubsidiary(prc.fas_book_id, 'n') 'entity_name',
				   dbo.FNANextInstanceCreationDate(prc.risk_control_id) 'as_of_date',
				   dbo.FNAgetSQLStandardDate(DATEADD(dd, -prce.no_of_days, dbo.FNANextInstanceCreationDate(prce.risk_control_id))) + '-' + ISNULL(aru.user_login_id, au.user_login_id) + '-reminder' [reminderDate],
				   prce.no_of_days 'no_of_days',
				   prc.risk_control_id
			FROM   process_risk_controls prc
			INNER JOIN process_risk_controls_email prce ON  prc.risk_control_id = prce.risk_control_id
			LEFT JOIN application_role_user aru
				ON  CAST(aru.role_id AS VARCHAR) LIKE ISNULL(CAST(prc.perform_role AS VARCHAR), '%')
				AND aru.user_login_id LIKE ISNULL(prc.perform_user, '%')
			LEFT JOIN application_users au ON au.user_login_id = ISNULL(prc.perform_user, dbo.FNADBUser()) 
			WHERE  DATEADD(dd,-prce.no_of_days,dbo.FNANextInstanceCreationDate(prce.risk_control_id)) = CAST(dbo.FNAgetSQLStandardDate(@as_of_date) AS DATETIME) --CAST(@as_of_date AS DATETIME)
				   AND prce.control_status = -5
				   AND prce.communication_type IN (751, 752)
				   AND dbo.FNANextInstanceCreationDate(prc.risk_control_id) IS NOT NULL
				   AND NOT EXISTS (
						   SELECT risk_control_reminder_id
						   FROM process_risk_controls_reminders_acknowledge ack
						   WHERE  ack.risk_control_reminder_id = prce.risk_control_email_id
					   )
			)
			INSERT INTO message_board (user_login_id, source, [description], url_desc, URL, TYPE, job_name, as_of_date, reminderDate)
			SELECT  DISTINCT user_login_id,
					'RiskControl.Reminders',
					'Activities reminder(s) you to perform on : '+ CAST(dbo.FNADateformat(DATEADD(d,no_of_days,@as_of_date)) AS VARCHAR),
					'Proceed...',
					( './run_process_control_activities.php? as_of_date='+dbo.FNAgetSQLStandardDate(dbo.FNANextInstanceCreationDate(x.risk_control_id))
					  + '&frequency_id=NULL&risk_priority_id=NULL&user_id=' + user_login_id + '&role_id=NULL&unapproved_flag=R&Retrieve=Retrieve&__user_name__=' + user_login_id 
					 ),
					'a',
					NULL,
					@as_of_date,
					x.reminderDate
			FROM   reminderCTE x
			WHERE NOT EXISTS(SELECT  m.reminderDate FROM message_board m WHERE x.reminderDate = m.reminderDate)
			
			--EXCEEDS THRESHOLD DAYS
			;WITH othersCTE(user_login_id,entity_name,as_of_date,reminderDate,controlStatus)
			AS(
						SELECT 
							DISTINCT 
							ISNULL(aru.user_login_id, au.user_login_id) [user_login_id],
							dbo.FNAGetSubsidiary(prc.fas_book_id,'n') entity_name,
							 dbo.FNADateformat(as_of_date) 'as_of_date',
							dbo.FNAgetSQLStandardDate(as_of_date)+'-'+ ISNULL(aru.user_login_id, au.user_login_id) +'-'+'Exception' reminderDate,
							prca.control_status [controlStatus]
							FROM 
							 process_risk_controls prc
							INNER JOIN process_risk_controls_activities prca
								ON prc.risk_control_id = prca.risk_control_id
							INNER JOIN process_risk_controls_email prce 
								ON prc.risk_control_id=prce.risk_control_id						 
							LEFT JOIN application_role_user aru
								ON  CAST(aru.role_id AS VARCHAR) LIKE ISNULL(CAST(prc.perform_role AS VARCHAR), '%')
								AND aru.user_login_id LIKE ISNULL(prc.perform_user, '%')
							LEFT JOIN application_users au ON au.user_login_id = ISNULL(prc.perform_user, dbo.FNADBUser())
							WHERE prca.control_status = 725 	
							AND prce.control_status = 733 					
							AND prca.exception_date<CAST(dbo.FNAgetSQLStandardDate(@as_of_date) AS DATETIME)
							AND prce.communication_type in (751,752)										
				)	
				
				INSERT INTO message_board (user_login_id, source, [description], url_desc, URL, TYPE, job_name, as_of_date, reminderDate)
				SELECT  DISTINCT
						user_login_id,
						'RiskControl.Exception' [source],
						'Activity has crossed threshold days.' [description],
						'Proceed...',
						( 'dev/spa_html_complaince_status_1.1.php?spa=exec spa_read_status_control_activities '''
						  + user_login_id + ''',''' + SUBSTRING(x.reminderDate,1,10)
						  + ''',NULL,NULL,NULL,NULL,'+CAST(733 AS VARCHAR)+',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,''n'',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,''v''&__user_name__=' + user_login_id 
						),
						'a',
						NULL,
						@as_of_date,
						x.reminderDate             
				FROM othersCTE x
				WHERE NOT EXISTS(SELECT  m.reminderDate FROM message_board m WHERE x.reminderDate = m.reminderDate)					

				--Pending Mitigation
				;WITH othersCTE(user_login_id,entity_name,as_of_date,reminderDate,controlStatus,requires_approval)
				AS(
						SELECT DISTINCT 
							   ISNULL(aru.user_login_id, au.user_login_id) 
							   [user_login_id],
							   dbo.FNAGetSubsidiary(prc.fas_book_id, 'n') 
							   entity_name,
							   dbo.FNADateformat(as_of_date) 'as_of_date',
							   dbo.FNAgetSQLStandardDate(as_of_date) + '-' + ISNULL(aru.user_login_id, au.user_login_id)
							   + '-' +
							   CASE prca.control_status
									WHEN 731 THEN 'PendingMitigation'
							   END reminderDate,
							   prca.control_status [controlStatus],
							   requires_approval
						FROM   process_risk_controls prc
						INNER JOIN process_risk_controls_activities prca ON  prc.risk_control_id = prca.risk_control_id
						INNER JOIN process_risk_controls_email prce
							ON  prc.risk_control_id = prce.risk_control_id
							AND prca.risk_control_id = prce.risk_control_id
							AND prca.control_status = prce.control_status
						LEFT JOIN application_role_user aru
							ON  CAST(aru.role_id AS VARCHAR) LIKE ISNULL(CAST(prc.perform_role AS VARCHAR), '%')
							AND aru.user_login_id LIKE ISNULL(prc.perform_user, '%')
						LEFT JOIN application_users au ON  au.user_login_id = ISNULL(prc.perform_user, dbo.FNADBUser())
						WHERE  prca.control_status = 731
							   AND prca.as_of_date <= @as_of_date
							   AND prce.communication_type IN (751, 752, 756, 750)					
				)	
				INSERT INTO message_board (user_login_id, source, [description], url_desc, URL, TYPE, job_name, as_of_date, reminderDate)
				SELECT  DISTINCT
						user_login_id,						
						'RiskControl.Pending Mitigation',							 
						'Activity is pending for mitigation.' [description],
						'Proceed...',
						('dev/spa_html_complaince_status_1.1.php?spa=exec spa_read_status_control_activities ''' + user_login_id + ''',''' + SUBSTRING(x.reminderDate,1,10)
						 + ''',NULL,NULL,NULL,NULL,'+CAST(x.controlStatus AS VARCHAR)+',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,''n'',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,''v''&__user_name__=' + user_login_id 
						),
						'a',
						NULL,@as_of_date,
						x.reminderDate             
				FROM  othersCTE x
				WHERE NOT EXISTS(SELECT  m.reminderDate FROM message_board m WHERE x.reminderDate = m.reminderDate)					
			END -- End of the procedure
	END
