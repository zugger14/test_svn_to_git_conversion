IF EXISTS (SELECT 1 FROM sys.objects WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[spa_schedule_deal_flow_optimization]') AND TYPE IN (N'P', N'PC'))
	DROP PROCEDURE [dbo].[spa_schedule_deal_flow_optimization]
	
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**
	Create deals and optimizer data according to flow scheduled

	Parameters 
	@flag : Not in use
	@flow_date_from : Flow Date From
	@sub : Subsidiary
	@str : Strategy
	@book : Book
	@sub_book : Sub Book
	@box_ids : Box Ids
	@contract_process_id : Contract Process Id
	@from_priority : From Priority
	@to_priority : To Priority
	@flow_date_to : Flow Date To
	@counterparty_id : Counterparty Id
	@call_from : Call From
	@granularity : Granularity
	@period : Period
	@target_uom : Target Uom
	@reschedule : Flag for Reschedule
	@receipt_deals_id : Receipt Deals Id
	@delivery_deals_id : Delivery Deals Id
*/
CREATE PROC [dbo].[spa_schedule_deal_flow_optimization]
	@flag					CHAR(1)
	, @flow_date_from		DATETIME
	, @sub					VARCHAR(1000) = NULL
	, @str					VARCHAR(1000) = NULL
	, @book					VARCHAR(1000) = NULL --,'162,164,166,206'
	, @sub_book				VARCHAR(1000)
	, @box_ids				VARCHAR(1000)
	, @contract_process_id	VARCHAR(50) = NULL
	, @from_priority		INT = NULL
	, @to_priority			INT = NULL
	, @flow_date_to			DATETIME = NULL
	, @counterparty_id		INT = NULL
	, @call_from			VARCHAR(500) = NULL --transmission_opt
	, @granularity			INT = NULL
    , @period				VARCHAR(1000) = NULL
	, @target_uom			INT = NULL
	, @reschedule			TINYINT = 0
	, @receipt_deals_id		VARCHAR(200) = NULL
	, @delivery_deals_id	VARCHAR(200) = NULL
AS
SET NOCOUNT ON

/*
	SET NOCOUNT ON


	DECLARE @flag CHAR(1)
		, @flow_date_from DATETIME
		, @sub VARCHAR(1000) = NULL
		, @str VARCHAR(1000) = NULL
		, @book VARCHAR(1000) = NULL
		, @sub_book VARCHAR(1000)
		, @box_ids VARCHAR(1000)
		, @contract_process_id	VARCHAR(50) = NULL
		, @from_priority INT = NULL
		, @to_priority INT = NULL
		, @flow_date_to DATETIME = NULL
		, @counterparty_id INT = NULL
		, @call_from VARCHAR(500) = NULL --transmission_opt
		, @granularity INT = NULL
		, @period VARCHAR(1000) = NULL
		, @target_uom INT = NULL
		, @reschedule TINYINT = 0
		, @receipt_deals_id VARCHAR(200) = NULL
		, @delivery_deals_id VARCHAR(200) = NULL

	EXEC sys.sp_set_session_context @key = N'DB_USER', @value = 'adangol'

	--Sets contextinfo to debug mode so that spa_print will prints data
	DECLARE @contextinfo VARBINARY(128) = CONVERT(VARBINARY(128), 'DEBUG_MODE_ON')
	SET CONTEXT_INFO @contextinfo

	EXEC spa_print 'Use spa_print instead of PRINT statement in debug mode.'
		
	--Drops all temp tables created in this scope.
	EXEC [spa_drop_all_temp_table] 
	
	-- SPA parameter values

select 
	@flag = 'i'
	, @box_ids = '3'
	, @flow_date_from = '2025-07-01'
	, @flow_date_to = '2025-07-01'
	, @sub = NULL
	, @str = NULL
	, @book = NULL
	, @sub_book = NULL
	, @contract_process_id = 'E7FE6D8B_4A0E_444D_B2DC_34C122B9ADC9'
	, @from_priority = NULL
	, @to_priority = NULL
	, @call_from = 'flow_auto'
	, @target_uom = 1158
	, @reschedule = 0
	, @granularity = 982


--transport_deal_id	deal_volume		up_down_stream	source_deal_header_id
--219590				6014.00000000	U				219589
--219590				7001.00000000	D				219591
--219591				6001.00000000	U				219590
--219591				7002.00000000	D				219591
---- */
DECLARE @process_id					VARCHAR(50)
	, @report_position				VARCHAR(250)
	, @user_name					VARCHAR(30)
	, @st1							VARCHAR(MAX)
	, @sdh_id						INT
	, @idoc							INT
	, @contract_detail				VARCHAR(250)
	, @contract_detail_fresh		VARCHAR(250)
	, @contract_detail_hourly		VARCHAR(250)
	, @scheduled_deals				VARCHAR(250)
	, @opt_deal_detail_pos			VARCHAR(250)
	, @sdv_from_deal				INT
	, @sdv_priority					INT
	, @sdv_to_deal					INT
	, @path_id						INT
	, @package_id					VARCHAR(20) 
	, @upstream_counterparty		INT
	, @upstream_contract			INT
	, @gen_nomination_mapping		VARCHAR(100) 
	, @storage_book_mapping			VARCHAR(100)
	, @dest_deal_info				VARCHAR(500) 
	, @single_path_id				INT
	, @transportation_template_id   INT
	, @transportation_deal_type_id	INT
	, @base_contract_id				INT
	, @default_counterparty_id      INT
	, @default_trader_id			INT
	, @is_hourly_calc				BIT --flag to check if hourly calculation is needed
	, @sql							VARCHAR(MAX)
	, @template_names				VARCHAR(1000)

SET @is_hourly_calc = IIF(@granularity = 982, 1, 0);

SET @package_id = REPLACE(LTRIM(REPLACE(STR(CAST(RAND() AS NUMERIC(20,20)),20,20),'0.','')),' ','')

SELECT @sdv_from_deal = value_id
FROM static_data_value
WHERE [TYPE_ID] = 5500 
	AND code = 'From Deal'

SELECT @sdv_to_deal = value_id
FROM static_data_value
WHERE [TYPE_ID] = 5500 
	AND code = 'To Deal'

SELECT @sdv_priority = value_id
FROM static_data_value
WHERE [TYPE_ID] = 5500 
	AND code = 'Priority'
	 
SELECT @upstream_counterparty = value_id
FROM static_data_value
WHERE [TYPE_ID] = 5500 
	AND code = 'Upstream CPTY'

SELECT @upstream_contract = value_id
FROM static_data_value
WHERE [TYPE_ID] = 5500 
	AND code = 'Upstream Contract'

SELECT @transportation_template_id = template_id 
FROM source_deal_header_template
WHERE template_name = 'Transportation NG'

SELECT @transportation_deal_type_id = source_deal_type_id 
FROM source_deal_type
WHERE deal_type_id = 'Transportation'

SELECT @base_contract_id = contract_id 
FROM contract_group
WHERE contract_name = 'Back to Back Transportation Contract' --TO DO: Reveiw hardcoded value

SELECT @default_counterparty_id = source_counterparty_id
FROM source_counterparty
WHERE counterparty_name  = 'ANR Pipeline Company' --TO DO: Reveiw hardcoded value

SET @gen_nomination_mapping = 'Flow Optimization Mapping'
SET @storage_book_mapping = 'Storage Book Mapping'

SET @template_names = 'Transportation NG, Transmission Phy'


IF @period IS NULL AND @granularity IS NOT NULL AND @call_from = 'transmission_opt'
	SELECT @period = CASE WHEN @granularity = 982 THEN '1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24'
						  WHEN @granularity = 987 THEN '1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48'
						  --WHEN @granularity=982 THEN '1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24'
					END

SET @from_priority = ISNULL(@from_priority, @to_priority)
SET @to_priority = ISNULL(@to_priority, @from_priority)

-- change value id filter to code
SELECT @from_priority = sdv.code
FROM static_data_value sdv 
WHERE sdv.value_id = @from_priority

SELECT @to_priority = sdv.code
FROM static_data_value sdv 
WHERE sdv.value_id = @to_priority

SELECT CAST(clm1_value AS INT) pipeline
	, CAST(clm2_value AS INT) sub_book_id	   
	, CAST(clm3_value AS INT) path_id	   
INTO #gen_nomination_mapping
FROM generic_mapping_header h 
INNER JOIN generic_mapping_values v 
	ON v.mapping_table_id = h.mapping_table_id
	AND h.mapping_name = @gen_nomination_mapping

SELECT CAST(clm1_value AS INT) location_id
		, clm2_value storage_type 
		, CAST(clm3_value AS INT) pipeline
		, CAST(clm4_value AS INT) sub_book_id 
		, CAST(clm5_value AS INT) path_id
		, CAST(clm6_value AS INT) pfc_curve_id 
INTO #storage_book_mapping
FROM generic_mapping_header h 
INNER JOIN generic_mapping_values v 
	ON v.mapping_table_id = h.mapping_table_id
	AND h.mapping_name = @storage_book_mapping 
	AND clm2_value IN ('w', 'i')

SET @process_id = ISNULL(@contract_process_id, dbo.FNAGetNewID())
SET @user_name = dbo.FNADBUser()	-- 'gkoju' -- 
SET @report_position = dbo.FNAProcessTableName('report_position', @user_name, @process_id) 
SET @contract_detail = dbo.FNAProcessTableName('contractwise_detail_mdq', @user_name, @process_id) 
SET @contract_detail_fresh	= dbo.FNAProcessTableName('contractwise_detail_mdq_fresh', @user_name, @process_id) 
SET @contract_detail_hourly = dbo.FNAProcessTableName('contractwise_detail_mdq_hourly', @user_name, @process_id) 
SET @scheduled_deals = dbo.FNAProcessTableName('scheduled_deals', @user_name, @process_id) 
SET @opt_deal_detail_pos = dbo.FNAProcessTableName('opt_deal_detail_pos', @user_name, @process_id) 
SET @dest_deal_info = dbo.FNAProcessTableName('dest_deal_info', @user_name, @process_id)
DECLARE @hourly_pos_info VARCHAR(500) = dbo.FNAProcessTableName('hourly_pos_info', @user_name, @process_id)
DECLARE @inserted_updated_deals VARCHAR(500) = dbo.FNAProcessTableName('inserted_updated_deals', @user_name, @process_id)

--Delete deals on storage location from process table
SET @sql = 'DELETE FROM '+  @opt_deal_detail_pos + ' WHERE location_type = ''storage''' 
EXEC(@sql)

CREATE TABLE #dest_deal_info
(
	group_path_id INT,
	single_path_id INT,
	rec_vol FLOAT, 
	del_vol FLOAT, 
	term_start DATETIME
)

CREATE TABLE #existing_deals (
	source_deal_header_id INT
	, single_path_id INT
	, group_path_id INT
	, description1 NVARCHAR(500) COLLATE DATABASE_DEFAULT
	, description2 NVARCHAR(500) COLLATE DATABASE_DEFAULT
	, contract_id INT
	, leg1_loc_id INT
	, leg2_loc_id INT
	, deal_id NVARCHAR(500) COLLATE DATABASE_DEFAULT
	, first_dom DATETIME
	, flow_date_from DATETIME
	, flow_date_to DATETIME
	, include_rec INT
	, storage_deal_type CHAR(1) COLLATE DATABASE_DEFAULT
	, org_storage_deal_type CHAR(1) COLLATE DATABASE_DEFAULT
)


IF @call_from = 'flow_match'
BEGIN
	EXEC('
	INSERT INTO #dest_deal_info(group_path_id, single_path_id, rec_vol, del_vol, term_start )
	SELECT group_path_id, single_path_id, rec_vol, del_vol, term_start  FROM  ' + @dest_deal_info)
END

IF OBJECT_ID(@scheduled_deals) IS NOT NULL
	EXEC('DROP TABLE ' + @scheduled_deals)

IF OBJECT_ID(@report_position) IS NOT NULL
	EXEC('DROP TABLE ' + @report_position)

EXEC ('IF OBJECT_ID (N''' + @report_position + ''') IS NOT NULL DROP TABLE ' + @report_position + ' 
		CREATE TABLE ' + @report_position + '(source_deal_header_id INT, action CHAR(1) COLLATE DATABASE_DEFAULT) ')  
			   
EXEC ('IF OBJECT_ID (N''' + @inserted_updated_deals + ''') IS NOT NULL DROP TABLE ' + @inserted_updated_deals + ' 
		CREATE TABLE ' + @inserted_updated_deals + '(source_deal_header_id INT, is_inserted INT) ')  



SET @from_priority = COALESCE(@from_priority, @to_priority, 0)
SET @to_priority = COALESCE(@to_priority, NULLIF(@from_priority, 0), 999999999)

CREATE TABLE #collect_deals(
	rowid						INT IDENTITY(1, 1)
	, box_id					INT
	, source_deal_header_id		INT 
	, term_start				DATETIME  
	, path_id					INT
	, from_location				INT
	, to_location				INT
	, receipt_volume			NUMERIC(38,20)
	, delivery_volume			NUMERIC(38,20)
	, loss_factor				NUMERIC(38,20)
	, contract_id				INT
	, storage_deal_type			CHAR(1) COLLATE DATABASE_DEFAULT
	, storage_asset_id			INT	
	, storage_volume			NUMERIC(38,20)
	, location_id				INT
	, route_id					INT
	, org_storage_deal_type		CHAR(1) COLLATE DATABASE_DEFAULT
	, mdq						FLOAT
	, receipt_deals				VARCHAR(MAX) COLLATE DATABASE_DEFAULT
	, delivery_deals			VARCHAR(MAX) COLLATE DATABASE_DEFAULT
	, match_term_start			DATETIME
	, match_term_end			DATETIME
	, group_path				VARCHAR(1) COLLATE DATABASE_DEFAULT
	, single_path_id			INT
)

CREATE TABLE #inserted_optimizer_detail (
	optimizer_detail_id INT
)

--CREATE FRAME #tmp_header
SELECT [source_system_id]
	, CAST([deal_id] AS VARCHAR(250)) [deal_id]
	, [deal_date]
	, [ext_deal_id]
	, [physical_financial_flag]
	, [structured_deal_id]
	, [counterparty_id]
	, [entire_term_start]
	, [entire_term_end]
	, [source_deal_type_id]
	, [deal_sub_type_type_id]
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
	, [deal_category_value_id]
	, [trader_id]
	, [internal_deal_type_value_id]
	, [internal_deal_subtype_value_id]
	, [template_id]
	, [header_buy_sell_flag]
	, [broker_id]
	, [generator_id]
	, [status_value_id]
	, [status_date]
	, [assignment_type_value_id]
	, [compliance_year]
	, [state_value_id]
	, [assigned_date]
	, [assigned_by]
	, [generation_source]
	, [aggregate_environment]
	, [aggregate_envrionment_comment]
	, [rec_price]
	, [rec_formula_id]
	, [rolling_avg]
	, [contract_id]
	, [create_user]
	, [create_ts]
	, [update_user]
	, [update_ts]
	, [legal_entity]
	, [internal_desk_id]
	, [product_id]
	, [internal_portfolio_id]
	, [commodity_id]
	, [reference]
	, [deal_locked]
	, [close_reference_id]
	, [block_type]
	, [block_define_id]
	, [granularity_id]
	, [Pricing]
	, [deal_reference_type_id]
	, [unit_fixed_flag]
	, [broker_unit_fees]
	, [broker_fixed_cost]
	, [broker_currency_id]
	, [deal_status]
	, [term_frequency]
	, [option_settlement_date]
	, [verified_by]
	, [verified_date]
	, [risk_sign_off_by]
	, [risk_sign_off_date]
	, [back_office_sign_off_by]
	, [back_office_sign_off_date]
	, [book_transfer_id]
	, [confirm_status_type]
	, [sub_book]
	, [deal_rules]
	, [confirm_rule]
	, [description4]
	, [timezone_id]
	, CAST(0 AS INT) source_deal_header_id 
	, CAST(1 AS BIT) is_insert
INTO #tmp_header
FROM [dbo].[source_deal_header] 
WHERE 1 = 2

BEGIN --START OF INSERTING TEMPLATE DEAL

	CREATE TABLE #temp_deal_template (
		template_name VARCHAR(200) COLLATE DATABASE_DEFAULT,
		storage_asset_id INT, 
		storage_deal_type CHAR(1) COLLATE DATABASE_DEFAULT
	)

	SET @sql = '
			INSERT INTO #temp_deal_template (template_name, storage_asset_id, storage_deal_type)
			SELECT DISTINCT
						CASE cd.storage_deal_type 
						WHEN ''i'' THEN  ISNULL(NULLIF(sdhti.template_name, ''''), ''Storage Injection'')
						WHEN ''w'' THEN  ISNULL(NULLIF(sdhtw.template_name, ''''), ''Storage Withdrawal'')
						END	,
						cd.storage_asset_id,
						cd.storage_deal_type			
				FROM ' + @contract_detail + ' cd
				LEFT JOIN general_assest_info_virtual_storage g
					ON g.general_assest_id = cd.storage_asset_id
				LEFT JOIN source_deal_header_template sdhti
					ON sdhti.template_id = g.injection_template_id
				LEFT JOIN source_deal_header_template sdhtw
					ON sdhtw.template_id = g.withdrawal_template_id
				WHERE cd.storage_deal_type IN (''i'', ''w'') AND cd.path_id <> 0
			'
	--print (@sql)
	EXEC (@sql)


	SELECT @template_names = @template_names + ', ' + template_name
	FROM #temp_deal_template 


	SELECT @default_counterparty_id = MIN(source_counterparty_id) 
	FROM source_counterparty

	SELECT @default_trader_id = MIN(source_trader_id)
	FROM source_traders

	SELECT * INTO #source_deal_header FROM source_deal_header WHERE 1 = 0
	SELECT * INTO #source_deal_detail FROM source_deal_detail WHERE 1 = 0
	SELECT * INTO #user_defined_deal_fields FROM user_defined_deal_fields WHERE 1 = 0

	--Creating template deals from deal template
	INSERT INTO #source_deal_header (
		[source_system_id]
		,deal_id
		,[deal_date]
		,[ext_deal_id]
		,[physical_financial_flag]
		,[structured_deal_id]
		,[counterparty_id]
		,[entire_term_start]
		,[entire_term_end]
		,[source_deal_type_id]
		,[deal_sub_type_type_id]
		,[option_flag]
		,[option_type]
		,[option_excercise_type]
		,[description1]
		,[description2]
		,[description3]
		,[deal_category_value_id]
		,[trader_id]
		,[internal_deal_type_value_id]
		,[internal_deal_subtype_value_id]
		,[template_id]
		,[header_buy_sell_flag]
		,[broker_id]
		,[generator_id]
		,[status_value_id]
		,[status_date]
		,[assignment_type_value_id]
		,[compliance_year]
		,[state_value_id]
		,[assigned_date]
		,[assigned_by]
		,[generation_source]
		,[aggregate_environment]
		,[aggregate_envrionment_comment]
		,[rec_price]
		,[rec_formula_id]
		,[rolling_avg]
		,[contract_id]
		,[create_user]
		,[create_ts]
		,[update_user]
		,[update_ts]
		,[legal_entity]
		,[internal_desk_id]
		,[product_id]
		,[internal_portfolio_id]
		,[commodity_id]
		,[reference]
		,[deal_locked]
		,[close_reference_id]
		,[block_type]
		,[block_define_id]
		,[granularity_id]
		,[Pricing]
		,[deal_reference_type_id]
		,[unit_fixed_flag]
		,[broker_unit_fees]
		,[broker_fixed_cost]
		,[broker_currency_id]
		,[deal_status]
		,[term_frequency]
		,[option_settlement_date]
		,[verified_by]
		,[verified_date]
		,[risk_sign_off_by]
		,[risk_sign_off_date]
		,[back_office_sign_off_by]
		,[back_office_sign_off_date]
		,[book_transfer_id]
		,[confirm_status_type]
		,[deal_rules]
		,[confirm_rule]
		,[description4]
		,[timezone_id]
		,[source_system_book_id1]
		,[source_system_book_id2]
		,[source_system_book_id3]
		,[source_system_book_id4]	
	)

	SELECT 
		[source_system_id]
		, CASE template_name 
			WHEN 'Transportation NG' THEN 'Gath Nom Template'
			WHEN 'Transmission Phy' THEN 'Transmission Template' 
			ELSE template_name
		 END deal_id
		, GETDATE()
		,[ext_deal_id]
		,[physical_financial_flag]
		,[structured_deal_id]
		,ISNULL([counterparty_id], @default_counterparty_id)
		,GETDATE()
		,GETDATE()
		,[source_deal_type_id]
		,[deal_sub_type_type_id]
		,[option_flag]
		,[option_type]
		,[option_excercise_type]
		,[description1]
		,NULL [description2] --TO DO: Remove hardcored NULL
		,[description3]
		,[deal_category_value_id]
		,ISNULL([trader_id], @default_trader_id)
		,[internal_deal_type_value_id]
		,[internal_deal_subtype_value_id]
		,[template_id]
		,[header_buy_sell_flag]
		,[broker_id]
		,[generator_id]
		,[status_value_id]
		,[status_date]
		,[assignment_type_value_id]
		,[compliance_year]
		,[state_value_id]
		,[assigned_date]
		,[assigned_by]
		,[generation_source]
		,[aggregate_environment]
		,[aggregate_envrionment_comment]
		,[rec_price]
		,[rec_formula_id]
		,[rolling_avg]
		,[contract_id]
		,[create_user]
		,[create_ts]
		,[update_user]
		,[update_ts]
		,[legal_entity]
		,[internal_desk_id]
		,[product_id]
		,[internal_portfolio_id]
		,[commodity_id]
		,[reference]
		,[deal_locked]
		,[close_reference_id]
		,[block_type]
		,[block_define_id]
		,[granularity_id]
		,[Pricing]
		,[deal_reference_type_id]
		,[unit_fixed_flag]
		,[broker_unit_fees]
		,[broker_fixed_cost]
		,[broker_currency_id]
		,[deal_status]
		, 'd'
		,[option_settlement_date]
		,[verified_by]
		,[verified_date]
		,[risk_sign_off_by]
		,[risk_sign_off_date]
		,[back_office_sign_off_by]
		,[back_office_sign_off_date]
		,[book_transfer_id]
		,[confirm_status_type]
		,[deal_rules]
		,[confirm_rule]
		,[description4]
		,[timezone_id]
		, -1
		, -2
		, -3
		, -4
	 FROM source_deal_header_template sdht
	 INNER JOIN dbo.SplitCommaSeperatedValues(@template_names) t
		ON t.item = sdht.template_name

	INSERT INTO #source_deal_detail
	(
		[source_deal_header_id]
		, [term_start]
		, [term_end]
		, [Leg]
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
		, [volume_left]
		, [settlement_volume]
		, [settlement_uom]
		, [create_user]
		, [create_ts]
		, [update_user]
		, [update_ts]
		, [price_adder]
		, [price_multiplier]
		, [settlement_date]
		, [day_count_id]
		, [location_id]
		, [meter_id]
		, [physical_financial_flag]
		, [Booked]
		, [process_deal_status]
		, [fixed_cost]
		, [multiplier]
		, [adder_currency_id]
		, [fixed_cost_currency_id]
		, [formula_currency_id]
		, [price_adder2]
		, [price_adder_currency2]
		, [volume_multiplier2]
		, [pay_opposite]
		, [capacity]
		, [settlement_currency]
		, [standard_yearly_volume]
		, [formula_curve_id]
		, [price_uom_id]
		, [category]
		, [profile_code]
		, [pv_party]
		, [status]
		, [lock_deal_detail]
	)
	 SELECT 
		 sdh.source_deal_header_id
		, sddt.[term_start]
		, sddt.[term_end]
		, sddt.[Leg]
		, sddt.[contract_expiration_date]
		, sddt.[fixed_float_leg]
		, sddt.[buy_sell_flag]
		, sddt.[curve_id]
		, sddt.[fixed_price]
		, sddt.[fixed_price_currency_id]
		, sddt.[option_strike_price]
		, sddt.[deal_volume]
		, sddt.[deal_volume_frequency]
		, sddt.[deal_volume_uom_id]
		, sddt.[block_description]
		, sddt.[deal_detail_description]
		, sddt.[formula_id]
		, sddt.[volume_left]
		, sddt.[settlement_volume]
		, sddt.[settlement_uom]
		, sddt.[create_user]
		, sddt.[create_ts]
		, sddt.[update_user]
		, sddt.[update_ts]
		, sddt.[price_adder]
		, sddt.[price_multiplier]
		, sddt.[settlement_date]
		, sddt.[day_count_id]
		, sddt.[location_id]
		, sddt.[meter_id]
		, sddt.[physical_financial_flag]
		, sddt.[Booked]
		, sddt.[process_deal_status]
		, sddt.[fixed_cost]
		, sddt.[multiplier]
		, sddt.[adder_currency_id]
		, sddt.[fixed_cost_currency_id]
		, sddt.[formula_currency_id]
		, sddt.[price_adder2]
		, sddt.[price_adder_currency2]
		, sddt.[volume_multiplier2]
		, sddt.[pay_opposite]
		, sddt.[capacity]
		, sddt.[settlement_currency]
		, sddt.[standard_yearly_volume]
		, sddt.[formula_curve_id]
		, sddt.[price_uom_id]
		, sddt.[category]
		, sddt.[profile_code]
		, sddt.[pv_party]
		, sddt.[status]
		, sddt.[lock_deal_detail]
	  FROM source_deal_detail_template sddt
		INNER JOIN source_deal_header_template sdht
			ON sddt.template_id = sdht.template_id
		INNER JOIN #source_deal_header sdh
			ON sdh.template_id = sdht.template_id

	INSERT INTO #user_defined_deal_fields (
		source_deal_header_id, 
		udf_template_id, 
		udf_value
	)
	SELECT 
		sdh.source_deal_header_id, 
		udf_template_id, 
		default_value
	FROM user_defined_deal_fields_template_main uddft
	INNER JOIN source_deal_header_template sdht
		ON uddft.template_id = sdht.template_id
	INNER JOIN #source_deal_header sdh
		ON sdh.template_id = uddft.template_id
	AND udf_type= 'h'


END --END OF INSERTING TEMPLATE DEAL


BEGIN --Data Prepararion
	
	
	--Update contract_detail process table with sum of hourly received and delivered volume 
	IF @is_hourly_calc = 1
	BEGIN 
		SET @sql = 'UPDATE c
						SET received = ISNULL(NULLIF(c.received, 0), h.received), 
							delivered = ISNULL(NULLIF(c.delivered, 0), h.delivered)
					FROM ' + @contract_detail + ' c
					CROSS APPLY(
						SELECT SUM(ch.received) received 
							, SUM(ch.delivered)  delivered
						FROM ' + @contract_detail_hourly + ' ch
						WHERE 	ch.box_id = c.box_id
						GROUP BY box_id
					) h
					'
		--print @sql
		EXEC(@sql)

		SET @sql = 'UPDATE c
					SET received = ISNULL(NULLIF(c.received, 0), h.received), 
						delivered = ISNULL(NULLIF(c.delivered, 0), h.delivered)
				FROM ' + @contract_detail_fresh + ' c
				CROSS APPLY(
					SELECT SUM(ch.received) received 
						, SUM(ch.delivered)  delivered
					FROM ' + @contract_detail_hourly + ' ch
					WHERE 	ch.box_id = c.box_id
					GROUP BY box_id
				) h
				'
		--print @sql
		EXEC(@sql)
	END

	/**** INSERT COLLECT DEALS 1 ****/
	SET @sql = '
		INSERT INTO #collect_deals (
			box_id
			, source_deal_header_id	
			, path_id				
			, from_location			
			, to_location			
			, receipt_volume		
			, delivery_volume	
			, loss_factor	
			, contract_id
			, location_id
			, storage_deal_type
			, route_id
			, storage_volume
			, org_storage_deal_type
			, mdq
			, receipt_deals
			, delivery_deals
			, match_term_start
			, match_term_end
			, group_path
			, single_path_id
		)
		SELECT DISTINCT  
			t.box_id
			, d.source_deal_header_id			
			, t.path_id
			, dp.from_location
			, dp.to_location
			, t.received receipt_volume
			, t.delivered delivery_volume
			, ISNULL(t.loss_factor,0) loss_factor
			, t.contract_id 
			, dp.from_location  [location_id]
			, ''n'' storage_deal_type
			, t.box_id  route_id
			, NULL storage_volume	
			, CASE WHEN t.from_loc_grp_name = ''Storage''  
					THEN ''w'' 
					ELSE 
						CASE WHEN t.to_loc_grp_name = ''Storage'' THEN ''i'' ELSE ''n'' END 
				END  org_storage_deal_type
			, t.path_mdq
			, t.receipt_deals
			, t.delivery_deals
			, t.match_term_start
			, t.match_term_end
			, t.group_path
			, dp.path_id
		FROM ' + @contract_detail + ' t 
		CROSS JOIN (
			SELECT DISTINCT h.source_deal_header_id
			FROM  #source_deal_header h 
			WHERE deal_id=''' + CASE WHEN @call_from = 'transmission_opt' THEN 'Transmission Template' ELSE  'Gath Nom Template' END +'''
		) d	
		LEFT JOIN delivery_path dp 
			ON dp.path_id = COALESCE(t.single_path_id, t.path_id)
		WHERE t.box_id IN (' + @box_ids + ')' 
		+	
		--CASE WHEN ISNULL(@reschedule, 0) = 0 
		--	THEN ' AND t.received <> 0 
		--			AND t.delivered <> 0 ' ELSE '' END +
		'
		--ORDER BY t.box_id
	'
	EXEC(@sql)



	--SELECT 'collect_deals1',* FROM #collect_deals

	/**** INSERT COLLECT DEALS 2 
	****/
	SET @sql = '
		INSERT INTO #collect_deals(
			box_id
			, source_deal_header_id	
			, path_id				
			, from_location			
			, to_location			
			, receipt_volume		
			, delivery_volume	
			, loss_factor	
			, contract_id
			, storage_deal_type
			, storage_asset_id
			, storage_volume	
			, location_id
			, route_id  
			, org_storage_deal_type
			, receipt_deals
			, delivery_deals
			, match_term_start
			, match_term_end
			, group_path
			, single_path_id
		)
		SELECT DISTINCT  
			t.box_id
			, d.source_deal_header_id
			, t.path_id
			, CASE	WHEN t.from_loc_grp_name=''Storage'' THEN dp.from_location  --for storage FROM location AND to location is same.
					WHEN t.to_loc_grp_name=''Storage'' THEN dp.to_location 
					ELSE NULL
			  END
			, CASE	WHEN t.from_loc_grp_name=''Storage'' THEN dp.from_location --for storage FROM location AND to location is same.
					WHEN t.to_loc_grp_name=''Storage'' THEN dp.to_location 
					ELSE NULL
			  END
			, t.received receipt_volume
			, t.delivered delivery_volume
			, ISNULL(t.loss_factor,0) loss_factor
			, t.contract_id 
			, CASE WHEN t.from_loc_grp_name = ''Storage'' THEN ''w'' ELSE 
				CASE WHEN t.to_loc_grp_name = ''Storage'' THEN ''i'' ELSE ''n'' END 
			  END storage_deal_type
			, t.storage_asset_id
			, NULL storage_volume
			, CASE	WHEN t.from_loc_grp_name=''Storage'' THEN dp.from_location 
					WHEN t.to_loc_grp_name=''Storage'' THEN dp.to_location 
					ELSE NULL
			  END  [location_id]
			, t.box_id  route_id	
			, CASE WHEN t.from_loc_grp_name=''Storage''  THEN ''w'' ELSE 
					CASE WHEN t.to_loc_grp_name=''Storage'' THEN ''i'' ELSE ''n'' END 
			  END org_storage_deal_type
			, t.receipt_deals
			, t.delivery_deals
			, t.match_term_start
			, t.match_term_end
			, t.group_path
			, dp.path_id
		FROM ' + @contract_detail + ' t 
		CROSS APPLY (
			SELECT DISTINCT h.source_deal_header_id
			FROM  #source_deal_header h 
			INNER JOIN #temp_deal_template tdt
				ON h.deal_id = tdt.template_name
				AND tdt.storage_asset_id = t.storage_asset_id
				AND tdt.storage_deal_type = t.storage_deal_type
		) d	
		INNER JOIN delivery_path dp 
			ON dp.path_id = COALESCE(t.single_path_id, t.path_id)
		LEFT JOIN source_minor_location sml_from 
			ON sml_from.source_minor_location_id = dp.from_location
		LEFT JOIN source_major_location smj_from 
			ON smj_from.source_major_location_ID = sml_from.source_major_location_ID
		LEFT JOIN source_minor_location sml_to 
			ON sml_to.source_minor_location_id = dp.to_location
		LEFT JOIN source_major_location smj_to 
			ON smj_to.source_major_location_ID = sml_to.source_major_location_ID
		WHERE ( ISNULL(smj_from.location_name, t.from_loc_grp_name) = ''Storage'' OR ISNULL(smj_to.location_name, t.to_loc_grp_name) = ''Storage'')
			AND t.box_id IN (' + @box_ids + ')'
			+ CASE WHEN ISNULL(@reschedule, 0) = 0  THEN ' 
			AND ISNULL(t.received, 0) <> 0 AND ISNULL(t.delivered,0) <> 0 ' ELSE '' END +'
		--ORDER BY t.box_id
		'
	--print @sql
	EXEC(@sql)

	IF OBJECT_ID(N'tempdb..#delivery_deals') IS NOT NULL DROP TABLE #delivery_deals
	CREATE TABLE #delivery_deals (source_deal_header_id INT)

	INSERT INTO #delivery_deals
	SELECT DISTINCT item
	FROM #collect_deals cd
		CROSS APPLY dbo.SplitCommaSeperatedValues(cd.delivery_deals)

	--generic mapping part
	--SELECT * FROM #gen_nomination_mapping

	IF @sub_book  IS NULL
	BEGIN
		IF EXISTS(
			SELECT	1  FROM 
			 (
			  SELECT DISTINCT CASE WHEN cd.storage_deal_type = 'i' THEN cd.to_location ELSE cd.from_location END location_id
					, dp.counterparty  pipeline 
					, cd.storage_deal_type
				FROM #collect_deals	 cd
				INNER JOIN delivery_path dp 
					ON dp.path_id = ISNULL(cd.single_path_id, cd.path_id)
					AND cd.storage_deal_type IN ('w','i')
			 ) s 
			 LEFT JOIN #storage_book_mapping sbm
				ON s.location_id = ISNULL(sbm.location_id,s.location_id) 
				AND s.pipeline = sbm.pipeline
				AND sbm.storage_type = s.storage_deal_type
			 WHERE sbm.sub_book_id IS NULL
			)
		BEGIN
 			EXEC spa_ErrorHandler -1
				, 'Flow Optimization'
				, 'spa_schedule_deal_flow_optimization'
				, 'Error'
				, 'Generic Mapping NOT found for Storage.'
				, 'generic_mapping'
			
			RETURN
		
		END 
		ELSE
		BEGIN
			IF EXISTS(
				SELECT	1  FROM (
					SELECT DISTINCT dp.counterParty pipeline, dp.path_id
					FROM #collect_deals cd
					INNER JOIN delivery_path dp 
						ON dp.path_id = ISNULL(cd.single_path_id, cd.path_id)
					WHERE cd.storage_deal_type = 'n'
				 ) s 
				 LEFT JOIN #gen_nomination_mapping sbm 
					ON  s.pipeline = sbm.pipeline
					AND s.path_id = sbm.path_id
				  WHERE sbm.sub_book_id IS NULL
				)
			BEGIN

 				EXEC spa_ErrorHandler -1
					, 'Flow Optimization'
					, 'spa_schedule_deal_flow_optimization'
					, 'Error'
					, 'Generic Mapping NOT found for Transportation.'
					, 'generic_mapping'
				RETURN
			END
		END 
	END 


	CREATE TABLE #tmp_vol_split_deal_pre (
		box_id INT,
		master_rowid INT,
		[priority] INT,
		available_volume NUMERIC(20, 2),
		delivery_volume NUMERIC(20, 2),
		tot_volume NUMERIC(20, 2),
		loss_factor FLOAT,
		contract_id INT,
		storage_asset_id INT,
		path_id INT,
		run_sum NUMERIC(20, 2),
		source_deal_header_id INT,
		[description1] VARCHAR(500) COLLATE DATABASE_DEFAULT,
		[description2] VARCHAR(500) COLLATE DATABASE_DEFAULT,
		templete_deal_id INT,
		storage_deal_type VARCHAR(1) COLLATE DATABASE_DEFAULT,
		from_location INT,
		to_location INT,
		rnk INT,
		org_storage_deal_type VARCHAR(1) COLLATE DATABASE_DEFAULT,
		source_deal_detail_id INT,
		rowid INT IDENTITY (1, 1),
		match_term_start DATETIME,
		match_term_end DATETIME,
		group_path VARCHAR(1) COLLATE DATABASE_DEFAULT,
		single_path_id INT,
		source0  TINYINT,
		actual_available_volume NUMERIC(20, 2),
		term_start DATETIME,
		term_end DATETIME,
		is_transport_deal BIT
	)

	CREATE TABLE #tmp_vol_split_deal_del_pre (
		box_id INT,
		master_rowid INT,
		[priority] INT,
		available_volume NUMERIC(20, 2),
		delivery_volume NUMERIC(20, 2),
		tot_volume NUMERIC(20, 2),
		loss_factor FLOAT,
		contract_id INT,
		storage_asset_id INT,
		path_id INT,
		run_sum NUMERIC(20, 2),
		source_deal_header_id INT,
		[description1] VARCHAR(500) COLLATE DATABASE_DEFAULT,
		[description2] VARCHAR(500) COLLATE DATABASE_DEFAULT,
		templete_deal_id INT,
		storage_deal_type VARCHAR(1) COLLATE DATABASE_DEFAULT,
		from_location INT,
		to_location INT,
		rnk INT,
		org_storage_deal_type VARCHAR(1) COLLATE DATABASE_DEFAULT,
		source_deal_detail_id INT,
		rowid INT IDENTITY (1, 1),
		match_term_start DATETIME,
		match_term_end DATETIME,
		group_path VARCHAR(1) COLLATE DATABASE_DEFAULT,
		single_path_id INT,
		source0  TINYINT,
		actual_available_volume NUMERIC(20, 2),
		term_start DATETIME,
		term_end DATETIME,
		is_transport_deal BIT
	)

	IF @is_hourly_calc = 1
	BEGIN

		CREATE TABLE #tmp_vol_split_deal_hour_pre (
			box_id INT,
			master_rowid INT,
			hr INT,
			period INT,
			[priority] INT,
			available_volume NUMERIC(20, 2),
			delivery_volume NUMERIC(20, 2),
			tot_volume NUMERIC(20, 2),
			loss_factor FLOAT,
			contract_id INT,
			storage_asset_id INT,
			path_id INT,
			run_sum NUMERIC(20, 2),
			source_deal_header_id INT,
			[description1] VARCHAR(500) COLLATE DATABASE_DEFAULT,
			[description2] VARCHAR(500) COLLATE DATABASE_DEFAULT,
			templete_deal_id INT,
			storage_deal_type VARCHAR(1) COLLATE DATABASE_DEFAULT,
			from_location INT,
			to_location INT,
			rnk INT,
			org_storage_deal_type VARCHAR(1) COLLATE DATABASE_DEFAULT,
			source_deal_detail_id INT,
			rowid INT IDENTITY (1, 1),
			match_term_start DATETIME,
			match_term_end DATETIME,
			group_path VARCHAR(1) COLLATE DATABASE_DEFAULT,
			single_path_id INT,
			source0  TINYINT,
			actual_available_volume NUMERIC(20, 2),
			term_start DATETIME,
			term_end DATETIME,
			is_transport_deal BIT
		)

		CREATE TABLE #tmp_vol_split_deal_del_hour_pre (
			box_id INT,
			master_rowid INT,
			hr INT,
			period INT,
			[priority] INT,
			available_volume NUMERIC(20, 2),
			delivery_volume NUMERIC(20, 2),
			tot_volume NUMERIC(20, 2),
			loss_factor FLOAT,
			contract_id INT,
			storage_asset_id INT,
			path_id INT,
			run_sum NUMERIC(20, 2),
			source_deal_header_id INT,
			[description1] VARCHAR(500) COLLATE DATABASE_DEFAULT,
			[description2] VARCHAR(500) COLLATE DATABASE_DEFAULT,
			templete_deal_id INT,
			storage_deal_type VARCHAR(1) COLLATE DATABASE_DEFAULT,
			from_location INT,
			to_location INT,
			rnk INT,
			org_storage_deal_type VARCHAR(1) COLLATE DATABASE_DEFAULT,
			source_deal_detail_id INT,
			rowid INT IDENTITY (1, 1),
			match_term_start DATETIME,
			match_term_end DATETIME,
			group_path VARCHAR(1) COLLATE DATABASE_DEFAULT,
			single_path_id INT,
			source0  TINYINT,
			actual_available_volume NUMERIC(20, 2),
			term_start DATETIME,
			term_end DATETIME,
			is_transport_deal BIT
		)
	END


	SET @sql = 'UPDATE ' +  @opt_deal_detail_pos + ' SET priority = NULL ' --WHERE priority = 168 '  --TODO: Review this hardcorded value
	EXEC(@sql)

	---retrieving source deal
	-- Collect Receive Deals
	SET @sql = '
		INSERT INTO #tmp_vol_split_deal_pre (
			box_id
			, master_rowid
			, [priority]
			, available_volume
			, tot_volume 
			, loss_factor
			, contract_id 
			, storage_asset_id 
			, path_id
			, run_sum 
			, source_deal_header_id 
			, [description1]
			, [description2]
			, templete_deal_id 
			, storage_deal_type  
			, from_location
			, to_location 
			, rnk 
			, org_storage_deal_type  
			, delivery_volume
			, source_deal_detail_id
			, match_term_start
			, match_term_end
			, group_path
			, single_path_id
			, actual_available_volume
			, term_start
			, term_end
			, is_transport_deal

		)
		SELECT cd.box_id 
			, cd.rowid master_rowid
			, opt.[priority]
			, SUM(opt.[position]) available_volume   
			, cd.receipt_volume tot_volume 
			, cd.loss_factor
			, cd.contract_id  
			, cd.storage_asset_id
			, cd.path_id
			, CAST(0.00 AS FLOAT) run_sum 
			, opt.source_deal_header_id
			, opt.[nom_group] [description1] 
			, NULLIF(opt.[priority], 168) [description2]
			, cd.source_deal_header_id templete_deal_id   
			, cd.storage_deal_type 
			, cd.from_location	
			, cd.to_location
			, opt.[location_rank] rnk
			, cd.org_storage_deal_type
			, cd.delivery_volume 
			, opt.source_deal_detail_id
			, MAX(cd.match_term_start) match_term_start
			, MAX(cd.match_term_end) match_term_end
			, MAX(cd.group_path) group_path
			, MAX(cd.single_path_id) single_path_id
			, SUM(opt.[position]) available_volume
			, MAX(ISNULL(opt.term_start, ''' + CAST(@flow_date_from AS VARCHAR(50)) + '''))
			, MAX(ISNULL(opt.term_end, ''' + CAST(@flow_date_to AS VARCHAR(50))+ '''))
			, 0
		FROM (
			SELECT DISTINCT path_id --,storage_deal_type 
			FROM #collect_deals
		) pth
		CROSS APPLY
		(
			SELECT TOP(1) p.* 
			FROM delivery_path p 
			LEFT JOIN delivery_path_detail dpd 
				ON p.path_id = dpd.path_id
			WHERE p.path_id = pth.path_id 
			ORDER BY delivery_path_detail_id
		) p_top
		INNER JOIN #collect_deals cd 
			ON cd.path_id = pth.path_id 
			AND cd.location_id = p_top.from_location
			--AND cd.location_id = CASE pth.storage_deal_type WHEN ''i'' THEN p_top.to_location ELSE p_top.from_location END
			--AND cd.storage_deal_type = pth.storage_deal_type
		OUTER APPLY (
			SELECT COUNT(1) buy_deal_count 
			FROM  '+  @opt_deal_detail_pos +'  o
			WHERE cd.location_id = o.location_id
				AND ISNULL(position, 0) <>0
		) o 
		OUTER APPLY ( 		
			SELECT opt.*
			FROM (
				SELECT location_id 
				FROM #collect_deals c
				WHERE c.location_id = cd.location_id
				UNION
				SELECT proxy_location_id location_id
				FROM source_minor_location sml
				WHERE source_minor_location_id = cd.location_id
					AND proxy_location_id IS NOT NULL
				UNION 
				SELECT sml_p.source_minor_location_id
				FROM source_minor_location sml
				INNER JOIN source_minor_location sml_p
					ON sml.proxy_location_id = sml_p.proxy_location_id
				WHERE sml.source_minor_location_id = cd.location_id
					AND sml_p.source_minor_location_id IS NOT NULL
				UNION 
				SELECT source_minor_location_id location_id
				FROM source_minor_location sml
				WHERE proxy_location_id = cd.location_id
					AND source_minor_location_id IS NOT NULL
			) l
			LEFT JOIN '+  @opt_deal_detail_pos +' opt  --USED LEFT JOIN TO SUPPORT ZERO VOLUME SCHEDULE
				ON opt.location_id = l.location_id 
				AND cd.storage_deal_type IN (''n'', ''i'')
				AND ISNULL(cd.receipt_deals,''0'') = ''0''
				AND o.buy_deal_count >0
		) opt		
		LEFT JOIN dbo.source_deal_header sdh ON sdh.source_deal_header_id=opt.source_deal_header_id AND  ISNULL(sdh.internal_deal_type_value_id,-1)<>157
		WHERE CAST(ISNULL(opt.[priority],' + CAST(@from_priority AS VARCHAR) + ') AS INT) BETWEEN ' + CAST(@from_priority AS VARCHAR) + '  AND  ' + CAST(@to_priority AS VARCHAR) + '
		GROUP BY cd.box_id
				, cd.rowid
				, opt.[priority]
				, cd.receipt_volume
				, cd.loss_factor
				, cd.contract_id  
				, cd.storage_asset_id
				, cd.path_id
				, opt.source_deal_header_id
				, opt.[nom_group]
				, opt.[priority]
				, cd.source_deal_header_id   
				, cd.storage_deal_type 
				, cd.from_location	
				, cd.to_location
				, opt.[location_rank] 
				, cd.org_storage_deal_type
				, cd.delivery_volume
				, opt.source_deal_detail_id			
			
	'
	EXEC(@sql)
	SET @sql = '
		INSERT INTO #tmp_vol_split_deal_pre (
			box_id
			, master_rowid
			, [priority]
			, available_volume
			, tot_volume 
			, loss_factor
			, contract_id 
			, storage_asset_id 
			, path_id
			, run_sum 
			, source_deal_header_id 
			, [description1]
			, [description2]
			, templete_deal_id 
			, storage_deal_type  
			, from_location
			, to_location 
			, rnk 
			, org_storage_deal_type  
			, delivery_volume	
			, source_deal_detail_id
			, match_term_start
			, match_term_end
			, group_path
			, single_path_id
			, actual_available_volume
			, term_start
			, term_end
			, is_transport_deal
	)
	SELECT cd.box_id
		  , cd.rowid master_rowid
		  , opt.[priority]
		  , MAX(opt.available_volume) available_volume   
		  , cd.receipt_volume tot_volume 
		  , cd.loss_factor
		  , cd.contract_id  
		  , cd.storage_asset_id
		  , cd.path_id
		  , CAST(0.00 AS FLOAT) run_sum 
		  , opt.source_deal_header_id
		  , opt.[nom_group] [description1] 
		  , opt.[priority] [description2]
		  , cd.source_deal_header_id templete_deal_id   
		  , cd.storage_deal_type 
		  , cd.from_location	
		  , cd.to_location
		  , opt.[location_rank] rnk
		  , cd.org_storage_deal_type
		  , cd.delivery_volume
		  , opt.source_deal_detail_id
		  , MAX(cd.match_term_start) match_term_start
		  , MAX(cd.match_term_end) match_term_end
		  , MAX(cd.group_path) group_path
		  , MAX(cd.single_path_id) single_path_id
		  , MAX(opt.available_volume)  available_volume
		  , MAX(ISNULL(opt.term_start, ''' + CAST(@flow_date_from AS VARCHAR(50)) + '''))
		  , MAX(ISNULL(opt.term_end, ''' + CAST(@flow_date_to AS VARCHAR(50))+ '''))
		  , 0
	FROM ( SELECT DISTINCT path_id FROM #collect_deals ) pth
	CROSS APPLY (
		SELECT TOP(1) p.* 
		FROM delivery_path p 
		LEFT JOIN delivery_path_detail dpd 
			ON p.path_id = dpd.path_id
		WHERE p.path_id = pth.path_id 
		ORDER BY delivery_path_detail_id
	) p_top
	INNER JOIN #collect_deals cd 
		ON cd.path_id = pth.path_id 
		AND cd.location_id=p_top.from_location
	OUTER APPLY (
		SELECT opt.[priority],
				opt.source_deal_header_id
				, opt.[nom_group]
				, opt.[location_rank]
				, opt.source_deal_detail_id
				, SUM(opt.[position]) available_volume
				, opt.term_start
				, opt.term_end
		FROM ' +  @opt_deal_detail_pos + ' opt
		LEFT JOIN dbo.source_deal_header sdh ON sdh.source_deal_header_id=opt.source_deal_header_id AND ISNULL(sdh.internal_deal_type_value_id,-1)<>157 --TODO check this hardcoded value
		WHERE opt.location_id = cd.location_id
			AND cd.org_storage_deal_type IN (''n'', ''i'')
			AND opt.buy_sell_flag IN (' + CASE WHEN @call_from = 'flow_match' THEN   + '''b''' ELSE '''s'',''b''' END + ')
			AND ISNULL(cd.receipt_deals, ''0'') <> ''0''
		GROUP BY  opt.[priority]
				, opt.source_deal_header_id
				, opt.[nom_group]
				, opt.[location_rank]
				, opt.source_deal_detail_id
				, opt.term_start
				, opt.term_end
	) opt
	CROSS APPLY dbo.FNASplit(cd.receipt_deals, '','') d
	WHERE CAST(ISNULL(opt.[priority],' + CAST(@from_priority AS VARCHAR) + ') AS INT) BETWEEN ' + CAST(@from_priority AS VARCHAR) + '  AND  ' + CAST(@to_priority AS VARCHAR) +'
		AND d.item <> 0
	--AND opt.source_deal_header_id is NOT NULL
	GROUP BY cd.box_id 
			, cd.rowid
			, opt.[priority]
			, cd.receipt_volume
			, cd.loss_factor
			, cd.contract_id  
			, cd.storage_asset_id
			, cd.path_id
			, opt.source_deal_header_id
			, opt.[nom_group]
			, opt.[priority]
			, cd.source_deal_header_id   
			, cd.storage_deal_type 
			, cd.from_location	
			, cd.to_location
			, opt.[location_rank] 
			, cd.org_storage_deal_type
			, cd.delivery_volume
			, opt.source_deal_detail_id
		
	'
	--print @sql
	EXEC(@sql)

	
	IF NULLIF(@receipt_deals_id, '-1') IS NOT NULL
	BEGIN
		SET @sql = 'DELETE tv 
					FROM #tmp_vol_split_deal_pre tv
					LEFT JOIN dbo.SplitCommaSeperatedValues(''' + @receipt_deals_id + ''') temp
						ON temp.item = tv.source_deal_header_id
					WHERE temp.item IS NULL'
					
		EXEC(@sql)
	END

	-- Collect Delivered Deals
	SET @sql = '
		INSERT INTO #tmp_vol_split_deal_del_pre (
			box_id
			, master_rowid
			, [priority]
			, available_volume
			, tot_volume 
			, loss_factor
			, contract_id 
			, storage_asset_id 
			, path_id
			, run_sum 
			, source_deal_header_id 
			, [description1]
			, [description2]
			, templete_deal_id 
			, storage_deal_type  
			, from_location
			, to_location 
			, rnk 
			, org_storage_deal_type  
			, delivery_volume
			, source_deal_detail_id
			, match_term_start
			, match_term_end
			, group_path
			, single_path_id
			, actual_available_volume
			, term_start
			, term_end
			, is_transport_deal 
		)
			SELECT	box_id
					, cd.rowid master_rowid
					, opt.[priority]
					, ABS(SUM( IIF(cd.org_storage_deal_type = ''i'', NULL, opt.[position]) )) available_volume   
					, cd.delivery_volume tot_volume 
					, cd.loss_factor
					, cd.contract_id  
					, cd.storage_asset_id
					, cd.path_id
					, CAST(0.00 AS FLOAT) run_sum 
					, IIF(cd.org_storage_deal_type = ''i'',  NULL, opt.source_deal_header_id) source_deal_header_id 
					, opt.[nom_group] [description1] 
					, NULLIF(opt.[priority], 168) [description2]
					, cd.source_deal_header_id templete_deal_id   
					, cd.storage_deal_type 
					, cd.from_location	
					, cd.to_location
					, opt.[location_rank] rnk
					, cd.org_storage_deal_type
					, cd.delivery_volume 
					, IIF(cd.org_storage_deal_type = ''i'',  NULL, opt.source_deal_detail_id) source_deal_detail_id
					, MAX(cd.match_term_start) match_term_start
					, MAX(cd.match_term_end) match_term_end
					, MAX(cd.group_path) group_path
					, MAX(cd.single_path_id) single_path_id
					, SUM(IIF(cd.org_storage_deal_type = ''i'', NULL, opt.[position]) ) available_volume
					, MAX(ISNULL(opt.term_start, ''' + CAST(@flow_date_from AS VARCHAR(50)) + '''))
					, MAX(ISNULL(opt.term_end, ''' + CAST(@flow_date_to AS VARCHAR(50))+ '''))
					, 0
		FROM (
			SELECT DISTINCT path_id FROM #collect_deals
		) pth
		CROSS APPLY
		(
			SELECT TOP(1) p.* 
			FROM delivery_path p 
			LEFT JOIN delivery_path_detail dpd 
				ON p.path_id = dpd.path_id
			WHERE p.path_id = pth.path_id 
			ORDER BY delivery_path_detail_id
		) p_top

		INNER JOIN #collect_deals cd 
			ON cd.path_id = pth.path_id 
			AND cd.to_location = p_top.to_location
		
		OUTER APPLY ( 		
			SELECT opt.*
			FROM (
				SELECT to_location location_id
				FROM #collect_deals c
				WHERE c.to_location = cd.to_location
				UNION
				SELECT proxy_location_id location_id
				FROM source_minor_location sml
				WHERE source_minor_location_id = cd.to_location
					AND proxy_location_id IS NOT NULL
				UNION 
				SELECT sml_p.source_minor_location_id
				FROM source_minor_location sml
				INNER JOIN source_minor_location sml_p
					ON sml.proxy_location_id = sml_p.proxy_location_id
				WHERE sml.source_minor_location_id = cd.to_location
					AND sml_p.source_minor_location_id IS NOT NULL
				UNION
				SELECT source_minor_location_id location_id
				FROM source_minor_location sml
				WHERE proxy_location_id = cd.to_location
					AND source_minor_location_id IS NOT NULL
			) l
			LEFT JOIN ' +  @opt_deal_detail_pos + ' opt  --USED LEFT JOIN TO SUPPORT ZERO VOLUME SCHEDULE
				ON opt.location_id = l.location_id 
				AND cd.org_storage_deal_type IN (''n'', ''i'',''w'')
				AND ISNULL(cd.delivery_deals,''0'') = ''0''				
			) opt
		WHERE CAST(ISNULL(opt.[priority],' + CAST(@from_priority AS VARCHAR) + ') AS INT) BETWEEN ' + CAST(@from_priority AS VARCHAR) + '  AND  ' + CAST(@to_priority AS VARCHAR) +'
		GROUP BY cd.box_id
				, cd.rowid
				, opt.[priority]
				, cd.receipt_volume
				, cd.loss_factor
				, cd.contract_id  
				, cd.storage_asset_id
				, cd.path_id
				, opt.source_deal_header_id
				, opt.[nom_group]
				, cd.source_deal_header_id   
				, cd.storage_deal_type 
				, cd.from_location	
				, cd.to_location
				, opt.[location_rank] 
				, cd.org_storage_deal_type
				, cd.delivery_volume
				, opt.source_deal_detail_id
		
	'
	--print @sql
	EXEC(@sql)

		--SELECT * FROM #tmp_vol_split_deal_del_pre return;

	SET @sql = '
		INSERT INTO #tmp_vol_split_deal_del_pre (
			box_id
			, master_rowid
			, [priority]
			, available_volume
			, tot_volume 
			, loss_factor
			, contract_id 
			, storage_asset_id 
			, path_id
			, run_sum 
			, source_deal_header_id 
			, [description1]
			, [description2]
			, templete_deal_id 
			, storage_deal_type  
			, from_location
			, to_location 
			, rnk 
			, org_storage_deal_type  
			, delivery_volume
			, source_deal_detail_id
			, match_term_start
			, match_term_end
			, group_path
			, single_path_id
			, actual_available_volume
			, term_start
			, term_end	
			, is_transport_deal 
		)
	SELECT box_id
		, cd.rowid master_rowid
		, opt.[priority]
		, ABS(MAX(IIF(cd.org_storage_deal_type = ''i'', NULL, opt.[position]))) available_volume   
		, cd.delivery_volume tot_volume 
		, cd.loss_factor
		, cd.contract_id  
		, cd.storage_asset_id
		, cd.path_id
		, CAST(0.00 AS FLOAT) run_sum 
		, IIF(cd.org_storage_deal_type = ''i'',  NULL, opt.source_deal_header_id) source_deal_header_id
		, opt.[nom_group] [description1] 
		, opt.[priority] [description2]
		, cd.source_deal_header_id templete_deal_id   
		, cd.storage_deal_type 
		, cd.from_location	
		, cd.to_location
		, opt.[location_rank] rnk
		, cd.org_storage_deal_type
		, cd.delivery_volume
		, IIF(cd.org_storage_deal_type = ''i'',  NULL, opt.source_deal_detail_id) source_deal_detail_id
		, MAX(cd.match_term_start) match_term_start
		, MAX(cd.match_term_end) match_term_end
		, MAX(cd.group_path) group_path
		, MAX(cd.single_path_id) single_path_id
		, MAX(IIF(cd.org_storage_deal_type = ''i'', NULL, opt.[position])) available_volume
		, MAX(ISNULL(opt.term_start, ''' + CAST(@flow_date_from AS VARCHAR(50)) + '''))
		, MAX(ISNULL(opt.term_end, ''' + CAST(@flow_date_to AS VARCHAR(50))+ '''))
		, 0
	FROM 
	(
		SELECT DISTINCT path_id FROM #collect_deals
	) pth
	CROSS APPLY
	(
		SELECT TOP(1) p.* 
		FROM delivery_path p 
		LEFT JOIN delivery_path_detail dpd 
			ON p.path_id = dpd.path_id
		WHERE p.path_id = pth.path_id 
		ORDER BY delivery_path_detail_id
	) p_top
	INNER JOIN #collect_deals cd 
		ON cd.path_id = pth.path_id 
		AND cd.to_location = p_top.to_location
	OUTER APPLY (
			SELECT opt.[priority],
					opt.source_deal_header_id
					, opt.[nom_group]
					, opt.[location_rank]
					, opt.source_deal_detail_id
					, SUM(opt.[position]) position
					, opt.term_start
					, opt.term_end
			FROM ' +  @opt_deal_detail_pos + ' opt
			WHERE opt.location_id = cd.to_location
		AND cd.org_storage_deal_type IN (''n'',''i'',''w'')
		AND opt.buy_sell_flag IN (' + CASE WHEN @call_from = 'flow_match' THEN   + '''s''' ELSE '''s'',''b''' END + ')
			GROUP BY  opt.[priority],
					opt.source_deal_header_id
		, opt.[nom_group]
		, opt.[location_rank] 
		, opt.source_deal_detail_id
					, opt.term_start
					, opt.term_end
		) opt
	CROSS APPLY dbo.FNASplit(cd.delivery_deals, '','') d
	WHERE  CAST(ISNULL(opt.[priority],' + CAST(@from_priority AS VARCHAR) + ') AS INT) BETWEEN ' + CAST(@from_priority AS VARCHAR) + '  AND  ' + CAST(@to_priority AS VARCHAR) + '
		AND d.item <> 0
	GROUP BY cd.box_id 
		, cd.rowid
		, opt.[priority]
		, cd.receipt_volume
		, cd.loss_factor
		, cd.contract_id  
		, cd.storage_asset_id
		, cd.path_id
		, opt.source_deal_header_id
		, opt.[nom_group]
		, opt.[priority]
		, cd.source_deal_header_id   
		, cd.storage_deal_type 
		, cd.from_location	
		, cd.to_location
		, opt.[location_rank] 
		, cd.org_storage_deal_type
		, cd.delivery_volume
		, opt.source_deal_detail_id
	
	'	
	--print @sql
	EXEC(@sql)

	IF @delivery_deals_id IS NOT NULL
	BEGIN
		SET @sql = '
				DELETE tv 
				FROM #tmp_vol_split_deal_del_pre tv
				LEFT JOIN dbo.SplitCommaSeperatedValues(''' + @delivery_deals_id + ''') temp
					ON temp.item = tv.source_deal_header_id
				WHERE temp.item IS NULL
					--AND  tv.source_deal_header_id IS NOT NULL'
		--PRINT @sql
		EXEC(@sql)
	END

	INSERT INTO #tmp_vol_split_deal_pre   (
		box_id
		, master_rowid
		, priority
		, available_volume
		, delivery_volume
		, tot_volume
		, loss_factor
		, contract_id
		, storage_asset_id
		, path_id
		, run_sum
		, source_deal_header_id
		, description1
		, description2
		, templete_deal_id
		, storage_deal_type
		, from_location
		, to_location
		, rnk
		, org_storage_deal_type
		, source_deal_detail_id
		--, rowid
		, match_term_start
		, match_term_end
		, group_path
		, single_path_id
		, source0
		, actual_available_volume
		, term_start
		, term_end
		, is_transport_deal				

	)
	SELECT DISTINCT
			p.box_id
		, p.master_rowid
		, p.priority
		, p.available_volume
		, 0.01 delivery_volume
		, p.tot_volume
		, p.loss_factor
		, p.contract_id
		, p.storage_asset_id
		, p.path_id
		, p.run_sum
		, p.source_deal_header_id
		, p.description1
		, p.description2
		, p.templete_deal_id
		, p.storage_deal_type
		, p.from_location
		, p.to_location
		, p.rnk
		, p.org_storage_deal_type
		, p.source_deal_detail_id
		--, p.rowid
		, p.match_term_start
		, p.match_term_end
		, p.group_path
		, p.single_path_id
		, p.source0
		, p.actual_available_volume
		, p.term_start
		, p.term_end
		, p.is_transport_deal	
	FROM  #tmp_vol_split_deal_pre p		
	OUTER APPLY (SELECT DISTINCT box_id 
				FROM #tmp_vol_split_deal_pre 
				WHERE delivery_volume > 0
				AND box_id =  p.box_id
				) a
	WHERE p.box_id <> ISNULL(a.box_id, -1)


	INSERT INTO  #tmp_vol_split_deal_del_pre   (
		box_id
		, master_rowid
		, priority
		, available_volume
		, delivery_volume
		, tot_volume
		, loss_factor
		, contract_id
		, storage_asset_id
		, path_id
		, run_sum
		, source_deal_header_id
		, description1
		, description2
		, templete_deal_id
		, storage_deal_type
		, from_location
		, to_location
		, rnk
		, org_storage_deal_type
		, source_deal_detail_id
		--, rowid
		, match_term_start
		, match_term_end
		, group_path
		, single_path_id
		, source0
		, actual_available_volume
		, term_start
		, term_end
		, is_transport_deal				

	)
	SELECT DISTINCT
			p.box_id
		, p.master_rowid
		, p.priority
		, p.available_volume
		, 0.01 delivery_volume
		, p.tot_volume
		, p.loss_factor
		, p.contract_id
		, p.storage_asset_id
		, p.path_id
		, p.run_sum
		, p.source_deal_header_id
		, p.description1
		, p.description2
		, p.templete_deal_id
		, p.storage_deal_type
		, p.from_location
		, p.to_location
		, p.rnk
		, p.org_storage_deal_type
		, p.source_deal_detail_id
		--, p.rowid
		, p.match_term_start
		, p.match_term_end
		, p.group_path
		, p.single_path_id
		, p.source0
		, p.actual_available_volume
		, p.term_start
		, p.term_end
		, p.is_transport_deal	
	
	 FROM #tmp_vol_split_deal_del_pre p
	OUTER APPLY (SELECT DISTINCT box_id 
				FROM #tmp_vol_split_deal_del_pre 
				WHERE delivery_volume > 0 
					AND box_id =  p.box_id) a
	WHERE p.box_id <> ISNULL(a.box_id, -1)


	IF @delivery_deals_id IS NOT NULL
	BEGIN
		EXEC ('DELETE tv 
			   FROM #tmp_vol_split_deal_del_pre tv
			   LEFT JOIN dbo.SplitCommaSeperatedValues(''' + @delivery_deals_id + ''') temp
					ON temp.item = tv.source_deal_header_id
				WHERE temp.item IS NULL
					--AND tv.source_deal_header_id IS NOT NULL
					
		')
	END

	DELETE FROM #tmp_vol_split_deal_del_pre WHERE delivery_volume = 0
	DELETE FROM #tmp_vol_split_deal_pre WHERE delivery_volume = 0 

	IF @is_hourly_calc = 1
	BEGIN

		SET @sql = '
			INSERT INTO #tmp_vol_split_deal_hour_pre (
				box_id
				, master_rowid
				, hr
				, period
				, [priority]
				, available_volume
				, tot_volume 
				, loss_factor
				, contract_id 
				, storage_asset_id 
				, path_id
				, run_sum 
				, source_deal_header_id 
				, [description1]
				, [description2]
				, templete_deal_id 
				, storage_deal_type  
				, from_location
				, to_location 
				, rnk 
				, org_storage_deal_type  
				, delivery_volume
				, source_deal_detail_id
				, match_term_start
				, match_term_end
				, group_path
				, single_path_id
				, actual_available_volume
				, term_start
				, term_end
				, is_transport_deal
			)
		SELECT 	t.box_id
				, t.master_rowid
				, cdmh.hour
				, NULL period
				, t.[priority]
				, hp.position
				, cdmh.received 
				, t.loss_factor
				, t.contract_id 
				, t.storage_asset_id 
				, t.path_id
				, t.run_sum 
				, t.source_deal_header_id 
				, t.[description1]
				, t.[description2]
				, t.templete_deal_id 
				, t.storage_deal_type  
				, t.from_location
				, t.to_location 
				, t.rnk 
				, t.org_storage_deal_type  
				, cdmh.received delivery_volume
				, t.source_deal_detail_id
				, t.match_term_start
				, t.match_term_end
				, t.group_path
				, t.single_path_id
				, hp.position actual_available_volume
				, t.term_start
				, t.term_end
				, t.is_transport_deal
		FROM #tmp_vol_split_deal_pre t  --  select * from #tmp_vol_split_deal_pre
		INNER JOIN source_deal_header sdh ON sdh.source_deal_header_id = t.source_deal_header_id
		INNER JOIN source_deal_header_template sdht ON sdht.template_id = sdh.template_id
		LEFT JOIN ' + @hourly_pos_info + ' hp
			ON hp.source_deal_detail_id = t.source_deal_detail_id
			AND hp.term_start BETWEEN ''' + CAST( @flow_date_from AS VARCHAR(50)) + ''' AND ''' + CAST(@flow_date_to AS VARCHAR(50)) + '''
		LEFT JOIN ' + @contract_detail_hourly + ' cdmh
			ON cdmh.box_id = t.box_id
			AND cdmh.from_loc_id = t.from_location
			AND cdmh.to_loc_id = t.to_location
			AND ISNULL(cdmh.single_path_id, cdmh.path_id) = ISNULL(t.single_path_id, t.path_id)
			AND cdmh.contract_id = t.contract_id
			AND IIF(sdht.term_frequency_type = ''m'', [dbo].[FNAGetFirstLastDayOfMonth](cdmh.term_start, ''f''), cdmh.term_start)  = t.term_start
			AND cdmh.hour = ISNULL(LEFT(hp.hour, 2), cdmh.hour)
	--	WHERE hp.term_start BETWEEN ''' + CAST( @flow_date_from AS VARCHAR(50)) + ''' AND ''' + CAST(@flow_date_to AS VARCHAR(50)) + '''
		'

		EXEC(@sql)

		
		SET @sql = '
			INSERT INTO #tmp_vol_split_deal_del_hour_pre (
				box_id
				, master_rowid
				, hr
				, period
				, [priority]
				, available_volume
				, tot_volume 
				, loss_factor
				, contract_id 
				, storage_asset_id 
				, path_id
				, run_sum 
				, source_deal_header_id 
				, [description1]
				, [description2]
				, templete_deal_id 
				, storage_deal_type  
				, from_location
				, to_location 
				, rnk 
				, org_storage_deal_type  
				, delivery_volume
				, source_deal_detail_id
				, match_term_start
				, match_term_end
				, group_path
				, single_path_id
				, actual_available_volume
				, term_start
				, term_end	
				, is_transport_deal 
			)
		SELECT 
				t.box_id
				, t.master_rowid
				, cdmh.hour
				, NULL period
				, t.[priority]
				, -1 * hp.position [available_volume] --*-1 done since position of demand side is negative
				, cdmh.delivered tot_volume 
				, t.loss_factor
				, t.contract_id 
				, t.storage_asset_id 
				, t.path_id
				, t.run_sum 
				, t.source_deal_header_id 
				, t.[description1]
				, t.[description2]
				, t.templete_deal_id 
				, t.storage_deal_type  
				, t.from_location
				, t.to_location 
				, t.rnk 
				, t.org_storage_deal_type  
				, cdmh.delivered delivery_volume
				, t.source_deal_detail_id
				, t.match_term_start
				, t.match_term_end
				, t.group_path
				, t.single_path_id
				, t.actual_available_volume
				, t.term_start
				, t.term_end	
				, t.is_transport_deal 
		FROM #tmp_vol_split_deal_del_pre t -- select * from #tmp_vol_split_deal_del_hour_pre
		INNER JOIN source_deal_header sdh ON sdh.source_deal_header_id = t.source_deal_header_id
		INNER JOIN source_deal_header_template sdht ON sdht.template_id = sdh.template_id
		INNER JOIN ' + @hourly_pos_info + ' hp
			ON hp.source_deal_detail_id = t.source_deal_detail_id
		INNER JOIN ' + @contract_detail_hourly + ' cdmh
			ON cdmh.box_id = t.box_id
			AND cdmh.from_loc_id = t.from_location
			AND cdmh.to_loc_id = t.to_location
			AND ISNULL(cdmh.single_path_id, cdmh.path_id) = ISNULL(t.single_path_id, t.path_id)
			AND cdmh.contract_id = t.contract_id
			AND IIF(sdht.term_frequency_type = ''m'', [dbo].[FNAGetFirstLastDayOfMonth](cdmh.term_start, ''f''), cdmh.term_start)  = t.term_start
			AND cdmh.hour = LEFT(hp.hour, 2) 
		WHERE hp.term_start BETWEEN ''' + CAST( @flow_date_from AS VARCHAR(50)) + ''' AND ''' + CAST(@flow_date_to AS VARCHAR(50)) + '''
		UNION ALL
		
		SELECT t.box_id
				, t.master_rowid
				, cdmh.hour
				, NULL period
				, t.[priority]
				, NULL available_volume
				, cdmh.delivered tot_volume 
				, t.loss_factor
				, t.contract_id 
				, t.storage_asset_id 
				, t.path_id
				, t.run_sum 
				, t.source_deal_header_id 
				, t.[description1]
				, t.[description2]
				, t.templete_deal_id 
				, t.storage_deal_type  
				, t.from_location
				, t.to_location 
				, t.rnk 
				, t.org_storage_deal_type  
				, cdmh.delivered delivery_volume
				, t.source_deal_detail_id
				, t.match_term_start
				, t.match_term_end
				, t.group_path
				, t.single_path_id
				, t.actual_available_volume
				, t.term_start
				, t.term_end	
				, t.is_transport_deal
		 
		FROM ' + @contract_detail_hourly + ' cdmh
		INNER JOIN (
		SELECT top 1 t.*	
		FROM #tmp_vol_split_deal_del_pre  t
		LEFT JOIN #tmp_vol_split_deal_del_hour_pre th
			ON t.box_id = th.box_id
			AND t.master_rowid = th.master_rowid
		
		WHERE t.storage_deal_type = ''i''
		AND th.box_id IS NULL
		) t
		ON cdmh.box_id = t.box_id

		'
		EXEC (@sql)
	END

	DECLARE @delivery_path_id INT
		, @grp_delivery_path_id INT 

	SELECT @delivery_path_id = value_id FROM static_data_value sdv WHERE code = 'Delivery Path'		
	SELECT @grp_delivery_path_id = value_id FROM static_data_value sdv WHERE code = 'Path detail id'	

	UPDATE d1 
		SET is_transport_deal = 1
	FROM #tmp_vol_split_deal_pre d1
	INNER JOIN source_deal_header sdh 
		ON d1.source_deal_header_id = sdh.source_deal_header_id
	INNER JOIN source_deal_detail sdd
		ON d1.source_deal_header_id = sdd.source_deal_header_id
		AND sdd.leg = 2 
	OUTER APPLY (
		SELECT uddf.udf_value 
		FROM user_defined_deal_fields uddf			
		INNER JOIN user_defined_deal_fields_template uddft
			ON uddft.template_id = sdh.template_id
			AND uddft.udf_template_id = uddf.udf_template_id
			AND uddft.field_id = @delivery_path_id --293432
		WHERE  uddf.source_deal_header_id = sdh.source_deal_header_id
	) a
	WHERE ISNULL(sdh.template_id, -1) = @transportation_template_id --51
		AND ISNULL(sdh.source_deal_type_id, -1) = @transportation_deal_type_id --57
		AND ( sdd.location_id <> d1.from_location OR a.udf_value = -99)

	UPDATE d1 SET is_transport_deal = 1
	FROM #tmp_vol_split_deal_del_pre d1
	INNER JOIN source_deal_header sdh 
		ON d1.source_deal_header_id = sdh.source_deal_header_id
	INNER JOIN source_deal_detail sdd
		ON d1.source_deal_header_id = sdd.source_deal_header_id
		AND sdd.leg = 1 --AND sdd.location_id <> d1.to_location
	OUTER APPLY (
		SELECT uddf.udf_value
		FROM user_defined_deal_fields uddf			
		INNER JOIN user_defined_deal_fields_template uddft
			ON uddft.template_id = sdh.template_id
			AND uddft.udf_template_id = uddf.udf_template_id
			AND uddft.field_id 	= @delivery_path_id --293432
		WHERE uddf.source_deal_header_id = sdh.source_deal_header_id
	) a
	WHERE  ISNULL(sdh.template_id, -1) = @transportation_template_id --51
		AND ISNULL(sdh.source_deal_type_id, -1) = @transportation_deal_type_id --57
		AND (sdd.location_id <> d1.to_location OR a.udf_value = -99)

	SELECT 
		t.master_rowid
		, t.[priority]
		, ISNULL(abs(t.available_volume) - rem_vol.vol_used, 0) available_volume
		, ISNULL(t.tot_volume, 0)  tot_volume
		, t.loss_factor, t.contract_id 
		, t.storage_asset_id 
		, t.path_id
		, ISNULL(t.run_sum, 0) run_sum 
		, t.source_deal_header_id 
		, t.[description1]
		, t.[description2]
		, t.templete_deal_id 
		, t.storage_deal_type  
		, t.from_location
		, t.to_location 
		, t.rnk 
		, t.org_storage_deal_type
		, t.delivery_volume	
		, t.source_deal_detail_id
		, t.match_term_start
		, t.match_term_end
		, t.group_path
		, t.single_path_id
		, tm.term_start
		, t.rowid
		, t.source0
		, ISNULL(t.actual_available_volume - rem_vol.vol_used, 0) actual_available_volume
		, ISNULL(abs(t.available_volume) - rem_vol.vol_used,0) intial_available_volume
		, CAST(0 AS NUMERIC(20, 4)) over_flow_volume
		, tm.term_start term_end
		, CAST(0 AS NUMERIC(20, 4)) tot_volume_sell
		, ISNULL(abs(t.available_volume) - rem_vol.vol_used, 0) available_volume_sell
		, ISNULL(t.run_sum, 0) run_sum_sell
		, is_transport_deal
	INTO #tmp_vol_split_deal --#tmp_vol_split_deal_not_daily -- SELECT * FROM #tmp_vol_split_deal_pre SELECT * FROM #tmp_vol_split_deal_del_pre SELECT * FROM #tmp_vol_split_deal
	FROM #tmp_vol_split_deal_pre t
	CROSS APPLY [dbo].[FNATermBreakdown]('d', ISNULL(t.term_start, @flow_date_from), ISNULL(t.term_end, @flow_date_to)) tm
	OUTER APPLY 
	(
		SELECT ISNULL(SUM(volume_used), 0) vol_used 
		FROM optimizer_detail 
		WHERE source_deal_detail_id = t.source_deal_detail_id 
			AND up_down_stream = CASE WHEN t.org_storage_deal_type IN ('n', 'i') THEN 'U' ELSE t.org_storage_deal_type END 
			AND ISNULL(@reschedule, 0) = 0
			AND flow_date = tm.term_start
	) rem_vol 
	WHERE ISNULL(abs(t.available_volume) - rem_vol.vol_used, 0) >= 0 
		AND tm.term_start BETWEEN @flow_date_from AND @flow_date_to

	IF @is_hourly_calc = 1
	BEGIN
		SELECT 
			t.master_rowid
			, t.hr
			, t.period
			, t.[priority]
			, ISNULL(abs(t.available_volume) - rem_vol.vol_used, 0) available_volume
			, ISNULL(t.tot_volume, 0)  tot_volume
			, t.loss_factor, t.contract_id 
			, t.storage_asset_id 
			, t.path_id
			, ISNULL(t.run_sum, 0) run_sum 
			, t.source_deal_header_id 
			, t.[description1]
			, t.[description2]
			, t.templete_deal_id 
			, t.storage_deal_type  
			, t.from_location
			, t.to_location 
			, t.rnk 
			, t.org_storage_deal_type
			, t.delivery_volume	
			, t.source_deal_detail_id
			, t.match_term_start
			, t.match_term_end
			, t.group_path
			, t.single_path_id
			, tm.term_start
			, t.rowid
			, t.source0
			, ISNULL(t.actual_available_volume - rem_vol.vol_used, 0) actual_available_volume
			, ISNULL(abs(t.available_volume) - rem_vol.vol_used,0) intial_available_volume
			, CAST(0 AS NUMERIC(20, 4)) over_flow_volume
			, tm.term_start term_end
			, CAST(0 AS NUMERIC(20, 4)) tot_volume_sell
			, ISNULL(abs(t.available_volume) - rem_vol.vol_used, 0) available_volume_sell
			, ISNULL(t.run_sum, 0) run_sum_sell
			, is_transport_deal
		INTO #tmp_vol_split_deal_hour
		FROM #tmp_vol_split_deal_hour_pre t 
		CROSS APPLY [dbo].[FNATermBreakdown]('d', ISNULL(t.term_start, @flow_date_from), ISNULL(t.term_end, @flow_date_to)) tm
		OUTER APPLY 
		(
			SELECT ISNULL(SUM(volume_used), 0) vol_used 
			FROM optimizer_detail_hour 
			WHERE source_deal_detail_id = t.source_deal_detail_id 
				AND up_down_stream = CASE WHEN t.org_storage_deal_type IN ('n', 'i') THEN 'U' ELSE t.org_storage_deal_type END 
				AND ISNULL(@reschedule, 0) = 0
				AND flow_date = tm.term_start
				AND hr = t.hr
		) rem_vol 
		WHERE ISNULL(abs(t.available_volume) - rem_vol.vol_used, 0) >= 0 
			AND tm.term_start BETWEEN @flow_date_from AND @flow_date_to

	END

	SELECT sup.from_location
		, SUM(available_volume) available_volume 
	INTO #sup_net_volume --  SELECT * FROM #sup_net_volume
	FROM (
		SELECT  p.from_location
				, p.source_deal_header_id
				, p.source_deal_detail_id 
				, ABS(MAX(available_volume)) available_volume 
		FROM #tmp_vol_split_deal_pre p
		WHERE p.available_volume<0
			AND p.is_transport_deal = 0
		GROUP BY p.from_location
				, p.source_deal_header_id
				, p.source_deal_detail_id
	) sup
	OUTER APPLY
	(
		SELECT TOP(1) 1 ex
		FROM optimizer_header oh
		INNER JOIN optimizer_detail od
			ON oh.optimizer_header_id = od.optimizer_header_id
		INNER JOIN optimizer_detail_downstream odd
			ON odd.optimizer_header_id = oh.optimizer_header_id
			AND odd.transport_deal_id=od.transport_deal_id
		WHERE oh.group_path_id=-99
			AND oh.receipt_location_id=sup.from_location
			AND odd.source_deal_detail_id=sup.source_deal_detail_id
	)	ex
	WHERE (ex.ex IS NULL OR ISNULL(@reschedule, 0) = 1
	)
	GROUP BY sup.from_location

	UPDATE #tmp_vol_split_deal 
		SET tot_volume_sell=b.available_volume
	FROM #tmp_vol_split_deal a
	INNER JOIN #sup_net_volume b 
		ON a.from_location = b.from_location
		AND a.is_transport_deal = 0
	
	SELECT 
		t.master_rowid
		, t.[priority]
		, ISNULL(t.available_volume - rem_vol.vol_used,0) available_volume
		, ISNULL(t.tot_volume,0)  tot_volume
		, t.loss_factor
		, t.contract_id 
		, t.storage_asset_id 
		, t.path_id
		, ISNULL(t.run_sum, 0) run_sum 
		, t.source_deal_header_id 
		, t.[description1]
		, t.[description2]
		, t.templete_deal_id 
		, t.storage_deal_type  
		, t.from_location
		, t.to_location 
		, t.rnk 
		, t.org_storage_deal_type
		, t.delivery_volume	
		, t.source_deal_detail_id
		, t.match_term_start
		, t.match_term_end
		, t.group_path
		, t.single_path_id
		, tm.term_start
		, t.rowid
		, t.source0
		, ISNULL(t.actual_available_volume - rem_vol.vol_used, 0) actual_available_volume
		, ISNULL(t.available_volume - rem_vol.vol_used, 0) intial_available_volume
		, CAST(0 AS NUMERIC(20, 4)) over_flow_volume
		, tm.term_start term_end
		, CAST(0 AS NUMERIC(20, 4)) tot_volume_buy
		, ISNULL(t.available_volume - rem_vol.vol_used, 0) available_volume_buy
		, ISNULL(t.run_sum, 0) run_sum_buy
		, t.is_transport_deal
	INTO #tmp_vol_split_deal_del -- SELECT * FROM #tmp_vol_split_deal_del
	FROM
	(
		SELECT DATEADD(DAY, n - 1,@flow_date_from) term_start, DATEADD(DAY, n - 1, @flow_date_from) term_end  
		FROM seq 
		WHERE @flow_date_to >= DATEADD(DAY, n - 1, @flow_date_from) --AND dd.term_start <> dd.term_end
	) tm
	INNER JOIN #tmp_vol_split_deal_del_pre t  ON tm.term_start between t.term_start AND t.term_end
	OUTER APPLY 
	(
		SELECT ABS(ISNULL(SUM(deal_volume), 0)) vol_used 
		FROM  optimizer_detail_downstream  
		WHERE source_deal_detail_id = t.source_deal_detail_id 
			AND ISNULL(@reschedule, 0) = 0
			AND flow_date= tm.term_start
	) rem_vol 
	WHERE ISNULL(t.available_volume - rem_vol.vol_used, 0) >= 0

	IF @is_hourly_calc = 1
	BEGIN

		SELECT 
			t.master_rowid
			, t.hr
			, NULL period
			, t.[priority]
			, ISNULL(t.available_volume - rem_vol.vol_used,0) available_volume
			, ISNULL(t.tot_volume,0)  tot_volume
			, t.loss_factor
			, t.contract_id 
			, t.storage_asset_id 
			, t.path_id
			, ISNULL(t.run_sum, 0) run_sum 
			, t.source_deal_header_id 
			, t.[description1]
			, t.[description2]
			, t.templete_deal_id 
			, t.storage_deal_type  
			, t.from_location
			, t.to_location 
			, t.rnk 
			, t.org_storage_deal_type
			, t.delivery_volume	
			, t.source_deal_detail_id
			, t.match_term_start
			, t.match_term_end
			, t.group_path
			, t.single_path_id
			, tm.term_start
			, t.rowid
			, t.source0
			, ISNULL(t.actual_available_volume - rem_vol.vol_used, 0) actual_available_volume
			, ISNULL(t.available_volume - rem_vol.vol_used, 0) intial_available_volume
			, CAST(0 AS NUMERIC(20, 4)) over_flow_volume
			, tm.term_start term_end
			, CAST(0 AS NUMERIC(20, 4)) tot_volume_buy
			, ISNULL(t.available_volume - rem_vol.vol_used, 0) available_volume_buy
			, ISNULL(t.run_sum, 0) run_sum_buy
			, t.is_transport_deal
		INTO #tmp_vol_split_deal_del_hour -- SELECT * FROM #tmp_vol_split_deal_del
		FROM
		(
			SELECT DATEADD(DAY, n - 1,@flow_date_from) term_start, DATEADD(DAY, n - 1, @flow_date_from) term_end  
			FROM seq 
			WHERE @flow_date_to >= DATEADD(DAY, n - 1, @flow_date_from) --AND dd.term_start <> dd.term_end
		) tm
		INNER JOIN #tmp_vol_split_deal_del_hour_pre t  ON tm.term_start between t.term_start AND t.term_end
		OUTER APPLY 
		(
			SELECT ABS(ISNULL(SUM(deal_volume), 0)) vol_used 
			FROM  optimizer_detail_downstream_hour
			WHERE source_deal_detail_id = t.source_deal_detail_id 
				AND ISNULL(@reschedule, 0) = 0
				AND flow_date= tm.term_start
				AND hr = t.hr
		) rem_vol 
		WHERE ISNULL(t.available_volume - rem_vol.vol_used, 0) >= 0
	END

	IF OBJECT_ID('tempdb..#dem_net_volume') IS NOT NULL DROP TABLE #dem_net_volume
	SELECT dem.to_location
		, SUM(available_volume) available_volume 
	INTO #dem_net_volume
	FROM (
		SELECT  p.to_location
				, p.source_deal_header_id
				, p.source_deal_detail_id
				, ABS(MAX(available_volume)) available_volume 
		FROM #tmp_vol_split_deal_del_pre p
		WHERE actual_available_volume>0
			AND p.is_transport_deal = 0
		GROUP BY p.to_location
				, p.source_deal_header_id
				, p.source_deal_detail_id
	) dem
	OUTER APPLY
	(
		SELECT TOP(1) 1 ex
		FROM optimizer_header oh
		INNER JOIN optimizer_detail od
			ON oh.optimizer_header_id = od.optimizer_header_id
		WHERE oh.group_path_id = -99
			AND oh.delivery_location_id = dem.to_location
			AND od.source_deal_detail_id = dem.source_deal_detail_id
	)	ex
	WHERE (ex.ex IS NULL OR ISNULL(@reschedule, 0) = 1
	)
	GROUP BY dem.to_location
	
	UPDATE #tmp_vol_split_deal_del 
		SET tot_volume_buy=b.available_volume
	FROM #tmp_vol_split_deal_del a
	INNER JOIN #dem_net_volume b 
		ON a.to_location=b.to_location
		AND a.is_transport_deal = 0

	IF OBJECT_ID('tempdb..#tmp_vol_split_deal_bookout') IS NOT NULL DROP TABLE #tmp_vol_split_deal_bookout
	SELECT  DISTINCT
		IDENTITY (INT, 1, 1) rowid
		, t.from_location
		, t.term_start
		, t.term_end
		, t.available_volume_sell actual_available_volume
		, t.available_volume_sell intial_available_volume
		, t.tot_volume_sell
		, t.available_volume_sell
		, 0 run_sum_sell
		, t.source_deal_header_id
		, t.source_deal_detail_id
		, t.priority
		, t.templete_deal_id
		, t.storage_deal_type
		, t.rnk
		, t.org_storage_deal_type
		, t.contract_id
		, t.storage_asset_id
		, t.is_transport_deal
	INTO #tmp_vol_split_deal_bookout --  SELECT * FROM #tmp_vol_split_deal_bookout
	FROM #tmp_vol_split_deal t
	INNER JOIN source_minor_location sml ON sml.source_minor_location_id = t.from_location
	INNER JOIN source_major_location smj ON smj.source_major_location_id = sml.source_major_location_id AND smj.location_name <> 'storage'
	WHERE NULLIF(tot_volume_sell, 0) IS NOT NULL
		AND is_transport_deal = 0
	ORDER BY priority, rnk

	IF OBJECT_ID('tempdb..#tmp_vol_split_deal_del_bookout') IS NOT NULL DROP TABLE #tmp_vol_split_deal_del_bookout
	SELECT DISTINCT
		IDENTITY (INT,1,1) rowid
		, d.to_location
		, d.term_start
		, d.term_end
		, d.actual_available_volume
		, d.intial_available_volume
		, d.tot_volume_buy
		, d.available_volume_buy
		, 0 run_sum_buy
		, d.source_deal_header_id
		, d.source_deal_detail_id
		, d.priority
		, d.templete_deal_id
		, d.storage_deal_type
		, d.rnk
		, d.org_storage_deal_type
		, d.contract_id
		, d.storage_asset_id
		, d.is_transport_deal
	INTO #tmp_vol_split_deal_del_bookout --   SELECT * FROM #tmp_vol_split_deal_del_bookout
	FROM #tmp_vol_split_deal_del d 
	CROSS APPLY
	(
		SELECT top(1) 1 ext 
		FROM #tmp_vol_split_deal  
		WHERE path_id=d.path_id 
			AND from_location=d.from_location 
			AND to_location=d.to_location 
			AND term_start=d.term_start 
			AND tot_volume_sell<>0
	) ex
	INNER JOIN source_minor_location sml ON sml.source_minor_location_id = d.to_location
	INNER JOIN source_major_location smj ON smj.source_major_location_id = sml.source_major_location_id AND smj.location_name <> 'storage'
	WHERE NULLIF(d.tot_volume_buy, 0)  IS NOT NULL AND ex.ext is not null
	ORDER BY d.priority, d.rnk

	--disable auto bookout 
	DELETE FROM #tmp_vol_split_deal_bookout
	DELETE FROM #tmp_vol_split_deal_del_bookout

	DECLARE @from_location INT
			, @to_location INT
			, @rnk INT
			, @term DATETIME
			, @master_rowid INT
			, @term_end DATETIME
			, @hr INT

	-- sell deal netting
	DECLARE  cur_source_deal_sell CURSOR LOCAL FOR
		SELECT from_location
			, term_start
		FROM #tmp_vol_split_deal_bookout 
		WHERE tot_volume_sell <> 0
		GROUP BY  from_location 
				, term_start
	
	OPEN cur_source_deal_sell
	FETCH NEXT FROM cur_source_deal_sell INTO  @from_location, @term--,@term_end
	WHILE @@FETCH_STATUS = 0   
	BEGIN 
		
		UPDATE #tmp_vol_split_deal_bookout 
			SET run_sum_sell = run_sum.run_sum 
		FROM #tmp_vol_split_deal_bookout a
		OUTER APPLY
		(	
			SELECT SUM(available_volume_sell) run_sum 
			FROM #tmp_vol_split_deal_bookout 
			WHERE rowid <= a.rowid 
				AND from_location = @from_location 
				AND @term BETWEEN term_start AND term_end
				AND tot_volume_sell <> 0
		) run_sum
		WHERE  a.from_location = @from_location 
			AND @term BETWEEN a.term_start AND a.term_end
			AND a.tot_volume_sell <> 0

		--UPDATE required deal volume for the location (split deal)
		UPDATE #tmp_vol_split_deal_bookout 
			SET available_volume_sell = CASE WHEN (tot_volume_sell - (run_sum_sell - available_volume_sell)) < 0 THEN 0 ELSE (tot_volume_sell - (run_sum_sell - available_volume_sell)) END
		WHERE run_sum_sell > tot_volume_sell 
			AND from_location = @from_location 
			AND @term BETWEEN term_start AND term_end
			AND tot_volume_sell <> 0
		
		FETCH NEXT FROM cur_source_deal_sell INTO  @from_location,  @term
	END

	CLOSE cur_source_deal_sell

	-- buy deal netting
	DECLARE  cur_source_deal_buy CURSOR LOCAL FOR
		SELECT to_location
			, term_start
		FROM #tmp_vol_split_deal_del_bookout 
		WHERE tot_volume_buy <> 0
		AND is_transport_deal=0
		GROUP BY to_location 
				, term_start
	
	OPEN cur_source_deal_buy
	FETCH NEXT FROM cur_source_deal_buy INTO @to_location, @term
	WHILE @@FETCH_STATUS = 0   
	BEGIN 
		
		UPDATE #tmp_vol_split_deal_del_bookout 
			SET run_sum_buy = run_sum.run_sum 
		FROM #tmp_vol_split_deal_del_bookout a
		OUTER APPLY
		(	
			SELECT SUM(available_volume_buy) run_sum 
			FROM #tmp_vol_split_deal_del_bookout 
			WHERE rowid <= a.rowid 
				AND to_location = @to_location 
				AND @term BETWEEN term_start AND term_end
				AND tot_volume_buy <> 0
				AND is_transport_deal=0
		) run_sum
		WHERE  a.to_location = @to_location 
			AND @term BETWEEN a.term_start AND a.term_end
			AND a.tot_volume_buy <> 0
			AND a.is_transport_deal=0

		--UPDATE required deal volume for the location (split deal)
		UPDATE #tmp_vol_split_deal_del_bookout 
			SET available_volume_buy = CASE WHEN (tot_volume_buy - (run_sum_buy - available_volume_buy)) < 0 THEN 0 ELSE (tot_volume_buy - (run_sum_buy - available_volume_buy)) END
		WHERE run_sum_buy > tot_volume_buy 
			AND to_location = @to_location 
			AND @term BETWEEN term_start AND term_end
			AND tot_volume_buy <> 0
			AND is_transport_deal = 0
		FETCH NEXT FROM cur_source_deal_buy INTO  @to_location,  @term
	END

	CLOSE cur_source_deal_buy
	
	UPDATE t
		SET available_volume = t.available_volume - b.available_volume_sell
	FROM #tmp_vol_split_deal t
	INNER JOIN #tmp_vol_split_deal_bookout b
		ON t.from_location = b.from_location
		AND t.source_deal_detail_id = b.source_deal_detail_id

	UPDATE t
		SET available_volume = t.available_volume - b.available_volume_buy
	FROM #tmp_vol_split_deal_del t
	INNER JOIN #tmp_vol_split_deal_del_bookout b
		ON t.to_location = b.to_location
		AND t.source_deal_detail_id = b.source_deal_detail_id
		AND t.is_transport_deal = 0

	DECLARE  cur_source_deal CURSOR LOCAL FOR
		SELECT  master_rowid
			, from_location
			, to_location
			, path_id  
			, term_start
		FROM #tmp_vol_split_deal 
		WHERE tot_volume <> 0
			AND is_transport_deal = 0
		GROUP BY  master_rowid
				, from_location
				, to_location 
				, path_id
				, term_start
		ORDER BY master_rowid 
		   
	OPEN cur_source_deal
	FETCH NEXT FROM cur_source_deal INTO @master_rowid, @from_location, @to_location, @path_id, @term--,@term_end
	WHILE @@FETCH_STATUS = 0   
	BEGIN 
		
		UPDATE #tmp_vol_split_deal 
			SET run_sum = run_sum.run_sum 
		FROM #tmp_vol_split_deal a
		OUTER APPLY
		(	
			SELECT SUM(available_volume) run_sum 
			FROM #tmp_vol_split_deal 
			WHERE rowid <= a.rowid 
				AND @term BETWEEN term_start AND term_end
				AND master_rowid = a.master_rowid
				AND is_transport_deal = 0
		) run_sum
		WHERE  a.from_location = @from_location 
			AND a.to_location = @to_location	  
			AND ISNULL(path_id, -1) = ISNULL(@path_id, -1) 
			AND @term BETWEEN a.term_start AND a.term_end
			AND a.is_transport_deal = 0
			
		--UPDATE required deal volume for the location (split deal)
		UPDATE #tmp_vol_split_deal 
			SET available_volume = CASE WHEN (tot_volume - (run_sum - available_volume)) < 0 THEN 0 ELSE (tot_volume - (run_sum - available_volume)) END
		WHERE run_sum > tot_volume 
			AND from_location = @from_location 
			AND to_location = @to_location   
			AND ISNULL(path_id, -1) = ISNULL(@path_id, -1)  
			AND @term BETWEEN term_start AND term_end
			AND is_transport_deal = 0
		
		--UPDATE remaing deal volume for other low ranking location (split deal)
		UPDATE 	t  
			SET available_volume = CASE WHEN new_available_volume < 0 THEN 0 ELSE new_available_volume END 
		FROM #tmp_vol_split_deal t 
		INNER JOIN
		(	SELECT source_deal_detail_id
					, run_sum - tot_volume new_available_volume 
			FROM  #tmp_vol_split_deal
			WHERE  --(run_sum >= tot_volume OR run_sum=available_volume)	AND 
				 from_location = @from_location 
				AND to_location = @to_location  
				AND ISNULL(path_id, -1) = ISNULL(@path_id, -1)  
				AND available_volume <> 0
				AND @term BETWEEN term_start AND term_end
				AND is_transport_deal = 0
		) d
			ON t.source_deal_detail_id = d.source_deal_detail_id   
			AND @term BETWEEN t.term_start AND t.term_end			
		WHERE run_sum = 0
			AND t.is_transport_deal = 0
		
		FETCH NEXT FROM cur_source_deal INTO @master_rowid, @from_location, @to_location, @path_id, @term--,@term_end
	END

	CLOSE cur_source_deal

	IF @is_hourly_calc = 1
	BEGIN
		DECLARE  cur_source_deal_hour CURSOR LOCAL FOR
			SELECT  master_rowid
				, from_location
				, to_location
				, path_id  
				, term_start
				, hr
			FROM #tmp_vol_split_deal_hour
			WHERE tot_volume <> 0
				AND is_transport_deal = 0
			GROUP BY  master_rowid
					, from_location
					, to_location 
					, path_id
					, term_start
					, hr
			ORDER BY master_rowid 
		   
		OPEN cur_source_deal_hour
		FETCH NEXT FROM cur_source_deal_hour INTO @master_rowid, @from_location, @to_location, @path_id, @term, @hr--,@term_end
		WHILE @@FETCH_STATUS = 0   
		BEGIN 
		
			UPDATE #tmp_vol_split_deal_hour
				SET run_sum = run_sum.run_sum 
			FROM #tmp_vol_split_deal_hour a
			OUTER APPLY
			(	
				SELECT SUM(available_volume) run_sum 
				FROM #tmp_vol_split_deal_hour
				WHERE rowid <= a.rowid 
					AND @term BETWEEN term_start AND term_end
					AND master_rowid = a.master_rowid
					AND hr = a.hr
					AND is_transport_deal = 0
			) run_sum
			WHERE  a.from_location = @from_location 
				AND a.to_location = @to_location	  
				AND ISNULL(a.path_id, -1) = ISNULL(@path_id, -1) 
				AND @term BETWEEN a.term_start AND a.term_end
				AND a.is_transport_deal = 0
				AND a.hr = @hr
			
			--UPDATE required deal volume for the location (split deal)
			UPDATE #tmp_vol_split_deal_hour
				SET available_volume = CASE WHEN (tot_volume - (run_sum - available_volume)) < 0 THEN 0 ELSE (tot_volume - (run_sum - available_volume)) END
			WHERE run_sum > tot_volume 
				AND from_location = @from_location 
				AND to_location = @to_location   
				AND ISNULL(path_id, -1) = ISNULL(@path_id, -1)  
				AND @term BETWEEN term_start AND term_end
				AND is_transport_deal = 0
				AND hr = @hr
		
			--UPDATE remaing deal volume for other low ranking location (split deal)
			UPDATE 	t  
				SET available_volume = CASE WHEN new_available_volume < 0 THEN 0 ELSE new_available_volume END 
			FROM #tmp_vol_split_deal_hour t 
			INNER JOIN
			(	SELECT source_deal_detail_id
						, run_sum - tot_volume new_available_volume 
				FROM  #tmp_vol_split_deal_hour
				WHERE  --(run_sum >= tot_volume OR run_sum=available_volume)	AND 
					 from_location = @from_location 
					AND to_location = @to_location  
					AND ISNULL(path_id, -1) = ISNULL(@path_id, -1)  
					AND available_volume <> 0
					AND @term BETWEEN term_start AND term_end
					AND is_transport_deal = 0
					AND hr = @hr
			) d
				ON t.source_deal_detail_id = d.source_deal_detail_id   
				AND @term BETWEEN t.term_start AND t.term_end	
				AND t.hr = @hr
			WHERE run_sum = 0
				AND t.is_transport_deal = 0
		
			FETCH NEXT FROM cur_source_deal_hour INTO @master_rowid, @from_location, @to_location, @path_id, @term, @hr--,@term_end
		END

		CLOSE cur_source_deal_hour
	END

	IF @call_from <> 'flow_match' 
	BEGIN
		INSERT INTO #tmp_vol_split_deal(
				master_rowid
				,priority
				,available_volume
				,tot_volume
				,loss_factor
				,contract_id
				,storage_asset_id
				,path_id
				,run_sum
				,source_deal_header_id
				,description1
				,description2
				,templete_deal_id
				,storage_deal_type
				,from_location
				,to_location
				,rnk
				,org_storage_deal_type
				,delivery_volume
				,source_deal_detail_id
				,match_term_start
				,match_term_end
				,group_path
				,single_path_id
				,term_start
				,rowid
				,source0
				,actual_available_volume
				,intial_available_volume
				,over_flow_volume
				,term_end
				,tot_volume_sell
				,available_volume_sell
				,run_sum_sell
				,is_transport_deal	
		)
		SELECT rowid * -1
			, priority
			, available_volume_sell available_volume
			, tot_volume_sell
			, 0 loss_factor
			, @base_contract_id contract_id
			, storage_asset_id
			, -99 path_id
			, run_sum_sell
			, source_deal_header_id
			, NULL description1
			, NULL description2
			, templete_deal_id
			, storage_deal_type
			, from_location
			, from_location [to_location]
			, rnk
			, org_storage_deal_type
			, NULL delivery_volume
			, source_deal_detail_id
			, NULL match_term_start
			, NULL match_term_end
			, 'n' group_path
			, -99 single_path_id
			, term_start
			, rowid * -1
			, NULL source0
			, actual_available_volume
			, intial_available_volume
			, 0 over_flow_volume
			, term_end
			, tot_volume_sell
			, available_volume_sell
			, run_sum_sell
			, is_transport_deal
	FROM #tmp_vol_split_deal_bookout
		WHERE run_sum_sell - intial_available_volume <= tot_volume_sell 

		UNION ALL
		SELECT 
			rowid * 10000 
			, priority
			, available_volume_buy available_volume
			, tot_volume_buy
			, 0 loss_factor
			, @base_contract_id contract_id
			, storage_asset_id
			, -99 path_id
			, run_sum_buy
			, source_deal_header_id
			, NULL description1
			, NULL description2
			, templete_deal_id
			, storage_deal_type
			, to_location from_location
			, to_location [to_location]
			, rnk
			, org_storage_deal_type
			, NULL delivery_volume
			, source_deal_detail_id
			, NULL match_term_start
			, NULL match_term_end
			, 'n' group_path
			, -99 single_path_id
			, term_start
			, rowid  * 10000 
			, NULL source0
			, actual_available_volume
			, intial_available_volume
			, 0 over_flow_volume
			, term_end
			, tot_volume_buy
			, available_volume_buy
			, run_sum_buy
			, is_transport_deal
		FROM #tmp_vol_split_deal_del_bookout
		WHERE run_sum_buy - intial_available_volume <= tot_volume_buy			
	END 
		
	IF OBJECT_ID('tempdb..#over_sch_vol') IS NOT NULL DROP TABLE #over_sch_vol
	SELECT from_location
		, to_location
		, path_id 
		, ISNULL(single_path_id, path_id) single_path_id
		, term_start flow_date
		, MAX(tot_volume) - SUM(available_volume) over_vol
		, MAX(source_deal_header_id) source_deal_header_id
		, MAX(source_deal_header_id) source_deal_detail_id
		, contract_id
	INTO #over_sch_vol
	FROM #tmp_vol_split_deal
	WHERE tot_volume<>0
		AND is_transport_deal = 0
		AND org_storage_deal_type NOT IN ('w') --There won't be over schedule CASE for storage withdrawal
	GROUP BY  from_location
			, to_location
			, path_id
			, term_start
			, single_path_id
			, contract_id
	HAVING (MAX(tot_volume) - SUM(available_volume)) > 0
	
	IF @is_hourly_calc = 1
	BEGIN
		SELECT from_location
			, to_location
			, path_id 
			, ISNULL(single_path_id, path_id) single_path_id
			, term_start flow_date
			, hr
			, MAX(tot_volume) - SUM(available_volume) over_vol
			, MAX(source_deal_header_id) source_deal_header_id
			, MAX(source_deal_header_id) source_deal_detail_id
			, contract_id
		INTO #over_sch_vol_hour
		FROM #tmp_vol_split_deal_hour
		WHERE tot_volume<>0
			AND is_transport_deal = 0
			AND org_storage_deal_type NOT IN ('w') --There won't be over schedule CASE for storage withdrawal
		GROUP BY  from_location
				, to_location
				, path_id
				, term_start
				, hr
				, single_path_id
				, contract_id
		HAVING (MAX(tot_volume) - SUM(available_volume)) > 0
	END

	DECLARE  cur_source_deal_del CURSOR LOCAL FOR
		SELECT  master_rowid
				, from_location
				, to_location
				, path_id  
				, term_start 
		FROM #tmp_vol_split_deal_del
		WHERE tot_volume <> 0
		GROUP BY  master_rowid
				, from_location
				, to_location 
				, path_id
				, term_start
		ORDER BY master_rowid 
		   
	OPEN cur_source_deal_del
	FETCH NEXT FROM cur_source_deal_del INTO @master_rowid, @from_location, @to_location, @path_id, @term
	WHILE @@FETCH_STATUS = 0   
	BEGIN 
		UPDATE #tmp_vol_split_deal_del 
			SET run_sum = run_sum.run_sum 
		FROM #tmp_vol_split_deal_del a
		OUTER APPLY
		(	
			SELECT SUM(available_volume) run_sum 
			FROM #tmp_vol_split_deal_del
			WHERE rowid <= a.rowid  
				AND @term BETWEEN  term_start AND term_end
				AND master_rowid = a.master_rowid
		) run_sum
		WHERE a.from_location = @from_location 
			AND a.to_location = @to_location	  
			AND ISNULL(path_id, -1) = ISNULL(@path_id, -1) 
			AND @term BETWEEN a.term_start AND a.term_end
				
		--UPDATE required deal volume for the location (split deal)
		UPDATE #tmp_vol_split_deal_del 
			SET available_volume = CASE WHEN (tot_volume - (run_sum - available_volume)) < 0 
									THEN 0 
									ELSE  (tot_volume - (run_sum - available_volume)) 
									END
		WHERE run_sum > tot_volume 
			AND from_location = @from_location 
			AND to_location = @to_location   
			AND ISNULL(path_id, -1) = ISNULL(@path_id,-1)  
			AND @term BETWEEN term_start AND term_end

		--UPDATE remaing deal volume for other low ranking location (split deal)
		UPDATE t SET available_volume =	CASE WHEN new_available_volume < 0 
											THEN 0 
											ELSE new_available_volume 
											END 
		FROM #tmp_vol_split_deal_del t 
		INNER JOIN
		(	SELECT  source_deal_detail_id
					, run_sum - tot_volume new_available_volume 
			FROM  #tmp_vol_split_deal_del
			WHERE --(run_sum >= tot_volume OR run_sum = available_volume)	 AND
				 from_location = @from_location 
				AND to_location = @to_location  
				AND ISNULL(path_id, -1) = ISNULL(@path_id, -1)  
				AND available_volume <> 0
				AND @term BETWEEN term_start AND term_end
		) d
			ON t.source_deal_detail_id = d.source_deal_detail_id   
			AND @term BETWEEN t.term_start AND t.term_end
		WHERE run_sum = 0
		
		FETCH NEXT FROM cur_source_deal_del INTO @master_rowid, @from_location, @to_location, @path_id, @term
	END

	CLOSE cur_source_deal_del

	IF @is_hourly_calc = 1
	BEGIN
	
		DECLARE  cur_source_deal_del_hour CURSOR LOCAL FOR
			SELECT  master_rowid
					, from_location
					, to_location
					, path_id  
					, term_start 
					, hr
			FROM #tmp_vol_split_deal_del_hour
			WHERE tot_volume <> 0
			GROUP BY  master_rowid
					, from_location
					, to_location 
					, path_id
					, term_start
					, hr
			ORDER BY master_rowid 
		   
		OPEN cur_source_deal_del_hour
		FETCH NEXT FROM cur_source_deal_del_hour INTO @master_rowid, @from_location, @to_location, @path_id, @term, @hr
		WHILE @@FETCH_STATUS = 0   
		BEGIN 
			UPDATE #tmp_vol_split_deal_del_hour
				SET run_sum = run_sum.run_sum 
			FROM #tmp_vol_split_deal_del_hour a
			OUTER APPLY
			(	
				SELECT SUM(available_volume) run_sum 
				FROM #tmp_vol_split_deal_del_hour
				WHERE rowid <= a.rowid  
					AND @term BETWEEN  term_start AND term_end
					AND master_rowid = a.master_rowid
					AND hr = a.hr
			) run_sum
			WHERE a.from_location = @from_location 
				AND a.to_location = @to_location	  
				AND ISNULL(path_id, -1) = ISNULL(@path_id, -1) 
				AND @term BETWEEN a.term_start AND a.term_end
				AND a.hr = @hr
				
			--UPDATE required deal volume for the location (split deal)
			UPDATE #tmp_vol_split_deal_del_hour
				SET available_volume = CASE WHEN (tot_volume - (run_sum - available_volume)) < 0 
										THEN 0 
										ELSE  (tot_volume - (run_sum - available_volume)) 
										END
			WHERE run_sum > tot_volume 
				AND from_location = @from_location 
				AND to_location = @to_location   
				AND ISNULL(path_id, -1) = ISNULL(@path_id,-1)  
				AND @term BETWEEN term_start AND term_end
				AND hr = @hr

			--UPDATE remaing deal volume for other low ranking location (split deal)
			UPDATE t SET available_volume =	CASE WHEN new_available_volume < 0 
												THEN 0 
												ELSE new_available_volume 
												END 
			FROM #tmp_vol_split_deal_del_hour t 
			INNER JOIN
			(	SELECT  source_deal_detail_id
						, run_sum - tot_volume new_available_volume 
				FROM  #tmp_vol_split_deal_del_hour
				WHERE --(run_sum >= tot_volume OR run_sum = available_volume)	 AND
					 from_location = @from_location 
					AND to_location = @to_location  
					AND ISNULL(path_id, -1) = ISNULL(@path_id, -1)  
					AND available_volume <> 0
					AND @term BETWEEN term_start AND term_end
					AND hr = @hr
			) d
				ON t.source_deal_detail_id = d.source_deal_detail_id   
				AND @term BETWEEN t.term_start AND t.term_end
				AND t.hr = @hr
			WHERE run_sum = 0
		
			FETCH NEXT FROM cur_source_deal_del_hour INTO @master_rowid, @from_location, @to_location, @path_id, @term, @hr
		END

		CLOSE cur_source_deal_del_hour
	END

	IF OBJECT_ID('tempdb..#tmp_vol_split_deal_final') IS NOT NULL DROP TABLE #tmp_vol_split_deal_final
	SELECT * INTO #tmp_vol_split_deal_final 
	FROM -- SELECT * FROM #tmp_vol_split_deal_final
	(
		--transportation deal except Withdrawal deal
		SELECT rowid
			, master_rowid
			, priority
			, available_volume
			, tot_volume
			, loss_factor
			, contract_id
			, storage_asset_id
			, path_id
			, run_sum
			, source_deal_header_id
			, description1
			, description2
			, templete_deal_id
			, storage_deal_type
			, from_location
			, to_location
			, rnk 
			, org_storage_deal_type
			, delivery_volume	 
			, source_deal_detail_id
			, match_term_start
			, match_term_end
			, group_path
			, NULL single_path_id
			, tm.term_start
			, source0
			, actual_available_volume
			, is_transport_deal
		FROM #tmp_vol_split_deal  -- SELECT * FROM #tmp_vol_split_deal
		CROSS JOIN [dbo].[FNATermBreakdown]('d', @flow_date_from, @flow_date_to) tm
		UNION ALL ---Injuction deal
		SELECT -1 * a.rowid
			, a.master_rowid
			, a.priority
			, a.available_volume
			, a.tot_volume
			, a.loss_factor
			, a.contract_id
			, b.storage_asset_id
			, a.path_id
			, a.run_sum
			, a.source_deal_header_id
			, a.description1
			, a.description2
			, b.source_deal_header_id templete_deal_id
			, b.storage_deal_type
			, a.from_location
			, a.to_location
			, a.rnk 
			, b.storage_deal_type org_storage_deal_type
			, a.delivery_volume 
			, a.source_deal_detail_id
			, a.match_term_start
			, a.match_term_end
			, a.group_path
			, b.single_path_id
			, tm.term_start
			, a.source0
			, a.actual_available_volume
			, a.is_transport_deal
		FROM #tmp_vol_split_deal a 
		INNER JOIN #collect_deals b 
			ON a.path_id = b.path_id 
			AND b.storage_asset_id IS NOT NULL   
			AND b.org_storage_deal_type = 'i' 
			AND a.group_path = 'y'
		CROSS JOIN [dbo].[FNATermBreakdown]('d', @flow_date_from, @flow_date_to) tm
		UNION ALL   ---Withdrawal AND transportation deal
		SELECT 100000000 + a.rowid
			, a.rowid
			, NULL priority
			, a.receipt_volume available_volume
			, a.receipt_volume tot_volume
			, a.loss_factor
			, a.contract_id
			, a.storage_asset_id
			, a.path_id
			, a.receipt_volume run_sum
			, NULL source_deal_header_id
			, NULL description1
			, NULL description2
			, a.source_deal_header_id templete_deal_id
			, a.storage_deal_type
			, a.from_location
			, a.to_location
			, NULL rnk 
			, 'w' org_storage_deal_type
			, a.delivery_volume 
			, NULL source_deal_detail_id
			, match_term_start
			, match_term_end
			, group_path
			, single_path_id
			, tm.term_start
			, NULL source0
			, NULL actual_available_volume
			, 0 is_transport_deal 
		FROM #collect_deals a 
		CROSS JOIN [dbo].[FNATermBreakdown]('d', @flow_date_from, @flow_date_to) tm
		WHERE a.storage_deal_type = 'w'

		--added later while inj deal missing issue ON scheduling, ON TRMTracker_DEV after antero merge.
		UNION ALL   ---INJECTION deal
		SELECT -1 * a.rowid
			, a.rowid
			, NULL priority
			, a.receipt_volume available_volume
			, a.receipt_volume tot_volume
			, a.loss_factor
			, a.contract_id
			, a.storage_asset_id
			, a.path_id
			, a.receipt_volume run_sum
			, NULL source_deal_header_id
			, NULL description1
			, NULL description2
			, a.source_deal_header_id templete_deal_id
			, a.storage_deal_type
			, a.from_location
			, a.to_location
			, NULL rnk 
			, 'i' org_storage_deal_type
			, a.delivery_volume 
			, NULL source_deal_detail_id
			, match_term_start
			, match_term_end
			, group_path
			, single_path_id
			, tm.term_start
			, NULL source0
			, NULL actual_available_volume
			, 0 is_transport_deal 
		FROM #collect_deals a 
		CROSS JOIN [dbo].[FNATermBreakdown]('d', @flow_date_from, @flow_date_to) tm
		WHERE a.storage_deal_type = 'i'
	) tmp

	UPDATE #tmp_vol_split_deal_final 
		SET available_volume = 0
	WHERE tot_volume = 0

	IF @is_hourly_calc = 1
	BEGIN
		UPDATE #tmp_vol_split_deal_hour
			SET available_volume = 0
		WHERE tot_volume = 0

		UPDATE #tmp_vol_split_deal_del_hour
			SET available_volume = 0
		WHERE tot_volume = 0
	END 

	UPDATE #tmp_vol_split_deal_final 
		SET [contract_id] = ISNULL(st.agreement, p.[contract_id] ) 
	FROM #tmp_vol_split_deal_final p
	LEFT JOIN general_assest_info_virtual_storage st 
		ON st.general_assest_id = p.storage_asset_id
	LEFT JOIN delivery_path dp 
		ON dp.path_id = p.path_id 

	UPDATE #tmp_vol_split_deal 
		SET [contract_id] = ISNULL(st.agreement, p.[contract_id] ) 
	FROM #tmp_vol_split_deal p
	LEFT JOIN general_assest_info_virtual_storage st 
		ON st.general_assest_id = p.storage_asset_id
	LEFT JOIN delivery_path dp 
		ON dp.path_id = p.path_id 

	UPDATE #tmp_vol_split_deal_del 
		SET [contract_id] = ISNULL(st.agreement, p.[contract_id] ) 
	FROM #tmp_vol_split_deal_del p
	LEFT JOIN general_assest_info_virtual_storage st 
		ON st.general_assest_id = p.storage_asset_id
	LEFT JOIN delivery_path dp 
		ON dp.path_id = p.path_id 

	IF @is_hourly_calc = 1
	BEGIN
		UPDATE #tmp_vol_split_deal_del_hour
			SET [contract_id] = ISNULL(st.agreement, p.[contract_id] ) 
		FROM #tmp_vol_split_deal_del_hour p
		LEFT JOIN general_assest_info_virtual_storage st 
			ON st.general_assest_id = p.storage_asset_id
		LEFT JOIN delivery_path dp 
			ON dp.path_id = p.path_id 
	
		UPDATE #tmp_vol_split_deal_hour
			SET [contract_id] = ISNULL(st.agreement, p.[contract_id] ) 
		FROM #tmp_vol_split_deal_hour p
		LEFT JOIN general_assest_info_virtual_storage st 
			ON st.general_assest_id = p.storage_asset_id
		LEFT JOIN delivery_path dp 
			ON dp.path_id = p.path_id 
	END

	IF OBJECT_ID('tempdb..#group_path_breakdown_vol') IS NOT NULL DROP TABLE #group_path_breakdown_vol
	SELECT b.*
		, serial_no = ROW_NUMBER() OVER (PARTITION BY b.path_id, b.storage_deal_type, b.first_dom ORDER BY b.delivery_path_detail_id)
		, serial_no_desc = ROW_NUMBER() OVER (PARTITION BY b.path_id,b.storage_deal_type,b.first_dom ORDER BY b.delivery_path_detail_id DESC)
		, rowid = IDENTITY(INT, 1, 1)		
	INTO #group_path_breakdown_vol  ---  SELECT * FROM #tmp_vol_split_deal_final   SELECT * FROM #group_path_breakdown_vol SELECT * FROM #collect_deals
	FROM (
		SELECT DISTINCT a.*
		FROM
		(
			SELECT  p.description1
				, p.description2				
				, ISNULL(st.agreement, p.[contract_id] ) [contract_id]  
				, p.storage_deal_type
				, cd.path_id
				, cd.single_path_id
				, d.delivery_path_detail_id
				, MAX(cd.loss_factor) loss_factor
				, MAX(cd.from_location) from_location
				, MAX(cd.to_location) to_location
				, MAX(p.tot_volume) available_volume
				, MAX(dp.counterParty) counterParty
				, MAX(dp.[CONTRACT]) single_contract_id
				, CONVERT(VARCHAR(7), p.term_start, 120) + '-01' first_dom --first DAY of month
			FROM #tmp_vol_split_deal_final p 
			INNER JOIN #collect_deals cd 
				ON cd.path_id = p.path_id 
				AND cd.group_path ='y'
				AND cd.storage_deal_type = p.storage_deal_type
			INNER JOIN delivery_path_detail d 
				ON d.path_name = cd.single_path_id 
				AND d.path_id = p.path_id
			INNER JOIN (
				SELECT path_id path_id1
					, from_location from_location1
					, to_location to_location1 
					, (master_rowid) master_rowid1 
					, term_start
					, COUNT(1) no_source_deal
				FROM #tmp_vol_split_deal_final	
				GROUP BY path_id
					, from_location
					, to_location
					, master_rowid
					, term_start
			) mn 
				ON ISNULL(mn.path_id1, -1) = ISNULL(p.path_id, -1) 
				AND mn.from_location1 = p.from_location 
				AND mn.to_location1 = p.to_location
				AND mn.master_rowid1 = p.master_rowid 
				AND mn.term_start = p.term_start
			LEFT JOIN general_assest_info_virtual_storage st 
				ON st.general_assest_id = p.storage_asset_id
			LEFT JOIN delivery_path dp 
				ON dp.path_id = cd.single_path_id
			LEFT JOIN #gen_nomination_mapping  gnm 
				ON gnm.pipeline = ISNULL(@counterparty_id, dp.counterparty) 
				AND gnm.path_id = p.path_id
				AND p.storage_deal_type = 'n' 
			LEFT JOIN #storage_book_mapping  sbm 
				ON sbm.pipeline = ISNULL(@counterparty_id, dp.counterparty)
				AND ISNULL(sbm.location_id, CASE WHEN p.storage_deal_type = 'i' THEN p.to_location ELSE p.from_location END )
				= CASE WHEN p.storage_deal_type = 'i' THEN p.to_location ELSE p.from_location END  
				AND p.storage_deal_type IN ('w', 'i') 
				AND sbm.storage_type = p.storage_deal_type
			LEFT JOIN  source_system_book_map b  
				ON b.book_deal_type_map_id = COALESCE(gnm.sub_book_id, sbm.sub_book_id, 1)
			GROUP BY  p.description1
					, p.description2
					, ISNULL(st.agreement, p.[contract_id]) 
					, p.storage_deal_type 
					, cd.path_id
					, cd.single_path_id
					, d.delivery_path_detail_id
					, p.term_start
		) a
	) b
	ORDER BY b.first_dom
		, b.path_id
		, b.delivery_path_detail_id

	IF OBJECT_ID('tempdb..#group_path_volume') IS NOT NULL DROP TABLE #group_path_volume
	;WITH cte_group_path(
		description1
		, description2
		, [contract_id] 
		, storage_deal_type
		, path_id
		, single_path_id
		, received_volume
		, delivered_volume
		, loss_factor
		, from_location
		, to_location
		, serial_no
		, counterParty
		, single_contract_id
		, first_dom
		, serial_no_desc
	)
	AS
	(
		SELECT description1
			, description2
			, [contract_id] 
			, storage_deal_type
			, path_id,single_path_id
			, CAST(available_volume AS NUMERIC(20,4)) received_volume
			, CAST(available_volume * (1 - loss_factor) AS NUMERIC(20,4)) delivered_volume
			, loss_factor
			, from_location
			, to_location
			, serial_no
			, counterParty
			, single_contract_id
			, first_dom
			, serial_no_desc
		FROM #group_path_breakdown_vol 
		WHERE serial_no = 1 
			AND storage_deal_type = 'n'
		UNION ALL
		SELECT r.description1
				, r.description2
				, r.[contract_id] 
				, r.storage_deal_type
				, r.path_id
				, r.single_path_id
				, c.delivered_volume received_volume
				, CAST(c.delivered_volume * (1 - r.loss_factor) AS NUMERIC(20,4)) delivered_volume
				, r.loss_factor 
				, r.from_location
				, r.to_location
				, r.serial_no
				, r.counterParty
				, r.single_contract_id
				, c.first_dom
				, r.serial_no_desc
		FROM #group_path_breakdown_vol r 
		INNER JOIN cte_group_path c 
			ON r.path_id = c.path_id  
			AND r.serial_no = c.serial_no + 1 
			AND ISNULL(r.description1, -1) = ISNULL(c.description1, -1) 
			AND ISNULL(r.description2, 168) = ISNULL(c.description2, 168) 
			AND ISNULL(r.[contract_id], -1) = ISNULL(c.[contract_id], -1) 
			AND ISNULL(r.storage_deal_type, -1) = ISNULL(c.storage_deal_type, -1)  
			AND r.storage_deal_type = 'n' 
			AND r.first_dom = c.first_dom
	)

	SELECT a.* 
	INTO #group_path_volume  -- SELECT * FROM #group_path_volume
	FROM cte_group_path a;

	IF OBJECT_ID('tempdb..#tmp_vol_split_deal_final_grp_pre') IS NOT NULL DROP TABLE #tmp_vol_split_deal_final_grp_pre
	SELECT DISTINCT a.*
		, rowid = IDENTITY(INT, 1, 1)
	INTO #tmp_vol_split_deal_final_grp_pre -- SELECT *  FROM  #tmp_vol_split_deal_final_grp_pre	
	FROM 
	(
		SELECT  p.description1
			, p.description2
			, p.to_location
			, ISNULL(st.agreement, p.[contract_id] ) [contract_id]  
			, p.storage_deal_type
			, dp.path_id
			, MAX(p.templete_deal_id)  templete_deal_id
			, MAX(COALESCE(source_counterparty_id,dp.[counterparty])) [counterparty_id]
			, MAX(b.source_system_book_id1 ) source_system_book_id1
			, MAX(b.source_system_book_id2 ) source_system_book_id2
			, MAX(b.source_system_book_id3)	 source_system_book_id3
			, MAX(b.source_system_book_id4)	source_system_book_id4
			, MAX( b.book_deal_type_map_id) book_deal_type_map_id
			, leg1_volume = ROUND(CASE WHEN MAX(mn.no_source_deal)>1 THEN 
			 							MAX(p.tot_volume * CASE WHEN ISNULL(p.storage_deal_type,'n') IN ('n','w') THEN 1 ELSE 1-COALESCE(p.loss_factor,0) END)
			 						ELSE 
			 							MAX(p.tot_volume * CASE WHEN ISNULL(p.storage_deal_type,'n') IN ('n','w') THEN 1 ELSE 1-COALESCE(p.loss_factor,0) END)
			 						END, 0)
			, leg2_volume = ROUND(CASE WHEN MAX(mn.no_source_deal)>1 THEN 
			 							MAX(p.tot_volume * (1-COALESCE(p.loss_factor,0)) )
			 						ELSE 
			 							MAX(p.tot_volume * (1-COALESCE(p.loss_factor,0)) )
			 						END, 0)
			, leg1_loc_id= MAX(CASE WHEN ISNULL(p.storage_deal_type, 'n') = 'n' THEN  p.from_location  WHEN ISNULL(p.storage_deal_type, 'n') = 'w' THEN p.from_location ELSE p.to_location END)
			, leg2_loc_id= MAX(CASE WHEN ISNULL(p.storage_deal_type, 'n') = 'n' THEN  p.to_location  WHEN ISNULL(p.storage_deal_type, 'n') = 'w' THEN p.from_location ELSE p.to_location END)
			, leg1_meter_id = MAX(CASE WHEN ISNULL(p.storage_deal_type, 'n') = 'n' THEN  dp.meter_from  WHEN ISNULL(p.storage_deal_type, 'n') = 'w' THEN dp.meter_from ELSE dp.meter_to END )
 			, leg2_meter_id = MAX(CASE WHEN ISNULL(p.storage_deal_type, 'n') = 'n' THEN dp.meter_to WHEN ISNULL(p.storage_deal_type, 'n') = 'w' THEN dp.meter_from ELSE dp.meter_to END)
			, MAX(p.org_storage_deal_type) org_storage_deal_type
			, MAX(p.match_term_start) match_term_start
			, MAX(p.match_term_end) match_term_end
			, MAX(p.group_path) group_path
			, CONVERT(VARCHAR(7), p.term_start, 120) + '-01' first_dom
			, MAX(p.source0) source0
			, MAX(p.storage_asset_id) storage_asset_id
		FROM #tmp_vol_split_deal_final p --SELECT * FROM #tmp_vol_split_deal_final
		INNER JOIN (
			SELECT path_id path_id1
				, from_location from_location1
				, to_location to_location1 
				, (master_rowid) master_rowid1
				, term_start
				, COUNT(1) no_source_deal
			FROM #tmp_vol_split_deal_final	
			GROUP BY path_id, from_location, to_location, master_rowid, term_start
		) mn 
			ON ISNULL(mn.path_id1, -1) = ISNULL(p.path_id,-1) 
			AND mn.from_location1 = p.from_location 
			AND mn.to_location1 = p.to_location 
			AND mn.master_rowid1 = p.master_rowid 
			AND mn.term_start = p.term_start
		LEFT JOIN general_assest_info_virtual_storage st 
			ON st.general_assest_id =p.storage_asset_id
		LEFT JOIN delivery_path dp 
			ON dp.path_id = p.path_id 
		LEFT JOIN #gen_nomination_mapping  gnm 
			ON gnm.pipeline = ISNULL(@counterparty_id, dp.counterparty) 
			AND gnm.path_id = p.path_id
			AND p.storage_deal_type = 'n' 
		LEFT JOIN #storage_book_mapping  sbm 
			ON sbm.pipeline = ISNULL(@counterparty_id,dp.counterparty)
			AND ISNULL(sbm.location_id, CASE WHEN p.storage_deal_type = 'i' THEN p.to_location ELSE p.from_location END )
			= CASE WHEN p.storage_deal_type = 'i' THEN p.to_location ELSE p.from_location END  
			AND p.storage_deal_type IN ('w','i') 
			AND sbm.storage_type = p.storage_deal_type
		LEFT JOIN source_system_book_map b  
			ON b.book_deal_type_map_id = COALESCE(@sub_book, gnm.sub_book_id,sbm.sub_book_id, 1)
		 GROUP BY  p.description1
				, p.description2
				, p.to_location
				, ISNULL(st.agreement, p.[contract_id])
				, p.storage_deal_type
				, dp.path_id
				, p.term_start
	) a


	DELETE p 
	FROM  #tmp_vol_split_deal_final_grp_pre p
	INNER JOIN source_minor_location sml
		ON p.to_location = sml.source_minor_location_id
	LEFT JOIN source_major_location maj
		ON maj.source_major_location_ID = sml.source_major_location_ID
	WHERE p.storage_deal_type in ('i', 'w')
		AND ISNULL(maj.location_name,'-1') <> 'Storage'

	IF OBJECT_ID('tempdb..#tmp_vol_split_deal_final_grp') IS NOT NULL DROP TABLE #tmp_vol_split_deal_final_grp
	SELECT p.description1
		, p.description2
		, ISNULL(gpv.to_location, p.to_location) to_location
		--, ISNULL(gpv.[contract_id], p.[contract_id]) [contract_id]
		, case when ISNULL(p.storage_deal_type, 'n') in('i','w') then ISNULL(p.[contract_id],gpv.[contract_id]) else ISNULL(gpv.[contract_id], p.[contract_id]) end [contract_id]
		, p.storage_deal_type
		, ISNULL(p.path_id, gpv.single_path_id) path_id
		, p.templete_deal_id
		, ISNULL(gpv.counterParty, p.[counterparty_id]) [counterparty_id]
		, ISNULL(p.source_system_book_id1,ssbm.source_system_book_id1) [source_system_book_id1]
		, ISNULL(p.source_system_book_id2,ssbm.source_system_book_id2) [source_system_book_id2]
		, ISNULL(p.source_system_book_id3,ssbm.source_system_book_id3) [source_system_book_id3]
		, ISNULL(p.source_system_book_id4,ssbm.source_system_book_id4) [source_system_book_id4]
		, ISNULL(p.book_deal_type_map_id,ssbm.book_deal_type_map_id) [book_deal_type_map_id]
		, leg1_volume = ROUND(CASE WHEN ISNULL(p.storage_deal_type, 'n') IN ('n', 'w') 
							THEN ISNULL(gpv.received_volume, p.leg1_volume) 
							ELSE ISNULL(gpv.delivered_volume, p.leg1_volume) 
							END, 0)
		, leg2_volume = ROUND(ISNULL(gpv.delivered_volume, p.leg2_volume), 0)
		, leg1_loc_id = (CASE WHEN ISNULL(p.storage_deal_type, 'n') = 'n' 
								THEN  ISNULL(gpv.from_location,p.leg1_loc_id)  
							WHEN ISNULL(p.storage_deal_type, 'n') = 'w' 
								THEN ISNULL(gpv.from_location, p.leg1_loc_id) 
							ELSE ISNULL(gpv.to_location, p.leg1_loc_id) 
						END	)
		, leg2_loc_id = (CASE WHEN ISNULL(p.storage_deal_type, 'n') = 'n' 
								THEN  ISNULL(gpv.to_location, p.leg2_loc_id)  
							WHEN ISNULL(p.storage_deal_type, 'n') = 'w' 
								THEN ISNULL(gpv.from_location, p.leg2_loc_id) 
							ELSE ISNULL(gpv.to_location, p.leg2_loc_id) 
						END)
		, p.leg1_meter_id
		, p.leg2_meter_id
		, p.org_storage_deal_type
		, p.match_term_start
		, p.match_term_end
		, p.group_path
		, ISNULL(gpv.single_path_id, p.path_id) single_path_id
		, ISNULL(gpv.serial_no,1) serial_no
		, case when ISNULL(p.storage_deal_type, 'n') in('i','w') then ISNULL(p.[contract_id],gpv.single_contract_id) else gpv.single_contract_id end single_contract_id
		, p.first_dom
		, 0 include_rec
		, ISNULL(gpv.serial_no_desc, 1) serial_no_desc
		, p.source0
		, leg1_deal_volume = ROUND(CASE WHEN ISNULL(p.storage_deal_type, 'n') IN ('n', 'w') 
							THEN ISNULL(gpv.received_volume, p.leg1_volume) 
							ELSE ISNULL(gpv.delivered_volume, p.leg1_volume) 
							END, 0)
		, leg2_deal_volume = ROUND(ISNULL(gpv.delivered_volume, p.leg2_volume), 0)
		, CAST(NULL AS INT) source_deal_header_id
		, @flow_date_from flow_date_from 
		, @flow_date_to flow_date_to
		, p.storage_asset_id
		, rowid = IDENTITY(INT, 1, 1)
	INTO #tmp_vol_split_deal_final_grp -- SELECT *  FROM  #tmp_vol_split_deal_final_grp_pre	
	FROM #tmp_vol_split_deal_final_grp_pre p
	OUTER APPLY
	(	--Trasportation
		SELECT * 
		FROM #group_path_volume  
		WHERE path_id = p.path_id
			AND ISNULL(description1, -1) = ISNULL(p.description1, -1)
			AND ISNULL(description2, 168) = ISNULL(p.description2, 168)
			AND [contract_id] = p.[contract_id] 
			AND ISNULL(storage_deal_type, -1) = ISNULL(p.storage_deal_type, -1)
			AND ISNULL(p.storage_deal_type, 'n') = 'n' 
			AND first_dom = p.first_dom
		UNION ALL --Injection
		SELECT TOP(1) *
		FROM #group_path_volume 
		WHERE path_id=p.path_id
			AND ISNULL(description1, -1) = ISNULL(p.description1, -1) 
			AND ISNULL(description2, -1) = ISNULL(p.description2, -1)
			AND ISNULL(p.storage_deal_type, 'n') = 'i' 
			AND first_dom = p.first_dom
		ORDER BY path_id
				, serial_no DESC
		UNION ALL
		SELECT TOP(1) * --Withdraw
		FROM #group_path_volume  
		WHERE path_id = p.path_id
			AND ISNULL(description1, -1) = ISNULL(p.description1, -1) 
			AND ISNULL(description2, -1) = ISNULL(p.description2, -1)
			AND ISNULL(p.storage_deal_type, 'n') = 'w' 
			AND first_dom = p.first_dom
	) gpv
	left join #gen_nomination_mapping gnm 
		ON gnm.pipeline = ISNULL(gpv.counterParty, p.[counterparty_id])
		AND gnm.path_id = p.path_id
	LEFT JOIN source_system_book_map ssbm ON ssbm.book_deal_type_map_id = gnm.sub_book_id

	-- SELECT * FROM optimizer_detail
	DELETE #tmp_vol_split_deal_final_grp
	FROM #tmp_vol_split_deal_final_grp p
	LEFT JOIN  dbo.source_deal_header sdh	
		ON ISNULL(sdh.[description1], -1) = ISNULL(p.[description1], -1) 
		AND ISNULL(sdh.[description2], -1) = ISNULL(p.[description2], -1) 
		AND COALESCE(p.single_contract_id, NULLIF(p.[contract_id], 0), -1) = ISNULL(sdh.[contract_id], -1)
		AND p.first_dom = sdh.entire_term_start
	LEFT JOIN  dbo.source_deal_detail sdd	
		ON sdh.source_deal_header_id = sdd.source_deal_header_id
		AND sdd.leg = 1 
		AND sdd.location_id = p.leg1_loc_id
	WHERE sdd.source_deal_header_id IS NULL 
		AND ISNULL(@reschedule, 0) = 0
		AND ISNULL(p.leg1_volume, 0) = 0  
		AND ISNULL(p.leg2_volume, 0) = 0 

	DELETE #tmp_vol_split_deal_final
	FROM #tmp_vol_split_deal_final d
	LEFT JOIN  #tmp_vol_split_deal_final_grp p 
		ON ISNULL(p.description1, 'zzzzzzzz') = ISNULL(d.description1, 'zzzzzzzz') 
		AND ISNULL(p.description2, 168) = ISNULL(d.description2, 168)
		AND p.[contract_id] = d.[contract_id] 
		AND p.storage_deal_type = d.storage_deal_type 
		AND COALESCE(p.path_id, -1) = COALESCE(d.single_path_id, d.path_id, -1)
	WHERE d.rowid IS NULL -- AND ISNULL(@reschedule,0)=1

	BEGIN	-- Handling common path
--------------------------------------------------------------------------
		IF OBJECT_ID('tempdb..#common_path') IS NOT NULL DROP TABLE #common_path
		SELECT single_path_id,first_dom
			, CASE WHEN MIN(serial_no_desc)=1 THEN MAX(rowid) ELSE MIN(rowid) END rowid --create deal for this rowid only
			--, sum(leg1_volume) leg1_volume,sum(leg2_volume) leg2_volume
			, MAX(leg1_volume) leg1_volume,MAX(leg2_volume) leg2_volume -- changed FROM SUM to MAX as sum of volume raised issue of doubling of deal volume while re scheduing manually for same box same set.
			, MAX(serial_no_desc) serial_no_desc,MAX(serial_no) serial_no
			, contract_id
		INTO #common_path -- SELECT * FROM #common_path	
		FROM  #tmp_vol_split_deal_final_grp 
		WHERE leg2_volume <> 0 
			AND leg1_volume<>0
			AND path_id >0
		GROUP BY single_path_id,first_dom, contract_id, storage_deal_type
		HAVING COUNT(1) > 1


	

		UPDATE p 
			SET include_rec = 1
			, leg1_deal_volume = ISNULL(cp1.leg1_volume, p.leg1_volume) 
			, leg2_deal_volume = ISNULL(cp1.leg2_volume, p.leg2_volume)
		FROM #tmp_vol_split_deal_final_grp p
		LEFT JOIN #common_path cp1 
			ON p.single_path_id = cp1.single_path_id
			AND p.first_dom = cp1.first_dom 
			AND p.rowid = cp1.rowid			
		LEFT JOIN #common_path cp2 
			ON p.single_path_id = cp2.single_path_id
			AND p.first_dom = cp2.first_dom 
			AND p.rowid <> cp2.rowid
		WHERE ( cp2.single_path_id IS NULL)
			AND p.leg2_volume <> 0 
			AND p.leg1_volume <> 0

		IF OBJECT_ID('tempdb..#common_path_detail') IS NOT NULL DROP TABLE #common_path_detail
		SELECT grp.path_id
			, grp.single_path_id
			, grp.first_dom
			, grp.rowid
			, grp.leg1_volume
			, grp.leg2_volume
			, grp.serial_no
			, grp.serial_no_desc
			, grp.include_rec
		INTO #common_path_detail
		FROM  #tmp_vol_split_deal_final_grp grp
		INNER JOIN #common_path cp 
			ON cp.single_path_id = grp.single_path_id 
			AND cp.first_dom = grp.first_dom
			AND grp.leg2_volume <> 0 
			AND grp.leg1_volume <> 0

	END	-- Handling common path
-----------------------------------------

	CREATE TABLE #exclude_product_group(product_name NVARCHAR(500) COLLATE DATABASE_DEFAULT)

	
	IF @call_from = 'flow_auto'
	BEGIN
		DELETE FROM #exclude_product_group
		DECLARE @rec_del_deals VARCHAR(1000)

		SET @rec_del_deals =   @receipt_deals_id + ',' + @delivery_deals_id

		INSERT INTO #exclude_product_group
		SELECT DISTINCT sdv.code
		FROM source_deal_header sdh
		INNER JOIN dbo.SplitCommaSeperatedValues(@rec_del_deals) s
			ON sdh.source_deal_header_id = s.item
		LEFT JOIN static_data_value sdv
			ON sdv.value_id = sdh.internal_portfolio_id 
			AND sdv.type_id = 39800	

		INSERT INTO #existing_deals (
			source_deal_header_id 
			, single_path_id 
			, group_path_id 
			, description1 
			, description2 
			, contract_id 
			, leg1_loc_id 
			, leg2_loc_id 
			, deal_id 
			, first_dom 
			, flow_date_from 
			, flow_date_to 
			, include_rec 
			, storage_deal_type 
			, org_storage_deal_type
		)
		SELECT	DISTINCT sdh.source_deal_header_id ,
			p.single_path_id,p.path_id group_path_id
			, sdh.[description1]
			, sdh.[description2]
			, ISNULL(sdh.[contract_id],-1) [contract_id]
			, p.leg1_loc_id
			, p.leg2_loc_id
			, sdh.deal_id
			, p.first_dom
			, p.flow_date_from
			, p.flow_date_to
			, p.include_rec
			, p.storage_deal_type
			, p.org_storage_deal_type	
		FROM dbo.source_deal_header sdh
		CROSS APPLY
		(
			SELECT MAX(CASE WHEN leg = 1 THEN location_id ELSE NULL END ) leg1_location_id
				, MAX(CASE WHEN leg = 2 THEN location_id ELSE NULL END ) leg2_location_id
			FROM source_deal_detail 
			WHERE source_deal_header_id = sdh.source_deal_header_id
		) sdd	
		INNER JOIN #tmp_vol_split_deal_final_grp p	
			ON  p.leg1_loc_id = sdd.leg1_location_id
			AND p.leg2_loc_id = sdd.leg2_location_id 
			AND p.first_dom = sdh.entire_term_start
		INNER JOIN static_data_value sdv
			ON sdv.value_id = sdh.internal_portfolio_id 
			AND sdv.type_id = 39800	
		INNER JOIN #exclude_product_group epg
			ON epg.product_name = ISNULL(sdv.code, '-1')	
		WHERE p.storage_deal_type = 'n'		
			AND sdh.source_deal_type_id = @transportation_deal_type_id --exclude transportation deal
			--AND epg.product_name IS NULL
		UNION ALL
		SELECT  DISTINCT sdh.source_deal_header_id ,
			p.single_path_id,p.path_id group_path_id
			,sdh.[description1]
			,sdh.[description2]
			,COALESCE(od.contract_id, sdh.[contract_id],-1) [contract_id]
			,p.leg1_loc_id
			,p.leg2_loc_id
			,sdh.deal_id
			,p.first_dom
			,p.flow_date_from
			,p.flow_date_to
			,p.include_rec
			,p.storage_deal_type
			,p.org_storage_deal_type
		FROM #tmp_vol_split_deal_final_grp  p
		INNER JOIN delivery_path dp
			ON p.single_path_id = dp.path_id
		INNER JOIN source_deal_detail sdd
			ON sdd.location_id = p.leg1_loc_id
		INNER JOIN source_deal_header sdh
			ON sdh.source_deal_header_id = sdd.source_deal_header_id
			AND p.first_dom = sdh.entire_term_start
		INNER JOIN optimizer_detail od
			ON od.source_deal_header_id = sdh.source_deal_header_id
			AND COALESCE(p.single_contract_id,p.contract_id) = sdh.contract_id
		INNER JOIN delivery_path dp1
			ON dp1.path_id = od.single_path_id
			AND dp1.from_location = dp.from_location
		INNER JOIN static_data_value sdv
			ON sdv.value_id = sdh.internal_portfolio_id 
			AND sdv.type_id = 39800	
		INNER JOIN #exclude_product_group epg
			ON epg.product_name = ISNULL(sdv.code, '-1')
		WHERE p.storage_deal_type = 'i'
			AND sdh.deal_id LIKE 'INJC[_]%'
			--AND epg.product_name IS NULL
		UNION ALL
		SELECT  DISTINCT  sdh.source_deal_header_id ,
			p.single_path_id,p.path_id group_path_id
			,sdh.[description1]
			,sdh.[description2]
			,COALESCE(od.contract_id, sdh.[contract_id],-1) [contract_id]
			,p.leg1_loc_id
			,p.leg2_loc_id
			,sdh.deal_id
			,p.first_dom
			,p.flow_date_from
			,p.flow_date_to
			,p.include_rec
			,p.storage_deal_type
			,p.org_storage_deal_type
		FROM #tmp_vol_split_deal_final_grp  p
		INNER JOIN delivery_path dp
			ON p.single_path_id = dp.path_id
		INNER JOIN source_deal_detail sdd
			ON sdd.location_id = p.leg1_loc_id
		INNER JOIN source_deal_header sdh
			ON sdh.source_deal_header_id = sdd.source_deal_header_id
			AND p.first_dom = sdh.entire_term_start
		INNER JOIN optimizer_detail od
			ON od.source_deal_header_id = sdh.source_deal_header_id
			AND COALESCE(p.single_contract_id,p.contract_id) = sdh.contract_id
		INNER JOIN delivery_path dp1
			ON dp1.path_id = od.single_path_id
			AND dp1.to_location = dp.to_location
		INNER JOIN static_data_value sdv
			ON sdv.value_id = sdh.internal_portfolio_id 
			AND sdv.type_id = 39800	
		INNER JOIN #exclude_product_group epg
			ON epg.product_name = ISNULL(sdv.code, '-1')
		WHERE 
			p.storage_deal_type = 'w'
			AND sdh.deal_id LIKE 'WTHD[_]%'
			--AND epg.product_name IS NULL

		--Remove sell lto deal in case of 'b' deal and vice versa
		IF  CHARINDEX(',', @delivery_deals_id) = 0 
		BEGIN 
			IF EXISTS(			
					SELECT 1 
					FROM  source_deal_header sdh				
					LEFT JOIN static_data_value sdv
						ON sdv.value_id = sdh.internal_portfolio_id
						AND sdv.type_id = 39800
					WHERE ISNULL(sdv.code, '-1') = 'Complex-LTO'
					AND sdh.source_deal_header_id = @delivery_deals_id --@delivery_deals_id
			)
			BEGIN
				DECLARE @header_buy_sell_flag CHAR(1)

				SELECT @header_buy_sell_flag = header_buy_sell_flag
				FROM  source_deal_header sdh				
				LEFT JOIN static_data_value sdv
					ON sdv.value_id = sdh.internal_portfolio_id
					AND sdv.type_id = 39800
				WHERE ISNULL(sdv.code, '-1') = 'Complex-LTO'
					AND sdh.source_deal_header_id = @delivery_deals_id --@delivery_deals_id

				IF @header_buy_sell_flag = 'b'
				BEGIN

					DELETE ed 
					FROM #existing_deals ed
					INNER JOIN source_deal_detail sdd
						ON ed.source_deal_header_id  = sdd.source_deal_header_id				
					WHERE leg = 1 
						AND	sdd.buy_sell_flag = 's'
					
				END
				ELSE
				BEGIN
					DELETE ed
					FROM #existing_deals ed
					INNER JOIN source_deal_detail sdd
						ON ed.source_deal_header_id  = sdd.source_deal_header_id				
					WHERE leg = 1 
						AND	sdd.buy_sell_flag = 'b'
					
				END
				
			END
		END

	
	END
	ELSE 
	BEGIN
		INSERT INTO #exclude_product_group
		SELECT 'Complex-EEX' UNION ALL
		SELECT 'Complex-LTO' UNION ALL
		SELECT 'Complex-ROD' UNION ALL
		SELECT 'Autopath Only'


		INSERT INTO #existing_deals (
			source_deal_header_id 
			, single_path_id 
			, group_path_id 
			, description1 
			, description2 
			, contract_id 
			, leg1_loc_id 
			, leg2_loc_id 
			, deal_id 
			, first_dom 
			, flow_date_from 
			, flow_date_to 
			, include_rec 
			, storage_deal_type 
			, org_storage_deal_type
		)
		SELECT	DISTINCT sdh.source_deal_header_id ,
			p.single_path_id,p.path_id group_path_id
			, sdh.[description1]
			, sdh.[description2]
			, ISNULL(sdh.[contract_id],-1) [contract_id]
			, p.leg1_loc_id
			, p.leg2_loc_id
			, sdh.deal_id
			, p.first_dom
			, p.flow_date_from
			, p.flow_date_to
			, p.include_rec
			, p.storage_deal_type
			, p.org_storage_deal_type	
		FROM dbo.source_deal_header sdh
		CROSS APPLY
		(
			SELECT MAX(CASE WHEN leg = 1 THEN location_id ELSE NULL END ) leg1_location_id
				, MAX(CASE WHEN leg = 2 THEN location_id ELSE NULL END ) leg2_location_id
			FROM source_deal_detail 
			WHERE source_deal_header_id = sdh.source_deal_header_id
		) sdd	
		INNER JOIN #tmp_vol_split_deal_final_grp p	
			ON  p.leg1_loc_id = sdd.leg1_location_id
			AND p.leg2_loc_id = sdd.leg2_location_id 
			AND p.first_dom = sdh.entire_term_start
		LEFT JOIN static_data_value sdv
			ON sdv.value_id = sdh.internal_portfolio_id 
			AND sdv.type_id = 39800	
		LEFT JOIN #exclude_product_group epg
			ON epg.product_name = ISNULL(sdv.code, '-1')
	
		WHERE p.storage_deal_type = 'n'		
			AND sdh.source_deal_type_id = @transportation_deal_type_id-- @transportation_deal_type_id --exclude transportation deal
			AND epg.product_name IS NULL
		UNION ALL
		SELECT  DISTINCT sdh.source_deal_header_id ,
			p.single_path_id,p.path_id group_path_id
			,sdh.[description1]
			,sdh.[description2]
			,COALESCE(od.contract_id, sdh.[contract_id],-1) [contract_id]
			,p.leg1_loc_id
			,p.leg2_loc_id
			,sdh.deal_id
			,p.first_dom
			,p.flow_date_from
			,p.flow_date_to
			,p.include_rec
			,p.storage_deal_type
			,p.org_storage_deal_type
		FROM #tmp_vol_split_deal_final_grp  p
		INNER JOIN delivery_path dp
			ON p.single_path_id = dp.path_id
		INNER JOIN source_deal_detail sdd
			ON sdd.location_id = p.leg1_loc_id
		INNER JOIN source_deal_header sdh
			ON sdh.source_deal_header_id = sdd.source_deal_header_id
			AND p.first_dom = sdh.entire_term_start
		INNER JOIN optimizer_detail od
			ON od.source_deal_header_id = sdh.source_deal_header_id
			AND COALESCE(p.single_contract_id,p.contract_id) = sdh.contract_id
		INNER JOIN delivery_path dp1
			ON dp1.path_id = od.single_path_id
			AND dp1.from_location = dp.from_location
		LEFT JOIN static_data_value sdv
			ON sdv.value_id = sdh.internal_portfolio_id 
			AND sdv.type_id = 39800	
		LEFT JOIN #exclude_product_group epg
			ON epg.product_name = ISNULL(sdv.code, '-1')
		WHERE p.storage_deal_type = 'i'
			AND sdh.deal_id LIKE 'INJC[_]%'
			AND epg.product_name IS NULL
		UNION ALL
		SELECT  DISTINCT  sdh.source_deal_header_id ,
			p.single_path_id,p.path_id group_path_id
			,sdh.[description1]
			,sdh.[description2]
			,COALESCE(od.contract_id, sdh.[contract_id],-1) [contract_id]
			,p.leg1_loc_id
			,p.leg2_loc_id
			,sdh.deal_id
			,p.first_dom
			,p.flow_date_from
			,p.flow_date_to
			,p.include_rec
			,p.storage_deal_type
			,p.org_storage_deal_type
		FROM #tmp_vol_split_deal_final_grp  p
		INNER JOIN delivery_path dp
			ON p.single_path_id = dp.path_id
		INNER JOIN source_deal_detail sdd
			ON sdd.location_id = p.leg1_loc_id
		INNER JOIN source_deal_header sdh
			ON sdh.source_deal_header_id = sdd.source_deal_header_id
			AND p.first_dom = sdh.entire_term_start
		INNER JOIN optimizer_detail od
			ON od.source_deal_header_id = sdh.source_deal_header_id
			AND COALESCE(p.single_contract_id,p.contract_id) = sdh.contract_id
		INNER JOIN delivery_path dp1
			ON dp1.path_id = od.single_path_id
			AND dp1.to_location = dp.to_location
		LEFT JOIN static_data_value sdv
			ON sdv.value_id = sdh.internal_portfolio_id 
			AND sdv.type_id = 39800	
		LEFT JOIN #exclude_product_group epg
			ON epg.product_name = ISNULL(sdv.code, '-1')
		WHERE 
		p.storage_deal_type = 'w'
			AND sdh.deal_id LIKE 'WTHD[_]%'
			AND epg.product_name IS NULL
				
	END



	
END --Data Prepararion

IF EXISTS(SELECT 1 FROM  #collect_deals) --Checked Template deals 
BEGIN
BEGIN TRY
	IF ISNULL(@reschedule, 0)  = 1 
	BEGIN
			
		SELECT 
			optimizer_header_id
			,flow_date
			,transport_deal_id
			,up_down_stream
			,source_deal_header_id
			,source_deal_detail_id
			,deal_volume
			,volume_used
			,sch_rec_volume
			,sch_del_volume
			,actual_rec_volume
			,actual_del_volume
			,create_user
			,create_ts
			,update_user
			,update_ts
		INTO  #deleted_od 
		FROM optimizer_detail 
		WHERE 1 = 2 				
		
		DELETE optimizer_detail_downstream 
		FROM optimizer_detail_downstream od 
		CROSS APPLY(
			SELECT MAX(CASE WHEN leg = 1 THEN location_id ELSE NULL END ) leg1_loc_id
				, MAX(CASE WHEN leg = 2 THEN location_id ELSE NULL END ) leg2_loc_id
			FROM source_Deal_detail 
			WHERE source_deal_header_id = od.transport_deal_id
				
		) sdd
		INNER JOIN #existing_deals rs 		
			ON rs.leg1_loc_id = sdd.leg1_loc_id
			AND rs.leg2_loc_id = sdd.leg2_loc_id
			AND rs.contract_id = od.contract_id
			AND od.transport_deal_id = rs.source_deal_header_id 
		WHERE od.flow_date BETWEEN @flow_date_from AND @flow_date_to 

	 
		DELETE optimizer_detail 
		OUTPUT	deleted.optimizer_header_id
				,deleted.flow_date
				,deleted.transport_deal_id
				,deleted.up_down_stream
				,deleted.source_deal_header_id
				,deleted.source_deal_detail_id
				,deleted.deal_volume
				,deleted.volume_used
				,deleted.sch_rec_volume
				,deleted.sch_del_volume
				,deleted.actual_rec_volume
				,deleted.actual_del_volume	
				,deleted.create_user
				,deleted.create_ts
				,deleted.update_user
				,deleted.update_ts		  
		INTO #deleted_od 
		FROM optimizer_detail od 
		INNER JOIN #existing_deals rs 
			ON od.transport_deal_id = rs.source_deal_header_id 
			AND rs.group_path_id = od.group_path_id
			AND rs.single_path_id = od.single_path_id
			AND rs.contract_id = od.contract_id
		WHERE od.flow_date BETWEEN @flow_date_from AND @flow_date_to

		DELETE optimizer_header 
		FROM optimizer_header oh
		INNER JOIN #existing_deals rs 
			ON oh.transport_deal_id = rs.source_deal_header_id
			AND rs.group_path_id = oh.group_path_id
			AND rs.single_path_id = oh.single_path_id
			AND rs.contract_id = oh.contract_id
		LEFT JOIN optimizer_detail od
			ON od.optimizer_header_id = oh.optimizer_header_id 
		WHERE oh.flow_date BETWEEN @flow_date_from AND @flow_date_to
			AND od.optimizer_header_id IS NULL			
			
	END
		
	IF OBJECT_ID('tempdb..#existing_deal_volume') IS NOT NULL DROP TABLE #existing_deal_volume
	SELECT ex.source_deal_header_id ,
		ex.single_path_id,ex.group_path_id
		,od.flow_date
		,od.leg1_volume leg1_volume
		,od.leg2_volume leg2_volume
		,od.contract_id
		,ex.leg1_loc_id
		,ex.leg2_loc_id
	INTO #existing_deal_volume --   SELECT * FROM  #existing_deal_volume
	FROM #existing_deals ex
	CROSS APPLY (
		SELECT flow_date
				, SUM(CASE WHEN up_down_stream = 'U' THEN volume_used ELSE NULL END) leg1_volume
				, SUM(CASE WHEN up_down_stream = 'D' THEN volume_used ELSE NULL END) leg2_volume 
				, MAX(contract_id) contract_id
		FROM optimizer_detail
		WHERE transport_deal_id = ex.source_deal_header_id 
			AND single_path_id = ex.single_path_id
			AND flow_date BETWEEN flow_date_from AND flow_date_to
			AND contract_id = ex.contract_id
		GROUP BY flow_date
	) od
	UNION ALL
	SELECT ex.source_deal_header_id ,
		ex.single_path_id,ex.group_path_id
		,od.flow_date
		,ISNULL(od.leg1_volume, od.leg2_volume) leg1_volume
		,ISNULL(od.leg2_volume,od.leg1_volume) leg2_volume
		,od.contract_id
		,ex.leg1_loc_id
		,ex.leg2_loc_id 
	FROM #existing_deals ex
	CROSS APPLY (
		SELECT flow_date
				, SUM(CASE WHEN up_down_stream = 'U' THEN volume_used ELSE NULL END) leg1_volume
				, SUM(CASE WHEN up_down_stream = 'D' THEN volume_used ELSE NULL END) leg2_volume 
				, MAX(contract_id) contract_id
		FROM optimizer_detail od
			WHERE source_deal_header_id = ex.source_deal_header_id 
			AND single_path_id = ex.single_path_id
			AND flow_date BETWEEN flow_date_from AND flow_date_to
			--AND contract_id = sdh.contract_id
		GROUP BY flow_date
	) od
	WHERE ex.storage_deal_type IN ('i', 'w')



IF @call_from IN('flow_match', 'match', 'main_menu', 'flow_auto', 'flow_auto_non_complex') AND @reschedule = 0
BEGIN
	DELETE FROM #existing_deals
END 


BEGIN -- Insert/Update Deal data 
--begin transaction t1;
	INSERT INTO [dbo].[source_deal_header]
		([source_system_id]
		, [deal_id]
		, [deal_date]
		, [ext_deal_id]
		, [physical_financial_flag]
		, [structured_deal_id]
		, [counterparty_id]
		, [entire_term_start]
		, [entire_term_end]
		, [source_deal_type_id]
		, [deal_sub_type_type_id]
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
		, [deal_category_value_id]
		, [trader_id]
		, [internal_deal_type_value_id]
		, [internal_deal_subtype_value_id]
		, [template_id]
		, [header_buy_sell_flag]
		, [broker_id]
		, [generator_id]
		, [status_value_id]
		, [status_date]
		, [assignment_type_value_id]
		, [compliance_year]
		, [state_value_id]
		, [assigned_date]
		, [assigned_by]
		, [generation_source]
		, [aggregate_environment]
		, [aggregate_envrionment_comment]
		, [rec_price]
		, [rec_formula_id]
		, [rolling_avg]
		, [contract_id]
		, [create_user]
		, [create_ts]
		, [update_user]
		, [update_ts]
		, [legal_entity]
		, [internal_desk_id]
		, [product_id]
		, [internal_portfolio_id]
		, [commodity_id]
		, [reference]
		, [deal_locked]
		, [close_reference_id]
		, [block_type]
		, [block_define_id]
		, [granularity_id]
		, [Pricing]
		, [deal_reference_type_id]
		, [unit_fixed_flag]
		, [broker_unit_fees]
		, [broker_fixed_cost]
		, [broker_currency_id]
		, [deal_status]
		, [term_frequency]
		, [option_settlement_date]
		, [verified_by]
		, [verified_date]
		, [risk_sign_off_by]
		, [risk_sign_off_date]
		, [back_office_sign_off_by]
		, [back_office_sign_off_date]
		, [book_transfer_id]
		, [confirm_status_type]
		, [sub_book]
		, [deal_rules]
		, [confirm_rule]
		, [description4]
		, [timezone_id]
		, [profile_granularity])
	OUTPUT 
		inserted.[source_system_id]
		, inserted.[deal_id]
		, inserted.[deal_date]
		, inserted.[ext_deal_id]
		, inserted.[physical_financial_flag]
		, inserted.[structured_deal_id]
		, inserted.[counterparty_id]
		, inserted.[entire_term_start]
		, inserted.[entire_term_end]
		, inserted.[source_deal_type_id]
		, inserted.[deal_sub_type_type_id]
		, inserted.[option_flag]
		, inserted.[option_type]
		, inserted.[option_excercise_type]
		, inserted.[source_system_book_id1]
		, inserted.[source_system_book_id2]
		, inserted.[source_system_book_id3]
		, inserted.[source_system_book_id4]
		, inserted.[description1]
		, inserted.[description2]
		, inserted.[description3]
		, inserted.[deal_category_value_id]
		, inserted.[trader_id]
		, inserted.[internal_deal_type_value_id]
		, inserted.[internal_deal_subtype_value_id]
		, inserted.[template_id]
		, inserted.[header_buy_sell_flag]
		, inserted.[broker_id]
		, inserted.[generator_id]
		, inserted.[status_value_id]
		, inserted.[status_date]
		, inserted.[assignment_type_value_id]
		, inserted.[compliance_year]
		, inserted.[state_value_id]
		, inserted.[assigned_date]
		, inserted.[assigned_by]
		, inserted.[generation_source]
		, inserted.[aggregate_environment]
		, inserted.[aggregate_envrionment_comment]
		, inserted.[rec_price]
		, inserted.[rec_formula_id]
		, inserted.[rolling_avg]
		, inserted.[contract_id]
		, inserted.[create_user]
		, inserted.[create_ts]
		, inserted.[update_user]
		, inserted.[update_ts]
		, inserted.[legal_entity]
		, inserted.[internal_desk_id]
		, inserted.[product_id]
		, inserted.[internal_portfolio_id]
		, inserted.[commodity_id]
		, inserted.[reference]
		, inserted.[deal_locked]
		, inserted.[close_reference_id]
		, inserted.[block_type]
		, inserted.[block_define_id]
		, inserted.[granularity_id]
		, inserted.[Pricing]
		, inserted.[deal_reference_type_id]
		, inserted.[unit_fixed_flag]
		, inserted.[broker_unit_fees]
		, inserted.[broker_fixed_cost]
		, inserted.[broker_currency_id]
		, inserted.[deal_status]
		, inserted.[term_frequency]
		, inserted.[option_settlement_date]
		, inserted.[verified_by]
		, inserted.[verified_date]
		, inserted.[risk_sign_off_by]
		, inserted.[risk_sign_off_date]
		, inserted.[back_office_sign_off_by]
		, inserted.[back_office_sign_off_date]
		, inserted.[book_transfer_id]
		, inserted.[confirm_status_type]
		, inserted.[sub_book]
		, inserted.[deal_rules]
		, inserted.[confirm_rule]
		, inserted.[description4]
		, inserted.[timezone_id]
		, inserted.[source_deal_header_id]			
		,1 is_insert		
	INTO #tmp_header   -- SELECT * FROM #tmp_header
	SELECT DISTINCT
		h.[source_system_id]
		, @process_id + '____' + CAST(p.rowid AS VARCHAR)
		, p.first_dom
		, h.[ext_deal_id]
		, h.[physical_financial_flag]
		, h.[structured_deal_id]
		, COALESCE(@counterparty_id, p.counterparty_id,h.[counterparty_id] ) [counterparty_id]
		, p.first_dom
		, DATEADD(MONTH, 1, CAST(p.first_dom AS DATETIME)) - 1
		, h.[source_deal_type_id]
		, h.[deal_sub_type_type_id]
		, h.[option_flag]
		, h.[option_type]
		, h.[option_excercise_type]
		, ISNULL(p.source_system_book_id1, h.source_system_book_id1) [source_system_book_id1]
		, ISNULL(p.source_system_book_id2, h.source_system_book_id2) [source_system_book_id2]
		, ISNULL(p.source_system_book_id3, h.source_system_book_id3) [source_system_book_id3]
		, ISNULL(p.source_system_book_id4, h.source_system_book_id4) [source_system_book_id4]
		, p.[description1]
		, ISNULL(p.[description2],h.description2) [description2]
		, h.[description3]
		, h.[deal_category_value_id]
		, h.[trader_id]
		, CASE WHEN @counterparty_id IS NOT NULL THEN 153 ELSE h.[internal_deal_type_value_id] END [internal_deal_type_value_id]
		, h.[internal_deal_subtype_value_id]
		, h.[template_id]
		, h.[header_buy_sell_flag]
		, h.[broker_id]
		, h.[generator_id]
		, h.[status_value_id]
		, h.[status_date]
		, h.[assignment_type_value_id]
		, h.[compliance_year]
		, h.[state_value_id]
		, h.[assigned_date]
		, h.[assigned_by]
		, h.[generation_source]
		, h.[aggregate_environment]
		, h.[aggregate_envrionment_comment]
		, h.[rec_price]
		, h.[rec_formula_id]
		, h.[rolling_avg]
		, ISNULL(p.single_contract_id, NULLIF(p.[contract_id], 0)) [contract_id]
		, h.[create_user]
		, GETDATE()
		, h.[update_user]
		, GETDATE()
		, h.[legal_entity]
		, CASE @granularity WHEN 981 THEN 17300 WHEN 982 THEN 17302 ELSE 17300 END [internal_desk_id]
		, h.[product_id]
		, h.[internal_portfolio_id]
		, h.[commodity_id]
		, h.[reference]
		, 'n' [deal_locked]
		, h.[close_reference_id]
		, h.[block_type]
		, h.[block_define_id]
		, h.[granularity_id]
		, h.[Pricing]
		, h.[deal_reference_type_id]
		, h.[unit_fixed_flag]
		, h.[broker_unit_fees]
		, h.[broker_fixed_cost]
		, h.[broker_currency_id]
		, h.[deal_status]
		, h.[term_frequency]
		, h.[option_settlement_date]
		, h.[verified_by]
		, h.[verified_date]
		, h.[risk_sign_off_by]
		, h.[risk_sign_off_date]
		, h.[back_office_sign_off_by]
		, h.[back_office_sign_off_date]
		, h.[book_transfer_id]
		, h.[confirm_status_type]
		, ISNULL(p.book_deal_type_map_id, h.[sub_book])
		, h.[deal_rules]
		, h.[confirm_rule]
		, h.[description4]
		, h.[timezone_id]
		, IIF(@is_hourly_calc = 1, @granularity, NULL) --    SELECT *
	FROM #tmp_vol_split_deal_final_grp p
	INNER JOIN #source_deal_header h 
		ON h.source_deal_header_id = p.templete_deal_id	 
	--LEFT JOIN #gen_nomination_mapping gnm 
	--	ON gnm.pipeline = COALESCE(@counterparty_id, p.counterparty_id,h.[counterparty_id] )
	--LEFT JOIN source_system_book_map ssbm 
	--	ON ssbm.book_deal_type_map_id = gnm.sub_book_id
	LEFT JOIN #existing_deals ed 
		ON ed.leg1_loc_id= p.leg1_loc_id
		AND ed.leg2_loc_id= p.leg2_loc_id
		AND ed.first_dom = p.first_dom
	LEFT JOIN optimizer_detail od
		ON od.source_deal_header_id = ed.source_deal_header_id
		AND ed.contract_id = COALESCE(od.contract_id, p.single_contract_id, p.contract_id) 
	WHERE ed.source_deal_header_id IS NULL 
		AND  p.include_rec = 1
		AND (p.leg1_volume <> 0 AND p.leg2_volume <> 0)

	UPDATE #tmp_vol_split_deal_final_grp
		SET source_deal_header_id = th.source_deal_header_id
	FROM #tmp_vol_split_deal_final_grp p
	INNER JOIN #tmp_header th 
		ON p.rowid = REVERSE(LEFT(REVERSE(th.deal_id), CHARINDEX('____', REVERSE(th.deal_id), 1) - 1))

	UPDATE #tmp_vol_split_deal_final_grp
		SET source_deal_header_id = ed.source_deal_header_id
	FROM #tmp_vol_split_deal_final_grp p
	INNER JOIN #existing_deals ed 
		ON ed.leg1_loc_id= p.leg1_loc_id
		AND ed.leg2_loc_id= p.leg2_loc_id
		AND ed.first_dom= p.first_dom
	LEFT JOIN optimizer_detail od
		ON od.source_deal_header_id = ed.source_deal_header_id 
		AND ed.contract_id = COALESCE(od.contract_id,p.single_contract_id, p.contract_id)

	INSERT INTO #tmp_header 
	SELECT DISTINCT i.[source_system_id]
		, i.[deal_id]
		, i.[deal_date]
		, i.[ext_deal_id]
		, i.[physical_financial_flag]
		, i.[structured_deal_id]
		, i.[counterparty_id]
		, i.[entire_term_start]
		, i.[entire_term_end]
		, i.[source_deal_type_id]
		, i.[deal_sub_type_type_id]
		, i.[option_flag]
		, i.[option_type]
		, i.[option_excercise_type]
		, i.[source_system_book_id1]
		, i.[source_system_book_id2]
		, i.[source_system_book_id3]
		, i.[source_system_book_id4]
		, i.[description1]
		, i.[description2]
		, i.[description3]
		, i.[deal_category_value_id]
		, i.[trader_id]
		, i.[internal_deal_type_value_id]
		, i.[internal_deal_subtype_value_id]
		, i.[template_id]
		, i.[header_buy_sell_flag]
		, i.[broker_id]
		, i.[generator_id]
		, i.[status_value_id]
		, i.[status_date]
		, i.[assignment_type_value_id]
		, i.[compliance_year]
		, i.[state_value_id]
		, i.[assigned_date]
		, i.[assigned_by]
		, i.[generation_source]
		, i.[aggregate_environment]
		, i.[aggregate_envrionment_comment]
		, i.[rec_price]
		, i.[rec_formula_id]
		, i.[rolling_avg]
		, i.[contract_id]
		, i.[create_user]
		, i.[create_ts]
		, i.[update_user]
		, i.[update_ts]
		, i.[legal_entity]
		, i.[internal_desk_id]
		, i.[product_id]
		, i.[internal_portfolio_id]
		, i.[commodity_id]
		, i.[reference]
		, i.[deal_locked]
		, i.[close_reference_id]
		, i.[block_type]
		, i.[block_define_id]
		, i.[granularity_id]
		, i.[Pricing]
		, i.[deal_reference_type_id]
		, i.[unit_fixed_flag]
		, i.[broker_unit_fees]
		, i.[broker_fixed_cost]
		, i.[broker_currency_id]
		, i.[deal_status]
		, i.[term_frequency]
		, i.[option_settlement_date]
		, i.[verified_by]
		, i.[verified_date]
		, i.[risk_sign_off_by]
		, i.[risk_sign_off_date]
		, i.[back_office_sign_off_by]
		, i.[back_office_sign_off_date]
		, i.[book_transfer_id]
		, i.[confirm_status_type]
		, i.[sub_book]
		, i.[deal_rules]
		, i.[confirm_rule]
		, i.[description4]
		, i.[timezone_id]
		, i.[source_deal_header_id]	
		,0 is_insert		
	FROM source_deal_header i
	INNER JOIN #existing_deals e 
		ON i.source_deal_header_id = e.source_deal_header_id
	LEFT JOIN #tmp_header h 
		ON i.source_deal_header_id = h.source_deal_header_id
	WHERE h.source_deal_header_id IS NULL
	
	SET @sql = 'INSERT INTO ' + @inserted_updated_deals + '
				SELECT source_deal_header_id,
					is_insert
				FROM #tmp_header
				'
	EXEC(@sql)
	
	UPDATE #existing_deals
		SET [deal_id] = @process_id + '____' + CAST(p.rowid AS VARCHAR)	
	FROM #tmp_vol_split_deal_final_grp p
	INNER JOIN source_deal_header h 
		ON h.source_deal_header_id = p.templete_deal_id	 
	LEFT JOIN #gen_nomination_mapping gnm 
		ON gnm.pipeline = COALESCE(@counterparty_id, p.counterparty_id,h.[counterparty_id] )
		AND gnm.path_id = p.path_id
	LEFT JOIN source_system_book_map ssbm 
		ON ssbm.book_deal_type_map_id = gnm.sub_book_id
	LEFT JOIN #existing_deals ed 
		ON ed.leg1_loc_id= p.leg1_loc_id
		AND ed.leg2_loc_id= p.leg2_loc_id
		AND ed.first_dom = p.first_dom		
	LEFT JOIN optimizer_detail od
		ON od.source_deal_header_id = ed.source_deal_header_id
		AND ed.contract_id = COALESCE(od.contract_id, p.single_contract_id, p.contract_id) 

	WHERE ed.source_deal_header_id IS NOT NULL
		AND p.include_rec = 1
		
	UPDATE #tmp_header 
		SET [deal_id]=ed.[deal_id] 
	FROM #tmp_header th 
	INNER JOIN #existing_deals ed
		ON th.source_deal_header_id = ed.source_deal_header_id
	WHERE ed.include_rec = 1	

	UPDATE sdd 
	SET deal_volume = NULL
	FROM source_deal_detail sdd
	INNER JOIN #existing_deals rs 
		ON sdd.source_deal_header_id = rs.source_deal_header_id
		AND ( ISNULL(@reschedule, 0) = 1)
	WHERE sdd.term_start BETWEEN @flow_date_from AND @flow_date_to

	IF OBJECT_ID('tempdb..#inserted_deal_detail') IS NOT NULL DROP TABLE #inserted_deal_detail 
	CREATE  TABLE #inserted_deal_detail (
		source_deal_header_id	INT
		, source_deal_detail_id	INT
		, leg						INT
		, term_start DATETIME
		, deal_volume NUMERIC(28,8)
		, fixed_price FLOAT
		, is_insert BIT
		, deal_volume_old NUMERIC(28,8)
		, group_path_id INT
		, single_path_id INT
	)

	UPDATE [dbo].[source_deal_detail] 
		SET [deal_volume] = ISNULL(CASE WHEN sdd.Leg = 1 THEN ed.leg1_volume ELSE ed.leg2_volume END,0)
							+ ROUND(CASE WHEN leg = 1 THEN ISNULL(cp.leg1_volume,  p.leg1_deal_volume) ELSE ISNULL(cp.leg2_volume, p.leg2_deal_volume) END, 0)
							, actual_volume = CASE WHEN ISNULL(@reschedule, 0) = 1 THEN NULL ELSE actual_volume END
							, schedule_volume = CASE WHEN ISNULL(@reschedule, 0) = 1 THEN NULL ELSE schedule_volume END
							, attribute4 = ISNULL(p.path_id, p.single_path_id)
							, attribute5 = p.single_path_id

	OUTPUT INSERTED.source_deal_header_id
		, INSERTED.source_deal_detail_id 
		, INSERTED.leg  
		, inserted.term_start
		, inserted.deal_volume
		, inserted.fixed_price
		, CASE WHEN ISNULL(@reschedule, 0) = 1 THEN 1 ELSE 0 END
		, deleted.deal_volume
		, inserted.attribute4 
		, inserted.attribute5 
	INTO #inserted_deal_detail --SELECT * FROM #inserted_deal_detail
	FROM #tmp_vol_split_deal_final_grp p
	INNER JOIN [dbo].[source_deal_detail] sdd 
		ON sdd.source_deal_header_id = p.source_deal_header_id
		AND sdd.term_start BETWEEN p.flow_date_from AND p.flow_date_to
	INNER JOIN #existing_deals e 
		ON e.source_deal_header_id = p.source_deal_header_id
		AND e.leg1_loc_id= p.leg1_loc_id
		AND e.leg2_loc_id= p.leg2_loc_id
	LEFT JOIN #existing_deal_volume ed 
		ON ed.source_deal_header_id = p.source_deal_header_id
		AND ed.flow_date = sdd.term_start
		AND ed.leg1_loc_id= p.leg1_loc_id
		AND ed.leg2_loc_id= p.leg2_loc_id
	LEFT JOIN optimizer_detail od
		ON od.source_deal_header_id = ed.source_deal_header_id
		AND ed.contract_id = COALESCE(od.contract_id, p.single_contract_id, p.contract_id) 
	 LEFT JOIN #common_path cp
		 ON  p.single_path_id = cp.single_path_id
		 AND p.first_dom = cp.first_dom 
		 AND p.contract_id = cp.contract_id	
	WHERE ISNULL(CASE WHEN sdd.Leg = 1 THEN ed.leg1_volume ELSE ed.leg2_volume END,0)
		+ ROUND(CASE WHEN leg = 1 THEN p.leg1_deal_volume ELSE p.leg2_deal_volume END, 0) <> 0
	--rollback transaction t1;
	--return
	INSERT INTO [dbo].[source_deal_detail](
		[source_deal_header_id]
		, [term_start]
		, [term_end]
		, [Leg]
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
		, [volume_left]
		, [settlement_volume]
		, [settlement_uom]
		, [create_user]
		, [create_ts]
		, [update_user]
		, [update_ts]
		, [price_adder]
		, [price_multiplier]
		, [settlement_date]
		, [day_count_id]
		, [location_id]
		, [meter_id]
		, [physical_financial_flag]
		, [Booked]
		, [process_deal_status]
		, [fixed_cost]
		, [multiplier]
		, [adder_currency_id]
		, [fixed_cost_currency_id]
		, [formula_currency_id]
		, [price_adder2]
		, [price_adder_currency2]
		, [volume_multiplier2]
		, [pay_opposite]
		, [capacity]
		, [settlement_currency]
		, [standard_yearly_volume]
		, [formula_curve_id]
		, [price_uom_id]
		, [category]
		, [profile_code]
		, [pv_party]
		, [status]
		, [lock_deal_detail]
		, attribute4
		, attribute5
	)
	OUTPUT INSERTED.source_deal_header_id
		, INSERTED.source_deal_detail_id 
		, INSERTED.leg  
		, INSERTED.term_start
		, INSERTED.deal_volume
		, inserted.fixed_price
		, 1
		, NULL
		, INSERTED.attribute4
		, INSERTED.attribute5
	INTO #inserted_deal_detail   ---    SELECT * FROM #source_deal_detail
	SELECT DISTINCT th.[source_deal_header_id]
		, tm.term_start
		, tm.term_end
		, s.[Leg]
		, tm.term_end [contract_expiration_date]
		, s.[fixed_float_leg]
		, s.[buy_sell_flag]
		, sml.term_Pricing_Index curve_id
		, s.[fixed_price]
		, s.[fixed_price_currency_id]
		, s.[option_strike_price]
		, ROUND(CASE WHEN tm.term_start BETWEEN ISNULL(p.match_term_start, @flow_date_from) AND ISNULL(p.match_term_end, @flow_date_to) 
				THEN ROUND(CASE WHEN s.leg = 1 THEN p.leg1_deal_volume ELSE p.leg2_deal_volume END,0) ELSE 0 	END, 0) [deal_volume]
		, CASE @granularity WHEN 981 THEN 'd' WHEN 982 THEN 'h' ELSE 'd' END [deal_volume_frequency]
		, ISNULL(NULLIF(@target_uom, ''), s.[deal_volume_uom_id]) deal_volume_uom_id
		, s.[block_description]
		, s.[deal_detail_description]
		, s.[formula_id]
		, ROUND(CASE WHEN tm.term_start BETWEEN ISNULL(p.match_term_start,@flow_date_from) AND ISNULL(p.match_term_end,@flow_date_to) 
			THEN ROUND(CASE WHEN s.leg = 1 THEN p.leg1_deal_volume ELSE p.leg2_deal_volume END, 0) ELSE 0 END, 0) [volume_left]
		, s.[settlement_volume]
		, s.[settlement_uom]
		, s.[create_user]
		, GETDATE() [create_ts]
		, s.[update_user]
		, GETDATE() [update_ts]
		, s.[price_adder]
		, s.[price_multiplier]
		, s.[settlement_date]
		, s.[day_count_id]
		, CASE WHEN s.leg = 1 THEN p.leg1_loc_id ELSE p.leg2_loc_id END [location_id]
		, CASE WHEN s.leg = 1 THEN p.leg1_meter_id ELSE p.leg2_meter_id END [meter_id]
		, s.[physical_financial_flag]
		, s.[Booked]
		, s.[process_deal_status]
		, s.[fixed_cost]
		, s.[multiplier]
		, s.[adder_currency_id]
		, s.[fixed_cost_currency_id]
		, s.[formula_currency_id]
		, s.[price_adder2]
		, s.[price_adder_currency2]
		, s.[volume_multiplier2]
		, s.[pay_opposite]
		, s.[capacity]
		, s.[settlement_currency]
		, s.[standard_yearly_volume]
		, ISNULL(pfc_curve.pfc_curve_id, s.[formula_curve_id])
		, s.[price_uom_id]
		, s.[category]
		, s.[profile_code]
		, s.[pv_party]
		, s.[status]
		, s.[lock_deal_detail]	
		, ISNULL(p.path_id, p.single_path_id)
		, p.single_path_id	--SELECT *
	FROM #tmp_vol_split_deal_final_grp p	
	INNER JOIN	#source_deal_detail s 
		ON s.source_deal_header_id = p.templete_deal_id
	INNER JOIN  #tmp_header th  
		ON th.deal_id = @process_id + '____' + CAST(p.rowid AS VARCHAR)
	OUTER APPLY (
		SELECT DATEADD(DAY, n - 1, th.[entire_term_start]) term_start, DATEADD(DAY, n - 1, th.[entire_term_start]) term_end  
		FROM seq 
		WHERE th.[entire_term_end] >= DATEADD(DAY, n - 1, th.[entire_term_start]) --AND dd.term_start <> dd.term_end
	) tm
	INNER JOIN source_minor_location sml 
		ON sml.source_minor_location_id = CASE WHEN leg = 1 THEN p.leg1_loc_id ELSE p.leg2_loc_id END 
	LEFT JOIN #dest_deal_info ddi 
		ON ddi.term_start = tm.term_start  
		AND ISNULL(p.single_path_id, p.path_id) = ddi.single_path_id
	LEFT JOIN delivery_path dp
		ON dp.path_id = ISNULL(p.path_id, p.single_path_id)
	LEFT JOIN #storage_book_mapping pfc_curve
		ON pfc_curve.path_id = ISNULL(p.single_path_id, p.path_id)
		AND pfc_curve.location_id = p.leg2_loc_id
		AND pfc_curve.pipeline = COALESCE(@counterparty_id, dp.counterParty, th.[counterparty_id] )
		AND pfc_curve.storage_type = p.storage_deal_type
		AND p.storage_deal_type = 'i'
	WHERE p.include_rec = 1 
		AND ISNULL(@reschedule, 0) = 0	
		AND NOT EXISTS(SELECT TOP 1 1 FROM #existing_deals e1 WHERE e1.source_deal_header_id = th.[source_deal_header_id]) --excluding duplicate insert of existing deals where error caused for unique key constraint 'IX_source_deal_detail'

	UPDATE sdd
	SET attribute4 = NULL,
		attribute5 = NULL
	FROM [source_deal_detail] sdd
	INNER JOIN #inserted_deal_detail i
		ON sdd.source_deal_detail_id = i.source_deal_detail_id
	
	--Updating Shipper mapping data in transportation deal 
	IF EXISTS( 
		SELECT 1
		FROM #tmp_header tm
		INNER JOIN source_deal_header sdh
			ON sdh.source_deal_header_id = tm.source_deal_header_id 
		WHERE sdh.template_id = @transportation_template_id
	)
	BEGIN
		DECLARE @source_deal_header_id INT,
				@entire_term_start DATETIME,
				@entire_term_end DATETIME,
				@deal_counterparty_id INT,
				@contract_id INT,
				@shipper_mapping_id INT

		DECLARE  cur_shipper CURSOR LOCAL FOR
			SELECT tm.source_deal_header_id, tm.entire_term_start, tm.entire_term_end, tm.counterparty_id, tm.contract_id
			FROM #tmp_header tm
				INNER JOIN source_deal_header sdh
				ON sdh.source_deal_header_id = tm.source_deal_header_id 
			WHERE sdh.template_id = @transportation_template_id
	
		OPEN cur_shipper
		FETCH NEXT FROM cur_shipper INTO  @source_deal_header_id, @entire_term_start, @entire_term_end, @deal_counterparty_id, @contract_id
		WHILE @@FETCH_STATUS = 0   
		BEGIN 
			
			--leg1 == sell
			--leg2== buy

			EXEC spa_deal_fields_mapping @flag = 'v'
										, @deal_id = @source_deal_header_id										
										, @counterparty_id = @deal_counterparty_id									
										, @deal_fields = 'shipper_code1'
										, @term_start =  @entire_term_start									
										, @contract_id = @contract_id
										, @buy_sell_flag = 'b'
										, @json_string = @shipper_mapping_id OUTPUT
			
			UPDATE sdd
				SET shipper_code1 = @shipper_mapping_id,
					shipper_code2 = @shipper_mapping_id
			FROM source_deal_detail sdd
			WHERE source_deal_header_id = @source_deal_header_id
			AND term_start BETWEEN @entire_term_start AND @entire_term_end
			AND sdd.leg = 2

			EXEC spa_deal_fields_mapping @flag = 'v'
										, @deal_id = @source_deal_header_id										
										, @counterparty_id = @deal_counterparty_id									
										, @deal_fields = 'shipper_code1'
										, @term_start =  @entire_term_start									
										, @contract_id = @contract_id
										, @buy_sell_flag = 's'
										, @json_string = @shipper_mapping_id OUTPUT
			
			UPDATE sdd
				SET shipper_code1 = @shipper_mapping_id,
					shipper_code2 = @shipper_mapping_id
			FROM source_deal_detail sdd
			WHERE source_deal_header_id = @source_deal_header_id
			AND term_start BETWEEN @entire_term_start AND @entire_term_end
			AND sdd.leg = 1


			FETCH NEXT FROM cur_shipper INTO @source_deal_header_id, @entire_term_start, @entire_term_end, @deal_counterparty_id, @contract_id
		END

		CLOSE cur_shipper
		
	END

	UPDATE sdh
	SET counterparty_id = ISNULL(sml.pipeline, @default_counterparty_id) 
	FROM source_deal_header sdh
	INNER JOIN #inserted_deal_detail idd
		ON sdh.source_deal_header_id = idd.source_deal_header_id
	INNER JOIN source_deal_detail sdd
		ON sdd.source_deal_detail_id = idd.source_deal_detail_id
	INNER JOIN source_minor_location sml
		ON sml.source_minor_location_id = sdd.location_id
	WHERE sdh.contract_id = @base_contract_id



	IF OBJECT_ID('tempdb..#inserted_deal_detail111') IS NOT NULL DROP TABLE #inserted_deal_detail111 
	SELECT DISTINCT * 
	INTO  #inserted_deal_detail111 -- SELECT * FROM #inserted_deal_detail111
	FROM #inserted_deal_detail

	IF @call_from IN( 'flow_opt', 'flow_auto') AND @is_hourly_calc = 1
	BEGIN


		--Add hour volume in case of incremental schedule
		--update hour volume in case of reschedule
	
		IF @call_from <> 'flow_auto'
		BEGIN
		SET @sql = 'UPDATE sddh
					SET volume ' + CASE WHEN @reschedule = 1 THEN '=' ELSE '+=' END + ' CASE WHEN idd.leg = 1 THEN cdmh.received ELSE cdmh.delivered END 
				FROM #inserted_deal_detail idd
				INNER JOIN ' + @contract_detail_hourly + ' cdmh
					ON idd.term_start = cdmh.term_start
					AND idd.single_path_id = cdmh.path_id
				INNER JOIN source_deal_detail_hour sddh
					ON sddh.source_deal_detail_id = idd.source_deal_detail_id
					AND sddh.hr =  RIGHT(''0'' + CAST(cdmh.hour AS VARCHAR(10)), 2) + '':00''
				INNER JOIN source_deal_header sdh
					ON sdh.source_deal_header_id = idd.source_deal_header_id
				--LEFT JOIN static_data_value sdv
				--	ON sdv.value_id = sdh.internal_portfolio_id
				--	AND sdv.type_id = 39800
				--WHERE ISNULL(sdv.code, ''-1'') NOT IN (''Complex-LTO'', ''Autopath Only'')
				'
		EXEC(@sql)

		
		SET @sql = 'INSERT INTO source_deal_detail_hour(
						source_deal_detail_id
						, term_date
						, hr
						, is_dst
						, granularity
						, volume
					) 
					SELECT idd.source_deal_detail_id
						,idd.term_start
						, RIGHT(''0'' + CAST(cdmh.hour AS VARCHAR(10)), 2) + '':00'' hr
						, 0 is_dst
						, ' + CAST(@granularity AS VARCHAR(10)) + ' granularity
						--, ABS(CAST(CASE WHEN idd.leg = 1 THEN cdmh.received ELSE cdmh.delivered END AS NUMERIC(38,20))) deal_volume
						, CAST(CASE WHEN idd.leg = 1 THEN cdmh.received ELSE cdmh.delivered END AS NUMERIC(38,20)) deal_volume
					FROM #inserted_deal_detail idd
					INNER JOIN ' + @contract_detail_hourly + ' cdmh
						ON idd.term_start = cdmh.term_start
						AND idd.single_path_id = cdmh.path_id
					LEFT JOIN source_deal_detail_hour sddh
						ON sddh.source_deal_detail_id = idd.source_deal_detail_id
						AND sddh.hr =  RIGHT(''0'' + CAST(cdmh.hour AS VARCHAR(10)), 2) + '':00''
					WHERE sddh.source_deal_detail_id IS NULL
				'
			--print @sql
			EXEC(@sql)	
			
		END
		

	END 
	ELSE IF @call_from = 'transmission_opt'
	BEGIN
		DELETE dbo.source_deal_detail_hour 
		FROM #inserted_deal_detail111 idd 
		INNER JOIN dbo.source_deal_detail_hour sddh 
			ON idd.source_deal_detail_id = sddh.source_deal_detail_id
			AND idd.term_start = sddh.term_date

		INSERT INTO dbo.source_deal_detail_hour (
			source_deal_detail_id
			, term_date
			, hr
			, is_dst
			, volume
			, price
			, formula_id
			, granularity
		)
		SELECT idd.source_deal_detail_id,
			idd.term_start
			, hr = RIGHT('0'+CAST(CASE WHEN @granularity = 982 THEN hr.item    --hourly
						WHEN @granularity = 989 THEN 1 + hr.item / 2 + CASE WHEN hr.item % 2 = 0 THEN 0 ELSE -1 END --30Min
						WHEN @granularity = 987 THEN 1 + hr.item / 4 + CASE WHEN hr.item % 4 = 0 THEN 0 ELSE -1 END --15min
					END
					AS VARCHAR), 2)+':'+
					CASE WHEN @granularity = 982 THEN '00'    --hourly
						WHEN @granularity = 989 THEN CASE WHEN hr.item % 2 = 1 THEN '00' ELSE '30' END --30Min
						WHEN @granularity = 987 THEN  
							CASE WHEN hr.item % 4 = 1 THEN '00'
								WHEN hr.item % 4 = 2 THEN '15'
								WHEN hr.item % 4 = 3 THEN '30'
								WHEN hr.item % 4 = 0 THEN '45'
							 END   --15min
						END,
			0 is_dst,
			ABS(CAST(idd.deal_volume AS NUMERIC(38,20))),
			idd.fixed_price,
			NULL formula_id,
			@granularity granularity
		FROM #inserted_deal_detail111 idd 
		CROSS APPLY [dbo].[FNASplit](@period, ',') hr
		WHERE idd.is_insert = 1 
			AND ISNULL(@reschedule, 0) = 0	


		UPDATE dbo.source_deal_detail_hour 
			SET volume = idd.deal_volume
				, price = idd.fixed_price
		FROM #inserted_deal_detail111 idd 
		INNER JOIN dbo.source_deal_detail_hour sddh 
			ON idd.source_deal_detail_id = sddh.source_deal_detail_id
			AND idd.term_start = sddh.term_date
		WHERE idd.is_insert = CASE WHEN ISNULL(@reschedule, 0) = 0 THEN 0 ELSE 1 END

		UPDATE sdd1
			SET deal_volume = gen_term.volume
				,fixed_price = gen_term.price / gen_term.volume
		FROM #inserted_deal_detail111 sdd
		INNER JOIN source_deal_detail sdd1 
			ON sdd.source_deal_detail_id=sdd1.source_deal_detail_id
			CROSS APPLY ( 
				SELECT SUM(volume * price) price
					, SUM(volume) volume 
				FROM  source_deal_detail_hour 
				WHERE source_deal_detail_id = sdd.source_deal_detail_id
			) gen_term
		WHERE  gen_term.volume <> 0
	END

	IF OBJECT_ID('tempdb..#inserted_deal_scheduled') IS NOT NULL DROP TABLE #inserted_deal_scheduled
	CREATE TABLE #inserted_deal_scheduled (
			deal_schedule_id		INT, 
			path_id					INT 	
	)

	INSERT INTO [dbo].[deal_schedule] (path_id, term_start, term_end, scheduled_volume, delivered_volume) 
	OUTPUT INSERTED.deal_schedule_id, INSERTED.path_id
	INTO #inserted_deal_scheduled
	SELECT ISNULL(p.single_path_id,p.path_id) path_id
			, ISNULL(p.match_term_start, @flow_date_from) term_start
			, ISNULL(p.match_term_end, @flow_date_to) term_end
			, p.receipt_volume
			, p.delivery_volume
	 FROM #collect_deals p
	 WHERE ISNULL(p.storage_deal_type,'n') ='n'	 

	/**********************INSERT INTO *[user_defined_deal_fields]*****************************************************/

	IF OBJECT_ID('tempdb..#inserted_grp_path') IS NOT NULL DROP TABLE #inserted_grp_path
	CREATE TABLE #inserted_grp_path (
		source_deal_header_id INT,
		[udf_template_id] INT,
		[udf_value] VARCHAR(1000) COLLATE DATABASE_DEFAULT
	)								
			
	INSERT INTO [dbo].[user_defined_deal_fields](
		[source_deal_header_id]
		,[udf_template_id]
		,[udf_value]
		,[create_user]
		,[create_ts]
	)
	SELECT	th.source_deal_header_id 
		, u.[udf_template_id]
		, CASE uddft.field_id
			WHEN -5614 THEN CAST((p.leg1_volume - p.leg2_volume) / p.leg1_volume AS VARCHAR)	 -- loss_factor
			WHEN @delivery_path_id THEN CAST(CAST(ISNULL(p.single_path_id, p.path_id) AS NUMERIC(28, 0)) AS VARCHAR)
			WHEN @grp_delivery_path_id THEN CASE WHEN p.group_path = 'y' THEN CAST(CAST(p.path_id AS NUMERIC(28, 0)) AS VARCHAR) ELSE NULL END
			ELSE u.udf_value
		 END
		, dbo.fnadbuser()
		, GETDATE()			
	FROM #tmp_vol_split_deal_final_grp p
	INNER JOIN  #tmp_header th	
		ON th.deal_id = @process_id + '____' + CAST(p.rowid AS VARCHAR)
	LEFT JOIN #user_defined_deal_fields u 
		ON u.[source_deal_header_id] = p.templete_deal_id
	LEFT JOIN [dbo].[user_defined_deal_fields_template] uddft 
		ON uddft.template_id = th.template_id 
		AND uddft.udf_template_id = u.udf_template_id 
	LEFT JOIN  #user_defined_deal_fields uddf
		ON uddf.source_deal_header_id = th.source_deal_header_id 
		AND uddf.[udf_template_id] = u.[udf_template_id]
	WHERE p.include_rec = 1
		AND uddf.source_deal_header_id IS NULL
		AND NOT EXISTS(SELECT TOP 1 1 FROM #existing_deals e1 WHERE e1.source_deal_header_id = th.[source_deal_header_id]) --excluding duplicate insert of existing deals udf where error caused for unique key constraint 'UC_user_defined_deal_fields_source_deal_header_id'

	INSERT INTO #inserted_grp_path (
		source_deal_header_id
		, udf_template_id 
		, [udf_value]
	)
	SELECT	th.source_deal_header_id 
		,u.[udf_template_id]
		, CASE uddft.field_id
			WHEN -5614 THEN CAST((p.leg1_volume-p.leg2_volume) / p.leg1_volume AS VARCHAR)	 -- loss_factor
			WHEN @delivery_path_id THEN CAST(CAST(ISNULL(p.single_path_id,p.path_id) AS NUMERIC(28,0)) AS VARCHAR)
			WHEN @grp_delivery_path_id THEN CASE WHEN p.group_path='y' THEN CAST(CAST(p.path_id AS NUMERIC(28,0)) AS VARCHAR) ELSE NULL END
			ELSE u.udf_value
		END		
	FROM #tmp_vol_split_deal_final_grp p
	INNER JOIN #tmp_header th	
		ON th.deal_id = @process_id + '____' + CAST(p.rowid AS VARCHAR)
	LEFT JOIN #user_defined_deal_fields u 
		ON u.[source_deal_header_id] = p.templete_deal_id
	LEFT JOIN [dbo].[user_defined_deal_fields_template] uddft 
		ON uddft.template_id = th.template_id 
		AND uddft.udf_template_id = u.udf_template_id 
	LEFT JOIN  #user_defined_deal_fields uddf
		ON uddf.source_deal_header_id = th.source_deal_header_id 
		AND uddf.[udf_template_id] = u.[udf_template_id]
	WHERE p.include_rec=1 

	UPDATE sdd
		SET attribute1 = i.udf_value
	FROM #inserted_deal_detail idd
	INNER JOIN #inserted_grp_path i
		ON idd.source_deal_header_id = i.source_deal_header_id
	INNER JOIN source_deal_header sdh
		ON sdh.source_deal_header_id = i.source_deal_header_id
	INNER JOIN user_defined_deal_fields_template uddft
		ON sdh.template_id = uddft.template_id
		AND i.udf_template_id = uddft.udf_template_id
	INNER JOIN source_deal_detail sdd
		ON idd.source_deal_detail_id = sdd.source_deal_detail_id
	WHERE uddft.field_id = @grp_delivery_path_id -- -5606-- 

	DELETE udddf
	FROM #tmp_vol_split_deal_final_grp p 
	INNER JOIN  #tmp_header th	
		ON th.deal_id = @process_id + '____' + CAST(p.rowid AS VARCHAR)
	INNER JOIN	#inserted_deal_detail111 idd 
		ON th.source_deal_header_id = idd.source_deal_header_id 
		AND idd.is_insert = 1
	INNER JOIN source_deal_header sdh 
		ON sdh.source_deal_header_id = p.templete_deal_id
	INNER JOIN user_defined_deal_fields_template uddft 
		ON uddft.template_id = sdh.template_id
		AND uddft.leg = idd.leg	
		AND uddft.udf_type = 'd'
	INNER JOIN  #tmp_vol_split_deal_final_grp p_tra	
		ON p_tra.rowid = -1 * p.rowid  
		AND p.rowid < 0 
		AND p_tra.rowid > 0
	INNER JOIN static_data_value sdv 
		ON ISNULL(p_tra.description2, 168) = sdv.code 
		AND sdv.type_id = 32000
	INNER JOIN user_defined_deal_detail_fields udddf 
		ON udddf.source_deal_detail_id = idd.source_deal_detail_id
		AND udddf.udf_template_id = uddft.udf_template_id
	WHERE p.include_rec = 1  
		AND ISNULL(@reschedule, 0) = 0

	INSERT INTO user_defined_deal_detail_fields (
		source_deal_detail_id,
		udf_template_id,
		udf_value
	)
	SELECT DISTINCT idd.source_deal_detail_id
		, uddft.udf_template_id
		, CASE uddft.field_id				
			WHEN  @sdv_priority 
			THEN CAST(CAST(CASE WHEN p.storage_deal_type = 'i' THEN sdv.value_id ELSE uddft.default_value END AS NUMERIC(28, 0)) AS VARCHAR)
			ELSE uddft.default_value
		END default_value
	FROM #tmp_vol_split_deal_final_grp p 
	INNER JOIN  #tmp_header th	
		ON th.deal_id = @process_id + '____' + CAST(p.rowid AS VARCHAR)
	INNER JOIN	#inserted_deal_detail111 idd 
		ON th.source_deal_header_id = idd.source_deal_header_id 
		AND idd.is_insert = 1
	INNER JOIN source_deal_header sdh 
		ON sdh.source_deal_header_id = p.templete_deal_id
	INNER JOIN user_defined_deal_fields_template uddft 
		ON uddft.template_id = sdh.template_id
		AND uddft.leg = idd.leg	
		AND uddft.udf_type = 'd'
	LEFT JOIN  #tmp_vol_split_deal_final_grp p_tra	
		ON p_tra.rowid = -1 * p.rowid  
		AND p.rowid < 0 
		AND p_tra.rowid > 0
	LEFT JOIN static_data_value sdv 
		ON ISNULL(p_tra.description2, 168) = sdv.code 
		AND sdv.type_id = 32000
	WHERE p.include_rec = 1  
		AND ISNULL(@reschedule, 0) = 0

	UPDATE 	h 
		SET description2 = sdv.code   
	FROM  source_deal_header h
	INNER JOIN #tmp_vol_split_deal_final_grp p 
		ON h.deal_id = @process_id + '____' + CAST(p.rowid AS VARCHAR)
	INNER JOIN #collect_deals wth 
		ON ISNULL(p.single_path_id,p.path_id) = ISNULL(wth.single_path_id, wth.path_id) 
		AND  p.org_storage_deal_type = 'w'
		AND p.storage_deal_type = 'n' 
		AND wth.storage_deal_type='w'
	INNER JOIN  #tmp_header th_wth	
		ON th_wth.deal_id = @process_id + '____' + CAST(100000000 + wth.rowid AS VARCHAR)
	LEFT JOIN source_deal_header sdh1 
		ON sdh1.source_deal_header_id = th_wth.source_deal_header_id
	LEFT JOIN user_defined_deal_fields_template uddft1 
		ON uddft1.template_id = sdh1.template_id
		AND uddft1.leg = 1 
		AND uddft1.udf_type = 'd' 
		AND uddft1.field_id = @sdv_priority
	LEFT JOIN static_data_value sdv 
		ON sdv.value_id = uddft1.default_value
	WHERE p.include_rec = 1 
		AND ISNULL(@reschedule, 0) = 0

/*Update contract AND storage according to setup defined in storage contract*/
	UPDATE sdh
		SET sdh.contract_id = cg.contract_id
			,sdh.counterparty_id = ISNULL(cg.pipeline,sdh.counterparty_id)
	FROM [dbo].[source_deal_header] sdh
	INNER JOIN #tmp_header t 
		ON sdh.source_deal_header_id = t.source_deal_header_id
	INNER JOIN #tmp_vol_split_deal_final_grp p 
		ON sdh.deal_id = @process_id + '____' + CAST(p.rowid AS VARCHAR)
	INNER JOIN source_deal_type sdt
		ON sdt.source_deal_type_id = sdh.source_deal_type_id
	INNER JOIN source_deal_type sdt1
		ON sdt1.source_deal_type_id = sdh.deal_sub_type_type_id
	INNER JOIN general_assest_info_virtual_storage gaivs
		ON gaivs.general_assest_id = p.storage_asset_id
	INNER JOIN contract_group cg
		ON cg.contract_id = gaivs.agreement
	WHERE sdt.source_deal_type_name = 'Storage'
	AND sdt1.source_deal_type_name IN ('Injection','Withdrawal')
	
/*End of update*/

	UPDATE [dbo].[source_deal_header] 
		SET deal_id = CASE WHEN ISNULL(p.storage_deal_type,'n') = 'i' THEN 'INJC_' WHEN ISNULL(p.storage_deal_type,'n') = 'w' THEN 'WTHD_' ELSE 'SCHD_' END + CAST(h.source_deal_header_id AS VARCHAR) 
	FROM [dbo].[source_deal_header] h 
	INNER JOIN #tmp_header t 
		ON h.source_deal_header_id = t.source_deal_header_id
	INNER JOIN #tmp_vol_split_deal_final_grp p 
		ON h.deal_id = @process_id + '____' + CAST(p.rowid AS VARCHAR)
	
END   -- Insert/Update Deal data


DELETE a FROM #tmp_vol_split_deal  a
--INNER JOIN source_deal_detail sdd ON 
--sdd.source_deal_header_id=a.source_deal_header_id
--	AND sdd.leg=2 AND sdd.location_id<>a.from_location	
WHERE tot_volume = 0 or  is_transport_deal = 1

DELETE a  FROM #tmp_vol_split_deal_pre  a
--INNER JOIN source_deal_detail sdd ON 
--sdd.source_deal_header_id=a.source_deal_header_id
--	AND sdd.leg=2 AND sdd.location_id<>a.from_location	
WHERE  is_transport_deal = 1

DELETE a  FROM #tmp_vol_split_deal_del  a
--INNER JOIN source_deal_detail sdd ON 
--sdd.source_deal_header_id=a.source_deal_header_id
--	AND sdd.leg=1 AND sdd.location_id<>a.to_location	
WHERE  is_transport_deal = 1

DELETE a  FROM #tmp_vol_split_deal_del_pre  a
--INNER JOIN source_deal_detail sdd ON 
--sdd.source_deal_header_id=a.source_deal_header_id
--	AND sdd.leg=1 AND sdd.location_id<>a.to_location	
WHERE  is_transport_deal = 1

DELETE a FROM #tmp_vol_split_deal_bookout  a
--INNER JOIN source_deal_detail sdd ON 
--sdd.source_deal_header_id=a.source_deal_header_id
--	AND sdd.leg=1 AND sdd.location_id<>a.to_location	
WHERE  is_transport_deal = 1

DELETE a FROM #tmp_vol_split_deal_del_bookout  a
--INNER JOIN source_deal_detail sdd ON 
--sdd.source_deal_header_id=a.source_deal_header_id
--	AND sdd.leg=1 AND sdd.location_id<>a.to_location	
WHERE  is_transport_deal = 1

BEGIN -- Insert/Update Optimizer Data
	IF OBJECT_ID('tempdb..#inserted_optimizer_header') IS NOT NULL DROP TABLE #inserted_optimizer_header 
	CREATE TABLE #inserted_optimizer_header (
		optimizer_header_id INT
		, package_id VARCHAR(20) COLLATE DATABASE_DEFAULT
		, SLN_id INT
		, flow_date DATETIME
		, transport_deal_id INT
		, del_nom_volume NUMERIC(28,8)
		, rec_nom_volume  NUMERIC(28,8)
		, is_insert BIT
		, del_nom_volume_old NUMERIC(28,8)
		, rec_nom_volume_old  NUMERIC(28,8)
		, rec_nom_cycle5 NUMERIC(28,8) 
		, receipt_location_id INT
		, delivery_location_id INT
		, group_path_id INT
		, single_path_id INT
		, contract_id INT
	)

	UPDATE dbo.optimizer_header
	SET		rec_nom_volume = p.rec_nom_volume,
			del_nom_volume = p.del_nom_volume
			,group_path_id = CASE WHEN ISNULL(grp.group_path, 0) = 1 THEN NULL ELSE group_path_id END
	OUTPUT	inserted.optimizer_header_id
			, inserted.package_id
			, inserted.SLN_id
			, inserted.flow_date
			, inserted.transport_deal_id 
			, inserted.del_nom_volume
			, inserted.rec_nom_volume
			, 0 is_insert
			, deleted.del_nom_volume
			, deleted.rec_nom_volume
			, deleted.rec_nom_cycle5
			, inserted.receipt_location_id
			, inserted.delivery_location_id
			, inserted.group_path_id
			, inserted.single_path_id
			, inserted.contract_id
	INTO #inserted_optimizer_header ( --  SELECT * FROM #inserted_optimizer_header
		optimizer_header_id 
		, package_id
		, SLN_id
		, flow_date
		, transport_deal_id
		, del_nom_volume
		, rec_nom_volume
		, is_insert
		, del_nom_volume_old
		, rec_nom_volume_old
		, rec_nom_cycle5
		, receipt_location_id
		, delivery_location_id
		, group_path_id
		, single_path_id
		, contract_id
	)
	FROM dbo.optimizer_header oh
	INNER JOIN #tmp_header th 
		ON oh.transport_deal_id=th.source_deal_header_id
	CROSS APPLY	(
		SELECT
			rec_nom_volume = SUM(CASE WHEN leg = 1 THEN deal_volume ELSE 0 END),
			del_nom_volume = SUM(CASE WHEN leg = 2 THEN deal_volume ELSE 0 END)
		FROM source_deal_detail 
		WHERE source_deal_header_id = oh.transport_deal_id 
			AND term_start =oh.flow_date
	) p 
	OUTER APPLY	(
		SELECT MAX(1)  group_path  
		FROM #existing_deals 
		WHERE source_deal_header_id = th.source_deal_header_id
			AND group_path_id <> oh.group_path_id
	) grp
	WHERE p.rec_nom_volume IS NOT NULL

	INSERT INTO dbo.optimizer_header (
		flow_date 
		, transport_deal_id
		, package_id	
		, SLN_id	
		, receipt_location_id	
		, delivery_location_id
		, rec_nom_volume
		, del_nom_volume	
		, rec_nom_cycle5   -- temporary used for storage type : 0=schedule, 1= injection	, 2 =withdraw
		, group_path_id
		, single_path_id
		, contract_id			
	)
	OUTPUT inserted.optimizer_header_id
		, inserted.package_id
		, inserted.SLN_id
		, inserted.flow_date
		, inserted.transport_deal_id 
		, inserted.del_nom_volume
		, inserted.rec_nom_volume
		, 1 is_insert
		, NULL
		, NULL
		, inserted.rec_nom_cycle5
		, inserted.receipt_location_id
		, inserted.delivery_location_id
		, inserted.group_path_id
		, inserted.single_path_id
		, inserted.contract_id
	INTO #inserted_optimizer_header (
		optimizer_header_id 
		, package_id
		, SLN_id
		, flow_date
		, transport_deal_id
		, del_nom_volume
		, rec_nom_volume
		, is_insert
		, del_nom_volume_old
		, rec_nom_volume_old
		, rec_nom_cycle5
		, receipt_location_id
		, delivery_location_id 
		, group_path_id
		, single_path_id
		, contract_id
	)
	SELECT DISTINCT	idd.term_start 
		, p.source_deal_header_id transport_deal_id 
		, @package_id package_id 
		, p.rowid SLN_id 
		, leg1_loc_id receipt_location_id
		, leg2_loc_id delivery_location_id
		, ROUND(CASE WHEN idd.term_start BETWEEN @flow_date_from AND @flow_date_to THEN leg1_deal_volume ELSE NULL END, 0) rec_nom_volume
		, ROUND(CASE WHEN idd.term_start BETWEEN @flow_date_from AND @flow_date_to THEN leg2_deal_volume ELSE NULL END, 0)  del_nom_volume
		, CASE p.org_storage_deal_type WHEN 'i' THEN 1 WHEN 'w' THEN 2 ELSE 0 END rec_nom_cycle5
		, IIF(cp.single_path_id IS NULL, p.path_id, NULL) group_path_id
		, ISNULL(p.single_path_id, p.path_id)
		, ISNULL(p.single_contract_id, p.contract_id)
	FROM #tmp_vol_split_deal_final_grp p
	INNER JOIN #inserted_deal_detail111 idd 
		ON idd.source_deal_header_id = p.source_deal_header_id
		--AND idd.is_insert = 1 
		AND idd.leg = 1	  
	LEFT JOIN #common_path cp
		ON cp.single_path_id = p.single_path_id
	LEFT JOIN optimizer_header oh
		ON oh.transport_deal_id = p.source_deal_header_id
		AND oh.flow_date = idd.term_start
	WHERE p.include_rec = 1
		AND p.leg1_volume <> 0
		AND oh.transport_deal_id IS NULL
		AND p.storage_deal_type = 'n'
		
	BEGIN -- Generic logic
		BEGIN -- Upsteam(Received)
			-- 1st path IN group 

			IF @is_hourly_calc = 1
			BEGIN
				INSERT INTO  optimizer_detail_hour (
					optimizer_header_id
					, hr
					, period
					, flow_date
					, transport_deal_id
					, up_down_stream
					, source_deal_header_id
					, source_deal_detail_id
					, deal_volume
					, volume_used
					, group_path_id
					, single_path_id
					, contract_id 
				)
				SELECT i.optimizer_header_id 
					, d.hr
					, NULL [period]				
					, i.flow_date
					, i.transport_deal_id
					, IIF(d.rowid >=10000, 'D', 'U') up_down_stream
					, IIF(d.rowid >=10000, idd.source_deal_header_id, d.source_deal_header_id) source_deal_header_id
					, IIF(d.rowid >=10000, idd.source_deal_detail_id, d.source_deal_detail_id) source_deal_detail_id
					, 6002 --sdd.deal_volume
					, CASE WHEN i.flow_date BETWEEN p.flow_date_from AND p.flow_date_to THEN 
						d.available_volume
					 ELSE NULL END volume_used	
					, p.path_id
					, p.single_path_id	
					, ISNULL(p.single_contract_id, p.contract_id)
					--SELECT * FROM #tmp_vol_split_deal_final_grp SELECT * FROM #tmp_vol_split_deal
				FROM  #tmp_vol_split_deal_final_grp p
				INNER JOIN #inserted_optimizer_header i
					ON ISNULL(p.single_path_id, p.path_id) = COALESCE(i.single_path_id, p.single_path_id, p.path_id)
					AND p.path_id = ISNULL(i.group_path_id,p.path_id)
					AND p.serial_no = 1
					AND ISNULL(p.single_contract_id, p.contract_id)	 = i.contract_id
					AND p.leg1_loc_id = i.receipt_location_id
					AND p.leg2_loc_id = i.delivery_location_id
				INNER JOIN #tmp_vol_split_deal_hour d  -- select * from #tmp_vol_split_deal_hour
					ON ISNULL(p.description1, 'zzzzzzzz') = ISNULL(d.description1, 'zzzzzzzz') 
					AND ISNULL(p.description2, 168) = ISNULL(d.description2, 168)
					AND ISNULL(p.single_contract_id, p.contract_id) = d.[contract_id] 
					AND p.storage_deal_type = d.storage_deal_type
					AND  COALESCE(p.path_id, -1) = COALESCE(d.path_id, -1)
					AND ISNULL(d.single_path_id, d.path_id) = COALESCE(i.single_path_id, p.single_path_id, p.path_id)
					AND i.flow_date= d.term_start
					AND ISNULL(d.available_volume, 0) <> 0	
					AND d.from_location = i.receipt_location_id
					AND d.to_location = i.delivery_location_id
				LEFT JOIN #inserted_deal_detail111 idd 
					ON idd.source_deal_header_id = i.transport_deal_id 
					AND idd.term_start = i.flow_date 
					AND idd.leg = 2
					AND d.rowid >= 10000
				LEFT JOIN #inserted_deal_detail111 iddh
					ON iddh.source_deal_header_id = i.transport_deal_id 
					AND iddh.term_start = i.flow_date 
					AND iddh.leg = 1
				--INNER JOIN source_deal_detail_hour sddh
				--	ON sddh.source_deal_detail_id = iddh.source_deal_detail_id
			END

			INSERT INTO dbo.optimizer_detail	(
					optimizer_header_id,
					flow_date,	
					transport_deal_id,
					up_down_stream,
					source_deal_header_id,
					source_deal_detail_id,
					deal_volume,
					volume_used,
					group_path_id,
					single_path_id,
					contract_id
			)					
			SELECT i.optimizer_header_id 
				, i.flow_date
				, i.transport_deal_id
				, IIF(d.rowid >=10000, 'D', 'U') up_down_stream
				, IIF(d.rowid >=10000, idd.source_deal_header_id, d.source_deal_header_id) source_deal_header_id
				, IIF(d.rowid >=10000, idd.source_deal_detail_id, d.source_deal_detail_id) source_deal_detail_id
				, 6002 --sdd.deal_volume
				, CASE WHEN i.flow_date BETWEEN p.flow_date_from AND p.flow_date_to THEN 
					d.available_volume 
				 ELSE NULL END volume_used	
				, p.path_id
				, p.single_path_id	
				, ISNULL(p.single_contract_id, p.contract_id)
				--SELECT * FROM #tmp_vol_split_deal_final_grp SELECT * FROM #tmp_vol_split_deal
			FROM  #tmp_vol_split_deal_final_grp p
			INNER JOIN #inserted_optimizer_header i
				ON ISNULL(p.single_path_id, p.path_id) = COALESCE(i.single_path_id, p.single_path_id, p.path_id)
				AND p.path_id = ISNULL(i.group_path_id,p.path_id)
				AND p.serial_no = 1
				AND ISNULL(p.single_contract_id, p.contract_id)	 = i.contract_id
				AND p.leg1_loc_id = i.receipt_location_id
				AND p.leg2_loc_id = i.delivery_location_id
			INNER JOIN #tmp_vol_split_deal d 
				ON ISNULL(p.description1, 'zzzzzzzz') = ISNULL(d.description1, 'zzzzzzzz') 
				AND ISNULL(p.description2, 168) = ISNULL(d.description2, 168)
				AND ISNULL(p.single_contract_id, p.contract_id) = d.[contract_id] 
				AND p.storage_deal_type = d.storage_deal_type
				AND  COALESCE(p.path_id, -1) = COALESCE(d.path_id, -1)
				AND ISNULL(d.single_path_id, d.path_id) = COALESCE(i.single_path_id, p.single_path_id, p.path_id)
				AND i.flow_date= d.term_start
				AND ISNULL(d.available_volume, 0) <> 0	
				AND d.from_location = i.receipt_location_id
				AND d.to_location = i.delivery_location_id
			LEFT JOIN #inserted_deal_detail111 idd 
				ON idd.source_deal_header_id = i.transport_deal_id 
				AND idd.term_start = i.flow_date 
				AND idd.leg = 2
				AND d.rowid >= 10000

			--UPDATE od
			--	SET volume_used = a.volume_used	
			
			--FROM optimizer_detail od
			--CROSS APPLY(
			--	SELECT  SUM(odh.volume_used) volume_used
			--	FROM optimizer_detail_hour odh
			--	WHERE odh.optimizer_header_id = od.optimizer_header_id
			--		AND odh.flow_date = od.flow_date
			--		AND odh.transport_deal_id = od.transport_deal_id
			--		AND odh.up_down_stream = od.up_down_stream
			--		AND odh.source_deal_header_id = od.source_deal_header_id
			--		AND odh.source_deal_detail_id = od.source_deal_detail_id	

			--	GROUP BY odh.optimizer_header_id,odh.flow_date,odh.transport_deal_id,odh.up_down_stream,odh.source_deal_header_id,odh.source_deal_detail_id
			--) a
			--INNER JOIN #inserted_optimizer_header ioh
			--	ON ioh.optimizer_header_id = od.optimizer_header_id

			-- non 1st path IN group 
			INSERT INTO dbo.optimizer_detail (
				optimizer_header_id,
				flow_date,	
				transport_deal_id,
				up_down_stream,
				source_deal_header_id,
				source_deal_detail_id,
				deal_volume,
				volume_used,
				group_path_id,
				single_path_id,
				contract_id
			)	
			SELECT DISTINCT i.optimizer_header_id 
				, i.flow_date
				, i.transport_deal_id
				, 'U' up_down_stream
				, idd.source_deal_header_id
				, idd.source_deal_detail_id
				, 6001 --sdd.deal_volume
				, CASE WHEN i.flow_date BETWEEN @flow_date_from AND @flow_date_to THEN 
					p.leg1_volume
				ELSE NULL END volume_used
				, p.path_id
				, p.single_path_id		
				, ISNULL(p.single_contract_id, p.contract_id)
				--SELECT *
			FROM  #tmp_vol_split_deal_final_grp p
			INNER JOIN #inserted_optimizer_header i
				ON ISNULL(p.single_path_id, p.path_id) = COALESCE(i.single_path_id, p.single_path_id, p.path_id)
				AND p.path_id = ISNULL(i.group_path_id, p.path_id)
				AND p.serial_no <> 1 
				AND ISNULL(p.single_contract_id, p.contract_id) = i.contract_id
				AND p.leg1_loc_id = i.receipt_location_id
				AND p.leg2_loc_id = i.delivery_location_id
			INNER JOIN #tmp_vol_split_deal_final_grp p1
				ON p.rowid  = p1.rowid + 1  	
				AND p1.storage_deal_type = 'n'					
			LEFT JOIN #inserted_optimizer_header i1 
				ON i1.single_path_id = p1.single_path_id
				AND ISNULL(i1.group_path_id, p1.path_id) = p1.path_id -- identify common path  (NULL common AND NOT NULL non common
				AND i1.flow_date = i.flow_date	
				AND p1.leg1_loc_id = i1.receipt_location_id
				AND p1.leg2_loc_id = i1.delivery_location_id
			LEFT JOIN #inserted_deal_detail111 idd 
				ON idd.source_deal_header_id = i1.transport_deal_id 
				AND idd.term_start = i1.flow_date 
				AND idd.leg = 2
			WHERE i1.flow_date IS NOT NULL
						
			--(DownStream) non last path IN group 
			INSERT INTO dbo.optimizer_detail (
				optimizer_header_id,
				flow_date,	
				transport_deal_id,
				up_down_stream,
				source_deal_header_id,
				source_deal_detail_id,
				deal_volume,
				volume_used,
				group_path_id,
				single_path_id,
				contract_id 
			)	
			SELECT DISTINCT i.optimizer_header_id 
				, i.flow_date
				, i.transport_deal_id
				, 'D' up_down_stream
				, idd.source_deal_header_id
				, idd.source_deal_detail_id
				, 7001 --sdd.deal_volume
				, CASE WHEN i.flow_date BETWEEN @flow_date_from AND @flow_date_to 
				  THEN p.leg2_volume
				  ELSE NULL 
				  END volume_used
				, p.path_id
				, p.single_path_id
				, ISNULL(p.single_contract_id, p.contract_id)		
				--SELECT *
			FROM #tmp_vol_split_deal_final_grp p
			INNER JOIN #inserted_optimizer_header i
				ON  ISNULL(p.single_path_id, p.path_id) = COALESCE(i.single_path_id, p.single_path_id, p.path_id)
				AND p.path_id = ISNULL(i.group_path_id,p.path_id)
				AND p.serial_no_desc <> 1 
				AND ISNULL(p.single_contract_id, p.contract_id) = i.contract_id
				AND p.leg1_loc_id = i.receipt_location_id
				AND p.leg2_loc_id = i.delivery_location_id
				AND p.storage_deal_type = 'n'
			INNER JOIN #tmp_vol_split_deal_final_grp p1
				ON p.rowid + 1 = p1.rowid  	
				AND p1.storage_deal_type = 'n'					
			LEFT JOIN #inserted_optimizer_header i1 
				ON i1.single_path_id = p1.single_path_id
				AND ISNULL(i1.group_path_id, p1.path_id) = p1.path_id
				AND p1.leg1_loc_id = i1.receipt_location_id
				AND p1.leg2_loc_id = i1.delivery_location_id
				AND i1.flow_date = i.flow_date	
			LEFT JOIN  #inserted_deal_detail111 idd 
				ON idd.source_deal_header_id = i1.transport_deal_id 
				AND idd.term_start = i1.flow_date 
				AND idd.leg = 2
			WHERE i1.flow_date IS NOT NULL

			--(DownStream) last path IN group
			INSERT INTO dbo.optimizer_detail (
				optimizer_header_id,
				flow_date,	
				transport_deal_id,
				up_down_stream,
				source_deal_header_id,
				source_deal_detail_id,
				deal_volume,
				volume_used,
				group_path_id,
				single_path_id,
				contract_id
			)	
			SELECT DISTINCT i.optimizer_header_id 
				, i.flow_date
				, i.transport_deal_id
				, IIF(d.rowid >= 10000, 'U', 'D') up_down_stream
				, IIF(d.rowid >= 10000, d1.source_deal_header_id, idd.source_deal_header_id) source_deal_header_id
				, IIF(d.rowid >= 10000, d1.source_deal_detail_id, idd.source_deal_detail_id) source_deal_detail_id
				, 7002 --sdd.deal_volume
				, CASE WHEN i.flow_date BETWEEN  p.flow_date_from AND p.flow_date_to
					THEN IIF(d.rowid >=10000, d1.available_volume,  p.leg2_volume)
					ELSE NULL 
					END volume_used
				, p.path_id
				, p.single_path_id	
				, ISNULL(p.single_contract_id, p.contract_id) --	SELECT * --FROM #tmp_vol_split_deal_final_grp SELECT * FROM #inserted_optimizer_header SELECT * FROM #inserted_deal_detail111
			FROM #tmp_vol_split_deal_final_grp p
			INNER JOIN 	#inserted_optimizer_header i
				ON ISNULL(p.single_path_id, p.path_id) = COALESCE(i.single_path_id, p.single_path_id, p.path_id)
				AND p.path_id = ISNULL(i.group_path_id,p.path_id)
				AND p.serial_no_desc = 1 
				AND ISNULL(p.single_contract_id, p.contract_id) = i.contract_id
				AND p.leg1_loc_id = i.receipt_location_id
				AND p.leg2_loc_id = i.delivery_location_id
			INNER JOIN #inserted_deal_detail111 idd  -- SELECT * FROM #inserted_deal_detail111
				ON idd.source_deal_header_id = i.transport_deal_id 
				AND idd.term_start = i.flow_date 
				AND idd.leg = 2
			LEFT JOIN #tmp_vol_split_deal d
				ON d.from_location = p.leg1_loc_id
				AND d.to_location = p.leg2_loc_id
				AND p.path_id = -99 AND d.rowid >=10000
				AND i.flow_date BETWEEN  d.term_start AND d.term_end
				AND d.available_volume <> 0
			OUTER APPLY 
			( 
				SELECT  TOP(1) master_rowid  
				FROM #tmp_vol_split_deal_del_pre 
				WHERE actual_available_volume>0
					AND to_location= d.to_location
			) box
			LEFT JOIN  #tmp_vol_split_deal_del_pre d1
			ON d.to_location = d1.to_location
				AND p.path_id = -99
				AND d1.actual_available_volume > 0
				AND d1.master_rowid = box.master_rowid
				AND d1.available_volume <> 0
			WHERE NOT EXISTS(
								SELECT TOP 1 1 
								FROM #tmp_vol_split_deal_final_grp t1 
								WHERE t1.to_location = p.to_location 
									AND t1.storage_deal_type = 'i'
							) --exclude downstream of schd deal which has injection deal created.
			
			IF @is_hourly_calc = 1
			BEGIN
				INSERT INTO  optimizer_detail_hour (
					optimizer_header_id
					, hr
					, period
					, flow_date
					, transport_deal_id
					, up_down_stream
					, source_deal_header_id
					, source_deal_detail_id
					, deal_volume
					, volume_used
					, group_path_id
					, single_path_id
					, contract_id 
				)
				SELECT i.optimizer_header_id 
					, ISNULL(d.hr, r.hr) hr
					, NULL [period]				
					, i.flow_date
					, i.transport_deal_id
					, IIF(ISNULL(d.rowid, r.rowid) >=10000, 'U', 'D') up_down_stream
					, IIF(ISNULL(d.rowid, r.rowid) >=10000, ISNULL(d.source_deal_header_id, r.source_deal_header_id), iddh.source_deal_header_id ) source_deal_header_id
					, IIF(ISNULL(d.rowid, r.rowid) >=10000, ISNULL(d.source_deal_detail_id, r.source_deal_detail_id), iddh.source_deal_detail_id) source_deal_detail_id
					, 7002 --sdd.deal_volume
					--, SUM( 
					--	CASE WHEN i.flow_date BETWEEN p.flow_date_from AND p.flow_date_to THEN ISNULL(r.available_volume, d.available_volume)
					--		 ELSE NULL 
					--	END
					--  ) 
					, MAX( 
						CASE WHEN i.flow_date BETWEEN p.flow_date_from AND p.flow_date_to THEN ISNULL(r.tot_volume, d.tot_volume)
							 ELSE NULL 
						END
					  )
					  [volume_used]
					, p.path_id
					, p.single_path_id	
					, ISNULL(p.single_contract_id, p.contract_id)
					--SELECT * --FROM #tmp_vol_split_deal_final_grp SELECT * FROM #tmp_vol_split_deal
			 	FROM  #tmp_vol_split_deal_final_grp p
				INNER JOIN #inserted_optimizer_header i -- SELECT * FROM #inserted_optimizer_header
					ON ISNULL(p.single_path_id, p.path_id) = COALESCE(i.single_path_id, p.single_path_id, p.path_id)
					AND p.path_id = ISNULL(i.group_path_id,p.path_id)
					AND p.serial_no = 1
					AND ISNULL(p.single_contract_id, p.contract_id)	 = i.contract_id
					AND p.leg1_loc_id = i.receipt_location_id
					AND p.leg2_loc_id = i.delivery_location_id
				LEFT JOIN #tmp_vol_split_deal_del_hour d  --select * from  #tmp_vol_split_deal_del_hour d 
					ON ISNULL(p.description1, 'zzzzzzzz') = ISNULL(d.description1, 'zzzzzzzz') 
					AND ISNULL(p.description2, 168) = ISNULL(d.description2, 168)
					AND ISNULL(p.single_contract_id, p.contract_id) = d.[contract_id] 
					AND p.storage_deal_type = d.storage_deal_type
					AND  COALESCE(p.path_id, -1) = COALESCE(d.path_id, -1)
					AND ISNULL(d.single_path_id, d.path_id) = COALESCE(i.single_path_id, p.single_path_id, p.path_id)
					AND i.flow_date= d.term_start
					AND ISNULL(d.available_volume, 0) <> 0	
					AND d.from_location = i.receipt_location_id
					AND d.to_location = i.delivery_location_id
				LEFT JOIN #tmp_vol_split_deal_hour r  -- select * from #tmp_vol_split_deal_hour
					ON ISNULL(p.description1, 'zzzzzzzz') = ISNULL(r.description1, 'zzzzzzzz') 
					AND ISNULL(p.description2, 168) = ISNULL(r.description2, 168)
					AND ISNULL(p.single_contract_id, p.contract_id) = r.[contract_id] 
					AND p.storage_deal_type = r.storage_deal_type
					AND COALESCE(p.path_id, -1) = COALESCE(r.path_id, -1)
					AND ISNULL(r.single_path_id, r.path_id) = COALESCE(i.single_path_id, p.single_path_id, p.path_id)
					AND i.flow_date= r.term_start
					AND ISNULL(r.available_volume, 0) <> 0	
					AND r.from_location = i.receipt_location_id
					AND r.to_location = i.delivery_location_id
					AND COALESCE( r.hr, d.hr, -1) = COALESCE( d.hr, r.hr, -1) 
				LEFT JOIN #inserted_deal_detail111 idd  --select * from #inserted_deal_detail111
					ON idd.source_deal_header_id = i.transport_deal_id 
					AND idd.term_start = i.flow_date 
					AND idd.leg = 2
					AND ISNULL(d.rowid,r.rowid) >= 10000
				LEFT JOIN #inserted_deal_detail111 iddh --  select * from #inserted_deal_detail111
					ON iddh.source_deal_header_id = i.transport_deal_id 
					AND iddh.term_start = i.flow_date 
					AND iddh.leg = 2
				WHERE ISNULL(d.hr,r.hr) IS NOT NULL
					AND NOT EXISTS(
								SELECT TOP 1 1 
								FROM #tmp_vol_split_deal_final_grp t1 
								WHERE t1.to_location = p.to_location 
									AND t1.storage_deal_type = 'i'
							) --exclude downstream of schd deal which has injection deal created --storage injc and withdrawal will be inserted in later block  
				GROUP BY i.optimizer_header_id 
					, ISNULL(d.hr, r.hr)
					, i.flow_date
					, i.transport_deal_id
					, IIF(ISNULL(d.rowid, r.rowid) >=10000, 'U', 'D')
					, IIF(ISNULL(d.rowid, r.rowid) >=10000, ISNULL(d.source_deal_header_id, r.source_deal_header_id), iddh.source_deal_header_id)
					, IIF(ISNULL(d.rowid, r.rowid) >=10000, ISNULL(d.source_deal_detail_id, r.source_deal_detail_id), iddh.source_deal_detail_id)
					, p.path_id
					, p.single_path_id	
					, ISNULL(p.single_contract_id, p.contract_id)
			END

			--injection: delivered
			IF @is_hourly_calc = 1
			BEGIN
				INSERT INTO  optimizer_detail_hour (
						optimizer_header_id
						, hr
						, period
						, flow_date
						, transport_deal_id
						, up_down_stream
						, source_deal_header_id
						, source_deal_detail_id
						, deal_volume
						, volume_used
						, group_path_id
						, single_path_id
						, contract_id 
				)
				SELECT i.optimizer_header_id
					, h.hr
					, NULL period
					, i.flow_date
					, i.transport_deal_id
					, 'D' up_down_stream
					, idd.source_deal_header_id
					, idd.source_deal_detail_id
					, 6013 
					, h.delivery_volume
					, p.path_id
					, p.single_path_id
					, ISNULL(p.single_contract_id, p.contract_id)	
					-- select *	
				FROM #tmp_vol_split_deal_del_hour h
				INNER JOIN  #tmp_vol_split_deal_final_grp p
					ON ISNULL(h.single_path_id, h.path_id) =  ISNULL(p.single_path_id,p.path_id)				
					AND h.to_location = p.to_location
					--AND ISNULL(h.available_volume, 0) <> 0	
				INNER JOIN #inserted_optimizer_header i
					ON ISNULL(p.single_path_id, p.path_id) = COALESCE(i.single_path_id, p.single_path_id, p.path_id)
					AND p.path_id = ISNULL(i.group_path_id, p.path_id)
					AND p.leg2_loc_id = i.delivery_location_id
					AND p.flow_date_from = i.flow_date
				CROSS APPLY (
					 SELECT TOP(1) * 
					 FROM #tmp_vol_split_deal_final_grp 
					 WHERE to_location = p.to_location  
						AND path_id = p.path_id
						AND storage_deal_type = 'i' 
						AND p.storage_deal_type <> storage_deal_type	
						AND p.org_storage_deal_type = 'i'
						AND org_storage_deal_type = p.org_storage_deal_type
						AND ISNULL(p.description1,'zzzzzzzz') = ISNULL(description1,'zzzzzzzz') 
						AND ISNULL(p.description2,'zzzzzzzz') = ISNULL(description2,'zzzzzzzz')
						AND first_dom = p.first_dom
					ORDER BY serial_no
				) p_inj
				INNER JOIN #tmp_header th_inj	
					ON (th_inj.deal_id = @process_id + '____' + CAST(p_inj.rowid AS VARCHAR) 
						OR th_inj.source_deal_header_id = p_inj.source_deal_header_id)
				LEFT JOIN  #inserted_deal_detail111 idd 
					ON idd.source_deal_header_id = th_inj.source_deal_header_id
					AND i.flow_date = idd.term_start 
				WHERE p.org_storage_deal_type = 'i'
			END

			INSERT INTO dbo.optimizer_detail(
				optimizer_header_id,
				flow_date,	
				transport_deal_id,
				up_down_stream,
				source_deal_header_id,
				source_deal_detail_id,
				deal_volume,
				volume_used,
				group_path_id,
				single_path_id,
				contract_id
			)	
			SELECT  i.optimizer_header_id ,idd.term_start,i.transport_deal_id
					, 'D'  up_down_stream
					, idd.source_deal_header_id
					, idd.source_deal_detail_id
					, 6013 --sdd.deal_volume
					, CASE WHEN idd.term_start BETWEEN @flow_date_from AND @flow_date_to THEN i.del_nom_volume - ISNULL(del_nom_volume_old, 0) ELSE NULL END volume_used
					, p.path_id
					, p.single_path_id	
					, ISNULL(p.single_contract_id, p.contract_id)
					--select *
			FROM #tmp_vol_split_deal_final_grp p					
			INNER JOIN  #inserted_optimizer_header i 
				ON ISNULL(p.single_path_id, p.path_id) = COALESCE(i.single_path_id, p.single_path_id, p.path_id)
				AND p.path_id = ISNULL(i.group_path_id, p.path_id)
				AND p.leg2_loc_id = i.delivery_location_id
			CROSS APPLY (
				 SELECT TOP(1) * 
				 FROM #tmp_vol_split_deal_final_grp 
				 WHERE to_location = p.to_location  
					AND path_id = p.path_id
					AND storage_deal_type = 'i' 
					AND p.storage_deal_type <> storage_deal_type	
					AND p.org_storage_deal_type = 'i'
					AND org_storage_deal_type = p.org_storage_deal_type
					AND ISNULL(p.description1,'zzzzzzzz') = ISNULL(description1,'zzzzzzzz') 
					AND ISNULL(p.description2,'zzzzzzzz') = ISNULL(description2,'zzzzzzzz')
					AND first_dom = p.first_dom
				ORDER BY serial_no
			) p_inj
			INNER JOIN #tmp_header th_inj	
				ON (th_inj.deal_id = @process_id + '____' + CAST(p_inj.rowid AS VARCHAR) 
					OR th_inj.source_deal_header_id = p_inj.source_deal_header_id)
			LEFT JOIN  #inserted_deal_detail111 idd 
				ON idd.source_deal_header_id = th_inj.source_deal_header_id
				AND i.flow_date = idd.term_start 
				--AND idd.is_insert = 1
			WHERE p.org_storage_deal_type = 'i'

	
			--withdrawal: received
			IF @is_hourly_calc = 1
			BEGIN
				INSERT INTO  optimizer_detail_hour (
						optimizer_header_id
						, hr
						, period
						, flow_date
						, transport_deal_id
						, up_down_stream
						, source_deal_header_id
						, source_deal_detail_id
						, deal_volume
						, volume_used
						, group_path_id
						, single_path_id
						, contract_id 
				)
				SELECT i.optimizer_header_id
					, h.hr
					, NULL period
					, i.flow_date
					, i.transport_deal_id
					, 'U' up_down_stream
					, idd.source_deal_header_id
					, idd.source_deal_detail_id
					, 6014 
					, h.delivery_volume
					, p.path_id
					, p.single_path_id
					, ISNULL(p.single_contract_id, p.contract_id)		
				FROM #tmp_vol_split_deal_del_hour h
				INNER JOIN  #tmp_vol_split_deal_final_grp p
					ON ISNULL(h.single_path_id, h.path_id) =  ISNULL(p.single_path_id,p.path_id)				
					AND h.from_location = p.leg1_loc_id
					AND ISNULL(h.available_volume, 0) <> 0	
				INNER JOIN #inserted_optimizer_header i 
					ON ISNULL(p.single_path_id, p.path_id) = COALESCE(i.single_path_id, p.single_path_id, p.path_id)
					AND p.path_id = ISNULL(i.group_path_id, p.path_id)
					AND p.leg1_loc_id = i.receipt_location_id
					AND p.flow_date_from = i.flow_date
   				OUTER APPLY (
					SELECT TOP(1) * 
					FROM #tmp_vol_split_deal_final_grp  
					WHERE leg1_loc_id = p.leg1_loc_id  
						AND path_id = p.path_id
						AND storage_deal_type = 'w' 
						AND p.storage_deal_type <> storage_deal_type
						AND org_storage_deal_type = p.org_storage_deal_type
						AND ISNULL(p.description1, 'zzzzzzzz') = ISNULL(description1, 'zzzzzzzz') 
						AND ISNULL(p.description2, 'zzzzzzzz') = ISNULL(description2, 'zzzzzzzz')
						AND first_dom = p.first_dom
					ORDER BY serial_no DESC
				) p_wth
				LEFT JOIN  #tmp_header th_wth	
					ON (th_wth.deal_id = @process_id + '____' + CAST(p_wth.rowid AS VARCHAR)
					OR th_wth.source_deal_header_id = p_wth.source_deal_header_id) -- Added for reschedule
				INNER JOIN #inserted_deal_detail111 idd 
					ON idd.source_deal_header_id = th_wth.source_deal_header_id	  
					AND idd.leg = 1 
					AND i.flow_date = idd.term_start 
				WHERE p.org_storage_deal_type = 'w'
			END

			INSERT INTO dbo.optimizer_detail (
				optimizer_header_id,
				flow_date,	
				transport_deal_id,
				up_down_stream,
				source_deal_header_id,
				source_deal_detail_id,
				deal_volume,
				volume_used,
				group_path_id,
				single_path_id,
				contract_id
			)	
			SELECT  i.optimizer_header_id ,idd.term_start,i.transport_deal_id
				, 'U'   up_down_stream
				, idd.source_deal_header_id
				, idd.source_deal_detail_id
				, 6014 --sdd.deal_volume
				, CASE WHEN idd.term_start BETWEEN @flow_date_from AND @flow_date_to THEN i.rec_nom_volume - ISNULL(i.rec_nom_volume_old, 0)  ELSE NULL END  volume_used
				, p.path_id
				, p.single_path_id	
				, ISNULL(p.single_contract_id, p.contract_id)
			FROM #tmp_vol_split_deal_final_grp p
			INNER JOIN #inserted_optimizer_header i 
				ON ISNULL(p.single_path_id, p.path_id) = COALESCE(i.single_path_id, p.single_path_id, p.path_id)
				AND p.path_id = ISNULL(i.group_path_id, p.path_id)
				AND p.leg1_loc_id = i.receipt_location_id
   			OUTER APPLY (
				SELECT TOP(1) * 
				FROM #tmp_vol_split_deal_final_grp  
				WHERE leg1_loc_id = p.leg1_loc_id  
					AND path_id = p.path_id
					AND storage_deal_type = 'w' 
					AND p.storage_deal_type <> storage_deal_type
					AND org_storage_deal_type = p.org_storage_deal_type
					AND ISNULL(p.description1, 'zzzzzzzz') = ISNULL(description1, 'zzzzzzzz') 
					AND ISNULL(p.description2, 'zzzzzzzz') = ISNULL(description2, 'zzzzzzzz')
					AND first_dom = p.first_dom
				ORDER BY serial_no DESC
			) p_wth
			LEFT JOIN  #tmp_header th_wth	
				ON (th_wth.deal_id = @process_id + '____' + CAST(p_wth.rowid AS VARCHAR)
				OR th_wth.source_deal_header_id = p_wth.source_deal_header_id) -- Added for reschedule
			INNER JOIN #inserted_deal_detail111 idd 
				ON idd.source_deal_header_id = th_wth.source_deal_header_id	  
				AND idd.leg = 1 
				AND i.flow_date = idd.term_start 
				--AND idd.is_insert = 1
			WHERE --p.storage_deal_type = 'n'	AND
				 p.org_storage_deal_type = 'w'

		


			INSERT INTO dbo.optimizer_detail (
				optimizer_header_id,
				flow_date,	
				transport_deal_id,
				up_down_stream,
				source_deal_header_id,
				source_deal_detail_id,
				deal_volume,
				volume_used,
				group_path_id,
				single_path_id,
				contract_id			
			)	
			SELECT DISTINCT od.optimizer_header_id
				, od.flow_date
				, od.transport_deal_id
				, 'U'
				, NULL
				, NULL
				, 7000
				, o.over_vol 
				, o.path_id
				, o.single_path_id
				, o.contract_id
			FROM #inserted_optimizer_header h
			INNER JOIN optimizer_detail od 
				ON h.transport_deal_id = od.transport_deal_id
			INNER JOIN #over_sch_vol o
				ON o.from_location = h.receipt_location_id
				AND o.to_location = h.delivery_location_id
				AND o.flow_date = od.flow_date

			IF @is_hourly_calc = 1
			BEGIN
			INSERT INTO  optimizer_detail_hour (
					optimizer_header_id
					, hr
					, period
					, flow_date
					, transport_deal_id
					, up_down_stream
					, source_deal_header_id
					, source_deal_detail_id
					, deal_volume
					, volume_used
					, group_path_id
					, single_path_id
					, contract_id 
				)
			SELECT DISTINCT od.optimizer_header_id
				, o.hr
				, NULL period
				, od.flow_date
				, od.transport_deal_id
				, 'U'
				, NULL
				, NULL
				, 7000
				, o.over_vol 
				, o.path_id
				, o.single_path_id
				, o.contract_id
			FROM #inserted_optimizer_header h
			INNER JOIN optimizer_detail od 
				ON h.transport_deal_id = od.transport_deal_id
			INNER JOIN #over_sch_vol_hour o
				ON o.from_location = h.receipt_location_id
				AND o.to_location = h.delivery_location_id
				AND o.flow_date = od.flow_date

				
			END
		END

		UPDATE od
			SET deal_volume = NULL
		FROM #inserted_optimizer_header i 
		INNER JOIN dbo.optimizer_detail od 
			ON i.optimizer_header_id = od.optimizer_header_id  
			AND i.transport_deal_id = od.transport_deal_id
			AND i.flow_date = od.flow_date
		WHERE od.deal_volume IS NOT NULL

		UPDATE odh
			SET deal_volume = NULL
		FROM #inserted_optimizer_header i 
		INNER JOIN dbo.optimizer_detail_hour odh
			ON i.optimizer_header_id = odh.optimizer_header_id  
			AND i.transport_deal_id = odh.transport_deal_id
			AND i.flow_date = odh.flow_date
		WHERE odh.deal_volume IS NOT NULL


	END -- Generic logic
END -- Insert/Update Optimizer Data	

UPDATE optimizer_HEADER 
	SET group_path_id=od.group_path_id 
FROM
(
	SELECT optimizer_header_id
			, flow_date
			, single_path_id
			, contract_id
	FROM optimizer_HEADER 
	WHERE group_path_id IS NULL
) oh
CROSS APPLY (
	SELECT  MAX(group_path_id) group_path_id  
	FROM optimizer_detail  
	WHERE single_path_id = oh.single_path_id
		AND contract_id = oh.contract_id
		AND optimizer_header_id = oh.optimizer_header_id
		AND volume_used <> 0
		AND up_down_stream = 'D'
	GROUP BY optimizer_header_id
	HAVING COUNT(1) < 2
) od



IF EXISTS(SELECT 1 FROM #inserted_optimizer_header)
BEGIN	


	IF @is_hourly_calc = 1
	BEGIN
		INSERT INTO optimizer_detail_downstream_hour(  
			optimizer_header_id
			, hr
			, period
			, flow_date
			, transport_deal_id
			, source_deal_header_id
			, source_deal_detail_id
			, deal_volume
			, group_path_id
			, single_path_id
			, contract_id
		)
		SELECT i.optimizer_header_id
			, dvry.hr hr
			, NULL [period]
			, i.flow_date
			, i.transport_deal_id		
			, ISNULL(inj.source_deal_header_id,dvry.source_deal_header_id)
			, ISNULL(inj.source_deal_detail_id,dvry.source_deal_detail_id)
			, ROUND(MAX(CASE WHEN dvry.available_volume <= dvry.tot_volume 
						THEN IIF(p_stor.storage_deal_type = 'i' --OR @call_from = 'flow_auto'
									, dvry.tot_volume, dvry.available_volume)
						ELSE dvry.tot_volume END), 4)	
			, p.path_id
			, i.single_path_id
			, i.contract_id --	SELECT * FROM #inserted_optimizer_header SELECT * FROM #inserted_deal_detail111
		FROM #tmp_vol_split_deal_final_grp p	
		INNER JOIN #inserted_optimizer_header i 
			ON ISNULL(p.single_contract_id, p.contract_id)=i.contract_id 
			AND p.single_path_id=i.single_path_id
			AND p.path_id=ISNULL(i.group_path_id,p.path_id)
			AND	p.storage_deal_type='n' 
		INNER JOIN #tmp_vol_split_deal_del_hour dvry 
			ON ISNULL(p.path_id, -1) = ISNULL(dvry.path_id, -1)
			AND ((p.leg1_loc_id = dvry.from_location ) OR (dvry.storage_deal_type = 'i' AND p.leg2_loc_id = dvry.from_location))
			AND p.leg2_loc_id = dvry.to_location
			--AND ISNULL(p.single_contract_id, p.contract_id) = dvry.contract_id
			AND i.flow_date=dvry.term_start 
			AND (ISNULL(dvry.available_volume, 0) <> 0	OR dvry.org_storage_deal_type = 'i' --OR @call_from = 'flow_auto'
			)
		OUTER APPLY (
			SELECT  idd1.source_deal_detail_id, idd1.source_deal_header_id
			FROM #inserted_deal_detail111 idd1
			INNER JOIN source_deal_header sdh 
				ON sdh.source_deal_header_id = idd1.source_deal_header_id
				AND (sdh.deal_id LIKE 'INJC[_]%' )--or sdh.deal_id LIKE 'WTHD[_]%')
			WHERE idd1.term_start = i.flow_date
				AND idd1.group_path_id = i.group_path_id
				AND idd1.single_path_id = i.single_path_id
				AND idd1.leg = 1
		) inj
		LEFT JOIN #tmp_vol_split_deal_final_grp p_stor
			ON p_stor.source_deal_header_id = inj.source_deal_header_id		
		LEFT JOIN #inserted_deal_detail111 idd 
				ON idd.term_start = i.flow_date 
				AND idd.leg = 2
				AND idd.source_deal_header_id = p.source_deal_header_id
		--INNER JOIN source_deal_detail_hour sddh
		--	ON sddh.source_deal_detail_id = idd.source_deal_detail_id
		GROUP BY i.optimizer_header_id
				, i.flow_date
				, i.transport_deal_id 
				, ISNULL(inj.source_deal_header_id, dvry.source_deal_header_id)
				, ISNULL(inj.source_deal_detail_id, dvry.source_deal_detail_id)
				, p.path_id
				, i.single_path_id
				, i.contract_id
				, dvry.hr
	END

	INSERT INTO dbo.optimizer_detail_downstream(
		optimizer_header_id
		, flow_date
		, transport_deal_id
		, source_deal_header_id
		, source_deal_detail_id
		, deal_volume	
		, group_path_id
		, single_path_id
		, contract_id
	)
	SELECT i.optimizer_header_id
		, i.flow_date
		, i.transport_deal_id
		--, inj.source_deal_header_id,dvry.source_deal_header_id
		, ISNULL(inj.source_deal_header_id,dvry.source_deal_header_id)
		, ISNULL(inj.source_deal_detail_id,dvry.source_deal_detail_id)
		
		, ROUND(MAX(CASE WHEN dvry.available_volume <= dvry.tot_volume 
					THEN IIF(p_stor.storage_deal_type = 'i' --OR @call_from = 'flow_auto'
								, dvry.tot_volume, dvry.available_volume)
					ELSE dvry.tot_volume END), 4)	
		, p.path_id
		, i.single_path_id
		, i.contract_id --	SELECT * FROM #inserted_optimizer_header SELECT * FROM #inserted_deal_detail111
	FROM #tmp_vol_split_deal_final_grp p	
	INNER JOIN #inserted_optimizer_header i 
		ON ISNULL(p.single_contract_id, p.contract_id)=i.contract_id 
		AND p.single_path_id=i.single_path_id
		AND p.path_id=ISNULL(i.group_path_id,p.path_id)
		AND	p.storage_deal_type='n' 
	INNER JOIN #tmp_vol_split_deal_del dvry
		ON ISNULL(p.path_id, -1) = ISNULL(dvry.path_id, -1)
		AND p.leg1_loc_id = dvry.from_location 
		AND p.leg2_loc_id = dvry.to_location
		--AND ISNULL(p.single_contract_id, p.contract_id) = dvry.contract_id
		AND i.flow_date=dvry.term_start 
		AND (ISNULL(dvry.available_volume, 0) <> 0	
			OR dvry.org_storage_deal_type = 'i' 
			--OR @call_from = 'flow_auto'
			)
	OUTER APPLY (
		SELECT  idd1.source_deal_detail_id, idd1.source_deal_header_id
		FROM #inserted_deal_detail111 idd1
		INNER JOIN source_deal_header sdh 
			ON sdh.source_deal_header_id = idd1.source_deal_header_id
			AND (sdh.deal_id LIKE 'INJC[_]%' )--or sdh.deal_id LIKE 'WTHD[_]%')
		WHERE idd1.term_start = i.flow_date
			AND idd1.group_path_id = i.group_path_id
			AND idd1.single_path_id = i.single_path_id
			AND idd1.leg = 1
	) inj
	LEFT JOIN #tmp_vol_split_deal_final_grp p_stor
		ON p_stor.source_deal_header_id = inj.source_deal_header_id		
	LEFT JOIN #inserted_deal_detail111 idd 
			ON idd.term_start = i.flow_date 
			AND idd.leg = 1
			AND idd.source_deal_header_id = p.source_deal_header_id
	GROUP BY i.optimizer_header_id
			, i.flow_date
			, i.transport_deal_id 
			, ISNULL(inj.source_deal_header_id, dvry.source_deal_header_id)
			, ISNULL(inj.source_deal_detail_id, dvry.source_deal_detail_id)
			, p.path_id
			, i.single_path_id
			, i.contract_id
			
	--UPDATE odd
	--	SET deal_volume = a.deal_volume
	--FROM optimizer_detail_downstream odd
	--CROSS APPLY(
	--	SELECT  SUM(oddh.deal_volume) deal_volume
	--	FROM optimizer_detail_downstream_hour oddh

	--	WHERE oddh.optimizer_header_id = odd.optimizer_header_id
	--		AND oddh.flow_date = odd.flow_date
	--		AND oddh.transport_deal_id = odd.transport_deal_id
	--		AND oddh.source_deal_header_id = odd.source_deal_header_id
	--		AND oddh.source_deal_detail_id = odd.source_deal_detail_id
	--	GROUP BY oddh.optimizer_header_id
	--			, oddh.flow_date
	--			, oddh.transport_deal_id
	--			, oddh.source_deal_header_id
	--			, oddh.source_deal_detail_id
	--) a
	--INNER JOIN #inserted_optimizer_header ioh
	--	ON ioh.optimizer_header_id = odd.optimizer_header_id


	IF @call_from <> 'flow_match'
	BEGIN
		---  book out
		INSERT INTO dbo.optimizer_detail_downstream(
			optimizer_header_id
			, flow_date
			, transport_deal_id
			, source_deal_header_id
			, source_deal_detail_id
			, deal_volume	
			, group_path_id
			, single_path_id
			, contract_id
		)
		SELECT i.optimizer_header_id
			, i.flow_date
			, i.transport_deal_id
			, p.source_deal_header_id,p.source_deal_detail_id
			, ABS(p.available_volume)
			, i.group_path_id
			, i.single_path_id
			, i.contract_id
		FROM #inserted_optimizer_header i
		CROSS APPLY 
		( 
			SELECT  TOP(1) master_rowid  
			FROM #tmp_vol_split_deal_pre 
			WHERE available_volume < 0
				AND from_location = i.receipt_location_id
		) box
		INNER JOIN #tmp_vol_split_deal_pre  p 
			ON  available_volume < 0
			AND p.from_location=i.receipt_location_id
			AND p.master_rowid=box.master_rowid
		OUTER APPLY (
			SELECT TOP(1) 1 ex
			FROM optimizer_header oh
			INNER JOIN optimizer_detail od
				ON oh.optimizer_header_id = od.optimizer_header_id
			INNER JOIN optimizer_detail_downstream odd
				ON odd.optimizer_header_id = oh.optimizer_header_id
				AND odd.transport_deal_id=od.transport_deal_id
			WHERE oh.group_path_id = -99
				AND oh.receipt_location_id= p.from_location
				AND odd.source_deal_detail_id=p.source_deal_detail_id
			)	ex
		WHERE (ex.ex IS NULL OR ISNULL(@reschedule, 0) = 1
		) 
			AND i.receipt_location_id=i.delivery_location_id 
	
		UNION ALL

		SELECT i.optimizer_header_id
			, i.flow_date
			, i.transport_deal_id
			, p.source_deal_header_id,p.source_deal_detail_id
			, p.available_volume_buy
			, i.group_path_id
			, i.single_path_id
			, i.contract_id
		 FROM #inserted_optimizer_header i
		INNER JOIN #tmp_vol_split_deal_del_bookout  p 
			ON  actual_available_volume< 0
			AND p.to_location=i.delivery_location_id
		OUTER APPLY (
			SELECT TOP(1) 1 ex
			FROM optimizer_header oh
			INNER JOIN optimizer_detail od
				ON oh.optimizer_header_id = od.optimizer_header_id
			WHERE oh.group_path_id = -99
				AND oh.delivery_location_id=p.to_location
				AND od.source_deal_detail_id=p.source_deal_detail_id
			)	ex
		WHERE (ex.ex IS NULL OR ISNULL(@reschedule, 0) = 1
		)
			AND i.receipt_location_id = i.delivery_location_id 
			AND run_sum_buy-intial_available_volume <= tot_volume_buy
	END
END
DELETE FROM optimizer_detail_downstream WHERE ISNULL(deal_volume, 0) = 0	
DELETE FROM optimizer_detail WHERE ISNULL(volume_used, 0) = 0		
DELETE FROM optimizer_header WHERE ISNULL(rec_nom_volume, 0) = 0 AND  ISNULL(del_nom_volume, 0)  = 0	


--Deal audit logic for INSERT deals starts
DECLARE @deal_ids VARCHAR(MAX)

SELECT @deal_ids = STUFF((SELECT ','+ CAST(sdh.source_deal_header_id  AS VARCHAR)  
							FROM #tmp_header sdh ORDER BY  sdh.source_deal_header_id  FOR XML PATH ('')), 1, 1, '')
	
--INSERT DEALS JUST CREATED ON PROCESS TABLE THAT IS USED TO DELETE BY REFRESH BUTTON ON OPTIMIZATION SCREEN ON BASIS OF PROCESS ID
SET @sql = '
SELECT  ROW_NUMBER() OVER(ORDER BY d.item) [row_id], d.item [source_deal_header_id]
INTO ' + @scheduled_deals + '
		FROM dbo.SplitCommaSeperatedValues(''' + @deal_ids + ''') d
	'

EXEC(@sql)
							
EXEC spa_insert_update_audit 'i', @deal_ids
--Deal audit logic for INSERT deals ends
			
IF EXISTS(SELECT 1 FROM #tmp_header)
BEGIN
	/**
		position calc done without job. If job takes time, optimization grid will plot wrong values since position will not be available at that moment.
	*/
	EXEC [dbo].[spa_update_deal_total_volume] 
		@source_deal_header_ids = @deal_ids
		, @process_id = NULL
		, @insert_type = 0
		, @partition_no = NULL
		, @user_login_id  = @user_name
		, @insert_process_table = 'n'
		, @call_from = 1
		, @call_from_2 = NULL
	/*
	DECLARE @spa VARCHAR(MAX)
			, @job_name VARCHAR(150)
	SET @job_name = 'calc_deal_position_breakdown' + @process_id

	SET @st1 = 'INSERT INTO ' + @report_position + '(source_deal_header_id,action) SELECT source_deal_header_id,''i'' FROM #tmp_header'  
	EXEC (@st1) 

	SET @spa = 'spa_update_deal_total_volume NULL,'''+@process_id+''',0,1,''' + @user_name + ''',NULL, NULL, ' + ISNULL('' + NULL + '', 'NULL') + ''	
	EXEC spa_run_sp_as_job @job_name, @spa, 'generating_report_table', @user_name
	*/

	--TRANSFER/OFFSET DEAL CREATION - START
	SELECT dtm.deal_transfer_mapping_id,h.source_deal_header_id
	INTO #deal_tansfer_criteria_match
	FROM deal_transfer_mapping dtm
	INNER JOIN #tmp_header h 
		ON h.counterparty_id = dtm.counterparty_id_from
		AND h.sub_book = dtm.source_book_mapping_id_from
		AND h.contract_id = dtm.contract_id_from
		AND h.template_id = dtm.template_id
		AND h.source_deal_type_id = dtm.source_deal_type_id
	
	IF EXISTS(SELECT TOP 1 1 FROM #deal_tansfer_criteria_match)
	BEGIN
		DECLARE @trf_deal_id VARCHAR(200) = ''
			, @trf_transfer_counterparty_id VARCHAR(10) = ''
			, @trf_transfer_contract_id VARCHAR(10) = ''
			, @trf_transfer_trader_id VARCHAR(10) = ''
			, @trf_transfer_sub_book VARCHAR(10) = ''
			, @trf_transfer_template_id VARCHAR(10) = ''
			, @trf_counterparty_id VARCHAR(10) = ''
			, @trf_contract_id VARCHAR(10) = ''
			, @trf_trader_id VARCHAR(10) = ''
			, @trf_sub_book VARCHAR(10) = ''
			, @trf_template_id VARCHAR(10) = ''
			, @trf_location_id VARCHAR(10) = ''
			, @trf_transfer_volume VARCHAR(10) = ''
			, @trf_volume_per VARCHAR(10) = ''
			, @trf_pricing_options VARCHAR(10) = ''
			, @trf_fixed_price VARCHAR(10) = ''
			, @trf_transfer_date VARCHAR(10) = ''
			, @trf_index_adder VARCHAR(10) = ''
			, @trf_fixed_adder VARCHAR(10) = ''
		
		SELECT TOP 1
			@trf_deal_id = ISNULL(dtcm.source_deal_header_id, '')
			, @trf_transfer_counterparty_id = ISNULL(dtmd.transfer_counterparty_id, '')
			, @trf_transfer_contract_id = ISNULL(dtmd.transfer_contract_id, '')
			, @trf_transfer_trader_id = ISNULL(dtmd.transfer_trader_id, '')
			, @trf_transfer_sub_book = ISNULL(dtmd.transfer_sub_book, '')
			, @trf_transfer_template_id = ISNULL(dtmd.transfer_template_id, '')
			, @trf_counterparty_id = ISNULL(dtmd.counterparty_id, '')
			, @trf_contract_id = ISNULL(dtmd.contract_id, '')
			, @trf_trader_id = ISNULL(dtmd.trader_id, '')
			, @trf_sub_book = ISNULL(dtmd.sub_book, '')
			, @trf_template_id = ISNULL(dtmd.template_id, '')
			, @trf_location_id = ISNULL(buy_loc.location_id, '')
			, @trf_transfer_volume = ISNULL(dtmd.transfer_volume, '')
			, @trf_volume_per = ISNULL(dtmd.volume_per, '')
			, @trf_pricing_options = ISNULL(dtmd.pricing_options, '')
			, @trf_fixed_price = ISNULL(dtmd.fixed_price, '')
			, @trf_transfer_date = ISNULL(cast(dtmd.transfer_date as date), '')
			, @trf_index_adder = ISNULL(dtmd.index_adder, '')
			, @trf_fixed_adder = ISNULL(dtmd.fixed_adder, '')

		FROM #deal_tansfer_criteria_match dtcm
		INNER JOIN deal_transfer_mapping dtm 
			ON dtm.deal_transfer_mapping_id = dtcm.deal_transfer_mapping_id
		INNER JOIN deal_transfer_mapping_detail dtmd 
			ON dtmd.deal_transfer_mapping_id = dtm.deal_transfer_mapping_id
		OUTER APPLY (
			SELECT MAX(sdd.location_id) [location_id]
			FROM source_deal_detail sdd
			WHERE sdd.source_deal_header_id = dtcm.source_deal_header_id
				AND sdd.buy_sell_flag = 'b'
		) buy_loc

		DECLARE @trf_xml VARCHAR(2000) = '<GridXML><GridRow  transfer_counterparty_id="' + @trf_transfer_counterparty_id + '" transfer_contract_id="' + @trf_transfer_contract_id + '" transfer_trader_id="' + @trf_transfer_trader_id + '" transfer_sub_book="' + @trf_transfer_sub_book + '" transfer_template_id="' + @trf_transfer_template_id + '" counterparty_id="' + @trf_counterparty_id + '" contract_id="' + @trf_contract_id + '" trader_id="' + @trf_trader_id + '" sub_book="' + @trf_sub_book + '" template_id="' + @trf_template_id + '" location_id="' + @trf_location_id + '" transfer_volume="' + @trf_transfer_volume + '" volume_per="' + @trf_volume_per + '" pricing_options="' + @trf_pricing_options + '" fixed_price="' + @trf_fixed_price + '" transfer_date="' + @trf_transfer_date + '" index_adder="' + @trf_index_adder + '" fixed_adder="' + @trf_fixed_adder + '"></GridRow></GridXML>'

		EXEC spa_deal_transfer @flag='t'
			,@source_deal_header_id=@trf_deal_id
			,@transfer_without_offset='0'
			,@transfer_only_offset='0'
			,@xml=@trf_xml
		
	END
	   	--TRANSFER/OFFSET DEAL CREATION - END
END

EXEC spa_ErrorHandler 0
	, 'Flow Optimization'
	, 'spa_schedule_deal_flow_optimization'
	, 'Success'
	, 'Successfully saved transportation deal.'
	, ''

END TRY
BEGIN CATCH
	--PRINT 'Catch Error:' + ERROR_MESSAGE()
	
	--delete junk deals	produced when error occured after inserting on deal header block. (mainly error occurs on inserting deal detail block)
	BEGIN
		DECLARE @junk_deal_ids VARCHAR(2000)
		SELECT @junk_deal_ids = COALESCE(@junk_deal_ids + ',', '') + CAST(sdh.source_deal_header_id AS VARCHAR(20))
		FROM #tmp_header th
		INNER JOIN source_deal_header sdh 
			ON sdh.source_deal_header_id = th.source_deal_header_id
		LEFT JOIN source_deal_detail sdd
			ON sdd.source_deal_header_id = sdh.source_deal_header_id
		WHERE sdh.deal_id like '%[_][_]%'
			AND sdd.source_deal_detail_id IS NULL

		IF NULLIF(@junk_deal_ids, '') IS NOT NULL
		BEGIN
			EXEC spa_source_deal_header @flag='d', @deal_ids = @junk_deal_ids
		END
		
	END

	EXEC spa_ErrorHandler -1
		, 'Flow Optimization'
		, 'spa_schedule_deal_flow_optimization'
		, 'Error'
		, 'Fail to save transportation deal.'
		, ''

END CATCH
END
    ELSE
	   EXEC spa_ErrorHandler -1
		   , 'Flow Optimization'
		   , 'spa_schedule_deal_flow_optimization'
		   , 'Error'
		   , 'Template Deal NOT found.'
		   , ''
