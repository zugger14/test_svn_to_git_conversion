IF OBJECT_ID('spa_import_data_from_rdb_core') IS NOT NULL
	DROP  PROCEDURE [dbo].[spa_import_data_from_rdb_core]
GO

-- ===================================================================================================
-- Created date: 2008-09-10 05:12PM
-- Description:	Import MTM, Positions, Agreements data from RDB to FasTracker staging table.
-- Params:
-- @batch_id varchar(50)						- unique batch id to process the set of records
-- @source varchar(50)							- source from which record is obtained (eg. ENDUR)
-- @as_of_date varchar(20) 						- as of date to process records
-- @fact_id varchar(50)							- fact_id (MTM, POS or ARG)
-- @db_name varchar(50)							- remote db name
-- @import_status_temp_table_name varchar(50)	- temp table name to store import status
-- ===================================================================================================
CREATE PROCEDURE [dbo].[spa_import_data_from_rdb_core]
(
	@batch_id						varchar(150),
	@source							varchar(150),
	@as_of_date						varchar(20),
	@fact_id						varchar(150),
	@db_name						varchar(50),
	@import_status_temp_table_name	varchar(50)
)
AS
BEGIN
	
	SET NOCOUNT ON;

	DECLARE @insert_sql						varchar(2000)
	DECLARE @openrowset_sql					varchar(2000)
	DECLARE @sql							varchar(4000)
	DECLARE @resolved_source				varchar(50)
	DECLARE @process_id						varchar(50)
	DECLARE @elapsed_time					float
	DECLARE @ssis_import_sp					varchar(50)
	DECLARE @batch_start_ts					datetime
	DECLARE @data_import_start_ts			datetime
	DECLARE @error_message					varchar(4000)
	DECLARE @source_system_id				int
	
	--RDB is used by source system Endur (id: 2) only
	SET @source_system_id = 2

	exec spa_print 'Import ', @fact_id, ' values from RDB for process_id:', @process_id, ' STARTED'

	SET @batch_start_ts = GETDATE()
	SET @process_id = dbo.FNAGetNewID()

	BEGIN TRY
		--truncate @import_status_temp_table_name
		EXEC('DELETE FROM ' + @import_status_temp_table_name)
		
		--log data import status INSERT
		EXEC spa_import_data_files_audit 'i', DEFAULT, DEFAULT, @process_id, @fact_id, @batch_id, @as_of_date, 'p', DEFAULT, DEFAULT, DEFAULT, @source_system_id

		SET @resolved_source = dbo.FNAResolveRDBSource(@source)
		--SELECT @resolved_source = resolved_source FROM vwRDBSources WHERE source = @source
		--SET @resolved_source = ISNULL(@resolved_source, 'Endur') -- this step might be dangerous as it hides error

		exec spa_print 'Copying ', @fact_id, ' values from RDB to first staging table for process_id:', @process_id, ' STARTED'
		IF @fact_id = 'MTM'
		BEGIN
			--clean up table before inserting new records
			DELETE FROM SSIS_MTM_Formate2

			SET @ssis_import_sp = 'sp_ssis_mtm_formate2'

			SET @insert_sql = '
				INSERT INTO SSIS_MTM_Formate2
				(
					deal_num, 
					reference, 
					ins_type, 
					portfolio, 
					internal_desk, 
					counterparty, 
					buy_sell, 
					trader, 
					trade_date,
					deal_side, 
					price_region, 
					unit_of_measure, 
					commodity, 
					settlement_type, 
					product, 
					settlement_currency, 
					mtm_disc_eur, 
					time_bucket, 
					ias39_scope, 
					ias39_book, 
					contract_value, 
					commodity_balance, 
					external_commodity_balance, 
					ins_sub_type, 
					fx_flt,
					legal_entity,
					deal_start_date
				)'

			
			--Oracle version
			SET @openrowset_sql = 
				' SELECT 
					deal_num, 
					reference, 
					ins_type, 
					portfolio, 
					internal_desk, 
					counterparty, 
					buy_sell, 
					nvl(trader, ''''None'''') trader, 
					to_char(nvl(trade_date, nvl(deal_start_date, to_date(''''' + @as_of_date + ''''', ''''YYYY-MM-DD'''')))) trade_date,	
					deal_side, 
					price_region, 
					unit_of_measure, 
					commodity, 
					nvl(settlement_type, ''''Physical Settlement'''') settlement_type, 
					product, 
					settlement_currency, 
					to_char(mtm_disc_eur) mtm_disc_eur,
					time_bucket, 
					ias39_scope, 
					ias39_book, 
					to_char(contract_value) contract_value, 
					(CASE WHEN commodity_balance IS NULL AND unit_of_measure = ''''FX'''' THEN ''''FX'''' ELSE commodity_balance END) commodity_balance, 
					external_commodity_balance, 
					ins_sub_type,  
					nvl(fx_flt, ''''FLOAT'''') fx_flt,
					legal_entity,
					deal_start_date
				FROM ' + @db_name + 'out_ftr_MTMValues
				WHERE control_batch_id = ''''' + @batch_id + '''''			
				AND report_date = to_date(''''' + @as_of_date + ''''', ''''YYYY-MM-DD'''')'
			
			
			--sql version
--			SET @openrowset_sql = 
--				' SELECT 
--					deal_num, 
--					reference, 
--					ins_type, 
--					portfolio, 
--					internal_desk, 
--					counterparty, 
--					buy_sell, 
--					ISNULL(trader, ''''None'''') trader,
--					ISNULL(trade_date, ISNULL(deal_start_date, ''''' + @as_of_date + ''''')) trade_date,
--					deal_side, 
--					price_region, 
--					unit_of_measure, 
--					commodity, 
--					ISNULL(settlement_type, ''''Physical Settlement'''') settlement_type, 
--					product, 
--					settlement_currency, 
--					mtm_disc_eur,
--					time_bucket, 
--					ias39_scope, 
--					ias39_book, 
--					contract_value, 
--					(CASE WHEN commodity_balance IS NULL AND unit_of_measure = ''''FX'''' THEN ''''FX'''' ELSE commodity_balance END) commodity_balance, 
--					external_commodity_balance, 
--					ins_sub_type,  
--					ISNULL(fx_flt, ''''FLOAT'''') fx_flt,
--					legal_entity,
--					deal_start_date
--				FROM ' + @db_name + 'out_ftr_MTMValues
--				WHERE control_batch_id = ''''' + @batch_id + '''''			
--				AND report_date = ''''' + @as_of_date + ''''''
			

			SET @sql = @insert_sql + ' SELECT * FROM ' + dbo.FNARowSet(@openrowset_sql)
			--copy data to SSIS_MTM_Format2 table (1st staging table)
			exec spa_print @sql
			
			BEGIN TRY
				EXEC(@sql)	
			END TRY
			BEGIN CATCH
				SELECT @error_message = ERROR_MESSAGE()
				SET @elapsed_time = DATEDIFF(second, @batch_start_ts, GETDATE())
				EXEC spa_rdb_openrowset_error_handler @as_of_date, @error_message, 'Verify that the query string is free of syntax errors'
					, @process_id, @elapsed_time, @fact_id, @batch_id
				RETURN
			END CATCH;

			exec spa_print 'Copying ', @fact_id, ' values from RDB to first staging table for process_id:', @process_id, ' FINISHED. Process took ' --+ dbo.FNACalculateTimestamp(@batch_start_ts)
			
			exec spa_print 'Importing ', @fact_id, ' values from first staging table to main FasTracker tables for process_id:', @process_id, ' STARTED'
			SET @data_import_start_ts = GETDATE()
			--copy data to 2nd staging table
			EXEC sp_ssis_mtm_formate2 @process_id, @resolved_source, @as_of_date, NULL, @import_status_temp_table_name
			exec spa_print 'Importing ', @fact_id, ' values from first staging table to main FasTracker tables for process_id:', @process_id, ' FINISHED. Process took ' --+ dbo.FNACalculateTimestamp(@data_import_start_ts)
			
		END
		ELSE IF @fact_id = 'POS'
		BEGIN
			--clean up table before inserting new records
			DELETE FROM SSIS_Position_Formate2

			SET @ssis_import_sp = 'spa_position_load'

			SET @insert_sql = '
				INSERT INTO SSIS_Position_Formate2
				(
					deal_num, 
					deal_side, 
					settlement_type, 
					settlement_currency, 
					position, 
					time_bucket, 
					unit_of_measure, 
					fx_flt, 
					delivery_accounting
				)'

			
			--Oracle version
			SET @openrowset_sql = 
				'SELECT 
					deal_num, 
					deal_side, 
					settlement_type, 
					settlement_currency, 
					to_char(position) position,
					time_bucket, 
					unit_of_measure, 
					nvl(fx_flt, ''''FLOAT'''') fx_flt, 
					delivery_accounting		
				FROM ' + @db_name + 'out_ftr_positions
				WHERE control_batch_id = ''''' + @batch_id + '''''			
				AND report_date = to_date(''''' + @as_of_date + ''''', ''''YYYY-MM-DD'''')'
		
			
			--sql version
--			SET @openrowset_sql = 
--				'SELECT 
--					deal_num, 
--					deal_side, 
--					settlement_type, 
--					settlement_currency, 
--					position,
--					time_bucket, 
--					unit_of_measure, 
--					ISNULL(fx_flt, ''''FLOAT'''') fx_flt,
--					delivery_accounting		
--				FROM ' + @db_name + 'out_ftr_positions
--				WHERE control_batch_id = ''''' + @batch_id + '''''			
--				AND report_date = ''''' + @as_of_date + ''''''	
	

			SET @sql = @insert_sql + ' SELECT * FROM ' + dbo.FNARowSet(@openrowset_sql)
			--copy data to SSIS_MTM_Format2 table (1st staging table)
			exec spa_print @sql
			BEGIN TRY
				EXEC(@sql)	
			END TRY
			BEGIN CATCH
				SELECT @error_message = ERROR_MESSAGE()
				SET @elapsed_time = DATEDIFF(second, @batch_start_ts, GETDATE())
				EXEC spa_rdb_openrowset_error_handler @as_of_date, @error_message, 'Verify that the query string is free of syntax errors'
						, @process_id, @elapsed_time, @fact_id, @batch_id
				RETURN
			END CATCH;

			exec spa_print 'Copying ', @fact_id, ' values from RDB to first staging table for process_id:', @process_id, ' FINISHED. Process took ' --+ dbo.FNACalculateTimestamp(@batch_start_ts)

			exec spa_print 'Importing ', @fact_id, ' values from first staging table to main FasTracker tables for process_id:', @process_id, ' STARTED'
			SET @data_import_start_ts = GETDATE()
			--copy data to 2nd staging TABLE
			EXEC spa_position_load @process_id, @resolved_source, @as_of_date, NULL, @import_status_temp_table_name
			exec spa_print 'Importing ', @fact_id, ' values from first staging table to main FasTracker tables for process_id:', @process_id, ' FINISHED. Process took ' --+ dbo.FNACalculateTimestamp(@data_import_start_ts)
			
		END
		ELSE IF @fact_id = 'AGR'
		BEGIN
			--clean up table before inserting new records
			DELETE FROM SSIS_Agreement

			SET @ssis_import_sp = 'sp_ssis_agreement'

			SET @insert_sql = '
				INSERT INTO SSIS_Agreement
				(
					deal_tracking_num, 
					legal_agreement
				)'

			
			--Oracle version
			SET @openrowset_sql = 
				'SELECT 
					deal_num, 
					legal_agreement	
				FROM ' + @db_name + 'out_ftr_agreements
				WHERE control_batch_id = ''''' + @batch_id + '''''
				AND report_date = to_date(''''' + @as_of_date + ''''', ''''YYYY-MM-DD'''')'
			

			--sql version
--			SET @openrowset_sql = 
--				'SELECT 5
--					deal_num, 
--					legal_agreement	
--				FROM ' + @db_name + 'out_ftr_agreements
--				WHERE control_batch_id = ''''' + @batch_id + '''''
--				AND report_date = ''''' + @as_of_date + ''''''			

			SET @sql = @insert_sql + ' SELECT * FROM ' + dbo.FNARowSet(@openrowset_sql)
			--copy data to SSIS_MTM_Format2 table (1st staging table)
			exec spa_print @sql
			BEGIN TRY
				EXEC(@sql)	
			END TRY
			BEGIN CATCH
				SELECT @error_message = ERROR_MESSAGE()
				SET @elapsed_time = DATEDIFF(second, @batch_start_ts, GETDATE())
				EXEC spa_rdb_openrowset_error_handler @as_of_date, @error_message, 'Verify that the query string is free of syntax errors'
					, @process_id, @elapsed_time, @fact_id, @batch_id
				RETURN
			END CATCH;

			exec spa_print 'Copying ', @fact_id, ' values from RDB to first staging table for process_id:', @process_id, ' FINISHED. Process took ' --+ dbo.FNACalculateTimestamp(@batch_start_ts)

			exec spa_print 'Importing ', @fact_id, ' values from first staging table to main FasTracker tables for process_id:', @process_id, ' STARTED'
			SET @data_import_start_ts = GETDATE()
			--copy data to 2nd staging TABLE
			EXEC sp_ssis_agreement @process_id, @resolved_source, @as_of_date, @import_status_temp_table_name
			exec spa_print 'Importing ', @fact_id, ' values from first staging table to main FasTracker tables for process_id:', @process_id, ' FINISHED. Process took ' --+ dbo.FNACalculateTimestamp(@data_import_start_ts)
		END
		
		SET @elapsed_time = DATEDIFF(second, @batch_start_ts, GETDATE())
		--log data import status UPDATE
		SET @sql = 'DECLARE @status varchar(50)
					SELECT @status = dbo.FNAResolveRDBImportStatus(error_code) FROM ' + @import_status_temp_table_name + '
					SELECT * FROM ' + @import_status_temp_table_name + '
					EXEC spa_import_data_files_audit ''u'', DEFAULT, DEFAULT, ''' + @process_id + ''', DEFAULT, DEFAULT, DEFAULT, @status, ''' + CAST(@elapsed_time AS varchar) + ''''
		
		EXEC(@sql)

		SET @openrowset_sql = 'SELECT status FROM ' +  @db_name + 'out_ftr_status WHERE batch_id = ''''' + @batch_id + ''''''
		SET @sql = 'UPDATE ' + dbo.FNARowSet(@openrowset_sql) + ' SET status = ''P'''

		exec spa_print @sql
		BEGIN TRY
			EXEC(@sql)	
		END TRY
		BEGIN CATCH
			SELECT @error_message = ERROR_MESSAGE()
			SET @elapsed_time = DATEDIFF(second, @batch_start_ts, GETDATE())
			EXEC spa_rdb_openrowset_error_handler @as_of_date, @error_message, 'Verify that the query string is free of syntax errors'
				, @process_id, @elapsed_time, @elapsed_time, @fact_id, @batch_id
		END CATCH;

		exec spa_print 'Import ', @fact_id, ' values from RDB for process_id:', @process_id, ' FINISHED. Process took ' --+ dbo.FNACalculateTimestamp(@batch_start_ts)
	
	END TRY
	BEGIN CATCH	
		DECLARE @desc	varchar(5000)

		SET @desc = 'SQL Error found:  (' + ERROR_MESSAGE() + ')'
		SET @elapsed_time = DATEDIFF(second, @batch_start_ts, GETDATE())
		EXEC spa_rdb_error_handler @as_of_date, @desc, 'Please check your data', @process_id, @elapsed_time, @fact_id
	END CATCH
	  
END

GO
