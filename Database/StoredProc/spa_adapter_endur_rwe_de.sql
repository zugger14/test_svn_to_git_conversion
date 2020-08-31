
IF OBJECT_ID(N'dbo.spa_adapter_endur_rwe_de', N'P') IS NOT NULL
	DROP PROCEDURE dbo.spa_adapter_endur_rwe_de
GO

-- ===============================================================================================================
-- Create date: 2011-08-29
-- Description:	Import price, deal, MTM and aggrement data from Endur data files (loaded already in staging table)
--				to main table.				
-- Params:
--	@data_type		VARCHAR(20) - 'Data' for data import, 'Error' for error handling
--	@parse_type		VARCHAR(100) - parse type in CSV. 4 - price, 5 - deal, 6 - MTM
--	@process_id		VARCHAR(100) - process id
--	@job_name		VARCHAR(100) - Name of the job
--	@send_email		VARCHAR(1) - Whether to send email to users after job completes.
--	@err_msg		VARCHAR(5000) - Error message
-- ===============================================================================================================
CREATE PROCEDURE dbo.spa_adapter_endur_rwe_de
	@data_type			VARCHAR(10)
	, @parse_type		VARCHAR(100) = NULL
	, @process_id		VARCHAR(100) = NULL
	, @job_name			VARCHAR(100) = NULL
	, @send_email		VARCHAR(1) = 'y'
	, @err_msg			VARCHAR(5000) = NULL
	, @user				VARCHAR(100) = NULL
AS


DECLARE @error_code				VARCHAR(200)	
DECLARE @url					VARCHAR(500)	
DECLARE @desc					VARCHAR(500)	
--DECLARE @user					VARCHAR(100)		  	
DECLARE @table					VARCHAR(1000)	
DECLARE @sql					VARCHAR(8000)	  
DECLARE @desc_detail			VARCHAR(8000)	
DECLARE @error					INT				
DECLARE @id						INT				
DECLARE @count					INT				
DECLARE @totalcount				INT				
DECLARE @run_start_time			DATETIME		

DECLARE @tablename				TABLE (tname VARCHAR(1000))
DECLARE @e_time					INT
DECLARE @e_time_text			VARCHAR(100)

DECLARE @file_name				VARCHAR(200)
DECLARE @endur_run_date			VARCHAR(10)

DECLARE @as_of_date				VARCHAR(10)
DECLARE @import_process_table	VARCHAR(MAX)
DECLARE @msg_board_err			BIT 
DECLARE @main_process_id		VARCHAR(50)
DECLARE @process_id1 			VARCHAR(50)
DECLARE @process_id2 			VARCHAR(50)
DECLARE @process_id3 			VARCHAR(50)
DECLARE @start_ts				DATETIME

IF @process_id IS NULL
BEGIN
	SET @process_id = dbo.FNAGetNewID()
	SET @start_ts = GETDATE()
END
ELSE
BEGIN
	IF LEN(@process_id) = 15
		SET @start_ts = CONVERT(DATETIME, LEFT(@process_id, 8) + ' ' + LEFT(RIGHT(@process_id,6), 2) + ':' + LEFT(RIGHT(@process_id,4), 2) + ':' + RIGHT(@process_id, 2), 120)
	ELSE
		SET @start_ts = GETDATE()
END
EXEC spa_print 'SSIS Run Time:', @start_ts
DELETE @tablename

DECLARE @table_no				VARCHAR(10)
DECLARE @folder_endur_or_user	VARCHAR(1)
DECLARE @url_email				VARCHAR(2000)
DECLARE @no_rec					INT
DECLARE @out_of_rec				INT 
DECLARE @max_date				VARCHAR(20)
DECLARE @create_time			VARCHAR(20)
DECLARE @file_type				VARCHAR(20)
DECLARE @file_name_status		VARCHAR(1000)
DECLARE @i						TINYINT
DECLARE @next_step VARCHAR(50), @is_empty BIT 

SET @next_step = 'Please verify data.'
SET @is_empty = 0


SELECT @user = ISNULL(NULLIF(@user,''), dbo.FNADBuser())	
DECLARE @as_of_date_import DATETIME, @source_system_id INT
SET @source_system_id = 2

-- Creation Of Temp Tables
CREATE TABLE #ErrorHandler
(
	err_code			VARCHAR(50) COLLATE DATABASE_DEFAULT
	, [module]			VARCHAR(50) COLLATE DATABASE_DEFAULT
	, area				VARCHAR(50) COLLATE DATABASE_DEFAULT
	, [status]			VARCHAR(50) COLLATE DATABASE_DEFAULT
	, msg				VARCHAR(500) COLLATE DATABASE_DEFAULT
	, recommendation	VARCHAR(1000) COLLATE DATABASE_DEFAULT
)

CREATE TABLE #tmp_status (
	process_id			VARCHAR(50) COLLATE DATABASE_DEFAULT
	, [source]			VARCHAR(500) COLLATE DATABASE_DEFAULT
	, [type]			VARCHAR(500) COLLATE DATABASE_DEFAULT
	, [description]		VARCHAR(5000) COLLATE DATABASE_DEFAULT
)

SET @main_process_id = @process_id
SET @send_email = 'n'

IF @parse_type IS NULL OR @parse_type = 'NULL' OR @parse_type = '' OR @parse_type = '0' --to handle SSIS Error exception 
BEGIN
	IF @parse_type = '0' 
	BEGIN
		SET @is_empty = 1
		SET	@err_msg = 'Data not found'
		SET @next_step = 'Add Files to working folder'
	END
		
	SET @max_date = CONVERT(VARCHAR(10),GETDATE(),103)
	SET @msg_board_err = 1
	GOTO messageboard
END
	
IF @data_type = 'Data'
BEGIN
	IF EXISTS(SELECT 1 FROM dbo.SplitCommaSeperatedValues(@parse_type) WHERE item = 5)	-- RWE Deal
	BEGIN
		
		IF OBJECT_ID('tempdb..#temp_process_table_name') IS NULL
		BEGIN
			CREATE TABLE #temp_process_table_name([name] VARCHAR(MAX) COLLATE DATABASE_DEFAULT)
		END
		
		IF OBJECT_ID('tempdb..#temp_process_table_name_UK') IS NULL
		BEGIN
			CREATE TABLE #temp_process_table_name_UK([name] VARCHAR(MAX) COLLATE DATABASE_DEFAULT)
		END
		
		-- #proj_index_mapping temp tbl for valid uom conversion inserted in proc, spa_deal_interface_adapter_endur_rwe_de
		CREATE TABLE #proj_index_mapping(source_book_id INT, source_book_name VARCHAR(50) COLLATE DATABASE_DEFAULT , vol_uom INT, price_uom INT, to_uom INT)

		--SET @process_id = dbo.FNAGetNewID()
		SET @i = 1
		EXEC dbo.spa_deal_interface_adapter_endur_rwe_de @process_id;

		SET @table_no = 4005

		CREATE TABLE #void_deal(
			source_deal_header_id	INT 
			, deal_id				VARCHAR(150) COLLATE DATABASE_DEFAULT 
			, voided_date			DATETIME
			, create_ts				DATETIME
			, tran_status			VARCHAR(10) COLLATE DATABASE_DEFAULT
		)
		
		
		DELETE @tablename
		INSERT INTO @tablename EXEC dbo.spa_import_temp_table 4072 -- custom table schema of source deal detail for RWE DE
		SELECT @table = tname FROM @tablename
		
		DECLARE cur_files CURSOR LOCAL FOR 
		SELECT [file_name], MAX(file_as_of_date) file_as_of_date, folder_endur_or_user, MAX(file_type) file_type, MAX(file_timestamp) file_timestamp
		FROM adiha_process.dbo.stage_deals_rwe_de 
		GROUP BY folder_endur_or_user, [file_name]
		ORDER BY folder_endur_or_user, file_type, file_as_of_date, file_timestamp 
		OPEN cur_files
		FETCH NEXT FROM cur_files INTO @file_name, @as_of_date, @folder_endur_or_user, @file_type, @create_time
		WHILE @@FETCH_STATUS = 0
		BEGIN
			BEGIN TRY
				SELECT @as_of_date = dbo.FNAGetSplitPart(@file_name,'_',4)

				EXEC spa_print '########################################################Start: ', @import_process_table
				IF ISNULL(@max_date, '19000101') < @as_of_date
					SET @max_date = @as_of_date
				SET @run_start_time = GETDATE()

				--SET @import_process_table = dbo.FNAProcessTableName(@folder_endur_or_user+replace(@file_name,'.txt',''), @user, @process_id)

				SET @import_process_table = dbo.FNAProcessTableName('deal' + CAST(@i AS VARCHAR), @user, @process_id)
				SET @i = @i + 1

				--select @import_process_table
				SET @file_name_status = CASE WHEN @folder_endur_or_user = 'e' THEN 'Endur/' ELSE 'User/' END + @file_name
				EXEC('SELECT * INTO ' + @import_process_table + ' from ' + @table)
				TRUNCATE TABLE #ErrorHandler

				SET @sql = 
				'INSERT INTO '+ @import_process_table + '
				   ([deal_id]
				   , [source_system_id]
				   , [term_start]
				   , [term_end]
				   , [leg]
				   , [contract_expiration_date]
				   , [fixed_float_leg]
				   , [buy_sell_flag]
				   , [curve_id]
				   , [fixed_price]
				   , [fixed_price_currency_id]
				   , [option_strike_price]
				   , [deal_volume]
				   , [deal_volume_frequency]
				   , [deal_volume_uom_id]
				   , [block_description]
				   , [deal_detail_description]
				   , [formula_id]
				   , [deal_date]
				   , [ext_deal_id]
				   , [physical_financial_flag]
				   , [structured_deal_id]
				   , [counterparty_id]
				   , [source_deal_type_id]
				   , [source_deal_sub_type_id]
				   , [option_flag]
				   , [option_type]
				   , [option_excercise_type]
				   , [source_system_book_id1]
				   , [source_system_book_id2]
				   , [source_system_book_id3]
				   , [source_system_book_id4]
				   , [description1]
				   , [description2]
				   , [description3]
				   , [description4]
				   , [deal_category_value_id]
				   , [trader_id]
				   , [header_buy_sell_flag]
				   , [broker_id]
				   , [contract_id]
				   , [legal_entity]
				   , [table_code]
				   , [reference]
				   , [internal_portfolio_id]
				   , [internal_desk_id]
				   , [product_id]
				   , [settlement_date]
				   , [option_settlement_date]
				   , [trade_status]
				   )
					SELECT 
					   sdd.[deal_id]
					   , sdd.[source_system_id]
					   , convert(VARCHAR(10),CONVERT(datetime,sdd.[term_start],103),120) [term_start]
					   , dateadd(month,1,CONVERT(datetime,sdd.[term_start],103))-1 [term_end]
					   ,[leg]
					   ,convert(VARCHAR(10),CONVERT(datetime,sdd.[contract_expiration_date],103),120) [contract_expiration_date]
					   ,sdd.[fixed_float_leg]
					   ,[buy_sell_flag]
					   ,sdd.[curve_id]
					   ,[fixed_price]
					   ,[fixed_price_currency_id]
					   ,[option_strike_price]
					   ,[deal_volume]
					   ,''m'' [deal_volume_frequency]
					   ,[deal_volume_uom_id]
					   ,[block_description]
					   ,[deal_detail_description]
					   ,sdd.[formula_id]
					   ,CONVERT(datetime,sdd.[deal_date],103) [deal_date]
					   ,[ext_deal_id]
					   ,[physical_financial_flag]
					   ,[structured_deal_id]
					   ,[counterparty_id]
					   ,[source_deal_type_id]
					   ,[source_deal_sub_type_id]
					   ,[option_flag]
					   ,[option_type]
					   ,[option_excercise_type]
					   ,[source_system_book_id1]
					   ,[source_system_book_id2]
					   ,[source_system_book_id3]
					   ,[source_system_book_id4]
					   ,[description1]
					   ,[description2]
					   ,[description3]
					   ,[description4]
					   ,475
					   ,[trader_id]
					   ,[header_buy_sell_flag]
					   ,[broker_id]
					   ,[contract_id]
					   ,[legal_entity]
					   ,4005 [table_code]
					   ,[reference]
					   ,[internal_portfolio_id]
					   ,[internal_desk_id]
					   ,[product_id]
					   ,[settlement_date]	
					   ,[option_settlement_date]
					   ,[trade_status]
					FROM stage_sdd_rwe_de sdd 
					WHERE 
						--CONVERT(datetime, sdd.[term_start], 103) > CONVERT(DATETIME, '''+@as_of_date  +''', 103) AND 
						sdd.file_name='''+ @file_name + ''' AND folder_endur_or_user='''+ @folder_endur_or_user+'''
					'
				exec spa_print @sql
				EXEC(@sql)
				
				INSERT INTO #ErrorHandler EXEC spa_import_data_job @import_process_table, @table_no, @job_name, @process_id, @user, 'n', 6, NULL, NULL, @file_name_status
				IF EXISTS(SELECT 1 FROM #ErrorHandler WHERE err_code = 'Error') 
					SET @error_code = 'e'
				ELSE
					SET @error_code = 's'


				-- UOM Conversion Exception handling
				
				INSERT INTO source_system_data_import_status_detail(process_id, [source], [type], [description]) 
				SELECT @process_id, 'uom_conversion', @file_name_status, p.source_book_name + ': Volume UOM conversion missing: ' +
				ISNULL(su.uom_id, 'undefined') + ' to ' + ISNULL(su2.uom_id, 'undefined')
				FROM #proj_index_mapping p
				LEFT JOIN source_uom su ON su.source_uom_id = p.vol_uom
				LEFT JOIN source_uom su2 ON su2.source_uom_id = p.to_uom
				LEFT JOIN rec_volume_unit_conversion rvuc ON  rvuc.from_source_uom_id = p.vol_uom AND rvuc.to_source_uom_id = p.to_uom
				WHERE rvuc.rec_volume_unit_conversion_id IS NULL AND ISNULL(su.source_uom_id, -1) <> ISNULL(su2.source_uom_id, -1)

				INSERT INTO source_system_data_import_status_detail(process_id, [source], [type], [description]) 
				SELECT @process_id, 'uom_conversion', @file_name_status, p.source_book_name + ': Price UOM conversion missing: ' +
				ISNULL(su.uom_id, 'undefined') + ' to ' + ISNULL(su2.uom_id, 'undefined')
				FROM #proj_index_mapping p
				LEFT JOIN source_uom su ON su.source_uom_id = p.price_uom
				LEFT JOIN source_uom su2 ON su2.source_uom_id = p.to_uom
				LEFT JOIN rec_volume_unit_conversion rvuc ON  rvuc.from_source_uom_id = p.price_uom AND rvuc.to_source_uom_id = p.to_uom
				WHERE rvuc.rec_volume_unit_conversion_id IS NULL AND ISNULL(su.source_uom_id, -1) <> ISNULL(su2.source_uom_id, -1)


				INSERT INTO source_system_data_import_status(process_id, code, [module], [source], [type], [description], recommendation) 
				SELECT @process_id, 'Warning', @file_name_status, 'uom_conversion', 'Data Warning', 'UOM conversion missing.',
				 'Please verify UOM mapping setup'
				FROM source_system_data_import_status_detail ssdisd
				WHERE ssdisd.process_id = @process_id AND ssdisd.source = 'uom_conversion'
				GROUP BY ssdisd.process_id, ssdisd.[source]
				
				--------------------------------Hadling Voided Deal Start----------------------------------------
				
				EXEC spa_print 'Insert into deal_voided_in_external'
				INSERT INTO deal_voided_in_external(source_deal_header_id, deal_id,voided_date, create_ts, tran_status)
				OUTPUT inserted.source_deal_header_id, inserted.deal_id, inserted.voided_date, inserted.create_ts, inserted.tran_status INTO #void_deal
				SELECT sdh.source_deal_header_id,s.deal_id, CONVERT(DATETIME, @as_of_date, 103) voided_date, GETDATE() create_ts, 'v' tran_status
				FROM stage_sdd_rwe_de s 
				INNER JOIN source_deal_header sdh ON s.deal_id = sdh.deal_id 
					AND sdh.source_system_id = @source_system_id 
					AND trade_status = 'V' 
					AND s.[file_name] = @file_name 
					AND folder_endur_or_user = @folder_endur_or_user
					AND CONVERT(DATETIME, s.[term_start], 103) > CONVERT(DATETIME, @as_of_date, 103)
				LEFT JOIN deal_voided_in_external v ON sdh.source_deal_header_id = v.source_deal_header_id
				WHERE v.source_deal_header_id IS NULL
				GROUP BY s.deal_id ,sdh.source_deal_header_id
			
				IF EXISTS(SELECT 1 FROM #void_deal)
				BEGIN
					INSERT INTO source_system_data_import_status(process_id, code, [module], [source], [type], [description], recommendation) 
					SELECT @process_id, 'Warning', @file_name_status, 'voided_deal', 'Data Warning', CAST(COUNT(*) AS VARCHAR) + ' Voided deals found in RWE Endur(at:' + CAST(GETDATE() AS VARCHAR) + ')', 'Please verify and correct the voided deal in FasTracker.'
					FROM #void_deal
					
					INSERT INTO source_system_data_import_status_detail(process_id, [source], [type], [description]) 
					SELECT @process_id, 'voided_deal', @file_name_status, 'Voided Deal Found in RWE Endur(Deal_ID:' + deal_id + ' Voided_Date:' + dbo.FNADateFormat(voided_date)+ ')' FROM #void_deal
				END

				TRUNCATE TABLE #void_deal
				
				--------------------------------Hadling Voided Deal End----------------------------------------
				
				INSERT import_data_files_audit(
					dir_path
					, imp_file_name
					, as_of_date
					, [status]
					, elapsed_time
					, process_id
					, create_user
					, source_system_id
				)
				VALUES(
					'Endur'
					, @file_name_status
					, CONVERT(VARCHAR(10)
					, CONVERT(DATETIME, @as_of_date, 103), 120)
					, @error_code
					, DATEDIFF(ss, @run_start_time, GETDATE())
					, @process_id
					, @user
					, @source_system_id)
					
				SET	@as_of_date_import = CONVERT(DATETIME, @as_of_date, 103)
				
			END TRY 
			BEGIN CATCH	
				INSERT INTO source_system_data_import_status(process_id, code, [module], [source], [type], [description], recommendation) 
				SELECT @process_id, 'Error', 'Import Data', @file_name_status, 'Data Error', 'Error in RWE Deal Data (' + ERROR_MESSAGE() + ')', 'Please verify connection.'

				INSERT INTO source_system_data_import_status_detail(process_id, [source], [type], [description]) 
				SELECT @process_id, @file_name_status, @file_name_status, 'Error in RWE Deal Data (' + ERROR_MESSAGE() + ')'
			
			END CATCH
			FETCH NEXT FROM cur_files INTO @file_name, @as_of_date, @folder_endur_or_user, @file_type, @create_time
		END
		CLOSE cur_files
		DEALLOCATE cur_files;
		
		EXEC spa_print '##########################################################End: ', @import_process_table
		
		UPDATE source_deal_header SET term_frequency = 'm' WHERE term_frequency IS NULL
		SET @process_id1 = @process_id
		GOTO Messaging
		level_4005:
	END
	
	IF EXISTS (SELECT 1 FROM dbo.splitCommaseperatedValues(@parse_type) WHERE item = 6)	-- RWE MTM
	BEGIN
		--SET @process_id = dbo.FNAGetNewID()
		SET @table_no = 4006
		DELETE @tablename
		INSERT INTO @tablename EXEC dbo.spa_import_temp_table @table_no
		SELECT @table = tname FROM @tablename
		SET @i = 1
		
		DECLARE cur_files CURSOR LOCAL FOR 
		SELECT [file_name], MAX(file_as_of_date) file_as_of_date,folder_endur_or_user, MAX(file_type) file_type, MAX(file_timestamp ) file_timestamp
		, MAX(endur_run_date_for_files) endur_run_date
		FROM adiha_process.dbo.stage_mtm_rwe_de 
		GROUP BY folder_endur_or_user, [file_name] 
		ORDER BY folder_endur_or_user, file_type, file_as_of_date, file_timestamp, endur_run_date
		 
		OPEN cur_files
		FETCH NEXT FROM cur_files INTO @file_name, @as_of_date, @folder_endur_or_user, @file_type, @create_time, @endur_run_date
		WHILE @@FETCH_STATUS = 0
		BEGIN
			BEGIN TRY
				SET @as_of_date = @endur_run_date
				IF ISNULL(@max_date, '19000101') < @as_of_date
					SET @max_date = @as_of_date

				SET @run_start_time = GETDATE()
				SET @import_process_table = dbo.FNAProcessTableName('mtm' + CAST(@i AS VARCHAR), @user, @process_id)
				SET @i = @i + 1

				SET @file_name_status = CASE WHEN @folder_endur_or_user = 'e' THEN 'Endur/' ELSE 'User/' END + @file_name

				EXEC('SELECT * INTO ' +@import_process_table + ' FROM '+ @table)
				TRUNCATE TABLE #ErrorHandler

				EXEC spa_print 'insert into #tmp_dicount_factor'
				
				--SELECT sdh.source_deal_header_id, CONVERT(DATETIME, @as_of_date, 103) as_of_date, CONVERT(DATETIME, t.[profile_end_date],103) maturity
				--INTO #tmp_dicount_factor 
				--FROM source_deal_header sdh 
				--INNER JOIN adiha_process.dbo.stage_mtm_rwe_de t ON t.deal_num = sdh.deal_id 
				--	AND sdh.source_system_id = @source_system_id
				--	AND CONVERT(DATETIME,t.[profile_end_date], 103) > CONVERT(DATETIME, @as_of_date, 103)
				--	AND t.[file_name] = @file_name 
				--	AND folder_endur_or_user = @folder_endur_or_user

				--CREATE INDEX index_tmp_dicount_factor ON #tmp_dicount_factor (source_deal_header_id, as_of_date, maturity)
									
				EXEC spa_print 'DELETE [dbo].[source_deal_discount_factor]'

				--DELETE [dbo].[source_deal_discount_factor] FROM [source_deal_discount_factor] s
				--INNER JOIN #tmp_dicount_factor sdh ON sdh.source_deal_header_id = s.source_deal_header_id 
				--	AND sdh.as_of_date = s.as_of_date 
				--	AND sdh.maturity = s.maturity
					
				--DROP TABLE #tmp_dicount_factor


				EXEC spa_print 'INSERT INTO [dbo].[source_deal_discount_factor]'
				INSERT INTO [dbo].[source_deal_discount_factor](
					[as_of_date]
					, [source_deal_header_id]
					, [maturity]
					, [market_price]
					, [discount_factor]
					, [create_user]
					, [create_ts]
				)
				SELECT 
					CONVERT(DATETIME, @as_of_date, 103)
					, sdh.source_deal_header_id
					, CONVERT(VARCHAR(10), CONVERT(DATETIME, a.[profile_end_date], 105), 120)
					, 0 --ISNULL(a.market_price, 0)
					, ISNULL(a.df_by_leg_result, 0)
					, dbo.FNADBUser()
					, GETDATE()
				FROM adiha_process.dbo.stage_mtm_rwe_de a 
				INNER JOIN source_deal_header sdh ON a.deal_num = sdh.deal_id 
					AND sdh.source_system_id = @source_system_id
					AND a.[file_name] = @file_name  
					AND folder_endur_or_user = @folder_endur_or_user 
					AND CONVERT(DATETIME, a.[profile_end_date], 103) > CONVERT(DATETIME, @as_of_date, 103)
								
				SET	@as_of_date_import = CONVERT(VARCHAR(10), CONVERT(DATETIME, @as_of_date, 103), 120) --CONVERT(DATETIME, @as_of_date, 103)

				SET @sql = 
				'INSERT INTO  '+ @import_process_table +'
				   ([source_deal_header_id]
				   , [source_system_id]
				   , [term_start]
				   , [term_end]
				   , [leg]
				   , [pnl_as_of_date]
				   , [und_pnl]
				   , [und_intrinsic_pnl]
				   , [und_extrinsic_pnl]
				   , [dis_pnl]
				   , [dis_intrinsic_pnl]
				   , [dis_extrinisic_pnl]
				   , [pnl_source_value_id]
				   , [pnl_currency_id]
				   , [pnl_conversion_factor]
				   , [pnl_adjustment_value]
				   , [deal_volume]
				)
				SELECT	
					sdh.deal_id,
					' + CAST(@source_system_id AS VARCHAR(3)) + ' [source_system_id]
					,CONVERT(VARCHAR(10), CONVERT(DATETIME, DATEADD(MONTH, -1, DATEADD(DAY, 1, CONVERT(DATETIME, a.[profile_end_date],103))), 103), 120) [term_start] -- term start is start day of term end month
					,CONVERT(VARCHAR(10), CONVERT(DATETIME, a.[profile_end_date],103),120) [term_end]
					,1 leg
					,CONVERT(VARCHAR(10), CONVERT(DATETIME, ''' + @as_of_date + ''', 103), 120) [pnl_as_of_date]
					,ISNULL(a.pv_df_by_leg_result, 0) [und_pnl]
					,ISNULL(a.pv_df_by_leg_result, 0) [und_intrinsic_pnl]
					,0 [und_extrinsic_pnl]
					,ISNULL(a.pv_from_mtm_detail_result, 0) [dis_pnl]
					,ISNULL(a.pv_from_mtm_detail_result, 0) [dis_intrinsic_pnl]
					,0 [dis_extrinisic_pnl]
					,775 [pnl_source_value_id]
					,ISNULL(sc.currency_id, ''UNKNOWN'') [pnl_currency_id]
					,1 [pnl_conversion_factor]
					,0 [pnl_adjustment_value]
					,0 [deal_volume]
					FROM adiha_process.dbo.stage_mtm_rwe_de a LEFT JOIN source_deal_header sdh ON a.deal_num = sdh.deal_id AND sdh.source_system_id=' + CAST(@source_system_id AS VARCHAR(3)) + '
						LEFT JOIN source_deal_detail sdd ON sdd.source_deal_header_id = sdh.source_deal_header_id
						AND  CONVERT(VARCHAR(10), CONVERT(DATETIME, a.[profile_end_date], 103), 120) = sdd.term_start
						AND sdd.leg = 1
						LEFT JOIN source_currency sc ON sc.currency_id = a.euro_side_currency
					WHERE 
					--CONVERT(DATETIME, a.[profile_end_date], 103) > CONVERT(DATETIME, '''+@as_of_date  +''', 103) AND
					a.file_name=''' + @file_name + ''' AND folder_endur_or_user =''' + @folder_endur_or_user + '''
					AND  sc.source_system_id = '''+ CAST(@source_system_id AS VARCHAR(3)) + ''' ' 

				EXEC spa_print @sql
				EXEC(@sql)

				SELECT @no_rec = COUNT(*) FROM adiha_process.dbo.stage_mtm_rwe_de a 
				INNER JOIN source_deal_header sdh ON a.deal_num = sdh.deal_id 
					AND sdh.source_system_id = @source_system_id 
					AND a.[file_name] = @file_name  
					AND folder_endur_or_user = @folder_endur_or_user
					WHERE CONVERT(DATETIME, a.[profile_end_date], 103) > CONVERT(DATETIME, @as_of_date, 103)
					
				SELECT @out_of_rec = COUNT(*) 
				FROM adiha_process.dbo.stage_mtm_rwe_de 
				WHERE [file_name] = @file_name
					AND folder_endur_or_user = @folder_endur_or_user
					--AND CONVERT(DATETIME, [profile_end_date], 103) > CONVERT(DATETIME, @as_of_date, 103)
				
				--INSERT INTO source_system_data_import_status(process_id, code, [module], [source], [type], [description], recommendation) 
				--SELECT @process_id, (CASE WHEN @out_of_rec = @no_rec THEN 'Success' ELSE 'Warning' END) code, @file_name_status, 'MTM Discount Factor', 'Data Import', CAST(@no_rec AS VARCHAR)+ ' forward deal detail discount factors imported successfully out of rows ' + CAST(@out_of_rec AS VARCHAR) + ' records.','Please verify data.'
				--FROM adiha_process.dbo.stage_mtm_rwe_de a INNER JOIN source_deal_header sdh ON a.source_deal_header_id=sdh.deal_id
									
				INSERT INTO #ErrorHandler EXEC spa_import_data_job @import_process_table, @table_no, @job_name, @process_id, @user, 'n', 6, NULL, @as_of_date_import, @file_name_status
				IF EXISTS(SELECT 1 FROM #ErrorHandler WHERE err_code = 'Error') 
					SET @error_code = 'e'
				ELSE
					SET @error_code = 's'
				
				INSERT import_data_files_audit(
					dir_path
					, imp_file_name
					, as_of_date
					, [status]
					, elapsed_time
					, process_id
					, create_user
					, source_system_id
				)
				VALUES(
					'Endur'
					, @file_name_status
					, CONVERT(VARCHAR(10), CONVERT(DATETIME, @as_of_date, 103), 120)
					, @error_code
					, DATEDIFF(ss, @run_start_time, GETDATE())
					, @process_id
					, @user
					, @source_system_id)
			END TRY 
			BEGIN CATCH	
				INSERT INTO source_system_data_import_status(process_id, code, [module], [source], [type], [description], recommendation) 
				SELECT @process_id, 'Error', @file_name_status, 'RWE MTM', 'Data Error', 'Error in RWE MTM Data (' + ERROR_MESSAGE() + ')', 'Please check data.'

				INSERT INTO source_system_data_import_status_detail(process_id, [source], [type], [description]) 
				SELECT @process_id, 'RWE MTM', @file_name_status, 'Error in RWE MTM Data (' + ERROR_MESSAGE() + ')'
					
--				IF CURSOR_STATUS('local', 'cur_files') >= 0 
--				BEGIN
--					CLOSE cur_files
--					DEALLOCATE cur_files;
--				END
			END CATCH	
				
			FETCH NEXT FROM cur_files INTO @file_name,@as_of_date,@folder_endur_or_user,@file_type,@create_time, @endur_run_date
			
		END
		CLOSE cur_files
		DEALLOCATE cur_files

		SET @process_id2 = @process_id

		GOTO Messaging
		level_4006:			
	END
	
	
	IF EXISTS (SELECT 1 FROM dbo.splitCommaseperatedValues(@parse_type) WHERE item = 4)	-- RWE Price curve
	BEGIN
		--SET @process_id = dbo.FNAGetNewID()
		SET @table_no = 4008
		UPDATE adiha_process.dbo.stage_spc_rwe_de SET [proj_index_id] = REPLACE([proj_index_id], '#', '_')
		SET @i = 1
		DELETE @tablename
		INSERT INTO @tablename EXEC dbo.spa_import_temp_table @table_no
		SELECT @table = tname FROM @tablename
	
		DECLARE cur_files CURSOR LOCAL FOR 
		SELECT [file_name], MAX(file_as_of_date) file_as_of_date, folder_endur_or_user, MAX(file_type) file_type, MAX(file_timestamp )file_timestamp
		FROM adiha_process.dbo.stage_spc_rwe_de 
		GROUP BY folder_endur_or_user, [file_name] 
		ORDER BY folder_endur_or_user, file_type, file_as_of_date ,file_timestamp 
		OPEN cur_files
		FETCH NEXT FROM cur_files INTO @file_name, @as_of_date, @folder_endur_or_user, @file_type, @create_time
		WHILE @@FETCH_STATUS = 0
		BEGIN
			BEGIN TRY
			
			--SET @as_of_date = LEFT(REPLACE(@file_name, 'IAS39_CURVE_', ''), 8)
			
			IF ISNULL(@max_date, '19000101') < @as_of_date
				SET @max_date = @as_of_date

			SET @run_start_time = GETDATE()

			SET @import_process_table = dbo.FNAProcessTableName('price' + CAST(@i AS VARCHAR), @user, @process_id)
			SET @i = @i + 1

			--select @import_process_table
			SET @file_name_status = CASE WHEN @folder_endur_or_user = 'e' THEN 'Endur/' ELSE 'User/' END + @file_name

			EXEC('SELECT * INTO ' +@import_process_table + ' FROM '+ @table)
			TRUNCATE TABLE #ErrorHandler

			SET @sql =
			'INSERT INTO ' + @import_process_table + '
			   (
					[source_curve_def_id]
					, [source_system_id]
					, [as_of_date]
					, [Assessment_curve_type_value_id]
					, [curve_source_value_id]
					, [maturity_date]
					, [maturity_hour]
					, [curve_value]
					, [table_code]
				)
				SELECT 
					a.[proj_index_id]
					, ' + CAST(@source_system_id AS VARCHAR(3)) + ' [source_system_id]
					, CONVERT(VARCHAR(10), CONVERT(DATETIME, a.[endur_run_date_for_files], 105), 101) [as_of_date]
					, 77 [Assessment_curve_type_value_id]
					, 4500 [curve_source_value_id] ---4500 --775
					, CONVERT(VARCHAR(10), CONVERT(DATETIME, DATEADD(MM, DATEDIFF(MM, 0, CONVERT(DATETIME, a.[index_curve_date], 105)), 0), 105), 101) [maturity_date] -- maturity date is required to set as 1st day of month
					, ''00:00:00''
					, CAST(a.[curve_price] as NUMERIC(38,4))
					, 4008 [table_code]
				FROM adiha_process.dbo.stage_spc_rwe_de a WHERE a.file_name = ''' + @file_name + ''' AND a.folder_endur_or_user = ''' + @folder_endur_or_user + ''''
		
			exec spa_print @sql
			EXEC(@sql)

			INSERT INTO #ErrorHandler EXEC spa_import_data_job @import_process_table, @table_no, @job_name, @process_id, @user, 'n', 6, NULL, NULL, @file_name_status
			IF EXISTS(SELECT 1 FROM #ErrorHandler WHERE err_code = 'Error') 
				SET @error_code = 'e'
			ELSE
				SET @error_code = 's'
			
			INSERT import_data_files_audit(
				dir_path
				, imp_file_name
				, as_of_date
				, [status]
				, elapsed_time
				, process_id
				, create_user
				, source_system_id)
			VALUES(
				'Endur'
				, @file_name_status
				, CONVERT(VARCHAR(10), CONVERT(DATETIME, @as_of_date, 103), 120)
				, @error_code
				, DATEDIFF(ss, @run_start_time, GETDATE())
				, @process_id
				, @user
				, @source_system_id)
				
			SET	@as_of_date_import = CONVERT(DATETIME, @as_of_date, 103)
			
			END TRY 
			BEGIN CATCH	
				INSERT INTO source_system_data_import_status(process_id, code, [module], [source], [type], [description], recommendation) 
				SELECT @process_id, 'Error', @file_name_status, 'RWE Price curve', 'Data Error', 'Error in RWE Price curve Data (' + ERROR_MESSAGE() + ')', 'Please verify connection.'

				INSERT INTO source_system_data_import_status_detail(process_id, [source], [type], [description]) 
				SELECT @process_id, 'RWE Price curve', @file_name_status, 'Error in RWE Price curve Data (' + ERROR_MESSAGE() + ')'
					
--					IF CURSOR_STATUS('local', 'cur_files') >= 0 
--					BEGIN
--						CLOSE cur_files
--						DEALLOCATE cur_files;
--					END
			END CATCH

			FETCH NEXT FROM cur_files INTO @file_name, @as_of_date, @folder_endur_or_user, @file_type, @create_time
		END
		CLOSE cur_files
		DEALLOCATE cur_files
		
		SET @process_id3 = @process_id
		GOTO Messaging
		level_4008:
	END
	


END

IF @data_type = 'Error'
BEGIN
	
	addError:		
	EXEC spa_print 'Problem in SSIS Side'
	
	INSERT INTO fas_eff_ass_test_run_log(process_id, code, [module], [source],[type], [description], nextsteps) 
	SELECT @main_process_id, 'Error', 'Import Data'
		, CASE @parse_type 
				WHEN '4' THEN 'RWE Price Curve'
				WHEN '6' THEN 'RWE MTM'
				WHEN '5' THEN 'RWE Deal'
				WHEN '7' THEN 'Deal Detail Hour'
				WHEN '0' THEN 'No Files Found'
				ELSE 'File Format Error' 
			END
			, 'Data Error', ISNULL(@err_msg, 'Error found in import file.'), @next_step

	RETURN		
END 

messageboard:

IF ISNULL(@msg_board_err, 0) = 1
	SET @error_code = 'e'
ELSE		
BEGIN
	IF EXISTS(SELECT 1 FROM fas_eff_ass_test_run_log WHERE process_id = @main_process_id AND code = 'Error')
		SET @error_code = 'e'
	ELSE
		SET @error_code = 's'
END

SELECT @url_email = php_path + '/dev/spa_html.php?__user_name__=' + @user + '&spa=exec spa_get_import_process_status_from_ass_log ''' + @main_process_id + ''''
FROM connection_string

SET @e_time = DATEDIFF(ss, @start_ts, GETDATE())  
SET @e_time_text = CAST(@e_time/60  AS VARCHAR) + ' Mins ' + CAST(@e_time%60 AS VARCHAR) + ' Secs'
--EXEC spa_print 'Complete Time:' + CONVERT(VARCHAR(30),GETDATE(),120)
EXEC spa_print @e_time_text

SELECT @url = './dev/spa_html.php?__user_name__=' + @user + '&spa=exec spa_get_import_process_status_from_ass_log ''' + @main_process_id + ''''
SELECT @desc = '<a target="_blank" href="' + @url + '">Import process completed for as of date ' + dbo.FNAUserDateFormat(ISNULL(CONVERT(DATETIME, @max_date, 103),GETDATE()), @user)
			+	CASE WHEN (@error_code = 'e') THEN ' (ERRORS found)  ' ELSE '  ' END + '[Elapse time: ' + ISNULL(@e_time_text,'ooooooooooooooo') + '].</a>' 

EXEC spa_print @desc

--emailing if error found
IF @error_code = 'e'
BEGIN
	IF @send_email = 'y'
	BEGIN
		IF NOT EXISTS(SELECT 1 FROM message_board WHERE process_id = @process_id)
		BEGIN
			SET @desc_detail = ''

			SELECT  @desc_detail = @desc_detail + ISNULL([description], '') + ' (' + ISNULL([source], '') + ');' 
			FROM source_system_data_import_status
			WHERE process_id IN (@process_id1, @process_id2, @process_id3) AND code = 'Error'

			EXEC spa_interface_Adapter_email @process_id, 1, @desc, @desc_detail, @url_email

			RETURN
		END
	END
END

IF @send_email = 'y'
BEGIN
	IF NOT EXISTS(SELECT 1 FROM message_board WHERE process_id = @main_process_id)
	BEGIN
		DECLARE list_user CURSOR FOR 
		SELECT application_users.user_login_id	
		FROM dbo.application_role_user 
		INNER JOIN dbo.application_security_role ON dbo.application_role_user.role_id = dbo.application_security_role.role_id 
		INNER JOIN dbo.application_users ON dbo.application_role_user.user_login_id = dbo.application_users.user_login_id
		WHERE (dbo.application_users.user_active = 'y') AND (dbo.application_security_role.role_type_value_id = 2) 
				--AND  dbo.application_users.user_emal_add IS NOT NULL
		GROUP BY dbo.application_users.user_login_id, dbo.application_users.user_emal_add

		OPEN list_user

		FETCH NEXT FROM list_user INTO @user

		WHILE @@FETCH_STATUS = 0
		BEGIN				
			EXEC  spa_message_board 'i', @user, NULL, 'Import Data', @desc, '', '', @error_code, 'Interface Adaptor', NULL, @main_process_id
			FETCH NEXT FROM list_user INTO 	@user
		END

		CLOSE list_user
		DEALLOCATE list_user
	END
END
ELSE
BEGIN
	IF  NOT EXISTS(SELECT 1 FROM message_board WHERE process_id = @process_id) 
	BEGIN
		EXEC  spa_message_board 'i', @user, NULL, 'Import Data', @desc, '', '', @error_code, 'Interface Adaptor', NULL, @main_process_id
/*
		IF EXISTS(SELECT 1 FROM dbo.SplitCommaSeperatedValues(@parse_type) WHERE item = 5)
		BEGIN
			DECLARE @today VARCHAR(10)
			DECLARE @process_tablename VARCHAR(MAX)
			SET @today = dbo.FNAGetSQLStandardDate(GETDATE())
			SELECT @process_tablename = [name] FROM #temp_process_table_name
			
			IF @process_tablename = 'ALL'
				EXEC spa_calc_dynamic_limit @run_date = @today, @flag = 'c', @user_login_id = @user --, @test_value = @process_tablename
			ELSE IF @process_tablename IS NOT NULL
				EXEC spa_calc_dynamic_limit @run_date = @today, @flag = 'c', @source_updated_deal_ids = NULL, @source_updated_deal_table = @process_tablename, @user_login_id = @user --, @test_value = @process_tablename
		
			-- for UK Limit 
			DECLARE @process_tablename_UK VARCHAR(MAX)
			SELECT @process_tablename_UK = [name] FROM #temp_process_table_name_UK
			EXEC [spa_calc_UK_limit] @flag = 'c', @source_updated_deal_table = @process_tablename_UK, @user_login_id = @user
		END
		*/
	END 
	ELSE
	BEGIN
		EXEC spa_message_board 'u', @user, NULL, 'Import Data', @desc, '', '', @error_code, 'Interface Adaptor', NULL, @main_process_id, NULL ,'n'
	END

END


IF NOT EXISTS(SELECT 1 FROM fas_eff_ass_test_run_log WHERE process_id = @main_process_id)
BEGIN
	SET @parse_type = '99'
	IF @is_empty = 1
		SET @parse_type = '0'
	GOTO addError
END

RETURN	

Messaging:	

SELECT @count = COUNT(*) 
FROM source_system_data_import_status 
WHERE process_id = @process_id AND code = 'Error' 
	AND ([source] = CASE @table_no 
						WHEN '4008' THEN 'source_price_curve'
						WHEN '4006' THEN 'RWE MTM' -- 'source_deal_pnl'
						WHEN '4005' THEN 'RWE Deal' -- 'source_deal_detail'
		           END OR [source] = CASE @table_no 
						WHEN '4005' THEN 'Position' -- 'source_deal_detail'
						ELSE [source]
		           END)
							           
IF @count > 0
BEGIN 
	SET @error_code = 'e'
	SET @msg_board_err = 1
END
ELSE
	SET @error_code = 's'

SELECT @url = 'exec spa_get_import_process_status ^' + @process_id + '^,^' + @user + '^'
SELECT @desc = '<a href="javascript: second_level_drill(''' + @url + ''')">' 
				+ CASE @table_no 
							WHEN '4008' THEN 'Price curve import completed for as of date:'+ dbo.FNAUserDateFormat(ISNULL(CONVERT(DATETIME, @max_date, 103),GETDATE()), @user)
							WHEN '4005' THEN 'Deal import completed for as of date:'+ dbo.FNAUserDateFormat(ISNULL(CONVERT(DATETIME, @max_date, 103),GETDATE()), @user)
							WHEN '4006' THEN 'MTM import completed for as of date:' + dbo.FNAUserDateFormat(ISNULL(CONVERT(DATETIME, @max_date, 103),GETDATE()), @user)
					END
				+ CASE WHEN (@error_code = 'e') THEN ' (ERRORS found)' ELSE '' END +
				'.</a>' 

IF EXISTS(
	SELECT 1 FROM source_system_data_import_status where process_id=@process_id
	UNION ALL
	SELECT  1 FROM source_system_data_import_status_vol where process_id=@process_id
)
BEGIN
	INSERT INTO fas_eff_ass_test_run_log(process_id, code, [module], [source], [type], [description], nextsteps) 
	SELECT @main_process_id, CASE WHEN (@error_code = 'e') THEN 'Error' ELSE 'Success' END
	,'Import Data', CASE @table_no 
					WHEN '4008' THEN 'RWE Price Curve'
					WHEN '4006' THEN 'RWE MTM'
					WHEN '4005' THEN 'RWE Deal'
				END
	, CASE WHEN (@error_code = 'e') THEN 'Data Error' ELSE 'Data Success' END, @desc, 'Please verify data.'
	
END


IF @table_no = '4005'
	GOTO level_4005			
ELSE IF @table_no = '4006'
	GOTO level_4006			
ELSE IF @table_no = '4008'
	GOTO level_4008			

GO
