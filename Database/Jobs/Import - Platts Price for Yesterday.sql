DECLARE @db_name NVARCHAR(100)
DECLARE @owner_name NVARCHAR(100)
DECLARE @job_category NVARCHAR(150)
DECLARE @command NVARCHAR(4000)
DECLARE @job_name NVARCHAR(250)
DECLARE @job_proxy_name NVARCHAR(150)
DECLARE @root NVARCHAR(1000)
DECLARE @ssis_path NVARCHAR(4000)

SET @db_name = DB_NAME()
SET @owner_name = dbo.FNAAppAdminID()
SET @job_category = N'Import'
SET @job_name = @db_name + N' - ' + @job_category + N' - Platts Price for Yesterday'

SELECT @job_proxy_name = CAST(sql_proxy_account AS NVARCHAR(150)) FROM connection_string AS cs
SELECT @root = dbo.FNAGetSSISPkgFullPath('PKG_NymexTreasuryPlattsPriceCurveImport', 'User::PS_PackageSubDir') 
SET @ssis_path = @root + 'platts.dtsx'

SET @command =  N'/FILE "' + @ssis_path + '" /CHECKPOINTING OFF /SET "\Package.Connections[OLE_CONN_MainDB].Properties[UserName]";"'+ @owner_name +'" /SET "\Package.Variables[User::ps_setupFileName].Properties[Value]";platts /SET "\Package.Variables[User::PS_dateOption].Properties[Value]";1 /REPORTING E'

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
		@enabled=0, 
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
		@os_run_priority=0, @subsystem=N'SSIS', 
		@command=@command, 
		@database_name=@db_name, 
		@flags=0, 
		@proxy_name=@job_proxy_name
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Run every 1 hour', 
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

