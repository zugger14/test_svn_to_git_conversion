DECLARE @db_name NVARCHAR(100)
DECLARE @owner_name NVARCHAR(100)
DECLARE @job_category NVARCHAR(150)
DECLARE @command NVARCHAR(4000)
DECLARE @job_name NVARCHAR(250)
DECLARE @job_proxy_name NVARCHAR(150)
DECLARE @root NVARCHAR(1000)

SET @db_name = DB_NAME()
SET @owner_name = dbo.FNAAppAdminID()
SET @job_category = N'Import'
SET @job_name = @db_name + N' - ' + @job_category + N' - Platts'

DECLARE @sql_cmd VARCHAR(MAX), @ixp_rule_id INT

SELECT @ixp_rule_id = ixp_rules_id FROM ixp_rules WHERE ixp_rule_hash = '12C73B31_EA7B_4905_8F61_210E1610FD33'
SET @sql_cmd = 'DECLARE @contextinfo varbinary(128)
	
				SELECT @contextinfo = convert(varbinary(128),'''+ @owner_name +''')
				SET CONTEXT_INFO @contextinfo
				GO
				DECLARE @process_id VARCHAR(100)= REPLACE(NEWID(),''-'',''_'')

				EXEC spa_ixp_rules  @flag=''t'', @process_id=@process_id, @ixp_rules_id=' + CAST(@ixp_rule_id AS VARCHAR) + ', @run_table='''', @source = ''21407'', @run_with_custom_enable = ''n'', @parameter_xml=''<Root><PSRecordset paramName="PS_StartDate" paramValue="today"/></Root>'', @enable_ftp=0, @run_in_debug_mode =''y'''

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
		@description=N'Import Platts Price for Yesterday', 
		@category_name=@job_category, 
		@owner_login_name=@owner_name, @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Run Import Platts Price for Yesterday', 
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
		@flags=0, 
		@proxy_name=@job_proxy_name
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Run Daily', 
		@enabled=1, 
		@freq_type=8, 
		@freq_interval=62, 
		@freq_subday_type=1, 
		@freq_subday_interval=1, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=1, 
		@active_start_date=20151012, 
		@active_end_date=99991231, 
		@active_start_time=70000, 
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

