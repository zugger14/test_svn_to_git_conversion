
IF OBJECT_ID(N'[dbo].[spa_import_northpool_deals]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[spa_import_northpool_deals]
GO
 
SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
-- ===========================================================================================================
-- Author: rtuladhar@pioneersolutionsglobal.com
-- Create date: 2016-04-27
-- Description: import northpool deals and create report
 
-- Params:
-- @flag CHAR(1) - Operation flag
-- ===========================================================================================================
CREATE PROCEDURE [dbo].[spa_import_northpool_deals]
	@flag CHAR(1) = NULL,
	@file_dir VARCHAR(1000) = NULL,
	@file_name VARCHAR(500)  = NULL,
	@subsidiary_id VARCHAR(MAX) = NULL,
	@strategy_id VARCHAR(MAX) = NULL,
	@book_id VARCHAR(MAX) = NULL,

	@batch_process_id VARCHAR(250) = NULL,
	@batch_report_param VARCHAR(500) = NULL, 
	@enable_paging INT = 0,  --'1' = enable, '0' = disable
	@page_size INT = NULL,
	@page_no INT = NULL

AS

SET NOCOUNT ON

/*******************************************1st Paging Batch START**********************************************/
 
DECLARE @str_batch_table VARCHAR(8000)
DECLARE @user_login_id VARCHAR(50)
DECLARE @sql_paging VARCHAR(8000)
DECLARE @is_batch BIT
 
SET @str_batch_table = ''
SET @user_login_id = dbo.FNADBUser() 
SET @is_batch = CASE WHEN @batch_process_id IS NOT NULL AND @batch_report_param IS NOT NULL THEN 1 ELSE 0 END 
 
IF @is_batch = 1
   SET @str_batch_table = ' INTO ' + dbo.FNAProcessTableName('batch_report', @user_login_id, @batch_process_id)
 
IF @enable_paging = 1 --paging processing
BEGIN
   IF @batch_process_id IS NULL
      SET @batch_process_id = dbo.FNAGetNewID()
 
   SET @str_batch_table = dbo.FNAPagingProcess('p', @batch_process_id, @page_size, @page_no)
 
   --retrieve data from paging table instead of main table
   IF @page_no IS NOT NULL 
   BEGIN
      SET @sql_paging = dbo.FNAPagingProcess('s', @batch_process_id, @page_size, @page_no) 
      EXEC (@sql_paging) 
      RETURN 
   END
END
 
/*******************************************1st Paging Batch END**********************************************/

DECLARE @file_full_path VARCHAR(500)
DECLARE @str_batch_table_final VARCHAR(8000)
DECLARE @sql VARCHAR(MAX)
 
SET @user_login_id = dbo.FNADBUser()

/*
DECLARE @file_dir varchar(1000)
DECLARE @file_name  VARCHAR(500)
-- */

--SET @file_dir = 'E:\TEST'
----TODO: change file name
--SET @file_name = 'test1.csv'
--SET @file_full_path = @file_dir + '\' + @file_name
--PRINT 'Bulk import from ' + @file_full_path

IF @flag = 'i' --import
BEGIN 
	DECLARE @cmd      varchar(1000)
	SET @cmd = 'dir ' + @file_dir  + '\' + '*.csv /b'
 
	CREATE TABLE #file_names([file_name] VARCHAR(255) COLLATE DATABASE_DEFAULT)
    INSERT INTO  #file_names([file_name])
    EXEC Master..xp_cmdShell @cmd
	
	SELECT @file_name = [file_name] FROM #file_names WHERE [file_name] IS NOT NULL
	SET @file_full_path =  @file_dir + '\' + @file_name

	SET @batch_process_id = dbo.FNAGetNewID()
	SET @str_batch_table =  dbo.FNAProcessTableName('import_data_deal', @user_login_id, 'fixed')
	SET @str_batch_table_final =  dbo.FNAProcessTableName('import_data_deal_final', @user_login_id, @batch_process_id)

	IF @file_name = 'File Not Found' 
	BEGIN 
		EXEC spa_ErrorHandler -1,
			'import_northpool_deals',
			'spa_import_northpool_deals',
			'File Error',
			'File not found.',
			''
		RETURN
	END
	  
	IF OBJECT_ID('tempdb.dbo.#tmp_ref_ids') IS NOT NULL
		DROP TABLE #tmp_ref_ids

	BEGIN TRY
		BEGIN TRAN
		CREATE TABLE #tmp_ref_ids (trader_id 	VARCHAR(MAX) COLLATE DATABASE_DEFAULT 
									, tso		VARCHAR(MAX) COLLATE DATABASE_DEFAULT 
									, eis		VARCHAR(MAX) COLLATE DATABASE_DEFAULT 
									, b_s		VARCHAR(MAX) COLLATE DATABASE_DEFAULT 
									, product	VARCHAR(MAX) COLLATE DATABASE_DEFAULT 
									, contract	VARCHAR(MAX) COLLATE DATABASE_DEFAULT 
									, qty		VARCHAR(MAX) COLLATE DATABASE_DEFAULT 
									, prc		VARCHAR(MAX) COLLATE DATABASE_DEFAULT 
									, curr		VARCHAR(MAX) COLLATE DATABASE_DEFAULT 
									, act		VARCHAR(MAX) COLLATE DATABASE_DEFAULT 
									, text		VARCHAR(MAX) COLLATE DATABASE_DEFAULT 
									, state		VARCHAR(MAX) COLLATE DATABASE_DEFAULT 
									, order_no	VARCHAR(MAX) COLLATE DATABASE_DEFAULT 
									, trade_no	VARCHAR(MAX) COLLATE DATABASE_DEFAULT 
									, p_o		VARCHAR(MAX) COLLATE DATABASE_DEFAULT 
									, date_time	VARCHAR(MAX) COLLATE DATABASE_DEFAULT 
									, bg		VARCHAR(MAX) COLLATE DATABASE_DEFAULT 
									)

		EXEC('
		BULK INSERT #tmp_ref_ids
				FROM ''' + @file_full_path + '''
				WITH 
				( 
					FIRSTROW = 3, 
					FIELDTERMINATOR = '','', 
					ROWTERMINATOR = ''\n'' 
				)
		')

		DELETE FROM #tmp_ref_ids WHERE act = 'P'
		 
		IF COL_LENGTH('tempdb..#tmp_ref_ids', 'term_start') IS NULL
		BEGIN 
			ALTER TABLE #tmp_ref_ids 
			ADD term_start VARCHAR(100)		
		END

		IF COL_LENGTH('tempdb..#tmp_ref_ids', 'term_end') IS NULL
		BEGIN 
			ALTER TABLE #tmp_ref_ids 
			ADD term_end VARCHAR(100)	
		END

		IF COL_LENGTH('tempdb..#tmp_ref_ids', 'term_start_hr') IS NULL
		BEGIN 
			ALTER TABLE #tmp_ref_ids 
			ADD term_start_hr VARCHAR(100)		
		END

		IF COL_LENGTH('tempdb..#tmp_ref_ids', 'term_end_hr') IS NULL
		BEGIN 
			ALTER TABLE #tmp_ref_ids 
			ADD term_end_hr VARCHAR(100)	
		END

		IF COL_LENGTH('tempdb..#tmp_ref_ids', 'granularity') IS NULL
		BEGIN 
			ALTER TABLE #tmp_ref_ids 
			ADD granularity VARCHAR(100)	
		END

		--get term start, term end, granularity and hours
		UPDATE r
		SET term_start = LEFT(contract, 4) + '-' + SUBSTRING(contract, 5, 2) + '-' + SUBSTRING(contract, 7, 2)  
			, term_end = SUBSTRING(contract, 16, 4)  + '-' + SUBSTRING(contract, 20, 2) + '-' + SUBSTRING(contract, 22, 2)  
			, term_start_hr = SUBSTRING(contract, 10, 5)   
			, term_end_hr = SUBSTRING(contract, 24, 6)  
			, granularity = CASE WHEN product = 'Intraday_Power_D' THEN 982 ELSE 987 END 
		FROM #tmp_ref_ids r

		--EXEC('DROP TABLE ' + @str_batch_table)

 
		SET @sql = 'IF OBJECT_ID (N''' + @str_batch_table + ''', N''U'') IS NULL
					BEGIN 
		 				CREATE TABLE ' + @str_batch_table + '(deal_id VARCHAR(1000), date_time VARCHAR(1000), state INT)
						INSERT INTO ' + @str_batch_table + '
						SELECT trade_no, date_time, 1 from #tmp_ref_ids
					END
					ELSE 
					BEGIN 
						UPDATE a
						SET state = 0
						FROM ' + @str_batch_table + ' a
						INNER JOIN #tmp_ref_ids tri ON tri.trade_no = a.deal_id
							AND tri.date_time = a.date_time 

						INSERT INTO ' + @str_batch_table + '
						SELECT trade_no, date_time, 1 FROM #tmp_ref_ids
						WHERE 1=1 AND date_time NOT IN (SELECT date_time FROM  ' + @str_batch_table + ')
			 
					END
					'
		--PRINT @Sql
		EXEC(@sql)	  

		--DROP TABLE  adiha_process.dbo.import_data_deal_final_sa_12 
		SET @sql = '
					SELECT ROW_NUMBER() OVER(ORDER BY tri.date_time) temp_header_id
						, sdht.source_system_id
						, tri.trade_no deal_id
						, dbo.FNAClientToSqlDate(LEFT(tri.date_time, 10)) deal_date
						, tri.order_no ext_deal_id						  
						, sdht.physical_financial_flag					  
						, sdht.structured_deal_id						  
						, sdht.counterparty_id							  
						, dbo.FNAClientToSqlDate(LEFT(tri.date_time, 10)) entire_term_start
						, dbo.FNAClientToSqlDate(LEFT(tri.date_time, 10)) entire_term_end
						, sdht.source_deal_type_id
						, sdht.deal_sub_type_type_id
						, sdht.option_flag
						--, sdht.option_type
						--, sdht.option_excercise_type
						--, source_system_book_id1
						--, source_system_book_id2
						--, source_system_book_id3
						--, source_system_book_id4
						, sdht.description1
						, tri.text description2
						, tri.p_o description3
						, sdht.deal_category_value_id
						, COALESCE(st.source_trader_id, sdht.trader_id, 128) trader_id
						--, sdht.internal_deal_type_value_id
						--, sdht.internal_deal_subtype_value_id
						, sdht.template_id
						, tri.b_s header_buy_sell_flag
						, sdht.broker_id
						--, sdht.generator_id
						--, sdht.status_value_id
						--, sdht.status_date
						--, sdht.assignment_type_value_id
						--, sdht.compliance_year
						--, sdht.state_value_id
						--, sdht.assigned_date
						, sdht.assigned_by
						--, sdht.generation_source
						--, sdht.aggregate_environment
						--, sdht.aggregate_envrionment_comment
						--, sdht.rec_price
						--, sdht.rec_formula_id
						--, sdht.rolling_avg
						, sdht.contract_id
						--, sdht.legal_entity
						, sdht.internal_desk_id
						, sdht.product_id
						--, sdht.internal_portfolio_id
						, sdht.commodity_id
						, sdht.reference
						, sdht.deal_locked
						, sdht.close_reference_id
						--, sdht.block_type
						--, sdht.block_define_id
						--, sdht.granularity_id
						--, sdht.Pricing
						--, sdht.deal_reference_type_id
						--, sdht.unit_fixed_flag
						--, sdht.broker_unit_fees
						--, sdht.broker_fixed_cost
						--, sdht.broker_currency_id
						, sdht.deal_status
						--, sdht.term_frequency
						--, sdht.option_settlement_date
						--, sdht.verified_by
						--, sdht.verified_date
						--, sdht.risk_sign_off_by
						--, sdht.risk_sign_off_date
						--, sdht.back_office_sign_off_by
						--, sdht.back_office_sign_off_date
						--, sdht.book_transfer_id
						, sdht.confirm_status_type
						--, sdht.sub_book
						--, sdht.deal_rules
						--, sdht.confirm_rule
						, tri.date_time aggregate_envrionment_comment
						--, sdht.timezone_id
						--, reference_detail_id
						--detail
						--,sddt.*
						, tri.term_start
						, tri.term_end
 
						, sddt.leg
						, sddt.fixed_float_leg
						, tri.b_s buy_sell_flag
						, sddt.curve_type
						, sddt.curve_id
						, sddt.deal_volume_frequency
						, sddt.deal_volume_uom_id
						, sc.source_currency_id currency_id
						, sddt.block_description
						--, sddt.template_id
						, sddt.commodity_id detail_commodity_id
						--, sddt.day_count
						, sddt.physical_financial_flag physical_financial_flag_detail
						, sml.source_minor_location_id location_id
						--, sddt.meter_id
						--, sddt.strip_months_from
						--, sddt.lag_months
						--, sddt.strip_months_to
						--, sddt.conversion_factor
						, sddt.pay_opposite
						, sddt.formula
						--, sddt.settlement_currency
						--, sddt.standard_yearly_volume
						--, sddt.price_uom_id
						--, sddt.category
						--, sddt.profile_code
						--, sddt.pv_party
						--, sddt.adder_currency_id
						--, sddt.booked
						--, sddt.capacity
						--, sddt.day_count_id
						--, sddt.deal_detail_description
						--, sddt.fixed_cost
						--, sddt.fixed_cost_currency_id
						--, sddt.formula_currency_id
						--, sddt.formula_curve_id
						--, sddt.formula_id
						--, sddt.multiplier
						--, sddt.option_strike_price
						--, sddt.price_adder
						--, sddt.price_adder_currency2
						--, sddt.price_adder2
						--, sddt.price_multiplier
						--, sddt.process_deal_status
						--, sddt.settlement_date
						--, sddt.settlement_uom
						--, sddt.settlement_volume
						--, sddt.volume_left
						--, sddt.volume_multiplier2
						, sddt.contract_expiration_date
						, tri.prc fixed_price
						, sddt.fixed_price_currency_id
						, tri.qty deal_volume
						, sddt.status
						, sddt.lock_deal_detail
						, sddt.contractual_volume
						, sddt.contractual_uom_id
						, sddt.actual_volume
						, term_start_hr	
						, term_end_hr
						, NULL temp_detail_id
						, granularity
						INTO ' + @str_batch_table_final + ' 
					FROM source_deal_header_template sdht 
					INNER JOIN #tmp_ref_ids tri ON REPLACE(tri.product, ''_'', '' '') = sdht.template_name
					INNER JOIN ' + @str_batch_table + ' tt ON tt.date_time = tri.date_time
						AND tri.trade_no = tt.deal_id
					INNER JOIN source_deal_detail_template sddt ON sddt.template_id = sdht.template_id
					INNER JOIN source_currency sc ON sc.currency_name = tri.curr
						AND sc.currency_name = ''EUR''
					LEFT JOIN source_traders st ON st.trader_name = tri.trader_id
					LEFT JOIN source_minor_location sml On sml.Location_Name = tri.eis
						--AND Location_Name IN ()
					WHERE template_name IN (''Quarterly Hour Power'',''Intraday Power D'')
						AND tt.state = 1
		 '

		--PRINT(@sql)
		EXEC(@sql)
	 
		DECLARE @source_system_book_id1 VARCHAR(100)  
		DECLARE @source_system_book_id2 VARCHAR(100)  
		DECLARE @source_system_book_id3 VARCHAR(100)  
		DECLARE @source_system_book_id4 VARCHAR(100)  
		DECLARE @sub_book				VARCHAR(100)  

		SELECT   
			@source_system_book_id1 = ssbm.source_system_book_id1, 
			@source_system_book_id2 = ssbm.source_system_book_id2, 
			@source_system_book_id3 = ssbm.source_system_book_id3, 
			@source_system_book_id4 = ssbm.source_system_book_id4,
			@sub_book = book_deal_type_map_id
		FROM   portfolio_hierarchy book(NOLOCK)
		INNER JOIN Portfolio_hierarchy stra(NOLOCK) ON  book.parent_entity_id = stra.entity_id
		INNER JOIN portfolio_hierarchy sub (NOLOCK) ON  stra.parent_entity_id = sub.entity_id
		INNER JOIN source_system_book_map ssbm ON  ssbm.fas_book_id = book.entity_id 
		WHERE stra.entity_name = 'NPOOL'
				AND sub.entity_name = 'NPOOL'
				AND book.entity_name = 'EPEX'


			--header
		SET @sql ='
					MERGE source_deal_header AS t
					USING (SELECT source_system_id
								, deal_id
								, deal_date
								, ext_deal_id
								, physical_financial_flag
								, structured_deal_id
								, counterparty_id
								, entire_term_start
								, entire_term_end
								, source_deal_type_id
								, deal_sub_type_type_id
								, option_flag
								, description1
								, description2
								, description3
								, aggregate_envrionment_comment
								, deal_category_value_id
								, trader_id
								, template_id
								, header_buy_sell_flag
								, broker_id
								, assigned_by
								, contract_id
								, internal_desk_id
								, product_id
								, commodity_id
								, reference
								, deal_locked
								, close_reference_id
								, deal_status
								, confirm_status_type
								, ' + @source_system_book_id1 + ' source_system_book_id1
								, ' + @source_system_book_id2 + ' source_system_book_id2
								, ' + @source_system_book_id3 + ' source_system_book_id3
								, ' + @source_system_book_id4 + ' source_system_book_id4
								, ' + @sub_book  + '  sub_book
					FROM ' + @str_batch_table_final + ') AS s
					ON s.deal_id = t.deal_id
					WHEN MATCHED THEN 
						UPDATE SET t.header_buy_sell_flag = s.header_buy_sell_flag
									, t.trader_id = s.trader_id
					WHEN NOT MATCHED THEN
					INSERT(source_system_id
										, deal_id
										, deal_date
										, ext_deal_id
										, physical_financial_flag
										, structured_deal_id
										, counterparty_id
										, entire_term_start
										, entire_term_end
										, source_deal_type_id
										, deal_sub_type_type_id
										, option_flag
										, description1
										, description2
										, description3
										, aggregate_envrionment_comment
										, deal_category_value_id
										, trader_id
										, template_id
										, header_buy_sell_flag
										, broker_id
										, assigned_by
										, contract_id
										, internal_desk_id
										, product_id
										, commodity_id
										, reference
										, deal_locked
										, close_reference_id
										, deal_status
										, confirm_status_type
										, source_system_book_id1
										, source_system_book_id2
										, source_system_book_id3
										, source_system_book_id4
										, sub_book)
					VALUES(source_system_id
							, s.deal_id
							, s.deal_date
							, s.ext_deal_id
							, s.physical_financial_flag
							, s.structured_deal_id
							, s.counterparty_id
							, s.entire_term_start
							, s.entire_term_end
							, s.source_deal_type_id
							, s.deal_sub_type_type_id
							, s.option_flag
							, s.description1
							, s.description2
							, s.description3
							, s.aggregate_envrionment_comment
							, s.deal_category_value_id
							, s.trader_id
							, s.template_id
							, s.header_buy_sell_flag
							, s.broker_id
							, s.assigned_by
							, s.contract_id
							, s.internal_desk_id
							, s.product_id
							, s.commodity_id
							, s.reference
							, s.deal_locked
							, s.close_reference_id
							, s.deal_status
							, s.confirm_status_type
							, s.source_system_book_id1
							, s.source_system_book_id2
							, s.source_system_book_id3
							, s.source_system_book_id4
							, s.sub_book );			 
	'

	--PRINT(@sql)
	EXEC(@sql)

	SET @sql = 'UPDATE a
				SET a.temp_header_id = sdh.source_deal_header_id
				FROM ' + @str_batch_table_final + ' a
				INNER JOIN source_deal_header sdh ON sdh.deal_id = a.deal_id
				 ' 
	--PRINT(@sql)
	EXEC(@sql)

	--detail
	SET @sql = 'MERGE source_deal_detail AS t
				USING (SELECT temp_header_id
								, term_start
								, term_end
								, leg
								, fixed_float_leg
								, buy_sell_flag
								, curve_type
								, curve_id
								, deal_volume_frequency
								, deal_volume_uom_id
								, currency_id
								, block_description						
								, physical_financial_flag_detail
								, location_id
								, pay_opposite
								, contract_expiration_date
								, fixed_price
								, fixed_price_currency_id
								, deal_volume
								, status
								, lock_deal_detail
								, contractual_volume
								, contractual_uom_id
								, actual_volume  
					FROM ' + @str_batch_table_final + ') AS s
				ON s.temp_header_id =  t.source_deal_header_id AND
					s.term_start =  t.term_start
				WHEN MATCHED THEN UPDATE SET t.deal_volume = s.deal_volume,
											 t.fixed_price = s.fixed_price
										
				WHEN NOT MATCHED THEN
				INSERT(source_deal_header_id
						, term_start
						, term_end
						, leg
						, fixed_float_leg
						, buy_sell_flag
						, curve_id
						, deal_volume_frequency
						, deal_volume_uom_id
						, fixed_price_currency_id   
						, block_description
						, physical_financial_flag 
						, location_id
						, pay_opposite
						, contract_expiration_date
						, fixed_price
						, deal_volume
						, status
						, lock_deal_detail
						, contractual_volume
						, contractual_uom_id
						, actual_volume)
				VALUES(temp_header_id, term_start
						, term_end
						, leg
						, fixed_float_leg
						, buy_sell_flag
						, curve_id
						, deal_volume_frequency
						, deal_volume_uom_id
						, currency_id
						, block_description
						, physical_financial_flag_detail
						, location_id
						, pay_opposite
						, contract_expiration_date
						, fixed_price
						, deal_volume
						, status
						, lock_deal_detail
						, contractual_volume
						, contractual_uom_id
						, actual_volume );
	 '
	 --select * FROM source_deal_header order by 1 desc
	--EXEC('SELECT * FROM '  + @str_batch_table_final )
	--PRINT(@sql)
	EXEC(@sql)

	SET @sql = 'UPDATE a
				SET a.temp_detail_id = sdd.source_deal_detail_id
				FROM ' + @str_batch_table_final + ' a
				INNER JOIN source_deal_detail sdd ON sdd.source_deal_header_id = a.temp_header_id
					AND sdd.term_start = a.term_start
				 ' 
	--PRINT(@sql)
	EXEC(@sql)
	-- source_deal_detail_hour
	--EXEC('SELECT * FROM ' + @str_batch_table_final  )
 
	SET @sql = 'MERGE source_deal_detail_hour AS t
				USING (	SELECT temp_detail_id
						, term_start
						, term_start_hr
						, term_end_hr
						, deal_volume
						, fixed_price
						, granularity
					FROM '  + @str_batch_table_final + ') AS s
				ON s.temp_detail_id = t.source_deal_detail_id
				WHEN MATCHED THEN UPDATE SET t.volume = s.deal_volume
											, t.price = s.fixed_price
				WHEN NOT MATCHED THEN
				INSERT(source_deal_detail_id
						, term_date
						, hr
						, is_dst
						, volume
						, price					
						, granularity)
				VALUES(s.temp_detail_id 
						, s.term_start
						, s.term_start_hr		
						, 0			
						, s.deal_volume
						, s.fixed_price
						, s.granularity);
			 '
		--PRINT(@sql)
		EXEC(@sql)

		DECLARE @report_page_tablix_id VARCHAR(1000)
		DECLARE @report_paramset_id VARCHAR(1000)

		SELECT @report_page_tablix_id = report_page_tablix_id, @report_paramset_id = report_paramset_id
		FROM report_page_tablix  rpt 
		INNER JOIN report_paramset rp ON rpt.page_id = rp.page_id
		WHERE rpt.name  like '%Market Place Position Report%'
		
		DECLARE @desc VARCHAR(1000)= '	&report_filter=sub_id=NULL,stra_id=NULL,book_id=NULL,sub_book_id=NULL'
										+ '&is_refresh=0'
										+ '&items_combined=ITEM_MarketPlacePositionReport:' + @report_page_tablix_id + '&paramset_id=' + @report_paramset_id + '&export_type=HTML4.0'
										+ '&__user_name__=' + dbo.FNADBUSer() + '&close_progress=1'

		SET @sql = 'IF EXISTS(SELECT 1 FROM ' + @str_batch_table + ' WHERE state = 1 )
					BEGIN
					 EXEC [spa_message_board]
							@flag = ''i'',
							@user_login_id = ''farrms_admin'' ,
							@source=''ImportData'',
							@description =''<a href="javascript:void();" onclick="TRMHyperlink(10202210, ''''' + @desc + ''''', ''''Market Place Position Report_MPPR'''')" >Deals Imported Successfully. Click Here to view Position Report.</a>'',
							@type = ''s''
					END'

		--PRINT @sql 
		EXEC(@sql)
		
		--rollback tran			
		COMMIT TRAN
		
	END TRY 
	BEGIN CATCH
 		ROLLBACK TRAN
		
		EXEC spa_ErrorHandler -1,
			'import_northpool_deals',
			'spa_import_northpool_deals',
			'DB Error',
			'Error while importing.',
					''
		--DROP TABLE  adiha_process.dbo.import_data_deal_final_sa_12 
	END CATCH
END
ELSE IF @flag = 'r'
BEGIN 
	IF OBJECT_ID(N'tempdb..#books') IS NOT NULL  
		DROP TABLE #books  

	IF OBJECT_ID(N'tempdb..#minute_table') IS NOT NULL  
		DROP TABLE #minute_table  

	IF OBJECT_ID(N'tempdb..#temp_ht_time') IS NOT NULL  
		DROP TABLE #temp_ht_time
	   
	IF OBJECT_ID(N'tempdb..#final_data') IS NOT NULL  
		DROP TABLE #final_data  

	CREATE TABLE  #minute_table(hr_time VARCHAR(2) COLLATE DATABASE_DEFAULT) INSERT INTO #minute_table (hr_time) VALUES ('00')
   
	DECLARE @_sub_id  INT = NULL 
	DECLARE @_stra_id INT = NULL 
	DECLARE @_book_id VARCHAR(1000) = NULL 
 
	SELECT @_sub_id = entity_id  FROM portfolio_hierarchy WHERE hierarchy_level = 2 AND entity_name = 'NPOOL'   
	SELECT @_stra_id = entity_id  FROM portfolio_hierarchy WHERE hierarchy_level = 1 AND entity_name = 'NPOOL' 
	SELECT @_book_id = COALESCE(@_book_id, '') + ',' + CAST(entity_id AS VARCHAR(100)) FROM portfolio_hierarchy WHERE hierarchy_level = 0 AND entity_name IN ('EPEX', 'B_EPEX')  
	SELECT @_book_id = SUBSTRING(@_book_id, 2, LEN(@_book_id)) 

	CREATE TABLE #books(      source_system_book_id1 INT      , source_system_book_id2 INT      , source_system_book_id3 INT      , source_system_book_id4 INT)  
	INSERT INTO #books 
	SELECT ssbm.source_system_book_id1
		, ssbm.source_system_book_id2
		, ssbm.source_system_book_id3
		, ssbm.source_system_book_id4 
	FROM portfolio_hierarchy book(NOLOCK) 
	INNER JOIN Portfolio_hierarchy stra(NOLOCK) ON  book.parent_entity_id = stra.entity_id 
	INNER JOIN portfolio_hierarchy sub (NOLOCK) ON  stra.parent_entity_id = sub.entity_id 
	INNER JOIN source_system_book_map ssbm ON  ssbm.fas_book_id = book.entity_id  
	WHERE 1 = 1   
		AND ( sub.entity_id IN (@_sub_id))   
		AND (stra.entity_id IN (@_stra_id))   
		AND (book.entity_id IN (SELECT item FROM dbo.FNASplit(@_book_id, ',')))  

	SELECT n, RIGHT('00' + CAST(n AS VARCHAR(10)), 2)  hr_time 
		INTO #temp_ht_time 
	FROM dbo.seq  
	CROSS apply #minute_table 
	WHERE N < 25 
	ORDER BY N  

	CREATE TABLE #final_data(Volume NUMERIC(18,4)  , counterparty_id VARCHAR(1000) COLLATE DATABASE_DEFAULT  , buy_sell_flag VARCHAR(100) COLLATE DATABASE_DEFAULT  , hr_time INT  , sub_id INT  , stra_id INT  , book_id INT   , sub_book_id INT)   

	INSERT INTO #final_data(Volume   , counterparty_id   , buy_sell_flag   , hr_time   , sub_id   , stra_id   , book_id   , sub_book_id ) 
	SELECT  SUM(CASE WHEN tht.hr_time = LEFT(sddh.hr, 2) THEN CASE WHEN LOWER(sdd.buy_sell_flag) = 's' THEN ROUND(sddh.volume, 2) * -1 ELSE ROUND(sddh.volume, 2) END ELSE 0 END) [Volume]      
			, sc.counterparty_id        
			, CASE WHEN LOWER(sdd.buy_sell_flag) = 's' THEN 'Sell' ELSE 'Buy' END  buy_sell_flag   
			, tht.hr_time     
			, 0 sub_id   
			, 0 stra_id   
			, 0 book_id   
			, 0 sub_book_id  
	FROM source_deal_header sdh  
	INNER JOIN #books books ON books.source_system_book_id1 = sdh.source_system_book_id1  
		AND books.source_system_book_id2 = sdh.source_system_book_id2  
		AND books.source_system_book_id3 = sdh.source_system_book_id3  
		AND books.source_system_book_id4 = sdh.source_system_book_id4  
	INNER JOIN source_deal_detail sdd ON sdd.source_deal_header_id = sdh.source_deal_header_id 
	INNER JOIN source_deal_detail_hour sddh ON sddh.source_deal_detail_id = sdd.source_deal_detail_id  
		AND sdd.term_start = sddh.term_date      
	CROSS APPLY #temp_ht_time tht   
	LEFT JOIN source_counterparty sc ON sc.source_counterparty_id = sdh.counterparty_id     
	GROUP BY hr_time, sc.counterparty_id,  buy_sell_flag  

	SELECT hr_time Hr,counterparty_id NET,  BUY Buy, SELL Sell
	FROM (
		SELECT hr_time, counterparty_id, buy_sell_flag, CAST(CONVERT(NUMERIC(18, 2), Volume) AS VARCHAR(1000)) Volume
		FROM #final_data) up
	PIVOT (MAX(Volume) FOR buy_sell_flag IN (BUY, SELL)) AS pvt
	ORDER BY hr_time
	 
END 

/*******************************************2nd Paging Batch START**********************************************/
 
--update time spent and batch completion message in message board
IF @is_batch = 1
BEGIN
   SELECT @sql_paging = dbo.FNABatchProcess('u', @batch_process_id, @batch_report_param, GETDATE(), NULL, NULL) 
   EXEC(@sql_paging)
 
   --TODO: modify sp and report name
   SELECT @sql_paging = dbo.FNABatchProcess('c', @batch_process_id, @batch_report_param, GETDATE(), 'spa_import_northpool_deals', 'Import')
   EXEC(@sql_paging)  
 
   RETURN
END
 
--if it is first call from paging, return total no. of rows and process id instead of actual data
IF @enable_paging = 1 AND @page_no IS NULL
BEGIN
   SET @sql_paging = dbo.FNAPagingProcess('t', @batch_process_id, @page_size, @page_no)
   EXEC(@sql_paging)
END
 

/*******************************************2nd Paging Batch END**********************************************/

GO
