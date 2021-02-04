IF OBJECT_ID(N'[dbo].[spa_calendar]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[spa_calendar]
GO
 
SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO

/**
	Calendar CRUDs

	Parameters
	@flag : Flag
			'a' -- Lists alert
			'b' -- Creates workflow instance for events
			'c' -- Lists events
			'd' -- Delete events
			'e' -- Share calendar
			'f' -- Get shared calendar
			'g' -- Lists users
			'i' -- Inserts events
			'r' -- Reminder,Workflow,Alert Triggering, Instance Creation
			't' -- Workflow Reminder
			'u' -- Update Events
			'v' -- Snooze Reminder
			'w' -- Workflow Dropdown List
			'x' -- Dismiss Reminder
			'y' -- Reminder Dropdown List
			'z' -- Reminder Grid
			'h' -- Selects number as value and code
			'j' -- Lists events status as report
	@xml : XML data
	@calendar_event_id : Id of the event
	@user_id : User login Id
	@role_id : Role Id
	@status : Status of the event
	@date_from : Event start date
	@date_to : Event end date
	@snooze_time : Time to snooze event
	@is_shared : Event share flag
	@is_batch : Batch flag
	@hour_from : Event start hour
	@hour_to : Event end hour
	@module_id : Module ID
	@source_object_id : Source Object Id
*/
CREATE PROCEDURE [dbo].[spa_calendar]
    @flag CHAR(1),
	@xml TEXT = NULL,
	@calendar_event_id VARCHAR(4000) = NULL,
	@user_id VARCHAR(100) = NULL,
	@role_id INT = NULL,
	@status INT = NULL,
	@date_from DATE = NULL,
	@date_to DATE = NULL,
	@snooze_time INT = NULL,
	@is_shared INT = 0,
	@is_batch INT = 1,
	@hour_from INT = NULL,
	@hour_to INT = NULL,
	@module_id INT = NULL,
	@source_object_id INT = NULL
AS

SET NOCOUNT ON

DECLARE @sql_stmt VARCHAR(MAX),  @idoc INT
DECLARE @desc VARCHAR(500)
DECLARE @err_no INT
DECLARE @default_hol_grp_id INT = NULL

SELECT @default_hol_grp_id = calendar_desc FROM default_holiday_calendar AS dhc

SET @user_id = ISNULL(NULLIF(@user_id, ''), dbo.FNADBUser())

IF @flag = 'a' -- Alert Dropdown List
BEGIN
	SELECT '' [key], '' [label]
	UNION
	SELECT	alert_sql_id [key],
			alert_sql_name [label]
	FROM alert_sql
	WHERE alert_sql_id > 0
END
ELSE IF @flag = 'b' --Creating Instance for Calendar Events (Single)
BEGIN
	BEGIN TRY
		IF NOT EXISTS(SELECT 1 FROM workflow_activities WHERE source_column = 'calendar_event_id' AND source_id = @calendar_event_id AND as_of_date = @date_from)
		BEGIN
			IF EXISTS (SELECT 1 FROM dbo.calendar_events WHERE calendar_event_id = @calendar_event_id AND alert_id IS NOT NULL AND workflow_group_id IS NOT NULL)
			BEGIN
				DECLARE @tw_id INT, @tw_group_id INT, @tsource_id INT, @tw_process_xml VARCHAR(1000), @te_id INT

				SELECT	@tw_group_id =  ce.workflow_group_id,
						@tsource_id = ce.source_id,
						@tw_process_xml = ce.process_table_xml,
						@tw_id = ce.workflow_id,
						@te_id = ce.alert_id
				FROM dbo.calendar_events ce
				WHERE ce.calendar_event_id = @calendar_event_id

				EXEC spa_register_event_manual	@flag = 't',
											@event_trigger_id = @te_id,
											@module_event_id = @tw_id,
											@group_id = @tw_group_id,
											@source_id = @tsource_id,
											@is_batch = @is_batch,
											@process_table_xml = @tw_process_xml
				
				DECLARE @hol_group_id INT = NULL
				SELECT @hol_group_id =  hol_group_id FROM holiday_group AS hg 
					WHERE hg.hol_group_value_id = @default_hol_grp_id
						AND hol_date = CONVERT(VARCHAR(10), @date_from, 120)
				
				INSERT INTO workflow_activities(workflow_trigger_id, as_of_date, user_login_id, event_message_id, message, source_column, source_id, control_status)
				SELECT	@te_id [workflow_trigger_id], 
						CONVERT(VARCHAR(10), GETDATE(), 120) [as_of_date], 
						ce.create_user [user_login_id], 
						wem.event_message_id [event_message_id], 
						ce.name [message], 
						'calendar_event_id' [source_column], 
						ce.calendar_event_id,
						728
				FROM calendar_events ce
				INNER JOIN dbo.module_events me ON ce.workflow_id = me.module_events_id
				INNER JOIN dbo.event_trigger et ON et.modules_event_id = me.module_events_id AND et.event_trigger_id = @te_id
				INNER JOIN dbo.workflow_event_message wem ON wem.event_trigger_id = et.event_trigger_id
				WHERE (@hol_group_id IS NULL OR ce.include_holiday = 'y') AND ce.calendar_event_id = @calendar_event_id AND ce.workflow_group_id = @tw_group_id
			END
			ELSE IF EXISTS (SELECT 1 FROM calendar_events ce
							INNER JOIN workflow_custom_activities wca ON ce.source_id = wca.workflow_custom_activity_id
							WHERE ce.calendar_event_id = @calendar_event_id AND ce.description = 'Custom Step')
			BEGIN
				UPDATE wca
				SET [status] = 728
				FROM calendar_events ce
				INNER JOIN workflow_custom_activities wca ON ce.source_id = wca.workflow_custom_activity_id
				WHERE ce.calendar_event_id = @calendar_event_id AND ce.description = 'Custom Step'

				EXEC spa_ErrorHandler 0,
					 'Workflow Progress',
					 'spa_workflow_progress',
					 'Success',
					 'Scheduled task successfully completed.',
					 ''
			END
			ELSE 
			BEGIN
				DECLARE @trigger_id VARCHAR(100), @message_id INT
				SELECT @trigger_id = et.event_trigger_id, @message_id = wem.event_message_id
				FROM module_events me
				LEFT JOIN event_trigger et ON me.module_events_id = et.modules_event_id
				LEFT JOIN workflow_event_message wem ON wem.event_trigger_id = et.event_trigger_id
				WHERE  et.event_trigger_id IS NOT NULL AND wem.event_message_id IS NOT NULL

				INSERT INTO workflow_activities(workflow_trigger_id, as_of_date, user_login_id, event_message_id, message, source_column, source_id)
				SELECT @trigger_id [workflow_trigger_id], @date_from [as_of_date], create_user [user_login_id], @message_id [event_message_id], name [message], 'calendar_event_id' [source_column], @calendar_event_id
				FROM calendar_events
				WHERE calendar_event_id = @calendar_event_id

				EXEC spa_ErrorHandler 0,
					 'Workflow Progress',
					 'spa_workflow_progress',
					 'Success',
					 'Instance Created',
					 '1'
			END
		END
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
		   ROLLBACK
		   
		EXEC spa_ErrorHandler -1,
             'Workflow Progress',
             'spa_workflow_progress',
             'Error',
             'Fail',
             ''
	END CATCH
END
ELSE IF @flag = 'c' --Calendar Events List for Scheduler
BEGIN
	IF OBJECT_ID('tempdb..#tmp_approval_permission') IS NOT NULL
			DROP TABLE #tmp_approval_permission
	CREATE TABLE #tmp_approval_permission(user_login_id VARCHAR(100)  COLLATE DATABASE_DEFAULT, action_permission INT)

	INSERT INTO #tmp_approval_permission(user_login_id, action_permission)
	SELECT	user_login_id, 
			CASE WHEN dbo.FNADBUser() = user_login_id THEN 2 ELSE share_calendar END [action_permission]
	FROM application_users au
	INNER JOIN dbo.SplitCommaSeperatedValues(@user_id) a ON au.user_login_id = a.item

	SET @sql_stmt = 'SELECT	CAST(MAX(workflow_activity_id) AS VARCHAR(10)) [id], 
						''Workflow Approval'' [text], 
						''No description available'' [description],
						FORMAT(dbo.FNAConvertTimezone(MIN(as_of_date), 0), ''MM/dd/yyyy HH:mm:ss'') [start_date], 
						CASE WHEN MAX(control_status) IS NULL THEN FORMAT(dbo.FNAConvertTimezone(GETDATE(), 0), ''MM/dd/yyyy HH:mm:ss'')
						ELSE FORMAT(dbo.FNAConvertTimezone(MAX(as_of_date), 0), ''MM/dd/yyyy HH:mm:ss'')
						END [end_date],
						'''' [workflow],
						'''' [alert],
						'''' [reminder],
						CASE WHEN MAX(control_status) IS NULL THEN ''week_1___1,2,3,4,5#''
						ELSE ''''
						END [rec_type],
						0 [event_pid],
						900 [event_length],
						CASE WHEN MAX(control_status) IS NULL THEN ''workflow''
						ELSE ''completed''
						END [type],
						''y'' [include_holiday]
				INTO #temp_outstanding_workflow
				FROM workflow_activities wa
				LEFT JOIN dbo.SplitCommaSeperatedValues(''' + @user_id + ''') s ON s.item = wa.user_login_id 
				LEFT JOIN application_users au ON au.user_login_id = wa.user_login_id'
			
			IF NULLIF(@role_id, '') IS NOT NULL
				SET @sql_stmt += ' LEFT JOIN application_role_user aru ON aru.user_login_id = au.user_login_id AND aru.role_id IS NOT NULL
				LEFT JOIN calendar_shared_user_role csur ON csur.user_login_id = au.user_login_id AND ISNULL(au.share_calendar, 0) = 1
				LEFT JOIN application_role_user aru2 ON aru2.user_login_id = csur.user_login_id
				LEFT JOIN application_role_user aruu ON aruu.role_id = csur.shared_role_id AND aruu.user_login_id = dbo.FNADBUser()'
			
			SET @sql_stmt += ' WHERE source_column <> ''calendar_event_id''  AND control_status IS NULL'
			
			IF NULLIF(@role_id, '') IS NOT NULL
				SET @sql_stmt += ' AND (s.item IS NOT NULL OR (aru.role_id =' + CAST(@role_id AS VARCHAR(10)) + ' AND aruu.role_id IS NOT NULL))'
			ELSE
				SET @sql_stmt += ' AND wa.user_login_id IN (''' + REPLACE(@user_id, ',', ''',''') + ''')'

			SET @sql_stmt +=	' 
				UNION
				SELECT	CAST(MAX(workflow_activity_id) AS VARCHAR(10)) [id], 
						''Workflow Approval'' [text], 
						''No description available'' [description],
						--FORMAT(dbo.FNAConvertTimezone(MIN(as_of_date), 0), ''MM/dd/yyyy HH:mm:ss'') [start_date], 
						CASE WHEN MAX(control_status) IS NULL THEN 
							CASE WHEN MAX(wea.threshold_days) IS NOT NULL
								THEN FORMAT(DATEADD(DAY,MAX(wea.threshold_days)-1,dbo.FNAConvertTimezone(MIN(as_of_date), 0)), ''MM/dd/yyyy HH:mm:ss'')
								ELSE FORMAT(dbo.FNAConvertTimezone(MIN(as_of_date), 0), ''MM/dd/yyyy HH:mm:ss'')
							END
						ELSE FORMAT(dbo.FNAConvertTimezone(MAX(as_of_date), 0), ''MM/dd/yyyy HH:mm:ss'')
						END [start_date],
						CASE WHEN MAX(control_status) IS NULL THEN 
							CASE WHEN MAX(wea.threshold_days) IS NOT NULL
								THEN FORMAT(DATEADD(DAY,MAX(wea.threshold_days),dbo.FNAConvertTimezone(MIN(as_of_date), 0)), ''MM/dd/yyyy HH:mm:ss'')
								ELSE FORMAT(dbo.FNAConvertTimezone(GETDATE(), 0), ''MM/dd/yyyy HH:mm:ss'')
							END
						ELSE FORMAT(dbo.FNAConvertTimezone(MAX(as_of_date), 0), ''MM/dd/yyyy HH:mm:ss'')
						END [end_date],
						'''' [workflow],
						'''' [alert],
						'''' [reminder],
						CASE WHEN MAX(control_status) IS NULL THEN ''week_1___1,2,3,4,5#''
						ELSE ''''
						END [rec_type],
						0 [event_pid],
						900 [event_length],
						CASE WHEN MAX(control_status) IS NULL THEN ''workflow''
						ELSE ''completed''
						END [type],
						''y'' [include_holiday]
				FROM workflow_activities wa
				LEFT JOIN event_trigger et ON et.event_trigger_id = wa.workflow_trigger_id
				LEFT JOIN workflow_event_message wem ON et.event_trigger_id = wem.event_trigger_id
				LEFT JOIN workflow_event_action wea ON wea.event_message_id = wem.event_message_id AND wea.status_id = 733
				LEFT JOIN workflow_event_user_role weur ON wem.event_message_id = weur.event_message_id
				LEFT JOIN application_role_user aru ON aru.role_id = weur.role_id AND aru.role_id IS NOT NULL
				LEFT JOIN application_users au ON au.user_login_id = aru.user_login_id 
				LEFT JOIN dbo.SplitCommaSeperatedValues(''' + @user_id + ''') s ON s.item = au.user_login_id
				LEFT JOIN application_users au2 ON au2.user_login_id = weur.user_login_id 
				LEFT JOIN dbo.SplitCommaSeperatedValues(''' + @user_id + ''') s2 ON s2.item = au2.user_login_id 
				'
		
		SET @sql_stmt += '
				WHERE (s.item IS NOT NULL OR s2.item IS NOT NULL) AND source_column <> ''calendar_event_id''
				AND control_status IS NULL'
		
		IF NULLIF(@role_id, '') IS NOT NULL
			SET @sql_stmt += ' AND (1=1 OR (ISNULL(au.share_calendar, 0) = 1 AND aru.role_id =' + CAST(@role_id AS VARCHAR(10)) + '))'
		
		IF @status IN (1,3)
			SET @sql_stmt += '
				SELECT CASE WHEN event_parent_id <> 0 AND event_parent_id <> '''' THEN CAST(event_parent_id AS VARCHAR(10)) + ''#'' + CAST(calendar_event_id AS VARCHAR(10)) ELSE CAST(calendar_event_id AS VARCHAR(10)) END [id], 
						name [text], 
						description, 
						FORMAT(dbo.FNAConvertTimezone(start_date, 0), ''MM/dd/yyyy HH:mm:ss'') [start_date], 
						FORMAT(dbo.FNAConvertTimezone(end_date, 0), ''MM/dd/yyyy HH:mm:ss'') [end_date],
						workflow_id [workflow],
						alert_id [alert],
						reminder,
						rec_type, 
						event_parent_id [event_pid], 
						event_length, 
						''calendar'' [type],
						include_holiday
				 FROM calendar_events ce
				 LEFT JOIN dbo.SplitCommaSeperatedValues(''' + @user_id + ''') s ON s.item = ce.create_user
				 WHERE 1=1 '

				 IF NULLIF(@module_id,'') IS NOT NULL
					SET @sql_stmt += ' AND ce.module_id = ' + CAST(@module_id AS VARCHAR)
				IF NULLIF(@source_object_id,'') IS NOT NULL
					SET @sql_stmt += ' AND ce.source_id = ' + CAST(@source_object_id AS VARCHAR)
				 
				 SET @sql_stmt += ' AND s.item IS NOT NULL AND rec_type <> ''''  UNION '

		SET @sql_stmt += '
			SELECT	CASE WHEN wa.workflow_activity_id IS NOT NULL AND wa.control_status IS NOT NULL AND rec_type <> '''' THEN CAST(dbo.FNAGetNewID() AS VARCHAR(100))
					ELSE 
						CASE WHEN event_parent_id <> 0 AND event_parent_id <> '''' THEN CAST(event_parent_id AS VARCHAR(10)) + ''#'' + CAST(calendar_event_id AS VARCHAR(10)) ELSE CAST(calendar_event_id AS VARCHAR(10)) END 
					END [id], 
					CASE WHEN wca.workflow_custom_activity_id IS NULL THEN ce.name ELSE sdv.code + '' - '' + CAST(wca.source_id AS VARCHAR) + '' | '' + w_me.workflow_name + '' - '' + wca.workflow_custom_activity_desc END [text], 
					CASE WHEN ce.description <> '''' THEN ce.description
					WHEN (wa.workflow_activity_id IS NOT NULL AND wa.control_status IS NOT NULL) OR (ce.create_user <> dbo.FNADBUSER()) THEN ''No description available''
					ELSE ''''
					END [description],
					CASE WHEN wa.workflow_activity_id IS NOT NULL AND wa.control_status IS NOT NULL THEN FORMAT(dbo.FNAConvertTimezone(CONVERT(VARCHAR(10), CAST(as_of_date AS DATE), 120) + '' '' + CONVERT(VARCHAR(5), CAST(start_date AS TIME), 120), 0), ''MM/dd/yyyy HH:mm:ss'')
					ELSE FORMAT(dbo.FNAConvertTimezone(start_date, 0), ''MM/dd/yyyy HH:mm:ss'')
					END [start_date], 
					CASE WHEN wa.workflow_activity_id IS NOT NULL AND wa.control_status IS NOT NULL THEN FORMAT(dbo.FNAConvertTimezone(CONVERT(VARCHAR(10), CAST(as_of_date AS DATE), 120) + '' '' + CONVERT(VARCHAR(5), CAST(start_date AS TIME), 120), 0), ''MM/dd/yyyy HH:mm:ss'')
					ELSE FORMAT(dbo.FNAConvertTimezone(end_date, 0), ''MM/dd/yyyy HH:mm:ss'')
					END [end_date],
					workflow_id [workflow],
					alert_id [alert],
					reminder [reminder],
					CASE WHEN wa.workflow_activity_id IS NOT NULL AND wa.control_status IS NOT NULL AND ' + CAST(@status AS VARCHAR(10)) + ' = 1 THEN ''none''
					WHEN wa.workflow_activity_id IS NOT NULL AND wa.control_status IS NOT NULL THEN ''''
					ELSE rec_type 
					END [rec_type],
					CASE WHEN wa.workflow_activity_id IS NOT NULL AND wa.control_status IS NOT NULL AND rec_type <> '''' THEN calendar_event_id
					ELSE event_parent_id 
					END [event_pid],
					CASE WHEN wa.workflow_activity_id IS NOT NULL AND wa.control_status IS NOT NULL AND rec_type <> '''' THEN DATEDIFF(s, ''1970-01-01 00:00:00'', CONVERT(VARCHAR(10), CAST(as_of_date AS DATE), 120) + '' '' + CONVERT(VARCHAR(5), CAST(start_date AS TIME), 120))
					ELSE event_length 
					END [event_length],
					CASE 
						WHEN ce.create_user <> dbo.FNADBUSER() AND tap.action_permission <> 2 THEN ''readonly'' 
						WHEN wa.workflow_activity_id IS NOT NULL AND wa.control_status IS NOT NULL THEN ''completed''
						WHEN wca.[status] = 728 THEN ''completed''
					ELSE ''calendar''
					END [type],
					ce.include_holiday
			FROM calendar_events ce
			LEFT JOIN workflow_activities wa ON ce.calendar_event_id = wa.source_id AND wa.source_column = ''calendar_event_id''
			LEFT JOIN dbo.SplitCommaSeperatedValues(''' + @user_id + ''') s ON s.item = ce.create_user
			LEFT JOIN application_users au ON au.user_login_id = ce.create_user
			LEFT JOIN #tmp_approval_permission tap ON tap.user_login_id = au.user_login_id
			LEFT JOIN workflow_custom_activities wca ON wca.workflow_custom_activity_id = ce.source_id AND ce.description = ''Custom Step''
			LEFT JOIN module_events w_me ON w_me.module_events_id = wca.modules_event_id
			LEFT JOIN static_data_value sdv ON sdv.value_id = w_me.modules_id
		'
	
	IF NULLIF(@role_id, '') IS NOT NULL
		SET @sql_stmt += ' LEFT JOIN application_role_user aru ON aru.user_login_id = au.user_login_id AND aru.role_id IS NOT NULL
			LEFT JOIN calendar_shared_user_role csur ON csur.user_login_id = au.user_login_id AND ISNULL(au.share_calendar, 0) = 1
			LEFT JOIN application_role_user aru2 ON aru2.user_login_id = csur.user_login_id
			LEFT JOIN application_role_user aruu ON aruu.role_id = csur.shared_role_id AND aruu.user_login_id = dbo.FNADBUser()'
	
	SET @sql_stmt += ' WHERE s.item IS NOT NULL '
	
	IF NULLIF(@module_id,'') IS NOT NULL
				SET @sql_stmt += ' AND ce.module_id = ' + CAST(@module_id AS VARCHAR)
	IF NULLIF(@source_object_id,'') IS NOT NULL
				SET @sql_stmt += ' AND ce.source_id = ' + CAST(@source_object_id AS VARCHAR)

	IF NULLIF(@role_id, '') IS NOT NULL
		SET @sql_stmt += ' OR (aru.role_id =' + CAST(@role_id AS VARCHAR(10)) + ' AND aruu.role_id IS NOT NULL)  OR csur.shared_user_login_id = dbo.FNADBUser()'
	
	IF @status = 1
		SET @sql_stmt += ' AND ((ISNULL(wa.workflow_activity_id,wca.workflow_custom_activity_id) IS NULL) OR (ISNULl(wa.control_status,wca.[status]) IS NULL AND ISNULL(wa.workflow_activity_id,wca.workflow_custom_activity_id) IS NOT NULL) OR rec_type <> '''') '
	ELSE IF @status = 2
		SET @sql_stmt += ' AND ISNULl(wa.workflow_activity_id,wca.workflow_custom_activity_id) IS NOT NULL AND ISNULL(wa.control_status,wca.[status]) IS NOT NULL '

	IF EXISTS(SELECT workflow_activity_id 
				FROM workflow_activities 
				WHERE ISNULL(NULLIF(user_login_id, ''), dbo.FNADBUser()) = dbo.FNADBUser() AND ((control_status IS NULL AND @status = 1) OR (control_status IS NOT NULL AND @status = 2) OR @status = 3)
	)
	BEGIN
		IF @status = 1 OR @status = 3
		BEGIN
			SET @sql_stmt += '
				UNION
				SELECT	*
				FROM #temp_outstanding_workflow
				WHERE id IS NOT NULL
			'
			IF NULLIF(@module_id,'') IS NOT NULL
				SET @sql_stmt += ' AND 1=2 '
		END
		IF @status = 2 OR @status = 3
		BEGIN
			SET @sql_stmt += '
				UNION
				SELECT	CAST(MAX(workflow_activity_id) AS VARCHAR(10)) [id], 
						''Workflow Approval'' [text], 
						''No description available'' [description],
						MAX(FORMAT(dbo.FNAConvertTimezone(as_of_date, 0), ''MM/dd/yyyy HH:mm:ss'')) [start_date], 
						CASE WHEN MAX(control_status) IS NULL THEN FORMAT(dbo.FNAConvertTimezone(GETDATE(), 0), ''MM/dd/yyyy HH:mm:ss'')
						ELSE MAX(FORMAT(dbo.FNAConvertTimezone(as_of_date, 0), ''MM/dd/yyyy HH:mm:ss''))
						END [end_date],
						'''' [workflow],
						'''' [alert],
						'''' [reminder],
						'''' [rec_type],
						0 [event_pid],
						900 [event_length],
						''completed'' [type],
						''y'' [include_holiday]
				FROM workflow_activities wa
				LEFT JOIN event_trigger et ON et.event_trigger_id = wa.workflow_trigger_id
				LEFT JOIN workflow_event_message wem ON et.event_trigger_id = wem.event_trigger_id
				LEFT JOIN workflow_event_user_role weur ON wem.event_message_id = weur.event_message_id
				LEFT JOIN dbo.SplitCommaSeperatedValues(''' + @user_id + ''') s ON s.item = weur.user_login_id 
				LEFT JOIN application_users au ON au.user_login_id = weur.user_login_id'
			
			IF NULLIF(@role_id, '') IS NOT NULL
				SET @sql_stmt += ' LEFT JOIN application_role_user aru ON aru.user_login_id = au.user_login_id AND aru.role_id IS NOT NULL
				LEFT JOIN calendar_shared_user_role csur ON csur.user_login_id = au.user_login_id AND ISNULL(au.share_calendar, 0) = 1
				LEFT JOIN application_role_user aru2 ON aru2.user_login_id = csur.user_login_id
				LEFT JOIN application_role_user aruu ON aruu.role_id = csur.shared_role_id AND aruu.user_login_id = dbo.FNADBUser()'
			
			SET @sql_stmt += ' WHERE s.item IS NOT NULL AND source_column <> ''calendar_event_id'''
			
			IF NULLIF(@module_id,'') IS NOT NULL
				SET @sql_stmt += ' AND 1=2 '

			SET @sql_stmt += ' AND control_status IS NOT NULL'
			
			IF NULLIF(@role_id, '') IS NOT NULL
				SET @sql_stmt += ' OR (aru.role_id =' + CAST(@role_id AS VARCHAR(10)) + ' AND aruu.role_id IS NOT NULL)'

			SET @sql_stmt += ' GROUP BY CAST([dbo].FNADateTimeFormat(as_of_date, 1) AS VARCHAR(10))'
		END
	END
	--PRINT @sql_stmt
	EXEC(@sql_stmt)
END
ELSE IF @flag = 'd' --Delete Events
BEGIN
	IF EXISTS(SELECT 1 FROM calendar_events WHERE calendar_event_id = @calendar_event_id AND event_parent_id = 0)
	BEGIN
		DELETE
		FROM workflow_activities
		WHERE control_status IS NULL AND source_column = 'calendar_event_id' AND source_id = @calendar_event_id
		
		DELETE
		FROM calendar_events
		WHERE event_parent_id = @calendar_event_id

		DELETE
		FROM calendar_events
		WHERE calendar_event_id = @calendar_event_id
	END
	ELSE
	BEGIN
		UPDATE calendar_events
		SET rec_type = 'none'
		WHERE calendar_event_id = @calendar_event_id
	END
END
ELSE IF @flag = 'e' -- Share Calendar
BEGIN
	BEGIN TRY
		UPDATE application_users
		SET share_calendar = @is_shared
		WHERE user_login_id = dbo.FNADBUser()

		EXEC sp_xml_preparedocument @idoc OUTPUT, @xml

		IF OBJECT_ID('tempdb..#share_calendar_user_role') IS NOT NULL
			DROP TABLE #share_calendar_user_role
		
		SELECT 
				NULLIF(user_login_id, '')		[user_login_id],
				NULLIF(role_id, 0)				[role_id]
		INTO #share_calendar_user_role
		FROM OPENXML(@idoc, '/Root/FormXML', 1)
		WITH (
			user_login_id			VARCHAR(100),
			role_id					VARCHAR(100)
		)

		DELETE 
		FROM calendar_shared_user_role
		WHERE user_login_id = dbo.FNADBUser()

		INSERT INTO calendar_shared_user_role
		(
			user_login_id,
			shared_user_login_id,
			shared_role_id
		)
		SELECT dbo.FNADBUser(),
			user_login_id,
			role_id 
		FROM #share_calendar_user_role AS scur

		EXEC spa_ErrorHandler 0
			, 'application_users'
			, 'spa_calendar'
			, 'Success' 
			, 'Changes have been saved successfully.'
			, ''
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
			ROLLBACK
	 
		SET @desc = 'Fail to update Data ( Errr Description:' + ERROR_MESSAGE() + ').'
	 
		SELECT @err_no = ERROR_NUMBER()
	 
		EXEC spa_ErrorHandler @err_no
			, 'application_users'
			, 'spa_calendar'
			, 'Error'
			, @desc
			, ''
	END CATCH
END
ELSE IF @flag = 'f' -- Get share calendar
BEGIN
	SELECT	CASE WHEN au.share_calendar > 0 THEN 1 ELSE 0 END [share_calendar],
			CASE WHEN au.share_calendar = 2 THEN 1 ELSE 0 END [action_permission],
			STUFF((SELECT ',' + b.shared_user_login_id
				FROM calendar_shared_user_role b 
				WHERE b.user_login_id = au.user_login_id AND b.shared_user_login_id <> ''
				FOR XML PATH('')), 1, 1, '') [user_id],
			STUFF((SELECT ',' + CAST(c.shared_role_id AS VARCHAR(10))
				FROM calendar_shared_user_role c 
				WHERE c.user_login_id = au.user_login_id AND c.shared_role_id <> 0
				FOR XML PATH('')), 1, 1, '') [role_id]
	FROM application_users au
	WHERE user_login_id = dbo.FNADBUser()
END
ELSE IF @flag = 'g' -- User Dropdown
BEGIN
	SELECT	DISTINCT 
			LOWER(au.user_login_id), 
			au.user_f_name + ' ' + ISNULL(au.user_m_name, '') + ' ' + au.user_l_name AS name,
			CASE WHEN au.user_login_id = dbo.FNADBUser() THEN 'disable' ELSE 'enable' END as [state]
	FROM application_users au
	LEFT JOIN application_role_user aru ON au.user_login_id = aru.user_login_id
	LEFT JOIN calendar_shared_user_role c ON au.user_login_id = c.user_login_id
	LEFT JOIN application_role_user aruu ON aruu.role_id = c.shared_role_id AND aruu.user_login_id = dbo.FNADBUser()
	WHERE (ISNULL(au.share_calendar, 0) > 1 AND (c.shared_user_login_id = dbo.FNADBUser() OR c.shared_role_id = aruu.role_id)) 
			OR au.user_login_id = dbo.FNADBUser()
	ORDER BY au.user_f_name + ' ' + ISNULL(au.user_m_name, '') + ' ' + au.user_l_name
END
ELSE IF @flag = 'i' --Inserting Events
BEGIN
	BEGIN TRY
		EXEC sp_xml_preparedocument @idoc OUTPUT, @xml
	
		IF OBJECT_ID('tempdb..#temp_calendar_detail') IS NOT NULL
			DROP TABLE #temp_calendar_detail

		SELECT
			calendar_event_id,
			name,
			[description],
			workflow_id,
			alert_id,
			include_holiday,
			reminder,
			rec_type,
			[start_date],
			end_date ,
			event_parent_id,
			event_length
		INTO #temp_calendar_detail
		FROM OPENXML(@idoc, '/Root', 1)
		WITH (
			calendar_event_id BIGINT,
			name VARCHAR(100),
			[description] VARCHAR(1000),
			workflow_id INT,
			alert_id INT,
			include_holiday CHAR(1),
			reminder INT,
			rec_type VARCHAR(1000),
			[start_date] DATETIME,
			end_date DATETIME,
			event_parent_id INT,
			event_length INT
		)

		IF EXISTS(SELECT 1 FROM calendar_events ce
					INNER JOIN #temp_calendar_detail tcd ON ce.calendar_event_id = tcd.calendar_event_id
				)
		BEGIN
			EXEC spa_calendar 'u', @xml
		END
		ELSE
		BEGIN
			INSERT INTO calendar_events (
				name,
				[description],
				workflow_id,
				alert_id,
				reminder,
				rec_type,
				[start_date],
				end_date,
				event_parent_id,
				event_length,
				include_holiday,
				workflow_group_id
			)
			SELECT
				tcd.name,
				tcd.[description],
				tcd.workflow_id,
				tcd.alert_id,
				tcd.reminder,
				tcd.rec_type,
				dbo.FNAConvertTimezone(tcd.[start_date], 1),
				dbo.FNAConvertTimezone(tcd.end_date, 1),
				tcd.event_parent_id,
				tcd.event_length,
				tcd.include_holiday,
				wst.parent
			FROM #temp_calendar_detail tcd
			LEFT JOIN workflow_schedule_task wst ON tcd.workflow_id = wst.workflow_id AND wst.workflow_id_type = 1
		END
		EXEC spa_ErrorHandler 0,
					 'Workflow Progress',
					 'spa_workflow_progress',
					 'Success',
					 'Changes have been saved successfully.',
					 ''
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
		   ROLLBACK
		   
		EXEC spa_ErrorHandler -1,
             'Workflow Progress',
             'spa_workflow_progress',
             'Error',
             'Fail',
             ''
	END CATCH
END
ELSE IF @flag = 'r' --Reminder,Workflow,Alert Triggering, Instance Creation
BEGIN
	SELECT @hol_group_id  = hol_group_id FROM holiday_group AS hg 
	WHERE hg.hol_group_value_id = @default_hol_grp_id
		AND hol_date = CONVERT(VARCHAR(10), GETDATE(), 120)
	
	INSERT INTO message_board(user_login_id, source, description, type, is_alert)
	SELECT create_user, 'Calendar Reminder', name, 'r', 'y'
	FROM calendar_events
	WHERE (@hol_group_id IS NULL OR include_holiday = 'y') AND rec_type = '' AND reminder <> -1 AND CONVERT(VARCHAR(16),DATEADD(MINUTE, -reminder, start_date), 120) = CONVERT(VARCHAR(16), GETDATE(), 120)
	AND event_message_id IS NULL
	UNION
	SELECT ce.create_user, 'Calendar Reminder', ce.name, 'r', 'y'
	FROM dbo.FNAGetRecurringEventOnDate(CONVERT(VARCHAR(10), GETDATE(), 120)) s
	LEFT JOIN calendar_events ce on ce.calendar_event_id = s.item
	WHERE (@hol_group_id IS NULL OR ce.include_holiday = 'y') AND reminder <> -1  AND CONVERT(VARCHAR(5),DATEADD(MINUTE, -reminder, CAST(start_date AS TIME)), 120) = CONVERT(VARCHAR(5), CAST(GETDATE() AS TIME), 120)
	AND event_message_id IS NULL

	--IF EXISTS(SELECT 1 FROM calendar_events WHERE alert_id <> 0 AND rec_type = '' AND CONVERT(VARCHAR(16),start_date, 120) = CONVERT(VARCHAR(16), GETDATE(), 120))
	--BEGIN
	DECLARE @alert_id INT, @w_id INT, @w_process_xml VARCHAR(1000), @w_group_id INT, @source_id INT, @c_event_id INT, @run_only_individual_step CHAR(1), @w_process_id VARCHAR(300), @scheduled_as_of_date DATETIME

	DECLARE calendar_alert_cursor CURSOR FOR
		SELECT ce.alert_id, ce.workflow_id, ce.process_table_xml,ce.workflow_group_id, ce.source_id, ce.calendar_event_id, ce.run_only_individual_step, ce.workflow_process_id, ce.scheduled_as_of_date
		FROM calendar_events ce
		INNER JOIN dbo.module_events me ON ce.workflow_id = me.module_events_id AND ISNULL(me.is_active, 'y') = 'y'
		WHERE ce.alert_id <> 0 AND ce.rec_type = '' AND CONVERT(VARCHAR(16),start_date, 120) = CONVERT(VARCHAR(16), GETDATE(), 120) AND ISNULL(ce.automatic_trigger, 'y') = 'y'
		UNION
		SELECT ce.alert_id, ce.workflow_id, ce.process_table_xml, ce.workflow_group_id, ce.source_id, ce.calendar_event_id, ce.run_only_individual_step, ce.workflow_process_id, ce.scheduled_as_of_date
		FROM dbo.FNAGetRecurringEventOnDate(CONVERT(VARCHAR(10), GETDATE(), 120)) s
		LEFT JOIN calendar_events ce ON ce.calendar_event_id = s.item
		INNER JOIN dbo.module_events me ON ce.workflow_id = me.module_events_id AND ISNULL(me.is_active, 'y') = 'y'
		WHERE ce.alert_id <> 0 AND ce.rec_type <> '' AND CONVERT(VARCHAR(16),start_date, 120) = CONVERT(VARCHAR(16), GETDATE(), 120)  AND ISNULL(ce.automatic_trigger, 'y') = 'y'
	OPEN calendar_alert_cursor
	FETCH NEXT FROM calendar_alert_cursor INTO @alert_id, @w_id, @w_process_xml, @w_group_id, @source_id, @c_event_id, @run_only_individual_step,@w_process_id,@scheduled_as_of_date
	WHILE @@FETCH_STATUS = 0
	BEGIN	
		EXEC spa_register_event_manual	@flag = 't',
										@event_trigger_id = @alert_id,
										@module_event_id = @w_id,
										@group_id = @w_group_id,
										@source_id = @source_id,
										@is_batch = 1,
										@process_table_xml = @w_process_xml,
										@run_only_individual_step = @run_only_individual_step,
										@group_process_id = @w_process_id,
										@custom_schedule_date = @scheduled_as_of_date

		INSERT INTO workflow_activities(workflow_trigger_id, as_of_date, user_login_id, event_message_id, message, source_column, source_id, control_status)
		SELECT	@alert_id [workflow_trigger_id], 
				CONVERT(VARCHAR(10), GETDATE(), 120) [as_of_date], 
				ce.create_user [user_login_id], 
				wem.event_message_id [event_message_id], 
				ce.name [message], 
				'calendar_event_id' [source_column], 
				ce.calendar_event_id,
				728
		FROM calendar_events ce
		INNER JOIN dbo.module_events me ON ce.workflow_id = me.module_events_id
		INNER JOIN dbo.event_trigger et ON et.modules_event_id = me.module_events_id AND et.event_trigger_id = @alert_id
		INNER JOIN dbo.workflow_event_message wem ON wem.event_trigger_id = et.event_trigger_id
		WHERE ce.calendar_event_id = @c_event_id AND ce.workflow_group_id = @w_group_id

		--EXEC spa_run_alert_sql @alert_id, NULL, NULL, NULL, NULL
		FETCH NEXT FROM calendar_alert_cursor INTO @alert_id, @w_id, @w_process_xml, @w_group_id, @source_id, @c_event_id, @run_only_individual_step,@w_process_id,@scheduled_as_of_date
	END
	CLOSE calendar_alert_cursor
	DEALLOCATE calendar_alert_cursor
	--END

	--IF EXISTS(SELECT 1 FROM calendar_events WHERE workflow_id <> 0 AND rec_type = '' AND CONVERT(VARCHAR(16),start_date, 120) = CONVERT(VARCHAR(16), GETDATE(), 120))
	--BEGIN
	DECLARE @alert_sql_statement VARCHAR(500), @process_id VARCHAR(100), @job_name VARCHAR(200)
	DECLARE @workflow_id INT, @event_trigger_id VARCHAR(100), @schedule_user VARCHAR(1000)
	DECLARE workflow_cursor CURSOR FOR  
		SELECT ce.workflow_id, ce.create_user, ce.workflow_group_id
		FROM calendar_events ce
		INNER JOIN dbo.module_events me ON ce.workflow_id = me.module_events_id AND ISNULL(me.is_active, 'y') = 'y'
		WHERE (@hol_group_id IS NULL OR ce.include_holiday = 'y') AND ce.workflow_id <> 0 AND ce.alert_id = 0 and ce.rec_type = '' AND CONVERT(VARCHAR(16),start_date, 120) = CONVERT(VARCHAR(16), GETDATE(), 120)
		UNION
		SELECT ce.workflow_id, ce.create_user, ce.workflow_group_id
		FROM dbo.FNAGetRecurringEventOnDate(CONVERT(VARCHAR(10), GETDATE(), 120)) s
		LEFT JOIN calendar_events ce ON ce.calendar_event_id = s.item
		INNER JOIN dbo.module_events me ON ce.workflow_id = me.module_events_id AND ISNULL(me.is_active, 'y') = 'y'
		WHERE (@hol_group_id IS NULL OR ce.include_holiday = 'y') AND ce.workflow_id <> 0 AND ce.alert_id = 0 AND rec_type <> '' AND CONVERT(VARCHAR(5), CAST(start_date AS TIME), 120) = CONVERT(VARCHAR(5), CAST(GETDATE() AS TIME), 120)
	OPEN workflow_cursor
	FETCH NEXT FROM workflow_cursor INTO @workflow_id, @schedule_user, @w_group_id

	WHILE @@FETCH_STATUS = 0   
	BEGIN  
		SELECT TOP(1) @alert_id = ett.alert_id, @event_trigger_id = ett.event_trigger_id
		FROM module_events mee
		INNER JOIN event_trigger ett ON mee.module_events_id = ett.modules_event_id
		INNER JOIN workflow_schedule_task wst ON wst.workflow_id = ett.event_trigger_id
		LEFT JOIN (	
			SELECT DISTINCT wea.alert_id
			FROM module_events me
			INNER JOIN event_trigger et ON  me.module_events_id = et.modules_event_id
			INNER JOIN workflow_event_message wem ON wem.event_trigger_id = et.event_trigger_id
			LEFT JOIN workflow_event_action wea ON wea.event_message_id = wem.event_message_id
			INNER JOIN alert_sql as1 ON as1.alert_sql_id = et.alert_id
			WHERE as1.is_active = 'y' AND wea.event_action_id IS NOT NULL AND wea.alert_id IS NOT NULL
		) a ON a.alert_id = ett.event_trigger_id
		LEFT JOIN alert_sql as2 ON ett.alert_id = as2.alert_sql_id
		WHERE ett.modules_event_id = @workflow_id AND (a.alert_id IS NULL OR ett.initial_event = 'y') and as2.is_active = 'y'
		ORDER BY wst.sort_order

		SET @process_id = dbo.FNAGetNewID();
		SET @alert_sql_statement = 'spa_run_alert_sql ' + CAST(@alert_id AS VARCHAR) + ', NULL, NULL, NULL, NULL, ' + CAST(@event_trigger_id AS VARCHAR) + ',NULL,NULL,NULL,' + CAST(@w_group_id AS VARCHAR)
		SET @job_name = 'Alert_Calender_' + CAST(@alert_id AS VARCHAR) + '_' + @process_id
		EXEC spa_run_sp_as_job @job_name, @alert_sql_statement, @job_name, @schedule_user,NULL, NULL, NULL

		FETCH NEXT FROM workflow_cursor INTO @workflow_id, @schedule_user, @w_group_id
	END
	CLOSE workflow_cursor   
	DEALLOCATE workflow_cursor
	--END

	--Instance Creation
	SELECT @trigger_id = et.event_trigger_id, @message_id = wem.event_message_id
	FROM module_events me
	LEFT JOIN event_trigger et ON me.module_events_id = et.modules_event_id
	LEFT JOIN workflow_event_message wem ON wem.event_trigger_id = et.event_trigger_id
	OUTER APPLY (SELECT item [event_id] FROM dbo.SplitCommaSeperatedValues(me.event_id)) evt
	WHERE modules_id = 20610 AND evt.event_id = 20534
	
	IF @trigger_id IS NOT NULL AND @message_id IS NOT NULL
	BEGIN
		INSERT INTO workflow_activities(workflow_trigger_id, as_of_date, user_login_id, event_message_id, message, source_column, source_id)
		SELECT @trigger_id [workflow_trigger_id], CONVERT(VARCHAR(10), GETDATE(), 120) [as_of_date], ce.create_user [user_login_id], @message_id [event_message_id], ce.name [message], 'calendar_event_id' [source_column], ce.calendar_event_id
		FROM calendar_events ce
		LEFT JOIN workflow_activities wa ON wa.source_id = ce.calendar_event_id AND wa.source_column = 'calendar_event_id'
		WHERE (@hol_group_id IS NULL OR ce.include_holiday = 'y') AND ce.rec_type = '' AND CONVERT(VARCHAR(10),ce.start_date, 120) = CONVERT(VARCHAR(10), GETDATE(), 120)
		AND wa.workflow_activity_id IS NULL
		UNION
		SELECT @trigger_id [workflow_trigger_id], CONVERT(VARCHAR(10), GETDATE(), 120) [as_of_date], ce.create_user [user_login_id], @message_id [event_message_id], ce.name [message], 'calendar_event_id' [source_column], ce.calendar_event_id
		FROM dbo.FNAGetRecurringEventOnDate(CONVERT(VARCHAR(10), GETDATE(), 120)) s
		LEFT JOIN calendar_events ce ON s.item = ce.calendar_event_id
		LEFT JOIN workflow_activities wa ON wa.source_id = ce.calendar_event_id AND wa.source_column = 'calendar_event_id' AND as_of_date = CONVERT(VARCHAR(10), GETDATE(), 120)
		WHERE wa.workflow_activity_id IS NULL AND (@hol_group_id IS NULL OR ce.include_holiday = 'y')
	END

	DECLARE @activity_id VARCHAR(1000) = ''

	SELECT @activity_id = @activity_id + CAST(workflow_activity_id AS VARCHAR(10)) + ','
	FROM workflow_activities wa
	LEFT JOIN workflow_event_action wea ON wea.event_message_id = wa.event_message_id
	WHERE wa.control_status IS NULL AND wea.threshold_days IS NOT NULL 
		AND wea.status_id = 733 AND alert_id IS NOT NULL
		AND DATEADD(DAY, wea.threshold_days, wa.create_ts) < GETDATE()
	SET @activity_id = SUBSTRING(@activity_id, 0, LEN(@activity_id))

	IF @activity_id <> ''
		EXEC spa_setup_rule_workflow  @flag='c', @activity_id = @activity_id, @approved='3', @comments=''

	/* Reminder Alerts Messaging logic */
	DECLARE @rem_module_id INT, @rem_source_id INT, @rem_event_message_id INT
	DECLARE reminder_msg_cursor CURSOR FOR  
			SELECT module_id, source_id, event_message_id
			FROM calendar_events
			WHERE (@hol_group_id IS NULL OR include_holiday = 'y') AND rec_type = '' AND reminder <> -1 AND CONVERT(VARCHAR(16),DATEADD(MINUTE, -reminder, start_date), 120) = CONVERT(VARCHAR(16), GETDATE(), 120)
			AND event_message_id IS NOT NULL
			UNION
			SELECT module_id, source_id, event_message_id
			FROM dbo.FNAGetRecurringEventOnDate(CONVERT(VARCHAR(10), GETDATE(), 120)) s
			LEFT JOIN calendar_events ce on ce.calendar_event_id = s.item
			WHERE (@hol_group_id IS NULL OR ce.include_holiday = 'y') AND reminder <> -1  AND CONVERT(VARCHAR(5),DATEADD(MINUTE, -reminder, CAST(start_date AS TIME)), 120) = CONVERT(VARCHAR(5), CAST(GETDATE() AS TIME), 120)
			AND event_message_id IS NOT NULL
		OPEN reminder_msg_cursor
	FETCH NEXT FROM reminder_msg_cursor INTO @rem_module_id, @rem_source_id, @rem_event_message_id

	WHILE @@FETCH_STATUS = 0   
	BEGIN  
		SET @process_id = dbo.FNAGetNewID();
		SET @alert_sql_statement = ' spa_run_alert_message @module_id = ' + CAST(@rem_module_id AS VARCHAR) + ', @source_id = ' + CAST(@rem_source_id AS VARCHAR) + ', @event_message_id = ' + CAST(@rem_event_message_id AS VARCHAR)
		SET @job_name = 'Alert_Messaging_' + CAST(@rem_source_id AS VARCHAR) + '_' + @process_id
		EXEC spa_run_sp_as_job @job_name, @alert_sql_statement, @job_name, @user_id,NULL, NULL, NULL

		FETCH NEXT FROM reminder_msg_cursor INTO @rem_module_id, @rem_source_id, @rem_event_message_id
	END
	CLOSE reminder_msg_cursor   
	DEALLOCATE reminder_msg_cursor
	/* Reminder Alerts Messaging logic end */

	/* Create or Start the Queue job */
	IF DATEPART(mi,GETDATE()) = 0
	BEGIN
		DECLARE @process_queue_status VARCHAR(100)
		EXEC spa_process_queue @flag = 'create_or_start_queue_job',@output_status = @process_queue_status
	END
END
ELSE IF @flag = 't' --Workflow Reminder
BEGIN
	INSERT INTO message_board(user_login_id, source, description, type, is_alert, is_alert_processed, reminderDate)
	SELECT dbo.FNADBUser(), 'Calendar Reminder', 'Workflow Approval Reminder', 'r', 'y', 'y', CONVERT(VARCHAR(16),DATEADD(MINUTE, @snooze_time, GETDATE()), 120)
END
ELSE IF @flag = 'u' --Update Events
BEGIN
	EXEC sp_xml_preparedocument @idoc OUTPUT, @xml
	
	IF OBJECT_ID('tempdb..#temp_calendar_details') IS NOT NULL
		DROP TABLE #temp_calendar_details

	SELECT
		calendar_event_id,
		name,
		[description],
		workflow_id,
		alert_id,
		include_holiday,
		reminder,
		rec_type,
		[start_date],
		end_date ,
		event_parent_id,
		event_length
	INTO #temp_calendar_details
	FROM OPENXML(@idoc, '/Root', 1)
	WITH (
		calendar_event_id INT,
		name VARCHAR(100),
		[description] VARCHAR(1000),
		workflow_id INT,
		alert_id INT,
		include_holiday CHAR(1),
		reminder INT,
		rec_type VARCHAR(1000),
		[start_date] DATETIME,
		end_date DATETIME,
		event_parent_id INT,
		event_length INT
	)

	UPDATE ce
	SET ce.name = tcd.name,
		ce.description = tcd.description,
		ce.workflow_id = tcd.workflow_id,
		ce.alert_id = tcd.alert_id,
		ce.reminder = tcd.reminder,
		ce.rec_type = tcd.rec_type,
		ce.start_date = dbo.FNAConvertTimezone(tcd.start_date, 1),
		ce.end_date = dbo.FNAConvertTimezone(tcd.end_date, 1),
		ce.event_parent_id = tcd.event_parent_id,
		ce.include_holiday = tcd.include_holiday
		--ce.event_length = tcd.event_length
		, ce.workflow_group_id = wst.parent
	FROM calendar_events ce
	INNER JOIN #temp_calendar_details tcd ON ce.calendar_event_id = tcd.calendar_event_id
	LEFT JOIN workflow_schedule_task wst ON tcd.workflow_id = wst.workflow_id AND wst.workflow_id_type = 1

	DELETE ce
	FROM calendar_events ce
	INNER JOIN #temp_calendar_details tcd ON ce.event_parent_id = tcd.calendar_event_id
END
ELSE IF @flag = 'v' --Snooze Reminder
BEGIN
	IF EXISTS(
	SELECT 1
	FROM message_board 
	WHERE message_id = @calendar_event_id
	)
	BEGIN
		DECLARE @reminder_time VARCHAR(16)
		SELECT @reminder_time = CONVERT(VARCHAR(16),DATEADD(minute, @snooze_time, GETDATE()), 120)

		UPDATE message_board 
		SET is_alert_processed = 'n',
		reminderDate = @reminder_time
		WHERE message_id = @calendar_event_id
	END
END
ELSE IF @flag = 'w' -- Workflow Dropdown List
BEGIN
	SELECT '' [key], '' [label]
	UNION
	SELECT me.module_events_id [key], ISNULL(wst1.[text] + ' >> ','')  + me.workflow_name [label]
	FROM module_events me 
	LEFT JOIN workflow_schedule_task wst ON me.module_events_id = wst.workflow_id AND wst.workflow_id_type = 1
	LEFT JOIN workflow_schedule_task wst1 On wst.parent = wst1.id
	WHERE me.modules_id <> 20610 OR event_id <> 20534
	ORDER BY [label]
END
ELSE IF @flag = 'x' --Dismiss Reminder
BEGIN
	IF EXISTS(
		SELECT 1
		FROM message_board mb
		INNER JOIN dbo.SplitCommaSeperatedValues(@calendar_event_id) a ON a.item = mb.message_id
	)
	BEGIN
		UPDATE mb
			SET is_alert_processed = 'y',
				reminderDate = NULL
		FROM message_board mb
		INNER JOIN dbo.SplitCommaSeperatedValues(@calendar_event_id) a ON a.item = mb.message_id
	END
END
ELSE IF @flag = 'y' --Reminder Dropdown List
BEGIN
	SELECT 5 [id], '5 Minutes' [label] UNION
	SELECT 10, '10 Minutes' UNION
	SELECT 15, '15 Minutes' UNION
	SELECT 30, '30 Minutes' UNION
	SELECT 60, '1 Hour'
END
ELSE IF @flag = 'z' --Reminder Grid
BEGIN
	SELECT message_id, description
	FROM message_board
	WHERE is_alert = 'y' AND type = 'r' AND ISNULL(is_alert_processed, 'n') = 'n' AND ISNULL(NULLIF(reminderDate, ''),GETDATE()) <= GETDATE() AND user_login_id = dbo.FNADBUser()
END

ELSE IF @flag = 'h'
BEGIN
	WITH Numbers AS (
		SELECT 1 AS Number
		UNION ALL SELECT Number + 1
		FROM Numbers
		WHERE Number < 24
	)
	SELECT Number [value], Number [code] FROM Numbers
	OPTION (MaxRecursion 0)
END


ELSE IF @flag = 'j'
BEGIN

	IF OBJECT_ID('tempdb..#temp_calendar_report') IS NOT NULL
		DROP TABLE #temp_calendar_report

	IF OBJECT_ID('tempdb..#temp_calendar_report_user') IS NOT NULL
		DROP TABLE #temp_calendar_report_user

	CREATE TABLE #temp_calendar_report (
		calendar_event_id	INT,
		event_name			VARCHAR(1000)  COLLATE DATABASE_DEFAULT,
		event_description	VARCHAR(1000)  COLLATE DATABASE_DEFAULT,
		start_datetime		DATETIME,
		create_user			VARCHAR(100)  COLLATE DATABASE_DEFAULT,
		user_login_id		VARCHAR(100)  COLLATE DATABASE_DEFAULT,
		create_time			DATETIME,
		role_name			VARCHAR(100) COLLATE DATABASE_DEFAULT,
		module				VARCHAR(100) COLLATE DATABASE_DEFAULT,
		source_id			INT,
		source_desc			VARCHAR(1000) COLLATE DATABASE_DEFAULT,
		[status]			VARCHAR(100) COLLATE DATABASE_DEFAULT
	)

	-- Calendar Events
	INSERT INTO #temp_calendar_report
	SELECT ce.calendar_event_id,
		ce.[name] [Event Name],
		ce.[description] [Event Description],
		ce.[start_date] [Start Datetime],
		au.user_f_name + ' ' + au.user_l_name [Create User],
		au.user_login_id,
		ce.create_ts [Create Time],
		asr.role_name [Role],
		sdv.code [Module],
		CASE 
		WHEN me.modules_id = 20601 THEN sdh.source_deal_header_id
		WHEN me.modules_id = 20611 THEN mgs.match_group_shipment_id
		ELSE ''
		END [Source ID],
		CASE 
		WHEN me.modules_id = 20601 THEN sdh.deal_id
		WHEN me.modules_id = 20611 THEN mgs.match_group_shipment
		ELSE ''
		END [Source Desc],
		CASE WHEN wca.workflow_custom_activity_id IS NOT NULL AND wca.[status] = 728 THEN 'Completed'
			ELSE 'Outstanding' 
		END [Status]
	 FROM calendar_events ce
	 INNER JOIN application_users au ON au.user_login_id = ce.create_user
	 LEFT JOIN application_role_user aru ON aru.user_login_id = au.user_login_id
	 LEFT JOIN workflow_custom_activities wca ON wca.workflow_custom_activity_id = ce.source_id AND ce.[description] = 'Custom Step'
	 LEFT JOIN module_events me ON me.module_events_id = ce.workflow_id OR me.module_events_id = wca.modules_event_id
	 LEFT JOIN static_data_value sdv On sdv.value_id = me.modules_id
	 LEFT JOIN source_deal_header sdh ON sdh.source_deal_header_id = ce.source_id OR sdh.source_deal_header_id = wca.source_id
	 LEFT JOIN match_group_shipment mgs On mgs.match_group_shipment_id = ce.source_id OR mgs.match_group_shipment_id = wca.source_id
	 LEFT JOIN application_security_role asr ON asr.role_id = aru.role_id
	 WHERE	aru.role_id = CASE WHEN @role_id IS NULL THEN aru.role_id ELSE @role_id END
		AND CONVERT(DATE,ce.[start_date]) >= CASE WHEN @date_from IS NOT NULL AND @date_from <> '' THEN  CONVERT(DATE,@date_from) ELSE CONVERT(DATE,ce.[start_date]) END
		AND CONVERT(DATE,ce.[start_date]) <= CASE WHEN @date_to IS NOT NULL AND @date_to <> '' THEN  CONVERT(DATE,@date_to) ELSE CONVERT(DATE,ce.[start_date]) END
		--AND DATEPART(hh,ce.[start_date]) >= CASE WHEN @hour_from IS NOT NULL THEN  @hour_from ELSE DATEPART(hh,ce.[start_date]) END
		--AND DATEPART(hh,ce.[start_date]) <= CASE WHEN @hour_to IS NOT NULL THEN  @hour_to ELSE DATEPART(hh,ce.[start_date]) END
		AND DATEPART(hh,dbo.FNAConvertTimezone(ce.[start_date],0)) >= CASE WHEN @hour_from IS NOT NULL THEN  @hour_from ELSE DATEPART(hh,dbo.FNAConvertTimezone(ce.[start_date],0)) END
		AND DATEPART(hh,dbo.FNAConvertTimezone(ce.[start_date],0)) <= CASE WHEN @hour_to IS NOT NULL THEN  @hour_to ELSE DATEPART(hh,dbo.FNAConvertTimezone(ce.[start_date],0)) END
		
	--Workflow Activities		
	INSERT INTO #temp_calendar_report
	SELECT wa.workflow_activity_id,
		dbo.FNAStripHTML(wa.[message]),
		'',
		wa.as_of_date [Start Date],
		au.user_f_name + ' ' + au.user_l_name [Create User],
		au.user_login_id,
		wa.create_ts [Create Time],
		asr.role_name [Role],
		sdv.code [Module],
		CASE 
		WHEN me.modules_id = 20601 THEN sdh.source_deal_header_id
		WHEN me.modules_id = 20611 THEN mgs.match_group_shipment_id
		ELSE ''
		END [Source ID],
		CASE 
		WHEN me.modules_id = 20601 THEN sdh.deal_id
		WHEN me.modules_id = 20611 THEN mgs.match_group_shipment
		ELSE ''
		END [Source Desc],
		CASE WHEN sdv1.code = 'Approved' THEN 'Completed' ELSE ISNULL(sdv1.code,'Outstanding') END  [Status]
	 FROM workflow_activities wa
	 INNER JOIN application_users au ON au.user_login_id = wa.create_user
	 LEFT JOIN application_role_user aru ON aru.user_login_id = au.user_login_id
	 LEFT JOIN event_trigger et ON et.event_trigger_id = wa.workflow_trigger_id
	 LEFT JOIN module_events me ON me.module_events_id = et.modules_event_id
	 LEFT JOIN static_data_value sdv On sdv.value_id = me.modules_id
	 LEFT JOIN source_deal_header sdh ON sdh.source_deal_header_id = wa.source_id
	 LEFT JOIN match_group_shipment mgs On mgs.match_group_shipment_id = wa.source_id
	 LEFT JOIN static_data_value sdv1 On sdv1.value_id = wa.control_status
	 LEFT JOIN application_security_role asr ON asr.role_id = aru.role_id
	 WHERE	aru.role_id = CASE WHEN @role_id IS NULL THEN aru.role_id ELSE @role_id END
		AND CONVERT(DATE,wa.as_of_date) >= CASE WHEN @date_from IS NOT NULL AND @date_from <> '' THEN  CONVERT(DATE,@date_from) ELSE CONVERT(DATE,wa.as_of_date) END
		AND CONVERT(DATE,wa.as_of_date) <= CASE WHEN @date_to IS NOT NULL AND @date_to <> '' THEN  CONVERT(DATE,@date_to) ELSE CONVERT(DATE,wa.as_of_date) END
		--AND DATEPART(hh,wa.as_of_date) >= CASE WHEN @hour_from IS NOT NULL THEN  @hour_from ELSE DATEPART(hh,wa.as_of_date) END
		--AND DATEPART(hh,wa.as_of_date) <= CASE WHEN @hour_to IS NOT NULL THEN  @hour_to ELSE DATEPART(hh,wa.as_of_date) END
		AND DATEPART(hh,dbo.FNAConvertTimezone(wa.as_of_date,0)) >= CASE WHEN @hour_from IS NOT NULL THEN  @hour_from ELSE DATEPART(hh,dbo.FNAConvertTimezone(wa.as_of_date,0)) END
		AND DATEPART(hh,dbo.FNAConvertTimezone(wa.as_of_date,0)) <= CASE WHEN @hour_to IS NOT NULL THEN  @hour_to ELSE DATEPART(hh,dbo.FNAConvertTimezone(wa.as_of_date,0)) END
			

	CREATE TABLE #temp_calendar_report_user (user_login_id VARCHAR(100) COLLATE DATABASE_DEFAULT)

	IF @user_id IS NOT NULL AND @user_id <> ''
	BEGIN
		INSERT INTO #temp_calendar_report_user(user_login_id)
		SELECT item FROM dbo.SplitCommaSeperatedValues(@user_id)
	END
	ELSE 
	BEGIN
		INSERT INTO #temp_calendar_report_user(user_login_id)
		SELECT user_login_id FROM application_users	
	END


	SELECT calendar_event_id,
			event_name,
			event_description,
			dbo.FNADateTimeFormat(start_datetime,0) [start_date],
			create_user,
			dbo.FNADateTimeFormat(create_time,0) [create],
			role_name,
			module,
			CASE WHEN source_id =  0 THEN NULL ELSE source_id END [source_id],
			source_desc,
			[status]	 
	FROM #temp_calendar_report tmp
	INNER JOIN #temp_calendar_report_user usr ON tmp.user_login_id = usr.user_login_id
	WHERE tmp.[status] = CASE WHEN @status = '2' THEN 'Completed' WHEN @status = '1' THEN 'Outstanding' ELSE tmp.[status] END 	 
	ORDER BY start_datetime DESC
		
END