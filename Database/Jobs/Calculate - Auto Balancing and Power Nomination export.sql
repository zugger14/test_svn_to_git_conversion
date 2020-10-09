DECLARE @db_name NVARCHAR(100)
DECLARE @owner_name NVARCHAR(100)
DECLARE @job_name NVARCHAR(250)

SET @db_name = DB_NAME()
SET @owner_name = 'farrms_admin' --SYSTEM_USER
SET @job_name = @db_name + N' - Calculate - Auto Balancing and Power Nomination export'

BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

IF EXISTS (SELECT job_id FROM   msdb.dbo.sysjobs_view WHERE  NAME = @job_name)
	EXEC msdb.dbo.sp_delete_job @job_name = @job_name, @delete_unused_schedule = 1

DECLARE @command VARCHAR(MAX) = '

--set statistics io on
--set statistics time on
DECLARE @current_datetime DATETIME = GETDATE()

DECLARE @_as_of_date VARCHAR(10) = CONVERT(VARCHAR(10), @current_datetime, 120)
DECLARE @_term_start VARCHAR(10) = @_as_of_date, 
		@_term_end VARCHAR(10) = CASE WHEN CAST(@current_datetime AS TIME) >= ''23:38'' THEN CONVERT(VARCHAR(10), DATEADD(DAY, 1, @current_datetime), 120) ELSE @_as_of_date END
	  , @_location_ids VARCHAR(1000), @_balance_location_id INT, @_desc VARCHAR(MAX), @process_id VARCHAR(100) = REPLACE(NEWID(),''-'',''_'')

DECLARE @report_file_full_path VARCHAR(300) -- ''\\EU-D-SQL01\shared_docs_TRMTracker_Enercity\temp_Note\'' 
SELECT @report_file_full_path = document_path + ''\temp_Note\'' FROM connection_string
SET @report_file_full_path = @report_file_full_path + ''Enercity Nomination Report_farrms_admin.xlsx''

SELECT @_location_ids = STUFF((SELECT '','' + CAST(source_minor_location_id AS VARCHAR(10))
FROM source_minor_location where location_name IN (''Tennet'', ''Amprion'', ''Transnet'', ''50Hertz'')
FOR XML PATH('''')) ,1,1,'''')
SELECT @_balance_location_id = source_minor_location_id FROM source_minor_location WHERE location_name = ''Tennet''

IF OBJECT_ID(''tempdb..#tmp_result'') IS NOT NULL
	DROP TABLE #tmp_result
 
CREATE TABLE #tmp_result (
	 ErrorCode VARCHAR(200) COLLATE DATABASE_DEFAULT
	,Module VARCHAR(200) COLLATE DATABASE_DEFAULT
	,Area VARCHAR(200) COLLATE DATABASE_DEFAULT
	,STATUS VARCHAR(200) COLLATE DATABASE_DEFAULT
	,Message VARCHAR(1000) COLLATE DATABASE_DEFAULT
	,Recommendation VARCHAR(200) COLLATE DATABASE_DEFAULT
)

--INSERT INTO #tmp_result (ErrorCode, Module, Area, Status, Message, Recommendation)   
  EXEC spa_calc_power_balance  -- insert exec causes error due to nested so insertion in #tmp_result is used in sp itself
	  ''b''
	, @_as_of_date
	, NULL
	, NULL
	, NULL
	, NULL
	, NULL
	, @_location_ids
	, @_term_start
	, @_term_end
	, NULL
	, NULL
	, NULL
	, ''RAMPS'' 
	, NULL
	, ''123''
	, ''p''
	, NULL
	, @_balance_location_id
	, 1185
	, NULL
    ,NULL

IF EXISTS(SELECT 1 FROM #tmp_result WHERE [Status] = ''Error'')
BEGIN
	SET @_desc = ''Error in auto balancing''
	SELECT top 1 @_desc = [message] FROM #tmp_result WHERE [Status] = ''Error''
 	EXEC spa_message_board ''u'', ''farrms_admin'', NULL, ''Calculation'', @_desc, '''', '''', ''e'', NULL, NULL, @process_id, '''', '''', '''', ''n''

END
ELSE
BEGIN
	SET @_desc = ''Auto-Balancing Calculation Process is completed.''
	--SELECT top 1 @_desc = [message] FROM #tmp_result WHERE [Status] = ''Success''
 	EXEC spa_message_board ''u'', ''farrms_admin'', NULL, ''Calculation'', @_desc, '''', '''', ''e'', NULL, NULL, @process_id, '''', '''', '''', ''n''

	--DECLARE @_as_of_date varchar(10) =  CONVERT(VARCHAR(10), GETDATE(), 120)
	--DECLARE @_term_start VARCHAR(10) = @_as_of_date, @_term_end VARCHAR(10) = @_as_of_date
	--	  , @_location_ids VARCHAR(1000), @_balance_location_id INT

	DECLARE @report_param VARCHAR(MAX)
	SET @report_param = ''report_filter:''''''''as_of_date='' + @_as_of_date + '',sub_id=NULL,stra_id=NULL,book_id=NULL,sub_book_id=NULL,convert_timezone_id=14,term_start='' + @_term_start + '',term_end='' + @_term_end + '',commodity_id=123,source_deal_header_ids=NULL,counterparty_ids=NULL,location_ids=NULL,deal_id=NULL,deal_status_id=NULL,deal_type_id=NULL,external_id1=NULL'''''''',is_refresh:0,report_region:en-US,runtime_user:farrms_admin,global_currency_format:$,global_date_format:dd.M.yyyy,global_thousand_format:,#,global_rounding_format:#0.0000,global_price_rounding_format:#0.0000,global_volume_rounding_format:#0.00,global_amount_rounding_format:#0.00,global_science_rounding_format:2,global_negative_mark_format:1,global_number_format_region:de-DE,is_html:n''
	 --print @report_param

	EXEC spa_rfx_export_report_job @report_param = @report_param
	, @proc_desc = ''BatchReport'', @user_login_id = ''farrms_admin'', @report_RDL_name = ''Enercity Nomination Report_Enercity Nomination Report'' 
	, @report_file_name = ''Enercity Nomination Report_farrms_admin.xlsx''
	, @report_file_full_path = @report_file_full_path
	, @output_file_format = ''EXCELOPENXML'', @paramset_hash = ''9F239C20_03E5_4F47_81A9_55A6A1EB2959''

END

'
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
		@job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
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
		@command = @command, 
		@database_name = @db_name, 
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
		@active_end_time=235500
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:

GO


