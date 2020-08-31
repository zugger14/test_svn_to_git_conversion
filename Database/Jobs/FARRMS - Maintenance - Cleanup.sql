DECLARE @db_name NVARCHAR(MAX)
SET @db_name = DB_NAME()
DECLARE @owner_name NVARCHAR(MAX)
SET @owner_name = SYSTEM_USER

DECLARE @prior_no_days_for_job_delete INT
SET @prior_no_days_for_job_delete = 3  -- clearing expired jobs prior this day: this value can be changed as required

DECLARE @prior_no_days_for_adiha_tables_delete INT
SET @prior_no_days_for_adiha_tables_delete = 3  -- clearing adiha_process tables prior this day: this value can be changed as required

/*
	Command for Step 1: Clear all adiha_process tables.
	In this step, code from spa_clear_all_temp_table(for clearing adiha_process tables) has been directly applied
*/
DECLARE @command1 NVARCHAR(MAX)

SET @command1 = N'
DECLARE @contextinfo VARBINARY(128)
SELECT @contextinfo = CONVERT(VARBINARY(128), '''+ @owner_name +''')
SET CONTEXT_INFO @contextinfo
GO

--EXEC spa_clear_all_temp_table 1

DECLARE @process_id	VARCHAR(150) = NULL
DECLARE @tbl_name	VARCHAR(130)
DECLARE @tot		INT
DECLARE @cnt		INT
DECLARE @sel_date	DATETIME

SET @sel_date =
CAST(YEAR(GETDATE() - ' + CAST(@prior_no_days_for_adiha_tables_delete AS NVARCHAR(10)) + ') AS VARCHAR) + ''-'' + CASE WHEN (MONTH(GETDATE() - ' + CAST(@prior_no_days_for_adiha_tables_delete AS NVARCHAR(10)) + ') < 10)
	THEN ''0''
	ELSE ''''
END +
CAST(MONTH(GETDATE() - ' + CAST(@prior_no_days_for_adiha_tables_delete AS NVARCHAR(10)) + ') AS VARCHAR) + ''-'' + CASE WHEN (DAY(GETDATE() - ' + CAST(@prior_no_days_for_adiha_tables_delete AS NVARCHAR(10)) + ') < 10)
	THEN ''0''
	ELSE ''''
END +
CAST(DAY(GETDATE() - ' + CAST(@prior_no_days_for_adiha_tables_delete AS NVARCHAR(10)) + ') AS VARCHAR)

--EXEC spa_print @sel_date

CREATE TABLE #temp1(
	sno			INT IDENTITY(1 ,1),
	table_name	VARCHAR(130) COLLATE DATABASE_DEFAULT
)

IF @process_id IS NULL
BEGIN
	INSERT INTO #temp1 (table_name)
	SELECT name
	FROM adiha_process.dbo.sysobjects
	WHERE xtype = ''u''
		AND crdate <= @sel_date
		AND CHARINDEX(''batch_export_'', [name]) <> 1 --exclude export tables in deletion action; export table starts with batch_export_
		AND CHARINDEX(''batch_report_power_bi_'', [name]) <> 1 --exclude power bi tables in deletion action; power bi table starts with batch_report_power_bi_
END
ELSE
BEGIN
	INSERT INTO #temp1 (table_name)
	SELECT name
	FROM adiha_process.dbo.sysobjects so
	WHERE xtype = ''u''
		AND crdate <= @sel_date and name like ''%''+@process_id+''%''
		AND CHARINDEX(''batch_export_'', [name]) <> 1	--exclude export tables in deletion action; export table starts with batch_export_
		AND CHARINDEX(''batch_report_power_bi_'', [name]) <> 1	--exclude power bi tables in deletion action; power bi table starts with batch_report_power_bi_
END

SET @tot = @@ROWCOUNT
SET @cnt = 1

WHILE @cnt < @tot
BEGIN
	SELECT @tbl_name = table_name
	FROM #temp1
	WHERE sno = @cnt
    
	EXEC (''DROP TABLE adiha_process.dbo.['' + @tbl_name + '']'')
	SET @cnt = @cnt + 1
END

--DB Mail log
--https://www.databasejournal.com/features/mssql/purging-old-database-mail-items.html
DECLARE @PurgeDate DATETIME =  DATEADD(DD,-30,GETDATE());
EXEC msdb.dbo.sysmail_delete_mailitems_sp @sent_before = @PurgeDate;

'
-- End command for Step 1

/*
	Command for Step 3
	Cleanup expired jobs.
*/
DECLARE @command3 NVARCHAR(MAX)
SET @command3 = N'
-- EXEC spa_clean_jobs 3 (has been replaced with code within the SP)
DECLARE @j_id VARCHAR(MAX)
					
DECLARE tblCursor CURSOR FOR
SELECT DISTINCT j.job_id
FROM msdb.dbo.sysjobs j
LEFT JOIN msdb.dbo.sysjobschedules s ON j.job_id = s.job_id
LEFT JOIN msdb.dbo.sysjobhistory h ON j.job_id = h.job_id
WHERE [enabled] = 1
	AND ISNULL([h].[run_status], 0) IN (0, 1, 3, 5) AND h.run_status IS NOT NULL
	AND CAST (
			CASE ISNULL(next_run_date,''1'')
				WHEN ''0'' THEN ''9999-jan-01''
				WHEN ''1'' THEN ''1900-jan-01''
				ELSE LTRIM(STR(next_run_date)) + '' '' + STUFF(STUFF(RIGHT(''000000'' + LTRIM(STR(next_run_time)), 6), 3, 0, '':''), 6, 0, '':'')
			END
		AS DATETIME) < GETDATE() - ' + CAST(@prior_no_days_for_job_delete AS NVARCHAR(10)) + '

OPEN tblCursor
FETCH NEXT FROM tblCursor INTO @j_id
WHILE @@FETCH_STATUS = 0
BEGIN
	-- Existence check added here just before deletion because, the above cursor might take a time within which a job could get completed and removed.
	-- Doing so will help to prevent error of job not found.
	IF EXISTS (SELECT 1 FROM msdb.dbo.sysjobs WHERE job_id = @j_id)
	BEGIN
		EXEC msdb.dbo.sp_delete_job @job_id = @j_id, @delete_unused_schedule = 1, @delete_history = 1
	END

	FETCH NEXT FROM tblCursor into @j_id
END
CLOSE tblCursor
DEALLOCATE tblCursor
'
-- End command for Step 3: Cleanup expired jobs

--actual job code starts here 
BEGIN TRANSACTION
	DECLARE @ReturnCode INT
	SELECT @ReturnCode = 0

	IF NOT EXISTS (SELECT NAME FROM msdb.dbo.syscategories WHERE NAME = N'Maintenance'	AND category_class = 1)
	BEGIN
		EXEC @ReturnCode = msdb.dbo.sp_add_category @class = N'JOB', @type = N'LOCAL', @name = N'Maintenance'
    
		IF (@@ERROR <> 0 OR @ReturnCode <> 0)
			GOTO QuitWithRollback
	END

	IF EXISTS (SELECT job_id FROM msdb.dbo.sysjobs_view WHERE NAME = N'FARRMS - Maintenance - Cleanup')
		EXEC msdb.dbo.sp_delete_job @job_name = N'FARRMS - Maintenance - Cleanup', @delete_unused_schedule = 1
    
	DECLARE @jobId BINARY(16)
	EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'FARRMS - Maintenance - Cleanup', 
		@enabled=1, 
		@notify_level_eventlog=2, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'Deletes old tables from adiha_process db, removes old expired jobs.', 
		@category_name=N'Maintenance', 
		@owner_login_name=@owner_name, @job_id = @jobId OUTPUT

	IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

	EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Cleanup old adiha_process tables', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=3, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=@command1,
		@database_name=@db_name, 
		@flags=0
	IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

	EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Shrink adiha_process', 
		@step_id=2, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=3, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'DBCC SHRINKDATABASE(N''adiha_process'')', 
		@database_name=N'master', 
		@flags=0
	IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

	EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Cleanup expired jobs', 
		@step_id=3, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=@command3, 
		@database_name=@db_name, 
		@flags=0
	IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

	EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
	IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

	EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Everyday', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=1, 
		@freq_subday_interval=0, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20100101, 
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