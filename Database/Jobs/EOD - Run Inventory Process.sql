DECLARE @db_name NVARCHAR(100)
DECLARE @owner_name NVARCHAR(100)
DECLARE @job_name NVARCHAR(250)
DECLARE @step2_command NVARCHAR(MAX)

SET @db_name = DB_NAME()
SET @owner_name = SYSTEM_USER
SET @job_name = @db_name + N'- EOD - Run Inventory Process'
DECLARE @sql_cmd NVARCHAR(MAX)		

SET @sql_cmd = N'		
DECLARE @contextinfo VARBINARY(128)
SELECT @contextinfo = CONVERT(VARBINARY(128),''' + @owner_name + ''')
SET CONTEXT_INFO @contextinfo
GO

DECLARE @sub_book_ids VARCHAR(MAX) , @wacog_group_ids VARCHAR(MAX), @storage_assets_ids VARCHAR(MAX)
, @as_of_date DATE, @term_start DATE

SELECT @sub_book_ids = COALESCE(@sub_book_ids + '','', '''') + sub_book_id FROM
(
SELECT DISTINCT gmv.clm7_value sub_book_id FROM generic_mapping_header gmh
INNER JOIN generic_mapping_values gmv ON gmv.mapping_table_id = gmh.mapping_table_id
WHERE mapping_name = ''Storage Book Mapping''
UNION
SELECT DISTINCT gmv.clm2_value FROM generic_mapping_header gmh
INNER JOIN generic_mapping_values gmv ON gmv.mapping_table_id = gmh.mapping_table_id
WHERE mapping_name = ''Scheduling Storage Mapping''
UNION
SELECT DISTINCT gmv.clm4_value FROM generic_mapping_header gmh
INNER JOIN generic_mapping_values gmv ON gmv.mapping_table_id = gmh.mapping_table_id
WHERE mapping_name = ''Scheduling Transportation Mapping''
UNION
SELECT DISTINCT gmv.clm3_value FROM generic_mapping_header gmh
INNER JOIN generic_mapping_values gmv ON gmv.mapping_table_id = gmh.mapping_table_id
WHERE mapping_name = ''Nomination Mapping''
) a

SELECT @storage_assets_ids = COALESCE(@storage_assets_ids + '','', '''') + CAST(general_assest_id AS VARCHAR(20)) 
FROM [general_assest_info_virtual_storage] gaivs 
INNER JOIN contract_group cg 
ON cg.contract_id = gaivs.agreement 
INNER JOIN source_minor_location sml 
ON sml.source_minor_location_id = gaivs.storage_location
INNER JOIN static_data_value sdv  ON sdv.value_id = gaivs.storage_type

SELECT @wacog_group_ids = COALESCE(@wacog_group_ids + '','', '''') + CAST(wacog_group_id AS VARCHAR(20)) FROM wacog_group

SET @as_of_date = GETDATE()
SET @term_start = DATEFROMPARTS(YEAR(GETDATE()),MONTH(GETDATE()),1)

EXEC [spa_run_inventory_process]
@as_of_date = @as_of_date
, @term_start = @term_start
, @term_end = @as_of_date
, @wacog_group_name_id = @wacog_group_ids
, @storage_asset_id = @storage_assets_ids
, @lpds_sub_book_id = @sub_book_ids
, @lpods_sub_book_id = @sub_book_ids
, @tds_sub_book_id = @sub_book_ids
, @ids_sub_book_id = @sub_book_ids
'
/****** Object:  Job [EOD - Run Inventory Process]    Script Date: 8/13/2019 4:16:37 PM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0

IF EXISTS ( SELECT job_id FROM msdb.dbo.sysjobs_view WHERE NAME = @job_name )
    EXEC msdb.dbo.sp_delete_job @job_name = @job_name, @delete_unused_schedule = 1

/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 8/13/2019 4:16:38 PM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END
SET @step2_command = 'EXEC ' + @db_name + '.dbo.spa_message_board ''i'', '''+ @owner_name +''', NULL, ''ImportData'', ''Job '+ @job_name +' failed.'', '''', '''', ''e'', NULL'

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=@job_name, 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'No description available.', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=@owner_name, @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Step 1]    Script Date: 8/13/2019 4:16:39 PM ******/

EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Run Inventory Process', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=3, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=@sql_cmd, 
		@database_name=@db_name, 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

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
		@database_name=@db_name, 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Schedule1', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=1, 
		@freq_subday_interval=0, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20190814, 
		@active_end_date=99991231, 
		@active_start_time=220000, 
		@active_end_time=235959, 
		@schedule_uid=N'ad653308-2021-4fd8-82cb-e850b7c1b43f'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO
