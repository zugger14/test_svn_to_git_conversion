/****** Object:  StoredProcedure [dbo].[spa_import_temp_table]    Script Date: 11/25/2011 09:43:25 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[spa_import_temp_table]') AND TYPE IN (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_import_temp_table]
GO

/****** Object:  StoredProcedure [dbo].[spa_import_temp_table]    Script Date: 11/25/2011 09:43:25 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[spa_import_temp_table]
	@table_id		VARCHAR(200),
	@process_id		VARCHAR(50) = NULL,
	@user_login_id		VARCHAR(100) = NULL
AS
DECLARE @temptablename	VARCHAR(128)
--DECLARE @user_login_id	VARCHAR(50)
DECLARE @sql			VARCHAR(8000)
DECLARE @tablename		VARCHAR(200)

IF @table_id IN  (
	'rec_transaction'
	, 'gis_rec_transaction'
 	, 'rec_loadstar'
 	, 'contract_price'
 	, 'import_edr'
 	, 'hourly_data'
 	, 'stage_generator'
 	, 'rec_loadstar_mins'
 	, 'deal_detail_hour_lrs'
 	, 'deal_detail_hour_csv'
 	, 'source_deal_detail_hour'
 	, 'mv90_data_mins'
 	, 'holiday_group'
 	, 'Storage_Schedule_Import'
 	, 'imbalance_volume'
)
BEGIN
	 SET @tablename = @table_id
END
ELSE
BEGIN
	SELECT @tablename=code FROM static_data_value WHERE value_id=@table_id
END

IF @process_id IS NULL 
	SET @process_id = REPLACE(NEWID(),'-','_')
	
SET @user_login_id=ISNULL(@user_login_id,dbo.FNADBUser())

SET @temptablename=dbo.FNAProcessTableName(@tablename, @user_login_id, @process_id)
EXEC spa_print @tablename
--create temporary table to store data from external file
IF @tablename='source_book'
	SET @sql = 'CREATE TABLE ' + @temptablename + '(
					[source_book_id] [varchar] (100) ,
					[source_system_id] [varchar] (100) ,
					[source_system_book_id] [varchar] (100) ,
					[source_system_book_type_value_id] [varchar] (100) ,
					[source_book_name] [varchar] (260) ,
					[source_book_desc] [varchar] (260) ,
					[source_parent_book_id] [varchar] (100) ,
					[source_parent_type] [varchar] (100) ,
					[table_code] [varchar] (100))'
ELSE IF @tablename = 'RECs_Actual'
	SET @sql = 'create table ' + @temptablename + '(
		generator VARCHAR(1000),
		[monthly term] VARCHAR(1000),
		volume VARCHAR(1000),
		[contract volume] VARCHAR(1000),
		[invoice volume] VARCHAR(1000),
		[price] VARCHAR(1000),
		[cert from] VARCHAR(1000), 
		[cert to] VARCHAR(1000),
		[Utility Cost] VARCHAR(1000),
		[Participant Cost] VARCHAR(1000),
		[Total Resource Cost] VARCHAR(1000),
		[Sub-Book1] VARCHAR(1000))'
ELSE IF @tablename = 'NCRETS'
 SET @sql = 'create table ' + @temptablename + ' (
		[satType] VARCHAR(1000),
		[Sub-Account] VARCHAR(1000),
		[Sub-Account ID] VARCHAR(1000),
		[NC-RETS ID] VARCHAR(1000),
		[Project Name] VARCHAR(1000),
		[Unit Name] VARCHAR(1000),
		[Project Owner Company Name] VARCHAR(1000),
		[Fuel/Project Type] VARCHAR(1000),
		[Certificate Vintage] VARCHAR(1000),
		[Year] VARCHAR(1000),
		[Month] VARCHAR(1000),
		[Certificate Serial Numbers] VARCHAR(1000),
		[Quantity] VARCHAR(1000),
		[NC] VARCHAR(1000),
		[Green-e Energy Eligible] VARCHAR(1000),
		[LIHI Certified] VARCHAR(1000),
		[In State] VARCHAR(1000),
		[Cost Recovery Year] VARCHAR(1000)
		)'
ELSE IF @tablename = 'NCRETS_Retirement'
	SET @sql = 'create table ' + @temptablename + '(
		generator VARCHAR(1000),
		[monthly term] VARCHAR(1000),
		volume VARCHAR(1000),
		[member] VARCHAR(1000),
		[percentage] VARCHAR(1000),
		[cert from] VARCHAR(1000), 
		[cert to] VARCHAR(1000),
		[compliance YEAR] VARCHAR(1000),
		[Sub-book1] VARCHAR(1000),
		[Sub-book2] VARCHAR(1000))'				
ELSE IF @tablename='source_commodity'
	SET @sql = 'CREATE TABLE ' + @temptablename + '(
					[source_commodity_id] [varchar] (100) ,
					[source_system_id] [varchar] (100) ,
					[commodity_id] [varchar] (100) ,
					[commodity_name] [varchar] (260) ,
					[commodity_desc] [varchar] (260) ,
					[table_code] [varchar] (100)
				)'
				
ELSE IF @tablename='contract_group'
	SET @sql = 'CREATE TABLE ' + @temptablename + '(
					[contract_id] [varchar] (100) ,		
					[source_system_id] [varchar] (100) ,
					[source_contract_id] [varchar] (100) ,		
					[contract_name] [varchar] (260) ,
					[contract_desc] [varchar] (260) ,
					[table_code] [varchar] (100)
				)'
				
ELSE IF @tablename='source_counterparty'
	SET @sql = 'CREATE TABLE ' + @temptablename + '(
					[source_counterparty_id] [varchar] (100) ,
					[source_system_id] [varchar] (100) ,
					[counterparty_id] [varchar] (100) ,
					[counterparty_name] [varchar] (260) ,
					[counterparty_desc] [varchar] (260) ,
					[int_ext_flag] [varchar] (100) ,
					[netting_parent_counterparty_id] [varchar] (100) ,
					[table_code] [varchar] (100)
				)'
				
ELSE IF @tablename='source_legal_entity'
	SET @sql = 'CREATE TABLE ' + @temptablename + '(
					[source_legal_entity_id] varchar(100),
					[source_system_id] varchar(100),
					[legal_entity_id] varchar(100),
					[legal_entity_name] [varchar](1000),
					[legal_entity_desc] [varchar](1000),
					[table_code] [varchar] (100)
				)'
				
ELSE IF @tablename='source_currency'
	SET @sql = 'CREATE TABLE ' + @temptablename + '(
					[source_currency_id] [varchar] (100) ,
					[source_system_id] [varchar] (100) ,
					[currency_id] [varchar] (100) ,
					[currency_name] [varchar] (260) ,
					[currency_desc] [varchar] (260) ,
					[table_code] [varchar] (100)
				)'
				
ELSE IF @tablename='source_deal_detail_hour'
	SET @sql = 'CREATE TABLE ' + @temptablename + '(
					[source_deal_header_id] INT NULL,
					[deal_id] [varchar] (100) NULL,
					[date] [varchar] (100) ,
					[hour] [varchar] (260) ,
					[volume] [varchar] (260) ,
					[price] [varchar] (100),
					[leg] [varchar] (100) 
				)'
ELSE IF @tablename='source_deal_detail'
	SET @sql = 'CREATE TABLE ' + @temptablename + '(
					[deal_id] [varchar] (100) , 
					[source_system_id] [varchar] (100) ,
					[term_start] [varchar] (100) , 
					[term_end] [varchar] (100) , 
					[Leg] [varchar] (100) , 
					[contract_expiration_date] [varchar] (100) ,
 					[fixed_float_leg] [varchar] (100) , 
					[buy_sell_flag] [varchar] (100) , 
					[curve_id] [varchar] (100) , 
					[fixed_price] [varchar] (100) , 
					[fixed_price_currency_id] [varchar] (100) , 	
					[option_strike_price] [varchar] (100) , 
					[deal_volume] [varchar] (100) , 
					[deal_volume_frequency] [varchar] (100) , 
					[deal_volume_uom_id] [varchar] (100) , 
					[block_description] [varchar] (260) , 
					[deal_detail_description] [varchar] (260) , 
					[formula_id] [varchar] (100) , 
					[deal_date] [varchar] (100) , 
					[ext_deal_id] [varchar] (100) , 
					[physical_financial_flag] [varchar] (100) , 
					[structured_deal_id] [varchar] (100) , 
					[counterparty_id] [varchar] (100) ,
					[source_deal_type_id] [varchar] (100) ,
					[source_deal_sub_type_id] [varchar] (100) , 
					[option_flag] [varchar] (100) , 
					[option_type] [varchar] (100) , 
					[option_excercise_type] [varchar] (100) , 
					[source_system_book_id1] [varchar] (100) , 
					[source_system_book_id2] [varchar] (100) , 
					[source_system_book_id3] [varchar] (100) ,
					[source_system_book_id4] [varchar] (100) , 
					[description1] [varchar] (260) ,
					[description2] [varchar] (260) ,
					[description3] [varchar] (260) , 
					[deal_category_value_id] [varchar] (100) , 
					[trader_id] [varchar] (100) , 
					[header_buy_sell_flag] [varchar] (100) , 
					[broker_id] [varchar] (100) , 
					[contract_id] [varchar] (100),
					legal_entity varchar(100), 
					[table_code] [varchar] (100))'

ELSE IF @tablename='source_deal_detail_rwe_de'
	SET @sql='CREATE TABLE ' + @temptablename + '(
				[deal_id] [varchar] (100) , 
				[source_system_id] [varchar] (100) ,
				[term_start] [varchar] (100) , 
				[term_end] [varchar] (100) , 
				[Leg] [varchar] (100) , 
				[contract_expiration_date] [varchar] (100) ,
 				[fixed_float_leg] [varchar] (100) , 
				[buy_sell_flag] [varchar] (100) , 
				[curve_id] [varchar] (100) , 
				[fixed_price] [varchar] (100) , 
				[fixed_price_currency_id] [varchar] (100) , 	
				[option_strike_price] [varchar] (100) , 
				[deal_volume] [varchar] (100) , 
				[deal_volume_frequency] [varchar] (100) , 
				[deal_volume_uom_id] [varchar] (100) , 
				[block_description] [varchar] (260) , 
				[deal_detail_description] [varchar] (260) , 
				[formula_id] [varchar] (100) , 
				[deal_date] [varchar] (100) , 
				[ext_deal_id] [varchar] (100) , 
				[physical_financial_flag] [varchar] (100) , 
				[structured_deal_id] [varchar] (100) , 
				[counterparty_id] [varchar] (100) ,
				[source_deal_type_id] [varchar] (100) ,
				[source_deal_sub_type_id] [varchar] (100) , 
				[option_flag] [varchar] (100) , 
				[option_type] [varchar] (100) , 
				[option_excercise_type] [varchar] (100) , 
				[source_system_book_id1] [varchar] (100) , 
				[source_system_book_id2] [varchar] (100) , 
				[source_system_book_id3] [varchar] (100) ,
				[source_system_book_id4] [varchar] (100) , 
				[description1] [varchar] (260) ,
				[description2] [varchar] (260) ,
				[description3] [varchar] (260) ,
				[description4] [varchar] (260) , 
				[deal_category_value_id] [varchar] (100) , 
				[trader_id] [varchar] (100) , 
				[header_buy_sell_flag] [varchar] (100) , 
				[broker_id] [varchar] (100) , 
				[contract_id] [varchar] (100),
				[legal_entity] varchar(100), 
				[table_code] [varchar] (100),
				[reference] [VARCHAR] (100),
				[internal_portfolio_id] [VARCHAR] (50),
				[internal_desk_id] [VARCHAR] (50),
				[product_id] [VARCHAR] (50),
				[settlement_date] [VARCHAR] (30),
				[option_settlement_date] [VARCHAR] (30),
				[trade_status] VARCHAR(30),
				[template] VARCHAR(50)
				)'
				
--this is new format for essent
ELSE IF @tablename='source_deal_detail_essent'
	SET @sql = 'CREATE TABLE ' + @temptablename + '(
					[deal_id] [varchar] (100) , 
					[source_system_id] [varchar] (100) ,
					[term_start] [varchar] (100) , 
					[term_end] [varchar] (100) , 
					[Leg] [varchar] (100) , 
					[contract_expiration_date] [varchar] (100) ,
 					[fixed_float_leg] [varchar] (100) , 
					[buy_sell_flag] [varchar] (100) , 
					[curve_id] [varchar] (100) , 
					[fixed_price] [varchar] (100) , 
					[fixed_price_currency_id] [varchar] (100) , 	
					[option_strike_price] [varchar] (100) , 
					[deal_volume] [varchar] (100) , 
					[deal_volume_frequency] [varchar] (100) , 
					[deal_volume_uom_id] [varchar] (100) , 
					[block_description] [varchar] (260) , 
					[deal_detail_description] [varchar] (260) , 
					[formula_id] [varchar] (100) , 
					[deal_date] [varchar] (100) , 
					[ext_deal_id] [varchar] (100) , 
					[physical_financial_flag] [varchar] (100) , 
					[structured_deal_id] [varchar] (100) , 
					[counterparty_id] [varchar] (100) ,
					[source_deal_type_id] [varchar] (100) ,
					[source_deal_sub_type_id] [varchar] (100) , 
					[option_flag] [varchar] (100) , 
					[option_type] [varchar] (100) , 
					[option_excercise_type] [varchar] (100) , 
					[source_system_book_id1] [varchar] (100) , 
					[source_system_book_id2] [varchar] (100) , 
					[source_system_book_id3] [varchar] (100) ,
					[source_system_book_id4] [varchar] (100) , 
					[description1] [varchar] (260) ,
					[description2] [varchar] (260) ,
					[description3] [varchar] (260) , 
					[deal_category_value_id] [varchar] (100) , 
					[trader_id] [varchar] (100) , 
					[header_buy_sell_flag] [varchar] (100) , 
					[broker_id] [varchar] (100) , 
					[contract_id] [varchar] (100),
					legal_entity varchar(100), 
					internal_desk_id [varchar] (100), 
					product_id [varchar] (100),
					internal_portfolio_id [varchar] (100),
					commodity_id [varchar] (100), 
					reference varchar(250),
					[table_code] [varchar] (100)
				)'
	
--this is new format inclide all the fields till jan 18, 2009
ELSE IF @tablename='source_deal_detail_trm'
	SET @sql = 'CREATE TABLE ' + @temptablename + '(
					[deal_id] [varchar] (100) , 
					[source_system_id] [varchar] (100) ,
					[term_start] [varchar] (100) , 
					[term_end] [varchar] (100) , 
					[Leg] [varchar] (100) , 
					[contract_expiration_date] [varchar] (100) ,
 					[fixed_float_leg] [varchar] (100) , 
					[buy_sell_flag] [varchar] (100) , 
					[curve_id] [varchar] (100) , 
					[fixed_price] [varchar] (100),   
					[fixed_price_currency_id] [varchar] (100) , 	
					[option_strike_price] [varchar] (100) , 
					 [deal_volume] float ,   
					[deal_volume_frequency] [varchar] (100) , 
					[deal_volume_uom_id] [varchar] (100) , 
					[block_description] [varchar] (260) , 
					[deal_detail_description] [varchar] (260) , 
					[formula_id] [varchar] (100) , 
					[deal_date] [varchar] (100) , 
					[ext_deal_id] [varchar] (100) , 
					[physical_financial_flag] [varchar] (100) , 
					[structured_deal_id] [varchar] (100) , 
					[counterparty_id] [varchar] (100) ,
					[source_deal_type_id] [varchar] (100) ,
					[source_deal_sub_type_id] [varchar] (100) , 
					[option_flag] [varchar] (100) , 
					[option_type] [varchar] (100) , 
					[option_excercise_type] [varchar] (100) , 
					[source_system_book_id1] [varchar] (100) , 
					[source_system_book_id2] [varchar] (100) , 
					[source_system_book_id3] [varchar] (100) ,
					[source_system_book_id4] [varchar] (100) , 
					[description1] [varchar] (260) ,
					[description2] [varchar] (260) ,
					[description3] [varchar] (260) , 
					[deal_category_value_id] [varchar] (100) , 
					[trader_id] [varchar] (100) , 
					[header_buy_sell_flag] [varchar] (100) , 
					[broker_id] [varchar] (100) , 
					[contract_id] [varchar] (100),
					legal_entity varchar(100), 
					internal_desk_id [varchar] (100), 
					product_id [varchar] (100),
					internal_portfolio_id [varchar] (100),
					commodity_id [varchar] (100), 
					reference varchar(250),
					
				--header added fileds	
					[block_type] [varchar] (100), --sdv
					[block_define_id] [varchar] (100), --sdv
					[granularity_id] [varchar] (100), --sdv
					[Pricing] [varchar] (100), --sdv
					[unit_fixed_flag] [varchar] (100),
					[broker_unit_fees] [varchar] (100),
					[broker_fixed_cost] [varchar] (100),
					[broker_currency_id] [varchar] (250), --scur
					[term_frequency] [varchar] (100) ,
					[option_settlement_date] [varchar](50),		
				
				--detail added fileds	
					[settlement_volume] float,  
					[settlement_uom] [varchar] (100) ,
					[price_adder] [varchar] (100),
					[price_multiplier] [varchar] (100),
					[settlement_date] [varchar] (100),
					[day_count_id] [varchar] (100),			--sdv
					[location_id] [varchar] (250),			--select * from source_minor_location
					[meter_id] [varchar] (250),				-- select * from source_minor_location_meter
					[physical_financial_flag_detail] [varchar] (100)  ,
					[fixed_cost] [varchar] (100),
					[template] [varchar] (250),
					
				--added header fields and detail fields for intrabook deals import
					[adder_currency_id] varchar(50),
					[multiplier] numeric (38,20),
					[deal_status] varchar(50),
					[capacity] numeric(38,20) ,
					[fixed_cost_currency_id] varchar(50),
					[formula_currency_id] varchar(50) ,
					[price_adder2] numeric(38,20),
					[price_adder_currency2] varchar(50) ,
					[volume_multiplier2] numeric(38,20),
					[pay_opposite] varchar(1),
					[settlement_currency] varchar(50),
					[standard_yearly_volume] float ,
					[price_uom_id] varchar(50),
					[category] varchar(50),
					[profile_code] varchar(50),
					[close_reference_id] varchar(50) ,
					[pv_party] varchar(100),
					[deal_seperator_id] varchar(100),
					[Intrabook_deal_flag] char(2),
					[table_code] [varchar] (100)
				)'	
				
ELSE IF @tablename='source_deal_detail_trm_essent_excel'
	SET @sql = 'CREATE TABLE ' + @temptablename + '(
					[deal_seperator_id] varchar(100),
					[Intrabook_deal_flag] char(2),
					[source_system_id] [varchar] (100) ,
					[source_system_book_id1] [varchar] (100) , 
					[source_system_book_id2] [varchar] (100) , 
					[source_system_book_id3] [varchar] (100) , 
					[source_system_book_id4] [varchar] (100) , 
					[deal_id] [varchar] (100) , 
					[physical_financial_flag] [varchar] (100) , 
					[counterparty_id] [varchar] (100) ,
					[source_deal_type_id] [varchar] (100) ,
					[source_deal_sub_type_id] [varchar] (100) , 
					[term_frequency] [varchar] (100) ,
					[description1] [varchar] (260) ,
					[description2] [varchar] (260) ,
					[description3] [varchar] (260) ,
					[deal_category_value_id] [varchar] (100) , 
					[trader_id] [varchar] (100) , 
					[header_buy_sell_flag] [varchar] (100) , 
					[contract_id] [varchar] (100),
					legal_entity varchar(100), 
					internal_desk_id [varchar] (100), 
					product_id [varchar] (100),
					internal_portfolio_id [varchar] (100),
					commodity_id [varchar] (100), 
					reference varchar(250),
					[close_reference_id] varchar(50) ,
					[block_define_id] [varchar] (100), --sdv
					[granularity_id] [varchar] (100), --sdv
					[Pricing] [varchar] (100), --sdv
					[deal_status] varchar(50),
					[structured_deal_id] [varchar] (100) , 
					[template] [varchar] (250),
					[deal_date] [varchar] (100) , 
					[term_start] [varchar] (100) , 
					[term_end] [varchar] (100) , 
					[Leg] [varchar] (100) , 
					[contract_expiration_date] [varchar] (100) ,
					[fixed_float_leg] [varchar] (100) , 
					[buy_sell_flag] [varchar] (100) , 
					[curve_id] [varchar] (100) , 
					[fixed_price] [varchar] (100),   
					[fixed_price_currency_id] [varchar] (100) , 
					[option_strike_price] [varchar] (100) , 
					[deal_volume] float ,   
					[deal_volume_frequency] [varchar] (100) , 
					[deal_volume_uom_id] [varchar] (100) , 
					[formula_id] [varchar] (100) , 
					[price_adder] [varchar] (100),
					[price_multiplier] [varchar] (100),
					[settlement_date] [varchar] (100),
					[location_id] [varchar] (250), 
					[meter_id] [varchar] (250),   
					[physical_financial_flag_detail] [varchar] (100)  ,
					[fixed_cost] [varchar] (100),
					[multiplier] numeric (38,20),
					[adder_currency_id] varchar(50),
					[fixed_cost_currency_id] varchar(50),
					[formula_currency_id] varchar(50) ,
					[price_adder2] numeric(38,20),
					[price_adder_currency2] varchar(50) ,
					[volume_multiplier2] numeric(38,20),
					[pay_opposite] varchar(1),
					[capacity] numeric(38,20) ,
					[settlement_currency] varchar(50),
					[standard_yearly_volume] float ,
					[price_uom_id] varchar(50),
					[category] varchar(50),
					[profile_code] varchar(50),
					[pv_party] varchar(100),
					[broker_id] [varchar] (100), 
					[table_code] [varchar] (100)
				)'
	
ELSE IF @tablename='deal_SNWA'
	SET @sql = 'CREATE TABLE ' + @temptablename + '(
					[Deal ID] VARCHAR(100),
					[deal_date] [varchar] (100),
					[Term] VARCHAR(100),
					[Leg] int,
					buy_sell varchar(30),
					curveID [varchar] (250),
					[Volume] [varchar] (100),
					[Commodity] VARCHAR(250),
					[Price] [varchar] (100),
					[Price Adder] [varchar] (100),
					[Price Multiplier] [varchar] (100),
					[Fixed Cost] [varchar] (100),
					[Counterparty] VARCHAR(250),
					[Trader] VARCHAR(250),
					[Template] VARCHAR(250),
					[Book ID1] VARCHAR(250),
					[Book ID2] VARCHAR(250),
					[Book ID3] VARCHAR(250),
					[Book ID4] VARCHAR(250),
					[Block TYPE] VARCHAR(250),
					[Block NAME] VARCHAR(250),
					[UDF1] VARCHAR(250),
					[UDF2] VARCHAR(250),
					[UDF3] VARCHAR(250),
					[Comments] VARCHAR(500),
					[table_code] [varchar] (100)
				)'
		
ELSE IF @tablename='source_deal_header'
	SET @sql = 'CREATE TABLE ' + @temptablename + '(
					[source_deal_header_id] [varchar] (100) ,
					[source_system_id] [varchar] (100) ,		
					[deal_id]  [varchar] (100) ,
					[deal_date] [varchar] (100) ,
					[ext_deal_id] [varchar] (100) ,
					[physical_financial_flag] [varchar] (100) ,
					[structured_deal_id] [varchar] (100) ,
					[counterparty_id] [varchar] (100) ,
					[entire_term_start] [varchar] (100) ,
					[entire_term_end] [varchar] (100) ,
					[source_deal_type_id] [varchar] (100) ,
					[deal_sub_type_type_id] [varchar] (100) ,
					[option_flag] [varchar] (100) ,
					[option_type] [varchar] (100) ,
					[option_excercise_type] [varchar] (100) ,
					[source_system_book_id1] [varchar] (100) ,
					[source_system_book_id2] [varchar] (100) ,
					[source_system_book_id3] [varchar] (100) ,
					[source_system_book_id4] [varchar] (100) ,
					[description1] [varchar] (260) ,
					[description2] [varchar] (260),
					[description3] [varchar] (260) ,
					[deal_category_value_id] [varchar] (100),
					[trader_id] [varchar] (100),
					[internal_deal_type_value_id] [varchar] (100),
					[internal_deal_subtype_value_id] [varchar] (100),
					[header_buy_sell_flag] [varchar] (100),
					[broker_id] [varchar] (100),
					[table_code] [varchar] (100)
				)'

ELSE IF @tablename='source_deal_pnl'
	SET @sql = 'CREATE TABLE ' + @temptablename + '(
					[source_deal_header_id] [varchar] (100) ,
					[source_system_id] [varchar] (100) ,
					[term_start] [varchar] (100) ,
					[term_end] [varchar] (100) ,
					[Leg] [varchar] (100) ,
					[pnl_as_of_date] [varchar] (100) ,
					[und_pnl] float ,
					[und_intrinsic_pnl] float ,
					[und_extrinsic_pnl] float ,
					[dis_pnl] float ,
					[dis_intrinsic_pnl] float ,
					[dis_extrinisic_pnl] float ,
					[pnl_source_value_id] [varchar] (100) ,
					[pnl_currency_id] [varchar] (100) ,
					[pnl_conversion_factor] float ,
					[pnl_adjustment_value] float,
					[deal_volume] varchar(100) ,
					[table_code] [varchar] (100)
				)'

ELSE IF @tablename='source_deal_type'
	SET @sql = 'CREATE TABLE ' + @temptablename + '(
					[source_deal_type_id] [varchar] (100) ,
					[source_system_id] [varchar] (100) ,
					[deal_type_id] [varchar] (100) ,
					[source_deal_type_name] [varchar] (100) ,
					[source_deal_desc] [varchar] (260) ,
					[Deal_Sub_Type_Flag] [varchar] (1),				--added by gyan(because it is found in zainet output table)
					[table_code] [varchar] (100)
				)'
		
ELSE IF @tablename='source_price_curve'
	SET @sql = 'CREATE TABLE ' + @temptablename + '(
					[source_curve_def_id] [varchar] (100) ,
					[source_system_id] [varchar] (100) ,
					[as_of_date] [varchar] (100) ,
					[Assessment_curve_type_value_id] [varchar] (100) ,
					[curve_source_value_id] [varchar] (100) ,
					[maturity_date] [varchar] (100) ,
					[maturity_hour] [varchar] (100) ,
					[bid_value] [varchar] (100) ,
					[ask_value] [varchar] (100) ,
					[curve_value] [varchar] (100) ,
					[is_dst] [varchar] (5) ,
					[import_file_name] VARCHAR(2000),
					[table_code] [varchar] (100)
				)'
		
ELSE IF @tablename='cma_price_curve_request'
	SET @sql = 'CREATE TABLE ' + @temptablename + '(
					[source_curve_def_id] [varchar] (100) ,
					[source_system_id] [varchar] (100) ,
					[as_of_date] [varchar] (100) ,
					[Assessment_curve_type_value_id] [varchar] (100) ,
					[curve_source_value_id] [varchar] (100) ,
					[maturity_date] [varchar] (100) ,
					[maturity_hour] [varchar] (100) ,
					[bid_value] [varchar] (100) ,
					[ask_value] [varchar] (100) ,
					[curve_value] [varchar] (100) ,
					[is_dst] [varchar] (5) ,
					[table_code] [varchar] (100)
				)'
		
ELSE IF @tablename='cma_price_curve_response'
	SET @sql = 'CREATE TABLE ' + @temptablename + '(
					[source_curve_def_id] [varchar] (100) ,
					[source_system_id] [varchar] (100) ,
					[as_of_date] [varchar] (100) ,
					[Assessment_curve_type_value_id] [varchar] (100) ,
					[curve_source_value_id] [varchar] (100) ,
					[maturity_date] [varchar] (100) ,
					[maturity_hour] [varchar] (100) ,
					[bid_value] [varchar] (100) ,
					[ask_value] [varchar] (100) ,
					[curve_value] [varchar] (100) ,
					[is_dst] [varchar] (5) ,
					[table_code] [varchar] (100)
				)'
		
ELSE IF @tablename='contract_price'
	SET @sql = 'CREATE TABLE ' + @temptablename + '(
					[source_curve_def_id] [varchar] (100) ,
					[as_of_date] [varchar] (100) ,
					[maturity_hour] [varchar] (100) ,
					[curve_value] [varchar] (100)
				)'

ELSE IF @tablename='source_price_curve_def'
	SET @sql = 'CREATE TABLE ' + @temptablename + '(
					[source_curve_def_id] [varchar] (100) ,
					[source_system_id] [varchar] (100) ,
					[curve_id] [varchar] (100) ,
					[curve_name] [varchar] (260) ,
					[curve_des] [varchar] (260) ,
					[commodity_id] [varchar] (100) ,
					[market_value_id] [varchar] (100) ,
					[market_value_desc] [varchar] (260) ,
					[source_currency_id] [varchar] (100),
					[source_currency_to_id] [varchar] (100) ,
					[source_curve_type_value_id] [varchar] (100) ,
					[uom_id] [varchar] (100) ,
					[proxy_source_curve_def_id] [varchar] (100) ,
					Granularity [varchar] (100) ,
					exp_calendar_id [varchar] (100),
					risk_bucket_id [varchar] (100),
					[table_code] [varchar] (100)
				)'

ELSE IF @tablename='source_traders'
	SET @sql = 'CREATE TABLE ' + @temptablename + '(
					[source_trader_id] [varchar] (100) ,
					[source_system_id] [varchar] (100) ,
					[trader_id] [varchar] (100) ,
					[trader_name] [varchar] (260) ,
					[trader_desc] [varchar] (260) ,
					[table_code] [varchar] (100)
				)'

ELSE IF @tablename='source_uom'
	SET @sql = 'CREATE TABLE ' + @temptablename + '(
					[source_uom_id] [varchar] (100) ,
					[source_system_id] [varchar] (100) ,
					[uom_id] [varchar] (100) ,
					[uom_name] [varchar] (260) ,
					[uom_desc] [varchar] (260) ,
					[table_code] [varchar] (100)
				)'

ELSE IF @tablename='fas_eff_ass_test_results'
	SET @sql = 'CREATE TABLE ' + @temptablename + '(
					[eff_test_profile_id] [varchar] (100) ,
					[as_of_date] [varchar] (100) ,
					[initial_ongoing] [varchar] (100) ,
					[result_value] [varchar] (100) ,
					[additional_result_value] [varchar] (100) ,
					[additional_result_value2] [varchar] (100),
					[table_code] [varchar] (100)
				) '

ELSE IF @tablename='source_brokers'
	SET @sql = 'CREATE TABLE ' + @temptablename + '(
					[source_broker_id] [varchar] (100) ,
					[source_system_id] [varchar] (100) ,
					[broker_id] [varchar] (100) ,
					[broker_name] [varchar] (260) ,
					[broker_desc] [varchar] (260) ,
					[table_code] [varchar] (100)
				)'
			
ELSE IF @tablename='source_legal_entity'
	SET @sql = 'CREATE TABLE ' + @temptablename + '(
					[source_legal_entity_id] [varchar] (100) ,
					[source_system_id] [varchar] (100) ,
					[legal_entity_id] [varchar] (100) ,
					[legal_entity_name] [varchar] (260) ,
					[legal_entity_desc] [varchar] (260) ,
					[table_code] [varchar] (100)
				)'

ELSE IF @tablename='rec_transaction'
	SET @sql = 'CREATE TABLE ' + @temptablename + '(
					[Book] [nvarchar] (255)  NULL ,
					[Feeder_System_ID] [nvarchar] (255)  NULL ,
					[Gen_Date_From] varchar(50) NULL ,
					[Gen_Date_To] [varchar] (50) NULL ,
					[Volume] [varchar] (255)  NULL ,
					[UOM] [varchar] (255)  NULL ,
					[Price] [varchar] (255)  NULL ,
					[Formula] [varchar] (255)  NULL ,
					[Counterparty] [varchar] (255)  NULL ,
					[Generator] [varchar] (255)  NULL ,
					[Deal_Type] [varchar] (255)  NULL ,
					[Deal_Sub_Type] [varchar] (255)  NULL ,
					[Trader] [varchar] (255)  NULL ,
					[Broker] [varchar] (255)  NULL ,
					[Rec_Index] [varchar] (255)  NULL ,
					[Frequency] [varchar] (255)  NULL ,
					[Deal_Date] [varchar] (50) NULL ,
					[Currency] [varchar] (255)  NULL ,
					[Category] [varchar] (255)  NULL ,
					[buy_sell_flag] [varchar] (255)  NULL,
					[leg] [varchar] (255)  NULL,
					[settlement_volume] [varchar] (255)  NULL,
					[settlement_uom] [varchar] (255)  NULL,
					[table_code] [varchar] (100)
				)'
			
ELSE IF @tablename='gis_rec_transaction'
	SET @sql = 'CREATE TABLE ' + @temptablename + '(
					[Type] [varchar] (255),
					[Feeder_System_ID] [varchar] (255),
					[Gen_Date_From] [varchar] (255),
					[Gen_Date_To] [varchar] (255),
					[Volume] [varchar] (255),
					[UOM] [varchar] (255),
					[Generator] [varchar] (255),
					[GIS] [varchar] (255),
					[GIS_Certificate_Number] [varchar] (255),
					[GIS_Certificate_Number_To] [varchar] (255),
					[GIS_Certificate_Date] [varchar] (255),
					[table_code] [varchar] (100)
				)' 
ELSE IF @tablename='rec_loadstar'
	SET @sql = 'CREATE TABLE ' + @temptablename + '(
						[header_id] varchar(100),
						[recorder_id] varchar(100),
						[channel] varchar(100),
						[from_date] varchar(100),
						[to_date] varchar(100),
						[header1] varchar(100),
						[header2] varchar(100),
						[header3] varchar(100),
						[header4] varchar(100),
						[header5] varchar(100),
						[header6] varchar(100),
						[header7] varchar(100),
						[header8] varchar(100),
						[header9] varchar(100),
						[header10] varchar(100),
						[header11] varchar(100),
						[header12] varchar(100),
						[header13] varchar(100),
						[header14] varchar(100),
						[header15] varchar(100),
						[header16] varchar(100),
						[header17] varchar(100),
						[header18] varchar(100),
						[header19] varchar(100),
						[header20] varchar(100),
						[header21] varchar(100),
						[gen_date] varchar(100),
						[header23] varchar(100),
						[detail_id] varchar(100),
						[Field1] varchar(100),
						[Field2] varchar(100),
						[Field3] varchar(100),
						[Field4] varchar(100),
						[Field5] varchar(100),
						[Field6] varchar(100),
						[Field7] varchar(100),
						[Field8] varchar(100),
						[Field91] varchar(100),
						[Field10] varchar(100),
						[Field11] varchar(100),
						[Field12] varchar(100),
						[Field13] varchar(100),
						[Field14] varchar(100),
						[Field15] varchar(100),
						[Field16] varchar(100),
						[Field17] varchar(100),
						[Field18] varchar(100),
						[Field19] varchar(100),
						[Field20] varchar(100),
						[Field21] varchar(100),
						[Field22] varchar(100),
						[Field23] varchar(100),
						[Field24] varchar(100),	
						[Field25] varchar(100),
						[Field26] varchar(100),
						[Field27] varchar(100),
						[Field28] varchar(100),
						[Field29] varchar(100),
						[Field30] varchar(100),
						[Field31] varchar(100),
						[Field32] varchar(100),
						[Field33] varchar(100),
						[Field34] varchar(100),
						[Field35] varchar(100),
						[Field36] varchar(100),
						[Field37] varchar(100)
					)'			

IF @table_id = 'hourly_data'
BEGIN
SET @sql = 'CREATE TABLE ' + @temptablename + '(
				[meter_id] [varchar] (255),
				[channel] [varchar] (255),
				[date] [varchar] (255),
				[hour] [varchar] (255),
				[value] [varchar] (255)
			)'
END

IF @tablename = 'tagging_update'
BEGIN
SET @sql = 'CREATE TABLE ' + @temptablename + '(
				deal_id [varchar] (255),
				source_system_book_id1 [varchar] (255),
				source_system_book_id2 [varchar] (255),
				source_system_book_id3 [varchar] (255),
				source_system_book_id4 [varchar] (255),
				source_system_id varchar(100),
				user_comment varchar(500),
				[table_code] [varchar] (100)
			)'
END

---new added

IF @tablename = 'source_internal_desk'
BEGIN
SET @sql = 'CREATE TABLE ' + @temptablename + '(
				[source_internal_desk_id] [varchar](100),
				[source_system_id] [int] NOT NULL,
				[internal_desk_id] [varchar](50),
				[internal_desk_name] [varchar](260),
				[internal_desk_desc] [varchar](260),
				[table_code] [varchar] (100)
			)'
END

IF @tablename = 'source_product'
BEGIN
SET @sql = 'CREATE TABLE ' + @temptablename + '(
				[source_product_id] [varchar](100),
				[source_system_id] [varchar](100),
				[product_id] [varchar](100),
				[product_name] [varchar](260),
				[product_desc] [varchar](260),
				[table_code] [varchar] (100)
			)'
END

IF @tablename = 'source_internal_portfolio'
BEGIN
SET @sql = 'CREATE TABLE ' + @temptablename + '(
				[source_internal_portfolio_id] [varchar](100),
				[source_system_id] [varchar](100),
				[internal_portfolio_id] [varchar](100),
				[internal_portfolio_name] [varchar](260),
				[internal_portfolio_desc] [varchar](260),
				[table_code] [varchar] (100)
			)'

END
IF @tablename='source_deal_cash_settlement'
BEGIN
SET @sql = 'CREATE TABLE ' + @temptablename + '
			(
				[source_deal_header_id] varchar(100),
				[source_system_id] [varchar] (100),
				[term_start] varchar(50),
				[cash_received] varchar(50),
				[as_of_date] varchar(50),
				[Description] varchar(260),
				[table_code] [varchar] (100)
			)'
END

IF @tablename='probability'
BEGIN
SET @sql = 'CREATE TABLE ' + @temptablename + '
			(
				[effective_date] [varchar] (250) ,
				[debt_rating] [varchar] (250),
				[recovery] [varchar] (250),
				[months] [varchar] (250) ,
				[probability] [varchar] (250),
				[table_code] [varchar] (100)
			)'
END

IF @tablename='recovery'
BEGIN
SET @sql = 'CREATE TABLE ' + @temptablename + '
			(
				[effective_date] [varchar] (250),
				[debt_rating] [varchar] (250),
				[recovery] [varchar] (250),
				[months] [varchar] (250),
				[rate] [varchar] (250),
				[table_code] [varchar] (100)
			)'
END

IF @tablename='curve_correlation'
BEGIN
SET @sql = 'CREATE TABLE ' + @temptablename + '
			(
				[as_of_date] [varchar] (250),
				[curve_id_from] [varchar] (250),
				[curve_id_to] [varchar] (250),
				[term1][varchar] (250),
				[term2] [varchar] (250),
				[curve_source_value_id][varchar] (250),
				[value][varchar] (250),
				[table_code] [varchar] (100)
			)'
END
IF @tablename='curve_volatility'
BEGIN
SET @sql = 'CREATE TABLE ' + @temptablename + '
			(
				[as_of_date] [varchar] (250) ,
				[curve_id] [varchar] (250) ,
				[curve_source_value_id] [varchar] (250)  ,
				[term] [varchar] (250),
				[value] [varchar] (250) ,
				granularity [varchar] (100),
				[table_code] [varchar] (100)
			)'
END
IF @tablename='expected_return'
BEGIN
SET @sql = 'CREATE TABLE ' + @temptablename + '
			(
				[as_of_date] [varchar] (250) ,
				[curve_id] [varchar] (250) ,	
				[term] [varchar] (250),
				[curve_source_value_id] [varchar] (250)  ,
				[value] [varchar] (250) ,
				[table_code] [varchar] (100)
			)'
END
IF @tablename = 'import_edr'
BEGIN
SET @sql = 'CREATE TABLE ' + @temptablename + '(
				[facility_id] [varchar] (255),
				[stack_id] [varchar] (255),
				[unit_id] [varchar] (255),
				[record_type_code] [varchar] (255),
				[sub_type_id] [varchar] (255),
				[edr_date] [varchar] (255),
				[edr_hour] [varchar] (255),
				[curve_id] [varchar] (255),
				[edr_value] [varchar] (255),
				[uom_id] [varchar] (255),
				[uom_id1] [varchar] (255),
				[table_code] [varchar] (100)
			)'
END
IF @tablename = 'hourly_data'
BEGIN
SET @sql = 'CREATE TABLE ' + @temptablename + '(
				[meter_id] [varchar] (255),
				[channel] [varchar] (255),
				[date] [varchar] (255),
				[hour] [varchar] (255),
				[value] [varchar] (255)
			)'
END

IF @tablename='ppa_data'
BEGIN
SET @sql = 'CREATE TABLE ' + @temptablename + '(
				[company][varchar] (255),
				[id][varchar](255),
				[unit][varchar](255),
				[counterparty][varchar](255),
				[production_month][varchar](255),
				[mw][varchar](255),
				[table_code] [varchar] (100)
			)'
END

IF @tablename='epa_data'
BEGIN
SET @sql = 'CREATE TABLE ' + @temptablename + '(
				[state] [varchar] (50),
				[FACILITY_NAME][varchar](255),
				[ORISPL_CODE][varchar](50),
				[UNITID][varchar](50),
				[OP_YEAR][varchar](255),
				[ASSOC_STACKS][varchar](100),
				[OP_MONTH][varchar](255),
				[PRG_CODE_INFO][varchar](255),
				[SUM_OP_TIME][varchar](255),
				[GLOAD] varchar(255),
				[SO2_MASS][varchar](255),
				[NOX_RATE][varchar](255),
				[NOX_MASS][varchar](255),
				[CO2_MASS][varchar](255),
				[HEAT_INPUT][varchar](255),
				[CAPACITY_INPUT] varchar(255)
				,[table_code] [varchar] (100)
			)'

END

ELSE IF @tablename='activity_data'
BEGIN
SET @sql = 'CREATE TABLE ' + @temptablename + '(
				[sub][varchar](250),
				[Stra][varchar](250),
				[Book][varchar](250),
				[FacilityID][varchar](250),
				[Unit] [varchar](250),
				[ems_input] [varchar](250),
				[term_start] [varchar](250),
				[term_end] [varchar](250),
				[frequency] [varchar](250),
				[char1] [varchar](250),
				[char2] [varchar](250),
				[char3] [varchar](250),
				[char4] [varchar](250),
				[char5] [varchar](250),
				[char6] [varchar](250),
				[char7] [varchar](250),
				[char8] [varchar](250),
				[char9] [varchar](250),
				[char10] [varchar](250),
				[input_value] [varchar](250),
				[uom] [varchar](250),
				[table_code] [varchar] (100)
			)'
END

ELSE IF @tablename='Activity_Data_New'
BEGIN
SET @sql = 'CREATE TABLE ' + @temptablename + '(
				[FacilityID][varchar](250),
				[input] [varchar](250),
				[month] [varchar](250),
				[year] [varchar](250),
				[value] [varchar](250),
				[uom] [varchar](250),
				[price] [varchar](250),
				[table_code] [varchar] (100)
			)'

END
--else if @tablename='epa_allowance_data'
--SET @sql = ' create table '+@temptablename+'(
--			[AccountNumber][varchar](250),
--			[AccountName][varchar](250),
--			[Vinatage] [varchar](250),
--			[start_block] [varchar](250),
--			[end_block] [varchar](250),
--			[PRG_Code] [varchar](250),
--			[total_block] [varchar](250),
--			[orispl_code] [varchar](250)
--			,[table_code] [varchar] (100)
--)'
ELSE IF @tablename='epa_allowance_data'
BEGIN
SET @sql = 'CREATE TABLE ' + @temptablename + '(
				PRG_Code VARCHAR(250),
				TRANSACTION_ID varchar(50), --int,
				TRANSACTION_TOTAL varchar(100), --int,
				TRANSACTION_TYPE VARCHAR(250),
				SELL_ACCT_NUMBER VARCHAR(250),
				SELL_ACCT_NAME VARCHAR(250),
				SELL_STATE VARCHAR(30),
				SELL_DISPLAY_NAME VARCHAR(250),
				BUY_ACCT_NUMBER VARCHAR(250),
				BUY_ACCT_NAME VARCHAR(250),
				BUY_STATE VARCHAR(30),
				BUY_DISPLAY_NAME VARCHAR(250),
				TRANSACTION_DATE VARCHAR(30),
				VINTAGE_YEAR varchar(20), --int,
				START_BLOCK varchar(50), --int,
				END_BLOCK varchar(50), --int,
				TOTAL_BLOCK varchar(50) --int
				--[table_code] [varchar] (100)
			)'
END

ELSE IF @tablename='stage_generator'
BEGIN
SET @sql = 'CREATE TABLE ' + @temptablename + '(
				STATE varchar(100),
				FACILITY_NAME varchar(100),
				ORISPL_CODE varchar(100),
				UNITID int,OP_YEAR int,
				ASSOC_STACKS varchar(100),
				PRG_CODE varchar(100),
				OWN_DISPLAY varchar(100),
				PRM_DISPLAY_BLOCK varchar(300),
				code VARCHAR(100),
				descr VARCHAR(1000),
				sno int identity(1,1)
			)'
END

ELSE IF @tablename='Load_Forecast'
BEGIN
SET @sql = 'CREATE TABLE ' + @temptablename + '(
				location_id VARCHAR(100),
				load_forecast_date  VARCHAR(100),
				load_forecast_hour  VARCHAR(100),
				load_forecast_volume  VARCHAR(100),
				[table_code] [varchar] (100)
			)'
END
ELSE IF @tablename='rec_loadstar_mins'
BEGIN
	SET @sql = 'CREATE TABLE ' + @temptablename + '(
					[header_id] varchar(100),
					[recorder_id] varchar(100),
					[channel] varchar(100),
					[from_date] varchar(100),
					[to_date] varchar(100),
					[header1] varchar(100),
					[header2] varchar(100),
					[header3] varchar(100),
					[header4] varchar(100),
					[header5] varchar(100),
					[header6] varchar(100),
					[header7] varchar(100),
					[header8] varchar(100),
					[header9] varchar(100),
					[header10] varchar(100),
					[header11] varchar(100),
					[header12] varchar(100),
					[header13] varchar(100),
					[header14] varchar(100),
					[header15] varchar(100),
					[header16] varchar(100),
					[header17] varchar(100),
					[header18] varchar(100),
					[header19] varchar(100),
					[header20] varchar(100),
					[header21] varchar(100),
					[gen_date] varchar(100),
					[header23] varchar(100),
					[detail_id] varchar(100),
					[field1] varchar(100),
					[field2] varchar(100),
					[field3] varchar(100),
					[field4] varchar(100),
					[field5] varchar(100),
					[field6] varchar(100),
					[field7] varchar(100),
					[field8] varchar(100),
					[field9] varchar(100),
					[field10] varchar(100),
					[field11] varchar(100),
					[field12] varchar(100),
					[field13] varchar(100),
					[field14] varchar(100),
					[field15] varchar(100),
					[field16] varchar(100),
					[field17] varchar(100),
					[field18] varchar(100),
					[field19] varchar(100),
					[field20] varchar(100),
					[field21] varchar(100),
					[field22] varchar(100),
					[field23] varchar(100),
					[field24] varchar(100),	
					[field25] varchar(100),
					[field26] varchar(100),
					[field27] varchar(100),
					[field28] varchar(100),
					[field29] varchar(100),
					[field30] varchar(100),
					[field31] varchar(100),
					[field32] varchar(100),
					[field33] varchar(100),
					[field34] varchar(100),
					[field35] varchar(100),
					[field36] varchar(100),
					[field37] varchar(100),
					[field38] varchar(100),
					[field39] varchar(100),
					[field40] varchar(100),
					[field41] varchar(100),
					[field42] varchar(100),
					[field43] varchar(100),
					[field44] varchar(100),
					[field45] varchar(100),
					[field46] varchar(100),
					[field47] varchar(100),
					[field48] varchar(100),
					[field49] varchar(100),
					[field50] varchar(100),
					[field51] varchar(100),
					[field52] varchar(100),
					[field53] varchar(100),
					[field54] varchar(100),
					[field55] varchar(100),
					[field56] varchar(100),
					[field57] varchar(100),
					[field58] varchar(100),
					[field59] varchar(100),
					[field60] varchar(100),
					[field61] varchar(100),	
					[field62] varchar(100),
					[field63] varchar(100),
					[field64] varchar(100),
					[field65] varchar(100),
					[field66] varchar(100),
					[field67] varchar(100),
					[field68] varchar(100),
					[field69] varchar(100),
					[field70] varchar(100),
					[field71] varchar(100),
					[field72] varchar(100),
					[field73] varchar(100),
					[field74] varchar(100),
					[field75] varchar(100),
					[field76] varchar(100),
					[field77] varchar(100),
					[field78] varchar(100),
					[field79] varchar(100),
					[field80] varchar(100),
					[field81] varchar(100),
					[field82] varchar(100),
					[field83] varchar(100),
					[field84] varchar(100),
					[field85] varchar(100),
					[field86] varchar(100),
					[field87] varchar(100),
					[field88] varchar(100),
					[field89] varchar(100),
					[field90] varchar(100),
					[field91] varchar(100),
					[field92] varchar(100),	
					[field93] varchar(100),
					[field94] varchar(100),
					[field95] varchar(100),
					[field96] varchar(100),
					[field97] varchar(100),
					[field98] varchar(100),
					[field99] varchar(100),
					[field100] varchar(100),
					[field101] varchar(100),
					[field102] varchar(100),
					[field103] varchar(100),
					[field104] varchar(100),
					[field105] varchar(100),
					[field106] varchar(100),
					[field107] varchar(100),
					[field108] varchar(100),
					[field109] varchar(100),
					[field110] varchar(100),
					[field111] varchar(100),
					[field112] varchar(100),
					[field113] varchar(100),
					[field114] varchar(100),
					[field115] varchar(100),
					[field116] varchar(100),
					[field117] varchar(100),
					[field118] varchar(100),
					[field119] varchar(100),
					[field120] varchar(100),
					[field121] varchar(100),
					[field122] varchar(100),
					[field123] varchar(100),
					[field124] varchar(100),
					[field125] varchar(100),
					[field126] varchar(100),
					[field127] varchar(100),
					[field128] varchar(100),
					[field129] varchar(100),
					[field130] varchar(100),
					[field131] varchar(100),
					[field132] varchar(100),
					[field133] varchar(100),
					[field134] varchar(100),
					[field135] varchar(100),
					[field136] varchar(100),
					[field137] varchar(100),
					[field138] varchar(100),
					[field139] varchar(100),
					[field140] varchar(100),
					[field141] varchar(100),
					[field142] varchar(100),
					[field143] varchar(100),
					[field144] varchar(100),
					[field145] varchar(100)
				)'		
END
ELSE IF @tablename = 'deal_detail_hour_lrs'
BEGIN
	SET @sql = 'CREATE TABLE ' + @temptablename + '(
					term_date				VARCHAR(10),
					day_name				VARCHAR(30),
					vol1					float, vol2					float,
					vol3					float, vol4					float,
					vol5					float, vol6					float,
					vol7					float, vol8					float,
					vol9					float, vol10				float,
					vol11					float, vol12				float,
					vol13					float, vol14				float,
					vol15					float, vol16				float,
					vol17					float, vol18				float,
					vol19					float, vol20				float,
					vol21					float, vol22				float,
					vol23					float, vol24				float,
					vol25					float, vol26				float,
					vol27					float, vol28				float,
					vol29					float, vol30				float,
					vol31					float, vol32				float,
					vol33					float, vol34				float,
					vol35					float, vol36				float,
					vol37					float, vol38				float,
					vol39					float, vol40				float,
					vol41					float, vol42				float,
					vol43					float, vol44				float,
					vol45					float, vol46				float,
					vol47					float, vol48				float,
					vol49					float, vol50				float,
					vol51					float, vol52				float,
					vol53					float, vol54				float,
					vol55					float, vol56				float,
					vol57					float, vol58				float,
					vol59					float, vol60				float,
					vol61					float, vol62				float,
					vol63					float, vol64				float,
					vol65					float, vol66				float,
					vol67					float, vol68				float,
					vol69					float, vol70				float,
					vol71					float, vol72				float,
					vol73					float, vol74				float,
					vol75					float, vol76				float,
					vol77					float, vol78				float,
					vol79					float, vol80				float,
					vol81					float, vol82				float,
					vol83					float, vol84				float,
					vol85					float, vol86				float,
					vol87					float, vol88				float,
					vol89					float, vol90				float,
					vol91					float, vol92				float,
					vol93					float, vol94				float,
					vol95					float, vol96				float,
					vol97					float, vol98				float,
					vol99					float, vol100				float,
					vol101					float, vol102				float,
					vol103					float, vol104				float,
					vol105					float, vol106				float,
					vol107					float, vol108				float,
					vol109					float, vol110				float,
					vol111					float, vol112				float,
					vol113					float, vol114				float,
					vol115					float, vol116				float,
					vol117					float, vol118				float,
					vol119					float, vol120				float,
					vol121					float, vol122				float,
					vol123					float, vol124				float,
					vol125					float, vol126				float,
					vol127					float, vol128				float,
					vol129					float, vol130				float,
					vol131					float, vol132				float,
					vol133					float, vol134				float,
					vol135					float, vol136				float,
					vol137					float, vol138				float,
					vol139					float, vol140				float,
					vol141					float, vol142				float,
					vol143					float, vol144				float,
					vol145					float, vol146				float,
					vol147					float, vol148				float,
					vol149					float, vol150				float,
					vol151					float, vol152				float,
					vol153					float, vol154				float,
					vol155					float, vol156				float,
					vol157					float, vol158				float,
					vol159					float, vol160				float,
					vol161					float, vol162				float,
					vol163					float, vol164				float,
					vol165					float, vol166				float,
					vol167					float, vol168				float,
					vol169					float, vol170				float,
					vol171					float, vol172				float,
					vol173					float, vol174				float,
					vol175					float, vol176				float,
					vol177					float, vol178				float,
					vol179					float, vol180				float,
					vol181					float, vol182				float,
					vol183					float, vol184				float,
					vol185					float, vol186				float,
					vol187					float, vol188				float,
					vol189					float, vol190				float,
					vol191					float, vol192				float,
					vol193					float, vol194				float,
					vol195					float, vol196				float,
					vol197					float, vol198				float,
					vol199					float, vol200				float,
					vol201					float, vol202				float,
					vol203					float, vol204				float,
					vol205					float, vol206				float,
					vol207					float, vol208				float,
					vol209					float, vol210				float,
					vol211					float, vol212				float,
					vol213					float, vol214				float,
					vol215					float, vol216				float,
					vol217					float, vol218				float,
					vol219					float, vol220				float,
					vol221					float, vol222				float,
					vol223					float, vol224				float,
					vol225					float, vol226				float,
					vol227					float, vol228				float,
					vol229					float, vol230				float,
					vol231					float, vol232				float,
					vol233					float, vol234				float,
					vol235					float, vol236				float,
					vol237					float, vol238				float,
					vol239					float, vol240				float,
					vol241					float, vol242				float,
					vol243					float, vol244				float,
					vol245					float, vol246				float,
					vol247					float, vol248				float,
					vol249					float, vol250				float,
					vol251					float, vol252				float,
					vol253					float, vol254				float,
					vol255					float, vol256				float,
					vol257					float, vol258				float,
					vol259					float, vol260				float,
					vol261					float, vol262				float,
					vol263					float, vol264				float,
					vol265					float, vol266				float,
					vol267					float, vol268				float,
					vol269					float, vol270				float,
					vol271					float, vol272				float,
					vol273					float, vol274				float,
					vol275					float, vol276				float,
					vol277					float, vol278				float,
					vol279					float, vol280				float,
					vol281					float, vol282				float,
					vol283					float, vol284				float,
					vol285					float, vol286				float,
					vol287					float, vol288				float
				)'
	
END
ELSE IF @tablename = 'deal_detail_hour_csv'
BEGIN
	SET @sql = 'CREATE TABLE ' + @temptablename + '(
					ean_code varchar(100),
					date	VARCHAR(100),
					hours	TINYINT,
					vol		FLOAT,
					extra	varchar(10)
				)'
END
ELSE IF @tablename = 'mv90_data_mins'
BEGIN
	SET @sql = 'CREATE TABLE ' + @temptablename + ' (
					[meter_id] VARCHAR(100),
					[channel] INT,
					[date] VARCHAR(10),
					[hour] varchar(5),
					[value] VARCHAR(100)
				)'
END
ELSE IF @tablename = 'holiday_group'
BEGIN
	SET @sql = 'CREATE TABLE ' + @temptablename + '
	            (
	            	[holiday_group]       VARCHAR(200),
	            	[description]         VARCHAR(400),
	            	[maturity_date_from]  VARCHAR(20),	--[hol_date]
	            	[maturity_date_to]    VARCHAR(20),
	            	[expiration_date]     VARCHAR(20),
	            	[settlement_date]     VARCHAR(20)
	            )'	
END
ELSE IF @tablename = 'Storage_Schedule_Import'
BEGIN
	SET @sql = 'CREATE TABLE ' + @temptablename + '
	            (
	            	[source_deal_header_id]       VARCHAR(200),
	            	[reference_id]         VARCHAR(400),
	            	[term_start]  VARCHAR(20),	
	            	[volume]    VARCHAR(20)
	            )'	
END
ELSE IF @tablename = 'imbalance_volume'
BEGIN
	SET @sql = 'CREATE TABLE ' + @temptablename + '
	            (
	            	[source_curve_def_id]  VARCHAR(100),
	            	[as_of_date]           VARCHAR(10),
	            	[hour]                 VARCHAR(5),
	            	[volume]               VARCHAR(100),
	            	[excluded_column1]     VARCHAR(10),
	            	[excluded_column2]     VARCHAR(10)
	            ) '
END

ELSE IF @tablename = 'Finance_Categories'
BEGIN
	SET @sql = 'CREATE TABLE ' + @temptablename + '
	            (
	            	[sub_id]				VARCHAR(25),
	            	[counterparty_id]		VARCHAR(50),
	            	[deferral]				VARCHAR(20),
	            	[buy_sell_flag]			VARCHAR(8),
	            	[source_deal_type_id]	VARCHAR(50),
	            	[charge_type_id]		VARCHAR(50),
	            	[contract_id]			VARCHAR(50),
	            	[gl_code]				VARCHAR(50),
	            	[cat1]					VARCHAR(50),
	            	[cat2]					VARCHAR(50),
	            	[cat3]					VARCHAR(50)
	            ) '	
END

EXEC spa_print @sql
EXEC(@sql)
SELECT  @temptablename [TableName]