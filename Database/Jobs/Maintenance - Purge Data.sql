DECLARE @db_name NVARCHAR(100)
DECLARE @owner_name NVARCHAR(100)
DECLARE @job_category NVARCHAR(150)
DECLARE @job_name NVARCHAR(400)
DECLARE @command NVARCHAR(4000)

SET @db_name = DB_NAME()
SET @owner_name = SYSTEM_USER

SET @job_category = N'Maintenance'
SET @job_name = @db_name + N' - ' + @job_category + N' - Purge Data'

/*
	Command for Step 1
	Periodic cleanup of log tables.
*/
DECLARE @cmd NVARCHAR(MAX) = CAST('' AS NVARCHAR(MAX)) + N'
DECLARE @one_month AS DATETIME = DATEADD(DD, -30, GETDATE()),
	@one_week AS DATETIME =	DATEADD(WEEK, -1, GETDATE()),
	@three_months AS DATETIME = DATEADD(DD, -90, GETDATE()),
	@five_days AS DATETIME = DATEADD(DD, -5, GETDATE())

IF EXISTS (
	SELECT 1
	FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = ''clr_error_log''
		AND COLUMN_NAME = ''log_date''
)
BEGIN
	DELETE FROM clr_error_log WHERE log_date < @one_month
END

IF EXISTS (
	SELECT 1
	FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = ''credit_exposure_calculation_log''
		AND COLUMN_NAME = ''create_ts''
)
BEGIN
	DELETE FROM credit_exposure_calculation_log WHERE create_ts < @one_week
END

IF EXISTS (
	SELECT 1
	FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = ''alert_output_status''
		AND COLUMN_NAME = ''create_ts''
)
BEGIN
	DELETE FROM alert_output_status WHERE create_ts < @one_week
END

IF EXISTS (
	SELECT 1
	FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = ''email_notes''
		AND COLUMN_NAME = ''create_ts''
)
BEGIN
	DELETE FROM email_notes WHERE create_ts < @one_month
END

IF EXISTS (
	SELECT 1
	FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = ''eod_process_status''
		AND COLUMN_NAME = ''create_ts''
)
BEGIN
	DELETE FROM eod_process_status WHERE create_ts < @three_months
END

IF EXISTS (
	SELECT 1
	FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = ''ems_input_error_log''
		AND COLUMN_NAME = ''create_ts''
)
BEGIN
	DELETE FROM ems_input_error_log WHERE create_ts < @one_week
END

IF EXISTS (
	SELECT 1
	FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = ''finalize_approve_test_run_log''
		AND COLUMN_NAME = ''create_ts''
)
BEGIN
	DELETE FROM finalize_approve_test_run_log WHERE create_ts < @one_month
END

IF EXISTS (
	SELECT 1
	FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = ''import_data_files_audit''
		AND COLUMN_NAME = ''create_ts''
)
BEGIN
	DELETE FROM import_data_files_audit WHERE create_ts < @three_months
END

IF EXISTS (
	SELECT 1
	FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = ''import_data_request_status_log''
		AND COLUMN_NAME = ''create_ts''
)
BEGIN
	DELETE FROM import_data_request_status_log WHERE create_ts < @one_week
END

IF EXISTS (
	SELECT 1
	FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = ''Import_Transactions_Log''
		AND COLUMN_NAME = ''create_ts''
)
BEGIN
	DELETE FROM Import_Transactions_Log WHERE create_ts < @one_week
END

IF EXISTS (
	SELECT 1
	FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = ''interface_missing_deal_log''
		AND COLUMN_NAME = ''create_ts''
)
BEGIN
	DELETE FROM interface_missing_deal_log WHERE create_ts < @one_week
END

IF EXISTS (
	SELECT 1
	FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = ''inventory_accounting_log''
		AND COLUMN_NAME = ''create_ts''
)
BEGIN
	DELETE FROM inventory_accounting_log WHERE create_ts < @one_week
END

IF EXISTS (
	SELECT 1
	FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = ''invoice_email_log''
		AND COLUMN_NAME = ''create_ts''
)
BEGIN
	DELETE FROM invoice_email_log WHERE create_ts < @one_week
END

IF EXISTS (
	SELECT 1
	FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = ''ixp_import_data_interface_staging''
		AND COLUMN_NAME = ''create_ts''
)
BEGIN
	DELETE FROM ixp_import_data_interface_staging WHERE create_ts < @one_week
END

IF EXISTS (
	SELECT 1
	FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = ''import_process_info''
		AND COLUMN_NAME = ''create_ts''
)
BEGIN
	DELETE FROM import_process_info WHERE create_ts < @five_days
END

IF EXISTS (
	SELECT 1
	FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = ''memcache_log''
		AND COLUMN_NAME = ''create_ts''
)
BEGIN
	DELETE FROM memcache_log WHERE create_ts < @five_days
END

IF EXISTS (
	SELECT 1
	FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = ''calendar_events''
		AND COLUMN_NAME = ''end_date''
)
BEGIN
	DELETE FROM calendar_events WHERE end_date < @one_month
END

IF EXISTS (
	SELECT 1
	FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = ''message_board''
		AND COLUMN_NAME = ''create_ts''
)
BEGIN
	DELETE FROM message_board WHERE create_ts < @one_month
END

IF EXISTS (
	SELECT 1
	FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = ''mtm_test_run_log''
		AND COLUMN_NAME = ''create_ts''
)
BEGIN
	DELETE FROM mtm_test_run_log WHERE create_ts < @three_months
END

IF EXISTS (
	SELECT 1
	FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = ''pratos_nominator_request_log''
		AND COLUMN_NAME = ''create_ts''
)
BEGIN
	DELETE FROM pratos_nominator_request_log WHERE create_ts < @one_week
END

IF EXISTS (
	SELECT 1
	FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = ''process_log_tracker''
		AND COLUMN_NAME = ''time_start''
)
BEGIN
	DELETE FROM process_log_tracker WHERE time_start < @five_days
END

IF EXISTS (
	SELECT 1
	FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = ''process_settlement_invoice_log''
		AND COLUMN_NAME = ''create_ts''
)
BEGIN
	DELETE FROM process_settlement_invoice_log WHERE create_ts < @one_week
END

IF EXISTS (
	SELECT 1
	FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = ''rec_assign_log''
		AND COLUMN_NAME = ''create_ts''
)
BEGIN
	DELETE FROM rec_assign_log WHERE create_ts < @one_week
END

IF EXISTS (
	SELECT 1
	FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = ''recovery_password_log''
		AND COLUMN_NAME = ''request_date''
) 
BEGIN
	DELETE FROM recovery_password_log WHERE request_date < @one_week
END

IF EXISTS (
	SELECT 1
	FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = ''remote_service_response_log''
		AND COLUMN_NAME = ''create_ts''
)
BEGIN
	DELETE FROM remote_service_response_log WHERE create_ts < @three_months
END

IF EXISTS (
	SELECT 1
	FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = ''source_deal_error_log''
		AND COLUMN_NAME = ''create_ts''
)
BEGIN
	DELETE FROM source_deal_error_log WHERE create_ts < @three_months
END

IF EXISTS (
	SELECT 1
	FROM INFORMATION_SCHEMA.COLUMNS
	WHERE  TABLE_NAME = ''source_system_data_import_status''
		AND COLUMN_NAME = ''create_ts''
)
BEGIN
	DELETE FROM source_system_data_import_status WHERE create_ts < @three_months
END

IF EXISTS (
	SELECT 1
	FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = ''source_system_data_import_status_detail''
		AND COLUMN_NAME = ''create_ts''
)
BEGIN
	DELETE FROM source_system_data_import_status_detail WHERE create_ts < @three_months
END

IF EXISTS (
	SELECT 1
	FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = ''source_system_data_import_status_vol''
		AND COLUMN_NAME = ''create_ts''
)
BEGIN
	DELETE FROM source_system_data_import_status_vol WHERE create_ts < @three_months
END

IF EXISTS (
	SELECT 1
	FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = ''source_system_data_import_status_vol_detail''
		AND COLUMN_NAME = ''create_ts''
)
BEGIN
	DELETE FROM source_system_data_import_status_vol_detail WHERE create_ts < @three_months
END

IF EXISTS (
	SELECT 1
	FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = ''ssis_mtm_formate1_error_log''
		AND COLUMN_NAME = ''create_ts''
)
BEGIN
	DELETE FROM ssis_mtm_formate1_error_log WHERE create_ts < @one_week
END

IF EXISTS (
	SELECT 1
	FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = ''ssis_mtm_formate2_error_log''
		AND COLUMN_NAME = ''create_ts''
)
BEGIN
	DELETE FROM ssis_mtm_formate2_error_log WHERE create_ts < @one_week
END

IF EXISTS (
	SELECT 1
	FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = ''ssis_position_formate1_error_log''
		AND COLUMN_NAME = ''create_ts''
)
BEGIN
	DELETE FROM ssis_position_formate1_error_log WHERE create_ts < @one_week
END

IF EXISTS (
	SELECT 1
	FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = ''ssis_position_formate2_error_log''
		AND COLUMN_NAME = ''create_ts''
)
BEGIN
	DELETE FROM ssis_position_formate2_error_log WHERE create_ts < @one_week
END

IF EXISTS (
	SELECT 1
	FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = ''sysssislog''
		AND COLUMN_NAME = ''starttime''
)
BEGIN
	DELETE FROM sysssislog WHERE starttime < @one_month
END

IF EXISTS (
	SELECT 1
	FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = ''system_access_log''
		AND COLUMN_NAME = ''access_timestamp''
)
BEGIN
	DELETE FROM system_access_log WHERE access_timestamp < @three_months
END

IF EXISTS (
	SELECT 1
	FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = ''trm_sap_status_log_detail''
		AND COLUMN_NAME = ''BillingDate''
)
BEGIN
	DELETE FROM trm_sap_status_log_detail WHERE STUFF(BillingDate, 5, 0, ''-'') + ''-01'' < @one_week
END

IF EXISTS (
	SELECT 1
	FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = ''trm_sap_status_log_header''
		AND COLUMN_NAME = ''create_ts''
)
BEGIN
	DELETE FROM trm_sap_status_log_header WHERE create_ts < @one_week
END

IF EXISTS (
	SELECT 1
	FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = ''user_application_log''
		AND COLUMN_NAME = ''log_date''
)
BEGIN
	DELETE FROM user_application_log WHERE log_date < @three_months
END

IF EXISTS (
	SELECT 1
	FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = ''fix_message_log''
		AND COLUMN_NAME = ''create_ts''
)
BEGIN
	DELETE FROM fix_message_log WHERE create_ts < @three_months
END

IF EXISTS (
	SELECT 1
	FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = ''CommandLog''
		AND COLUMN_NAME = ''EndTime''
)
BEGIN
	DELETE FROM CommandLog WHERE EndTime < @one_week
END

IF EXISTS (
	SELECT 1
	FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = ''pnl_component_price_detail''
		AND COLUMN_NAME = ''run_as_of_date''
)
BEGIN
	DECLARE @row_count INT;
 
	SET @row_count = 1;
 
	WHILE @row_count > 0
	BEGIN
		DELETE TOP (10000) FROM pnl_component_price_detail WHERE run_as_of_date < @one_month 

		SET @row_count = @@ROWCOUNT
	END
END

'

BEGIN TRANSACTION

DECLARE @jobId BINARY(16)
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0

IF EXISTS (SELECT job_id FROM msdb.dbo.sysjobs_view WHERE [name] = @job_name)
	EXEC msdb.dbo.sp_delete_job @job_name = @job_name, @delete_unused_schedule = 1

IF NOT EXISTS (SELECT [name] FROM msdb.dbo.syscategories WHERE [name] = @job_category AND category_class = 1)
BEGIN
	EXEC @ReturnCode = msdb.dbo.sp_add_category @CLASS=N'JOB', @type=N'LOCAL', @name=@job_category

	IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
END

EXEC @ReturnCode = msdb.dbo.sp_add_job @job_name =  @job_name,
     @enabled = 1,
     @notify_level_eventlog = 0,
     @notify_level_email = 0,
     @notify_level_netsend = 0,
     @notify_level_page = 0,
     @delete_level = 0,
     @description = N'Periodic database cleanup.',
     @category_name = @job_category,
     @owner_login_name = @owner_name,
     @job_id = @jobId OUTPUT

IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id = @jobId,
     @step_name = N'Purge Data',
     @step_id = 1,
     @cmdexec_success_code = 0,
     @on_success_action = 1,
     @on_success_step_id = 0,
     @on_fail_action = 2,
     @on_fail_step_id = 0,
     @retry_attempts = 0,
     @retry_interval = 0,
     @os_run_priority = 0,
     @subsystem = N'TSQL',
     @command = @cmd,
     @database_name = @db_name,
     @flags = 0

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

EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId,
     @server_name = N'(local)'

IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
IF (@@TRANCOUNT > 0)
    ROLLBACK TRANSACTION
EndSave: