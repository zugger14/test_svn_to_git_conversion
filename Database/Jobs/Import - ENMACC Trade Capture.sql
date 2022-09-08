DECLARE @job_db_name	NVARCHAR(250) = DB_NAME(),
		@job_owner		NVARCHAR(100) = dbo.FNADBUser(),
		@job_category	NVARCHAR(150) = N'Import', 
		@job_name		NVARCHAR(500) = '',
		@step_init		NVARCHAR(2000) = '',
		@step1_command	NVARCHAR(MAX) = '',
		@step2_command	NVARCHAR(MAX) = '',
		@username		NVARCHAR(100) = dbo.FNAAppAdminID()  

DECLARE @job_description NVARCHAR (MAX) = 'Created by: ' + @username + CHAR(13) + ' Get Trade and its detail from ENMACC Interface' 

SET @job_name = @job_db_name + N' - ' + @job_category + N' - ENMACC Trade Capture' 
SET @step_init = N' 
	DECLARE @app_admin_user NVARCHAR(1000) = dbo.FNAAppAdminID() 
	EXEC sys.sp_set_session_context @key = N''DB_USER'', @value = @app_admin_user 
	GO 
' 

SET @step1_command = @step_init + N'
	DECLARE @trade_end NVARCHAR(20) = CONVERT(VARCHAR, GETDATE(), 120)
	DECLARE @trade_start NVARCHAR(20) =  CONVERT(VARCHAR,DATEADD(MINUTE, -2, @trade_end), 120)
	DECLARE @sql NVARCHAR(MAX)
	, @rule_id NVARCHAR(20)
	, @server_path NVARCHAR(200)
	, @process_id NVARCHAR(200) = dbo.FNAGetNewID()

	SELECT @rule_id = ixp_rules_id FROM ixp_rules WHERE ixp_rules_name = ''ENMACC Trade Capture''
	SELECT @server_path = document_path + ''\temp_note'' FROM connection_string

	SET @sql = 	''
		EXEC spa_ixp_rules @flag = ''''r'''', @ixp_rules_id = '''''' + @rule_id + '''''', @server_path = '''''' + @server_path + '''''', @source = ''''21407'''', @enable_ftp = '''''''', @parameter_xml = ''''<Root><PSRecordset paramName="PS_Commodity" paramValue="null" paramType="combo"/><PSRecordset paramName="PS_Venue" paramValue="null" paramType="combo"/><PSRecordset paramName="PS_TradedStart" paramValue="'' +@trade_start+ ''" paramType="calendar"/><PSRecordset paramName="PS_TradedEnd" paramValue="''+ @trade_end +''" paramType="calendar"/><PSRecordset paramName="PS_Skip" paramValue="null" paramType="input"/><PSRecordset paramName="PS_Limit" paramValue="100" paramType="input"/></Root>'''', @batch_process_id="'' + @process_id + ''", @batch_report_param=''''spa_ixp_rules @flag = ''''''''r'''''''', @ixp_rules_id = '''''''''' + @rule_id + '''''''''', @server_path = '''''''''' + @server_path + '''''''''', @source = ''''''''21407'''''''', @enable_ftp = '''''''''''''''', @parameter_xml = ''''''''<Root><PSRecordset paramName="PS_Commodity" paramValue="null" paramType="combo"/><PSRecordset paramName="PS_Venue" paramValue="null" paramType="combo"/><PSRecordset paramName="PS_TradedStart" paramValue="'' +@trade_start+ ''" paramType="calendar"/><PSRecordset paramName="PS_TradedEnd" paramValue="''+ @trade_end +''" paramType="calendar"/><PSRecordset paramName="PS_Skip" paramValue="null" paramType="input"/><PSRecordset paramName="PS_Limit" paramValue="100" paramType="input"/></Root>'''''''''''', @notify_empty_source = 0
	''
	EXEC(@sql)'
	
SET @step2_command = @step_init + N'
	EXEC spa_message_board ''i'', ''' +@job_owner +''', NULL, ''ImportData'', ''Job '+@job_db_name+' - '+ @job_category + ' - ENMACC Trade Capture.'', '''', '''', ''e'', NULL'

BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
--delete job if already exists
IF EXISTS(SELECT job_id FROM msdb.dbo.sysjobs_view WHERE name = @job_name)
	EXEC msdb.dbo.sp_delete_job @job_name = @job_name, @delete_unused_schedule = 1

IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name = @job_category AND category_class = 1)
BEGIN
	EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=@job_category
	IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=@job_name,
		@enabled=0, 
		@notify_level_eventlog=2, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=@job_description ,
		@category_name=@job_category, 
		@owner_login_name=@job_owner,
		@job_id = @jobId OUTPUT

IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Run Import Rule]    Script Date: 8/15/2022 1:53:03 PM ******/
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
		@command=@step1_command, 
		@database_name=@job_db_name, 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Notify on failure]    Script Date: 8/15/2022 1:53:03 PM ******/
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
		@command=@step2_command, 
		@database_name=@job_db_name, 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Run weekdays-8 to 6', 
		@enabled=1, 
		@freq_type=8, 
		@freq_interval=62, 
		@freq_subday_type=4, 
		@freq_subday_interval=2, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=1, 
		@active_start_date=20220801, 
		@active_end_date=99991231, 
		@active_start_time=80000, 
		@active_end_time=180000
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO


