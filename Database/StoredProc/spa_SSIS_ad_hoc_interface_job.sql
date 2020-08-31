
IF OBJECT_ID(N'spa_SSIS_ad_hoc_interface_job', N'P') IS NOT NULL
DROP PROCEDURE [dbo].[spa_SSIS_ad_hoc_interface_job] 
GO 

--select * from source_system_data_import_status where process_id='88881'
-- No data found in staging table(source_deal_detail).
--spa_SSIS_ad_hoc_interface_job 'n','sss','2'
CREATE PROC [dbo].[spa_SSIS_ad_hoc_interface_job] 
	@process_ssis CHAR(1) = NULL,
	@process_id VARCHAR(150),
	@source_system VARCHAR(150) = NULL
AS 
DECLARE @user_login_id  VARCHAR(50),
        @source_name    VARCHAR(100)

SET @user_login_id = dbo.FNADBUser()

DECLARE @desc VARCHAR(500)

IF @process_ssis='y'
BEGIN
BEGIN TRY
	create table #temp_JObs(
	session_id int,
	job_id uniqueidentifier,
	job_name sysname,
	run_requested_date datetime,
	run_requested_source sysname,
	queued_date datetime,
	start_execution_date datetime,
	last_executed_step_id int,
last_exectued_step_date datetime,
stop_execution_date datetime,
next_scheduled_run_date datetime,
job_history_id int,
message nvarchar(1024) COLLATE DATABASE_DEFAULT,
run_status int,
operator_id_emailed int,
operator_id_netsent int,
operator_id_paged int
)

--	declare	@job_id UNIQUEIDENTIFIER 
--	select @job_id = job_id from msdb..sysjobs_view where name = 'Fastracker_Interface_job'

insert into #temp_JObs 
exec msdb.dbo.sp_help_jobactivity @job_name='Fastracker_Interface_job' 
--select * from #temp_JObs where job_name = 'Fastracker_Interface_Job'
--	insert into #temp_JObs
--	EXECUTE master.dbo.xp_sqlagent_enum_jobs 1,'sa',@job_id

declare @last_run datetime,@run_status int
select @last_run=start_execution_date,@run_status=run_status 
from #temp_JObs where job_name = 'Fastracker_Interface_job' 

if @run_status IS NULL
begin
	
	set @desc='FASTracker Interface process is running,	please wait till it completes its imports'
	
	insert into source_system_data_import_status(process_id,code,module,source,type,
	[description],recommendation) 
	select @process_id,'Error','Import Data','Interface',
	'Data Error',
	@desc,'N/A.'
	
	EXEC  spa_message_board 'i', @user_login_id, NULL, 'ImportData',  @desc, '', '', 'e', 'Interface',
	null,@process_id

end	
else
begin
	set @desc='FASTracker Interface process started, please visit Import Audit Report for detail status '
	EXEC  spa_message_board 'i', @user_login_id, NULL, 'ImportData',  @desc, '', '', 's', 'Interface',
	null,@process_id

	exec msdb.dbo.sp_start_job @job_name ='Fastracker_Interface_job'
end
end try
begin catch
	
	set @desc='SQL Error found:  (' + ERROR_MESSAGE() + ')'
	
	insert into source_system_data_import_status(process_id,code,module,source,type,
	[description],recommendation) 
	select @process_id,'Error','Import Data','Interface',
	'Data Error',
	@desc,'N/A.'
	
	EXEC  spa_message_board 'i', @user_login_id, NULL, 'ImportData',  @desc, '', '', 'e', 'Interface',
	null,@process_id	
end catch
	
end
else
begin
	

	set @desc='FASTracker Interface process from staging table started, please visit Import Audit Report for detail status '
	EXEC  spa_message_board 'i', @user_login_id, NULL, 'ImportData',  @desc, '', '', 's', 'Interface',
	null,@process_id

	select @source_name=source_system_name from source_system_description where source_system_id=@source_system
	

	insert import_data_files_audit(dir_path,
			imp_file_name,
			as_of_date,
			status,
			elapsed_time,
			process_id,
			create_user,
			create_ts)
	values('Adhoc Interface',
			'Process from staging tables',
			convert(varchar,getdate(),102),
			'p',
			0,
			@process_id,
			@user_login_id,
			getdate())

declare @proceed_staging int
declare @max_dt datetime
set @proceed_staging=0
if (select count(*) from ssis_mtm_formate2_error_log) > 0
begin
	select @max_dt=max(convert(datetime,as_of_date,120)) from ssis_mtm_formate2_error_log
	delete ssis_mtm_formate2_error_log where convert(datetime,as_of_date,120)<@max_dt
	set @proceed_staging=1
	exec sp_ssis_MTM_formate2 @process_id,@source_name,NULL,'y'	
end
if (select count(*) from ssis_mtm_formate1_error_log) > 0
begin
	select @max_dt=max(convert(datetime,as_of_date,120)) from ssis_mtm_formate1_error_log
	delete ssis_mtm_formate1_error_log where convert(datetime,as_of_date,120)<@max_dt
	set @proceed_staging=1
	exec sp_ssis_MTM_formate1 @process_id,@source_name,NULL,'y'		
end
if (select count(*) from ssis_position_formate2_error_log) > 0
begin
	set @proceed_staging=1
	delete ssis_position_formate2
	declare @as_of_date varchar(20)
	select @as_of_date=max(pnl_as_of_date) from ssis_position_formate2_error_log
	exec spa_position_load @process_id,@source_name,@as_of_date,'y'		
end
if @proceed_staging=0
begin
	update import_data_files_audit
	set imp_file_name='Staging table is empty',
	status='c'
	where process_id=@process_id
end

--if (select count(*) from ssis_position_formate2_error_log) > 0
--begin
--	exec sp_ssis_position_formate2 @process_id,NULL,NULL,'y'
--end
--if (select count(*) from ssis_position_formate1_error_log) > 0
--begin
--	exec sp_ssis_position_formate1 @process_id,NULL,NULL,'y'
--end
end



