IF OBJECT_ID(N'[dbo].[spa_import_epex_web_service]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[spa_import_epex_web_service]
GO
 
SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
/**  
	Different data processing for EPEX Web Service

	Parameters
	@flag				: Flag	
							'day_ahead' - For Building EPEX Request body 
							'likron' - For inserting Likron API response json data into process table. 
	@rules_id			: ID of import rule
	@auction_area_id	: ID of Auction Area
	@auction_date		: Date of Auction
	@auction_name_id	: ID of Auction Name
	@process_id			: Process Id
	@process_table		: Process Table
	@response_data      : Response Data
*/

CREATE PROCEDURE [dbo].[spa_import_epex_web_service]
    @flag NVARCHAR(10),
	@rules_id INT = NULL,	
	@auction_area_id INT = NULL,
	@auction_date NVARCHAR(25) = NULL, -- Used NVARCHAR for 2020-02-02 16;06, ':' is used in CLR to separate parameters
	@auction_name_id INT = NULL,
	@process_id NVARCHAR(200) = NULL,
	@process_table NVARCHAR(200) = NULL,
	@response_data NVARCHAR(MAX) = NULL
    
AS
SET NOCOUNT ON

DECLARE @sql NVARCHAR(MAX)
IF @flag = 'day_ahead'
BEGIN
	SELECT 
	REPLACE(REPLACE(REPLACE(REPLACE(REPLACE([request_body],'<__user_name__>', iws.[user_name]), '<__auth_token__>', iws.[auth_token]),'<__auction_area__>', sdv_area.code),'<__auction_date__>', CONVERT(VARCHAR(50), REPLACE(@auction_date, ';', ':'), 126)),'<__auction_name__>', sdv_name.code)
	FROM ixp_import_data_source iids
	INNER JOIN import_web_service iws
		ON iids.clr_function_id = iws.clr_function_id
	INNER JOIN static_data_value sdv_area ON sdv_area.value_id = @auction_area_id AND sdv_area.[type_id] = 112500
	INNER JOIN static_data_value sdv_name ON sdv_name.value_id = @auction_name_id AND sdv_name.[type_id] = 112600		
	WHERE rules_id = @rules_id
END

IF @flag = 'likron'
BEGIN
	SELECT *
	INTO #temp_likron_table
	FROM OPENJSON(@response_data)
	  WITH (
		trader_id NVARCHAR(200) '$.TraderId'
		, related_order_id NVARCHAR(200) '$.RelatedOrderId'
		, underlying_start NVARCHAR(200) '$.TradedUnderlying.UnderlyingStart'
		, underlying_end NVARCHAR(200) '$.TradedUnderlying.UnderlyingEnd'
		, delivery_start_local_time NVARCHAR(200) '$.TradedUnderlying.DeliveryStart.LocalTime'
		, delivery_start_local_time_cet NVARCHAR(200) '$.TradedUnderlying.DeliveryStart.LocalTimeCet'
		, delivery_start_utc_time NVARCHAR(200) '$.TradedUnderlying.DeliveryStart.UtcTime'
		, delivery_start_ticks NVARCHAR(200) '$.TradedUnderlying.DeliveryStart.Ticks'
		, delivery_start_local_date NVARCHAR(200) '$.TradedUnderlying.DeliveryStart.LocalDate'
		, delivery_end_local_time NVARCHAR(200) '$.TradedUnderlying.DeliveryEnd.LocalTime'
		, delivery_end_local_time_cet NVARCHAR(200) '$.TradedUnderlying.DeliveryEnd.LocalTimeCet'
		, delivery_end_utc_time NVARCHAR(200) '$.TradedUnderlying.DeliveryEnd.UtcTime'
		, delivery_end_ticks NVARCHAR(200) '$.TradedUnderlying.DeliveryEnd.Ticks'
		, delivery_end_local_date NVARCHAR(200) '$.TradedUnderlying.DeliveryEnd.LocalDate'
		, [type] NVARCHAR(200) '$.TradedUnderlying.Type'
		, [name] NVARCHAR(200) '$.TradedUnderlying.Name'
		, short_name NVARCHAR(200) '$.TradedUnderlying.ShortName'
		, daylight_change_suffix NVARCHAR(200) '$.TradedUnderlying.DaylightChangeSuffix'
		, is_hour NVARCHAR(200) '$.TradedUnderlying.IsHour'
		, is_quarter NVARCHAR(200) '$.TradedUnderlying.IsQuarter'
		, is_half_hour NVARCHAR(200) '$.TradedUnderlying.IsHalfHour'
		, is_block NVARCHAR(200) '$.TradedUnderlying.IsBlock'
		, major_type NVARCHAR(200) '$.TradedUnderlying.MajorType'
		, traded_underlying_delivery_day NVARCHAR(200) '$.TradedUnderlying.DeliveryDay'
		, delivery_hour NVARCHAR(200) '$.TradedUnderlying.DeliveryHour'
		, scaling_factor NVARCHAR(200) '$.TradedUnderlying.ScalingFactor'
		, tso_name NVARCHAR(200) '$.TsoName'
		, tso NVARCHAR(200) '$.Tso'
		, target_tso NVARCHAR(200) '$.TargetTso'
		, is_buy_trade NVARCHAR(200) '$.IsBuyTrade'
		, quantity NVARCHAR(200) '$.Quantity'
		, price NVARCHAR(200) '$.Price'
		, trade_id NVARCHAR(200) '$.TradeId'
		, exchange_id NVARCHAR(200) '$.ExchangeId'
		, external_trade_id NVARCHAR(200) '$.ExternalTradeId'
		, execution_time_local_time NVARCHAR(200) '$.ExecutionTime.LocalTime'
		, execution_time_local_time_cet NVARCHAR(200) '$.ExecutionTime.LocalTimeCet'
		, execution_utc_time NVARCHAR(200) '$.ExecutionTime.UtcTime'
		, execution_ticks NVARCHAR(200) '$.ExecutionTime.Ticks'
		, execution_local_date NVARCHAR(200) '$.ExecutionTime.LocalDate'
		, strategy_order_id NVARCHAR(200) '$.StrategyOrderId'
		, external_order_id NVARCHAR(200) '$.ExternalOrderId'
		, [text] NVARCHAR(200) '$.Text'
		, [state] NVARCHAR(200) '$.State'
		, strategy_name NVARCHAR(200) '$.StrategyName'
		, trading_cost_group NVARCHAR(200) '$.TradingCostGroup'
		, pre_arranged NVARCHAR(200) '$.PreArranged'
		, pre_arranged_type NVARCHAR(200) '$.PreArrangedType'
		, com_xerv_eic NVARCHAR(200) '$.ComXervEic'
		, user_code NVARCHAR(200) '$.UserCode'
		, com_xerv_account_type NVARCHAR(200) '$.ComXervAccountType'
		, balance_group NVARCHAR(200) '$.BalanceGroup'
		, portfolio NVARCHAR(200) '$.Portfolio'
		, analysis_info NVARCHAR(200) '$.AnalysisInfo'
		, self_trade NVARCHAR(200) '$.SelfTrade'
		, com_xerv_product NVARCHAR(200) '$.ComXervProduct'
		, [contract] NVARCHAR(200) '$.Contract'
		, signed_quantity NVARCHAR(200) '$.SignedQuantity'
		, scaled_quantity NVARCHAR(200) '$.ScaledQuantity'
		, exchange_key NVARCHAR(200) '$.ExchangeKey'
		, product_name NVARCHAR(200) '$.ProductName'
		, buy_or_sell NVARCHAR(200) '$.BuyOrSell'
		, delivery_day NVARCHAR(200) '$.DeliveryDay'
		, contract_type NVARCHAR(200) '$.ContractType'
		, delivery_date DATETIME 
		, [hour] INT 
		, [minutes] INT
	  );

	EXEC('SELECT trader_id, related_order_id, underlying_start, underlying_end, delivery_start_local_time, delivery_start_local_time_cet, delivery_start_utc_time, delivery_start_ticks, delivery_start_local_date, delivery_end_local_time, delivery_end_local_time_cet, delivery_end_utc_time, delivery_end_ticks, delivery_end_local_date, type, name, short_name, daylight_change_suffix, is_hour, is_quarter, is_half_hour, is_block, major_type, traded_underlying_delivery_day, delivery_hour, scaling_factor, tso_name, tso, target_tso, is_buy_trade, quantity, price, trade_id, exchange_id, external_trade_id, execution_time_local_time, execution_time_local_time_cet, execution_utc_time, execution_ticks, execution_local_date, strategy_order_id, external_order_id, text, state, strategy_name, trading_cost_group, pre_arranged, pre_arranged_type, com_xerv_eic, user_code, com_xerv_account_type, balance_group, portfolio, analysis_info, self_trade, com_xerv_product, contract, signed_quantity, scaled_quantity, exchange_key, product_name, buy_or_sell, delivery_day, contract_type, CONVERT(datetime, SWITCHOFFSET(CAST([delivery_end_utc_time] AS DATETIME), DATEPART(TZOFFSET, CAST([delivery_end_utc_time] AS DATETIME) AT TIME ZONE ''Central Europe Standard Time''))) delivery_date ,DATEPART(HOUR, CONVERT(datetime, SWITCHOFFSET(CAST([delivery_end_utc_time] AS DATETIME), DATEPART(TZOFFSET, CAST([delivery_end_utc_time] AS DATETIME) AT TIME ZONE ''Central Europe Standard Time'')))) [hour], DATEPART(MINUTE, CONVERT(datetime, SWITCHOFFSET(CAST([delivery_end_utc_time] AS DATETIME), DATEPART(TZOFFSET, CAST([delivery_end_utc_time] AS DATETIME) AT TIME ZONE ''Central Europe Standard Time'')))) minutes INTO '+ @process_table +' FROM #temp_likron_table')
END

GO
