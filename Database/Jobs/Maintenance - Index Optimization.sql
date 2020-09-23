/* This job is for Daily Index optimization*/
DECLARE @db_name NVARCHAR(100)
DECLARE @owner_name NVARCHAR(100)
DECLARE @job_category NVARCHAR(150)
DECLARE @job_name NVARCHAR(400)
DECLARE @command NVARCHAR(4000)

SET @db_name = DB_NAME()
SET @owner_name = SYSTEM_USER
SET @job_category = N'Maintenance'
SET @job_name = @db_name + N' - ' + @job_category + N' - Index Optimization'
SET @command = N'

/************************************* StopAndNotifyDDL Disable START *************************************/
IF EXISTS (SELECT 1 FROM sys.triggers WHERE parent_class = 0 AND name = ''StopAndNotifyDDL'')
BEGIN   
    DISABLE TRIGGER [StopAndNotifyDDL] ON DATABASE;
END;
GO 
/************************************* StopAndNotifyDDL Disable END ***************************************/

DECLARE @contextinfo VARBINARY(128)
                  SELECT @contextinfo = CONVERT(VARBINARY(128), '''+ @owner_name +''')
                  SET CONTEXT_INFO @contextinfo
                  GO
DECLARE @db_name VARCHAR(150)
SET @db_name = DB_NAME()

EXECUTE dbo.spa_indexoptimize @Databases = @db_name,
@FragmentationLow = NULL,
@FragmentationMedium = ''INDEX_REORGANIZE,INDEX_REBUILD_ONLINE,INDEX_REBUILD_OFFLINE'',
@FragmentationHigh = ''INDEX_REBUILD_ONLINE,INDEX_REBUILD_OFFLINE'',
@FragmentationLevel1 = 5,
@FragmentationLevel2 = 30,
@UpdateStatistics = ''ALL'',
@OnlyModifiedStatistics = ''Y'',
@LogToTable = ''Y'',
@MinNumberOfPages = 100

/************************************* StopAndNotifyDDL Enable START *************************************/
IF EXISTS (SELECT 1 FROM sys.triggers WHERE parent_class = 0 AND name = ''StopAndNotifyDDL'')
BEGIN   
    ENABLE TRIGGER [StopAndNotifyDDL] ON DATABASE;
END;
GO 
/************************************* StopAndNotifyDDL Enable END ***************************************/

'

BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0

IF  EXISTS (SELECT job_id FROM msdb.dbo.sysjobs_view WHERE name = @job_name)
      EXEC msdb.dbo.sp_delete_job @job_name = @job_name, @delete_unused_schedule = 1

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
		@description=N'Index Optimization.', 
		@category_name=@job_category, 
		@owner_login_name=@owner_name, @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Run Index Optimization', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=@command, 
		@database_name=@db_name, 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Run every day', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=1, 
		@freq_subday_interval=0, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20120201, 
		@active_end_date=99991231, 
		@active_start_time=20000, 
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


