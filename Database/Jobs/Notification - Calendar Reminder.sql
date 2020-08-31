DECLARE @ReturnCode INT,
		@db_name VARCHAR(100),
		@owner_name NVARCHAR(100),
		@job_name NVARCHAR(250),
		@job_category NVARCHAR(150)

SELECT @ReturnCode = 0,
		@db_name = DB_NAME(), 
		@owner_name = dbo.FNAAppAdminID(),
		@job_category = N'Notification',
		@job_name = @db_name + N' - ' + @job_category + N' - Calendar Reminder'

BEGIN TRANSACTION
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=@job_category AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=@job_category
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

IF EXISTS (SELECT job_id FROM   msdb.dbo.sysjobs_view WHERE  NAME = @job_name)
	EXEC msdb.dbo.sp_delete_job @job_name = @job_name, @delete_unused_schedule = 1

DECLARE @jobId BINARY(16)

DECLARE @sql_stmt varchar(1000) =  N'DECLARE @contextinfo varbinary(128)
SELECT @contextinfo = convert(varbinary(128),'''+ @owner_name +''')
SET CONTEXT_INFO @contextinfo
GO
EXEC spa_calendar ''r'''

EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name = @job_name, 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'Calendar Reminder.', 
		@category_name= @job_category, 
		@owner_login_name = @owner_name,
		@job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

EXEC @ReturnCode = msdb.dbo.sp_add_jobstep 
		@job_id=@jobId, 
		@step_name=N'Run Notification Calendar Reminder', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=3, 
		@on_fail_step_id=2, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=@sql_stmt, 
		@database_name= @db_name, 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Run every day', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=4, 
		@freq_subday_interval=1, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20160228, 
		@active_end_date=99991231, 
		@active_start_time=00000, 
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