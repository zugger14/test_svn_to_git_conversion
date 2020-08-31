
IF OBJECT_ID('spa_import_data_from_rdb') IS NOT NULL
	DROP  PROCEDURE [dbo].[spa_import_data_from_rdb]
GO

-- =============================================
-- Create date: 2008-09-09 04:47PM
-- Description:	Import position, MTM and aggrement data from RDB to FasTracker db. It is
--				assumed that source will be same for every batch
-- Params:
-- @as_of_date varchar(20) - Datetime the entry or a adjustment made into
-- @is_incremental bit - Is the data import job incremental or the full one? (i.e. full refresh)
-- @control_batch_id varchar(100) - Batch Id if provided to import data from RDB

-- =============================================
CREATE PROCEDURE [dbo].[spa_import_data_from_rdb]
	@as_of_date			VARCHAR(20),
	@is_incremental		BIT,
	@control_batch_id	VARCHAR(100) = NULL
AS
BEGIN
	
	SET NOCOUNT ON;

	DECLARE @sql					varchar(1500)
	DECLARE @select_sql				varchar(1000)
	DECLARE @insert_sql				varchar(500)
	DECLARE @db_name				varchar(50)
	DECLARE @dest_as_of_date		varchar(20)
	DECLARE @start_ts				datetime
	DECLARE @master_process_id		varchar(50)
	DECLARE @elapsed_time			float

	exec spa_print 'Import data from RDB STARTED.'
	SET @start_ts = GETDATE()
	SET @master_process_id = dbo.FNAGetNewID()

	BEGIN TRY	
	
		SELECT @db_name = database_name FROM rdb_config
		IF @db_name IS NULL
		BEGIN
			SET @elapsed_time = DATEDIFF(second, @start_ts, GETDATE())
			EXEC spa_rdb_error_handler @as_of_date, 'RDB Server db name is missing in table rdb_config.'
					, 'Verify db name in rdb_config table.', @master_process_id, @elapsed_time
			RETURN
		END

		CREATE TABLE #status
		(
			batch_id			varchar(50) COLLATE DATABASE_DEFAULT NOT NULL,
			fact_id				varchar(10) COLLATE DATABASE_DEFAULT NOT NULL,
			source				varchar(255) COLLATE DATABASE_DEFAULT,
			report_date			datetime NOT NULL,
			control_timestamp	datetime,
		)
		
		SET @insert_sql = 'INSERT INTO #status (batch_id, fact_id, source, report_date, control_timestamp) '

		--SQL server version, to be used in local testing
		/* There may be multiple rows with same value pair (batch_id, fact_id), but since we need to process a batch_id for only once,
		   we need to group the result by the pair. Aggregate function max is only used to get one of the value in the group. Otherwise, 
		   it doesn't hold any special meaning.
		*/
		
		
--		SET @select_sql = 
--			'SELECT batch_id, fact_id, max(source), max(report_date), max(control_timestamp) cts
--			FROM ' + @db_name + 'out_ftr_status st
--			WHERE report_date >= DATEADD(dd, DATEDIFF(dd, 0, ''''' + @as_of_date + '''''), 0) --gives date part only
--			AND report_date < DATEADD(dd, DATEDIFF(dd, 0, ''''' + @as_of_date + '''''), 1) --adds 1 day for comparision
--			AND source IN (''''ENDUR_POS'''', ''''ENDUR_MTM'''', ''''ENDUR_FX_MTM'''', ''''ENDUR_AGR''''
--							, ''''VESSELOPS_MTM'''', ''''CDO_MTM'''', ''''CORRECTION_MTM'''', ''''CORRECTION_POS'''', ''''FTR_CORRECTION_MTM'''')
--			'
		

		--Oracle version, to be used in RDB server
		SET @select_sql = 
			'SELECT batch_id, fact_id, max(source), max(report_date), max(control_timestamp) cts 
			FROM ' + @db_name + 'out_ftr_status 
			WHERE report_date >= trunc(to_date(''''' + @as_of_date + ''''', ''''YYYY-MM-DD''''))
			AND report_date < trunc(to_date(''''' + @as_of_date + ''''', ''''YYYY-MM-DD'''') + 1)
			AND source IN (''''ENDUR_POS'''', ''''ENDUR_MTM'''', ''''ENDUR_FX_MTM'''', ''''ENDUR_AGR''''
							, ''''VESSELOPS_MTM'''', ''''CDO_MTM'''', ''''CORRECTION_MTM'''', ''''CORRECTION_POS'''', ''''FTR_CORRECTION_MTM'''')
		    '

		IF ISNULL(@control_batch_id, '') <> ''
			SET @select_sql = @select_sql + ' AND batch_id = ''''' + @control_batch_id + ''''''
		--in case of full refresh, don't filter by status
		ELSE IF @is_incremental = 1
			SET @select_sql = @select_sql + ' AND status = ''''U'''''
			
		SET @select_sql = @select_sql + ' GROUP BY batch_id, fact_id ORDER BY cts'

		SET @sql = ' SELECT * FROM ' + dbo.FNARowSet(@select_sql)
		
		exec spa_print 'Fetching batch_id for importing RDB data STARTED'

		exec spa_print @insert_sql, @sql

		BEGIN TRY
			EXEC(@insert_sql + @sql)
		END TRY
		BEGIN CATCH
			DECLARE @error_message varchar(4000)
			SELECT @error_message = ERROR_MESSAGE()
			SET @elapsed_time = DATEDIFF(second, @start_ts, GETDATE())
			EXEC spa_rdb_openrowset_error_handler @as_of_date, @error_message, 'Verify that the query string is free of syntax errors', @master_process_id, @elapsed_time
			RETURN
		END CATCH;

		SELECT * FROM #status
		
		exec spa_print 'Fetching batch_id for importing RDB data FINISHED. Process took ' --+ dbo.FNACalculateTimestamp(@start_ts)
		
		SELECT * FROM #status

		DECLARE @batch_id						varchar(50)
		DECLARE @source							varchar(50)
		DECLARE @import_status_temp_table_name	varchar(50)
		DECLARE @fact_id						varchar(50)
		DECLARE @sort_order						tinyint
		DECLARE @control_timestamp				datetime
		
		CREATE TABLE #tmp_import_status
		(
			error_code		varchar(50) COLLATE DATABASE_DEFAULT,
			module			varchar(50) COLLATE DATABASE_DEFAULT,
			area			varchar(50) COLLATE DATABASE_DEFAULT,
			status			varchar(50) COLLATE DATABASE_DEFAULT,
			[message]		varchar(500) COLLATE DATABASE_DEFAULT,
			recommendation	varchar(500) COLLATE DATABASE_DEFAULT		
		)
		SET @import_status_temp_table_name = '#tmp_import_status'

		DECLARE cur_status CURSOR LOCAL FOR
		SELECT batch_id, source, fact_id, 1 sort_order, control_timestamp
		FROM #status
		WHERE fact_id = 'MTM'
		UNION 
		SELECT batch_id, source, fact_id, 2 sort_order, control_timestamp
		FROM #status
		WHERE fact_id = 'POS'
		UNION
		SELECT batch_id, source, fact_id, 3 sort_order, control_timestamp
		FROM #status
		WHERE fact_id = 'AGR'
		ORDER BY sort_order, control_timestamp

		OPEN cur_status;

		FETCH NEXT FROM cur_status INTO @batch_id, @source, @fact_id, @sort_order, @control_timestamp
		WHILE @@FETCH_STATUS = 0
		BEGIN
			exec spa_print 'Now processing fact_ID: ', @fact_id
			EXEC spa_import_data_from_rdb_core @batch_id, @source, @as_of_date, @fact_id, @db_name, @import_status_temp_table_name
		
			FETCH NEXT FROM cur_status INTO @batch_id, @source, @fact_id, @sort_order, @control_timestamp
		END;

		CLOSE cur_status;
		DEALLOCATE cur_status;
		
		exec spa_print 'Import data from RDB FINISHED. Process took ' --+ dbo.FNACalculateTimestamp(@start_ts)
	
	END TRY
	BEGIN CATCH	
		
		IF CURSOR_STATUS('local', 'cur_status') >= 0 
		BEGIN
			CLOSE cur_status
			DEALLOCATE cur_status;
		END

		DECLARE @desc	varchar(5000)

		SET @desc = 'SQL Error found:  (' + ERROR_MESSAGE() + ')'
		SET @elapsed_time = DATEDIFF(second, @start_ts, GETDATE())
		EXEC spa_rdb_error_handler @as_of_date, @desc, 'Please check your data', @master_process_id, @elapsed_time
	END CATCH

END



GO
