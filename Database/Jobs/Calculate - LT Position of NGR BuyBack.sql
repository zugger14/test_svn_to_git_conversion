DECLARE @db_name NVARCHAR(100)
DECLARE @owner_name NVARCHAR(100)
DECLARE @job_name NVARCHAR(250)

SET @db_name = DB_NAME()
SET @owner_name =  SYSTEM_USER
SET @job_name = @db_name + N' - Calculate - LT Position of NGR BuyBack'

BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0

IF EXISTS (SELECT job_id FROM   msdb.dbo.sysjobs_view WHERE  NAME = @job_name)
	EXEC msdb.dbo.sp_delete_job @job_name = @job_name, @delete_unused_schedule = 1

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=@job_name, 
		@enabled=0, 
		@notify_level_eventlog=2, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'No description available.', 
		@owner_login_name=@owner_name, @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'calc', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=2, 
		@on_fail_action=4, 
		@on_fail_step_id=2, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'

GO
DECLARE @run_date DATE = GETDATE()
DECLARE @alert_sql_id INT, @event_trigger_id INT, @workflow_group_id INT 
DECLARE @delivery_date DATETIME = CONVERT(VARCHAR(7), DATEADD(month, 1, @run_date), 120) + ''-01''

IF (@run_date = dbo.FNAGetBusinessDay(''p'', dbo.FNAGetBusinessDay(''p'', dbo.FNAGetBusinessDay(''p'', @delivery_date, 50000114), 50000114), 50000114))
BEGIN
		SELECT @alert_sql_id = alert_sql_id FROM alert_sql WHERE alert_sql_name = ''NGR BuyBack of LT Position Tennet''
		SELECT @event_trigger_id = e.event_trigger_id FROM event_trigger e
		INNER JOIN module_events m ON m.module_events_id = e.modules_event_id
		WHERE e.alert_id = @alert_sql_id AND  m.workflow_name = ''NGR BuyBack of LT Position Tennet''
		SELECT @workflow_group_id = id FROM workflow_schedule_task WHERE [text] = ''NGR BuyBack of LT Position Tennet''

		IF( @alert_sql_id IS NOT NULL AND @event_trigger_id IS NOT NULL AND @workflow_group_id IS NOT NULL)
			EXEC spa_run_alert_sql @alert_sql_id, NULL, NULL, NULL, NULL, @event_trigger_id, NULL, NULL, NULL, @workflow_group_id
END
	
', 
		@database_name=@db_name, 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback


EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'run daily', 
		@enabled=1, 
		@freq_type=8, 
		@freq_interval=62, 
		@freq_subday_type=1, 
		@freq_subday_interval=0, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=1, 
		@active_start_date=20180529, 
		@active_end_date=99991231, 
		@active_start_time=100000, 
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


