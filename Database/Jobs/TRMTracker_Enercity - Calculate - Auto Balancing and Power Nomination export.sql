

DECLARE @job_db_name NVARCHAR(250) = DB_NAME() 
	, @job_owner NVARCHAR(100) =  SYSTEM_USER	--dbo.FNAAppAdminID()    --in case of maintenance jobs, put SYSTEM_USER 




/****** Object:  Job [TRMTracker_Enercity - Calculate - Auto Balancing and Power Nomination export]    Script Date: 2/8/2021 7:35:18 PM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 2/8/2021 7:35:20 PM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

IF EXISTS (SELECT job_id FROM msdb.dbo.sysjobs_view WHERE NAME = N'TRMTracker_Enercity - Calculate - Auto Balancing and Power Nomination export')
	EXEC msdb.dbo.sp_delete_job @job_name = N'TRMTracker_Enercity - Calculate - Auto Balancing and Power Nomination export', @delete_unused_schedule = 1


DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'TRMTracker_Enercity - Calculate - Auto Balancing and Power Nomination export', 
		@enabled=0, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'No description available.', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=@job_owner, @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [calc auto balancing]    Script Date: 2/8/2021 7:35:22 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'calc auto balancing', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'DECLARE @contextinfo varbinary(128)
SELECT @contextinfo = convert(varbinary(128),''enercity_4442'')
			
DECLARE @job_name NVARCHAR(1000) = ''$(ESCAPE_NONE(JOBNAME))''
EXEC sys.sp_set_session_context @key = N''JOB_NAME'', @value = @job_name;
SET CONTEXT_INFO @contextinfo

exec [dbo].[spa_export_nomination_power_balance]
	@as_of_date  = null,
	@sub =null,
	@str =null,
	@book =null,
	@sub_book =null,
	@location_ids =null,
	@term_start = null,
	@term_end = null,
	@round = 10,
	@commodity = 123,
	@physical_financial = ''p'',
	@balance_location_id=NULL,
	@trans_deal_type_id=1185,
	@power_plant_deal_header_id=NULL,
	@process_id =null', 
		@database_name=@job_db_name, 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Run every 15mins', 
		@enabled=1, 
		@freq_type=8, 
		@freq_interval=127, 
		@freq_subday_type=4, 
		@freq_subday_interval=15, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=1, 
		@active_start_date=20201002, 
		@active_end_date=99991231, 
		@active_start_time=800, 
		@active_end_time=235500, 
		@schedule_uid=N'52b35ce4-1613-47ae-a838-8039f8988029'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:

GO


