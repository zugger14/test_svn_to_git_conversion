DECLARE @db_name NVARCHAR(100)
DECLARE @owner_name NVARCHAR(100)
DECLARE @job_category NVARCHAR(150)
DECLARE @job_name NVARCHAR(250)
DECLARE @job_proxy_name NVARCHAR(150)

SET @db_name = DB_NAME()
SET @owner_name = SYSTEM_USER
SET @job_category = N'Import'
SET @job_name = @db_name + N' - ' + @job_category + N' - Trayport Price Enrichment'

DECLARE @sql_cmd NVARCHAR(MAX),  @sql_cmd2 NVARCHAR(MAX)

SET @sql_cmd = '
DECLARE @contextinfo VARBINARY(128)	
SELECT @contextinfo = CONVERT(VARBINARY(128),''' + @owner_name + ''')
SET CONTEXT_INFO @contextinfo
GO 
IF OBJECT_ID(''tempdb..#temp_deals'') IS NOT NULL
	DROP TABLE #temp_deals

CREATE TABLE #temp_deals (source_deal_header_id INT)

UPDATE sdd 
SET 
fixed_price = udt.legLastpx 
OUTPUT INSERTED.source_deal_header_id INTO #temp_deals
FROM source_deal_header sdh
INNER JOIN udt_ice_deal_price udt ON udt.tradeId1 = SUBSTRING(sdh.deal_id,0, CHARINDEX(''|'', sdh.deal_id, 0))
INNER JOIN source_deal_detail sdd ON sdd.source_deal_header_id = sdh.source_deal_header_id 
AND sdd.term_start = udt.legStartDate
WHERE ISNULL(udt.LegUnitOfMeasure, ''n'') = ''n''

UPDATE udt 
SET 
LegUnitOfMeasure = ''y''
FROM source_deal_header sdh
INNER JOIN udt_ice_deal_price udt ON udt.tradeId1 = SUBSTRING(sdh.deal_id,0, CHARINDEX(''|'', sdh.deal_id, 0))
INNER JOIN source_deal_detail sdd ON sdd.source_deal_header_id = sdh.source_deal_header_id 
AND sdd.term_start = udt.legStartDate
WHERE ISNULL(udt.LegUnitOfMeasure, ''n'') = ''n''

IF NOT EXISTS (SELECT 1 FROM #temp_deals) RETURN

DECLARE @msg NVARCHAR(MAX), @deal_ids NVARCHAR(MAX)

SELECT @deal_ids = COALESCE(@deal_ids + '', '', '''') +
CAST(source_deal_header_id AS NVARCHAR(10)) FROM 
(SELECT DISTINCT source_deal_header_id FROM #temp_deals ) a
ORDER BY source_deal_header_id
SET @msg = ''Price has been updated for Deal Id(s) '' + @deal_ids

DECLARE @process_id VARCHAR(100) = dbo.FNAGetNewID()
EXEC spa_NotificationUserByRole 7, @process_id, ''TrayportPrice'', @msg, ''s'', ''Trayport Price Enrichment'', 0
'

SET @sql_cmd2 = 'DECLARE @process_id VARCHAR(100) = dbo.FNAGetNewID()
EXEC spa_NotificationUserByRole 7, @process_id, ''TrayportPrice'', ''Failed to update Trayport Price. Please contact technical support'', ''e'', ''Trayport Price Enrichment'', 0'

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
		@on_fail_action=3, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=@sql_cmd, 
		@database_name=@db_name, 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'On failure', 
		@step_id=2, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=@sql_cmd2,
		@database_name=@db_name, 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Daily Schedule', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=1, 
		@freq_subday_interval=1, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20200603, 
		@active_end_date=99991231, 
		@active_start_time=180000, 
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


