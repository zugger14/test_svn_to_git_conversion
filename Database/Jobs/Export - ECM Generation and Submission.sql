DECLARE @db_name NVARCHAR(100)
DECLARE @owner_name NVARCHAR(100)
DECLARE @job_category NVARCHAR(150)
DECLARE @job_name NVARCHAR(250)
DECLARE @command NVARCHAR(MAX),
		@command1 NVARCHAR(MAX)
DECLARE @name NVARCHAR(4000)

SET @db_name = DB_NAME()
SET @owner_name = dbo.FNAAppAdminID()
SET @job_category = N'Export'
SET @job_name = @db_name + N' - ' + @job_category + N' - ECM Generation and Submission'
SET @name = N'Export - ECM Generation and Submission'
SET @command = N'  DECLARE @temp_path NVARCHAR(500), 
		@regulatory_role INT,
		@process_id NVARCHAR(100),
		@process_id1 NVARCHAR(100),
		@csv_file_path NVARCHAR(2000),
		@form_xml NVARCHAR(MAX),
		@ecm_process_id NVARCHAR(100),
		@email_subject NVARCHAR(MAX),
		@email_description NVARCHAR(MAX),
		@process_table  NVARCHAR(200),
		@file_name  NVARCHAR(200),
		@user_login_id NVARCHAR(100) = dbo.FNADBUSER(),
		@full_file_path NVARCHAR(200),
		@output_result NVARCHAR(MAX),
		@desc NVARCHAR(MAX),
		@url NVARCHAR(1000),
		@email_enable NVARCHAR(2) = ''n''

SELECT @form_xml=''<Root><FormXML  create_date_from="'' + CONVERT(VARCHAR(10), GETDATE(),120) + ''" create_date_to="'' + CONVERT(VARCHAR(10), GETDATE(),120) + ''" submission_type="44705" report_type="39405" deal_date_from="'' + CONVERT(VARCHAR(10), GETDATE(),120) + ''" deal_date_to="'' + CONVERT(VARCHAR(10), GETDATE(),120) + ''" deal_id="" commodity_id="" counterparty_id="" contract_id="" book_structure="" subsidiary_id="" strategy_id="" book_id="" subbook_id="" generate_uti="n" action_type_error="n" level="" action_type="" valuation_date="" level_mifid="" action_type_mifid="" include_bfi="y" ></FormXML></Root>''

SELECT @csv_file_path = document_path + ''\temp_Note\''
FROM connection_string

IF OBJECT_ID(''tempdb..#temp_result'') IS NOT NULL
	DROP TABLE #temp_result
CREATE TABLE #temp_result(
	 ErrorCode NVARCHAR(1000) COLLATE DATABASE_DEFAULT
	,Module NVARCHAR(1000) COLLATE DATABASE_DEFAULT
	,Area NVARCHAR(1000) COLLATE DATABASE_DEFAULT
	,Status NVARCHAR(1000) COLLATE DATABASE_DEFAULT
	,Message NVARCHAR(1000) COLLATE DATABASE_DEFAULT
	,Recommendation NVARCHAR(1000) COLLATE DATABASE_DEFAULT
)

INSERT INTO #temp_result
EXEC spa_regulatory_reporting  @flag = ''GEN''
	,@form_xml = @form_xml

SELECT @regulatory_role = role_id 
FROM application_security_role 
WHERE role_name = ''Regulatory Submission''

SELECT @ecm_process_id = Recommendation
FROM #temp_result

SELECT @process_id1 = dbo.FNAGetNewID()
SELECT @process_id = RIGHT(REPLACE(@process_id1,''_'',''''), 13)

INSERT INTO batch_process_notifications (user_login_id, role_id, process_id, notification_type, attach_file, scheduled, csv_file_path, compress_file, delimiter, 
report_header, output_file_format, xml_format)
SELECT NULL, role_id, @process_id, 752, ''y'', ''n'', @csv_file_path, ''n'', '','', 1, ''.csv'', -100000 
FROM application_security_role 
WHERE role_name = ''Regulatory Submission''

IF EXISTS(SELECT 1 FROM #temp_result WHERE [ErrorCode] = ''Success'')
BEGIN	
	IF EXISTS (SELECT 1 FROM source_ecm WHERE process_id = @ecm_process_id AND NULLIF(error_validation_message,'''') IS NOT NULL)
	BEGIN
		SET @email_enable = ''y''
		SELECT @email_subject = DB_NAME() +  '' : ECM generation and submission.''
		SELECT @email_description = ''ECM report generated and submitted with error. Please check the attached file for more information''

		SELECT @file_name = ''ECM_Generation_Submission'' + CONVERT(VARCHAR(30), GETDATE(),112) + REPLACE(CONVERT(VARCHAR(30), GETDATE(),108),'':'','''') + ''.csv''
		SELECT @full_file_path = @csv_file_path + @file_name

		SELECT @process_table = dbo.FNAProcessTableName(''ecm_gen_sub_'', dbo.FNADBUser(), @process_id1) 
		EXEC(''SELECT source_deal_header_id, deal_id, REPLACE(error_validation_message, '''','''', '''';'''') error_validation_message, dbo.FNADateTimeFormat(create_ts, NULL) create_ts
			 INTO '' + @process_table + '' 
			 FROM source_ecm 
			 WHERE process_id = '''''' + @ecm_process_id + '''''' 
			 AND NULLIF(error_validation_message,'''''''') IS NOT NULL
			''
		)

		EXEC spa_export_to_csv @table_name = @process_table
							  ,@export_file_name = @full_file_path
							  ,@include_column_headers = ''y''
							  ,@delimiter = '',''
							  ,@compress_file = ''n''
							  ,@use_date_conversion = ''y''
							  ,@strip_html = ''n''
							  ,@enclosed_with_quotes = ''n''
							  ,@result = @output_result OUTPUT

		INSERT INTO source_system_data_import_status (process_id, code, module, source, type, description)
		SELECT @process_id1, ''Error'', ''ECM generation and submission'', ''ECM generation and submission'', ''Error'', ''Deal ID : '' + deal_id + '', Error : '' + error_validation_message
		FROM source_ecm 
		WHERE process_id = @ecm_process_id
		AND NULLIF(error_validation_message,'''') IS NOT NULL

		SELECT @url = ''../../adiha.php.scripts/dev/spa_html.php?__user_name__='' + @user_login_id + ''&spa=exec spa_get_import_process_status '''''' + @process_id1 + '''''',''''''+ @user_login_id+''''''''

		SELECT @desc = ''ECM report generated and submitted with error. <a target="_blank" href="'' + @url + ''">Click here.</a>''

		DELETE FROM source_ecm 
		WHERE process_id = @ecm_process_id 
		AND NULLIF(error_validation_message,'''') IS NOT NULL		
	END

	EXEC spa_convert_xml @sub_id = NULL
					  , @stra_id = NULL
					  , @book_id = NULL
					  , @sub_book_id = NULL
					  , @Delivery_Start_Date = NULL
					  , @Delivery_End_Date = NULL
					  , @process_id = @ecm_process_id
					  , @report_type = NULL
					  , @mirror_reporting = ''0''
					  , @file_transfer_endpoint_name = ''ECM Submission''

	EXEC spa_message_board @flag = ''u''
							, @user_login_id =  @user_login_id
							, @message_id =  NULL
							, @source = ''ECM generation and submission''
							, @description = @desc
							, @url_desc = ''''
							, @url = ''''
							, @type = ''e''
							, @email_enable = @email_enable
							, @email_subject = @email_subject
							, @email_description = @email_description
							, @file_name = @file_name
							, @process_id = @process_id
	
END
ELSE 
BEGIN
	SELECT @desc = ''No Deal found for ECM.''
	EXEC spa_message_board @flag = ''i''
						, @user_login_id =  @user_login_id
						, @message_id =  NULL
						, @source = ''ECM generation and submission''
						, @description = @desc
						, @url_desc = ''''
						, @url = ''''
						, @type = ''e''
						, @process_id = @process_id
END
'

SET @command1 = N'EXEC spa_message_board ''i'', ''' + @owner_name + ''', NULL, ''BatchReport'', ''Job ' + @job_name + ' failed.'', '''', '''', ''e'', NULL'
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0

IF EXISTS (SELECT job_id FROM   msdb.dbo.sysjobs_view WHERE  NAME = @job_name)
	EXEC msdb.dbo.sp_delete_job @job_name = @job_name, @delete_unused_schedule = 1

IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=@job_category AND category_class=1)
BEGIN
	EXEC @ReturnCode = msdb.dbo.sp_add_category @CLASS=N'JOB', @type=N'LOCAL', @name=@job_category
	IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
 
END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=@job_name, 
		@enabled=0, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'No description available.', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Step 1]    Script Date: 06/08/2020 6:26:59 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Step 1', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=3, 
		@on_fail_step_id=2, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=@command, 
		@database_name=@db_name, 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Job fail]    Script Date: 06/08/2020 3:45:14 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Job fail', 
		@step_id=2, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=@command1, 
		@database_name=@db_name, 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Import', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=1, 
		@freq_subday_interval=1, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20201009, 
		@active_end_date=99991231, 
		@active_start_time=180000, 
		@active_end_time=235959
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO
