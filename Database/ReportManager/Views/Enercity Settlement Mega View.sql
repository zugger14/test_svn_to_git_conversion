 BEGIN TRY
		BEGIN TRAN
	
	declare @new_ds_alias varchar(10) = 'ESSMV1'
	/** IF DATA SOURCE ALIAS ALREADY EXISTS ON DESTINATION, RAISE ERROR **/
	if exists(select top 1 1 from data_source where alias = 'ESSMV1' and name <> 'Enercity Settlement Mega View')
	begin
		select top 1 @new_ds_alias = 'ESSMV1' + cast(s.n as varchar(5))
		from seq s
		left join data_source ds on ds.alias = 'ESSMV1' + cast(s.n as varchar(5))
		where ds.data_source_id is null
			and s.n < 10

		--RAISERROR ('Datasource alias already exists on system.', 16, 1);
	end

	DECLARE @report_id_data_source_dest INT 
	
	SELECT @report_id_data_source_dest = report_id
	FROM report r
	WHERE r.[name] = NULL
	IF NOT EXISTS (SELECT 1 
	           FROM data_source 
	           WHERE [name] = 'Enercity Settlement Mega View'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	AND NOT EXISTS (SELECT 1 FROM map_function_category WHERE [function_name] = 'Enercity Settlement Mega View' AND '106500' = '106501') 
	BEGIN
		INSERT INTO data_source([type_id], [name], [alias], [description], [tsql], report_id, system_defined,category)
		SELECT TOP 1 1 AS [type_id], 'Enercity Settlement Mega View' AS [name], @new_ds_alias AS ALIAS, 'Standard Enercity Settlement Mega View' AS [description],null AS [tsql], @report_id_data_source_dest AS report_id,'1' AS [system_defined]
			,'106500' AS [category]
	END

	UPDATE data_source
	SET alias = @new_ds_alias, description = 'Standard Enercity Settlement Mega View'
	, [tsql] = CAST('' AS VARCHAR(MAX)) + '--Enercity Enercity Settlement Mega View
DECLARE @_sql_select1 VARCHAR(max)
DECLARE @_sql_select2 VARCHAR(max)
DECLARE @_sql_from1 VARCHAR(max)
DECLARE @_sql_from2 VARCHAR(max)
DECLARE @_sql_from3 VARCHAR(max)
DECLARE @_sql_from4 VARCHAR(max)
DECLARE @_sql_whr VARCHAR(max)
DECLARE @_from_as_of_date VARCHAR(50) --=''2020-01-31''
DECLARE @_to_as_of_date VARCHAR(50) --=''2020-09-30''
DECLARE @_term_start VARCHAR(50) --=''2016-01-01''
DECLARE @_term_end VARCHAR(50) --=''2017-12-31''
DECLARE @_deal_status_group CHAR(1) --= ''o''
DECLARE @_deal_date_from VARCHAR(50), @_deal_date_to VARCHAR(50), @_source_counterparty_id VARCHAR(max), 
@_source_deal_type_id VARCHAR(max), @_deal_sub_type_type_id VARCHAR(max), @_physical_financial_flag VARCHAR(20),
 @_contract_id VARCHAR(max), @_trader_id VARCHAR(max), @_block_definition_id VARCHAR(MAX), @_location_id VARCHAR(max), 
 @_index_id VARCHAR(max), 
@_source_deal_header_id VARCHAR(50) --=103922  
	,@_currency_id VARCHAR(MAX),
	@_broker_id VARCHAR(MAX),
	@_country_id VARCHAR(MAX),
	@_internal_counterparty_id VARCHAR(MAX),
	@_product_id VARCHAR(MAX),
	@_region_id VARCHAR(MAX),
	@_template_id VARCHAR(MAX),
	@_commodity_id VARCHAR(max), @_period_from VARCHAR(50), @_period_to VARCHAR(50), @_buy_sell_flag VARCHAR(20), @_deal_ref_id VARCHAR(50), @_deal_status_id VARCHAR(MAX), @_confirm_status_id VARCHAR(MAX), @_pnl_source_value_id VARCHAR(MAX), @_pricing_type_id VARCHAR(MAX),
	@_cur_type CHAR(1),
	@_col_sdpd_pnl VARCHAR(100),
	@_col_sdpd_cur VARCHAR(100)
SET @_from_as_of_date = nullif(isnull(@_from_as_of_date, nullif(''@from_as_of_date'', replace(''@_from_as_of_date'', ''@_'', ''@''))), ''null'')
SET @_to_as_of_date = nullif(isnull(@_to_as_of_date, nullif(''@to_as_of_date'', replace(''@_to_as_of_date'', ''@_'', ''@''))), ''null'')
SET @_term_start = nullif(isnull(@_term_start, nullif(''@term_start'', replace(''@_term_start'', ''@_'', ''@''))), ''null'')
SET @_term_end = nullif(isnull(@_term_end, nullif(''@term_end'', replace(''@_term_end'', ''@_'', ''@''))), ''null'')
SET @_deal_date_from = nullif(isnull(@_deal_date_from, nullif(''@deal_date_from'', replace(''@_deal_date_from'', ''@_'', ''@''))), ''null'')
SET @_deal_date_to = nullif(isnull(@_deal_date_to, nullif(''@deal_date_to'', replace(''@_deal_date_to'', ''@_'', ''@''))), ''null'')
SET @_source_counterparty_id = nullif(isnull(@_source_counterparty_id, nullif(''@source_counterparty_id'', replace(''@_source_counterparty_id'', ''@_'', ''@''))), ''null'')
SET @_source_deal_type_id = nullif(isnull(@_source_deal_type_id, nullif(''@source_deal_type_id'', replace(''@_source_deal_type_id'', ''@_'', ''@''))), ''null'')
SET @_deal_sub_type_type_id = nullif(isnull(@_deal_sub_type_type_id, nullif(''@deal_sub_type_type_id'', replace(''@_deal_sub_type_type_id'', ''@_'', ''@''))), ''null'')
SET @_physical_financial_flag = nullif(isnull(@_physical_financial_flag, nullif(''@physical_financial_flag'', replace(''@_physical_financial_flag'', ''@_'', ''@''))), ''null'')
SET @_contract_id = nullif(isnull(@_contract_id, nullif(''@contract_id'', replace(''@_contract_id'', ''@_'', ''@''))), ''null'')
SET @_trader_id = nullif(isnull(@_trader_id, nullif(''@trader_id'', replace(''@_trader_id'', ''@_'', ''@''))), ''null'')
SET @_location_id = nullif(isnull(@_location_id, nullif(''@location_id'', replace(''@_location_id'', ''@_'', ''@''))), ''null'')
SET @_block_definition_id = nullif(isnull(@_block_definition_id, nullif(''@block_definition_id'', replace(''@_block_definition_id'', ''@_'', ''@''))), ''null'')
SET @_pnl_source_value_id = nullif(isnull(@_pnl_source_value_id, nullif(''@pnl_source_value_id'', replace(''@_pnl_source_value_id'', ''@_'', ''@''))), ''null'')
SET @_confirm_status_id = nullif(isnull(@_confirm_status_id, nullif(''@confirm_status_id'', replace(''@_confirm_status_id'', ''@_'', ''@''))), ''null'')
SET @_deal_status_id = nullif(isnull(@_deal_status_id, nullif(''@deal_status_id'', replace(''@_deal_status_id'', ''@_'', ''@''))), ''null'')
SET @_deal_ref_id = nullif(isnull(@_deal_ref_id, nullif(''@deal_ref_id'', replace(''@_deal_ref_id'', ''@_'', ''@''))), ''null'')
SET @_buy_sell_flag = nullif(isnull(@_buy_sell_flag, nullif(''@buy_sell_flag'', replace(''@_buy_sell_flag'', ''@_'', ''@''))), ''null'')
SET @_period_to = nullif(isnull(@_period_to, nullif(''@period_to'', replace(''@_period_to'', ''@_'', ''@''))), ''null'')
SET @_period_from = nullif(isnull(@_period_from, nullif(''@period_from'', replace(''@_period_from'', ''@_'', ''@''))), ''null'')
SET @_commodity_id = nullif(isnull(@_commodity_id, nullif(''@commodity_id'', replace(''@_commodity_id'', ''@_'', ''@''))), ''null'')
SET @_source_deal_header_id = nullif(isnull(@_source_deal_header_id, nullif(''@source_deal_header_id'', replace(''@_source_deal_header_id'', ''@_'', ''@''))), ''null'')
SET @_deal_status_group = nullif(isnull(@_deal_status_group, nullif(''@deal_status_group'', replace(''@_deal_status_group'', ''@_'', ''@''))), ''null'')
SET @_index_id = nullif(isnull(@_index_id, nullif(''@index_id'', replace(''@_index_id'', ''@_'', ''@''))), ''null'')
SET @_from_as_of_date = isnull(@_from_as_of_date, ''1900-01-01'')
SET @_currency_id = nullif(isnull(@_currency_id, nullif(''@currency_id'', replace(''@_currency_id'', ''@_'', ''@''))), ''null'')
SET @_broker_id = nullif(isnull(@_broker_id, nullif(''@broker_id'', replace(''@_broker_id'', ''@_'', ''@''))), ''null'')
SET @_country_id = nullif(isnull(@_country_id, nullif(''@country_id'', replace(''@_country_id'', ''@_'', ''@''))), ''null'')
SET @_internal_counterparty_id = nullif(isnull(@_internal_counterparty_id, nullif(''@internal_counterparty_id'', replace(''@_internal_counterparty_id'', ''@_'', ''@''))), ''null'')
SET @_product_id = nullif(isnull(@_product_id, nullif(''@product_id'', replace(''@_product_id'', ''@_'', ''@''))), ''null'')
SET @_region_id = nullif(isnull(@_region_id, nullif(''@region_id'', replace(''@_region_id'', ''@_'', ''@''))), ''null'')
SET @_template_id = nullif(isnull(@_template_id, nullif(''@template_id'', replace(''@_template_id'', ''@_'', ''@''))), ''null'')
SET @_pricing_type_id  = nullif(isnull(@_pricing_type_id, nullif(''@pricing_type_id'', replace(''@_pricing_type_id'', ''@_'', ''@''))), ''null'')
SET @_cur_type = nullif(isnull(@_cur_type, nullif(''@cur_type'', replace(''@_cur_type'', ''@_'', ''@''))), ''null'')
--set @_term_end==isnull(@_term_start,''9999-01-01'')
IF Object_id(N''tempdb..#books'') IS NOT NULL
	DROP TABLE #books
IF Object_id(N''tempdb..#contract_fees'') IS NOT NULL
	DROP TABLE #contract_fees
IF Object_id(N''tempdb..#deal_fees'') IS NOT NULL
	DROP TABLE #deal_fees
IF Object_id(N''tempdb..#settlement_value'') IS NOT NULL
	DROP TABLE #settlement_value
IF Object_id(N''tempdb..#deal_fees_set'') IS NOT NULL
	DROP TABLE #deal_fees_set
IF Object_id(N''tempdb..#deal_fees_set_onetime'') IS NOT NULL
	DROP TABLE #deal_fees_set_onetime
SELECT @_col_sdpd_pnl = CASE @_cur_type WHEN ''d'' THEN ''und_pnl_deal'' WHEN ''i'' THEN ''und_pnl_inv'' ELSE ''und_pnl'' END
SELECT @_col_sdpd_cur = CASE @_cur_type WHEN ''d'' THEN ''deal_cur_id'' WHEN ''i'' THEN ''inv_cur_id'' ELSE ''pnl_currency_id'' END
SELECT sub.entity_id sub_id, stra.entity_id stra_id, book.entity_id book_id, sub.entity_name AS sub_name, stra.entity_name AS stra_name, book.entity_name AS book_name, ssbm.source_system_book_id1, ssbm.source_system_book_id2, ssbm.source_system_book_id3, ssbm.source_system_book_id4, ssbm.logical_name, ssbm.book_deal_type_map_id [sub_book_id], ssbm.fas_deal_type_value_id [transaction_type], sdv.code [transaction_type_name], ssbm.sub_book_group1, ssbm.sub_book_group2, ssbm.sub_book_group3, ssbm.sub_book_group4, fs.counterparty_id
INTO #books
FROM portfolio_hierarchy book(NOLOCK)
	INNER JOIN portfolio_hierarchy stra(NOLOCK) ON book.parent_entity_id = stra.entity_id
	INNER JOIN portfolio_hierarchy sub(NOLOCK) ON stra.parent_entity_id = sub.entity_id
	INNER JOIN source_system_book_map ssbm ON ssbm.fas_book_id = book.entity_id
	INNER JOIN fas_subsidiaries fs ON fs.fas_subsidiary_id = sub.entity_id
	LEFT JOIN static_data_value sdv ON sdv.[type_id] = 400 AND ssbm.fas_deal_type_value_id = sdv.value_id
WHERE 1 = 1 AND (''@sub_id'' = ''NULL'' OR sub.entity_id IN (@sub_id)) AND (''@stra_id'' = ''NULL'' OR stra.entity_id IN (@stra_id)) AND (''@book_id'' = ''NULL'' OR book.entity_id IN (@book_id)) AND (''@sub_book_id'' = ''NULL'' OR ssbm.book_deal_type_map_id IN (@sub_book_id))
IF ''@from_as_of_date'' = ''NULL'' AND ''@to_as_of_date'' <> ''NULL''
	SELECT @_from_as_of_date = Max(CONVERT(CHAR(10), sdp.pnl_as_of_date, 126))
	FROM dbo.source_deal_pnl sdp
	WHERE sdp.pnl_as_of_date <= ''@to_as_of_date''
IF ''@from_as_of_date'' = ''NULL'' AND ''@to_as_of_date'' = ''NULL''
	SELECT @_from_as_of_date = Max(CONVERT(CHAR(10), sdp.pnl_as_of_date, 126))
	FROM dbo.source_deal_pnl sdp
DECLARE @_temp_date AS VARCHAR(25) = @_from_as_of_date
IF @_to_as_of_date IS NOT NULL
	SET @_temp_date = @_to_as_of_date
IF @_period_from IS NOT NULL
	SET @_term_start = dbo.Fnagettermstartdate(''m'', @_temp_date, Isnull(@_period_from, 0))
IF @_period_to IS NOT NULL
	SET @_term_end = dbo.Fnagettermenddate(''m'', @_temp_date, @_period_to)
IF Object_id(N''tempdb..#cs_group_info'') IS NOT NULL
	DROP TABLE #cs_group_info
IF Object_id(N''tempdb..#final_values'') IS NOT NULL
	DROP TABLE #final_values
CREATE TABLE #final_values (
	sub_id INT, stra_id INT, book_id INT, subsidiary NVARCHAR(500) COLLATE DATABASE_DEFAULT NULL, strategy NVARCHAR(500) COLLATE DATABASE_DEFAULT NULL, book NVARCHAR(500) COLLATE DATABASE_DEFAULT NULL, sub_book NVARCHAR(500) COLLATE DATABASE_DEFAULT NULL, source_deal_header_id INT, deal_ref_id NVARCHAR(500) COLLATE DATABASE_DEFAULT NULL, deal_date_from DATETIME, deal_date_to DATETIME, trader_id INT, trader_name NVARCHAR(500) COLLATE DATABASE_DEFAULT NULL, counterparty_name NVARCHAR(500) COLLATE DATABASE_DEFAULT, parent_counterparty_name NVARCHAR(500) COLLATE DATABASE_DEFAULT, contract_id INT, contract_name NVARCHAR(500) COLLATE DATABASE_DEFAULT NULL, source_deal_type_id INT, deal_type_name NVARCHAR(500) COLLATE DATABASE_DEFAULT NULL, deal_sub_type_type_id INT, deal_sub_type_name NVARCHAR(500) COLLATE DATABASE_DEFAULT NULL, product_id INT, commodity_id INT, product_desc NVARCHAR(500) COLLATE DATABASE_DEFAULT NULL, block_definition NVARCHAR(500) COLLATE DATABASE_DEFAULT NULL, buy_sell_flag VARCHAR(500) COLLATE DATABASE_DEFAULT NULL, term_start DATETIME, term_end DATETIME, country_id INT, country NVARCHAR(500) COLLATE DATABASE_DEFAULT NULL, grid 
	NVARCHAR(500) COLLATE DATABASE_DEFAULT NULL, region_id INT, region NVARCHAR(500) COLLATE DATABASE_DEFAULT NULL, source_major_location_id INT, location_group VARCHAR(500) COLLATE DATABASE_DEFAULT NULL, location_id INT, location_name NVARCHAR(500) COLLATE DATABASE_DEFAULT NULL, location_description NVARCHAR(500) COLLATE DATABASE_DEFAULT NULL, from_as_of_date DATETIME, amount FLOAT, und_intrinsic_pnl FLOAT, und_extrinsic_pnl FLOAT, dis_pnl FLOAT, dis_intrinsic_pnl FLOAT, dis_extrinisic_pnl FLOAT, market_value FLOAT, contract_value FLOAT, dis_market_value FLOAT, dis_contract_value FLOAT, discount_factor FLOAT, discount_amount FLOAT, commodity VARCHAR(500) COLLATE DATABASE_DEFAULT NULL, deal_volume FLOAT, volume_uom VARCHAR(500) COLLATE DATABASE_DEFAULT NULL, template_name NVARCHAR(500) COLLATE DATABASE_DEFAULT NULL, curve_name NVARCHAR(500) COLLATE DATABASE_DEFAULT NULL, index_tou NVARCHAR(500) COLLATE DATABASE_DEFAULT NULL, currency VARCHAR(500) COLLATE DATABASE_DEFAULT NULL, formula VARCHAR(2000) COLLATE DATABASE_DEFAULT NULL, total_volume FLOAT, position_uom VARCHAR(500) COLLATE 
	DATABASE_DEFAULT NULL, cva FLOAT, dva FLOAT, market_price FLOAT, formula_price FLOAT, net_price FLOAT, physical_financial_flag VARCHAR(10) COLLATE DATABASE_DEFAULT NULL, block_definition_id INT, leg INT, source_counterparty_id INT, counterparty_id NVARCHAR(500) COLLATE DATABASE_DEFAULT, index_id INT, credit_adjusted_mtm FLOAT, discounted_credit_adjusted_mtm FLOAT, term_start_day INT, term_start_month VARCHAR(500) COLLATE DATABASE_DEFAULT NULL, term_start_month_name VARCHAR(500) COLLATE DATABASE_DEFAULT, term_start_year INT, term_start_year_month VARCHAR(500) COLLATE DATABASE_DEFAULT NULL, term_quarter VARCHAR(500) COLLATE DATABASE_DEFAULT NULL, to_as_of_date DATETIME, sub_book_id INT, transaction_type INT, transaction_type_name VARCHAR(500) COLLATE DATABASE_DEFAULT NULL, period_from VARCHAR(500) COLLATE DATABASE_DEFAULT NULL, period_to VARCHAR(500) COLLATE DATABASE_DEFAULT NULL, probability FLOAT, credit_reserve FLOAT, dis_credit_reserve FLOAT, fair_value FLOAT, dis_fair_value FLOAT, model_reserve INT, actual_forward CHAR(1) COLLATE DATABASE_DEFAULT NULL, pnl_conversion_factor FLOAT, pnl_adjustment_value FLOAT, 
	internal_deal_type_id INT, internal_deal_type VARCHAR(500) COLLATE DATABASE_DEFAULT NULL, internal_deal_sub_type_id INT, internal_deal_sub_type VARCHAR(500) COLLATE DATABASE_DEFAULT NULL, fixed_cost FLOAT, fixed_price FLOAT, formula_value FLOAT, price_adder FLOAT, price_multiplier FLOAT, strike_price FLOAT, und_pnl_set FLOAT, formula_curve_id INT, formula_curve_name NVARCHAR(500) COLLATE DATABASE_DEFAULT NULL, internal_desk_id INT, internal_desk NVARCHAR(500) COLLATE DATABASE_DEFAULT NULL, internal_portfolio_id INT, internal_portfolio NVARCHAR(500) COLLATE DATABASE_DEFAULT NULL, broker_id INT, broker_name NVARCHAR(500) COLLATE DATABASE_DEFAULT, type_of_entity_id INT, type_of_entity NVARCHAR(500) COLLATE DATABASE_DEFAULT NULL, int_ext_flag_id CHAR, int_ext_flag VARCHAR(500) COLLATE DATABASE_DEFAULT NULL, deal_status_id INT, deal_status NVARCHAR(500) COLLATE DATABASE_DEFAULT NULL, confirm_status_id INT, confirm_status NVARCHAR(500) COLLATE DATABASE_DEFAULT NULL, pnl_source_value_id INT, pnl_source_name NVARCHAR(500) COLLATE DATABASE_DEFAULT NULL, description1 NVARCHAR(500) COLLATE DATABASE_DEFAULT NULL, 
	description2 NVARCHAR(500) COLLATE DATABASE_DEFAULT NULL, description3 NVARCHAR(500) COLLATE DATABASE_DEFAULT NULL, description4 NVARCHAR(500) COLLATE DATABASE_DEFAULT NULL, counterparty_id2 INT, counterparty_name2 NVARCHAR(500) COLLATE DATABASE_DEFAULT, ext_deal_id NVARCHAR(500) COLLATE DATABASE_DEFAULT NULL, reference NVARCHAR(500) COLLATE DATABASE_DEFAULT NULL, create_by NVARCHAR(500) COLLATE DATABASE_DEFAULT NULL, create_ts DATETIME, update_by NVARCHAR(500) COLLATE DATABASE_DEFAULT NULL, update_ts DATETIME, broker_fixed_cost NUMERIC, confirm_date DATETIME, sub_book_group1_id INT, sub_book_group2_id INT, sub_book_group3_id INT, sub_book_group4_id INT, sub_book_group1 NVARCHAR(500) COLLATE DATABASE_DEFAULT NULL, sub_book_group2 NVARCHAR(500) COLLATE DATABASE_DEFAULT NULL, sub_book_group3 NVARCHAR(500) COLLATE DATABASE_DEFAULT NULL, sub_book_group4 NVARCHAR(500) COLLATE DATABASE_DEFAULT NULL, book_identifier1_id INT, book_identifier2_id INT, book_identifier3_id INT, book_identifier4_id INT, book_identifier1 NVARCHAR(500) COLLATE DATABASE_DEFAULT NULL, book_identifier2 NVARCHAR(500) COLLATE DATABASE_DEFAULT 
	NULL, book_identifier3 NVARCHAR(500) COLLATE DATABASE_DEFAULT NULL, book_identifier4 NVARCHAR(500) COLLATE DATABASE_DEFAULT NULL, deal_price FLOAT, float_price FLOAT, volume FLOAT, close_reference_id INT, charge_type_id INT, charge_type VARCHAR(500) COLLATE DATABASE_DEFAULT NULL, agg_term VARCHAR(500) COLLATE DATABASE_DEFAULT NULL, recovery_rate FLOAT, fv_level NVARCHAR(500) COLLATE DATABASE_DEFAULT NULL, current_non_current VARCHAR(500) COLLATE DATABASE_DEFAULT NULL, deal_category_id INT, deal_category NVARCHAR(500) COLLATE DATABASE_DEFAULT NULL, internal_counterparty_id INT, internal_couterparty NVARCHAR(500) COLLATE DATABASE_DEFAULT NULL, template_id INT, volume_profile NVARCHAR(500) COLLATE DATABASE_DEFAULT NULL, price_adder2 FLOAT, volume_multiplier FLOAT, volume_multiplier2 FLOAT, debt_rating NVARCHAR(500) COLLATE DATABASE_DEFAULT NULL, volume_frequency VARCHAR(500) COLLATE DATABASE_DEFAULT NULL, currency_id INT, is_expired VARCHAR(10) COLLATE DATABASE_DEFAULT NULL, entire_term_start DATETIME, entire_term_end DATETIME, contract_exipration_date DATETIME, structured_id 
	NVARCHAR(500) COLLATE DATABASE_DEFAULT NULL, payment_date DATETIME, pricing_type_id VARCHAR(500) COLLATE DATABASE_DEFAULT NULL, must_run_volume FLOAT, dispatch_volume FLOAT, must_run_market_value FLOAT, must_run_contract_value FLOAT, dispatch_market_value FLOAT, dispatch_contract_value FLOAT, cash_flow FLOAT, pnl_date DATETIME, pricing_type  NVARCHAR(500) COLLATE DATABASE_DEFAULT NULL,source_deal_detail_id int
	,invoice_currency VARCHAR(50) COLLATE DATABASE_DEFAULT, 
	deal_currency VARCHAR(50) COLLATE DATABASE_DEFAULT, 
	amount_inv FLOAT, 
	amount_deal FLOAT,
	[reporting_group1] INT,
	[reporting_group2] INT,
	[reporting_group3] INT,
	[reporting_group4] INT,
	[reporting_group5] INT,
	[reporting_group1_name] VARCHAR(1000),
	[reporting_group2_name] VARCHAR(1000),
	[reporting_group3_name] VARCHAR(1000),
	[reporting_group4_name] VARCHAR(1000),
	[reporting_group5_name] VARCHAR(1000)
	)
SET @_sql_select1 = 
	''INSERT INTO #final_values
	SELECT books.sub_id sub_id,
	books.stra_id stra_id,
	books.book_id book_id,
	books.sub_name AS subsidiary,
	books.stra_name AS strategy,
	books.book_name AS book,
	books.logical_name [sub_book],
	sdh.source_deal_header_id,
	sdh.deal_id deal_ref_id,
	sdh.deal_date deal_date_from,
	sdh.deal_date deal_date_to,
	st.source_trader_id [trader_id],
	st.trader_name,
	sc.counterparty_name,
	psc.counterparty_name parent_counterparty_name,
	cg.contract_id,
	cg.contract_name AS contract_name,
	sdh.source_deal_type_id,
	sdt.source_deal_type_name AS deal_type_name,
	sdh.deal_sub_type_type_id,
	sdts.source_deal_type_name AS deal_sub_type_name,
	sdh.product_id,
	sc2.source_commodity_id commodity_id,
	sprod.code product_desc,
	sdv_block_def.code AS block_definition,
	(CASE WHEN sdh.header_buy_sell_flag = ''''b'''' THEN ''''Buy'''' ELSE ''''Sell'''' END ) AS buy_sell_flag,
	sdd.term_start,
	sdd.term_end,
	sdv_cnty.value_id country_id,
	sdv_cnty.code AS country,
	sdv_grid.code AS grid,
	sdv_region.value_id region_id,
	sdv_region.code AS region,
	smjl.source_major_location_ID,
	smjl.location_name AS location_group,
	sml.source_minor_location_id [location_id],
	sml.location_name,
	sml.location_description,
	sdpd.pnl_as_of_date from_as_of_date,
	CAST(sdpd.und_pnl AS FLOAT) amount, -- 	CAST('' + @_col_sdpd_pnl + '' AS FLOAT) amount,
	CAST(ISNULL(sdpd.und_intrinsic_pnl,0) AS FLOAT) und_intrinsic_pnl,
	CAST(ISNULL(sdpd.und_extrinsic_pnl,0) AS FLOAT) und_extrinsic_pnl,
	CAST(ISNULL(sdpd.dis_pnl,0) AS FLOAT) dis_pnl,
	CAST(ISNULL(sdpd.dis_intrinsic_pnl,0) AS FLOAT) dis_intrinsic_pnl,
	CAST(ISNULL(sdpd.dis_extrinisic_pnl,0) AS FLOAT) dis_extrinisic_pnl,
	CAST(COALESCE(sdpd.market_value,0) AS FLOAT) market_value,
	CAST(COALESCE(sdpd.contract_value,0) AS FLOAT) contract_value,
	CAST(ISNULL(sdpd.dis_market_value,0) AS FLOAT) dis_market_value,
	CAST(ISNULL(sdpd.dis_contract_value,0) AS FLOAT) dis_contract_value,
	CAST(ISNULL(sdpd.discount_factor,0) AS FLOAT) discount_factor,
	ISNULL('' + @_col_sdpd_pnl + '', 0) - ISNULL(sdpd.dis_pnl, 0) [discount_amount],
	sc2.commodity_name AS commodity,
	CASE WHEN sdd.buy_sell_flag = ''''s'''' THEN sdd.deal_volume * (-1) ELSE sdd.deal_volume END [deal_volume],
	su.uom_name AS volume_uom,
	sdht.template_name AS [template_name],
	spcd.curve_name[curve_name],
	sdv_peakness.code [index_tou],
	scur.currency_name currency,
	fe.formula [formula],
	sdpd.deal_volume [total_volume],
	puom.uom_name AS [position_uom],
	CAST(ISNULL(sdc.cva,0) AS FLOAT) [CVA],CAST(ISNULL(sdc.dva,0) AS FLOAT) [DVA],
	CAST(COALESCE(sdpd.curve_value,0) AS FLOAT) [market_price], sdpd.formula_value [formula_price],
	CAST(COALESCE(sdpd.price,0) AS FLOAT) * CASE WHEN sdd.buy_sell_flag = ''''s'''' THEN -1 ELSE 1 END [net_price],
	CASE WHEN sdd.physical_financial_flag = ''''p'''' THEN ''''Physical'''' ELSE ''''Financial'''' END [physical_financial_flag],
	sdh.block_define_id block_definition_id,
	sdd.Leg [leg],
	sc.source_counterparty_id [source_counterparty_id],
	sc.counterparty_id [counterparty_id],
	spcd.source_curve_def_id [index_id],
	ISNULL('' + @_col_sdpd_pnl + '',0) - (ISNULL('' + @_col_sdpd_pnl + '',0)* ISNULL(dp.probability, 0) * (1 - ISNULL(drr.rate, 0))) [credit_adjusted_mtm],
	ISNULL(sdpd.dis_pnl,0) - (ISNULL(sdpd.dis_pnl,0)* ISNULL(dp.probability, 0) * (1 - ISNULL(drr.rate, 0))) [discounted_credit_adjusted_mtm],
	DAY(sdd.term_start) [term_start_day],
	RIGHT(''''0''''+ CAST(MONTH(sdd.term_start) AS VARCHAR(2)), 2) [term_start_month],
	DATENAME(m,sdd.term_start) [term_start_month_name],
	YEAR(sdd.term_start) [term_start_year],
	CAST(YEAR(sdd.term_start) AS VARCHAR(5)) + ''''-'''' + RIGHT(''''0''''+ CAST(MONTH(sdd.term_start) AS VARCHAR(2)), 2) [term_start_year_month],
	''''Q'''' + CAST(DATEPART(q,sdd.term_start) AS VARCHAR) [term_quarter],
	sdpd.pnl_as_of_date to_as_of_date,
	books.[sub_book_id], books.[transaction_type],
	books.[transaction_type_name],
	''''@_period_from'''' [period_from],
	''''@_period_to'''' [period_to],
	ISNULL(dp.probability, 0) [probability], ISNULL('' + @_col_sdpd_pnl + '', 0) * ISNULL(dp.probability, 0) * (1 - ISNULL(drr.rate, 0)) [credit_reserve],
	ISNULL(sdpd.dis_pnl, 0)* ISNULL(dp.probability, 0) * (1 - ISNULL(drr.rate, 0)) [dis_credit_reserve],
	'' + @_col_sdpd_pnl + '' - (ISNULL('' + @_col_sdpd_pnl + '', 0)* ISNULL(dp.probability, 0) * (1 - ISNULL(drr.rate, 0))) [fair_value], sdpd.dis_pnl - (ISNULL(sdpd.dis_pnl, 0)* ISNULL(dp.probability, 0) * (1 - ISNULL(drr.rate, 0))) [dis_fair_value],
	0 [model_reserve],
	case when sdpd.source_deal_header_id is null then ''''a'''' else ''''f'''' end AS actual_forward,
	sdpd.pnl_conversion_factor,
	sdpd.pnl_adjustment_value,
	sdpd.internal_deal_type_value_id internal_deal_type_id,
	idtst.internal_deal_type_subtype_type internal_deal_type,
	sdpd.internal_deal_subtype_value_id internal_deal_sub_type_id,
	idtst1.internal_deal_type_subtype_type internal_deal_sub_type,
	ISNULL(sdpd.fixed_cost, 0) fixed_cost,
	CAST(COALESCE(sdpd.fixed_price,sdd.fixed_price, 0) AS FLOAT) fixed_price,
	sdpd.formula_value,
	COALESCE(sdpd.price_adder, sdd.price_adder, 0) price_adder, ISNULL(sdpd.price_multiplier, 1) price_multiplier, sdpd.strike_price, sdpd.und_pnl_set,
	sdd.formula_curve_id,
	formula_curve.curve_name formula_curve_name,
	sdh.internal_desk_id,
	idesk.code internal_desk,
	sdh.internal_portfolio_id,
	iport.code internal_portfolio,
	sdh.broker_id,
	sbro.counterparty_name broker_name,
	sc.type_of_entity type_of_entity_id,
	ient.code type_of_entity,
	sc.int_ext_flag int_ext_flag_id,
	CASE sc.int_ext_flag WHEN ''''b'''' THEN ''''Broker''''
	WHEN ''''c'''' THEN ''''Clearing''''
	WHEN ''''e'''' THEN ''''External''''
	WHEN ''''i'''' THEN ''''Internal''''
	ELSE '''''''' END int_ext_flag,
	sdh.deal_status deal_status_id,
	ds.code deal_status,
	sdh.confirm_status_type confirm_status_id,
	cst.code confirm_status,
	sdpd.pnl_source_value_id,
	pnl_sour.code pnl_source_name,
	sdh.description1,
	sdh.description2,
	sdh.description3,
	sdh.description4,
	sdh.counterparty_id2,
	sid2.counterparty_name counterparty_name2,
	sdh.ext_deal_id, sdh.reference,
	sdh.create_user [create_by],
	sdh.create_ts,
	sdh.update_user [update_by],
	sdh.update_ts,
	sdh.broker_fixed_cost,
	cs.as_of_date [confirm_date],
	books.sub_book_group1 sub_book_group1_id,
	books.sub_book_group2 sub_book_group2_id,
	books.sub_book_group3 sub_book_group3_id,
	books.sub_book_group4 sub_book_group4_id,
	sdv_sbg1.code sub_book_group1,
	sdv_sbg2.code sub_book_group2,
	sdv_sbg3.code sub_book_group3,
	sdv_sbg4.code sub_book_group4,
	sb1.source_book_id book_identifier1_id,
	sb2.source_book_id book_identifier2_id,
	sb3.source_book_id book_identifier3_id,
	sb4.source_book_id book_identifier4_id,
	sb1.source_book_name book_identifier1,
	sb2.source_book_name book_identifier2,
	sb3.source_book_name book_identifier3,
	sb4.source_book_name book_identifier4,
	CASE WHEN sdpd.deal_volume = 0 THEN sdpd.contract_value ELSE abs(sdpd.contract_value / ISNULL(sdpd.deal_volume, 1)) END deal_price,
	0 float_price,
	sdpd.deal_volume Volume,
''
SET @_sql_select2 = '' sdh.close_reference_id,
	-5500 AS [charge_type_id],
	''''Commodity'''' AS [charge_type],
	ag_t.agg_term,
	ISNULL(drr.rate, 0) recovery_rate,
	COALESCE(deal_level.code, curve_level.code,''''Level 3'''') fv_level,
	CASE WHEN ((DATEPART(year, sdd.term_start) - DATEPART(year, '''''' + Cast(@_from_as_of_date AS VARCHAR(100)) + '''''')) * 12 + (DATEPART(month, sdd.term_start) - DATEPART(month, '''''' + Cast(@_from_as_of_date AS VARCHAR(100)) + 
		''''''))) > 12 THEN ''''Non-Current'''' ELSE ''''Current''''
	END [current_non_current],
	sdh.deal_category_value_id deal_category_id,
	sdv_dc.code deal_category,
	books.counterparty_id internal_counterparty_id,
	cpt_i.counterparty_name internal_counterparty,
	sdh.template_id ,
	sdv_p.code volume_profile,
	sdpd.price_adder2,
	sdpd.volume_multiplier,
	sdpd.volume_multiplier2,
	sdv_d.code debt_rating,
	CASE WHEN sdd.deal_volume_frequency = ''''h'''' THEN ''''Hourly''''
	WHEN sdd.deal_volume_frequency = ''''d'''' THEN ''''Daily''''
	WHEN sdd.deal_volume_frequency = ''''m'''' THEN ''''Monthly''''
	WHEN sdd.deal_volume_frequency = ''''t'''' THEN ''''Term''''
	WHEN sdd.deal_volume_frequency = ''''a'''' THEN ''''Annually''''
	WHEN sdd.deal_volume_frequency = ''''x'''' THEN ''''15 Minutes''''
	WHEN sdd.deal_volume_frequency = ''''y'''' THEN ''''30 Minutes''''
	END [volume_frequency],
	scur.source_currency_id currency_id,
	CASE WHEN sdd.contract_expiration_date < '''''' + Cast(@_from_as_of_date AS VARCHAR(100)) + 
		'''''' THEN ''''Yes'''' ELSE ''''No'''' END is_expired,
	sdh.entire_term_start,
	sdh.entire_term_end,
	sdd.contract_expiration_date,
	sdh.structured_deal_id,
	COALESCE(dbo.FNAInvoiceDueDate(sdd.term_start, ISNULL(cca.invoice_due_date,cg.invoice_due_date), cg.holiday_calendar_id,ISNULL(cca.payment_days,cg.payment_days)),sdd.term_end) [payment_date],
	sdh.pricing_type [pricing_type_id],
	sdpd.must_run_volume,
	sdpd.dispatch_volume,
	sdpd.must_run_market_value,
	sdpd.must_run_contract_value,
	sdpd.dispatch_market_value,
	sdpd.dispatch_contract_value,
	CAST(sdpd.und_pnl_set AS FLOAT) cash_flow,
	COALESCE(dbo.FNAInvoiceDueDate(sdd.term_start, cg.pnl_date, cg.holiday_calendar_id,10),sdd.term_end) [pnl_date],
	sdv_pr.code [pricing_type],sdd.source_deal_detail_id,
   scur_ic.currency_id invoice_currency, 
   scur_dc.currency_id deal_currency,
   sdpd.und_pnl_inv  amount_inv,
   sdpd.und_pnl_deal amount_deal,
   sdh.[reporting_group1],
   sdh.[reporting_group2],
   sdh.[reporting_group3],
   sdh.[reporting_group4],
   sdh.[reporting_group5],
   reporting_group1.code [reporting_group1_name],
   reporting_group2.code [reporting_group2_name],
   reporting_group3.code [reporting_group3_name],
   reporting_group4.code [reporting_group4_name],
   reporting_group5.code [reporting_group5_name]
''
SET @_sql_from1 = ''
	FROM source_deal_header sdh '' + CASE WHEN @_deal_status_group = ''o'' THEN '' INNER JOIN deal_status_group dsg ON dsg.status_value_id = sdh.deal_status '' WHEN @_deal_status_group = ''u'' THEN '' INNER JOIN (SELECT value_id FROM static_data_value WHERE type_id = 5600 EXCEPT SELECT status_value_id FROM deal_status_group) unofficial_status ON unofficial_status.value_id = sdh.deal_status '' ELSE '''' END + ''
	INNER JOIN source_deal_detail sdd ON sdh.source_deal_header_id = sdd.source_deal_header_id
	LEFT JOIN source_deal_pnl_detail sdpd ON sdpd.source_deal_header_id = sdh.source_deal_header_id
		AND '' + CASE WHEN @_to_as_of_date IS NULL THEN ''sdpd.pnl_as_of_date = CAST('''''' + @_from_as_of_date + '''''' AS DATETIME)'' ELSE ''sdpd.pnl_as_of_date BETWEEN CAST('''''' + @_from_as_of_date + '''''' AS DATETIME) AND CAST('''''' + @_to_as_of_date + '''''' AS DATETIME) '' END + CASE WHEN @_term_start IS NULL AND @_term_end IS NULL THEN '''' WHEN @_term_end IS NULL THEN '' AND sdpd.term_start >= CAST('''''' + Cast(@_term_start AS VARCHAR(100)) + '''''' AS DATETIME)'' WHEN @_term_start IS NULL 
					THEN '' AND sdpd.term_start <= CAST('''''' + Cast(@_term_end AS VARCHAR(100)) + '''''' AS DATETIME)'' ELSE '' AND sdpd.term_start BETWEEN CAST('''''' + Cast(@_term_start AS VARCHAR(100)) + '''''' as DATETIME)
		AND CAST('''''' + Cast(@_term_end AS VARCHAR(100)) + '''''' as DATETIME)'' END + 
			'' AND sdd.term_start =sdpd.term_start
		AND sdd.term_end =sdpd.term_end
		AND sdpd.Leg = sdd.leg
	LEFT JOIN source_currency scur_ic ON scur_ic.source_currency_id = sdpd.inv_cur_id
	LEFT JOIN source_currency scur_dc ON scur_dc.source_currency_id = sdpd.deal_cur_id
	INNER JOIN #books books ON books.source_system_book_id1 = sdh.source_system_book_id1 AND
	books.source_system_book_id2 = sdh.source_system_book_id2 AND
	books.source_system_book_id3 = sdh.source_system_book_id3 AND
	books.source_system_book_id4 = sdh.source_system_book_id4
	INNER JOIN source_book sb1 ON sb1.source_book_id = books.source_system_book_id1
	INNER JOIN source_book sb2 ON sb2.source_book_id = books.source_system_book_id2
	INNER JOIN source_book sb3 ON sb3.source_book_id = books.source_system_book_id3
	INNER JOIN source_book sb4 ON sb4.source_book_id = books.source_system_book_id4
	LEFT JOIN static_data_value ds ON ds.value_id = sdh.deal_status
	LEFT JOIN static_data_value cst ON cst.value_id = sdh.confirm_status_type
	LEFT JOIN source_traders st ON st.source_trader_id = sdh.trader_id
	LEFT JOIN source_counterparty AS sc ON sc.source_counterparty_id = sdh.counterparty_id
	LEFT JOIN source_counterparty AS psc ON psc.source_counterparty_id = sc.parent_counterparty_id
	LEFT JOIN source_counterparty AS sid2 ON sid2.source_counterparty_id = sdh.counterparty_id2
	LEFT JOIN static_data_value AS sdv_block_def ON sdv_block_def.value_id = sdh.block_define_id
	LEFT JOIN source_deal_type AS sdt ON sdt.source_deal_type_id = sdh.source_deal_type_id
	LEFT JOIN source_deal_type AS sdts ON sdts.source_deal_type_id = sdh.deal_sub_type_type_id
	LEFT JOIN static_data_value sprod ON sprod.value_id = sdh.product_id
	LEFT JOIN source_price_curve_def AS spcd ON spcd.source_curve_def_id = sdd.curve_id
	LEFT JOIN source_price_curve_def AS formula_curve ON formula_curve.source_curve_def_id = sdd.formula_curve_id
	LEFT JOIN internal_deal_type_subtype_types idtst ON idtst.internal_deal_type_subtype_id = sdpd.internal_deal_type_value_id
	LEFT JOIN internal_deal_type_subtype_types idtst1 ON idtst1.internal_deal_type_subtype_id = sdpd.internal_deal_subtype_value_id
	LEFT JOIN source_uom AS su ON su.source_uom_id = sdd.deal_volume_uom_id
	LEFT JOIN source_minor_location sml ON sml.source_minor_location_id = sdd.location_id
	LEFT JOIN source_major_location smjl ON smjl.source_major_location_ID = sml.source_major_location_ID
	LEFT JOIN contract_group cg ON cg.contract_id = sdh.contract_id
	LEFT JOIN static_data_value sdv_cnty ON sdv_cnty.value_id = sml.country
	LEFT JOIN static_data_value sdv_grid ON sdv_grid.value_id = sml.grid_value_id
	LEFT JOIN static_data_value sdv_region ON sdv_region.value_id = sml.region
	LEFT JOIN static_data_value sdv_ctgy ON sdv_ctgy.value_id = sdh.deal_category_value_id
	LEFT JOIN static_data_value sdv_peakness ON sdv_peakness.value_id = spcd.curve_tou
	LEFT JOIN static_data_value idesk ON idesk.value_id = sdh.internal_desk_id
	LEFT JOIN static_data_value iport ON iport.value_id = sdh.internal_portfolio_id
	LEFT JOIN source_counterparty sbro ON sbro.source_counterparty_id = sdh.broker_id AND sbro.int_ext_flag=''''b''''
	LEFT JOIN static_data_value ient ON ient.value_id = sc.type_of_entity
	LEFT JOIN static_data_value pnl_sour on pnl_sour.value_id = sdpd.pnl_source_value_id
	LEFT JOIN source_deal_header_template sdht ON sdh.template_id = sdht.template_id
	LEFT JOIN source_commodity sc2 ON sc2.source_commodity_id = COALESCE(sdd.detail_commodity_id, spcd.commodity_id, sdh.commodity_id)
	LEFT JOIN source_uom puom ON puom.source_uom_id = ISNULL(spcd.display_uom_id, spcd.uom_id)
	LEFT JOIN counterparty_credit_info cci ON cci.counterparty_id = sdh.counterparty_id
	LEFT JOIN counterparty_contract_address cca On cca.counterparty_id = sdh.counterparty_id AND cca.contract_id = cg.contract_id OUTER APPLY( SELECT probability FROM default_probability
	WHERE id IN (SELECT MAX(id) FROM default_probability WHERE effective_date <= '''''' 
		+ Cast(@_from_as_of_date AS VARCHAR(100)) + '''''' AND debt_rating = cci.Risk_rating
	)
	) dp
	OUTER APPLY (
		SELECT rate FROM default_recovery_rate
		WHERE id IN (SELECT MAX(id) FROM default_recovery_rate
		WHERE effective_date <= '''''' + Cast(@_from_as_of_date AS VARCHAR(100)) + '''''' AND debt_rating = cci.Risk_rating
	)
	) drr
	OUTER APPLY (
		SELECT cva CVA, dva DVA FROM source_deal_cva sdc
		WHERE sdc.Source_Counterparty_ID = sdh.counterparty_id
			AND sdc.source_deal_header_id = sdpd.source_deal_header_id
			AND sdc.as_of_date = sdpd.pnl_as_of_date
			AND sdc.term_start = sdd.term_start
	) sdc
	LEFT JOIN formula_editor fe ON fe.formula_id = sdd.formula_id
	OUTER APPLY (
		SELECT TOP(1) * FROM confirm_status cs
		WHERE cs.source_deal_header_id = sdh.source_deal_header_id
		ORDER BY cs.confirm_status_id
) cs ''
SET @_sql_from3 = ''
	LEFT JOIN source_deal_header sdh_close_ref_id ON sdh_close_ref_id.source_deal_header_id = sdh.close_reference_id
	LEFT JOIN static_data_value sdv_sbg1 ON sdv_sbg1.value_id = books.sub_book_group1
	LEFT JOIN static_data_value sdv_sbg2 ON sdv_sbg2.value_id = books.sub_book_group2
	LEFT JOIN static_data_value sdv_sbg3 ON sdv_sbg3.value_id = books.sub_book_group3
	LEFT JOIN static_data_value sdv_sbg4 ON sdv_sbg4.value_id = books.sub_book_group4
	OUTER APPLY(
	SELECT TOP 1 CASE WHEN MONTH(sdd.term_start)< MONTH('''''' + @_from_as_of_date + '''''')
	AND YEAR(sdd.term_start)<= YEAR('''''' + @_from_as_of_date + '''''') THEN '''' '''' + CAST(YEAR
	(sdd.term_start) AS VARCHAR) + ''''-YTD''''
	WHEN MONTH(sdd.term_start)=MONTH('''''' + @_from_as_of_date + '''''')
	AND YEAR(sdd.term_start)=YEAR('''''' + @_from_as_of_date + '''''')
	THEN CAST(YEAR(sdd.term_start) AS VARCHAR) + '''' - Current''''
	WHEN DATEPART(q,'''''' + @_from_as_of_date + '''''') = DATEPART(q,sdd.term_start)
	AND YEAR('''''' + @_from_as_of_date + 
		'''''') = YEAR(sdd.term_start) THEN convert(varchar(4),sdd.term_start,120) +''''-''''+ ''''M'''' + CAST(DATEDIFF(m,'''''' + @_from_as_of_date + '''''',sdd.term_start) AS VARCHAR) +'''' ''''+ ''''('''' + UPPER(LEFT(DATENAME(MONTH,dateadd(MONTH, MONTH(sdd.term_start),-1)),3)) + '''')'''' WHEN YEAR('''''' + @_from_as_of_date + '''''') = YEAR(sdd.term_start) THEN convert(varchar(4),sdd.term_start,120) + ''''-''''+ ''''Q'''' + CAST(DATEPART(q,sdd.term_start) AS VARCHAR)
	ELSE CAST(YEAR(sdd.term_start) AS VARCHAR)
	END agg_term
	FROM portfolio_mapping_tenor
) ag_t ''
SET @_sql_from4 = 
	''
	OUTER APPLY ( SELECT MAX(effective_date) effective_date FROM fv_report_group_deal
	WHERE source_deal_header_id = sdpd.source_deal_header_id AND
	sdpd.term_start = term_start AND
	effective_date <= sdpd.Pnl_as_of_date
	) fv_d_mx
	OUTER APPLY ( SELECT fv_level_value_id ,MAX(effective_date) effective_date FROM fv_report_group_deal
	WHERE source_deal_header_id = sdpd.source_deal_header_id AND
	sdpd.term_start = term_start AND
	effective_date = fv_d_mx.effective_date
	GROUP BY fv_level_value_id
	) frgd
	LEFT JOIN static_data_value deal_level ON deal_level.value_id = frgd.fv_level_value_id
	OUTER APPLY( SELECT MAX(effective_date) effective_date FROM price_curve_fv_mapping
	WHERE source_curve_def_id = sdpd.curve_id AND sdpd.term_start
	BETWEEN DATEADD(MM, from_no_of_months, effective_date) AND DATEADD(MM, to_no_of_months, effective_date)
	AND effective_date <= sdpd.Pnl_as_of_date
	) P_fv_mx
	OUTER APPLY ( SELECT fv_reporting_group_id ,MAX(effective_date) effective_date FROM price_curve_fv_mapping
	WHERE source_curve_def_id = sdpd.curve_id AND
	sdpd.term_start BETWEEN DATEADD(MM, from_no_of_months, effective_date)
	AND DATEADD(MM, to_no_of_months, effective_date) AND effective_date= P_fv_mx.effective_date
	GROUP BY fv_reporting_group_id
	) pcfm1
	LEFT JOIN source_currency scur ON scur.source_currency_id = '' + @_col_sdpd_cur + ''
	LEFT JOIN static_data_value curve_level ON curve_level.value_id = pcfm1.fv_reporting_group_id
	LEFT JOIN static_data_value sdv_dc ON sdv_dc.value_id = sdh.deal_category_value_id LEFT JOIN static_data_value sdv_p ON sdv_p.value_id = sdh.internal_desk_id LEFT JOIN source_counterparty cpt_i ON cpt_i.source_counterparty_id = books.counterparty_id LEFT JOIN static_data_value sdv_d ON sdv_d.value_id=cci.Risk_rating
	LEFT JOIN static_data_value sdv_pr ON sdv_pr.value_id = sdh.pricing_type
	LEFT JOIN static_data_value reporting_group1 ON reporting_group1.value_id = sdh.[reporting_group1] AND reporting_group1.type_id = 113000
	LEFT JOIN static_data_value reporting_group2 ON reporting_group2.value_id = sdh.[reporting_group2] AND reporting_group2.type_id = 113100
	LEFT JOIN static_data_value reporting_group3 ON reporting_group3.value_id = sdh.[reporting_group3] AND reporting_group3.type_id = 113200
	LEFT JOIN static_data_value reporting_group4 ON reporting_group4.value_id = sdh.[reporting_group4] AND reporting_group4.type_id = 113300
	LEFT JOIN static_data_value reporting_group5 ON reporting_group5.value_id = sdh.[reporting_group5] AND reporting_group5.type_id = 113400
	''
SET @_sql_whr = '' WHERE 1 = 1 '' + CASE WHEN @_deal_date_from IS NULL AND @_deal_date_to IS NULL THEN '''' WHEN @_deal_date_to IS NULL THEN '' AND sdh.deal_date = CAST('''''' + @_deal_date_from + '''''' AS DATETIME)'' WHEN @_deal_date_from IS NULL THEN '' AND sdh.deal_date <= CAST('''''' + @_deal_date_to + '''''' AS DATETIME)'' ELSE '' AND sdh.deal_date BETWEEN CAST('''''' + @_deal_date_from + '''''' AS DATETIME) AND CAST('''''' + @_deal_date_to + '''''' AS DATETIME)'' END + CASE WHEN @_source_counterparty_id IS NULL THEN '''' ELSE '' AND sdh.counterparty_id IN ('' + @_source_counterparty_id + '')'' END + CASE WHEN @_source_deal_type_id IS NULL THEN '''' ELSE '' AND sdh.source_deal_type_id IN ('' + @_source_deal_type_id + '')'' END + CASE WHEN @_deal_sub_type_type_id IS NULL THEN '''' ELSE '' AND sdh.deal_sub_type_type_id IN ('' + @_deal_sub_type_type_id + '')'' END + CASE WHEN @_physical_financial_flag IS NULL THEN '''' ELSE '' AND sdd.physical_financial_flag = '''''' + @_physical_financial_flag + '''''''' END + CASE WHEN @_contract_id IS NULL THEN '''' ELSE '' AND sdh.contract_id IN ('' + @_contract_id + '')'' END + CASE WHEN @_trader_id IS NULL THEN '''' ELSE 
			'' AND sdh.trader_id IN ('' + @_trader_id + '')'' END + CASE WHEN @_block_definition_id IS NULL THEN '''' ELSE '' AND sdh.block_define_id IN ('' + @_block_definition_id + '')'' END + CASE WHEN @_location_id IS NULL THEN '''' ELSE '' AND sdd.location_id IN ('' + @_location_id + '')'' END + CASE WHEN @_index_id IS NULL THEN '''' ELSE '' AND sdd.curve_id IN ('' + @_index_id + '')'' END + CASE WHEN @_source_deal_header_id IS NULL THEN '''' ELSE '' AND sdh.source_deal_header_id IN ('' + @_source_deal_header_id + '')'' END + CASE WHEN @_commodity_id IS NULL THEN '''' ELSE '' AND sdh.commodity_id IN ('' + @_commodity_id + '')'' END + CASE WHEN @_buy_sell_flag IS NULL THEN '''' ELSE '' AND sdh.header_buy_sell_flag = '''''' + @_buy_sell_flag + '''''''' END + CASE WHEN @_deal_ref_id IS NULL THEN '''' ELSE '' AND sdh.deal_id = '''''' + @_deal_ref_id + '''''''' END + CASE WHEN @_deal_status_id IS NULL THEN '''' ELSE '' AND sdh.deal_status IN ('' + @_deal_status_id + '')'' END + CASE WHEN @_confirm_status_id IS NULL THEN '''' ELSE '' AND sdh.confirm_status_type IN ('' + @_confirm_status_id + '')'' END + CASE WHEN @_pnl_source_value_id IS NULL THEN '''' ELSE '' AND (sdpd.pnl_source_value_id IN ('' + 
			@_pnl_source_value_id + '')'' + '' OR sdpd.pnl_source_value_id IS NULL) '' END + CASE WHEN @_term_start IS NULL THEN '''' ELSE '' AND sdd.term_start>='''''' + CONVERT(VARCHAR(10), @_term_start, 120) + '''''''' END + CASE WHEN @_term_end IS NULL THEN '''' ELSE '' AND sdd.term_end<='''''' + CONVERT(VARCHAR(10), @_term_end, 120) + '''''''' END
			+ CASE WHEN @_currency_id IS NULL THEN '''' ELSE '' AND sdpd.pnl_currency_id IN ('' + @_currency_id + '')'' END
			+ CASE WHEN @_broker_id IS NULL THEN '''' ELSE '' AND sdh.broker_id IN ('' + @_broker_id + '')'' END
			+ CASE WHEN @_country_id IS NULL THEN '''' ELSE '' AND sml.country IN ('' + @_country_id + '')'' END
			+ CASE WHEN @_internal_counterparty_id IS NULL THEN '''' ELSE '' AND books.counterparty_id IN ('' + @_internal_counterparty_id + '')'' END
			+ CASE WHEN @_product_id IS NULL THEN '''' ELSE '' AND sdh.product_id IN ('' + @_product_id + '')'' END
			+ CASE WHEN @_region_id IS NULL THEN '''' ELSE '' AND sml.region IN ('' + @_region_id + '')'' END
			+ CASE WHEN @_template_id IS NULL THEN '''' ELSE '' AND sdh.template_id IN ('' + @_template_id + '')'' END
			+ CASE WHEN @_pricing_type_id  IS NULL THEN '''' ELSE '' AND sdh.pricing_type IN ('' + @_pricing_type_id + '')'' END
--+'' AND (sdpd.pnl_source_value_id IS NOT NULL) ''
--print @_sql_select1
--print @_sql_select2
--print @_sql_from1
--print @_sql_from2
--print @_sql_from3
--print @_sql_from4
--print @_sql_whr
EXEC (@_sql_select1 + @_sql_select2 + @_sql_from1 + @_sql_from2 + @_sql_from3 + @_sql_from4 + @_sql_whr)
---------------------------------------------------------------------------------------------------------------
SELECT fv.source_deal_header_id, term_start, term_end, leg, sds1.settlement_amount_s amount, Isnull(sds1.market_value_s, 0) market_value, sds1.contract_value_s contract_value, sds1.volume_s total_volume, sds1.float_price_s market_price, 
CASE WHEN fv.formula IS NOT NULL OR fv.formula_curve_id IS NOT NULL THEN sds1.net_price_s- (ISNULL(fv.price_adder, 0) + ISNULL(fv.price_adder2, 0)) + ISNULL(sds1.float_price_s, 0) ELSE '''' END formula_price, 
sds1.net_price_s net_price, sds1.deal_price_s deal_price, sds1.float_price_s float_price, sds1.volume_s Volume, sds1.charge_type_id AS [charge_type_id], ''Commodity'' AS [charge_type], sds1.settlement_currency_id currency_id, sds1.payment_date, sds1.currency, ''a'' actual_forward, fv.pnl_date, fv.pricing_type,fv.source_deal_detail_id
, sds1.invoice_currency, sds1.deal_currency, sds1.amount_inv, sds1.amount_deal
INTO #settlement_value -- select * from #settlement_value
FROM #final_values fv
CROSS APPLY (
	SELECT Max(as_of_date) as_of_date
	FROM source_deal_settlement
	WHERE source_deal_header_id = fv.source_deal_header_id AND term_start = fv.term_start AND leg = fv.leg --and set_type=''''s''''
		AND term_start <= @_from_as_of_date AND as_of_date <= @_from_as_of_date
	) aod
CROSS APPLY (
	SELECT volume volume_s, 
		deal_price deal_price_s, 
		net_price net_price_s, 
		float_price float_price_s, 
		market_value market_value_s, 
		contract_value Contract_value_s, 
		settlement_amount settlement_amount_s,
		scur.source_currency_id settlement_currency_id, 
		payment_date, 
		-5500 charge_type_id, 
		scur.currency_name currency,
		scur_ic.currency_id invoice_currency, 
		scur_dc.currency_id deal_currency,
		settlement_amount_inv  amount_inv,
		settlement_amount_deal amount_deal 
	FROM source_deal_settlement a
	LEFT JOIN source_currency scur ON scur.source_currency_id = CASE @_cur_type WHEN ''d'' THEN a.deal_cur_id WHEN ''i'' THEN a.inv_cur_id ELSE a.settlement_currency_id END
	LEFT JOIN source_currency scur_ic ON scur_ic.source_currency_id = a.inv_cur_id
	LEFT JOIN source_currency scur_dc ON scur_dc.source_currency_id = a.deal_cur_id
	WHERE source_deal_header_id = fv.source_deal_header_id AND term_start = fv.term_start AND term_end = fv.term_end AND leg = fv.leg AND as_of_date = aod.as_of_date
) sds1
LEFT JOIN settlement_charge_type_exclude scte ON Isnull(scte.charge_type_id, - 1) = sds1.charge_type_id AND ISNULL(scte.counterparty_id, - 1) = fv.source_counterparty_id AND ISNULL(scte.internal_counterparty_id, fv.internal_counterparty_id) = fv.internal_counterparty_id AND ISNULL(scte.contract_id, fv.contract_id) = fv.contract_id AND ISNULL(scte.commodity_id, fv.commodity_id) = fv.commodity_id AND ISNULL(scte.deal_type_id, fv.source_deal_type_id) = fv.source_deal_type_id AND COALESCE(scte.deal_sub_type_id, fv.deal_sub_type_type_id, - 1) = Isnull(fv.deal_sub_type_type_id, - 1) AND COALESCE(scte.internal_deal_type_id, fv.internal_deal_type_id, - 1) = Isnull(fv.internal_deal_type_id, - 1) AND COALESCE(scte.internal_deal_sub_type_id, fv.internal_deal_sub_type_id, - 1) = Isnull(fv.internal_deal_sub_type_id, - 1) AND COALESCE(scte.product_id, fv.product_id, - 1) = Isnull(fv.product_id, - 1) AND COALESCE(scte.pricing_type, fv.pricing_type_id, - 1) = Isnull(fv.pricing_type_id, - 1)
WHERE scte.charge_type_id IS NULL
--### Get Contract Settlement Values
SELECT source_counterparty_id, contract_id, entire_term_start term_start, entire_term_end term_end, commodity_id, Max(agg_term) agg_term
INTO #cs_group_info -- select * from #cs_group_info
FROM #final_values
GROUP BY source_counterparty_id, contract_id, entire_term_start, entire_term_end, commodity_id
SELECT source_counterparty_id, commodity_id, contract_id, term_start entire_term_start, term_end entire_term_end, civv1.charge_type_id, Cast(source_counterparty_id AS VARCHAR) + ''-'' + Cast(contract_id AS VARCHAR) + ''-'' + Cast(civv1.charge_type_id AS VARCHAR) reference, civv1.charge_type charge_type, civv1.value amount, civv1.volume total_volume, civv1.volume Volume, agg_term, civv1.curreny_id, civv1.payment_date, civv1.currency_name currency
INTO #contract_fees -- select * from #contract_fees
FROM #cs_group_info fv
CROSS APPLY (
	SELECT Max(as_of_date) as_of_date
	FROM calc_invoice_volume_variance
	WHERE counterparty_id = fv.source_counterparty_id AND contract_id = fv.contract_id AND prod_date = fv.term_start AND as_of_date <= @_from_as_of_date
	) civv
CROSS APPLY (
	SELECT civ.invoice_line_item_id charge_type_id, sdv.code charge_type, civ.volume volume, civ.value value, civ.uom_id uom_id, su.uom_name uom, sc.source_currency_id curreny_id, sc.currency_name currency_name, civvt.payment_date payment_date
	FROM calc_invoice_volume_variance civvt
	INNER JOIN calc_invoice_volume civ ON civvt.calc_id = civ.calc_id
	INNER JOIN static_data_value sdv ON sdv.value_id = civ.invoice_line_item_id
	INNER JOIN contract_group cg ON cg.contract_id = civvt.contract_id
	INNER JOIN source_uom su ON su.source_uom_id = cg.volume_uom
	LEFT JOIN source_currency sc ON sc.source_currency_id = cg.currency
	LEFT JOIN contract_group_detail cgd ON cgd.contract_id = cg.contract_id AND cgd.include_cash_flow = ''y''
	LEFT JOIN contract_charge_type cct ON cct.contract_charge_type_id = cg.contract_charge_type_id
	LEFT JOIN contract_charge_type_detail cctd ON cctd.contract_charge_type_id = cct.contract_charge_type_id AND cctd.include_cash_flow = ''y''
	LEFT JOIN contract_charge_type_detail cctd1 ON cctd1.[id] = cgd.contract_component_template AND cctd1.include_cash_flow = ''y''
	WHERE civvt.as_of_date = civv.as_of_date AND civvt.counterparty_id = fv.source_counterparty_id AND civvt.contract_id = fv.contract_id AND civvt.prod_date = fv.term_start AND COALESCE(cctd1.include_cash_flow, cctd.include_cash_flow, cgd.include_cash_flow) = ''y''
) civv1
SELECT sv.source_deal_header_id, sv.term_start, sv.term_end, sv.leg, COALESCE(ifbs.fees, sv.amount, 0) amount, COALESCE(ifbs.fees, sv.amount, 0) contract_value, ifbs.price net_price, ifbs.actual_forward, COALESCE(sv.amount, fv.und_pnl_set, 0) und_pnl_set, ifbs.price deal_price, COALESCE(ifbs.volume, sv.volume) Volume, COALESCE(ifbs.field_id, sv.charge_type_id) charge_type_id, COALESCE(ifbs.field_name, sv.charge_type) charge_type, COALESCE(ifbs.currency_id, sv.currency_id) currency_id, scur.currency_name currency,ifbs.internal_type
	, ifbs.invoice_currency, ifbs.deal_currency, ifbs.amount_inv, ifbs.amount_deal, ifbs.counterparty_id, ifbs.contract_id
INTO #deal_fees_set -- select * from #deal_fees_set
	-- select 1
FROM #settlement_value sv
	LEFT JOIN #final_values fv ON fv.source_deal_header_id = sv.source_deal_header_id AND fv.term_start = sv.term_start AND fv.term_end = sv.term_end AND fv.leg = sv.leg AND fv.charge_type_id = sv.charge_type_id AND fv.charge_type = ''Commodity'' --and coalesce(fv.cash_flow,sv.amount,fv.amount) IS NOT NULL
	CROSS APPLY (
		SELECT Max(as_of_date) as_of_date FROM index_fees_breakdown_settlement WHERE source_deal_header_id = sv.source_deal_header_id 
			and term_start = sv.term_start AND Isnull(leg, 1) = Isnull(sv.leg, 1)
			AND as_of_date <= Isnull(fv.from_as_of_date, @_from_as_of_date) 
			AND field_id > 0 and internal_type not in (18722,18723,18733,18742,18743, 18732)
	) ifbs_mx
	CROSS APPLY (
		SELECT volume, 
			   CASE @_cur_type WHEN ''d'' THEN value_deal WHEN ''i'' THEN value_inv ELSE [value] END fees, 
			   field_id, 
			   field_name, 
			   price, 
			   contract_value, 
			   ''a'' actual_forward, 
			   CASE @_cur_type WHEN ''d'' THEN deal_cur_id WHEN ''i'' THEN inv_cur_id ELSE fee_currency_id END currency_id,
			   internal_type,
			   scur_ic.currency_id invoice_currency, 
			   scur_dc.currency_id deal_currency,
			   value_inv  amount_inv,
			   value_deal amount_deal,
			   counterparty_id,
			   contract_id 		
		FROM index_fees_breakdown_settlement
		LEFT JOIN source_currency scur_ic ON scur_ic.source_currency_id = inv_cur_id
		LEFT JOIN source_currency scur_dc ON scur_dc.source_currency_id = deal_cur_id
		WHERE source_deal_header_id = sv.source_deal_header_id 
		AND term_start = sv.term_start 		
		AND (Isnull(leg, 1) = Isnull(sv.leg, 1) or field_id in (307014,307075))
		AND (as_of_date = ifbs_mx.as_of_date or field_id in (307014,307075)) AND field_id > 0
		  and internal_type not in (18722,18723,18733,18742,18743, 18732)
	) ifbs
	LEFT JOIN source_currency scur ON scur.source_currency_id = isnull(ifbs.currency_id, sv.currency_id)
WHERE ifbs.field_id IS NOT NULL
select sv.source_deal_header_id, ifbs.term_start, ifbs.term_end, ifbs.leg, COALESCE(ifbs.value, 0) amount
	, COALESCE(ifbs.value, 0) contract_value, ifbs.price net_price, ''a'' actual_forward, null und_pnl_set, ifbs.price deal_price
	, ifbs.volume Volume, ifbs.field_id charge_type_id, ifbs.field_name charge_type, ifbs.currency_id
	, scur.currency_name currency,ifbs.internal_type, ifbs.counterparty_id, ifbs.contract_id
INTO #deal_fees_set_onetime -- select * from #deal_fees_set_onetime
from 
	(
		SELECT distinct fv.source_deal_header_id,fv.from_as_of_date 
		FROM #final_values fv
			LEFT JOIN settlement_charge_type_exclude scte ON Isnull(scte.charge_type_id, - 1) = -5500 
				AND ISNULL(scte.counterparty_id, - 1) = fv.source_counterparty_id 
				AND ISNULL(scte.internal_counterparty_id, fv.internal_counterparty_id) = fv.internal_counterparty_id 
				AND ISNULL(scte.contract_id, fv.contract_id) = fv.contract_id AND ISNULL(scte.commodity_id, fv.commodity_id) = fv.commodity_id 
				AND ISNULL(scte.deal_type_id, fv.source_deal_type_id) = fv.source_deal_type_id 
				AND COALESCE(scte.deal_sub_type_id, fv.deal_sub_type_type_id, - 1) = Isnull(fv.deal_sub_type_type_id, - 1) 
				AND COALESCE(scte.internal_deal_type_id, fv.internal_deal_type_id, - 1) = Isnull(fv.internal_deal_type_id, - 1) 
				AND COALESCE(scte.internal_deal_sub_type_id, fv.internal_deal_sub_type_id, - 1) = Isnull(fv.internal_deal_sub_type_id, - 1) 
				AND COALESCE(scte.product_id, fv.product_id, - 1) = Isnull(fv.product_id, - 1) 
				AND COALESCE(scte.pricing_type, fv.pricing_type_id, - 1) = Isnull(fv.pricing_type_id, - 1)
		WHERE scte.charge_type_id IS NULL
	) sv
	CROSS APPLY (
		SELECT Max(as_of_date) as_of_date FROM index_fees_breakdown_settlement WHERE source_deal_header_id = sv.source_deal_header_id 
			AND as_of_date <= Isnull(sv.from_as_of_date, @_from_as_of_date) 
            AND term_start BETWEEN @_term_start AND @_term_end
			--and internal_type in (18722,18723,18733,18742,18743, 18732)
	) ifbs_mx
	--cross join ( VALUES (18722),(18723),(18733) , (18742),(18743),(18732) ) fee (internal_type)
	outer apply
	( select * from index_fees_breakdown_settlement  where source_deal_header_id = sv.source_deal_header_id 
	--	and internal_type =fee.internal_type 
        AND as_of_date=ifbs_mx.as_of_date
		 AND term_start BETWEEN @_term_start AND @_term_end
        --order by term_start
	)ifbs
	LEFT JOIN source_currency scur ON scur.source_currency_id = ifbs.currency_id
WHERE ifbs.field_id IS NOT NULL
SELECT fv.source_deal_header_id, 
	fv.term_start, 
	fv.term_end, 
	fv.leg, 
	COALESCE(CASE @_cur_type WHEN ''d'' THEN ifb.value_deal WHEN ''i'' THEN ifb.value_inv ELSE [value] END, fv.amount, 0) amount, 
	COALESCE(CASE @_cur_type WHEN ''d'' THEN ifb.value_deal WHEN ''i'' THEN ifb.value_inv ELSE [value] END, fv.amount, 0) contract_value, 
	ifb.price net_price, 
	''f'' actual_forward, 
	COALESCE(CASE @_cur_type WHEN ''d'' THEN ifb.value_deal WHEN ''i'' THEN ifb.value_inv ELSE [value] END, fv.amount, fv.und_pnl_set, 0) und_pnl_set, 
	ifb.price deal_price, 
	COALESCE(ifb.volume, fv.volume) Volume, 
	COALESCE(ifb.field_id, fv.charge_type_id) charge_type_id, 
	COALESCE(ifb.field_name, fv.charge_type) charge_type, 
	scur.source_currency_id currency_id, 
	scur.currency_name currency,
	ifb.internal_type,
	scur_ic.currency_id invoice_currency, 
	scur_dc.currency_id deal_currency,
	value_inv  amount_inv,
	value_deal amount_deal,
	ifb.counterparty_id,
	ifb.contract_id
INTO #deal_fees -- select * from #deal_fees
FROM #final_values fv
	INNER JOIN index_fees_breakdown ifb ON ifb.source_deal_header_id = fv.source_deal_header_id AND ifb.term_start = fv.term_start AND Isnull(ifb.leg, 1) = Isnull(fv.leg, 1) AND ifb.as_of_date = Isnull(fv.from_as_of_date, @_from_as_of_date) AND ifb.field_id > 0 AND internal_type > 0 AND fv.actual_forward = ''f''
	LEFT JOIN source_currency scur ON scur.source_currency_id = 
		CASE @_cur_type WHEN ''d'' THEN ifb.deal_cur_id WHEN ''i'' THEN ifb.inv_cur_id ELSE COALESCE(ifb.fee_currency_id, fv.currency_id) END
	LEFT JOIN source_currency scur_ic ON scur_ic.source_currency_id = ifb.inv_cur_id
	LEFT JOIN source_currency scur_dc ON scur_dc.source_currency_id = ifb.deal_cur_id 
WHERE ifb.field_id IS NOT NULL and ifb.internal_type not in (18722,18723,18733,18742,18743, 18732)
--and fv.term_start>Isnull(fv.from_as_of_date, @_from_as_of_date)
INSERT INTO #final_values (sub_id, stra_id, book_id, subsidiary, strategy, book, sub_book, charge_type_id, charge_type, counterparty_name, parent_counterparty_name, contract_id, [contract_name], commodity_id, term_start, term_end, from_as_of_date, amount, commodity, total_volume, source_counterparty_id, counterparty_id, term_start_day, term_start_month, term_start_month_name, term_start_year, term_start_year_month, term_quarter, to_as_of_date, sub_book_id, actual_forward, Volume, agg_term, currency_id, entire_term_start, entire_term_end, payment_date, currency, pnl_date, reference)
SELECT fv.sub_id, fv.stra_id, fv.book_id, fv.subsidiary, fv.strategy, fv.book, fv.sub_book, cf.charge_type_id, cf.charge_type, fv.counterparty_name, fv.parent_counterparty_name, fv.contract_id, fv.[contract_name], fv.commodity_id, fv.term_start, fv.term_end, fv.from_as_of_date, cf.amount, fv.commodity, cf.volume total_volume, fv.source_counterparty_id, fv.counterparty_id, fv.term_start_day, fv.term_start_month, fv.term_start_month_name, fv.term_start_year, fv.term_start_year_month, fv.term_quarter, fv.to_as_of_date, fv.sub_book_id, ''a'' AS actual_forward, cf.volume Volume, cf.agg_term, cf.curreny_id currency_id, term_start entire_term_start, term_end entire_term_end, cf.payment_date, cf.currency, fv.pnl_date, cf.reference
FROM #final_values fv
INNER JOIN #contract_fees cf ON cf.source_counterparty_id = fv.source_counterparty_id AND cf.contract_id = fv.contract_id AND cf.entire_term_start = fv.entire_term_start AND cf.entire_term_end = fv.entire_term_end AND cf.commodity_id = cf.commodity_id
INSERT INTO #final_values (
	sub_id, stra_id, book_id, subsidiary, strategy, book, sub_book, source_deal_header_id, deal_ref_id, deal_date_from, deal_date_to, trader_id, trader_name, counterparty_name, parent_counterparty_name, contract_id, [contract_name], source_deal_type_id, deal_type_name, deal_sub_type_type_id, deal_sub_type_name, product_id, commodity_id, product_desc, block_definition, buy_sell_flag, term_start, term_end, country_id, country, grid, region_id, region, source_major_location_id, location_group, location_id, location_name, location_description, from_as_of_date, Amount, und_intrinsic_pnl, und_extrinsic_pnl, dis_pnl, dis_intrinsic_pnl, dis_extrinisic_pnl, market_value, contract_value, dis_market_value, dis_contract_value, discount_factor, discount_amount, commodity, deal_volume, volume_uom, template_name, curve_name, index_tou, currency, formula, total_volume, position_uom, cva, dva, market_price, formula_price, net_price, physical_financial_flag, block_definition_id, leg, source_counterparty_id, counterparty_id, index_id, credit_adjusted_mtm, 
	discounted_credit_adjusted_mtm, term_start_day, term_start_month, term_start_month_name, term_start_year, term_start_year_month, term_quarter, to_as_of_date, sub_book_id, transaction_type, transaction_type_name, period_from, period_to, probability, credit_reserve, dis_credit_reserve, fair_value, dis_fair_value, model_reserve, actual_forward, pnl_conversion_factor, pnl_adjustment_value, internal_deal_type_id, internal_deal_type, internal_deal_sub_type_id, internal_deal_sub_type, fixed_cost, fixed_price, formula_value, price_adder, price_multiplier, strike_price, und_pnl_set, formula_curve_id, formula_curve_name, internal_desk_id, internal_desk, internal_portfolio_id, internal_portfolio, broker_id, broker_name, type_of_entity_id, type_of_entity, int_ext_flag_id, int_ext_flag, deal_status_id, deal_status, confirm_status_id, confirm_status, pnl_source_value_id, pnl_source_name, description1, description2, description3, description4, counterparty_id2, counterparty_name2, ext_deal_id, reference, create_by, create_ts, update_by, update_ts, 
	broker_fixed_cost, confirm_date, sub_book_group1_id, sub_book_group2_id, sub_book_group3_id, sub_book_group4_id, sub_book_group1, sub_book_group2, sub_book_group3, sub_book_group4, book_identifier1_id, book_identifier2_id, book_identifier3_id, book_identifier4_id, book_identifier1, book_identifier2, book_identifier3, book_identifier4, deal_price, float_price, Volume, close_reference_id, charge_type_id, charge_type, agg_term, recovery_rate, fv_level, current_non_current, deal_category_id, deal_category, internal_counterparty_id, internal_couterparty, template_id, volume_profile, price_adder2, volume_multiplier, volume_multiplier2, debt_rating, volume_frequency, currency_id, is_expired, entire_term_start, entire_term_end, contract_exipration_date, structured_id, payment_date, pricing_type_id, must_run_volume, dispatch_volume, must_run_market_value, must_run_contract_value, dispatch_market_value, dispatch_contract_value, pnl_date, cash_flow, pricing_type,source_deal_detail_id
	,invoice_currency, deal_currency, amount_inv, amount_deal,
		[reporting_group1],
	[reporting_group2],
	[reporting_group3],
	[reporting_group4],
	[reporting_group5],
	[reporting_group1_name],
	[reporting_group2_name],
	[reporting_group3_name],
	[reporting_group4_name],
	[reporting_group5_name]
)
SELECT fv.sub_id, fv.stra_id, fv.book_id, fv.subsidiary, fv.strategy, fv.book, fv.sub_book, fv.source_deal_header_id, fv.deal_ref_id, fv.deal_date_from, fv.deal_date_to, fv.trader_id, fv.trader_name, ISNULL(sc.counterparty_name, fv.counterparty_name) counterparty_name, fv.parent_counterparty_name, ISNULL(cg.contract_id, fv.contract_id) contract_id, ISNULL(cg.[contract_name], fv.[contract_name]) [contract_name], fv.source_deal_type_id, fv.deal_type_name, fv.deal_sub_type_type_id, fv.deal_sub_type_name, fv.product_id, fv.commodity_id, fv.product_desc, fv.block_definition, fv.buy_sell_flag, fv.term_start, fv.term_end, fv.country_id, fv.country, fv.grid, fv.region_id, fv.region, fv.source_major_location_id, fv.location_group, fv.location_id, fv.location_name, fv.location_description, fv.from_as_of_date, df.Amount, fv.und_intrinsic_pnl, fv.und_extrinsic_pnl, fv.dis_pnl, fv.dis_intrinsic_pnl, fv.dis_extrinisic_pnl, fv.market_value, df.contract_value, fv.dis_market_value, fv.dis_contract_value, fv.discount_factor, fv.discount_amount, fv.commodity, fv.deal_volume, fv.volume_uom, fv.template_name, fv.curve_name, fv.index_tou, df.currency, fv.formula, ISNULL(df.volume, fv.total_volume) total_volume, fv.
	position_uom, fv.cva, fv.dva, fv.market_price, fv.formula_price, df.net_price, fv.physical_financial_flag, fv.block_definition_id, fv.leg, ISNULL(sc.source_counterparty_id, fv.source_counterparty_id) source_counterparty_id, ISNULL(sc.counterparty_id, fv.counterparty_id) counterparty_id, fv.index_id, fv.credit_adjusted_mtm, fv.discounted_credit_adjusted_mtm, fv.term_start_day, fv.term_start_month, fv.term_start_month_name, fv.term_start_year, fv.term_start_year_month, fv.term_quarter, fv.to_as_of_date, fv.sub_book_id, fv.transaction_type, fv.transaction_type_name, fv.period_from, fv.period_to, fv.probability, fv.credit_reserve, fv.dis_credit_reserve, fv.fair_value, fv.dis_fair_value, fv.model_reserve, df.actual_forward, fv.pnl_conversion_factor, fv.pnl_adjustment_value, fv.internal_deal_type_id, fv.internal_deal_type, fv.internal_deal_sub_type_id, fv.internal_deal_sub_type, fv.fixed_cost, fv.fixed_price, fv.formula_value, fv.price_adder, fv.price_multiplier, fv.strike_price, df.und_pnl_set, fv.formula_curve_id, fv.formula_curve_name, fv.internal_desk_id, fv.internal_desk, fv.internal_portfolio_id, fv.internal_portfolio, fv.broker_id
	, fv.broker_name, fv.type_of_entity_id, fv.type_of_entity, fv.int_ext_flag_id, fv.int_ext_flag, fv.deal_status_id, fv.deal_status, fv.confirm_status_id, fv.confirm_status, fv.pnl_source_value_id, fv.pnl_source_name, fv.description1, fv.description2, fv.description3, fv.description4, fv.counterparty_id2, fv.counterparty_name2, fv.ext_deal_id, fv.reference, fv.create_by, fv.create_ts, fv.update_by, fv.update_ts, fv.broker_fixed_cost, fv.confirm_date, fv.sub_book_group1_id, fv.sub_book_group2_id, fv.sub_book_group3_id, fv.sub_book_group4_id, fv.sub_book_group1, fv.sub_book_group2, fv.sub_book_group3, fv.sub_book_group4, fv.book_identifier1_id, fv.book_identifier2_id, fv.book_identifier3_id, fv.book_identifier4_id, fv.book_identifier1, fv.book_identifier2, fv.book_identifier3, fv.book_identifier4, df.deal_price, fv.float_price, df.Volume, fv.close_reference_id, df.charge_type_id, df.charge_type, fv.agg_term, fv.recovery_rate, fv.fv_level, fv.current_non_current, fv.deal_category_id, fv.deal_category, fv.internal_counterparty_id, fv.
	internal_couterparty, fv.template_id, fv.volume_profile, fv.price_adder2, fv.volume_multiplier, fv.volume_multiplier2, fv.debt_rating, fv.volume_frequency, df.currency_id, fv.is_expired, fv.entire_term_start, fv.entire_term_end, fv.contract_exipration_date, fv.structured_id, fv.payment_date, fv.pricing_type_id, fv.must_run_volume, fv.dispatch_volume, fv.must_run_market_value, fv.must_run_contract_value, fv.dispatch_market_value, fv.dispatch_contract_value, fv.pnl_date, df.Amount cash_flow, fv.pricing_type,fv.source_deal_detail_id
	,df.invoice_currency, df.deal_currency, df.amount_inv, df.amount_deal,
	fv.[reporting_group1],
	fv.[reporting_group2],
	fv.[reporting_group3],
	fv.[reporting_group4],
	fv.[reporting_group5],
	fv.[reporting_group1_name],
	fv.[reporting_group2_name],
	fv.[reporting_group3_name],
	fv.[reporting_group4_name],
	fv.[reporting_group5_name]
FROM #final_values fv  --    select * from #final_values
	cross apply (
		SELECT * FROM #deal_fees_set where source_deal_header_id = fv.source_deal_header_id 
			AND term_start = fv.term_start  AND leg = fv.leg
		UNION ALL	
		--SELECT * FROM #deal_fees_set_onetime where source_deal_header_id = fv.source_deal_header_id 
		--	AND term_start = fv.term_start  AND leg = fv.leg
		--UNION ALL	
		SELECT * FROM #deal_fees where source_deal_header_id = fv.source_deal_header_id 
			AND term_start = fv.term_start  AND leg = fv.leg
	) df  
	LEFT JOIN source_counterparty AS sc ON sc.source_counterparty_id = df.counterparty_id
	LEFT JOIN contract_group cg ON cg.contract_id = df.contract_id
where df.source_deal_header_id is not null
INSERT INTO #final_values (
	sub_id, stra_id, book_id, subsidiary, strategy, book, sub_book, source_deal_header_id, deal_ref_id, deal_date_from, deal_date_to, trader_id, trader_name, counterparty_name, parent_counterparty_name, contract_id, [contract_name], source_deal_type_id, deal_type_name, deal_sub_type_type_id, deal_sub_type_name, product_id, commodity_id, product_desc, block_definition, buy_sell_flag, term_start, term_end, country_id, country, grid, region_id, region, source_major_location_id, location_group, location_id, location_name, location_description, from_as_of_date, Amount, und_intrinsic_pnl, und_extrinsic_pnl, dis_pnl, dis_intrinsic_pnl, dis_extrinisic_pnl, market_value, contract_value, dis_market_value, dis_contract_value, discount_factor, discount_amount, commodity, deal_volume, volume_uom, template_name, curve_name, index_tou, currency, formula, total_volume, position_uom, cva, dva, market_price, formula_price, net_price, physical_financial_flag, block_definition_id, leg, source_counterparty_id, counterparty_id, index_id, credit_adjusted_mtm, 
	discounted_credit_adjusted_mtm, term_start_day, term_start_month, term_start_month_name, term_start_year, term_start_year_month, term_quarter, to_as_of_date, sub_book_id, transaction_type, transaction_type_name, period_from, period_to, probability, credit_reserve, dis_credit_reserve, fair_value, dis_fair_value, model_reserve, actual_forward, pnl_conversion_factor, pnl_adjustment_value, internal_deal_type_id, internal_deal_type, internal_deal_sub_type_id, internal_deal_sub_type, fixed_cost, fixed_price, formula_value, price_adder, price_multiplier, strike_price, und_pnl_set, formula_curve_id, formula_curve_name, internal_desk_id, internal_desk, internal_portfolio_id, internal_portfolio, broker_id, broker_name, type_of_entity_id, type_of_entity, int_ext_flag_id, int_ext_flag, deal_status_id, deal_status, confirm_status_id, confirm_status, pnl_source_value_id, pnl_source_name, description1, description2, description3, description4, counterparty_id2, counterparty_name2, ext_deal_id, reference, create_by, create_ts, update_by, update_ts, 
	broker_fixed_cost, confirm_date, sub_book_group1_id, sub_book_group2_id, sub_book_group3_id, sub_book_group4_id, sub_book_group1, sub_book_group2, sub_book_group3, sub_book_group4, book_identifier1_id, book_identifier2_id, book_identifier3_id, book_identifier4_id, book_identifier1, book_identifier2, book_identifier3, book_identifier4, deal_price, float_price, Volume, close_reference_id, charge_type_id, charge_type, agg_term, recovery_rate, fv_level, current_non_current, deal_category_id, deal_category, internal_counterparty_id, internal_couterparty, template_id, volume_profile, price_adder2, volume_multiplier, volume_multiplier2, debt_rating, volume_frequency, currency_id, is_expired, entire_term_start, entire_term_end, contract_exipration_date, structured_id, payment_date, pricing_type_id, must_run_volume, dispatch_volume, must_run_market_value, must_run_contract_value, dispatch_market_value, dispatch_contract_value, pnl_date, cash_flow, pricing_type,source_deal_detail_id
		,[reporting_group1],
	[reporting_group2],
	[reporting_group3],
	[reporting_group4],
	[reporting_group5],
	[reporting_group1_name],
	[reporting_group2_name],
	[reporting_group3_name],
	[reporting_group4_name],
	[reporting_group5_name]
)
SELECT fv.sub_id, fv.stra_id, fv.book_id, fv.subsidiary, fv.strategy, fv.book, fv.sub_book, fv.source_deal_header_id, fv.deal_ref_id, fv.deal_date_from, fv.deal_date_to, fv.trader_id, fv.trader_name, ISNULL(sc.counterparty_name, fv.counterparty_name) counterparty_name, fv.parent_counterparty_name, ISNULL(cg.contract_id, fv.contract_id) contract_id, ISNULL(cg.[contract_name], fv.[contract_name]) [contract_name], fv.source_deal_type_id, fv.deal_type_name, fv.deal_sub_type_type_id, fv.deal_sub_type_name, fv.product_id, fv.commodity_id, fv.product_desc, fv.block_definition, fv.buy_sell_flag, df.term_start, df.term_end, fv.country_id, fv.country, fv.grid, fv.region_id, fv.region, fv.source_major_location_id, fv.location_group, fv.location_id, fv.location_name, fv.location_description, fv.from_as_of_date, df.Amount, fv.und_intrinsic_pnl, fv.und_extrinsic_pnl, fv.dis_pnl, fv.dis_intrinsic_pnl, fv.dis_extrinisic_pnl, null market_value, df.contract_value, null dis_market_value, fv.dis_contract_value, fv.discount_factor, fv.discount_amount, fv.commodity, fv.deal_volume, fv.volume_uom, fv.template_name, fv.curve_name, fv.index_tou, df.currency, fv.formula, fv.total_volume
, fv.position_uom, fv.cva, fv.dva, null market_price, fv.formula_price, df.net_price, fv.physical_financial_flag, fv.block_definition_id, fv.leg, ISNULL(sc.source_counterparty_id, fv.source_counterparty_id) source_counterparty_id, ISNULL(sc.counterparty_id, fv.counterparty_id) counterparty_id, fv.index_id, fv.credit_adjusted_mtm, fv.discounted_credit_adjusted_mtm, DAY(df.term_start)term_start_day, RIGHT(''0''+ CAST(MONTH(df.term_start) AS VARCHAR(2)), 2) term_start_month, DATENAME(m,df.term_start) term_start_month_name, YEAR(df.term_start) term_start_year, CAST(YEAR(df.term_start) AS VARCHAR(5)) + ''-'' + RIGHT(''0''+ CAST(MONTH(df.term_start) AS VARCHAR(2)), 2) term_start_year_month, ''Q'' + CAST(DATEPART(q,df.term_start) AS VARCHAR) term_quarter, fv.to_as_of_date, fv.sub_book_id, fv.transaction_type, fv.transaction_type_name, fv.period_from, fv.period_to, fv.probability, fv.credit_reserve, fv.dis_credit_reserve, fv.fair_value, fv.dis_fair_value, fv.model_reserve, df.actual_forward, fv.pnl_conversion_factor, fv.pnl_adjustment_value, fv.internal_deal_type_id, fv.internal_deal_type, fv.internal_deal_sub_type_id, fv.internal_deal_sub_type, fv.fixed_cost, fv.fixed_price, fv.formula_value, fv.price_adder, fv.price_multiplier, fv.strike_price, df.und_pnl_set, fv.formula_curve_id, fv.formula_curve_name, fv.internal_desk_id, fv.internal_desk, fv.internal_portfolio_id, fv.internal_portfolio, fv.broker_id
	, fv.broker_name, fv.type_of_entity_id, fv.type_of_entity, fv.int_ext_flag_id, fv.int_ext_flag, fv.deal_status_id, fv.deal_status, fv.confirm_status_id, fv.confirm_status, fv.pnl_source_value_id, fv.pnl_source_name, fv.description1, fv.description2, fv.description3, fv.description4, fv.counterparty_id2, fv.counterparty_name2, fv.ext_deal_id, fv.reference, fv.create_by, fv.create_ts, fv.update_by, fv.update_ts, fv.broker_fixed_cost, fv.confirm_date, fv.sub_book_group1_id, fv.sub_book_group2_id, fv.sub_book_group3_id, fv.sub_book_group4_id, fv.sub_book_group1, fv.sub_book_group2, fv.sub_book_group3, fv.sub_book_group4, fv.book_identifier1_id, fv.book_identifier2_id, fv.book_identifier3_id, fv.book_identifier4_id, fv.book_identifier1, fv.book_identifier2, fv.book_identifier3, fv.book_identifier4, df.deal_price, fv.float_price, df.Volume, fv.close_reference_id, df.charge_type_id, df.charge_type, ag_t.agg_term, fv.recovery_rate, fv.fv_level, fv.current_non_current, fv.deal_category_id, fv.deal_category, fv.internal_counterparty_id
	, fv.internal_couterparty, fv.template_id, fv.volume_profile, fv.price_adder2, fv.volume_multiplier, fv.volume_multiplier2, fv.debt_rating, fv.volume_frequency, df.currency_id, fv.is_expired, fv.entire_term_start, fv.entire_term_end, fv.contract_exipration_date, fv.structured_id, fv.payment_date, fv.pricing_type_id, fv.must_run_volume, fv.dispatch_volume, fv.must_run_market_value, fv.must_run_contract_value, fv.dispatch_market_value, fv.dispatch_contract_value, fv.pnl_date, df.Amount cash_flow, fv.pricing_type,fv.source_deal_detail_id
,fv.[reporting_group1],
fv.[reporting_group2],
fv.[reporting_group3],
fv.[reporting_group4],
fv.[reporting_group5],
fv.[reporting_group1_name],
fv.[reporting_group2_name],
fv.[reporting_group3_name],
fv.[reporting_group4_name],
fv.[reporting_group5_name]
FROM  #deal_fees_set_onetime df
LEFT JOIN source_counterparty AS sc ON sc.source_counterparty_id = df.counterparty_id
LEFT JOIN contract_group cg ON cg.contract_id = df.contract_id
cross apply
(
	select top(1) * from  #final_values where source_deal_header_id = df.source_deal_header_id 
	order by term_start 
) fv
OUTER APPLY(
	SELECT TOP 1 CASE WHEN MONTH(df.term_start)< MONTH( @_from_as_of_date )
	AND YEAR(df.term_start)<= YEAR(@_from_as_of_date) THEN '' '' + CAST(YEAR
	(df.term_start) AS VARCHAR) + ''-YTD''
	WHEN MONTH(df.term_start)=MONTH(@_from_as_of_date)
	AND YEAR(df.term_start)=YEAR( @_from_as_of_date )
	THEN CAST(YEAR(df.term_start) AS VARCHAR) + '' - Current''
	WHEN DATEPART(q, @_from_as_of_date ) = DATEPART(q,df.term_start)
	AND YEAR( @_from_as_of_date) = YEAR(df.term_start) THEN convert(varchar(4),df.term_start,120) +''-''+ ''M'' + CAST(DATEDIFF(m, @_from_as_of_date,df.term_start) AS VARCHAR) +'' ''+ ''('' + UPPER(LEFT(DATENAME(MONTH,dateadd(MONTH, MONTH(df.term_start),-1)),3)) + '')'' WHEN YEAR(@_from_as_of_date) = YEAR(df.term_start) THEN convert(varchar(4),df.term_start,120) + ''-''+ ''Q'' + CAST(DATEPART(q,df.term_start) AS VARCHAR)
	ELSE CAST(YEAR(df.term_start) AS VARCHAR) END agg_term
	FROM portfolio_mapping_tenor
) ag_t
INSERT INTO #final_values (
	sub_id, stra_id, book_id, subsidiary, strategy, book, sub_book, source_deal_header_id, deal_ref_id, deal_date_from, deal_date_to, trader_id, trader_name, counterparty_name, parent_counterparty_name, contract_id, contract_name, source_deal_type_id, deal_type_name, deal_sub_type_type_id, deal_sub_type_name, product_id, commodity_id, product_desc, block_definition, buy_sell_flag, country_id, country, grid, region_id, region, source_major_location_id, location_group, location_id, location_name, location_description, from_as_of_date, und_intrinsic_pnl, und_extrinsic_pnl, dis_pnl, dis_intrinsic_pnl, dis_extrinisic_pnl, dis_market_value, dis_contract_value, discount_factor, discount_amount, commodity, deal_volume, volume_uom, template_name, curve_name, index_tou, formula, total_volume, position_uom, cva, dva, market_price, formula_price, net_price, physical_financial_flag, block_definition_id, leg, source_counterparty_id, counterparty_id, index_id, credit_adjusted_mtm, discounted_credit_adjusted_mtm, term_start_day, term_start_month, term_start_month_name, 
	term_start_year, term_start_year_month, term_quarter, to_as_of_date, sub_book_id, transaction_type, transaction_type_name, period_from, period_to, probability, credit_reserve, dis_credit_reserve, fair_value, dis_fair_value, model_reserve, pnl_conversion_factor, pnl_adjustment_value, internal_deal_type_id, internal_deal_type, internal_deal_sub_type_id, internal_deal_sub_type, fixed_cost, fixed_price, formula_value, price_adder, price_multiplier, strike_price, formula_curve_id, formula_curve_name, internal_desk_id, internal_desk, internal_portfolio_id, internal_portfolio, broker_id, broker_name, type_of_entity_id, type_of_entity, int_ext_flag_id, int_ext_flag, deal_status_id, deal_status, confirm_status_id, confirm_status, pnl_source_value_id, pnl_source_name, description1, description2, description3, description4, counterparty_id2, counterparty_name2, ext_deal_id, reference, create_by, create_ts, update_by, update_ts, broker_fixed_cost, confirm_date, sub_book_group1_id, sub_book_group2_id, sub_book_group3_id, sub_book_group4_id, 
	sub_book_group1, sub_book_group2, sub_book_group3, sub_book_group4, book_identifier1_id, book_identifier2_id, book_identifier3_id, book_identifier4_id, book_identifier1, book_identifier2, book_identifier3, book_identifier4, deal_price, float_price, Volume, close_reference_id, agg_term, recovery_rate, fv_level, current_non_current, deal_category_id, deal_category, internal_counterparty_id, internal_couterparty, template_id, volume_profile, price_adder2, volume_multiplier, volume_multiplier2, debt_rating, volume_frequency, currency_id, is_expired, entire_term_start, entire_term_end, contract_exipration_date, structured_id, payment_date, pricing_type_id, must_run_volume, dispatch_volume, must_run_market_value, must_run_contract_value, dispatch_market_value, dispatch_contract_value, charge_type_id, charge_type, actual_forward, currency, term_start, term_end, und_pnl_set, market_value, contract_value, Amount, cash_flow, pnl_date,pricing_type,source_deal_detail_id
	,invoice_currency, deal_currency, amount_inv, amount_deal
	,[reporting_group1],
	[reporting_group2],
	[reporting_group3],
	[reporting_group4],
	[reporting_group5],
	[reporting_group1_name],
	[reporting_group2_name],
	[reporting_group3_name],
	[reporting_group4_name],
	[reporting_group5_name]
)
SELECT fv.sub_id, fv.stra_id, fv.book_id, fv.subsidiary, fv.strategy, fv.book, fv.sub_book, fv.source_deal_header_id, fv.deal_ref_id, fv.deal_date_from, fv.deal_date_to, fv.trader_id, fv.trader_name, fv.counterparty_name, fv.parent_counterparty_name, fv.contract_id, fv.contract_name, fv.source_deal_type_id, fv.deal_type_name, fv.deal_sub_type_type_id, fv.deal_sub_type_name, fv.product_id, fv.commodity_id, fv.product_desc, fv.block_definition, fv.buy_sell_flag, fv.country_id, fv.country, fv.grid, fv.region_id, fv.region, fv.source_major_location_id, fv.location_group, fv.location_id, fv.location_name, fv.location_description, fv.from_as_of_date, fv.und_intrinsic_pnl, fv.und_extrinsic_pnl, fv.dis_pnl, fv.dis_intrinsic_pnl, fv.dis_extrinisic_pnl,
	--isnull(sv.market_value ,fv.market_value) market_value ,
	--isnull(sv.contract_value,fv.contract_value) contract_value ,
	fv.dis_market_value, fv.dis_contract_value, fv.discount_factor, fv.discount_amount, fv.commodity, fv.deal_volume, fv.volume_uom, fv.template_name, fv.curve_name, fv.index_tou, fv.formula, isnull(sv.total_volume, fv.total_volume) total_volume, fv.position_uom, fv.cva, fv.dva, isnull(sv.market_price, fv.market_price) market_price, isnull(sv.formula_price, fv.formula_price) formula_price, isnull(sv.net_price, fv.net_price) net_price, fv.physical_financial_flag, fv.block_definition_id, fv.leg, fv.source_counterparty_id, fv.counterparty_id, fv.index_id, fv.credit_adjusted_mtm, fv.discounted_credit_adjusted_mtm, fv.term_start_day, fv.term_start_month, fv.term_start_month_name, fv.term_start_year, fv.term_start_year_month, fv.term_quarter, fv.to_as_of_date, fv.sub_book_id, fv.transaction_type, fv.transaction_type_name, fv.period_from, fv.period_to, fv.probability, fv.credit_reserve, fv.dis_credit_reserve, fv.fair_value, fv.dis_fair_value, fv.model_reserve, fv.pnl_conversion_factor, fv.pnl_adjustment_value, fv.internal_deal_type_id, fv.
	internal_deal_type, fv.internal_deal_sub_type_id, fv.internal_deal_sub_type, fv.fixed_cost, fv.fixed_price, fv.formula_value, fv.price_adder, fv.price_multiplier, fv.strike_price, fv.formula_curve_id, fv.formula_curve_name, fv.internal_desk_id, fv.internal_desk, fv.internal_portfolio_id, fv.internal_portfolio, fv.broker_id, fv.broker_name, fv.type_of_entity_id, fv.type_of_entity, fv.int_ext_flag_id, fv.int_ext_flag, fv.deal_status_id, fv.deal_status, fv.confirm_status_id, fv.confirm_status, fv.pnl_source_value_id, fv.pnl_source_name, fv.description1, fv.description2, fv.description3, fv.description4, fv.counterparty_id2, fv.counterparty_name2, fv.ext_deal_id, fv.reference, fv.create_by, fv.create_ts, fv.update_by, fv.update_ts, fv.broker_fixed_cost, fv.confirm_date, fv.sub_book_group1_id, fv.sub_book_group2_id, fv.sub_book_group3_id, fv.sub_book_group4_id, fv.sub_book_group1, fv.sub_book_group2, fv.sub_book_group3, fv.sub_book_group4, fv.book_identifier1_id, fv.book_identifier2_id, fv.book_identifier3_id, fv.book_identifier4_id, fv.
	book_identifier1, fv.book_identifier2, fv.book_identifier3, fv.book_identifier4, isnull(sv.deal_price, fv.deal_price) deal_price, isnull(sv.float_price, fv.float_price) float_price, isnull(sv.Volume, fv.Volume) Volume, fv.close_reference_id, fv.agg_term, fv.recovery_rate, fv.fv_level, fv.current_non_current, fv.deal_category_id, fv.deal_category, fv.internal_counterparty_id, fv.internal_couterparty, fv.template_id, fv.volume_profile, fv.price_adder2, fv.volume_multiplier, fv.volume_multiplier2, fv.debt_rating, fv.volume_frequency, isnull(sv.currency_id, fv.currency_id) currency_id, fv.is_expired, fv.entire_term_start, fv.entire_term_end, fv.contract_exipration_date, fv.structured_id, isnull(sv.payment_date, fv.payment_date) payment_date, fv.pricing_type_id, fv.must_run_volume, fv.dispatch_volume, fv.must_run_market_value, fv.must_run_contract_value, fv.dispatch_market_value, fv.dispatch_contract_value, fv.charge_type_id, fv.charge_type, isnull(sv.actual_forward, fv.actual_forward) actual_forward, isnull(sv.currency, fv.currency) 
	currency, fv.term_start, fv.term_end, fv.und_pnl_set, isnull(sv.market_value, fv.market_value) market_value, isnull(sv.contract_value, fv.contract_value) contract_value, isnull(sv.amount, fv.amount) Amount, coalesce(sv.amount, fv.cash_flow, fv.amount) cash_flow, sv.pnl_date, fv.pricing_type,sv.source_deal_detail_id
	, sv.invoice_currency, sv.deal_currency, sv.amount_inv, sv.amount_deal
	,fv.[reporting_group1],
	fv.[reporting_group2],
	fv.[reporting_group3],
	fv.[reporting_group4],
	fv.[reporting_group5],
	fv.[reporting_group1_name],
	fv.[reporting_group2_name],
	fv.[reporting_group3_name],
	fv.[reporting_group4_name],
	fv.[reporting_group5_name]
FROM #settlement_value sv
LEFT JOIN #final_values fv ON fv.source_deal_header_id = sv.source_deal_header_id AND fv.term_start = sv.term_start AND fv.term_end = sv.term_end AND fv.leg = sv.leg AND fv.charge_type_id = sv.charge_type_id
WHERE fv.charge_type = ''Commodity'' AND COALESCE(fv.cash_flow, sv.amount, fv.amount) IS NOT NULL
--select charge_type ,
-- actual_forward ,
-- currency ,
-- term_start ,
-- term_end ,
-- und_pnl_set ,
--market_value ,
--contract_value ,
--Amount ,
--cash_flow,* from #final_values where charge_type=''Commodity''
DELETE #final_values
WHERE charge_type = ''Commodity'' AND COALESCE(cash_flow, amount) IS NULL AND actual_forward = ''a''
IF Object_id(N''tempdb..#tmp_settlement_detail'') IS NOT NULL
	DROP TABLE #tmp_settlement_detail
SELECT fv.sub_id, fv.stra_id, fv.book_id, fv.subsidiary, fv.strategy, fv.book, fv.sub_book, fv.source_deal_header_id, ISNULL(fv.deal_ref_id, fv.reference) deal_ref_id, fv.deal_date_from, fv.deal_date_to, fv.trader_id, fv.trader_name, fv.counterparty_name, fv.parent_counterparty_name, fv.contract_id, fv.contract_name, fv.source_deal_type_id, fv.deal_type_name, fv.deal_sub_type_type_id, fv.deal_sub_type_name, fv.product_id, fv.commodity_id, fv.product_desc, fv.block_definition, fv.buy_sell_flag, fv.country_id, fv.country, fv.grid, fv.region_id, fv.region, fv.source_major_location_id, fv.location_group, fv.location_id, fv.location_name, fv.location_description, fv.from_as_of_date, fv.und_intrinsic_pnl, fv.und_extrinsic_pnl, fv.dis_pnl, fv.dis_intrinsic_pnl, fv.dis_extrinisic_pnl
	--isnull(sv.market_value ,fv.market_value) market_value,
	--isnull(sv.contract_value,fv.contract_value) contract_value,
	, fv.dis_market_value, fv.dis_contract_value, fv.discount_factor, fv.discount_amount, fv.commodity, fv.deal_volume, fv.volume_uom, fv.template_name, fv.curve_name, fv.index_tou, fv.formula, fv.total_volume, fv.position_uom, fv.cva, fv.dva, fv.market_price, fv.formula_price, fv.net_price, fv.physical_financial_flag, fv.block_definition_id, fv.leg, fv.source_counterparty_id, fv.counterparty_id, fv.index_id, fv.credit_adjusted_mtm, fv.discounted_credit_adjusted_mtm, fv.term_start_day, fv.term_start_month, fv.term_start_month_name, fv.term_start_year, fv.term_start_year_month, fv.term_quarter, fv.to_as_of_date, fv.sub_book_id, fv.transaction_type, fv.transaction_type_name, fv.period_from, fv.period_to, fv.probability, fv.credit_reserve, fv.dis_credit_reserve, fv.fair_value, fv.dis_fair_value, fv.model_reserve, fv.pnl_conversion_factor, fv.pnl_adjustment_value, fv.internal_deal_type_id, fv.internal_deal_type, fv.internal_deal_sub_type_id, fv.internal_deal_sub_type, fv.fixed_cost, fv.fixed_price, fv.formula_value, fv.price_adder, fv.
	price_multiplier, fv.strike_price, fv.formula_curve_id, fv.formula_curve_name, fv.internal_desk_id, fv.internal_desk, fv.internal_portfolio_id, fv.internal_portfolio, fv.broker_id, fv.broker_name, fv.type_of_entity_id, fv.type_of_entity, fv.int_ext_flag_id, fv.int_ext_flag, fv.deal_status_id, fv.deal_status, fv.confirm_status_id, fv.confirm_status, fv.pnl_source_value_id, fv.pnl_source_name, fv.description1, fv.description2, fv.description3, fv.description4, fv.counterparty_id2, fv.counterparty_name2, fv.ext_deal_id, fv.reference, fv.create_by, fv.create_ts, fv.update_by, fv.update_ts, fv.broker_fixed_cost, fv.confirm_date, fv.sub_book_group1_id, fv.sub_book_group2_id, fv.sub_book_group3_id, fv.sub_book_group4_id, fv.sub_book_group1, fv.sub_book_group2, fv.sub_book_group3, fv.sub_book_group4, fv.book_identifier1_id, fv.book_identifier2_id, fv.book_identifier3_id, fv.book_identifier4_id, fv.book_identifier1, fv.book_identifier2, fv.book_identifier3, fv.book_identifier4, fv.deal_price, fv.float_price, fv.Volume, fv.close_reference_id, 
	fv.agg_term, fv.recovery_rate, fv.fv_level, fv.current_non_current, fv.deal_category_id, fv.deal_category, fv.internal_counterparty_id, fv.internal_couterparty, fv.template_id, fv.volume_profile, fv.price_adder2, fv.volume_multiplier, fv.volume_multiplier2, fv.debt_rating, fv.volume_frequency, fv.currency_id, fv.is_expired, fv.entire_term_start, fv.entire_term_end, fv.contract_exipration_date, fv.structured_id, fv.payment_date, fv.pricing_type_id, fv.must_run_volume, fv.dispatch_volume, fv.must_run_market_value, fv.must_run_contract_value, fv.dispatch_market_value, fv.dispatch_contract_value, fv.charge_type_id, fv.charge_type, 
	fv.actual_forward, fv.currency, fv.term_start, fv.term_end, fv.und_pnl_set, fv.market_value, fv.contract_value, fv.Amount, fv.cash_flow, fv.pnl_date, CONVERT(VARCHAR(7), fv.pnl_date, 120) [PNL_year_month], CONVERT(VARCHAR(7), fv.payment_date, 120) [cash_flow_year_month], ISNULL(@_deal_status_group, '''') [deal_status_group], fv.pricing_type,fv.source_deal_detail_id
	,fv.invoice_currency, fv.deal_currency, fv.amount_inv, fv.amount_deal,
	fv.[reporting_group1],
	fv.[reporting_group2],
	fv.[reporting_group3],
	fv.[reporting_group4],
	fv.[reporting_group5],
	fv.[reporting_group1_name],
	fv.[reporting_group2_name],
	fv.[reporting_group3_name],
	fv.[reporting_group4_name],
	fv.[reporting_group5_name]
INTO #tmp_settlement_detail
FROM #final_values fv
IF Object_id(N''tempdb..#tmp_matched_ratio'') IS NOT NULL
	DROP TABLE #tmp_matched_ratio
SELECT tsd.source_deal_detail_id, (ISNULL(mdv.match_vol, mdv1.match_vol) / (ISNULL(mdv.match_vol, mdv1.match_vol) + ISNULL(mdv.buy_outstanding_vol, mdv1.sell_outstanding_vol))) match_ratio, (ISNULL(mdv.buy_outstanding_vol, mdv1.sell_outstanding_vol) / (ISNULL(mdv.match_vol, mdv1.match_vol) + ISNULL(mdv.buy_outstanding_vol, mdv1.sell_outstanding_vol))) AS outstanding_ratio, buy.buy_outstanding_vol, sell.sell_outstanding_vol
INTO #tmp_matched_ratio
FROM (
	SELECT DISTINCT source_deal_detail_id FROM #tmp_settlement_detail
) tsd
OUTER APPLY (
	SELECT SUM(match_vol) AS match_vol, MIN(buy_outstanding_vol) AS buy_outstanding_vol, MIN(buy_outstanding_vol) AS b_outstanding_vol
	FROM match_deal_volume mdv
	WHERE mdv.buy_source_deal_detail_id = tsd.source_deal_detail_id
	GROUP BY mdv.buy_source_deal_detail_id
	HAVING MIN(buy_outstanding_vol) > 0
) mdv
OUTER APPLY (
	SELECT SUM(match_vol) AS match_vol, MIN(sell_outstanding_vol) AS sell_outstanding_vol, MIN(sell_outstanding_vol) AS s_outstanding_vol
	FROM match_deal_volume mdv
	WHERE mdv.sell_source_deal_detail_id = tsd.source_deal_detail_id
	GROUP BY mdv.sell_source_deal_detail_id
	HAVING MIN(sell_outstanding_vol) > 0
) mdv1
OUTER APPLY (
	SELECT MIN(buy_outstanding_vol) AS buy_outstanding_vol
	FROM match_deal_volume mdv
	WHERE mdv.buy_source_deal_detail_id = tsd.source_deal_detail_id
) buy
OUTER APPLY (
	SELECT MIN(sell_outstanding_vol) AS sell_outstanding_vol
	FROM match_deal_volume mdv
	WHERE mdv.sell_source_deal_detail_id = tsd.source_deal_detail_id
) sell
SELECT tsd.sub_id
	,tsd.stra_id
	,tsd.book_id
	,tsd.subsidiary
	,tsd.strategy
	,tsd.book
	,tsd.sub_book
	,tsd.source_deal_header_id
	,ISNULL(tsd.deal_ref_id, tsd.reference) deal_ref_id
	,tsd.deal_date_from
	,tsd.deal_date_to
	,tsd.trader_id
	,tsd.trader_name
	,tsd.counterparty_name
	,tsd.parent_counterparty_name
	,tsd.contract_id
	,tsd.contract_name
	,tsd.source_deal_type_id
	,tsd.deal_type_name
	,tsd.deal_sub_type_type_id
	,tsd.deal_sub_type_name
	,tsd.product_id
	,tsd.commodity_id
	,tsd.product_desc
	,tsd.block_definition
	,tsd.buy_sell_flag
	,tsd.country_id
	,tsd.country
	,tsd.grid
	,tsd.region_id
	,tsd.region
	,tsd.source_major_location_id
	,tsd.location_group
	,tsd.location_id
	,tsd.location_name
	,tsd.location_description
	,tsd.from_as_of_date
	,tsd.und_intrinsic_pnl
	,tsd.und_extrinsic_pnl
	,tsd.dis_pnl
	,tsd.dis_intrinsic_pnl
	,tsd.dis_extrinisic_pnl
	--isnull(sv.market_value ,tsd.market_value)  market_value,
	--isnull(sv.contract_value,tsd.contract_value) contract_value,
	,(tsd.dis_market_value * ISNULL(t.match_ratio, 1)) dis_market_value
	,(tsd.dis_contract_value * ISNULL(t.match_ratio, 1)) dis_contract_value
	,tsd.discount_factor
	,tsd.discount_amount
	,tsd.commodity
	,(tsd.deal_volume * ISNULL(t.match_ratio, 1)) deal_volume
	,tsd.volume_uom
	,tsd.template_name
	,tsd.curve_name
	,tsd.index_tou
	,tsd.formula
	,CASE WHEN tsd.buy_sell_flag = ''Sell'' THEN -1 ELSE 1 END * ABS(tsd.total_volume * ISNULL(t.match_ratio, 1)) total_volume
	,tsd.position_uom
	,tsd.cva
	,tsd.dva
	,tsd.market_price
	,tsd.formula_price
	,CASE WHEN tsd.buy_sell_flag = ''Sell'' THEN -1 ELSE 1 END * ABS(tsd.net_price) net_price
	,tsd.physical_financial_flag
	,tsd.block_definition_id
	,tsd.leg
	,tsd.source_counterparty_id
	,tsd.counterparty_id
	,tsd.index_id
	,tsd.credit_adjusted_mtm
	,tsd.discounted_credit_adjusted_mtm
	,tsd.term_start_day
	,tsd.term_start_month
	,tsd.term_start_month_name
	,tsd.term_start_year
	,tsd.term_start_year_month
	,tsd.term_quarter
	,tsd.to_as_of_date
	,tsd.sub_book_id
	,tsd.transaction_type
	,tsd.transaction_type_name
	,tsd.period_from
	,tsd.period_to
	,tsd.probability
	,tsd.credit_reserve
	,tsd.dis_credit_reserve
	,tsd.fair_value
	,tsd.dis_fair_value
	,tsd.model_reserve
	,tsd.pnl_conversion_factor
	,tsd.pnl_adjustment_value
	,tsd.internal_deal_type_id
	,tsd.internal_deal_type
	,tsd.internal_deal_sub_type_id
	,tsd.internal_deal_sub_type
	,tsd.fixed_cost
	,tsd.fixed_price
	,tsd.formula_value
	,tsd.price_adder
	,tsd.price_multiplier
	,tsd.strike_price
	,tsd.formula_curve_id
	,tsd.formula_curve_name
	,tsd.internal_desk_id
	,tsd.internal_desk
	,tsd.internal_portfolio_id
	,tsd.internal_portfolio
	,tsd.broker_id
	,tsd.broker_name
	,tsd.type_of_entity_id
	,tsd.type_of_entity
	,tsd.int_ext_flag_id
	,tsd.int_ext_flag
	,tsd.deal_status_id
	,tsd.deal_status AS deal_status_name
	,tsd.confirm_status_id
	,tsd.confirm_status
	,tsd.pnl_source_value_id
	,tsd.pnl_source_name
	,tsd.description1
	,tsd.description2
	,tsd.description3
	,tsd.description4
	,tsd.counterparty_id2
	,tsd.counterparty_name2
	,tsd.ext_deal_id
	,tsd.reference
	,tsd.create_by
	,tsd.create_ts
	,tsd.update_by
	,tsd.update_ts
	,tsd.broker_fixed_cost
	,tsd.confirm_date
	,tsd.sub_book_group1_id
	,tsd.sub_book_group2_id
	,tsd.sub_book_group3_id
	,tsd.sub_book_group4_id
	,tsd.sub_book_group1
	,tsd.sub_book_group2
	,tsd.sub_book_group3
	,tsd.sub_book_group4
	,tsd.book_identifier1_id
	,tsd.book_identifier2_id
	,tsd.book_identifier3_id
	,tsd.book_identifier4_id
	,tsd.book_identifier1
	,tsd.book_identifier2
	,tsd.book_identifier3
	,tsd.book_identifier4
	,tsd.deal_price
	,tsd.float_price
	,tsd.Volume
	,tsd.close_reference_id
	,tsd.agg_term
	,tsd.recovery_rate
	,tsd.fv_level
	,tsd.current_non_current
	,tsd.deal_category_id
	,tsd.deal_category
	,tsd.internal_counterparty_id
	,tsd.internal_couterparty
	,tsd.template_id
	,tsd.volume_profile
	,tsd.price_adder2
	,tsd.volume_multiplier
	,tsd.volume_multiplier2
	,tsd.debt_rating
	,tsd.volume_frequency
	,tsd.currency_id
	,tsd.is_expired
	,tsd.entire_term_start
	,tsd.entire_term_end
	,tsd.contract_exipration_date
	,tsd.structured_id
	,tsd.payment_date
	,tsd.pricing_type_id
	,tsd.must_run_volume
	,tsd.dispatch_volume
	,tsd.must_run_market_value
	,tsd.must_run_contract_value
	,tsd.dispatch_market_value
	,tsd.dispatch_contract_value
	,tsd.charge_type_id
	,tsd.charge_type
	,CASE WHEN t.actual_forward IS NOT NULL THEN t.actual_forward WHEN COALESCE(t1.buy_outstanding_vol, t1.sell_outstanding_vol, 1) < 1 THEN ''a'' ELSE tsd.actual_forward END AS actual_forward
	,tsd.currency
	,tsd.term_start
	,tsd.term_end
	,tsd.und_pnl_set
	,(tsd.market_value * ISNULL(t.match_ratio, 1)) market_value
	,(tsd.contract_value * ISNULL(t.match_ratio, 1)) contract_value
	,(tsd.Amount * ISNULL(t.match_ratio, 1)) Amount
	,(tsd.cash_flow * ISNULL(t.match_ratio, 1)) cash_flow
	,tsd.pnl_date
	,CONVERT(VARCHAR(7), tsd.pnl_date, 120) [PNL_year_month]
	,CONVERT(VARCHAR(7), tsd.payment_date, 120) [cash_flow_year_month]
	,ISNULL(@_deal_status_group,'''') [deal_status_group]
	,tsd.pricing_type
	,ISNULL(@_cur_type,''f'') [Cur_type]
	, tsd.invoice_currency
	, tsd.deal_currency
	, tsd.amount_inv
	, tsd.amount_deal
	, tsd.[reporting_group1] 
	, tsd.[reporting_group2] 
	, tsd.[reporting_group3] 
	, tsd.[reporting_group4] 
	, tsd.[reporting_group5] 
	, tsd.[reporting_group1_name] 
	, tsd.[reporting_group2_name] 
	, tsd.[reporting_group3_name] 
	, tsd.[reporting_group4_name] 
	, tsd.[reporting_group5_name] 
 INTO #tmp_final_data
FROM #tmp_settlement_detail tsd
OUTER APPLY (
	SELECT source_deal_detail_id, match_ratio, ''a'' actual_forward
	FROM #tmp_matched_ratio tmr
	WHERE tmr.source_deal_detail_id = tsd.source_deal_detail_id AND match_ratio > 0 --AND ((tsd.buy_sell_flag = ''b'' AND tmr.b_outstanding_vol > 0) OR
		--(tsd.buy_sell_flag = ''s'' AND tmr.s_outstanding_vol > 0))
	UNION ALL
	SELECT source_deal_detail_id, outstanding_ratio, ''f'' actual_forward
	FROM #tmp_matched_ratio tmr
	WHERE tmr.source_deal_detail_id = tsd.source_deal_detail_id AND outstanding_ratio > 0 --AND ((tsd.buy_sell_flag = ''b'' AND tmr.b_outstanding_vol > 0) OR
		--(tsd.buy_sell_flag = ''s'' AND tmr.s_outstanding_vol > 0))
) t
OUTER APPLY (
	SELECT * FROM #tmp_matched_ratio tmr WHERE tmr.source_deal_detail_id = tsd.source_deal_detail_id
) t1
SELECT   sub_id
		, stra_id
		, book_id
		, subsidiary
		, strategy
		, book
		, sub_book
		, source_deal_header_id
		, deal_ref_id
		, deal_date_from
		, deal_date_to
		, trader_id
		, trader_name
		, counterparty_name
		, parent_counterparty_name
		, contract_id
		, [contract_name]
		, source_deal_type_id
		, deal_type_name
		, deal_sub_type_type_id
		, deal_sub_type_name
		, product_id
		, commodity_id
		, product_desc
		, block_definition
		, buy_sell_flag
		, country_id
		, country
		, grid
		, region_id
		, region
		, source_major_location_id
		, location_group
		, location_id
		, location_name
		, location_description
		, from_as_of_date
		, und_intrinsic_pnl
		, und_extrinsic_pnl
		, dis_pnl
		, dis_intrinsic_pnl
		, dis_extrinisic_pnl
		, dis_market_value
		, dis_contract_value
		, discount_factor
		, discount_amount
		, commodity
		, deal_volume
		, volume_uom
		, template_name
		, curve_name
		, index_tou
		, formula
		, total_volume
		, position_uom
		, cva
		, dva
		, market_price
		, formula_price
		, net_price
		, physical_financial_flag
		, block_definition_id
		, leg
		, source_counterparty_id
		, counterparty_id
		, index_id
		, credit_adjusted_mtm
		, discounted_credit_adjusted_mtm
		, term_start_day
		, term_start_month
		, term_start_month_name
		, term_start_year
		, term_start_year_month
		, term_quarter
		, to_as_of_date
		, sub_book_id
		, transaction_type
		, transaction_type_name
		, period_from
		, period_to
		, probability
		, credit_reserve
		, dis_credit_reserve
		, fair_value
		, dis_fair_value
		, model_reserve
		, pnl_conversion_factor
		, pnl_adjustment_value
		, internal_deal_type_id
		, internal_deal_type
		, internal_deal_sub_type_id
		, internal_deal_sub_type
		, fixed_cost
		, fixed_price
		, formula_value
		, price_adder
		, price_multiplier
		, strike_price
		, formula_curve_id
		, formula_curve_name
		, internal_desk_id
		, internal_desk
		, internal_portfolio_id
		, internal_portfolio
		, broker_id
		, broker_name
		, type_of_entity_id
		, type_of_entity
		, int_ext_flag_id
		, int_ext_flag
		, deal_status_id
		, deal_status_name
		, confirm_status_id
		, confirm_status
		, pnl_source_value_id
		, pnl_source_name
		, description1
		, description2
		, description3
		, description4
		, counterparty_id2
		, counterparty_name2
		, ext_deal_id
		, reference
		, create_by
		, create_ts
		, update_by
		, update_ts
		, broker_fixed_cost
		, confirm_date
		, sub_book_group1_id
		, sub_book_group2_id
		, sub_book_group3_id
		, sub_book_group4_id
		, sub_book_group1
		, sub_book_group2
		, sub_book_group3
		, sub_book_group4
		, book_identifier1_id
		, book_identifier2_id
		, book_identifier3_id
		, book_identifier4_id
		, book_identifier1
		, book_identifier2
		, book_identifier3
		, book_identifier4
		, deal_price
		, float_price
		, CASE WHEN charge_type =''Positive Price Commodity''  AND buy_sell_flag = ''Buy'' THEN ABS(Volume)
			  WHEN charge_type =''Positive Price Commodity''  AND buy_sell_flag = ''Sell'' THEN (ABS(Volume)*-1)
			  WHEN charge_type =''Negative Price Commodity''  AND buy_sell_flag = ''Buy'' THEN ABS(Volume)
			  WHEN charge_type =''Negative Price Commodity''  AND buy_sell_flag = ''Sell'' THEN (ABS(Volume)*-1) 
			  WHEN charge_type =''Commodity''  AND buy_sell_flag = ''Buy'' THEN ABS(Volume)
			  WHEN charge_type =''Commodity''  AND buy_sell_flag = ''Sell'' THEN (ABS(Volume)*-1)
		  ELSE Volume END Volume
		, close_reference_id
		, agg_term
		, recovery_rate
		, fv_level
		, current_non_current
		, deal_category_id
		, deal_category
		, internal_counterparty_id
		, internal_couterparty
		, template_id
		, volume_profile
		, price_adder2
		, volume_multiplier
		, volume_multiplier2
		, debt_rating
		, volume_frequency
		, currency_id
		, is_expired
		, entire_term_start
		, entire_term_end
		, contract_exipration_date
		, structured_id
		, payment_date
		, pricing_type_id
		, must_run_volume
		, dispatch_volume
		, must_run_market_value
		, must_run_contract_value
		, dispatch_market_value
		, dispatch_contract_value
		, charge_type_id
		, charge_type
		, actual_forward
		, currency
		, term_start
		, term_end
		, und_pnl_set
		, market_value
		, contract_value
		, Amount
		, cash_flow
		, pnl_date
		, PNL_year_month
		, cash_flow_year_month
		, deal_status_group
		, pricing_type
		, Cur_type
		, invoice_currency
		, deal_currency
		, amount_inv
		, amount_deal
		, reporting_group1
		, reporting_group2
		, reporting_group3
		, reporting_group4
		, reporting_group5
		, reporting_group1_name
		, reporting_group2_name
		, reporting_group3_name
		, reporting_group4_name
		, reporting_group5_name
		, CASE
		WHEN charge_type =''Positive Price Commodity''  AND buy_sell_flag = ''Buy'' THEN (ABS(IIF(actual_forward= ''f'', IIF(ISNULL(deal_type_name, ''Non'') = ''Physical'', ABS(contract_value), ABS(und_pnl_set) ),ABS(contract_value)))*-1)
		WHEN charge_type =''Positive Price Commodity''  AND buy_sell_flag = ''Sell'' THEN ABS(IIF(actual_forward= ''f'', IIF(ISNULL(deal_type_name, ''Non'') = ''Physical'', ABS(contract_value), ABS(und_pnl_set) ),ABS(contract_value)))
		  WHEN charge_type =''Negative Price Commodity'' AND buy_sell_flag = ''Buy'' THEN ABS(IIF(actual_forward= ''f'', IIF(ISNULL(deal_type_name, ''Non'') = ''Physical'', ABS(contract_value), ABS(und_pnl_set) ),ABS(contract_value)))
		  WHEN charge_type =''Negative Price Commodity''  AND buy_sell_flag = ''Sell'' THEN (ABS(IIF(actual_forward= ''f'', IIF(ISNULL(deal_type_name, ''Non'') = ''Physical'', ABS(contract_value), ABS(und_pnl_set) ),ABS(contract_value))) *-1)
		  WHEN charge_type =''Commodity''  AND buy_sell_flag = ''Buy'' THEN (ABS(IIF(actual_forward= ''f'', IIF(ISNULL(deal_type_name, ''Non'') = ''Physical'', ABS(contract_value), ABS(und_pnl_set) ),ABS(contract_value)))*-1)
		WHEN charge_type =''Commodity''  AND buy_sell_flag = ''Sell'' THEN ABS(IIF(actual_forward= ''f'', IIF(ISNULL(deal_type_name, ''Non'') = ''Physical'', ABS(contract_value), ABS(und_pnl_set) ),ABS(contract_value)))
		  ELSE (IIF(actual_forward= ''f'', IIF(ISNULL(deal_type_name, ''Non'') = ''Physical'', contract_value,und_pnl_set),contract_value)) END pnl
		 , CASE
		WHEN charge_type =''Positive Price Commodity'' AND buy_sell_flag = ''Buy'' THEN (ABS(IIF(actual_forward= ''f'', IIF(ISNULL(deal_type_name, ''Non'') = ''Physical'', ABS(contract_value), ABS(und_pnl_set) ),ABS(contract_value)))*-1)/ NULLIF((ABS(Volume)*-1),0)
		WHEN charge_type =''Positive Price Commodity''  AND buy_sell_flag = ''Sell'' THEN ABS(IIF(actual_forward= ''f'', IIF(ISNULL(deal_type_name, ''Non'') = ''Physical'', ABS(contract_value), ABS(und_pnl_set) ),ABS(contract_value))) / (NULLIF((ABS(Volume)*-1),0)*-1)
		  WHEN charge_type =''Negative Price Commodity'' AND buy_sell_flag = ''Buy'' THEN ABS(IIF(actual_forward= ''f'', IIF(ISNULL(deal_type_name, ''Non'') = ''Physical'', ABS(contract_value), ABS(und_pnl_set) ),ABS(contract_value)))/ NULLIF((ABS(Volume)*-1),0) 
		  WHEN charge_type =''Negative Price Commodity''  AND buy_sell_flag = ''Sell'' THEN (ABS(IIF(actual_forward= ''f'', IIF(ISNULL(deal_type_name, ''Non'') = ''Physical'', ABS(contract_value), ABS(und_pnl_set) ),ABS(contract_value))) *-1)/ (NULLIF((ABS(Volume)*-1),0)*-1)
		  WHEN charge_type =''Commodity'' AND buy_sell_flag = ''Buy'' THEN (ABS(IIF(actual_forward= ''f'', IIF(ISNULL(deal_type_name, ''Non'') = ''Physical'', ABS(contract_value), ABS(und_pnl_set) ),ABS(contract_value)))*-1)/ NULLIF((ABS(Volume)*-1),0)
		WHEN charge_type =''Commodity''  AND buy_sell_flag = ''Sell'' THEN ABS(IIF(actual_forward= ''f'', IIF(ISNULL(deal_type_name, ''Non'') = ''Physical'', ABS(contract_value), ABS(und_pnl_set) ),ABS(contract_value))) / (NULLIF((ABS(Volume)*-1),0)*-1)
		  ELSE ABS(IIF(actual_forward= ''f'', IIF(ISNULL(deal_type_name, ''Non'') = ''Physical'', contract_value,und_pnl_set),contract_value))/NULLIF((ABS(Volume)*-1),0) END [price]
	--[__batch_report__]  
FROM #tmp_final_data', report_id = @report_id_data_source_dest,
	system_defined = '1'
	,category = '106500' 
	WHERE [name] = 'Enercity Settlement Mega View'
		AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1)
		
	
	IF OBJECT_ID('tempdb..#data_source_column', 'U') IS NOT NULL
		DROP TABLE #data_source_column	
	CREATE TABLE #data_source_column(column_id INT)	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Mega View'
	            AND dsc.name =  'block_definition'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Block Definition'
			   , reqd_param = 0, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Mega View'
			AND dsc.name =  'block_definition'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'block_definition' AS [name], 'Block Definition' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Mega View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Mega View'
	            AND dsc.name =  'block_definition_id'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Block Definition ID'
			   , reqd_param = 1, widget_id = 9, datatype_id = 4, param_data_source = 'EXEC spa_StaticDataValues @flag = ''h'', @type_id = 10018', param_default_value = NULL, append_filter = 0, tooltip = NULL, column_template = 2, key_column = 0, required_filter = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Mega View'
			AND dsc.name =  'block_definition_id'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'block_definition_id' AS [name], 'Block Definition ID' AS ALIAS, 1 AS reqd_param, 9 AS widget_id, 4 AS datatype_id, 'EXEC spa_StaticDataValues @flag = ''h'', @type_id = 10018' AS param_data_source, NULL AS param_default_value, 0 AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column, 0 AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Mega View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Mega View'
	            AND dsc.name =  'book'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Book'
			   , reqd_param = 0, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Mega View'
			AND dsc.name =  'book'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'book' AS [name], 'Book' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Mega View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Mega View'
	            AND dsc.name =  'book_id'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Book ID'
			   , reqd_param = 1, widget_id = 5, datatype_id = 4, param_data_source = NULL, param_default_value = NULL, append_filter = 0, tooltip = NULL, column_template = 2, key_column = 0, required_filter = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Mega View'
			AND dsc.name =  'book_id'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'book_id' AS [name], 'Book ID' AS ALIAS, 1 AS reqd_param, 5 AS widget_id, 4 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 0 AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column, 0 AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Mega View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Mega View'
	            AND dsc.name =  'broker_fixed_cost'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Broker Fixed Cost'
			   , reqd_param = 0, widget_id = 1, datatype_id = 3, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 2, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Mega View'
			AND dsc.name =  'broker_fixed_cost'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'broker_fixed_cost' AS [name], 'Broker Fixed Cost' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 3 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Mega View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Mega View'
	            AND dsc.name =  'broker_id'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Broker ID'
			   , reqd_param = 0, widget_id = 9, datatype_id = 4, param_data_source = 'EXEC spa_source_counterparty_maintain ''c'', @int_ext_flag=''b''', param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 2, key_column = 0, required_filter = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Mega View'
			AND dsc.name =  'broker_id'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'broker_id' AS [name], 'Broker ID' AS ALIAS, 0 AS reqd_param, 9 AS widget_id, 4 AS datatype_id, 'EXEC spa_source_counterparty_maintain ''c'', @int_ext_flag=''b''' AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column, 0 AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Mega View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Mega View'
	            AND dsc.name =  'broker_name'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Broker'
			   , reqd_param = 0, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Mega View'
			AND dsc.name =  'broker_name'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'broker_name' AS [name], 'Broker' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Mega View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Mega View'
	            AND dsc.name =  'buy_sell_flag'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Buy/Sell'
			   , reqd_param = 1, widget_id = 2, datatype_id = 5, param_data_source = 'SELECT ''b'' as value,''Buy'' as Code' + CHAR(10) + 'UNION' + CHAR(10) + 'SELECT ''s'' as value, ''Sell'' as Code', param_default_value = NULL, append_filter = 0, tooltip = NULL, column_template = 0, key_column = 0, required_filter = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Mega View'
			AND dsc.name =  'buy_sell_flag'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'buy_sell_flag' AS [name], 'Buy/Sell' AS ALIAS, 1 AS reqd_param, 2 AS widget_id, 5 AS datatype_id, 'SELECT ''b'' as value,''Buy'' as Code' + CHAR(10) + 'UNION' + CHAR(10) + 'SELECT ''s'' as value, ''Sell'' as Code' AS param_data_source, NULL AS param_default_value, 0 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, 0 AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Mega View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Mega View'
	            AND dsc.name =  'commodity'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Commodity'
			   , reqd_param = 0, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Mega View'
			AND dsc.name =  'commodity'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'commodity' AS [name], 'Commodity' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Mega View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Mega View'
	            AND dsc.name =  'commodity_id'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Commodity ID'
			   , reqd_param = 1, widget_id = 9, datatype_id = 4, param_data_source = 'exec spa_source_commodity_maintain ''a''', param_default_value = NULL, append_filter = 0, tooltip = NULL, column_template = 2, key_column = 1, required_filter = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Mega View'
			AND dsc.name =  'commodity_id'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'commodity_id' AS [name], 'Commodity ID' AS ALIAS, 1 AS reqd_param, 9 AS widget_id, 4 AS datatype_id, 'exec spa_source_commodity_maintain ''a''' AS param_data_source, NULL AS param_default_value, 0 AS append_filter, NULL  AS tooltip,2 AS column_template, 1 AS key_column, 0 AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Mega View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Mega View'
	            AND dsc.name =  'confirm_date'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Confirm Date'
			   , reqd_param = 0, widget_id = 6, datatype_id = 2, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 4, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Mega View'
			AND dsc.name =  'confirm_date'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'confirm_date' AS [name], 'Confirm Date' AS ALIAS, 0 AS reqd_param, 6 AS widget_id, 2 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,4 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Mega View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Mega View'
	            AND dsc.name =  'confirm_status'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Confirm Status'
			   , reqd_param = 0, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Mega View'
			AND dsc.name =  'confirm_status'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'confirm_status' AS [name], 'Confirm Status' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Mega View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Mega View'
	            AND dsc.name =  'confirm_status_id'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Confirm Status ID'
			   , reqd_param = 1, widget_id = 9, datatype_id = 4, param_data_source = 'EXEC spa_StaticDataValues @flag = ''h'', @type_id = 17200', param_default_value = NULL, append_filter = 0, tooltip = NULL, column_template = 2, key_column = 0, required_filter = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Mega View'
			AND dsc.name =  'confirm_status_id'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'confirm_status_id' AS [name], 'Confirm Status ID' AS ALIAS, 1 AS reqd_param, 9 AS widget_id, 4 AS datatype_id, 'EXEC spa_StaticDataValues @flag = ''h'', @type_id = 17200' AS param_data_source, NULL AS param_default_value, 0 AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column, 0 AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Mega View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Mega View'
	            AND dsc.name =  'contract_id'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Contract ID'
			   , reqd_param = 1, widget_id = 7, datatype_id = 4, param_data_source = 'browse_contract_counterparty', param_default_value = NULL, append_filter = 0, tooltip = NULL, column_template = 2, key_column = 1, required_filter = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Mega View'
			AND dsc.name =  'contract_id'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'contract_id' AS [name], 'Contract ID' AS ALIAS, 1 AS reqd_param, 7 AS widget_id, 4 AS datatype_id, 'browse_contract_counterparty' AS param_data_source, NULL AS param_default_value, 0 AS append_filter, NULL  AS tooltip,2 AS column_template, 1 AS key_column, 0 AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Mega View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Mega View'
	            AND dsc.name =  'contract_name'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Contract'
			   , reqd_param = 0, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Mega View'
			AND dsc.name =  'contract_name'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'contract_name' AS [name], 'Contract' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Mega View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Mega View'
	            AND dsc.name =  'contract_value'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Contract Value'
			   , reqd_param = 0, widget_id = 1, datatype_id = 3, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 2, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Mega View'
			AND dsc.name =  'contract_value'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'contract_value' AS [name], 'Contract Value' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 3 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Mega View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Mega View'
	            AND dsc.name =  'counterparty_id'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Counterparty Code'
			   , reqd_param = 0, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 1, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Mega View'
			AND dsc.name =  'counterparty_id'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'counterparty_id' AS [name], 'Counterparty Code' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,0 AS column_template, 1 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Mega View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Mega View'
	            AND dsc.name =  'counterparty_id2'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Counterparty ID2'
			   , reqd_param = 0, widget_id = 1, datatype_id = 4, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 2, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Mega View'
			AND dsc.name =  'counterparty_id2'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'counterparty_id2' AS [name], 'Counterparty ID2' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 4 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Mega View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Mega View'
	            AND dsc.name =  'counterparty_name'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Counterparty'
			   , reqd_param = 0, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Mega View'
			AND dsc.name =  'counterparty_name'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'counterparty_name' AS [name], 'Counterparty' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Mega View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Mega View'
	            AND dsc.name =  'counterparty_name2'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Counterparty 2'
			   , reqd_param = 0, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Mega View'
			AND dsc.name =  'counterparty_name2'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'counterparty_name2' AS [name], 'Counterparty 2' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Mega View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Mega View'
	            AND dsc.name =  'country'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Country'
			   , reqd_param = 0, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Mega View'
			AND dsc.name =  'country'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'country' AS [name], 'Country' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Mega View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Mega View'
	            AND dsc.name =  'country_id'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Country ID'
			   , reqd_param = 0, widget_id = 9, datatype_id = 4, param_data_source = 'EXEC spa_StaticDataValues ''h'', 14000', param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 2, key_column = 0, required_filter = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Mega View'
			AND dsc.name =  'country_id'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'country_id' AS [name], 'Country ID' AS ALIAS, 0 AS reqd_param, 9 AS widget_id, 4 AS datatype_id, 'EXEC spa_StaticDataValues ''h'', 14000' AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column, 0 AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Mega View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Mega View'
	            AND dsc.name =  'create_by'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Created By'
			   , reqd_param = 0, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Mega View'
			AND dsc.name =  'create_by'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'create_by' AS [name], 'Created By' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Mega View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Mega View'
	            AND dsc.name =  'create_ts'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Created Date'
			   , reqd_param = 0, widget_id = 6, datatype_id = 2, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 4, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Mega View'
			AND dsc.name =  'create_ts'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'create_ts' AS [name], 'Created Date' AS ALIAS, 0 AS reqd_param, 6 AS widget_id, 2 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,4 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Mega View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Mega View'
	            AND dsc.name =  'credit_adjusted_mtm'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Credit Adjusted MTM'
			   , reqd_param = 0, widget_id = 1, datatype_id = 3, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 2, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Mega View'
			AND dsc.name =  'credit_adjusted_mtm'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'credit_adjusted_mtm' AS [name], 'Credit Adjusted MTM' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 3 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Mega View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Mega View'
	            AND dsc.name =  'credit_reserve'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Credit Reserve'
			   , reqd_param = 0, widget_id = 1, datatype_id = 3, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 2, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Mega View'
			AND dsc.name =  'credit_reserve'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'credit_reserve' AS [name], 'Credit Reserve' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 3 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Mega View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Mega View'
	            AND dsc.name =  'currency'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Currency'
			   , reqd_param = 0, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Mega View'
			AND dsc.name =  'currency'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'currency' AS [name], 'Currency' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Mega View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Mega View'
	            AND dsc.name =  'current_non_current'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Current/Non Current'
			   , reqd_param = 0, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Mega View'
			AND dsc.name =  'current_non_current'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'current_non_current' AS [name], 'Current/Non Current' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Mega View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Mega View'
	            AND dsc.name =  'curve_name'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Index'
			   , reqd_param = 0, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Mega View'
			AND dsc.name =  'curve_name'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'curve_name' AS [name], 'Index' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Mega View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Mega View'
	            AND dsc.name =  'cva'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'CVA'
			   , reqd_param = 0, widget_id = 1, datatype_id = 3, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 2, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Mega View'
			AND dsc.name =  'cva'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'cva' AS [name], 'CVA' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 3 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Mega View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Mega View'
	            AND dsc.name =  'deal_date_from'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Deal Date From'
			   , reqd_param = 1, widget_id = 6, datatype_id = 2, param_data_source = NULL, param_default_value = NULL, append_filter = 0, tooltip = NULL, column_template = 4, key_column = 0, required_filter = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Mega View'
			AND dsc.name =  'deal_date_from'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'deal_date_from' AS [name], 'Deal Date From' AS ALIAS, 1 AS reqd_param, 6 AS widget_id, 2 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 0 AS append_filter, NULL  AS tooltip,4 AS column_template, 0 AS key_column, 0 AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Mega View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Mega View'
	            AND dsc.name =  'deal_date_to'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Deal Date To'
			   , reqd_param = 1, widget_id = 6, datatype_id = 2, param_data_source = NULL, param_default_value = NULL, append_filter = 0, tooltip = NULL, column_template = 4, key_column = 0, required_filter = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Mega View'
			AND dsc.name =  'deal_date_to'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'deal_date_to' AS [name], 'Deal Date To' AS ALIAS, 1 AS reqd_param, 6 AS widget_id, 2 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 0 AS append_filter, NULL  AS tooltip,4 AS column_template, 0 AS key_column, 0 AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Mega View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Mega View'
	            AND dsc.name =  'deal_ref_id'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Deal Reference ID'
			   , reqd_param = 1, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 0, tooltip = NULL, column_template = 0, key_column = 0, required_filter = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Mega View'
			AND dsc.name =  'deal_ref_id'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'deal_ref_id' AS [name], 'Deal Reference ID' AS ALIAS, 1 AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 0 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, 0 AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Mega View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Mega View'
	            AND dsc.name =  'deal_status_id'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Deal Status ID'
			   , reqd_param = 1, widget_id = 9, datatype_id = 4, param_data_source = 'EXEC spa_StaticDataValues @flag = ''h'', @type_id = 5600', param_default_value = NULL, append_filter = 0, tooltip = NULL, column_template = 2, key_column = 0, required_filter = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Mega View'
			AND dsc.name =  'deal_status_id'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'deal_status_id' AS [name], 'Deal Status ID' AS ALIAS, 1 AS reqd_param, 9 AS widget_id, 4 AS datatype_id, 'EXEC spa_StaticDataValues @flag = ''h'', @type_id = 5600' AS param_data_source, NULL AS param_default_value, 0 AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column, 0 AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Mega View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Mega View'
	            AND dsc.name =  'deal_sub_type_name'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Deal Sub Type'
			   , reqd_param = 0, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Mega View'
			AND dsc.name =  'deal_sub_type_name'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'deal_sub_type_name' AS [name], 'Deal Sub Type' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Mega View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Mega View'
	            AND dsc.name =  'deal_sub_type_type_id'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Deal Sub Type ID'
			   , reqd_param = 1, widget_id = 9, datatype_id = 4, param_data_source = 'exec spa_source_deal_type_maintain ''x'',@sub_type=''y''', param_default_value = NULL, append_filter = 0, tooltip = NULL, column_template = 2, key_column = 0, required_filter = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Mega View'
			AND dsc.name =  'deal_sub_type_type_id'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'deal_sub_type_type_id' AS [name], 'Deal Sub Type ID' AS ALIAS, 1 AS reqd_param, 9 AS widget_id, 4 AS datatype_id, 'exec spa_source_deal_type_maintain ''x'',@sub_type=''y''' AS param_data_source, NULL AS param_default_value, 0 AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column, 0 AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Mega View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Mega View'
	            AND dsc.name =  'deal_type_name'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Deal Type'
			   , reqd_param = 0, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Mega View'
			AND dsc.name =  'deal_type_name'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'deal_type_name' AS [name], 'Deal Type' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Mega View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Mega View'
	            AND dsc.name =  'deal_volume'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Deal Volume'
			   , reqd_param = 0, widget_id = 1, datatype_id = 3, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 2, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Mega View'
			AND dsc.name =  'deal_volume'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'deal_volume' AS [name], 'Deal Volume' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 3 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Mega View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Mega View'
	            AND dsc.name =  'description1'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Description1'
			   , reqd_param = 0, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Mega View'
			AND dsc.name =  'description1'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'description1' AS [name], 'Description1' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Mega View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Mega View'
	            AND dsc.name =  'description2'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Description2'
			   , reqd_param = 0, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Mega View'
			AND dsc.name =  'description2'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'description2' AS [name], 'Description2' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Mega View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Mega View'
	            AND dsc.name =  'description3'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Description3'
			   , reqd_param = 0, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Mega View'
			AND dsc.name =  'description3'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'description3' AS [name], 'Description3' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Mega View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Mega View'
	            AND dsc.name =  'description4'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Description4'
			   , reqd_param = 0, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Mega View'
			AND dsc.name =  'description4'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'description4' AS [name], 'Description4' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Mega View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Mega View'
	            AND dsc.name =  'dis_contract_value'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Dis Contract Value'
			   , reqd_param = 0, widget_id = 1, datatype_id = 3, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 2, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Mega View'
			AND dsc.name =  'dis_contract_value'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'dis_contract_value' AS [name], 'Dis Contract Value' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 3 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Mega View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Mega View'
	            AND dsc.name =  'dis_credit_reserve'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Dis Credit Reserve'
			   , reqd_param = 0, widget_id = 1, datatype_id = 3, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 2, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Mega View'
			AND dsc.name =  'dis_credit_reserve'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'dis_credit_reserve' AS [name], 'Dis Credit Reserve' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 3 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Mega View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Mega View'
	            AND dsc.name =  'dis_extrinisic_pnl'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Dis Extrinisic MTM'
			   , reqd_param = 0, widget_id = 1, datatype_id = 3, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 2, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Mega View'
			AND dsc.name =  'dis_extrinisic_pnl'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'dis_extrinisic_pnl' AS [name], 'Dis Extrinisic MTM' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 3 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Mega View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Mega View'
	            AND dsc.name =  'dis_fair_value'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Dis Fair Value'
			   , reqd_param = 0, widget_id = 1, datatype_id = 3, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 2, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Mega View'
			AND dsc.name =  'dis_fair_value'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'dis_fair_value' AS [name], 'Dis Fair Value' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 3 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Mega View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Mega View'
	            AND dsc.name =  'dis_intrinsic_pnl'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Dis Intrinsic MTM'
			   , reqd_param = 0, widget_id = 1, datatype_id = 3, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 2, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Mega View'
			AND dsc.name =  'dis_intrinsic_pnl'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'dis_intrinsic_pnl' AS [name], 'Dis Intrinsic MTM' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 3 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Mega View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Mega View'
	            AND dsc.name =  'dis_market_value'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Dis Market Value'
			   , reqd_param = 0, widget_id = 1, datatype_id = 3, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 2, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Mega View'
			AND dsc.name =  'dis_market_value'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'dis_market_value' AS [name], 'Dis Market Value' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 3 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Mega View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Mega View'
	            AND dsc.name =  'dis_pnl'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Dis MTM'
			   , reqd_param = 0, widget_id = 1, datatype_id = 3, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 2, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Mega View'
			AND dsc.name =  'dis_pnl'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'dis_pnl' AS [name], 'Dis MTM' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 3 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Mega View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Mega View'
	            AND dsc.name =  'discount_amount'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Discount Amount'
			   , reqd_param = 0, widget_id = 1, datatype_id = 3, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 2, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Mega View'
			AND dsc.name =  'discount_amount'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'discount_amount' AS [name], 'Discount Amount' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 3 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Mega View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Mega View'
	            AND dsc.name =  'discount_factor'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Discount Factor'
			   , reqd_param = 0, widget_id = 1, datatype_id = 3, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 2, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Mega View'
			AND dsc.name =  'discount_factor'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'discount_factor' AS [name], 'Discount Factor' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 3 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Mega View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Mega View'
	            AND dsc.name =  'dva'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'DVA'
			   , reqd_param = 0, widget_id = 1, datatype_id = 3, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 2, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Mega View'
			AND dsc.name =  'dva'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'dva' AS [name], 'DVA' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 3 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Mega View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Mega View'
	            AND dsc.name =  'ext_deal_id'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'External Deal ID'
			   , reqd_param = 0, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Mega View'
			AND dsc.name =  'ext_deal_id'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'ext_deal_id' AS [name], 'External Deal ID' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Mega View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Mega View'
	            AND dsc.name =  'fair_value'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Fair Value'
			   , reqd_param = 0, widget_id = 1, datatype_id = 3, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 2, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Mega View'
			AND dsc.name =  'fair_value'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'fair_value' AS [name], 'Fair Value' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 3 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Mega View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Mega View'
	            AND dsc.name =  'fixed_cost'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Fixed Cost'
			   , reqd_param = 0, widget_id = 1, datatype_id = 3, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 2, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Mega View'
			AND dsc.name =  'fixed_cost'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'fixed_cost' AS [name], 'Fixed Cost' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 3 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Mega View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Mega View'
	            AND dsc.name =  'fixed_price'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Fixed Price'
			   , reqd_param = 0, widget_id = 1, datatype_id = 3, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 2, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Mega View'
			AND dsc.name =  'fixed_price'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'fixed_price' AS [name], 'Fixed Price' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 3 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Mega View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Mega View'
	            AND dsc.name =  'formula'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Formula'
			   , reqd_param = 0, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Mega View'
			AND dsc.name =  'formula'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'formula' AS [name], 'Formula' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Mega View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Mega View'
	            AND dsc.name =  'formula_curve_id'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Indexed On'
			   , reqd_param = 0, widget_id = 1, datatype_id = 4, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 2, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Mega View'
			AND dsc.name =  'formula_curve_id'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'formula_curve_id' AS [name], 'Indexed On' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 4 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Mega View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Mega View'
	            AND dsc.name =  'formula_curve_name'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Formula Index'
			   , reqd_param = 0, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Mega View'
			AND dsc.name =  'formula_curve_name'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'formula_curve_name' AS [name], 'Formula Index' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Mega View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Mega View'
	            AND dsc.name =  'formula_price'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Formula Price'
			   , reqd_param = 0, widget_id = 1, datatype_id = 3, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 2, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Mega View'
			AND dsc.name =  'formula_price'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'formula_price' AS [name], 'Formula Price' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 3 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Mega View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Mega View'
	            AND dsc.name =  'formula_value'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Formula Value'
			   , reqd_param = 0, widget_id = 1, datatype_id = 3, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 2, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Mega View'
			AND dsc.name =  'formula_value'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'formula_value' AS [name], 'Formula Value' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 3 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Mega View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Mega View'
	            AND dsc.name =  'from_as_of_date'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'As of Date From'
			   , reqd_param = 1, widget_id = 6, datatype_id = 2, param_data_source = NULL, param_default_value = NULL, append_filter = 0, tooltip = NULL, column_template = 4, key_column = 0, required_filter = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Mega View'
			AND dsc.name =  'from_as_of_date'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'from_as_of_date' AS [name], 'As of Date From' AS ALIAS, 1 AS reqd_param, 6 AS widget_id, 2 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 0 AS append_filter, NULL  AS tooltip,4 AS column_template, 0 AS key_column, 0 AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Mega View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Mega View'
	            AND dsc.name =  'grid'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Grid'
			   , reqd_param = 0, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Mega View'
			AND dsc.name =  'grid'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'grid' AS [name], 'Grid' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Mega View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Mega View'
	            AND dsc.name =  'index_id'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Index ID'
			   , reqd_param = 1, widget_id = 7, datatype_id = 4, param_data_source = 'browse_curve', param_default_value = NULL, append_filter = 0, tooltip = NULL, column_template = 2, key_column = 0, required_filter = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Mega View'
			AND dsc.name =  'index_id'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'index_id' AS [name], 'Index ID' AS ALIAS, 1 AS reqd_param, 7 AS widget_id, 4 AS datatype_id, 'browse_curve' AS param_data_source, NULL AS param_default_value, 0 AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column, 0 AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Mega View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Mega View'
	            AND dsc.name =  'index_tou'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Index ToU'
			   , reqd_param = 0, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Mega View'
			AND dsc.name =  'index_tou'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'index_tou' AS [name], 'Index ToU' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Mega View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Mega View'
	            AND dsc.name =  'int_ext_flag'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Internal/External'
			   , reqd_param = 0, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Mega View'
			AND dsc.name =  'int_ext_flag'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'int_ext_flag' AS [name], 'Internal/External' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Mega View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Mega View'
	            AND dsc.name =  'int_ext_flag_id'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Internal/External ID'
			   , reqd_param = 0, widget_id = 1, datatype_id = 1, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Mega View'
			AND dsc.name =  'int_ext_flag_id'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'int_ext_flag_id' AS [name], 'Internal/External ID' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 1 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Mega View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Mega View'
	            AND dsc.name =  'internal_desk'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Internal Desk'
			   , reqd_param = 0, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Mega View'
			AND dsc.name =  'internal_desk'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'internal_desk' AS [name], 'Internal Desk' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Mega View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Mega View'
	            AND dsc.name =  'internal_desk_id'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Internal Desk ID'
			   , reqd_param = 0, widget_id = 1, datatype_id = 4, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 2, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Mega View'
			AND dsc.name =  'internal_desk_id'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'internal_desk_id' AS [name], 'Internal Desk ID' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 4 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Mega View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Mega View'
	            AND dsc.name =  'internal_portfolio'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Internal Portfolio'
			   , reqd_param = 0, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Mega View'
			AND dsc.name =  'internal_portfolio'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'internal_portfolio' AS [name], 'Internal Portfolio' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Mega View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Mega View'
	            AND dsc.name =  'internal_portfolio_id'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Internal Portfolio ID'
			   , reqd_param = 0, widget_id = 9, datatype_id = 4, param_data_source = 'EXEC spa_StaticDataValues @flag = ''h'', @type_id = 39800', param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 2, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Mega View'
			AND dsc.name =  'internal_portfolio_id'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'internal_portfolio_id' AS [name], 'Internal Portfolio ID' AS ALIAS, 0 AS reqd_param, 9 AS widget_id, 4 AS datatype_id, 'EXEC spa_StaticDataValues @flag = ''h'', @type_id = 39800' AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Mega View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Mega View'
	            AND dsc.name =  'leg'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Leg'
			   , reqd_param = 0, widget_id = 1, datatype_id = 4, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 2, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Mega View'
			AND dsc.name =  'leg'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'leg' AS [name], 'Leg' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 4 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Mega View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Mega View'
	            AND dsc.name =  'location_description'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Location Description'
			   , reqd_param = 0, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Mega View'
			AND dsc.name =  'location_description'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'location_description' AS [name], 'Location Description' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Mega View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Mega View'
	            AND dsc.name =  'location_group'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Location Group'
			   , reqd_param = 0, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Mega View'
			AND dsc.name =  'location_group'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'location_group' AS [name], 'Location Group' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Mega View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Mega View'
	            AND dsc.name =  'location_id'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Location ID'
			   , reqd_param = 1, widget_id = 7, datatype_id = 4, param_data_source = 'browse_location', param_default_value = NULL, append_filter = 0, tooltip = NULL, column_template = 2, key_column = 0, required_filter = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Mega View'
			AND dsc.name =  'location_id'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'location_id' AS [name], 'Location ID' AS ALIAS, 1 AS reqd_param, 7 AS widget_id, 4 AS datatype_id, 'browse_location' AS param_data_source, NULL AS param_default_value, 0 AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column, 0 AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Mega View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Mega View'
	            AND dsc.name =  'location_name'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Location'
			   , reqd_param = 0, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Mega View'
			AND dsc.name =  'location_name'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'location_name' AS [name], 'Location' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Mega View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Mega View'
	            AND dsc.name =  'market_price'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Market Price'
			   , reqd_param = 0, widget_id = 1, datatype_id = 3, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 2, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Mega View'
			AND dsc.name =  'market_price'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'market_price' AS [name], 'Market Price' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 3 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Mega View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Mega View'
	            AND dsc.name =  'market_value'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Market Value'
			   , reqd_param = 0, widget_id = 1, datatype_id = 3, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 2, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Mega View'
			AND dsc.name =  'market_value'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'market_value' AS [name], 'Market Value' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 3 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Mega View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Mega View'
	            AND dsc.name =  'model_reserve'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Model Reserve'
			   , reqd_param = 0, widget_id = 1, datatype_id = 4, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 2, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Mega View'
			AND dsc.name =  'model_reserve'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'model_reserve' AS [name], 'Model Reserve' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 4 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Mega View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Mega View'
	            AND dsc.name =  'net_price'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Net Price'
			   , reqd_param = 0, widget_id = 1, datatype_id = 3, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 2, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Mega View'
			AND dsc.name =  'net_price'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'net_price' AS [name], 'Net Price' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 3 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Mega View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Mega View'
	            AND dsc.name =  'parent_counterparty_name'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Parent Counterparty'
			   , reqd_param = 0, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Mega View'
			AND dsc.name =  'parent_counterparty_name'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'parent_counterparty_name' AS [name], 'Parent Counterparty' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Mega View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Mega View'
	            AND dsc.name =  'period_from'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Period From'
			   , reqd_param = 1, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 0, tooltip = NULL, column_template = 0, key_column = 0, required_filter = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Mega View'
			AND dsc.name =  'period_from'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'period_from' AS [name], 'Period From' AS ALIAS, 1 AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 0 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, 0 AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Mega View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Mega View'
	            AND dsc.name =  'period_to'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Period To'
			   , reqd_param = 1, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 0, tooltip = NULL, column_template = 0, key_column = 0, required_filter = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Mega View'
			AND dsc.name =  'period_to'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'period_to' AS [name], 'Period To' AS ALIAS, 1 AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 0 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, 0 AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Mega View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Mega View'
	            AND dsc.name =  'physical_financial_flag'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Physical/Financial'
			   , reqd_param = 1, widget_id = 2, datatype_id = 5, param_data_source = 'SELECT ''p'' as value,''Physical'' as Code' + CHAR(10) + 'UNION' + CHAR(10) + 'SELECT ''f'' as value, ''Financial'' as Code', param_default_value = NULL, append_filter = 0, tooltip = NULL, column_template = 0, key_column = 0, required_filter = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Mega View'
			AND dsc.name =  'physical_financial_flag'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'physical_financial_flag' AS [name], 'Physical/Financial' AS ALIAS, 1 AS reqd_param, 2 AS widget_id, 5 AS datatype_id, 'SELECT ''p'' as value,''Physical'' as Code' + CHAR(10) + 'UNION' + CHAR(10) + 'SELECT ''f'' as value, ''Financial'' as Code' AS param_data_source, NULL AS param_default_value, 0 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, 0 AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Mega View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Mega View'
	            AND dsc.name =  'pnl_adjustment_value'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Pnl Adjustment Value'
			   , reqd_param = 0, widget_id = 1, datatype_id = 3, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 2, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Mega View'
			AND dsc.name =  'pnl_adjustment_value'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'pnl_adjustment_value' AS [name], 'Pnl Adjustment Value' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 3 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Mega View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Mega View'
	            AND dsc.name =  'pnl_conversion_factor'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Pnl Conversion Factor'
			   , reqd_param = 0, widget_id = 1, datatype_id = 3, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 2, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Mega View'
			AND dsc.name =  'pnl_conversion_factor'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'pnl_conversion_factor' AS [name], 'Pnl Conversion Factor' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 3 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Mega View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Mega View'
	            AND dsc.name =  'pnl_source_name'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Pnl Source'
			   , reqd_param = 0, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Mega View'
			AND dsc.name =  'pnl_source_name'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'pnl_source_name' AS [name], 'Pnl Source' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Mega View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Mega View'
	            AND dsc.name =  'pnl_source_value_id'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Pnl Source Value ID'
			   , reqd_param = 1, widget_id = 9, datatype_id = 4, param_data_source = 'EXEC spa_StaticDataValues @flag = ''h'', @type_id = 10007', param_default_value = NULL, append_filter = 0, tooltip = NULL, column_template = 2, key_column = 0, required_filter = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Mega View'
			AND dsc.name =  'pnl_source_value_id'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'pnl_source_value_id' AS [name], 'Pnl Source Value ID' AS ALIAS, 1 AS reqd_param, 9 AS widget_id, 4 AS datatype_id, 'EXEC spa_StaticDataValues @flag = ''h'', @type_id = 10007' AS param_data_source, NULL AS param_default_value, 0 AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column, 0 AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Mega View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Mega View'
	            AND dsc.name =  'position_uom'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Position UOM'
			   , reqd_param = 0, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Mega View'
			AND dsc.name =  'position_uom'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'position_uom' AS [name], 'Position UOM' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Mega View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Mega View'
	            AND dsc.name =  'price_adder'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Price Adder'
			   , reqd_param = 0, widget_id = 1, datatype_id = 3, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 2, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Mega View'
			AND dsc.name =  'price_adder'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'price_adder' AS [name], 'Price Adder' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 3 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Mega View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Mega View'
	            AND dsc.name =  'price_multiplier'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Price Multiplier'
			   , reqd_param = 0, widget_id = 1, datatype_id = 3, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 2, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Mega View'
			AND dsc.name =  'price_multiplier'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'price_multiplier' AS [name], 'Price Multiplier' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 3 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Mega View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Mega View'
	            AND dsc.name =  'probability'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Probability'
			   , reqd_param = 0, widget_id = 1, datatype_id = 3, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 2, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Mega View'
			AND dsc.name =  'probability'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'probability' AS [name], 'Probability' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 3 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Mega View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Mega View'
	            AND dsc.name =  'product_desc'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Product Description'
			   , reqd_param = 0, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Mega View'
			AND dsc.name =  'product_desc'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'product_desc' AS [name], 'Product Description' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Mega View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Mega View'
	            AND dsc.name =  'product_id'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Product ID'
			   , reqd_param = 0, widget_id = 1, datatype_id = 4, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 2, key_column = 0, required_filter = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Mega View'
			AND dsc.name =  'product_id'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'product_id' AS [name], 'Product ID' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 4 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column, 0 AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Mega View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Mega View'
	            AND dsc.name =  'reference'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Reference'
			   , reqd_param = 0, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Mega View'
			AND dsc.name =  'reference'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'reference' AS [name], 'Reference' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Mega View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Mega View'
	            AND dsc.name =  'region'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Region'
			   , reqd_param = 0, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Mega View'
			AND dsc.name =  'region'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'region' AS [name], 'Region' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Mega View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Mega View'
	            AND dsc.name =  'region_id'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Region ID'
			   , reqd_param = 0, widget_id = 9, datatype_id = 4, param_data_source = 'EXEC spa_StaticDataValues ''h'', 11150', param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 2, key_column = 0, required_filter = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Mega View'
			AND dsc.name =  'region_id'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'region_id' AS [name], 'Region ID' AS ALIAS, 0 AS reqd_param, 9 AS widget_id, 4 AS datatype_id, 'EXEC spa_StaticDataValues ''h'', 11150' AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column, 0 AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Mega View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Mega View'
	            AND dsc.name =  'source_counterparty_id'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Counterparty ID'
			   , reqd_param = 1, widget_id = 7, datatype_id = 4, param_data_source = 'browse_counterparty', param_default_value = NULL, append_filter = 0, tooltip = NULL, column_template = 2, key_column = 0, required_filter = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Mega View'
			AND dsc.name =  'source_counterparty_id'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'source_counterparty_id' AS [name], 'Counterparty ID' AS ALIAS, 1 AS reqd_param, 7 AS widget_id, 4 AS datatype_id, 'browse_counterparty' AS param_data_source, NULL AS param_default_value, 0 AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column, 0 AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Mega View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Mega View'
	            AND dsc.name =  'source_deal_header_id'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Deal ID'
			   , reqd_param = 1, widget_id = 1, datatype_id = 4, param_data_source = NULL, param_default_value = NULL, append_filter = 0, tooltip = NULL, column_template = 2, key_column = 1, required_filter = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Mega View'
			AND dsc.name =  'source_deal_header_id'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'source_deal_header_id' AS [name], 'Deal ID' AS ALIAS, 1 AS reqd_param, 1 AS widget_id, 4 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 0 AS append_filter, NULL  AS tooltip,2 AS column_template, 1 AS key_column, 0 AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Mega View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Mega View'
	            AND dsc.name =  'source_deal_type_id'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Deal Type ID'
			   , reqd_param = 1, widget_id = 9, datatype_id = 4, param_data_source = 'exec spa_source_deal_type_maintain ''x''', param_default_value = NULL, append_filter = 0, tooltip = NULL, column_template = 2, key_column = 0, required_filter = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Mega View'
			AND dsc.name =  'source_deal_type_id'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'source_deal_type_id' AS [name], 'Deal Type ID' AS ALIAS, 1 AS reqd_param, 9 AS widget_id, 4 AS datatype_id, 'exec spa_source_deal_type_maintain ''x''' AS param_data_source, NULL AS param_default_value, 0 AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column, 0 AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Mega View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Mega View'
	            AND dsc.name =  'source_major_location_id'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Major Location ID'
			   , reqd_param = 0, widget_id = 1, datatype_id = 4, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 2, key_column = 1, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Mega View'
			AND dsc.name =  'source_major_location_id'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'source_major_location_id' AS [name], 'Major Location ID' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 4 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,2 AS column_template, 1 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Mega View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Mega View'
	            AND dsc.name =  'stra_id'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Strategy ID'
			   , reqd_param = 1, widget_id = 4, datatype_id = 4, param_data_source = NULL, param_default_value = NULL, append_filter = 0, tooltip = NULL, column_template = 2, key_column = 0, required_filter = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Mega View'
			AND dsc.name =  'stra_id'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'stra_id' AS [name], 'Strategy ID' AS ALIAS, 1 AS reqd_param, 4 AS widget_id, 4 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 0 AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column, 0 AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Mega View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Mega View'
	            AND dsc.name =  'strategy'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Strategy'
			   , reqd_param = 0, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Mega View'
			AND dsc.name =  'strategy'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'strategy' AS [name], 'Strategy' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Mega View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Mega View'
	            AND dsc.name =  'strike_price'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Strike Price'
			   , reqd_param = 0, widget_id = 1, datatype_id = 3, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 2, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Mega View'
			AND dsc.name =  'strike_price'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'strike_price' AS [name], 'Strike Price' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 3 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Mega View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Mega View'
	            AND dsc.name =  'sub_book'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Sub Book'
			   , reqd_param = 0, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Mega View'
			AND dsc.name =  'sub_book'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'sub_book' AS [name], 'Sub Book' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Mega View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Mega View'
	            AND dsc.name =  'sub_book_id'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Sub Book ID'
			   , reqd_param = 1, widget_id = 8, datatype_id = 4, param_data_source = NULL, param_default_value = NULL, append_filter = 0, tooltip = NULL, column_template = 2, key_column = 0, required_filter = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Mega View'
			AND dsc.name =  'sub_book_id'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'sub_book_id' AS [name], 'Sub Book ID' AS ALIAS, 1 AS reqd_param, 8 AS widget_id, 4 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 0 AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column, 0 AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Mega View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Mega View'
	            AND dsc.name =  'sub_id'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Subsidiary ID'
			   , reqd_param = 1, widget_id = 3, datatype_id = 4, param_data_source = NULL, param_default_value = NULL, append_filter = 0, tooltip = NULL, column_template = 2, key_column = 0, required_filter = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Mega View'
			AND dsc.name =  'sub_id'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'sub_id' AS [name], 'Subsidiary ID' AS ALIAS, 1 AS reqd_param, 3 AS widget_id, 4 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 0 AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column, 0 AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Mega View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Mega View'
	            AND dsc.name =  'subsidiary'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Subsidiary'
			   , reqd_param = 0, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Mega View'
			AND dsc.name =  'subsidiary'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'subsidiary' AS [name], 'Subsidiary' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Mega View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Mega View'
	            AND dsc.name =  'template_name'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Template'
			   , reqd_param = 0, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Mega View'
			AND dsc.name =  'template_name'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'template_name' AS [name], 'Template' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Mega View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Mega View'
	            AND dsc.name =  'term_end'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Term End'
			   , reqd_param = 1, widget_id = 6, datatype_id = 2, param_data_source = NULL, param_default_value = NULL, append_filter = 0, tooltip = NULL, column_template = 4, key_column = 0, required_filter = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Mega View'
			AND dsc.name =  'term_end'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'term_end' AS [name], 'Term End' AS ALIAS, 1 AS reqd_param, 6 AS widget_id, 2 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 0 AS append_filter, NULL  AS tooltip,4 AS column_template, 0 AS key_column, 0 AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Mega View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Mega View'
	            AND dsc.name =  'term_start'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Term Start'
			   , reqd_param = 1, widget_id = 6, datatype_id = 2, param_data_source = NULL, param_default_value = NULL, append_filter = 0, tooltip = NULL, column_template = 4, key_column = 1, required_filter = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Mega View'
			AND dsc.name =  'term_start'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'term_start' AS [name], 'Term Start' AS ALIAS, 1 AS reqd_param, 6 AS widget_id, 2 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 0 AS append_filter, NULL  AS tooltip,4 AS column_template, 1 AS key_column, 0 AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Mega View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Mega View'
	            AND dsc.name =  'term_start_day'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Term Day'
			   , reqd_param = 0, widget_id = 1, datatype_id = 4, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 2, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Mega View'
			AND dsc.name =  'term_start_day'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'term_start_day' AS [name], 'Term Day' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 4 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Mega View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Mega View'
	            AND dsc.name =  'term_start_month'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Term Month'
			   , reqd_param = 0, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Mega View'
			AND dsc.name =  'term_start_month'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'term_start_month' AS [name], 'Term Month' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Mega View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Mega View'
	            AND dsc.name =  'term_start_month_name'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Term Month Name'
			   , reqd_param = 0, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Mega View'
			AND dsc.name =  'term_start_month_name'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'term_start_month_name' AS [name], 'Term Month Name' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Mega View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Mega View'
	            AND dsc.name =  'term_start_year'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Term Year'
			   , reqd_param = 0, widget_id = 1, datatype_id = 4, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 2, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Mega View'
			AND dsc.name =  'term_start_year'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'term_start_year' AS [name], 'Term Year' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 4 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Mega View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Mega View'
	            AND dsc.name =  'term_start_year_month'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Term Year Month'
			   , reqd_param = 0, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Mega View'
			AND dsc.name =  'term_start_year_month'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'term_start_year_month' AS [name], 'Term Year Month' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Mega View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Mega View'
	            AND dsc.name =  'to_as_of_date'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'As of Date To'
			   , reqd_param = 1, widget_id = 6, datatype_id = 2, param_data_source = NULL, param_default_value = NULL, append_filter = 0, tooltip = NULL, column_template = 4, key_column = 0, required_filter = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Mega View'
			AND dsc.name =  'to_as_of_date'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'to_as_of_date' AS [name], 'As of Date To' AS ALIAS, 1 AS reqd_param, 6 AS widget_id, 2 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 0 AS append_filter, NULL  AS tooltip,4 AS column_template, 0 AS key_column, 0 AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Mega View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Mega View'
	            AND dsc.name =  'total_volume'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Total Volume'
			   , reqd_param = 0, widget_id = 1, datatype_id = 3, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 2, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Mega View'
			AND dsc.name =  'total_volume'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'total_volume' AS [name], 'Total Volume' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 3 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Mega View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Mega View'
	            AND dsc.name =  'trader_id'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Trader ID'
			   , reqd_param = 1, widget_id = 7, datatype_id = 4, param_data_source = 'BrowseTrader', param_default_value = NULL, append_filter = 0, tooltip = NULL, column_template = 2, key_column = 0, required_filter = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Mega View'
			AND dsc.name =  'trader_id'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'trader_id' AS [name], 'Trader ID' AS ALIAS, 1 AS reqd_param, 7 AS widget_id, 4 AS datatype_id, 'BrowseTrader' AS param_data_source, NULL AS param_default_value, 0 AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column, 0 AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Mega View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Mega View'
	            AND dsc.name =  'trader_name'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Trader'
			   , reqd_param = 0, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Mega View'
			AND dsc.name =  'trader_name'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'trader_name' AS [name], 'Trader' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Mega View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Mega View'
	            AND dsc.name =  'transaction_type'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Transaction Type ID'
			   , reqd_param = 0, widget_id = 1, datatype_id = 4, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 2, key_column = 1, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Mega View'
			AND dsc.name =  'transaction_type'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'transaction_type' AS [name], 'Transaction Type ID' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 4 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,2 AS column_template, 1 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Mega View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Mega View'
	            AND dsc.name =  'transaction_type_name'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Transaction Type'
			   , reqd_param = 0, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Mega View'
			AND dsc.name =  'transaction_type_name'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'transaction_type_name' AS [name], 'Transaction Type' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Mega View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Mega View'
	            AND dsc.name =  'type_of_entity'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Type of Entity'
			   , reqd_param = 0, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Mega View'
			AND dsc.name =  'type_of_entity'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'type_of_entity' AS [name], 'Type of Entity' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Mega View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Mega View'
	            AND dsc.name =  'type_of_entity_id'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Type of Entity ID'
			   , reqd_param = 0, widget_id = 1, datatype_id = 4, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 2, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Mega View'
			AND dsc.name =  'type_of_entity_id'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'type_of_entity_id' AS [name], 'Type of Entity ID' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 4 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Mega View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Mega View'
	            AND dsc.name =  'und_extrinsic_pnl'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Und Extrinsic MTM'
			   , reqd_param = 0, widget_id = 1, datatype_id = 3, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 2, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Mega View'
			AND dsc.name =  'und_extrinsic_pnl'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'und_extrinsic_pnl' AS [name], 'Und Extrinsic MTM' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 3 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Mega View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Mega View'
	            AND dsc.name =  'und_intrinsic_pnl'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Und Intrinsic MTM'
			   , reqd_param = 0, widget_id = 1, datatype_id = 3, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 2, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Mega View'
			AND dsc.name =  'und_intrinsic_pnl'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'und_intrinsic_pnl' AS [name], 'Und Intrinsic MTM' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 3 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Mega View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Mega View'
	            AND dsc.name =  'und_pnl_set'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Und Pnl Settlement'
			   , reqd_param = 0, widget_id = 1, datatype_id = 3, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 2, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Mega View'
			AND dsc.name =  'und_pnl_set'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'und_pnl_set' AS [name], 'Und Pnl Settlement' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 3 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Mega View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Mega View'
	            AND dsc.name =  'update_by'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Updated By'
			   , reqd_param = 0, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Mega View'
			AND dsc.name =  'update_by'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'update_by' AS [name], 'Updated By' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Mega View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Mega View'
	            AND dsc.name =  'update_ts'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Updated Date'
			   , reqd_param = 0, widget_id = 6, datatype_id = 2, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 4, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Mega View'
			AND dsc.name =  'update_ts'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'update_ts' AS [name], 'Updated Date' AS ALIAS, 0 AS reqd_param, 6 AS widget_id, 2 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,4 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Mega View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Mega View'
	            AND dsc.name =  'volume_uom'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Volume UOM'
			   , reqd_param = 0, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Mega View'
			AND dsc.name =  'volume_uom'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'volume_uom' AS [name], 'Volume UOM' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Mega View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Mega View'
	            AND dsc.name =  'close_reference_id'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Close Reference Id'
			   , reqd_param = 0, widget_id = 1, datatype_id = 4, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 2, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Mega View'
			AND dsc.name =  'close_reference_id'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'close_reference_id' AS [name], 'Close Reference Id' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 4 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Mega View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Mega View'
	            AND dsc.name =  'internal_deal_sub_type'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Internal Deal Sub Type'
			   , reqd_param = 0, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Mega View'
			AND dsc.name =  'internal_deal_sub_type'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'internal_deal_sub_type' AS [name], 'Internal Deal Sub Type' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Mega View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Mega View'
	            AND dsc.name =  'internal_deal_sub_type_id'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Internal Deal Sub Type ID'
			   , reqd_param = 0, widget_id = 1, datatype_id = 4, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 2, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Mega View'
			AND dsc.name =  'internal_deal_sub_type_id'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'internal_deal_sub_type_id' AS [name], 'Internal Deal Sub Type ID' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 4 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Mega View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Mega View'
	            AND dsc.name =  'internal_deal_type'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Internal Deal Type'
			   , reqd_param = 0, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Mega View'
			AND dsc.name =  'internal_deal_type'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'internal_deal_type' AS [name], 'Internal Deal Type' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Mega View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Mega View'
	            AND dsc.name =  'internal_deal_type_id'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Internal Deal Type ID'
			   , reqd_param = 0, widget_id = 1, datatype_id = 4, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 2, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Mega View'
			AND dsc.name =  'internal_deal_type_id'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'internal_deal_type_id' AS [name], 'Internal Deal Type ID' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 4 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Mega View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Mega View'
	            AND dsc.name =  'book_identifier1'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Book Identifier1'
			   , reqd_param = 0, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Mega View'
			AND dsc.name =  'book_identifier1'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'book_identifier1' AS [name], 'Book Identifier1' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Mega View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Mega View'
	            AND dsc.name =  'book_identifier1_id'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Book Identifier1 ID'
			   , reqd_param = 0, widget_id = 1, datatype_id = 4, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 2, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Mega View'
			AND dsc.name =  'book_identifier1_id'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'book_identifier1_id' AS [name], 'Book Identifier1 ID' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 4 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Mega View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Mega View'
	            AND dsc.name =  'book_identifier2'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Book Identifier2'
			   , reqd_param = 0, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Mega View'
			AND dsc.name =  'book_identifier2'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'book_identifier2' AS [name], 'Book Identifier2' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Mega View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Mega View'
	            AND dsc.name =  'book_identifier2_id'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Book Identifier2 ID'
			   , reqd_param = 0, widget_id = 1, datatype_id = 4, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 2, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Mega View'
			AND dsc.name =  'book_identifier2_id'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'book_identifier2_id' AS [name], 'Book Identifier2 ID' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 4 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Mega View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Mega View'
	            AND dsc.name =  'book_identifier3'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Book Identifier3'
			   , reqd_param = 0, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Mega View'
			AND dsc.name =  'book_identifier3'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'book_identifier3' AS [name], 'Book Identifier3' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Mega View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Mega View'
	            AND dsc.name =  'book_identifier3_id'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Book Identifier3 ID'
			   , reqd_param = 0, widget_id = 1, datatype_id = 4, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 2, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Mega View'
			AND dsc.name =  'book_identifier3_id'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'book_identifier3_id' AS [name], 'Book Identifier3 ID' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 4 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Mega View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Mega View'
	            AND dsc.name =  'book_identifier4'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Book Identifier4'
			   , reqd_param = 0, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Mega View'
			AND dsc.name =  'book_identifier4'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'book_identifier4' AS [name], 'Book Identifier4' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Mega View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Mega View'
	            AND dsc.name =  'book_identifier4_id'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Book Identifier4 ID'
			   , reqd_param = 0, widget_id = 1, datatype_id = 4, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 2, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Mega View'
			AND dsc.name =  'book_identifier4_id'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'book_identifier4_id' AS [name], 'Book Identifier4 ID' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 4 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Mega View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Mega View'
	            AND dsc.name =  'sub_book_group1'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Report Group 1'
			   , reqd_param = 0, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Mega View'
			AND dsc.name =  'sub_book_group1'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'sub_book_group1' AS [name], 'Report Group 1' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Mega View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Mega View'
	            AND dsc.name =  'sub_book_group1_id'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Report Group 1 ID'
			   , reqd_param = 0, widget_id = 1, datatype_id = 4, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 2, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Mega View'
			AND dsc.name =  'sub_book_group1_id'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'sub_book_group1_id' AS [name], 'Report Group 1 ID' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 4 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Mega View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Mega View'
	            AND dsc.name =  'sub_book_group2'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Report Group 2'
			   , reqd_param = 0, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Mega View'
			AND dsc.name =  'sub_book_group2'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'sub_book_group2' AS [name], 'Report Group 2' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Mega View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Mega View'
	            AND dsc.name =  'sub_book_group2_id'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Report Group 2 ID'
			   , reqd_param = 0, widget_id = 1, datatype_id = 4, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 2, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Mega View'
			AND dsc.name =  'sub_book_group2_id'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'sub_book_group2_id' AS [name], 'Report Group 2 ID' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 4 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Mega View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Mega View'
	            AND dsc.name =  'sub_book_group3'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Report Group 3'
			   , reqd_param = 0, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Mega View'
			AND dsc.name =  'sub_book_group3'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'sub_book_group3' AS [name], 'Report Group 3' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Mega View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Mega View'
	            AND dsc.name =  'sub_book_group3_id'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Report Group 3 ID'
			   , reqd_param = 0, widget_id = 1, datatype_id = 4, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 2, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Mega View'
			AND dsc.name =  'sub_book_group3_id'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'sub_book_group3_id' AS [name], 'Report Group 3 ID' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 4 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Mega View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Mega View'
	            AND dsc.name =  'sub_book_group4'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Report Group 4'
			   , reqd_param = 0, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Mega View'
			AND dsc.name =  'sub_book_group4'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'sub_book_group4' AS [name], 'Report Group 4' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Mega View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Mega View'
	            AND dsc.name =  'sub_book_group4_id'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Report Group 4 ID'
			   , reqd_param = 0, widget_id = 1, datatype_id = 4, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 2, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Mega View'
			AND dsc.name =  'sub_book_group4_id'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'sub_book_group4_id' AS [name], 'Report Group 4 ID' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 4 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Mega View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Mega View'
	            AND dsc.name =  'actual_forward'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Actual/Forward'
			   , reqd_param = 0, widget_id = 2, datatype_id = 5, param_data_source = 'SELECT ''a'',''Actual''UNION SELECT ''f'', ''Forward''', param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 1, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Mega View'
			AND dsc.name =  'actual_forward'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'actual_forward' AS [name], 'Actual/Forward' AS ALIAS, 0 AS reqd_param, 2 AS widget_id, 5 AS datatype_id, 'SELECT ''a'',''Actual''UNION SELECT ''f'', ''Forward''' AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,0 AS column_template, 1 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Mega View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Mega View'
	            AND dsc.name =  'charge_type'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Charge Type'
			   , reqd_param = 0, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Mega View'
			AND dsc.name =  'charge_type'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'charge_type' AS [name], 'Charge Type' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Mega View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Mega View'
	            AND dsc.name =  'charge_type_id'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Charge Type ID'
			   , reqd_param = 0, widget_id = 9, datatype_id = 4, param_data_source = 'EXEC spa_StaticDataValues @flag = ''h'', @type_id = 5500', param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 2, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Mega View'
			AND dsc.name =  'charge_type_id'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'charge_type_id' AS [name], 'Charge Type ID' AS ALIAS, 0 AS reqd_param, 9 AS widget_id, 4 AS datatype_id, 'EXEC spa_StaticDataValues @flag = ''h'', @type_id = 5500' AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Mega View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Mega View'
	            AND dsc.name =  'Amount'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Amount'
			   , reqd_param = 0, widget_id = 1, datatype_id = 3, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 2, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Mega View'
			AND dsc.name =  'Amount'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'Amount' AS [name], 'Amount' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 3 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Mega View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Mega View'
	            AND dsc.name =  'deal_price'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Deal Price'
			   , reqd_param = 0, widget_id = 1, datatype_id = 3, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 2, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Mega View'
			AND dsc.name =  'deal_price'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'deal_price' AS [name], 'Deal Price' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 3 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Mega View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Mega View'
	            AND dsc.name =  'float_price'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Float Price'
			   , reqd_param = 0, widget_id = 1, datatype_id = 3, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 2, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Mega View'
			AND dsc.name =  'float_price'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'float_price' AS [name], 'Float Price' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 3 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Mega View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Mega View'
	            AND dsc.name =  'Volume'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Volume'
			   , reqd_param = 0, widget_id = 1, datatype_id = 3, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 2, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Mega View'
			AND dsc.name =  'Volume'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'Volume' AS [name], 'Volume' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 3 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Mega View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Mega View'
	            AND dsc.name =  'agg_term'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Aggregate Term'
			   , reqd_param = 0, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Mega View'
			AND dsc.name =  'agg_term'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'agg_term' AS [name], 'Aggregate Term' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Mega View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Mega View'
	            AND dsc.name =  'discounted_credit_adjusted_mtm'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Discounted Credit Adjusted Mtm'
			   , reqd_param = 0, widget_id = 1, datatype_id = 3, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 2, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Mega View'
			AND dsc.name =  'discounted_credit_adjusted_mtm'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'discounted_credit_adjusted_mtm' AS [name], 'Discounted Credit Adjusted Mtm' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 3 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Mega View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Mega View'
	            AND dsc.name =  'fv_level'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'FV Level'
			   , reqd_param = 0, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Mega View'
			AND dsc.name =  'fv_level'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'fv_level' AS [name], 'FV Level' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Mega View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Mega View'
	            AND dsc.name =  'recovery_rate'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Recovery Rate'
			   , reqd_param = 0, widget_id = 1, datatype_id = 3, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 2, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Mega View'
			AND dsc.name =  'recovery_rate'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'recovery_rate' AS [name], 'Recovery Rate' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 3 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Mega View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Mega View'
	            AND dsc.name =  'term_quarter'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Term Quarter'
			   , reqd_param = 0, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Mega View'
			AND dsc.name =  'term_quarter'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'term_quarter' AS [name], 'Term Quarter' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Mega View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Mega View'
	            AND dsc.name =  'contract_exipration_date'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Contract Exipration Date'
			   , reqd_param = 0, widget_id = 6, datatype_id = 2, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 4, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Mega View'
			AND dsc.name =  'contract_exipration_date'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'contract_exipration_date' AS [name], 'Contract Exipration Date' AS ALIAS, 0 AS reqd_param, 6 AS widget_id, 2 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,4 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Mega View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Mega View'
	            AND dsc.name =  'currency_id'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Currency ID'
			   , reqd_param = 0, widget_id = 9, datatype_id = 4, param_data_source = 'exec spa_source_currency_maintain ''p''', param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 2, key_column = 0, required_filter = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Mega View'
			AND dsc.name =  'currency_id'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'currency_id' AS [name], 'Currency ID' AS ALIAS, 0 AS reqd_param, 9 AS widget_id, 4 AS datatype_id, 'exec spa_source_currency_maintain ''p''' AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column, 0 AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Mega View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Mega View'
	            AND dsc.name =  'deal_category'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Deal Category'
			   , reqd_param = 0, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Mega View'
			AND dsc.name =  'deal_category'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'deal_category' AS [name], 'Deal Category' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Mega View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Mega View'
	            AND dsc.name =  'deal_category_id'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Deal Category ID'
			   , reqd_param = 0, widget_id = 9, datatype_id = 4, param_data_source = 'EXEC spa_StaticDataValues @flag = ''h'', @type_id = 475', param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 2, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Mega View'
			AND dsc.name =  'deal_category_id'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'deal_category_id' AS [name], 'Deal Category ID' AS ALIAS, 0 AS reqd_param, 9 AS widget_id, 4 AS datatype_id, 'EXEC spa_StaticDataValues @flag = ''h'', @type_id = 475' AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Mega View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Mega View'
	            AND dsc.name =  'debt_rating'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Debt Rating'
			   , reqd_param = 0, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Mega View'
			AND dsc.name =  'debt_rating'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'debt_rating' AS [name], 'Debt Rating' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Mega View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Mega View'
	            AND dsc.name =  'entire_term_end'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Deal Term End'
			   , reqd_param = 0, widget_id = 6, datatype_id = 2, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 4, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Mega View'
			AND dsc.name =  'entire_term_end'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'entire_term_end' AS [name], 'Deal Term End' AS ALIAS, 0 AS reqd_param, 6 AS widget_id, 2 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,4 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Mega View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Mega View'
	            AND dsc.name =  'entire_term_start'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Deal Term Start'
			   , reqd_param = 0, widget_id = 6, datatype_id = 2, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 4, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Mega View'
			AND dsc.name =  'entire_term_start'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'entire_term_start' AS [name], 'Deal Term Start' AS ALIAS, 0 AS reqd_param, 6 AS widget_id, 2 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,4 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Mega View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Mega View'
	            AND dsc.name =  'internal_counterparty_id'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Internal Counterparty ID'
			   , reqd_param = 0, widget_id = 9, datatype_id = 4, param_data_source = 'EXEC spa_source_counterparty_maintain @flag = ''f'', @int_ext_flag = ''i''', param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 2, key_column = 0, required_filter = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Mega View'
			AND dsc.name =  'internal_counterparty_id'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'internal_counterparty_id' AS [name], 'Internal Counterparty ID' AS ALIAS, 0 AS reqd_param, 9 AS widget_id, 4 AS datatype_id, 'EXEC spa_source_counterparty_maintain @flag = ''f'', @int_ext_flag = ''i''' AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column, 0 AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Mega View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Mega View'
	            AND dsc.name =  'internal_couterparty'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Internal Couterparty'
			   , reqd_param = 0, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Mega View'
			AND dsc.name =  'internal_couterparty'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'internal_couterparty' AS [name], 'Internal Couterparty' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Mega View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Mega View'
	            AND dsc.name =  'is_expired'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Is Expired'
			   , reqd_param = 0, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Mega View'
			AND dsc.name =  'is_expired'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'is_expired' AS [name], 'Is Expired' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Mega View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Mega View'
	            AND dsc.name =  'price_adder2'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Price Adder2'
			   , reqd_param = 0, widget_id = 1, datatype_id = 3, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 2, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Mega View'
			AND dsc.name =  'price_adder2'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'price_adder2' AS [name], 'Price Adder2' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 3 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Mega View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Mega View'
	            AND dsc.name =  'structured_id'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Structured Deal ID'
			   , reqd_param = 0, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Mega View'
			AND dsc.name =  'structured_id'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'structured_id' AS [name], 'Structured Deal ID' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Mega View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Mega View'
	            AND dsc.name =  'template_id'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Template ID'
			   , reqd_param = 0, widget_id = 9, datatype_id = 4, param_data_source = 'EXEC spa_getDealTemplate ''s''', param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 2, key_column = 0, required_filter = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Mega View'
			AND dsc.name =  'template_id'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'template_id' AS [name], 'Template ID' AS ALIAS, 0 AS reqd_param, 9 AS widget_id, 4 AS datatype_id, 'EXEC spa_getDealTemplate ''s''' AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column, 0 AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Mega View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Mega View'
	            AND dsc.name =  'volume_frequency'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Volume Frequency'
			   , reqd_param = 0, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Mega View'
			AND dsc.name =  'volume_frequency'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'volume_frequency' AS [name], 'Volume Frequency' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Mega View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Mega View'
	            AND dsc.name =  'volume_multiplier'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Volume Multiplier'
			   , reqd_param = 0, widget_id = 1, datatype_id = 3, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 2, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Mega View'
			AND dsc.name =  'volume_multiplier'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'volume_multiplier' AS [name], 'Volume Multiplier' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 3 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Mega View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Mega View'
	            AND dsc.name =  'volume_multiplier2'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Volume Multiplier2'
			   , reqd_param = 0, widget_id = 1, datatype_id = 3, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 2, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Mega View'
			AND dsc.name =  'volume_multiplier2'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'volume_multiplier2' AS [name], 'Volume Multiplier2' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 3 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Mega View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Mega View'
	            AND dsc.name =  'volume_profile'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Volume Profile'
			   , reqd_param = 0, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Mega View'
			AND dsc.name =  'volume_profile'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'volume_profile' AS [name], 'Volume Profile' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Mega View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Mega View'
	            AND dsc.name =  'payment_date'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Payment Date'
			   , reqd_param = 0, widget_id = 6, datatype_id = 2, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 4, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Mega View'
			AND dsc.name =  'payment_date'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'payment_date' AS [name], 'Payment Date' AS ALIAS, 0 AS reqd_param, 6 AS widget_id, 2 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,4 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Mega View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Mega View'
	            AND dsc.name =  'dispatch_contract_value'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Dispatch Contract Value'
			   , reqd_param = NULL, widget_id = 1, datatype_id = 3, param_data_source = NULL, param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 2, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Mega View'
			AND dsc.name =  'dispatch_contract_value'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'dispatch_contract_value' AS [name], 'Dispatch Contract Value' AS ALIAS, NULL AS reqd_param, 1 AS widget_id, 3 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Mega View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Mega View'
	            AND dsc.name =  'dispatch_market_value'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Dispatch Market Value'
			   , reqd_param = NULL, widget_id = 1, datatype_id = 3, param_data_source = NULL, param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 2, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Mega View'
			AND dsc.name =  'dispatch_market_value'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'dispatch_market_value' AS [name], 'Dispatch Market Value' AS ALIAS, NULL AS reqd_param, 1 AS widget_id, 3 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Mega View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Mega View'
	            AND dsc.name =  'dispatch_volume'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Dispatch Volume'
			   , reqd_param = NULL, widget_id = 1, datatype_id = 3, param_data_source = NULL, param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 2, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Mega View'
			AND dsc.name =  'dispatch_volume'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'dispatch_volume' AS [name], 'Dispatch Volume' AS ALIAS, NULL AS reqd_param, 1 AS widget_id, 3 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Mega View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Mega View'
	            AND dsc.name =  'must_run_contract_value'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Must Run Contract Value'
			   , reqd_param = NULL, widget_id = 1, datatype_id = 3, param_data_source = NULL, param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 2, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Mega View'
			AND dsc.name =  'must_run_contract_value'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'must_run_contract_value' AS [name], 'Must Run Contract Value' AS ALIAS, NULL AS reqd_param, 1 AS widget_id, 3 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Mega View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Mega View'
	            AND dsc.name =  'must_run_market_value'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Must Run Market Value'
			   , reqd_param = NULL, widget_id = 1, datatype_id = 3, param_data_source = NULL, param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 2, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Mega View'
			AND dsc.name =  'must_run_market_value'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'must_run_market_value' AS [name], 'Must Run Market Value' AS ALIAS, NULL AS reqd_param, 1 AS widget_id, 3 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Mega View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Mega View'
	            AND dsc.name =  'must_run_volume'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Must Run Volume'
			   , reqd_param = NULL, widget_id = 1, datatype_id = 3, param_data_source = NULL, param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 2, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Mega View'
			AND dsc.name =  'must_run_volume'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'must_run_volume' AS [name], 'Must Run Volume' AS ALIAS, NULL AS reqd_param, 1 AS widget_id, 3 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Mega View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Mega View'
	            AND dsc.name =  'pricing_type'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Pricing Type'
			   , reqd_param = NULL, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 2, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Mega View'
			AND dsc.name =  'pricing_type'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'pricing_type' AS [name], 'Pricing Type' AS ALIAS, NULL AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Mega View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Mega View'
	            AND dsc.name =  'cash_flow'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Cash Flow'
			   , reqd_param = NULL, widget_id = 1, datatype_id = 3, param_data_source = NULL, param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 2, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Mega View'
			AND dsc.name =  'cash_flow'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'cash_flow' AS [name], 'Cash Flow' AS ALIAS, NULL AS reqd_param, 1 AS widget_id, 3 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Mega View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Mega View'
	            AND dsc.name =  'pnl_date'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Pnl Date'
			   , reqd_param = NULL, widget_id = 6, datatype_id = 2, param_data_source = NULL, param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 4, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Mega View'
			AND dsc.name =  'pnl_date'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'pnl_date' AS [name], 'Pnl Date' AS ALIAS, NULL AS reqd_param, 6 AS widget_id, 2 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,4 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Mega View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Mega View'
	            AND dsc.name =  'cash_flow_year_month'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Cash Flow Year Month'
			   , reqd_param = NULL, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 0, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Mega View'
			AND dsc.name =  'cash_flow_year_month'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'cash_flow_year_month' AS [name], 'Cash Flow Year Month' AS ALIAS, NULL AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Mega View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Mega View'
	            AND dsc.name =  'PNL_year_month'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Pnl Year Month'
			   , reqd_param = NULL, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 0, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Mega View'
			AND dsc.name =  'PNL_year_month'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'PNL_year_month' AS [name], 'Pnl Year Month' AS ALIAS, NULL AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Mega View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Mega View'
	            AND dsc.name =  'deal_status_group'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Deal Status Group'
			   , reqd_param = NULL, widget_id = 2, datatype_id = 1, param_data_source = 'SELECT ''a'', ''All'' UNION SELECT ''o'', ''Official'' UNION SELECT ''u'', ''Unofficial''', param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 0, key_column = 0, required_filter = 1
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Mega View'
			AND dsc.name =  'deal_status_group'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'deal_status_group' AS [name], 'Deal Status Group' AS ALIAS, NULL AS reqd_param, 2 AS widget_id, 1 AS datatype_id, 'SELECT ''a'', ''All'' UNION SELECT ''o'', ''Official'' UNION SELECT ''u'', ''Unofficial''' AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, 1 AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Mega View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Mega View'
	            AND dsc.name =  'pricing_type_id'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Pricing Type ID'
			   , reqd_param = NULL, widget_id = 2, datatype_id = 5, param_data_source = 'exec spa_StaticDataValues @flag = ''h'', @type_id = 46700', param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 2, key_column = 0, required_filter = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Mega View'
			AND dsc.name =  'pricing_type_id'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'pricing_type_id' AS [name], 'Pricing Type ID' AS ALIAS, NULL AS reqd_param, 2 AS widget_id, 5 AS datatype_id, 'exec spa_StaticDataValues @flag = ''h'', @type_id = 46700' AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column, 0 AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Mega View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Mega View'
	            AND dsc.name =  'amount_deal'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Amount Deal'
			   , reqd_param = NULL, widget_id = 1, datatype_id = 3, param_data_source = NULL, param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 2, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Mega View'
			AND dsc.name =  'amount_deal'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'amount_deal' AS [name], 'Amount Deal' AS ALIAS, NULL AS reqd_param, 1 AS widget_id, 3 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Mega View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Mega View'
	            AND dsc.name =  'amount_inv'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Amount Inv'
			   , reqd_param = NULL, widget_id = 1, datatype_id = 3, param_data_source = NULL, param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 2, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Mega View'
			AND dsc.name =  'amount_inv'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'amount_inv' AS [name], 'Amount Inv' AS ALIAS, NULL AS reqd_param, 1 AS widget_id, 3 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Mega View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Mega View'
	            AND dsc.name =  'Cur_type'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Cur Type'
			   , reqd_param = NULL, widget_id = 1, datatype_id = 1, param_data_source = NULL, param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 0, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Mega View'
			AND dsc.name =  'Cur_type'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'Cur_type' AS [name], 'Cur Type' AS ALIAS, NULL AS reqd_param, 1 AS widget_id, 1 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Mega View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Mega View'
	            AND dsc.name =  'deal_currency'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Deal Currency'
			   , reqd_param = NULL, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 0, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Mega View'
			AND dsc.name =  'deal_currency'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'deal_currency' AS [name], 'Deal Currency' AS ALIAS, NULL AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Mega View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Mega View'
	            AND dsc.name =  'deal_status_name'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Deal Status Name'
			   , reqd_param = NULL, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 0, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Mega View'
			AND dsc.name =  'deal_status_name'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'deal_status_name' AS [name], 'Deal Status Name' AS ALIAS, NULL AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Mega View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Mega View'
	            AND dsc.name =  'invoice_currency'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Invoice Currency'
			   , reqd_param = NULL, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 0, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Mega View'
			AND dsc.name =  'invoice_currency'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'invoice_currency' AS [name], 'Invoice Currency' AS ALIAS, NULL AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Mega View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Mega View'
	            AND dsc.name =  'pnl'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'PNL'
			   , reqd_param = NULL, widget_id = 1, datatype_id = 3, param_data_source = NULL, param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 2, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Mega View'
			AND dsc.name =  'pnl'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'pnl' AS [name], 'PNL' AS ALIAS, NULL AS reqd_param, 1 AS widget_id, 3 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Mega View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Mega View'
	            AND dsc.name =  'reporting_group1'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Reporting Group1'
			   , reqd_param = NULL, widget_id = 2, datatype_id = 4, param_data_source = 'EXEC spa_StaticDataValues @flag = ''h'', @type_id = 113000', param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 2, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Mega View'
			AND dsc.name =  'reporting_group1'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'reporting_group1' AS [name], 'Reporting Group1' AS ALIAS, NULL AS reqd_param, 2 AS widget_id, 4 AS datatype_id, 'EXEC spa_StaticDataValues @flag = ''h'', @type_id = 113000' AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Mega View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Mega View'
	            AND dsc.name =  'reporting_group1_name'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Reporting Group1 Name'
			   , reqd_param = NULL, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 0, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Mega View'
			AND dsc.name =  'reporting_group1_name'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'reporting_group1_name' AS [name], 'Reporting Group1 Name' AS ALIAS, NULL AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Mega View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Mega View'
	            AND dsc.name =  'reporting_group2'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Reporting Group2'
			   , reqd_param = NULL, widget_id = 2, datatype_id = 4, param_data_source = 'EXEC spa_StaticDataValues @flag = ''h'', @type_id = 113100', param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 2, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Mega View'
			AND dsc.name =  'reporting_group2'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'reporting_group2' AS [name], 'Reporting Group2' AS ALIAS, NULL AS reqd_param, 2 AS widget_id, 4 AS datatype_id, 'EXEC spa_StaticDataValues @flag = ''h'', @type_id = 113100' AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Mega View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Mega View'
	            AND dsc.name =  'reporting_group2_name'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Reporting Group2 Name'
			   , reqd_param = NULL, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 0, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Mega View'
			AND dsc.name =  'reporting_group2_name'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'reporting_group2_name' AS [name], 'Reporting Group2 Name' AS ALIAS, NULL AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Mega View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Mega View'
	            AND dsc.name =  'reporting_group3'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Reporting Group3'
			   , reqd_param = NULL, widget_id = 2, datatype_id = 4, param_data_source = 'EXEC spa_StaticDataValues @flag = ''h'', @type_id = 113200', param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 2, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Mega View'
			AND dsc.name =  'reporting_group3'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'reporting_group3' AS [name], 'Reporting Group3' AS ALIAS, NULL AS reqd_param, 2 AS widget_id, 4 AS datatype_id, 'EXEC spa_StaticDataValues @flag = ''h'', @type_id = 113200' AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Mega View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Mega View'
	            AND dsc.name =  'reporting_group3_name'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Reporting Group3 Name'
			   , reqd_param = NULL, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 0, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Mega View'
			AND dsc.name =  'reporting_group3_name'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'reporting_group3_name' AS [name], 'Reporting Group3 Name' AS ALIAS, NULL AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Mega View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Mega View'
	            AND dsc.name =  'reporting_group4'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Reporting Group4'
			   , reqd_param = NULL, widget_id = 2, datatype_id = 4, param_data_source = 'EXEC spa_StaticDataValues @flag = ''h'', @type_id = 113300', param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 2, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Mega View'
			AND dsc.name =  'reporting_group4'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'reporting_group4' AS [name], 'Reporting Group4' AS ALIAS, NULL AS reqd_param, 2 AS widget_id, 4 AS datatype_id, 'EXEC spa_StaticDataValues @flag = ''h'', @type_id = 113300' AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Mega View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Mega View'
	            AND dsc.name =  'reporting_group4_name'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Reporting Group4 Name'
			   , reqd_param = NULL, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 0, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Mega View'
			AND dsc.name =  'reporting_group4_name'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'reporting_group4_name' AS [name], 'Reporting Group4 Name' AS ALIAS, NULL AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Mega View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Mega View'
	            AND dsc.name =  'reporting_group5'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Reporting Group5'
			   , reqd_param = NULL, widget_id = 2, datatype_id = 4, param_data_source = 'EXEC spa_StaticDataValues @flag = ''h'', @type_id = 113400', param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 2, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Mega View'
			AND dsc.name =  'reporting_group5'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'reporting_group5' AS [name], 'Reporting Group5' AS ALIAS, NULL AS reqd_param, 2 AS widget_id, 4 AS datatype_id, 'EXEC spa_StaticDataValues @flag = ''h'', @type_id = 113400' AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Mega View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Mega View'
	            AND dsc.name =  'reporting_group5_name'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Reporting Group5 Name'
			   , reqd_param = NULL, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 0, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Mega View'
			AND dsc.name =  'reporting_group5_name'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'reporting_group5_name' AS [name], 'Reporting Group5 Name' AS ALIAS, NULL AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Mega View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Mega View'
	            AND dsc.name =  'price'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Price'
			   , reqd_param = NULL, widget_id = 1, datatype_id = 3, param_data_source = NULL, param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 2, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Mega View'
			AND dsc.name =  'price'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'price' AS [name], 'Price' AS ALIAS, NULL AS reqd_param, 1 AS widget_id, 3 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Mega View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	DELETE dsc
	FROM data_source_column dsc 
	INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		AND ds.[name] = 'Enercity Settlement Mega View'
		AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1)
	LEFT JOIN #data_source_column tdsc ON tdsc.column_id = dsc.data_source_column_id
	WHERE tdsc.column_id IS NULL
	COMMIT TRAN

	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
			ROLLBACK TRAN;
		
			DECLARE @error_msg VARCHAR(1000)
             	SET @error_msg = ERROR_MESSAGE()
             	RAISERROR (@error_msg, 16, 1);
	END CATCH
	
	IF OBJECT_ID('tempdb..#data_source_column', 'U') IS NOT NULL
		DROP TABLE #data_source_column	
