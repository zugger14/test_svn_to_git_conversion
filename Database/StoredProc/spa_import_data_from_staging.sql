IF OBJECT_ID (N'spa_import_data_from_staging', N'P') IS NOT NULL
	DROP PROC [dbo].[spa_import_data_from_staging]
GO

-- =============================================
-- Create date: 2008-09-09 04:47PM
-- Description:	Import data from staging table
-- Params:
--@process_id varchar(50) -  Process ID
--@source_name varchar(100) - Source Name
-- =============================================
CREATE PROCEDURE [dbo].[spa_import_data_from_staging]
	@process_id VARCHAR(50),
	@source_name VARCHAR(100)
AS
BEGIN
	
	SET NOCOUNT ON;

	DECLARE @proceed_staging int
	DECLARE @max_dt datetime
	SET @proceed_staging = 0
	IF (SELECT COUNT(*) FROM ssis_mtm_formate2_error_log) > 0
	BEGIN
		exec spa_print 'Loading data from ssis_mtm_formate2_error_log'
		SELECT @max_dt = MAX(CONVERT(datetime, as_of_date, 120)) FROM ssis_mtm_formate2_error_log
		DELETE ssis_mtm_formate2_error_log WHERE CONVERT(datetime, as_of_date, 120) < @max_dt
		SET @proceed_staging = 1
		EXEC sp_ssis_MTM_formate2 @process_id, @source_name, NULL, 'y'	
	END
	IF (SELECT COUNT(*) FROM ssis_mtm_formate1_error_log) > 0
	BEGIN
		SELECT @max_dt = MAX(CONVERT(datetime, as_of_date, 120)) FROM ssis_mtm_formate1_error_log
		DELETE ssis_mtm_formate1_error_log WHERE CONVERT(datetime, as_of_date, 120) < @max_dt
		SET @proceed_staging = 1
		--EXEC sp_ssis_MTM_formate1 @process_id,@source_name,NULL,'y'		
	END
	IF (SELECT COUNT(*) FROM ssis_position_formate2_error_log) > 0
	BEGIN
		exec spa_print 'Loading data from ssis_position_formate2_error_log'
		SET @proceed_staging = 1
		DELETE ssis_position_formate2
		DECLARE @as_of_date varchar(20)
		SELECT @as_of_date = MAX(pnl_as_of_date) FROM ssis_position_formate2_error_log

		DELETE ssis_position_formate2_error_log WHERE CONVERT(datetime, pnl_as_of_date, 120) < @as_of_date

		EXEC spa_position_load @process_id, @source_name, @as_of_date, 'y'		
	END
	IF @proceed_staging = 0
	BEGIN
		UPDATE import_data_files_audit
		SET imp_file_name = 'Staging table is empty',
		status = 'c'
		WHERE process_id = @process_id
	END

END
GO
