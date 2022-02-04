DECLARE @db_name NVARCHAR(100)
DECLARE @owner_name NVARCHAR(100)
DECLARE @job_category NVARCHAR(150)
DECLARE @job_name NVARCHAR(250)
DECLARE @job_proxy_name NVARCHAR(150)

SET @db_name = DB_NAME()
SET @owner_name = SYSTEM_USER
SET @job_category = N'Import'
SET @job_name = @db_name + N' - ' + @job_category + N' - Prisma Capacity Trade'

DECLARE @sql_cmd NVARCHAR(MAX)

SET @sql_cmd = '
DECLARE @contextinfo VARBINARY(128)	
DECLARE @app_admin_user NVARCHAR(1000) = dbo.FNAAppAdminID() 
SELECT @contextinfo = CONVERT(VARBINARY(128),@app_admin_user)
SET CONTEXT_INFO @contextinfo
GO 
DECLARE @process_id NVARCHAR(100) = dbo.FNAGetNewID()
DECLARE @date NVARCHAR(35), @ixp_rule_id NVARCHAR(10), @parameters NVARCHAR(MAX)
,@call_spa NVARCHAR(MAX), @role_id NVARCHAR(20), @utc_date DATETIME , @timezone INT
, @time_difference INT
SELECT @timezone = TIMEZONE_ID FROM time_zones WHERE TIMEZONE_NAME = ''(GMT +1:00 hour) Brussels, Copenhagen, Madrid, Paris''
SELECT @utc_date = dbo.FNAGetUTCTTime(GETDATE(), @timezone)

--Rule Name : Prisma Capacity Deal
SELECT @ixp_rule_id = ixp_rules_id FROM ixp_rules WHERE ixp_rules_name = ''Prisma Capacity Deal''
SELECT @time_difference = -30
SELECT @date = FORMAT(DATEADD(minute, @time_difference, @utc_date), ''yyyy-MM-ddTHH:mm:ss.fffZ'')				

SELECT @parameters = ''<Root><PSRecordset paramName="PS_auctionId" paramValue="null" paramType="input"/><PSRecordset paramName="PS_bookedAt" paramValue="null" paramType="calendar"/><PSRecordset paramName="PS_bookedSince" paramValue="'' + @date + ''" paramType="calendar"/><PSRecordset paramName="PS_bookedBefore" paramValue="null" paramType="calendar"/></Root>''
SELECT @call_spa = ''EXEC spa_ixp_rules @flag = ''''r'''', @ixp_rules_id ='' + @ixp_rule_id +'' ,@source = ''''21407'''',@enable_ftp = '''''''',@parameter_xml = '''''' + @parameters + '''''', @run_in_debug_mode =''''n'''', @process_id ='''''' + @process_id + ''''''''
SELECT @role_id = role_id FROM application_security_role WHERE role_name = ''Enercity Traders''
SET @process_id =  SUBSTRING(REPLACE(NEWID(), ''-'',''''), 1 ,13)

EXEC batch_report_process 
@spa = @call_spa,
@flag = ''i'', @jobId = '''', @scheduleId = '''', @report_name = '''', @active_start_date = '''', @active_start_time = '''', @freq_type = '''', @freq_interval = '''', @freq_subday_type = '''', @freq_subday_interval = '''', 
@freq_relative_interval = '''', @freq_recurrence_factor = '''', @active_end_time = '''', @batch_type = ''i'', 
@generate_dynamic_params = ''0'', @custom_as_of_date = '''', @notify_users = '''', @notify_roles = @role_id, 
@notification_type = ''751'', @send_attachment = ''n'', @batch_unique_id = @process_id, @source = NULL, 
@csv_path = '''', @login_id = '''', @holiday_calendar_id = '''', @non_sys_users = '''', 
@temp_notes_path = '''', @export_table_name = '''', 
@export_table_name_suffix = '''', @compress_file = ''n'', @delim = '','', @is_header = ''1'', @xml_format = ''-100000'',
@export_file_format = ''.csv'', 
@debug_mode = '''', @export_web_services_id = ''''

'

BEGIN TRANSACTION
IF  EXISTS (SELECT job_id FROM msdb.dbo.sysjobs_view WHERE name = @job_name)
      EXEC msdb.dbo.sp_delete_job @job_name = @job_name, @delete_unused_schedule = 1
   
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0

IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=@job_category AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=@job_category
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=@job_name, 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'No description available.', 
		@category_name=@job_category, 
		@owner_login_name=@owner_name, @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Step 1', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=@sql_cmd, 
		@database_name=@db_name, 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'First minute', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=8, 
		@freq_subday_interval=1, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20210928, 
		@active_end_date=99991231, 
		@active_start_time=101, 
		@active_end_time=235959
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Thirty Minute', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=8, 
		@freq_subday_interval=1, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20210928, 
		@active_end_date=99991231, 
		@active_start_time=3000, 
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


