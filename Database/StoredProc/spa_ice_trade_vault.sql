IF OBJECT_ID (N'[dbo].[spa_ice_trade_vault]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[spa_ice_trade_vault]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[spa_ice_trade_vault]
	@flag CHAR(1),
	@filter_table_process_id VARCHAR(100) = NULL,
	@create_date_from VARCHAR(100) = NULL,
	@create_date_to VARCHAR(100) = NULL,
	@process_id VARCHAR(100) = NULL,
	@batch_process_id VARCHAR(100) = '',
	@batch_report_param VARCHAR(500) = NULL
AS
/*-------------Debug Section--------------------
DECLARE	@flag CHAR(1),
		@filter_table_process_id VARCHAR(100) = NULL,
		@create_date_from VARCHAR(100) = NULL,
		@create_date_to VARCHAR(100) = NULL,
		@process_id VARCHAR(100) = NULL,
		@batch_process_id VARCHAR(100) = '',
		@batch_report_param VARCHAR(500) = NULL

SELECT @flag='g', @process_id='3E2E8760_E197_49CE_B570_51268918CB20',@batch_process_id='594A3CCF_9109_4945_BB0F_C9CBE0A1380E_5cb6fdbdc1dbc',@batch_report_param='spa_ice_trade_vault @flag=''g'', @process_id=''3E2E8760_E197_49CE_B570_51268918CB20'''
----------------------------------------------*/
SET NOCOUNT ON

IF @batch_process_id IS NOT NULL AND @batch_report_param IS NOT NULL
BEGIN
	DECLARE @str_batch_table VARCHAR(MAX) = '', @temp_table_name VARCHAR(200) = ''

	IF (@batch_process_id IS NULL)
		SET @batch_process_id = REPLACE(NEWID(), '-', '_')
	
	SET @temp_table_name = dbo.FNAProcessTableName('batch_report', dbo.FNADBUser(), @batch_process_id)

	SET @str_batch_table = ' INTO ' + @temp_table_name
END

DECLARE @file_name VARCHAR(500),
		@file_path VARCHAR(500),
		@job_name VARCHAR(100) = 'report_batch_' + @batch_process_id,
		@user_name VARCHAR(100) = dbo.FNADBUser()

SET @file_name = 'ICE_Vault_Export_' + REPLACE(REPLACE(REPLACE(CONVERT(VARCHAR(19), GETDATE(), 120), ' ', '_'), ':', '-'), '-', '_') + '.txt'
SELECT @file_path = document_path FROM connection_string

IF @flag = 'i'
BEGIN
	DECLARE @ssbm_table_name VARCHAR(120),
			@deal_header_table_name VARCHAR(120),
			@deal_detail_table_name VARCHAR(120),
			@n_process_id VARCHAR(100) = dbo.FNAGetNewID()

	SET @ssbm_table_name = dbo.FNAProcessTableName('ssbm', dbo.FNADBUser(), @filter_table_process_id)
	SET @deal_header_table_name = dbo.FNAProcessTableName('deal_header', dbo.FNADBUser(), @filter_table_process_id)
	SET @deal_detail_table_name = dbo.FNAProcessTableName('deal_detail', dbo.FNADBUser(), @filter_table_process_id)

	IF OBJECT_ID ('tempdb..#ssbm') IS NOT NULL
		DROP TABLE #ssbm

	CREATE TABLE #ssbm (
		[sub_id] INT,
		[stra_id] INT,
		[book_id] INT,
		[sub] VARCHAR(100) COLLATE DATABASE_DEFAULT,
		[stra] VARCHAR(100) COLLATE DATABASE_DEFAULT,
		[book] VARCHAR(100) COLLATE DATABASE_DEFAULT,
		[source_system_book_id1] INT,
		[source_system_book_id2] INT,
		[source_system_book_id3] INT,
		[source_system_book_id4] INT,
		[logical_name] VARCHAR(200) COLLATE DATABASE_DEFAULT,
		[sub_book_id] INT,
		[counterparty_id] INT
	) 

	EXEC ('
		INSERT INTO #ssbm
		SELECT * FROM ' + @ssbm_table_name + '
	')

	IF OBJECT_ID('tempdb..#temp_deals') IS NOT NULL
		DROP TABLE #temp_deals

	CREATE TABLE #temp_deals (
		source_deal_header_id INT,
		deal_id VARCHAR(200),
		template_id INT,
		counterparty_id INT,
		sub_book_id INT,
		deal_date DATETIME,
		physical_financial_flag CHAR(10),
		entire_term_start DATETIME,
		entire_term_end DATETIME,
		source_deal_type_id INT,
		deal_sub_type_type_id INT,
		option_flag CHAR(1),
		option_type CHAR(1),
		option_excercise_type CHAR(1),
		header_buy_sell_flag VARCHAR(1),
		create_ts DATETIME,
		update_ts DATETIME,
		internal_desk_id INT,
		product_id INT,
		commodity_id INT,
		block_define_id INT,
		deal_status INT,
		description1 VARCHAR(260),
		description2 VARCHAR(260),
		trader_id INT,
		contract_id INT,
		deal_group_id INT,
		ext_deal_id VARCHAR(512),
		confirm_status VARCHAR(1000),
		[commodity_name] VARCHAR(1000)
	)

	EXEC ('
		INSERT INTO #temp_deals
		SELECT * FROM ' + @deal_header_table_name + '
	')

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

	IF OBJECT_ID('tempdb..#tmp_filters') IS NOT NULL
		DROP TABLE #tmp_filters

	SELECT DISTINCT
		   NULLIF(t.clm1_value, 0) AS source_contract_id,
		   t.clm2_value AS source_book_id,
		   t.clm3_value AS source_deal_type_id,
		   t.clm4_value AS source_deal_sub_type_id,
		   t.clm5_value AS source_commodity_id,
		   t.clm6_value AS source_template_id,
		   t.clm7_value AS source_confirmation_status_id,
		   t.clm8_value AS source_deal_status_id,
		   t.clm9_value AS source_submission_type_id
	INTO #tmp_filters
	FROM generic_mapping_header gmh
	INNER JOIN generic_mapping_values t ON gmh.mapping_table_id = t.mapping_table_id
	WHERE gmh.mapping_name = 'Submission Field Mapping'

	IF OBJECT_ID('tempdb..#tmp_counterparty_udf') IS NOT NULL
		DROP TABLE #tmp_counterparty_udf
	
	SELECT musddv.primary_field_object_id AS counterparty_id,
		   musddv.static_data_udf_values AS flag
	INTO #tmp_counterparty_udf
	FROM application_ui_template aut
	INNER JOIN application_ui_template_group ag ON aut.application_ui_template_id = ag.application_ui_template_id
	INNER JOIN application_ui_template_definition ad on aut.application_function_id = ad.application_function_id
	INNER JOIN application_ui_template_fields autf ON autf.application_group_id = ag.application_group_id
		AND autf.application_ui_field_id = ad.application_ui_field_id
	INNER JOIN maintain_udf_static_data_detail_values musddv ON musddv.application_field_id = autf.application_field_id
	WHERE aut.template_name ='SetupCounterparty'
		AND musddv.static_data_udf_values IN ('Y','N')

	BEGIN TRY
		BEGIN TRANSACTION
		INSERT INTO source_ice_trade_vault
		SELECT source_deal_header_id = sdh.source_deal_header_id,
			   sender_trade_ref_id = sdh.deal_id,
			   trade_date = REPLACE(CONVERT(VARCHAR(11), MAX(sdh.deal_date), 106), ' ', '-'),
			   commodity = MAX(scom.commodity_name),
			   position = CASE MAX(sdd.buy_sell_flag) WHEN 'b' THEN 'Buy' WHEN 's' THEN 'Sell'  ELSE NULL END,
			   buyer = CASE MAX(sdd.buy_sell_flag) WHEN 'b' THEN MAX(scp.counterparty_name) ELSE MAX(sc.counterparty_name) END,
			   [index] = MAX(spcd.curve_name),
			   price = dbo.FNARemoveTrailingZeroes(MAX(sdd.fixed_price)),
			   quantity = dbo.FNARemoveTrailingZeroes(MAX(sdd.deal_volume)),
			   [start_date] = REPLACE(CONVERT(VARCHAR(11), MAX(sdh.entire_term_start), 106), ' ', '-'),
			   end_date = REPLACE(CONVERT(VARCHAR(11), MAX(sdh.entire_term_end), 106), ' ', '-'),
			   accounting_treatment = MAX(sdh.description2),
			   total_quantity = dbo.FNARemoveTrailingZeroes(SUM(sdd.total_volume)),
			   seller = CASE MAX(sdd.buy_sell_flag) WHEN 'b' THEN MAX(sc.counterparty_name) ELSE MAX(scp.counterparty_name) END,
			   [broker] = ISNULL(NULLIF(MAX(sb2.counterparty_name), ''), 'No broker' ),
			   payment_calendar = CASE WHEN (MAX(sc.counterparty_name) = 'BP Canada Energy Group ULC' AND MAX(scom.commodity_name) = 'Gas') THEN 'NY Banks' ELSE 'Toronto Banks' END,
			   payment_from = 'After Settlement',
			   price_currency = MAX(scc.currency_name),
			   settlement_currency = MAX(scc.currency_name),
			   seller_pay_index = MAX(spcd.curve_definition),
			   hours_from_thru = CASE MAX(scom.commodity_name) WHEN 'Power' THEN MAX(block_d.description) ELSE NULL END,
			   hours_from_thru_timezone = CASE MAX(scom.commodity_name) WHEN 'Power' THEN 'MPT' ELSE NULL END,
			   load_type = CASE MAX(scom.commodity_name) WHEN 'Power' THEN CASE MAX(stou.code) WHEN 'Offpeak' THEN 'Off Peak' WHEN 'Onpeak' THEN 'On Peak' END ELSE NULL END,
			   days_of_week = CASE MAX(scom.commodity_name) WHEN 'Power' THEN 'M-Su' ELSE NULL END,
			   master_agreement_type = MAX(cg.contract_name),
			   contract_date = REPLACE(CONVERT(VARCHAR(11), MAX(cca.contract_start_date), 106), ' ', '-'),
			   master_agreement_version = '2002',
			   market_type = (CASE MAX(sdh.physical_financial_flag) WHEN 'p' THEN 'Physical' WHEN 'f' THEN 'Financial' ELSE NULL END + ' ' + MAX(scom.commodity_name)),
			   trade_type = CASE WHEN (MAX(sc.counterparty_name) = 'BP Canada Energy Group ULC' AND MAX(scom.commodity_name) = 'Gas') THEN 'Fixed Price for Swing' ELSE (MAX(scom.commodity_name) + ' Fixed Price ') END,
			   product_id = CASE WHEN (MAX(sc.counterparty_name) = 'BP Canada Energy Group ULC' AND MAX(scom.commodity_name) = 'Gas') THEN '303' ELSE CASE MAX(scom.commodity_name) WHEN 'Power' THEN 600 ELSE 309 END END,
			   product_name = CASE MAX(sdt.source_deal_type_name) WHEN 'Swap' THEN (CASE MAX(sdh.physical_financial_flag) WHEN 'p' THEN 'Phy' ELSE 'Fin' END  + ' ' + MAX(scom.commodity_name) + ' FP SWAP') ELSE  (CASE MAX(sdh.physical_financial_flag) WHEN 'p' THEN 'Phy' ELSE 'Fin' END  + ' ' + MAX(scom.commodity_name)) END,
			   reportable_product = 'y',
			   contract_type = MAX(sdt.source_deal_type_name),
			   swap_purpose = 'Undisclosed',
			   settlement_method = 'Cash',
			   price_unit = MAX(pouom.uom_name),
			   quantity_unit = MAX(pouom.uom_name),
			   quantity_frequency = CASE MAX(sdd.deal_volume_frequency) WHEN 'd' THEN 'Daily' WHEN 'm' THEN 'Monthly' WHEN 'h' THEN 'Hourly' END,
			   settlement_frequency = 'Monthly',
			   seller_index_pricing_calendar = CASE WHEN (MAX(sc.counterparty_name) = 'BP Canada Energy Group ULC' AND MAX(scom.commodity_name) = 'Gas') THEN 'Gas Daily' ELSE CASE MAX(scom.commodity_name) WHEN 'Power' THEN 'Include' ELSE 'Canadian Gas Price Reporter' END END,
			   payment_days = CASE MAX(scom.commodity_name) WHEN 'Power' THEN 10 ELSE 5 END,
			   payment_terms = 'Business',
			   currency_conversion = 'None',
			   currency_conversion_source = 'None',
			   execution_venue = 'Off Facility',
			   [compression] = 'N',
			   cleared = 'N',
			   ussdr_reportable_trade = 'N',
			   extra_legal_language = 'N',
			   allocation_trade = 'None',
			   inter_affiliate_clearing_exemption_election = 'N',
			   emir_reportable_trade = 'N',
			   execution_time = CONVERT(VARCHAR(27), MAX(sdh.create_ts), 126),
			   collateralization_type = 'Uncollateralized',
			   execution_time_creator = CASE MAX(sdd.buy_sell_flag) WHEN 'b' THEN 'Buyer' WHEN 's' THEN 'Seller' END,
			   uti_creator = CASE MAX(sdd.buy_sell_flag) WHEN 'b' THEN 'Buyer' WHEN 's' THEN 'Seller' END,
			   buyer_cadtr = 'ICE Trade Vault Canada',
			   cad_clearing_exemption = 'N',
			   cad_reporting_entity = CASE WHEN (MAX(tcu.flag) = 'y' AND MAX(sdd.buy_sell_flag) = 'b') THEN 'Buyer'
										   WHEN (MAX(tcu.flag) = 'y' AND MAX(sdd.buy_sell_flag) = 's') THEN 'Seller'
										   WHEN (MAX(tcu.flag) = 'n' AND MAX(sdd.buy_sell_flag) = 'b') THEN 'Seller'
										   WHEN (MAX(tcu.flag) = 'n' AND MAX(sdd.buy_sell_flag) = 's') THEN 'Buyer'
									  END,
			   seller_cadtr = 'ICE Trade Vault Canada',
			   cad_historic_swap = 'N',
			   csa_reportable_trade = MAX(tcu.flag),
			   create_date_from = @create_date_from,
			   create_date_to = @create_date_to,
			   ice_vault_submission_status = 39500,
			   process_id = @n_process_id,
			   report_type_id = NULL,
			   create_user = dbo.FNADBUSER(),
			   create_ts = GETDATE(),
			   update_user = NULL,
			   update_ts = NULL,
			   [file_name] = @file_name
		FROM source_deal_header sdh
		INNER JOIN #temp_deals td ON sdh.source_deal_header_id = td.source_deal_header_id
		INNER JOIN source_deal_detail sdd ON sdh.source_deal_header_id = sdd.source_deal_header_id
		INNER JOIN #temp_deal_details tdd ON tdd.source_deal_detail_id = sdd.source_deal_detail_id
		INNER JOIN #ssbm books ON books.source_system_book_id1 = sdh.source_system_book_id1
			AND books.source_system_book_id2 = sdh.source_system_book_id2
			AND books.source_system_book_id3 = sdh.source_system_book_id3
			AND books.source_system_book_id4 = sdh.source_system_book_id4
		/*INNER JOIN #tmp_filters tf ON COALESCE(tf.source_contract_id, sdh.contract_id, '') = ISNULL(sdh.contract_id, '')
			AND ISNULL(tf.source_book_id, books.book_id) = books.book_id
			AND COALESCE(tf.source_deal_type_id, sdh.source_deal_type_id, '') = ISNULL(sdh.source_deal_type_id, '')
			AND COALESCE(tf.source_deal_sub_type_id, sdh.deal_sub_type_type_id, '') = ISNULL(sdh.deal_sub_type_type_id, '')
			AND COALESCE(tf.source_commodity_id, sdh.commodity_id, '') = ISNULL(sdh.commodity_id, '')
			AND COALESCE(tf.source_template_id, sdh.template_id, '') = ISNULL(sdh.template_id, '')
			AND COALESCE(tf.source_confirmation_status_id, sdh.confirm_status_type, 17200) = ISNULL(sdh.confirm_status_type, 17200)
			AND COALESCE(tf.source_deal_status_id, sdh.deal_status, '') = ISNULL(sdh.deal_status, '')
			AND tf.source_submission_type_id = 44701
		INNER JOIN #tmp_counterparty_udf tcu ON tcu.counterparty_id = sdh.counterparty_id 
		*/LEFT JOIN #tmp_counterparty_udf tcu ON tcu.counterparty_id = sdh.counterparty_id --To Do: remove this join
		LEFT JOIN source_commodity scom ON sdh.commodity_id = scom.source_commodity_id
		LEFT JOIN source_product sp ON sdh.product_id = sp.source_product_id
		LEFT JOIN source_counterparty sc ON sdh.counterparty_id = sc.source_counterparty_id
		LEFT JOIN source_price_curve_def spcd ON sdd.curve_id = spcd.source_curve_def_id
		LEFT JOIN static_data_value block_d ON block_d.value_id = spcd.block_define_id
		LEFT JOIN source_counterparty scp ON books.counterparty_id = scp.source_counterparty_id
		LEFT JOIN source_currency scc ON sdd.fixed_price_currency_id = scc.source_currency_id
		LEFT JOIN contract_group cg ON sdh.contract_id = cg.contract_id
		LEFT JOIN static_data_value sdv_bd ON spcd.block_define_id = sdv_bd.value_id
		LEFT JOIN static_data_value stou ON stou.value_id = spcd.curve_tou
		LEFT JOIN time_zones tz ON spcd.time_zone = tz.timezone_id
		LEFT JOIN source_deal_type sdt ON sdh.source_deal_type_id = sdt.source_deal_type_id
		LEFT JOIN source_uom puom ON sdd.price_uom_id = puom.source_uom_id
		LEFT JOIN source_uom pouom ON sdd.position_uom = pouom.source_uom_id
		LEFT JOIN counterparty_contract_address cca ON cca.counterparty_id = sdh.counterparty_id
			AND cca.contract_id = sdh.contract_id
		OUTER APPLY (
			SELECT DISTINCT
				   sb2.source_counterparty_id,
				   sb2.counterparty_name
			FROM user_defined_deal_fields_template uddft
			INNER JOIN user_defined_deal_fields uddf ON uddf.udf_template_id = uddft.udf_template_id
				AND sdh.source_deal_header_id = uddf.source_deal_header_id
			INNER JOIN source_counterparty sb2 ON CAST(sb2.source_counterparty_id AS VARCHAR) = uddf.udf_value
			WHERE uddft.template_id = sdh.template_id
		) sb2
		GROUP BY sdh.source_deal_header_id, sdh.deal_id

		EXEC spa_ErrorHandler 0, 'ICE Vault Export', 'spa_source_ice_trade_vault', 'Success', 'Data successfully saved.', ''
		COMMIT
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 1
			ROLLBACK

		EXEC spa_ErrorHandler -1, 'ICE Vault Export', 'spa_source_ice_trade_vault', 'Error', 'Fail to save data.', ''
	END CATCH
END
ELSE IF @flag = 'd'
BEGIN
	SELECT source_deal_header_id AS [SenderTradeRefId],
			trade_date [TradeDate],
			commodity [Commodity],
			position [Position],
			buyer [Buyer],
			[index] [Index],
			price [Price],
			quantity [Quantity],
			start_date [StartDate],
			end_date [EndDate],
			accounting_treatment [Accounting Treatment],
			total_quantity [TotalQuantity],
			seller [Seller],
			broker [Broker],
			payment_calendar [PaymentCalendar],
			payment_from [PaymentFrom],
			price_currency [PriceCurrency],
			settlement_currency [SettlementCurrency],
			seller_pay_index [SellerPayIndex],
			hours_from_thru [HoursFromThru],
			hours_from_thru_timezone [HoursFromThruTimezone],
			load_type [LoadType],
			days_of_week [DaysOfWeek],
			master_agreement_type [MasterAgreementType],
			contract_date [ContractDate],
			master_agreement_version [MasterAgreementVersion],
			market_type [MarketType],
			trade_type [TradeType],
			product_id [ProductId],
			product_name [ProductName],
			reportable_product [ReportableProduct],
			contract_type [ContractType],
			swap_purpose [SwapPurpose],
			settlement_method [SettlementMethod],
			price_unit [PriceUnit],
			quantity_unit [QuantityUnit],
			quantity_frequency [QuantityFrequency],
			settlement_frequency [SettlementFrequency],
			seller_index_pricing_calendar [SellerIndexPricingCalendar],
			payment_days [PaymentDays],
			payment_terms [PaymentTerms],
			currency_conversion [CurrencyConversion],
			currency_conversion_source [CurrencyConversionSource],
			execution_venue [ExecutionVenue],
			compression [Compression],
			cleared [Cleared],
			ussdr_reportable_trade [USSDRReportableTrade],
			extra_legal_language [ExtraLegalLanguage],
			allocation_trade [AllocationTrade],
			inter_affiliate_clearing_exemption_election [InterAffiliateClearingExemptionElection],
			emir_reportable_trade [EMIRReportableTrade],
			execution_time [ExecutionTime],
			collateralization_type [CollateralizationType],
			execution_time_creator [ExecutionTimeCreator],
			uti_creator [UTICreator],
			buyer_cadtr [BuyerCADTR],
			cad_clearing_exemption [CADClearingExemption],
			cad_reporting_entity [CADReportingEntity],
			seller_cadtr [SellerCADTR],
			cad_historic_swap [CADHistoricSwap],
			csa_reportable_trade [CSAReportableTrade]
	FROM source_ice_trade_vault
	WHERE process_id = @process_id
END
ELSE IF @flag = 'g'
BEGIN
	IF EXISTS(SELECT 1 FROM source_ice_trade_vault WHERE process_id =  @process_id)
	BEGIN
		DECLARE @deal_info_process_table VARCHAR(200),
				@deal_information NVARCHAR(MAX),
				@export_file_name NVARCHAR(1024),
				@sql VARCHAR(MAX)

		SET @deal_info_process_table = dbo.FNAProcessTableName('deal_information', dbo.FNADBUser(), REPLACE(NEWID(), '-', '_'))
		
		SELECT @file_name = [file_name] 
		FROM source_ice_trade_vault
		WHERE process_id = @process_id
				
		SET @export_file_name = @file_path + '\temp_Note\' + @file_name
	
		SET @sql = '
			SELECT source_deal_header_id AS [SenderTradeRefId],
				   trade_date [TradeDate],
				   commodity [Commodity],
				   position [Position],
				   buyer [Buyer],
				   [index] [Index],
				   price [Price],
				   quantity [Quantity],
				   start_date [StartDate],
				   end_date [EndDate],
				   accounting_treatment [Accounting Treatment],
				   total_quantity [TotalQuantity],
				   seller [Seller],
				   broker [Broker],
				   payment_calendar [PaymentCalendar],
				   payment_from [PaymentFrom],
				   price_currency [PriceCurrency],
				   settlement_currency [SettlementCurrency],
				   seller_pay_index [SellerPayIndex],
				   hours_from_thru [HoursFromThru],
				   hours_from_thru_timezone [HoursFromThruTimezone],
				   load_type [LoadType],
				   days_of_week [DaysOfWeek],
				   master_agreement_type [MasterAgreementType],
				   contract_date [ContractDate],
				   master_agreement_version [MasterAgreementVersion],
				   market_type [MarketType],
				   trade_type [TradeType],
				   product_id [ProductId],
				   product_name [ProductName],
				   reportable_product [ReportableProduct],
				   contract_type [ContractType],
				   swap_purpose [SwapPurpose],
				   settlement_method [SettlementMethod],
				   price_unit [PriceUnit],
				   quantity_unit [QuantityUnit],
				   quantity_frequency [QuantityFrequency],
				   settlement_frequency [SettlementFrequency],
				   seller_index_pricing_calendar [SellerIndexPricingCalendar],
				   payment_days [PaymentDays],
				   payment_terms [PaymentTerms],
				   currency_conversion [CurrencyConversion],
				   currency_conversion_source [CurrencyConversionSource],
				   execution_venue [ExecutionVenue],
				   compression [Compression],
				   cleared [Cleared],
				   ussdr_reportable_trade [USSDRReportableTrade],
				   extra_legal_language [ExtraLegalLanguage],
				   allocation_trade [AllocationTrade],
				   inter_affiliate_clearing_exemption_election [InterAffiliateClearingExemptionElection],
				   emir_reportable_trade [EMIRReportableTrade],
				   execution_time [ExecutionTime],
				   collateralization_type [CollateralizationType],
				   execution_time_creator [ExecutionTimeCreator],
				   uti_creator [UTICreator],
				   buyer_cadtr [BuyerCADTR],
				   cad_clearing_exemption [CADClearingExemption],
				   cad_reporting_entity [CADReportingEntity],
				   seller_cadtr [SellerCADTR],
				   cad_historic_swap [CADHistoricSwap],
				   csa_reportable_trade [CSAReportableTrade]
			INTO ' + @deal_info_process_table + '
			FROM source_ice_trade_vault
			WHERE process_id = ''' + @process_id + ''''
		
			EXEC(@sql)
			
			EXEC spa_export_to_csv @deal_info_process_table, @export_file_name, 'y', 'tab', 'n', 'y', 'n', 'n', @deal_information OUTPUT 
			
			IF @deal_information = 1
			BEGIN
				UPDATE source_ice_trade_vault
				SET acer_submission_status = 39401
				WHERE process_id = @process_id

				EXEC spa_ErrorHandler 0, 'ICE Vault Export', 'spa_source_remit', 'Success', 'Trade details generated successfully', ''
			END
			ELSE
			BEGIN
				EXEC spa_ErrorHandler 0, 'ICE Vault Export', 'spa_source_remit', 'Error', 'Trade details generation failed', ''
			END
	END
	ELSE
	BEGIN
		EXEC spa_message_board 'u', @user_name, NULL, 'ICE Vault', 'No data to submit.', '', '', 's', @job_name, NULL, @batch_process_id, NULL, NULL, NULL, 'n', 
					'No data to submit.', 'spa_ice_trade_vault' , NULL, NULL,NULL, ''
		RETURN
	END
END

IF @batch_process_id IS NOT NULL AND @batch_report_param IS NOT NULL
BEGIN
	DECLARE @desc VARCHAR(2048)

	SELECT @str_batch_table = dbo.FNABatchProcess('u', @batch_process_id, @batch_report_param, GETDATE(), NULL, NULL)	
	EXEC (@str_batch_table)
	
	SET @desc = 'Batch process completed for <b>ICE Trade Vault</b>.Report has been saved. Please <a target="_blank" href="../../adiha.php.scripts/dev/shared_docs/temp_Note/' + @file_name + '"><b>Click Here</a></b> to download.'

	EXEC spa_message_board 'u', @user_name, NULL, 'ICE Trade Vault', @desc, NULL, NULL, 's', @job_name, NULL, @batch_process_id, NULL, NULL,NULL, 'y', 'Batch process completed for <b>ICE Trade Vault</b>.', NULL, NULL, NULL,NULL, NULL
END