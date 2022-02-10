
/**

	The job is run at startup sql server agent service.

	Analysis:
	The issue is occurred when the position calc job is in idle stage (not start job and no history). Still is not replicable manual. It could be due to  slow system, interrupt job by restart sql agent or etc..
	The new position calc job is not created when exist job(WHERE b.name like 'dbname()- Calc Position Breakdown%') in such ideal stage and position is not calculated.



 Run job after restart sqlserver agent (FARRMS - Maintenance - Startup) and step tasks:

	UPDATE [TRMTracker_DEV_PT].dbo.process_deal_position_breakdown SET process_status=0 WHERE process_status=1 ( Put deals in queue that did not complete process)
	EXEC msdb.dbo.sp_delete_job @job_id='87C76A84-4C4F-4F01-AA22-CFA724F12B41', @delete_unused_schedule=1 – Drop position calc job that is in idle  stage
	EXEC [TRMTracker_DEV_PT].dbo.spa_calc_deal_position_breakdown -1 – Create/start position calc job

*/


DECLARE @db_name NVARCHAR(100)
DECLARE @owner_name NVARCHAR(100)
DECLARE @job_category NVARCHAR(150)
DECLARE @job_name NVARCHAR(250)
DECLARE @command NVARCHAR(2000)
--sp_helplogins

SET @owner_name = 'sa' --dbo.FNAAppAdminID()
SET @job_category = N'Maintenance'
SET @job_name = N'FARRMS - Maintenance - Startup'

SET @command = '
/**

	The job is run at startup sql server agent service.

	Activities in database level for fixing to create position calculation job( The position job is not creating due to already exist position job as running status though it is in idle stage. ):
	1. update dbo.process_deal_position_breakdown set process_status=0 where process_status=1
	2. EXEC msdb.dbo.sp_delete_job @job_id=''AADE5D46-F983-4A1E-8698-B3D25C3AD03F'', @delete_unused_schedule=1
	3. EXEC dbo.spa_calc_deal_position_breakdown -1 ( -1 is just passed as fake deal id to start position calc job)

*/


DECLARE @sql varchar(max),@st_update varchar(max),@st_pos_calc varchar(max)
SELECT distinct @sql=isnull(@sql+'';'','''') +''EXEC msdb.dbo.sp_delete_job @job_id=''''''+cast(b.job_id as varchar(100))+'''''', @delete_unused_schedule=1''
,@st_update=isnull(@st_update+'';'','''')+''UPDATE ''+quotename(left(b.name,charindex('' - Calc Position Breakdown'' ,b.name,1)-1))+''.dbo.process_deal_position_breakdown SET process_status=0 WHERE process_status=1''
,@st_pos_calc=isnull(@st_pos_calc+'';'','''')+''EXEC ''+db.db_name+''.dbo.spa_calc_deal_position_breakdown -1''
FROM msdb.dbo.sysjobs_view b  
--INNER JOIN dbo.farrms_sysjobactivity a  ON a.job_id=b.job_id 
	cross apply (
		select quotename(left(b.name,charindex('' - Calc Position Breakdown'' ,b.name,1)-1)) db_name
	) db
WHERE b.name like ''%- Calc Position Breakdown%''

--print(@st_update)
--print(@sql)
--print(@st_pos_calc)

exec(@sql)
exec(@st_update)
exec(@st_pos_calc)

'

BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0

IF EXISTS (SELECT job_id FROM msdb.dbo.sysjobs_view WHERE  NAME = @job_name)
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
		@description=@job_category, 
		@category_name=@job_category, 
		@owner_login_name=@owner_name, @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Maintenance', 
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
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Agent_Startup', 
		@enabled=1, 
		@freq_type=64, 
		@freq_interval=1, 
		@freq_subday_type=0, 
		@freq_subday_interval=0, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=1, 
		@active_start_date=20211102, 
		@active_end_date=99991231, 
		@active_start_time=0, 
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


