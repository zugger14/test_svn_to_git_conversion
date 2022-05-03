IF OBJECT_ID(N'spa_source_emir', N'P') IS NOT NULL
	DROP PROCEDURE [dbo].[spa_source_emir]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[spa_source_emir]
	@create_date_from VARCHAR(100) = NULL,
	@create_date_to VARCHAR(100) = NULL,
	@process_id VARCHAR(MAX) = NULL,
	@flag CHAR(1) = NULL,
	@report_id VARCHAR(1000) = NULL,
	@status INT = 39500,
	@submission_type INT = NULL,
	@action_type CHAR(4) = NULL,
	@level CHAR(1) = NULL,
	@is_detail BIT = 0,
	@action_type_mifid CHAR(4) = NULL,
	@level_mifid VARCHAR(10) = NULL,
	@submit_process_id VARCHAR(100) = NULL OUTPUT,
	@deal_date_from VARCHAR(10) = NULL,
	@deal_date_to VARCHAR(10) = NULL,
	@valuation_date VARCHAR(10) = '',
	@filter_table_process_id VARCHAR(100) = NULL,
	@batch_process_id VARCHAR(100) = '',	
	@batch_report_param VARCHAR(500) = NULL
AS

/******************Test Code Start********************
--DECLARE @contextinfo VARBINARY(128) = CONVERT(VARBINARY(128), 'DEBUG_MODE_ON')
--SET CONTEXT_INFO @contextinfo

DECLARE @create_date_from VARCHAR(100) = NULL,
		@create_date_to VARCHAR(100) = NULL,
		@process_id VARCHAR(MAX) = NULL,
		@flag CHAR(1) = NULL,
		@report_id VARCHAR(1000) = NULL,
		@status INT = 39500,
		@submission_type INT = NULL,
		@action_type CHAR(1) = NULL,
		@level CHAR(1) = NULL,
		@is_detail BIT = 0,
		@action_type_mifid CHAR(4) = NULL,
		@level_mifid VARCHAR(10) = NULL,
		@submit_process_id VARCHAR(100) = NULL,
		@deal_date_from VARCHAR(10) = NULL,
		@deal_date_to VARCHAR(10) = NULL,
		@valuation_date VARCHAR(10) = '',
		@filter_table_process_id VARCHAR(100) = NULL,
		@batch_process_id VARCHAR(100) = '',
		@batch_report_param VARCHAR(500) = NULL

SELECT  @create_date_from='2019-05-30', @create_date_to='2019-05-31', @flag='i', @submission_type=44703, @action_type='N',
		@level='P', @action_type_mifid='', @level_mifid='',
		@deal_date_from='', @deal_date_to='', @valuation_date='',
		@filter_table_process_id='65BBD792_1CD5_4B85_B69D_898A1091236E'
--*****************Test Code Start*******************/
SET NOCOUNT ON

DECLARE @ssbm_table_name VARCHAR(120),
		@deal_header_table_name VARCHAR(120),
		@deal_detail_table_name VARCHAR(120), @tr_rmm INT, @file_transfer_endpoint_id INT, @xml_string NVARCHAR(MAX),
	    @result NVARCHAR(10), @url NVARCHAR(500), @desc NVARCHAR(1000), @emir_file_name VARCHAR(1000), @user_name VARCHAR(100) = dbo.FNADBUser()

SET @ssbm_table_name = dbo.FNAProcessTableName('ssbm', dbo.FNADBUser(), @filter_table_process_id)
SET @deal_header_table_name = dbo.FNAProcessTableName('deal_header', dbo.FNADBUser(), @filter_table_process_id)
SET @deal_detail_table_name = dbo.FNAProcessTableName('deal_detail', dbo.FNADBUser(), @filter_table_process_id)

IF @batch_process_id IS NOT NULL AND @batch_report_param IS NOT NULL
BEGIN
	DECLARE @str_batch_table VARCHAR(MAX) = '', @temp_table_name VARCHAR(200) = ''

	IF (@batch_process_id IS NULL)
		SET @batch_process_id = REPLACE(NEWID(), '-', '_')
	
	SET @temp_table_name = dbo.FNAProcessTableName('batch_report', dbo.FNADBUser(), @batch_process_id)

	SET @str_batch_table = ' INTO ' + @temp_table_name
END

DECLARE @_sql VARCHAR(MAX),
		@error_spa VARCHAR(1000),
		@temp_path VARCHAR(500),
		@pnl_deals VARCHAR(MAX)

IF @submission_type='44703' AND @level='M' AND @flag IN ('i', 's')
BEGIN	
	SELECT @pnl_deals = ISNULL(@pnl_deals + ',', '') + CAST(source_deal_header_id AS VARCHAR(10)) 
	FROM (
		SELECT DISTINCT source_deal_header_id
		FROM source_deal_pnl pnl
		WHERE CONVERT(VARCHAR(10), pnl.pnl_as_of_date, 120) = @valuation_date
	) a
	
	IF @pnl_deals IS NULL AND @flag <> 's'
	BEGIN
		EXEC spa_ErrorHandler -1, 'Regulatory Submission', 'spa_source_emir', 'Error', 'No valid deals found.', ''
		RETURN
	END
END

IF @flag = 'i' 
BEGIN
	/**** Regulatory Report Generation *****
	@submission_type = 44703 AND @level <> C EMIR Trade, Position AND MTM level
	@submission_type = 44703 AND @level = C EMIR Collateral level
	@submission_type = 44704 AND @level_mifid = X MiFID Transaction level
	@submission_type = 44704 AND @level_mifid = T MiFID Trade level
	*******************************************/
	IF @process_id IS NULL
		SET @process_id = dbo.FNAGetNewID()
		
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
		[commodity_name] VARCHAR(1000) COLLATE DATABASE_DEFAULT,
		[term_frequency] NCHAR(1) COLLATE DATABASE_DEFAULT,
		profile_granularity INT

	)

	SET @_sql = '
		INSERT INTO #temp_deals (
			source_deal_header_id
			, deal_id
			, template_id
			, counterparty_id
			, sub_book_id
			, deal_date
			, physical_financial_flag
			, entire_term_start
			, entire_term_end
			, source_deal_type_id
			, deal_sub_type_type_id
			, option_flag
			, option_type
			, option_excercise_type
			, header_buy_sell_flag
			, create_ts
			, update_ts
			, internal_desk_id
			, product_id
			, commodity_id
			, block_define_id
			, deal_status
			, description1
			, description2
			, source_trader_id
			, contract_id
			, deal_group_id
			, ext_deal_id
			, confirm_status
			, [commodity_name]
			, [term_frequency]
			, profile_granularity
		)
		SELECT source_deal_header_id
			, deal_id
			, template_id
			, counterparty_id
			, sub_book_id
			, deal_date
			, physical_financial_flag
			, entire_term_start
			, entire_term_end
			, source_deal_type_id
			, deal_sub_type_type_id
			, option_flag
			, option_type
			, option_excercise_type
			, header_buy_sell_flag
			, create_ts
			, update_ts
			, internal_desk_id
			, product_id
			, commodity_id
			, block_define_id
			, deal_status
			, description1
			, description2
			, source_trader_id
			, contract_id
			, deal_group_id
			, ext_deal_id
			, confirm_status
			, [commodity_name]
			, [term_frequency]
			, profile_granularity
		FROM ' + @deal_header_table_name + '
		WHERE 1 = 1 
	' + IIF(@pnl_deals IS NOT NULL, ' AND source_deal_header_id IN ('+ @pnl_deals +') ', '')
	+ IIF(NULLIF(@deal_date_from,'') IS NOT NULL, ' AND deal_date >= ''' + @deal_date_from + '''', '')
	+ IIF(NULLIF(@deal_date_to,'') IS NOT NULL, ' AND deal_date <= ''' + @deal_date_to + '''', '')
	
	EXEC(@_sql)

	IF NOT EXISTS (
		SELECT sdv.code FROM #temp_deals sdh
		INNER JOIN static_data_value sdv
			ON sdv.value_id = sdh.deal_status
				AND sdv.[type_id] = 5600
		WHERE sdv.code IN ('New', 'Amended', 'Reviewed', 'Final')
	)
	BEGIN
		EXEC spa_ErrorHandler -1, 'Regulatory Submission', 'spa_source_emir', 'Error', 'No valid deals found.', ''
		RETURN
	END
	
	IF OBJECT_ID('tempdb..#temp_deal_details') IS NOT NULL
		DROP TABLE #temp_deal_details
	
	CREATE TABLE #temp_deal_details (
		[source_deal_header_id] INT NULL,
		[source_deal_detail_id] INT NULL,
		[term_start] DATETIME NOT NULL,
		[term_end] DATETIME NOT NULL,
		[leg] INT NOT NULL,
		[fixed_float_leg] CHAR(1) COLLATE DATABASE_DEFAULT NOT NULL,
		[buy_sell_flag] CHAR(1) COLLATE DATABASE_DEFAULT NOT NULL,
		[curve_id] INT NULL,
		[location_id] INT NULL,
		[physical_financial_flag] CHAR(1) COLLATE DATABASE_DEFAULT NULL,
		[deal_volume] NUMERIC(38, 20) NULL,
		[total_volume] NUMERIC(38, 20) NULL,
		[standard_yearly_volume] NUMERIC(22, 8) NULL,
		[deal_volume_frequency] CHAR(1) COLLATE DATABASE_DEFAULT NOT NULL,
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

	IF OBJECT_ID('tempdb..#temp_cpty_udf_values') IS NOT NULL
		DROP TABLE #temp_cpty_udf_values

	CREATE TABLE #temp_cpty_udf_values (
		sub_book_id INT,
		source_deal_header_id INT, 
		counterparty_id INT, 
		[ACER] VARCHAR(150) COLLATE DATABASE_DEFAULT,
		[BIC] VARCHAR(150) COLLATE DATABASE_DEFAULT,
		[Collateralization] VARCHAR(150) COLLATE DATABASE_DEFAULT,
		[Commercial/Treasury] VARCHAR(150) COLLATE DATABASE_DEFAULT,
		[Corporate Sector] VARCHAR(150) COLLATE DATABASE_DEFAULT,
		[CSA Reportable Trade] VARCHAR(150) COLLATE DATABASE_DEFAULT,
		[EAN Gas] VARCHAR(150) COLLATE DATABASE_DEFAULT,
		[EAN Power] VARCHAR(150) COLLATE DATABASE_DEFAULT,
		[EEA] VARCHAR(150) COLLATE DATABASE_DEFAULT,
		[EIC] VARCHAR(150) COLLATE DATABASE_DEFAULT,
		[Financial/Non-Financial] VARCHAR(150) COLLATE DATABASE_DEFAULT,
		[LEI] VARCHAR(150) COLLATE DATABASE_DEFAULT,
		[PRP Gas] VARCHAR(150) COLLATE DATABASE_DEFAULT,
		[PRP Power] VARCHAR(150) COLLATE DATABASE_DEFAULT,
		[TSO Gas] VARCHAR(150) COLLATE DATABASE_DEFAULT,
		[TSO power] VARCHAR(150) COLLATE DATABASE_DEFAULT,
		[Collateral Portfolio Code] VARCHAR(150) COLLATE DATABASE_DEFAULT,
		[Country] VARCHAR(150) COLLATE DATABASE_DEFAULT
	)

	INSERT INTO #temp_cpty_udf_values(source_deal_header_id, counterparty_id, [ACER], [BIC], [Collateralization], [Commercial/Treasury], [Corporate Sector], [CSA Reportable Trade], [EAN Gas], [EAN Power], [EEA], [EIC], [Financial/Non-Financial], [LEI], [PRP Gas], [PRP Power], [TSO Gas], [TSO power], [Collateral Portfolio Code], [Country])
	SELECT source_deal_header_id, counterparty_id, [ACER], [BIC], [Collateralization], [Commercial/Treasury], [Corporate Sector], [CSA Reportable Trade], [EAN Gas], [EAN Power], [EEA], [EIC], [Financial/Non-Financial], [LEI], [PRP Gas], [PRP Power], [TSO Gas], [TSO power], [Collateral Portfolio Code], [Country]
	FROM (
		SELECT td.source_deal_header_id, td.counterparty_id, udft.Field_label, musddv.static_data_udf_values
		FROM #temp_deals td
		INNER JOIN maintain_udf_static_data_detail_values musddv
			ON musddv.primary_field_object_id = td.counterparty_id
		INNER JOIN application_ui_template_fields autf
			ON autf.application_field_id = musddv.application_field_id
		INNER JOIN user_defined_fields_template udft
			ON udft.udf_template_id = autf.udf_template_id
		) AS a
	PIVOT(MAX(a.static_data_udf_values) FOR a.Field_label IN ([ACER], [BIC], [Collateralization], [Commercial/Treasury], [Corporate Sector], [CSA Reportable Trade], [EAN Gas], [EAN Power], [EEA], [EIC], [Financial/Non-Financial], [LEI], [PRP Gas], [PRP Power], [TSO Gas], [TSO power], [Collateral Portfolio Code], [Country])) AS P
	
	EXEC('
		INSERT INTO #temp_cpty_udf_values (sub_book_id, counterparty_id, [ACER], [BIC], [Collateralization], [Commercial/Treasury], [Corporate Sector], [CSA Reportable Trade], [EAN Gas], [EAN Power], [EEA], [EIC], [Financial/Non-Financial], [LEI], [PRP Gas], [PRP Power], [TSO Gas], [TSO power], [Collateral Portfolio Code], [Country])		
		SELECT sub_book_id, counterparty_id, [ACER], [BIC], [Collateralization], [Commercial/Treasury], [Corporate Sector], [CSA Reportable Trade], [EAN Gas], [EAN Power], [EEA], [EIC], [Financial/Non-Financial], [LEI], [PRP Gas], [PRP Power], [TSO Gas], [TSO power], [Collateral Portfolio Code], [Country]
		FROM (
			SELECT sub_book_id, counterparty_id, udft.Field_label, musddv.static_data_udf_values
			FROM ' + @ssbm_table_name + ' book
			INNER JOIN maintain_udf_static_data_detail_values musddv
				ON musddv.primary_field_object_id = book.counterparty_id
			INNER JOIN application_ui_template_fields autf
				ON autf.application_field_id = musddv.application_field_id
			INNER JOIN user_defined_fields_template udft
				ON udft.udf_template_id = autf.udf_template_id
			) AS a
		PIVOT(MAX(a.static_data_udf_values) FOR a.Field_label IN ([ACER], [BIC], [Collateralization], [Commercial/Treasury], [Corporate Sector], [CSA Reportable Trade], [EAN Gas], [EAN Power], [EEA], [EIC], [Financial/Non-Financial], [LEI], [PRP Gas], [PRP Power], [TSO Gas], [TSO power], [Collateral Portfolio Code], [Country])) AS P
	')	

	IF OBJECT_ID('tempdb..#temp_deal_udf_values') IS NOT NULL
		DROP TABLE #temp_deal_udf_values

	CREATE TABLE #temp_deal_udf_values (
		[source_deal_header_id] INT, 
		[Asset Class] VARCHAR(100) COLLATE DATABASE_DEFAULT,
		[Product Classification Type] VARCHAR(100) COLLATE DATABASE_DEFAULT,
		[Product Classification] VARCHAR(100) COLLATE DATABASE_DEFAULT,
		[Global UTI] VARCHAR(100) COLLATE DATABASE_DEFAULT,
		[Venue of Execution] VARCHAR(100) COLLATE DATABASE_DEFAULT,
		[Execution Timestamp] VARCHAR(100) COLLATE DATABASE_DEFAULT,
		[Clearing Obligation] VARCHAR(100) COLLATE DATABASE_DEFAULT,
		[Cleared] VARCHAR(100) COLLATE DATABASE_DEFAULT,
		[Clearing Timestamp] VARCHAR(100) COLLATE DATABASE_DEFAULT,
		[Intragroup] VARCHAR(100) COLLATE DATABASE_DEFAULT,
		[Trading Venue Transaction ID] VARCHAR(100) COLLATE DATABASE_DEFAULT,
		[Derivative Notional] VARCHAR(100) COLLATE DATABASE_DEFAULT,
		[Country of the Branch Membership] VARCHAR(100) COLLATE DATABASE_DEFAULT,
		[Initial Margin] VARCHAR(100) COLLATE DATABASE_DEFAULT,
		[Complex Trade Component ID] VARCHAR(100) COLLATE DATABASE_DEFAULT,
		[Instrument Full Name] VARCHAR(100) COLLATE DATABASE_DEFAULT,
		[Instrument Classification] VARCHAR(100) COLLATE DATABASE_DEFAULT,
		[Delivery Type] VARCHAR(100) COLLATE DATABASE_DEFAULT,
		[Firm Execution] VARCHAR(100) COLLATE DATABASE_DEFAULT,
		[Short Selling Indicator] VARCHAR(100) COLLATE DATABASE_DEFAULT,
		[OTC Post-Trade Indicator] VARCHAR(100) COLLATE DATABASE_DEFAULT,
		[Commodity Derivative Indicator] VARCHAR(100) COLLATE DATABASE_DEFAULT,
		[Publication Time Stamp] VARCHAR(100) COLLATE DATABASE_DEFAULT,
		[Venue of Publication] VARCHAR(100) COLLATE DATABASE_DEFAULT,
		[Flags] VARCHAR(100) COLLATE DATABASE_DEFAULT,
		[Supplimentary Deferral Flags] VARCHAR(100) COLLATE DATABASE_DEFAULT,
		[Threshold] VARCHAR(100) COLLATE DATABASE_DEFAULT,
		[decision_maker_id] VARCHAR(250) COLLATE DATABASE_DEFAULT,
		[ISIN] VARCHAR(250) COLLATE DATABASE_DEFAULT,
		[Pure OTC] VARCHAR(250) COLLATE DATABASE_DEFAULT
	)

	INSERT INTO #temp_deal_udf_values (source_deal_header_id, [Asset Class], [Product Classification Type], [Product Classification], [Global UTI], [Venue of Execution], [Execution Timestamp], [Clearing Obligation], [Cleared], [Clearing Timestamp], [Intragroup], [Trading Venue Transaction ID], [Derivative Notional], [Country of the Branch Membership], [Initial Margin], [Complex Trade Component ID], [Instrument Full Name], [Instrument Classification], [Delivery Type], [Firm Execution], [Short Selling Indicator], [OTC Post-Trade Indicator], [Commodity Derivative Indicator], [Publication Time Stamp], [Venue of Publication], [Flags], [Supplimentary Deferral Flags], [Threshold],[decision_maker_id], [ISIN], [Pure OTC])
	SELECT source_deal_header_id, [Asset Class], [Product Classification Type], [Product Classification], [Global UTI], [Venue of Execution], [Execution Timestamp], [Clearing Obligation], [Cleared], [Clearing Timestamp], [Intragroup], [Trading Venue Transaction ID], [Derivative Notional], [Country of the Branch Membership], [Initial Margin], [Complex Trade Component ID], [Instrument Full Name], [Instrument Classification], [Delivery Type], [Firm Execution], [Short Selling Indicator], [OTC Post-Trade Indicator], [Commodity Derivative Indicator], [Publication Time Stamp], [Venue of Publication], [Flags], [Supplimentary Deferral Flags], [Threshold], [Decision Maker ID], [ISIN], [Pure OTC]
	FROM (
		SELECT sdh.source_deal_header_id, udft.field_label, uddf.udf_value
		FROM #temp_deals sdh
		INNER JOIN #temp_deal_details sdd
			ON sdh.source_deal_header_id = sdd.source_deal_header_id
		INNER JOIN user_defined_deal_fields uddf
			ON uddf.source_deal_header_id = sdh.source_deal_header_id
				AND NULLIF(uddf.udf_value, '') IS NOT NULL
		INNER JOIN user_defined_deal_fields_template uddft
			ON uddft.udf_template_id = uddf.udf_template_id
		INNER JOIN user_defined_fields_template udft
			ON udft.field_id = uddft.field_id
		) AS a
	PIVOT (MAX(a.udf_value) FOR a.Field_label IN ([Asset Class], [Product Classification Type], [Product Classification], [Global UTI], [Venue of Execution], [Execution Timestamp], [Clearing Obligation], [Cleared], [Clearing Timestamp], [Intragroup], [Trading Venue Transaction ID], [Derivative Notional], [Country of the Branch Membership], [Initial Margin], [Complex Trade Component ID], [Instrument Full Name], [Instrument Classification], [Delivery Type], [Firm Execution], [Short Selling Indicator], [OTC Post-Trade Indicator], [Commodity Derivative Indicator], [Publication Time Stamp], [Venue of Publication], [Flags], [Supplimentary Deferral Flags], [Threshold], [Decision Maker ID], [ISIN], [Pure OTC])) AS p
	
	IF OBJECT_ID('tempdb..#temp_deal_detail_udf_values') IS NOT NULL
		DROP TABLE #temp_deal_detail_udf_values

	CREATE TABLE #temp_deal_detail_udf_values (
		source_deal_header_id INT,
		[Price Notation] VARCHAR(100) COLLATE DATABASE_DEFAULT, 
		[Quantity Notation] VARCHAR(100) COLLATE DATABASE_DEFAULT
	)

	INSERT INTO #temp_deal_detail_udf_values (source_deal_header_id, [Price Notation], [Quantity Notation])
	SELECT source_deal_header_id, [Price Notation], [Quantity Notation]
	FROM (
		SELECT sdh.source_deal_header_id, udft.field_label, udddf.udf_value
		FROM #temp_deals sdh
		INNER JOIN #temp_deal_details sdd
			ON sdh.source_deal_header_id = sdd.source_deal_header_id
		INNER JOIN user_defined_deal_detail_fields udddf
			ON udddf.source_deal_detail_id = sdd.source_deal_detail_id
				AND NULLIF(udddf.udf_value, '') IS NOT NULL
		INNER JOIN user_defined_deal_fields_template uddft
			ON uddft.udf_template_id = udddf.udf_template_id
		INNER JOIN user_defined_fields_template udft
			ON udft.field_id = uddft.field_id
		) a
	PIVOT (MAX(a.udf_value) FOR a.Field_label IN ([Price Notation], [Quantity Notation])) AS P

	IF @submission_type = 44703 AND @level <> 'C' --Logic to insert EMIR Trade, Position AND MTM report
	BEGIN
		IF OBJECT_ID('tempdb..#source_deal_pnl') IS NOT NULL
			DROP TABLE #source_deal_pnl
		
		SELECT sdh.source_deal_header_id,
			   SUM(sdp.und_pnl) und_pnl,
			   MAX(sdp.pnl_as_of_date) update_ts, 
			   MAX(sdp.pnl_as_of_date) create_ts
		INTO #source_deal_pnl
		FROM source_deal_pnl sdp
		INNER JOIN #temp_deals sdh
			ON sdh.source_deal_header_id = sdp.source_deal_header_id
		WHERE CONVERT(VARCHAR(10), sdp.pnl_as_of_date, 120) = CONVERT(VARCHAR(10), @valuation_date, 120)
		GROUP BY sdh.source_deal_header_id
		ORDER BY sdh.source_deal_header_id

		IF OBJECT_ID('tempdb..#emir_log_status') IS NOT NULL
			DROP TABLE #emir_log_status

		SELECT a.trade_id, 
			   a.status, 
			   a.create_ts,
			   RANK() OVER(PARTITION BY a.trade_id ORDER BY a.create_ts DESC) [rank]
		INTO #emir_log_status
		FROM source_emir_audit a
		INNER JOIN #temp_deals sdh
			ON sdh.deal_id = a.trade_id
		ORDER BY a.trade_id

		IF @level <> 'M'
		BEGIN
			--SELECT DISTINCT b.submission_status, c.[status], c.trade_id
			DELETE a
			FROM #temp_deals a
			LEFT JOIN source_emir b
				ON a.source_deal_header_id = b.source_deal_header_id
					AND a.deal_id = b.deal_id
					AND a.sub_book_id = b.sub_book_id
			LEFT JOIN #emir_log_status c
				ON c.trade_id = a.deal_id
			WHERE c.[rank] = 1
				AND (
						a.deal_id IS NULL
						OR (
								b.submission_status = 39501 
								AND c.[status] = 'ACK' 
								AND b.create_ts > ISNULL(a.update_ts, a.create_ts)
							)
					)
				AND b.[level] = @level
		END
			
		IF NOT EXISTS (SELECT 1 FROM #temp_deals)
		BEGIN
			EXEC spa_ErrorHandler -1, 'Regulatory Submission', 'spa_source_emir', 'Error', 'No new deals found.', ''
			RETURN
		END
		
		IF OBJECT_ID('tempdb..#temp_source_emir') IS NOT NULL
			DROP TABLE #temp_source_emir
				
		SELECT DISTINCT 
			source_deal_header_id = sdh.source_deal_header_id,
			deal_id = MAX(sdh.deal_id),
			sub_book_id = MAX(sdh.sub_book_id),
			reporting_timestamp = CONVERT(VARCHAR(10), CONVERT(DATETIME, GETDATE(), 103), 126) + 'T' + CAST(CAST(GETDATE() AS TIME) AS VARCHAR(8)) + 'Z',
			counterparty_id = MAX(sub_cpty.LEI),
			other_counterparty_id = 'LEI',
			counterparty_name = MAX(deal_cpty.LEI),
			counterparty_country = MAX(submission_country.code),
			corporate_sector = MAX(sub_cpty.[Corporate Sector]),
			corporate_sector2 = MAX(deal_cpty.[Corporate Sector]),						
			nature_of_reporting_cpty = MAX(sub_cpty.[Financial/Non-Financial]),
			nature_of_reporting_cpty2 = MAX(deal_cpty.[Financial/Non-Financial]),
			broker_id = NULL,
			reporting_entity_id = MAX(sub_cpty.LEI),
			clearing_member_id = MAX(sub_cpty.LEI),
			beneficiary_type_id = 'LEI',
			beneficiary_id = MAX(deal_cpty.LEI),
			trading_capacity = 'P',
			counterparty_side = UPPER(MAX(sdh.header_buy_sell_flag)),
			commercial_or_treasury = 'N',
			clearing_threshold = 'N',
			contarct_mtm_value = IIF(MAX(sdt.source_deal_type_name) <> 'Option',
									CASE when @level = 'T' then NULL
											WHEN MAX(deal_match_info.fas_link_detail_id) IS NULL THEN MAX(sdpd.und_pnl)
											WHEN MAX(deal_match_info.fas_link_detail_id) IS NOT NULL AND SUM(deal_match_info.[rem_vol]) > 0 AND @level = 'M' 
											THEN (MAX(deal_match_info.[curve_value]) - AVG(sdd.[fixed_price])) * SUM(deal_match_info.rem_vol) * iif(MAX(sdh.header_buy_sell_flag) = 's', -1, 1)
											ELSE MAX(sdpd.und_pnl)
									END
								, 
									CASE when @level = 'T' then NULL
											WHEN MAX(deal_match_info.fas_link_detail_id) IS NULL THEN MAX(sdd.total_volume) * (MAX(s.market_price) - AVG(sdd.fixed_price)) * iif(MAX(sdh.header_buy_sell_flag) = 's', -1, 1)
											WHEN MAX(deal_match_info.fas_link_detail_id) IS NOT NULL AND SUM(deal_match_info.[rem_vol]) > 0 AND @level = 'M' 
											THEN (MAX(s.market_price) - AVG(sdd.fixed_price)) * SUM(deal_match_info.rem_vol) * iif(MAX(sdh.header_buy_sell_flag) = 's', -1, 1)
											ELSE MAX(sdd.total_volume) * (MAX(s.market_price) - AVG(sdd.fixed_price)) * iif(MAX(sdh.header_buy_sell_flag) = 's', -1, 1)
									END
								)
				,

			contarct_mtm_currency = MAX(sc.currency_name),
			valuation_ts = CONVERT(VARCHAR(10), MAX(ISNULL(sdpd.update_ts, sdpd.create_ts)), 120),
			valuation_type = 'M',
			collateralization = MAX(sub_cpty.Collateralization),
			collateral_portfolio = 'Y',
			collateral_portfolio_code = MAX(sub_cpty.[Collateral Portfolio Code]),
			initial_margin_posted = MAX(deal_udf.[Initial Margin]),
			initial_margin_posted_currency = MAX(sc.currency_name),
			variation_margin_posted = MAX(deal_udf.[Threshold]),
			variation_margin_posted_currency = MAX(sc.currency_name),
			initial_margin_received = NULL,
			initial_margin_received_currency = MAX(sc.currency_name),
			variation_margin_received = NULL,
			variation_margins_received_currency = NULL,
			excess_collateral_posted = NULL,
			excess_collateral_posted_currency = NULL,
			excess_collateral_received = NULL,
			excess_collateral_received_currency = NULL,
			contract_type = MAX(gmv_contract_type.clm2_value),
			asset_class = MAX(gmv_asset.clm2_value),
			product_classification_type = 'C',--MAX(deal_udf.[Product Classification Type]),
			product_classification = MAX(gmv1.clm3_value),--MAX(deal_udf.[Product Classification]),
			product_identification_type = IIF(MAX(deal_udf.[Pure OTC]) = 'Y', '', 'I'),
			product_identification = MAX(gmv1.clm1_value),
			underlying = 'I',
			underlying_identification = CASE WHEN MAX(scm.commodity_id) IN ('CER', 'EUA') AND MAX(sdt.source_deal_type_name) IN ('FORWARD','FUTURE')  THEN MAX(gmv_ff.clm4_value) ELSE MAX(gmv1.clm4_value) END,
			notional_currency_1 = CASE WHEN ISNULL(SUM(ABS(sdpd.und_pnl)), CAST((ISNULL(SUM(sdd.total_volume), 0) * ISNULL(AVG(sdd.fixed_price), 0)) AS NUMERIC(38, 20))) IS NOT NULL THEN 'EUR' ELSE NULL END,
			notional_currency_2 = CASE WHEN MAX(scm.commodity_id) = 'FX' THEN MAX(su.uom_id) ELSE NULL END,
			derivable_currency = MAX(sc.currency_name),
			trade_id = COALESCE(MAX(ext_deal_id),MAX(sdh.deal_id)),
			report_tracking_no = NULL,
			complex_trade_component_id = NULL,
			exec_venue = IIF(MAX(deal_udf.[Pure OTC]) = 'Y', 'XXXX', IIF(MAX(sco.counterparty_id) = MAX(gmv.clm7_value), MAX(gmv.clm4_value), 'XOFF')),--MAX(deal_udf.[Venue of Execution]),
			[compression] = 'N',
			price_rate = AVG(sdd.fixed_price),
			price_notation = CASE WHEN AVG(sdd.fixed_price) = 999999999999999.99999 THEN 'X' ELSE 'U' END,
			price_currency = CASE WHEN (CASE WHEN AVG(sdd.fixed_price) = 999999999999999.99999 THEN 'X' ELSE 'U' END) = 'U' THEN MAX(sc.currency_name) ELSE '' END,
			notional_amount = IIF(@level = 'M', SUM(ABS(sdpd.und_pnl)), SUM(ISNULL(sdd.total_volume,0))),
			price_multiplier = SUM(ISNULL(sdd.total_volume,0)) ,
			quantity = MAX(ISNULL(sdd.deal_volume, 0)),
			up_front_payment = MAX(deal_udf.[Initial Margin]),
			delivery_type = CASE WHEN MAX(deal_udf.[Delivery Type]) = 'PHYS' THEN 'P'
									WHEN MAX(deal_udf.[Delivery Type]) = 'CASH' THEN 'C'
									ELSE 'O'
							END,
			execution_timestamp = CONVERT(VARCHAR(10), CONVERT(DATETIME, MAX(sdh.deal_date), 103),126) + 'T' + CAST(CAST(MAX(sdh.deal_date) AS TIME) AS VARCHAR(8)) + 'Z',--MAX(deal_udf.[Execution Timestamp]),
			effective_date = CONVERT(VARCHAR(10), CONVERT(DATETIME, MAX(sdh.deal_date), 103), 126),
			maturity_date = CONVERT(VARCHAR(10), CONVERT(DATETIME, MAX(sdd.contract_expiration_date), 103), 126),
			termination_date = NULL,
			settlement_date = CONVERT(VARCHAR(10),MAX(sdh.entire_term_end), 126),
			aggreement_type = MAX(cg.[contract_name]),
			aggreement_version = NULL,
			confirm_ts = LEFT(STUFF(STUFF(REPLACE(MAX(deal_udf.[Execution Timestamp]), '-', 'T'), 7, 0, '-'), 5, 0, '-'), 19) + 'Z',--MAX(deal_udf.[Execution Timestamp]),--CONVERT(VARCHAR(10), CONVERT(DATETIME, MAX(sdh.deal_date), 103),126) + 'T' + CAST(CAST(MAX(sdh.deal_date) AS TIME) AS VARCHAR(8)) + 'Z',
			confirm_means = MAX(sdh.confirm_status),
			clearing_obligation = 'N',
			cleared = MAX(deal_udf.Cleared),
			clearing_ts = CONVERT(VARCHAR(10), CONVERT(DATETIME,  MAX(sdh.deal_date), 103),126) + 'T' + CAST(CAST( MAX(sdh.deal_date) AS TIME) AS VARCHAR(8)) + 'Z',
			ccp = MAX(deal_cpty.LEI),
			intra_group = 'N',
			fixed_rate_leg_1 = AVG(sdd.fixed_price),
			fixed_rate_leg_2 = AVG(sdd.fixed_price),
			fixed_rate_day_count_leg_1 = NULL,
			fixed_rate_day_count_leg_2 = NULL,
			fixed_rate_payment_feq_time_leg_1 = NULL,
			fixed_rate_payment_feq_mult_leg_1 = NULL,
			fixed_rate_payment_feq_time_leg_2 = NULL,
			fixed_rate_payment_feq_mult_leg_2 = NULL,
			float_rate_payment_feq_time_leg_1 = NULL,
			float_rate_payment_feq_mult_leg_1 = NULL,
			float_rate_payment_feq_time_leg_2 = NULL,
			float_rate_payment_feq_mult_leg_2 = NULL,
			float_rate_reset_freq_leg_1_time = NULL,
			float_rate_reset_freq_leg_1_mult = NULL,
			float_rate_reset_freq_leg_2_time = NULL,
			float_rate_reset_freq_leg_2_mult = NULL,
			float_rate_leg_1 = NULL,
			float_rate_ref_period_leg_1_time = NULL,
			float_rate_ref_period_leg_1_mult = NULL,
			float_rate_leg_2 = NULL,
			float_rate_ref_period_leg_2_time = NULL,
			float_rate_ref_period_leg_2_mult = NULL,
			delivery_currency_2 = NULL,
			exchange_rate_1 = AVG(sdd.fixed_price),
			forward_exchange_rate = AVG(sdd.fixed_price),
			exchange_rate_basis = CASE WHEN MAX(scm.commodity_id) = 'FX' THEN MAX(spcd.curve_id) ELSE NULL END,
			commodity_base = CASE WHEN MAX(scm.commodity_id) = 'FX' THEN 'OT' ELSE 'EV' END,
			commodity_details = CASE WHEN MAX(scm.commodity_id) = 'FX' THEN 'OT' ELSE 'EM' END,
			delivery_point = NULL,
			interconnection_point = NULL,
			load_type = CASE WHEN MAX(ISNULL(sdh.internal_desk_id,17300))=17302 THEN 'SH'
							WHEN MAX(scm.commodity_name) IN ('Gas', 'Natural Gas', 'LNG', 'NG') THEN 'GD' 
							WHEN MAX(sdv_block.code) LIKE '%Base%' THEN 'BL'
							WHEN MAX(sdv_block.code) LIKE '%Peak%' THEN 'PL'
							WHEN MAX(sdv_block.code) LIKE '%Offpeak%' THEN 'OP'
							ELSE 'OT'
						END,
			load_delivery_interval = 'T' + CAST(CAST(GETDATE() AS TIME) AS VARCHAR(8)) + 'Z',
			delivery_start_date = CONVERT(VARCHAR(10), CONVERT(DATETIME, MAX(sdh.entire_term_start), 103),126) + 'T' + CAST(CAST(MAX(sdh.entire_term_start) AS TIME) AS VARCHAR(8)) + 'Z',
			delivery_end_date = CONVERT(VARCHAR(10), CONVERT(DATETIME, MAX(sdh.entire_term_end), 103),126) + 'T' + CAST(CAST(MAX(sdh.entire_term_start) AS TIME) AS VARCHAR(8)) + 'Z',
			duration = NULL,
			days_of_the_week = NULL,
			delivery_capacity = SUM(sdd.deal_volume),
			quantity_unit = MAX(su.uom_name),
			price_time_interval_quantity = AVG(sdd.fixed_price),
			option_type = CASE WHEN MAX(sdt.source_deal_type_name) = 'Option' THEN UPPER(MAX(sdh.option_type)) ELSE '' END,
			option_style = CASE WHEN MAX(sdt.source_deal_type_name) = 'Option' THEN UPPER(MAX(sdh.option_excercise_type)) ELSE '' END,
			strike_price = CASE WHEN MAX(sdt.source_deal_type_name) = 'Option' THEN AVG(sdd.option_strike_price) ELSE NULL END,
			strike_price_notation = CASE WHEN MAX(sdt.source_deal_type_name) = 'Option' THEN 'U' ELSE '' END,
			underlying_maturity_date = CASE WHEN MAX(sdt.source_deal_type_name) = 'Option' THEN CONVERT(VARCHAR(10), CONVERT(DATETIME, MAX(sdd.term_end), 103),126) ELSE '' END,
			seniority = NULL,
			reference_entity = NULL,
			frequency_of_payment = NULL,
			calculation_basis = NULL,
			series = NULL,
			[version] = NULL,
			index_factor = NULL,
			tranche = NULL,
			attachment_point = NULL,
			detachment_point = NULL,
			action_type = CASE WHEN MAX(deal_status.code) IN ('New', 'Amended', 'Final') THEN 'N' 
								WHEN MAX(deal_status.code) = 'Reviewed' THEN 'C' 
							END ,
			[level] = @level,
			report_type = NULL,
			create_date_from = @create_date_from,
			create_date_to = @create_date_to,
			submission_status = 39500,
			submission_date = GETDATE(),
			confirmation_date = GETDATE(),
			process_id = @process_id,
			document_id = IIF(MAX(emr.document_id) IS NULL, ROW_NUMBER() OVER(PARTITION BY sdh.source_deal_header_id ORDER BY sdh.source_deal_header_id), MAX(emr.document_id) + 1 ),
			commodity_id = MAX(scm.commodity_id)
		INTO #temp_source_emir
		--SELECT  * 
		FROM #temp_deals sdh
		INNER JOIN #temp_deal_details sdd ON sdh.source_deal_header_id = sdd.source_deal_header_id
		LEFT JOIN source_price_curve_def spcd ON spcd.source_curve_def_id = sdd.curve_id
		LEFT JOIN source_deal_type sdt ON sdh.source_deal_type_id = sdt.source_deal_type_id
		LEFT JOIN #source_deal_pnl sdpd ON sdpd.source_deal_header_id = sdh.source_deal_header_id
		LEFT JOIN #temp_cpty_udf_values deal_cpty ON deal_cpty.source_deal_header_id = sdh.source_deal_header_id
		LEFT JOIN #temp_cpty_udf_values sub_cpty ON sub_cpty.sub_book_id = sdh.sub_book_id
		LEFT JOIN #temp_deal_udf_values deal_udf ON deal_udf.source_deal_header_id = sdh.source_deal_header_id
		LEFT JOIN source_currency sc ON sc.source_currency_id = sdd.fixed_price_currency_id
		LEFT JOIN contract_group cg ON cg.contract_id = sdh.contract_id
		LEFT JOIN static_data_value sdv_block ON sdv_block.value_id = sdh.block_define_id
		LEFT JOIN source_uom su ON su.source_uom_id = sdd.deal_volume_uom_id
		LEFT JOIN static_data_value sdv_deal_status ON sdv_deal_status.value_id = sdh.deal_status
		LEFT JOIN source_counterparty sco ON sco.source_counterparty_id = sdh.counterparty_id
		LEFT JOIN source_commodity scm ON scm.source_commodity_id = sdh.commodity_id
		LEFT JOIN static_data_value sdv_country ON sdv_country.value_id = sco.country
		LEFT JOIN static_data_value deal_status ON sdh.deal_status = deal_status.value_id
		LEFT JOIN static_data_value submission_country ON submission_country.value_id = sub_cpty.[Country]
		LEFT JOIN (
			SELECT gmva.mapping_table_id,
				   gmva.clm1_value,
				   gmva.clm2_value,
				   gmva.clm3_value,
				   gmva.clm4_value,
				   gmva.clm5_value,
				   gmva.clm6_value,
				   gmva.clm7_value,
				   gmva.clm8_value,
				   gmva.clm9_value,
				   gmva.clm10_value,
				   gmva.clm11_value,
				   gmva.clm12_value,
				   gmva.clm13_value,
				   gmva.clm14_value
			FROM generic_mapping_values gmva
			INNER JOIN generic_mapping_header gmh
				ON gmh.mapping_table_id = gmva.mapping_table_id
			WHERE gmh.mapping_name = 'Venue of Execution'
		) gmv ON clm7_value = sco.counterparty_id
		LEFT JOIN (
			SELECT gmvcc.clm1_value, gmvcc.clm2_value
			FROM generic_mapping_values gmvcc
			INNER JOIN generic_mapping_header gmh1
				ON gmh1.mapping_table_id = gmvcc.mapping_table_id
			WHERE gmh1.mapping_name = 'Emir Asset Class and Subclass'
		) gmv_asset ON gmv_asset.clm1_value = CAST(sdh.commodity_id AS VARCHAR(10))
		LEFT JOIN (
			SELECT gmvcc.clm1_value, gmvcc.clm2_value
			FROM generic_mapping_values gmvcc
			INNER JOIN generic_mapping_header gmh1
				ON gmh1.mapping_table_id = gmvcc.mapping_table_id
			WHERE gmh1.mapping_name = 'Emir Contract Type'
		) gmv_contract_type ON gmv_contract_type.clm1_value = CAST(sdh.source_deal_type_id AS VARCHAR(10))		  
		LEFT JOIN (
			SELECT gmvx.mapping_table_id, gmvx.clm1_value, gmvx.clm2_value, gmvx.clm3_value, gmvx.clm4_value,
				   gmvx.clm5_value, gmvx.clm6_value, gmvx.clm7_value, gmvx.clm8_value, gmvx.clm9_value
			FROM generic_mapping_values gmvx
			INNER JOIN generic_mapping_header gmh1
				ON gmh1.mapping_table_id = gmvx.mapping_table_id
			WHERE gmh1.mapping_name = 'Instrument Detail'
		) gmv1 ON gmv1.clm6_value = CAST(sdd.curve_id AS VARCHAR(10))
			AND MONTH(gmv1.clm5_value) = MONTH(sdd.contract_expiration_date)
			AND YEAR(gmv1.clm5_value) = YEAR(sdd.contract_expiration_date)
			AND CASE WHEN sdh.counterparty_id IN (SELECT source_counterparty_id FROM source_counterparty WHERE counterparty_id IN ('ICE', 'CME', 'EEX')) THEN sdh.counterparty_id ELSE (SELECT source_counterparty_id FROM source_counterparty WHERE counterparty_id IN ('ICE')) END = gmv1.clm7_value	
			AND ISNULL(NULLIF(sdh.option_type, ' '), '$') = ISNULL(gmv1.clm8_value, '$')
			AND ISNULL(gmv1.clm9_value, -1) = ISNULL(sdd.option_strike_price, -1)
		OUTER APPLY (
			SELECT gmvx.clm4_value
			FROM generic_mapping_values gmvx
			INNER JOIN generic_mapping_header gmh1
				ON gmh1.mapping_table_id = gmvx.mapping_table_id
			INNER JOIN source_price_curve_def spcd1 ON spcd1.source_curve_def_id = CAST(gmvx.clm6_value AS INT)
			WHERE gmh1.mapping_name = 'Instrument Detail' 
				AND gmvx.clm2_value = 'SPOT' 
				AND DAY(gmvx.clm5_value) = DAY(sdh.deal_date)
				AND MONTH(gmvx.clm5_value) = MONTH(sdh.deal_date)
				AND YEAR(gmvx.clm5_value) = YEAR(sdh.deal_date)
				AND spcd1.commodity_id = spcd.commodity_id
				AND spcd1.curve_id like '% spot'
				AND CASE WHEN sdh.counterparty_id IN (SELECT source_counterparty_id FROM source_counterparty WHERE counterparty_id IN ('ICE', 'CME', 'EEX')) THEN sdh.counterparty_id ELSE (SELECT source_counterparty_id FROM source_counterparty WHERE counterparty_id IN ('ICE')) END = gmvx.clm7_value	
			
		) gmv_ff
		OUTER APPLY (
			SELECT MAX(dmd.fas_link_detail_id) [fas_link_detail_id],
				   CAST(ROUND((sdd.total_volume - SUM(dmd.matched_volume)), 2) AS NUMERIC(20,2)) [rem_vol],
				   MAX(COALESCE(spc1.curve_value, spc2.curve_value, spc3.curve_value, spc4.curve_value)) [curve_value]
			FROM matching_detail dmd
			LEFT JOIN source_price_curve spc1 ON spc1.as_of_date = @valuation_date 
				AND spc1.source_curve_def_id = spcd.source_curve_def_id
				AND spc1.maturity_date = sdd.term_start
			LEFT JOIN source_price_curve spc2 ON spc2.as_of_date = @valuation_date
				AND spc2.source_curve_def_id = spcd.proxy_source_curve_def_id
				AND spc2.maturity_date = sdd.term_start
			LEFT JOIN source_price_curve spc3 ON spc3.as_of_date = @valuation_date
				AND spc3.source_curve_def_id = spcd.monthly_index
				AND spc3.maturity_date = sdd.term_start
			LEFT JOIN source_price_curve spc4 ON spc4.as_of_date = @valuation_date
				AND spc4.source_curve_def_id = spcd.proxy_curve_id3
				AND spc4.maturity_date = sdd.term_start
			WHERE dmd.source_deal_header_id = sdd.source_deal_header_id
				AND @level = 'M'				
		) deal_match_info
		LEFT JOIN (
			SELECT gmvm.mapping_table_id, gmvm.clm1_value as_of_date, gmvm.clm2_value [index], gmvm.clm3_value strike_price,
				   gmvm.clm4_value call_put, gmvm.clm5_value expiration_date, gmvm.clm6_value market_price
			FROM generic_mapping_values gmvm
			INNER JOIN generic_mapping_header gmhm ON gmhm.mapping_table_id = gmvm.mapping_table_id
			WHERE gmhm.mapping_name = 'EMIR Option MTM'
		) s ON sdd.curve_id = s.[index]
			AND CONVERT(VARCHAR(10), sdd.contract_expiration_date, 120) = CONVERT(VARCHAR(10), s.expiration_date, 120)
			AND sdh.option_type = s.call_put
		OUTER APPLY(
			SELECT TOP 1 emir.document_id
			FROM source_emir emir
			WHERE emir.source_deal_header_id = sdh.source_deal_header_id
			ORDER BY emir.document_id DESC
		) emr
		WHERE 1 = 1
		-- AND sub_cpty.LEI IS NOT NULL
			AND ((sco.counterparty_id IN ('ICE', 'CME', 'EEX') AND sdt.source_deal_type_name <> 'Spot') OR (sco.counterparty_id NOT IN ('ICE', 'CME', 'EEX')))
			AND deal_status.code IN ('New', 'Amended', 'Reviewed', 'Final')
			AND CASE WHEN NULLIF(@action_type, '') IS NULL THEN '1' 
					 ELSE CASE WHEN deal_status.code IN ('New', 'Amended', 'Final') THEN 'N' 
							   WHEN deal_status.code = 'Reviewed' THEN 'C' 
						  END 
				END = CASE WHEN NULLIF(@action_type, '') IS NULL THEN '1' 
						   ELSE @action_type 
					  END
			AND NOT(deal_match_info.fas_link_detail_id IS NOT NULL AND deal_match_info.rem_vol = 0 AND @level = 'M')
		GROUP BY sdh.source_deal_header_id
			
		IF NOT EXISTS(SELECT 1 FROM #temp_source_emir)
		BEGIN
			EXEC spa_ErrorHandler -1, 'Regulatory Submission', 'spa_source_emir', 'Error', 'No matching deals found.', ''
			RETURN
		END
	
		BEGIN TRY
			BEGIN TRAN
			INSERT INTO source_emir(
				source_deal_header_id, deal_id, sub_book_id, reporting_timestamp, counterparty_id, other_counterparty_id, counterparty_name, counterparty_country, 
				corporate_sector, corporate_sector2, nature_of_reporting_cpty, nature_of_reporting_cpty2, broker_id, reporting_entity_id, clearing_member_id, beneficiary_type_id, beneficiary_id, trading_capacity, counterparty_side,
				commercial_or_treasury, clearing_threshold, contarct_mtm_value, contarct_mtm_currency, valuation_ts, valuation_type, collateralization, collateral_portfolio, 
				collateral_portfolio_code, initial_margin_posted, initial_margin_posted_currency, variation_margin_posted, variation_margin_posted_currency, initial_margin_received, 
				initial_margin_received_currency, variation_margin_received, variation_margins_received_currency, excess_collateral_posted, excess_collateral_posted_currency, 
				excess_collateral_received, excess_collateral_received_currency, contract_type, asset_class, product_classification_type, product_classification, product_identification_type, 
				product_identification, underlying, underlying_identification, notional_currency_1, notional_currency_2, derivable_currency, trade_id, report_tracking_no, complex_trade_component_id, 
				exec_venue, compression, price_rate, price_notation, price_currency, notional_amount, price_multiplier, quantity, up_front_payment, delivery_type, execution_timestamp, effective_date, 
				maturity_date, termination_date, settlement_date, aggreement_type, aggreement_version, confirm_ts, confirm_means, clearing_obligation, cleared, clearing_ts, ccp, intra_group, 
				fixed_rate_leg_1, fixed_rate_leg_2, fixed_rate_day_count_leg_1, fixed_rate_day_count_leg_2, fixed_rate_payment_feq_time_leg_1, fixed_rate_payment_feq_mult_leg_1, 
				fixed_rate_payment_feq_time_leg_2, fixed_rate_payment_feq_mult_leg_2, float_rate_payment_feq_time_leg_1, float_rate_payment_feq_mult_leg_1, float_rate_payment_feq_time_leg_2, 
				float_rate_payment_feq_mult_leg_2, float_rate_reset_freq_leg_1_time, float_rate_reset_freq_leg_1_mult, float_rate_reset_freq_leg_2_time, float_rate_reset_freq_leg_2_mult, 
				float_rate_leg_1, float_rate_ref_period_leg_1_time, float_rate_ref_period_leg_1_mult, float_rate_leg_2, float_rate_ref_period_leg_2_time, float_rate_ref_period_leg_2_mult, 
				delivery_currency_2, exchange_rate_1, forward_exchange_rate, exchange_rate_basis, commodity_base, commodity_details, delivery_point, interconnection_point, load_type, 
				load_delivery_interval, delivery_start_date, delivery_end_date, duration, days_of_the_week, delivery_capacity, quantity_unit, price_time_interval_quantity, option_type, option_style, 
				strike_price, strike_price_notation, underlying_maturity_date, seniority, reference_entity, frequency_of_payment, calculation_basis, series, version, index_factor, tranche, 
				attachment_point, detachment_point, action_type, level, report_type, create_date_from, create_date_to, submission_status, submission_date, confirmation_date, process_id, document_id, commodity_id
			)
			SELECT * FROM #temp_source_emir
			
			/*******************************************Error Validation Start*******************************************/
			BEGIN --validations
			IF OBJECT_ID('tempdb..#temp_messages') IS NOT NULL
				DROP TABLE #temp_messages

			CREATE TABLE #temp_messages (
				[source_deal_header_id]	 INT,
				[column] VARCHAR(100) COLLATE DATABASE_DEFAULT,
				[messages] VARCHAR(5000) COLLATE DATABASE_DEFAULT
			)

			INSERT INTO #temp_messages ([source_deal_header_id], [column], [messages])
			SELECT DISTINCT source_deal_header_id, 'counterparty_id','counterparty_id cannot be blank'
			FROM source_emir 
			WHERE NULLIF(counterparty_id, '') IS NULL 
				AND process_id = @process_id

			INSERT INTO #temp_messages ([source_deal_header_id], [column], [messages])
			SELECT DISTINCT source_deal_header_id, 'other_counterparty_id','other_counterparty_id cannot be blank'
			FROM source_emir 
			WHERE NULLIF(other_counterparty_id, '') IS NULL 
				AND process_id = @process_id

			INSERT INTO #temp_messages ([source_deal_header_id], [column], [messages])
			SELECT DISTINCT source_deal_header_id, 'counterparty_name','counterparty_name cannot be blank'
			FROM source_emir 
			WHERE NULLIF(counterparty_name, '') IS NULL 
				AND process_id = @process_id

			INSERT INTO #temp_messages ([source_deal_header_id], [column], [messages])
			SELECT DISTINCT source_deal_header_id, 'counterparty_country','counterparty_country cannot be blank'
			FROM source_emir 
			WHERE NULLIF(counterparty_country, '') IS NULL 
				AND process_id = @process_id

			INSERT INTO #temp_messages ([source_deal_header_id], [column], [messages])
			SELECT DISTINCT source_deal_header_id, 'counterparty_country','counterparty_country Country format doesnot match.'
			FROM source_emir 
			WHERE counterparty_country NOT IN ('AD', 'AE', 'AF', 'AG', 'AI', 'AL', 'AM', 'AO', 'AQ', 'AR', 'AS', 'AT', 'AU', 'AW', 'AX', 'AZ', 'BA', 'BB', 'BD', 'BE', 
				'BF', 'BG', 'BH', 'BI', 'BJ', 'BL', 'BM', 'BN', 'BO', 'BQ', 'BR', 'BS', 'BT', 'BV', 'BW', 'BY', 'BZ', 'CA', 'CC', 'CD', 'CF', 'CG', 'CH', 'CI', 'CK', 'CL', 'CM', 'CN', 
				'CO', 'CR', 'CU', 'CV', 'CW', 'CX', 'CY', 'CZ', 'DE', 'DJ', 'DK', 'DM', 'DO', 'DZ', 'EC', 'EE', 'EG', 'EH', 'ER', 'ES', 'ET', 'FI', 'FJ', 'FK', 'FM', 'FO', 'FR', 'GA', 
				'GB', 'GD', 'GE', 'GF', 'GG', 'GH', 'GI', 'GL', 'GM', 'GN', 'GP', 'GQ', 'GR', 'GS', 'GT', 'GU', 'GW', 'GY', 'HK', 'HM', 'HN', 'HR', 'HT', 'HU', 'ID', 'IE', 'IL', 'IM',
				'IN', 'IO', 'IQ', 'IR', 'IS', 'IT', 'JE', 'JM', 'JO', 'JP', 'KE', 'KG', 'KH', 'KI', 'KM', 'KN', 'KP', 'KR', 'KW', 'KY', 'KZ', 'LA', 'LB', 'LC', 'LI', 'LK', 'LR', 'LS',
				'LT', 'LU', 'LV', 'LY', 'MA', 'MC', 'MD', 'ME', 'MF', 'MG', 'MH', 'MK', 'ML', 'MM', 'MN', 'MO', 'MP', 'MQ', 'MR', 'MS', 'MT', 'MU', 'MV', 'MW', 'MX', 'MY', 'MZ', 'NA',
				'NC', 'NE', 'NF', 'NG', 'NI', 'NL', 'NO', 'NP', 'NR', 'NU', 'NZ', 'OM', 'PA', 'PE', 'PF', 'PG', 'PH', 'PK', 'PL', 'PM', 'PN', 'PR', 'PS', 'PT', 'PW', 'PY', 'QA', 'RE',
				'RO', 'RS', 'RU', 'RW', 'SA', 'SB', 'SC', 'SD', 'SE', 'SG', 'SH', 'SI', 'SJ', 'SK', 'SL', 'SM', 'SN', 'SO', 'SR', 'SS', 'ST', 'SV', 'SX', 'SY', 'SZ', 'TC', 'TD', 'TF',
				'TG', 'TH', 'TJ', 'TK', 'TL', 'TM', 'TN', 'TO', 'TR', 'TT', 'TV', 'TW', 'TZ', 'UA', 'UG', 'UM', 'US', 'UY', 'UZ', 'VA', 'VC', 'VE', 'VG', 'VI', 'VN', 'VU', 'WF', 'WS',
				'YE', 'YT', 'ZA', 'ZM', 'ZW') 
				AND process_id = @process_id

			INSERT INTO #temp_messages ([source_deal_header_id], [column], [messages])
			SELECT DISTINCT source_deal_header_id, 'nature_of_reporting_cpty','nature_of_reporting_cpty cannot be blank'
			FROM source_emir 
			WHERE NULLIF(nature_of_reporting_cpty, '') IS NULL 
				AND process_id = @process_id

			INSERT INTO #temp_messages ([source_deal_header_id], [column], [messages])
			SELECT DISTINCT source_deal_header_id, 'beneficiary_type_id','beneficiary_type_id cannot be blank'
			FROM source_emir 
			WHERE NULLIF(beneficiary_type_id, '') IS NULL 
				AND process_id = @process_id
			
			INSERT INTO #temp_messages ([source_deal_header_id], [column], [messages])
			SELECT DISTINCT source_deal_header_id, 'trading_capacity','trading_capacity cannot be blank'
			FROM source_emir 
			WHERE NULLIF(trading_capacity, '') IS NULL 
				AND process_id = @process_id

			INSERT INTO #temp_messages ([source_deal_header_id], [column], [messages])
			SELECT DISTINCT source_deal_header_id, 'beneficiary_id','beneficiary_id cannot be blank'
			FROM source_emir 
			WHERE NULLIF(beneficiary_id, '') IS NULL 
				AND process_id = @process_id
			
			INSERT INTO #temp_messages ([source_deal_header_id], [column], [messages])
			SELECT DISTINCT source_deal_header_id, 'collateral_portfolio_code','collateral_portfolio_code should be ''Y'''
			FROM source_emir 
			WHERE NULLIF(collateral_portfolio_code, '') IS NOT NULL 
				AND collateral_portfolio = 'Yes'
				AND process_id = @process_id
			
			INSERT INTO #temp_messages ([source_deal_header_id], [column], [messages])
			SELECT DISTINCT source_deal_header_id, 'nature_of_reporting_cpty', 'nature_of_reporting_counterparty cannot be blank'
			FROM source_emir 
			WHERE nature_of_reporting_cpty IS NULL
				AND process_id = @process_id

			INSERT INTO #temp_messages ([source_deal_header_id], [column], [messages])
			SELECT DISTINCT source_deal_header_id, 'nature_of_reporting_cpty', 'nature_of_reporting_counterparty does not match the format'
			FROM source_emir 
			WHERE NULLIF(nature_of_reporting_cpty, '') IS NOT NULL 
				AND nature_of_reporting_cpty NOT IN ('F', 'N', 'C', 'O')
				AND process_id = @process_id
			
			INSERT INTO #temp_messages ([source_deal_header_id], [column], [messages])
			SELECT DISTINCT source_deal_header_id, 'corporate_sector', 'corporate_sector cannot be blank'
			FROM source_emir 
			WHERE NULLIF(corporate_sector, '') IS NULL 
				AND nature_of_reporting_cpty IN ('C', 'O')
				AND process_id = @process_id

			INSERT INTO #temp_messages ([source_deal_header_id], [column], [messages])
			SELECT DISTINCT source_deal_header_id, 'counterparty_side', 'counterparty_side does not match the format'
			FROM source_emir 
			WHERE counterparty_side NOT IN ('B', 'S') 
				AND process_id = @process_id

			DECLARE @commercial_or_treasury_non VARCHAR(10) = '''Y'',''N'''
			
			INSERT INTO #temp_messages ([source_deal_header_id], [column], [messages])
			SELECT DISTINCT source_deal_header_id, 'commercial_or_treasury', 'commercial_or_treasury cannot be blank when nature of counterparty populated with N AND level with T'
			FROM source_emir
			WHERE nature_of_reporting_cpty = 'N' 
				AND level = 'T'
				AND commercial_or_treasury IS NULL
				AND process_id = @process_id
			
			INSERT INTO #temp_messages ([source_deal_header_id], [column], [messages])
			SELECT DISTINCT source_deal_header_id, 'clearing_threshold', 'clearing_threshold cannot be blank'
			FROM source_emir
			WHERE clearing_threshold IS NULL
				AND process_id = @process_id

			INSERT INTO #temp_messages ([source_deal_header_id], [column], [messages])
			SELECT DISTINCT source_deal_header_id, 'clearing_threshold', 'clearing_threshold does not match the format'
			FROM source_emir
			WHERE clearing_threshold IN (CASE WHEN nature_of_reporting_cpty = 'N' THEN @commercial_or_treasury_non ELSE '' END)
				AND clearing_threshold IS NOT NULL
				AND process_id = @process_id

			INSERT INTO #temp_messages ([source_deal_header_id], [column], [messages])
			SELECT DISTINCT source_deal_header_id, 'contarct_mtm_value, collateralization', 'contarct_mtm_value, collateralization both cannot be blank'
			FROM source_emir
			WHERE contarct_mtm_value IS NULL 
				AND collateralization IS NULL 
				AND process_id = @process_id

			INSERT INTO #temp_messages ([source_deal_header_id], [column], [messages])
			SELECT DISTINCT source_deal_header_id, 'contarct_mtm_currency', 'contarct_mtm_currency does not match the format'
			FROM source_emir
			WHERE contarct_mtm_value IS NOT NULL 
				AND contarct_mtm_currency NOT IN ('BGN', 'CHF', 'CZK','DKK', 'EUR', 'EUX','GBX', 'GBP', 'HRK','HUF', 'ISK', 'NOK','PCT', 'PLN', 'RON','SEK', 'USD', 'OTH')
				AND process_id = @process_id

			INSERT INTO #temp_messages ([source_deal_header_id], [column], [messages])
			SELECT DISTINCT source_deal_header_id, 'valuation_ts', 'valuation_ts cannot be blank'
			FROM source_emir
			WHERE contarct_mtm_value IS NOT NULL 
				AND NULLIF(valuation_ts, '') IS NULL
				AND process_id = @process_id

			INSERT INTO #temp_messages ([source_deal_header_id], [column], [messages])
			SELECT DISTINCT source_deal_header_id, 'valuation_ts', 'Both collateralization AND contarct_mtm_value cannot be blank'
			FROM source_emir
			WHERE NULLIF(collateralization, '') IS NULL 
				AND contarct_mtm_value IS NULL
				AND process_id = @process_id
				
			INSERT INTO #temp_messages ([source_deal_header_id], [column], [messages])
			SELECT DISTINCT source_deal_header_id, 'collateral_portfolio', 'collateral_portfolio cannot be blank'
			FROM source_emir
			WHERE collateral_portfolio NOT IN ('Y', 'N') 
				AND action_type IN ('N', 'P') 
				AND process_id = @process_id

			/*INSERT INTO #temp_messages ([source_deal_header_id], [column], [messages])
			SELECT DISTINCT source_deal_header_id, 'collateral_portfolio_code', 'collateral_portfolio_code cannot be blank'
			FROM source_emir
			WHERE collateral_portfolio = 'Y'
				AND NULLIF(collateral_portfolio_code, '') IS NULL
				AND process_id = @process_id
			*/

			INSERT INTO #temp_messages ([source_deal_header_id], [column], [messages])
			SELECT DISTINCT source_deal_header_id, 'initial_margin_posted', 'initial_margin_posted should be positive value'
			FROM source_emir
			WHERE initial_margin_posted < 0
				AND @level <> 'M'
				AND process_id = @process_id

			INSERT INTO #temp_messages ([source_deal_header_id], [column], [messages])
			SELECT DISTINCT source_deal_header_id, 'initial_margin_posted_currency', 'initial_margin_posted_currency does not match the format'
			FROM source_emir
			WHERE initial_margin_posted IS NOT NULL 
				AND initial_margin_posted_currency NOT IN ('BGN', 'CHF', 'CZK','DKK', 'EUR', 'EUX','GBX', 'GBP', 'HRK','HUF', 'ISK', 'NOK','PCT', 'PLN', 'RON','SEK', 'USD', 'OTH')
				AND @level <> 'M'
				AND process_id = @process_id

			INSERT INTO #temp_messages ([source_deal_header_id], [column], [messages])
			SELECT DISTINCT source_deal_header_id, 'variation_margin_posted', 'variation_margin_posted should be positive value'
			FROM source_emir
			WHERE variation_margin_posted < 0
				AND @level <> 'M'
				AND process_id = @process_id
				
			INSERT INTO #temp_messages ([source_deal_header_id], [column], [messages])
			SELECT DISTINCT source_deal_header_id, 'variation_margin_posted_currency', 'variation_margin_posted_currency does not match the format'
			FROM source_emir
			WHERE variation_margin_posted IS NOT NULL 
				AND variation_margin_posted_currency NOT IN ('BGN', 'CHF', 'CZK','DKK', 'EUR', 'EUX','GBX', 'GBP', 'HRK','HUF', 'ISK', 'NOK','PCT', 'PLN', 'RON','SEK', 'USD', 'OTH')
				AND @level <> 'M'
				AND process_id = @process_id

			INSERT INTO #temp_messages ([source_deal_header_id], [column], [messages])
			SELECT DISTINCT source_deal_header_id, 'initial_margin_received', 'initial_margin_received should be positive value'
			FROM source_emir
			WHERE initial_margin_received < 0
				AND @level <> 'M'
				AND process_id = @process_id

			INSERT INTO #temp_messages ([source_deal_header_id], [column], [messages])
			SELECT DISTINCT source_deal_header_id, 'initial_margin_received_currency', 'initial_margin_received_currency does not match the format'
			FROM source_emir
			WHERE initial_margin_received IS NOT NULL 
				AND initial_margin_received_currency NOT IN ('BGN', 'CHF', 'CZK','DKK', 'EUR', 'EUX','GBX', 'GBP', 'HRK','HUF', 'ISK', 'NOK','PCT', 'PLN', 'RON','SEK', 'USD', 'OTH')
				AND @level <> 'M'
				AND process_id = @process_id

			INSERT INTO #temp_messages ([source_deal_header_id], [column], [messages])
			SELECT DISTINCT source_deal_header_id, 'variation_margin_received', 'variation_margin_received should be positive value'
			FROM source_emir
			WHERE variation_margin_received < 0
				AND @level <> 'M'

			INSERT INTO #temp_messages ([source_deal_header_id], [column], [messages])
			SELECT DISTINCT source_deal_header_id, 'variation_margins_received_currency', 'variation_margins_received_currency does not match the format'
			FROM source_emir
			WHERE variation_margin_received IS NOT NULL 
				AND variation_margins_received_currency NOT IN ('BGN', 'CHF', 'CZK','DKK', 'EUR', 'EUX','GBX', 'GBP', 'HRK','HUF', 'ISK', 'NOK','PCT', 'PLN', 'RON','SEK', 'USD', 'OTH')
				AND process_id = @process_id
				AND @level <> 'M'

			INSERT INTO #temp_messages ([source_deal_header_id], [column], [messages])
			SELECT DISTINCT source_deal_header_id, 'excess_collateral_posted', 'excess_collateral_posted should be positive value'
			FROM source_emir
			WHERE excess_collateral_posted < 0
				AND @level <> 'M'

			INSERT INTO #temp_messages ([source_deal_header_id], [column], [messages])
			SELECT DISTINCT source_deal_header_id, 'excess_collateral_posted_currency', 'excess_collateral_posted_currency does not match the format'
			FROM source_emir
			WHERE excess_collateral_posted IS NOT NULL 
				AND excess_collateral_posted_currency NOT IN ('BGN', 'CHF', 'CZK','DKK', 'EUR', 'EUX','GBX', 'GBP', 'HRK','HUF', 'ISK', 'NOK','PCT', 'PLN', 'RON','SEK', 'USD', 'OTH')
				AND process_id = @process_id
				AND @level <> 'M'

			INSERT INTO #temp_messages ([source_deal_header_id], [column], [messages])
			SELECT DISTINCT source_deal_header_id, 'excess_collateral_received', 'excess_collateral_received should be positive value'
			FROM source_emir
			WHERE excess_collateral_posted < 0
				AND @level <> 'M'

			INSERT INTO #temp_messages ([source_deal_header_id], [column], [messages])
			SELECT DISTINCT source_deal_header_id, 'excess_collateral_received_currency', 'excess_collateral_received_currency does not match the format'
			FROM source_emir
			WHERE excess_collateral_received IS NOT NULL 
				AND excess_collateral_received_currency NOT IN ('BGN', 'CHF', 'CZK','DKK', 'EUR', 'EUX','GBX', 'GBP', 'HRK','HUF', 'ISK', 'NOK','PCT', 'PLN', 'RON','SEK', 'USD', 'OTH')
				AND process_id = @process_id
				AND @level <> 'M'

			INSERT INTO #temp_messages ([source_deal_header_id], [column], [messages])
			SELECT DISTINCT source_deal_header_id, 'contract_type', 'contract_type cannot be blank'
			FROM source_emir
			WHERE NULLIF(contract_type, '') IS NULL
				AND process_id = @process_id

			INSERT INTO #temp_messages ([source_deal_header_id], [column], [messages])
			SELECT DISTINCT source_deal_header_id, 'contract_type', 'contract_type does not match the format'
			FROM source_emir
			WHERE contract_type NOT IN ('CD', 'FR', 'FU', 'FW', 'OP', 'SB', 'SW', 'ST', 'OT') 
				AND NULLIF(contract_type, '') IS NOT NULL
				AND process_id = @process_id

			INSERT INTO #temp_messages ([source_deal_header_id], [column], [messages])
			SELECT DISTINCT source_deal_header_id, 'asset_class', 'asset_class cannot be blank'
			FROM source_emir
			WHERE NULLIF(asset_class, '') IS NULL
				AND process_id = @process_id

			INSERT INTO #temp_messages ([source_deal_header_id], [column], [messages])
			SELECT DISTINCT source_deal_header_id, 'asset_class', 'asset_class cannot be blank'
			FROM source_emir
			WHERE NULLIF(asset_class, '') IS NOT NULL 
				AND asset_class NOT IN ('CO', 'CR', 'CU', 'EQ', 'IR')
				AND process_id = @process_id

			INSERT INTO #temp_messages ([source_deal_header_id], [column], [messages])
			SELECT DISTINCT source_deal_header_id, 'product_classification_type', 'product_classification_type cannot be blank'
			FROM source_emir
			WHERE NULLIF(product_classification_type, '') IS NULL
				AND process_id = @process_id

			INSERT INTO #temp_messages ([source_deal_header_id], [column], [messages])
			SELECT DISTINCT source_deal_header_id, 'product_classification', 'product_classification cannot be blank'
			FROM source_emir
			WHERE NULLIF(product_classification, '') IS NULL
				AND process_id = @process_id

			INSERT INTO #temp_messages ([source_deal_header_id], [column], [messages])
			SELECT DISTINCT source_deal_header_id, 'product_classification', 'product_classification does not match the format'
			FROM source_emir
			WHERE NULLIF(product_classification, '') IS NOT NULL 
				AND IIF(product_classification = 'C', product_classification_type, '')  <> IIF(product_classification = 'C', 'C', '')
				AND process_id = @process_id

			INSERT INTO #temp_messages ([source_deal_header_id], [column], [messages])
			SELECT DISTINCT source_deal_header_id, 'product_identification_type', 'product_identification_type cannot be blank'
			FROM source_emir
			WHERE NULLIF(product_identification_type, '') IS NULL
				AND process_id = @process_id

			INSERT INTO #temp_messages ([source_deal_header_id], [column], [messages])
			SELECT DISTINCT source_deal_header_id, 'product_identification_type', 'product_identification_type does not match the format'
			FROM source_emir
			WHERE NULLIF(product_identification_type, '') IS NOT NULL 
				AND product_identification_type NOT IN ('I', 'A')
				AND process_id = @process_id

			INSERT INTO #temp_messages ([source_deal_header_id], [column], [messages])
			SELECT DISTINCT source_deal_header_id, 'product_identification', 'product_identification cannot be blank'
			FROM source_emir
			WHERE NULLIF(product_identification_type, '') IS NOT NULL 
				AND product_identification IS NULL
				AND process_id = @process_id

			INSERT INTO #temp_messages ([source_deal_header_id], [column], [messages])
			SELECT DISTINCT source_deal_header_id, 'product_identification', 'product_identification does not match the format'
			FROM source_emir
			WHERE NULLIF(product_identification, '') IS NOT NULL 
				AND CASE 
						WHEN product_identification = 'I' THEN product_identification_type
						WHEN product_identification = 'A' THEN product_identification_type
						ELSE '' 
					END  <> CASE 
								WHEN product_identification = 'I' THEN 'ISIN' 
								WHEN product_identification = 'A' THEN 'All' 
								ELSE '' 
							END
				AND process_id = @process_id
			
			INSERT INTO #temp_messages ([source_deal_header_id], [column], [messages])
			SELECT DISTINCT source_deal_header_id, 'underlying', 'underlying AND reference_entity both cannot be blank when asset class is "CR"'
			FROM source_emir
			WHERE NULLIF(underlying, '') IS NOT NULL 
				AND asset_class = 'CR'
				AND process_id = @process_id

			INSERT INTO #temp_messages ([source_deal_header_id], [column], [messages])
			SELECT DISTINCT source_deal_header_id, 'underlying', 'underlying both cannot be blank'
			FROM source_emir
			WHERE NULLIF(underlying, '') IS NOT NULL 
				AND asset_class = 'EQ'
				AND process_id = @process_id

			INSERT INTO #temp_messages ([source_deal_header_id], [column], [messages])
			SELECT DISTINCT source_deal_header_id, 'underlying', 'underlying, fixed_rate_leg_1 AND float_rate_leg_1 all three cannot be blank'
			FROM source_emir
			WHERE NULLIF(underlying, '') IS NOT NULL 
				AND asset_class = 'IR'
				AND process_id = @process_id

			INSERT INTO #temp_messages ([source_deal_header_id], [column], [messages])
			SELECT DISTINCT source_deal_header_id, 'underlying', 'underlying does not match the format'
			FROM source_emir
			WHERE NULLIF(underlying, '') IS NOT NULL 
				AND underlying NOT IN ('I','A','U','B','X')
				AND process_id = @process_id

			INSERT INTO #temp_messages ([source_deal_header_id], [column], [messages])
			SELECT DISTINCT source_deal_header_id, 'underlying_identification', 'underlying_identification does not match the format'
			FROM source_emir
			WHERE NULLIF(underlying, '') IS NOT NULL 
				AND LEN(underlying_identification) <> CASE WHEN underlying = 'I' THEN 12 
														   WHEN underlying = 'A' THEN 48 
														   WHEN underlying = 'B' THEN 6499 
													 END
				AND process_id = @process_id
			
			INSERT INTO #temp_messages ([source_deal_header_id], [column], [messages])
			SELECT DISTINCT source_deal_header_id, 'notional_currency_1', 'notional_currency_1 cannot be blank'
			FROM source_emir
			WHERE NULLIF(notional_currency_1, '') IS NULL
				AND process_id = @process_id

			INSERT INTO #temp_messages ([source_deal_header_id], [column], [messages])
			SELECT DISTINCT source_deal_header_id, 'notional_currency_1', 'notional_currency_1 does not match the format'
			FROM source_emir
			WHERE NULLIF(notional_currency_1, '') IS NOT NULL
				AND notional_currency_1 NOT IN ('BGN', 'CHF', 'CZK','DKK', 'EUR', 'EUX','GBX', 'GBP', 'HRK','HUF', 'ISK', 'NOK','PCT', 'PLN', 'RON','SEK', 'USD', 'OTH')
				AND process_id = @process_id

			INSERT INTO #temp_messages ([source_deal_header_id], [column], [messages])
			SELECT DISTINCT source_deal_header_id, 'trade_id', 'trade_id cannot be blank'
			FROM source_emir
			WHERE NULLIF(trade_id, '') IS NULL
				AND process_id = @process_id

			INSERT INTO #temp_messages ([source_deal_header_id], [column], [messages])
			SELECT DISTINCT source_deal_header_id, 'trade_id', 'trade_id does not match the format'
			FROM source_emir
			WHERE NULLIF(trade_id, '') IS NOT NULL
				AND LEN(trade_id) > 52
				AND process_id = @process_id
				
			INSERT INTO #temp_messages ([source_deal_header_id], [column], [messages])
			SELECT DISTINCT source_deal_header_id, 'exec_venue', 'exec_venue cannot be blank'
			FROM source_emir
			WHERE NULLIF(exec_venue, '') IS NULL
				AND process_id = @process_id

			/*INSERT INTO #temp_messages ([source_deal_header_id], [column], [messages])
			SELECT DISTINCT source_deal_header_id, 'exec_venue', 'exec_venue does not match format'
			FROM source_emir
			WHERE NULLIF(exec_venue, '') IS NOT NULL
				AND (exec_venue NOT IN (
					SELECT clm4_value 
					FROM generic_mapping_values gmv 
						INNER JOIN generic_mapping_header gmh 
							ON gmh.mapping_table_id = gmv.mapping_table_id
								AND mapping_name = 'Venue of Execution'
					)
				AND exec_venue <> 'XOFF')
				AND process_id = @process_id
			*/
			INSERT INTO #temp_messages ([source_deal_header_id], [column], [messages])
			SELECT DISTINCT source_deal_header_id, 'price_currency', 'price_currency cannot be blank when price_notation is U'
			FROM source_emir
			WHERE NULLIF(price_currency, '') IS NULL 
				AND price_notation = 'U'
				AND process_id = @process_id

			INSERT INTO #temp_messages ([source_deal_header_id], [column], [messages])
			SELECT DISTINCT source_deal_header_id, 'price_currency', 'price_currency does not match the format'
			FROM source_emir
			WHERE NULLIF(price_currency, '') IS NOT NULL 
				AND price_currency NOT IN ('BGN', 'CHF', 'CZK','DKK', 'EUR', 'EUX','GBX', 'GBP', 'HRK','HUF', 'ISK', 'NOK','PCT', 'PLN', 'RON','SEK', 'USD', 'OTH')
				AND process_id = @process_id
			
			INSERT INTO #temp_messages ([source_deal_header_id], [column], [messages])
			SELECT DISTINCT source_deal_header_id, 'notional_amount', 'notional_amount cannot be blank'
			FROM source_emir
			WHERE notional_amount IS NULL
				AND process_id = @process_id

			INSERT INTO #temp_messages ([source_deal_header_id], [column], [messages])
			SELECT DISTINCT source_deal_header_id, 'notional_amount', 'notional_amount should be greater than 0'
			FROM source_emir
			WHERE NULLIF(notional_amount, '') IS NOT NULL 
				AND notional_amount < 0 
				AND asset_class <> 'CO'
				AND process_id = @process_id

			INSERT INTO #temp_messages ([source_deal_header_id], [column], [messages])
			SELECT DISTINCT source_deal_header_id, 'price_multiplier', 'price_multiplier cannot be blank'
			FROM source_emir
			WHERE NULLIF(price_multiplier, '') IS NULL
				AND process_id = @process_id

			INSERT INTO #temp_messages ([source_deal_header_id], [column], [messages])
			SELECT DISTINCT source_deal_header_id, 'price_multiplier', 'price_multiplier should be greater than 0'
			FROM source_emir
			WHERE NULLIF(price_multiplier, '') IS NOT NULL
				AND price_multiplier < 0
				AND process_id = @process_id

			INSERT INTO #temp_messages ([source_deal_header_id], [column], [messages])
			SELECT DISTINCT source_deal_header_id, 'quantity', 'quantity cannot be blank'
			FROM source_emir
			WHERE NULLIF(quantity, '') IS NULL
				AND process_id = @process_id

			INSERT INTO #temp_messages ([source_deal_header_id], [column], [messages])
			SELECT DISTINCT source_deal_header_id, 'quantity', 'quantity cannot be negative value'
			FROM source_emir
			WHERE NULLIF(quantity, '') IS NULL
				AND quantity < 0
				AND process_id = @process_id
			
			INSERT INTO #temp_messages ([source_deal_header_id], [column], [messages])
			SELECT DISTINCT source_deal_header_id, 'delivery_type', 'delivery_type cannot be blank'
			FROM source_emir
			WHERE NULLIF(delivery_type, '') IS NULL
				AND process_id = @process_id

			/*INSERT INTO #temp_messages ([source_deal_header_id], [column], [messages])
			SELECT DISTINCT source_deal_header_id, 'aggreement_version', 'aggreement_version cannot be blank'
			FROM source_emir
			WHERE NULLIF(aggreement_version, '') IS NULL 
				AND NULLIF(aggreement_type, '') IS NOT NULL
				AND process_id = @process_id

			INSERT INTO #temp_messages ([source_deal_header_id], [column], [messages])
			SELECT DISTINCT source_deal_header_id, 'confirm_ts', 'confirm_ts cannot be blank'
			FROM source_emir
			WHERE NULLIF(confirm_ts, '') IS NULL 
				AND confirm_means NOT IN ('Y', 'E')
				AND process_id = @process_id
			*/
			INSERT INTO #temp_messages ([source_deal_header_id], [column], [messages])
			SELECT DISTINCT source_deal_header_id, 'confirm_ts', 'confirm_ts must be greater than or equal to execution_timestamp'
			FROM source_emir
			WHERE NULLIF(confirm_ts, '') IS NOT NULL 
				AND LEFT(confirm_ts, 10) < LEFT(execution_timestamp, 10)
				AND process_id = @process_id
				AND execution_timestamp IS NOT NULL
				AND @level <> 'M'

			/*INSERT INTO #temp_messages ([source_deal_header_id], [column], [messages])
			SELECT DISTINCT source_deal_header_id, 'confirm_means', 'confirm_means cannot be blank'
			FROM source_emir
			WHERE confirm_means NOT IN ('Y', 'N', 'E')
				AND process_id = @process_id*/

			INSERT INTO #temp_messages ([source_deal_header_id], [column], [messages])
			SELECT DISTINCT source_deal_header_id, 'clearing_obligation', 'clearing_obligation does not match the format'
			FROM source_emir
			WHERE clearing_obligation NOT IN ('Y', 'N') 
				AND exec_venue IS NULL
				AND process_id = @process_id

			/*INSERT INTO #temp_messages ([source_deal_header_id], [column], [messages])
			SELECT DISTINCT source_deal_header_id, 'cleared', 'cleared cannot be blank'
			FROM source_emir
			WHERE NULLIF(cleared, '') IS NULL
				AND process_id = @process_id*/

			--INSERT INTO #temp_messages ([source_deal_header_id], [column], [messages])
			--SELECT DISTINCT source_deal_header_id, 'clearing_ts', 'clearing_ts cannot be blank'
			--FROM source_emir
			--WHERE cleared = 'Y' 
			--	AND clearing_ts IS NULL
			--	AND process_id = @process_id

			--INSERT INTO #temp_messages ([source_deal_header_id], [column], [messages])
			--SELECT DISTINCT source_deal_header_id, 'clearing_ts', 'clearing_ts must be greater than execution_timestamp'
			--FROM source_emir
			--WHERE clearing_ts IS NOT NULL 
			--	AND LEFT(clearing_ts, 10) < LEFT(execution_timestamp, 10)
			--	AND process_id = @process_id
			--	AND execution_timestamp IS NOT NULL

			INSERT INTO #temp_messages ([source_deal_header_id], [column], [messages])
			SELECT DISTINCT source_deal_header_id, 'intra_group', 'intra_group cannot be blank'
			FROM source_emir
			WHERE exec_venue IS NULL 
				AND intra_group IS NULL
				AND process_id = @process_id

			INSERT INTO #temp_messages ([source_deal_header_id], [column], [messages])
			SELECT DISTINCT source_deal_header_id, 'action_type', 'action_type cannot be blank'
			FROM source_emir
			WHERE action_type IS NULL
				AND process_id = @process_id

			INSERT INTO #temp_messages ([source_deal_header_id], [column], [messages])
			SELECT DISTINCT source_deal_header_id, 'level', 'level cannot be blank'
			FROM source_emir
			WHERE [level] IS NULL
				AND process_id = @process_id

			INSERT INTO #temp_messages ([source_deal_header_id], [column], [messages])
			SELECT DISTINCT source_deal_header_id, 'effective_date', 'effective_date cannot be less than execution_timestamp'
			FROM source_emir
			WHERE LEFT(effective_date, 10) < LEFT(execution_timestamp, 10)
				AND process_id = @process_id
				AND execution_timestamp IS NOT NULL
				AND effective_date IS NOT NULL

			INSERT INTO #temp_messages ([source_deal_header_id], [column], [messages])
			SELECT source_deal_header_id, 'maturity_date', 'maturity_date must be greater than execution_timestamp'
			FROM source_emir
			WHERE LEFT(maturity_date, 10) < LEFT(execution_timestamp, 10)
				AND process_id = @process_id
				AND maturity_date IS NOT NULL
				AND execution_timestamp IS NOT NULL

			INSERT INTO #temp_messages ([source_deal_header_id], [column], [messages])
			SELECT source_deal_header_id, 'settlement_date', 'settlement_date must be greater than execution_timestamp'
			FROM source_emir
			WHERE LEFT(settlement_date, 10) < LEFT(execution_timestamp, 10)
				AND process_id = @process_id
				AND settlement_date IS NOT NULL
				AND execution_timestamp IS NOT NULL
			
			--delete from #temp_messages //commented for demo

			IF OBJECT_ID('tempdb..#error_messages') IS NOT NULL
				DROP TABLE #error_messages

			SELECT a.source_deal_header_id, 
				STUFF((SELECT ', ' + messages
						FROM #temp_messages b 
						WHERE b.source_deal_header_id = a.source_deal_header_id 
						FOR XML PATH('')), 1, 2, '') messages
			INTO #error_messages
			FROM #temp_messages a
			GROUP BY a.source_deal_header_id

			UPDATE se
			SET error_validation_message = tm.messages
			FROM source_emir se
			INNER JOIN #error_messages tm 
				ON se.source_deal_header_id = tm.source_deal_header_id
			END		
			/*******************************************Error Validation End*********************************************/
			COMMIT
			EXEC spa_ErrorHandler 0, 'Regulatory Submission', 'spa_source_emir', 'Success', 'Data saved successfully.', ''
		END TRY
		BEGIN CATCH
			DECLARE @error VARCHAR(1000)
			SET @error = 'Error:-' + ERROR_MESSAGE()
			ROLLBACK	
			EXEC spa_ErrorHandler -1, 'Regulatory Submission', 'spa_source_emir', 'Error', @error, ''
		END CATCH
	END
	IF @submission_type = 44703 AND @level = 'C' --Logic to insert EMIR collateral report
	BEGIN
		DELETE a
		FROM #temp_deals a
		INNER JOIN source_emir_collateral b
			ON a.source_deal_header_id = b.source_deal_header_id
				AND a.deal_id = b.deal_id
				AND a.sub_book_id = b.sub_book_id
		WHERE b.submission_status = 39501
			AND b.[level] = @level

		IF NOT EXISTS (SELECT 1 FROM #temp_deals)
		BEGIN
			EXEC spa_ErrorHandler -1, 'Regulatory Submission', 'spa_source_emir', 'Error', 'No new deals found.', ''
			RETURN
		END

		IF OBJECT_ID('tempdb..#temp_source_emir_collateral') IS NOT NULL
			DROP TABLE #temp_source_emir_collateral

		SELECT source_deal_header_id = sdh.source_deal_header_id,
			   --CONVERT(VARCHAR(10), mcc.margin_call_date, 120) , CONVERT(VARCHAR(10), GETDATE(), 120),
			   deal_id = MAX(sdh.deal_id),
			   sub_book_id = MAX(sdh.sub_book_id),
			   message_type = 'CollateralValue',
			   data_submitter_message_id = '',
			   [action] = @action_type,
			   data_submitter_prefix = '',
			   data_submitter_value = MAX(sub_cpty.LEI),
			   trade_party_prefix = '',
			   trade_party_value = MAX(deal_cpty.LEI),
			   execution_agent_party_prefix = '',
			   execution_agent_party_value = MAX(sub_cpty.LEI),
			   collateral_portfolio_code = MAX(sco.counterparty_id),
			   collateral_portfolio = 'Y',
			   value_of_the_collateral = '',
			   currency_of_the_collateral = '',
			   collateral_valuation_date_time = '',
			   collateral_reporting_date = '',
			   send_to = '',
			   execution_agent_masking_indicator = 'FALSE',
			   trade_party_reporting_obligation = 'ESMA',
			   other_party_id_type = CASE 
										WHEN MAX(sco.int_ext_flag) = 'i' THEN 'Internal' 
										WHEN MAX(sco.int_ext_flag) = 'e' THEN 'External' 
										WHEN MAX(sco.int_ext_flag) = 'b' THEN 'Broker' 
									 END,
			   other_party_id = MAX(sco.counterparty_name),
			   collateralized = 'Fully',
			   initial_margin_posted = SUM(CAST(deal_udf.[Initial Margin] AS FLOAT)),
			   initial_margin_posted_currency = MAX(sc.currency_name),
			   initial_margin_received = SUM(ipi.payment_amount),
			   initial_margin_received_currency = MAX(sc.currency_name),
			   variation_margin_posted = SUM(mcc.margin_call_amount),
			   variation_margin_posted_currency = MAX(sc.currency_name),
			   variation_margin_received = SUM(mpi.payment_amount),
			   variation_margin_received_currency = MAX(mpi.currency),
			   excess_collateral_posted = '',
			   excess_collateral_posted_currency = '',
			   excess_collateral_received = '',
			   excess_collateral_received_currency = '',
			   third_party_viewer = '',
			   reserved_participant_use_1 = '',
			   reserved_participant_use_2 = '',
			   reserved_participant_use_3 = '',
			   reserved_participant_use_4 = '',
			   reserved_participant_use_5 = '',
			   action_type_party_1 = 'V',
			   third_party_viewer_id_type = '',
			   [level] = '',
			   process_id = @process_id,
			   error_validation_message = NULL,
			   submission_status = 39500,
			   submission_date = NULL,
			   create_date_from = @create_date_from,
			   create_date_to = @create_date_to
		INTO #temp_source_emir_collateral
		FROM #temp_deals sdh
		INNER JOIN #temp_deal_details sdd
			ON sdh.source_deal_header_id = sdd.source_deal_header_id
		LEFT JOIN #temp_cpty_udf_values deal_cpty
			ON deal_cpty.source_deal_header_id = sdh.source_deal_header_id
		LEFT JOIN #temp_cpty_udf_values sub_cpty
			ON sub_cpty.sub_book_id = sdh.sub_book_id
		LEFT JOIN source_currency sc
			ON sc.source_currency_id = sdd.fixed_price_currency_id
		LEFT JOIN source_counterparty sco
			ON sco.source_counterparty_id = sdh.counterparty_id
		LEFT JOIN initial_payment_info ipi
			ON ipi.deal_id = sdh.deal_id
		LEFT JOIN margin_payment_info mpi
			ON mpi.counterparty_id = sco.counterparty_id
		LEFT JOIN margin_calculation_counterparty mcc
			ON mcc.counterparty_id = sco.source_counterparty_id
		LEFT JOIN #temp_deal_udf_values deal_udf
			ON deal_udf.source_deal_header_id = sdh.source_deal_header_id
		--WHERE CONVERT(VARCHAR(10), mcc.margin_call_date, 120) = CONVERT(VARCHAR(10), GETDATE(), 120)
		GROUP BY sdh.source_deal_header_id

		BEGIN TRY
		BEGIN TRANSACTION
			INSERT INTO source_emir_collateral (
				source_deal_header_id, deal_id, sub_book_id, message_type, data_submitter_message_id, [action], data_submitter_prefix, data_submitter_value, trade_party_prefix,
				trade_party_value, execution_agent_party_prefix, execution_agent_party_value, collateral_portfolio_code, collateral_portfolio, value_of_the_collateral, 
				currency_of_the_collateral, collateral_valuation_date_time, collateral_reporting_date, send_to, execution_agent_masking_indicator, trade_party_reporting_obligation,
				other_party_id_type, other_party_id, collateralized, initial_margin_posted, initial_margin_posted_currency, initial_margin_received, initial_margin_received_currency,
				variation_margin_posted, variation_margin_posted_currency, variation_margin_received, variation_margin_received_currency, excess_collateral_posted, 
				excess_collateral_posted_currency, excess_collateral_received, excess_collateral_received_currency, third_party_viewer, reserved_participant_use_1, 
				reserved_participant_use_2, reserved_participant_use_3, reserved_participant_use_4, reserved_participant_use_5, action_type_party_1, third_party_viewer_id_type, 
				[level], process_id, error_validation_message, submission_status, submission_date, create_date_from, create_date_to		
			)
			SELECT * FROM #temp_source_emir_collateral
			
			COMMIT
			EXEC spa_ErrorHandler 0, 'Regulatory Submission', 'spa_source_emir', 'Success', 'Data saved successfully.', ''
		END TRY
		BEGIN CATCH
			PRINT 'Catch Error:' + ERROR_MESSAGE()
			ROLLBACK	
			EXEC spa_ErrorHandler -1, 'Regulatory Submission', 'spa_source_emir', 'Error', 'Failed to save data.', ''
		END CATCH
	END
	ELSE IF @submission_type = 44704 AND @level_mifid = 'X' -- Logic to insert MiFID Transaction report
	BEGIN
		IF OBJECT_ID('tempdb..#mifid_log_status') IS NOT NULL
			DROP TABLE #mifid_log_status

		SELECT a.deal_id, 
			   a.response_status, 
			   a.create_ts,
			   RANK() OVER(PARTITION BY a.deal_id ORDER BY a.create_ts DESC) [rank]
		INTO #mifid_log_status
		FROM source_mifid_audit_log a
		INNER JOIN #temp_deals sdh
			ON sdh.deal_id = a.deal_id
		ORDER BY a.deal_id
		
		IF OBJECT_ID('tempdb..#source_mifid') IS NOT NULL
			DROP TABLE #source_mifid

		SELECT sm.deal_id, 
			   sm.report_status,
			   sm.create_ts,
			   RANK() OVER(PARTITION BY sm.deal_id ORDER BY sm.create_ts DESC) [rank]
		INTO #source_mifid
		FROM source_mifid sm
		INNER JOIN #temp_deals sdh
			ON sdh.source_deal_header_id = sm.source_deal_header_id
		WHERE sm.submission_status = 39502
		ORDER BY deal_id
		
		DELETE a
		FROM #temp_deals a
		LEFT JOIN #mifid_log_status b
			ON a.deal_id = b.deal_id
		INNER JOIN static_data_value sdv
			ON sdv.value_id = a.deal_status
				AND sdv.[type_id] = 5600
		LEFT JOIN #source_mifid sm
			ON a.deal_id = b.deal_id
		WHERE (b.[rank] = 1 OR ( NULLIF(sm.report_status, '') IS NULL AND NULLIF(response_status, '') IS NULL))
			AND (sm.[rank] = 1 OR ( NULLIF(sm.report_status, '') IS NULL AND NULLIF(response_status, '') IS NULL))
			AND (
				   (sdv.code IN ('New', 'Amended') AND sm.report_status = 'NEWT' AND response_status = 'ACPT')	
				OR (sdv.code IN ('New', 'Amended') AND sm.report_status = 'NEWT' AND response_status = 'ACPD')	
				OR (sdv.code IN ('New', 'Amended') AND sm.report_status = 'NEWT' AND response_status = 'PDNG')	
				OR (sdv.code IN ('New', 'Amended') AND sm.report_status = 'NEWT' AND response_status = 'WARN')	
				OR (sdv.code IN ('New', 'Amended') AND sm.report_status = 'NEWT' AND response_status = 'RCVD')	
				OR (sdv.code IN ('New', 'Amended') AND sm.report_status = 'CANC' AND response_status = 'PDNG')	
				OR (sdv.code IN ('New', 'Amended') AND sm.report_status = 'CANC' AND response_status = 'RJCT')	
				OR (sdv.code IN ('New', 'Amended') AND sm.report_status = 'CANC' AND response_status = 'RJPD')	
				OR (sdv.code IN ('New', 'Amended') AND sm.report_status = 'CANC' AND response_status = 'RCVD')
				OR (sdv.code = 'Reviewed' AND NULLIF(sm.report_status, '') IS NULL AND NULLIF(response_status, '') IS NULL)	
				OR (sdv.code = 'Reviewed' AND sm.report_status = 'NEWT' AND response_status = 'RJCT')	
				OR (sdv.code = 'Reviewed' AND sm.report_status = 'NEWT' AND response_status = 'RJPD')	
				OR (sdv.code = 'Reviewed' AND sm.report_status = 'CANC' AND response_status = 'ACPT')	
				OR (sdv.code = 'Reviewed' AND sm.report_status = 'CANC' AND response_status = 'ACPD')	
				OR (sdv.code = 'Reviewed' AND sm.report_status = 'CANC' AND response_status = 'PDNG')	
				OR (sdv.code = 'Reviewed' AND sm.report_status = 'CANC' AND response_status = 'WARN')	
				OR (sdv.code = 'Reviewed' AND sm.report_status = 'CANC' AND response_status = 'RCVD')	
			)
		
		IF NOT EXISTS (SELECT 1 FROM #temp_deals)
		BEGIN
			EXEC spa_ErrorHandler -1, 'Regulatory Submission', 'spa_source_emir', 'Error', 'No new deals found.', ''
			RETURN
		END
		
		DECLARE @macquarie_lei VARCHAR(1024), @macquarie_country VARCHAR(100)

		SELECT @macquarie_lei = musddv.static_data_udf_values,
			   @macquarie_country = sdv.code
	 	FROM source_counterparty td
		INNER JOIN maintain_udf_static_data_detail_values musddv
			ON musddv.primary_field_object_id = td.source_counterparty_id
		INNER JOIN application_ui_template_fields autf
			ON autf.application_field_id = musddv.application_field_id
		INNER JOIN user_defined_fields_template udft
			ON udft.udf_template_id = autf.udf_template_id
		LEFT JOIN static_data_value sdv
			ON sdv.value_id = td.country
		WHERE counterparty_name = 'MacQuarie Bank International'
			AND Field_label = 'LEI'

		IF OBJECT_ID('tempdb..#temp_source_mifid') IS NOT NULL
			DROP TABLE #temp_source_mifid
					
		SELECT DISTINCT
			   source_deal_header_id = sdh.source_deal_header_id,
			   deal_id = sdh.deal_id,
			   sub_book_id = sdh.sub_book_id,
			   report_status = CASE 
			   					WHEN deal_status.code IN ('New', 'Amended') THEN 'NEWT' 											 
			   					WHEN deal_status.code = 'Reviewed' THEN 'CANC' 
			   				END,
			   trans_ref_no = sdh.deal_id,
			   trading_trans_id = CASE 
			   						WHEN deal_status.code IN ('New', 'Amended') AND gmv.clm14_value = 'Y' THEN deal_udf.[Trading Venue Transaction ID] 
			   						ELSE NULL 
			   					END,
			   exec_entity_id = sub_cpty.LEI,
			   covered_by_dir = IIF(deal_status.code IN ('New', 'Amended'), 'true', NULL),
			   submitting_entity_id_code = sub_cpty.LEI,
			   --buyer_id = IIF(deal_status.code IN ('New', 'Amended'), 
						--	IIF(sdh.header_buy_sell_flag = 'b', sub_cpty.LEI,
						--		IIF(scn.counterparty_id NOT IN ('ICE', 'CME'), deal_cpty.LEI, @macquarie_lei)
						--  ), NULL),
			   buyer_id = IIF(deal_status.code IN ('New', 'Amended'), 
							IIF(sdh.header_buy_sell_flag = 'b', sub_cpty.LEI, deal_cpty.LEI)
						  , NULL),
			   --buyer_country = IIF(deal_status.code IN ('New', 'Amended'), 
						--			IIF(sdh.header_buy_sell_flag = 'b', NULLIF(c_sub_cpty.code, ''), 
						--				IIF(scn.counterparty_id NOT IN ('ICE', 'CME'), NULLIF(c_deal_cpty.code, ''), @macquarie_country)
						--			), 
						--	   NULL),
			   buyer_country = IIF(deal_status.code IN ('New', 'Amended'), 
									IIF(sdh.header_buy_sell_flag = 'b', NULLIF(c_sub_cpty.code, ''), NULLIF(c_deal_cpty.code, ''))
							   , NULL),
			   buyer_fname = NULL,
			   buyer_sname = NULL,
			   buyer_dob = NULL,
			   --buyer_decision_maker_code = IIF(deal_status.code IN ('New', 'Amended'), 
						--						UPPER(IIF(sdh.header_buy_sell_flag = 'b', st.national_id, 
						--							IIF(scn.counterparty_id NOT IN ('ICE', 'CME'), dm_cc.national_id, @macquarie_lei)
						--						)
						--					), NULL),
			   buyer_decision_maker_code = IIF(deal_status.code IN ('New', 'Amended'), 
												UPPER(IIF(sdh.header_buy_sell_flag = 'b', st.national_id, 
													IIF(scn.counterparty_id NOT IN ('ICE', 'CME', 'EEX'), ISNULL( dm_cc.national_id, deal_cpty.LEI), deal_cpty.LEI)
												)
											), NULL),  
			   --buyer_decision_maker_fname = IIF(deal_status.code IN ('New', 'Amended'), 
						--						UPPER(IIF(sdh.header_buy_sell_flag = 'b', st.trader_name, 
						--							IIF(scn.counterparty_id NOT IN ('ICE', 'CME'), dm_cc.[name], NULL)
						--							)
						--					), NULL),
			   buyer_decision_maker_fname = IIF(deal_status.code IN ('New', 'Amended'), 
												UPPER(IIF(sdh.header_buy_sell_flag = 'b', st.trader_name, 
													IIF(scn.counterparty_id NOT IN ('ICE', 'CME', 'EEX'), dm_cc.[name], NULL)
													)
											), NULL),
			   --buyer_decision_maker_sname = IIF(deal_status.code IN ('New', 'Amended'), 
						--						UPPER(IIF(sdh.header_buy_sell_flag = 'b', st.last_name, 
						--							IIF(scn.counterparty_id NOT IN ('ICE', 'CME'), dm_cc.last_name, NULL)
						--							)
						--					), NULL),
			   buyer_decision_maker_sname = IIF(deal_status.code IN ('New', 'Amended'), 
												UPPER(IIF(sdh.header_buy_sell_flag = 'b', st.last_name, 
													IIF(scn.counterparty_id NOT IN ('ICE', 'CME', 'EEX'), dm_cc.last_name, NULL)
													)
											), NULL),
			   --buyer_decision_maker_dob = IIF(deal_status.code IN ('New', 'Amended'), 
						--						IIF(sdh.header_buy_sell_flag = 'b', st.date_of_birth, 
						--							IIF(scn.counterparty_id NOT IN ('ICE', 'CME'), dm_cc.date_of_birth, NULL)
						--					), NULL),
			   buyer_decision_maker_dob = IIF(deal_status.code IN ('New', 'Amended'), 
												IIF(sdh.header_buy_sell_flag = 'b', st.date_of_birth, 
													IIF(scn.counterparty_id NOT IN ('ICE', 'CME', 'EEX'), dm_cc.date_of_birth, NULL)
											), NULL),
			   --seller_id = IIF(deal_status.code IN ('New', 'Amended'), 
						--	IIF(sdh.header_buy_sell_flag = 's', sub_cpty.LEI,
						--		IIF(scn.counterparty_id NOT IN ('ICE', 'CME'), deal_cpty.LEI, @macquarie_lei)
						--  ), NULL),
			   seller_id = IIF(deal_status.code IN ('New', 'Amended'), 
								IIF(sdh.header_buy_sell_flag = 's', sub_cpty.LEI, deal_cpty.LEI), 
						   NULL),
			   --seller_country = IIF(deal_status.code IN ('New', 'Amended'), 
						--			IIF(sdh.header_buy_sell_flag = 's', NULLIF(c_sub_cpty.code, ''), 
						--				IIF(scn.counterparty_id NOT IN ('ICE', 'CME'), NULLIF(c_deal_cpty.code, ''), @macquarie_country)
						--			), 
						--	   NULL),
			   seller_country = IIF(deal_status.code IN ('New', 'Amended'), 
									IIF(sdh.header_buy_sell_flag = 's', NULLIF(c_sub_cpty.code, ''), NULLIF(c_deal_cpty.code, ''))
								, NULL),
			   seller_fname = NULL,
			   seller_sname = NULL,
			   seller_dob = NULL,
			   --seller_decision_maker_code = IIF(deal_status.code IN ('New', 'Amended'), 
						--						UPPER(IIF(sdh.header_buy_sell_flag = 's', st.national_id, 
						--							IIF(scn.counterparty_id NOT IN ('ICE', 'CME'), dm_cc.national_id, @macquarie_lei)
						--						)
						--					), NULL),
			   seller_decision_maker_code = IIF(deal_status.code IN ('New', 'Amended'), 
												UPPER(IIF(sdh.header_buy_sell_flag = 's', st.national_id, 
													IIF(scn.counterparty_id NOT IN ('ICE', 'CME', 'EEX'), ISNULL( dm_cc.national_id, deal_cpty.LEI), deal_cpty.LEI)
												)
											), NULL),
			   --seller_decision_maker_fname = IIF(deal_status.code IN ('New', 'Amended'), 
						--						UPPER(IIF(sdh.header_buy_sell_flag = 's', st.trader_name, 
						--							IIF(scn.counterparty_id NOT IN ('ICE', 'CME'), dm_cc.[name], NULL)
						--						)
						--					 ), NULL),
			   seller_decision_maker_fname = IIF(deal_status.code IN ('New', 'Amended'), 
												UPPER(IIF(sdh.header_buy_sell_flag = 's', st.trader_name, 
													IIF(scn.counterparty_id NOT IN ('ICE', 'CME', 'EEX'), dm_cc.[name], NULL)
												)
											 ), NULL),
			   --seller_decision_maker_sname = IIF(deal_status.code IN ('New', 'Amended'), 
						--						UPPER(IIF(sdh.header_buy_sell_flag = 's', st.last_name,
						--							IIF(scn.counterparty_id NOT IN ('ICE', 'CME'), dm_cc.last_name, NULL)
						--						)
						--					 ), NULL),
			   seller_decision_maker_sname = IIF(deal_status.code IN ('New', 'Amended'), 
												UPPER(IIF(sdh.header_buy_sell_flag = 's', st.last_name,
													IIF(scn.counterparty_id NOT IN ('ICE', 'CME', 'EEX'), dm_cc.last_name, NULL)
												)
											 ), NULL),
			   --seller_decision_maker_dob = IIF(deal_status.code IN ('New', 'Amended'), 
						--						IIF(sdh.header_buy_sell_flag = 's', st.date_of_birth, 
						--						IIF(scn.counterparty_id NOT IN ('ICE', 'CME'), dm_cc.date_of_birth, NULL)
						--					), NULL),
			   seller_decision_maker_dob = IIF(deal_status.code IN ('New', 'Amended'), 
												IIF(sdh.header_buy_sell_flag = 's', st.date_of_birth, 
												IIF(scn.counterparty_id NOT IN ('ICE', 'CME', 'EEX'), dm_cc.date_of_birth, NULL)
											), NULL),
			   order_trans_indicator = IIF(deal_status.code <> 'Reviewed', 'false', NULL),
			   buyer_trans_firm_id = NULL,
			   seller_trans_firm_id = NULL,
			   trading_date_time = IIF(deal_status.code IN ('New', 'Amended'), LEFT(STUFF(STUFF(REPLACE(deal_udf.[Execution Timestamp], '-', 'T'), 7, 0, '-'), 5, 0, '-'), 19) + 'Z', NULL),
			   trading_capacity = IIF(deal_status.code IN ('New', 'Amended'), 'DEAL', NULL),
			   quantity = IIF(deal_status.code IN ('New', 'Amended'), sdd.total_volume, NULL),
			   quantity_currency = IIF(sco.commodity_id = 'FX', su.uom_id, NULL),--volume_uom -- NULL,--IIF(deal_status.code IN ('New', 'Amended'), sc.currency_name, NULL),
			   der_notional_incr_decr = NULL,--IIF(@action_type_mifid = 'NEWT', deal_udf.[Derivative Notional], NULL),
			   price = IIF(deal_status.code IN ('New', 'Amended'), sdd.fixed_price, NULL),
			   price_currency = IIF(deal_status.code IN ('New', 'Amended') AND sdd.fixed_price IS NOT NULL, sc.currency_name, NULL),
			   net_amount = NULL,
			   venue = IIF(deal_status.code IN ('New', 'Amended'), IIF(deal_udf.[Pure OTC] = 'Y', 'XXXX', IIF(scn.counterparty_id = gmv.clm7_value, gmv.clm4_value, 'XOFF')), NULL),
			   branch_membership_country = IIF(deal_status.code IN ('New', 'Amended'), 'NL', NULL),
			   upfront_payment = IIF(deal_status.code IN ('New', 'Amended'), deal_udf.[Initial Margin], NULL),
			   upfront_payment_currency = IIF(deal_status.code IN ('New', 'Amended'), IIF(deal_udf.[Initial Margin] IS NOT NULL, sc.currency_name, ''), NULL),
			   complex_trade_component_id = IIF(deal_status.code IN ('New', 'Amended'), deal_udf.[Complex Trade Component ID], NULL),
			   instrument_id_code = IIF(deal_status.code IN ('New', 'Amended'), IIF(deal_udf.[Pure OTC] = 'Y', NULL, IIF(sco.commodity_id = 'FX' AND sdt.deal_type_id = 'Forward' AND deal_udf.[ISIN] IS NOT NULL, deal_udf.[ISIN], IIF( IIF(scn.counterparty_id = gmv.clm7_value, gmv.clm4_value, 'XOFF') <> 'XXXX', IIF(sdt.deal_type_id = 'SPOT', gmv_spot.clm1_value, gmv1.clm1_value), NULL))), NULL),
									--IIF(deal_status.code IN ('New', 'Amended'), IIF(IIF(scn.counterparty_id = gmv.clm7_value, gmv.clm4_value, 'XOFF') <> 'XXXX', gmv1.clm1_value, NULL), NULL),
			   instrument_name = IIF(deal_status.code IN ('New', 'Amended'), IIF(sco.commodity_id = 'FX' AND sdt.deal_type_id = 'Forward' AND deal_udf.[ISIN] IS NOT NULL, 'FX FORWARD', IIF(sdt.deal_type_id = 'SPOT', gmv_spot.clm2_value, gmv1.clm2_value)), NULL),
									--IIF(deal_status.code IN ('New', 'Amended'), gmv1.clm2_value, NULL),
			   instrument_classification = IIF(deal_status.code IN ('New', 'Amended'), IIF(sco.commodity_id = 'FX' AND sdt.deal_type_id = 'Forward' AND deal_udf.[ISIN] IS NOT NULL, 'JFTXFP', IIF(sdt.deal_type_id = 'SPOT', gmv_spot.clm3_value, gmv1.clm3_value)), NULL),
									--IIF(deal_status.code IN ('New', 'Amended'), gmv1.clm3_value, NULL),
			   --notional_currency_1 = IIF(deal_status.code IN ('New', 'Amended'), IIF(sco.commodity_id = 'FX',su.uom_id, sc.currency_name), NULL), --for fx volume uom
			   --notional_currency_2 = IIF(sco.commodity_id = 'FX', sc.currency_name, NULL),
			   notional_currency_1 = IIF(deal_status.code IN ('New', 'Amended'), sc.currency_name, NULL),
			   notional_currency_2 = NULL,
			   price_multiplier = IIF(deal_status.code IN ('New', 'Amended'), 1, NULL),--IIF(deal_status.code IN ('New', 'Amended'), IIF(IIF(scn.counterparty_id = gmv.clm7_value, gmv.clm4_value, 'XOFF') IN ('SI', 'XOFF') OR gmv.clm14_value = 'Y', NULL, sdd.price_multiplier), NULL),
			   underlying_instrument_code = IIF(deal_status.code IN ('New', 'Amended'), IIF(sco.commodity_id = 'FX' AND sdt.deal_type_id = 'Forward' AND deal_udf.[ISIN] IS NOT NULL, deal_udf.[ISIN], IIF(sdt.deal_type_id = 'SPOT', gmv_spot.clm4_value, CASE WHEN sco.commodity_id IN ('CER', 'EUA') AND sdt.deal_type_id IN ('FORWARD','FUTURE') THEN gmv_ff.clm4_value ELSE gmv1.clm4_value END)), NULL),
											--IIF(deal_status.code IN ('New', 'Amended'), gmv1.clm4_value, NULL),
			   underlying_index_name = NULL,
			   underlying_index_term = NULL,
			   option_type = CASE 
			   				WHEN deal_status.code IN ('Reviewed') OR 
			   					(deal_udf.[Instrument Classification] LIKE 'F_____' OR deal_udf.[Instrument Classification] LIKE 'S_____' OR
			   						deal_udf.[Instrument Classification] LIKE 'E_____' OR deal_udf.[Instrument Classification] LIKE 'C_____' OR
			   						deal_udf.[Instrument Classification] LIKE 'D_____' OR deal_udf.[Instrument Classification] LIKE 'I_____' OR
			   						deal_udf.[Instrument Classification] LIKE 'J_____' OR deal_udf.[Instrument Classification] LIKE 'L_____' OR
			   						deal_udf.[Instrument Classification] LIKE 'T_____') THEN NULL  
			   				ELSE CASE WHEN UPPER(sdh.option_type) = 'P' THEN 'PUTO' WHEN UPPER(sdh.option_type) = 'C' THEN 'CALL' END
			   				END,
			   strike_price = CASE 
			   				WHEN deal_status.code IN ('Reviewed') OR 
			   					(deal_udf.[Instrument Classification] LIKE 'F_____' OR deal_udf.[Instrument Classification] LIKE 'S_____' OR
			   						deal_udf.[Instrument Classification] LIKE 'E_____' OR deal_udf.[Instrument Classification] LIKE 'C_____' OR
			   						deal_udf.[Instrument Classification] LIKE 'D_____' OR deal_udf.[Instrument Classification] LIKE 'I_____' OR
			   						deal_udf.[Instrument Classification] LIKE 'J_____' OR deal_udf.[Instrument Classification] LIKE 'L_____' OR
			   						deal_udf.[Instrument Classification] LIKE 'T_____') THEN NULL  
			   				ELSE sdd.option_strike_price
			   				END,
			   strike_price_currency = CASE 
			   							WHEN deal_status.code IN ('Reviewed') OR 
			   								(deal_udf.[Instrument Classification] LIKE 'F_____' OR deal_udf.[Instrument Classification] LIKE 'S_____' OR
			   									deal_udf.[Instrument Classification] LIKE 'E_____' OR deal_udf.[Instrument Classification] LIKE 'C_____' OR
			   									deal_udf.[Instrument Classification] LIKE 'D_____' OR deal_udf.[Instrument Classification] LIKE 'I_____' OR
			   									deal_udf.[Instrument Classification] LIKE 'J_____' OR deal_udf.[Instrument Classification] LIKE 'L_____' OR
			   									deal_udf.[Instrument Classification] LIKE 'T_____') THEN NULL  
			   							ELSE IIF(sdd.option_strike_price IS NOT NULL, sc.currency_name, NULL)
			   							END,						
			   option_exercise_style = CASE 
			   							WHEN (deal_status.code IN ('Reviewed') OR
			   									deal_udf.[Instrument Classification] LIKE 'F_____' OR deal_udf.[Instrument Classification] LIKE 'S_____' OR 
			   									deal_udf.[Instrument Classification] LIKE 'E_____' OR deal_udf.[Instrument Classification] LIKE 'C_____' OR
			   									deal_udf.[Instrument Classification] LIKE 'C_____' OR deal_udf.[Instrument Classification] LIKE 'D_____' OR
			   									deal_udf.[Instrument Classification] LIKE 'I_____' OR deal_udf.[Instrument Classification] LIKE 'J_____' OR
			   									deal_udf.[Instrument Classification] LIKE 'L_____' OR deal_udf.[Instrument Classification] LIKE 'T_____') THEN NULL
			   							ELSE CASE 
												WHEN UPPER(sdh.option_excercise_type) = 'A' THEN 'AMER' 
												WHEN UPPER(sdh.option_excercise_type) = 'E' THEN 'EURO' 
												WHEN UPPER(sdh.option_excercise_type) = 'S' THEN 'ASIA'
											 END
			   						END,						
			   maturity_date = '',
			   expiry_date = CASE WHEN deal_status.code IN ('Reviewed') OR deal_udf.[Instrument Classification] LIKE 'E_____' OR 
			   						deal_udf.[Instrument Classification] LIKE 'C_____' OR deal_udf.[Instrument Classification] LIKE 'D_____' OR
			   						deal_udf.[Instrument Classification] LIKE 'T_____' OR deal_udf.[Instrument Classification] LIKE 'M_____' 
			   					THEN NULL 
			   					ELSE CONVERT(DATE, (ISNULL(hg.exp_date, sdd.contract_expiration_date)), 120)
			   				END,
			   delivery_type = IIF(deal_status.code IN ('Reviewed'), NULL, 
								   IIF(scn.counterparty_id IN ('ICE', 'CME', 'EEX'), 'PHYS', deal_udf.[Delivery Type])
							   ),
			   firm_invest_decision = IIF(deal_status.code <> 'Reviewed', st.national_id, NULL),
			   decision_maker_country = IIF(deal_status.code <> 'Reviewed' AND st.national_id IS NOT NULL, 'NL', NULL),
			   firm_execution = IIF(deal_status.code <> 'Reviewed', st.national_id, NULL),
			   supervising_execution_country = IIF(deal_status.code <> 'Reviewed' AND st.national_id IS NOT NULL, 'NL', NULL),
			   waiver_indicator = NULL,
			   short_selling_indicator = IIF(deal_status.code IN ('New', 'Amended'), 'SELL', NULL),
			   otc_post_trade_indicator = NULL,--IIF((@action_type_mifid = 'NEWT' AND deal_udf.[Venue of Execution] IN ('XXXX', 'XOFF')), deal_udf.[OTC Post-Trade Indicator], NULL),
			   --commodity_derivative_indicator = IIF(deal_status.code <> 'Reviewed', IIF(sco.commodity_id IN ('EUA', 'EUAA'), 'true', 'false'), NULL), -- EUA AND EUAA are emmission allowence
			   commodity_derivative_indicator = IIF(deal_status.code <> 'Reviewed', 
												CASE 
													WHEN scn.counterparty_id IN ('ICE','EEX','CME') THEN 'true' 
													ELSE CASE WHEN sdt.deal_type_id = 'Spot' THEN 'false' 
															  WHEN sdt.deal_type_id = 'Future' OR deal_udf.[Delivery Type] = 'PHYS' THEN 'true' 
															  ELSE 'false'
														 END
												END, NULL),
			   securities_financing_transaction_indicator = IIF(deal_status.code <> 'Reviewed', 'false', NULL),
			   report_type = 1,
			   create_date_from = GETDATE(),
			   create_date_to = GETDATE(),
			   submission_status = 39500,
			   submission_date = GETDATE(),
			   confirmation_date = GETDATE(),
			   process_id = @process_id,
			   error_validation_message = NULL,
			   file_export_name = NULL,
			   hash_of_concatenated_values = NULL,
			   progressive_number = 1
		INTO #temp_source_mifid
		FROM #temp_deals sdh
		INNER JOIN #temp_deal_details sdd
			ON sdh.source_deal_header_id = sdd.source_deal_header_id
				AND sdd.leg = 1
		LEFT JOIN source_deal_type sdt 
			ON sdh.source_deal_type_id = sdt.source_deal_type_id
		LEFT JOIN #temp_deal_details sdd1
			ON sdh.source_deal_header_id = sdd1.source_deal_header_id
				AND sdd1.leg = 2
		LEFT JOIN source_price_curve_def spcd
			ON spcd.source_curve_def_id = sdd.curve_id
		LEFT JOIN holiday_group hg
			ON hg.hol_group_value_id = spcd.exp_calendar_id
				AND (sdd.term_start BETWEEN hg.hol_date AND hg.hol_date_to)
				AND (sdd.term_end BETWEEN hg.hol_date AND hg.hol_date_to)
		LEFT JOIN #temp_cpty_udf_values deal_cpty
			ON deal_cpty.source_deal_header_id = sdh.source_deal_header_id
		LEFT JOIN source_counterparty sc_deal_cpty 
			ON sc_deal_cpty.source_counterparty_id = deal_cpty.counterparty_id
		LEFT JOIN static_data_value c_deal_cpty 
			ON sc_deal_cpty.country = c_deal_cpty.value_id
		LEFT JOIN counterparty_contacts	deal_contact
			ON deal_contact.counterparty_id = sdh.counterparty_id
				AND deal_contact.contact_type = -32205
		LEFT JOIN #temp_cpty_udf_values sub_cpty
			ON sub_cpty.sub_book_id = sdh.sub_book_id
		LEFT JOIN source_counterparty sc_sub_cpty 
			ON sc_sub_cpty.source_counterparty_id = sub_cpty.counterparty_id		
		LEFT JOIN static_data_value c_sub_cpty 
			ON sc_sub_cpty.country = c_sub_cpty.value_id
		LEFT JOIN counterparty_contacts	sub_contact
			ON sub_contact.counterparty_id = sub_cpty.counterparty_id
				AND sub_contact.contact_type = -32205
		LEFT JOIN #temp_deal_udf_values deal_udf	
			ON deal_udf.source_deal_header_id = sdh.source_deal_header_id
		LEFT JOIN counterparty_contacts	dm_cc
			ON dm_cc.counterparty_id =  sdh.counterparty_id
				AND dm_cc.contact_type = -32205
				AND dm_cc.id = deal_udf.[decision_maker_id]
		LEFT JOIN source_currency sc
			ON sc.source_currency_id = sdd.fixed_price_currency_id
		LEFT JOIN contract_group cg
			ON cg.contract_id = sdh.contract_id
		LEFT JOIN static_data_value sdv_block
			ON sdv_block.value_id = sdh.block_define_id
		LEFT JOIN source_uom su
			ON su.source_uom_id = sdd.deal_volume_uom_id
		LEFT JOIN static_data_value sdv_deal_status
			ON sdv_deal_status.value_id = sdh.deal_status
		LEFT JOIN source_traders st
			ON st.source_trader_id = sdh.source_trader_id
		LEFT JOIN source_commodity	sco
			ON sco.source_commodity_id = sdh.commodity_id
		LEFT JOIN source_counterparty scn
			ON scn.source_counterparty_id = sdh.counterparty_id
		LEFT JOIN (
			SELECT gmva.mapping_table_id,
				   gmva.clm1_value,
				   gmva.clm2_value,
				   gmva.clm3_value,
				   gmva.clm4_value,
				   gmva.clm5_value,
				   gmva.clm6_value,
				   gmva.clm7_value,
				   gmva.clm8_value,
				   gmva.clm9_value,
				   gmva.clm10_value,
				   gmva.clm11_value,
				   gmva.clm12_value,
				   gmva.clm13_value,
				   gmva.clm14_value
			FROM generic_mapping_values gmva
			INNER JOIN generic_mapping_header gmh
				ON gmh.mapping_table_id = gmva.mapping_table_id
			WHERE gmh.mapping_name = 'Venue of Execution'
		) gmv ON clm7_value = scn.counterparty_id
		LEFT JOIN (
			SELECT gmvx.mapping_table_id,
				   gmvx.clm1_value,
				   gmvx.clm2_value,
				   gmvx.clm3_value,
				   gmvx.clm4_value,
				   gmvx.clm5_value,
				   gmvx.clm6_value,
				   gmvx.clm7_value,
				   gmvx.clm8_value,
				   gmvx.clm9_value
			FROM generic_mapping_values gmvx
			INNER JOIN generic_mapping_header gmh1
				ON gmh1.mapping_table_id = gmvx.mapping_table_id
			WHERE gmh1.mapping_name = 'Instrument Detail'
		) gmv1 ON gmv1.clm6_value = CAST(sdd.curve_id AS VARCHAR(10))
			AND MONTH(gmv1.clm5_value) = MONTH(sdd.contract_expiration_date)
			AND YEAR(gmv1.clm5_value) = YEAR(sdd.contract_expiration_date)
			AND CASE WHEN sdh.counterparty_id IN (SELECT source_counterparty_id FROM source_counterparty WHERE counterparty_id IN ('ICE', 'CME', 'EEX')) THEN sdh.counterparty_id ELSE (SELECT source_counterparty_id FROM source_counterparty WHERE counterparty_id IN ('ICE')) END = gmv1.clm7_value	
			AND ISNULL(NULLIF(sdh.option_type, ' '), '$') = ISNULL(gmv1.clm8_value, '$')
			AND ISNULL(gmv1.clm9_value, -1) = ISNULL(sdd.option_strike_price, -1)
		LEFT JOIN (
			SELECT gmvx.mapping_table_id,
				   gmvx.clm1_value,
				   gmvx.clm2_value,
				   gmvx.clm3_value,
				   gmvx.clm4_value,
				   gmvx.clm5_value,
				   gmvx.clm6_value,
				   gmvx.clm7_value,
				   gmvx.clm8_value,
				   gmvx.clm9_value
			FROM generic_mapping_values gmvx
			INNER JOIN generic_mapping_header gmh1
				ON gmh1.mapping_table_id = gmvx.mapping_table_id
			WHERE gmh1.mapping_name = 'Instrument Detail'
				AND gmvx.clm2_value = 'SPOT'
		) gmv_spot ON gmv_spot.clm6_value = CAST(sdd.curve_id AS VARCHAR(10))
			AND DAY(gmv_spot.clm5_value) = DAY(sdh.deal_date)
			AND MONTH(gmv_spot.clm5_value) = MONTH(sdh.deal_date)
			AND YEAR(gmv_spot.clm5_value) = YEAR(sdh.deal_date)
			AND CASE WHEN sdh.counterparty_id IN (SELECT source_counterparty_id FROM source_counterparty WHERE counterparty_id IN ('ICE', 'CME', 'EEX')) THEN sdh.counterparty_id ELSE (SELECT source_counterparty_id FROM source_counterparty WHERE counterparty_id IN ('ICE')) END = gmv_spot.clm7_value	
			AND ISNULL(NULLIF(sdh.option_type, ' '), '$') = ISNULL(gmv_spot.clm8_value, '$')
			AND ISNULL(gmv_spot.clm9_value, -1) = ISNULL(sdd.option_strike_price, -1)
		LEFT JOIN static_data_value deal_status
			ON sdh.deal_status = deal_status.value_id
		OUTER APPLY (
			SELECT
				   gmvx.clm4_value
			FROM generic_mapping_values gmvx
			INNER JOIN generic_mapping_header gmh1
				ON gmh1.mapping_table_id = gmvx.mapping_table_id
			INNER JOIN source_price_curve_def spcd1 ON spcd1.source_curve_def_id = CAST(gmvx.clm6_value AS INT)
			WHERE gmh1.mapping_name = 'Instrument Detail' 
			AND gmvx.clm2_value = 'SPOT' 
			AND DAY(gmvx.clm5_value) = DAY(sdh.deal_date)
			AND MONTH(gmvx.clm5_value) = MONTH(sdh.deal_date)
			AND YEAR(gmvx.clm5_value) = YEAR(sdh.deal_date)
			AND spcd1.commodity_id = spcd.commodity_id
			AND spcd1.curve_id like '% spot' 
			AND CASE WHEN sdh.counterparty_id IN (SELECT source_counterparty_id FROM source_counterparty WHERE counterparty_id IN ('ICE', 'CME', 'EEX')) THEN sdh.counterparty_id ELSE (SELECT source_counterparty_id FROM source_counterparty WHERE counterparty_id IN ('ICE')) END = gmvx.clm7_value
			
		) gmv_ff
		OUTER APPLY (
			SELECT ccc.national_id,
				   ccc.[name],
				   ccc.last_name,
				   ccc.date_of_birth
			FROM counterparty_contacts ccc
			LEFT JOIN source_traders stt 
				ON stt.trader_name = ccc.name + ' ' + ccc.last_name
			WHERE ccc.counterparty_id = deal_contact.counterparty_id
				AND stt.source_trader_id = sdh.source_trader_id
		) deal_trader_ccc
		OUTER APPLY (
			SELECT ccc.national_id,
				   ccc.[name],
				   ccc.last_name,
				   ccc.date_of_birth
			FROM counterparty_contacts ccc
			LEFT JOIN source_traders stt 
				ON stt.trader_name = ccc.name + ' ' + ccc.last_name
			WHERE ccc.counterparty_id = sub_contact.counterparty_id
		) sub_trader_ccc
		WHERE deal_status.code IN ('New', 'Amended', 'Reviewed')
			AND CASE WHEN NULLIF(@action_type_mifid, '') IS NULL THEN '1' 
					 ELSE CASE WHEN deal_status.code in ('New', 'Amended') THEN 'NEWT' 
							   WHEN deal_status.code = 'Reviewed' THEN 'CANC' 
						  END 
				END = CASE WHEN NULLIF(@action_type_mifid, '') IS NULL THEN '1' 
						   ELSE @action_type_mifid 
					  END

		BEGIN TRY
			BEGIN TRAN
			INSERT INTO source_mifid (source_deal_header_id, deal_id, sub_book_id, report_status, trans_ref_no, trading_trans_id, exec_entity_id, covered_by_dir, submitting_entity_id_code, buyer_id,
									  buyer_country, buyer_fname, buyer_sname, buyer_dob, buyer_decision_maker_code, buyer_decision_maker_fname, buyer_decision_maker_sname, buyer_decision_maker_dob,
									  seller_id, seller_country, seller_fname, seller_sname, seller_dob, seller_decision_maker_code, seller_decision_maker_fname, seller_decision_maker_sname,
									  seller_decision_maker_dob, order_trans_indicator, buyer_trans_firm_id, seller_trans_firm_id, trading_date_time, trading_capacity, quantity, quantity_currency,
									  der_notional_incr_decr, price, price_currency, net_amount, venue, branch_membership_country, upfront_payment, upfront_payment_currency, complex_trade_component_id,
									  instrument_id_code, instrument_name, instrument_classification, notional_currency_1, notional_currency_2, price_multiplier, underlying_instrument_code,
									  underlying_index_name, underlying_index_term, option_type, strike_price, strike_price_currency, option_exercise_style, maturity_date, expiry_date, delivery_type,
									  firm_invest_decision, decision_maker_country, firm_execution, supervising_execution_country, waiver_indicator, short_selling_indicator, otc_post_trade_indicator,
									  commodity_derivative_indicator, securities_financing_transaction_indicator, report_type, create_date_from, create_date_to, submission_status, submission_date,
									  confirmation_date, process_id, error_validation_message, file_export_name, hash_of_concatenated_values, progressive_number)
			SELECT * FROM #temp_source_mifid
			
			
		/*******************************************Error Validation Start*******************************************/
			BEGIN
			IF OBJECT_ID('tempdb..#temp_messages_mifid') IS NOT NULL
				DROP TABLE #temp_messages_mifid

			CREATE TABLE #temp_messages_mifid (
				[source_deal_header_id]	 INT,
				[column] VARCHAR(100) COLLATE DATABASE_DEFAULT,
				[messages] VARCHAR(5000) COLLATE DATABASE_DEFAULT
			)

			INSERT INTO #temp_messages_mifid ([source_deal_header_id], [column], [messages])
			SELECT DISTINCT source_deal_header_id, 'trans_ref_no','Transaction Reference Number exceeds the character limit of 52'
			FROM source_mifid 
			WHERE NULLIF(trans_ref_no, '') IS NOT NULL
				AND LEN(trans_ref_no) > 52
				AND process_id = @process_id

			INSERT INTO #temp_messages_mifid ([source_deal_header_id], [column], [messages])
			SELECT DISTINCT source_deal_header_id, 'trading_trans_id','Trading Venue Transaction ID Code exceeds the character limit of 52'
			FROM source_mifid 
			WHERE NULLIF(trading_trans_id, '') IS NOT NULL
				AND LEN(trading_trans_id) > 52
				AND process_id = @process_id
				AND ISNULL(NULLIF(@action_type_mifid, ''), 'NEWT') = 'NEWT'

			INSERT INTO #temp_messages_mifid ([source_deal_header_id], [column], [messages])
			SELECT DISTINCT source_deal_header_id, 'exec_entity_id','Executing Entity Identification Code cannot be blank'
			FROM source_mifid 
			WHERE NULLIF(exec_entity_id, '') IS NULL
				AND process_id = @process_id
			
			INSERT INTO #temp_messages_mifid ([source_deal_header_id], [column], [messages])
			SELECT DISTINCT source_deal_header_id, 'instrument_id_code','Instrument ID Code cannot be blank'
			FROM source_mifid 
			WHERE NULLIF(instrument_id_code, '') IS NULL
				AND (venue IN ('XOFF', 'SI') OR 
					 venue IN (
					SELECT clm4_value 
					FROM generic_mapping_values gmv 
						INNER JOIN generic_mapping_header gmh 
					ON gmv.mapping_table_id = gmh.mapping_table_id 
					WHERE gmh.mapping_name = 'Venue of Execution' 
						AND clm14_value = 'Y'
					)
				)
				AND process_id = @process_id
				AND ISNULL(NULLIF(@action_type_mifid, ''), 'NEWT') = 'NEWT'
			
			INSERT INTO #temp_messages_mifid ([source_deal_header_id], [column], [messages])
			SELECT DISTINCT source_deal_header_id, 'instrument_name','Instrument Name cannot be blank'
			FROM source_mifid 
			WHERE NULLIF(instrument_name, '') IS NULL
				AND (venue IN ('XXXX') OR 
					 venue IN (
					SELECT clm4_value 
					FROM generic_mapping_values gmv 
						INNER JOIN generic_mapping_header gmh 
					ON gmv.mapping_table_id = gmh.mapping_table_id 
					WHERE gmh.mapping_name = 'Venue of Execution' 
						AND clm14_value = 'N'
					)
				)
				AND process_id = @process_id
				AND ISNULL(NULLIF(@action_type_mifid, ''), 'NEWT') = 'NEWT'

			INSERT INTO #temp_messages_mifid ([source_deal_header_id], [column], [messages])
			SELECT DISTINCT source_deal_header_id, 'instrument_classification','Instrument Classification cannot be blank'
			FROM source_mifid 
			WHERE NULLIF(instrument_classification, '') IS NULL
				AND (venue IN ('XXXX') OR 
					 venue IN (
					SELECT clm4_value 
					FROM generic_mapping_values gmv 
						INNER JOIN generic_mapping_header gmh 
					ON gmv.mapping_table_id = gmh.mapping_table_id 
					WHERE gmh.mapping_name = 'Venue of Execution' 
						AND clm14_value = 'N'
					)
				)
				AND process_id = @process_id
				AND ISNULL(NULLIF(@action_type_mifid, ''), 'NEWT') = 'NEWT'
			
			INSERT INTO #temp_messages_mifid ([source_deal_header_id], [column], [messages])
			SELECT DISTINCT source_deal_header_id, 'underlying_instrument_code','Underlying Instrument Code cannot be blank'
			FROM source_mifid 
			WHERE NULLIF(underlying_instrument_code, '') IS NULL
				AND (venue IN ('XXXX') OR 
					 venue IN (
					SELECT clm4_value 
					FROM generic_mapping_values gmv 
						INNER JOIN generic_mapping_header gmh 
					ON gmv.mapping_table_id = gmh.mapping_table_id 
					WHERE gmh.mapping_name = 'Venue of Execution' 
						AND clm14_value = 'N'
					)
				)
				AND process_id = @process_id
				AND ISNULL(NULLIF(@action_type_mifid, ''), 'NEWT') = 'NEWT'
				
			INSERT INTO #temp_messages_mifid ([source_deal_header_id], [column], [messages])
			SELECT DISTINCT source_deal_header_id, 'underlying_instrument_code','Underlying Instrument Code exceeds the character limit of 12'
			FROM source_mifid 
			WHERE NULLIF(underlying_instrument_code, '') IS NOT NULL
				AND LEN(underlying_instrument_code) <> 12
				AND process_id = @process_id
				AND ISNULL(NULLIF(@action_type_mifid, ''), 'NEWT') = 'NEWT'

			INSERT INTO #temp_messages_mifid ([source_deal_header_id], [column], [messages])
			SELECT DISTINCT source_deal_header_id, 'submitting_entity_id_code','Submitting Entity Identification Code cannot be blank'
			FROM source_mifid 
			WHERE NULLIF(submitting_entity_id_code, '') IS NULL
				AND process_id = @process_id
				
			INSERT INTO #temp_messages_mifid ([source_deal_header_id], [column], [messages])
			SELECT DISTINCT source_deal_header_id, 'Buyer ID','Buyer ID cannot be blank'
			FROM source_mifid 
			WHERE NULLIF(buyer_id, '') IS NULL
				AND process_id = @process_id
				AND ISNULL(NULLIF(@action_type_mifid, ''), 'NEWT') = 'NEWT'
				
			INSERT INTO #temp_messages_mifid ([source_deal_header_id], [column], [messages])
			SELECT DISTINCT source_deal_header_id, 'Buyer Decision Maker Code','Buyer Decision Maker Code cannot be blank'
			FROM source_mifid 
			WHERE NULLIF(buyer_decision_maker_code, '') IS NULL
				AND process_id = @process_id
				AND ISNULL(NULLIF(@action_type_mifid, ''), 'NEWT') = 'NEWT'

			INSERT INTO #temp_messages_mifid ([source_deal_header_id], [column], [messages])
			SELECT DISTINCT source_deal_header_id, 'Seller ID','Seller ID cannot be blank'
			FROM source_mifid 
			WHERE NULLIF(seller_id, '') IS NULL
				AND process_id = @process_id
				AND ISNULL(NULLIF(@action_type_mifid, ''), 'NEWT') = 'NEWT'

			INSERT INTO #temp_messages_mifid ([source_deal_header_id], [column], [messages])
			SELECT DISTINCT source_deal_header_id, 'Seller Decision Maker Code','Seller Decision Maker Code cannot be blank'
			FROM source_mifid 
			WHERE NULLIF(seller_decision_maker_code, '') IS NULL
				AND process_id = @process_id
				AND ISNULL(NULLIF(@action_type_mifid, ''), 'NEWT') = 'NEWT'
			
			INSERT INTO #temp_messages_mifid ([source_deal_header_id], [column], [messages])
			SELECT DISTINCT source_deal_header_id, 'trading_date_time','For New Transaction, Trading Date Time cannot be blank'
			FROM source_mifid 
			WHERE NULLIF(trading_date_time, '') IS NULL
				AND process_id = @process_id
				AND ISNULL(NULLIF(@action_type_mifid, ''), 'NEWT') = 'NEWT'
				
			INSERT INTO #temp_messages_mifid ([source_deal_header_id], [column], [messages])
			SELECT DISTINCT source_deal_header_id, 'trading_date_time','Invalid Date Format for Trading Date Time'
			FROM source_mifid 
			WHERE NULLIF(trading_date_time, '') IS NOT NULL
				AND trading_date_time NOT LIKE '____-__-__T__:__:__Z'
				AND process_id = @process_id
				AND ISNULL(NULLIF(@action_type_mifid, ''), 'NEWT') = 'NEWT'

			INSERT INTO #temp_messages_mifid ([source_deal_header_id], [column], [messages])
			SELECT DISTINCT source_deal_header_id, 'trading_capacity','Trading Capacity cannot be blank'
			FROM source_mifid 
			WHERE NULLIF(trading_capacity, '') IS NULL
				AND process_id = @process_id
				AND ISNULL(NULLIF(@action_type_mifid, ''), 'NEWT') = 'NEWT'

			INSERT INTO #temp_messages_mifid ([source_deal_header_id], [column], [messages])
			SELECT DISTINCT source_deal_header_id, 'quantity','For New Transaction, Quantity cannot be blank'
			FROM source_mifid 
			WHERE quantity IS NULL
				AND process_id = @process_id
				AND ISNULL(NULLIF(@action_type_mifid, ''), 'NEWT') = 'NEWT'
			
			/*********** Numeric Data Range Validation*******/
			DECLARE @quantity NUMERIC(38, 20)
			DECLARE @get_quantity CURSOR
			SET @get_quantity = CURSOR FOR
			SELECT quantity
			FROM source_mifid 
			WHERE process_id = @process_id
			OPEN @get_quantity
			FETCH NEXT
			FROM @get_quantity INTO @quantity
			WHILE @@FETCH_STATUS = 0
			BEGIN
				INSERT INTO #temp_messages_mifid ([source_deal_header_id], [column], [messages])
				SELECT DISTINCT source_deal_header_id, 'quantity','Quantity exceeds maximum of 18 digits or maximum of 17 fraction digits'
				FROM dbo.FNASplitAndTranspose(@quantity, '.') a
				INNER JOIN source_mifid sm
				ON sm.process_id = @process_id
					AND sm.quantity = @quantity
				WHERE ((LEN(clm1) + LEN(REPLACE(RTRIM(REPLACE(clm2,'0',' ')),' ','0'))) > 18
					OR LEN(REPLACE(RTRIM(REPLACE(clm2,'0',' ')),' ','0')) > 17)
					AND ISNULL(NULLIF(@action_type_mifid, ''), 'NEWT') = 'NEWT'
				FETCH NEXT
				FROM @get_quantity INTO @quantity
			END
			CLOSE @get_quantity
			DEALLOCATE @get_quantity
			/*********** Numeric Data Range Validation*******/

			/*********** Numeric Data Range Validation*******/
			DECLARE @price NUMERIC(38, 20)
			DECLARE @get_price CURSOR
			SET @get_price = CURSOR FOR
			SELECT price
			FROM source_mifid 
			WHERE process_id = @process_id
			OPEN @get_price
			FETCH NEXT
			FROM @get_price INTO @price
			WHILE @@FETCH_STATUS = 0
			BEGIN
				INSERT INTO #temp_messages_mifid ([source_deal_header_id], [column], [messages])
				SELECT DISTINCT source_deal_header_id, 'price','Price exceeds maximum of 18 digits or maximum of 17 fraction digits'
				FROM dbo.FNASplitAndTranspose(@price, '.') a
				INNER JOIN source_mifid sm
				ON sm.process_id = @process_id
					AND sm.price = @price
				WHERE ((LEN(clm1) + LEN(REPLACE(RTRIM(REPLACE(clm2,'0',' ')),' ','0'))) > 18
					OR LEN(REPLACE(RTRIM(REPLACE(clm2,'0',' ')),' ','0')) > 17)
					AND ISNULL(NULLIF(@action_type_mifid, ''), 'NEWT') = 'NEWT'
				FETCH NEXT
				FROM @get_price INTO @price
			END
			CLOSE @get_price
			DEALLOCATE @get_price
			/*********** Numeric Data Range Validation*******/

			INSERT INTO #temp_messages_mifid ([source_deal_header_id], [column], [messages])
			SELECT DISTINCT source_deal_header_id, 'price','For New Transaction, Price cannot be blank'
			FROM source_mifid 
			WHERE price IS NULL
				AND process_id = @process_id
				AND ISNULL(NULLIF(@action_type_mifid, ''), 'NEWT') = 'NEWT'
			
			/*********** Numeric Data Range Validation*******/
			DECLARE @strike_price NUMERIC(38, 20)
			DECLARE @get_strike_price CURSOR
			SET @get_strike_price = CURSOR FOR
			SELECT strike_price
			FROM source_mifid 
			WHERE process_id = @process_id
			OPEN @get_strike_price
			FETCH NEXT
			FROM @get_strike_price INTO @strike_price
			WHILE @@FETCH_STATUS = 0
			BEGIN
				INSERT INTO #temp_messages_mifid ([source_deal_header_id], [column], [messages])
				SELECT DISTINCT source_deal_header_id, 'strike_price','Strike Price exceeds maximum of 18 digits or maximum of 13 fraction digits'
				FROM dbo.FNASplitAndTranspose(@strike_price, '.') a
				INNER JOIN source_mifid sm
				ON sm.process_id = @process_id
					AND sm.strike_price = @strike_price
				WHERE ((LEN(clm1) + LEN(REPLACE(RTRIM(REPLACE(clm2,'0',' ')),' ','0'))) > 18
					OR LEN(REPLACE(RTRIM(REPLACE(clm2,'0',' ')),' ','0')) > 13)
					AND ISNULL(NULLIF(@action_type_mifid, ''), 'NEWT') = 'NEWT'
				FETCH NEXT
				FROM @get_strike_price INTO @strike_price
			END
			CLOSE @get_strike_price
			DEALLOCATE @get_strike_price
			/*********** Numeric Data Range Validation*******/

			INSERT INTO #temp_messages_mifid ([source_deal_header_id], [column], [messages])
			SELECT DISTINCT source_deal_header_id, 'strike_price','Strike Price cannot be blank'
			FROM source_mifid 
			WHERE strike_price IS NULL
				AND (instrument_classification LIKE 'O_____' OR instrument_classification LIKE 'H_____' OR --Options
					 instrument_classification LIKE 'RW____' OR instrument_classification LIKE 'RF____') -- Warrants
				AND process_id = @process_id
				AND ISNULL(NULLIF(@action_type_mifid, ''), 'NEWT') = 'NEWT'

			INSERT INTO #temp_messages_mifid ([source_deal_header_id], [column], [messages])
			SELECT DISTINCT source_deal_header_id, 'strike_price_currency','Strike Price Currency does not meet the alphanumeric character limit of 3'
			FROM source_mifid 
			WHERE strike_price_currency IS NOT NULL
				AND LEN(strike_price_currency) <> 3 
				AND process_id = @process_id
				AND ISNULL(NULLIF(@action_type_mifid, ''), 'NEWT') = 'NEWT'
		
			INSERT INTO #temp_messages_mifid ([source_deal_header_id], [column], [messages])
			SELECT DISTINCT source_deal_header_id, 'strike_price_currency','Invalid Strike Currency Code'
			FROM source_mifid 
			WHERE strike_price_currency IS NOT NULL
				AND strike_price_currency NOT IN ('BGN', 'CHF', 'CZK', 'DKK', 'EUR', 'EUX', 'GBX', 'GBP', 'HRK', 'HUF', 'ISK', 'NOK', 'PCT', 'PLN', 'RON', 'SEK', 'USD', 'OTH')
				AND process_id = @process_id
				AND ISNULL(NULLIF(@action_type_mifid, ''), 'NEWT') = 'NEWT'

			INSERT INTO #temp_messages_mifid ([source_deal_header_id], [column], [messages])
			SELECT DISTINCT source_deal_header_id, 'quantity_currency','Quantity Currency does not meet the alphanumeric character limit of 3'
			FROM source_mifid 
			WHERE quantity_currency IS NOT NULL
				AND LEN(quantity_currency) <> 3 
				AND process_id = @process_id
				AND ISNULL(NULLIF(@action_type_mifid, ''), 'NEWT') = 'NEWT'
			
			INSERT INTO #temp_messages_mifid ([source_deal_header_id], [column], [messages])
			SELECT DISTINCT source_deal_header_id, 'quantity_currency','Invalid Quantity Currency Code'
			FROM source_mifid 
			WHERE quantity_currency IS NOT NULL
				AND quantity_currency NOT IN ('BGN', 'CHF', 'CZK', 'DKK', 'EUR', 'EUX', 'GBX', 'GBP', 'HRK', 'HUF', 'ISK', 'NOK', 'PCT', 'PLN', 'RON', 'SEK', 'USD', 'OTH')
				AND process_id = @process_id
				AND ISNULL(NULLIF(@action_type_mifid, ''), 'NEWT') = 'NEWT'

			INSERT INTO #temp_messages_mifid ([source_deal_header_id], [column], [messages])
			SELECT DISTINCT source_deal_header_id, 'der_notional_incr_decr','Invalid Derivative Notional'
			FROM source_mifid 
			WHERE NULLIF(der_notional_incr_decr, '') IS NOT	NULL
				AND der_notional_incr_decr NOT IN ('INCR', 'DECR')
				AND process_id = @process_id
				AND ISNULL(NULLIF(@action_type_mifid, ''), 'NEWT') = 'NEWT'
			
			INSERT INTO #temp_messages_mifid ([source_deal_header_id], [column], [messages])
			SELECT DISTINCT source_deal_header_id, 'buyer_decision_maker_code','Buyer Decision Maker Code exceeds the character limit of 20'
			FROM source_mifid 
			WHERE NULLIF(buyer_decision_maker_code, '') IS NOT	NULL
				AND LEN(buyer_decision_maker_code) > 20
				AND process_id = @process_id
				AND ISNULL(NULLIF(@action_type_mifid, ''), 'NEWT') = 'NEWT'

			INSERT INTO #temp_messages_mifid ([source_deal_header_id], [column], [messages])
			SELECT DISTINCT source_deal_header_id, 'seller_decision_maker_code','Seller Decision Maker Code exceeds the character limit of 20'
			FROM source_mifid 
			WHERE NULLIF(seller_decision_maker_code, '') IS NOT	NULL
				AND LEN(seller_decision_maker_code) > 20
				AND process_id = @process_id
				AND ISNULL(NULLIF(@action_type_mifid, ''), 'NEWT') = 'NEWT'

			INSERT INTO #temp_messages_mifid ([source_deal_header_id], [column], [messages])
			SELECT DISTINCT source_deal_header_id, 'price_currency','Invalid Price Currency Code'
			FROM source_mifid 
			WHERE price_currency IS NOT NULL
				AND price_currency NOT IN ('BGN', 'CHF', 'CZK', 'DKK', 'EUR', 'EUX', 'GBX', 'GBP', 'HRK', 'HUF', 'ISK', 'NOK', 'PCT', 'PLN', 'RON', 'SEK', 'USD', 'OTH')
				AND process_id = @process_id
				AND ISNULL(NULLIF(@action_type_mifid, ''), 'NEWT') = 'NEWT'
			
			INSERT INTO #temp_messages_mifid ([source_deal_header_id], [column], [messages])
			SELECT DISTINCT source_deal_header_id, 'price_currency','Price Currency does not meet the alphanumeric character limit of 3'
			FROM source_mifid 
			WHERE price_currency IS NOT NULL
				AND LEN(price_currency) <> 3 
				AND process_id = @process_id
				AND ISNULL(NULLIF(@action_type_mifid, ''), 'NEWT') = 'NEWT'

			INSERT INTO #temp_messages_mifid ([source_deal_header_id], [column], [messages])
			SELECT DISTINCT source_deal_header_id, 'der_notional_incr_decr','Invalid Derivative Notional'
			FROM source_mifid 
			WHERE NULLIF(der_notional_incr_decr, '') IS NOT	NULL
				AND der_notional_incr_decr NOT IN ('INCR', 'DECR')
				AND process_id = @process_id
				AND ISNULL(NULLIF(@action_type_mifid, ''), 'NEWT') = 'NEWT'

			INSERT INTO #temp_messages_mifid ([source_deal_header_id], [column], [messages])
			SELECT DISTINCT source_deal_header_id, 'venue','For New Transaction, Venue cannot be blank'
			FROM source_mifid 
			WHERE NULLIF(venue, '') IS NULL
				AND process_id = @process_id
				AND ISNULL(NULLIF(@action_type_mifid, ''), 'NEWT') = 'NEWT'
			
			INSERT INTO #temp_messages_mifid ([source_deal_header_id], [column], [messages])
			SELECT DISTINCT source_deal_header_id, 'branch_membership_country','Country of the Branch Membership does not meet the alphanumeric character limit of 2'
			FROM source_mifid 
			WHERE NULLIF(branch_membership_country, '') IS NOT NULL
				AND LEN(branch_membership_country) <> 2
				AND process_id = @process_id
				AND ISNULL(NULLIF(@action_type_mifid, ''), 'NEWT') = 'NEWT'
				
			INSERT INTO #temp_messages_mifid ([source_deal_header_id], [column], [messages])
			SELECT DISTINCT source_deal_header_id, 'branch_membership_country','Country of the Branch Membership cannot be blank'
			FROM source_mifid 
			WHERE NULLIF(branch_membership_country, '') IS NULL
				AND venue IN (SELECT clm4_value 
								  FROM generic_mapping_values gmv 
								  INNER JOIN generic_mapping_header gmh 
									ON gmh.mapping_table_id = gmv.mapping_table_id 
										AND gmh.mapping_name = 'Venue of Execution'
								  WHERE clm14_value = 'Y'
								  )
				AND process_id = @process_id
				AND ISNULL(NULLIF(@action_type_mifid, ''), 'NEWT') = 'NEWT'
			
			INSERT INTO #temp_messages_mifid ([source_deal_header_id], [column], [messages])
			SELECT DISTINCT source_deal_header_id, 'upfront_payment','Upfront Payment cannot be blank'
			FROM source_mifid 
			WHERE upfront_payment IS NULL
				AND ((NULLIF(der_notional_incr_decr, '') IS NOT NULL) OR instrument_classification LIKE 'SC____')
				AND process_id = @process_id
				AND ISNULL(NULLIF(@action_type_mifid, ''), 'NEWT') = 'NEWT'
			
			/*********** Numeric Data Range Validation*******/
			DECLARE @upfront_payment NUMERIC(38, 20)
			DECLARE @get_upfront_payment CURSOR
			SET @get_upfront_payment = CURSOR FOR
			SELECT upfront_payment
			FROM source_mifid 
			WHERE process_id = @process_id
			OPEN @get_upfront_payment
			FETCH NEXT
			FROM @get_upfront_payment INTO @upfront_payment
			WHILE @@FETCH_STATUS = 0
			BEGIN
				INSERT INTO #temp_messages_mifid ([source_deal_header_id], [column], [messages])
				SELECT DISTINCT source_deal_header_id, 'upfront_payment', 'Upfront Payment exceeds maximum of 18 digits or maximum of 5 fraction digits'
				FROM dbo.FNASplitAndTranspose(@upfront_payment, '.') a
				INNER JOIN source_mifid sm
				ON sm.process_id = @process_id
					AND sm.upfront_payment = @upfront_payment
				WHERE ((LEN(clm1) + LEN(REPLACE(RTRIM(REPLACE(clm2,'0',' ')),' ','0'))) > 18
					OR LEN(REPLACE(RTRIM(REPLACE(clm2,'0',' ')),' ','0')) > 5)
					AND ISNULL(NULLIF(@action_type_mifid, ''), 'NEWT') = 'NEWT'
				FETCH NEXT
				FROM @get_upfront_payment INTO @upfront_payment
			END
			CLOSE @get_upfront_payment
			DEALLOCATE @get_upfront_payment
						
			/*********** Numeric Data Range Validation*******/
			
			INSERT INTO #temp_messages_mifid ([source_deal_header_id], [column], [messages])
			SELECT DISTINCT source_deal_header_id, 'upfront_payment_currency','Upfront Payment Currency does not meet the alphanumeric character limit of 3'
			FROM source_mifid 
			WHERE NULLIF(upfront_payment_currency, '') IS NOT NULL
				AND LEN(upfront_payment_currency) <> 3
				AND process_id = @process_id
				AND ISNULL(NULLIF(@action_type_mifid, ''), 'NEWT') = 'NEWT'
			
			INSERT INTO #temp_messages_mifid ([source_deal_header_id], [column], [messages])
			SELECT DISTINCT source_deal_header_id, 'complex_trade_component_id','Complex Trade Component ID exceeds the alphanumeric character limit of 35'
			FROM source_mifid 
			WHERE NULLIF(complex_trade_component_id, '') IS NOT NULL
				AND LEN(complex_trade_component_id) > 35
				AND process_id = @process_id
				AND ISNULL(NULLIF(@action_type_mifid, ''), 'NEWT') = 'NEWT'

			INSERT INTO #temp_messages_mifid ([source_deal_header_id], [column], [messages])
			SELECT DISTINCT source_deal_header_id, 'instrument_name','Instrument Full Name exceeds the alphanumeric character limit of 350'
			FROM source_mifid 
			WHERE NULLIF(instrument_name, '') IS NOT NULL
				AND LEN(instrument_name) > 350
				AND process_id = @process_id
				AND ISNULL(NULLIF(@action_type_mifid, ''), 'NEWT') = 'NEWT'
			
			INSERT INTO #temp_messages_mifid ([source_deal_header_id], [column], [messages])
			SELECT DISTINCT source_deal_header_id, 'instrument_name','Instrument Full Name cannot be blank'
			FROM source_mifid 
			WHERE NULLIF(instrument_name, '') IS NULL
				AND venue IN (SELECT clm4_value 
							  FROM generic_mapping_values gmv 
								INNER JOIN generic_mapping_header gmh 
									ON gmh.mapping_table_id = gmv.mapping_table_id 
										AND gmh.mapping_name = 'Venue of Execution'
								  WHERE clm14_value = 'N' OR clm4_value = 'XXXX'
								  )
				AND process_id = @process_id
				AND ISNULL(NULLIF(@action_type_mifid, ''), 'NEWT') = 'NEWT'
			
			INSERT INTO #temp_messages_mifid ([source_deal_header_id], [column], [messages])
			SELECT DISTINCT source_deal_header_id, 'instrument_name','Invalid Instrument Full Name'
			FROM source_mifid 
			WHERE NULLIF(instrument_name, '') IS NOT NULL
				AND instrument_name LIKE '%[^A-Z1-9%?+#/ ]%'
				AND process_id = @process_id
				AND ISNULL(NULLIF(@action_type_mifid, ''), 'NEWT') = 'NEWT'

			INSERT INTO #temp_messages_mifid ([source_deal_header_id], [column], [messages])
			SELECT DISTINCT source_deal_header_id, 'instrument_classification','Instrument Classification does not meet the character limit of 6'
			FROM source_mifid 
			WHERE NULLIF(instrument_classification, '') IS NOT NULL
				AND LEN(instrument_classification) <> 6
				AND process_id = @process_id
				AND ISNULL(NULLIF(@action_type_mifid, ''), 'NEWT') = 'NEWT'
			
			INSERT INTO #temp_messages_mifid ([source_deal_header_id], [column], [messages])
			SELECT DISTINCT source_deal_header_id, 'instrument_classification','Instrument Classification is not consistent with Option Exercise Style'
			FROM source_mifid 
			WHERE NULLIF(instrument_classification, '') IS NOT NULL
				AND LEN(instrument_classification) = 6
				AND ((option_exercise_style = 'EURO' AND (instrument_classification NOT LIKE 'O_E___' AND instrument_classification NOT LIKE 'H__A__' AND instrument_classification NOT LIKE 'H__D__' AND instrument_classification NOT LIKE 'H__G__')) OR 
					 (option_exercise_style = 'AMER' AND (instrument_classification NOT LIKE 'O_A___' AND instrument_classification NOT LIKE 'H__B__' AND instrument_classification NOT LIKE 'H__E__' AND instrument_classification NOT LIKE 'H__H__')) OR
					 (option_exercise_style = 'BERM' AND (instrument_classification NOT LIKE 'O_B___' AND instrument_classification NOT LIKE 'H__C__' AND instrument_classification NOT LIKE 'H__F__' AND instrument_classification NOT LIKE 'H__I__')) 
					)
				AND process_id = @process_id
				AND ISNULL(NULLIF(@action_type_mifid, ''), 'NEWT') = 'NEWT'
			
			INSERT INTO #temp_messages_mifid ([source_deal_header_id], [column], [messages])
			SELECT DISTINCT source_deal_header_id, 'notional_currency_1','Notional Currency1 does not meet the alphanumeric character limit of 3'
			FROM source_mifid 
			WHERE NULLIF(notional_currency_1, '') IS NOT NULL
				AND LEN(notional_currency_1) <> 3
				AND process_id = @process_id
				AND ISNULL(NULLIF(@action_type_mifid, ''), 'NEWT') = 'NEWT'

			INSERT INTO #temp_messages_mifid ([source_deal_header_id], [column], [messages])
			SELECT DISTINCT sm.source_deal_header_id, 'notional_currency_1','Notional Currency1 cannot be blank'
			FROM source_mifid sm			
			WHERE NULLIF(notional_currency_1, '') IS NULL
				AND (instrument_classification LIKE 'O__C__' OR instrument_classification LIKE 'O__N__' OR --Options
					 instrument_classification LIKE 'FFC___' OR instrument_classification LIKE 'FFN___' OR --Futures
					 instrument_classification LIKE 'SF____' OR instrument_classification LIKE 'SR____' OR --SWAPs
					 instrument_classification LIKE 'HR____' OR instrument_classification LIKE 'HF____' OR --Complex Options
					 instrument_classification LIKE 'JR__S_' OR instrument_classification LIKE 'JR__F_' OR instrument_classification LIKE 'JF____' --Forwards
					 )
				AND process_id = @process_id
				AND ISNULL(NULLIF(@action_type_mifid, ''), 'NEWT') = 'NEWT'
			
			INSERT INTO #temp_messages_mifid ([source_deal_header_id], [column], [messages])
			SELECT DISTINCT source_deal_header_id, 'price_multiplier','Price Multiplier cannot be blank'
			FROM source_mifid 
			WHERE price_multiplier IS NULL
				AND venue IN (SELECT clm4_value 
							  FROM generic_mapping_values gmv 
							  INNER JOIN generic_mapping_header gmh 
								  ON gmh.mapping_table_id = gmv.mapping_table_id 
							  		AND gmh.mapping_name = 'Venue of Execution'
							  WHERE clm14_value = 'N' OR clm4_value = 'XXXX'
							  )
				AND process_id = @process_id
				AND ISNULL(NULLIF(@action_type_mifid, ''), 'NEWT') = 'NEWT'
			
			INSERT INTO #temp_messages_mifid ([source_deal_header_id], [column], [messages])
			SELECT DISTINCT source_deal_header_id, 'price_multiplier','Price Multiplier cannot be 0 or less than 0'
			FROM source_mifid 
			WHERE price_multiplier IS NOT NULL
				AND price_multiplier <= 0
				AND process_id = @process_id
				AND ISNULL(NULLIF(@action_type_mifid, ''), 'NEWT') = 'NEWT'
			
			/*********** Numeric Data Range Validation*******/
			DECLARE @price_multiplier NUMERIC(38, 20)
			DECLARE @get_price_multiplier CURSOR
			SET @get_price_multiplier = CURSOR FOR
			SELECT price_multiplier
			FROM source_mifid 
			WHERE process_id = @process_id
			OPEN @get_price_multiplier
			FETCH NEXT
			FROM @get_price_multiplier INTO @price_multiplier
			WHILE @@FETCH_STATUS = 0
			BEGIN
				INSERT INTO #temp_messages_mifid ([source_deal_header_id], [column], [messages])
				SELECT DISTINCT source_deal_header_id, 'price_multiplier','Price Multiplier exceeds maximum of 18 digits or maximum of 17 fraction digits'
				FROM dbo.FNASplitAndTranspose(@price_multiplier, '.') a
				INNER JOIN source_mifid sm
				ON sm.process_id = @process_id
					AND sm.price_multiplier = @price_multiplier
				WHERE ((LEN(clm1) + LEN(REPLACE(RTRIM(REPLACE(clm2,'0',' ')),' ','0'))) > 18
					OR LEN(REPLACE(RTRIM(REPLACE(clm2,'0',' ')),' ','0')) > 17)
					AND ISNULL(NULLIF(@action_type_mifid, ''), 'NEWT') = 'NEWT'
				FETCH NEXT
				FROM @get_price_multiplier INTO @price_multiplier
			END
			CLOSE @get_price_multiplier
			DEALLOCATE @get_price_multiplier
			/*********** Numeric Data Range Validation*******/
			
			INSERT INTO #temp_messages_mifid ([source_deal_header_id], [column], [messages])
			SELECT DISTINCT source_deal_header_id, 'option_type','Option Type cannot be blank'
			FROM source_mifid 
			WHERE NULLIF(option_type, '') IS NULL
				AND (instrument_classification LIKE 'O_____' OR instrument_classification LIKE 'H_____' OR --Option
					 instrument_classification LIKE 'RW____' OR instrument_classification LIKE 'RF____' --Warrants
					 )
				AND process_id = @process_id
				AND ISNULL(NULLIF(@action_type_mifid, ''), 'NEWT') = 'NEWT'
			
			INSERT INTO #temp_messages_mifid ([source_deal_header_id], [column], [messages])
			SELECT DISTINCT source_deal_header_id, 'option_type','Invalid Option Type'
			FROM source_mifid 
			WHERE NULLIF(option_type, '') IS NOT NULL
				AND (option_type NOT IN ('PUTO','CALL','OTHR'))
				AND process_id = @process_id
				AND ISNULL(NULLIF(@action_type_mifid, ''), 'NEWT') = 'NEWT'

			INSERT INTO #temp_messages_mifid ([source_deal_header_id], [column], [messages])
			SELECT DISTINCT sm.source_deal_header_id, 'option_exercise_style','Option Exercise Style cannot be blank'
			FROM source_mifid sm
			WHERE NULLIF(option_exercise_style, '') IS NULL
				AND (instrument_classification LIKE 'O_____' OR 
					 instrument_classification LIKE 'H_____' OR 
					 instrument_classification LIKE 'RW____' OR 
					 instrument_classification LIKE 'RF____')
				AND process_id = @process_id
				AND ISNULL(NULLIF(@action_type_mifid, ''), 'NEWT') = 'NEWT'
			
			INSERT INTO #temp_messages_mifid ([source_deal_header_id], [column], [messages])
			SELECT DISTINCT sm.source_deal_header_id, 'option_exercise_style','Invalid Option Exercise Style'
			FROM source_mifid sm
			WHERE NULLIF(option_exercise_style, '') IS NOT NULL
				AND option_exercise_style NOT IN ('EURO', 'AMER', 'ASIA', 'BERM', 'OTHR')
				AND process_id = @process_id
				AND ISNULL(NULLIF(@action_type_mifid, ''), 'NEWT') = 'NEWT'
			
			--INSERT INTO #temp_messages_mifid ([source_deal_header_id], [column], [messages])
			--SELECT DISTINCT sm.source_deal_header_id, 'maturity_date','Maturity Date cannot be null'
			--FROM source_mifid sm
			--WHERE NULLIF(maturity_date, '') IS NULL
			--	AND instrument_classification LIKE 'D_____'
			--	AND process_id = @process_id
			--	AND ISNULL(NULLIF(@action_type_mifid, ''), 'NEWT') = 'NEWT'

			INSERT INTO #temp_messages_mifid ([source_deal_header_id], [column], [messages])
			SELECT DISTINCT sm.source_deal_header_id, 'maturity_date','Invalid date format for Maturity Date'
			FROM source_mifid sm
			WHERE NULLIF(maturity_date, '') IS NOT NULL
				AND dbo.IsValidDatePattern(maturity_date) = 0
				AND process_id = @process_id
				AND ISNULL(NULLIF(@action_type_mifid, ''), 'NEWT') = 'NEWT'
				
			INSERT INTO #temp_messages_mifid ([source_deal_header_id], [column], [messages])
			SELECT DISTINCT sm.source_deal_header_id, 'maturity_date','Maturity Date should be equal or later than the Trading Date Time'
			FROM source_mifid sm
			WHERE NULLIF(maturity_date, '') IS NOT NULL
				AND CONVERT(VARCHAR(10), maturity_date, 120) < CONVERT(VARCHAR(10), trading_date_time, 120)
				AND process_id = @process_id
				AND ISNULL(NULLIF(@action_type_mifid, ''), 'NEWT') = 'NEWT'
				
			INSERT INTO #temp_messages_mifid ([source_deal_header_id], [column], [messages])
			SELECT DISTINCT sm.source_deal_header_id, 'expiry_date','Expiry Date cannot be blank'
			FROM source_mifid sm
			WHERE NULLIF(expiry_date, '') IS NULL
				AND ( 
					 instrument_classification LIKE 'O_____' OR instrument_classification LIKE 'H_____' OR --Options
					 instrument_classification LIKE 'F_____' OR --Future
					 instrument_classification LIKE 'RWB___' OR instrument_classification LIKE 'RWS___' OR --Warrants
					 instrument_classification LIKE 'RWD___' OR instrument_classification LIKE 'RWI___' --Warrants
					 )
				AND process_id = @process_id
				AND ISNULL(NULLIF(@action_type_mifid, ''), 'NEWT') = 'NEWT'
			
			INSERT INTO #temp_messages_mifid ([source_deal_header_id], [column], [messages])
			SELECT DISTINCT sm.source_deal_header_id, 'expiry_date','Invalid date format for Expiry Date'
			FROM source_mifid sm
			WHERE NULLIF([expiry_date], '') IS NOT NULL
				AND dbo.IsValidDatePattern([expiry_date]) = 0
				AND process_id = @process_id
				AND ISNULL(NULLIF(@action_type_mifid, ''), 'NEWT') = 'NEWT'
			
			INSERT INTO #temp_messages_mifid ([source_deal_header_id], [column], [messages])
			SELECT DISTINCT sm.source_deal_header_id, 'expiry_date','Expiry Date should be equal or later than the Trading Date Time'
			FROM source_mifid sm
			WHERE NULLIF([expiry_date], '') IS NOT NULL
				AND CONVERT(VARCHAR(10), [expiry_date], 120) < CONVERT(VARCHAR(10), trading_date_time, 120)
				AND process_id = @process_id
				AND ISNULL(NULLIF(@action_type_mifid, ''), 'NEWT') = 'NEWT'
			
			INSERT INTO #temp_messages_mifid ([source_deal_header_id], [column], [messages])
			SELECT DISTINCT source_deal_header_id, 'delivery_type','Delivery Type cannot be blank'
			FROM source_mifid sm
			WHERE delivery_type IS NULL
				AND venue IN (SELECT clm4_value 
							  FROM generic_mapping_values gmv 
							  INNER JOIN generic_mapping_header gmh 
							  ON gmh.mapping_table_id = gmv.mapping_table_id 
							  	AND gmh.mapping_name = 'Venue of Execution'
							  WHERE clm14_value = 'N' OR clm4_value = 'XXXX'
							)
				AND process_id = @process_id
				AND ISNULL(NULLIF(@action_type_mifid, ''), 'NEWT') = 'NEWT'
			
			INSERT INTO #temp_messages_mifid ([source_deal_header_id], [column], [messages])
			SELECT DISTINCT source_deal_header_id, 'delivery_type','Invalid Delivery Type'
			FROM source_mifid 
			WHERE delivery_type IS NOT NULL
				AND delivery_type NOT IN ('CASH','OPTL','PHYS')
				AND process_id = @process_id
				AND ISNULL(NULLIF(@action_type_mifid, ''), 'NEWT') = 'NEWT'

			INSERT INTO #temp_messages_mifid ([source_deal_header_id], [column], [messages])
			SELECT DISTINCT source_deal_header_id, 'firm_invest_decision','For New Transaction, Investment Decision within Firm should not be blank'
			FROM source_mifid 
			WHERE firm_invest_decision IS NULL
				AND process_id = @process_id
				AND ISNULL(NULLIF(@action_type_mifid, ''), 'NEWT') = 'NEWT'
			
			INSERT INTO #temp_messages_mifid ([source_deal_header_id], [column], [messages])
			SELECT DISTINCT source_deal_header_id, 'firm_invest_decision','Investment Decision within Firm exceeds character limit of 35'
			FROM source_mifid 
			WHERE firm_invest_decision IS NOT NULL
				AND LEN(firm_invest_decision) > 35
				AND process_id = @process_id
				AND ISNULL(NULLIF(@action_type_mifid, ''), 'NEWT') = 'NEWT'
			
			INSERT INTO #temp_messages_mifid ([source_deal_header_id], [column], [messages])
			SELECT DISTINCT source_deal_header_id, 'firm_execution','For New Transaction, Execution within Firm cannot not be blank'
			FROM source_mifid 
			WHERE firm_execution IS NULL
				AND process_id = @process_id
				AND ISNULL(NULLIF(@action_type_mifid, ''), 'NEWT') = 'NEWT'
			
			INSERT INTO #temp_messages_mifid ([source_deal_header_id], [column], [messages])
			SELECT DISTINCT source_deal_header_id, 'firm_execution','Execution within Firm exceeds character limit of 35'
			FROM source_mifid 
			WHERE firm_execution IS NOT NULL
				AND LEN(firm_execution) > 35
				AND process_id = @process_id
				AND ISNULL(NULLIF(@action_type_mifid, ''), 'NEWT') = 'NEWT'
			
			INSERT INTO #temp_messages_mifid ([source_deal_header_id], [column], [messages])
			SELECT DISTINCT source_deal_header_id, 'short_selling_indicator','Invalid Short Selling Indicator'
			FROM source_mifid 
			WHERE short_selling_indicator IS NOT NULL
				AND short_selling_indicator NOT IN ('SESH','SSEX','SELL','NTAV')
				AND process_id = @process_id
				AND ISNULL(NULLIF(@action_type_mifid, ''), 'NEWT') = 'NEWT'
			
			INSERT INTO #temp_messages_mifid ([source_deal_header_id], [column], [messages])
			SELECT DISTINCT source_deal_header_id, 'otc_post_trade_indicator','Invalid OTC Post Trade Indicator'
			FROM source_mifid 
			WHERE otc_post_trade_indicator IS NOT NULL
				AND otc_post_trade_indicator NOT IN ('BENC','ACTX','NPFT','LRGS','ILQD','SIZE','CANC','AMND','SDIV','RFPT','NLIQ','OILQ','PRIC','ALGO','RPRI','DUPL','TNCP','TPA','XFPH')
				AND process_id = @process_id
				AND ISNULL(NULLIF(@action_type_mifid, ''), 'NEWT') = 'NEWT'

			IF OBJECT_ID('tempdb..#error_messages_mifid') IS NOT NULL
				DROP TABLE #error_messages_mifid

			SELECT a.source_deal_header_id, 
				STUFF((SELECT '| ' + messages
						FROM #temp_messages_mifid b 
						WHERE b.source_deal_header_id = a.source_deal_header_id 
						FOR XML PATH('')), 1, 2, '') messages
			INTO #error_messages_mifid
			FROM #temp_messages_mifid a
			GROUP BY a.source_deal_header_id
			
			UPDATE se
			SET error_validation_message = tm.messages
			FROM source_mifid se
			INNER JOIN #error_messages_mifid tm 
				ON se.source_deal_header_id = tm.source_deal_header_id

			UPDATE se
			SET error_validation_message = NULL
			FROM source_mifid se
			INNER JOIN source_deal_header sdh
				ON sdh.source_deal_header_id = se.source_deal_header_id
			INNER JOIN static_data_value sdv
				ON sdv.value_id = sdh.deal_status
			WHERE process_id = @process_id
				AND sdv.code = 'Reviewed'
					
			/*******************************************Error Validation End*********************************************/
			SET @submit_process_id = @process_id
			END
			COMMIT
			EXEC spa_ErrorHandler 0, 'Regulatory Submission', 'spa_source_emir', 'Success', 'Data saved successfully.', ''
		END TRY
		BEGIN CATCH
			PRINT 'Catch Error:' + ERROR_MESSAGE()
			ROLLBACK	
			EXEC spa_ErrorHandler -1, 'Regulatory Submission', 'spa_source_emir', 'Error', 'Failed to save data.', ''
		END CATCH
	END
	ELSE IF @submission_type = 44704 AND @level_mifid = 'T' -- Logic to insert MiFID Trade report
	BEGIN
		IF OBJECT_ID('tempdb..#tradeweb_log_status') IS NOT NULL
			DROP TABLE #tradeweb_log_status

		SELECT a.SecondaryTradeReportID trade_id, 
			   a.TradeReportRejectReason status, 
			   a.create_ts,
			   RANK() OVER(PARTITION BY a.SecondaryTradeReportID ORDER BY a.create_ts DESC) [rank]
		INTO #tradeweb_log_status
		FROM tradeweb_message_result a
		LEFT JOIN #temp_deals sdh
			ON sdh.deal_id = a.SecondaryTradeReportID
		ORDER BY a.SecondaryTradeReportID
		
		--SELECT DISTINCT c.[rank], *--b.submission_status, c.[status], c.trade_id
		DELETE a
		FROM #temp_deals a
		LEFT JOIN source_mifid_trade b
			ON a.source_deal_header_id = b.source_deal_header_id
				AND a.deal_id = b.deal_id
				AND a.sub_book_id = b.sub_book_id
		LEFT JOIN #tradeweb_log_status c
			ON a.deal_id = c.trade_id
		WHERE ISNULL(c.[rank], 1) = 1
			AND (
					(
							b.submission_status = 39501 
							AND NULLIF(c.[status], '') IS NULL 
							AND b.create_ts > ISNULL(a.update_ts, a.create_ts)
						)
				)

		IF NOT EXISTS (SELECT 1 FROM #temp_deals)
		BEGIN
			EXEC spa_ErrorHandler -1, 'Regulatory Submission', 'spa_source_emir', 'Error', 'No new deals found.', ''
			RETURN
		END

		IF OBJECT_ID('tempdb..#temp_source_mifid_trade') IS NOT NULL
			DROP TABLE #temp_source_mifid_trade
		
		SELECT DISTINCT source_deal_header_id = sdh.source_deal_header_id,
						deal_id = sdh.deal_id,
						sub_book_id = sdh.sub_book_id,
						trading_date_and_time = deal_udf.[Execution Timestamp],
						instrument_identification_code_type = 'ISIN',
						instrument_identification_code = IIF(sco.commodity_id = 'FX' AND sdt.deal_type_id = 'Forward' AND deal_udf.[ISIN] IS NOT NULL, deal_udf.[ISIN], IIF(IIF(scn.counterparty_id = gmv.clm7_value, gmv.clm4_value, 'XOFF') <> 'XXXX', IIF(sdt.deal_type_id = 'SPOT', gmv_spot.clm1_value, gmv1.clm1_value), NULL)),
						price = sdd.fixed_price,
						venue_of_execution = IIF(scn.counterparty_id = gmv.clm7_value, gmv.clm4_value, 'XOFF'),
						price_notation = 'Monetary value (units)',--detail_udf.[Price Notation],
						price_currency = sc.currency_name, 
						notation_quantity_measurement_unit = 'Contracts',--detail_udf.[Quantity Notation],
						quantity_measurement_unit = NULL,
						quantity = sdd.total_volume,
						notional_amount = sdd.fixed_price * (CASE WHEN sco.commodity_id IN ('CER', 'EUA', 'ERU', 'EUAA', 'JETFUEL NWE CIF', 'JETFUEL SINGAPORE') THEN 1000 
																  WHEN sco.commodity_id IN ('Gasoil','ULSD 10ppm CIF Med Cg', 'Biodiesel FAME0 / Gasoil diff', 'Biodiesel RME / Gasoil diff') THEN 100
																  WHEN sco.commodity_id = 'RBOB Gasoline' THEN 42000
																  ELSE sdd.multiplier
																END),
						notional_currency = sc.currency_name,
						[type] = CASE 
									WHEN sco.commodity_id = 'CER' THEN 'CERE' 
									WHEN sco.commodity_id = 'EUA' THEN 'EUAE' 
									WHEN sco.commodity_id = 'ERU' THEN 'ERUE'
									WHEN sco.commodity_id = 'EUAA' THEN 'EUAA'
									ELSE 'OTHR'
								 END,
						publication_date_and_time = NULL,--deal_udf.[Publication Time Stamp],
						venue_of_publication = NULL,--deal_udf.[Venue of Publication],
						transaction_identification_code = CASE WHEN deal_status.code = 'New' THEN CAST(sdh.source_deal_header_id AS VARCHAR(50)) ELSE tmr.TradeID END,--IIF(gmv.clm14_value = 'Y' OR gmv.clm4_value NOT IN ('XXXX', 'XOFF'), deal_udf.[Trading Venue Transaction ID], NULL),
						transaction_to_be_cleared = 'True',
						flags = NULL,--deal_udf.[Flags], 
						supplimentary_deferral_flags = NULL,--deal_udf.[Supplimentary Deferral Flags],
						process_id = @process_id,
						submission_status = 39500,
						create_date_from = @create_date_from, 
						create_date_to = @create_date_to,
						--additional added columns
						trade_report_id = sdh.deal_id,
						trade_version = sdh.deal_id,
						trade_report_type = '0',
						trade_report_reject_reason = NULL,
						trade_report_trans_type = CASE WHEN deal_status.code IN ('New') THEN 0 WHEN deal_status.code = 'Reviewed' THEN 1 ELSE 2 END,
						package_id = NULL,
						trade_number = NULL,
						total_num_trade_reports = NULL,
						security_id = NULL,
						security_id_source = NULL,
						unit_of_measure = su.uom_id,
						contract_multiplier = CASE WHEN sco.commodity_id IN ('CER', 'EUA', 'ERU', 'EUAA', 'JETFUEL NWE CIF', 'JETFUEL SINGAPORE') THEN 1000 
												   WHEN sco.commodity_id IN ('Gasoil','ULSD 10ppm CIF Med Cg','Biodiesel RME / Gasoil diff', 'Biodiesel FAME0 / Gasoil diff') THEN 100
												   WHEN sco.commodity_id = 'RBOB Gasoline' THEN 42000
												   ELSE sdd.multiplier
											  END,
						reporting_party_lei = sub_cpty.LEI,
						submitting_party_lei = sub_cpty.LEI,
						submitting_party_si_status = 'Y',
						asset_class = CASE WHEN sco.commodity_id IN ('RBOB Gasoline', 'Gasoil','ULSD 10ppm CIF Med Cg', 'JETFUEL NWE CIF', 'JETFUEL SINGAPORE','Biodiesel RME / Gasoil diff', 'Biodiesel FAME0 / Gasoil diff', 'Financial Electric Power') THEN 'Commodity Derivative' 
										   WHEN sco.commodity_id = 'FX' THEN 'Currency Derivative' ELSE 'Emission Allowances' END,
						contract_type = CASE WHEN sdt.source_deal_type_name = 'Future' THEN 'Futures' 
											 WHEN sdt.source_deal_type_name = 'Swap' THEN 'Swaps' 
											 WHEN sdt.source_deal_type_name = 'Forward' THEN 'Forwards' 
											 ELSE 'Other' 
										END,
						asset_sub_class = CASE WHEN sco.commodity_id = 'CER' THEN 'Certified Emission Reductions (CER)' 
											   WHEN sco.commodity_id = 'EUA' THEN 'European Union Allowances (EUA)' 
											   WHEN sco.commodity_id = 'ERU' THEN 'Emission Reduction Units (ERU)'
											   WHEN sco.commodity_id = 'EUAA' THEN 'European Union Aviation Allowances (EUAA)'
											   WHEN sco.commodity_id IN ('Gasoil','ULSD 10ppm CIF Med Cg', 'RBOB Gasoline', 'JETFUEL NWE CIF', 'JETFUEL SINGAPORE', 'Biodiesel RME / Gasoil diff', 'Biodiesel FAME0 / Gasoil diff', 'Financial Electric Power') THEN 'Energy commodity futures/forwards'
											   WHEN sco.commodity_id = 'FX' THEN 'DF (Deliverable forward)'
											   ELSE 'Other Emission Allowances'
										  END,
						maturity_date = CASE WHEN deal_status.code = 'Reviewed' OR deal_udf.[Instrument Classification] LIKE 'E_____' OR 
												deal_udf.[Instrument Classification] LIKE 'C_____' OR deal_udf.[Instrument Classification] LIKE 'D_____' OR
												deal_udf.[Instrument Classification] LIKE 'T_____' OR deal_udf.[Instrument Classification] LIKE 'M_____' 
											THEN NULL 
											ELSE CONVERT(DATE, (ISNULL(hg.exp_date, sdd.contract_expiration_date)), 120)
									  END,
						freight_size = NULL,
						specific_route_or_time_charter_average = NULL,
						settlement_location = NULL,
						reference_rate = NULL,
						ir_term_of_contract = NULL,
						parameter = NULL,
						notional_currency2 = NULL,
						series = NULL,
						version = NULL,
						roll_months = NULL,
						next_roll_date = NULL,
						option_type = CASE WHEN sdh.option_type = 'c' THEN 1 WHEN sdh.option_type = 'p' THEN 2 END,
						strike_price = sdd.option_strike_price,
						strike_currency = sc.currency_name,
						exercise_style = CASE 
											WHEN (deal_status.code = 'Reviewed' OR
													deal_udf.[Instrument Classification] LIKE 'F_____' OR deal_udf.[Instrument Classification] LIKE 'S_____' OR 
													deal_udf.[Instrument Classification] LIKE 'E_____' OR deal_udf.[Instrument Classification] LIKE 'C_____' OR
													deal_udf.[Instrument Classification] LIKE 'C_____' OR deal_udf.[Instrument Classification] LIKE 'D_____' OR
													deal_udf.[Instrument Classification] LIKE 'I_____' OR deal_udf.[Instrument Classification] LIKE 'J_____' OR
													deal_udf.[Instrument Classification] LIKE 'L_____' OR deal_udf.[Instrument Classification] LIKE 'T_____') THEN NULL
											ELSE CASE 
													WHEN UPPER(sdh.option_excercise_type) = 'A' THEN 'AMER' 
													WHEN UPPER(sdh.option_excercise_type) = 'E' THEN 'EURO'
													WHEN UPPER(sdh.option_excercise_type) = 'S' THEN 'ASIA'  
												 END
										END,
						delivery_type = deal_udf.[Delivery Type],
						transaction_type = CASE WHEN sdt.source_deal_type_name IN ('Future', 'Futures') THEN 'FUTR' 
												WHEN sdt.source_deal_type_name IN ('Option', 'Options') THEN 'OPTN' 
												WHEN sdt.source_deal_type_name = 'TAPOS' THEN 'TAPO' 
												WHEN sdt.source_deal_type_name IN ('SWAP', 'SWAPS') THEN 'SWAP' 
												WHEN sdt.source_deal_type_name IN ('Mini', 'Minis') THEN 'MINI' 
												WHEN sdt.source_deal_type_name IN ('OTC') THEN 'OTCT' 
												WHEN sdt.source_deal_type_name IN ('Outright') THEN 'ORIT' 
												WHEN sdt.source_deal_type_name IN ('Crack') THEN 'CRCK' 
												WHEN sdt.source_deal_type_name IN ('Differential') THEN 'DIFF' 
												ELSE 'OTHR'
										   END,
						final_price_type = NULL,
						floating_rate_of_leg2 = NULL,
						ir_term_of_contract_leg2 = NULL,
						issue_date = NULL,
						settl_currency = sc.currency_name,
						notional_schedule = NULL,
						valuation_method_trigger = NULL,
						return_or_payout_trigger = NULL,
						debt_seniority = NULL,
						dsb_use_case = NULL,
						no_underlyings = NULL,
						underlying_symbol = NULL,
						underlying_security_type = NULL,
						underlying_issuer = NULL,
						underlying_maturity_date = CASE WHEN deal_status.code = 'Reviewed' OR deal_udf.[Instrument Classification] LIKE 'E_____' OR 
															deal_udf.[Instrument Classification] LIKE 'C_____' OR deal_udf.[Instrument Classification] LIKE 'D_____' OR
															deal_udf.[Instrument Classification] LIKE 'T_____' OR deal_udf.[Instrument Classification] LIKE 'M_____' 
														THEN NULL 
														ELSE CONVERT(DATE, (ISNULL(hg.exp_date, sdd.contract_expiration_date)), 120)
												  END,
						underlying_issue_date = NULL,
						underlying_security_id = 'ISIN',
						underlying_security_id_source = 4,
						underlying_index_name = NULL,
						underlying_issuer_type = NULL,
						underlying_index_term = NULL,
						underlying_further_sub_product = NULL,
						underlying_other_security_type = NULL,
						underlying_other_further_sub_product = NULL,
						PreviouslyReported = CASE WHEN smt.source_deal_header_id IS NOT NULL THEN 'Y' ELSE 'N' END,
						side = sdh.header_buy_sell_flag,
						counterparty_partyid_lei = deal_cpty.LEI,
						regulatory_report_type = 'D',
						deferral_code = '1',
						initial_deferral_code,
						submitting_party_nca ='20',
						apa_entity = CASE WHEN sdv_country.code = 'GB' THEN 'UK' ELSE 'BV' END
		INTO #temp_source_mifid_trade
		FROM #temp_deals sdh
		INNER JOIN #temp_deal_details sdd
			ON sdh.source_deal_header_id = sdd.source_deal_header_id
				AND sdd.leg = 1
		OUTER APPLY(SELECT TOP 1 t.TradeID FROM tradeWeb_message_result t WHERE t.TradeReportType = 'Technical Ack' AND t.SecondaryTradeReportID = sdh.deal_id ORDER BY t.create_ts DESC) tmr
		LEFT JOIN source_uom su ON su.source_uom_id = sdd.position_uom
		LEFT JOIN source_deal_type sdt 
			ON sdh.source_deal_type_id = sdt.source_deal_type_id
		LEFT JOIN #temp_deal_details sdd1
			ON sdh.source_deal_header_id = sdd1.source_deal_header_id
				AND sdd1.leg = 2
		LEFT JOIN #temp_cpty_udf_values deal_cpty
			ON deal_cpty.source_deal_header_id = sdh.source_deal_header_id
		LEFT JOIN source_mifid_trade smt
			ON smt.source_deal_header_id = sdh.source_deal_header_id
		LEFT JOIN #temp_cpty_udf_values sub_cpty
			ON sub_cpty.sub_book_id = sdh.sub_book_id
		LEFT JOIN #temp_deal_udf_values deal_udf
			ON deal_udf.source_deal_header_id = sdh.source_deal_header_id
		LEFT JOIN #temp_deal_detail_udf_values detail_udf
			ON detail_udf.source_deal_header_id = sdh.source_deal_header_id
		LEFT JOIN source_currency sc
			ON sc.source_currency_id = sdd.fixed_price_currency_id
		LEFT JOIN source_commodity sco
			ON sco.source_commodity_id = sdh.commodity_id
		LEFT JOIN source_price_curve_def spcd
			ON spcd.source_curve_def_id = sdd.curve_id
		LEFT JOIN holiday_group hg
			ON hg.hol_group_value_id=spcd.exp_calendar_id
				AND sdh.entire_term_end = hg.hol_date
		LEFT JOIN source_counterparty scn
			ON scn.source_counterparty_id = sdh.counterparty_id
		LEFT JOIN static_data_value sdv_country
			ON sdv_country.value_id = scn.country AND sdv_country.[type_id] = 14000
		LEFT JOIN (
			SELECT gmva.mapping_table_id,
				   gmva.clm1_value,
				   gmva.clm2_value,
				   gmva.clm3_value,
				   gmva.clm4_value,
				   gmva.clm5_value,
				   gmva.clm6_value,
				   gmva.clm7_value,
				   gmva.clm8_value,
				   gmva.clm9_value,
				   gmva.clm10_value,
				   gmva.clm11_value,
				   gmva.clm12_value,
				   gmva.clm13_value,
				   gmva.clm14_value
			FROM generic_mapping_values gmva
			INNER JOIN generic_mapping_header gmh
				ON gmh.mapping_table_id = gmva.mapping_table_id
			WHERE gmh.mapping_name = 'Venue of Execution'
		) gmv ON clm7_value = scn.counterparty_id
		LEFT JOIN (
			SELECT gmvx.mapping_table_id,
				   gmvx.clm1_value,
				   gmvx.clm2_value,
				   gmvx.clm3_value,
				   gmvx.clm4_value,
				   gmvx.clm5_value,
				   gmvx.clm6_value,
				   gmvx.clm7_value,
				   gmvx.clm8_value,
				   gmvx.clm9_value
			FROM generic_mapping_values gmvx
			INNER JOIN generic_mapping_header gmh1
				ON gmh1.mapping_table_id = gmvx.mapping_table_id
			WHERE gmh1.mapping_name = 'Instrument Detail'
		) gmv1 ON gmv1.clm6_value = CAST(sdd.curve_id AS VARCHAR(10))
			AND MONTH(gmv1.clm5_value) = MONTH(sdd.contract_expiration_date)
			AND YEAR(gmv1.clm5_value) = YEAR(sdd.contract_expiration_date)	
			AND CASE WHEN sdh.counterparty_id IN (SELECT source_counterparty_id FROM source_counterparty WHERE counterparty_id IN ('ICE', 'CME', 'EEX')) THEN sdh.counterparty_id ELSE (SELECT source_counterparty_id FROM source_counterparty WHERE counterparty_id IN ('ICE')) END = gmv1.clm7_value	
			AND ISNULL(NULLIF(sdh.option_type, ' '), '$') = ISNULL(gmv1.clm8_value, '$')
			AND ISNULL(gmv1.clm9_value, -1) = ISNULL(sdd.option_strike_price, -1)
		LEFT JOIN (
			SELECT gmvx.mapping_table_id,
				   gmvx.clm1_value,
				   gmvx.clm2_value,
				   gmvx.clm3_value,
				   gmvx.clm4_value,
				   gmvx.clm5_value,
				   gmvx.clm6_value,
				   gmvx.clm7_value,
				   gmvx.clm8_value,
				   gmvx.clm9_value
			FROM generic_mapping_values gmvx
			INNER JOIN generic_mapping_header gmh1
				ON gmh1.mapping_table_id = gmvx.mapping_table_id
			WHERE gmh1.mapping_name = 'Instrument Detail'
				AND clm2_value = 'SPOT'
		) gmv_spot ON gmv_spot.clm6_value = CAST(sdd.curve_id AS VARCHAR(10))
			AND DAY(gmv_spot.clm5_value) = DAY(sdh.deal_date)
			AND MONTH(gmv_spot.clm5_value) = MONTH(sdh.deal_date)
			AND YEAR(gmv_spot.clm5_value) = YEAR(sdh.deal_date)	
			AND CASE WHEN sdh.counterparty_id IN (SELECT source_counterparty_id FROM source_counterparty WHERE counterparty_id IN ('ICE', 'CME', 'EEX')) THEN sdh.counterparty_id ELSE (SELECT source_counterparty_id FROM source_counterparty WHERE counterparty_id IN ('ICE')) END = gmv_spot.clm7_value	
			AND ISNULL(NULLIF(sdh.option_type, ' '), '$') = ISNULL(gmv_spot.clm8_value, '$')
			AND ISNULL(gmv_spot.clm9_value, -1) = ISNULL(sdd.option_strike_price, -1)
		LEFT JOIN static_data_value deal_status
			ON sdh.deal_status = deal_status.value_id
		WHERE deal_status.code IN ('New', 'Amended', 'Reviewed')
			AND CASE WHEN NULLIF(@action_type_mifid, '') IS NULL THEN '1' 
					 ELSE CASE WHEN deal_status.code in ('New') THEN 'NEWT' 
							   WHEN deal_status.code = 'Reviewed' THEN 'CANC' 
							   WHEN deal_status.code = 'Amended' THEN 'MDFY'
						  END 
				END = CASE WHEN NULLIF(@action_type_mifid, '') IS NULL THEN '1' 
						   ELSE @action_type_mifid 
					  END		
		
		BEGIN TRY
			BEGIN TRAN

			INSERT INTO source_mifid_trade (
				source_deal_header_id, deal_id, sub_book_id, trading_date_and_time, instrument_identification_code_type, instrument_identification_code, price, 
				venue_of_execution, price_notation, price_currency, notation_quantity_measurement_unit, quantity_measurement_unit, quantity, notional_amount,
				notional_currency, [type], publication_date_and_time, venue_of_publication, transaction_identification_code, transaction_to_be_cleared, flags, supplimentary_deferral_flags, process_id,
				submission_status, create_date_from, create_date_to, trade_report_id, trade_version, trade_report_type, trade_report_reject_reason, trade_report_trans_type, 
				package_id, trade_number, total_num_trade_reports, security_id, security_id_source, unit_of_measure, contract_multiplier, reporting_party_lei, 
				submitting_party_lei, submitting_party_si_status, asset_class, contract_type, asset_sub_class, maturity_date, freight_size, specific_route_or_time_charter_average,
				settlement_location, reference_rate, ir_term_of_contract, parameter, notional_currency2, series, version, roll_months, next_roll_date, option_type, strike_price,
				strike_currency, exercise_style, delivery_type, transaction_type, final_price_type, floating_rate_of_leg2, ir_term_of_contract_leg2, issue_date, settl_currency,
				notional_schedule, valuation_method_trigger, return_or_payout_trigger, debt_seniority, dsb_use_case, no_underlyings, underlying_symbol, underlying_security_type,
				underlying_issuer, underlying_maturity_date, underlying_issue_date, underlying_security_id, underlying_security_id_source, underlying_index_name, underlying_issuer_type,
				underlying_index_term, underlying_further_sub_product, underlying_other_security_type, underlying_other_further_sub_product, PreviouslyReported, side,counterparty_partyid_lei,regulatory_report_type,deferral_code,initial_deferral_code,submitting_party_nca, apa_entity
			)
			SELECT * FROM #temp_source_mifid_trade
			
			/******** Validation Start ********/
			BEGIN
			IF OBJECT_ID('tempdb..#temp_messages_mifid_trade') IS NOT NULL
				DROP TABLE #temp_messages_mifid_trade

			CREATE TABLE #temp_messages_mifid_trade (
				[source_deal_header_id]	 INT,
				[column] VARCHAR(100) COLLATE DATABASE_DEFAULT,
				[messages] VARCHAR(5000) COLLATE DATABASE_DEFAULT
			)

			/*********** Numeric Data Range Validation*******/
			DECLARE @price_trade NUMERIC(38, 20)
			DECLARE @get_price_trade CURSOR
			SET @get_price_trade = CURSOR FOR
			SELECT price
			FROM source_mifid_trade 
			WHERE process_id = @process_id
			OPEN @get_price_trade
			FETCH NEXT
			FROM @get_price_trade INTO @price_trade
			WHILE @@FETCH_STATUS = 0
			BEGIN
				INSERT INTO #temp_messages_mifid_trade ([source_deal_header_id], [column], [messages])
				SELECT DISTINCT source_deal_header_id, 'price','Price exceeds maximum of 18 digits or maximum of 17 fraction digits'
				FROM dbo.FNASplitAndTranspose(@price_trade, '.') a
				INNER JOIN source_mifid_trade sm
				ON sm.process_id = @process_id
					AND sm.price = @price_trade
				WHERE ((LEN(clm1) + LEN(REPLACE(RTRIM(REPLACE(clm2,'0',' ')),' ','0'))) > 18
					OR LEN(REPLACE(RTRIM(REPLACE(clm2,'0',' ')),' ','0')) > 13)
					AND @action_type_mifid = 'NEWT'
				FETCH NEXT
				FROM @get_price_trade INTO @price_trade
			END
			CLOSE @get_price_trade
			DEALLOCATE @get_price_trade
			/*********** Numeric Data Range Validation*******/

			INSERT INTO #temp_messages_mifid_trade ([source_deal_header_id], [column], [messages])
			SELECT DISTINCT source_deal_header_id, 'price','For New Trade, Price cannot be blank'
			FROM source_mifid_trade 
			WHERE price IS NULL
				AND process_id = @process_id
			
			INSERT INTO #temp_messages_mifid_trade ([source_deal_header_id], [column], [messages])
			SELECT DISTINCT source_deal_header_id, 'quantity','For New Trade, Quantity cannot be blank'
			FROM source_mifid_trade 
			WHERE quantity IS NULL
				AND process_id = @process_id

			INSERT INTO #temp_messages_mifid_trade ([source_deal_header_id], [column], [messages])
			SELECT DISTINCT source_deal_header_id, 'price_currency','Price Currency does not meet the alphanumeric character limit of 3'
			FROM source_mifid_trade 
			WHERE NULLIF(price_currency, '') IS NOT NULL
				AND LEN(price_currency) <> 3
				AND process_id = @process_id

			INSERT INTO #temp_messages_mifid_trade ([source_deal_header_id], [column], [messages])
			SELECT DISTINCT source_deal_header_id, 'price_currency','Invalid Price Currency Code'
			FROM source_mifid_trade 
			WHERE price_currency IS NOT NULL
				AND price_currency NOT IN ('BGN', 'CHF', 'CZK', 'DKK', 'EUR', 'EUX', 'GBX', 'GBP', 'HRK', 'HUF', 'ISK', 'NOK', 'PCT', 'PLN', 'RON', 'SEK', 'USD', 'OTH')
				AND process_id = @process_id				

			/*********** Numeric Data Range Validation*******/
			DECLARE @quantity_trade NUMERIC(38, 20)
			DECLARE @get_quantity_trade CURSOR
			SET @get_quantity_trade = CURSOR FOR
			SELECT quantity
			FROM source_mifid_trade 
			WHERE process_id = @process_id
			OPEN @get_quantity_trade
			FETCH NEXT
			FROM @get_quantity_trade INTO @quantity_trade
			WHILE @@FETCH_STATUS = 0
			BEGIN
				INSERT INTO #temp_messages_mifid_trade ([source_deal_header_id], [column], [messages])
				SELECT DISTINCT source_deal_header_id, 'quantity','Quantity exceeds maximum of 18 digits or maximum of 17 fraction digits'
				FROM dbo.FNASplitAndTranspose(@quantity_trade, '.') a
				INNER JOIN source_mifid_trade sm
				ON sm.process_id = @process_id
					AND sm.quantity = @quantity_trade
				WHERE ((LEN(clm1) + LEN(REPLACE(RTRIM(REPLACE(clm2,'0',' ')),' ','0'))) > 18
					OR LEN(REPLACE(RTRIM(REPLACE(clm2,'0',' ')),' ','0')) > 17)
					AND @action_type_mifid = 'NEWT'
				FETCH NEXT
				FROM @get_quantity_trade INTO @quantity_trade
			END
			CLOSE @get_quantity_trade
			DEALLOCATE @get_quantity_trade
			/*********** Numeric Data Range Validation*******/

			INSERT INTO #temp_messages_mifid_trade ([source_deal_header_id], [column], [messages])
			SELECT DISTINCT source_deal_header_id, 'trading_date_and_time','For New Trade, Trading Date Time cannot be blank'
			FROM source_mifid_trade 
			WHERE NULLIF(trading_date_and_time, '') IS NULL
				AND process_id = @process_id
				AND @action_type_mifid = 'NEWT'

			INSERT INTO #temp_messages_mifid_trade ([source_deal_header_id], [column], [messages])
			SELECT DISTINCT source_deal_header_id, 'trading_date_and_time','Invalid Date Format for Trading Date Time'
			FROM source_mifid_trade 
			WHERE NULLIF(trading_date_and_time, '') IS NOT NULL
				AND trading_date_and_time NOT LIKE '________-__:__:__.___'
				AND process_id = @process_id
				AND @action_type_mifid = 'NEWT'

			INSERT INTO #temp_messages_mifid_trade ([source_deal_header_id], [column], [messages])
			SELECT DISTINCT source_deal_header_id, 'venue_of_execution','For New Trade, Venue of Execution cannot be blank'
			FROM source_mifid_trade 
			WHERE NULLIF(venue_of_execution, '') IS NULL
				AND process_id = @process_id
				AND @action_type_mifid = 'NEWT'
			
			INSERT INTO #temp_messages_mifid_trade ([source_deal_header_id], [column], [messages])
			SELECT DISTINCT source_deal_header_id, 'contract_multiplier','For New Trade, Contract Multiplier cannot be blank'
			FROM source_mifid_trade 
			WHERE NULLIF(contract_multiplier, '') IS NULL
				AND process_id = @process_id
				AND @action_type_mifid = 'NEWT'

			INSERT INTO #temp_messages_mifid_trade ([source_deal_header_id], [column], [messages])
			SELECT DISTINCT source_deal_header_id, 'instrument_identification_code','For New Trade, Instrument Identification Code cannot be blank'
			FROM source_mifid_trade 
			WHERE NULLIF(instrument_identification_code, '') IS NULL
				AND process_id = @process_id
				AND @action_type_mifid = 'NEWT'

			INSERT INTO #temp_messages_mifid_trade ([source_deal_header_id], [column], [messages])
			SELECT DISTINCT source_deal_header_id, 'maturity_date','For New Trade, Maturity Date cannot be blank'
			FROM source_mifid_trade 
			WHERE NULLIF(maturity_date, '') IS NULL
				AND process_id = @process_id
				AND @action_type_mifid = 'NEWT'

			INSERT INTO #temp_messages_mifid_trade ([source_deal_header_id], [column], [messages])
			SELECT DISTINCT source_deal_header_id, 'delivery_type','For New Trade, Delivery Type cannot be blank'
			FROM source_mifid_trade 
			WHERE NULLIF(delivery_type, '') IS NULL
				AND process_id = @process_id
				AND @action_type_mifid = 'NEWT'
			
			INSERT INTO #temp_messages_mifid_trade ([source_deal_header_id], [column], [messages])
			SELECT DISTINCT source_deal_header_id, 'transaction_identification_code','Transaction ID Code exceeds the character limit of 52'
			FROM source_mifid_trade 
			WHERE NULLIF(transaction_identification_code, '') IS NOT NULL
				AND LEN(transaction_identification_code) > 52
				AND process_id = @process_id
				AND @action_type_mifid = 'NEWT'
				
			INSERT INTO #temp_messages_mifid_trade ([source_deal_header_id], [column], [messages])
			SELECT DISTINCT source_deal_header_id, 'underlying_maturity_date','For New Trade, Underlying Maturity Date cannot be blank'
			FROM source_mifid_trade 
			WHERE NULLIF(underlying_maturity_date, '') IS NULL				
				AND process_id = @process_id
				AND @action_type_mifid = 'NEWT'
			END
			IF OBJECT_ID('tempdb..#error_messages_mifid_trade') IS NOT NULL
				DROP TABLE #error_messages_mifid_trade

			SELECT a.source_deal_header_id, 
				STUFF((SELECT '| ' + messages
						FROM #temp_messages_mifid_trade b 
						WHERE b.source_deal_header_id = a.source_deal_header_id 
						FOR XML PATH('')), 1, 2, '') messages
			INTO #error_messages_mifid_trade
			FROM #temp_messages_mifid_trade a
			GROUP BY a.source_deal_header_id
			
			UPDATE se
			SET error_validation_message = tm.messages
			FROM source_mifid_trade se
			INNER JOIN #error_messages_mifid_trade tm 
				ON se.source_deal_header_id = tm.source_deal_header_id
			/******** Vaidation End **********/
			SET @submit_process_id = @process_id
			COMMIT
			EXEC spa_ErrorHandler 0, 'Regulatory Submission', 'spa_source_emir', 'Success', 'Data saved successfully.', ''
		END TRY
		BEGIN CATCH
			PRINT 'Catch Error:' + ERROR_MESSAGE()
			ROLLBACK	
			EXEC spa_ErrorHandler -1, 'Regulatory Submission', 'spa_source_emir', 'Error', 'Failed to save data.', ''
		END CATCH
	END
END
ELSE IF @flag = 's'
BEGIN
	--View tab grid refresh
	SET @_sql = '
		SELECT DISTINCT dbo.FNAUserDateFormat(se.create_date_from, dbo.FNADBUser())  [Create Date From],
				dbo.FNAUserDateFormat(se.create_date_to, dbo.FNADBUser()) [Create Date To],
				' + CASE WHEN @submission_type = 44703 AND @level IN ('P', 'T') THEN '''EMIR'''
						 WHEN @submission_type = 44703 AND @level = 'M' THEN '''EMIR Valuation'''
						 WHEN @submission_type = 44703 AND @level = 'C'  THEN '''EMIR Collateral'''
						 WHEN @submission_type = 44704 AND @level_mifid = 'X' THEN '''MiFID''' 
						 WHEN @submission_type = 44704 AND @level_mifid = 'T' THEN '''MiFID Trade''' 
					END + ' [Report Type],
				au.user_f_name + '' '' + ISNULL(user_m_name, '' '') + user_l_name [User],
				dbo.FNAUserDateTimeFormat(se.create_ts, 1, dbo.FNADBUser()) [Create TS],
				sdv_st.code [Status],
				process_id [Process ID],
				' + CAST(@submission_type AS VARCHAR(10)) + ' [Report Type ID]
		FROM ' + CASE WHEN @submission_type = 44703 AND @level <> 'C' THEN 'source_emir' 
					  WHEN @submission_type = 44703 AND @level = 'C' THEN 'source_emir_collateral' 
					  WHEN @submission_type = 44704 AND @level_mifid = 'X' THEN 'source_mifid' 
					  WHEN @submission_type = 44704 AND @level_mifid = 'T' THEN 'source_mifid_trade' 
				 END + ' se
		LEFT JOIN static_data_value sdv_st 
			ON sdv_st.value_id = se.submission_status
				AND sdv_st.type_id = 39500
		INNER JOIN source_deal_header sdh
			ON sdh.source_deal_header_id = se.source_deal_header_id
		LEFT JOIN application_users au
			ON au.user_login_id = se.create_user
		WHERE (CONVERT(VARCHAR(10), se.create_ts, 120) BETWEEN ''' + @create_date_from + ''' AND ''' + @create_date_to + '''
				OR CONVERT(VARCHAR(10), se.update_ts, 120) BETWEEN ''' + @create_date_from + ''' AND ''' + @create_date_to + ''')
			AND submission_status = ' + CAST(@status AS VARCHAR(100)) + '
		ORDER BY [Create Date From] DESC
	'
	
	EXEC(@_sql)
END
ELSE IF @flag = 'g'
BEGIN
	/**** Regulatory Report Submission *****
	@subission_type = 44703 AND @level in P AND T EMIR Trade, Position level
	@subission_type = 44703 AND @level = C EMIR Collateral level
	@subission_type = 44703 AND @level = M EMIR MTM Valuation level
	@subission_type = 44704 AND @level_mifid = X MiFID Transaction level
	@subission_type = 44704 AND @level_mifid = T MiFID Trade level
	*******************************************/
	DECLARE @sql_str VARCHAR(MAX)
	DECLARE @file_path VARCHAR(MAX), @trade_id NVARCHAR(100), @file_name_export NVARCHAR(MAX) = '', @temp_note_file_path NVARCHAR(100), @remote_directory NVARCHAR(2000)
	SELECT @file_path = CONCAT(cs.document_path, '\temp_note\')
	FROM connection_string cs

	SELECT @tr_rmm = ISNULL(gmv.clm2_value, -1)
	FROM generic_mapping_header gmh
	INNER JOIN generic_mapping_values gmv ON gmv.mapping_table_id = gmh.mapping_table_id
	WHERE mapping_name = 'Regulatory Repository' AND gmv.clm1_value = CAST(@submission_type AS NVARCHAR(10))
	
	DECLARE @document_usage NVARCHAR(100)
	SELECT @document_usage = gmv.clm1_value
	FROM generic_mapping_header gmh
	INNER JOIN generic_mapping_values gmv
		ON gmv.mapping_table_id = gmh.mapping_table_id
	WHERE gmh.mapping_name = 'Document Usage'

	IF @submission_type = 44703 AND @level IN ('P', 'T')
	BEGIN		
		IF @tr_rmm = 116901 -- Equias
		BEGIN
			DROP TABLE IF EXISTS #xml_data
			SELECT 
				'Trader' ReportingRole
				, 'Report' EMIRReportMode
				, 'NoReport' REMITReportMode
				, IIF(@level = 'P', 'true', 'false') Position
				, IIF(DATEDIFF(DAY, sdh.deal_date, reporting_timestamp ) > 30 AND submission_status = 39501, 'true', 'false') Backload
				, action_type ActionType
				, reporting_timestamp ReportingTimestamp
				, other_counterparty_id CPIDCodeType
				, ISNULL(beneficiary_id, '') BeneficiaryID	
				, trading_capacity TradingCapacity
				, 'false' OtherCPEEA
				, commercial_or_treasury CommercialOrTreasury	
				, IIF(clearing_threshold = 'N', 'false', 'true') ClearingThreshold
				, collateralization Collateralisation	
				, collateral_portfolio CollateralisationPortfolio
				, collateral_portfolio_code CollateralisationPortfolioCode
				, nature_of_reporting_cpty Taxonomy
				, 'EMIR_Taxonomy' TaxonomyCodeType
				, product_classification_type  EProductID1
				, 'EMIR_Taxonomy' Product1CodeType
				, contract_type EProductID2	
				, 'CpML' UnderlyingCodeType
				, trade_id TradeID
				, exec_venue VenueOfExecution
				, [compression] [Compression]
				, execution_timestamp ExecutionTimestamp
				, aggreement_type MasterAgreementVersion	
				, clearing_obligation ClearingObligation
				, intra_group Intragroup
				, ISNULL(load_type, '') LoadType
				, confirm_means ConfirmationMeans
				, ISNULL(confirm_ts, '') ConfirmationTimestamp
				, ISNULL(settlement_date, '') DateOfSettlement
				, CAST(document_id AS NVARCHAR(100)) DocumentID 	
				, ISNULL(@document_usage, 'Test') DocumentUsage 
				, se.counterparty_id SenderID 
				, ISNULL(se.counterparty_name, '') ReceiverID	
				, 'ClearingHouse' ReceiverRole
				, reporting_timestamp CreationTimestamp	
				, contract_type TransactionType	
				, asset_class PrimaryAssetClass	
				, trade_id DealID	
				, '11X-UNICLEAR---H' ClearingRegistrationAgentID	--??
				, '11X-UNICLEAR---H' ClearingHouseID --??
				, CONVERT(NVARCHAR(10),quantity)  Lots	
				, CONVERT(NVARCHAR(50),price_rate)  UnitPrice
				, 'true' [Anonymous]	
				, se.counterparty_id [Initiator]	
				, se.commodity_id CRAProductCode
				, delivery_start_date DeliveryStartDateAndTime
				, delivery_end_date DeliveryEndDateAndTime
				, other_counterparty_id BuyerParty	
				, 'Broker' AgentType 
				, ISNULL(sc.counterparty_name, '') AgentName
				, '11X-BETA-BROKERT' BrokerID --Derive from Generic Mapping --??
				, other_counterparty_id SellerParty
				, ISNULL(product_identification, '') MTFID 	
			INTO #xml_data
			FROM source_emir se
			INNER JOIN source_deal_header sdh
				ON sdh.source_deal_header_id = se.source_deal_header_id
			LEFT JOIN source_counterparty sc ON sc.source_counterparty_id = sdh.broker_id 
			WHERE process_id = @process_id AND error_validation_message IS NULL

			DECLARE c CURSOR FOR 
			SELECT DealID FROM #xml_data
			OPEN c 
			FETCH NEXT FROM c INTO @trade_id
			WHILE @@FETCH_STATUS = 0
			BEGIN
				WAITFOR DELAY '00:00:02'
				SET @emir_file_name = 'EMIR_EU_Lite_CO_' + CONVERT(VARCHAR(10), GETDATE(), 120) + '.' + REPLACE(CAST(CAST(GETDATE() AS TIME) AS VARCHAR(8)), ':', '_')
				SET @temp_note_file_path = NULL
				SELECT @xml_string = CAST('' AS NVARCHAR(MAX)) + 
					'<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
					<CpmlDocument>
						<Reporting>
							<Europe>
								<ProcessInformation>
									<ReportingRole>' + ReportingRole + '</ReportingRole>
									<EMIRReportMode>' + EMIRReportMode + '</EMIRReportMode>
									<REMITReportMode>' + REMITReportMode + '</REMITReportMode>
									<Position>' + Position + '</Position>
									<Backload>' + Backload + '</Backload>
								</ProcessInformation>
								<Action>
									<ActionType>' + ActionType + '</ActionType>
								</Action>
								<EURegulatoryDetails>
									<ReportingTimestamp>' + ReportingTimestamp + '</ReportingTimestamp>
									<CPIDCodeType>' + CPIDCodeType + '</CPIDCodeType>
									<BeneficiaryID>' + BeneficiaryID + '</BeneficiaryID>
									<TradingCapacity>' + TradingCapacity + '</TradingCapacity>
									<OtherCPEEA>' + OtherCPEEA + '</OtherCPEEA>
									<CommercialOrTreasury>' + CommercialOrTreasury + '</CommercialOrTreasury>
									<ClearingThreshold>' + ClearingThreshold + '</ClearingThreshold>
									<Collateralisation>' + Collateralisation + '</Collateralisation>
									<CollateralisationPortfolio>' + CollateralisationPortfolio + '</CollateralisationPortfolio>
									<CollateralisationPortfolioCode>' + CollateralisationPortfolioCode + '</CollateralisationPortfolioCode>
									<ProductIdentifier>
										<Taxonomy>' + Taxonomy + '</Taxonomy>
										<TaxonomyCodeType>' + TaxonomyCodeType + '</TaxonomyCodeType>
										<EProduct>
											<EProductID1>' + EProductID1 + '</EProductID1>
											<Product1CodeType>' + Product1CodeType + '</Product1CodeType>
											<EProductID2>' + EProductID2 + '</EProductID2>
										</EProduct>
									</ProductIdentifier>
									<UnderlyingCodeType>' + UnderlyingCodeType + '</UnderlyingCodeType>
									<TradeID>' + TradeID + '</TradeID>
									<VenueOfExecution>' + VenueOfExecution + '</VenueOfExecution>
									<Compression>' + [Compression] + '</Compression>
									<ExecutionTimestamp>' + ExecutionTimestamp + '</ExecutionTimestamp>
									<MasterAgreementVersion>' + MasterAgreementVersion + '</MasterAgreementVersion>
									<ClearingObligation>' + ClearingObligation + '</ClearingObligation>
									<Intragroup>' + Intragroup + '</Intragroup>
									<LoadType>' + LoadType + '</LoadType>
									<ConfirmationMeans>' + ConfirmationMeans + '</ConfirmationMeans>
									<ConfirmationTimestamp>' + ConfirmationTimestamp + '</ConfirmationTimestamp>
									<SettlementDates>
										<DateOfSettlement>' + DateOfSettlement + '</DateOfSettlement>
									</SettlementDates>
								</EURegulatoryDetails>
							</Europe>
						</Reporting>
						<ETDTradeDetails>
							<DocumentID>' + DocumentID + '</DocumentID>
							<DocumentUsage>' + DocumentUsage + '</DocumentUsage>
							<SenderID>' + SenderID + '</SenderID>
							<ReceiverID>' + ReceiverID + '</ReceiverID>
							<ReceiverRole>' + ReceiverRole + '</ReceiverRole>
							<DocumentVersion>' + DocumentID + '</DocumentVersion>
							<CreationTimestamp>' + CreationTimestamp + '</CreationTimestamp>
							<TransactionType>' + TransactionType + '</TransactionType>
							<PrimaryAssetClass>' + PrimaryAssetClass + '</PrimaryAssetClass>
							<ClearingParameters>
								<DealID>' + DealID + '</DealID>
								<ClearingRegistrationAgentID>' + ClearingRegistrationAgentID + '</ClearingRegistrationAgentID>
								<ClearingHouseID>' + ClearingHouseID + '</ClearingHouseID>
								<Lots>' + Lots + '</Lots>
								<UnitPrice>' + UnitPrice + '</UnitPrice>
								<Anonymous>' + [Anonymous] + '</Anonymous>
								<Initiator>' + [Initiator] + '</Initiator>
								<Product>
									<CRAProductCode>' + CRAProductCode + '</CRAProductCode>
									<DeliveryPeriod>
										<DeliveryStartDateAndTime>' + DeliveryStartDateAndTime + '</DeliveryStartDateAndTime>
										<DeliveryEndDateAndTime>' + DeliveryEndDateAndTime + '</DeliveryEndDateAndTime>
									</DeliveryPeriod>
								</Product>
							</ClearingParameters>
							<BuyerDetails>
								<BuyerParty>' + BuyerParty + '</BuyerParty>
								<DealID>' + DealID + '</DealID>
								<Agents>
									<Agent>
										<AgentType>' + AgentType + '</AgentType>
										<AgentName>' + AgentName + '</AgentName>
										<BrokerID>' + BrokerID + '</BrokerID>
									</Agent>
								</Agents>
							</BuyerDetails>
							<SellerDetails>
								<SellerParty>' + SellerParty + '</SellerParty>
								<DealID>' + DealID + '</DealID>
								<ExecutionTimestamp>' + ExecutionTimestamp + '</ExecutionTimestamp>
								<Agents>
									<Agent>
										<AgentType>' + AgentType + '</AgentType>
										<AgentName>' + AgentName + '</AgentName>
										<BrokerID>' + BrokerID + '</BrokerID>
									</Agent>
								</Agents>
							</SellerDetails>
							<MTFDetails>
								<MTFID>' + MTFID + '</MTFID>
								<ExecutionTimestamp>' + ExecutionTimestamp + '</ExecutionTimestamp>
							</MTFDetails>
						</ETDTradeDetails>
					</CpmlDocument>
					'
				FROM #xml_data
				WHERE DealID = @trade_id
				
				SELECT @emir_file_name = @emir_file_name + '.xml'
				
				SELECT @temp_note_file_path = @file_path + @emir_file_name
				EXEC [spa_write_to_file] @xml_string, 'n',  @temp_note_file_path, @result OUTPUT	
				IF @result = '1'
				BEGIN
					SELECT @file_name_export += IIF(NULLIF(@file_name_export,'') IS NULL, @temp_note_file_path, ',' + @temp_note_file_path)
				END
				
				FETCH NEXT FROM c INTO @trade_id
			END
			CLOSE c
			DEALLOCATE c		
			SET @desc = 'Export process completed for EMIR Equias for process_id: ' + @process_id + '. File has been saved at ' + @file_path
			EXEC spa_message_board 'i', @user_name, NULL, 'Export Xml', @desc, '', '', 's', 'EMIR XML Export'
			--drop table if exists adiha_process.dbo.test234
			--SELECT @batch_process_id id into adiha_process.dbo.test234
			SELECT @file_transfer_endpoint_id = file_transfer_endpoint_id	
			, @remote_directory = ftp_folder_path
			FROM batch_process_notifications bpn
			WHERE bpn.process_id = RIGHT(@batch_process_id, 13)

			SELECT @remote_directory = COALESCE(@remote_directory,remote_directory)
			FROM file_transfer_endpoint
			WHERE file_transfer_endpoint_id = @file_transfer_endpoint_id
			
			IF @file_transfer_endpoint_id IS NOT NULL
			BEGIN
				EXEC spa_upload_file_to_ftp_using_clr @file_transfer_endpoint_id, @remote_directory, @file_name_export, @result OUTPUT
			END	
			
			UPDATE source_emir 
			SET submission_status = 39501 
			WHERE process_id = @process_id
			RETURN
		END
		ELSE
		BEGIN
			SET @sql_str = '
				SELECT '''' [*Comments],				   
					   CASE
							WHEN se.action_type = ''N'' THEN ''New''
							WHEN se.action_type = ''M'' THEN ''Modify''
							WHEN se.action_type = ''E'' THEN ''Error''
							WHEN se.action_type = ''C'' THEN ''Cancel''
							WHEN se.action_type = ''V'' THEN ''Valuation update''
							WHEN se.action_type = ''Z'' THEN ''Compression''
							WHEN se.action_type = ''O'' THEN ''Other''				
					   END [Action],
					   ''EULITE1.0'' [Message Version],
					   ''Trade State'' [Message Type],
					   ISNULL(se.reporting_entity_id, '''') [Report submitting entity ID],
					   ISNULL(se.counterparty_id, '''') [Submitted For Party],
					   ISNULL(se.other_counterparty_id, '''') [Trade Party 1 - ID Type],
					   ISNULL(se.counterparty_id, '''') [Trade Party 1 - ID],
					   ISNULL(se.other_counterparty_id, '''') [Trade Party 2 - ID Type],
					   ISNULL(se.counterparty_name, '''') [Trade Party 2 - ID],
					   ''ESMA'' [Trade Party 1 - Reporting Destination],
					   ''ESMA'' [Trade Party 2 - Reporting Destination],
					   '''' [Trade Party 1 - Execution Agent ID],
					   '''' [Trade Party 2 - Execution Agent ID],
					   '''' [Trade Party 1 - Third Party Viewer ID- Party 1],
					   '''' [Trade Party 2 - Third Party Viewer ID- Party 2],
					   ''OTC'' [Exchange Traded Indicator],
					   ISNULL(se.counterparty_country, '''') [Country of the Other Counterparty - Trade Party 1 ],
					   ISNULL(sdv_country.code, '''') [Country of the Other Counterparty - Trade Party 2],
					   ISNULL(se.corporate_sector, '''') [Corporate sector of the reporting counterparty - Trade Party 1  ],
					   ISNULL(se.corporate_sector2, '''') [Corporate sector of the reporting counterparty - Trade Party 2],
					   ISNULL(se.nature_of_reporting_cpty, '''') [Nature of the Reporting Counterparty - Trade Party 1],
					   ISNULL(se.nature_of_reporting_cpty2, '''') [Nature of the Reporting Counterparty - Trade Party 2],
					   '''' [Broker ID - Trade Party 1],
					   ISNULL(se.broker_id, '''') [Broker ID - Trade Party 2],
					   '''' [Clearing Member ID - Trade Party 1],
					   '''' [Clearing Member ID - Trade Party 2],
					   ISNULL(se.beneficiary_type_id, '''') [Type of ID of the Beneficiary - Trade Party 1],
					   ISNULL(se.beneficiary_id, '''') [Beneficiary ID - Trade Party 1],
					   '''' [Type of ID of the Beneficiary - Trade Party 2],
					   '''' [Beneficiary ID - Trade Party 2],
					   ISNULL(se.trading_capacity, '''') [Trading Capacity - Trade Party 1],
					   ISNULL(se.trading_capacity, '''') [Trading Capacity - Trade Party 2],
					   ISNULL(se.counterparty_side, '''') [Counterparty Side - Trade Party 1],
					   CASE WHEN ISNULL(se.counterparty_side, '''') = ''S'' THEN ''B'' ELSE ''S'' END [Counterparty Side - Trade Party 2],
					   '''' [Directly linked to commercial activity or treasury financing Indicator - Trade Party 1],
					   ISNULL(se.commercial_or_treasury, '''') [Directly linked to commercial activity or treasury financing Indicator - Trade Party 2],
					   '''' [Clearing Threshold - Trade Party 1 ],
					   ISNULL(se.clearing_threshold, '''') [Clearing Threshold - Trade Party 2 ],
					   '''' [Collateral Portfolio Code - Trade Party 1 ],
					   '''' [Collateral Portfolio Code - Trade Party 2 ],
					   ISNULL(se.contract_type, '''') [Contract type],
					   ISNULL(se.asset_class, '''') [Asset Class],
					   ISNULL(se.product_classification_type, '''') [Product Classification Type],
					   ISNULL(se.product_classification, '''') [Product Classification],
					   ISNULL(se.product_identification_type, '''') [Product identification type],
					   ISNULL(se.product_identification, '''') [Product identification],
					   ISNULL(se.underlying, '''') [Underlying identification type],
					   ISNULL(se.underlying_identification, '''') [Underlying identification],
					   ISNULL(se.notional_currency_1, '''') [Notional Currency 1],
					   ISNULL(se.notional_currency_2, '''') [Notional Currency 2],
					   ISNULL(se.derivable_currency, '''') [Deliverable currency],
					   ISNULL(se.trade_id, '''') [Trade ID],
					   ISNULL(se.report_tracking_no, '''') [Report Tracking Number],
					   ISNULL(se.complex_trade_component_id, '''') [Complex Trade Component ID],
					   ISNULL(se.exec_venue, '''') [Venue of execution ],
					   ISNULL([compression], '''') [Compression],
					   dbo.FNARemoveTrailingZeroes(ROUND(price_rate, 4)) [Price / rate ],
					   ISNULL(price_notation, '''') [Price notation],
					   ISNULL(price_currency, '''') [Currency of Price],
					   dbo.FNARemoveTrailingZeroes(ROUND(notional_amount, 4)) [Notional],
					   price_multiplier [Price Multiplier],
					   quantity [Quantity],
					   up_front_payment [Up-front payment],
					   ISNULL(delivery_type, '''') [Delivery Type],
					   ISNULL(execution_timestamp, '''') [Execution Timestamp],
					   ISNULL(CONVERT(VARCHAR(10), effective_date, 120), '''') [Effective Date],
					   ISNULL(CONVERT(VARCHAR(10), maturity_date, 120), '''') [Maturity date],
					   ISNULL(termination_date, '''') [Termination Date],
					   ISNULL(settlement_date, '''') [Settlement Date],
					   ISNULL(aggreement_type, '''') [Master Agreement Type],
					   ISNULL(aggreement_version, '''') [Master Agreement Version],
					   ISNULL(confirm_ts, '''') [Confirmation timestamp],
					   ISNULL(confirm_means, '''') [Confirmation means],
					   ISNULL(clearing_obligation, '''') [Clearing obligation],
					   ISNULL(cleared, '''') [Cleared],
					   ISNULL(clearing_ts, '''') [Clearing timestamp],
					   ISNULL(ccp, '''') [CCP],
					   ISNULL(intra_group, '''') [Intragroup],
					   fixed_rate_leg_1 [Fixed rate of leg 1],
					   fixed_rate_leg_2 [Fixed rate of leg 2],
					   ISNULL(fixed_rate_day_count_leg_1, '''') [Fixed rate day count leg 1],
					   ISNULL(fixed_rate_day_count_leg_2, '''') [Fixed rate day count leg 2],
					   ISNULL(fixed_rate_payment_feq_time_leg_1, '''') [Fixed rate payment frequency leg 1 -time period],
					   ISNULL(fixed_rate_payment_feq_mult_leg_1, '''') [Fixed rate payment frequency leg 1 - multiplier],
					   ISNULL(fixed_rate_payment_feq_time_leg_2, '''') [Fixed rate payment frequency leg 2 - time period],
					   ISNULL(fixed_rate_payment_feq_mult_leg_2, '''') [Fixed rate payment frequency leg 2 - multiplier],
					   ISNULL(float_rate_payment_feq_time_leg_1, '''') [Floating rate payment frequency leg 1 - time period],
					   ISNULL(float_rate_payment_feq_mult_leg_1, '''') [Floating rate payment frequency leg 1 - multiplier],
					   ISNULL(float_rate_payment_feq_time_leg_2, '''') [Floating rate payment frequency leg 2 - time period],
					   ISNULL(float_rate_payment_feq_mult_leg_2, '''') [Floating rate payment frequency leg 2 - multiplier],
					   ISNULL(float_rate_reset_freq_leg_1_time, '''') [Floating rate reset frequency leg 1 - time period],
					   ISNULL(float_rate_reset_freq_leg_1_mult, '''') [Floating rate reset frequency leg 1 - multiplier],
					   ISNULL(float_rate_reset_freq_leg_2_time, '''') [Floating rate reset frequency leg 2- time period],
					   ISNULL(float_rate_reset_freq_leg_2_mult, '''') [Floating rate reset frequency leg 2 - multiplier],
					   ISNULL(float_rate_leg_1, '''') [Floating rate of leg 1],
					   float_rate_ref_period_leg_1_time [Floating rate reference period leg 1 - time period],
					   float_rate_ref_period_leg_1_mult [Floating rate reference period leg 1 - multiplier],
					   ISNULL(float_rate_leg_2, '''') [Floating rate of leg 2],
					   ISNULL(float_rate_ref_period_leg_2_time, '''') [Floating rate reference period leg 2 - time period],
					   float_rate_ref_period_leg_2_mult [Floating rate reference period leg 2 -multiplier],
					   ISNULL(delivery_currency_2, '''') [Delivery Currency 2],
					   exchange_rate_1 [Exchange rate 1],
					   forward_exchange_rate [Forward exchange rate],
					   ISNULL(exchange_rate_basis, '''') [Exchange rate basis],
					   ISNULL(commodity_base, '''') [Commodity base],
					   ISNULL(commodity_details, '''') [Commodity details],
					   ISNULL(delivery_point, '''') [Delivery point or zone],
					   ISNULL(interconnection_point, '''') [Interconnection Point ],
					   ISNULL(load_type, '''') [Load type],
					   ISNULL(load_delivery_interval, '''') [Load Delivery Intervals],
					   ISNULL(delivery_start_date, '''') [Delivery Start Date AND Time],
					   ISNULL(delivery_end_date, '''') [Delivery End Date AND Time],
					   ISNULL(duration, '''') [Duration],
					   ISNULL(days_of_the_week, '''') [Days of the Week],
					   ISNULL(delivery_capacity, '''') [Delivery Capacity],
					   ISNULL(quantity_unit, '''') [Quantity Unit ],
					   price_time_interval_quantity [Price/time interval quantities],
					   ISNULL(se.option_type, '''') [Option Type],
					   ISNULL(se.option_style, '''') [Option exercise style ],
					   strike_price [Strike price (cap/floor rate)],
					   ISNULL(strike_price_notation, '''') [Strike price notation],
					   ISNULL(underlying_maturity_date, '''') [Maturity Date of the Underlying],
					   ISNULL(seniority, '''') [Seniority],
					   ISNULL(reference_entity, '''') [Reference Entity],
					   ISNULL(frequency_of_payment, '''') [Frequency of Payment],
					   ISNULL(calculation_basis, '''') [The calculation basis],
					   series [Series],
					   [version] [Version],
					   ISNULL(dbo.FNARemoveTrailingZeroes(ROUND(index_factor, 4)), '''') [Index factor],
					   ISNULL(tranche, '''') [Tranche],
					   ISNULL(attachment_point, '''') [Attachment point],
					   ISNULL(detachment_point, '''') [Detachment Point],
					   ISNULL(action_type, '''') [Action Type - Trade Party 1],
					   ISNULL(action_type, '''') [Action Type - Trade Party 2],
					   ISNULL([level], '''') [Level],
					   ISNULL(reporting_timestamp, '''') [As of Date/Time],
					   '''' [Trade Party 1 - Event ID],
					   '''' [Trade Party 2 - Event ID],
					   '''' [Lifecycle Event],
					   '''' [Data Submitter Message ID],
					   '''' [Reserved - Participant Use 1],
					   '''' [Reserved - Participant Use 2],
					   '''' [Reserved - Participant Use 3],
					   '''' [Reserved - Participant Use 4],
					   '''' [Reserved - Participant Use 5],
					   '''' [Trade Party 1 - Branch Location],
					   '''' [Trade Party 2 - Branch Location],
					   '''' [Trade Party 2 - Third Party Viewer ID Type],
					   '''' [Trade Party 2 - Third Party Viewer ID ],
					   '''' [Product ID Type],
					   '''' [Product ID],
					   '''' [Trade Party 1 - Collateralization],
					   '''' [Trade Party 2 - Collateralization],
					   '''' [Trade Party 1 - Collateral Portfolio],
					   '''' [Trade Party 2 - Collateral Portfolio],
					   '''' [NA1],
					   '''' [NA2],
					   '''' [NA3],
					   '''' [NA4],
					   '''' [NA5],
					   '''' [NA6],
					   '''' [NA7],
					   '''' [NA8],
					   '''' [NA9],
					   '''' [NA10],
					   '''' [NA11],
					   '''' [NA12],
					   '''' [NA13],
					   '''' [NA14],
					   '''' [NA15],
					   '''' [NA16],
					   '''' [NA17],
					   '''' [NA18],
					   '''' [NA19],
					   '''' [NA20],
					   '''' [NA21],
					   '''' [NA22],
					   '''' [NA23],
					   '''' [NA24],
					   '''' [NA25],
					   '''' [NA26],
					   '''' [NA27],
					   '''' [NA28],
					   ISNULL(reporting_timestamp, '''') [Reporting Timestamp],
					   '''' [TBD30],
					   '''' [TBD31],
					   '''' [TBD32],
					   '''' [TBD33],
					   '''' [TBD34],
					   '''' [TBD35],
					   '''' [TBD36],
					   '''' [TBD37],
					   '''' [TBD38],
					   '''' [TBD39],
					   '''' [TBD40],
					   '''' [TBD41],
					   '''' [TBD42],
					   '''' [TBD43],
					   '''' [TBD44],
					   '''' [TBD45],
					   '''' [TBD46],
					   '''' [TBD47],
					   '''' [TBD48],
					   '''' [TBD49],
					   '''' [TBD50],
					   '''' [TBD51],
					   '''' [TBD52],
					   '''' [TBD53],
					   '''' [TBD54],
					   '''' [TBD55],
					   '''' [TBD56],
					   '''' [TBD57],
					   '''' [TBD58],
					   '''' [TBD59],
					   '''' [TBD60],
					   '''' [TBD61],
					   '''' [TBD62],
					   '''' [TBD63],
					   '''' [Trade Party 1 - Transaction ID],
					   '''' [Trade Party 2 - Transaction ID]
				' + @str_batch_table + '
				FROM source_emir se
				INNER JOIN source_deal_header sdh
					ON sdh.source_deal_header_id = se.source_deal_header_id
				LEFT JOIN source_counterparty sc
					ON sc.source_counterparty_id = sdh.counterparty_id
				LEFT JOIN static_data_value sdv_country 
					ON sdv_country.value_id = sc.country
				
			WHERE process_id = ''' + @process_id + '''
				AND error_validation_message IS NULL'
		END
		IF EXISTS(SELECT 1 FROM source_emir WHERE process_id = @process_id)
		BEGIN
			SET @error_spa = 'EXEC spa_regulatory_submission_error @submission_type = ''EMIR Trade'', @process_id = ''' + @process_id + ''''
			SELECT @temp_path = document_path + '\temp_Note\' FROM connection_string

			EXEC batch_report_process  @spa = @error_spa,
						@flag = 'i',
						@report_name = '',
						@batch_type = 'emir',
						@generate_dynamic_params = '0',
						@notification_type = '752',
						@send_attachment = 'y',
						@batch_unique_id = '5errMifid86a1',
						@temp_notes_path = @temp_path,
						@compress_file = 'n',
						@delim = ',',
						@is_header = '1',
						@export_file_format = '.csv'
		END

		UPDATE source_emir 
		SET submission_status = 39501 
		WHERE process_id = @process_id
	END
	ELSE IF @submission_type = 44703 AND @level = 'M'
	BEGIN
		SET @sql_str = '
			SELECT '''' [*Comment],
			   CASE WHEN action_type = ''N'' THEN ''New''
					WHEN action_type = ''C'' THEN ''Cancel''
					WHEN action_type = ''M'' THEN ''Modify'' 
					WHEN action_type = ''E'' THEN ''Error'' 
					WHEN action_type = ''T'' THEN ''Early Termination'' 
					WHEN action_type = ''R'' THEN ''Correction'' 
					WHEN action_type = ''Z'' THEN ''Compression'' 
					WHEN action_type = ''V'' THEN ''Valuation update''
					WHEN action_type = ''P'' THEN ''Position component'' 
			   END [Action],
			   ''EULITE1.0'' [Message Version],
			   ''Valuation'' [Message Type],
			   ISNULL(reporting_entity_id, '''') [Report submitting entity ID],
			   ISNULL(counterparty_id, '''') [Submitted For Party],
			   ISNULL(other_counterparty_id, '''') [Trade Party 1 - ID Type],
			   ISNULL(counterparty_id, '''') [Trade Party 1 - ID],
			   ISNULL(other_counterparty_id, '''') [Trade Party 2 - ID Type],
			   ISNULL(counterparty_name, '''') [Trade Party 2 - ID],			   
			   ''ESMA'' [Trade Party 1 - Reporting Destination],
			   '''' [Trade Party 2 - Reporting Destination],
			   '''' [Trade Party 1 - Execution Agent ID],
			   '''' [Trade Party 2 - Execution Agent ID],
			   '''' [Trade Party 1 - Third Party Viewer ID Type],
			   '''' [Trade Party 1 - Third Party Viewer ID],
			   ''OTC'' [Exchange Traded Indicator],
			   CAST(reporting_timestamp AS VARCHAR(10)) [Data Submitter Message ID],
			   '''' [Trade Party 1 - Event ID],
			   '''' [Trade Party 2 - Event ID],
			   contarct_mtm_value [Value of contract - Trade Party 1],
			   contarct_mtm_currency [Valuation Currency - Trade Party 1],
			   CONVERT(VARCHAR(10), valuation_ts, 120) + ''T'' + CAST(CAST(valuation_ts AS TIME) AS VARCHAR(8)) + ''Z'' [Valuation Datetime - Trade Party 1],
			   ''M'' [Valuation Type - Trade Party 1],
			   '''' [Value of contract - Trade Party 2],
			   '''' [Valuation Currency - Trade Party 2],
			   '''' [Valuation Datetime - Trade Party 2],
			   '''' [Valuation Type - Trade Party 2],
			   ISNULL(trade_id, '''') [Trade ID],
			   ISNULL(cleared, '''') [Cleared],
			   ''V'' [Trade Party 1 - Action Type],
			   '''' [Trade Party 2 - Action Type],
			   '''' [Reserved - Participant Use 1],
			   '''' [Reserved - Participant Use 2],
			   '''' [Reserved - Participant Use 3],
			   '''' [Reserved - Participant Use 4],
			   '''' [Reserved - Participant Use 5],
			   ISNULL(asset_class, '''') [Asset Class],
			   ''T'' [Level],
			   '''' [Trade Party 1 - Transaction ID],
			   '''' [Trade Party 2 - Transaction ID],
			   '''' [Trade Party 2 - Third Party Viewer ID Type],
			   '''' [Trade Party 2 - Third Party Viewer ID],
			   '''' [NA1],
			   '''' [NA2],
			   ISNULL(reporting_timestamp, '''') [Reporting Timestamp]
		' + @str_batch_table + '
		FROM source_emir
		WHERE [level] = ''M''
			AND error_validation_message IS NULL'
		
		IF EXISTS(SELECT 1 FROM source_emir WHERE process_id = @process_id)
		BEGIN
			SET @error_spa = 'EXEC spa_regulatory_submission_error @submission_type = ''EMIR MTM'', @process_id = ''' + @process_id + ''''
			SELECT @temp_path = document_path + '\temp_Note\' FROM connection_string
			
			EXEC batch_report_process  @spa = @error_spa,
						@flag = 'i',
						@report_name = '',
						@batch_type = 'emir',
						@generate_dynamic_params = '0',
						@notification_type = '752',
						@send_attachment = 'y',
						@batch_unique_id = '5errMifid86a1',
						@temp_notes_path = @temp_path,
						@compress_file = 'n',
						@delim = ',',
						@is_header = '1',
						@export_file_format = '.csv'
		END

		UPDATE source_emir 
		SET submission_status = 39501 
		WHERE process_id = @process_id
	END
	ELSE IF @submission_type = 44703 AND @level = 'C'
	BEGIN
		SET @sql_str = '
			SELECT ''CollateralizedPortfolioLevel'' [*Comment],
				   ''Coll1.0'' [Version],
				   message_type [Message Type],
				   data_submitter_message_id [Data Submitter Message ID],
				   [action] [Action],
				   data_submitter_prefix [Data Submitter prefix],
				   data_submitter_value [Data Submitter value],
				   trade_party_prefix [Trade Party Prefix],
				   trade_party_value [Trade Party Value],
				   execution_agent_party_prefix [Execution Agent Party Prefix],
				   execution_agent_party_value [Execution Agent Party Value],
				   collateral_portfolio_code [Collateral Portfolio Code],
				   collateral_portfolio [Collateral Portfolio],
				   value_of_the_collateral [Value of the collateral],
				   currency_of_the_collateral [Currency of the collateral],
				   collateral_valuation_date_time [Collateral Valuation Date Time],
				   collateral_reporting_date [Collateral Reporting Date],
				   send_to [sendTo],
				   execution_agent_masking_indicator [Execution Agent Masking Indicator],
				   trade_party_reporting_obligation [Trade Party Reporting Obligation],
				   other_party_id_type [Other Party ID Type],
				   other_party_id [Other Party ID],
				   collateralized [Collateralized],
				   initial_margin_posted [Initial Margin Posted],
				   initial_margin_posted_currency [Currency of the initial margin posted],
				   initial_margin_received [Initial Margin Received],
				   initial_margin_received_currency [Currency of the initial margin received],
				   variation_margin_posted [Variation Margin Posted],
				   variation_margin_posted_currency [Currency of the Variation Margin Posted],
				   variation_margin_received [Variation Margin Received],
				   variation_margin_received_currency [Currency of the variation margin received],
				   excess_collateral_posted [Excess Collateral Posted],
				   excess_collateral_posted_currency [Currency of the Excess Collateral Posted],
				   excess_collateral_received [Excess Collateral Received],
				   excess_collateral_received_currency [Currency of the Excess Collateral received],
				   third_party_viewer [Third Party Viewer],
				   reserved_participant_use_1 [Reserved - Participant Use 1],
				   reserved_participant_use_2 [Reserved - Participant Use 2],
				   reserved_participant_use_3 [Reserved - Participant Use 3],
				   reserved_participant_use_4 [Reserved - Participant Use 4],
				   reserved_participant_use_5 [Reserved - Participant Use 5],
				   action_type_party_1 [Action Type Party 1],
				   third_party_viewer_id_type [Third Party Viewer ID Type],
				   [level] [Level]
			' + @str_batch_table + '
			FROM source_emir_collateral
			WHERE process_id = ''' + @process_id + '''
				AND NULLIF(error_validation_message, '''') IS NULL'
		
		IF EXISTS(SELECT 1 FROM source_emir_collateral WHERE process_id = @process_id)
		BEGIN
			SET @error_spa = 'EXEC spa_regulatory_submission_error @submission_type = ''EMIR Collateral'', @process_id = ''' + @process_id + ''''
			SELECT @temp_path = document_path + '\temp_Note\' FROM connection_string

			EXEC batch_report_process  @spa = @error_spa,
						@flag = 'i',
						@report_name = '',
						@batch_type = 'mifid',
						@generate_dynamic_params = '0',
						@notification_type = '752',
						@send_attachment = 'y',
						@batch_unique_id = '5errMifid86a1',
						@temp_notes_path = @temp_path,
						@compress_file = 'n',
						@delim = ',',
						@is_header = '1',
						@export_file_format = '.csv'
		END

		UPDATE source_emir_collateral 
		SET submission_status = 39501 
		WHERE process_id = @process_id
	END
	ELSE IF @submission_type = 44704 AND @level_mifid = 'X'
	BEGIN
		SET @sql_str = '
			SELECT ISNULL([report_status], '''') AS [Report Status],
					ISNULL([trans_ref_no], '''') AS [Transaction Reference Number],
					ISNULL([trading_trans_id], '''') AS [Trading Venue Transaction ID Code],
					ISNULL([exec_entity_id], '''') AS [Executing Entity ID Code],
					ISNULL([covered_by_dir], '''') AS [Investment Firm Covered by Directive 2014/65/EU],
					ISNULL([submitting_entity_id_code], '''') AS [Submitting Entity ID Code],
					ISNULL([buyer_id], '''') AS [Buyer ID Code],
					ISNULL([buyer_country], '''') AS [Buyer - Country of the Branch ],
					ISNULL([buyer_fname], '''') AS [Buyer - First Name(s)],
					ISNULL([buyer_sname], '''') AS [Buyer - Surname(s)],
					ISNULL((CONVERT(VARCHAR(10), CONVERT(DATETIME, [buyer_dob], 103), 126)), '''') AS [Buyer - Date of Birth],
					ISNULL([buyer_decision_maker_code], '''') AS [Buyer Decision Maker Code],
					ISNULL([buyer_decision_maker_fname], '''') AS [Buyer Decision Maker - First Name(s)],
					ISNULL([buyer_decision_maker_sname], '''') AS [Buyer Decision Maker - Surname(s)],
					ISNULL((CONVERT(VARCHAR(10), CONVERT(DATETIME, [buyer_decision_maker_dob], 103), 120)), '''') AS [Buyer Decision Maker - Date of Birth],
					ISNULL([seller_id], '''') AS [Seller ID Code],
					ISNULL([seller_country], '''') AS [Seller - Country of the Branch],
					ISNULL([seller_fname], '''') AS [Seller - First Name(s)],
					ISNULL([seller_sname], '''') AS [Seller - Surname(s)],
					ISNULL((CONVERT(VARCHAR(10), CONVERT(DATETIME, [seller_dob], 103), 126)), '''') AS [Seller - Date of Birth],
					ISNULL([seller_decision_maker_code], '''') AS [Seller Decision Maker Code],
					ISNULL([seller_decision_maker_fname], '''') AS [Seller Decision Maker - First Name(s)],
					ISNULL([seller_decision_maker_sname], '''') AS [Seller Decision Maker - Surname(s)],
					ISNULL((CONVERT(VARCHAR(10), CONVERT(DATETIME, [seller_decision_maker_dob], 103), 126)), '''') [Seller Decision Maker - Date of Birth],
					ISNULL([order_trans_indicator], '''') AS [Transmission of Order Indicator],
					ISNULL([buyer_trans_firm_id], '''') AS [Buyer - Transmitting Firm ID Code],
					ISNULL([seller_trans_firm_id], '''') AS [Seller - Transmitting Firm ID Code],
					ISNULL([trading_date_time], '''') AS [Trading Date Time],
					ISNULL([trading_capacity], '''') AS [Trading Capacity],
					ISNULL(dbo.FNARemoveTrailingZeroes(ROUND([quantity], 4)), '''') AS [Quantity],
					ISNULL([quantity_currency], '''') AS [Quantity Currency],
					ISNULL([der_notional_incr_decr], '''') AS [Derivative Notional Increase/Decrease],
					ISNULL(dbo.FNARemoveTrailingZeroes([price]), '''') AS [Price],
					ISNULL([price_currency], '''') AS [Price Currency],
					ISNULL(dbo.FNARemoveTrailingZeroes(ROUND([net_amount], 4)), '''') AS [Net Amount],
					ISNULL([venue], '''') AS [Venue],
					ISNULL([branch_membership_country], '''') AS [Country of the Branch Membership],
					ISNULL(dbo.FNARemoveTrailingZeroes(ROUND([upfront_payment], 4)), '''') AS [Upfront Payment],
					ISNULL([upfront_payment_currency], '''') AS [Upfront Payment Currency],
					ISNULL([complex_trade_component_id], '''') AS [Complex Trade Component ID],
					ISNULL([instrument_id_code], '''') AS [Instrument ID Code],
					ISNULL([instrument_name], '''') AS [Instrument Full Name],
					ISNULL([instrument_classification], '''') AS [Instrument Classification],
					ISNULL([notional_currency_1], '''') AS [Notional Currency 1],
					ISNULL([notional_currency_2], '''') AS [Notional Currency 2],
					ISNULL(dbo.FNARemoveTrailingZeroes(ROUND([price_multiplier], 4)), '''') AS [Price Multiplier],
					ISNULL([underlying_instrument_code], '''') AS [Underlying Instrument Code],
					ISNULL([underlying_index_name], '''') AS [Underlying Index Name],
					ISNULL([underlying_index_term], '''') AS [Term of the Underlying Index],
					ISNULL([option_type], '''') AS [Option Type],
					ISNULL(dbo.FNARemoveTrailingZeroes(ROUND([strike_price], 4)), '''') AS [Strike Price],
					ISNULL([strike_price_currency], '''') AS [Strike Price Currency],
					ISNULL([option_exercise_style], '''') AS [Option Exercise Style],
					ISNULL((CONVERT(VARCHAR(10), CONVERT(DATETIME, [maturity_date], 103), 126)), '''') AS [Maturity Date],
					ISNULL((CONVERT(VARCHAR(10), CONVERT(DATETIME, [expiry_date], 103), 126)), '''') AS [Expiry Date],
					ISNULL([delivery_type], '''') AS [Delivery Type],
					ISNULL([firm_invest_decision], '''') AS [Investment Decision within Firm],
					ISNULL([decision_maker_country], '''') AS [Decision Maker - Country of the Branch],
					ISNULL([firm_execution], '''') AS [Execution within Firm],
					ISNULL([supervising_execution_country], '''') AS [Supervising Execution - Country of the Branch],
					ISNULL([waiver_indicator], '''') AS [Waiver Indicator],
					ISNULL([short_selling_indicator], '''') AS [Short Selling Indicator],
					ISNULL([otc_post_trade_indicator], '''') AS [OTC Post-Trade Indicator],
					ISNULL([commodity_derivative_indicator], '''') AS [Commodity Derivative Indicator],
					ISNULL([securities_financing_transaction_indicator], '''') AS [Securities Financing Transaction Indicator]
			' + @str_batch_table + ' 
			FROM source_mifid
			WHERE error_validation_message IS NULL
		'
			
		IF EXISTS(SELECT 1 FROM source_mifid WHERE process_id = @process_id)
		BEGIN
			SET @error_spa = 'EXEC spa_regulatory_submission_error @submission_type = ''MiFID Transaction'', @process_id = ''' + @process_id + ''''
			SELECT @temp_path = document_path + '\temp_Note\' FROM connection_string

			EXEC batch_report_process  @spa = @error_spa,
						@flag = 'i',
						@report_name = '',
						@batch_type = 'mifid',
						@generate_dynamic_params = '0',
						@notification_type = '752',
						@send_attachment = 'y',
						@batch_unique_id = '5errMifid86a1',
						@temp_notes_path = @temp_path,
						@compress_file = 'n',
						@delim = ',',
						@is_header = '1',
						@export_file_format = '.csv'
		END

		UPDATE source_mifid 
		SET submission_status = 39501 
		WHERE process_id = @process_id
			--AND error_validation_message IS NULL
	END
	ELSE IF @submission_type = 44704 AND @level_mifid = 'T'
	BEGIN
		SET @sql_str = '
			SELECT ISNULL(trading_date_and_time, '''') [TradingDate],
					ISNULL(instrument_identification_code_type, '''') [Instrument Identification Code Type],
					ISNULL(instrument_identification_code, '''') [InstrumentId],
					ISNULL(dbo.FNARemoveTrailingZeroes(ROUND(price, 4)), '''') [Price],
					ISNULL(venue_of_execution, '''') [ExecutionVenue],
					ISNULL(price_notation, '''') [PrcNotation],
					ISNULL(price_currency, '''') [PrcCurrency],
					ISNULL(notation_quantity_measurement_unit, '''') [QtyNotation],
					ISNULL(dbo.FNARemoveTrailingZeroes(ROUND(quantity_measurement_unit, 4)), '''') [QtyInMeasurementUnit ],
					ISNULL(dbo.FNARemoveTrailingZeroes(ROUND(quantity, 4)), '''') [Qty],
					ISNULL(dbo.FNARemoveTrailingZeroes(ROUND(notional_amount, 4)), '''') [NotionalAmount],
					ISNULL(notional_currency, '''') [NotionalCurrency],
					ISNULL(type, '''') [Type],
					ISNULL(publication_date_and_time, '''') [PublicationDateTime],
					--ISNULL(venue_of_publication, '''') [Venue of Publication],
					ISNULL(transaction_identification_code, '''') [TransactionIdentificationCode],
					ISNULL(transaction_to_be_cleared, '''') [Transaction to be Cleared],
					ISNULL(flags, '''') [Flags],
					ISNULL(supplimentary_deferral_flags, '''') [Supplimentary Deferral Flags],
					--
					ISNULL(trade_report_id, '''') [Trade Report ID],
					ISNULL(trade_version, '''') [Trade Version],
					ISNULL(trade_report_type, '''') [Trade Report Type],
					ISNULL(trade_report_reject_reason, '''') [Trade Report Reject Reason],
					ISNULL(trade_report_trans_type, '''') [Trade Report Trans Type],
					ISNULL(package_id, '''') [Package ID],
					ISNULL(trade_number, '''') [Trade Number],
					ISNULL(total_num_trade_reports, '''') [Total Num Trade Reports],
					ISNULL(security_id, '''') [Security ID],
					ISNULL(security_id_source, '''') [Security ID Source],
					ISNULL(unit_of_measure, '''') [Unit Of Measure],
					ISNULL(contract_multiplier, '''') [Contract Multiplier],
					ISNULL(reporting_party_lei, '''') [Reporting Party LEI],
					ISNULL(submitting_party_lei, '''') [Submitting Party LEI],
					ISNULL(submitting_party_si_status, '''') [Submitting Party SI Status],
					ISNULL(asset_class, '''') [Asset Class],
					ISNULL(contract_type, '''') [Contract Type],
					--
					ISNULL(asset_sub_class, '''') [AssetSubClass],
					ISNULL(maturity_date, '''') [MaturityDate],
					ISNULL(freight_size, '''') [FreightSize],
					ISNULL(specific_route_or_time_charter_average, '''') [SpecificRouteOrTimeCharterAverage],
					ISNULL(settlement_location, '''') [SettlementLocation],
					ISNULL(reference_rate, '''') [ReferenceRate],
					ISNULL(ir_term_of_contract, '''') [IRTermOfContract],
					ISNULL(parameter, '''') [Parameter],
					ISNULL(notional_currency2, '''') [NotionalCurrency2],
					ISNULL(series, '''') [Series],
					ISNULL(version, '''') [Version],
					ISNULL(roll_months, '''') [RollMonths],
					ISNULL(next_roll_date, '''') [NextRollDate],
					ISNULL(option_type, '''') [OptionType],
					strike_price [StrikePrice],
					ISNULL(strike_currency, '''') [StrikeCurrency],
					ISNULL(exercise_style, '''') [ExerciseStyle],
					ISNULL(delivery_type, '''') [DeliveryType],
					ISNULL(transaction_type, '''') [TransactionType],
					ISNULL(final_price_type, '''') [FinalPriceType ],
					ISNULL(floating_rate_of_leg2, '''') [FloatingRateOfLeg2],
					ISNULL(ir_term_of_contract_leg2, '''') [IRTermOfContractLeg2 ],
					ISNULL(issue_date, '''') [IssueDate ],
					ISNULL(settl_currency, '''') [SettlCurrency ],
					ISNULL(notional_schedule, '''') [NotionalSchedule ],
					ISNULL(valuation_method_trigger, '''') [ValuationMethodTrigger ],
					ISNULL(return_or_payout_trigger, '''') [ReturnorPayoutTrigger ],
					ISNULL(debt_seniority, '''') [DebtSeniority ],
					ISNULL(dsb_use_case, '''') [DSBUseCase ],
					ISNULL(no_underlyings, '''') [NoUnderlyings ],
					ISNULL(underlying_symbol, '''') [UnderlyingSymbol ],
					ISNULL(underlying_security_type, '''') [UnderlyingSecurityType ],
					ISNULL(underlying_issuer, '''') [UnderlyingIssuer ],
					ISNULL(underlying_maturity_date, '''') [UnderlyingMaturityDate],
					ISNULL(underlying_issue_date, '''') [UnderlyingIssueDate ],
					ISNULL(underlying_security_id, '''') [UnderlyingSecurityID],
					ISNULL(underlying_security_id_source, '''') [UnderlyingSecurityIDSource],
					ISNULL(underlying_index_name, '''') [UnderlyingIndexName ],
					ISNULL(underlying_issuer_type, '''') [UnderlyingIssuerType ],
					ISNULL(underlying_index_term, '''') [UnderlyingIndexTerm ],
					ISNULL(underlying_further_sub_product, '''') [UnderlyingFurtherSubProduct],
					ISNULL(underlying_other_security_type, '''') [UnderlyingOtherSecurityType],
					ISNULL(underlying_other_further_sub_product, '''') [UnderlyingOtherFurtherSubProduct],
					ISNULL(counterparty_partyid_lei, '''') [counterparty_partyid_lei]
			' + @str_batch_table + ' 
			FROM source_mifid_trade
			WHERE 1 = 1
		'
		
		IF EXISTS(SELECT 1 FROM source_mifid_trade WHERE process_id = @process_id)
		BEGIN
			SET @error_spa = 'EXEC spa_regulatory_submission_error @submission_type = ''MiFID Trade'', @process_id = ''' + @process_id + ''''
			SELECT @temp_path = document_path + '\temp_Note\' FROM connection_string

			EXEC batch_report_process  @spa = @error_spa,
						@flag = 'i',
						@report_name = '',
						@batch_type = 'mifid',
						@generate_dynamic_params = '0',
						@notification_type = '752',
						@send_attachment = 'y',
						@batch_unique_id = '5errMifid86a1',
						@temp_notes_path = @temp_path,
						@compress_file = 'n',
						@delim = ',',
						@is_header = '1',
						@export_file_format = '.csv'
		END
		
		DECLARE @contextinfo VARBINARY(128)
		DECLARE @db_name VARCHAR(150)
		DECLARE @owner VARCHAR(150)
		SELECT @owner = dbo.FNAAppAdminID() 
		
		DECLARE @Today VARCHAR(12) 
		DECLARE @script VARCHAR(5000)
		DECLARE @msg nvarchar(max)
		DECLARE @port varchar(4) = '8001'
		DECLARE @ip VARCHAR(100)='127.0.0.1'
		SELECT @Today = CAST(GETDATE() as DATE)
		SET @script = 'FARRMS_WS_CMD|TWEB|TRADEREQUEST|'+@Today
		SELECT @script
		SET @db_name = DB_NAME()
		EXEC spa_send_remote_command @ip, @port,@script, @msg output

		-- It doesnt ensure trade web submission through fix protocal service has been done.
		-- It only returns either request to fix protocal service has been transmitted or not
		DECLARE @db_user NVARCHAR(1024) = dbo.FNADBUser()
		IF(@msg ='true')
		BEGIN
			EXEC spa_message_board 'i', @db_user, NULL, 'FIX Protocol Service - Trade Web', 'Query trade web submitted.', '', '', 's', null, NULL, null, NULL, NULL, NULL, 'y', 
									   'No data to submit.', 'spa_source_emir' , NULL, NULL,NULL, ''
		END
		ELSE
		BEGIN
			EXEC spa_message_board 'i', @db_user, NULL, 'FIX Protocol Service - Trade Web', '<font color="red">Request for query trade web failed [Communication Error]</font>', '', '', 's', null, NULL, null, NULL, NULL, NULL, 'y', 
									   'No data to submit.', 'spa_source_emir' , NULL, NULL,NULL, ''
		END
	END
		
	SET @sql_str = @sql_str + ' AND process_id =  ''' + @process_id + ''''
	
	--PRINT @sql_str
	EXEC (@sql_str)
END
ELSE IF @flag = 'd'
BEGIN
	--Delete regulatory report data from respective tables
	SET @_sql = '
		DELETE
		FROM ' + CASE WHEN @submission_type = 44703 AND @Level <> 'C' THEN 'source_emir'
					  WHEN @submission_type = 44703 AND @Level = 'C' THEN 'source_emir_collateral' 
					  WHEN @submission_type = 44704 AND @level_mifid = 'X' THEN 'source_mifid' 
					  WHEN @submission_type = 44704 AND @level_mifid = 'T' THEN 'source_mifid_trade' 
				 END + '
		WHERE process_id IN (' + @process_id + ')
	'
	EXEC spa_print @_sql
	EXEC(@_sql)
	EXEC spa_ErrorHandler 0, 'Source EMIR', 'spa_source_emir', 'Success', 'Row deleted successfully.', ''
END
ELSE IF @flag = 'a'
BEGIN
	SELECT 'N' id, 'New' code UNION ALL
	SELECT 'M', 'Modify' UNION ALL
	SELECT 'E', 'Error' UNION ALL
	SELECT 'C', 'Cancel' UNION ALL
	SELECT 'Z', 'Compression' UNION ALL
	SELECT 'V', 'Valuation update' UNION ALL
	SELECT 'O', 'Other'
	ORDER BY id
END
ELSE IF @flag = 'e'--Generate Excel Detail from EMIR Trade AND Position
BEGIN	
	SELECT
		source_emir_id [EMIR ID],
		sdh.source_deal_header_id [Deal ID],
		se.deal_id [Deal Ref ID],
		ssbm.logical_name [Sub Book],
		dbo.FNAUSERDateFormat(sdh.deal_date, dbo.FNADBUser()) [Deal Date],
		se.reporting_timestamp [Reporting timestamp],
		'Trade' AS [Trade/Allege],
		ISNULL(trade_id, '') AS [Trade ID],
		ISNULL(se.counterparty_id, '') AS [Reporting Counterparty ID],
		ISNULL(other_counterparty_id, '') AS [Type of ID of the other Counterparty],
		ISNULL(counterparty_name, '') AS [ID of the other Counterparty],
		'' AS [Trade Party 1 - Execution Agent ID],
		'' AS [Trade Party 2 - Execution Agent ID],
		CASE
			WHEN se.action_type = 'N' THEN 'New'
			WHEN se.action_type = 'M' THEN 'Modify'
			WHEN se.action_type = 'E' THEN 'Error'
			WHEN se.action_type = 'C' THEN 'Cancel'			
			WHEN se.action_type = 'V' THEN 'Valuation update'
			WHEN se.action_type = 'Z' THEN 'Compression'
			WHEN se.action_type = 'O' THEN 'Other'
		END [Action Type],
		CASE
			WHEN se.[level] = 'P' THEN 'Position'
			WHEN se.[level] = 'T' THEN 'Trade'
		END [Level],
		ISNULL(reporting_timestamp, '') AS [Reporting timestamp],
		ISNULL(reporting_entity_id, '') AS [Report submitting entity ID],
		'' AS [Submitted For Party],
		'' AS [Message Version],
		CASE
			WHEN se.[level] = 'P' THEN 'Position'
			WHEN se.[level] = 'T' THEN 'Trade'
		END  AS [Message Type],
		'ESMA' AS [Trade Party 1 - Reporting Destination],
		'' AS [Trade Party 1 - Third Party Viewer ID Type],
		'' AS [Trade Party 1 - Third Party Viewer ID],
		'' AS [Message ID],
		'' AS [Name of the counterparty],
		'' AS [Domicile of the counterparty],
		'' AS [Contract with non-EEA counterparty],
		ISNULL(counterparty_country, '') AS [Country of the other Counterparty],
		ISNULL(corporate_sector, '') AS [Corporate sector of the reporting counterparty],
		'' AS [Financial or non-financial nature of the counterparty ],
		ISNULL(nature_of_reporting_cpty, '') AS [Nature of the reporting counterparty],
		ISNULL(se.broker_id, '') AS [Broker ID],
		ISNULL(clearing_member_id, '') AS [Clearing member ID],
		ISNULL(beneficiary_type_id, '') AS [Type of ID of the Beneficiary],
		ISNULL(beneficiary_id, '') AS [Beneficiary ID],
		ISNULL(trading_capacity, '') AS [Trading capacity],
		ISNULL(counterparty_side, '') AS [Counterparty side],
		ISNULL(commercial_or_treasury, '') AS [Directly linked to commercial activity or treasury financing],
		ISNULL(clearing_threshold, '') AS [Clearing threshold],
		'' AS [Taxonomy used],
		'' AS [Product ID 1],
		'' AS [Product ID 2],
		ISNULL(contract_type, '') AS [Contract type],
		ISNULL(asset_class, '') AS [Asset class],
		ISNULL(product_classification_type, '') AS [Product classification type],
		ISNULL(se.product_classification, '') AS [Product classification],
		ISNULL(product_identification_type, '') AS [Product identification type],
		ISNULL(product_identification, '') AS [Product identification],
		ISNULL(underlying, '') AS [Underlying identification type],
		ISNULL(underlying_identification, '') AS [Underlying identification],
		ISNULL(derivable_currency, '') AS [Deliverable currency],
		ISNULL(se.option_type, '') AS [Option type],
		ISNULL(option_style, '') AS [Option exercise style],
		ISNULL(strike_price, '') AS [Strike price (cap/floor rate)],
		ISNULL(strike_price_notation, '') AS [Strike price notation],
		ISNULL(underlying_maturity_date, '') AS [Maturity date of the underlying],
		ISNULL(exec_venue, '') AS [Venue of execution],
		ISNULL(compression, '') AS [Compression],
		ISNULL(dbo.FNARemoveTrailingZeroes(ROUND(price_rate, 4)), '') AS [Price / rate],
		ISNULL(price_notation, '') AS [Price notation],
		ISNULL(price_currency, '') AS [Currency of price],
		ISNULL(dbo.FNARemoveTrailingZeroes(ROUND(notional_amount, 4)), '') AS [Notional],
		ISNULL(notional_currency_1, '') AS [Notional currency 1],
		ISNULL(notional_currency_2, '') AS [Notional currency 2],
		ISNULL(price_multiplier, '') AS [Price multiplier],
		ISNULL(quantity, '') AS [Quantity],
		ISNULL(up_front_payment, '') AS [Up-front payment],
		ISNULL(delivery_type, '') AS [Delivery type],
		ISNULL(execution_timestamp, '') AS [Execution timestamp],
		ISNULL(effective_date, '') AS [Effective date],
		ISNULL(maturity_date, '') AS [Maturity date],
		ISNULL(termination_date, '') AS [Termination date],
		ISNULL(settlement_date, '') AS [Settlement date],
		ISNULL(aggreement_type, '') AS [Master Agreement type],
		ISNULL(aggreement_version, '') AS [Master Agreement version],
		ISNULL(confirm_ts, '') AS [Confirmation timestamp],
		ISNULL(confirm_means, '') AS [Confirmation means],
		ISNULL(clearing_obligation, '') AS [Clearing obligation],
		ISNULL(cleared, '') AS [Cleared],
		ISNULL(clearing_ts, '') AS [Clearing timestamp],
		ISNULL(ccp, '') AS [CCP],
		ISNULL(intra_group, '') AS [Intragroup],
		ISNULL(fixed_rate_leg_1, '') AS [Fixed rate of leg 1],
		ISNULL(fixed_rate_leg_2, '') AS [Fixed rate of leg 2],
		'' AS [Fixed rate day count],
		ISNULL(fixed_rate_day_count_leg_1, '') AS [Fixed rate day count leg 1],
		ISNULL(fixed_rate_day_count_leg_2, '') AS [Fixed rate day count leg 2],
		'' AS [Fixed leg payment frequency],--
		ISNULL(fixed_rate_payment_feq_time_leg_1, '') AS [Fixed rate payment frequency leg 1 - Time Period],
		ISNULL(fixed_rate_payment_feq_mult_leg_1, '') AS [Fixed rate payment frequency leg 1 - Multiplier],
		ISNULL(fixed_rate_payment_feq_time_leg_2, '') AS [Fixed rate payment frequency leg 2 - Time Period],
		ISNULL(fixed_rate_payment_feq_mult_leg_2, '') AS [Fixed rate payment frequency leg 2 - Multiplier],
		'' AS [Floating rate payment frequency],
		ISNULL(float_rate_payment_feq_time_leg_1, '') AS [Floating rate payment frequency leg 1 - Time Period],
		ISNULL(float_rate_payment_feq_mult_leg_1, '') AS [Floating rate payment frequency leg 1 - Multiplier],
		ISNULL(float_rate_payment_feq_time_leg_2, '') AS [Floating rate payment frequency leg 2 - Time Period],
		ISNULL(float_rate_payment_feq_mult_leg_2, '') AS [Floating rate payment frequency leg 2 - Multiplier],
		'' AS [Floating rate reset frequency],
		ISNULL(float_rate_reset_freq_leg_1_time, '') AS [Floating rate reset frequency leg 1 - Time Period],
		ISNULL(float_rate_reset_freq_leg_1_mult, '') AS [Floating rate reset frequency leg 1 - Multiplier],
		ISNULL(float_rate_reset_freq_leg_2_time, '') AS [Floating rate reset frequency leg 2- Time Period],
		ISNULL(float_rate_reset_freq_leg_2_mult, '') AS [Floating rate reset frequency leg 2 - Multiplier],
		ISNULL(float_rate_leg_1, '') AS [Floating rate of leg 1],
		ISNULL(float_rate_ref_period_leg_1_time, '') AS [Floating rate reference period leg 1 - Time Period],
		float_rate_ref_period_leg_1_mult AS [Floating rate reference period leg 1 - Multiplier],
		ISNULL(float_rate_leg_2, '') AS [Floating rate of leg 2],
		ISNULL(float_rate_ref_period_leg_2_time, '') AS [Floating rate reference period leg 2 - Time Period],
		ISNULL(float_rate_ref_period_leg_2_mult, '') AS [Floating rate reference period leg 2 - Multiplier],
		ISNULL(delivery_currency_2, '') AS [Delivery currency 2],
		ISNULL(exchange_rate_1, '') AS [Exchange rate 1],
		ISNULL(forward_exchange_rate, '') AS [Forward exchange rate],
		ISNULL(exchange_rate_basis, '') AS [Exchange rate basis],
		ISNULL(commodity_base, '') AS [Commodity base],
		ISNULL(commodity_details, '') AS [Commodity details],
		ISNULL(delivery_point, '') AS [Delivery point or zone],
		ISNULL(interconnection_point, '') AS [Interconnection Point],
		ISNULL(load_type, '') AS [Load type],
		ISNULL(load_delivery_interval, '') AS [Load delivery intervals],
		ISNULL(delivery_start_date, '') AS [Delivery start date AND time],
		ISNULL(delivery_end_date, '') AS [Delivery end date AND time],
		ISNULL(duration, '') AS [Duration],
		ISNULL(days_of_the_week, '') AS [Days of the week],
		'' AS [Contract capacity],
		ISNULL(delivery_capacity, '') AS [Delivery capacity],
		ISNULL(quantity_unit, '') AS [Quantity Unit],
		ISNULL(price_time_interval_quantity, '') AS [Price/time interval quantities],
		ISNULL(seniority, '') AS [Seniority],
		ISNULL(reference_entity, '') AS [Reference entity],
		ISNULL(frequency_of_payment, '') AS [Frequency of payment],
		ISNULL(calculation_basis, '') AS [The calculation basis],
		ISNULL(series, '') AS [Series],
		ISNULL(version, '') AS [Version],
		ISNULL(dbo.FNARemoveTrailingZeroes(ROUND(index_factor, 4)), '') AS [Index factor],
		ISNULL(tranche, '') AS [Tranche],
		ISNULL(attachment_point, '') AS [Attachment point],
		ISNULL(detachment_point, '') AS [Detachment point],
		ISNULL(dbo.FNARemoveTrailingZeroes(ROUND(contarct_mtm_value, 4)), '') AS [Value of contract],
		ISNULL(contarct_mtm_currency, '') AS [Currency of the value],
		ISNULL(valuation_ts, '') AS [Valuation timestamp],
		ISNULL(valuation_type, '') AS [Valuation type],
		'' AS [Reserved - Participant Use 1],
		'' AS [Reserved - Participant Use 2],
		'' AS [Reserved - Participant Use 3],
		'' AS [Reserved - Participant Use 4],
		'' AS [Reserved - Participant Use 5],
		se.create_date_from [Create Date From],
		se.create_date_to [Create Date To],
		sdv.code [Submission Status],
		se.submission_date [Submission Date],
		se.confirmation_date [Confirmation Date],
		se.process_id [Process ID],
		se.error_validation_message [Error Validation],
		se.file_export_name [Export File Name],
		se.commodity_id [Commodity Id],
		se.document_id [Document Id],
		se.create_user [Create User],
		se.create_ts [Create TS],
		se.update_user [Update User],
		se.update_ts [Update TS]
	FROM source_emir se
	INNER JOIN source_deal_header sdh
		ON sdh.source_deal_header_id = se.source_deal_header_id
	INNER JOIN source_system_book_map ssbm
		ON ssbm.source_system_book_id1 = sdh.source_system_book_id1
			AND ssbm.source_system_book_id2 = sdh.source_system_book_id2
			AND ssbm.source_system_book_id3 = sdh.source_system_book_id3
			AND ssbm.source_system_book_id4 = sdh.source_system_book_id4
	INNER JOIN static_data_value sdv
		ON sdv.value_id = se.submission_status
			AND sdv.type_id = 39500
	WHERE se.process_id = @process_id
END
ELSE IF @flag = 'f'--Generate Excel Detail from MiFID Transaction
BEGIN
	SELECT sm.source_mifid_id AS [MiFID ID],
		   sm.source_deal_header_id AS [Deal ID],
		   sm.deal_id AS [Reference ID],
		   ssbm.logical_name AS sub_book_id,
		   dbo.FNAUSERDateFormat(sdh.deal_date, dbo.FNADBUser()) [Deal Date],
		   sm.[report_status] AS [Report Status],
		   sm.[trans_ref_no] AS [Transaction Reference Number],
		   sm.[trading_trans_id] AS [Trading Venue Transaction ID Code],
		   sm.[exec_entity_id] AS [Executing Entity ID Code],
		   sm.[covered_by_dir] AS [Investment Firm Covered by Directive 2014/65/EU],
		   sm.[submitting_entity_id_code] AS [Submitting Entity ID Code],
		   sm.[buyer_id] AS [Buyer ID Code],
		   sm.[buyer_country] AS [Buyer - Country of the Branch ],
		   sm.[buyer_fname] AS [Buyer - First Name(s)],
		   sm.[buyer_sname] AS [Buyer - Surname(s)],
		   sm.[buyer_dob] AS [Buyer - Date of Birth],
		   sm.[buyer_decision_maker_code] AS [Buyer Decision Maker Code],
		   sm.[buyer_decision_maker_fname] AS [Buyer Decision Maker - First Name(s)],
		   sm.[buyer_decision_maker_sname] AS [Buyer Decision Maker - Surname(s)],
		   CONVERT(VARCHAR(10), sm.[buyer_decision_maker_dob], 120) AS [Buyer Decision Maker - Date of Birth],
		   sm.[seller_id] AS [Seller ID Code],
		   sm.[seller_country] AS [Seller - Country of the Branch],
		   sm.[seller_fname] AS [Seller - First Name(s)],
		   sm.[seller_sname] AS [Seller - Surname(s)],
		   sm.[seller_dob] AS [Seller - Date of Birth],
		   sm.[seller_decision_maker_code] AS [Seller Decision Maker Code],
		   sm.[seller_decision_maker_fname] AS [Seller Decision Maker - First Name(s)],
		   sm.[seller_decision_maker_sname] AS [Seller Decision Maker - Surname(s)],
		   CONVERT(VARCHAR(10), sm.[seller_decision_maker_dob], 120) AS [Seller Decision Maker - Date of Birth],
		   sm.[order_trans_indicator] AS [Transmission of Order Indicator],
		   sm.[buyer_trans_firm_id] AS [Buyer - Transmitting Firm ID Code],
		   sm.[seller_trans_firm_id] AS [Seller - Transmitting Firm ID Code],
		   sm.[trading_date_time] AS [Trading Date Time],
		   sm.[trading_capacity] AS [Trading Capacity],
		   sm.[quantity] AS [Quantity],
		   sm.[quantity_currency] AS [Quantity Currency],
		   sm.[der_notional_incr_decr] AS [Derivative Notional Increase/Decrease],
		   sm.[price] AS [Price],
		   sm.[price_currency] AS [Price Currency],
		   sm.[net_amount] AS [Net Amount],
		   sm.[venue] AS [Venue],
		   sm.[branch_membership_country] AS [Country of the Branch Membership],
		   sm.[upfront_payment] AS [Upfront Payment],
		   sm.[upfront_payment_currency] AS [Upfront Payment Currency],
		   sm.[complex_trade_component_id] AS [Complex Trade Component ID],
		   sm.[instrument_id_code] AS [Instrument ID Code],
		   sm.[instrument_name] AS [Instrument Full Name],
		   sm.[instrument_classification] AS [Instrument Classification],
		   sm.[notional_currency_1] AS [Notional Currency 1],
		   sm.[notional_currency_2] AS [Notional Currency 2],
		   sm.[price_multiplier] AS [Price Multiplier],
		   sm.[underlying_instrument_code] AS [Underlying Instrument Code],
		   sm.[underlying_index_name] AS [Underlying Index Name],
		   sm.[underlying_index_term] AS [Term of the Underlying Index],
		   sm.[option_type] AS [Option Type],
		   sm.[strike_price] AS [Strike Price],
		   sm.[strike_price_currency] AS [Strike Price Currency],
		   sm.[option_exercise_style] AS [Option Exercise Style],
		   NULLIF(sm.[maturity_date], '') AS [Maturity Date],
		   sm.[expiry_date] AS [Expiry Date],
		   sm.[delivery_type] AS [Delivery Type],
		   sm.[firm_invest_decision] AS [Investment Decision within Firm],
		   sm.[decision_maker_country] AS [Decision Maker - Country of the Branch],
		   sm.[firm_execution] AS [Execution within Firm],
		   sm.[supervising_execution_country] AS [Supervising Execution - Country of the Branch],
		   sm.[waiver_indicator] AS [Waiver Indicator],
		   sm.[short_selling_indicator] AS [Short Selling Indicator],
		   sm.[otc_post_trade_indicator] AS [OTC Post-Trade Indicator],
		   sm.[commodity_derivative_indicator] AS [Commodity Derivative Indicator],
		   sm.[securities_financing_transaction_indicator] AS [Securities Financing Transaction Indicator],
		   sm.report_type AS [Report type],
		   sm.create_date_from AS [Create Date From],
		   sm.create_date_to AS [Create Date To],
		   sdv.code AS [Submission Status],
		   sm.submission_date AS [Submission Date],
		   sm.confirmation_date AS [Confirmation Date],
		   sm.process_id AS [Process ID],
		   sm.error_validation_message AS [Error Validations],
		   sm.file_export_name AS [Export File Name],
		   sm.hash_of_concatenated_values AS [Hash Of Concatenated Values],
		   sm.progressive_number AS [Progressive Number],
		   sm.create_user AS [Create User],
		   sm.create_ts AS [Create Timestamp],
		   sm.update_user AS [Update User],
		   sm.update_ts AS [Update Timestamp]
	FROM source_mifid sm
	INNER JOIN source_deal_header sdh
		ON sdh.source_deal_header_id = sm.source_deal_header_id
	INNER JOIN source_system_book_map ssbm
		ON ssbm.source_system_book_id1 = sdh.source_system_book_id1
			AND ssbm.source_system_book_id2 = sdh.source_system_book_id2
			AND ssbm.source_system_book_id3 = sdh.source_system_book_id3
			AND ssbm.source_system_book_id4 = sdh.source_system_book_id4
	INNER JOIN static_data_value sdv
	  ON sdv.value_id = sm.submission_status
	  AND sdv.type_id = 39500
	WHERE sm.process_id = @process_id
END
ELSE IF @flag = 'h'
BEGIN
	SELECT smt.source_deal_header_id [Deal ID],
		   smt.deal_id [Reference ID],
		   ssbm.logical_name [Sub Book],
		   dbo.FNAUSERDateFormat(sdh.deal_date, dbo.FNADBUser()) [Deal Date],
		   trading_date_and_time [Trading Date AND Time],
		   instrument_identification_code_type [Instrument Identification Code Type],
		   instrument_identification_code [Instrument Identification Code],
		   dbo.FNARemoveTrailingZeroes(ROUND(price, 4)) [Price],
		   venue_of_execution [Venue of Execution],
		   price_notation [Price Notation],
		   price_currency [Price Currency],
		   notation_quantity_measurement_unit [Notation of the Quantity in Measurement Unit],
		   dbo.FNARemoveTrailingZeroes(ROUND(quantity_measurement_unit, 4)) [Quantity in Measurement Unit],
		   dbo.FNARemoveTrailingZeroes(ROUND(quantity, 4)) [Quantity],
		   dbo.FNARemoveTrailingZeroes(ROUND(notional_amount, 4)) [Notional Amount],
		   notional_currency [Notional Currency],
		   type [Type],
		   publication_date_and_time [Publication Date AND Time],
		   --venue_of_publication [Venue of Publication],
		   transaction_identification_code [Transaction Identification Code],
		   transaction_to_be_cleared [Transaction to be Cleared],
		   flags [Flags],
		   supplimentary_deferral_flags [Supplimentary Defferal Flags],
		   trade_report_id [Trade Report ID],
		   trade_version [Trade Version],
		   trade_report_type [Trade Report Type],
		   trade_report_reject_reason [Trade Report Reject Reason],
		   CASE WHEN trade_report_trans_type = 0 THEN 'New' WHEN trade_report_trans_type = 1 THEN 'Cancel' WHEN trade_report_trans_type = 2 THEN 'Modified' END [Trade Report Trans Type],
		   package_id [Package ID],
		   trade_number [Trade Number],
		   total_num_trade_reports [Total Num Trade Reports],
		   security_id [Security ID],
		   security_id_source [Security ID Source],
		   unit_of_measure [Unit Of Measure],
		   contract_multiplier [Contract Multiplier],
		   reporting_party_lei [Reporting Party LEI],
		   submitting_party_lei [Submitting Party LEI],
		   submitting_party_si_status [Submitting Party SI Status],
		   asset_class [Asset Class],
		   contract_type [Contract Type],
		   asset_sub_class [AssetSubClass],
		   maturity_date [MaturityDate],
		   freight_size [FreightSize],
		   specific_route_or_time_charter_average [SpecificRouteOrTimeCharterAverage],
		   settlement_location [SettlementLocation],
		   reference_rate [ReferenceRate],
		   ir_term_of_contract [IRTermOfContract],
		   parameter [Parameter],
		   notional_currency2 [NotionalCurrency2],
		   series [Series],
		   version [Version],
		   roll_months [RollMonths],
		   next_roll_date [NextRollDate],
		   CASE WHEN smt.option_type = 1 THEN 'Call' WHEN smt.option_type = 2 THEN 'Put' END [OptionType],
		   strike_price [StrikePrice],
		   strike_currency [StrikeCurrency],
		   exercise_style [ExerciseStyle],
		   delivery_type [DeliveryType],
		   transaction_type [TransactionType],
		   final_price_type [FinalPriceType ],
		   floating_rate_of_leg2 [FloatingRateOfLeg2],
		   ir_term_of_contract_leg2 [IRTermOfContractLeg2 ],
		   issue_date [IssueDate ],
		   settl_currency [SettlCurrency ],
		   notional_schedule [NotionalSchedule ],
		   valuation_method_trigger [ValuationMethodTrigger ],
		   return_or_payout_trigger [ReturnorPayoutTrigger ],
		   debt_seniority [DebtSeniority ],
		   dsb_use_case [DSBUseCase ],
		   no_underlyings [NoUnderlyings ],
		   underlying_symbol [UnderlyingSymbol ],
		   underlying_security_type [UnderlyingSecurityType ],
		   underlying_issuer [UnderlyingIssuer ],
		   underlying_maturity_date [UnderlyingMaturityDate],
		   underlying_issue_date [UnderlyingIssueDate ],
		   underlying_security_id [UnderlyingSecurityID],
		   underlying_security_id_source [UnderlyingSecurityIDSource],
		   underlying_index_name [UnderlyingIndexName ],
		   underlying_issuer_type [UnderlyingIssuerType ],
		   underlying_index_term [UnderlyingIndexTerm ],
		   underlying_further_sub_product [UnderlyingFurtherSubProduct],
		   underlying_other_security_type [UnderlyingOtherSecurityType],
		   underlying_other_further_sub_product [UnderlyingOtherFurtherSubProduct],
		   side,
		   counterparty_partyid_lei,
		   error_validation_message [Error Validations]
	FROM source_mifid_trade smt
	INNER JOIN source_deal_header sdh
		ON sdh.source_deal_header_id = smt.source_deal_header_id
	INNER JOIN source_system_book_map ssbm
		ON ssbm.source_system_book_id1 = sdh.source_system_book_id1
			AND ssbm.source_system_book_id2 = sdh.source_system_book_id2
			AND ssbm.source_system_book_id3 = sdh.source_system_book_id3
			AND ssbm.source_system_book_id4 = sdh.source_system_book_id4
	INNER JOIN static_data_value sdv
	  ON sdv.value_id = smt.submission_status
	  AND sdv.type_id = 39500
	WHERE smt.process_id = @process_id
END
ELSE IF @flag = 'c'
BEGIN
	SELECT sdh.source_deal_header_id [Deal ID],
		   se.deal_id + ' ' [Deal Ref ID],
		   ssbm.logical_name [Sub Book],
		   dbo.FNAUSERDateFormat(sdh.deal_date, dbo.FNADBUser()) [Deal Date],
		   'CollateralizedPortfolioLevel' [*Comment],
		   'Coll1.0' [Version],
		   message_type [Message Type],
		   data_submitter_message_id [Data Submitter Message ID],
		   [action] [Action],
		   data_submitter_prefix [Data Submitter prefix],
		   data_submitter_value [Data Submitter value],
		   trade_party_prefix [Trade Party Prefix],
		   trade_party_value [Trade Party Value],
		   execution_agent_party_prefix [Execution Agent Party Prefix],
		   execution_agent_party_value [Execution Agent Party Value],
		   collateral_portfolio_code [Collateral Portfolio Code],
		   collateral_portfolio [Collateral Portfolio],
		   value_of_the_collateral [Value of the collateral],
		   currency_of_the_collateral [Currency of the collateral],
		   collateral_valuation_date_time [Collateral Valuation Date Time],
		   collateral_reporting_date [Collateral Reporting Date],
		   send_to [sendTo],
		   execution_agent_masking_indicator [Execution Agent Masking Indicator],
		   trade_party_reporting_obligation [Trade Party Reporting Obligation],
		   other_party_id_type [Other Party ID Type],
		   other_party_id [Other Party ID],
		   collateralized [Collateralized],
		   initial_margin_posted [Initial Margin Posted],
		   initial_margin_posted_currency [Currency of the initial margin posted],
		   initial_margin_received [Initial Margin Received],
		   initial_margin_received_currency [Currency of the initial margin received],
		   variation_margin_posted [Variation Margin Posted],
		   variation_margin_posted_currency [Currency of the Variation Margin Posted],
		   variation_margin_received [Variation Margin Received],
		   variation_margin_received_currency [Currency of the variation margin received],
		   excess_collateral_posted [Excess Collateral Posted],
		   excess_collateral_posted_currency [Currency of the Excess Collateral Posted],
		   excess_collateral_received [Excess Collateral Received],
		   excess_collateral_received_currency [Currency of the Excess Collateral received],
		   third_party_viewer [Third Party Viewer],
		   reserved_participant_use_1 [Reserved - Participant Use 1],
		   reserved_participant_use_2 [Reserved - Participant Use 2],
		   reserved_participant_use_3 [Reserved - Participant Use 3],
		   reserved_participant_use_4 [Reserved - Participant Use 4],
		   reserved_participant_use_5 [Reserved - Participant Use 5],
		   action_type_party_1 [Action Type Party 1],
		   third_party_viewer_id_type [Third Party Viewer ID Type],
		   [level] [Level],
		   error_validation_message [Error]
	FROM source_emir_collateral se
	INNER JOIN source_deal_header sdh
		ON sdh.source_deal_header_id = se.source_deal_header_id
	INNER JOIN source_system_book_map ssbm
		ON ssbm.source_system_book_id1 = sdh.source_system_book_id1
			AND ssbm.source_system_book_id2 = sdh.source_system_book_id2
			AND ssbm.source_system_book_id3 = sdh.source_system_book_id3
			AND ssbm.source_system_book_id4 = sdh.source_system_book_id4
	INNER JOIN static_data_value sdv
		ON sdv.value_id = se.submission_status
			AND sdv.type_id = 39500
	WHERE se.process_id = @process_id
END
ELSE IF @flag = 'z'
BEGIN
	SELECT 'BENC' id, 'BENC' code UNION ALL
	SELECT 'ACTX', 'ACTX' UNION ALL
	SELECT 'NPFT', 'NPFT' UNION ALL
	SELECT 'LRGS', 'LRGS' UNION ALL
	SELECT 'ILQD', 'ILQD' UNION ALL
	SELECT 'SIZE', 'SIZE' UNION ALL
	SELECT 'CANC', 'CANC' UNION ALL
	SELECT 'AMND', 'AMND' UNION ALL
	SELECT 'SDIV', 'SDIV' UNION ALL
	SELECT 'RFPT', 'RFPT' UNION ALL
	SELECT 'NLIQ', 'NLIQ' UNION ALL
	SELECT 'OILQ', 'OILQ' UNION ALL
	SELECT 'PRIC', 'PRIC' UNION ALL
	SELECT 'ALGO', 'ALGO' UNION ALL
	SELECT 'RPRI', 'RPRI' UNION ALL
	SELECT 'DUPL', 'DUPL' UNION ALL
	SELECT 'TNCP', 'TNCP' UNION ALL
	SELECT 'TPA', 'TPA' UNION ALL
	SELECT 'XFPH', 'XFPH'
END
ELSE IF @flag = 'm'
BEGIN
	SELECT source_emir_id [EMIR ID],
		   sdh.source_deal_header_id [Deal ID],
		   se.deal_id [Deal Ref ID],
		   ssbm.logical_name [Sub Book],
		   se.reporting_timestamp [Reporting timestamp],
		   '' [*Comment],
		   action_type [Action],
		   'EULITE1.0' [Message Version],
		   'Valuation' [Message Type],
		   ISNULL(reporting_entity_id, '') [Report submitting entity ID],
		   ISNULL(se.counterparty_id, '') [Submitted For Party],
		   ISNULL(other_counterparty_id, '') [Trade Party 1 - ID Type],
		   ISNULL(se.counterparty_id, '') [Trade Party 1 - ID],
		   ISNULL(other_counterparty_id, '') [Trade Party 2 - ID Type],
		   ISNULL(counterparty_name, '') [Trade Party 2 - ID],
		   'ESMA' [Trade Party 1 - Reporting Destination],
		   '' [Trade Party 2 - Reporting Destination],
		   '' [Trade Party 1 - Execution Agent ID],
		   '' [Trade Party 2 - Execution Agent ID],
		   '' [Trade Party 1 - Third Party Viewer ID Type],
		   '' [Trade Party 1 - Third Party Viewer ID],
		   'OTC' [Exchange Traded Indicator],
		   CAST(reporting_timestamp AS VARCHAR(10)) [Data Submitter Message ID],
		   '' [Trade Party 1 - Event ID],
		   '' [Trade Party 2 - Event ID],
		   contarct_mtm_value [Value of contract - Trade Party 1],
		   contarct_mtm_currency [Valuation Currency - Trade Party 1],
		   valuation_ts [Valuation Datetime - Trade Party 1],
		   'M' [Valuation Type - Trade Party 1],
		   '' [Value of contract - Trade Party 2],
		   '' [Valuation Currency - Trade Party 2],
		   '' [Valuation Datetime - Trade Party 2],
		   '' [Valuation Type - Trade Party 2],
		   ISNULL(trade_id, '') [Trade ID],
		   ISNULL(cleared, '') [Cleared],
		   'V' [Trade Party 1 - Action Type],
		   '' [Trade Party 2 - Action Type],
		   '' [Reserved - Participant Use 1],
		   '' [Reserved - Participant Use 2],
		   '' [Reserved - Participant Use 3],
		   '' [Reserved - Participant Use 4],
		   '' [Reserved - Participant Use 5],
		   ISNULL(asset_class, '') [Asset Class],
		   'M' [Level],
		   '' [Trade Party 1 - Transaction ID],
		   '' [Trade Party 2 - Transaction ID],
		   '' [Trade Party 2 - Third Party Viewer ID Type],
		   '' [Trade Party 2 - Third Party Viewer ID],
		   error_validation_message [Error]
	FROM source_emir se
	INNER JOIN source_deal_header sdh
		ON sdh.source_deal_header_id = se.source_deal_header_id
	INNER JOIN source_system_book_map ssbm
		ON ssbm.source_system_book_id1 = sdh.source_system_book_id1
			AND ssbm.source_system_book_id2 = sdh.source_system_book_id2
			AND ssbm.source_system_book_id3 = sdh.source_system_book_id3
			AND ssbm.source_system_book_id4 = sdh.source_system_book_id4
	INNER JOIN static_data_value sdv
		ON sdv.value_id = se.submission_status
			AND sdv.type_id = 39500
	WHERE process_id = @process_id	
END
ELSE IF @flag='w'
BEGIN
	SELECT DISTINCT sc.source_counterparty_id, 
					sc.counterparty_name 
	FROM source_deal_header sdh 
		INNER JOIN source_counterparty sc 
		ON sc.source_counterparty_id = sdh.counterparty_id
END

IF @batch_process_id IS NOT NULL AND @batch_report_param IS NOT NULL
BEGIN
	DECLARE @report_name VARCHAR(100), @job_name VARCHAR(100) = 'report_batch_' + @batch_process_id
		
	SET @report_name = CASE WHEN @submission_type = 44703 THEN 'EMIR Report' 
							WHEN @submission_type = 44704 AND @level_mifid = 'X' THEN 'MiFID Transaction Report'
							ELSE 'MiFID Trade Report'
					   END
	SELECT @str_batch_table = dbo.FNABatchProcess('u', @batch_process_id, @batch_report_param, GETDATE(), NULL, NULL)	
	EXEC (@str_batch_table)

	DECLARE @xml_file_name VARCHAR(50)
	DECLARE @file_num INT , @xml_format INT, @file_name VARCHAR(1000) = NULL

	SELECT @xml_format = ISNULL(xml_format, -100000)
	FROM batch_process_notifications bpn
	WHERE bpn.process_id = RIGHT(@batch_process_id, 13)
	
	IF (@submission_type = 44704 AND @level_mifid = 'X')
	BEGIN
		IF EXISTS(SELECT 1 FROM source_mifid WHERE process_id = @process_id AND error_validation_message IS NULL)
		BEGIN
			IF (@xml_format = -100002)
			BEGIN
				--File Name Format changed for AML XML FORMAT to push to ACT FTP = TR_SEIC_ORI_YYYYMMDD_SEQ.TYPE 
				DECLARE @lei VARCHAR(50)
				
				SELECT @lei = a.static_data_udf_values FROM source_mifid sf
				INNER JOIN source_system_book_map ssbm ON ssbm.book_deal_type_map_id = sf.sub_book_id
				INNER JOIN portfolio_hierarchy book ON book.entity_id = ssbm.fas_book_id
				INNER JOIN portfolio_hierarchy stra ON book.parent_entity_id = stra.entity_id
				INNER JOIN portfolio_hierarchy sub ON stra.parent_entity_id = sub.entity_id
				INNER JOIN fas_subsidiaries fs ON fs.fas_subsidiary_id = sub.entity_id
				INNER JOIN source_counterparty sc ON fs.counterparty_id = sc.source_counterparty_id 
				INNER JOIN maintain_udf_static_data_detail_values a ON a.primary_field_object_id = sc.source_counterparty_id
				INNER JOIN application_ui_template_fields autf ON autf.application_field_id = a.application_field_id
				INNER JOIN application_ui_template_definition autd ON autd.application_ui_field_id = autf.application_ui_field_id
				AND autd.field_id = 'lei' AND sf.process_id = @process_id
				
				DECLARE @current_date DATETIME = GETDATE()
				
				DECLARE @file varchar(5000) --'TR_asdasd_123456_0001.xml'
				, @prefix VARCHAR(1000) --= 'TR_asdasd_123456_'
			
				SELECT @prefix = CONCAT('TR_', @lei,'_01_', YEAR(@current_date), FORMAT(@current_date,'MM'),FORMAT(@current_date,'dd') ,'_')				
				
				DECLARE @search_prefix VARCHAR(1000) = @prefix + '*.xml'
				EXEC spa_latest_file_in_directory_with_prefix @file_path, @search_prefix, @file OUTPUT

				SET @file = NULLIF(@file, 'null')
	
				SELECT @file_num = ISNULL(REPLACE(REPLACE(@file, '.xml', ''), @prefix, ''), 0)
				
				SET @file_num += 1
				SELECT @file_name = CASE WHEN LEN(@file_num) = 1 THEN @prefix + '000'+ CAST(@file_num AS VARCHAR(5))
									WHEN LEN(@file_num) = 2 THEN @prefix + '00'+ CAST(@file_num AS VARCHAR(5))
									WHEN LEN(@file_num) = 3 THEN @prefix + '0' + CAST(@file_num AS VARCHAR(5))
									ELSE @prefix + CAST(@file_num AS VARCHAR(5))
									END

				UPDATE source_mifid SET file_export_name = @file_name WHERE process_id = @process_id
				--SELECT @file_path = CONCAT(@file_path, @file_name,  '.xml')
			END

			SELECT @str_batch_table = dbo.FNABatchProcess('c', @batch_process_id, @batch_report_param, DEFAULT, @file_name, @report_name)
			EXEC  (@str_batch_table)

			RETURN
		END
		ELSE
		BEGIN
			EXEC spa_message_board 'u', @user_name, NULL, 'MiFID', 'No data to submit. PLease check <b>MiFID Transaction Error Report</b>', '', '', 's', @job_name, NULL, @batch_process_id, NULL, NULL, NULL, 'y', 
								   'No data to submit.', 'spa_source_emir' , NULL, NULL,NULL, ''
		END
	END
	ELSE IF (@submission_type = 44704 AND @level_mifid = 'T')
	BEGIN
		IF EXISTS(SELECT 1 FROM source_mifid_trade WHERE process_id = @process_id AND error_validation_message IS NULL)
		BEGIN
			SELECT @str_batch_table = dbo.FNABatchProcess('c', @batch_process_id, @batch_report_param, DEFAULT, @file_name, @report_name)
			EXEC (@str_batch_table)
		END
		ELSE
		BEGIN
			EXEC spa_message_board 'u', @user_name, NULL, 'MiFID Trade', 'No data to submit. PLease check <b>MiFID Trade Error Report</b>', '', '', 's', @job_name, NULL, @batch_process_id, NULL, NULL, NULL, 'n', 
									   'No data to submit.', 'spa_source_emir' , NULL, NULL,NULL, ''
		END
	END
	ELSE IF @submission_type = 44703
	BEGIN
		SET @emir_file_name = 'EMIR_EU_Lite ' + CASE WHEN @level IN ('P', 'T') THEN 'CO_' WHEN @level = 'M' THEN 'Valuation' END + CONVERT(VARCHAR(10), GETDATE(), 120) + '.' + REPLACE(CAST(CAST(GETDATE() AS TIME) AS VARCHAR(8)), ':', '_')
		SET @file_name = IIF(@submission_type = 44703, @emir_file_name, @file_name)
		
		IF EXISTS (SELECT 1 FROM source_emir WHERE process_id = @process_id AND error_validation_message IS NULL)
		BEGIN
			IF @tr_rmm NOT IN (116901) 
			BEGIN
				SELECT @str_batch_table = dbo.FNABatchProcess('c', @batch_process_id, @batch_report_param, DEFAULT, @file_name, @report_name)
				EXEC (@str_batch_table)
			END				
		END
		ELSE IF EXISTS (SELECT 1 FROM source_emir_collateral WHERE process_id = @process_id AND error_validation_message IS NULL)
		BEGIN
			SELECT @str_batch_table = dbo.FNABatchProcess('c', @batch_process_id, @batch_report_param, DEFAULT, @file_name, @report_name)
			EXEC (@str_batch_table)
		END
		ELSE
		BEGIN
			--Added to prevent request to web service in case of error
			UPDATE bpn
				SET export_web_services_id = NULL
			FROM   batch_process_notifications bpn
			LEFT JOIN application_role_user aru ON  bpn.role_id = aru.role_Id
			WHERE  bpn.process_id = RIGHT(ISNULL(@job_name, @batch_process_id), 13)
			EXEC spa_message_board 'u', @user_name, NULL, 'EMIR', 'No data to submit. PLease check <b>EMIR Error Report</b>', '', '', 's', @job_name, NULL, @batch_process_id, NULL, NULL, NULL, 'y', 
									'No data to submit.', 'spa_source_emir' , NULL, NULL,NULL, ''
		END
	END
	ELSE
	BEGIN
		SELECT @str_batch_table = dbo.FNABatchProcess('c', @batch_process_id, @batch_report_param, DEFAULT, @file_name, @report_name)
		EXEC  (@str_batch_table)
	END
END
