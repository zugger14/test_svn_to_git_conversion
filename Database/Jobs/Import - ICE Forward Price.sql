DECLARE @db_name NVARCHAR(100)
DECLARE @owner_name NVARCHAR(100)
DECLARE @job_category NVARCHAR(150)
DECLARE @job_name NVARCHAR(350)

SET @db_name = DB_NAME()
SET @owner_name = dbo.FNAAppAdminID()
SET @job_category = N'Import'
SET @job_name = @db_name + N' - ' + @job_category + N' - ICE Forward Price'

DECLARE @role_id INT, @process_id VARCHAR(100), @csv_file_path VARCHAR(2000)
SELECT @process_id = 'a' + RIGHT(dbo.FNAGetNewID(), 12)	

SELECT TOP 1 @csv_file_path =  document_path + '\temp_Note\' FROM connection_string
SELECT @role_id = role_id FROM application_security_role WHERE role_name = 'Data Import Exception'	
 
DELETE FROM batch_process_notifications WHERE cc_email = 'noreply_iceprice@anteroresources.com'
INSERT INTO batch_process_notifications(user_login_id, role_id, process_id, notification_type, attach_file, scheduled, csv_file_path, compress_file, 
										delimiter, report_header, xml_format, output_file_format, cc_email)
SELECT NULL, @role_id, @process_id, 751, 'n', 'y', @csv_file_path, 'n', ',', 1, -100000, '.csv', 'noreply_iceprice@anteroresources.com'

DECLARE @command VARCHAR(MAX) = 'DECLARE @contextinfo varbinary(128)
	
				SELECT @contextinfo = convert(varbinary(128),''' + @owner_name + ''')
				SET CONTEXT_INFO @contextinfo
				GO
DECLARE @as_of_date VARCHAR(10) = CONVERT(VARCHAR(10), GETDATE(), 120)
DECLARE @sql VARCHAR(MAX)
DECLARE @rule_id VARCHAR(20)
SELECT @rule_id = ixp_rules_id FROM ixp_rules WHERE ixp_rules_name = ''Ice Price Curve''

		SET @sql = 	''
	EXEC spa_run_sp_with_dynamic_params ''''spa_ixp_rules ''''''''r'''''''', NULL, ''''''''''+@rule_id+'''''''''', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, ''''''''\\app\shared_docs_TRMTracker\temp_Note'''''''', ''''''''<Root><PSRecordset paramName="PS_AsOfDate" paramValue="''+@as_of_date+''"></PSRecordset></Root>'''''''', NULL,@batch_process_id=''''''''PROCESS_ID:'''''''',@batch_report_param=''''''''spa_ixp_rules ''''''''''''''''r'''''''''''''''', NULL, ''''''''''''''''''+@rule_id+'''''''''''''''''', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, ''''''''''''''''\\APP01\shared_docs_TRMTracker\temp_Note'''''''''''''''', ''''''''''''''''<Root><PSRecordset paramName="PS_AsOfDate" paramValue="''+@as_of_date+''"></PSRecordset></Root>'''''''''''''''', NULL'''''''''''',''''' + @process_id + ''''',NULL
		
		''
 EXEC(@sql)

	'
		              
DECLARE @command2 VARCHAR(4000) = 'EXEC ' + @db_name + '.dbo.spa_message_board ''i'', ''' + @owner_name + ''', NULL, ''ImportData'', ''Job ' + @job_name + ' failed.'', '''', '''', ''e'', NULL'

BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0

IF EXISTS ( SELECT job_id FROM msdb.dbo.sysjobs_view WHERE NAME = @job_name )
    EXEC msdb.dbo.sp_delete_job @job_name = @job_name, @delete_unused_schedule = 1

IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=@job_category AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=@job_category
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=@job_name, 
		@enabled=1, 
		@notify_level_eventlog=2, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'Import ICE Forward Price', 
		@category_name=@job_category, 
		@owner_login_name=@owner_name, @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Step1]    Script Date: 4/21/2016 3:23:09 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Run Import Rule', 
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
/****** Object:  Step [Step2]    Script Date: 4/21/2016 3:23:09 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Notify on failure', 
		@step_id=2, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=@command2, 
		@database_name=@db_name, 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Run daily', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=1, 
		@freq_subday_interval=0, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20170602, 
		@active_end_date=99991231, 
		@active_start_time=191500, 
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

