IF OBJECT_ID (N'[dbo].[spa_ecm]', N'P') IS NOT NULL
	DROP PROCEDURE [dbo].[spa_ecm]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[spa_ecm]
	@flag CHAR(1) = NULL,
	@create_date_from VARCHAR(100) = NULL,
	@create_date_to VARCHAR(100) = NULL,
	@process_id VARCHAR(MAX) = NULL,
	@include_bfi BIT = NULL,
	@filter_table_process_id VARCHAR(1000) = NULL
AS

/*------------------Debug Section------------------
DECLARE @flag CHAR(1) = NULL,
		@create_date_from VARCHAR(100) = NULL,
		@create_date_to VARCHAR(100) = NULL,
		@process_id VARCHAR(MAX) = NULL,
		@include_bfi BIT = NULL,
		@filter_table_process_id VARCHAR(1000) = NULL

SELECT @flag='i', @create_date_from='2017-01-01', @create_date_to='2019-04-15',
	   @include_bfi='1', @filter_table_process_id='1CC1E4BA_36DB_4F09_81E3_424C077697F9'
-------------------------------------------------*/
SET NOCOUNT ON
DECLARE @create_ts DATETIME = GETDATE()

IF @create_date_from IS NULL
BEGIN
    SET @create_date_from = CONVERT(VARCHAR(10), DATEADD(MONTH, -1, @create_ts), 120)
END

IF @create_date_to IS NULL
BEGIN
    SET @create_date_to = CONVERT(VARCHAR(10), @create_ts, 120)
END

DECLARE @ssbm_table_name VARCHAR(120),
		@deal_header_table_name VARCHAR(120),
		@deal_detail_table_name VARCHAR(120),
		@show_data INT = 0,
		@xml XML,
		@sql2 VARCHAR(MAX),
		@_sql VARCHAR(MAX)

SET @ssbm_table_name = dbo.FNAProcessTableName('ssbm', dbo.FNADBUser(), @filter_table_process_id)
SET @deal_header_table_name = dbo.FNAProcessTableName('deal_header', dbo.FNADBUser(), @filter_table_process_id)
SET @deal_detail_table_name = dbo.FNAProcessTableName('deal_detail', dbo.FNADBUser(), @filter_table_process_id)

IF @flag = 'i'
BEGIN
	DECLARE @_cpty_udf_cpty_id VARCHAR(100) = 'Counterparty ID',
			@_cpty_udf_source_code VARCHAR(100) = 'Source Code',
			@err_msg VARCHAR(200) = ''
    
	IF OBJECT_ID('tempdb..#temp_deals') IS NOT NULL
		DROP TABLE #temp_deals

	CREATE TABLE #temp_deals (
		source_deal_header_id INT,
		deal_id VARCHAR(200) COLLATE DATABASE_DEFAULT,
		template_id INT,
		counterparty_id INT,
		sub_book_id INT,
		deal_date DATETIME,
		physical_financial_flag CHAR(10) COLLATE DATABASE_DEFAULT,
		entire_term_start DATETIME,
		entire_term_end DATETIME,
		source_deal_type_id INT,
		deal_sub_type_type_id INT,
		option_flag CHAR(1) COLLATE DATABASE_DEFAULT,
		option_type CHAR(1) COLLATE DATABASE_DEFAULT,
		option_excercise_type CHAR(1) COLLATE DATABASE_DEFAULT,
		header_buy_sell_flag VARCHAR(1) COLLATE DATABASE_DEFAULT,
		create_ts DATETIME,
		update_ts DATETIME,
		internal_desk_id INT,
		product_id INT,
		commodity_id INT,
		block_define_id INT,
		deal_status INT,
		description1 VARCHAR(100) COLLATE DATABASE_DEFAULT,
		description2 VARCHAR(100) COLLATE DATABASE_DEFAULT,
		source_trader_id INT,
		contract_id INT,
		deal_group_id INT,
		ext_deal_id VARCHAR(512) COLLATE DATABASE_DEFAULT,
		confirm_status VARCHAR(512) COLLATE DATABASE_DEFAULT,
		[commodity_name] VARCHAR(1000) COLLATE DATABASE_DEFAULT
	)

	SET @_sql = '
		INSERT INTO #temp_deals
		SELECT * FROM ' + @deal_header_table_name + '
	'

	EXEC(@_sql)
  	
	DECLARE @udf_broker_fee INT

	SELECT @udf_broker_fee = value_id
	FROM static_data_value
	WHERE [type_id] = 5500
		AND code = 'Broker Fee'	

    IF OBJECT_ID('tempdb..#temp_deal_details') IS NOT NULL
		DROP TABLE #temp_deal_details
	
	CREATE TABLE #temp_deal_details (
		[source_deal_header_id] INT NULL,
		[source_deal_detail_id] INT NULL,
		[term_start] DATETIME NOT NULL,
		[term_end] DATETIME NOT NULL,
		[leg] INT NOT NULL,
		[fixed_float_leg] CHAR(1) NOT NULL,
		[buy_sell_flag] CHAR(1) NOT NULL,
		[curve_id] INT NULL,
		[location_id] INT NULL,
		[physical_financial_flag] CHAR(1) NULL,
		[deal_volume] NUMERIC(38, 20) NULL,
		[total_volume] NUMERIC(38, 20) NULL,
		[standard_yearly_volume] NUMERIC(22, 8) NULL,
		[deal_volume_frequency] CHAR(1) NOT NULL,
		[deal_volume_uom_id] INT NOT NULL,
		[multiplier] NUMERIC(38, 20) NULL,
		[volume_multiplier2] NUMERIC(38, 20) NULL,
		[fixed_price] NUMERIC(38, 20) NULL,
		[fixed_price_currency_id] INT NULL,
		[option_strike_price] NUMERIC(38, 20) NULL,
		[fixed_cost] NUMERIC(38, 20) NULL,
		[formula_id] INT NULL,
		[formula_curve_id] INT NULL,
		[price_adder] NUMERIC(38, 20) NULL,
		[price_multiplier] NUMERIC(38, 20) NULL,
		[adder_currency_id] INT NULL,
		[fixed_cost_currency_id] INT NULL,
		[formula_currency_id] INT NULL,
		[price_adder2] NUMERIC(38, 20) NULL,
		[price_adder_currency2] INT NULL,
		[price_uom_id] INT NULL,
		[contract_expiration_date] DATETIME,
		position_uom INT NULL
	)

	EXEC ('
		INSERT INTO #temp_deal_details
		SELECT * FROM ' + @deal_detail_table_name + '
	')

    IF @process_id IS NULL
        SET @process_id = LOWER(NEWID())
	
	IF OBJECT_ID('tempdb..#temp_ecm') IS NOT NULL
		DROP TABLE #temp_ecm

    SELECT DISTINCT
		   td.source_deal_header_id source_deal_header_id,
		   td.deal_id deal_id,
		   MAX(td.sub_book_id) sub_book_id,
		   MAX(td.physical_financial_flag) physical_financial_flag,
		   'CNF_' + CONVERT(VARCHAR(10), GETDATE(), 112) + '_' + REPLICATE('0', 10 - LEN(RTRIM(td.source_deal_header_id))) + RTRIM(td.source_deal_header_id) + '@23X--121101ESPMJ' document_id,
		   'Live' document_usage,
		   '23X--121101ESPMJ' sender_id,
		   '11XRWETRADING--0' receiver_id,
		   'Trader' receiver_role,
		   CASE 
				WHEN MAX(ecm.document_version) IS NULL THEN ROW_NUMBER() OVER(PARTITION BY td.deal_id ORDER BY td.deal_id, MAX(ecm.ecm_document_type))
				ELSE MAX(ecm.document_version) + 1
		   END document_version,
		   CASE
				WHEN MAX(sdht.template_name) LIKE '%ztph%' OR MAX(sdht.template_name) LIKE '%ztpl%' THEN 'BE'
				ELSE MAX(sdv_cntry.code)
		   END market,
		   MAX(scom.commodity_id) commodity,
		   'FOR' transaction_type,
		   CASE 
				WHEN MAX(sdht.template_name) LIKE '%ztph%' THEN '21Y000000000024I'
				WHEN MAX(sdht.template_name) LIKE '%ztpl%' THEN '21Z000000000247L'
				WHEN MAX(sdht.template_name) LIKE '%Zeebrugge%' THEN '21Z0000000000090'
				ELSE
					CASE
						WHEN MAX(scom.commodity_id) IN ('ELectricity', 'Power') THEN CASE
																						WHEN MAX(sdv_cntry.code) IN ('NL','Netherlands') THEN '10YNL----------L'
																						WHEN MAX(sdv_cntry.code) IN ('BE', 'BELGIUM') THEN '10YBE----------2'
																					 END
						WHEN MAX(scom.commodity_id) = 'Gas' THEN CASE
																	WHEN MAX(sdv_cntry.code) IN ('NL','Netherlands') THEN '21YNL----TTF---1' 
																	WHEN MAX(sdv_cntry.code) IN ('BE', 'BELGIUM') AND MAX(sml.grid_value_id) = 292045 THEN '21Y000000000024I'
																	WHEN MAX(sdv_cntry.code) IN ('BE', 'BELGIUM') AND MAX(sml.grid_value_id) = 292081 THEN '21Z000000000247L'
																 END
					END
				 END delivery_point_area,
		   CASE 
				WHEN MAX(td.header_buy_sell_flag) = 'b' THEN '23X--121101ESPMJ'
				ELSE '11XRWETRADING--0'
		   END [buyer_party],
		   CASE
				WHEN MAX(td.header_buy_sell_flag) = 'b' THEN '11XRWETRADING--0'
				ELSE '23X--121101ESPMJ'
		   END [seller_party],
		   CASE	
				WHEN MAX(scom.source_commodity_id) = -1 THEN 'Base'
				WHEN MAX(scom.source_commodity_id) = -2 THEN 'Custom'
		   END [load_type],
		   'EFET' [agreement],
		   MAX(CASE scur_fixed.currency_name WHEN 'Euro' THEN 'EUR'
		                                     WHEN 'Ect' THEN 'EUX'
											 WHEN 'GPC' THEN 'GBX'
											 ELSE UPPER(scur_fixed.currency_name)
			   END
		   ) [currency],
		   CASE 
				WHEN MAX(td.physical_financial_flag) = 'p' THEN SUM(tdd.total_volume) 
				ELSE ROUND(SUM(tdd.total_volume),2) 
		   END * MAX(ISNULL(conv.conversion_factor, 1 )) [total_volume],
		   CASE 
				WHEN MAX(tsu.uom_name)='mwh' THEN 'MWh'
				WHEN MAX(tsu.uom_name)='kwh' THEN 'KWh'
				WHEN MAX(tsu.uom_name)='gwh' THEN 'GWh'
				WHEN MAX(tsu.uom_name)='therm' THEN 'Therm'
				WHEN MAX(tsu.uom_name)='mmbtu' THEN 'MMBtu'
				WHEN MAX(tsu.uom_name)='gj' THEN 'GJ'
				WHEN MAX(tsu.uom_name)='m3' THEN 'cm'
				WHEN MAX(tsu.uom_name)='m3/hr' THEN 'cm'
				WHEN MAX(tsu.uom_name)='m3(n,35.17)' THEN 'cm'
				WHEN MAX(tsu.uom_name)='Metric Tons' THEN 'cm'
				WHEN MAX(tsu.uom_name)='MT' THEN 'cm'
				WHEN MAX(tsu.uom_name)='mw' THEN 'MWh'
				ELSE NULL
		   END [total_volume_unit],
		   CONVERT(VARCHAR(10), MAX(td.deal_date), 120) [trade_date],
		   CASE
				WHEN MAX(tsu.uom_name)='mwh' THEN 'MWh'
			    WHEN MAX(tsu.uom_name)='kwh' THEN 'KWh'
			    WHEN MAX(tsu.uom_name)='gwh' THEN 'GWh'
			    WHEN MAX(tsu.uom_name)='therm' THEN 'Therm'
			    WHEN MAX(tsu.uom_name)='mmbtu' THEN 'MMBtu'
			    WHEN MAX(tsu.uom_name)='gj' THEN 'GJ'
			    WHEN MAX(tsu.uom_name)='m3' THEN 'cm'
			    WHEN MAX(tsu.uom_name)='m3/hr' THEN 'cm'
			    WHEN MAX(tsu.uom_name)='m3(n,35.17)' THEN 'cm'
			    WHEN MAX(tsu.uom_name)='Metric Tons' THEN 'cm'
			    WHEN MAX(tsu.uom_name)='MT' THEN 'cm'
			    WHEN MAX(tsu.uom_name)='mw' THEN 'MWh'
				ELSE NULL
		   END [capacity_unit],
		   MAX(CASE scur_fixed.currency_name WHEN 'Euro' THEN 'EUR'
											 WHEN 'Ect' THEN 'EUX'
											 WHEN 'GPC' THEN 'GBX'
											 ELSE UPPER(scur_fixed.currency_name)
			   END
		   ) [price_unit_currency],
		   CASE WHEN MAX(tsu.uom_name)='mwh' THEN 'MWh'
			    WHEN MAX(tsu.uom_name)='kwh' THEN 'KWh'
				WHEN MAX(tsu.uom_name)='gwh' THEN 'GWh'
				WHEN MAX(tsu.uom_name)='therm' THEN 'Therm'
				WHEN MAX(tsu.uom_name)='mmbtu' THEN 'MMBtu'
				WHEN MAX(tsu.uom_name)='gj' THEN 'GJ'
				WHEN MAX(tsu.uom_name)='m3' THEN 'cm'
				WHEN MAX(tsu.uom_name)='m3/hr' THEN 'cm'
				WHEN MAX(tsu.uom_name)='m3(n,35.17)' THEN 'cm'
				WHEN MAX(tsu.uom_name)='Metric Tons' THEN 'cm'
				WHEN MAX(tsu.uom_name)='MT' THEN 'cm'
				WHEN MAX(tsu.uom_name)='mw' THEN 'MWh'
				ELSE NULL
		   END [price_unit_capacity_unit],
		   SUM(tdd.total_volume * ISNULL(conv.conversion_factor, 1) * (tdd.fixed_price + ISNULL(ABS(CAST(uddf.udf_value AS FLOAT)), 0)) ) * CASE WHEN MAX(sdht.template_name) LIKE '%Zeebrugge%' THEN 100 ELSE 1 END [total_contract_value],
		   CASE 
				WHEN MAX(scom.source_commodity_id) = -1 THEN CONVERT(VARCHAR(19), DATEADD(hh, 6, MAX(td.entire_term_start)), 126)
				ELSE CONVERT(VARCHAR(19), CAST(MAX(td.entire_term_start) AS DATETIME), 126)
		   END [delivery_start],
		   CASE WHEN MAX(scom.source_commodity_id) = -1 THEN CONVERT(VARCHAR(19), DATEADD(hh, 6, MAX(td.entire_term_end)) + CASE WHEN ISNULL(MAX(td.block_define_id), 292037) = 292037 THEN 1 ELSE 0 END, 126) ELSE CONVERT(VARCHAR(19), CAST(MAX(td.entire_term_end) AS DATETIME) + CASE WHEN ISNULL(MAX(td.block_define_id), 292037) = 292037 THEN 1 ELSE 0 END, 126) END [delivery_end],
		   MAX(tdd.deal_volume) [contract_capacity],
		   (AVG(tdd.fixed_price) + ISNULL(MAX(ABS(CAST(uddf.udf_value AS FLOAT))), 0)) * CASE WHEN MAX(sdht.template_name) LIKE '%Zeebrugge%' THEN 100 ELSE 1 END [price],
		   CASE WHEN MAX(scom.commodity_id) IN ('ELectricity', 'Power') THEN NULL
			    WHEN MAX(scom.commodity_id) = 'Gas' THEN CASE WHEN MAX(sdht.template_name) LIKE '%ztph%' OR MAX(sdht.template_name) LIKE '%ztpl%' THEN CASE WHEN MAX(td.header_buy_sell_flag) = 'b' THEN 'ZHESSENTNL'
																																							WHEN MAX(td.header_buy_sell_flag) = 's' THEN 'ZHRWE'
																																					   END
															  ELSE CASE WHEN MAX(sdv_cntry.code) IN ('NL','Netherlands') AND MAX(td.header_buy_sell_flag) = 'b' THEN 'GSESSENTNL'
																		WHEN MAX(sdv_cntry.code) IN ('NL','Netherlands') AND MAX(td.header_buy_sell_flag) = 's' THEN 'GSRWE'  
																		WHEN MAX(sdv_cntry.code) IN ('BE', 'BELGIUM') AND MAX(sml.grid_value_id) = 292045 AND MAX(td.header_buy_sell_flag) = 'b' THEN 'ZHESSENTNL'
																		WHEN MAX(sdv_cntry.code) IN ('BE', 'BELGIUM') AND MAX(sml.grid_value_id) = 292045 AND MAX(td.header_buy_sell_flag) = 's' THEN 'ZHRWE'
																		WHEN MAX(sdv_cntry.code) IN ('BE', 'BELGIUM') AND MAX(sml.grid_value_id) = 292081 AND MAX(td.header_buy_sell_flag) = 'b' THEN 'ZHESSENTNL'
																		WHEN MAX(sdv_cntry.code) IN ('BE', 'BELGIUM') AND MAX(sml.grid_value_id) = 292081 AND MAX(td.header_buy_sell_flag) = 's' THEN 'ZHRWE'
																   END
														 END
		   END [buyer_hubcode],
		   CASE WHEN MAX(scom.commodity_id) IN ('ELectricity', 'Power') THEN NULL
			    WHEN MAX(scom.commodity_id) = 'Gas' THEN CASE WHEN MAX(sdht.template_name) LIKE '%ztph%' OR MAX(sdht.template_name) LIKE '%ztpl%' THEN CASE WHEN MAX(td.header_buy_sell_flag) = 'b' THEN 'ZHRWE'
																																							WHEN MAX(td.header_buy_sell_flag) = 's' THEN 'ZHESSENTNL'
																																					   END
															  ELSE CASE
																		WHEN MAX(sdv_cntry.code) IN ('NL','Netherlands') AND MAX(td.header_buy_sell_flag) = 'b' THEN 'GSRWE'
																		WHEN MAX(sdv_cntry.code) IN ('NL','Netherlands') AND MAX(td.header_buy_sell_flag) = 's' THEN 'GSESSENTNL'  
																		WHEN MAX(sdv_cntry.code) IN ('BE', 'BELGIUM') AND MAX(sml.grid_value_id) = 292045 AND MAX(td.header_buy_sell_flag) = 'b' THEN 'ZHRWE'
																		WHEN MAX(sdv_cntry.code) IN ('BE', 'BELGIUM') AND MAX(sml.grid_value_id) = 292045 AND MAX(td.header_buy_sell_flag) = 's' THEN 'ZHESSENTNL'
																		WHEN MAX(sdv_cntry.code) IN ('BE', 'BELGIUM') AND MAX(sml.grid_value_id) = 292081 AND MAX(td.header_buy_sell_flag) = 'b' THEN 'ZHRWE'
																		WHEN MAX(sdv_cntry.code) IN ('BE', 'BELGIUM') AND MAX(sml.grid_value_id) = 292081 AND MAX(td.header_buy_sell_flag) = 's' THEN 'ZHESSENTNL'
																   END
														 END
		   END [seller_hubcode],
		   ISNULL(MAX(st.trader_name), '') [trader_name],
		   'CNF' ecm_document_type,
		   NULL [report_type],
		   @create_date_from [create_date_from],
		   @create_date_to [create_date_to],
		   @create_ts [create_ts],
		   39500 [submission_status],
		   NULL [submission_date],
		   NULL [confirmation_date],
		   @process_id [process_id],
		   NULL [error_validation_message],
		   NULL [file_export_name]
	INTO #temp_ecm
	FROM #temp_deals td
	INNER JOIN #temp_deal_details tdd ON td.source_deal_header_id = tdd.source_deal_header_id
	OUTER APPLY(
		SELECT TOP 1 cs.[type]
		FROM confirm_status cs
		WHERE cs.source_deal_header_id = td.source_deal_header_id
		ORDER BY cs.confirm_status_id DESC
	) cs
	LEFT JOIN source_deal_header_template sdht ON sdht.template_id = td.template_id
	LEFT JOIN user_defined_deal_fields_template uddft ON uddft.template_id = td.template_id
		AND uddft.field_id = @udf_broker_fee
	LEFT JOIN user_defined_deal_fields uddf ON uddf.source_deal_header_id = td.source_deal_header_id
		AND uddf.udf_template_id = uddft.udf_template_id
	LEFT JOIN source_traders st ON st.source_trader_id = td.source_trader_id
	LEFT JOIN source_price_curve_def spcd ON spcd.source_curve_def_id = tdd.curve_id
	LEFT JOIN rec_volume_unit_conversion conv ON conv.from_source_uom_id = ISNULL(spcd.display_uom_id, spcd.uom_id)
		AND conv.to_source_uom_id = tdd.deal_volume_uom_id
	LEFT JOIN source_commodity scom ON scom.source_commodity_id = ISNULL(spcd.commodity_id, td.commodity_id)
	LEFT JOIN source_minor_location sml ON sml.source_minor_location_id = tdd.location_id
	LEFT JOIN static_data_value sdv_cntry ON sdv_cntry.type_id = 14000
		AND sdv_cntry.value_id = sml.country
	OUTER APPLY(
		SELECT TOP 1 
			   ecm.ecm_document_type,
			   ecm.document_version
		FROM source_ecm ecm
		WHERE ecm.source_deal_header_id = td.source_deal_header_id
			AND ecm.ecm_document_type = 'CNF'
		ORDER BY ecm.document_version DESC
	) ecm
	LEFT JOIN static_data_value sdv_deal_status ON sdv_deal_status.value_id = td.deal_status
	LEFT JOIN source_uom tsu ON tdd.deal_volume_uom_id = tsu.source_uom_id
	LEFT JOIN source_currency scur_fixed ON scur_fixed.source_currency_id = tdd.fixed_price_currency_id
	LEFT JOIN static_data_value sdv_block ON sdv_block.value_id = td.block_define_id
	LEFT JOIN source_deal_type sd_type ON sd_type.source_deal_type_id = td.source_deal_type_id
		AND sd_type.sub_type = 'n'
	WHERE td.deal_status <> 5607
		AND ISNULL(cs.[type], 17200) <> 17202
	GROUP BY  td.source_deal_header_id, td.deal_id

	IF OBJECT_ID('tempdb..#collect_deals') IS NOT NULL
		DROP TABLE #collect_deals
	
	CREATE TABLE #collect_deals (
		source_deal_header_id INT,
		allow_insert BIT
	)
	
	INSERT INTO #collect_deals(source_deal_header_id, allow_insert)
	SELECT sdh.source_deal_header_id,
		   CASE WHEN MAX(erl.[state]) = 'MATCHED' THEN 0 ELSE 1 END
	FROM #temp_deals sdh
	OUTER APPLY(
		SELECT TOP 1
			   s.source_deal_header_id,
			   s.document_id,
			   s.acer_submission_status
		FROM source_ecm s
		WHERE s.source_deal_header_id = sdh.source_deal_header_id
		ORDER BY create_ts DESC
	) src_ecm
	OUTER APPLY(
		SELECT TOP 1
			   s.document_id,
			   s.[state]
		FROM ecm_response_log s
		WHERE s.document_id = src_ecm.document_id
		ORDER BY create_ts DESC
	) erl
	WHERE sdh.deal_status <> 5607
	GROUP BY sdh.source_deal_header_id
 
	IF EXISTS (SELECT 1 FROM #collect_deals WHERE allow_insert = 0)
	BEGIN
		UPDATE c
		SET c.allow_insert = CASE WHEN cur.sender_id = pre.sender_id AND cur.receiver_id = pre.receiver_id AND cur.market = pre.market AND cur.commodity = pre.commodity AND cur.transaction_type = pre.transaction_type AND cur.delivery_point_area = pre.delivery_point_area AND cur.buyer_party = pre.buyer_party AND cur.seller_party = pre.seller_party AND cur.load_type = pre.load_type AND cur.agreement = pre.agreement AND cur.currency = pre.currency AND cur.total_volume = pre.total_volume AND cur.total_volume_unit = pre.total_volume_unit AND CAST(cur.trade_date AS DATE) = CAST(pre.trade_date AS DATE) AND cur.capacity_unit = pre.capacity_unit AND cur.price_unit_currency = pre.price_unit_currency AND CAST(cur.delivery_start AS DATETIME) = CAST(pre.delivery_start AS DATETIME) AND CAST(cur.delivery_end AS DATETIME) = CAST(pre.delivery_end AS DATETIME) AND CAST(cur.contract_capacity AS FLOAT) = CAST(pre.contract_capacity AS FLOAT) AND cur.price = pre.price AND ISNULL(cur.buyer_hubcode, '-1') = ISNULL(pre.buyer_hubcode, '-1') AND ISNULL(cur.seller_hubcode, '-1') = ISNULL(pre.seller_hubcode , '-1') THEN 0 ELSE 1 END
		FROM #collect_deals c
		CROSS APPLY (
			SELECT TOP 1 *
			FROM source_ecm s
			WHERE s.source_deal_header_id = c.source_deal_header_id
			ORDER BY create_ts DESC
		) pre
		INNER JOIN #temp_ecm cur ON cur.source_deal_header_id = pre.source_deal_header_id
		WHERE c.allow_insert = 0
	END

	IF EXISTS (SELECT 1 FROM #collect_deals WHERE allow_insert = 0) AND
	   NOT EXISTS (SELECT 1 FROM #collect_deals WHERE allow_insert = 1)
	BEGIN
		SET @err_msg = 'Selected deal(s) are already Matched.'
		
		EXEC spa_ErrorHandler -1, 'Source Remit table', 'spa_ecm', 'Error', @err_msg, 'Error' 
		RETURN
	END

	INSERT INTO #collect_deals(source_deal_header_id, allow_insert)
	SELECT DISTINCT c.source_deal_header_id, 1
	FROM #collect_deals c
	LEFT JOIN source_ecm ecm ON ecm.source_deal_header_id = c.source_deal_header_id
	LEFT JOIN ecm_response_log erl ON erl.document_id = ecm.document_id
		AND erl.[state] <> 'MATCHED'
	WHERE erl.id IS NULL

	IF EXISTS (SELECT 1 FROM #collect_deals WHERE allow_insert = 0) AND
	   EXISTS (SELECT 1 FROM #collect_deals WHERE allow_insert = 1)
	BEGIN
		SET @err_msg = 'Few deal(s) are already submitted. Only remaining deals will be submitted.'
		EXEC spa_ErrorHandler -1,'Source ECM table', 'spa_ecm', 'Error', @err_msg, 'Error'                
	END
	
	DELETE td
	FROM #temp_deals td
	INNER JOIN #collect_deals csd ON td.source_deal_header_id = csd.source_deal_header_id
	WHERE allow_insert = 0
		AND td.deal_status <> 5607
	
	DELETE te
	FROM #temp_ecm te
	LEFT JOIN #temp_deals td ON td.source_deal_header_id = te.source_deal_header_id
	WHERE td.source_deal_header_id IS NULL
     
    BEGIN TRY
		BEGIN TRANSACTION

		IF OBJECT_ID ('tempdb..#temp_messages') IS NOT NULL
			DROP TABLE #temp_messages

		CREATE TABLE #temp_messages (
        	source_deal_header_id INT,
        	[column] VARCHAR(100),
        	[messages] VARCHAR(5000)
        )
		
		INSERT INTO [source_ecm] (
			[source_deal_header_id], [deal_id], [sub_book_id], [physical_financial_flag], [document_id], [document_usage], [sender_id],
			[receiver_id], [receiver_role], [document_version], [market], [commodity], [transaction_type], [delivery_point_area], [buyer_party],
			[seller_party], [load_type], [agreement], [currency], [total_volume], [total_volume_unit], [trade_date], [capacity_unit],
			[price_unit_currency], [price_unit_capacity_unit], [total_contract_value], [delivery_start], [delivery_end], [contract_capacity],
			[price], [buyer_hubcode], [seller_hubcode], [trader_name], [ecm_document_type], [report_type], [create_date_from], [create_date_to],
			[create_ts], [acer_submission_status], [acer_submission_date], [acer_confirmation_date], [process_id], [error_validation_message], [file_export_name]
		)
		SELECT [source_deal_header_id], [deal_id], [sub_book_id], [physical_financial_flag], [document_id], [document_usage], [sender_id], [receiver_id],
			   [receiver_role], [document_version], [market], [commodity], [transaction_type], [delivery_point_area], [buyer_party], [seller_party],
			   [load_type], [agreement], [currency], [total_volume], [total_volume_unit], [trade_date], [capacity_unit], [price_unit_currency],
			   [price_unit_capacity_unit], [total_contract_value], [delivery_start], [delivery_end], [contract_capacity], [price], [buyer_hubcode],
			   [seller_hubcode], [trader_name], [ecm_document_type], [report_type], [create_date_from], [create_date_to], [create_ts], [submission_status],
			   [submission_date], [confirmation_date], [process_id], [error_validation_message], [file_export_name]
		FROM #temp_ecm

		IF OBJECT_ID('tempdb..#not_null') IS NOT NULL
			DROP TABLE #not_null

		CREATE TABLE #not_null (
			column_name VARCHAR(200),
			msg VARCHAR(1000)
		)
				
		INSERT INTO #not_null(column_name, msg) 
		VALUES ('document_id', 'document ID Must not be NULL'),
			   ('document_version', 'document version Must not be NULL'),
			   ('buyer_party', 'buyer party must not be NULL'),
			   ('seller_party', 'seller party must not be NULL'),
			   ('currency', 'Currency must not be NULL'),
			   ('total_volume', 'total volume must not be NULL'),
			   ('total_volume_unit', 'total volume unit must not be NULL'),
			   ('price_unit_currency', 'price unit currency must not be NULL'),
			   ('trade_date', 'trade date must not be NULL'),
			   ('delivery_start','delivery start must not be NULL'),
			   ('delivery_end', 'delivery end must not be NULL'),
			   ('contract_capacity', 'contract capacity must not be NULL'),
			   ('ecm_document_type', 'ecm document type must not be NULL')

		DECLARE @column_name VARCHAR(200), @msg VARCHAR(1000)
		DECLARE c CURSOR FOR 
			SELECT column_name,
				   msg
			FROM #not_null
		OPEN c 
		FETCH NEXT FROM c INTO @column_name, @msg
		WHILE @@FETCH_STATUS = 0
		BEGIN
			EXEC ('
				INSERT INTO #temp_messages (source_deal_header_id, [column], [messages])
				SELECT source_deal_header_id, ''' + @column_name + ''', ''' + @msg + '''
				FROM source_ecm
				WHERE NULLIF(' + @column_name + ', '''') IS NULL
					AND ecm_document_type = ''CNF''
					AND process_id= ''' + @process_id + ''''
			)

			FETCH NEXT FROM c INTO @column_name, @msg 
		END
		CLOSE c
		DEALLOCATE c 

		IF OBJECT_ID('tempdb..#financial_null') IS NOT NULL
			DROP TABLE #financial_null

		CREATE TABLE #financial_null (
			column_name VARCHAR(200),
			msg VARCHAR(1000)
		)
		
		INSERT INTO #financial_null(column_name, msg)
		VALUES ('market', 'Market must be NULL for financial deal'),
			   ('commodity', 'commodity must be NULL for financial deal'),
			   ('delivery_point_area', 'delivery_point_area Must be NULL for financial deal'),
			   ('load_type', 'Load type must be NULL for financial deal'),
			   ('price_unit_currency', 'Price unit currency must be NULL for financial deal'),
			   ('price_unit_capacity_unit', 'Price unit capacity unit must be NULL for financial deal')

		DECLARE c CURSOR FOR 
			SELECT column_name,
				   msg
			FROM #financial_null
		OPEN c 
		FETCH NEXT FROM c INTO @column_name, @msg
		WHILE @@FETCH_STATUS = 0
		BEGIN
			EXEC ('
				INSERT INTO #temp_messages(source_deal_header_id, [column], [messages])
				SELECT source_deal_header_id, ''' + @column_name + ''', ''' + @msg + '''
				FROM source_ecm
				WHERE physical_financial_flag = ''f''
					AND ecm_document_type = ''CNF''
					AND ' + @column_name + ' IS NOT NULL
					AND process_id= ''' + @process_id + '''
			')

			FETCH NEXT FROM c INTO @column_name, @msg 
		END
		CLOSE c
		DEALLOCATE c
		
		INSERT INTO #temp_messages(source_deal_header_id, [column], [messages])
		SELECT source_deal_header_id, 'document_id','document ID Must not exceed 255 characters'
		FROM source_ecm
		WHERE LEN(document_id) > 255
			AND ecm_document_type = 'CNF'
			AND process_id = @process_id
				
 		INSERT INTO #temp_messages(source_deal_header_id, [column], [messages])
		SELECT source_deal_header_id, 'market','Market Must be NL, BE or DE'
		FROM source_ecm
		WHERE market NOT IN ('NL', 'BE', 'DE')
			AND ecm_document_type = 'CNF'
			AND process_id = @process_id				

 		INSERT INTO #temp_messages(source_deal_header_id, [column], [messages])
		SELECT source_deal_header_id, 'currency','Currency is invalid'
		FROM source_ecm
		WHERE currency NOT IN ('BGN','CHF','CZK','DKK','EUR','EUX','GBX','GBP','HRK','HUF','ISK','NOK','PCT','PLN','RON','SEK','USD','OTH')
			AND ecm_document_type = 'CNF'
			AND process_id = @process_id	
				
 		INSERT INTO #temp_messages(source_deal_header_id, [column], [messages])
		SELECT source_deal_header_id, 'total_volume_unit','total volume unit is invalid'
		FROM source_ecm
		WHERE total_volume_unit NOT IN ('KWh','MWh','GWh','Therm','cm','mcm','MMBtu')
			AND ecm_document_type = 'CNF'
			AND process_id = @process_id	

 		INSERT INTO #temp_messages(source_deal_header_id, [column], [messages])
		SELECT source_deal_header_id, 'price_unit_currency','Price unit currency is invalid'
		FROM source_ecm
		WHERE price_unit_currency NOT IN ('BGN','CHF','CZK','DKK','EUR','EUX','GBX','GBP','HRK','HUF','ISK','NOK','PCT','PLN','RON','SEK','USD','OTH')
			AND ecm_document_type = 'CNF'
			AND process_id = @process_id	
				
 		INSERT INTO #temp_messages(source_deal_header_id, [column], [messages])
		SELECT source_deal_header_id, 'price_unit_capacity_unit','Price unit currency is invalid'
		FROM source_ecm
		WHERE price_unit_capacity_unit NOT IN ('KWh','MWh','GWh','Therm','cm','mcm','MMBtu')
			AND ecm_document_type = 'CNF'
			AND process_id = @process_id	
								
 		INSERT INTO #temp_messages(source_deal_header_id, [column], [messages])
		SELECT source_deal_header_id, 'total_contract_value','Total contract value must not be null for transaction type ''FOR'' or ''OPT'' '
		FROM source_ecm
		WHERE transaction_type IN ('FOR', 'OPT')
			AND total_contract_value IS NULL
			AND ecm_document_type = 'CNF'
			AND process_id = @process_id					
	
 		INSERT INTO #temp_messages(source_deal_header_id, [column], [messages])
		SELECT source_deal_header_id, 'buyer_hubcode','Buyer Hubcode must not be null for gas commodity '
		FROM source_ecm
		WHERE commodity = 'Gas'
			AND buyer_hubcode IS NULL
			AND ecm_document_type = 'CNF'
			AND process_id = @process_id					
	
 		INSERT INTO #temp_messages(source_deal_header_id, [column], [messages])
		SELECT source_deal_header_id, 'seller_hubcode','Seller Hubcode must not be null for gas commodity '
		FROM source_ecm
		WHERE commodity = 'Gas'
			AND seller_hubcode IS NULL
			AND ecm_document_type = 'CNF'
			AND process_id = @process_id

		UPDATE srns
		SET srns.[error_validation_message] = s.msg 
		FROM source_ecm srns
		INNER JOIN source_ecm vt_outer ON vt_outer.source_deal_header_id = srns.source_deal_header_id
			AND srns.ecm_document_type = 'CNF'
			AND srns.process_id = @process_id
		CROSS APPLY (
			SELECT STUFF((SELECT DISTINCT ','  + ISNULL((tm.[messages]), '')
						  FROM source_ecm vt
						  INNER JOIN #temp_messages tm ON vt.source_deal_header_id = tm.source_deal_header_id
						  WHERE tm.messages IS NOT NULL
							AND vt.ecm_document_type = 'CNF'
							AND vt_outer.source_deal_header_id = vt.source_deal_header_id
						  FOR XML PATH('')), 1, 1, ''
						) AS msg
			FROM source_ecm vt
			INNER JOIN #temp_messages tm ON vt.source_deal_header_id = tm.source_deal_header_id
			WHERE tm.messages IS NOT NULL
				AND vt.ecm_document_type = 'CNF'
				AND vt_outer.source_deal_header_id = vt.source_deal_header_id
			GROUP BY vt.source_deal_header_id
		) s

		IF @include_bfi = 1
		BEGIN
			INSERT INTO [source_ecm] (
				[source_deal_header_id], [deal_id], [sub_book_id], [physical_financial_flag], [document_id], [broker_fee], [document_usage], [sender_id],
				[receiver_id], [receiver_role], [document_version], [currency], [ecm_document_type], [report_type], [create_date_from], [create_date_to],
				[create_ts], [acer_submission_status], [process_id]
			)
			SELECT DISTINCT
				   td.source_deal_header_id source_deal_header_id,
				   td.deal_id deal_id,
				   MAX(td.sub_book_id) sub_book_id,
				   MAX(td.physical_financial_flag) physical_financial_flag,
				   'BFI_' + CONVERT(VARCHAR(10), GETDATE(), 112) + '_' + REPLICATE('0', 10 - LEN(RTRIM(td.source_deal_header_id))) + RTRIM(td.source_deal_header_id) + '@23X--121101ESPMJ' document_id,
				   MAX(CAST(uddf.udf_value AS FLOAT)) broker_fee,
				   'Live' document_usage,
				   '23X--121101ESPMJ' sender_id,
				   '11XRWETRADING--0' receiver_id,
				   'Broker' receiver_role,
				   CASE WHEN MAX(ecm.document_version) IS NULL THEN ROW_NUMBER() OVER(PARTITION BY td.deal_id ORDER BY td.deal_id, MAX(ecm.ecm_document_type)) ELSE MAX(ecm.document_version) + 1 END document_version,
				   MAX(CASE scur_fixed.currency_name WHEN 'Euro' THEN 'EUR'WHEN 'Ect' THEN 'EUX' WHEN 'GPC' THEN 'GBX' ELSE UPPER(scur_fixed.currency_name) END) [currency],
				   'BFI' ecm_document_type,
				   NULL [report_type],
				   @create_date_from [create_date_from],
				   @create_date_to [create_date_to],
				   @create_ts [create_ts],
				   39500 [submission_status],
				   @process_id [process_id]
			FROM #temp_deals td
			INNER JOIN #temp_deal_details tdd ON td.source_deal_header_id = tdd.source_deal_header_id
			LEFT JOIN user_defined_deal_fields_template uddft ON uddft.template_id = td.template_id
				AND uddft.field_id = @udf_broker_fee
			LEFT JOIN user_defined_deal_fields uddf ON uddf.source_deal_header_id = td.source_deal_header_id
				AND uddf.udf_template_id = uddft.udf_template_id
			LEFT JOIN source_price_curve_def spcd ON  spcd.source_curve_def_id = tdd.curve_id
        	LEFT JOIN source_commodity scom ON scom.source_commodity_id = ISNULL(spcd.commodity_id, td.commodity_id)
        	LEFT JOIN source_minor_location sml ON  sml.source_minor_location_id = tdd.location_id
        	LEFT JOIN static_data_value sdv_cntry ON sdv_cntry.type_id = 14000 AND sdv_cntry.value_id = sml.country
        	LEFT JOIN source_ecm ecm ON td.source_deal_header_id = ecm.source_deal_header_id
				AND ecm.ecm_document_type = 'BFI'
        	LEFT JOIN static_data_value sdv_deal_status ON sdv_deal_status.value_id = td.deal_status
        	LEFT JOIN source_uom tsu ON tdd.deal_volume_uom_id = tsu.source_uom_id
        	LEFT JOIN source_currency scur_fixed ON scur_fixed.source_currency_id = tdd.fixed_price_currency_id
        	LEFT JOIN static_data_value sdv_block ON sdv_block.value_id = td.block_define_id
        	LEFT JOIN source_deal_type sd_type ON sd_type.source_deal_type_id = td.source_deal_type_id
				AND sd_type.sub_type = 'n'
			WHERE td.deal_status <> 5607
				AND uddf.udf_value IS NOT NULL
			GROUP BY  td.source_deal_header_id, td.deal_id

			TRUNCATE TABLE #not_null
			TRUNCATE TABLE #temp_messages

			INSERT INTO #not_null(column_name, msg)
			VALUES ('document_id', 'document ID Must not be NULL'),
				   ('document_version', 'document version Must not be NULL'),
				   ('broker_fee', 'broker fee must not be NULL'),
				   ('currency', 'Currency must not be NULL'),
				   ('ecm_document_type', 'ecm document type must not be NULL')

			DECLARE c CURSOR FOR 
				SELECT column_name,
					   msg
				FROM #not_null
			OPEN c 
			FETCH NEXT FROM c INTO @column_name, @msg
			WHILE @@FETCH_STATUS = 0
			BEGIN
				EXEC('
					INSERT INTO #temp_messages(source_deal_header_id, [column], [messages])
					SELECT source_deal_header_id, ''' + @column_name + ''', ''' + @msg + '''
					FROM source_ecm
					WHERE NULLIF(' + @column_name + ', '''') IS NULL
						AND ecm_document_type = ''BFI''
						AND process_id = ''' + @process_id +'''
				')

				FETCH NEXT FROM c INTO @column_name, @msg 
			END
			CLOSE c
			DEALLOCATE c 
			

 			INSERT INTO #temp_messages(source_deal_header_id, [column], [messages])
			SELECT source_deal_header_id, 'document_id','document ID Must not exceed 255 characters'
			FROM source_ecm
			WHERE LEN(document_id) > 255
				AND ecm_document_type = 'BFI'
				AND process_id = @process_id
				
 			INSERT INTO #temp_messages(source_deal_header_id, [column], [messages])
			SELECT source_deal_header_id, 'currency','Currency is invalid'
			FROM source_ecm
			WHERE currency NOT IN ('BGN','CHF','CZK','DKK','EUR','EUX','GBX','GBP','HRK','HUF','ISK','NOK','PCT','PLN','RON','SEK','USD','OTH')
				AND ecm_document_type = 'BFI'
				AND process_id = @process_id	
								 
			UPDATE srns 
			SET srns.[error_validation_message] = s.msg
			FROM source_ecm srns
			INNER JOIN source_ecm vt_outer ON vt_outer.source_deal_header_id = srns.source_deal_header_id
				AND srns.ecm_document_type = 'BFI'
				AND srns.process_id = @process_id
			CROSS APPLY (
				SELECT STUFF((SELECT DISTINCT ','  + ISNULL((tm.[messages]), '')
							  FROM source_ecm vt
							  INNER JOIN #temp_messages tm ON vt.source_deal_header_id = tm.source_deal_header_id
							  WHERE tm.messages IS NOT NULL
								AND vt.ecm_document_type = 'BFI'
								AND vt_outer.source_deal_header_id = vt.source_deal_header_id
							  FOR XML PATH('')), 1, 1, '') AS msg
				FROM source_ecm vt
				INNER JOIN #temp_messages tm ON vt.source_deal_header_id = tm.source_deal_header_id
				WHERE tm.messages IS NOT NULL
					AND vt.ecm_document_type = 'BFI'
					AND vt_outer.source_deal_header_id = vt.source_deal_header_id
				GROUP BY vt.source_deal_header_id
			) s
		END  
 
		INSERT INTO [source_ecm] (
			[source_deal_header_id], [deal_id], [sub_book_id], [physical_financial_flag], [document_id], [document_usage], [sender_id],
			[receiver_id], [receiver_role], [reference_document_id], [reference_document_version], [ecm_document_type], [report_type],
			[create_date_from], [create_date_to], [create_ts], [acer_submission_status], [acer_submission_date], [acer_confirmation_date],
			[process_id], [error_validation_message], [file_export_name]
		)
		SELECT DISTINCT 
			   td.source_deal_header_id source_deal_header_id,
			   td.deal_id deal_id,
			   MAX(td.sub_book_id) sub_book_id,
			   MAX(td.physical_financial_flag) physical_financial_flag,
			   'CAN_' + CONVERT(VARCHAR(10), GETDATE(), 112) + '_' + REPLICATE('0', 10-LEN(RTRIM(td.source_deal_header_id))) + RTRIM(td.source_deal_header_id) + '@23X--121101ESPMJ' document_id,
			   'Live' document_usage,
			   '23X--121101ESPMJ' sender_id,
			   '11XRWETRADING--0' receiver_id,
			   'Trader' receiver_role,
			   MAX(ecm.document_id) reference_document_id,
			   MAX(ecm.document_version) reference_document_version,
			   'CAN' ecm_document_type,
			   NULL [report_type],
			   @create_date_from [create_date_from],
			   @create_date_to [create_date_to],
			   @create_ts [create_ts],
			   39500 [submission_status],
			   NULL [submission_date],
			   NULL [confirmation_date],
			   @process_id [process_id],
			   NULL [error_validation_message],
			   NULL [file_export_name]
		FROM #temp_deals td
        INNER JOIN #temp_deal_details tdd ON td.source_deal_header_id = tdd.source_deal_header_id
        LEFT JOIN source_price_curve_def spcd ON  spcd.source_curve_def_id = tdd.curve_id
        LEFT JOIN source_commodity scom ON scom.source_commodity_id = ISNULL(spcd.commodity_id, td.commodity_id)
        LEFT JOIN source_minor_location sml ON sml.source_minor_location_id = tdd.location_id
        LEFT JOIN static_data_value sdv_cntry ON sdv_cntry.type_id = 14000
			AND sdv_cntry.value_id = sml.country
		OUTER APPLY (
			SELECT TOP 1 * 
			FROM source_ecm e
			WHERE e.source_deal_header_id = td.source_deal_header_id
				AND e.ecm_document_type = 'CNF'
			ORDER BY create_ts DESC
		) ecm
        LEFT JOIN static_data_value sdv_deal_status ON sdv_deal_status.value_id = td.deal_status
        LEFT JOIN source_uom tsu ON tdd.deal_volume_uom_id = tsu.source_uom_id
        LEFT JOIN source_currency scur_fixed ON scur_fixed.source_currency_id = tdd.fixed_price_currency_id
        LEFT JOIN static_data_value sdv_block ON sdv_block.value_id = td.block_define_id
        LEFT JOIN source_deal_type sd_type ON sd_type.source_deal_type_id = td.source_deal_type_id
			AND sd_type.sub_type = 'n'
		WHERE td.deal_status = 5607
		GROUP BY  td.source_deal_header_id, td.deal_id

		TRUNCATE TABLE #not_null
		TRUNCATE TABLE #temp_messages

		INSERT INTO #not_null(column_name, msg)
		VALUES ('document_id', 'document ID Must not be NULL'),
			   ('ecm_document_type', 'ecm document type must not be NULL')

		DECLARE c CURSOR FOR 
			SELECT column_name,
				   msg
			FROM #not_null
		OPEN c 
		FETCH NEXT FROM c INTO @column_name, @msg
		WHILE @@FETCH_STATUS = 0
		BEGIN
			EXEC ('
				INSERT INTO #temp_messages(source_deal_header_id, [column], [messages])
				SELECT source_deal_header_id, ''' + @column_name + ''', ''' + @msg + '''
				FROM source_ecm
				WHERE NULLIF(' + @column_name + ', '''') IS NULL
					AND ecm_document_type = ''CAN''
					AND process_id= ''' + @process_id + '''
			')

			FETCH NEXT FROM c INTO @column_name, @msg 
		END
		CLOSE c
		DEALLOCATE c
		
		INSERT INTO #temp_messages(source_deal_header_id, [column], [messages])
		SELECT source_deal_header_id, 'document_id','document ID Must not exceed 255 characters'
		FROM source_ecm
		WHERE LEN(document_id) > 255
			AND ecm_document_type = 'CAN'
			AND process_id = @process_id
			
		UPDATE srns
		SET srns.[error_validation_message] = s.msg
		FROM source_ecm srns
		INNER JOIN source_ecm vt_outer ON vt_outer.source_deal_header_id = srns.source_deal_header_id
			AND srns.ecm_document_type = 'CAN'
			AND srns.process_id = @process_id
		CROSS APPLY (
			SELECT STUFF((SELECT DISTINCT ','  + ISNULL((tm.[messages]),'')
						  FROM source_ecm vt
						  INNER JOIN #temp_messages tm ON vt.source_deal_header_id = tm.source_deal_header_id
						  WHERE tm.messages IS NOT NULL
							AND vt.ecm_document_type = 'CAN'
							AND vt_outer.source_deal_header_id = vt.source_deal_header_id
						  FOR XML PATH('')
					), 1, 1, '') AS msg
			FROM source_ecm vt
			INNER JOIN #temp_messages tm ON vt.source_deal_header_id = tm.source_deal_header_id
			WHERE tm.messages IS NOT NULL
				AND vt.ecm_document_type = 'CAN'
				AND vt_outer.source_deal_header_id = vt.source_deal_header_id
			GROUP BY vt.source_deal_header_id
		) s

		EXEC spa_ErrorHandler 0, 'Regulatory Submission', 'spa_ecm', 'Success', 'Data saved successfully.', ''
		COMMIT
	END TRY
    BEGIN CATCH
        DECLARE @err_no INT,
				@err VARCHAR(MAX)
        SET @err = 'Failed to save data. Error:' + ERROR_MESSAGE()

		IF @@TRANCOUNT > 0
            	ROLLBACK	
        
		EXEC spa_ErrorHandler -1, 'Ecm', 'spa_ecm', 'Error', @err, ''
    END CATCH
END
ELSE IF @flag = 'r'
BEGIN
	BEGIN TRY
		DECLARE @result VARCHAR(MAX),
				@output_folder VARCHAR(1000),
				@archive_folder VARCHAR(1000)
	
		SELECT TOP (1)
			   @output_folder = gmv.clm2_value,
			   @archive_folder = gmv.clm3_value
		FROM generic_mapping_header gmh
		INNER JOIN generic_mapping_values gmv ON gmv.mapping_table_id = gmh.mapping_table_id
		WHERE gmh.mapping_name = 'Ecm_Config'
	
		EXEC [spa_read_ecm_xml_folder] @output_folder, @archive_folder, @result OUTPUT
	
		DECLARE @response_deal_id INT
	
		IF ISNULL(NULLIF(@result, ''), '0') <> '0'
		BEGIN
			DECLARE c CURSOR FOR		
				SELECT DISTINCT se.source_deal_header_id
				FROM source_ecm se		   
				INNER JOIN dbo.FNASplit(@result, ',') doc ON doc.item = se.document_id
				CROSS APPLY (
					SELECT TOP 1 *
					FROM ecm_response_log erl
					WHERE erl.document_id = se.document_id
						AND erl.document_version = se.document_version
					ORDER BY erl.create_ts DESC
				) r
			   WHERE r.state = 'Matched'
	   		OPEN c
			FETCH NEXT FROM c INTO @response_deal_id
			WHILE @@FETCH_STATUS = 0
			BEGIN
				EXEC spa_confirm_status 'i', NULL, @response_deal_id, '17202', @create_ts, NULL , NULL ,  NULL, 'c', '5605', 'n', NULL, NULL, NULL, n
			
				FETCH NEXT FROM c INTO @response_deal_id
			END
			CLOSE c
			DEALLOCATE c 
		END	   
	END TRY
	BEGIN CATCH
		PRINT 'Catch Error:' + ERROR_MESSAGE()
		IF @@TRANCOUNT > 0
			ROLLBACK	
	END CATCH 
END
ELSE IF @flag = 'x'
BEGIN
	SELECT id [ID],
		   source_deal_header_id [Source Deal Header ID],
		   deal_id [Deal ID],
		   sub_book_id [Sub Book ID],
		   physical_financial_flag [Physical Financial Flag],
		   document_id [Document ID],
		   document_usage [Document Usage],
		   sender_id [Sender ID],
		   receiver_id [Receiver ID],
		   receiver_role [Receiver Role],
		   document_version [Document Version],
		   market [Market],
		   commodity [Commodity],
		   transaction_type [Transaction Type],
		   delivery_point_area [Delivery Point Area],
		   buyer_party [Buyer Party],
		   seller_party [Seller Party],
		   load_type [Load Type],
		   agreement [Agreement],
		   currency [Currency],
		   total_volume [Total Volume],
		   total_volume_unit [Total Volume Unit],
		   trade_date [Trade Date],
		   capacity_unit [Capacity Unit],
		   price_unit_currency [Price Unit Currency],
		   price_unit_capacity_unit [Price Unit Capacity Unit],
		   total_contract_value [Total Contract Value],
		   delivery_start [Delivery Start],
		   delivery_end [Delivery End],
		   contract_capacity [Contract Capacity],
		   price [Price],
		   buyer_hubcode [Buyer Hubcode],
		   seller_hubcode [Seller Hubcode],
		   trader_name [Trader Name],
		   ecm_document_type [Ecm Document Type],
		   broker_fee [Broker Fee],
		   reference_document_id [Reference Document ID],
		   reference_document_version [Reference Document Version],
		   report_type [Report Type],
		   create_date_from [Create Date From],
		   create_date_to [Create Date To],
		   acer_submission_status [Acer Submission Status],
		   acer_submission_date [Acer Submission Date],
		   acer_confirmation_date [Acer Confirmation Date],
		   process_id [Process ID],
		   file_export_name [File Export Name],
		   error_validation_message [Error ValiDation Message]		   
	FROM source_ecm 
	WHERE process_id = @process_id
END
GO