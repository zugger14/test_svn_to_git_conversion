
IF OBJECT_ID(N'[dbo].[spa_generate_deal_details]', N'P') IS NOT NULL
    DROP PROCEDURE spa_generate_deal_details

GO
 
SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[spa_generate_deal_details]
	@temp_table_name VARCHAR(1250)
AS

/*------------------Debug Section-------------------
DECLARE @temp_table_name VARCHAR(1250)= 'adiha_process.dbo.ixp_source_deal_template_0_dev_admin_5524F5DC_BB25_4304_BE35_A44A0DD4D227'
--------------------------------------------------*/

BEGIN

	DECLARE @sql VARCHAR(MAX), @sql_query VARCHAR(MAX), @id VARCHAR(200) = dbo.FNAGetNewID();
	DECLARE @table_name VARCHAR(MAX) = 'adiha_process.dbo.Import_xlsx_' + dbo.FNADBUser() + '_' + @id;

	SET @sql = 'SELECT DISTINCT  * INTO ' + @table_name + ' FROM '+ @temp_table_name
	EXEC(@sql)

	DECLARE @new_table VARCHAR(MAX) = 'adiha_process.dbo.import_data_' + dbo.FNADBUser() + '_' + @id;

	SET @sql = ' 
		SELECT sub_book,
			   t.deal_id,
			   CONVERT(VARCHAR(10), tbd.[term_start], 120) AS term_start,
			   CONVERT(VARCHAR(10), tbd.[term_end], 120) AS term_end,
			   CAST(ISNULL(t.leg, 1) AS VARCHAR(100)) AS [leg],
			   ISNULL(dbo.FNAClientToSqlDate(t.contract_expiration_date),CONVERT(VARCHAR(10), tbd.[term_end], 120))  AS Expiration_date,
			   ''t'' AS fixed_float_leg,
			   t.[buy_sell_flag] AS Buy_Sell_flag,
			   CAST(0 AS VARCHAR(100)) AS TRADE_PRICE,
			   t.fixed_price_currency_id AS PRICE_CURRENCY,
			   CAST(option_strike_price AS VARCHAR(100)) AS OPTION_STRIKE_PRICE,
			   NULLIF(t.deal_volume, '''') AS DEAL_VOLUME,
			   deal_volume_frequency AS deal_volume_frequency,
			   [deal_volume_uom_id] AS [deal_volume_uom_id],
			   NULL AS BLOCK_DESCRIPTION,
			   NULL AS [DESCRIPTION],
			   NULL AS [FORMULA_ID],
			   CONVERT(VARCHAR(10), t.[deal_date], 120) AS DEAL_DATE,
			   t.ext_deal_id AS ext_deal_id,
			   ISNULL(IIF(t.physical_financial_flag IN (''Physical'', ''p''), ''p'', ''f''), sdht.PHYSICAL_FINANCIAL_FLAG) physical_financial_flag,
			   NULL AS STRUCTURED_DEAL_ID,
			   t.Counterparty_id AS COUNTERPARTY,
			   t.[source_deal_type_id] AS SOURCEDEALTYPEID,
			   NULL SOURCEDEALSUBTYPEID,
			   NULL OPTIONFLAG,
			   NULL OPTIONTYPE,
			   NULL OPTIONEXTYPE,
			   source_system_book_id1,
			   source_system_book_id2,
			   source_system_book_id3,
			   source_system_book_id4,
			   t.description1,
			   t.description2,
			   t.description3,
			   t.description4,
			   t.trader_id,
			   t.block_define_id,
			   fp.profile_id AS [profile_id],
			   t.internal_desk_id,
			   CASE WHEN t.[source_deal_type_id] = ''Physical'' THEN ''s'' ELSE
			   CASE WHEN t.[source_deal_type_id] = ''Capacity NG'' THEN 
			   CASE WHEN ISNULL(t.leg,1)  = 1 THEN ''s'' ELSE ''b'' END
			   ELSE ISNULL(t.[buy_sell_flag],''b'') END
			   END [1B/S],
			   t.broker_id [BROKER],
			   t.[contract_id] [CONTRACT],
			   t.formula_id formula,
			   t.commodity_id COMMODITY,
			   t.location_id LOCATION,
			   NULL PEAKNESS,
			   NULL BROKER_FEE_FLAT,
			   NULL HEAT_RATE,
			   NULL PREMIUM_SETTLEMENT_DATE,
			   NULL CYCLE,
			   NULL TIME_ZONE,
			   t.price_adder PRICE_ADDER,
			   NULL FIXED_COST,
			   NULL DEMAND_CHARGE,
			   ''FIRM'' FIRM,
			   NULL BROKER_FEE_VARIABLE,
			   NULL PREMIUM_FEES,
			   NULL TIMING,
			   t.template_id AS template,
			   t.deal_status,
			   t.deal_category_value_id,
			   curve_id,
			   t.udf_value1,
			   t.udf_value11,
			   udf_value2,
			   udf_value3,
			   udf_value4,
			   udf_value6,
			   udf_value7,
			   formula_curve_id [indexed on],
			   NULL Plant, 
			   NULL Pipeline,
			   [fixed_price],
			   formula_curve_id,
			   t.total_volume total_volume,
			   t.entire_term_start,
			   t.entire_term_end,
			   t.header_buy_sell_flag,
			   import_file_name,
			   t.pricing_type,
			   t.generator_id,
			   t.state_value_id,
			   tier_id,
			   vintage_id,
			   position_uom,
			   t.profile_granularity,
			   t.counterparty_id2,
			   t.multiplier,			   
			   t.fas_deal_type_value_id, 
			   t.standard_yearly_volume,
			   t.option_flag,
			   t.status,
			   t.delivery_date,
			   t.contractual_volume,
			   t.actual_volume,
			   t.schedule_volume,
			   t.match_type,
			   t.meter_id,
			   t.product_classification
		INTO ' + @new_table + '
		FROM '+ @table_name+ '  t 
		LEFT JOIN source_deal_header_template sdht
			ON sdht.template_name = t.template_id
		LEFT JOIN forecast_profile fp
			ON fp.external_id = t.profile_id
		CROSS APPLY (
			SELECT * 
			FROM dbo.FNATermBreakDown(IIF(sdht.term_frequency_type = ''t'', '''', sdht.term_frequency_type), t.term_start, t.term_end)
		) tbd
	'
	EXEC(@sql)
	
	DECLARE @del VARCHAR(1000)
	SET @del = 'DELETE FROM ' + @temp_table_name
	EXEC (@del)

	SET @sql_query = '
	INSERT INTO ' + @temp_table_name + ' (
		sub_book, deal_id, term_start, term_end, leg, contract_expiration_date, fixed_float_leg, buy_sell_flag, fixed_price_currency_id, OPTION_STRIKE_PRICE, deal_volume, deal_volume_frequency,
		deal_volume_uom_id, block_description, formula_id, deal_date, counterparty_id, physical_financial_flag, structured_deal_id, source_system_book_id1, source_system_book_id2, source_system_book_id3,
		source_system_book_id4, trader_id, block_define_id, profile_id, internal_desk_id, Broker_id, contract_id, location_id, price_adder, template_id, deal_status, deal_category_value_id, curve_id, 
		udf_value1, udf_value11, udf_value2, udf_value3, udf_value4, udf_value6, udf_value7, udf_value5, udf_value9, udf_value10, source_system_id, source_deal_type_id, [fixed_price], formula_curve_id,
		import_file_name, header_buy_sell_flag, commodity_id, total_volume, entire_term_start, entire_term_end, pricing_type, generator_id, state_value_id, tier_id, vintage_id, position_uom, profile_granularity, description1, description2, description3, description4,
		counterparty_id2,multiplier, ext_deal_id, fas_deal_type_value_id, standard_yearly_volume, option_flag, status, delivery_date, contractual_volume, actual_volume, schedule_volume, match_type, meter_id, product_classification
		) 
	SELECT sub_book, deal_id, term_start, term_end, leg, expiration_date, fixed_float_leg, buy_sell_flag, price_currency, OPTION_STRIKE_PRICE, deal_volume, deal_volume_frequency,deal_volume_uom_id,
		   block_description, formula, deal_date, counterparty, physical_financial_flag, structured_deal_id, source_system_book_id1, source_system_book_id2, source_system_book_id3, source_system_book_id4,
		   trader_id, block_define_id, profile_id, internal_desk_id, Broker, contract, location, price_adder, template, deal_status, deal_category_value_id, curve_id, udf_value1, udf_value11, udf_value2,
		   udf_value3, udf_value4, udf_value6, udf_value7, [Indexed On], pipeline, Plant, 2, SOURCEDEALTYPEID, [fixed_price], formula_curve_id, import_file_name, header_buy_sell_flag, commodity, total_volume,
		   entire_term_start, entire_term_end, pricing_type, generator_id, state_value_id, tier_id, vintage_id, position_uom, profile_granularity, description1, description2, description3,  description4,
		   counterparty_id2,multiplier , ext_deal_id, fas_deal_type_value_id, standard_yearly_volume, option_flag, status, delivery_date, contractual_volume, actual_volume, schedule_volume, match_type, meter_id, product_classification
	FROM ' + @new_table 

	EXEC (@sql_query)

END
