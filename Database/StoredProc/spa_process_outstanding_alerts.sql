IF OBJECT_ID(N'[dbo].[spa_process_outstanding_alerts]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[spa_process_outstanding_alerts]
GO

SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO

 /**
	Executes the messaging logic of the workflow.

	Parameters :
	@activity_process_id : Workflow_activity_id from workflow_activities table
	@alert_id :  Id of the Alert Rule (alert_sql_id FROM alert_sql)
	@process_table :Process table that contains the data to be processed from workflow
	@source_table : Primary table/view of the module
	@primary_table : Primary Column of the Workflow Module
	@output_table : Process Table name
	@event_trigger_id : Event Trigger Id (event_trigger_id FROM event_trigger)
	@msg_process_table :Process Table to save message instead of message_board
	@workflow_process_id : Unique Identifier for the current Process and other process triggered after current process
	@eod_message : Message passed from Eod steps
	@workflow_group_id : Workflow Group ID of the workflow
	@run_only_individual_step : 0 - Continue futher steps after completion of the current step
								1 - Stop and dont go further to next step after completioon of the current step
 */
 
CREATE PROCEDURE [dbo].[spa_process_outstanding_alerts]
	@activity_process_id NVARCHAR(200)= NULL,
	@alert_id INT = NULL,
	@process_table NVARCHAR(400) = NULL,
	@source_table NVARCHAR(400) = NULL,
	@primary_table NVARCHAR(MAX) = NULL,
	@output_table NVARCHAR(300) = NULL,
	@event_trigger_id INT = NULL,
	@msg_process_table NVARCHAR(400) = NULL,
	@workflow_process_id NVARCHAR(100) = NULL,
	@eod_message NVARCHAR(500) = NULL,
	@workflow_group_id INT = NULL,
	@run_only_individual_step NCHAR(1) = NULL
AS
/*
declare @activity_process_id NVARCHAR(200)= 'D6458812_2CED_4615_92DC_0E632229C972',
	@alert_id INT = 226,
	@process_table NVARCHAR(400) = 'adiha_process.dbo.alert_deal_D6458812_2CED_4615_92DC_0E632229C972_ad',
	@source_table NVARCHAR(400) = 'vwSourceDealHeader',
	@primary_table NVARCHAR(MAX) = 'source_deal_header_id',
	@output_table NVARCHAR(300) = NULL,
	@event_trigger_id INT = 349,
	@msg_process_table NVARCHAR(400) = NULL,
	@workflow_process_id NVARCHAR(100) = NULL,
	@eod_message NVARCHAR(500) = NULL,
	@workflow_group_id INT = 816

	

--*/
SET NOCOUNT ON

BEGIN
	SET @primary_table = NULLIF(NULLIF(@primary_table,''),'NULL')
	SET @eod_message = NULLIF(@eod_message,'')

	DECLARE @sql_id           INT,
			@process_id       NVARCHAR(150),
			@message          NVARCHAR(1000),
			@trader_user_id   NVARCHAR(50),
			@current_user_id  NVARCHAR(50),
			@report_param	  NVARCHAR(MAX),
			@workflow_id      INT,
			@alert_reports_id INT,
			@self_notify	  NCHAR(1),
			@event_message_id INT,
			@notify_trader	  NCHAR(1),
			@next_module_id			INT,
			@next_event_id			INT,
			@final_next_module_events_id INT = NULL,
			@module_id INT,
			@skip_log BIT = 0
	
	IF @workflow_process_id IS NULL
		SET @workflow_process_id = dbo.FNAGetNewID()
		DECLARE @logical_table_name	varchar(200)
		SELECT   @logical_table_name = logical_table_name
		FROM workflow_module_rule_table_mapping mp
		INNER JOIN alert_table_definition atd ON mp.rule_table_id = atd.alert_table_definition_id
		WHERE  atd.is_action_view = 'y' AND ISNULL(mp.is_active,0) = 1 AND primary_column = @primary_table	

	DECLARE @user_id NVARCHAR(50)
	SET @user_id = dbo.FNADBUser()

	SELECT @module_id = me.modules_id FROM event_trigger et
	INNER JOIN module_events me ON me.module_events_id = et.modules_event_id
	where event_trigger_id = @event_trigger_id

	IF @module_id IS NULL
	BEGIN
		SELECT  @module_id = module_id
		FROM workflow_module_rule_table_mapping mp
		INNER JOIN alert_table_definition atd ON mp.rule_table_id = atd.alert_table_definition_id
		WHERE  atd.is_action_view = 'y' AND ISNULL(mp.is_active,0) = 1 AND primary_column = @primary_table					
	END
	IF OBJECT_ID('tempdb..#alert_users') IS NOT NULL DROP TABLE #alert_users

	CREATE TABLE #alert_users (
		user_login_id NVARCHAR(50) COLLATE DATABASE_DEFAULT,
		message NVARCHAR(4000) COLLATE DATABASE_DEFAULT,
		mult_approval_required NCHAR(1) COLLATE DATABASE_DEFAULT,
		event_message_id INT,
		approval_action_required NCHAR(1) COLLATE DATABASE_DEFAULT ,
		automatic_proceed NCHAR(1) COLLATE DATABASE_DEFAULT,
		skip_log NCHAR(1) COLLATE DATABASE_DEFAULT
	)

	IF OBJECT_ID('tempdb..#notification_type') IS NOT NULL DROP TABLE #notification_type

	CREATE TABLE #notification_type (
		notification_type INT
	)

	DECLARE @ids_for_report NVARCHAR(2000)
		
	IF @primary_table IS NOT NULL AND @process_table IS NOT NULL
	BEGIN
		IF OBJECT_ID('tempdb..#tmp_ids_for_report') IS NOT NULL
			DROP TABLE #tmp_ids_for_report
		CREATE TABLE #tmp_ids_for_report (source_id INT)

		EXEC('INSERT INTO #tmp_ids_for_report SELECT ' + @primary_table + ' FROM ' + @process_table)
	
		SELECT @ids_for_report = STUFF((SELECT DISTINCT '!' +  CAST(source_id AS NVARCHAR) FROM #tmp_ids_for_report
										FOR XML PATH('')), 1, 1, '')
	END

	DECLARE alert_cursor CURSOR FOR
	SELECT aos.alert_id,
		   aos.alert_sql_id,
		   aos.process_id,
		   aos.[message],
		   aos.trader_user_id,
		   aos.current_user_id ,
		   wem.event_message_id
	FROM alert_output_status aos
	LEFT JOIN alert_sql s ON aos.alert_sql_id = s.alert_sql_id
	LEFT JOIN event_trigger et ON et.alert_id = s.alert_sql_id
	LEFT JOIN workflow_event_message wem ON wem.event_trigger_id = et.event_trigger_id
	WHERE aos.published <> 'y'
	AND et.event_trigger_id = @event_trigger_id
	AND aos.process_id = @activity_process_id
	UNION ALL
	-- ADD block to directly call message
	SELECT aos.alert_id,
		   aos.alert_sql_id,
		   aos.process_id,
		   aos.[message],
		   aos.trader_user_id,
		   aos.current_user_id,
		   wem.event_message_id
	FROM alert_output_status aos
	LEFT JOIN event_trigger et ON et.event_trigger_id = aos.event_trigger_id 
	LEFT JOIN workflow_event_message wem ON wem.event_trigger_id = et.event_trigger_id
	WHERE aos.published <> 'y'
	AND et.event_trigger_id = @event_trigger_id
	AND aos.process_id = @activity_process_id

	OPEN alert_cursor
	FETCH NEXT FROM alert_cursor 
	INTO @alert_id, @sql_id, @process_id,  @message, @trader_user_id, @current_user_id, @event_message_id
		
	DECLARE @report_url         NVARCHAR(MAX),
			@workflow_desc      NVARCHAR(4000),
			@original_message   NVARCHAR(500),
			@notification_type  NVARCHAR(100),
			@sql				NVARCHAR(MAX),
			@alert_name			NVARCHAR(1000),
			@workflow_approval_required NCHAR(1)
		
	WHILE @@FETCH_STATUS = 0
	BEGIN
		SELECT @original_message = wem.[message],
			   @notification_type = ISNULL(NULLIF(wem.notification_type,'0'),s.notification_type),
			   @alert_name = ISNULL(s.alert_sql_name,wem.[message]),
			   @self_notify = wem.self_notify,
			   @notify_trader = wem.notify_trader,
			   @event_trigger_id = et.event_trigger_id,
			   @workflow_approval_required = CASE WHEN w_m.event_action_id IS NULL THEN 'n' ELSE 'y' END,
			   @final_next_module_events_id = NULLIF(next_module_events_id,0)
		FROM event_trigger et
		LEFT JOIN alert_sql s ON et.alert_id = s.alert_sql_id
		INNER JOIN workflow_event_message wem ON wem.event_trigger_id = et.event_trigger_id
		CROSS APPLY (SELECT MAX(wea.event_action_id) event_action_id FROM workflow_event_action wea WHERE wem.event_message_id = wea.event_message_id AND wea.status_id IN (726,728,729)) w_m
		WHERE ISNULL(alert_sql_id,-99) = @sql_id AND wem.event_message_id = @event_message_id AND et.event_trigger_id = ISNULL(@event_trigger_id, et.event_trigger_id)
		
		DELETE FROM #notification_type
		INSERT INTO #notification_type (notification_type) SELECT a.item FROM dbo.SplitCommaSeperatedValues(@notification_type) a

		SET @report_url = ''
			
		SET @output_table = SUBSTRING(@output_table, LEN('adiha_process.dbo.') + 1, LEN(@output_table))
				
		IF OBJECT_ID('tempdb..#temp_report_params') IS NOT NULL DROP TABLE #temp_report_params
			
		CREATE TABLE #temp_report_params (event_message_id INT, alert_report_id INT, report_params NVARCHAR(MAX) COLLATE DATABASE_DEFAULT )
			
		DECLARE report_params_cursor CURSOR FOR  
			SELECT 
				alert_reports_id 
			FROM 
				alert_reports
			WHERE event_message_id = @event_message_id;				  

		OPEN report_params_cursor;  
		FETCH NEXT FROM report_params_cursor INTO @alert_reports_id;   

		WHILE @@FETCH_STATUS = 0   
		BEGIN   
				EXEC spa_alert_report_hyperlink @alert_reports_id, @output_table, @report_param OUTPUT
				
				IF EXISTS (SELECT 1 FROM alert_reports WHERE alert_reports_id = @alert_reports_id AND report_writer = 'y') AND @ids_for_report IS NOT NULL
				BEGIN
					SET @report_param = @primary_table + '=' + @ids_for_report;
				END
				
				INSERT INTO #temp_report_params
					SELECT @event_message_id, @alert_reports_id, @report_param
				FETCH NEXT FROM report_params_cursor INTO @alert_reports_id;				
		END
		CLOSE report_params_cursor   
		DEALLOCATE report_params_cursor      
			
		SELECT 
			@report_url = @report_url + '&nbsp;&nbsp;' + [dbo].[FNAAlertReportHyperLink](ar.alert_reports_id, @alert_id, ISNULL(temp_params.report_params,''), @activity_process_id)
		FROM   
			alert_reports ar
		INNER JOIN 
			#temp_report_params temp_params ON temp_params.alert_report_id = ar.alert_reports_id AND temp_params.event_message_id = ar.event_message_id   
		WHERE  
			ar.event_message_id = @event_message_id				
			
		SET @workflow_desc = COALESCE(@message, @original_message, '')
			
		DELETE FROM #alert_users
			
		INSERT INTO #alert_users
		SELECT aru.user_login_id, wem.message, wem.mult_approval_required,wem.event_message_id,CASE WHEN w_m.event_action_id IS NULL THEN 'n' ELSE 'y' END [approval_action_required],wem.automatic_proceed, wem.skip_log
		FROM   event_trigger et
		INNER JOIN workflow_event_message wem ON wem.event_trigger_id = et.event_trigger_id
		CROSS APPLY (SELECT MAX(wea.event_action_id) event_action_id FROM workflow_event_action wea WHERE wem.event_message_id = wea.event_message_id AND wea.status_id IN (726,728,729)) w_m
		INNER JOIN workflow_event_user_role weur ON weur.event_message_id = wem.event_message_id
		INNER JOIN application_role_user aru ON aru.role_id = weur.role_id
		WHERE wem.event_message_id = @event_message_id AND et.event_trigger_id = ISNULL(@event_trigger_id, et.event_trigger_id)
		UNION 
		SELECT weur.user_login_id, wem.message, wem.mult_approval_required,wem.event_message_id,CASE WHEN w_m.event_action_id IS NULL THEN 'n' ELSE 'y' END [approval_action_required],wem.automatic_proceed,wem.skip_log
		FROM   event_trigger et
		INNER JOIN workflow_event_message wem ON wem.event_trigger_id = et.event_trigger_id
		CROSS APPLY (SELECT MAX(wea.event_action_id) event_action_id FROM workflow_event_action wea WHERE wem.event_message_id = wea.event_message_id AND wea.status_id IN (726,728,729)) w_m
		INNER JOIN workflow_event_user_role weur ON weur.event_message_id = wem.event_message_id
		WHERE  wem.event_message_id = @event_message_id AND weur.user_login_id IS NOT NULL AND et.event_trigger_id = ISNULL(@event_trigger_id, et.event_trigger_id)
		UNION 
		SELECT @trader_user_id, wem.message, wem.mult_approval_required,wem.event_message_id,CASE WHEN w_m.event_action_id IS NULL THEN 'n' ELSE 'y' END [approval_action_required],wem.automatic_proceed, wem.skip_log
		FROM   event_trigger et
		INNER JOIN workflow_event_message wem ON wem.event_trigger_id = et.event_trigger_id
		CROSS APPLY (SELECT MAX(wea.event_action_id) event_action_id FROM workflow_event_action wea WHERE wem.event_message_id = wea.event_message_id AND wea.status_id IN (726,728,729)) w_m
		WHERE  @trader_user_id IS NOT NULL AND wem.event_message_id = @event_message_id AND et.event_trigger_id = ISNULL(@event_trigger_id, et.event_trigger_id)
		UNION 
		SELECT @current_user_id, wem.message, wem.mult_approval_required,wem.event_message_id,CASE WHEN w_m.event_action_id IS NULL THEN 'n' ELSE 'y' END [approval_action_required],wem.automatic_proceed, wem.skip_log
		FROM   event_trigger et
		INNER JOIN workflow_event_message wem ON wem.event_trigger_id = et.event_trigger_id
		CROSS APPLY (SELECT MAX(wea.event_action_id) event_action_id FROM workflow_event_action wea WHERE wem.event_message_id = wea.event_message_id AND wea.status_id IN (726,728,729)) w_m
		WHERE  @current_user_id IS NOT NULL AND wem.event_message_id = @event_message_id AND et.event_trigger_id = ISNULL(@event_trigger_id, et.event_trigger_id)
		--UNION
		--SELECT dbo.FNADBUser(), wem.message, wem.mult_approval_required,wem.event_message_id,wem.approval_action_required,wem.automatic_proceed
		--FROM   event_trigger et
		--INNER JOIN workflow_event_message wem ON wem.event_trigger_id = et.event_trigger_id
		--WHERE  wem.event_message_id = @event_message_id AND et.event_trigger_id = ISNULL(@event_trigger_id, et.event_trigger_id) AND @self_notify = 'y'

		IF @notify_trader = 'y'
		BEGIN
			SET @sql = 'INSERT INTO #alert_users(user_login_id, message, mult_approval_required, event_message_id, approval_action_required, skip_log)
						SELECT st.user_login_id, a.message, a.mult_approval_required, a.event_message_id,a.approval_action_required, a.skip_log FROM ' + @process_table + ' tmp
						INNER JOIN source_deal_header sdh ON tmp.source_deal_header_id = sdh.source_deal_header_id
						INNER JOIN source_traders st ON sdh.trader_id = st.source_trader_id
						OUTER APPLY (
										SELECT wem.message, wem.mult_approval_required,wem.event_message_id,CASE WHEN w_m.event_action_id IS NULL THEN ''n'' ELSE ''y'' END [approval_action_required], wem.skip_log
										FROM   event_trigger et
										INNER JOIN workflow_event_message wem ON wem.event_trigger_id = et.event_trigger_id
										CROSS APPLY (SELECT MAX(wea.event_action_id) event_action_id FROM workflow_event_action wea WHERE wem.event_message_id = wea.event_message_id AND wea.status_id IN (726,728,729)) w_m
										WHERE  wem.event_message_id = ' + CAST(@event_message_id AS NVARCHAR) + ' AND et.event_trigger_id = ISNULL(' + CAST(@event_trigger_id AS NVARCHAR) + ' , et.event_trigger_id)
									) a
						WHERE sdh.trader_id IS NOT NULL
						UNION
						SELECT st.user_login_id, a.message, a.mult_approval_required, a.event_message_id,a.approval_action_required, a.skip_log FROM ' + @process_table + ' tmp
						INNER JOIN source_deal_header sdh ON tmp.source_deal_header_id = sdh.source_deal_header_id
						INNER JOIN source_traders st ON sdh.trader_id2 = st.source_trader_id
						OUTER APPLY (
										SELECT wem.message, wem.mult_approval_required,wem.event_message_id,CASE WHEN w_m.event_action_id IS NULL THEN ''n'' ELSE ''y'' END [approval_action_required], wem.skip_log
										FROM   event_trigger et
										INNER JOIN workflow_event_message wem ON wem.event_trigger_id = et.event_trigger_id
										CROSS APPLY (SELECT MAX(wea.event_action_id) event_action_id FROM workflow_event_action wea WHERE wem.event_message_id = wea.event_message_id AND wea.status_id IN (726,728,729)) w_m
										WHERE  wem.event_message_id = ' + CAST(@event_message_id AS NVARCHAR) + ' AND et.event_trigger_id = ISNULL(' + CAST(@event_trigger_id AS NVARCHAR) + ', et.event_trigger_id)
									) a
						WHERE sdh.trader_id2 IS NOT NULL'
			EXEC(@sql)
		END
		
		/*** Removed Inactive Users For Notification ***/
		DELETE tau
		FROM #alert_users tau
		INNER JOIN application_users au
			ON au.user_login_id = tau.user_login_id
		WHERE au.user_active = 'n'



		/*
		*	Generate the Message
		*	Tags -: [ID],[#DEAL][DEAL#],[#TRADE][TRADE#],[CREATE_USER]
		*/
		DECLARE @msg NVARCHAR(1000) = @workflow_desc
		
		IF OBJECT_ID('tempdb..#splitted_process_table_mapping') IS NOT NULL DROP TABLE #splitted_process_table_mapping
		CREATE TABLE #splitted_process_table_mapping (source_id INT, process_table_name NVARCHAR(1000) COLLATE DATABASE_DEFAULT , attachment_file NVARCHAR(MAX) COLLATE DATABASE_DEFAULT , attachment_string NVARCHAR(MAX) COLLATE DATABASE_DEFAULT , [message] NVARCHAR(MAX) COLLATE DATABASE_DEFAULT , row_count INT, process_id NVARCHAR(200) COLLATE DATABASE_DEFAULT)
		
		DECLARE @automatic_proceed_msg NVARCHAR(1000) = NULL

		SELECT @automatic_proceed_msg = [message] FROM eod_process_status
		WHERE process_id = @process_id
		IF @automatic_proceed_msg IS NULL AND @eod_message IS NOT NULL
			SET @automatic_proceed_msg = @eod_message

		IF @automatic_proceed_msg IS NOT NULL
			SET @msg = REPLACE(@msg, '<PROCEED_MESSAGE>', @automatic_proceed_msg)

		IF @process_table IS NOT NULL
		BEGIN
			IF @primary_table IS NULL
			BEGIN
				EXEC('IF COL_LENGTH(''' + @process_table + ''',''primary_temp_id'') IS NULL BEGIN ALTER TABLE ' + @process_table + ' ADD primary_temp_id INT NOT NULL DEFAULT 1 END')
				SET @primary_table = 'primary_temp_id'
			END

			EXEC('IF COL_LENGTH(''' + @process_table + ''',''message'') IS NULL BEGIN ALTER TABLE ' + @process_table + ' ADD message NVARCHAR(4000) END')
			EXEC('UPDATE ' + @process_table + ' SET message = N''' +  @msg + '''')
			
		DECLARE @msg_cursor NVARCHAR(MAX)
		SET @msg_cursor = '
			
			DECLARE @message_output NVARCHAR(1000)
			

			DECLARE @create_user NVARCHAR(100)
			DECLARE @new_process_id NVARCHAR(100) 
			DECLARE @new_process_table NVARCHAR(100)	

			DECLARE @source_id INT, @msg NVARCHAR(MAX), @confirm_doc NVARCHAR(500), @confirm_doc2 NVARCHAR(500), @shipping_doc NVARCHAR(500), @confirm_doc_file_path NVARCHAR(2000), @confirm_doc2_file_path NVARCHAR(2000), @shipping_doc_file_path NVARCHAR(2000)

			SELECT @create_user = user_f_name + '' '' + user_l_name
			FROM application_users
			WHERE user_login_id = dbo.FNADBUser()

			DECLARE message_cursor CURSOR FOR
				SELECT DISTINCT ' + @primary_table + ', message FROM ' + @process_table + '
			OPEN message_cursor
				FETCH NEXT FROM message_cursor INTO @source_id, @msg
				WHILE @@FETCH_STATUS = 0
				BEGIN
					SET @new_process_id = dbo.FNAGetNewID()
					SET @new_process_table = ''adiha_process.dbo.alert_'' + CAST(@source_id AS NVARCHAR) + ''_'' + @new_process_id + ''_app''
					
					INSERT INTO #splitted_process_table_mapping (source_id, process_table_name,process_id)
					SELECT @source_id, @new_process_table,@new_process_id

					EXEC spa_resolve_workflow_message_tag @message_input = @msg, @source_id = @source_id, @module_id = ''' + CAST(@module_id AS NVARCHAR(20)) +''',@event_message_id= ''' + CAST(@event_message_id AS NVARCHAR) + ''',@message_output = @message_output OUTPUT
					SELECT @msg = REPLACE(@message_output, ''<#ALERT_REPORT>'', ''' + ISNULL(@report_url,'') + ''')
					
					UPDATE ' + @process_table + ' SET message = ''''+@msg+'''' WHERE ' + @primary_table + ' = @source_id
					UPDATE #splitted_process_table_mapping SET message = ''''+@msg+'''' WHERE source_id = @source_id

					FETCH NEXT FROM message_cursor INTO @source_id, @msg
				END
			CLOSE message_cursor
			DEALLOCATE message_cursor
		'
		EXEC spa_print @msg_cursor
		EXEC(@msg_cursor)
		END
		ELSE
		BEGIN
			SET @msg = REPLACE(REPLACE(@msg, '<#ALERT_REPORT>',  @report_url), '<ALERT_REPORT#>', '')
		END
		--- Message Generation Ends ---
		IF OBJECT_ID('tempdb..#temp_process_xml') IS NOT NULL
			DROP TABLE #temp_process_xml
		CREATE TABLE #temp_process_xml(xml_value XML)
		
		IF OBJECT_ID('tempdb..#temp_workflow_activities') IS NOT NULL
				DROP TABLE #temp_workflow_activities

		CREATE TABLE #temp_workflow_activities (workflow_activity_id INT, user_login_id NVARCHAR(50) COLLATE DATABASE_DEFAULT , source_id INT, wf_message NVARCHAR(MAX) COLLATE DATABASE_DEFAULT)
		
		IF OBJECT_ID('tempdb..#temp_grouping_workflow_activities') IS NOT NULL
				DROP TABLE #temp_grouping_workflow_activities
		CREATE TABLE #temp_grouping_workflow_activities (workflow_activity_id INT, user_login_id NVARCHAR(50) COLLATE DATABASE_DEFAULT , source_id INT, wf_message NVARCHAR(MAX) COLLATE DATABASE_DEFAULT)

		IF OBJECT_ID('tempdb..#temp_log_datas') IS NOT NULL
			DROP TABLE #temp_log_datas

		--created table to insert data without skipping the log
		SELECT workflow_trigger_id, as_of_date, process_id, process_table, [message], source_column, source_id, user_login_id, event_message_id,XML_process_data, control_status, workflow_process_id, workflow_group_id, CAST(NULL AS NVARCHAR(1)) skip_log
		INTO #temp_log_datas FROM workflow_activities WHERE 1 = 2
		
		SET @sql = '
			INSERT INTO  #temp_log_datas(workflow_trigger_id, as_of_date, process_id, process_table, message, source_column, source_id, user_login_id, event_message_id,XML_process_data, control_status, workflow_process_id, workflow_group_id, skip_log)
				SELECT  DISTINCT
						''' + CAST(ISNULL(@event_trigger_id, '') AS NVARCHAR(100)) + ''',
						GETDATE(), ''' + @process_id + ''',' +
						CASE WHEN @primary_table IS NOT NULL AND @process_table IS NOT NULL THEN + '
							stmp.process_table_name '
							ELSE '''''' 
						END + ',
						' + CASE WHEN @process_table IS NOT NULL THEN ' a.message ' ELSE '''' + @msg + '''' END + ',''' + ISNULL(@primary_table, '') + ''',' +
						CASE WHEN @primary_table IS NOT NULL AND @process_table IS NOT NULL THEN + '
							ISNULL(''  '' + a.' + @primary_table + ' + '''', '''') '
							ELSE '''''' 
						END + ', 
						CASE WHEN temp.mult_approval_required = ''y'' THEN
							temp.user_login_id
							ELSE ''''
						END,
						temp.event_message_id, NULL,
						CASE WHEN temp.approval_action_required = ''y'' THEN NULL ELSE 728 END,
						''' + @workflow_process_id + ''',
						' + CAST(@workflow_group_id AS NVARCHAR) + ',
						temp.skip_log
					FROM #alert_users temp '
		
		IF @process_table IS NOT NULL
			SET @sql = @sql + ' CROSS APPLY(SELECT * FROM ' + @process_table + ') a 
								INNER JOIN #splitted_process_table_mapping stmp ON a.' + @primary_table + ' = stmp.source_id'
		
		--SET @sql = @sql + ' WHERE ISNULL(temp.self_log, ''y'') = ''y'''
		
		IF @self_notify = 'n'
				SET @sql = @sql + ' WHERE temp.user_login_id <> dbo.FNADBUser()'
		
		SET @sql = @sql + ' INSERT INTO  workflow_activities(workflow_trigger_id, as_of_date, process_id, process_table, message, source_column, source_id, user_login_id, event_message_id,XML_process_data, control_status, workflow_process_id, workflow_group_id)
		  OUTPUT INSERTED.workflow_activity_id, INSERTED.user_login_id, INSERTED.source_id, INSERTED.[message] INTO #temp_workflow_activities(workflow_activity_id, user_login_id, source_id, wf_message)
		  SELECT workflow_trigger_id, as_of_date, process_id, process_table, message, source_column, source_id, user_login_id, event_message_id,XML_process_data, control_status, workflow_process_id, workflow_group_id FROM #temp_log_datas
		  WHERE ISNULL(skip_log, ''n'') = ''n'''
		--SET @sql = @sql + ' WHERE temp.approval_action_required = ''y'' '
		--PRINT(@sql)
		
		--	Triggering Push Notification for Mobile Application Block Start
		IF EXISTS(SELECT 1 from connection_string where mobile_integrated = 1) AND (@workflow_approval_required = 'y' OR EXISTS (SELECT 1 FROM #notification_type WHERE notification_type = 757))
		BEGIN
			SET @sql = ISNULL(@sql, '') + '
						DECLARE @push_message NVARCHAR(1000), @push_users NVARCHAR(MAX) = '''', @push_xml NVARCHAR(MAX) = '''', @output_result NVARCHAR(1024), @push_type NVARCHAR(50)
						SELECT @push_users = CASE WHEN @push_users = '''' THEN user_login_id ELSE @push_users + COALESCE('','' + user_login_id, '''') END
						FROM #alert_users
						'
			IF EXISTS (SELECT 1 FROM #notification_type WHERE notification_type = 757)
				SET @sql += ' SET @push_type = ''alerts'''
			ELSE
				SET @sql += ' SET @push_type = ''workflow'''

			IF @process_table IS NOT NULL
				SET @sql += ' SELECT @push_message = REPLACE(dbo.FNAStripHTML(a.message), ''&nbsp;'', '''') FROM ' + @process_table + ' a '
			ELSE
				SET @sql += ' SET @push_message = ''' + REPLACE(dbo.FNAStripHTML(@msg), '&nbsp;', '') + ''''
		
			SET @sql += ' SET @push_xml = ''<?xml version="1.0" encoding="UTF-8"?>
							<root>
								<messages>
									<message title="TRM" body="'' + @push_message + ''" type="'' + @push_type + ''"/>
								</messages>
								<users>
									<user id="'' + @push_users + ''"/>
								</users>          
							</root>'''
			SET @sql += ' EXEC spa_mobile_notification @push_xml, ''n'', @output_result  OUTPUT'
		END
		--	Triggering Push Notification Block End
		EXEC spa_print @sql
		EXEC(@sql)
		
		INSERT INTO #temp_grouping_workflow_activities(workflow_activity_id, user_login_id, source_id, wf_message)
		SELECT MAX(workflow_activity_id), user_login_id, source_id, wf_message FROM #temp_workflow_activities twa
		GROUP BY user_login_id, wf_message, source_id

		--UPDATE wa
		--SET wa.[message] = REPLACE(wa.[message],'__source_id__', ISNULL(NULLIF(wa.source_id,''),0))
		--FROM #temp_workflow_activities tmp
		--INNER JOIN workflow_activities wa ON tmp.workflow_activity_id = wa.workflow_activity_id

		--DECLARE @activity_id INT = ISNULL(@@IDENTITY, -1)
		DECLARE @activity_id INT
		select @activity_id=workflow_activity_id from #temp_workflow_activities
		
		DECLARE @event_msg_id NVARCHAR(100)
		SELECT @event_msg_id = STUFF((SELECT DISTINCT ',' +  CAST(event_message_id AS NVARCHAR) FROM #alert_users
									FOR XML PATH('')), 1, 1, '')
		
		IF OBJECT_ID('tempdb..#temp_attachments') IS NOT NULL DROP TABLE #temp_attachments
		CREATE TABLE #temp_attachments (attachment_files NVARCHAR(500) COLLATE DATABASE_DEFAULT )
		
		SET @sql = 'IF COL_LENGTH(''' + @process_table + ''', ''attachment_files'') IS NULL
					BEGIN
						ALTER TABLE ' + @process_table + ' ADD attachment_files NVARCHAR(300) NULL
					END'
		EXEC(@sql)

		IF @process_table IS NOT NULL
			EXEC ('INSERT INTO #temp_attachments SELECT attachment_files FROM ' + @process_table)

		DECLARE @att_files NVARCHAR(MAX), @att_file_string NVARCHAR(MAX) = '', @new_workflow_process_id NVARCHAR(100)

		DECLARE @sp_table_name NVARCHAR(100), @sp_source_id INT
		DECLARE pt_cursor CURSOR FOR
			SELECT process_table_name, source_id, process_id 
			FROM #splitted_process_table_mapping
		OPEN pt_cursor
			FETCH NEXT FROM pt_cursor INTO @sp_table_name, @sp_source_id, @new_workflow_process_id
			WHILE @@FETCH_STATUS = 0
			BEGIN
				
				SET @sql = 'SELECT * INTO ' + @sp_table_name + '
							FROM ' + @process_table + ' WHERE ' + @primary_table + ' = ' + CAST(@sp_source_id AS NVARCHAR) + '


							IF COL_LENGTH(''' + @sp_table_name + ''',''attachment_files'') IS NOT NULL 
							BEGIN
								UPDATE ' + @sp_table_name + ' SET attachment_files = NULL
							END '
							
							--DECLARE @xml_var_p XML
			
							--SET @xml_var_p =  ' + CASE WHEN @sp_table_name IS NOT NULL THEN '
							--	  (  SELECT *

							--		  FROM '+@sp_table_name+'

							--		  FOR XML RAW, TYPE
							--	  );
							--	  ' 
							--ELSE ''''''
							--END + '

							--UPDATE #splitted_process_table_mapping
							--SET process_table_xml = @xml_var_p
							--WHERE source_id = ' + CAST(@sp_source_id AS NVARCHAR)
							EXEC spa_print @sql
				EXEC(@sql)

				--UPDATE wa 
				--SET XML_process_data = tmp1.process_table_xml
				--FROM #temp_workflow_activities tmp
				--INNER JOIN workflow_activities wa ON tmp.workflow_activity_id = wa.workflow_activity_id
				--INNER JOIN #splitted_process_table_mapping tmp1 ON tmp1.source_id = wa.source_id

				IF EXISTS(	SELECT	1
							FROM workflow_event_message_documents wemd
							INNER JOIN static_data_value sdv ON wemd.document_template_id = sdv.value_id
							LEFT JOIN static_data_value sdv1 ON wemd.document_category = sdv1.value_id
							INNER JOIN dbo.SplitCommaSeperatedValues(@event_message_id) a ON a.item = wemd.event_message_id
							)
					BEGIN
						DECLARE @get_generated INT
						SELECT @get_generated = CASE WHEN use_generated_document = 'y' THEN 1 ELSE 0 END FROM workflow_event_message_documents wemd
						INNER JOIN static_data_value sdv ON wemd.document_template_id = sdv.value_id
						LEFT JOIN static_data_value sdv1 ON wemd.document_category = sdv1.value_id
						INNER JOIN dbo.SplitCommaSeperatedValues(@event_message_id) a ON a.item = wemd.event_message_id	

						EXEC spa_generate_document @event_message_id = @event_msg_id, @process_table = @sp_table_name, @workflow_process_id = @new_workflow_process_id, @get_generated =  @get_generated
					END
							
				DELETE FROM #temp_attachments
				SET @att_files = ''
				SET @att_file_string = ''

				IF @sp_table_name IS NOT NULL
					EXEC ('INSERT INTO #temp_attachments SELECT attachment_files FROM ' + @sp_table_name)

				SELECT @att_files = attachment_files FROM #temp_attachments
				
				IF  @process_table IS NOT NULL
				BEGIN
					SELECT @att_file_string = STUFF((SELECT DISTINCT ',' +  '<br/><a href="../../adiha.php.scripts/dev/shared_docs/attach_docs/' + a.item + '" target="_blank">' + SUBSTRING (a.item,CHARINDEX ('/',a.item)+1,LEN(a.item)) + '</a>'
													FROM dbo.SplitCommaSeperatedValues(@att_files) a WHERE a.item IS NOT NULL
													FOR XML PATH('')), 1, 1, '')

					SET @att_file_string = REPLACE(REPLACE(@att_file_string, '&lt;', '<'),'&gt;', '>')
				END
				EXEC spa_print @att_file_string
				UPDATE #splitted_process_table_mapping
				SET attachment_string = @att_file_string,
					attachment_file = @att_files
				WHERE source_id = @sp_source_id

			FETCH NEXT FROM pt_cursor INTO @sp_table_name, @sp_source_id,@new_workflow_process_id
			END
		CLOSE pt_cursor
		DEALLOCATE pt_cursor

		IF @final_next_module_events_id IS NULL
		BEGIN
			SELECT TOP(1) @final_next_module_events_id = -1 
			FROM workflow_event_message wem
			INNER JOIN event_trigger et ON et.event_trigger_id = wem.event_trigger_id
			INNER JOIN module_events me ON et.modules_event_id = me.module_events_id
			INNER JOIN workflow_schedule_task wst ON wst.workflow_id = me.module_events_id AND wst.workflow_id_type = 1
			INNER JOIN workflow_link wl ON wl.workflow_schedule_task_id = wst.id
			LEFT JOIN workflow_event_action ac ON ac.event_message_id = wem.event_message_id
			WHERE wem.event_trigger_id = @event_trigger_id AND ac.event_action_id IS NULL
		END

		-------------------------MESSAGING LOGIC
		DECLARE @report_file NVARCHAR(1000)
		IF EXISTS (SELECT 1 FROM #notification_type WHERE notification_type IN (750,757,751)) -- EMAIL
		BEGIN
			DECLARE @file_att_path NVARCHAR(200)

			SELECT @file_att_path = SUBSTRING(file_attachment_path,0,CHARINDEX('/adiha.php.scripts/',file_attachment_path))
			FROM connection_string
			
			SET @report_param = NULL
			-- Logic to generate html report
			DECLARE @alert_report NVARCHAR(MAX),
					@report_html NVARCHAR(MAX),
					@report_writer NVARCHAR(1),
					@paramset_hash NVARCHAR(200),
					@report_paramset_id INT,
					@component_id INT,
					@file_option_type NCHAR(1),
					@attachment_file_name NVARCHAR(200),
					@alert_source_id INT
			DECLARE email_report_cursor CURSOR FOR  
			SELECT ar.alert_reports_id,ar.report_writer,ar.paramset_hash,ISNULL(trp.report_params,ar.report_param),rps.report_paramset_id,rpt.report_page_tablix_id, ISNULL(ar.file_option_type, 'r'), ar.report_desc, wa_sid.source_id
			FROM alert_reports ar
			LEFT JOIN report_paramset rps ON ar.paramset_hash = rps.paramset_hash
			LEFT JOIN report_page_tablix rpt ON rpt.page_id = rps.page_id
			LEFT JOIN #temp_report_params trp ON ar.alert_reports_id = trp.alert_report_id
			OUTER APPLY(
				SELECT MAX(source_id) source_id FROM #temp_log_datas WHERE event_message_id = @event_message_id AND process_id = @process_id
			) wa_sid
			--LEFT JOIN workflow_activities wa ON wa.event_message_id  = ar.event_message_id 
			WHERE ar.event_message_id = @event_message_id AND (report_writer = 'n' OR report_writer ='a' OR report_writer ='y') --AND wa.process_id = @process_id
			OPEN email_report_cursor;
			FETCH NEXT FROM email_report_cursor INTO @alert_reports_id,@report_writer,@paramset_hash,@report_param,@report_paramset_id,@component_id,@file_option_type,@attachment_file_name,@alert_source_id
			WHILE @@FETCH_STATUS = 0
			BEGIN
				DECLARE @html_string NVARCHAR(MAX),
						@report_table NVARCHAR(300),
						@report_process_id NVARCHAR(200) = dbo.FNAGetNewId(),
						@user_name NVARCHAR(200) = dbo.FNADBUser(),
						@file_path NVARCHAR(1000) = NULL
				SET @html_string = NULL
				SET @report_table = dbo.FNAProcessTableName('report_table', @user_name, @report_process_id)

				IF OBJECT_ID(@report_table) IS NOT NULL
					EXEC('DROP TABLE ' + @report_table)

				--/*Block to attach report and file with email*/
				IF @report_writer = 'n'
				BEGIN
					EXEC spa_get_alert_report_output @alert_reports_id, @alert_id, @report_table
				END
				ELSE IF @report_writer = 'y'
				BEGIN
					--Run report to dump the data on process table
					SET @sql = 'EXEC spa_rfx_run_sql @paramset_id = ' + CAST(@report_paramset_id AS NVARCHAR) + ',@component_id = ' + CAST(@component_id AS NVARCHAR) + ', @criteria = ''' + ISNULL(@report_param,'') + ''', @temp_table_name=NULL,@display_type=''t'',@runtime_user=''' + dbo.FNADBUser() + ''', @is_html = ''y'' , @is_refresh=0 , @batch_process_id=NULL, @eod_call_table=''' + @report_table + ''''
					EXEC(@sql) 
				END
				ELSE IF @report_writer = 'a'
				BEGIN
					--table containing data from alert sql
					SET @report_table = 'adiha_process.dbo.nested_alert_workflow_report_' + @process_id + '_na'
				END

				IF @report_writer IN('n', 'y', 'a') AND @file_option_type IN('b', 'r')
				BEGIN
					--creates the html string of process table datas 
					EXEC spa_create_html_table @report_table, NULL, @html_string OUTPUT
				END
				IF @report_writer IN('n', 'y', 'a') AND @file_option_type IN('b', 'f')
				BEGIN
					DECLARE @result BIT, @file_name NVARCHAR(100) = ISNULL(@attachment_file_name, '') + ' ' + CAST(@alert_source_id AS NVARCHAR(8)) + ' ' + REPLACE(CONVERT(NVARCHAR(20),GETDATE(),120 ),':','') + '.csv'
					SELECT @file_path =  document_path + '\attach_docs\' +  @file_name FROM connection_string
					--dump datas from process table to excel file
					EXEC spa_export_to_csv @report_table, @file_path, 'y', ',', 'n','n','y','y',@result OUTPUT
					
					--to save the file name on email_notes table
					SET @att_file_string =  @file_name

					IF @file_option_type = 'f' OR @file_option_type = 'b' 
						SET @report_file ='<br/>Report Attached File : <a href="../../adiha.php.scripts/force_download.php?path=dev/shared_docs/attach_docs/' + @file_name + '" target="_blank">' + @attachment_file_name + '</a><br/>'
				END

				--do not drop table for data view as the table is used to show the report from hyperlink of alert message 
				IF OBJECT_ID(@report_table) IS NOT NULL AND @report_writer <> 'a'
					EXEC('DROP TABLE ' + @report_table)

				SELECT @report_html = COALESCE(@report_html + ' <br />', '') + @html_string
				FETCH NEXT FROM email_report_cursor INTO @alert_reports_id,@report_writer,@paramset_hash,@report_param,@report_paramset_id,@component_id,@file_option_type,@attachment_file_name,@alert_source_id;
			END
			CLOSE email_report_cursor
			DEALLOCATE email_report_cursor
			DECLARE @document_path NVARCHAR(300)
				SELECT @document_path = document_path FROM connection_string
			IF  @process_table IS NOT NULL
			BEGIN
				--SELECT @att_file_string = STUFF((SELECT DISTINCT ',' +  a.item 
				--								FROM dbo.SplitCommaSeperatedValues(@att_files) a
				--								FOR XML PATH('')), 1, 1, '')
				select @att_file_string = b.item from 
				(
					select a.item, ROW_NUMBER() over(order by (select null)) rnk
					FROM dbo.SplitCommaSeperatedValues(@att_files) a
				) b
				where rnk = 1
			END
			
			SELECT @skip_log = 1 FROm #temp_log_datas WHERE skip_log = 'y'

			-- Logic to send mail to listed user if the contact type is not defined. 
			IF @msg_process_table IS NULL AND EXISTS(SELECT 1 FROM #notification_type WHERE notification_type IN (750))
			BEGIN
				SET @sql = 'INSERT INTO email_notes (notes_subject, notes_text, send_from, send_to, attachment_file_name, send_status, email_type, workflow_activity_id, active_flag, sys_users)'
			END
			ELSE
			BEGIN
				SET @sql = 'INSERT INTO ' + @msg_process_table + ' (notes_subject, notes_text, send_from, send_to, attachment_file_name, send_status, email_type, workflow_activity_id, active_flag, sys_users, event_trigger_id)'
			END

			/** BUILD LINK FOR APPROVE,UNAPPROVE,COMPLETE TO OPEN A NEW MAIL WITH REPLY EMAIL ID AND SUBJECT WITH WORKFLOW PATTERN START **/
			
			declare @reply_email_id NVARCHAR(1000)

			select @reply_email_id = cs.imap_email_address
			from connection_string cs

			declare @reply_email_subject NVARCHAR(2000) = 'EVENT Notifications: __workflow_message_name__ [# Workflow : ' + cast(@activity_id as NVARCHAR(10)) + '|' + '__approve_status__ #]'
			declare @reply_email_body NVARCHAR(2000) = ' __email_body_message__'

			declare @href_build NVARCHAR(max) = dbo.FNAURLEncode('mailto:' + @reply_email_id + '?subject=' + @reply_email_subject + '&body=' + @reply_email_body)
			declare @anchor_tag_link NVARCHAR(max) = ''

			SELECT @anchor_tag_link = ISNULL(a.links, '') 
			FROM workflow_activities wa
			INNER JOIN (
				SELECT  event_message_id,
					STUFF((
					--SELECT ' ' + 
						--CASE	WHEN wea.status_id = 729 THEN '<a title="Approve" style="text-decoration:none;cursor:pointer" href="' + replace(replace(replace(@href_build,'__approve_status__','1'),'__workflow_message_name__',wmsg.event_message_name),'__email_body_message__','Approve')  + '"><span style="xbackground-color:#5CE55B;border-radius:7px;font-size:30pt;">&nbsp;&#x1f44d;&nbsp;</span></a>'
						--		WHEN wea.status_id = 726 THEN '<a title="Unapprove" style="text-decoration:none;cursor:pointer" href="' + replace(replace(replace(@href_build,'__approve_status__','0'),'__workflow_message_name__',wmsg.event_message_name),'__email_body_message__','Unapprove')  + '"><span style="xbackground-color:#5CE55B;border-radius:7px;font-size:30pt;">&nbsp;&#x1f44e;&nbsp;</span></a>'
						--		WHEN wea.status_id = 728 THEN '<a title="Complete" style="text-decoration:none;cursor:pointer" href="' + replace(replace(replace(@href_build,'__approve_status__','2'),'__workflow_message_name__',wmsg.event_message_name),'__email_body_message__','Complete')  + '"><span style="xbackground-color:#5CE55B;border-radius:7px;font-size:30pt;">&nbsp;&#x2705;&nbsp;</span></a>'
						--ELSE '' END

						SELECT ' ' + 
						CASE	WHEN wea.status_id = 729 THEN '<span style="xborder:solid 2px black;width:75px;height:95%;float:left;padding:1px;">
    <span style="xborder:solid 2px red;height:70%;font-size:40px;text-align:center;">
      <a title="Approve" href="' + replace(replace(replace(@href_build,'__approve_status__','1'),'__workflow_message_name__',wmsg.event_message_name),'__email_body_message__','Approve')  + '" style="xborder:solid 2px red;pointer:hand;text-decoration:none;">&#x1f44d;</a>
    </span>
    <span style="xborder:solid 2px blue;height:20%;font-size:10px;font-family:verdana;text-align:center;font-weight:bold;">
      <a title="Approve" href="' + replace(replace(replace(@href_build,'__approve_status__','1'),'__workflow_message_name__',wmsg.event_message_name),'__email_body_message__','Approve')  + '" style="xborder:solid 2px red;pointer:hand;text-decoration:none;">Approve</a>
    </span>
  </span>'
								WHEN wea.status_id = 726 THEN '<span style="xborder:solid 2px black;width:75px;height:95%;float:left;padding:1px;">
    <span style="xborder:solid 2px red;height:70%;font-size:40px;text-align:center;">
      <a title="Unapprove" href="' + replace(replace(replace(@href_build,'__approve_status__','0'),'__workflow_message_name__',wmsg.event_message_name),'__email_body_message__','Unapprove')  + '" style="xborder:solid 2px red;pointer:hand;text-decoration:none;">&#x1f44e;</a>
    </span>
    <span style="xborder:solid 2px blue;height:20%;font-size:10px;font-family:verdana;text-align:center;font-weight:bold;">
      <a title="Unapprove" href="' + replace(replace(replace(@href_build,'__approve_status__','0'),'__workflow_message_name__',wmsg.event_message_name),'__email_body_message__','Unapprove')  + '" style="xborder:solid 2px red;pointer:hand;text-decoration:none;">Unapprove</a>
    </span>
  </span>'
								WHEN wea.status_id = 728 THEN '<span style="xborder:solid 2px black;width:75px;height:95%;float:left;padding:1px;">
    <span style="xborder:solid 2px red;height:70%;font-size:40px;text-align:center;">
      <a title="Unapprove" href="' + replace(replace(replace(@href_build,'__approve_status__','2'),'__workflow_message_name__',wmsg.event_message_name),'__email_body_message__','Complete')  + '" style="xborder:solid 2px red;pointer:hand;text-decoration:none;">&#x2705;</a>
    </span>
    <span style="xborder:solid 2px blue;height:20%;font-size:10px;font-family:verdana;text-align:center;font-weight:bold;">
      <a title="Complete" href="' + replace(replace(replace(@href_build,'__approve_status__','2'),'__workflow_message_name__',wmsg.event_message_name),'__email_body_message__','Complete')  + '" style="xborder:solid 2px red;pointer:hand;text-decoration:none;">Complete</a>
    </span>
  </span>'
						ELSE '' END

						FROM workflow_event_action wea
						inner join workflow_event_message wmsg on wmsg.event_message_id = wea.event_message_id
						WHERE (wea.event_message_id = Results.event_message_id) 
						FOR XML PATH(''),TYPE 
					).value('.','NVARCHAR(MAX)') 
					,1,0,'') as links
				FROM    workflow_event_action Results
				GROUP BY event_message_id
			) a ON a.event_message_id = wa.event_message_id
			--ORDER BY 1 DESC
			WHERE wa.workflow_activity_id = @activity_id
			/** BUILD LINK FOR APPROVE,UNAPPROVE,COMPLETE TO OPEN A NEW MAIL WITH REPLY EMAIL ID AND SUBJECT WITH WORKFLOW PATTERN END **/
				SET @sql += 'SELECT DISTINCT ' + 
						 CASE WHEN @logical_table_name ='Import Process' 
						 THEN '''Import Notifications: '' + aem.event_message_name' ELSE
						  '''EVENT Notifications: '' + aem.event_message_name' END +',
							'' <body> <p> Dear '' + au2.user_f_name + '',</p> 
							'+CASE WHEN  @logical_table_name ='Import Process' THEN '<p> Message: <br/>'''
							ELSE +'<p> TRMTracker Event ' + @alert_name + ' has been triggered on : ' + CONVERT(VARCHAR(30), GETDATE(), 120) + ' with following status. </p> <p> <br/> 
							<p> Message: <br/>
							'''
							END + CASE WHEN @process_table IS NOT NULL THEN ' +  REPLACE(REPLACE(dbo.FNAStripHTML(a.message), ''&nbsp;'', ''<br/>''),''../..'',''' + @file_att_path + ''') + ' ELSE '''' + REPLACE(dbo.FNAStripHTML(@msg), '&nbsp;', '<br/>') + '''' END + ' + '' </p><p><br />' + @anchor_tag_link + ' <br />'
								+ ISNULL('' + REPLACE(@report_html,'''','''''') + '', '') + '</ body> '',
							''noreply@pioneersolutionsglobal.com'',
							au2.user_emal_add,
							''' + ISNULL(@document_path + '\attach_docs\' + NULLIF(@att_file_string, ''),'') + ''',
							''n'',
							''o'',
							' + cast(@activity_id as NVARCHAR(10))+ ',
							''y''
							, au2.user_login_id'
			
			IF @msg_process_table IS NOT NULL
				SET @sql += ' ,' + CAST(@event_trigger_id AS NVARCHAR(10))

			SET @sql += ' FROM   #alert_users au
						INNER JOIN workflow_event_message aem ON au.event_message_id = aem.event_message_id
						INNER JOIN application_users au2 ON  au.user_login_id = au2.user_login_id '
							 
			IF @process_table IS NOT NULL
				SET @sql = @sql + ' OUTER APPLY(SELECT * FROM ' + @process_table + ') a '
					
			SET @sql = @sql + ' WHERE aem.counterparty_contact_type IS NULL AND au2.user_emal_add IS NOT NULL AND  au.user_login_id IS NOT NULL'
			
			IF @self_notify = 'n'
				SET @sql = @sql + ' AND au.user_login_id <> dbo.FNADBUser()'
			
			--Only for Deal Assumptions
			IF @notify_trader = 'y'
			BEGIN
				SET @sql += ' UNION'
				SET @sql += ' SELECT DISTINCT ''EVENT Notifications'',
							'' <body> <p> Dear '' + au2.user_f_name + '',
							</p> <p> TRMTracker Event ' + @alert_name + '
								has been triggered on : ' + CONVERT(NVARCHAR(30), GETDATE(), 120) + ' with following status. </p> <p> <br/> <p> MESSAGE: <br/>
								'' + a.message + '' </body> '',
							''noreply@pioneersolutionsglobal.com'',
							au2.user_emal_add,
							''' + ISNULL(@att_file_string,'') + ''',
							''n'',
							''o'',
							' + cast(@activity_id as NVARCHAR(10))+ ',
							''y''
							, au2.user_login_id'
			
				IF @msg_process_table IS NOT NULL
					SET @sql += ' ,' + CAST(@event_trigger_id AS NVARCHAR(10))

				SET @sql += ' FROM   #alert_users au '
				
				IF @process_table IS NOT NULL
					SET @sql = @sql + ' CROSS JOIN ' + @process_table + ' a '
				
				SET @sql += ' INNER JOIN application_users au2 ON  a.trader_id = au2.user_login_id 
								WHERE au2.user_emal_add IS NOT NULL AND  a.trader_id IS NOT NULL'
			END
			EXEC spa_print @sql
			EXEC(@sql)

		END

		IF EXISTS (SELECT 1 FROM #notification_type WHERE notification_type IN (757,751)) -- MESSAGE BOARD & ALERT
		BEGIN
			
			IF @msg_process_table IS NULL OR @final_next_module_events_id IS NOT NULL
			BEGIN
				SET @sql = 'INSERT INTO message_board (user_login_id, [source], [description], [TYPE], is_alert, is_alert_processed, workflow_activity_id, process_id)'
			END
			ELSE
			BEGIN
				SET @sql = 'INSERT INTO ' + @msg_process_table + ' (user_login_id, [source], [description], [TYPE], is_alert, is_alert_processed, workflow_activity_id, process_id, event_trigger_id)'
			END

			SET @sql += 'SELECT DISTINCT 
								temp.user_login_id,'
								+ 
						 CASE WHEN @logical_table_name ='Import Process' 
						 THEN '''Import Notifications: ''' ELSE
						      '''Workflow Notification: ''' END + ','
								+ CASE WHEN @process_table IS NOT NULL THEN ' REPLACE(a.message,''__source_id__'',ISNULL(tgwa.source_id,''''))' ELSE 'REPLACE(''' + @msg + ''',''__source_id__'',ISNULL(tgwa.source_id,''''))' END + ' +
								CASE WHEN temp.approval_action_required = ''y'' THEN +
								''<br/> '' + '+ CASE WHEN @process_table IS NOT NULL THEN   'ISNULL(a.attachment_string, '''')'  ELSE ''   END +' +  ''
								<br/>'' + dbo.FNATrmWinHyperlink(''i'',10106700,''Proceed...'',' + CAST(1 AS NVARCHAR(10)) + ',DEFAULT,DEFAULT,DEFAULT,DEFAULT,DEFAULT,DEFAULT,DEFAULT,DEFAULT,DEFAULT,DEFAULT,DEFAULT,0) + ''''
								ELSE ''' + '<br/>'' +'+ CASE WHEN @process_table IS NOT NULL THEN '  ISNULL(a.attachment_string, '''') '  ELSE ''''''   END  + '
								END + '''  + ISNULL(@report_file,'') +''',
								''s'',
								CASE WHEN nt.notification_type = 757 THEN ''y'' ELSE ''n'' END,
								''n'',
								twa.workflow_activity_id,
								''' + @activity_process_id + ''''
			
			IF @msg_process_table IS NULL OR @final_next_module_events_id IS NOT NULL
				SET @sql += ''
			ELSE
				SET @sql += ' ,' + CAST(@event_message_id AS NVARCHAR(10))

			SET @sql += ' FROM #alert_users temp 
							CROSS JOIN #temp_workflow_activities twa
							LEFT JOIN #temp_grouping_workflow_activities tgwa ON twa.workflow_activity_id = tgwa.workflow_activity_id'

			IF @process_table  IS NOT NULL AND @skip_log = 'n'
				SET @sql = @sql + ' INNER JOIN workflow_activities wa ON wa.workflow_activity_id = twa.workflow_activity_id
									INNER JOIN #splitted_process_table_mapping a ON a.process_table_name = wa.process_table '

			SET @sql = @sql + ' OUTER APPLY (SELECT notification_type FROM #notification_type WHERE notification_type IN (757,751)) nt'
			SET @sql = @sql + ' WHERE temp.user_login_id IS NOT NULL AND ISNULL(NULLIF(twa.user_login_id,''''), temp.user_login_id) = temp.user_login_id AND temp.user_login_id <> '''''

			IF @process_table  IS NOT NULL
				SET @sql = @sql + ' AND a.message IS NOT NULL'

			IF @self_notify = 'n'
				SET @sql = @sql + ' AND temp.user_login_id <> dbo.FNADBUser()'
			
			SET @sql = @sql + ' AND ISNULL(temp.automatic_proceed,''a'') <> ''h'''
			
			IF @skip_log = 'n'
				SET @sql = @sql + ' AND tgwa.workflow_activity_id IS NOT NULL'

		EXEC spa_print @att_file_string
			EXEC(@sql)
		END
		
		----------------------------END OF MESSAGING LOGIC
		
		FETCH NEXT FROM alert_cursor 
		INTO @alert_id, @sql_id, @process_id,  @message, @trader_user_id, @current_user_id, @event_message_id		
	END
	CLOSE alert_cursor
	DEALLOCATE alert_cursor
	
	IF (@final_next_module_events_id IS NOT NULL) 
	BEGIN
		SET @next_module_id = NULL
		SET @next_event_id = NULL

		IF @final_next_module_events_id = -1
		BEGIN
			DECLARE @l_process_id NVARCHAR(100)
			DECLARE @l_process_table NVARCHAR(100)
			DECLARE @new_select_qry NVARCHAR(1000)

			IF OBJECT_ID('tempdb..#tmp_condition_chk_lnk') IS NOT NULL
				DROP TABLE #tmp_condition_chk_lnk
			CREATE TABLE #tmp_condition_chk_lnk (flag INT)

			DECLARE @next_module_event_id INT, @workflow_link_id INT
			DECLARE @table_name NVARCHAR(MAX), @primary_column NVARCHAR(100)
			DECLARE @select_part NVARCHAR(MAX), @where_part NVARCHAR(MAX)
			DECLARE @w_clause_type INT, @w_table_alias NVARCHAR(10), @w_column_name NVARCHAR(50), @w_sql_code NVARCHAR(20), @w_column_value NVARCHAR(100), @operator_id INT, @second_value NVARCHAR(100)
			DECLARE @workflow_link_where_clause_id INT
			DECLARE @data_source_view_sql NVARCHAR(MAX)
			DECLARE @data_source_result_table NVARCHAR(MAX)


			DECLARE next_workflow_cursor CURSOR FOR
			SELECT wl.modules_event_id, wl.workflow_link_id FROM event_trigger et
			INNER JOIN workflow_schedule_task wst ON wst.workflow_id = et.modules_event_id AND wst.workflow_id_type = 1
			INNER JOIN workflow_link wl On wl.workflow_schedule_task_id = wst.id
			LEFT JOIN workflow_schedule_task par ON wst.parent = par.id
			WHERE et.event_trigger_id = @event_trigger_id AND par.id = @workflow_group_id

			OPEN next_workflow_cursor
			FETCH NEXT FROM next_workflow_cursor 
			INTO @next_module_event_id, @workflow_link_id
			
			
			WHILE @@FETCH_STATUS = 0   
			BEGIN  	
				SET @data_source_result_table = 'adiha_process.dbo.alert_data_source_' + dbo.FNAGetNewID() + '_result'

				SELECT	@data_source_view_sql = REPLACE(ds.tsql,'--[__batch_report__]', 'INTO ' + @data_source_result_table)
				FROM module_events me
				INNER JOIN alert_table_definition atd ON atd.alert_table_definition_id = me.rule_table_id
				LEFT JOIN data_source ds ON ds.data_source_id = atd.data_source_id
				WHERE module_events_id = @next_module_event_id


				SET @data_source_view_sql = REPLACE(@data_source_view_sql,'--[__alert_process_table__]', ' INNER JOIN ' + @process_table)


				IF @data_source_view_sql IS NOT NULL
					EXEC(@data_source_view_sql)

				SELECT	@table_name = ISNULL(@data_source_result_table,atd.physical_table_name),
						@primary_column = ISNULL(atd.primary_column,  clm.[primary_column])
				FROM module_events me
				INNER JOIN alert_table_definition atd ON atd.alert_table_definition_id = me.rule_table_id
				OUTER APPLY (SELECT acd.column_name [primary_column] FROM alert_columns_definition acd WHERE acd.alert_table_id = atd.alert_table_definition_id AND is_primary = 'y') clm
				WHERE module_events_id = @next_module_event_id

				DECLARE @total_count INT, @count INT = 1, @or_flag INT = 0
				SELECT @total_count = COUNT(1) FROM workflow_link_where_clause w
				WHERE workflow_link_id = @workflow_link_id

				SET @select_part = 'SELECT 1  FROM ' + @table_name + ' a INNER JOIN ' + @process_table + ' p ON a.' + @primary_column + ' = p.' + @primary_column + ' WHERE 1=1 '  
				SET @where_part = ''

				IF @total_count > 0
					SET @where_part = ' AND (( '
				ELSE
					SET @where_part = ''

				DECLARE line_where_clause_cursor CURSOR FOR
				SELECT clause_type,
						'a' [alias],
						ISNULL(dsc.name,acd.column_name), 
						rpo.sql_code, 
						column_value,
						rpo.report_param_operator_id,
						second_value 
				FROM workflow_link_where_clause wlwc
				LEFT JOIN report_param_operator rpo ON rpo.report_param_operator_id = wlwc.operator_id
				LEFT JOIN alert_columns_definition acd ON acd.alert_columns_definition_id = wlwc.column_id
				LEFT JOIN data_source_column dsc ON dsc.data_source_column_id = wlwc.data_source_column_id
				WHERE wlwc.workflow_link_id = @workflow_link_id

				OPEN line_where_clause_cursor   
				FETCH NEXT FROM line_where_clause_cursor INTO @w_clause_type,@w_table_alias,@w_column_name,@w_sql_code,@w_column_value,@operator_id,@second_value

				WHILE @@FETCH_STATUS = 0   
				BEGIN  
					IF @count <> 1 AND @or_flag = 0 AND @w_clause_type = 1
						SET @where_part += ' AND '

					IF @count <> 1 AND @or_flag = 0 AND @w_clause_type = 2
						SET @where_part += ' OR '
	
					IF @w_clause_type = 4 AND @count <> @total_count
					BEGIN
						SET @where_part += ' ) OR ( ' 
						SET @or_flag = 1
					END

					IF @w_clause_type = 3 AND @count <> @total_count
					BEGIN
						SET @where_part += ' ) AND ( ' 
						SET @or_flag = 1
					END

					IF @w_clause_type = 1 OR @w_clause_type = 2
					BEGIN
						SET @where_part += 
										CASE WHEN @operator_id IN (14,15,16,17,18,19) THEN 'CAST(CONVERT(date,DATEADD(dd,CAST(' + @w_column_value + ' AS INT),' + @w_table_alias + '.' + @w_column_name + ')) AS NVARCHAR) ' 
										ELSE @w_table_alias + '.' + @w_column_name END 
										+  ' ' + @w_sql_code + ' ' + 
										CASE 
											WHEN @operator_id IN (6,7) THEN '' 
											WHEN @operator_id IN (14,15,16,17,18,19) THEN '''' + CAST(CONVERT(date, GETDATE()) AS NVARCHAR) + ''''
											ELSE
												CASE WHEN ISNUMERIC(@w_column_value) = 1 THEN @w_column_value ELSE '''' + @w_column_value + ''''  END
										END 
										+
										CASE WHEN @operator_id = 8 THEN ' AND ' + CASE WHEN ISNUMERIC(@second_value) = 1 THEN ISNULL(@second_value,'') ELSE '''' + ISNULL(@second_value,'') + ''''  END ELSE '' END
						SET @or_flag = 0
					END
					IF @count = @total_count
						SET @where_part += ' )) '

					SET @count = @count + 1

					FETCH NEXT FROM line_where_clause_cursor INTO @w_clause_type,@w_table_alias,@w_column_name,@w_sql_code,@w_column_value,@operator_id,@second_value
				END 

				CLOSE line_where_clause_cursor   
				DEALLOCATE line_where_clause_cursor

				IF EXISTS(SELECT 1 FROM #tmp_condition_chk_lnk)
				BEGIN
					DELETE FROM #tmp_condition_chk_lnk
				END

				INSERT INTO #tmp_condition_chk_lnk(flag)
				EXEC(@select_part + @where_part)

				IF((SELECT COUNT(1) FROM #tmp_condition_chk_lnk) > 0)
				BEGIN
					IF EXISTS (SELECT 1 FROM dbo.module_events WHERE module_events_id = @next_module_event_id AND ISNULL(is_active, 'y') = 'y')
					BEGIN
						SELECT	@next_module_id = modules_id,
								@next_event_id = event_id
						FROM module_events WHERE module_events_id = @next_module_event_id
						
						SET @l_process_id = dbo.FNAGetNewID()
						SET @l_process_table = 'adiha_process.dbo.alert_' + @l_process_id + '_app'

						SET @new_select_qry = REPLACE(@select_part,'SELECT 1', 'SELECT p.* INTO ' + @l_process_table) + @where_part
						EXEC(@new_select_qry)

						EXEC spa_register_event @next_module_id, @next_event_id, @l_process_table, 1, @l_process_id, @next_module_event_id,@workflow_group_id
					END
				END
			
				FETCH NEXT FROM next_workflow_cursor INTO @next_module_event_id, @workflow_link_id		
			END

			CLOSE next_workflow_cursor
			DEALLOCATE next_workflow_cursor
			
		END
		ELSE
		BEGIN
			IF EXISTS (SELECT 1 FROM dbo.module_events WHERE module_events_id = @final_next_module_events_id AND ISNULL(is_active, 'y') = 'y')
			BEGIN
				SELECT	@next_module_id = modules_id,
						@next_event_id = event_id
				FROM module_events WHERE module_events_id = @final_next_module_events_id
			
				EXEC spa_register_event @next_module_id, @next_event_id, @process_table, 0, @process_id, @final_next_module_events_id,@workflow_group_id
			END
		END
	END

	-- SUCCESS/FAILURE Logic
	DECLARE @is_automatic_proceed NCHAR(1) = 'n'
	DECLARE @automatic_proceed_status NVARCHAR(100) = NULL
	DECLARE @automatic_proceed_message NVARCHAR(100) = NULL
	DECLARE @automatic_proceed_next_event INT = NULL
	DECLARE @automatic_proceed_next_alert INT = NULL

	SELECT @is_automatic_proceed = ISNULL(automatic_proceed, 'n') FROM workflow_event_message WHERE event_trigger_id = @event_trigger_id 

	SELECT	@automatic_proceed_status = asfs.[status], 
			@automatic_proceed_message = asfs.[message]
	FROM workflow_activities wa 
	INNER JOIN eod_process_status asfs ON wa.process_id = asfs.process_id
	INNER JOIN workflow_event_message wem ON wa.event_message_id = wem.event_message_id
	WHERE wem.event_trigger_id = @event_trigger_id AND (wem.automatic_proceed = 'y' OR wem.automatic_proceed = 'h')  AND wa.process_id = @process_id

	IF @is_automatic_proceed <> 'n'
	BEGIN
		IF ISNULL(@run_only_individual_step,'n') = 'n'
		BEGIN
			IF @automatic_proceed_status = 'Success'
				SELECT	@automatic_proceed_next_alert = et.alert_id, 
						@automatic_proceed_next_event = CASE WHEN wea.alert_id = -7 THEN -7 ELSE et.event_trigger_id END 
				FROM workflow_event_action wea
				INNER JOIN workflow_event_message wem ON wea.event_message_id = wem.event_message_id
				LEFT JOIN event_trigger et ON wea.alert_id = et.event_trigger_id
				WHERE wem.event_trigger_id = @event_trigger_id AND (wem.automatic_proceed = 'y' OR wem.automatic_proceed = 'h') AND wea.status_id = 735
			ELSE IF @automatic_proceed_status = 'Error'
				SELECT	@automatic_proceed_next_alert = et.alert_id, 
						@automatic_proceed_next_event = CASE WHEN wea.alert_id = -7 THEN -7 ELSE et.event_trigger_id END
				FROM workflow_event_action wea
				INNER JOIN workflow_event_message wem ON wea.event_message_id = wem.event_message_id
				LEFT JOIN event_trigger et ON wea.alert_id = et.event_trigger_id
				WHERE wem.event_trigger_id = @event_trigger_id AND (wem.automatic_proceed = 'y' OR wem.automatic_proceed = 'h') AND wea.status_id = 736

			IF @automatic_proceed_next_event IS NULL
			BEGIN
				SELECT	@automatic_proceed_next_alert = et.alert_id, 
						@automatic_proceed_next_event = et.event_trigger_id  
				FROM workflow_schedule_task wst
				INNER JOIN workflow_schedule_task wst_n ON wst.parent = wst_n.parent AND wst.sort_order + 1 = wst_n.sort_order
				INNER JOIN event_trigger et ON wst_n.workflow_id = et.event_trigger_id
				WHERE wst.workflow_id = @event_trigger_id AND wst.workflow_id_type = 2
			END

			IF @automatic_proceed_next_event = -7
				SET @automatic_proceed_next_event = NULL

			IF @automatic_proceed_next_event IS NOT NULL
				EXEC spa_run_alert_sql @automatic_proceed_next_alert, NULL, NULL, NULL, NULL, @automatic_proceed_next_event, NULL, @workflow_process_id, @automatic_proceed_msg, @workflow_group_id	 
		END
	END

	-- UPDATE THE STATUS TO 'y'

	IF @alert_id = -99
	BEGIN
		UPDATE alert_output_status
		SET published = 'y'
		WHERE process_id = @activity_process_id
	END
	ELSE
	BEGIN
		UPDATE alert_output_status
		SET published = 'y'
		WHERE alert_id = @alert_id
	END

	
END
