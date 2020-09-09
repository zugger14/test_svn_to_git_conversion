IF OBJECT_ID(N'[dbo].[spa_deal_update_new]', N'P') IS NOT NULL
     DROP PROCEDURE [dbo].[spa_deal_update_new]
GO
  
SET ANSI_NULLS ON
GO
   
SET QUOTED_IDENTIFIER ON
GO
   
/**
	Mostly used to build header & detail user interface dynamically, load deal related data and update existing deal.
   
	Parameters:
		@flag									:	Operation flag that decides the action to be performed. Does not accept NULL.
		@source_deal_header_id					:	Identifier of Deal, used as filter to return filtered Deals.
		@no_of_columns							:	Number of Columns in Detail Grid.
		@header_xml								:	Deal Header fields and values in XML Format.
		@detail_xml								:	Deal Detail fields and values in XML format.
		@from_date								:	Date to be used as Term Start.
		@to_date								:	Date to be used as Term End.
		@view_deleted							:	Specify whether to Show or Hide deleted deals.
		@template_id							:	Identifier of deal template.
		@copy_deal_id							:	Identifier of copied deal.
		@pricing_process_id						:	Unique Identifier used to create process table for storing Pricing data.
		@deleted_details						:	Identifier of Deleted Deal Details.
		@detail_id								:	Identifier of Deal Details.
		@group_id								:	Identifier of Group of Deal Detail.
		@header_cost_xml						:	Deal Header Cost fields and values as XML.
		@download_path							:	Path to download the document to.
		@document_list							:	List of Documents related to deal.
		@remarks_list							:	List of Remarks related to deal.
		@runtime_user							:	Login ID of user who is actually inserting the deal.
		@farrms_field_id						:	Actual ID of the fields as in system that are used in Deal.
		@selected_value							:	Selected Value.
		@is_udf									:	Specify whether the Deal Type is User Defined or System.
		@required								:	Specify whether the field value required or not required.
		@deal_type_id							:	Identifier of the type of deal.
		@pricing_type							:	Pricing Type of deal.
		@term_frequency							:	Frequency of Term.
		@process_id								:	Unique Identifier used to create a process table where data are saved.
		@shaped_process_id						:	Unique Identifier used to create a process table where shaped data are stored.
		@sub_book								:	Sub Book ID.
		@formula_process_id						:	Process ID with formula related data.
		@detail_lock_status						:	Lock Status of Deal Detail.
		@udf_process_id							:	Unique Identifier used to create a process table for storing User Defined fields data.
		@commodity_id							:	Identifier of Commodity.
		@call_from								:	Specify from where the procedure is called.
		@environment_process_id					:	Unique Identifier used to create a process table for storing Environmental data when it is enabled.
		@certificate_process_id					:	Unique Identifier used to create a process table for storing Certificate data when it is enabled.
		@deal_price_data_process_id				:	Unique Identifier used to create a process table for storing Deal Complex Pricing data when it is enabled.
		@deal_provisional_price_data_process_id :	Unique Identifier used to create a process table for storing Deal Complex Provisional Pricing data when it is enabled.
		@header_prepay_xml						:	Header Prepay data to be stored in XML format, only when prepay is enabled.
		@header_udt_grid						:	Header UDT Grid data xml
*/

CREATE PROCEDURE [dbo].[spa_deal_update_new]
    @flag NVARCHAR(1000),
	@source_deal_header_id INT = NULL,
	@no_of_columns INT = 50,
	@header_xml XML = NULL,
	@detail_xml XML = NULL,
	@from_date DATETIME = NULL,
	@to_date DATETIME = NULL,
	@view_deleted NCHAR(1) = 'n',
	@template_id INT = NULL,
	@copy_deal_id INT = NULL,
	@pricing_process_id NVARCHAR(500) = NULL,
	@deleted_details NVARCHAR(MAX) = NULL,
	@detail_id INT = NULL,
	@group_id INT = NULL,
	@header_cost_xml XML = NULL,
	@download_path NVARCHAR(MAX) = NULL,
	@document_list NVARCHAR(MAX) = NULL,
	@remarks_list NVARCHAR(MAX) = NULL,
	@runtime_user NVARCHAR(100)  = NULL,
	@farrms_field_id NVARCHAR(200) = NULL,
	@selected_value NVARCHAR(500) = NULL,
	@is_udf NCHAR(1) = NULL,
	@required NCHAR(1) = NULL,
	@deal_type_id INT = NULL,
	@pricing_type INT = NULL,
	@term_frequency NCHAR(1) = NULL,
	@process_id NVARCHAR(200) = NULL,
	@shaped_process_id NVARCHAR(200) = NULL,
	@sub_book INT = NULL,
	@formula_process_id NVARCHAR(200) = NULL,
	@detail_lock_status NCHAR(1) = NULL,
	@udf_process_id NVARCHAR(200) = NULL,
	@commodity_id INT = NULL,
	@call_from NVARCHAR(20) = NULL,
	@environment_process_id NVARCHAR(200) = NULL,
	@certificate_process_id NVARCHAR(200) = NULL,
	@deal_price_data_process_id NVARCHAR(50) = NULL,
	@deal_provisional_price_data_process_id NVARCHAR(50) = NULL,
	@header_prepay_xml XML = NULL,
	@header_udt_grid VARCHAR(MAX) = NULL
AS

/*--------------Debug Section------------
DECLARE @flag NVARCHAR(1000),
		@source_deal_header_id INT = NULL,
		@no_of_columns INT = 50,
		@header_xml XML = NULL,
		@detail_xml XML = NULL,
		@from_date DATETIME = NULL,
		@to_date DATETIME = NULL,
		@view_deleted NCHAR(1) = 'n',
		@template_id INT = NULL,
		@copy_deal_id INT = NULL,
		@pricing_process_id NVARCHAR(500) = NULL,
		@deleted_details NVARCHAR(MAX) = NULL,
		@detail_id INT = NULL,
		@group_id INT = NULL,
		@header_cost_xml NVARCHAR(MAX) = NULL,
		@download_path NVARCHAR(MAX) = NULL,
		@document_list NVARCHAR(MAX) = NULL,
		@remarks_list NVARCHAR(MAX) = NULL,
		@runtime_user NVARCHAR(100)  = NULL,
		@farrms_field_id NVARCHAR(200) = NULL,
		@selected_value NVARCHAR(500) = NULL,
		@is_udf NCHAR(1) = NULL,
		@required NCHAR(1) = NULL,
		@deal_type_id INT = NULL,
		@pricing_type INT = NULL,
		@term_frequency NCHAR(1) = NULL,
		@process_id NVARCHAR(200) = NULL,
		@shaped_process_id NVARCHAR(200) = NULL,
		@sub_book INT = NULL,
		@formula_process_id NVARCHAR(200) = NULL,
		@detail_lock_status NCHAR(1) = NULL,
		@udf_process_id NVARCHAR(200) = NULL,
		@commodity_id INT = NULL,
		@call_from NVARCHAR(20) = NULL,
		@environment_process_id NVARCHAR(200) = NULL,
		@certificate_process_id NVARCHAR(200) = NULL,
		@deal_price_data_process_id NVARCHAR(50) = NULL,
		@deal_provisional_price_data_process_id NVARCHAR(50) = NULL,
		@header_prepay_xml NVARCHAR(MAX) = NULL,
		@header_udt_grid NVARCHAR(MAX) = NULL
 
	--Sets session DB users 
	EXEC sys.sp_set_session_context @key = N'DB_USER', @value = 'dmanandhar'

	--Sets contextinfo to debug mode so that spa_print will prints data
	DECLARE @contextinfo VARBINARY(128) = CONVERT(VARBINARY(128), 'DEBUG_MODE_ON')
	SET CONTEXT_INFO @contextinfo

	EXEC spa_print 'Use spa_print instead of PRINT statement in debug mode.'
		
	--Drops all temp tables created in this scope.
	EXEC [spa_drop_all_temp_table] 

--exec spa_debug_helper N'EXEC sys.sp_set_session_context @key = N''DB_USER'', @value = ''dmanandhar'';EXEC spa_deal_update_new  
--@flag=@P1,@source_deal_header_id=@P2,@header_xml=@P3,@detail_xml=@P4,@pricing_process_id=@P5,@header_cost_xml=@P6,@deal_type_id=@P7,@pricing_type=@P8,@term_frequency=@P9,@shaped_process_id=@P10,@formula_process_id=@P11,@udf_process_id=@P12,@environment_process_id=@P13,@certificate_process_id=@P14,@deal_price_data_process_id=@P15,@deal_provisional_price_data_process_id=@P16,@header_prepay_xml=@P17',N'@P1 
--nvarchar(4000),@P2 nvarchar(4000),@P3 nvarchar(4000),@P4 char(1),@P5 char(1),@P6 nvarchar(4000),@P7 nvarchar(4000),@P8 nvarchar(4000),@P9 nvarchar(4000),@P10 char(1),@P11 nvarchar(4000),@P12 
--nvarchar(4000),@P13 nvarchar(4000),@P14 nvarchar(4000),@P15 nvarchar(4000),@P16 nvarchar(4000),@P17 char(1)',N's',N'7385',N'<Root><FormXML  UDF___-1495="" profile_granularity="982" 
--sub_book="82" header_buy_sell_flag="s" deal_id="Flow Deal for hour" deal_date="2019-09-25" counterparty_id="7712" trader_id="1183" contract_id="8196" entire_term_start="2019-11-11" entire_term_end="2019-11-11" term_frequency="m" broker_id="" UDF___1342="" block_define_id="" deal_status="5604" confirm_status_type="17200" deal_category_value_id="475" deal_locked="n" deal_reference_type_id="" reporting_group3="" UDF___3="161" reporting_group1="" reporting_group2="" reporting_group4="" template_id="2698" source_deal_type_id="1171" deal_sub_type_type_id="" internal_desk_id="17302" commodity_id="50" pricing_type="46704" physical_financial_flag="p" granularity_id="" internal_portfolio_id="" ext_deal_id="" reference="" close_reference_id="" confirmation_type="" confirmation_template="" counterparty_id2="" counterparty2_trader="" internal_counterparty="" description1="" description2="" description3="" description4="" pricing="" fx_conversion_market="" payment_term="" payment_days="" create_user="Sulav  Nepal" create_ts="2020-06-08 08:55:00" update_user="Dewanand  Manandhar" update_ts="2020-06-30 10:55:00"></FormXML></Root>',NULL,NULL,N'<GridXML><GridRow  seq_no="0"  cost_id="-1441" cost_name="Premium" internal_field_type_id="18722" internal_field_type="Option Premium" udf_value="" currency_id="" uom_id="" counterparty_id="" contract_id="" receive_pay="" udf_field_type="t" settlement_date="" settlement_calendar="" settlement_days="" payment_date="" payment_calendar="" payment_days=""></GridRow><GridRow  seq_no="1"  cost_id="-1856" cost_name="Trans Fees" internal_field_type_id="18730" internal_field_type="Fees" udf_value="" currency_id="" uom_id="" counterparty_id="" contract_id="" receive_pay="" udf_field_type="t" settlement_date="" settlement_calendar="" settlement_days="" payment_date="" payment_calendar="" payment_days=""></GridRow></GridXML>',N'1171',N'46704',N'm',NULL,N'20D953AF_608D_4BED_9624_D5E43990E0DF',N'A0910EA1_C68D_4EE7_81A8_1C50CA0D36ED',N'',N'',N'',N'',NULL


	--Sets session DB users 
	EXEC sys.sp_set_session_context @key = N'DB_USER', @value = 'dmanandhar'

	--Sets contextinfo to debug mode so that spa_print will prints data
	--DECLARE @contextinfo VARBINARY(128) = CONVERT(VARBINARY(128), 'DEBUG_MODE_ON')
	SET CONTEXT_INFO @contextinfo

	EXEC spa_print 'Use spa_print instead of PRINT statement in debug mode.'
		
	--Drops all temp tables created in this scope.
	EXEC [spa_drop_all_temp_table] 
	
	-- SPA parameter values
	SELECT @flag = 's', @source_deal_header_id = '8407', @header_xml = '<Root><FormXML  UDF___-1495="" sub_book="82" 
header_buy_sell_flag="b" deal_id="COPY_8357_8407" deal_date="1980-09-25" counterparty_id="7712" trader_id="1183" contract_id="8196" entire_term_start="2000-11-01" entire_term_end="2000-11-30" term_frequency="m" broker_id="" UDF___1342="" block_define_id="" deal_status="5604" confirm_status_type="17200" deal_category_value_id="475" deal_locked="n" deal_reference_type_id="" UDF___3="158" reporting_group1="" reporting_group2="" reporting_group3="" reporting_group4="" reporting_group5="" template_id="2698" source_deal_type_id="1171" deal_sub_type_type_id="" internal_desk_id="17302" commodity_id="-1" pricing_type="46704" physical_financial_flag="p" granularity_id="" internal_portfolio_id="" profile_granularity="982" ext_deal_id="" reference="" close_reference_id="" confirmation_type="" confirmation_template="" counterparty_id2="" counterparty2_trader="" internal_counterparty="" description1="" description2="" description3="" description4="" pricing="" fx_conversion_market="" payment_term="" payment_days="" create_user="Sulav  Nepal" create_ts="2020-07-02 07:23:00" update_user="Sulav  Nepal" update_ts="2020-07-02 13:54:00"></FormXML></Root>', @detail_xml = NULL, @pricing_process_id = NULL, @header_cost_xml = '<GridXML><GridRow  seq_no="0"  cost_id="-1441" cost_name="Premium" internal_field_type_id="18722" internal_field_type="Option Premium" udf_value="" currency_id="" uom_id="" counterparty_id="" contract_id="" receive_pay="" udf_field_type="t" settlement_date="" settlement_calendar="" settlement_days="" payment_date="" payment_calendar="" payment_days=""></GridRow><GridRow  seq_no="1"  cost_id="-1856" cost_name="Trans Fees" internal_field_type_id="18730" internal_field_type="Fees" udf_value="" currency_id="" uom_id="" counterparty_id="" contract_id="" receive_pay="" udf_field_type="t" settlement_date="" settlement_calendar="" settlement_days="" payment_date="" payment_calendar="" payment_days=""></GridRow></GridXML>', @deal_type_id = '1171', @pricing_type = '46704', @term_frequency = 'm', @shaped_process_id = NULL, @formula_process_id = '33C4442F_F980_47A8_A670_1BBABDEB4052', @udf_process_id = 'FF478BC0_27EE_4D20_AD3A_804D07D43C65', @environment_process_id = '', @certificate_process_id = '', @deal_price_data_process_id = '', @deal_provisional_price_data_process_id = '', @header_prepay_xml = NULL

--**************************************/
 
SET NOCOUNT ON

DECLARE @combo_process_table NVARCHAR(300)
DECLARE @combo_process_id NVARCHAR(100) = dbo.FNAGETNEWID()
DECLARE @combo_user_name NVARCHAR(50) = dbo.FNADBUser()

IF @deal_price_data_process_id IS NOT NULL
BEGIN
	DECLARE @price_process_table NVARCHAR(100)

	SET @price_process_table = 'adiha_process.dbo.pricing_xml_' + dbo.FNADBUser() + '_' + @deal_price_data_process_id
END

IF OBJECT_ID('tempdb..#temp_collect_detail_ids') IS NOT NULL
	DROP TABLE #temp_collect_detail_ids


IF @deal_provisional_price_data_process_id IS NOT NULL
BEGIN
	DECLARE @price_provisional_process_table NVARCHAR(100)

	SET @price_provisional_process_table = 'adiha_process.dbo.provisional_pricing_xml_' + dbo.FNADBUser() + '_' + @deal_provisional_price_data_process_id
END

IF OBJECT_ID('tempdb..#temp_collect_detail_ids') IS NOT NULL
	DROP TABLE #temp_collect_detail_ids

IF ISNULL(@runtime_user, '') <> '' AND @runtime_user <> dbo.FNADBUser()   
BEGIN
	--EXECUTE AS USER = @runtime_user;
	DECLARE @contextinfo1 VARBINARY(128)
	SELECT @contextinfo1 = CONVERT(VARBINARY(128), @runtime_user)
	SET CONTEXT_INFO @contextinfo1
END

IF @copy_deal_id IS NOT NULL
	SET @source_deal_header_id = @copy_deal_id

IF @source_deal_header_id IS NOT NULL
BEGIN
	IF @view_deleted = 'n'
	BEGIN
		SELECT @deal_type_id = sdh.source_deal_type_id,
			   @pricing_type = sdh.pricing_type
		FROM source_deal_header sdh 
		WHERE sdh.source_deal_header_id = @source_deal_header_id
	END
	ELSE
	BEGIN
		SELECT @deal_type_id = sdh.source_deal_type_id,
			   @pricing_type = sdh.pricing_type
		FROM delete_source_deal_header sdh 
		WHERE sdh.source_deal_header_id = @source_deal_header_id
	END
END
 
DECLARE @sql NVARCHAR(MAX)

DECLARE @user_name NVARCHAR(100) = dbo.FNADBUser()
DECLARE @shaped_process_table NVARCHAR(400), @detail_value_process_id NVARCHAR(100)
DECLARE @underlying_options_mapping INT

IF @process_id IS NOT NULL AND @flag = 'e'
BEGIN		
	SET @shaped_process_table = dbo.FNAProcessTableName('shaped_volume', @user_name, @process_id)
	SELECT @detail_value_process_id = @process_id		
	IF OBJECT_ID(@shaped_process_table) IS NOT NULL
		EXEC('DROP TABLE ' + @shaped_process_table)
	
	IF @source_deal_header_id IS NOT NULL	
		SET @process_id = dbo.FNAGetNewId()
END

IF @process_id IS NULL
	SET @process_id = dbo.FNAGetNewId()
	
IF @formula_process_id IS NULL
	SET @formula_process_id = dbo.FNAGetNewId()

IF @udf_process_id IS NULL
	SET @udf_process_id = dbo.FNAGetNewId()

DECLARE @formula_present INT
DECLARE @position_formula_present INT
DECLARE @deemed_process_table NVARCHAR(400)
DECLARE @std_event_process_table NVARCHAR(400)
DECLARE @custom_event_process_table NVARCHAR(400)
DECLARE @pricing_type_process_table NVARCHAR(400)
DECLARE @deal_escalation_process_table NVARCHAR(500)
DECLARE @deemed_provisional_process_table NVARCHAR(400)
DECLARE @std_event_provisional_process_table NVARCHAR(400)
DECLARE @custom_event_provisional_process_table NVARCHAR(400)
DECLARE @pricing_type_provisional_process_table NVARCHAR(400)
DECLARE @deal_escalation_provisional_process_table NVARCHAR(500)
DECLARE @detail_cost_table NVARCHAR(400)
DECLARE @detail_udf_table NVARCHAR(400)
DECLARE @deal_date_rule     INT  
DECLARE @term_rule			INT
DECLARE @default_deal_date DATETIME
DECLARE @new_id NVARCHAR(200)
DECLARE @deal_required_doc_table NVARCHAR(400)
DECLARE @deal_remarks_table NVARCHAR(400)
DECLARE @enable_document_tab NCHAR(1) = 'n'
DECLARE @enable_pricing NCHAR(1) = 'n'
DECLARE @enable_provisional_tab NCHAR(1) = 'n'
DECLARE @enable_escalation_tab NCHAR(1) = 'n'
DECLARE @enable_cost_tab NVARCHAR(10) = 'n'
DECLARE @enable_detail_cost NVARCHAR(10) = 'n'
DECLARE @enable_remarks	NCHAR(1) = 'n'
DECLARE @formula_fields_detail NVARCHAR(1000)
DECLARE @formula_fields_header NVARCHAR(1000)
DECLARE @default_header_buy_sell_flag NCHAR(1)
DECLARE @enable_udf_tab NVARCHAR(10) = 'y'
DECLARE @enable_prepay_tab NVARCHAR(10) = 'n'

DECLARE @detail_formula_process_table NVARCHAR(200)
SET @detail_formula_process_table = dbo.FNAProcessTableName('detail_formula_process_table', @user_name, @formula_process_id)

DECLARE @header_formula_process_table NVARCHAR(200)
SET @header_formula_process_table = dbo.FNAProcessTableName('header_formula_process_table', @user_name, @formula_process_id)

-- Default size
DECLARE @default_field_size INT
		, @default_column_num_per_row INT
		, @default_offsetleft INT
		, @default_fieldset_offsettop INT
		, @default_filter_field_size INT
		, @default_fieldset_width INT =1000

-- Set Default Values
SELECT @default_field_size = var_value
FROM adiha_default_codes_values 
WHERE default_code_id = 86 
	AND instance_no = 1 
	AND seq_no = 1
SELECT @default_column_num_per_row = var_value 
FROM adiha_default_codes_values 
WHERE default_code_id = 86 
	AND seq_no = 4 
	AND instance_no = 1
SELECT @default_offsetleft = var_value 
FROM adiha_default_codes_values 
WHERE default_code_id = 86 
	AND seq_no = 3 
	AND instance_no = 1
SELECT @default_fieldset_offsettop = var_value 
FROM adiha_default_codes_values 
WHERE default_code_id = 86 
	AND seq_no = 5 
	AND instance_no = 1
SELECT @default_fieldset_width = var_value 
FROM adiha_default_codes_values 
WHERE default_code_id = 86 
	AND seq_no = 8 
	AND instance_no = 1

IF OBJECT_ID('tempdb..#temp_collect_detail_ids') IS NOT NULL
	DROP TABLE #temp_collect_detail_ids
 		
CREATE TABLE #temp_collect_detail_ids (source_deal_detail_id INT, source_deal_group_id INT)
 
SET @deal_required_doc_table = dbo.FNAProcessTableName('deal_required_doc', @user_name, @pricing_process_id)
SET @deal_remarks_table = dbo.FNAProcessTableName('deal_remarks', @user_name, @pricing_process_id)

DECLARE @spot_or_term CHAR(1)

-- When the term type is spot then the term frequency is 'd', so the value of spot or term can be obtained.
IF @term_frequency = 'd'
	SET @spot_or_term = 's'
ELSE
	SET @spot_or_term = 't'
 
DECLARE @field_template_id     INT
 
IF @template_id IS NULL
BEGIN
	IF ISNULL(@view_deleted,'n') = 'n'
	BEGIN
 		SELECT @template_id = sdht.template_id,
 				@field_template_id = sdht.field_template_id,
 				@term_frequency = sdh.term_frequency,
 				@commodity_id = ISNULL(@commodity_id, sdh.commodity_id),
				@default_header_buy_sell_flag = sdh.header_buy_sell_flag
 		FROM source_deal_header sdh 
 		INNER JOIN source_deal_header_template sdht ON sdht.template_id = sdh.template_id 
 		WHERE sdh.source_deal_header_id = @source_deal_header_id
	END	
	ELSE
	BEGIN
 		SELECT @template_id = sdht.template_id,
 				@field_template_id = sdht.field_template_id,
 				@term_frequency = sdh.term_frequency,
 				@commodity_id = ISNULL(@commodity_id, sdh.commodity_id),
				@default_header_buy_sell_flag = sdh.header_buy_sell_flag
 		FROM delete_source_deal_header sdh 
 		INNER JOIN source_deal_header_template sdht ON sdht.template_id = sdh.template_id 
 		WHERE sdh.source_deal_header_id = @source_deal_header_id
	END

	-- For Deal update, if the combination does not exists take the combination where commodity is NULL
	IF NOT EXISTS (SELECT 1 FROM deal_type_pricing_maping	
					WHERE source_deal_type_id = @deal_type_id 
					AND commodity_id = @commodity_id AND @commodity_id IS NOT NULL 
					AND (pricing_type = @pricing_type OR ([pricing_type] IS NULL AND @pricing_type IS NULL) ) 
					AND @source_deal_header_id IS NOT NULL AND template_id = @template_id)
	BEGIN
		SET @commodity_id = NULL
	END
END
ELSE
BEGIN
	SELECT @field_template_id = sdht.field_template_id,
 			@commodity_id = @commodity_id,--ISNULL(@commodity_id, sdht.commodity_id),
			@default_header_buy_sell_flag = header_buy_sell_flag
	FROM source_deal_header_template sdht 
	WHERE sdht.template_id = @template_id
	
	IF @term_frequency IS NULL
	BEGIN
		SELECT @term_frequency = sdht.term_frequency_type
		FROM source_deal_header_template sdht
 		WHERE sdht.template_id = @template_id
 			
		IF EXISTS(
			SELECT 1
			FROM deal_default_value
			WHERE [deal_type_id] = @deal_type_id
				  AND ( ([commodity] IS NULL AND @commodity_id IS NULL) OR [commodity] = @commodity_id)	  
				  AND ( ([pricing_type] IS NULL AND @pricing_type IS NULL) OR [pricing_type] = @pricing_type)				  
				  AND (buy_sell_flag IS NULL OR ISNULL(buy_sell_flag, 'x') = ISNULL(@default_header_buy_sell_flag, 'y'))
		)
		BEGIN
			SELECT @term_frequency = ISNULL(term_frequency, @term_frequency)
			FROM deal_default_value 
			WHERE deal_type_id = @deal_type_id 
			AND ((pricing_type IS NULL AND @pricing_type IS NULL) OR pricing_type = @pricing_type)
			AND ( ([commodity] IS NULL AND @commodity_id IS NULL) OR [commodity] = @commodity_id)
			AND (buy_sell_flag IS NULL OR ISNULL(buy_sell_flag, 'x') = ISNULL(@default_header_buy_sell_flag, 'y'))
		END
	END
END

DECLARE @term_end_present INT, @is_gas_daily NCHAR(1)
SELECT @is_gas_daily = ISNULL(sdht.is_gas_daily, 'n')
FROM source_deal_header_template sdht WHERE sdht.template_id = @template_id

SELECT @deal_date_rule = sdht.deal_date_rule,
 	   @term_rule = sdht.term_rule,
 	   @enable_document_tab = sdht.enable_document_tab,
 	   @enable_pricing = ISNULL(sdht.enable_pricing_tabs, 'n'),
 	   @enable_provisional_tab = ISNULL(sdht.enable_provisional_tab, 'n'),
 	   @enable_escalation_tab = ISNULL(sdht.enable_escalation_tab, 'n'),
 	   @enable_remarks = ISNULL(sdht.enable_remarks, 'n')
FROM  dbo.source_deal_header_template sdht
WHERE sdht.template_id = @template_id

IF EXISTS(
	SELECT 1
	FROM   deal_type_pricing_maping
	WHERE template_id             = @template_id
	AND   source_deal_type_id     = @deal_type_id
	AND   ((@pricing_type IS NULL AND pricing_type IS NULL) OR pricing_type = @pricing_type)
	AND	( ([commodity_id] IS NULL AND @commodity_id IS NULL) OR ISNULL([commodity_id],@commodity_id) = @commodity_id)
)
BEGIN
--case data is setup on deal type price mapping
	SELECT @enable_pricing = CASE WHEN dtpm.pricing_tab = 1 THEN 'y' ELSE 'n' END,
		   @enable_provisional_tab = CASE WHEN dtpm.enable_provisional_tab = 1 THEN 'y' ELSE 'n' END,
		   @enable_escalation_tab = CASE WHEN dtpm.enable_escalation_tab = 1 THEN 'y' ELSE 'n' END,
		   @enable_cost_tab = CASE WHEN dtpm.enable_cost_tab = 1 THEN 'y' ELSE 'n' END,
		   @enable_detail_cost = CASE WHEN dtpm.enable_cost_tab = 1 AND @source_deal_header_id IS NOT NULL THEN 'y' ELSE 'n' END,
		   @enable_udf_tab = CASE WHEN dtpm.enable_udf_tab = 1 THEN 'y' ELSE 'n' END,
		   @enable_prepay_tab = CASE WHEN dtpm.enable_prepay_tab = 1 THEN 'y' ELSE 'n' END
	FROM deal_type_pricing_maping dtpm
	WHERE dtpm.template_id = @template_id
	AND dtpm.source_deal_type_id = @deal_type_id
	AND ((@pricing_type IS NULL AND dtpm.pricing_type IS NULL) OR dtpm.pricing_type = @pricing_type)
	AND  ( (dtpm.[commodity_id] IS NULL AND @commodity_id IS NULL) OR ISNULL(dtpm.[commodity_id],@commodity_id) = @commodity_id)
	
	SELECT @enable_cost_tab = CASE WHEN  @enable_cost_tab = 'y' AND ISNULL(mft.show_cost_tab,'n') = 'n' THEN 'n'
		   ELSE @enable_cost_tab END	
	FROM maintain_field_template mft
	WHERE mft.field_template_id = @field_template_id 
END
ELSE
BEGIN
	--case data is not setup on deal type price mapping
	SELECT @enable_cost_tab = ISNULL(mft.show_cost_tab,'n')
	FROM maintain_field_template mft
	WHERE mft.field_template_id = @field_template_id
END
 
--select @template_id, @deal_type_id,@commodity_id,@field_template_id,@pricing_type
-- added logic to hide show udf as per new requirement
SELECT @enable_udf_tab = CASE 
		WHEN temp_maintain_field_template.show_udf_tab = 'y'
			AND ISNULL(temp_deal_type_pricing_maping.is_data_setuped, 'n') = 'n'
			--AND b.enable_udf_tab = 'n'
			THEN 'y'
		WHEN temp_maintain_field_template.show_udf_tab = 'y'
			AND ISNULL(temp_deal_type_pricing_maping.is_data_setuped, 'n') = 'y'
			AND ISNULL(temp_deal_type_pricing_maping.enable_udf_tab, 'n') = 'n'
			THEN 'n'
		WHEN temp_maintain_field_template.show_udf_tab = 'y'
			AND ISNULL(temp_deal_type_pricing_maping.is_data_setuped, 'n') = 'y'
			AND ISNULL(temp_deal_type_pricing_maping.enable_udf_tab, 'n') = 'y'
			THEN 'y'
				--WHEN a.show_udf_tab = 'n'
				--		AND b.is_data_setuped = 'y'
				--		AND b.enable_udf_tab = 'n'
				--	THEN 'n'
		WHEN temp_maintain_field_template.show_udf_tab = 'n'
			AND ISNULL(temp_deal_type_pricing_maping.is_data_setuped, 'n') = 'y'
			AND ISNULL(temp_deal_type_pricing_maping.enable_udf_tab, 'n') = 'y'
			THEN 'n'
		ELSE 'n'
		END
FROM (
	VALUES (1)
	) udf_mapping_set(id)
OUTER APPLY (
	SELECT ISNULL(show_udf_tab, 'n') show_udf_tab
	FROM maintain_field_template
	WHERE field_template_id = @field_template_id
	) temp_maintain_field_template
OUTER APPLY (
	SELECT 'y' AS is_data_setuped
		,CASE 
			WHEN ISNULL(enable_udf_tab, 0) = 0
				THEN 'n'
			ELSE 'y'
			END AS enable_udf_tab
	FROM deal_type_pricing_maping
	WHERE template_id = @template_id
		AND source_deal_type_id = @deal_type_id
		AND (
			(
				@pricing_type IS NULL
				AND pricing_type IS NULL
				)
			OR pricing_type = @pricing_type
			)
		AND ISNULL(commodity_id, @commodity_id) = @commodity_id
	) temp_deal_type_pricing_maping

SELECT @enable_detail_cost = CASE WHEN @enable_cost_tab = 'y' THEN ISNULL(@enable_detail_cost, mft.show_detail_cost_tab) ELSE 'n' END
FROM maintain_field_template mft
WHERE mft.field_template_id = @field_template_id
 	
SELECT @enable_cost_tab = CASE WHEN @enable_cost_tab = 'y' THEN CAST(mftg.field_group_id AS NVARCHAR(10)) ELSE 'n' END
FROM maintain_field_template_group mftg
WHERE mftg.field_template_id = @field_template_id
AND mftg.default_tab = 1
 
SET @default_deal_date = dbo.FNAResolveDate(CONVERT(DATE, GETDATE()), @deal_date_rule)
 
DECLARE @name           NVARCHAR(200),
        @sql_string     NVARCHAR(2000),
        @deal_value     NVARCHAR(2000),
        @is_required	NVARCHAR(10)
 
IF @flag = 'h'
BEGIN
	IF OBJECT_ID('tempdb..#temp_deal_tabs') IS NOT NULL
 		DROP TABLE #temp_deal_tabs
 	
	CREATE TABLE #temp_deal_tabs (id INT, [text] NVARCHAR(500) COLLATE DATABASE_DEFAULT, active NVARCHAR(20) COLLATE DATABASE_DEFAULT, seq_no INT, default_tab INT)
 	
	DECLARE @min_seq_no INT
	SELECT @min_seq_no = MIN(seq_no)
    FROM maintain_field_template_group
    WHERE field_template_id = @field_template_id
     
	INSERT INTO #temp_deal_tabs (id, [text], active, seq_no, default_tab)
    SELECT field_group_id,
        group_name,
        CASE WHEN seq_no = @min_seq_no THEN 'true' ELSE NULL END,
        seq_no,
        default_tab
    FROM maintain_field_template_group
    WHERE field_template_id = @field_template_id 
    ORDER BY seq_no 

	IF @enable_udf_tab = 'y'
	BEGIN
		INSERT INTO #temp_deal_tabs (id, [text], active, seq_no, default_tab)
		SELECT 0, 'UDFs', NULL, 1000, NULL
	END
     
	IF @enable_prepay_tab = 'y' AND @copy_deal_id IS NULL
	BEGIN
		INSERT INTO #temp_deal_tabs (id, [text], active, seq_no, default_tab)
		SELECT -1, 'Prepay', NULL,2000, NULL
	END
     
    --DELETE FROM #temp_deal_tabs WHERE default_tab = 1 AND @source_deal_header_id IS NULL
     
	-- SELECT @field_template_id
    --- call from Template window then return only those fields which are in Deal Templates
	
	IF OBJECT_ID('tempdb..#temp_header') IS NOT NULL
 		DROP TABLE #temp_header
	
	SELECT column_name 
	INTO #temp_header 
	FROM INFORMATION_SCHEMA.Columns 
	WHERE TABLE_NAME = 'source_deal_header_template'
 	
	IF @source_deal_header_id IS NULL
	BEGIN
 		DELETE FROM #temp_header WHERE column_name IN ('entire_term_start', 'entire_term_end')
	END
 	
	INSERT INTO #temp_header
	SELECT 'sub_book' 
	UNION ALL
	SELECT 'source_system_book_id1'
	UNION ALL
	SELECT 'source_system_book_id2'
	UNION ALL
	SELECT 'source_system_book_id3'
	UNION ALL
	SELECT 'source_system_book_id4'
 	
	IF OBJECT_ID('tempdb..#temp_deal_header_fields') IS NOT NULL
 		DROP TABLE #temp_deal_header_fields
 	
	CREATE TABLE #temp_deal_header_fields(
 		[name]               NVARCHAR(200) COLLATE DATABASE_DEFAULT,
 		group_id             NVARCHAR(200) COLLATE DATABASE_DEFAULT,
 		[label]              NVARCHAR(200) COLLATE DATABASE_DEFAULT,
 		[type]               NVARCHAR(20) COLLATE DATABASE_DEFAULT,
 		[data_type]          NVARCHAR(20) COLLATE DATABASE_DEFAULT,
 		[default_validation] NVARCHAR(200) COLLATE DATABASE_DEFAULT,
 		[header_detail]		 NVARCHAR(200) COLLATE DATABASE_DEFAULT,
 		[required]           NVARCHAR(20) COLLATE DATABASE_DEFAULT,
 		[sql_string]         NVARCHAR(2000) COLLATE DATABASE_DEFAULT,
 		[dropdown_json]      NVARCHAR(MAX) COLLATE DATABASE_DEFAULT,
 		[disabled]           NVARCHAR(20) COLLATE DATABASE_DEFAULT,
 		window_function_id	 NVARCHAR(100) COLLATE DATABASE_DEFAULT,
 		[inputWidth]         NVARCHAR(20) COLLATE DATABASE_DEFAULT,
 		[labelWidth]         NVARCHAR(20) COLLATE DATABASE_DEFAULT,
 		[udf_or_system]      NCHAR(1) COLLATE DATABASE_DEFAULT,
 		[seq_no]             INT,
 		[hidden]             NVARCHAR(10) COLLATE DATABASE_DEFAULT,
 		[deal_value]		 NVARCHAR(MAX) COLLATE DATABASE_DEFAULT,
 		[field_id]			 NVARCHAR(20) COLLATE DATABASE_DEFAULT,
 		[update_required]	 NVARCHAR(10) COLLATE DATABASE_DEFAULT,
 		[value_required]     NVARCHAR(10) COLLATE DATABASE_DEFAULT,
 		[block]				 INT,
 		[connector]			 NVARCHAR(MAX) COLLATE DATABASE_DEFAULT,
		[open_ui_function_id] INT
	)

	IF OBJECT_ID('tempdb..#temp_deal_type_mapping_header') IS NOT NULL
		DROP TABLE #temp_deal_type_mapping_header

	CREATE TABLE #temp_deal_type_mapping_header(
		id              INT IDENTITY(1, 1),
		column_name     NVARCHAR(200)  COLLATE DATABASE_DEFAULT,
		col_value       NVARCHAR(500)  COLLATE DATABASE_DEFAULT
	)
	
	DECLARE @whr_clause_header NVARCHAR(MAX)
	SET @whr_clause_header = 'template_id=' + CAST(@template_id AS NVARCHAR(200)) + ' AND source_deal_type_id = ' + CAST(ISNULL(@deal_type_id,0) AS NVARCHAR(20))  + ' AND commodity_id = ' + CAST(ISNULL(@commodity_id,0) AS NVARCHAR(20)) 
	
	IF @pricing_type IS NOT NULL	
		SET @whr_clause_header += ' AND pricing_type=' + CAST(@pricing_type AS NVARCHAR(20)) 

	INSERT INTO #temp_deal_type_mapping_header(column_name, col_value)
	EXEC spa_Transpose 'deal_type_pricing_maping', @whr_clause_header

	DELETE FROM #temp_deal_type_mapping_header WHERE column_name IN ('template_id', 'source_deal_type_id', 'commodity_id', 'pricing_type', 'deal_type_pricing_maping_id', 'create_ts', 'create_user', 'update_ts', 'update_user')

	IF OBJECT_ID('tempdb..#temp_deal_values') IS NOT NULL
 		DROP TABLE #temp_deal_values

 	IF OBJECT_ID('tempdb..#temp_deal_udf_values') IS NOT NULL
 		DROP TABLE #temp_deal_udf_values

	CREATE TABLE #temp_deal_values	 (
 		sno				INT IDENTITY(1, 1),
 		field_name     NVARCHAR(150) COLLATE DATABASE_DEFAULT,
 		field_value  NVARCHAR(1000) COLLATE DATABASE_DEFAULT
	)
 	
	CREATE TABLE #temp_deal_udf_values(
 		sno                 INT IDENTITY(1, 1),
 		field_name          NVARCHAR(150) COLLATE DATABASE_DEFAULT,
 		field_value         NVARCHAR(2000) COLLATE DATABASE_DEFAULT,
 		currency_id         INT,
 		uom_id              INT,
 		counterparty_id     INT,
 		field_label			NVARCHAR(100) COLLATE DATABASE_DEFAULT,
		seq_no				INT,
		contract_id			INT,
		receive_pay			NCHAR(1)  COLLATE DATABASE_DEFAULT,
		fixed_fx_rate		NUMERIC(38,18)
	)
	DECLARE @where NVARCHAR(200) 
 	
	IF @source_deal_header_id IS NOT NULL
	BEGIN
 		SET @where = 'source_deal_header_id = ' + CAST(@source_deal_header_id AS NVARCHAR(10)) 
 
 		IF @view_deleted = 'n'
 		BEGIN
 			INSERT INTO #temp_deal_values
 			EXEC spa_Transpose 'source_deal_header', @where
 		END
 		ELSE
 		BEGIN
 			INSERT INTO #temp_deal_values
 			EXEC spa_Transpose 'delete_source_deal_header', @where
 	
 			INSERT INTO #temp_deal_values(field_name, field_value)
 			SELECT 'sub_book', ssbm.book_deal_type_map_id
 			FROM delete_source_deal_header dsdh 
 			LEFT JOIN source_system_book_map ssbm
 				ON ssbm.source_system_book_id1 = dsdh.source_system_book_id1
 				AND ssbm.source_system_book_id2 = dsdh.source_system_book_id2
 				AND ssbm.source_system_book_id3 = dsdh.source_system_book_id3
 				AND ssbm.source_system_book_id4 = dsdh.source_system_book_id4
 			WHERE dsdh.source_deal_header_id = @source_deal_header_id		
 		END	
 	
 		SET @sql = 'INSERT INTO #temp_deal_udf_values (field_name, field_value, currency_id, uom_id, counterparty_id, field_label, seq_no, contract_id, receive_pay)
 					SELECT CAST(uddf.udf_template_id AS NVARCHAR(20)), CAST(uddf.udf_value AS NVARCHAR(2000)), currency_id, uom_id, counterparty_id
						, uddft.Field_label, uddf.seq_no , uddf.contract_id, uddf.receive_pay 
 					FROM user_defined_deal_fields_template uddft    
 					INNER JOIN ' + CASE WHEN @view_deleted ='y' THEN 'delete_' ELSE '' END + 'user_defined_deal_fields uddf
 						ON  uddft.udf_template_id = uddf.udf_template_id
 						AND uddf.source_deal_header_id = ' + CAST(@source_deal_header_id AS NVARCHAR(20)) + '
 					WHERE uddft.template_id = ' + CAST(@template_id AS NVARCHAR(20))
 		EXEC(@sql)
	END
	ELSE
	BEGIN
 		SET @where = 'template_id = ' + CAST(@template_id AS NVARCHAR(10))
 		INSERT INTO #temp_deal_values
 		EXEC spa_Transpose 'source_deal_header_template', @where
	END
	
	IF @spot_or_term = 's'
	BEGIN
		UPDATE tdv
		SET field_value = st.[sub_type_id]
		-- SELECT *, st.[sub_type_id]
		FROM #temp_deal_values tdv
		OUTER APPLY(
			SELECT source_deal_type_id [sub_type_id]
			FROM source_deal_type sdt
			WHERE sub_type = 'y'
				AND deal_type_id = 'Spot'
		) st
		WHERE field_name = 'deal_sub_type_type_id'
	END

	UPDATE tdv
	SET tdv.field_value = dbo.FNAGetUserName(user_login_id)
	FROM #temp_deal_values tdv
	INNER JOIN application_users au on au.user_login_id = tdv.field_value AND tdv.field_name = 'create_user'
	WHERE tdv.field_value IS NOT NULL

	UPDATE tdv
	SET tdv.field_value =  dbo.FNAGetUserName(user_login_id)
	FROM #temp_deal_values tdv
	INNER JOIN application_users au on au.user_login_id = tdv.field_value AND tdv.field_name = 'update_user'
	WHERE tdv.field_value IS NOT NULL
 	
	SET @sql = CAST('' AS NVARCHAR(MAX)) + 'INSERT INTO #temp_deal_header_fields ([name], group_id, [label], [type], [data_type], [default_validation], [header_detail], [required], [sql_string], [inputWidth], [labelWidth],  [disabled], window_function_id, [udf_or_system], [seq_no], [hidden], [deal_value], [field_id], [update_required], [value_required], [open_ui_function_id], [block])
 				SELECT *, ROW_NUMBER() OVER(PARTITION BY field_group_id ORDER BY ISNULL(seq_no, 10000), default_label)% ' + CAST(@no_of_columns AS NVARCHAR(10)) + ' 
 				FROM   (
 							SELECT LOWER(f.farrms_field_id) farrms_field_id,
 									field_group_id,
 									CASE WHEN NULLIF(f.window_function_id, '''') IS NOT NULL THEN 
									    CASE WHEN d.field_caption = ''book1'' OR mfd.farrms_field_id = ''source_system_book_id1'' THEN ''<a id=''''''+CAST(f.window_function_id AS NVARCHAR)+'''''' href=''''javascript:void(0);'''' onclick=''''call_TRMWinHyperlink(''+CAST(f.window_function_id AS NVARCHAR(20))+'',this.id);''''>'' + ISNULL(sbmc.group1,''Group1'') + ''</a>'' 
											 WHEN d.field_caption = ''book2'' OR mfd.farrms_field_id = ''source_system_book_id2'' THEN ''<a id=''''''+CAST(f.window_function_id AS NVARCHAR)+'''''' href=''''javascript:void(0);'''' onclick=''''call_TRMWinHyperlink(''+CAST(f.window_function_id AS NVARCHAR(20))+'',this.id);''''>'' + ISNULL(sbmc.group2,''Group2'') + ''</a>'' 
											 WHEN d.field_caption = ''book3'' OR mfd.farrms_field_id = ''source_system_book_id3'' THEN ''<a id=''''''+CAST(f.window_function_id AS NVARCHAR)+'''''' href=''''javascript:void(0);'''' onclick=''''call_TRMWinHyperlink(''+CAST(f.window_function_id AS NVARCHAR(20))+'',this.id);''''>'' + ISNULL(sbmc.group1,''Group3'') + ''</a>'' 
											 WHEN d.field_caption = ''book4'' OR mfd.farrms_field_id = ''source_system_book_id4'' THEN ''<a id=''''''+CAST(f.window_function_id AS NVARCHAR)+'''''' href=''''javascript:void(0);'''' onclick=''''call_TRMWinHyperlink(''+CAST(f.window_function_id AS NVARCHAR(20))+'',this.id);''''>'' + ISNULL(sbmc.group1,''Group4'') + ''</a>'' 
 										ELSE
 											''<a id=''''''+CAST(f.farrms_field_id AS NVARCHAR)+'''''' href=''''javascript:void(0);'''' onclick=''''call_TRMWinHyperlink(''+CAST(f.window_function_id AS NVARCHAR(20))+'',this.id);''''>''+ISNULL(d.field_caption, f.default_label)+''</a>'' 
 										END
 									ELSE
										CASE WHEN d.field_caption = ''book1'' OR mfd.farrms_field_id = ''source_system_book_id1'' THEN ISNULL(sbmc.group1,''Group1'')
											 WHEN d.field_caption = ''book2'' OR mfd.farrms_field_id = ''source_system_book_id2'' THEN ISNULL(sbmc.Group2,''Group2'') 
											 WHEN d.field_caption = ''book3'' OR mfd.farrms_field_id = ''source_system_book_id3'' THEN ISNULL(sbmc.Group3,''Group3'')
											 WHEN d.field_caption = ''book4'' OR mfd.farrms_field_id = ''source_system_book_id4'' THEN ISNULL(sbmc.Group4,''Group4'')
 											 ELSE ISNULL(d.field_caption, f.default_label) 
 										END
 									END default_label,
 									ISNULL(f.field_type, ''t'') field_type,
 									f.[data_type],
 									f.[default_validation],
 									f.[header_detail],
 									ISNULL(d.value_required, ''n'') required,
 									f.[sql_string],
 									ISNULL(f.field_size,' + CAST(@default_field_size AS NCHAR(3)) + ') field_size,
 									CAST(f.[field_size] AS INT) labelWidth,
 									COALESCE(d.is_disable, f.is_disable, ''n'') is_disable,
 									f.window_function_id,
 									''s'' udf_or_system,
 									ISNULL(d.seq_no, 1000) seq_no,
 									ISNULL(d.hide_control, ''n'') hide_control,
 									' + CASE WHEN @source_deal_header_id IS NOT NULL THEN ' dv.field_value ' ELSE ' ISNULL(dv.field_value, d.default_value) ' END + ' deal_value,
 									CAST(f.field_id AS NVARCHAR) field_id,
 									d.update_required,
 									CASE WHEN d.value_required = ''y'' THEN ''true'' ELSE ''false'' END value_required,
									mfd.open_ui_function_id
 							FROM maintain_field_template_detail d
 							INNER JOIN maintain_field_deal mfd ON d.field_id = mfd.field_id
							INNER JOIN maintain_field_deal f ON  d.field_id = f.field_id
						   OUTER APPLY source_book_mapping_clm sbmc
 							INNER join #temp_header t on case when t.column_name=''buy_sell_flag'' then ''header_buy_sell_flag'' else t.column_name end = f.farrms_field_id
 							INNER JOIN #temp_deal_values dv ON CASE WHEN dv.field_name = ''buy_sell_flag'' THEN ''header_buy_sell_flag'' ELSE dv.field_name END = f.farrms_field_id
 							LEFT JOIN #temp_deal_type_mapping_header temp ON temp.column_name = f.farrms_field_id AND CAST(ISNULL(temp.col_value, 0) AS NVARCHAR(10)) = ''0''
							WHERE field_group_id IS NOT NULL 
 							AND f.header_detail=''h'' 
 							' + CASE WHEN @source_deal_header_id IS NOT NULL THEN ' AND ISNULL(d.update_required, ''n'') = ''y''' ELSE ' AND ISNULL(d.insert_required, ''n'') = ''y''' END + '
 							AND ISNULL(d.udf_or_system,''s'') = ''s'' 
							AND temp.id IS NULL
 							AND d.field_template_id = ' + CAST(@field_template_id AS NVARCHAR(500))
 	
	SET @sql = @sql + '	
	UNION ALL 	
	SELECT ''UDF___'' + CAST(udf_temp.udf_template_id AS NVARCHAR) udf_template_id,
 			field_group_id,
 			CASE WHEN NULLIF(udf_temp.window_id, '''') IS NOT NULL THEN 
 			''<a id=''''UDF___''+CAST(udf_temp.udf_template_id AS NVARCHAR)+'''''' href=''''javascript:void(0);'''' onclick=''''call_TRMWinHyperlink(''+CAST(udf_temp.window_id AS NVARCHAR(20))+'',this.id);''''>''+ISNULL(mftd.field_caption, udf_temp.Field_label)+''</a>''
 			ELSE
 				ISNULL(mftd.field_caption, udf_temp.Field_label) 
 			END default_label,
 			ISNULL(udf_temp.field_type, ''t'') field_type,
 			udf_temp.[data_type],
 			NULL [default_validation],
 			''h'' header_detail,
 			ISNULL(mftd.value_required, udf_temp.is_required) required,
 			ISNULL(NULLIF(udf_temp.sql_string, ''''), uds.sql_string) sql_string,
 			ISNULL(udf_temp.field_size,' + CAST(@default_field_size AS NCHAR(3)) + ') field_size,			
 			CAST(udf_temp.[field_size] AS INT) ,
 			ISNULL(mftd.is_disable, ''n''),
 			udf_temp.window_id window_function_id,
 			''u'' udf_or_system,
 			ISNULL(mftd.seq_no, 1000) seq_no,
 			ISNULL(mftd.hide_control, ''n'') hide_control,
 			CASE WHEN tduf.field_name IS NULL THEN ISNULL(uddft.default_value, mftd.default_value) ELSE tduf.field_value END,
 			''u--''+cast(mftd.field_id as NVARCHAR) field_id,
 			mftd.update_required,
 			CASE WHEN mftd.value_required = ''y'' THEN ''true'' ELSE ''false'' END value_required,
			NULL
	FROM user_defined_fields_template udf_temp
	INNER JOIN maintain_field_template_detail mftd
 		ON  udf_temp.udf_template_id = mftd.field_id 
 		AND mftd.field_template_id = ' + CAST(@field_template_id AS NVARCHAR(20)) +'
 		AND ISNULL(mftd.udf_or_system, ''s'') = ''u''
	INNER JOIN user_defined_deal_fields_template uddft ON uddft.field_id = udf_temp.field_id AND uddft.template_id = ' + CAST(@template_id AS NVARCHAR(20)) + ' AND uddft.udf_template_id > 0
	LEFT JOIN #temp_deal_udf_values tduf ON uddft.udf_template_id = tduf.field_name
	LEFT JOIN udf_data_source uds ON uds.udf_data_source_id = udf_temp.data_source_type_id  	      
	WHERE field_group_id IS NOT NULL
	AND udf_temp.udf_type = ''h''
	' + CASE WHEN @source_deal_header_id IS NOT NULL THEN ' AND ISNULL(mftd.update_required, ''n'') = ''y''' ELSE ' AND ISNULL(mftd.insert_required, ''n'') = ''y''' END

	SET @sql = @sql + '	
	UNION ALL 	
	SELECT ''UDF___'' + CAST(tduf.field_name AS NVARCHAR) udf_template_id,
 			0,
 			CASE WHEN NULLIF(udf_temp.window_id, '''') IS NOT NULL THEN 
 			''<a id=''''UDF___''+CAST(udf_temp.udf_template_id AS NVARCHAR)+'''''' href=''''javascript:void(0);'''' onclick=''''call_TRMWinHyperlink(''+CAST(udf_temp.window_id AS NVARCHAR(20))+'',this.id);''''>''+udf_temp.Field_label+''</a>''
 			ELSE udf_temp.Field_label
 			END default_label,
 			ISNULL(udf_temp.field_type, ''t'') field_type,
 			udf_temp.[data_type],
 			NULL [default_validation],
 			''h'' header_detail,
 			ISNULL(udf_temp.is_required, ''n'') required,
 			ISNULL(NULLIF(udf_temp.sql_string, ''''), uds.sql_string) sql_string,
 			ISNULL(udf_temp.field_size,' + CAST(@default_field_size AS NCHAR(3)) + ') field_size,			
 			CAST(udf_temp.[field_size] AS INT) ,
 			''n'',
 			udf_temp.window_id window_function_id,
 			''u'' udf_or_system,
 			1000 + tduf.seq_no seq_no,
 			''n'' hide_control,
 			tduf.field_value,
 			''u--'' + cast(tduf.field_name as NVARCHAR) field_id,
 			''y'',
 			CASE WHEN udf_temp.is_required = ''y'' THEN ''true'' ELSE ''false'' END value_required,
			NULL
	FROM #temp_deal_udf_values tduf
	INNER JOIN user_defined_fields_template udf_temp ON udf_temp.udf_template_id = ABS(tduf.field_name)
	LEFT JOIN udf_data_source uds ON uds.udf_data_source_id = udf_temp.data_source_type_id
	WHERE tduf.field_name < 0 AND udf_temp.udf_type = ''h'' AND ISNULL(udf_temp.deal_udf_type, ''x'') <> ''c'' '
 	
	SET @sql = @sql + ') a ORDER BY field_group_id,ISNULL(a.seq_no, 10000), default_label' 
	--PRINT(@sql)
	EXEC(@sql)

	SELECT @formula_fields_header = COALESCE(@formula_fields_header + ',', '') + [name]
 	FROM #temp_deal_header_fields
 	WHERE [type] = 'w'
 	
	--Disable template field on update mode
	UPDATE #temp_deal_header_fields
	SET [disabled] = 'y'
	WHERE [name] = 'template_id'

	IF EXISTS(SELECT 1 FROM #temp_deal_header_fields WHERE [name] = 'collateral_amount' OR [name] = 'collateral_months' OR [name] = 'collateral_req_per') AND @source_deal_header_id IS NOT NULL
	BEGIN
		DECLARE @max_collateral_seq INT
		SELECT @max_collateral_seq = MAX(seq_no)
		FROM #temp_deal_header_fields
 		WHERE [name] = 'collateral_amount' OR [name] = 'collateral_months' OR [name] = 'collateral_req_per'

		INSERT INTO #temp_deal_header_fields ([name], group_id, [label], [type], [data_type], [default_validation], [header_detail], [required], [sql_string], [inputWidth], [labelWidth],  
		[disabled], window_function_id, [udf_or_system], [seq_no], [hidden], [deal_value], [field_id], [update_required], [value_required], [block])
		SELECT TOP(1) 'collateral_link',
 				group_id,
 				NULL,
 				'z' field_type,
 				NULL,
 				NULL,
 				'h',
 				NULL,
 				NULL,
 				[inputWidth],
 				labelWidth,
 				NULL,
 				NULL,
 				's',
 				@max_collateral_seq+1,
 				[hidden],
 				'Collateral',
 				NULL,
 				NULL,
 				NULL value_required,
 				500
 		FROM #temp_deal_header_fields f 
 		WHERE ([name] = 'collateral_amount' OR [name] = 'collateral_months' OR [name] = 'collateral_req_per')
		AND [seq_no] = @max_collateral_seq

		UPDATE temp 
		SET block = t2.[block]
		FROM #temp_deal_header_fields temp
		INNER JOIN (
			SELECT ROW_NUMBER() OVER(PARTITION BY t1.group_id ORDER BY ISNULL(t1.seq_no, 10000))%@no_of_columns [block], t1.name
			FROM #temp_deal_header_fields t1
		) t2 ON temp.name = t2.name
	END

	DECLARE @active_tab_id INT, @min_block_id INT, @initial_vol_type INT, @initial_granularity INT, @initial_deal_volume_freq INT
 	IF @source_deal_header_id IS NULL
	BEGIN		
		SELECT @active_tab_id = id
		FROM #temp_deal_tabs WHERE active = 'true'
		
		SELECT TOP(1) @min_block_id = [block]
		FROM #temp_deal_header_fields
		WHERE group_id = @active_tab_id
		
		DECLARE @has_new NCHAR(1) = 'n'
		
		IF NOT EXISTS (SELECT 1 FROM #temp_deal_header_fields WHERE name = 'sub_book')
		BEGIN
			SET @has_new = 'y'
			INSERT INTO #temp_deal_header_fields ([name], group_id, [label], [type], [data_type], [default_validation], [header_detail], [required], [sql_string], [inputWidth], [labelWidth],  
			[disabled], window_function_id, [udf_or_system], [seq_no], [hidden], [deal_value], [field_id], [update_required], [value_required], [block])
			SELECT LOWER(f.farrms_field_id) farrms_field_id,
 					@active_tab_id,
 					f.default_label default_label,
 					'd' field_type,
 					f.[data_type],
 					f.[default_validation],
 					f.[header_detail],
 					'y' required,
 					f.[sql_string],
 					f.[field_size],
 					CAST(f.[field_size] AS INT) + 10 labelWidth,
 					'n' is_disable,
 					f.window_function_id,
 					's' udf_or_system,
 					-1 seq_no,
 					'n' hide_control,
 					@sub_book deal_value,
 					f.field_id field_id,
 					'y',
 					'true' value_required,
 					@min_block_id
 			FROM maintain_field_deal f 
 			WHERE f.farrms_field_id = 'sub_book' AND f.header_detail = 'h'
		END

		--## Add Logical Term Field for insert mode
		INSERT INTO #temp_deal_header_fields ([name], group_id, [label], [type], [data_type], [default_validation], [header_detail], [required], [sql_string], [inputWidth], [labelWidth],  
			[disabled], window_function_id, [udf_or_system], [seq_no], [hidden], [deal_value], [field_id], [update_required], [value_required], [block])
		SELECT TOP(1) 'logical_term',
 				group_id,
 				'Logical Term',
 				'd' field_type,
 				NULL,
 				NULL,
 				'h',
 				NULL,
 				NULL,
 				[inputWidth],
 				labelWidth,
 				NULL,
 				NULL,
 				'e',
 				seq_no,
 				[hidden],
 				NULL,
 				NULL,
 				NULL,
 				NULL,
 				[block]
			FROM #temp_deal_header_fields
			WHERE [name] = 'deal_date'
	END

	IF NOT EXISTS (SELECT 1 FROM #temp_deal_header_fields WHERE name = 'profile_granularity')
	BEGIN
		SET @has_new = 'y'
		--sdht.internal_desk_id = 17302
		IF @source_deal_header_id IS NULL
		BEGIN
			SELECT @initial_vol_type = sdht.internal_desk_id
			FROM source_deal_header_template sdht
			WHERE sdht.template_id = @template_id

			SELECT TOP(1) @initial_deal_volume_freq = CASE sddt.deal_volume_frequency
			                                            WHEN 'x' THEN 987
			                                            WHEN 'y' THEN 989
			                                            WHEN 'a' THEN 993
			                                            WHEN 'd' THEN 981
			                                            WHEN 'h' THEN 982
			                                            WHEN 'm' THEN 980
			                                            ELSE NULL
			                                        END 
			FROM source_deal_detail_template sddt
			WHERE sddt.template_id = @template_id

			SELECT @initial_granularity = CASE WHEN sdht.internal_desk_id = 17302 THEN COALESCE(sdht.profile_granularity, sdht.hourly_position_breakdown, 982) ELSE @initial_deal_volume_freq END
			FROM source_deal_header_template sdht
			WHERE sdht.template_id = @template_id
		END
		ELSE
		BEGIN
			SELECT @initial_vol_type = sdh.internal_desk_id
			FROM source_deal_header sdh
			WHERE sdh.source_deal_header_id = @source_deal_header_id

			SELECT TOP(1) @initial_deal_volume_freq = CASE sdd.deal_volume_frequency
			                                            WHEN 'x' THEN 987
			                                            WHEN 'y' THEN 989
			                                            WHEN 'a' THEN 993
			                                            WHEN 'd' THEN 981
			                                            WHEN 'h' THEN 982
			                                            WHEN 'm' THEN 980
			                                            ELSE NULL
			                                        END 
			FROM source_deal_detail sdd
			WHERE sdd.source_deal_header_id = @source_deal_header_id

			SELECT @initial_granularity = CASE WHEN sdh.internal_desk_id = 17302 THEN sdh.profile_granularity ELSE @initial_deal_volume_freq END
			FROM source_deal_header sdh
			WHERE sdh.source_deal_header_id = @source_deal_header_id
		END
			
		DECLARE @internal_desk_seq INT			
			
		IF EXISTS(SELECT 1 FROM #temp_deal_header_fields WHERE name = 'internal_desk_id')
		BEGIN
			SELECT @internal_desk_seq = seq_no
			FROM #temp_deal_header_fields
			WHERE name = 'internal_desk_id'
			
			SELECT @active_tab_id = group_id
			FROM #temp_deal_header_fields
			WHERE name = 'internal_desk_id'
		END 
			
		INSERT INTO #temp_deal_header_fields ([name], group_id, [label], [type], [data_type], [default_validation], [header_detail], [required], [sql_string], [inputWidth], [labelWidth],  
		[disabled], window_function_id, [udf_or_system], [seq_no], [hidden], [deal_value], [field_id], [update_required], [value_required], [block], [open_ui_function_id])
		SELECT LOWER(f.farrms_field_id) farrms_field_id,
 				@active_tab_id,
 				f.default_label default_label,
 				'd' field_type,
 				f.[data_type],
 				f.[default_validation],
 				f.[header_detail],
 				'y' required,
 				f.[sql_string],
 				f.[field_size],
 				CAST(f.[field_size] AS INT) + 10 labelWidth,
 				CASE WHEN @initial_vol_type = 17302 THEN 'n' ELSE 'y' END is_disable,
 				f.window_function_id,
 				's' udf_or_system,
 				ISNULL(@internal_desk_seq, 1) + 1000 seq_no,
 				CASE WHEN @initial_vol_type = 17302 THEN 'n' ELSE 'y' END hide_control,
 				@initial_granularity deal_value,
 				f.field_id field_id,
 				'y',
 				'true' value_required,
 				@min_block_id,
				f.open_ui_function_id
 		FROM maintain_field_deal f 
 		WHERE f.farrms_field_id = 'profile_granularity' AND f.header_detail = 'h'
	END
		
	IF @has_new = 'y'
	BEGIN
		UPDATE temp 
		SET block = t2.[block]
		FROM #temp_deal_header_fields temp
		INNER JOIN (
			SELECT ROW_NUMBER() OVER(PARTITION BY t1.group_id ORDER BY ISNULL(t1.seq_no, 10000))%@no_of_columns [block], t1.name
			FROM #temp_deal_header_fields t1
		) t2 ON temp.name = t2.name
	END
	
	IF @copy_deal_id IS NOT NULL
	BEGIN
 		UPDATE #temp_deal_header_fields
 		SET deal_value = NULL
 		WHERE name = 'source_deal_header_id'
 		
 		UPDATE #temp_deal_header_fields
 		SET deal_value = 'COPY_' + CAST(@copy_deal_id AS NVARCHAR(20))
 		WHERE name = 'deal_id'
	END
 	
	IF @source_deal_header_id IS NULL OR @copy_deal_id IS NOT NULL 
	BEGIN
 		UPDATE #temp_deal_header_fields
 		SET [required] = 'n'
 		WHERE name = 'deal_id' 

 		UPDATE #temp_deal_header_fields
 		SET deal_value = @default_deal_date
 		WHERE name = 'deal_date' AND NULLIF(deal_value, '') IS NULL
 		
 		DECLARE @trader_id INT
		SELECT @trader_id = st.source_trader_id
		FROM source_traders st
		WHERE st.user_login_id = dbo.FNADBUser()
		
		UPDATE #temp_deal_header_fields 
		SET deal_value = ISNULL(@trader_id, deal_value)
		WHERE name = 'trader_id'	

		UPDATE #temp_deal_header_fields 
		SET deal_value = @deal_type_id
		WHERE name = 'source_deal_type_id'

		UPDATE #temp_deal_header_fields 
		SET deal_value = @commodity_id
		WHERE name = 'commodity_id'
	END
	
	IF @source_deal_header_id IS NOT NULL
	BEGIN
		UPDATE temp
		SET deal_value = sb.book_deal_type_map_id
		FROM #temp_deal_header_fields temp
		OUTER APPLY (
 			SELECT ssbm.book_deal_type_map_id
 			FROM source_deal_header sdh
 			LEFT JOIN source_system_book_map ssbm
 				ON ssbm.source_system_book_id1 = sdh.source_system_book_id1
 				AND ssbm.source_system_book_id2 = sdh.source_system_book_id2
 				AND ssbm.source_system_book_id3 = sdh.source_system_book_id3
 				AND ssbm.source_system_book_id4 = sdh.source_system_book_id4
 			WHERE sdh.source_deal_header_id = @source_deal_header_id
		) sb
		WHERE name = 'sub_book' 
	END
	
	IF EXISTS(SELECT 1 FROM #temp_deal_header_fields WHERE name = 'underlying_options')
	BEGIN
		SELECT @underlying_options_mapping = ddv.underlying_options
		FROM deal_default_value ddv
		WHERE deal_type_id = @deal_type_id 
		AND ISNULL(commodity, -1) = ISNULL(@commodity_id, '')
		AND ((pricing_type IS NULL AND @pricing_type IS NULL) OR pricing_type = @pricing_type)
		AND (buy_sell_flag IS NULL OR ISNULL(buy_sell_flag, 'x') = ISNULL(@default_header_buy_sell_flag, 'y'))
		
		UPDATE temp
		SET deal_value = @underlying_options_mapping
		FROM #temp_deal_header_fields temp
		WHERE name = 'underlying_options'
	END 
	
	IF EXISTS(SELECT 1 FROM #temp_deal_header_fields WHERE name = 'internal_counterparty' AND NULLIF(deal_value,'') IS NULL) AND @source_deal_header_id IS NULL
	BEGIN
		DECLARE @transfer_rules_cpty INT
		SELECT @transfer_rules_cpty = counterparty_id_to FROM deal_transfer_mapping 
			WHERE source_book_mapping_id_from = @sub_book

		DECLARE @internal_cpty_id INT
		
		SELECT @internal_cpty_id = COALESCE(@transfer_rules_cpty, ssbm.primary_counterparty_id, fb.primary_counterparty_id, fst.primary_counterparty_id, fs.counterparty_id)
		FROM source_system_book_map ssbm
		INNER JOIN fas_books fb ON fb.fas_book_id = ssbm.fas_book_id
		INNER JOIN portfolio_hierarchy ph_book ON ph_book.[entity_id] = fb.fas_book_id
		INNER JOIN portfolio_hierarchy ph_st ON ph_st.[entity_id] = ph_book.parent_entity_id
		INNER JOIN portfolio_hierarchy ph_sub ON ph_sub.[entity_id] = ph_st.parent_entity_id
		INNER JOIN fas_subsidiaries fs ON ph_sub.[entity_id] = fs.fas_subsidiary_id
		INNER JOIN fas_strategy fst ON ph_st.[entity_id] = fst.fas_strategy_id
		WHERE ssbm.book_deal_type_map_id = @sub_book
		
		SELECT @internal_cpty_id = ISNULL(@internal_cpty_id, counterparty_id)
		FROM   fas_subsidiaries
		WHERE fas_subsidiary_id = -1		
		
		UPDATE temp
		SET deal_value = @internal_cpty_id
		FROM #temp_deal_header_fields temp
		WHERE name = 'internal_counterparty'
	END 
	
	IF EXISTS(SELECT 1 FROM #temp_deal_header_fields WHERE [name] = 'entire_term_end') AND @is_gas_daily = 'y'
	BEGIN
		UPDATE #temp_deal_header_fields
		SET deal_value = CONVERT(NVARCHAR(10), DATEADD(d, 1, deal_value), 120)
		WHERE [name] = 'entire_term_end'
	END
	
 	UPDATE #temp_deal_header_fields
	SET connector = 'js_dropdown_connector_v2_url+"&call_from=deal&deal_id=' + ISNULL(CAST(@source_deal_header_id AS NVARCHAR(50)), '') + '&template_id=' + ISNULL(CAST(@template_id AS NVARCHAR(50)), '') + '&farrms_field_id=' + [name] + '&default_value=' + ISNULL(CAST(deal_value AS NVARCHAR(50)), '') + '&is_udf=' + udf_or_system + '&required=' + ISNULL([required], '') + '&deal_type_id=' + ISNULL(CAST(@deal_type_id AS NVARCHAR(50)), '') + '&commodity_id=' + ISNULL(CAST(@commodity_id AS NVARCHAR(50)), '') + '"'
	WHERE [type] IN ('d', 'c')
	
	DECLARE dropdown_cursor CURSOR FORWARD_ONLY READ_ONLY
	FOR
 		SELECT name,
 				sql_string,
 				deal_value,
 				value_required           
 		FROM #temp_deal_header_fields
 		WHERE [type] IN ('d', 'c') AND sql_string IS NOT NULL AND NULLIF(deal_value, '') IS NOT NULL
	OPEN dropdown_cursor
	FETCH NEXT FROM dropdown_cursor INTO @name, @sql_string, @deal_value, @is_required                                        
	WHILE @@FETCH_STATUS = 0
	BEGIN
 		DECLARE @json NVARCHAR(MAX)
 		DECLARE @nsql NVARCHAR(MAX)
 		SET @json = NULL
 		
		IF OBJECT_ID('tempdb..#temp_combo_options') IS NOT NULL
 			DROP TABLE #temp_combo_options

		CREATE TABLE #temp_combo_options ([value] NVARCHAR(10) COLLATE DATABASE_DEFAULT, [text] NVARCHAR(1000) COLLATE DATABASE_DEFAULT, selected NVARCHAR(10) COLLATE DATABASE_DEFAULT, [state] NVARCHAR(10) COLLATE DATABASE_DEFAULT)

 		IF @name <> 'contract_id' AND @name <> 'counterparty_id' AND @name <> 'counterparty_trader' AND @name <> 'counterparty2_trader'
 		BEGIN
 			IF @is_required = 'false'
 			BEGIN
 				INSERT INTO #temp_combo_options([value], [text])
 				SELECT '', ''
 			END
 			
 			DECLARE @type NCHAR(1)
 			SET @type = SUBSTRING(@sql_string, 1, 1)
 			
 			IF @type = '['
 			BEGIN
 				SET @sql_string = REPLACE(@sql_string, NCHAR(13), '')
 				SET @sql_string = REPLACE(@sql_string, NCHAR(10), '')
 				SET @sql_string = REPLACE(@sql_string, NCHAR(32), '')	
 				SET @sql_string = [dbo].[FNAParseStringIntoTable](@sql_string)  
 				EXEC('INSERT INTO #temp_combo_options([value], [text])
 						SELECT value_id, code from (' + @sql_string + ') a(value_id, code)');
 			END
 			ELSE
 			BEGIN
				--## Pass filter value for combo in case of default value to get only required options
				IF ((SELECT CHARINDEX('<FILTER_VALUE>', @sql_string)) > 0)
				BEGIN
					IF NULLIF(@deal_value, '') IS NOT NULL 
						SELECT @sql_string = REPLACE(@sql_string, '<FILTER_VALUE>', @deal_value)
					ELSE IF @is_required = 'y' --If required and default value none pass -1 as default value to get one default option
						SELECT @sql_string = REPLACE(@sql_string, '<FILTER_VALUE>', '-1')
				END

				BEGIN TRY
 					INSERT INTO #temp_combo_options([value], [text], [state])
 					EXEC(@sql_string)
				END TRY
				BEGIN CATCH
					INSERT INTO #temp_combo_options([value], [text])
 					EXEC(@sql_string)
				END CATCH
 			END

 			UPDATE #temp_combo_options
 			SET selected = 'true'			
 			WHERE value = @deal_value
 			
 			IF @name = 'template_id'
 			BEGIN
 				INSERT INTO #temp_combo_options([value], [text], selected)
 				SELECT sdht.template_id, sdht.template_name, 'true'
 				FROM source_deal_header_template sdht 
 				LEFT JOIN #temp_combo_options temp ON temp.value = sdht.template_id
 				WHERE sdht.template_id = @template_id AND temp.value IS NULL
 			END
 			
 			IF NOT EXISTS (SELECT 1 FROM #temp_combo_options WHERE value = @deal_value)
 			BEGIN
 				UPDATE #temp_deal_header_fields
 				SET deal_value = NULL
 				WHERE name = @name
 			END
 		END
 		ELSE 
 		BEGIN
 			IF @source_deal_header_id IS NOT NULL
 			BEGIN
				SET @combo_process_table = dbo.FNAProcessTableName('combo_options_process', @combo_user_name, @combo_process_id)
				
 				EXEC spa_deal_fields_mapping @flag='c',@deal_id=@source_deal_header_id,@deal_fields=@name,@default_value=@deal_value, @process_table = @combo_process_table

				SET @sql = 'INSERT INTO #temp_combo_options ([value], [text], [state], [selected])
 							SELECT [value], [text], [state], [selected]
 							FROM ' + @combo_process_table
 				EXEC(@sql)

				SET @sql = dbo.FNAProcessDeleteTableSql(@combo_process_table)
				EXEC (@sql)
 			END		
 		END

		--## IF field is required but no default value then set one option by default
		-- Backward Compatibility if filter value method not implemented in dropdown query starts
		IF @is_required = 'y' AND NULLIF(@deal_value, '') IS NULL
		BEGIN
			SELECT TOP 1 @deal_value =  [value]
			FROM #temp_combo_options
			WHERE NULLIF([value], '') IS NOT NULL
			ORDER BY [text]
		END
		
		DELETE tc
		FROM #temp_combo_options tc
		LEFT JOIN dbo.SplitCommaSeperatedValues(@deal_value) s ON s.item = tc.[value]
		WHERE s.item IS NULL
		-- Backward Compatibility if filter value method not implemented in dropdown query ends
		
		DECLARE @dropdown_xml XML
 		DECLARE @param NVARCHAR(100)
 		SET @param = N'@dropdown_xml XML OUTPUT';
		
 		SET @nsql = ' SET @dropdown_xml = (SELECT [value], REPLACE([text], ''"'', ''\"'') [text], [selected]
 						FROM #temp_combo_options 
 						FOR XML RAW (''row''), ROOT (''root''), ELEMENTS)'
 		
 		EXECUTE sp_executesql @nsql, @param, @dropdown_xml = @dropdown_xml OUTPUT;
 		
 		SET @json = dbo.FNAFlattenedJSON(@dropdown_xml)
		
 		IF CHARINDEX('[', @json, 0) <= 0
 			SET @json = '[' + @json + ']'
 
 		UPDATE #temp_deal_header_fields
 		SET dropdown_json = REPLACE(@json, '\/', '/')
 		WHERE [name] = @name
 	
 		FETCH NEXT FROM dropdown_cursor INTO @name, @sql_string, @deal_value, @is_required    
	END
	CLOSE dropdown_cursor
	DEALLOCATE dropdown_cursor
	
	IF OBJECT_ID('tempdb..#temp_deal_header_form_json') IS NOT NULL
 		DROP TABLE #temp_deal_header_form_json
 	
	CREATE TABLE #temp_deal_header_form_json(
 		tab_id		  NVARCHAR(10) COLLATE DATABASE_DEFAULT,
 		tab_json      NVARCHAR(MAX) COLLATE DATABASE_DEFAULT,
 		form_json     NVARCHAR(MAX) COLLATE DATABASE_DEFAULT,
 		tab_seq		  INT,
 		tab_sql		  NVARCHAR(MAX) COLLATE DATABASE_DEFAULT,
 		process_id	  NVARCHAR(100) COLLATE DATABASE_DEFAULT,
 		header_formula_fields NVARCHAR(1000) COLLATE DATABASE_DEFAULT,
		grid_json	  NVARCHAR(1000) COLLATE DATABASE_DEFAULT
	)
 	 	
	DECLARE @header_costs_table NVARCHAR(2000)
	SET @header_costs_table = dbo.FNAProcessTableName('header_costs_table', @user_name, @udf_process_id)

	IF OBJECT_ID(@header_costs_table) IS NULL
	BEGIN	
		EXEC('CREATE TABLE ' + @header_costs_table + '(
			id					INT IDENTITY(1,1),
 			udf_id				NVARCHAR(20),
 			udf_name            NVARCHAR(MAX),
 			udf_value           NVARCHAR(MAX),
 			currency_id         INT,
 			uom_id              INT,
 			counterparty_id     INT,
			seq_no				INT,
			internal_type_id	INT,
			charge_type		    NVARCHAR(100),
			contract_id			INT,
			receive_pay		    NCHAR(1),
			udf_field_type		NCHAR(1),
			settlement_date		DATETIME, 
			settlement_calendar NVARCHAR(20), 
			settlement_days		NVARCHAR(20),	
			payment_date		DATETIME, 
			payment_calendar	NVARCHAR(20),
			payment_days		NVARCHAR(20),
			fixed_fx_rate		NUMERIC(38, 18)
		)')
	END
	

	DECLARE @header_udf_table NVARCHAR(2000)
	SET @header_udf_table = dbo.FNAProcessTableName('header_udf_table', @user_name, @udf_process_id)
 	
	IF OBJECT_ID(@header_udf_table) IS NULL
	BEGIN
		EXEC('CREATE TABLE ' + @header_udf_table + '(
			id					INT IDENTITY(1,1),
 			udf_id				NVARCHAR(20),
 			udf_name            NVARCHAR(100),
 			udf_value           NVARCHAR(MAX),
 			currency_id         int,
 			uom_id              int,
 			counterparty_id     int,
			seq_no				int,
			charge_type		    NVARCHAR(100)
		)')
	END

	IF @enable_udf_tab = 'y'
	BEGIN
		IF @source_deal_header_id IS NOT NULL
		BEGIN
			SET @sql = 'INSERT INTO ' + @header_udf_table + '(udf_id, udf_name, udf_value, seq_no)
						SELECT tduf.field_name, udf_temp.Field_label, tduf.field_value, 1000 + ROW_NUMBER() OVER(ORDER BY tduf.field_name)    
						FROM #temp_deal_udf_values tduf
						INNER JOIN user_defined_fields_template udf_temp ON udf_temp.udf_template_id = ABS(tduf.field_name)
						WHERE tduf.field_name < 0 AND udf_temp.udf_type = ''h'' AND ISNULL(udf_temp.deal_udf_type, ''x'') <> ''c'' 
						'	

			--PRINT @sql
			EXEC(@sql)
		END
 	END
	
	DECLARE @source_deal_type_id INT
	SELECT @source_deal_type_id = source_deal_type_id FROM source_deal_header WHERE source_deal_header_id = @source_deal_header_id 
 	
	DECLARE @tab_id INT, @tab_seq INT, @default_tab INT, @next_tab_active NCHAR(1) = 'n'
	DECLARE tab_cursor CURSOR FORWARD_ONLY READ_ONLY 
	FOR
 		SELECT id, seq_no, default_tab          
 		FROM #temp_deal_tabs 
 		ORDER BY seq_no
	OPEN tab_cursor
	FETCH NEXT FROM tab_cursor INTO @tab_id, @tab_seq, @default_tab                                   
	WHILE @@FETCH_STATUS = 0
	BEGIN
 		IF ISNULL(@default_tab, 0) <> 1
 		BEGIN
 			IF @next_tab_active = 'y'
 			BEGIN
 				UPDATE #temp_deal_tabs
 				SET active = 'true'
 				WHERE id = @tab_id
 				
 				SET @next_tab_active = 'n'
 			END
 			DECLARE @tab_form_json NVARCHAR(MAX) = '',
 					@tab_xml      NVARCHAR(MAX)
 		
 			DECLARE @setting_xml NVARCHAR(2000)
 			SET @setting_xml = (
 								SELECT 'settings' [type],
 										'label-top' [position],
 										'230' labelWidth,
 										'230' inputWidth
 								FOR xml RAW('formxml'), ROOT('root'), ELEMENTS
 			)
 			SELECT @tab_form_json = '[' + dbo.FNAFlattenedJSON(@setting_xml)
 			
 			IF EXISTS(SELECT 1 FROM #temp_deal_tabs WHERE id = @tab_id AND active = 'true')
 			BEGIN
 				IF NOT EXISTS(SELECT 1 FROM #temp_deal_header_fields WHERE group_id = @tab_id)
 				BEGIN
 					SET @next_tab_active = 'y'
 				END
 			END 
 		        
 			SET @tab_xml = (
 				SELECT [id],
 						[text],
 						active
 				FROM #temp_deal_tabs
 				WHERE id = @tab_id
 				FOR xml RAW('tab'), ROOT('root'), ELEMENTS
 			)

 			DECLARE @block_id INT
 			DECLARE block_cursor CURSOR FORWARD_ONLY READ_ONLY 
 			FOR
 				SELECT block         
 				FROM #temp_deal_header_fields
 				WHERE group_id = @tab_id
 				GROUP BY hidden, block
 				ORDER BY hidden ,ISNULL(NULLIF(block, 0), 100)
 			OPEN block_cursor
 			FETCH NEXT FROM block_cursor INTO @block_id                                      
 			WHILE @@FETCH_STATUS = 0
 			BEGIN
 				DECLARE @form_xml NVARCHAR(MAX)			
 				DECLARE @block_json NVARCHAR(2000) = '{type:"block", blockOffset:0, offsetLeft:' + CAST(@default_offsetleft AS NCHAR(3)) + ', list:'
 
 				SET @form_xml = (   
 								SELECT CASE [type]
 											WHEN 'c' THEN 'combo'
 											WHEN 'd' THEN 'combo'
 											WHEN 'l' THEN 'input'
 											WHEN 't' THEN 'input'
										WHEN 'e' THEN 'time'
 											WHEN 'a' THEN 'calendar'
 											WHEN 'w' THEN 'input'
 											WHEN 'm' THEN 'input'
											WHEN 'z' THEN 'template'
 										END [type],
 										CASE [type]
 											WHEN 'c' THEN 'true'
 											WHEN 'd' THEN 'true'
 											ELSE NULL
 										END filtering,
 										CASE [type]
 											WHEN 'c' THEN 'between'
 											WHEN 'd' THEN 'between'
 											ELSE NULL
 										END filtering_mode,
 										name,
 										REPLACE(label, '"', '\"') label,
 										CASE 
											WHEN [type] = 'z' THEN NULL
 											WHEN [required] = 'y' THEN 'true'
 											ELSE 'false'
 										END [required],
 										dropdown_json AS [options],
 										connector AS [connector],
 										CASE 
											WHEN [type] = 'z' THEN NULL
 											WHEN [disabled] = 'y' THEN 'true'
 											ELSE 'false'
 										END [disabled],
 										inputWidth,
 										labelWidth,
										0 as offsetLeft,
 										CASE 
 											WHEN [type] = 'z' THEN NULL
 											WHEN [hidden] = 'y' THEN 'true'
 											ELSE 'false'
 										END [hidden],
										REPLACE(CASE 
											WHEN name IN ('update_ts','create_ts') THEN CONVERT(NVARCHAR, dbo.FNAConvertTimezone(NULLIF(deal_value, ''), 0),20) -- Column values must be exact same data type. FNAConvertTimezone returns datetime which is further converted to required NVARCHAR serverDateFormat :"%Y-%m-%d %H:%i:%s"
											ELSE CASE 
													WHEN [type] = 'a' THEN dbo.FNAGetSQLStandardDate(NULLIF(deal_value, ''))
													ELSE CASE 
														WHEN data_type IN ('price','number','numeric')THEN dbo.FNARemoveTrailingZero(NULLIF(deal_value, ''))
														ELSE CAST(NULLIF(deal_value, '') AS NVARCHAR(MAX))
														END
													END
										END, '"', '\"') AS [value],
 										NULL [position],
 										seq_no,
 										CASE WHEN [type] = 'a' THEN '%Y-%m-%d' ELSE NULL END + CASE WHEN name IN ('update_ts', 'create_ts') THEN ' %H:%i:%s' ELSE '' END [serverDateFormat],
 										CASE WHEN [type] = 'a' THEN COALESCE(dbo.FNAChangeDateFormat(), '%Y-%m-%d') ELSE NULL END + CASE WHEN name IN ('update_ts', 'create_ts') THEN ' %H:%i:%s' ELSE '' END [dateFormat],
 										CASE WHEN value_required = 'true' THEN 'NotEmptywithSpace' ELSE NULL END + CASE WHEN data_type = 'int' THEN ',ValidInteger' WHEN data_type IN ('price','number') THEN ',ValidNumeric' ELSE '' END [validate],
 										'{' +
										CASE
											WHEN [type] = 'w' THEN '"is_formula": "y", "formula_id": "' + ISNULL(deal_value, '') + '"'
											WHEN value_required = 'true' THEN '"validation_message": "Invalid data", "is_formula": "n"'
											ELSE '"is_formula": "n"'
										END + 
										IIF(open_ui_function_id IS NOT NULL, ', "data_window_info": "' + af.file_path + '"', '') + '}' [userdata],
 										CASE WHEN [type] = 'm' THEN 3 ELSE NULL END [rows],
										CASE WHEN [type] = 'z' AND name = 'collateral_link' THEN 'collateral_hyperlink' ELSE NULL END [format]
 								FROM #temp_deal_header_fields
								LEFT JOIN application_functions af ON af.function_id = open_ui_function_id
 								WHERE group_id = @tab_id
 								AND block = @block_id	
 								ORDER BY seq_no								
 								FOR xml RAW('formxml'), ROOT('root'), ELEMENTS
 				)
				
 				DECLARE @temp_form_json NVARCHAR(MAX) = dbo.FNAFlattenedJSON(@form_xml)
 				IF SUBSTRING(@temp_form_json, 1, 1) <> '['
 				BEGIN
 					SET @temp_form_json = '[' + @temp_form_json + ']'
 				END

 				SET @tab_form_json = COALESCE(@tab_form_json + ',', '') + @block_json + @temp_form_json + '},{type:"newcolumn"}'
 				FETCH NEXT FROM block_cursor INTO @block_id   
 			END
 			CLOSE block_cursor
 			DEALLOCATE block_cursor
 		
			IF EXISTS (SELECT 1 FROM source_deal_type where source_deal_type_id = @source_deal_type_id AND  source_deal_type_name = 'generation' AND @tab_seq = 1)
			BEGIN
				SET @tab_form_json = @tab_form_json + ',{"type": "template", "name": "setup_generation", "value": "Setup Generation", "format":"setup_generation_hyperlink"}'
			END

 			SET @tab_form_json = @tab_form_json + ']'

			-- Add UDT Grid JSON
			IF @source_deal_header_id IS NOT NULL
			BEGIN
				INSERT INTO #temp_deal_header_form_json
 				SELECT @tab_id, dbo.FNAFlattenedJSON(@tab_xml), NULL, @tab_seq, NULL, NULL, NULL, '{"name":"' + agd.grid_name + '", "label":"' + agd.grid_label + '"}'
				FROM maintain_field_template_detail mftd
				INNER JOIN adiha_grid_definition agd ON agd.grid_id = mftd.field_id
				WHERE mftd.field_group_id = @tab_id AND mftd.udf_or_system = 't' AND ISNULL(mftd.show_in_form, 'n') = 'y'
			END
			
 			IF EXISTS(SELECT 1 FROM #temp_deal_header_fields WHERE group_id = @tab_id) OR @tab_id = 0
 			BEGIN
			 	SET @tab_xml = REPLACE(CAST(@tab_xml AS NVARCHAR(MAX)), '"', '\"')		
 				INSERT INTO #temp_deal_header_form_json
 				SELECT @tab_id, dbo.FNAFlattenedJSON(@tab_xml), @tab_form_json, @tab_seq, NULL, NULL, @formula_fields_header, NULL
 			END	
 		END
 		ELSE 
 		BEGIN
			IF @enable_cost_tab <> 'n'
			BEGIN
				DECLARE @temp_process_id NVARCHAR(300) = dbo.FNAGetNewId()
				DECLARE @temp_process_table	NVARCHAR(300) = dbo.FNAProcessTableName('formula_editor', @user_name, @temp_process_id)
				DECLARE @formula_id NVARCHAR(MAX) = ''
				CREATE TABLE #formula_id(formula_id NVARCHAR(100))

				SET @sql = ' INSERT INTO #formula_id
							SELECT DISTINCT fe.formula_id
							FROM #temp_deal_header_fields temp
 							INNER JOIN user_defined_deal_fields_template uddft ON uddft.udf_user_field_id = REPLACE(temp.name, ''UDF___'', '''') AND uddft.template_id = ' + CAST(@template_id AS NVARCHAR(20)) + '
 							' + CASE WHEN @source_deal_header_id  IS NOT NULL THEN ' INNER JOIN ' ELSE ' LEFT JOIN ' END + ' #temp_deal_udf_values t_udf ON uddft.udf_template_id = t_udf.field_name
							INNER JOIN user_defined_fields_template udft ON udft.udf_template_id = uddft.udf_user_field_id
							INNER JOIN formula_editor fe ON CAST(fe.formula_id AS NVARCHAR(2000)) = COALESCE(t_udf.field_value, uddft.default_value, udft.default_value)
							WHERE temp.group_id = ' + CAST(@tab_id AS NVARCHAR(20)) + '						
							UNION 
							SELECT DISTINCT fe.formula_id
							FROM user_defined_deal_fields uddf
								INNER JOIN user_defined_fields_template udft ON udft.udf_template_id = ABS(uddf.udf_template_id)
								INNER JOIN formula_editor fe ON CAST(fe.formula_id AS NVARCHAR(2000)) = uddf.udf_value
								WHERE uddf.udf_template_id < 0 AND udft.deal_udf_type = ''c''
								AND uddf.source_deal_header_id = ' + CAST(@source_deal_header_id AS NVARCHAR(20)) + '
							'
				EXEC(@sql)
		
				SELECT @formula_id = @formula_id+','+COALESCE(formula_id,'') FROM  #formula_id

				IF @formula_id IS NOT NULL
					EXEC spa_resolve_function_parameter @flag = 's',@formula_id = @formula_id, @process_id = @temp_process_id

 				SET @sql = 'INSERT INTO ' + @header_costs_table + '(udf_id, udf_name, udf_value, currency_id, uom_id, counterparty_id, seq_no, internal_type_id, charge_type, contract_id, receive_pay, udf_field_type
								--, settlement_date, settlement_calendar, settlement_days, payment_date, payment_calendar, payment_days
								--, fixed_fx_rate
							)
							SELECT ISNULL(t_udf.field_name, uddft.udf_template_id), ISNULL(t_udf.field_label, uddft.Field_label)+ CASE WHEN [type] = ''w'' THEN ''::::Formula: '' + ISNULL('+CASE WHEN @formula_id IS NOT NULL THEN 'tpt.formula_name' ELSE 'NULL' END+', '''') ELSE '''' END, 
							CASE WHEN udft.[Field_type] = ''w'' THEN CAST(tpt.formula_id AS NVARCHAR(10)) + ''^'' + ISNULL(NULLIF(fe.formula_name,''''), tpt.formula_name) ELSE t_udf.field_value END udf_value, t_udf.currency_id, t_udf.uom_id, t_udf.counterparty_id, temp.seq_no     
								, sdv.value_id, sdv.code, t_udf.contract_id, t_udf.receive_pay, udft.Field_type
								--, uddf.settlement_date, uddf.settlement_calendar, uddf.settlement_days,	uddf.payment_date, uddf.payment_calendar, uddf.payment_days
								--,  uddf.fixed_fx_rate
							FROM #temp_deal_header_fields temp
							INNER JOIN user_defined_deal_fields_template uddft ON uddft.udf_user_field_id = REPLACE(temp.name, ''UDF___'', '''') AND uddft.template_id = ' + CAST(@template_id AS NVARCHAR(20)) + '
							' + CASE WHEN @source_deal_header_id  IS NOT NULL THEN ' INNER JOIN ' ELSE ' LEFT JOIN ' END + ' #temp_deal_udf_values t_udf ON uddft.udf_template_id = t_udf.field_name
							INNER JOIN user_defined_fields_template udft ON udft.udf_template_id = uddft.udf_user_field_id
							LEFT JOIN static_data_value sdv ON sdv.value_id = uddft.internal_field_type
							LEFT JOIN formula_editor fe ON CAST(fe.formula_id AS NVARCHAR(2000)) = COALESCE(t_udf.field_value, uddft.default_value, udft.default_value)
							'+CASE WHEN @formula_id IS NOT NULL THEN ' LEFT JOIN ' + @temp_process_table + ' tpt
								ON tpt.formula_id = fe.formula_id ' ELSE '' END + '
							WHERE temp.group_id = ' + CAST(@tab_id AS NVARCHAR(20))

				--PRINT @sql
				EXEC(@sql)

				IF @source_deal_header_id IS NOT NULL
				BEGIN
					SET @sql = 'INSERT INTO ' + @header_costs_table + '(udf_id, udf_name, udf_value, currency_id, uom_id, counterparty_id, seq_no, contract_id, receive_pay, charge_type,internal_type_id, udf_field_type
									, settlement_date, settlement_calendar, settlement_days, payment_date, payment_calendar, payment_days
									, fixed_fx_rate
								)
								SELECT uddf.udf_template_id, udft.Field_label + CASE WHEN udft.[Field_type] = ''w'' THEN ''::::Formula: '' + ISNULL('+CASE WHEN @formula_id IS NOT NULL THEN 'dbo.FNAEncodeXML(tpt.formula_name)' ELSE 'NULL' END+', '''') ELSE '''' END, 
								CASE WHEN udft.[Field_type] = ''w'' THEN CAST(tpt.formula_id AS NVARCHAR(10)) + ''^'' + ISNULL(NULLIF(fe.formula_name,''''), tpt.formula_name) ELSE uddf.udf_value END udf_value, uddf.currency_id, uddf.uom_id, uddf.counterparty_id, 1000 + ISNULL(uddf.seq_no, ROW_NUMBER() OVER(ORDER BY udft.udf_template_id))    
									, uddf.contract_id, uddf.receive_pay, sdv.code, sdv.value_id, udft.Field_type
									, uddf.settlement_date, uddf.settlement_calendar, uddf.settlement_days,	uddf.payment_date, uddf.payment_calendar, uddf.payment_days
									, uddf.fixed_fx_rate
								FROM user_defined_deal_fields uddf
								INNER JOIN user_defined_fields_template udft ON udft.udf_template_id = ABS(uddf.udf_template_id)
								LEFT JOIN formula_editor fe ON CAST(fe.formula_id AS NVARCHAR(2000)) = uddf.udf_value
								'+CASE WHEN @formula_id IS NOT NULL THEN ' LEFT JOIN ' + @temp_process_table + ' tpt
									ON tpt.formula_id = fe.formula_id ' ELSE '' END + '
								LEFT JOIN static_data_value sdv ON sdv.value_id = udft.internal_field_type
								WHERE uddf.udf_template_id < 0 AND udft.deal_udf_type = ''c''
								AND uddf.source_deal_header_id = ' + CAST(@source_deal_header_id AS NVARCHAR(20))
					--PRINT @sql
					EXEC(@sql)
				END 
 			
 				INSERT INTO #temp_deal_header_form_json
 				SELECT @tab_id, '{"id":"' + CAST(@tab_id AS NVARCHAR(20)) + '","text":"Cost"}', NULL, @tab_seq
					, 'SELECT udf_id,udf_name,internal_type_id,charge_type,udf_value,currency_id,uom_id,counterparty_id,contract_id,receive_pay,udf_field_type,settlement_date,settlement_calendar, settlement_days,payment_date,payment_calendar,payment_days,fixed_fx_rate  FROM ' + @header_costs_table + ' ORDER BY seq_no', CASE WHEN @copy_deal_id IS NOT NULL THEN @process_id ELSE NULL END, @formula_fields_header, NULL

            END
 		END	
	FETCH NEXT FROM tab_cursor INTO @tab_id, @tab_seq, @default_tab  
	END
	CLOSE tab_cursor
	DEALLOCATE tab_cursor
 	
	IF @source_deal_header_id IS NOT NULL
	BEGIN
		If @enable_prepay_tab = 'y' AND @copy_deal_id IS NULL
		BEGIN
			INSERT INTO #temp_deal_header_form_json
			SELECT @tab_id, '{"id":"' + CAST(@tab_id AS NVARCHAR(20)) + '","text":"PrePay"}', NULL, @tab_seq, 'EXEC spa_source_deal_prepay @flag=''s'', @source_deal_header_id=' + CAST(@source_deal_header_id AS NVARCHAR(10)), NULL, @formula_fields_header, NULL
		END	
	END
 	
	SELECT * FROM #temp_deal_header_form_json ORDER by tab_seq
END
ELSE IF @flag = 'd' OR @flag = 'e'
BEGIN
	DECLARE @buy_sell_flag_check NCHAR(1)
	DECLARE @default_price_format NVARCHAR(20)
	DECLARE @default_number_format NVARCHAR(20)
	
	SELECT @default_price_format = CAST('0,000.' + REPLICATE('0', ISNULL(price_rounding,4)) AS VARCHAR(16)) FROM company_info
	SELECT @default_number_format = CAST('0,000.' + REPLICATE('0', ISNULL(number_rounding,4)) AS VARCHAR(16)) FROM company_info
 	
	IF @source_deal_header_id IS NOT NULL
	BEGIN
 		IF @view_deleted = 'n'
 		BEGIN
 			SELECT @buy_sell_flag_check = buy_sell_flag FROM source_deal_detail WHERE Leg = 1 AND source_deal_header_id = @source_deal_header_id
 		END
 		ELSE
 		BEGIN
 			SELECT @buy_sell_flag_check = buy_sell_flag FROM delete_source_deal_detail WHERE Leg = 1 AND source_deal_header_id = @source_deal_header_id
 		END	
	END
	ELSE
	BEGIN
 		SELECT @buy_sell_flag_check = buy_sell_flag FROM source_deal_detail_template sddt WHERE Leg = 1 AND sddt.template_id = @template_id
	END	
	
	IF OBJECT_ID('tempdb..#temp_deal_type_mapping') IS NOT NULL
		DROP TABLE #temp_deal_type_mapping
	CREATE TABLE #temp_deal_type_mapping(
		id              INT IDENTITY(1, 1),
		column_name     NVARCHAR(200)  COLLATE DATABASE_DEFAULT,
		col_value       NVARCHAR(500)  COLLATE DATABASE_DEFAULT
	)
	
	DECLARE @whr_clause NVARCHAR(MAX)
	SET @whr_clause = 'template_id=' + CAST(@template_id AS NVARCHAR(200)) + ' AND source_deal_type_id = ' + CAST(ISNULL(@deal_type_id,0) AS NVARCHAR(20)) 
	
	IF @commodity_id IS NOT NULL	
		SET @whr_clause += ' AND commodity_id = ' + CAST(ISNULL(@commodity_id,0) AS NVARCHAR(20)) 
	ELSE 
		SET @whr_clause += ' AND commodity_id IS NULL'
	
	IF @pricing_type IS NOT NULL	
		SET @whr_clause += ' AND pricing_type=' + CAST(@pricing_type AS NVARCHAR(20)) 
	
	INSERT INTO #temp_deal_type_mapping(column_name, col_value)
	EXEC spa_Transpose 'deal_type_pricing_maping', @whr_clause
	
	IF OBJECT_ID('tempdb..#field_template_collection') IS NOT NULL
 		DROP TABLE #field_template_collection  
 		
	CREATE TABLE #field_template_collection (
 		[id]			 NVARCHAR(100) COLLATE DATABASE_DEFAULT,
 		default_label    NVARCHAR(100) COLLATE DATABASE_DEFAULT,
 		seq_no           INT,
 		field_id         NVARCHAR(50) COLLATE DATABASE_DEFAULT,
 		field_type       NVARCHAR(50) COLLATE DATABASE_DEFAULT,
 		leg              INT,
 		udf_or_system    NCHAR(1) COLLATE DATABASE_DEFAULT,
 		hide_control     NVARCHAR(50) COLLATE DATABASE_DEFAULT,
 		sql_string		 NVARCHAR(2000) COLLATE DATABASE_DEFAULT,
 		json_data		 NVARCHAR(MAX) COLLATE DATABASE_DEFAULT,
 		[disabled]		 NVARCHAR(10) COLLATE DATABASE_DEFAULT,
 		deal_value		 NVARCHAR(2000) COLLATE DATABASE_DEFAULT,
 		field_size		 NVARCHAR(20) COLLATE DATABASE_DEFAULT,
 		data_type		 NVARCHAR(20) COLLATE DATABASE_DEFAULT,
 		is_required		 NVARCHAR(10) COLLATE DATABASE_DEFAULT,
 		show_in_form	 NCHAR(1) COLLATE DATABASE_DEFAULT,
 		group_id		 INT,
 		round_value		 NVARCHAR(200) COLLATE DATABASE_DEFAULT
	)
 	
	DECLARE @round_price INT, @round_volume INT

	SELECT @round_price = ddv.round_price,
		   @round_volume = ddv.round_volume
	FROM deal_default_value ddv
	WHERE deal_type_id = @deal_type_id 
	AND ISNULL(commodity, -1) = ISNULL(@commodity_id, -1)
	AND ((pricing_type IS NULL AND @pricing_type IS NULL) OR pricing_type = @pricing_type)

	INSERT INTO #field_template_collection([id], default_label, seq_no, field_id, field_type, leg, udf_or_system, hide_control, sql_string, [disabled], field_size, data_type, is_required, show_in_form, group_id, round_value)
	SELECT *
	FROM   (
 			SELECT  mfd.farrms_field_id farrms_field_id,
 					CASE 
 							WHEN @buy_sell_flag_check = 's' THEN ISNULL(NULLIF(mftd.sell_label, ''), mftd.field_caption)
 							WHEN @buy_sell_flag_check = 'b' THEN ISNULL(NULLIF(mftd.buy_label, ''), mftd.field_caption)
 							ELSE mftd.field_caption
 					END default_label,
 					ISNULL(mftd.seq_no, 1000) seq_no,
 					CAST(mfd.field_id AS NVARCHAR) field_id,
 					mfd.field_type,
 					NULL AS leg,
 					's' udf_or_system,
 					CASE WHEN ISNULL(mftd.hide_control,'n') = 'n' THEN 'false' ELSE 'true' END hide_control,
 					mfd.sql_string,
 					CASE WHEN ISNULL(mftd.is_disable, mfd.is_disable) = 'y' THEN 'true' ELSE NULL END [disabled],
 					mfd.field_size,
 					mfd.data_type,
 					CASE WHEN mftd.value_required = 'y' THEN 'true' ELSE 'false' END value_required,
 					mftd.show_in_form,
 					mftd.detail_group_id,
 					CASE 
 					     WHEN mfd.data_type IN ('price') THEN 
 					          CASE WHEN ISNULL(@round_price, mftd.round_value) IS NULL THEN ISNULL(@default_price_format,'0,000.00')
 								   WHEN ISNULL(@round_price, mftd.round_value) = 0 THEN '0,000'
 								   WHEN ISNULL(@round_price, mftd.round_value) = 1 THEN '0,000.0'
 								   WHEN ISNULL(@round_price, mftd.round_value) = 2 THEN '0,000.00'
 								   WHEN ISNULL(@round_price, mftd.round_value) = 3 THEN '0,000.000'
 								   WHEN ISNULL(@round_price, mftd.round_value) = 4 THEN '0,000.0000'
 								   WHEN ISNULL(@round_price, mftd.round_value) = 5 THEN '0,000.00000'
 								   WHEN ISNULL(@round_price, mftd.round_value) = 6 THEN '0,000.000000'
 								   WHEN ISNULL(@round_price, mftd.round_value) = 7 THEN '0,000.0000000' 
 								   WHEN ISNULL(@round_price, mftd.round_value) = 8 THEN '0,000.00000000'
 								   WHEN ISNULL(@round_price, mftd.round_value) = 9 THEN '0,000.000000000'
 								END								   
 					     WHEN mfd.data_type IN ('number', 'numeric') THEN 
							CASE WHEN ISNULL(@round_volume, mftd.round_value) IS NULL THEN ISNULL(@default_number_format,'0,000.0000')
 								 WHEN ISNULL(@round_volume, mftd.round_value) = 0 THEN '0,000'
 								 WHEN ISNULL(@round_volume, mftd.round_value) = 1 THEN '0,000.0'
 								 WHEN ISNULL(@round_volume, mftd.round_value) = 2 THEN '0,000.00'
 								 WHEN ISNULL(@round_volume, mftd.round_value) = 3 THEN '0,000.000'
 								 WHEN ISNULL(@round_volume, mftd.round_value) = 4 THEN '0,000.0000'
 								 WHEN ISNULL(@round_volume, mftd.round_value) = 5 THEN '0,000.00000'
 								 WHEN ISNULL(@round_volume, mftd.round_value) = 6 THEN '0,000.000000'
 								 WHEN ISNULL(@round_volume, mftd.round_value) = 7 THEN '0,000.0000000' 
 								 WHEN ISNULL(@round_volume, mftd.round_value) = 8 THEN '0,000.00000000'
 								 WHEN ISNULL(@round_volume, mftd.round_value) = 9 THEN '0,000.000000000'
 							END
 					     ELSE NULL
 					END round_value
 			FROM maintain_field_deal mfd
 			INNER JOIN maintain_field_template_detail mftd ON  mftd.field_id = mfd.field_id
 			INNER JOIN dbo.source_deal_header_template sdht ON sdht.field_template_id = mftd.field_template_id
 			LEFT JOIN #temp_deal_type_mapping temp ON temp.column_name = mfd.farrms_field_id AND CAST(ISNULL(temp.col_value, 0) AS NVARCHAR(10)) = '0'
 			WHERE mfd.header_detail = 'd'
 				AND mftd.field_template_id = @field_template_id
 				AND sdht.template_id = @template_id
 				AND ISNULL(mftd.udf_or_system, 's') = 's'
 				--AND ISNULL(mftd.hide_control, 'n') = 'n' 
 				AND (
 						(ISNULL(mftd.update_required, 'n') = 'y' AND @source_deal_header_id IS NOT NULL) 
 						OR (ISNULL(mftd.insert_required, 'n') = 'y' AND @source_deal_header_id IS NULL) 
 				)
 				AND temp.id IS NULL
 			UNION ALL 
 			SELECT  'UDF___' + CAST(udft.udf_template_id AS NVARCHAR) udf_template_id,
 					CASE 
 							WHEN @buy_sell_flag_check = 's' THEN ISNULL(NULLIF(mftd.sell_label, ''), mftd.field_caption)
 							WHEN @buy_sell_flag_check = 'b' THEN ISNULL(NULLIF(mftd.buy_label, ''), mftd.field_caption)
 							ELSE mftd.field_caption
 					END default_label,
 					ISNULL(mftd.seq_no, 1000) seq_no,
 					CAST(udft.udf_template_id AS NVARCHAR) field_id,
 					udft.field_type field_type,
 					uddft.leg,
 					'u' udf_or_system,
 					CASE WHEN ISNULL(mftd.hide_control,'n') = 'n' THEN 'false' ELSE 'true' END hide_control,
 					ISNULL(NULLIF(udft.sql_string, ''''), uds.sql_string) sql_string,
 					CASE WHEN mftd.is_disable = 'y' THEN 'true' ELSE NULL END [disabled],
 					udft.field_size,
 					udft.data_type,
 					CASE WHEN mftd.value_required = 'y' THEN 'true' ELSE 'false' END value_required,
 					mftd.show_in_form,
 					mftd.detail_group_id,
 					CASE 
 					     WHEN udft.data_type IN ('price') THEN 
 					          CASE WHEN mftd.round_value IS NULL THEN ISNULL(@default_price_format,'0,000.0000')
 								   WHEN mftd.round_value = 0 THEN '0,000'
 								   WHEN mftd.round_value = 1 THEN '0,000.0'
 								   WHEN mftd.round_value = 2 THEN '0,000.00'
 								   WHEN mftd.round_value = 3 THEN '0,000.000'
 								   WHEN mftd.round_value = 4 THEN '0,000.0000'
 								   WHEN mftd.round_value = 5 THEN '0,000.00000'
 								   WHEN mftd.round_value = 6 THEN '0,000.000000'
 								   WHEN mftd.round_value = 7 THEN '0,000.0000000' 
 								   WHEN mftd.round_value = 8 THEN '0,000.00000000'
 								   WHEN mftd.round_value = 9 THEN '0,000.000000000'
 								END								   
 					     WHEN udft.data_type IN ('number', 'numeric') THEN 
							CASE WHEN mftd.round_value IS NULL THEN ISNULL(@default_number_format,'0,000.0000')
 								 WHEN mftd.round_value = 0 THEN '0,000'
 								 WHEN mftd.round_value = 1 THEN '0,000.0'
 								 WHEN mftd.round_value = 2 THEN '0,000.00'
 								 WHEN mftd.round_value = 3 THEN '0,000.000'
 								 WHEN mftd.round_value = 4 THEN '0,000.0000'
 								 WHEN mftd.round_value = 5 THEN '0,000.00000'
 								 WHEN mftd.round_value = 6 THEN '0,000.000000'
 								 WHEN mftd.round_value = 7 THEN '0,000.0000000' 
 								 WHEN mftd.round_value = 8 THEN '0,000.00000000'
 								 WHEN mftd.round_value = 9 THEN '0,000.000000000'
 							END
 					     ELSE NULL
 					END round_value
 			FROM  maintain_field_template_detail mftd
 			INNER JOIN user_defined_fields_template udft
 				ON  mftd.field_id = udft.udf_template_id
 				AND mftd.udf_or_system = 'u'
 			INNER JOIN user_defined_deal_fields_template uddft
 				ON  uddft.field_name = udft.field_name
 				AND uddft.template_id = @template_id
			LEFT JOIN udf_data_source uds 
				ON uds.udf_data_source_id = udft.data_source_type_id
 			WHERE  udft.udf_type = 'd'
 					AND mftd.field_template_id = @field_template_id
 					AND mftd.field_group_id IS NULL
 					--AND uddft.leg = 1
 					AND (
 						(ISNULL(mftd.update_required, 'n') = 'y' AND @source_deal_header_id IS NOT NULL) 
 						OR (ISNULL(mftd.insert_required, 'n') = 'y' AND @source_deal_header_id IS NULL) 
 					)
	) l 
	ORDER BY ISNULL(l.seq_no, 10000)
 	
	DECLARE @field_detail             NVARCHAR(MAX),
 			@field_temp_detail        NVARCHAR(MAX),
 			@field_process_detail     NVARCHAR(MAX),
 			@detail_grid_labels       NVARCHAR(MAX),
 			@max_detail_seq           INT,
 			@dummy_detail_value       NVARCHAR(MAX),
 			@detail_combo_list        NVARCHAR(MAX),
 			@udf_value                NVARCHAR(MAX),
 			@udf_field_id             NVARCHAR(MAX),
 			@final_select             NVARCHAR(MAX),
 			@header_menu              NVARCHAR(MAX),
 			@filter_list              NVARCHAR(MAX),
 			@validation_rule          NVARCHAR(MAX),
 			@detail_form_json1		  NVARCHAR(MAX),
 			@detail_form_json		  NVARCHAR(MAX),
			@order_by NVARCHAR(1000),
			@term_end_exists INT = 0
 			
 	
 	SELECT @formula_fields_detail = COALESCE(@formula_fields_detail + ',', '') + id
 	FROM #field_template_collection
 	WHERE field_type = 'w' 	

	SELECT @term_end_exists = 1 
	FROM #field_template_collection 
	WHERE id = 'term_end'
 	
 	IF (@formula_fields_detail IS NOT NULL OR @enable_pricing = 'y' OR @enable_provisional_tab = 'y') AND @flag = 'd'
 	BEGIN
 		 SET @sql = '
 				 CREATE TABLE ' + @detail_formula_process_table + ' (
 		 			[id]                        INT IDENTITY(1, 1) PRIMARY KEY NOT NULL,
 		 			[row_id]				    NVARCHAR(20) NULL,
 		 			[leg]						NVARCHAR(20) NULL,
 		 			[source_deal_detail_id]     NVARCHAR(100) NULL,
 		 			[source_deal_group_id]      NVARCHAR(100) NULL,
 		 			[udf_template_id]           INT NULL,
 		 			[udf_value]                 NVARCHAR(2000) NULL
 				 )'
 		  EXEC(@sql)
 		  
 		  IF @source_deal_header_id IS NOT NULL
 		  BEGIN
 		  		SET @sql = '
 		  		INSERT INTO ' + @detail_formula_process_table + ' (row_id, leg, source_deal_group_id, source_deal_detail_id, udf_template_id, udf_value)
 		  		SELECT 1, sdd.leg, sdd.source_deal_group_id, sdd.source_deal_detail_id, ddfu.udf_template_id, ddfu.udf_value
 		  		FROM deal_detail_formula_udf ddfu
 		  		INNER JOIN source_deal_detail sdd ON sdd.source_deal_detail_id = ddfu.source_deal_detail_id
 		  		WHERE sdd.source_deal_header_id = ' + CAST(@source_deal_header_id AS NVARCHAR(20)) + '
 		  		'
 		  		EXEC(@sql)		  		
 		  END
 	END
 	
	SELECT @max_detail_seq = MAX(seq_no)
	FROM #field_template_collection
 	
	SELECT  
	@field_detail = COALESCE(@field_detail + ',', '') + CAST(id AS NVARCHAR(150)) + ' NVARCHAR(MAX) ',
	@field_temp_detail = CASE WHEN ft.udf_or_system = 'u' THEN @field_temp_detail ELSE COALESCE(@field_temp_detail + ',', '') + CASE WHEN field_type = 'a' THEN 'NULLIF(sdd.' + id + ',''1900-01-01 00:00:00.000'')' ELSE 'sdd.' + id END END,
	@field_process_detail = CASE WHEN ft.udf_or_system = 'u' THEN @field_process_detail ELSE COALESCE(@field_process_detail + ',', '') + id END,
	@detail_grid_labels = COALESCE(@detail_grid_labels + ',', '') + '{"id":"' + id + '", "hidden":' +  CASE WHEN ft.show_in_form = 'y' THEN 'true' ELSE hide_control END + 							
							', "align":"' + CASE WHEN id IN ('total_volume','capacity','deal_volume_uom_id','standard_yearly_volume','fixed_price','fixed_price_currency_id','settlement_uom','price_uom_id','contractual_uom_id','broker_fixed_cost','fixed_cost','fixed_cost_currency_id','multiplier',
							'position_uom','rec_price','option_strike_price','price_adder','price_multiplier','price_adder2','price_adder_currency2','deal_volume','volume_left','settlement_volume','volume_multiplier2','contractual_volume','actual_volume','settlement_vol_type','schedule_volume') 
							THEN 'right' else 'left' END + '"' + 
 							',"sort":"' +  CASE WHEN field_type = 'a' THEN 'date' ELSE 'str' END + '"' +
 							', "width":"' + CASE WHEN field_type = 'a' THEN '160' ELSE ISNULL(field_size, '150') END + '"' +
 							', "type":"' + CASE 
 												WHEN id = 'product_description' THEN 'ro'
												WHEN data_type = 'price' AND ISNULL([disabled], 'false') = 'true' AND @source_deal_header_id IS NOT NULL THEN 'ro_p'
 												WHEN data_type = 'number' AND ISNULL([disabled], 'false') = 'true' AND @source_deal_header_id IS NOT NULL THEN 'ro_no'
 												WHEN data_type = 'price' THEN 'ed_p'
 												WHEN data_type = 'number' THEN 'ed_no'
 												ELSE  CASE field_type
 														WHEN 'c' THEN CASE WHEN ISNULL([disabled], 'false') = 'true' AND @source_deal_header_id IS NOT NULL  THEN 'ro_combo' ELSE 'combo' END
 														WHEN 'd' THEN CASE WHEN ISNULL([disabled], 'false') = 'true' AND @source_deal_header_id IS NOT NULL THEN 'ro_combo' ELSE 'combo' END
 														WHEN 't' THEN CASE WHEN ISNULL([disabled], 'false') = 'true' AND @source_deal_header_id IS NOT NULL THEN 'ro' ELSE 'ed' END
 														WHEN 'a' THEN CASE WHEN ISNULL([disabled], 'false') = 'true' AND @source_deal_header_id IS NOT NULL THEN 'ro_dhxCalendarA' ELSE 'dhxCalendarA' END
														WHEN 'e' THEN CASE WHEN ISNULL([disabled], 'false') = 'true' AND @source_deal_header_id IS NOT NULL THEN 'time' ELSE 'time' END
 														WHEN 'w' THEN CASE WHEN ISNULL([disabled], 'false') = 'true' AND @source_deal_header_id IS NOT NULL THEN 'ro_win_link_custom' ELSE 'win_link_custom' END
 														ELSE 'ro'
 													END
 										END + '"' +
 							CASE WHEN data_type IN ('price', 'number') THEN ',"format":"' + round_value + '" ' ELSE '' END + 
 							', "value":"' + CASE WHEN id IN ('total_volume','capacity','deal_volume_uom_id','standard_yearly_volume','fixed_price','fixed_price_currency_id','settlement_uom','price_uom_id','contractual_uom_id','broker_fixed_cost','fixed_cost','fixed_cost_currency_id','multiplier',
							'position_uom','rec_price','option_strike_price','price_adder','price_multiplier','price_adder2','price_adder_currency2','deal_volume','volume_left','settlement_volume','volume_multiplier2','contractual_volume','actual_volume','settlement_vol_type','schedule_volume') 
							THEN '<div style='+'''width:100%; text-align:right;'+'''>'+ dbo.FNAGetLocaleValue(ft.default_label) +'</div>' else '<div style='+'''width:100%; text-align:left;'+'''>'+ dbo.FNAGetLocaleValue(ft.default_label) +'</div>' END + '"'  + 
 							CASE WHEN field_type = 'a' THEN ', "dateFormat":"__DATEFORMAT__"' ELSE '' END +
 							+ '}',
 	
	@detail_combo_list = CASE WHEN ft.field_type IN ('d', 'c')  
							THEN COALESCE(@detail_combo_list + '||||', '') + ft.id + '::::' + 'dropdown.connector.v2.php?call_from=deal&deal_id=' + ISNULL(CAST(@source_deal_header_id AS NVARCHAR(50)), '') + '&template_id=' + ISNULL(CAST(@template_id AS NVARCHAR(50)), '') + '&farrms_field_id=' + ft.id + '&default_value=&is_udf=' + udf_or_system + '&required=' + CASE WHEN [is_required] = 'true' THEN 'y' ELSE 'n' END + '&deal_type_id=' + ISNULL(CAST(@deal_type_id AS NVARCHAR(50)), '') + '&commodity_id=' + ISNULL(CAST(@commodity_id AS NVARCHAR(50)), '')
						ELSE @detail_combo_list END,
	@dummy_detail_value = COALESCE(@dummy_detail_value + ',', '') + '""',
	@udf_value = CASE WHEN ft.udf_or_system = 's' THEN @udf_value ELSE COALESCE(@udf_value + ', ', '') + CAST(ft.id AS NVARCHAR) + '= u.[' + CAST(ft.field_id AS NVARCHAR) + ']' END,
	@udf_field_id = CASE WHEN ft.udf_or_system = 's' THEN @udf_field_id ELSE COALESCE(@udf_field_id + ', ', '') + '[' + CAST(ft.field_id AS NVARCHAR) + ']' END,
	@final_select = COALESCE(@final_select + ',', '') + CASE WHEN field_type = 'a' THEN 'dbo.FNAGetSQLStandardDate(sdd.' + id + ')' WHEN data_type IN ('price', 'number', 'numeric') THEN 'dbo.FNARemoveTrailingZero(NULLIF(FORMAT(CONVERT(NUMERIC(38,8), sdd.' + id + '),REPLACE(''' + ft.round_value + ''','','','''')),''''))'   ELSE 'sdd.' + id END + ' AS [' + ft.id + ']',
	@header_menu = COALESCE(@header_menu + ',', '') + CASE WHEN ft.show_in_form = 'y' THEN 'false' ELSE 'true' END,
	@filter_list = COALESCE(@filter_list + ',', '') + CASE WHEN field_type = 'c' THEN '#combo_filter' WHEN field_type = 'a' THEN '#daterange_filter' ELSE '#text_filter' END,
	@validation_rule = COALESCE(@validation_rule + ',', '') + CASE WHEN ft.is_required = 'true' AND data_type IN ('price', 'number') THEN 'ValidNumeric' WHEN ft.is_required = 'true' THEN 'NotEmpty' ELSE CASE WHEN data_type IN ('price', 'number') THEN 'ValidNumericWithEmpty'  ELSE '' END END ,
	@order_by = CASE WHEN id = 'term_start' THEN 'ORDER BY CONVERT(DATETIME, sdd.term_start, 120)'  
									 WHEN id = 'vintage' THEN 'ORDER BY CONVERT(DATETIME, sdd.vintage, 120)'
									 ELSE ''
							END
	FROM #field_template_collection ft
	WHERE id <> 'source_deal_detail_id' AND id <> 'lock_deal_detail'
	ORDER BY ft.seq_no
 	
 	SET @detail_grid_labels = '{"head":[{"id":"deal_group", "align":"left", "offsetLeft":0, "hidden":false, "width":200, "type": "tree", "value":"' + dbo.FNAGetLocaleValue('Group') + '"},{"id":"group_id", "align":"left", "offsetLeft":0, "hidden":true, "width":200, "type":"ro", "value":"' + dbo.FNAGetLocaleValue('GroupID') + '"},{"id":"detail_flag", "align":"left", "offsetLeft":0, "hidden":true, "width":200, "type": "ro", "value":"' + dbo.FNAGetLocaleValue('Detail Flag') + '"},{"id": "blotterleg", "align":"left", "offsetLeft":0, "hidden": true, "width": 50, "type": "ro", "value":""},{"id": "source_deal_detail_id", "align":"left", "offsetLeft":0, "hidden": true, "width": 50, "type": "ro", "value":"' + dbo.FNAGetLocaleValue('DetailID') + '"},{"id": "lock_deal_detail", "align":"left", "offsetLeft":0, "hidden": true, "width": 50, "type": "ro", "value":"' + dbo.FNAGetLocaleValue('Locked') + '"},' + @detail_grid_labels + '],"rows":[{"id":1, "data":[' + @dummy_detail_value + ']}]}'
	DECLARE @detail_group_id INT
	DECLARE @detail_form_final NVARCHAR(MAX) 
	DECLARE @detail_tab_json NVARCHAR(MAX)
	DECLARE @detail_tab_ids NVARCHAR(MAX)
 	
	IF EXISTS(
 			SELECT 1
 			FROM   #field_template_collection
 			WHERE show_in_form = 'y'
	) AND @flag = 'd'
	BEGIN	
 		SELECT @detail_tab_json = COALESCE(@detail_tab_json + ',', '') + '{"id":"tab_' + ISNULL(CAST(temp.group_id AS NVARCHAR(50)), 'detail') + '","text":"' + ISNULL(mftgd.group_name, 'Detail') + '"' + CASE WHEN temp.group_id IS NULL THEN ',"active":"true"}' ELSE '}' END,
 				@detail_tab_ids = COALESCE(@detail_tab_ids + ',', '') + 'tab_' + ISNULL(CAST(temp.group_id AS NVARCHAR(50)), 'detail') + '::' + 'form_' + CAST(ISNULL(temp.group_id, 0) AS NVARCHAR(50))
 		FROM #field_template_collection temp
 		LEFT JOIN maintain_field_template_group_detail mftgd ON mftgd.group_id = temp.group_id
 		WHERE show_in_form = 'y' 
 		GROUP BY temp.group_id, mftgd.group_name
 		
 		SET @detail_form_final = '[{"type":"settings","position":"label-top"}'
 		
	END 
 	
	DECLARE detail_form_cursor CURSOR FORWARD_ONLY READ_ONLY 
	FOR
 		SELECT ISNULL(group_id, 0) group_id   
 		FROM #field_template_collection temp
 		WHERE show_in_form = 'y' AND @flag = 'd'
 		GROUP BY group_id
	OPEN detail_form_cursor
	FETCH NEXT FROM detail_form_cursor INTO @detail_group_id                                  
	WHILE @@FETCH_STATUS = 0
	BEGIN
 		SET @detail_form_json1 = NULL
 		SET @detail_form_json1 = '{type:"block", blockOffset:20, id: "form_' + CAST(@detail_group_id AS NVARCHAR(50)) + '", list:['
 		SET @detail_form_json = NULL
 		
 		SELECT @detail_form_json = COALESCE(@detail_form_json + ',', '') 
 									+ '{"type":"'
 									+ CASE 
 											WHEN data_type = 'price' AND ISNULL([disabled], 'false') = 'true' THEN 'input'
 											WHEN data_type = 'number' AND ISNULL([disabled], 'false') = 'true' THEN 'input'
 											WHEN data_type = 'price' THEN 'input'
 											WHEN data_type = 'number' THEN 'input'
 											ELSE  CASE field_type
 													WHEN 'c' THEN 'checkbox'
 													WHEN 'd' THEN 'combo'
 													WHEN 't' THEN 'input'
												WHEN 'e' THEN 'time'
 													WHEN 'a' THEN 'calendar'
 													WHEN 'w' THEN 'input'
 													ELSE 'input'
 												END
 									END + '"' 
									+ CASE WHEN field_type IN ('d', 'c') THEN ', "connector":' + 'js_dropdown_connector_v2_url+"&call_from=deal&deal_id=' + ISNULL(CAST(@source_deal_header_id AS NVARCHAR(50)), '') + '&template_id=' + ISNULL(CAST(@template_id AS NVARCHAR(50)), '') + '&farrms_field_id=' + [id] + '&default_value=&is_udf=' + udf_or_system + '&required=' + CASE WHEN [is_required] = 'true' THEN 'y' ELSE 'n' END + '&deal_type_id=' + ISNULL(CAST(@deal_type_id AS NVARCHAR(50)), '') + '&commodity_id=' + ISNULL(CAST(@commodity_id AS NVARCHAR(50)), '') + '"' ELSE '' END +
									
 									+ ', "label":"' + ft.default_label + '"' +
 									+ ', "name":"' + ft.id + '"' +
 									+ CASE WHEN ISNULL([disabled], 'false') = 'true' AND @source_deal_header_id IS NOT NULL THEN ',"disabled":"true"' ELSE '' END
 									+ CASE WHEN field_type IN ('d') THEN ', "filtering":"true","filtering_mode":"between"' ELSE '' END
 									+ CASE WHEN field_type IN ('d') AND ft.json_data IS NOT NULL THEN ',' + SUBSTRING(ft.json_data, 2, LEN(ft.json_data) - 2) ELSE '' END
 									+ CASE WHEN field_type = 'a' THEN ',"dateFormat":"' + COALESCE(dbo.FNAChangeDateFormat(), '%Y-%m-%d') + '", "serverDateFormat":"%Y-%m-%d"' ELSE '' END 								
 									+ ', "offsetLeft": "20", "inputWidth":"' + CASE WHEN field_type = 'a' THEN '160' WHEN field_type = 'a' THEN '100' ELSE ISNULL(field_size, '150') END + '"'
 									+ CASE WHEN field_type = 'c' THEN ',"position":"label-right","offsetTop":"25"' ELSE '' END
 									+ CASE WHEN field_type = 'c' THEN ',"labelWidth": "120"' ELSE ',"labelWidth": "auto"' END
 									+ ', "hidden":' +  hide_control
									+ CASE WHEN [id] = 'deal_detail_description' THEN ',rows:3' ELSE '' END + 
									+ CASE WHEN field_type = 'm' THEN ', "rows":3' ELSE '' END +
 									+ '}'
 									+ ',{type:"newcolumn"}' 
 		FROM #field_template_collection ft
		WHERE id <> 'source_deal_detail_id'  AND show_in_form = 'y' AND id <> 'lock_deal_detail'
 		AND (ft.group_id = @detail_group_id OR (ft.group_id IS NULL AND @detail_group_id = 0))
 		ORDER BY ft.seq_no
 		
 		SET @detail_form_json = @detail_form_json1 + @detail_form_json + ']}'
 		
 		SET @detail_form_final = @detail_form_final + ',' + @detail_form_json
 		FETCH NEXT FROM detail_form_cursor INTO @detail_group_id
	END
	CLOSE detail_form_cursor
	DEALLOCATE detail_form_cursor
 	
	IF @detail_form_final IS NOT NULL 
	BEGIN
 		SET @detail_form_final += ']'
	END
 	
	SET @filter_list = '#text_filter,,,#text_filter,#text_filter,#text_filter,' + @filter_list
	SET @validation_rule = ',,,,,,' + @validation_rule
	--SET @header_menu = 'false,false,false,false,true,' + @header_menu
	SET @header_menu = 'true,false,false,false,true,true,' + @header_menu
	DECLARE @date_format NVARCHAR(20) = COALESCE(dbo.FNAChangeDateFormat(), '%Y-%m-%d')
 	
	SET @detail_grid_labels = REPLACE(@detail_grid_labels, '__DATEFORMAT__', @date_format)

	SET @detail_udf_table = dbo.FNAProcessTableName('detail_udf_table', @user_name, @udf_process_id)
	
	IF OBJECT_ID(@detail_udf_table) IS NULL
	BEGIN
		EXEC('CREATE TABLE ' + @detail_udf_table + '(
			id					INT IDENTITY(1,1),
			detail_id			NVARCHAR(50),
 			udf_id				NVARCHAR(20),
 			udf_name            NVARCHAR(100),
 			udf_value           NVARCHAR(MAX),
 			currency_id         int,
 			uom_id              int,
 			counterparty_id     int,
			seq_no				int,
			charge_type		    NVARCHAR(100),
			contract_id         INT,
			receive_pay         NCHAR(1)

		)')
	END

	IF @enable_udf_tab = 'y'
	BEGIN
		IF @source_deal_header_id IS NOT NULL
		BEGIN
			SET @sql = 'INSERT INTO ' + @detail_udf_table + ' (detail_id, udf_id, udf_name, udf_value, seq_no)
						SELECT uddf.source_deal_detail_id [detail_id], uddf.udf_template_id [udf_id], udft.field_label [udf_name], uddf.udf_value [udf_value], uddf.seq_no
 						FROM ' + CASE WHEN @view_deleted ='y' THEN 'delete_' ELSE '' END + 'user_defined_deal_detail_fields uddf
						INNER JOIN ' + CASE WHEN @view_deleted ='y' THEN 'delete_' ELSE '' END + 'source_deal_detail sdd ON  sdd.source_deal_detail_id = uddf.source_deal_detail_id
 						INNER JOIN user_defined_fields_template udft ON udft.udf_template_id = ABS(uddf.udf_template_id)
 						WHERE sdd.source_deal_header_id = ' + CAST(@source_deal_header_id AS NVARCHAR(20)) + '
						AND uddf.udf_template_id  < 0 AND udft.udf_type = ''d'' AND ISNULL(udft.deal_udf_type, ''x'') <> ''c''
					'
 			--PRINT(@sql)
 			EXEC(@sql)
		END
	END

	IF @enable_detail_cost = 'y'
	BEGIN
		SET @detail_cost_table = dbo.FNAProcessTableName('detail_cost_table', @user_name, @udf_process_id)
		

		EXEC('CREATE TABLE ' + @detail_cost_table + '(
			id					INT IDENTITY(1,1),
			detail_id			NVARCHAR(50),
 			udf_id				NVARCHAR(20),
 			udf_name            NVARCHAR(100),
 			udf_value           NVARCHAR(MAX),
 			currency_id				INT,
 			uom_id					INT,
 			counterparty_id			INT,
			seq_no					INT,
			internal_field_type_id	INT,
			charge_type				NVARCHAR(200), 
			contract_id				INT,
			receive_pay				NCHAR(1)

		)')


 		SET @sql = 'INSERT INTO ' + @detail_cost_table + ' (detail_id, udf_id, udf_name, udf_value, currency_id, uom_id, counterparty_id, seq_no, internal_field_type_id, charge_type, contract_id, receive_pay	)
					SELECT sdd.source_deal_detail_id [detail_id], uddf.udf_template_id [udf_id], udft.field_label [udf_name], uddf.udf_value [udf_value], uddf.currency_id [currency_id], uddf.uom_id [uom_id], uddf.counterparty_id [counterparty_id], mftd.seq_no
					,sdv.value_id [internal_field_type_id], sdv.code [charge_type], (uddf.contract_id) contract_id, (uddf.receive_pay) receive_pay
 					FROM ' + CASE WHEN @view_deleted ='y' THEN 'delete_' ELSE '' END + 'user_defined_deal_detail_fields uddf
 					INNER JOIN user_defined_deal_fields_template udft ON  uddf.udf_template_id = udft.udf_template_id
 					INNER JOIN ' + CASE WHEN @view_deleted ='y' THEN 'delete_' ELSE '' END + 'source_deal_detail sdd ON  sdd.source_deal_detail_id = uddf.source_deal_detail_id
 					INNER JOIN user_defined_fields_template udft2 ON udft2.field_name = udft.field_name
 					INNER JOIN maintain_field_template_detail mftd 
 						ON mftd.field_id = udft2.udf_template_id
 						AND mftd.udf_or_system = ''u''
 						AND mftd.detail_group_id IS NOT NULL
 						AND mftd.field_template_id = ' + CAST(@field_template_id AS NVARCHAR(10)) + '
					INNER JOIN maintain_field_template_group_detail mftgd ON mftgd.group_id = mftd.detail_group_id AND mftgd.default_tab = 1
 					LEFT JOIN static_data_value sdv ON sdv.value_id = udft2.internal_field_type
 					WHERE udft.udf_type = ''d'' AND sdd.source_deal_header_id = ' + CAST(@source_deal_header_id AS NVARCHAR(20))
 		--PRINT(@sql)
 		EXEC(@sql)

		IF @source_deal_header_id IS NOT NULL
		BEGIN
			SET @sql = 'INSERT INTO ' + @detail_cost_table + ' (detail_id, udf_id, udf_name, udf_value, currency_id, uom_id, counterparty_id, seq_no, internal_field_type_id, charge_type, contract_id, receive_pay)
						SELECT uddf.source_deal_detail_id [detail_id], uddf.udf_template_id [udf_id], udft.field_label [udf_name], uddf.udf_value [udf_value], uddf.currency_id [currency_id], uddf.uom_id [uom_id], uddf.counterparty_id [counterparty_id], uddf.seq_no
 						,sdv.value_id [internal_field_type_id], sdv.code [charge_type], (uddf.contract_id) contract_id, (uddf.receive_pay) receive_pay
 						FROM ' + CASE WHEN @view_deleted ='y' THEN 'delete_' ELSE '' END + 'user_defined_deal_detail_fields uddf
						INNER JOIN ' + CASE WHEN @view_deleted ='y' THEN 'delete_' ELSE '' END + 'source_deal_detail sdd ON  sdd.source_deal_detail_id = uddf.source_deal_detail_id
 						INNER JOIN user_defined_fields_template udft ON udft.udf_template_id = ABS(uddf.udf_template_id)
 						LEFT JOIN static_data_value sdv ON sdv.value_id = udft.internal_field_type
 						WHERE sdd.source_deal_header_id = ' + CAST(@source_deal_header_id AS NVARCHAR(20)) + '
						AND uddf.udf_template_id  < 0 AND udft.udf_type = ''d'' AND ISNULL(udft.deal_udf_type, ''x'') = ''c''
					'
 			--PRINT(@sql)
 			EXEC(@sql)
		END
	END

	DECLARE @deal_update_detail NVARCHAR(200)
 	
	IF OBJECT_ID('tempdb..#temp_uddf') IS NOT NULL
 		DROP TABLE #temp_uddf
 	
	CREATE TABLE #temp_uddf (
 		udf_template_id INT,
 		source_deal_detail_id INT,
 		udf_value NVARCHAR(MAX) COLLATE DATABASE_DEFAULT
	)
 	
	IF @source_deal_header_id IS NOT NULL AND @flag = 'e'
	BEGIN
 		SET @sql = 'INSERT INTO #temp_uddf
 					SELECT udft2.udf_template_id,
 							uddf.source_deal_detail_id,
 							CASE 
 								WHEN udft.Field_type = ''a'' THEN dbo.FNAGetSQLStandardDate(uddf.udf_value)
 								WHEN udft.Field_type = ''c'' AND uddf.udf_value = ''y'' THEN ''Yes''
 								WHEN udft.Field_type = ''c'' AND uddf.udf_value = ''n'' THEN ''No''
								WHEN udft.Field_type = ''w'' THEN CAST(fe.formula_id AS NVARCHAR(200)) + ''^'' + dbo.FNAFormulaFormat(fe.formula, ''r'')
 								ELSE uddf.udf_value
 							END udf_value 
 					FROM ' + CASE WHEN @view_deleted ='y' THEN 'delete_' ELSE '' END + 'user_defined_deal_detail_fields uddf
 					INNER JOIN user_defined_deal_fields_template udft ON  uddf.udf_template_id = udft.udf_template_id
 					INNER JOIN source_deal_detail sdd ON  sdd.source_deal_detail_id = uddf.source_deal_detail_id
 					INNER JOIN user_defined_fields_template udft2 ON udft2.field_name = udft.field_name
					LEFT JOIN formula_editor fe ON CAST(fe.formula_id AS NVARCHAR(20)) = uddf.udf_value AND udft2.Field_type = ''w''
 					WHERE sdd.source_deal_header_id = ' + CAST(@source_deal_header_id AS NVARCHAR(20))
 		EXEC(@sql)
	END
 	
	IF CHARINDEX('source_deal_detail_id', @field_process_detail) = 0
	BEGIN
		SET @field_detail = 'source_deal_detail_id NVARCHAR(100),lock_deal_detail NCHAR(1), ' + @field_detail
		SET @field_process_detail =  'source_deal_detail_id, lock_deal_detail, ' + @field_process_detail
		SET @final_select = 'source_deal_detail_id, ISNULL(lock_deal_detail, ''n'') lock_deal_detail, ' + @final_select
 		
 		IF @source_deal_header_id IS NOT NULL
			SET @field_temp_detail = 'source_deal_detail_id, lock_deal_detail, ' + @field_temp_detail
 		ELSE
			SET @field_temp_detail = 'NULL, lock_deal_detail, ' + @field_temp_detail
	END
 	
 	IF @flag = 'e'
 	BEGIN
		SET @deal_update_detail = dbo.FNAProcessTableName('deal_update_detail', @user_name, @process_id)
		
		IF OBJECT_ID(@deal_update_detail) IS NOT NULL
			EXEC('DROP TABLE ' + @deal_update_detail)
		
		SET @sql = ' 
 					CREATE TABLE ' + @deal_update_detail + ' (
						template_id INT,
 						deal_group	   NVARCHAR(500),
 						group_id	   INT,
 						detail_flag	   INT,
 						blotterleg INT,
 						' + @field_detail + '			
 					) '
		--PRINT(@sql)
		EXEC(@sql)
		
		IF @enable_escalation_tab = 'y' AND @pricing_process_id IS NOT NULL
		BEGIN
			SET @deal_escalation_process_table = dbo.FNAProcessTableName('deal_escalation_process_table', @user_name, @pricing_process_id)
			
			IF OBJECT_ID(@deal_escalation_process_table) IS NOT NULL
 			BEGIN
 				EXEC('DROP TABLE ' + @deal_escalation_process_table)
 			END
			
			INSERT INTO #temp_collect_detail_ids
 			SELECT sdd.source_deal_detail_id, sdd.source_deal_group_id
 			FROM source_deal_header sdh 
 			INNER JOIN source_deal_detail sdd ON sdh.source_deal_header_id = sdd.source_deal_header_id
 			WHERE sdh.source_deal_header_id = @source_deal_header_id
 			
 			SET @sql = 'SELECT de.deal_escalation_id [id], sdd.source_deal_detail_id, de.quality, de.range_from, de.range_to, de.increment, de.cost_increment, de.operator, de.[reference], de.currency, sdd.source_deal_group_id
 						INTO ' + @deal_escalation_process_table + '
 						FROM deal_escalation de
 						INNER JOIN source_deal_detail sdd ON sdd.source_deal_detail_id = de.source_deal_detail_id
 						WHERE sdd.source_deal_header_id = ' + CAST(@source_deal_header_id AS NVARCHAR(20)) + '
 						'
 			EXEC(@sql) 			
		END

		IF (@enable_pricing = 'y' OR @enable_provisional_tab = 'y') AND @pricing_process_id IS NOT NULL
		BEGIN
 			SET @deemed_process_table = dbo.FNAProcessTableName('deemed_process_table', @user_name, @pricing_process_id)
 			SET @std_event_process_table = dbo.FNAProcessTableName('std_event_process_table', @user_name, @pricing_process_id)
 			SET @custom_event_process_table = dbo.FNAProcessTableName('custom_event_process_table', @user_name, @pricing_process_id)
 			SET @pricing_type_process_table = dbo.FNAProcessTableName('pricing_type_process_table', @user_name, @pricing_process_id)
            SET @deemed_provisional_process_table = dbo.FNAProcessTableName('deemed_provisional_process_table', @user_name, @pricing_process_id)
 			SET @std_event_provisional_process_table = dbo.FNAProcessTableName('std_event_provisional_process_table', @user_name, @pricing_process_id)
 			SET @custom_event_provisional_process_table = dbo.FNAProcessTableName('custom_event_provisional_process_table', @user_name, @pricing_process_id)
 			SET @pricing_type_provisional_process_table = dbo.FNAProcessTableName('pricing_type_provisional_process_table', @user_name, @pricing_process_id)
 			
 			INSERT INTO #temp_collect_detail_ids
 			SELECT sdd.source_deal_detail_id, sdd.source_deal_group_id
 			FROM source_deal_header sdh 
 			INNER JOIN source_deal_detail sdd ON sdh.source_deal_header_id = sdd.source_deal_header_id
 			WHERE sdh.source_deal_header_id = @source_deal_header_id

			IF OBJECT_ID(@deemed_process_table) IS NOT NULL
 			BEGIN
 				EXEC('DROP TABLE ' + @deemed_process_table)
 			END

			IF OBJECT_ID(@std_event_process_table) IS NOT NULL
 			BEGIN
 				EXEC('DROP TABLE ' + @std_event_process_table)
 			END

			IF OBJECT_ID(@custom_event_process_table) IS NOT NULL
 			BEGIN
 				EXEC('DROP TABLE ' + @custom_event_process_table)
 			END
 			
			IF OBJECT_ID(@pricing_type_process_table) IS NOT NULL
 			BEGIN
 				EXEC('DROP TABLE ' + @pricing_type_process_table)
 			END
 			
			IF OBJECT_ID(@deemed_provisional_process_table) IS NOT NULL
 			BEGIN
 				EXEC('DROP TABLE ' + @deemed_provisional_process_table)
 			END

			IF OBJECT_ID(@std_event_provisional_process_table) IS NOT NULL
 			BEGIN
 				EXEC('DROP TABLE ' + @std_event_provisional_process_table)
 			END

			IF OBJECT_ID(@custom_event_provisional_process_table) IS NOT NULL
 			BEGIN
 				EXEC('DROP TABLE ' + @custom_event_provisional_process_table)
 			END
 			
			IF OBJECT_ID(@pricing_type_provisional_process_table) IS NOT NULL
 			BEGIN
 				EXEC('DROP TABLE ' + @pricing_type_provisional_process_table)
 			END


 			
 			SET @sql = 'SELECT sdd.source_deal_detail_id,
  						   dpd.pricing_index,
  						   dpd.pricing_start,
  						   dpd.pricing_end,
  						   dpd.adder,
  						   dpd.currency,
  						   dpd.multiplier,
  						   dpd.volume,
  						   dpd.uom,
  						   dpd.pricing_provisional,
  						   sdd.source_deal_group_id,
  						   dpd.pricing_period,
  						   dpd.fixed_price,
  						   dpd.formula_id,
  						   dpd.[priority],
  						   dpd.adder_currency,
  						   dpd.pricing_uom,
  						   dpd.formula_currency,
  						   dpd.fixed_cost,
  						   dpd.fixed_cost_currency
 					INTO ' + @deemed_process_table + '
 					FROM deal_price_deemed dpd
 					INNER JOIN #temp_collect_detail_ids sdd ON sdd.source_deal_detail_id = dpd.source_deal_detail_id
 			        WHERE 1 = 1
 			        ' + CASE WHEN ISNULL(@enable_pricing, 'n') = 'y' AND ISNULL(@enable_provisional_tab, 'n') = 'y' THEN '' 
 							 WHEN ISNULL(@enable_pricing, 'n') = 'y' AND ISNULL(@enable_provisional_tab, 'n') = 'n' THEN ' AND dpd.pricing_provisional = ''p'' '
 							 WHEN ISNULL(@enable_pricing, 'n') = 'n' AND ISNULL(@enable_provisional_tab, 'n') = 'y' THEN ' AND dpd.pricing_provisional = ''q'' '
 						ELSE '' END
 					+ '
 					    
 			            
 					SELECT dpse.deal_price_std_event_id [id], sdd.source_deal_detail_id, event_type, event_date, event_pricing_type, pricing_index, adder, currency, multiplier, volume, uom, pricing_provisional, sdd.source_deal_group_id
 					INTO ' + @std_event_process_table + '
 					FROM deal_price_std_event dpse
 					INNER JOIN #temp_collect_detail_ids sdd ON sdd.source_deal_detail_id = dpse.source_deal_detail_id
 					WHERE 1 = 1
 					' + CASE WHEN ISNULL(@enable_pricing, 'n') = 'y' AND ISNULL(@enable_provisional_tab, 'n') = 'y' THEN '' 
 							 WHEN ISNULL(@enable_pricing, 'n') = 'y' AND ISNULL(@enable_provisional_tab, 'n') = 'n' THEN ' AND dpse.pricing_provisional = ''p'' '
 							 WHEN ISNULL(@enable_pricing, 'n') = 'n' AND ISNULL(@enable_provisional_tab, 'n') = 'y' THEN ' AND dpse.pricing_provisional = ''q'' '
 						ELSE '' END
 					+ '
 					
 					SELECT dpce.deal_price_custom_event_id [id], sdd.source_deal_detail_id, event_type, event_date, pricing_index, skip_days, quotes_before, quotes_after, include_event_date, include_holidays, adder, currency, multiplier, volume, uom, pricing_provisional, sdd.source_deal_group_id
 					INTO ' + @custom_event_process_table + '
 					FROM deal_price_custom_event dpce
 					INNER JOIN #temp_collect_detail_ids sdd ON sdd.source_deal_detail_id = dpce.source_deal_detail_id
 					WHERE 1 = 1
 					' + CASE WHEN ISNULL(@enable_pricing, 'n') = 'y' AND ISNULL(@enable_provisional_tab, 'n') = 'y' THEN '' 
 							 WHEN ISNULL(@enable_pricing, 'n') = 'y' AND ISNULL(@enable_provisional_tab, 'n') = 'n' THEN ' AND dpce.pricing_provisional = ''p'' '
 							 WHEN ISNULL(@enable_pricing, 'n') = 'n' AND ISNULL(@enable_provisional_tab, 'n') = 'y' THEN ' AND dpce.pricing_provisional = ''q'' '
 						ELSE '' END
 					+ '
 					
 					SELECT sdd.source_deal_detail_id, sdd.pricing_type, sdd.source_deal_group_id, sdd.pricing_type2
 					INTO ' + @pricing_type_process_table + '
 					FROM source_deal_detail sdd 
 					INNER JOIN #temp_collect_detail_ids temp ON temp.source_deal_detail_id = sdd.source_deal_detail_id
 					'
 			--PRINT(@sql)
 			EXEC(@sql)


			SET @sql = 'SELECT sdd.source_deal_detail_id,
  						   dpd.pricing_index,
  						   dpd.pricing_start,
  						   dpd.pricing_end,
  						   dpd.adder,
  						   dpd.currency,
  						   dpd.multiplier,
  						   dpd.volume,
  						   dpd.uom,
  						   dpd.pricing_provisional,
  						   sdd.source_deal_group_id,
  						   dpd.pricing_period,
  						   dpd.fixed_price,
  						   dpd.formula_id,
  						   dpd.[priority],
  						   dpd.adder_currency,
  						   dpd.pricing_uom,
  						   dpd.formula_currency,
  						   dpd.fixed_cost,
  						   dpd.fixed_cost_currency
 					INTO ' + @deemed_provisional_process_table + '
 					FROM deal_price_deemed_provisional dpd
 					INNER JOIN #temp_collect_detail_ids sdd ON sdd.source_deal_detail_id = dpd.source_deal_detail_id
 			        WHERE 1 = 1
 			        ' + CASE WHEN ISNULL(@enable_pricing, 'n') = 'y' AND ISNULL(@enable_provisional_tab, 'n') = 'y' THEN '' 
 							 WHEN ISNULL(@enable_pricing, 'n') = 'y' AND ISNULL(@enable_provisional_tab, 'n') = 'n' THEN ' AND dpd.pricing_provisional = ''p'' '
 							 WHEN ISNULL(@enable_pricing, 'n') = 'n' AND ISNULL(@enable_provisional_tab, 'n') = 'y' THEN ' AND dpd.pricing_provisional = ''q'' '
 						ELSE '' END
 					+ '
 					    
 			            
 					SELECT dpse.deal_price_std_event_provisional_id [id], sdd.source_deal_detail_id, event_type, event_date, event_pricing_type, pricing_index, adder, currency, multiplier, volume, uom, pricing_provisional, sdd.source_deal_group_id
 					INTO ' + @std_event_provisional_process_table + '
 					FROM deal_price_std_event_provisional dpse
 					INNER JOIN #temp_collect_detail_ids sdd ON sdd.source_deal_detail_id = dpse.source_deal_detail_id
 					WHERE 1 = 1
 					' + CASE WHEN ISNULL(@enable_pricing, 'n') = 'y' AND ISNULL(@enable_provisional_tab, 'n') = 'y' THEN '' 
 							 WHEN ISNULL(@enable_pricing, 'n') = 'y' AND ISNULL(@enable_provisional_tab, 'n') = 'n' THEN ' AND dpse.pricing_provisional = ''p'' '
 							 WHEN ISNULL(@enable_pricing, 'n') = 'n' AND ISNULL(@enable_provisional_tab, 'n') = 'y' THEN ' AND dpse.pricing_provisional = ''q'' '
 						ELSE '' END
 					+ '
 					
 					SELECT dpce.deal_price_custom_event_provisional_id [id], sdd.source_deal_detail_id, event_type, event_date, pricing_index, skip_days, quotes_before, quotes_after, include_event_date, include_holidays, adder, currency, multiplier, volume, uom, pricing_provisional, sdd.source_deal_group_id
 					INTO ' + @custom_event_provisional_process_table + '
 					FROM deal_price_custom_event_provisional dpce
 					INNER JOIN #temp_collect_detail_ids sdd ON sdd.source_deal_detail_id = dpce.source_deal_detail_id
 					WHERE 1 = 1
 					' + CASE WHEN ISNULL(@enable_pricing, 'n') = 'y' AND ISNULL(@enable_provisional_tab, 'n') = 'y' THEN '' 
 							 WHEN ISNULL(@enable_pricing, 'n') = 'y' AND ISNULL(@enable_provisional_tab, 'n') = 'n' THEN ' AND dpce.pricing_provisional = ''p'' '
 							 WHEN ISNULL(@enable_pricing, 'n') = 'n' AND ISNULL(@enable_provisional_tab, 'n') = 'y' THEN ' AND dpce.pricing_provisional = ''q'' '
 						ELSE '' END
 					+ '
 					
 					SELECT sdd.source_deal_detail_id, sdd.pricing_type, sdd.source_deal_group_id, sdd.pricing_type2
 					INTO ' + @pricing_type_provisional_process_table + '
 					FROM source_deal_detail sdd 
 					INNER JOIN #temp_collect_detail_ids temp ON temp.source_deal_detail_id = sdd.source_deal_detail_id
 					'
 			--PRINT(@sql)
 			EXEC(@sql)


		END
 	END
 	
	IF @source_deal_header_id IS NOT NULL AND @flag = 'e'
	BEGIN
 		IF OBJECT_ID('tempdb..#temp_deal_grouping_info') IS NOT NULL
 			DROP TABLE #temp_deal_grouping_info
 		
 		CREATE TABLE #temp_deal_grouping_info (
 			column_name NVARCHAR(500) COLLATE DATABASE_DEFAULT,
 			table_name NVARCHAR(500) COLLATE DATABASE_DEFAULT,
 			original_column_name NVARCHAR(500) COLLATE DATABASE_DEFAULT,
 			table_alias NVARCHAR(20) COLLATE DATABASE_DEFAULT,
 			label_column NVARCHAR(50) COLLATE DATABASE_DEFAULT,
 			data_type NVARCHAR(50) COLLATE DATABASE_DEFAULT
 		)
 		
 		DECLARE @grouping_cols NVARCHAR(2000)
 		SELECT @grouping_cols = grouping_columns
 		FROM deal_grouping_information dgi
 		WHERE dgi.template_id = @template_id
 		
 		IF @grouping_cols IS NULL
 			SET @grouping_cols = 'term_start,term_end,location_id,curve_id'
 		
		INSERT INTO #temp_deal_grouping_info(column_name, table_name, original_column_name, table_alias, label_column, data_type)
 		SELECT scsv.item,
 				CASE scsv.item 
 					WHEN 'location_id' THEN 'source_minor_location'
 					WHEN 'curve_id' THEN 'source_price_curve_def'
 					ELSE NULL
 				END,
 				CASE scsv.item 
 					WHEN 'location_id' THEN 'source_minor_location_id'
 					WHEN 'curve_id' THEN 'source_curve_def_id'
 					ELSE NULL
 				END,
 				CASE scsv.item 
 					WHEN 'location_id' THEN 'sml'
 					WHEN 'curve_id' THEN 'spc'
 					ELSE NULL
 				END,
 				CASE scsv.item 
 					WHEN 'location_id' THEN 'Location_Name'
 					WHEN 'curve_id' THEN 'curve_name'
 					ELSE NULL
 				END,
 				CASE scsv.item 
 					WHEN 'term_start' THEN 'datetime'
 					WHEN 'term_end' THEN 'datetime'
 					WHEN 'leg' THEN 'int'
 					ELSE NULL
 				END					
 		FROM dbo.SplitCommaSeperatedValues(@grouping_cols) scsv
 		
 		DECLARE @grouping_joins NVARCHAR(MAX)
 		DECLARE @grouping_labels NVARCHAR(MAX)
 		
 		SELECT @grouping_joins = COALESCE(@grouping_joins + ' ', '') + 'LEFT JOIN ' + table_name + ' ' + table_alias + ' ON sdd.' + column_name + ' = ' + table_alias + '.' + original_column_name,
 				@grouping_labels = COALESCE(@grouping_labels + ' + ', '') + 'ISNULL('' - '' +  MAX(' + table_alias + '.' + label_column + '), '''')'
 		FROM #temp_deal_grouping_info
 		WHERE table_name IS NOT NULL
 			
 		SELECT @grouping_labels = COALESCE(@grouping_labels + '+', '') + 'ISNULL('' - '' + ' + CASE WHEN data_type = 'int' THEN 'CAST(MAX(sdd.' + column_name + ') AS NVARCHAR(20))' ELSE 'dbo.FNADateFormat(MAX(sdd.' + column_name + '))' END + ', '''')'
 		FROM #temp_deal_grouping_info
 		WHERE table_name IS NULL
 		
 		SET @sql = '			
 					INSERT INTO ' + @deal_update_detail + ' (deal_group, group_id, detail_flag, blotterleg, ' + @field_process_detail + ')
 					SELECT ISNULL(LTRIM(RTRIM(CAST(sdg.quantity AS NVARCHAR(10)))) + ''x->'', '''') + ISNULL(RTRIM(LTRIM(sdg.static_group_name)) + '' :: '', '''') + RTRIM(LTRIM(sdg.source_deal_groups_name)),
 						   sdg.source_deal_groups_id,
 					sdg.detail_flag,
						   sdd.leg, 
						   ' + @field_temp_detail + '
 					FROM ' + CASE WHEN @view_deleted ='y' THEN 'delete_' ELSE '' END + 'source_deal_header sdh 
 					INNER JOIN ' + CASE WHEN @view_deleted ='y' THEN 'delete_' ELSE '' END + 'source_deal_groups sdg ON sdg.source_deal_header_id = sdh.source_deal_header_id
 					INNER JOIN ' + CASE WHEN @view_deleted ='y' THEN 'delete_' ELSE '' END + 'source_deal_detail sdd 
 						ON sdd.source_deal_header_id = sdh.source_deal_header_id
 						AND sdg.source_deal_groups_id = sdd.source_deal_group_id					
 					WHERE sdh.source_deal_header_id = ' + CAST(@source_deal_header_id AS NVARCHAR(20)) + '	
 					
 					UPDATE temp
 					SET deal_group = temp2.new_group_name 					
 					FROM ' + @deal_update_detail + ' temp
 					INNER JOIN (
 						SELECT SUBSTRING(sdd.group_name, 3, LEN(sdd.group_name)) [new_group_name], group_id
 						FROM ' + @deal_update_detail + ' temp
 						OUTER APPLY (
 							SELECT ' + @grouping_labels + ' group_name
 							FROM source_deal_detail sdd 
 							' + ISNULL(@grouping_joins, '') + '
 							WHERE temp.group_id = sdd.source_deal_group_id
 						) sdd 	
 						WHERE NULLIF(temp.deal_group, '''') IS NULL
 					) temp2 ON temp.group_id = temp2.group_id 	
 					
 		'
 		--PRINT(@sql)
 		EXEC(@sql)

		-- Commented 17301 (Forecasted). Because, there was requirement to not update deal volume with total volume for Forecasted Deal Type.
		IF EXISTS (SELECT internal_desk_id FROM source_deal_header WHERE source_deal_header_id = @source_deal_header_id AND internal_desk_id IN (17301, 17302))
		BEGIN
			IF EXISTS (SELECT internal_desk_id FROM source_deal_header WHERE source_deal_header_id = @source_deal_header_id AND internal_desk_id IN (17301))
			BEGIN
			EXEC('
				IF COL_LENGTH(''' + @deal_update_detail + ''', ''deal_volume'') IS NOT NULL
					UPDATE a 
					SET a.deal_volume = sdd.total_volume 
					FROM ' + @deal_update_detail + ' a
					INNER JOIN source_deal_detail sdd ON sdd.source_deal_detail_id = a.source_deal_detail_id
			')
			END
			ELSE
				BEGIN
				EXEC('
					IF COL_LENGTH(''' + @deal_update_detail + ''', ''deal_volume'') IS NOT NULL
					BEGIN
					;WITH [vbp] AS (
						SELECT sddh.source_deal_detail_id [detail_id],
							sddh.volume * sddh.price [vol_by_price]
						FROM ' + @deal_update_detail + ' a
						INNER JOIN source_deal_detail_hour sddh ON sddh.source_deal_detail_id = a.source_deal_detail_id
					)
					UPDATE a
					SET a.deal_volume = vol_prc.volume
					FROM ' + @deal_update_detail + ' a
					INNER JOIN source_deal_detail sdd ON sdd.source_deal_detail_id = a.source_deal_detail_id
					OUTER APPLY (
						SELECT AVG(sddh.volume) [volume],
							AVG(sddh.price) [price],
							SUM(sddh.volume) [sum_volume],
							SUM(v.vol_by_price) [sum_vpb]
						FROM source_deal_detail_hour sddh
						INNER JOIN [vbp] v ON v.detail_id = sdd.source_deal_detail_id
						WHERE sddh.source_deal_detail_id = sdd.source_deal_detail_id
					) vol_prc
					END')
				END
				EXEC('
				IF COL_LENGTH(''' + @deal_update_detail + ''', ''deal_volume_uom_id'') IS NOT NULL
					UPDATE a 
					SET a.deal_volume_uom_id = ISNULL(a.deal_volume_uom_id, sdd.position_uom)
					FROM ' + @deal_update_detail + ' a
					INNER JOIN source_deal_detail sdd ON sdd.source_deal_detail_id = a.source_deal_detail_id
			')

			-- Checked fixed_price column existence in process table and handled the query execution error if column doesn't exist by making the query NULL
			-- If fixed priced field is not checked in the deal type pricing mapping
			EXEC('
				DECLARE @fixed_price_column_name VARCHAR(100) = NULL
				IF COL_LENGTH(''' + @deal_update_detail + ''', ''fixed_price'') IS NOT NULL
				BEGIN
					SET @fixed_price_column_name = ''fixed_price''
				END
				
				DECLARE @sql VARCHAR(MAX) = ''
					;WITH [vbp] AS (
						SELECT sddh.source_deal_detail_id [detail_id],
							sddh.volume * sddh.price [vol_by_price]
						FROM ' + @deal_update_detail + ' a
						INNER JOIN source_deal_detail_hour sddh ON sddh.source_deal_detail_id = a.source_deal_detail_id
					)
					UPDATE a
					SET a.'' + @fixed_price_column_name + '' = COALESCE(vol_prc.sum_vpb/IIF(vol_prc.sum_volume = 0, 1, vol_prc.sum_volume), sdd.fixed_price)
					FROM ' + @deal_update_detail + ' a
					INNER JOIN source_deal_detail sdd ON sdd.source_deal_detail_id = a.source_deal_detail_id
					OUTER APPLY (
						SELECT AVG(sddh.volume) [volume],
							AVG(sddh.price) [price],
							SUM(sddh.volume) [sum_volume],
							SUM(v.vol_by_price) [sum_vpb]
						FROM source_deal_detail_hour sddh
						INNER JOIN [vbp] v ON v.detail_id = sdd.source_deal_detail_id
						WHERE sddh.source_deal_detail_id = sdd.source_deal_detail_id
					) vol_prc
				''
				EXEC (@sql)     
		   ')
		END
		
	END
	ELSE IF @flag = 'e'
	BEGIN
 		SET @sql = '			
 					INSERT INTO ' + @deal_update_detail + ' (template_id, deal_group, group_id, detail_flag, blotterleg, ' + @field_process_detail + ')
 					SELECT 
 					' + CAST(@template_id AS NVARCHAR(20)) + ',
 					''New Group'',
 					1,
 					0,
 					sdd.leg, ' + @field_temp_detail + '
 					FROM source_deal_header_template sdht 
 					INNER JOIN source_deal_detail_template sdd
 						ON sdht.template_id = sdd.template_id
 					WHERE sdht.template_id = ' + CAST(@template_id AS NVARCHAR(20)) + '		
 		'
 		--PRINT(@sql)
 		EXEC(@sql)

		SET @sql = '';
		SELECT @sql +=	' UPDATE ' + @deal_update_detail + '
						 SET ' + ftc.id + ' = ISNULL('+ ftc.id +', ''' + ISNULL(uddf.default_value, '') + ''')
						 WHERE blotterleg = ' + CAST(uddf.leg AS NVARCHAR(10)) 			 
		FROM user_defined_deal_fields_template_main uddf
		INNER JOIN user_defined_fields_template udft
			ON uddf.field_id = udft.field_id
		INNER JOIN #field_template_collection ftc
			ON ftc.field_id = udft.udf_template_id
		WHERE template_id = @template_id
			AND  udf_or_system = 'u'
 		
		EXEC(@sql)
 		
 		IF @term_rule IS NULL AND @term_frequency = 'd'
 			SET @term_rule = 19308
 		
 		IF @term_rule IS NULL AND @term_frequency = 'm'
 			SET @term_rule = 19312
 			
 		IF @term_rule IS NOT NULL AND EXISTS (SELECT 1 FROM #field_template_collection WHERE id = 'term_start')
 		BEGIN
			SET @sql = '						 
						UPDATE ' + @deal_update_detail + '
 						SET term_start = ''' + CONVERT(NVARCHAR(10), dbo.FNAResolveDate(@default_deal_date, @term_rule), 120) + '''
						' + CASE WHEN @term_end_exists = 1 THEN',
 							term_end = ''' + CONVERT(NVARCHAR(10), CASE @term_frequency WHEN 't' THEN dbo.FNAResolveDate(@default_deal_date, @term_rule) ELSE dbo.FNAGetTermEndDate(@term_frequency, dbo.FNAResolveDate(@default_deal_date, @term_rule), 0) END, 120) + '''
						' ELSE '' END	
 		
			IF COL_LENGTH(@deal_update_detail, 'contract_expiration_date') IS NOT NULL
				SET @sql += ', contract_expiration_date = CASE WHEN contract_expiration_date IS NULL THEN ''' + CONVERT(NVARCHAR(10), CASE @term_frequency WHEN 't' THEN dbo.FNAResolveDate(@default_deal_date, @term_rule) ELSE dbo.FNAGetTermEndDate(@term_frequency, dbo.FNAResolveDate(@default_deal_date, @term_rule), 0) END, 120) + ''' ELSE contract_expiration_date END '
 						
			SET @sql += ' WHERE term_start IS NULL '
 			--PRINT(@sql)
 			EXEC(@sql)
 		END
 		
 		SET @sql = 'UPDATE ' + @deal_update_detail + '
					SET source_deal_detail_id = ''NEW_'' + CAST(blotterleg AS NVARCHAR(10))'
		EXEC(@sql)
	END
	
	IF @udf_value IS NOT NULL AND @copy_deal_id IS NULL AND @flag = 'e'
	BEGIN
 		SET @sql = '
 					UPDATE ' + @deal_update_detail + '
 					SET    ' + @udf_value + '
 					FROM   ' + @deal_update_detail + ' t
 					INNER JOIN (
 						SELECT *
 						FROM   (
 							SELECT source_deal_detail_id,
 									udf_template_id,
 									udf_value
 							FROM   #temp_uddf
 						) src 
 						PIVOT(
 							MAX(udf_value) FOR udf_template_id   
 							IN (' + @udf_field_id + ')
 						) AS pvt
 					) u
 					ON  t.source_deal_detail_id = CAST(u.source_deal_detail_id AS NVARCHAR(10))  
 		'
 	
 		--PRINT(@sql)
 		EXEC(@sql)
	END
	ELSE IF @copy_deal_id IS NOT NULL AND @flag = 'e'
	BEGIN
 		SET @sql = '
 					UPDATE ' + @deal_update_detail + '
 					SET    ' + @udf_value + '
 					FROM   ' + @deal_update_detail + ' t
 					INNER JOIN (
 						SELECT *
 						FROM   (
 							SELECT  DENSE_RANK() OVER(ORDER BY sdd.source_deal_group_id ASC) group_id ,
 									udf_template_id,
 									MAX(udf_value) udf_value,
									sdd.source_deal_detail_id
 							FROM #temp_uddf t
 							INNER JOIN source_deal_detail sdd ON t.source_deal_detail_id = sdd.source_deal_detail_id
 							GROUP BY source_deal_group_id, sdd.source_deal_detail_id, udf_template_id
 						) src 
 						PIVOT(
 							MAX(udf_value) FOR udf_template_id   
 							IN (' + @udf_field_id + ')
 						) AS pvt
 					) u
 					ON  t.group_id = u.group_id AND t.source_deal_detail_id = u.source_deal_detail_id
 		'
 		--PRINT(@sql)
 		EXEC(@sql)

		SET @sql = 'UPDATE ' + @deal_update_detail + '
					SET source_deal_detail_id = ''NEW_'' + CAST(blotterleg AS NVARCHAR(10)) + ''_'' + LEFT(REPLACE(NEWID(), ''-'', ''''), 10)'
		EXEC(@sql)
	END
 	
	DECLARE @floating_volume INT, @udf_id NVARCHAR(200)
 	
	SELECT @floating_volume = value_id 
	FROM static_data_value 
	WHERE type_id = 5500
	AND code = 'Available Volume'
 	
	SELECT @udf_id = 'UDF___' + CAST(udft.udf_template_id AS NVARCHAR) 
	FROM user_defined_fields_template udft
	WHERE field_name = @floating_volume
 	
	IF EXISTS(
 		SELECT 1 FROM #field_template_collection WHERE id = @udf_id
	) AND @flag = 'e'
	BEGIN
 		SET @sql = 'UPDATE temp
 					SET [' + @udf_id +  '] = dbo.FNARemoveTrailingZero((temp.deal_volume - ISNULL(vol.volume, 0))) 
 					FROM ' + @deal_update_detail + ' temp
 					OUTER APPLY (
     					SELECT SUM(sdd.deal_volume) [volume] 
     					FROM source_deal_header sdh
     					INNER JOIN source_deal_detail sdd ON sdd.source_deal_header_id = sdh.source_deal_header_id
     					WHERE CAST(sdh.reference_detail_id AS NVARCHAR(10)) = temp.source_deal_detail_id
 					) vol'
 		EXEC(@sql) 

	END
 	
	SET @formula_present = COL_LENGTH(@deal_update_detail, 'formula_id')
	SET @position_formula_present = COL_LENGTH(@deal_update_detail, 'position_formula_id')
	IF @formula_present IS NOT NULL AND @flag = 'e'
	BEGIN
		IF OBJECT_ID (N'tempdb..#temp_formula_id') IS NOT NULL  
			DROP TABLE 	#temp_formula_id

		CREATE TABLE #temp_formula_id(formula_id NVARCHAR(100))
		SET @sql = ' INSERT INTO #temp_formula_id
					 SELECT DISTINCT temp.formula_id
					 FROM ' + @deal_update_detail + ' temp
 					 INNER JOIN formula_editor fe ON CAST(fe.formula_id AS NVARCHAR(2000)) = temp.formula_id ' +
					 CASE WHEN @position_formula_present IS NOT NULL
					 THEN
							' UNION  
					 SELECT DISTINCT position_formula_id
					 FROM ' + @deal_update_detail + ' temp
 							 INNER JOIN formula_editor fe ON CAST(fe.formula_id AS NVARCHAR(2000)) = temp.position_formula_id '
					ELSE 
						''
					END
		EXEC(@sql)

		IF EXISTS(SELECT 1 FROM #temp_formula_id)
		BEGIN

			SELECT @formula_id = ISNULL(@formula_id+',', '') +COALESCE(formula_id,'') 
			FROM  #temp_formula_id 

			SET @temp_process_id  = dbo.FNAGetNewId()
			SET @temp_process_table = dbo.FNAProcessTableName('formula_editor', @user_name, @temp_process_id)
			EXEC spa_resolve_function_parameter @flag = 's',@process_id = @temp_process_id, @formula_id = @formula_id
 			SET @sql = 'UPDATE temp
 						SET formula_id = CAST(fe.formula_id AS NVARCHAR(200)) + ''^'' + CAST(fe.formula_id AS NVARCHAR(200)) + '' - '' + ISNULL(NULLIF(fe.formula_name, ''''), tpt.formula_name)
 						FROM ' + @deal_update_detail + ' temp
 						INNER JOIN formula_editor fe ON CAST(fe.formula_id AS NVARCHAR(2000)) = temp.formula_id
						INNER JOIN ' + @temp_process_table + ' tpt
							ON tpt.formula_id = fe.formula_id
						'
			EXEC(@sql)
			IF @position_formula_present IS NOT NULL 
			BEGIN
			SET @sql = 'UPDATE temp
 						SET  position_formula_id = CAST(fe.formula_id AS NVARCHAR(200)) + ''^'' + CAST(fe.formula_id AS NVARCHAR(200)) + '' - '' + fe.formula_name
						FROM ' + @deal_update_detail + ' temp
 						INNER JOIN formula_editor fe ON CAST(fe.formula_id AS NVARCHAR(2000)) = temp.position_formula_id
						INNER JOIN ' + @temp_process_table + ' tpt
							ON tpt.formula_id = fe.formula_id
						'
			EXEC(@sql)
		END
	END
	END
	
	DECLARE @phy_fin_present INT
	SET @phy_fin_present = COL_LENGTH(@deal_update_detail, 'physical_financial_flag')
	
	IF @flag = 'e' AND @source_deal_header_id IS NULL
	BEGIN
		DECLARE @mapping_present INT = 0
		SET @sql = 'UPDATE sdd SET deal_group = sdd.deal_group '
				
		IF COL_LENGTH(@deal_update_detail, 'physical_financial_flag') IS NOT NULL
		BEGIN
			SET @sql += ' ,physical_financial_flag = ISNULL(ddv.physical_financial_flag, sdd.physical_financial_flag)'
			SET @mapping_present = 1
		END	
		IF COL_LENGTH(@deal_update_detail, 'upstream_counterparty') IS NOT NULL
		BEGIN
			SET @sql += ' ,upstream_counterparty = ISNULL(ddv.upstream_counterparty, sdd.upstream_counterparty)'
			SET @mapping_present = 1
		END	

		IF COL_LENGTH(@deal_update_detail, 'upstream_contract') IS NOT NULL
		BEGIN
			SET @sql += ' ,upstream_contract = ISNULL(ddv.upstream_contract, sdd.upstream_contract)'			
			SET @mapping_present = 1
		END		

		IF COL_LENGTH(@deal_update_detail, 'fx_conversion_rate') IS NOT NULL
		BEGIN
			SET @sql += ' ,fx_conversion_rate = ISNULL(ddv.fx_conversion_rate, sdd.fx_conversion_rate)'
			SET @mapping_present = 1
		END	

		IF COL_LENGTH(@deal_update_detail, 'settlement_currency') IS NOT NULL
		BEGIN
			SET @sql += ' ,settlement_currency = ISNULL(ddv.settlement_currency, sdd.settlement_currency)'
			SET @mapping_present = 1
		END	

		IF COL_LENGTH(@deal_update_detail, 'settlement_date') IS NOT NULL
		BEGIN
			SET @sql += ' ,settlement_date = ISNULL(ddv.settlement_date, sdd.settlement_date)'
			SET @mapping_present = 1
		END	

		IF COL_LENGTH(@deal_update_detail, 'cycle') IS NOT NULL
		BEGIN
			SET @sql += ' ,cycle = ISNULL(ddv.cycle, sdd.cycle)'
			SET @mapping_present = 1
		END	

		IF @mapping_present = 1
		BEGIN
			SET @sql += ' 
					FROM ' + @deal_update_detail + ' sdd 
					INNER JOIN (
						SELECT leg, buy_sell_flag FROM source_deal_detail_template sddt WHERE sddt.template_id = ' + CAST(@template_id AS NVARCHAR(10)) + '
					) sddt ON sddt.leg = sdd.blotterleg
					OUTER APPLY (
						SELECT TOP(1) * 
						FROM deal_default_value ddv WHERE ddv.deal_type_id = ' + CAST(@deal_type_id AS NVARCHAR(10)) + '
						AND ((pricing_type IS NULL AND ' + ISNULL(CAST(@pricing_type AS NVARCHAR(10)), 'NULL') + ' IS NULL) OR pricing_type = ' + CAST(ISNULL(@pricing_type, 0) AS NVARCHAR(10)) + ')
						AND ISNULL(commodity, -1) = ' + CAST(ISNULL(@commodity_id, -1) AS NVARCHAR(10)) + ' 
						AND (ddv.buy_sell_flag IS NULL OR ISNULL(ddv.buy_sell_flag, ''x'') = ISNULL(sddt.buy_sell_flag, ''y''))
					) ddv
			'
			--PRINT(@sql)
			EXEC(@sql) 
		END
	END
 	--PRINT 'deded'
 	DECLARE @proct_desc_present INT
 	SET @proct_desc_present = COL_LENGTH(@deal_update_detail, 'product_description') 	
 	IF @proct_desc_present IS NOT NULL AND @flag = 'e'
 	BEGIN
 		SET @sql = 'UPDATE temp
 					SET product_description = ISNULL(sco.commodity_name, '''') + '' '' + ISNULL(sdv_form.code, '''') + '' | '' +  ISNULL(sdv_origin.code, '''') + '' |'' +  CASE WHEN sdd.organic = ''y'' THEN '' Organic'' ELSE '''' END + '' '' + ISNULL(sdv_att1.code, '''') + '' '' +  ISNULL(sdv_att2.code, '''') + '' '' +  ISNULL(sdv_att3.code, '''') + '' '' +  ISNULL(sdv_att4.code, '''') + '' '' +  ISNULL(sdv_att5.code, '''')
 					FROM ' + @deal_update_detail + ' temp
 					INNER JOIN source_deal_detail sdd ON CAST(sdd.source_deal_detail_id AS NVARCHAR(10)) = temp.source_deal_detail_id
					LEFT JOIN source_commodity sco ON sco.source_commodity_id = sdd.detail_commodity_id
 					LEFT JOIN commodity_origin co ON co.commodity_origin_id = sdd.origin
				    LEFT JOIN static_data_value sdv_origin ON sdv_origin.value_id = co.origin AND sdv_origin.value_id > 0       
				    LEFT JOIN commodity_form cf ON cf.commodity_form_id = sdd.[form]
				    LEFT JOIN commodity_type_form ct_form ON ct_form.commodity_type_form_id = cf.form
					LEFT JOIN static_data_value sdv_form ON sdv_form.value_id = ct_form.commodity_form_value AND sdv_form.value_id > 0
				    LEFT JOIN commodity_form_attribute1 cfa1 ON cfa1.commodity_form_attribute1_id = sdd.attribute1
				    LEFT JOIN commodity_attribute_form caf1 on caf1.commodity_attribute_form_id = cfa1.attribute_form_id
					LEFT JOIN static_data_value sdv_att1 ON sdv_att1.value_id = caf1.commodity_attribute_value AND sdv_att1.value_id > 0
				    LEFT JOIN commodity_form_attribute2 cfa2 ON cfa2.commodity_form_attribute2_id = sdd.attribute2
				    LEFT JOIN commodity_attribute_form caf2 on caf2.commodity_attribute_form_id = cfa2.attribute_form_id	
					LEFT JOIN static_data_value sdv_att2 ON sdv_att2.value_id = caf2.commodity_attribute_value AND sdv_att2.value_id > 0     
				    LEFT JOIN commodity_form_attribute3 cfa3 ON cfa3.commodity_form_attribute3_id = sdd.attribute3
				    LEFT JOIN commodity_attribute_form caf3 on caf3.commodity_attribute_form_id = cfa3.attribute_form_id
					LEFT JOIN static_data_value sdv_att3 ON sdv_att3.value_id = caf3.commodity_attribute_value AND sdv_att3.value_id > 0	       
				    LEFT JOIN commodity_form_attribute4 cfa4 ON cfa4.commodity_form_attribute4_id = sdd.attribute4
				    LEFT JOIN commodity_attribute_form caf4 on caf4.commodity_attribute_form_id = cfa4.attribute_form_id
					LEFT JOIN static_data_value sdv_att4 ON sdv_att4.value_id = caf4.commodity_attribute_value AND sdv_att4.value_id > 0	       
				    LEFT JOIN commodity_form_attribute5 cfa5 ON cfa5.commodity_form_attribute5_id = sdd.attribute5
				    LEFT JOIN commodity_attribute_form caf5 on caf5.commodity_attribute_form_id = cfa5.attribute_form_id
					LEFT JOIN static_data_value sdv_att5 ON sdv_att5.value_id = caf5.commodity_attribute_value AND sdv_att5.value_id > 0
 		            WHERE NULLIF(temp.product_description, '''') IS NULL
					'
 		--PRINT(@sql)
 		EXEC(@sql)
 	END
 	
	DECLARE @select_statement NVARCHAR(MAX)
 	
	IF @copy_deal_id IS NOT NULL AND @flag = 'e' AND EXISTS (SELECT 1 FROM #field_template_collection WHERE id = 'term_start')
	BEGIN
 		DECLARE @new_process_table NVARCHAR(300)
 		SET @new_process_table = dbo.FNAProcessTableName('new_process_table', @user_name, @process_id)
 		
 		IF OBJECT_ID(@new_process_table) IS NOT NULL
 			EXEC('DROP TABLE ' + @new_process_table)
 		
 		EXEC('SELECT deal_group, group_id, detail_flag, sdd.blotterleg,  ' + @final_select + ' INTO ' + @new_process_table + ' FROM '+ @deal_update_detail + ' sdd WHERE 1 = 2')
 		
 		SET @sql = ';WITH CTE_UPDATE AS (
 						SELECT ROW_NUMBER() OVER(PARTITION BY group_id, blotterleg ORDER BY group_id, blotterleg) group_row_id, deal_group, group_id, detail_flag, sdd.blotterleg,  ' + @final_select + ' FROM ' + @deal_update_detail + ' sdd
 					)	
 					INSERT INTO ' + @new_process_table + '
 					SELECT deal_group, group_id, detail_flag, sdd.blotterleg,  ' + @final_select + ' FROM CTE_UPDATE sdd
 					'
 		--PRINT(@sql)
 		EXEC(@sql)
 		SET @select_statement = 'SELECT RTRIM(LTRIM(deal_group)) deal_group, group_id, detail_flag, sdd.blotterleg,  ' + @final_select + ' FROM ' + @new_process_table + ' sdd ORDER BY CONVERT(DATETIME, sdd.term_start, 120)'
	END
	ELSE IF @flag = 'e'
	BEGIN
		IF @source_deal_header_id IS NOT NULL
		BEGIN
			IF @is_gas_daily = 'y'
			BEGIN
				SET @term_end_present = COL_LENGTH(@deal_update_detail, 'term_end')

				IF @term_end_present IS NOT NULL
				BEGIN
					SET @sql = '
						UPDATE ' + @deal_update_detail + '
						SET term_end = CONVERT(NVARCHAR(10), DATEADD(d, 1, term_end), 120)
					'
					EXEC(@sql)
				END
			END
		END
		IF @call_from = 'fields_and_values'
		BEGIN
			DECLARE @detail_field_values_process_table NVARCHAR(100)
			SET @detail_field_values_process_table = dbo.FNAProcessTableName('detail_field_values', @user_name, @detail_value_process_id)
		
			SET @select_statement = 'SELECT RTRIM(LTRIM(deal_group)) deal_group, CAST(group_id AS NVARCHAR(100)) group_id, detail_flag, sdd.blotterleg,  ' + @final_select + ', IDENTITY(INT,1,1) AS ID INTO ' + @detail_field_values_process_table + ' FROM ' + @deal_update_detail + ' sdd ' + @order_by
		END
		ELSE
		BEGIN
			 SET @select_statement = 'SELECT RTRIM(LTRIM(deal_group)) deal_group, group_id, detail_flag, sdd.blotterleg,  ' + @final_select + ' FROM ' + @deal_update_detail + ' sdd ' + @order_by
		END
	END

	IF @flag = 'd'
	BEGIN
 		SELECT @detail_grid_labels [config_json], @detail_combo_list [combo_list], @filter_list [filter_list], @select_statement [data_sp], @validation_rule [validation_rule], @detail_form_final [form_json], @header_menu [header_menu], @detail_tab_json [tab_json], @detail_tab_ids [tab_ids], @process_id [process_id], @formula_fields_detail [detail_formula_field], CASE WHEN @formula_fields_detail IS NOT NULL OR @enable_pricing = 'y' OR @enable_provisional_tab = 'y' THEN @formula_process_id ELSE NULL END [formula_process_id]
	END
	ELSE
	BEGIN
 		EXEC(@select_statement)
	END
END
ELSE IF @flag = 's'
BEGIN
BEGIN TRAN
BEGIN TRY
 	DECLARE @change_in_buy_sell NCHAR(1)
 	DECLARE @min_value NVARCHAR(200), 
			@max_value NVARCHAR(200),
			@column_name NVARCHAR(200),
			@err_msg NVARCHAR(MAX)
 		
	IF OBJECT_ID('tempdb..#temp_pre_sdh') IS NOT NULL DROP TABLE #temp_pre_sdh
	IF OBJECT_ID('tempdb..#temp_pre_sdd') IS NOT NULL DROP TABLE #temp_pre_sdd
	IF OBJECT_ID('tempdb..#temp_post_sdh') IS NOT NULL DROP TABLE #temp_post_sdh
	IF OBJECT_ID('tempdb..#temp_post_sdd') IS NOT NULL DROP TABLE #temp_post_sdd

	-- Insert data of deal prior to modification
	;WITH temp_tbl AS (
		SELECT CAST(source_deal_header_id AS VARCHAR(50)) source_deal_header_id,
			CAST(physical_financial_flag AS VARCHAR(50)) [physical_financial_flag],
			CAST(term_frequency AS VARCHAR(50)) term_frequency,
			CAST(header_buy_sell_flag AS VARCHAR(50)) AS header_buy_sell_flag,
			CAST(block_define_id AS VARCHAR(50)) AS block_define_id,
			CAST(source_deal_type_id AS VARCHAR(50)) AS source_deal_type_id,
			CAST(counterparty_id AS VARCHAR(50)) AS counterparty_id,
			CAST(close_reference_id AS VARCHAR(50)) AS close_reference_id,
			CAST(sub_book AS VARCHAR(50)) AS sub_book,
			CAST(source_system_book_id1 AS VARCHAR(50)) AS source_system_book_id1,
			CAST(source_system_book_id2 AS VARCHAR(50)) AS source_system_book_id2,
			CAST(source_system_book_id3 AS VARCHAR(50)) AS source_system_book_id3,
			CAST(source_system_book_id4 AS VARCHAR(50)) AS source_system_book_id4
		FROM source_deal_header
		WHERE source_deal_header_id = @source_deal_header_id
	)
	SELECT unp.[column], unp.[value]
	INTO #temp_pre_sdh
	FROM temp_tbl tsdh
	UNPIVOT (
		[value] FOR [column] IN (
			source_deal_header_id, physical_financial_flag, term_frequency, header_buy_sell_flag,
			block_define_id, source_deal_type_id, counterparty_id, close_reference_id, sub_book,
			source_system_book_id1, source_system_book_id2, source_system_book_id3, source_system_book_id4
		)
	) unp
	ORDER BY unp.[column] ASC

	-- Insert data of deal prior to modification
	;WITH temp_tbl AS (
		SELECT CAST(source_deal_header_id AS VARCHAR(50)) source_deal_header_id,
			CAST(source_deal_detail_id AS VARCHAR(50)) source_deal_detail_id,
			CAST(dbo.FNAGetSQLStandardDate(term_start) AS VARCHAR(50)) term_start,
			CAST(dbo.FNAGetSQLStandardDate(term_end) AS VARCHAR(50)) AS term_end,
			CAST(curve_id AS VARCHAR(50)) AS curve_id,
			CAST(location_id AS VARCHAR(50)) AS location_id,
			CAST(deal_volume AS VARCHAR(50)) AS deal_volume,
			CAST(deal_volume_uom_id AS VARCHAR(50)) AS deal_volume_uom_id,
			CAST(deal_volume_frequency AS VARCHAR(50)) AS deal_volume_frequency,
			CAST(position_uom AS VARCHAR(50)) AS position_uom,
			CAST(multiplier AS VARCHAR(50)) AS multiplier,
			CAST(volume_multiplier2 AS VARCHAR(50)) AS volume_multiplier2,
			CAST(price_multiplier AS VARCHAR(50)) AS price_multiplier,
			CAST(fixed_float_leg AS VARCHAR(50)) AS fixed_float_leg,
			CAST(buy_sell_flag AS VARCHAR(50)) AS buy_sell_flag,
			CAST(standard_yearly_volume AS VARCHAR(50)) AS standard_yearly_volume,
			CAST(formula_curve_id AS VARCHAR(50)) AS formula_curve_id,
			CAST(formula_id AS VARCHAR(50)) AS formula_id,
			CAST(contractual_volume AS VARCHAR(50)) AS contractual_volume,
			CAST(physical_financial_flag AS VARCHAR(50)) AS physical_financial_flag,
			CAST(price_uom_id AS VARCHAR(50)) AS price_uom_id,
			CAST(profile_id AS VARCHAR(50)) AS profile_id
		FROM source_deal_detail
		WHERE source_deal_header_id = @source_deal_header_id
	)
	SELECT unp.[column], unp.[value]
	INTO #temp_pre_sdd
	FROM temp_tbl tsdh
	UNPIVOT (
		[value] FOR [column] IN (
			source_deal_header_id, source_deal_detail_id, term_start, term_end, curve_id,
			location_id, deal_volume, deal_volume_uom_id, deal_volume_frequency, position_uom,
			multiplier, volume_multiplier2, price_multiplier, fixed_float_leg, buy_sell_flag,
			standard_yearly_volume, formula_curve_id, formula_id, contractual_volume,
			physical_financial_flag, price_uom_id, profile_id
		)
	) unp
	ORDER BY unp.[column] ASC
 		
	IF OBJECT_ID('tempdb..#temp_updated_transfer_deals') IS NOT NULL
 		DROP TABLE #temp_updated_transfer_deals
	CREATE TABLE #temp_updated_transfer_deals (source_deal_header_id INT)
 		
 	IF @header_xml IS NOT NULL
 	BEGIN
 		DECLARE @header_process_table NVARCHAR(200)
 		SET @header_process_table = dbo.FNAProcessTableName('header_process_table', @user_name, @process_id)
		
 		EXEC spa_parse_xml_file 'b', NULL, @header_xml, @header_process_table

		DECLARE @deal_commodity_id INT, @deal_ref_id NVARCHAR(200)
		
		SELECT @deal_commodity_id = commodity_id,
				@deal_ref_id = deal_id
		FROM source_deal_header
		WHERE source_deal_header_id = @source_deal_header_id

		SET @sql = 'USE adiha_process
				
					IF COL_LENGTH(''' + @header_process_table +  ''', ''commodity_id'') IS NULL
					BEGIN
						ALTER TABLE ' + @header_process_table +  '  
						ADD commodity_id INT DEFAULT( ' + ISNULL(CAST(@deal_commodity_id AS NVARCHAR(10)), ' NULL') + ') ;					
					END	
				'

		EXEC(@sql)

		IF @is_gas_daily = 'y'
		BEGIN
			DECLARE @entire_term_end_present INT
			SET @entire_term_end_present = COL_LENGTH(@header_process_table, 'entire_term_end')

			IF @entire_term_end_present IS NOT NULL
			BEGIN
				SET @sql = '
					UPDATE ' + @header_process_table + '
					SET entire_term_end = CONVERT(NVARCHAR(10), DATEADD(d, -1, entire_term_end), 120)
				'
				EXEC(@sql)
			END			
		END
 		
 		IF OBJECT_ID('tempdb..#field_template') IS NOT NULL
			DROP TABLE #field_template

		CREATE TABLE #field_template(
			farrms_field_id     NVARCHAR(100) COLLATE DATABASE_DEFAULT,
			field_label			NVARCHAR(200) COLLATE DATABASE_DEFAULT,
			default_value       NVARCHAR(100) COLLATE DATABASE_DEFAULT,
			data_type           NVARCHAR(200) COLLATE DATABASE_DEFAULT,
			is_udf              NCHAR(1) COLLATE DATABASE_DEFAULT,
			insert_required     NCHAR(1) COLLATE DATABASE_DEFAULT,
			update_required     NCHAR(1) COLLATE DATABASE_DEFAULT,
			min_value			NVARCHAR(200) COLLATE DATABASE_DEFAULT,
			max_value			NVARCHAR(200) COLLATE DATABASE_DEFAULT
		)

		INSERT #field_template
		SELECT *
		FROM FNAGetTemplateFieldTable(@template_id, 'h', 'y') j 
		
		IF OBJECT_ID('tempdb..#temp_min_max_error_handler') IS NOT NULL
			DROP TABLE #temp_min_max_error_handler
		
		CREATE TABLE #temp_min_max_error_handler (
			err_id INT IDENTITY(1,1),
			column_name NVARCHAR(300) COLLATE DATABASE_DEFAULT,
			row_id INT,
			error_type NVARCHAR(10) COLLATE DATABASE_DEFAULT
		)

		DECLARE min_max_columns_cursor CURSOR  
		FOR
			SELECT ft.farrms_field_id,ft.max_value, ft.min_value
			FROM #field_template ft
			WHERE (ft.min_value IS NOT NULL OR ft.max_value IS NOT NULL)
			AND (ISNULL(ft.min_value,0) <> ISNULL(ft.max_value, 0))
		OPEN min_max_columns_cursor
		FETCH NEXT FROM min_max_columns_cursor INTO @column_name, @max_value, @min_value
		WHILE @@FETCH_STATUS = 0   
		BEGIN
			SET @sql = 'INSERT INTO #temp_min_max_error_handler '
			DECLARE @min_val_check INT = 0
			
			IF @min_value IS NOT NULL
			BEGIN
				SET @sql += '
								SELECT ''' + @column_name + ''', row_id, ''go beneath''
								FROM ' + @header_process_table + '
								WHERE ' + @column_name + ' < ' + @min_value + ''
				SET @min_val_check = 1
			END	
			
			IF @max_value IS NOT NULL
			BEGIN
				SET @sql += CASE WHEN @min_val_check = 1 THEN ' UNION ALL ' ELSE '' END + 
							'
								SELECT ''' + @column_name + ''', row_id, ''exceed''
								FROM ' + @header_process_table + '
								WHERE ' + @column_name + ' > ' + @max_value + ''
			END		
			--PRINT(@sql)
			EXEC(@sql)
		
			FETCH NEXT FROM min_max_columns_cursor INTO @column_name, @max_value, @min_value	
		END
		CLOSE min_max_columns_cursor
		DEALLOCATE min_max_columns_cursor
		
		IF EXISTS (SELECT 1 FROM #temp_min_max_error_handler)
		BEGIN
			SELECT TOP(1)
			@err_msg = 'Value for ' + ft.field_label + ' should not ' + tnne.error_type + ' ' + CASE WHEN tnne.error_type = 'exceed' THEN ft.max_value ELSE ft.min_value END
			FROM #temp_min_max_error_handler tnne
			INNER JOIN #field_template ft ON ft.farrms_field_id = tnne.column_name 
			
			EXEC spa_ErrorHandler -1,
					'spa_insert_blotter_deal',
					'spa_insert_blotter_deal',
					'DB Error',
					@err_msg,
					''
			RETURN
		END
		ELSE
		BEGIN
			DROP TABLE #temp_min_max_error_handler
		END			
 		
 		IF OBJECT_ID('tempdb..#temp_header_columns') IS NOT NULL
 			DROP TABLE #temp_header_columns
 		
 		IF OBJECT_ID('tempdb..#temp_sdh') IS NOT NULL
 			DROP TABLE #temp_sdh
 			
 		CREATE TABLE #temp_header_columns (
			id INT IDENTITY(1,1),
 			columns_name NVARCHAR(200) COLLATE DATABASE_DEFAULT,
 			columns_value NVARCHAR(MAX) COLLATE DATABASE_DEFAULT,
			udf_order INT
 		)
 		CREATE TABLE #temp_sdh(
 			columns_name     NVARCHAR(200) COLLATE DATABASE_DEFAULT,
 			data_type        NVARCHAR(200) COLLATE DATABASE_DEFAULT
 		)
 		
 		DECLARE @table_name NVARCHAR(200) = REPLACE(@header_process_table, 'adiha_process.dbo.', '')
 		
 		INSERT INTO #temp_header_columns (columns_name, columns_value)
 		EXEC spa_Transpose @table_name, NULL, 1
		
		UPDATE t1
		SET udf_order = t2.[oder]
 		FROM #temp_header_columns t1
		INNER JOIN (
			SELECT columns_name, ROW_NUMBER() OVER(ORDER BY id) [oder]
			FROM #temp_header_columns t
			WHERE columns_name LIKE '%UDF___%'
		) t2 ON t1.columns_name = t2.columns_name

 		INSERT INTO #temp_sdh
 		SELECT column_name,
 				DATA_TYPE
 		FROM INFORMATION_SCHEMA.Columns
 		WHERE TABLE_NAME = 'source_deal_header'
 		
		--Logic to delete source_deal_detail_hour data when granularity is changed
		DECLARE @sddh_delete BIT = 0

		IF EXISTS (SELECT 1 FROM #temp_header_columns WHERE columns_name = 'internal_desk_id') AND 
		   NOT EXISTS (
				SELECT 1
				FROM source_deal_header sdh 
				INNER JOIN (
					SELECT columns_value 
					FROM #temp_header_columns 
					WHERE columns_name = 'internal_desk_id'
				) a ON a.columns_value = sdh.internal_desk_id 
				WHERE source_deal_header_id = @source_deal_header_id
		)
		BEGIN
			SET @sddh_delete = 1
		END

		IF EXISTS (SELECT 1 FROM #temp_header_columns WHERE columns_name = 'internal_desk_id' AND columns_value = 17302) AND
		   NOT EXISTS (
				SELECT 1 
				FROM source_deal_header sdh 
				INNER JOIN (
					SELECT columns_value 
					FROM #temp_header_columns 
					WHERE columns_name = 'profile_granularity'
				) a ON a.columns_value = sdh.profile_granularity 
				WHERE source_deal_header_id = @source_deal_header_id
		)
		BEGIN
			SET @sddh_delete = 1
		END
		
		IF @sddh_delete = 1
		BEGIN
			DELETE sddh
			FROM source_deal_detail_hour sddh
			INNER JOIN source_deal_detail sdd
				ON sddh.source_deal_detail_id = sdd.source_deal_detail_id
			WHERE sdd.source_deal_header_id = @source_deal_header_id
		END

 		DECLARE @update_string NVARCHAR(MAX)
 		DECLARE @h_udf_update_string NVARCHAR(MAX)

 		SELECT @update_string = COALESCE(@update_string + ',', '') + tsdh.columns_name + ISNULL(' = N''' + CASE WHEN tsdh.data_type = 'datetime' THEN dbo.FNAGetSQLStandardDate(thc.columns_value) ELSE REPLACE(CAST(thc.columns_value AS NVARCHAR(2000)), '''', '''''') END + '''', '= NULL')
 		FROM #temp_header_columns thc
 		INNER JOIN #temp_sdh tsdh ON tsdh.columns_name = thc.columns_name
 		WHERE tsdh.columns_name NOT IN ('source_deal_header_id', 'update_ts', 'update_user', 'create_ts', 'create_user', 'template_id')
 		AND thc.columns_name NOT LIKE '%UDF___%'
 			
 		DECLARE @prior_buy_sell NCHAR(1), @prior_sub_book INT
 		SELECT @prior_buy_sell = header_buy_sell_flag,
 				@prior_sub_book = sub_book
 		FROM source_deal_header WHERE source_deal_header_id = @source_deal_header_id
 			
 		SET @sql = '
 					UPDATE sdh
 					SET ' + @update_string + '
 					FROM source_deal_header sdh 
 					WHERE sdh.source_deal_header_id = ' + CAST(@source_deal_header_id AS NVARCHAR(20)) + '					
 					'
 		-- PRINT(@sql)
 		EXEC(@sql)

		UPDATE sdd SET  deal_volume = COALESCE(deal_volume, sdd.contractual_volume)
		FROM source_deal_header sdh
		INNER JOIN source_deal_detail sdd 
			ON sdd.source_deal_header_id = sdh.source_deal_header_id	
		WHERE sdh.internal_deal_subtype_value_id = 158 ---'Physical ? Oi land Soft'	
			AND sdh.source_deal_header_id = @source_deal_header_id
 			
 		DECLARE @after_buy_sell NCHAR(1), @after_sub_book INT
 		SELECT @after_buy_sell = header_buy_sell_flag,
 				@after_sub_book = sub_book
 		FROM source_deal_header WHERE source_deal_header_id = @source_deal_header_id
 			
 		IF @prior_buy_sell = @after_buy_sell
 			SET @change_in_buy_sell = 'n' 
 		ELSE 
 			SET @change_in_buy_sell = 'y'
 			
 			
 		IF @prior_sub_book <> @after_sub_book
 		BEGIN
				INSERT into deal_tagging_audit(source_deal_header_id,
                                           source_system_book_id1,
                                           source_system_book_id2,
                                           source_system_book_id3,
                                           source_system_book_id4
                                          ) 
                                           
				SELECT source_deal_header_id,
                    ssbm.source_system_book_id1,
                    ssbm.source_system_book_id2,
                    ssbm.source_system_book_id3,
                    ssbm.source_system_book_id4
				FROM  source_deal_header sdh
				INNER JOIN source_system_book_map ssbm
						ON sdh.sub_book = ssbm.book_deal_type_map_id
				WHERE sdh.source_deal_header_id = @source_deal_header_id	

 			UPDATE sdh
 			SET source_system_book_id1 = ssbm.source_system_book_id1,
 				source_system_book_id2 = ssbm.source_system_book_id2,
 				source_system_book_id3 = ssbm.source_system_book_id3,
 				source_system_book_id4 = ssbm.source_system_book_id4
 			FROM source_deal_header sdh
 			INNER JOIN source_system_book_map ssbm
 				ON sdh.sub_book = ssbm.book_deal_type_map_id
 			WHERE sdh.source_deal_header_id = @source_deal_header_id
 		END

		-- update UDF
 		UPDATE uddf
 		SET udf_value = thc.columns_value,
			seq_no = thc.udf_order
 		FROM user_defined_deal_fields_template uddft
 		INNER JOIN user_defined_deal_fields uddf
 			ON uddft.udf_template_id = uddf.udf_template_id
 			AND uddf.source_deal_header_id = @source_deal_header_id
 		INNER JOIN user_defined_fields_template udft ON udft.field_id = uddft.field_id
 		INNER JOIN #temp_header_columns thc ON ABS(REPLACE(thc.columns_name, 'UDF___', '')) = CAST(udft.udf_template_id AS NVARCHAR(20))
 		WHERE uddft.template_id = @template_id AND thc.columns_name LIKE '%UDF___%'
 			
 		-- insert udf if not present
 		INSERT INTO user_defined_deal_fields (source_deal_header_id, udf_template_id, udf_value, seq_no)
 		SELECT @source_deal_header_id, uddft.udf_template_id, thc.columns_value, thc.udf_order
 		FROM user_defined_deal_fields_template uddft
 		INNER JOIN user_defined_fields_template udft ON udft.field_id = uddft.field_id
 		INNER JOIN #temp_header_columns thc ON ABS(REPLACE(thc.columns_name, 'UDF___', '')) = CAST(udft.udf_template_id AS NVARCHAR(20))
 		LEFT JOIN user_defined_deal_fields uddf
 			ON uddft.udf_template_id = uddf.udf_template_id
 			AND uddf.source_deal_header_id = @source_deal_header_id
 		WHERE uddft.template_id = @template_id AND uddf.udf_deal_id IS NULL AND thc.columns_name LIKE '%UDF___%'
	
		DELETE uddf
 		FROM user_defined_deal_fields uddf
		INNER JOIN user_defined_fields_template udft ON udft.udf_template_id = ABS(uddf.udf_template_id)
		LEFT JOIN #temp_header_columns thc ON REPLACE(thc.columns_name, 'UDF___', '') = CAST(uddf.udf_template_id AS NVARCHAR(20))
		WHERE uddf.source_deal_header_id = @source_deal_header_id
		AND uddf.udf_template_id < 0 
		AND ISNULL(udft.deal_udf_type, 'x') <> 'c'
		AND thc.id IS NULL
		
		--PRINT @certificate_process_id
		--PRINT @environmental_process_id
	
		DECLARE @tablename_env NVARCHAR(200)
		SET @tablename_env = dbo.FNAProcessTableName('environmental', @user_name, @environment_process_id)
		DECLARE @tablename_env_check NVARCHAR(200)
	
		IF OBJECT_ID('tempdb..#temp_env') IS NOT NULL
 			DROP TABLE #temp_env
 		CREATE TABLE #temp_env 
			(id int, insert_del NCHAR)
	
		Declare @tablename_certi NVARCHAR(200)
		Set @tablename_certi = dbo.FNAProcessTableName('certificate', @user_name, @certificate_process_id)
		Declare @tablename_certi_check NVARCHAR(200)
		DECLARE @retval_env int 
		DECLARE @retval_certi int 

		IF OBJECT_ID('tempdb..#temp_certi') IS NOT NULL
 			DROP TABLE #temp_certi
 		Create table #temp_certi
			(id int, insert_del NCHAR)

		IF OBJECT_ID(@tablename_env) IS NOT NULL
		BEGIN		  
			DECLARE @sSQL_env nvarchar(500);
			DECLARE @ParmDefinition_env nvarchar(500);
			SELECT @sSQL_env = N'SELECT @retvalOUT = 1 FROM ' + @tablename_env + ' where insert_del = ''i''';  
			SET @ParmDefinition_env = N'@retvalOUT int OUTPUT';
			EXEC sp_executesql @sSQL_env, @ParmDefinition_env, @retvalOUT=@retval_env OUTPUT;

			EXEC(' Insert into #temp_env select source_product_number,insert_del from ' + @tablename_env)
		END

		IF OBJECT_ID(@tablename_certi) IS NOT NULL
		BEGIN
		  
			DECLARE @sSQL_certi nvarchar(500);
			DECLARE @ParmDefinition_certi nvarchar(500);
			SELECT @sSQL_certi = N'SELECT @retvalOUT = 1 FROM ' + @tablename_certi + ' where insert_del = ''i''';  
			SET @ParmDefinition_certi = N'@retvalOUT int OUTPUT';
			EXEC sp_executesql @sSQL_certi, @ParmDefinition_certi, @retvalOUT=@retval_certi OUTPUT;

			EXEC(' Insert into #temp_certi select source_certificate_number,insert_del from ' + @tablename_certi)
		END
			
		 --  Update transfer/offset deal header when the deal is not fixation deal.
		IF EXISTS (
			SELECT close_reference_id
			FROM source_deal_header
			WHERE source_deal_header_id = @source_deal_header_id
				AND product_id <> 4100
		)
		BEGIN
			DECLARE @close_refrence_id INT 
			DECLARE @buy_sell_flag_update CHAR
			SET @close_refrence_id = (
				SELECT close_reference_id 
				FROM source_deal_header 
				WHERE source_deal_header_id = @source_deal_header_id
			)
			SET @buy_sell_flag_update = (
				SELECT CASE WHEN header_buy_sell_flag = 'b' THEN 's' WHEN header_buy_sell_flag = 's' THEN 'b' ELSE  NULL END
				FROM source_deal_header
				WHERE source_deal_header_id = @source_deal_header_id
			)

			-- Commented the part that updates the header field of referenced deal.
			--DECLARE @update_string_2 VARCHAR(MAX) = ''
			--SET @sql = ''
			--DECLARE @h_udf_update_string_2 VARCHAR(MAX)
	
			--SELECT @update_string_2 = COALESCE(@update_string_2 + CASE WHEN @update_string_2 = '' THEN '' ELSE ',' END, '') + ISNULL(LTRIM(RTRIM(tsdh.columns_name )),'') + ISNULL(' = ''' + CASE WHEN tsdh.data_type = 'datetime' THEN dbo.FNAGetSQLStandardDate(thc.columns_value) ELSE CAST(thc.columns_value AS VARCHAR(2000)) END + '''', '= NULL')
			--FROM #temp_header_columns thc
			--INNER JOIN #temp_sdh tsdh ON tsdh.columns_name = thc.columns_name 
			--WHERE tsdh.columns_name NOT IN ('source_deal_header_id', 'update_ts', 'update_user', 'create_ts', 'create_user', 'template_id')
			--AND thc.columns_name NOT LIKE '%UDF___%'
			--AND thc.columns_name NOT IN ('close_reference_id', 'deal_id', 'header_buy_sell_flag', 'deal_locked')
						
			--SET @sql = 'UPDATE sdh
			--SET ' + @update_string_2 + '
			--FROM source_deal_header sdh 
			--WHERE sdh.source_deal_header_id = ' + CAST(@close_refrence_id AS varchar(20)) + ''
			--EXEC(@sql)

			UPDATE sdh
			SET sdh.header_buy_sell_flag = @buy_sell_flag_update
			FROM source_deal_header sdh
			WHERE source_deal_header_id = @close_refrence_id
		END
			
		IF EXISTS(
			SELECT sdh.is_environmental
			FROM source_deal_header sdh
			WHERE sdh.source_deal_header_id = @source_deal_header_id
				AND sdh.is_environmental = 'y'
		)
		BEGIN
			IF @retval_certi IS NOT NULL 
			OR 
			EXISTS(
				SELECT 1
				FROM Gis_Certificate gic
				INNER JOIN source_deal_detail sdd on sdd.source_deal_detail_id = gic.source_deal_header_id 
				WHERE sdd.source_deal_header_id = @source_deal_header_id
					AND gic.source_certificate_number NOT IN(
						SELECT id FROM #temp_certi WHERE insert_del = 'd')
			)
			OR
			@retval_env IS NOT NULL
			OR
			EXISTS(
				SELECT 1
				FROM Gis_Product gp
				WHERE source_deal_header_id = @source_deal_header_id
					AND source_product_number NOT IN(
						SELECT id FROM #temp_env WHERE insert_del = 'd')
			)
			OR
			EXISTS(
				SELECT 1
				FROM source_deal_header sdh
				INNER JOIN rec_generator rg ON rg.generator_id = sdh.generator_id
				INNER JOIN eligibility_mapping_template_detail emtd ON emtd.template_id = rg.eligibility_mapping_template_id
				WHERE sdh.generator_id IS NOT NULL
					AND source_deal_header_id = @source_deal_header_id
			)
			OR
			(
				EXISTS(
					SELECT columns_value
					FROM #temp_header_columns
					WHERE columns_value IS NOT NULL
						AND columns_name IN ('tier_value_id')
				)
				AND 
				EXISTS (
					SELECT columns_value
					FROM #temp_header_columns
					WHERE columns_name = ('state_value_id')
						AND columns_value IS NOT NULL
				)
			)
			--	AND 
			--EXISTS(Select columns_value FROM  #temp_header_columns WHERE columns_name in ('state_value_id') and columns_value is not null)										
			BEGIN
				IF OBJECT_ID(@tablename_env) IS NOT NULL
				BEGIN	
					EXEC spa_gis_product_detail  @flag  = 'v', @environment_process_id = @environment_process_id
				END

				IF OBJECT_ID(@tablename_certi) IS NOT NULL
				BEGIN	
					EXEC spa_gis_certificate_detail @flag = 'v', @certificate_process_id = @certificate_process_id
 				END
			END
			ELSE
			BEGIN
				IF @@TRANCOUNT > 0
				ROLLBACK
 
				SET @err_msg = 'Data in Jurisdiction or Tier field is missing. Please check the data and resave.'
				EXEC spa_ErrorHandler -1,
					'spa_deal_update_new',
					'spa_deal_update_new',
					'DB Error',
					@err_msg,
					''
				RETURN
 			END
		END
 	END

	-- Save UDT Grid data using spa_process_form_data
	IF @header_udt_grid IS NOT NULL
	BEGIN
		SET @header_udt_grid = '<Root function_id="10131000" object_id="' + @deal_ref_id + '">' + @header_udt_grid + '</Root>'
		EXEC spa_process_form_data @flag = 's', @xml = @header_udt_grid, @success_message = 0
	END
	
 	IF @header_cost_xml IS NOT NULL
 	BEGIN
 		SET @header_costs_table = dbo.FNAProcessTableName('header_costs_table', @user_name, @process_id)
 		EXEC spa_parse_xml_file 'b', NULL, @header_cost_xml, @header_costs_table
 		
		--EXEC('select * from ' + @header_costs_table)
 		SET @sql = 'UPDATE uddf
 					SET udf_value = hct.udf_value,
 						currency_id = NULLIF(hct.currency_id, ''''),
 						uom_id = NULLIF(hct.uom_id, ''''),
 						counterparty_id = NULLIF(hct.counterparty_id, ''''),
						seq_no = NULLIF(hct.seq_no, ''''),
						contract_id = NULLIF(hct.contract_id, ''''),
						receive_pay = NULLIF(hct.receive_pay, ''''),
						settlement_date 		= NULLIF(hct.settlement_date 	, ''''),
						settlement_calendar		= NULLIF(hct.settlement_calendar, ''''),
						settlement_days			= NULLIF(hct.settlement_days	, ''''),
						payment_date			= NULLIF(hct.payment_date		, ''''),
						payment_calendar		= NULLIF(hct.payment_calendar	, ''''),
						payment_days			= NULLIF(hct.payment_days		, ''''),
						fixed_fx_rate			= NULLIF(hct.fixed_fx_rate		, '''')
 					FROM user_defined_deal_fields uddf
 					INNER JOIN ' + @header_costs_table + ' hct
 						ON hct.cost_id = uddf.udf_template_id
 						AND uddf.source_deal_header_id = ' + CAST(@source_deal_header_id AS NVARCHAR(20)) + '
 					'
 		--PRINT(@sql)
 		EXEC(@sql)

		SET @sql = '
			INSERT INTO user_defined_deal_fields (source_deal_header_id, udf_template_id, udf_value, currency_id, uom_id, counterparty_id, seq_no
													, settlement_date, settlement_calendar, settlement_days, payment_date, payment_calendar, payment_days, fixed_fx_rate)
			SELECT ' + CAST(@source_deal_header_id AS NVARCHAR(20)) + ' , hct.cost_id, NULLIF(hct.udf_value, ''''), NULLIF(hct.currency_id, ''''), NULLIF(hct.uom_id, '''')
					, NULLIF(hct.counterparty_id, ''''), NULLIF(hct.seq_no, ''''),
				NULLIF(hct.settlement_date 	, ''''),
				NULLIF(hct.settlement_calendar, ''''),
				NULLIF(hct.settlement_days	, ''''),
				NULLIF(hct.payment_date		, ''''),
				NULLIF(hct.payment_calendar	, ''''),
				NULLIF(hct.payment_days		, ''''),
				NULLIF(hct.fixed_fx_rate	, '''')
			FROM ' + @header_costs_table + ' hct
			LEFT JOIN user_defined_deal_fields uddf
				ON hct.cost_id = uddf.udf_template_id
 				AND uddf.source_deal_header_id = ' + CAST(@source_deal_header_id AS NVARCHAR(20)) + ' 
			WHERE uddf.udf_deal_id IS NULL AND hct.cost_id < 0  
			'
		EXEC(@sql)

		SET @sql = '
			DELETE uddf
			FROM user_defined_deal_fields uddf
			INNER JOIN user_defined_fields_template udft ON udft.udf_template_id = ABS(uddf.udf_template_id)
			LEFT JOIN ' + @header_costs_table + ' hct  ON hct.cost_id = uddf.udf_template_id
			WHERE uddf.source_deal_header_id = ' + CAST(@source_deal_header_id AS NVARCHAR(20)) + ' 
			AND ISNULL(udft.deal_udf_type, ''x'') = ''c''
			AND uddf.udf_template_id < 0
			AND hct.cost_id IS NULL
			'
		EXEC(@sql)
 	END
 	ELSE
	BEGIN
		UPDATE uddf
 		SET udf_value = NULL,
 			currency_id = NULL,
 			uom_id = NULL,
 			counterparty_id = NULL
 		FROM user_defined_deal_fields uddf
		INNER JOIN user_defined_fields_template udft 
			ON udft.udf_template_id = ABS(uddf.udf_template_id)
				AND ISNULL(udft.deal_udf_type, 'x') = 'c'
 		WHERE uddf.source_deal_header_id = @source_deal_header_id

		SET @sql = '
			DELETE uddf
			FROM user_defined_deal_fields uddf
			INNER JOIN user_defined_fields_template udft ON udft.udf_template_id = ABS(uddf.udf_template_id)
			WHERE uddf.source_deal_header_id = ' + CAST(@source_deal_header_id AS VARCHAR(20)) + ' 
			AND ISNULL(udft.deal_udf_type, ''x'') = ''c''
			AND uddf.udf_template_id < 0
			'
		EXEC(@sql)
	END

	IF @header_prepay_xml IS NOT NULL
	BEGIN
		EXEC spa_source_deal_prepay @flag='i', @source_deal_header_id=@source_deal_header_id, @header_prepay_xml = @header_prepay_xml
	END

 	IF @enable_document_tab = 'y'
 	BEGIN	
 		SET @sql = '
 					DELETE drd
 					FROM deal_required_document drd
 					LEFT JOIN ' + @deal_required_doc_table + ' temp
 						ON temp.document_type = drd.document_type
 					WHERE temp.source_deal_header_id IS NULL AND drd.source_deal_header_id = ' + CAST(@source_deal_header_id AS NVARCHAR(20))
 		EXEC(@sql)
 			
 		SET @sql = '
 					INSERT INTO deal_required_document(source_deal_header_id, document_type)
 					SELECT temp.source_deal_header_id, temp.document_type
 					FROM ' + @deal_required_doc_table + ' temp
 					LEFT JOIN deal_required_document drd 
 						ON drd.source_deal_header_id = temp.source_deal_header_id
 						AND drd.document_type = temp.document_type
 					WHERE drd.deal_required_document_id IS NULL AND temp.deal_required_document_id IS NULL
 			
 		'
 		EXEC(@sql)
 			
 		--once save repopulate process table data
 		exec('delete from ' + @deal_required_doc_table)
 		SET @sql = '
 				INSERT INTO ' + @deal_required_doc_table + '(deal_required_document_id,source_deal_header_id,document_type)
 				SELECT drd.deal_required_document_id,
 						drd.source_deal_header_id,
 					    drd.document_type
 				FROM deal_required_document drd
 				WHERE drd.source_deal_header_id = ' + CAST(@source_deal_header_id AS NVARCHAR(20))		
 		--PRINT(@sql)
 		EXEC(@sql)
 	END
 		
 	IF @enable_remarks = 'y'
 	BEGIN	
 		SET @sql = '
 					DELETE dr
 					FROM deal_remarks dr
 					LEFT JOIN ' + @deal_remarks_table + ' temp
 						ON temp.deal_remarks_id = CAST(dr.deal_remarks_id AS NVARCHAR(20))
 					WHERE temp.deal_remarks_id IS NULL 
 					AND dr.source_deal_header_id = ' + CAST(@source_deal_header_id AS NVARCHAR(20))
 						
 		EXEC(@sql)
 			
 		SET @sql = '
 					INSERT INTO deal_remarks(source_deal_header_id, deal_remarks)
 					SELECT temp.source_deal_header_id, temp.deal_remarks
 					FROM ' + @deal_remarks_table + ' temp
 					LEFT JOIN deal_remarks dr 
 						ON CAST(dr.deal_remarks_id AS NVARCHAR(20)) = temp.deal_remarks_id
 					WHERE dr.deal_remarks_id IS NULL
 			
 		'
 		EXEC(@sql)

		SET @sql = ' 					
 					UPDATE dr
					SET deal_remarks = temp.deal_remarks
 					FROM ' + @deal_remarks_table + ' temp
 					INNER JOIN deal_remarks dr 
 						ON CAST(dr.deal_remarks_id AS NVARCHAR(20)) = temp.deal_remarks_id
 			
 		'
 		EXEC(@sql)
 			
 		--once save repopulate process table data
 		IF @deal_remarks_table IS NOT NULL
			exec('delete from ' + @deal_remarks_table)
 		SET @sql = '
 				INSERT INTO ' + @deal_remarks_table + '(deal_remarks_id,source_deal_header_id,deal_remarks)
 				SELECT dr.deal_remarks_id,
 						dr.source_deal_header_id,
 					    dr.deal_remarks
 				FROM deal_remarks dr
 				WHERE dr.source_deal_header_id = ' + CAST(@source_deal_header_id AS NVARCHAR(20))		
 		--PRINT(@sql)
 		EXEC(@sql)
 	END
 		
 	IF @deleted_details IS NOT NULL
 	BEGIN
 		IF OBJECT_ID('tempdb..#temp_deleted_detail_ids') IS NOT NULL
 			DROP TABLE #temp_deleted_detail_ids
 		CREATE TABLE #temp_deleted_detail_ids(detail_id INT, group_id INT)
 				
 		INSERT INTO #temp_deleted_detail_ids(detail_id, group_id)
 		SELECT sdd.source_deal_detail_id, sdd.source_deal_group_id
 		FROM dbo.SplitCommaSeperatedValues(@deleted_details) scsv
 		INNER JOIN source_deal_detail sdd ON scsv.item = sdd.source_deal_detail_id
 				
 		DELETE sddh
 		FROM source_deal_detail_hour sddh
 		INNER JOIN #temp_deleted_detail_ids temp ON temp.detail_id = sddh.source_deal_detail_id
 				
 		DELETE cfv
 		FROM calc_formula_value  cfv 
 		INNER JOIN #temp_deleted_detail_ids temp ON temp.detail_id = cfv.deal_id	
 				
 		DELETE udddf
 		FROM user_defined_deal_detail_fields udddf
 		INNER JOIN #temp_deleted_detail_ids temp ON temp.detail_id = udddf.source_deal_detail_id
 				
 		DELETE dpbd
 		FROM deal_position_break_down dpbd
 		INNER JOIN #temp_deleted_detail_ids temp ON temp.detail_id = dpbd.source_deal_detail_id
 			
 		DELETE dpce
 		FROM deal_price_custom_event dpce 
 		INNER JOIN #temp_deleted_detail_ids temp ON temp.detail_id = dpce.source_deal_detail_id
 			
 		DELETE dpd
 		FROM deal_price_deemed dpd 
 		INNER JOIN #temp_deleted_detail_ids temp ON temp.detail_id = dpd.source_deal_detail_id
 			
 		DELETE dpse
 		FROM deal_price_std_event dpse
 		INNER JOIN #temp_deleted_detail_ids temp ON temp.detail_id = dpse.source_deal_detail_id
 			
 		DELETE de
 		FROM deal_escalation de
 		INNER JOIN #temp_deleted_detail_ids temp ON temp.detail_id = de.source_deal_detail_id
 				
 		DELETE sdd
 		FROM source_deal_detail  sdd 
 		INNER JOIN #temp_deleted_detail_ids temp ON temp.detail_id = sdd.source_deal_detail_id	
 			
 		DELETE sdg
 		FROM source_deal_groups sdg
 		INNER JOIN #temp_deleted_detail_ids temp ON temp.group_id = sdg.source_deal_groups_id
 		LEFT JOIN source_deal_detail sdd 
 			ON sdd.source_deal_group_id = sdg.source_deal_groups_id
 			AND sdd.source_deal_header_id = sdg.source_deal_header_id
 		WHERE sdd.source_deal_detail_id IS NULL AND sdg.source_deal_header_id = @source_deal_header_id
 	END
 	
 	IF @detail_xml IS NOT NULL
 	BEGIN
 		DECLARE @detail_table_schema XML 
 		DECLARE @detail_table_data XML
 		DECLARE @detail_process_table NVARCHAR(300)
 	
 		SET @detail_process_table = dbo.FNAProcessTableName('detail_process_table', @user_name, @process_id)	
 			
 		EXEC spa_parse_xml_file 'b', NULL, @detail_xml, @detail_process_table
		
		IF EXISTS (
			SELECT 1
			FROM maintain_field_template_detail d
			INNER JOIN maintain_field_deal f
				ON  d.field_id = f.field_id
			INNER JOIN source_deal_header_template sdht
				ON sdht.field_template_id = d.field_template_id
			INNER JOIN source_deal_detail_template sddt
				ON sddt.template_id = sdht.template_id
			WHERE farrms_field_id = 'vintage' 
				AND udf_or_system = 's'
				AND sdht.template_id = @template_id
		)
		BEGIN
			SET @sql = '
				IF COL_LENGTH(''' + @detail_process_table + ''', ''term_start'') IS NULL
				BEGIN
					ALTER TABLE ' + @detail_process_table + ' ADD term_start DATETIME
				END
				
				IF COL_LENGTH(''' + @detail_process_table + ''', ''term_end'') IS NULL
				BEGIN
					ALTER TABLE ' + @detail_process_table + ' ADD term_end DATETIME
				END

				IF COL_LENGTH(''' + @detail_process_table + ''', ''vintage'') IS NULL
				BEGIN
					ALTER TABLE ' + @detail_process_table + ' ADD vintage NVARCHAR(10)
				END
			'
			EXEC (@sql)
			
			SET @sql = '
				UPDATE dxt
				SET dxt.term_start = sdd.term_start
				FROM ' + @detail_process_table + ' dxt
				INNER JOIN static_data_value sdv
					ON sdv.value_id = dxt.vintage
						AND sdv.type_id = 10092	
				INNER JOIN source_deal_detail sdd ON sdd.source_deal_detail_id = dxt.source_deal_detail_id
				WHERE NULLIF(dxt.term_start, '''') IS NULL 
				AND CAST(dxt.source_deal_detail_id AS VARCHAR(300)) NOT LIKE ''%NEW_%''

				UPDATE dxt
				SET dxt.term_end = sdd.term_end
				FROM ' + @detail_process_table + ' dxt
				INNER JOIN static_data_value sdv
					ON sdv.value_id = dxt.vintage
						AND sdv.type_id = 10092	
				INNER JOIN source_deal_detail sdd ON sdd.source_deal_detail_id = dxt.source_deal_detail_id
				WHERE NULLIF(dxt.term_end, '''') IS NULL 
				AND CAST(dxt.source_deal_detail_id AS VARCHAR(300)) NOT LIKE ''%NEW_%''
				
				UPDATE dxt
				SET dxt.term_start = CONVERT(DATE, ISNULL(sdv.code, 1900) + ''-01-01'', 120), 
						dxt.term_end = CONVERT(DATE, ISNULL(sdv.code, 1900) + ''-12-31'', 120)
				FROM ' + @detail_process_table + ' dxt
				INNER JOIN static_data_value sdv
					ON sdv.value_id = dxt.vintage
						AND sdv.type_id = 10092
				LEFT JOIN gis_certificate gc ON gc.source_deal_header_id = dxt.source_deal_detail_id
 				WHERE gc.source_certificate_number IS NULL				
				AND CAST(dxt.source_deal_detail_id AS VARCHAR(300)) NOT LIKE ''%NEW_%''
				' 

			EXEC(@sql)
			
			SET @sql = '
				UPDATE dxt
				SET dxt.vintage = sdv.value_id 
				FROM ' + @detail_process_table + ' dxt
				INNER JOIN static_data_value sdv
					ON sdv.code = YEAR(dxt.term_start)
						AND sdv.type_id = 10092
			'
			EXEC(@sql)
		END

		/*Update term_end value based on term_start according to defined term frequency*/
		IF EXISTS (SELECT 1 from maintain_field_template_detail mftd
                                            INNER JOIN maintain_field_deal mfd ON mftd.field_id = mfd.field_id
                                            WHERE mftd.field_template_id = @field_template_id
                                            AND mfd.farrms_field_id = 'term_end'
                                            AND mfd.header_detail = 'd'
                                            AND mftd.update_required = 'n')
		BEGIN	
			SET @sql = '
				IF COL_LENGTH(''' + @detail_process_table + ''', ''term_end'') IS NULL
				BEGIN
					ALTER TABLE ' + @detail_process_table + ' ADD term_end DATETIME
				END
			'
			EXEC (@sql)

			SET @sql = '
				UPDATE temp
					SET temp.term_end = ' + CASE WHEN @term_frequency = 'm' THEN 'EOMONTH(temp.term_start)' 
											     WHEN @term_frequency = 'a' THEN 'CAST(DATEADD(ms,-3,DATEADD(yy,0,DATEADD(yy,DATEDIFF(yy,0,term_start)+1,0))) AS DATE)' 
											ELSE 'temp.term_start'
											END 
				+ ' FROM ' + @detail_process_table + ' temp
				WHERE temp.term_end IS NULL
			'
			EXEC(@sql)			
		END

		IF @is_gas_daily = 'y'
		BEGIN
			SET @term_end_present = COL_LENGTH(@detail_process_table, 'term_end')

			IF @term_end_present IS NOT NULL
			BEGIN
				SET @sql = '
					UPDATE ' + @detail_process_table + '
					SET term_end = CONVERT(NVARCHAR(10), DATEADD(d, -1, term_end), 120)
				'
				EXEC(@sql)
			END			
		END
 			
 		IF OBJECT_ID('tempdb..#detail_xml_columns') IS NOT NULL
 			DROP TABLE #detail_xml_columns
 			
 		CREATE TABLE #detail_xml_columns (id int IDENTITY(1,1), column_name NVARCHAR(200) COLLATE DATABASE_DEFAULT, data_type NVARCHAR(2000) COLLATE DATABASE_DEFAULT)
 
 		DECLARE @detail_table_name NVARCHAR(200) = REPLACE(@detail_process_table, 'adiha_process.dbo.', '')
 		
 		INSERT INTO #detail_xml_columns(column_name, data_type)
 		SELECT COLUMN_NAME, DATA_TYPE
 		FROM adiha_process.INFORMATION_SCHEMA.COLUMNS
 		WHERE TABLE_NAME = @detail_table_name
 		
 		IF OBJECT_ID('tempdb..#field_template_detail') IS NOT NULL
			DROP TABLE #field_template_detail

		CREATE TABLE #field_template_detail(
			farrms_field_id     NVARCHAR(100) COLLATE DATABASE_DEFAULT,
			field_label			NVARCHAR(200) COLLATE DATABASE_DEFAULT,
			default_value       NVARCHAR(100) COLLATE DATABASE_DEFAULT,
			data_type           NVARCHAR(200) COLLATE DATABASE_DEFAULT,
			is_udf              NCHAR(1) COLLATE DATABASE_DEFAULT,
			insert_required     NCHAR(1) COLLATE DATABASE_DEFAULT,
			update_required     NCHAR(1) COLLATE DATABASE_DEFAULT,
			min_value			NVARCHAR(200) COLLATE DATABASE_DEFAULT,				
			max_value			NVARCHAR(200) COLLATE DATABASE_DEFAULT
		)
			
		INSERT #field_template_detail
		SELECT *
		FROM FNAGetTemplateFieldTable(@template_id, 'd', 'y') j 

		IF OBJECT_ID('tempdb..#temp_min_max_error_handler_detail') IS NOT NULL
			DROP TABLE #temp_min_max_error_handler_detail
		
		CREATE TABLE #temp_min_max_error_handler_detail (
			err_id INT IDENTITY(1,1),
			column_name NVARCHAR(300) COLLATE DATABASE_DEFAULT,
			error_type NVARCHAR(10) COLLATE DATABASE_DEFAULT
		)

		DECLARE min_max_columns_cursor_detail CURSOR  
		FOR
			SELECT ft.farrms_field_id,ft.max_value, ft.min_value
			FROM #field_template_detail ft
			WHERE (ft.min_value IS NOT NULL OR ft.max_value IS NOT NULL)
			AND (ISNULL(ft.min_value,0) <> ISNULL(ft.max_value, 0))
		OPEN min_max_columns_cursor_detail
		FETCH NEXT FROM min_max_columns_cursor_detail INTO @column_name, @max_value, @min_value
		WHILE @@FETCH_STATUS = 0   
		BEGIN
			SET @sql = 'INSERT INTO #temp_min_max_error_handler_detail '
			DECLARE @min_val_check_detail INT = 0
			
			IF @min_value IS NOT NULL
			BEGIN
				SET @sql += '
								SELECT ''' + @column_name + ''', ''go beneath''
								FROM ' + @detail_process_table + '
								WHERE ' + @column_name + ' < ' + @min_value + ''
				SET @min_val_check_detail = 1
			END	
			
			IF @max_value IS NOT NULL
			BEGIN
				SET @sql += CASE WHEN @min_val_check_detail = 1 THEN ' UNION ALL ' ELSE '' END + 
							'
								SELECT ''' + @column_name + ''', ''exceed''
								FROM ' + @detail_process_table + '
								WHERE ' + @column_name + ' > ' + @max_value + ''
			END		
			--PRINT(@sql)
			EXEC(@sql)
		
			FETCH NEXT FROM min_max_columns_cursor_detail INTO @column_name, @max_value, @min_value	
		END
		CLOSE min_max_columns_cursor_detail
		DEALLOCATE min_max_columns_cursor_detail
		
		IF EXISTS (SELECT 1 FROM #temp_min_max_error_handler_detail)
		BEGIN
			SELECT TOP(1)
			@err_msg = 'Value for ' + ft.field_label + ' should not ' + tnne.error_type + ' ' + CASE WHEN tnne.error_type = 'exceed' THEN ft.max_value ELSE ft.min_value END
			FROM #temp_min_max_error_handler_detail tnne
			INNER JOIN #field_template_detail ft ON ft.farrms_field_id = tnne.column_name 
			
			EXEC spa_ErrorHandler -1,
					'spa_insert_blotter_deal',
					'spa_insert_blotter_deal',
					'DB Error',
					@err_msg,
					''

			IF @@TRANCOUNT > 0
				ROLLBACK
			RETURN
		END
		ELSE
		BEGIN
			DROP TABLE #temp_min_max_error_handler_detail
		END
 		
 		/*
 		SELECT @detail_table_schema = CAST(col.query('.') AS NVARCHAR(MAX))
 		FROM @detail_xml.nodes('/rows/head') AS xmlData(col)
 	
 		SELECT @detail_table_data = COALESCE(CAST(@detail_table_data AS NVARCHAR(MAX)) + '', '') + CAST(xmlData.col.query('.') AS NVARCHAR(MAX))
 		FROM @detail_xml.nodes('/rows/row') AS xmlData(col)
 			
 		IF OBJECT_ID('tempdb..#detail_xml_columns') IS NOT NULL
 			DROP TABLE #detail_xml_columns
 			
 		CREATE TABLE #detail_xml_columns (id int IDENTITY(1,1), column_name NVARCHAR(200), data_type NVARCHAR(2000))
 
 		INSERT INTO #detail_xml_columns
 		SELECT x.value('@id', 'sysname') AS column_name,
 				CASE x.value('@type', 'sysname')
 					WHEN 'ed_no' THEN 'NUMERIC(38,20)'
 					WHEN 'ed_p' THEN 'NUMERIC(38,20)'
 					WHEN 'dhxCalendarA' THEN 'DATETIME'
 					ELSE 'NVARCHAR(MAX)'
 				END AS data_type
 		FROM @detail_table_schema.nodes('/head/column') TempXML(x)
 			
 		DECLARE @detail_sql NVARCHAR(MAX) = 'SELECT '
 
 		SELECT @detail_sql = @detail_sql + CASE data_type
 			                                    WHEN 'NUMERIC(38,20)' THEN 
 			                                            'CAST(NULLIF(x.value(''(cell)['  + CAST(id AS NVARCHAR) + ']'', ''NVARCHAR(500)''), '''') AS NUMERIC(38,20))'
 			                                    ELSE 'NULLIF(x.value(''(cell)['  + CAST(id AS NVARCHAR(MAX)) + ']'', ''' + data_type +  '''' + '), '''')'
 			                                END + ' AS [' + column_name + '],'
 		FROM #detail_xml_columns
 
 		SET @detail_sql = LEFT(@detail_sql, LEN(@detail_sql) - 1)
 
 		SELECT @detail_sql = @detail_sql + ' INTO ' + @detail_process_table + ' FROM @detail_table_data.nodes(''/row'') TempXML(x)'
 		*/
 			
 		IF OBJECT_ID('tempdb..#temp_default_fields') IS NOT NULL
 			DROP TABLE #temp_default_fields
 			
 		CREATE TABLE #temp_default_fields (
 			columns_name NVARCHAR(200) COLLATE DATABASE_DEFAULT,
 			columns_value NVARCHAR(200) COLLATE DATABASE_DEFAULT
 		)
 			
 		DECLARE @whr NVARCHAR(2000) = 'leg=1 AND template_id = ' + CAST(@template_id AS NVARCHAR(10))
 		INSERT INTO #temp_default_fields
 		EXEC spa_Transpose 'source_deal_detail_template', @whr
 			
	
 		IF OBJECT_ID('tempdb..#temp_hidden_detail_fields') IS NOT NULL
 			DROP TABLE #temp_hidden_detail_fields
 			
 		CREATE TABLE #temp_hidden_detail_fields (
 			columns_name NVARCHAR(200) COLLATE DATABASE_DEFAULT,
 			columns_value NVARCHAR(200) COLLATE DATABASE_DEFAULT,
 			udf_or_system NCHAR(1) COLLATE DATABASE_DEFAULT,
 			field_type NVARCHAR(10) COLLATE DATABASE_DEFAULT
 		)
 			
 		INSERT INTO #temp_hidden_detail_fields
 		SELECT [column_name], default_value, udf_or_system, field_type
 		FROM (
 			SELECT mfd.farrms_field_id [column_name], COALESCE(tdf.columns_value, mfd.default_value) default_value, 's' [udf_or_system], mfd.field_type
 			FROM maintain_field_deal mfd
 			INNER JOIN maintain_field_template_detail mftd
 				ON  mftd.field_id = mfd.field_id
 				AND mftd.field_template_id = @field_template_id
 				AND ISNULL(mftd.udf_or_system, 's') = 's'
 			INNER JOIN #temp_default_fields tdf ON tdf.columns_name = mfd.farrms_field_id
 			LEFT JOIN #detail_xml_columns dxc ON dxc.column_name = tdf.columns_name
 			WHERE dxc.id IS NULL
 					AND mfd.header_detail = 'd'
 					AND mfd.farrms_field_id NOT IN ('leg', 'contract_expiration_date', 'buy_sell_flag', 'update_ts', 'update_user', 'create_ts', 'create_user', 'term_start', 'term_end')
 					  
 			UNION ALL 
 			
 			SELECT CAST(udft.udf_template_id AS NVARCHAR(200)) [column_name], uddft.default_value, 'u' [udf_or_system], udft.field_type
 			FROM maintain_field_template_detail mftd
 			INNER JOIN user_defined_fields_template udft
 				ON  mftd.field_id = udft.udf_template_id
 				AND mftd.udf_or_system = 'u'
 			LEFT JOIN user_defined_deal_fields_template uddft
 				ON  uddft.field_name = udft.field_name
 			LEFT JOIN #detail_xml_columns dxc ON dxc.column_name = 'UDF___' + CAST(udft.udf_template_id AS NVARCHAR)
 			WHERE  dxc.id IS NULL
 			AND mftd.field_template_id = @field_template_id
 			AND udft.udf_type = 'd'
 			AND ISNULL(mftd.udf_or_system, 's') = 'u'
 			AND uddft.template_id = @template_id
 						
 		) a
 						
 		--IF OBJECT_ID('tempdb..#temp_sdd_columns') IS NOT NULL
 		--	DROP TABLE #temp_sdd_columns
 			
 		--CREATE TABLE #temp_sdd_columns (id int IDENTITY(1,1), column_name NVARCHAR(200), data_type NVARCHAR(2000))
 			
 		--INSERT INTO #temp_sdd_columns(column_name, data_type)
 		--SELECT COLUMN_NAME, DATA_TYPE
 		--FROM INFORMATION_SCHEMA.COLUMNS
 		--WHERE TABLE_NAME = N'source_deal_detail'			
 		--SELECT * FROM #temp_sdd_columns
 		
 		DECLARE @update_list NVARCHAR(MAX),
 				@insert_list NVARCHAR(MAX),
 				@select_list NVARCHAR(MAX)					
 				
 		SELECT @update_list = COALESCE(@update_list + ',', '') + dxc.column_name + IIF(dxc.column_name <> 'contract_expiration_date', ' = NULLIF(LTRIM(RTRIM(temp.' + dxc.column_name + ')), '''')', ' = NULLIF(LTRIM(RTRIM(ISNULL(NULLIF(temp.' + dxc.column_name + ', ''''), temp.term_end))), '''')') + '', --AS ' + ISNULL(NULLIF(tsc.data_type, 'numeric'), 'float') + ' )',
 				@select_list = COALESCE(@select_list + ',', '') + 'NULLIF(LTRIM(RTRIM(temp.' + dxc.column_name + ')), '''') ',
 				@insert_list = COALESCE(@insert_list + ',', '') + dxc.column_name
 		FROM #detail_xml_columns dxc
 		WHERE dxc.column_name NOT IN ('deal_group', 'group_id', 'detail_flag', 'blotterleg', 'source_deal_detail_id', 'leg', 'update_ts', 'update_user', 'create_ts', 'create_user', 'added_from_sdd_id', 'total_volume')
 		AND dxc.column_name NOT LIKE '%UDF___%'			
 		
 		IF OBJECT_ID('tempdb..#temp_output_updated_detail') IS NOT NULL
 			DROP TABLE #temp_output_updated_detail
 			
 		CREATE TABLE #temp_output_updated_detail (source_deal_detail_id INT)
 		/*-- Not needed now
		--Added the logic to update the cycle when updated the values of deal_volume, schedule_volume and actual_volume.
 		DECLARE @update_cycle_condition NVARCHAR(MAX)
 
 		SET @update_cycle_condition = '
 				UPDATE tu
 				SET tu.cycle = 41000 
 				FROM ' + @detail_process_table + ' tu 
 					INNER JOIN source_deal_detail sdd
 						ON sdd.source_deal_detail_id = tu.source_deal_detail_id AND CAST(tu.source_deal_detail_id AS NVARCHAR(300)) NOT LIKE ''%NEW_%''
 						AND sdd.location_id = tu.location_id
 						AND sdd.term_start = tu.term_start
 				WHERE 1 = 1
 					AND ((NULLIF(tu.cycle, '''') IS NULL AND ISNULL(CAST(NULLIF(tu.deal_volume, '''') AS NUMERIC(38, 12)), 1) <> ISNULL(sdd.deal_volume, 1))
 					OR (NULLIF(tu.cycle, '''') IS NULL AND ISNULL(CAST(NULLIF(tu.schedule_volume, '''') AS NUMERIC(38, 12)), 1) <> ISNULL(sdd.schedule_volume, 1))
 					OR (NULLIF(tu.cycle, '''') IS NULL AND ISNULL(CAST(NULLIF(tu.actual_volume, '''') AS NUMERIC(38, 12)), 1) <> ISNULL(sdd.actual_volume, 1)))			
 			'
 
 		IF EXISTS(
 				SELECT  1
 				FROM source_deal_header sdh
 					INNER JOIN source_deal_header_template sdht
 						ON sdh.template_id = sdht.template_id
 					INNER JOIN maintain_field_template_detail mftd
 						ON mftd.field_template_id = sdht.field_template_id	
 					INNER join maintain_field_deal mfd
 						ON mfd.field_id = mftd.field_id		
 					WHERE sdh.source_deal_header_id = @source_deal_header_id
 						AND mfd.farrms_field_id = 'cycle'
 						AND mftd.udf_or_system = 's'
 			) 
 			BEGIN
 				IF COL_LENGTH('' + @detail_process_table + '', 'cycle') IS NOT NULL
 					EXEC(@update_cycle_condition)
 			END
 			------------*/
 			
 						--Updated deal_volume with best available volume	


		SET @sql = ' UPDATE sdg 
  						SET source_deal_groups_name = CASE WHEN CHARINDEX('' :: '', temp.deal_group) = 0 AND CHARINDEX(''x->'', temp.deal_group) = 0 THEN temp.deal_group
 															WHEN CHARINDEX(''x->'', temp.deal_group) <> 0 AND CHARINDEX('' :: '', temp.deal_group) = 0
 																THEN SUBSTRING(temp.deal_group, CHARINDEX(''x->'', temp.deal_group)+3, LEN(temp.deal_group))
 															ELSE SUBSTRING(temp.deal_group,  CHARINDEX('' :: '', temp.deal_group) + 4, LEN(temp.deal_group))
 														END,
  							static_group_name = CASE WHEN CHARINDEX('' :: '', temp.deal_group) = 0 THEN NULL
 													WHEN CHARINDEX(''x->'', temp.deal_group) <> 0 AND CHARINDEX('' :: '', temp.deal_group) <> 0
 														THEN SUBSTRING(SUBSTRING(temp.deal_group, 0, CHARINDEX('' :: '', temp.deal_group)), CHARINDEX(''x->'', temp.deal_group)+3, LEN(temp.deal_group))
 													ELSE SUBSTRING(temp.deal_group,  0, CHARINDEX('' :: '', temp.deal_group))
 												END,
 							quantity = CASE WHEN CHARINDEX(''x->'', temp.deal_group) = 0 THEN NULL
 											ELSE SUBSTRING(temp.deal_group, 0, CHARINDEX(''x->'', temp.deal_group))
 										END		 
 						FROM source_deal_groups sdg
 						INNER JOIN ' + @detail_process_table + ' temp ON sdg.source_deal_groups_id = temp.group_id
 			           WHERE CAST(temp.group_id AS NVARCHAR(300)) NOT LIKE ''%NEW_%''' 
 					
		IF COL_LENGTH('' + @detail_process_table + '', 'source_deal_detail_id') IS NOT NULL
 		BEGIN
			SET @sql = @sql + ' AND CAST(temp.source_deal_detail_id AS NVARCHAR(300)) NOT LIKE ''%NEW_%''' 
 		END
 		--PRINT(@sql)
 		EXEC(@sql)
 				
 		SET @sql = ' UPDATE sdd 
 						SET ' + @update_list + ',
 							source_deal_group_id = sdg.source_deal_groups_id		
 						OUTPUT INSERTED.source_deal_detail_id INTO #temp_output_updated_detail(source_deal_detail_id)				 
 						FROM source_deal_detail sdd
 						INNER JOIN ' + @detail_process_table + ' temp ON sdd.source_deal_detail_id = temp.source_deal_detail_id
 						INNER JOIN source_deal_groups sdg 
 							ON ISNULL(CAST(sdg.quantity AS NVARCHAR(20)) + ''x->'', '''') + ISNULL(sdg.static_group_name + '' :: '', '''') +  sdg.source_deal_groups_name = temp.deal_group
 							AND sdg.source_deal_header_id = sdd.source_Deal_header_id
 			            WHERE CAST(temp.source_deal_detail_id AS NVARCHAR(300)) NOT LIKE ''%NEW_%''
 					'
 		--PRINT(@sql)
		EXEC(@sql)
		
		--Updated deal_volume with best available volume	
		UPDATE sdd 
		SET deal_volume = COALESCE(sdd.actual_volume, sdd.schedule_volume, sdd.contractual_volume),
			volume_left = CASE WHEN volume_left IS NULL THEN 0 ELSE volume_left END
		FROM source_deal_header sdh
		INNER JOIN source_deal_detail sdd ON sdd.source_deal_header_id = sdh.source_deal_header_id
		INNER JOIN #temp_output_updated_detail toud ON toud.source_deal_detail_id = sdd.source_deal_detail_id
		INNER JOIN source_deal_type sdt ON sdt.source_deal_type_id = sdh.source_deal_type_id
		WHERE sdh.is_environmental = 'y'--sdt.deal_type_id IN ('RECs','Allowance','Emission Credits','RIN') 
		--AND sdd.buy_sell_flag = 'b'	
		
		-- update transfer deal
		UPDATE sdd1
		SET	sdd1.deal_volume = sdd.deal_volume,
			sdd1.fixed_price = sdd.fixed_price, 
			sdd1.fixed_cost = sdd.fixed_cost,
			sdd1.curve_id = sdd.curve_id,
			sdd1.fixed_price_currency_id = sdd.fixed_price_currency_id,
			sdd1.option_strike_price = sdd.option_strike_price,
			sdd1.deal_volume_frequency = sdd.deal_volume_frequency,
			sdd1.deal_volume_uom_id= sdd.deal_volume_uom_id,
			sdd1.price_adder = sdd.price_adder,
			sdd1.price_multiplier = sdd.price_multiplier,
			sdd1.multiplier = sdd.multiplier,
			sdd1.formula_curve_id = sdd.formula_curve_id
		OUTPUT INSERTED.source_deal_header_id INTO #temp_updated_transfer_deals(source_deal_header_id)		
		FROM source_deal_detail sdd
		INNER JOIN #temp_output_updated_detail t1 ON t1.source_deal_detail_id = sdd.source_deal_detail_id
		INNER JOIN source_deal_header sdh ON sdh.source_deal_header_id = sdd.source_deal_header_id
		LEFT JOIN source_deal_header sdh1 ON sdh1.close_reference_id = sdh.source_deal_header_id
			 AND sdh1.deal_reference_type_id = 12500
		LEFT JOIN source_deal_detail sdd1 ON sdd1.source_deal_header_id = sdh1.source_deal_header_id
			 AND sdd1.term_start = sdd.term_start
			 AND sdd1.leg = sdd1.leg
		WHERE sdd1.deal_volume <> sdd.deal_volume OR 
			sdd1.fixed_price <> sdd.fixed_price OR  
			sdd1.fixed_cost <> sdd.fixed_cost OR 
			sdd1.curve_id <> sdd.curve_id OR 
			sdd1.fixed_price_currency_id <> sdd.fixed_price_currency_id OR 
			sdd1.option_strike_price <> sdd.option_strike_price OR 
			sdd1.deal_volume_frequency <> sdd.deal_volume_frequency OR 
			sdd1.deal_volume_uom_id<> sdd.deal_volume_uom_id OR 
			sdd1.price_adder <> sdd.price_adder OR 
			sdd1.price_multiplier <> sdd.price_multiplier OR 
			sdd1.multiplier <> sdd.multiplier OR
			sdd1.formula_curve_id <> sdd.formula_curve_id
		
		IF NOT EXISTS(SELECT 1 FROM #temp_updated_transfer_deals) 
		BEGIN
			-- update transfer only calse
			UPDATE  sdd1  
			SET		sdd1.deal_volume = sdd.deal_volume,
					sdd1.fixed_price = sdd.fixed_price, 
					sdd1.fixed_cost = sdd.fixed_cost,
					sdd1.curve_id = sdd.curve_id,
					sdd1.fixed_price_currency_id = sdd.fixed_price_currency_id,
					sdd1.option_strike_price = sdd.option_strike_price,
					sdd1.deal_volume_frequency = sdd.deal_volume_frequency,
					sdd1.deal_volume_uom_id= sdd.deal_volume_uom_id,
					sdd1.price_adder = sdd.price_adder,
					sdd1.price_multiplier = sdd.price_multiplier,
					sdd1.multiplier = sdd.multiplier,
					sdd1.formula_curve_id = sdd.formula_curve_id
			OUTPUT INSERTED.source_deal_header_id INTO #temp_updated_transfer_deals(source_deal_header_id)		
			FROM  source_deal_detail sdd
			INNER JOIN #temp_output_updated_detail t1 ON t1.source_deal_detail_id = sdd.source_deal_detail_id
			INNER JOIN source_deal_header sdh ON  sdh.source_deal_header_id = sdd.source_deal_header_id
			LEFT JOIN source_deal_header sdh1
				 ON  sdh1.close_reference_id = sdh.source_deal_header_id
				 AND sdh1.deal_reference_type_id=12503  
			LEFT JOIN source_deal_detail sdd1
				 ON  sdd1.source_deal_header_id = sdh1.source_deal_header_id
				 AND sdd1.term_start = sdd.term_start
				 AND sdd1.leg = sdd1.leg  
			WHERE sdd1.deal_volume <> sdd.deal_volume OR 
					sdd1.fixed_price <> sdd.fixed_price OR  
					sdd1.fixed_cost <> sdd.fixed_cost OR 
					sdd1.curve_id <> sdd.curve_id OR 
					sdd1.fixed_price_currency_id <> sdd.fixed_price_currency_id OR 
					sdd1.option_strike_price <> sdd.option_strike_price OR 
					sdd1.deal_volume_frequency <> sdd.deal_volume_frequency OR 
					sdd1.deal_volume_uom_id<> sdd.deal_volume_uom_id OR 
					sdd1.price_adder <> sdd.price_adder OR 
					sdd1.price_multiplier <> sdd.price_multiplier OR 
					sdd1.multiplier <> sdd.multiplier OR 
					sdd1.formula_curve_id <> sdd.formula_curve_id
		END
		
		-- update offset deal
		UPDATE  sdd1  
		SET		sdd1.deal_volume = sdd.deal_volume,
				sdd1.fixed_price = sdd.fixed_price, 
				sdd1.fixed_cost = sdd.fixed_cost,
				sdd1.curve_id = sdd.curve_id,
				sdd1.fixed_price_currency_id = sdd.fixed_price_currency_id,
				sdd1.option_strike_price = sdd.option_strike_price,
				sdd1.deal_volume_frequency = sdd.deal_volume_frequency,
				sdd1.deal_volume_uom_id= sdd.deal_volume_uom_id,
				sdd1.price_adder = sdd.price_adder,
				sdd1.price_multiplier = sdd.price_multiplier,
				sdd1.multiplier = sdd.multiplier,
				sdd1.formula_curve_id = sdd.formula_curve_id
		OUTPUT INSERTED.source_deal_header_id INTO #temp_updated_transfer_deals(source_deal_header_id)		
		FROM  source_deal_detail sdd
		INNER JOIN source_deal_header sdh ON  sdh.source_deal_header_id = sdd.source_deal_header_id		
		INNER JOIN #temp_updated_transfer_deals t1 ON t1.source_deal_header_id = sdd.source_deal_header_id
		LEFT JOIN source_deal_header sdh1
			 ON  sdh1.close_reference_id = sdh.source_deal_header_id
			 AND sdh1.deal_reference_type_id=12503
		LEFT JOIN source_deal_detail sdd1
			 ON  sdd1.source_deal_header_id = sdh1.source_deal_header_id
			 AND sdd1.term_start = sdd.term_start
			 AND sdd1.leg = sdd1.leg  
		WHERE sdd1.deal_volume <> sdd.deal_volume OR 
				sdd1.fixed_price <> sdd.fixed_price OR  
				sdd1.fixed_cost <> sdd.fixed_cost OR 
				sdd1.curve_id <> sdd.curve_id OR 
				sdd1.fixed_price_currency_id <> sdd.fixed_price_currency_id OR 
				sdd1.option_strike_price <> sdd.option_strike_price OR 
				sdd1.deal_volume_frequency <> sdd.deal_volume_frequency OR 
				sdd1.deal_volume_uom_id<> sdd.deal_volume_uom_id OR 
				sdd1.price_adder <> sdd.price_adder OR 
				sdd1.price_multiplier <> sdd.price_multiplier OR 
				sdd1.multiplier <> sdd.multiplier OR
				sdd1.formula_curve_id <> sdd.formula_curve_id
		
		IF OBJECT_ID('tempdb..#temp_updated_transfer_deals2') IS NOT NULL
			DROP TABLE #temp_updated_transfer_deals2
		CREATE TABLE #temp_updated_transfer_deals2(source_deal_header_id INT)

		Declare @buy_sell_flag_update_detail char
		SET @buy_sell_flag_update_detail = (select header_buy_sell_flag  FROM source_deal_header where source_deal_header_id = (select close_reference_id from source_deal_header where source_deal_header_id = @source_deal_header_id ))
		
		---- vice versa  update offset when updating transfer deal
		UPDATE  sdd1  
		SET     sdd1.deal_volume = sdd.deal_volume,
				sdd1.fixed_price = sdd.fixed_price, 
				sdd1.fixed_cost = sdd.fixed_cost,
				sdd1.curve_id = sdd.curve_id,
				sdd1.fixed_price_currency_id = sdd.fixed_price_currency_id,
				sdd1.option_strike_price = sdd.option_strike_price,
				sdd1.deal_volume_frequency = sdd.deal_volume_frequency,
				sdd1.deal_volume_uom_id= sdd.deal_volume_uom_id,
				sdd1.price_adder = sdd.price_adder,
				sdd1.price_multiplier = sdd.price_multiplier,
				sdd1.multiplier = sdd.multiplier,
				sdd1.formula_curve_id = sdd.formula_curve_id,				
				sdd1.fixed_float_leg = sdd.fixed_float_leg,
				sdd1.location_id = sdd.location_id,
				sdd1.meter_id = sdd.meter_id,
				sdd1.physical_financial_flag = sdd.physical_financial_flag,
				sdd1.adder_currency_id = sdd.adder_currency_id,
				sdd1.fixed_cost_currency_id = sdd.fixed_cost_currency_id,
				sdd1.formula_currency_id = sdd.formula_currency_id,
				sdd1.price_adder2 = sdd.price_adder2,
				sdd1.price_adder_currency2 = sdd.price_adder_currency2,
				sdd1.pay_opposite = sdd.pay_opposite,
				sdd1.capacity = sdd1.capacity,
				sdd1.settlement_currency = sdd.settlement_currency,
				sdd1.standard_yearly_volume = sdd.standard_yearly_volume,
				sdd1.price_uom_id = sdd.price_uom_id,
				sdd1.category = sdd.category,
				sdd1.profile_code = sdd.profile_code,
				sdd1.pv_party = sdd.pv_party,
				sdd1.buy_sell_flag = @buy_sell_flag_update_detail,
				sdd1.formula_id = sdd.formula_id
		OUTPUT INSERTED.source_deal_header_id INTO #temp_updated_transfer_deals2(source_deal_header_id)	
		FROM source_deal_detail sdd
		INNER JOIN #temp_output_updated_detail t1 ON t1.source_deal_detail_id = sdd.source_deal_detail_id
		INNER JOIN source_deal_header sdh ON  sdh.source_deal_header_id = sdd.source_deal_header_id
		LEFT JOIN source_deal_header sdh1
			 ON  sdh1.source_deal_header_id = sdh.close_reference_id
			 AND sdh.deal_reference_type_id = 12503
		LEFT JOIN source_deal_detail sdd1
			 ON  sdd1.source_deal_header_id = sdh1.source_deal_header_id
			 AND sdd1.term_start = sdd.term_start
			 AND sdd1.leg = sdd1.leg  
		WHERE sdd1.deal_volume <> sdd.deal_volume OR 
				sdd1.fixed_price <> sdd.fixed_price OR  
				sdd1.fixed_cost <> sdd.fixed_cost OR 
				sdd1.curve_id <> sdd.curve_id OR 
				sdd1.fixed_price_currency_id <> sdd.fixed_price_currency_id OR 
				sdd1.option_strike_price <> sdd.option_strike_price OR 
				sdd1.deal_volume_frequency <> sdd.deal_volume_frequency OR 
				sdd1.deal_volume_uom_id<> sdd.deal_volume_uom_id OR 
				sdd1.price_adder <> sdd.price_adder OR 
				sdd1.price_multiplier <> sdd.price_multiplier OR 
				sdd1.multiplier <> sdd.multiplier  OR
				sdd1.formula_curve_id <> sdd.formula_curve_id OR 
				sdd1.fixed_float_leg<>  sdd.fixed_float_leg OR 
				sdd1.meter_id<> sdd.meter_id OR 
				sdd1.physical_financial_flag <>  sdd.physical_financial_flag OR 
				sdd1.adder_currency_id <>  sdd.adder_currency_id OR  
				sdd1.fixed_cost_currency_id <>  sdd.fixed_cost_currency_id OR 
				sdd1.formula_currency_id <>  sdd.formula_currency_id OR 
				sdd1.price_adder2 <>  sdd.price_adder2 OR 
				sdd1.price_adder_currency2 <>  sdd.price_adder_currency2 OR 
				sdd1.pay_opposite <> sdd.pay_opposite OR 
				sdd1.capacity <> sdd1.capacity OR 
				sdd1.settlement_currency <>  sdd.settlement_currency OR 
				sdd1.standard_yearly_volume <>  sdd.standard_yearly_volume OR 
				sdd1.price_uom_id <>  sdd.price_uom_id OR 
				sdd1.category <>  sdd.category OR 
				sdd1.profile_code <>  sdd.profile_code OR 
				sdd1.pv_party <>  sdd.pv_party OR
				sdd1.buy_sell_flag <> sdd.buy_sell_flag OR
				sdd1.formula_id <> sdd.formula_id

		---- vice versa  update original deal when updating transfer deal
		UPDATE  sdd1  
		SET     sdd1.deal_volume = sdd.deal_volume,
				sdd1.fixed_price = sdd.fixed_price, 
				sdd1.fixed_cost = sdd.fixed_cost,
				sdd1.curve_id = sdd.curve_id,
				sdd1.fixed_price_currency_id = sdd.fixed_price_currency_id,
				sdd1.option_strike_price = sdd.option_strike_price,
				sdd1.deal_volume_frequency = sdd.deal_volume_frequency,
				sdd1.deal_volume_uom_id= sdd.deal_volume_uom_id,
				sdd1.price_adder = sdd.price_adder,
				sdd1.price_multiplier = sdd.price_multiplier,
				sdd1.multiplier = sdd.multiplier ,
				sdd1.formula_curve_id = sdd.formula_curve_id
		OUTPUT INSERTED.source_deal_header_id INTO #temp_updated_transfer_deals2(source_deal_header_id)	
		FROM source_deal_detail sdd 
		INNER JOIN source_deal_header sdh ON  sdh.source_deal_header_id = sdd.source_deal_header_id
		INNER JOIN #temp_updated_transfer_deals2 t1 ON t1.source_deal_header_id = sdd.source_deal_header_id
		LEFT JOIN source_deal_header sdh1
			 ON  sdh1.source_deal_header_id = sdh.close_reference_id
			 AND sdh.deal_reference_type_id = 12500
		LEFT JOIN source_deal_detail sdd1
			 ON  sdd1.source_deal_header_id = sdh1.source_deal_header_id
			 AND sdd1.term_start = sdd.term_start
			 AND sdd1.leg = sdd1.leg  
		WHERE sdd1.deal_volume <> sdd.deal_volume OR 
				sdd1.fixed_price <> sdd.fixed_price OR  
				sdd1.fixed_cost <> sdd.fixed_cost OR 
				sdd1.curve_id <> sdd.curve_id OR 
				sdd1.fixed_price_currency_id <> sdd.fixed_price_currency_id OR 
				sdd1.option_strike_price <> sdd.option_strike_price OR 
				sdd1.deal_volume_frequency <> sdd.deal_volume_frequency OR 
				sdd1.deal_volume_uom_id<> sdd.deal_volume_uom_id OR 
				sdd1.price_adder <> sdd.price_adder OR 
				sdd1.price_multiplier <> sdd.price_multiplier OR 
				sdd1.multiplier <> sdd.multiplier OR
				sdd1.formula_curve_id <> sdd.formula_curve_id

		INSERT INTO #temp_updated_transfer_deals(source_deal_header_id)
		SELECT DISTINCT source_deal_header_id FROM #temp_updated_transfer_deals2

 		DECLARE @hidden_columns NVARCHAR(MAX)
 		DECLARE @hidden_values NVARCHAR(MAX)
 			
 		SELECT @hidden_columns = COALESCE(@hidden_columns + ',', '') + temp.columns_name,
 				@hidden_values = COALESCE(@hidden_values + ',', '') + CASE WHEN temp.columns_value IS NULL THEN 'NULL' ELSE '''' +  CASE WHEN temp.field_type = 'a' THEN dbo.FNAGetSQLStandardDate(temp.columns_value) ELSE CAST(temp.columns_value AS NVARCHAR(2000)) END + '''' END
 		FROM #temp_hidden_detail_fields temp
 		WHERE udf_or_system = 's'
 		
 		DECLARE @default_vol_freqn NVARCHAR(10)
 		IF EXISTS(
			SELECT 1
			FROM deal_default_value
			WHERE [deal_type_id] = @deal_type_id
				  AND [commodity] = @commodity_id
				  AND ( ([pricing_type] IS NULL AND @pricing_type IS NULL) OR [pricing_type] = @pricing_type)		
				  AND (buy_sell_flag IS NULL OR ISNULL(buy_sell_flag, 'x') = ISNULL(@default_header_buy_sell_flag, 'y'))
		)
		BEGIN
			SELECT @default_vol_freqn = CASE ddv.volume_frequency
											WHEN 987  THEN 'x'
											WHEN 989 THEN 'y'
											WHEN 993 THEN 'a'
											WHEN 981 THEN 'd'
											WHEN 982 THEN 'h'
											WHEN 980 THEN 'm'
											ELSE 't'
										END
			FROM deal_default_value ddv WHERE ddv.deal_type_id = @deal_type_id 
			AND ((pricing_type IS NULL AND @pricing_type IS NULL) OR pricing_type = @pricing_type)
			AND commodity = @commodity_id AND ddv.volume_frequency IS NOT NULL			
			AND (buy_sell_flag IS NULL OR ISNULL(buy_sell_flag, 'x') = ISNULL(@default_header_buy_sell_flag, 'y'))
		END
 		
 		IF EXISTS(SELECT 1 FROM #temp_hidden_detail_fields WHERE columns_name = 'deal_volume_frequency') AND @default_vol_freqn IS NOT NULL
 		BEGIN
 			UPDATE temp
			SET columns_value = @default_vol_freqn
			FROM #temp_hidden_detail_fields temp 
			WHERE 1 = 1
 		END
 		
		/** Not needed. It is only needed when the column is hidden. Might need to re-enable.
 		IF EXISTS(SELECT 1 FROM #detail_xml_columns WHERE column_name = 'deal_volume_frequency') AND @default_vol_freqn IS NOT NULL
 		BEGIN
 			SET @sql = '
 						UPDATE temp
						SET deal_volume_frequency = ''' + CASE WHEN CAST(@default_vol_freqn AS NVARCHAR(20)) = 't' THEN ' ISNULL(deal_volume_frequency, ''t'') ' ELSE CAST(@default_vol_freqn AS NVARCHAR(20)) END  + '''
						FROM '+ @detail_process_table + ' temp
					'
			--PRINT(@sql)
			EXEC(@sql)
 		END*/
 		
 		DECLARE @contract_expiration_column NVARCHAR(50)
 		DECLARE @contract_expiration_value NVARCHAR(50)
 		DECLARE @buy_sell_column NVARCHAR(50)
 		DECLARE @buy_sell_value NVARCHAR(50)
 		DECLARE @fixed_float_leg_column NVARCHAR(50)
 		DECLARE @fixed_float_leg_value NVARCHAR(50)
 			
 		IF ISNULL(CHARINDEX('contract_expiration_date', @insert_list), 0) = 0 AND ISNULL(CHARINDEX('contract_expiration_date', @hidden_columns), 0) = 0
 		BEGIN
 			SET @contract_expiration_column = ', contract_expiration_date'
 			SET @contract_expiration_value = ', temp.term_end'
 		END
 			
 		IF ISNULL(CHARINDEX('buy_sell_flag', @insert_list), 0) = 0 AND ISNULL(CHARINDEX('buy_sell_flag', @hidden_columns), 0) = 0
 		BEGIN
 			SET @buy_sell_column = ', buy_sell_flag'
 			SELECT @buy_sell_value = ',''' + header_buy_sell_flag + '''' FROM source_deal_header WHERE source_deal_header_id = @source_deal_header_id
 		END
 			
 		IF ISNULL(CHARINDEX('fixed_float_leg', @insert_list), 0) = 0 AND ISNULL(CHARINDEX('fixed_float_leg', @hidden_columns), 0) = 0
 		BEGIN
 			SET @fixed_float_leg_column = ', fixed_float_leg'
 			SELECT @fixed_float_leg_value = ',''' + MAX(fixed_float_leg) + '''' FROM source_deal_detail WHERE source_deal_header_id = @source_deal_header_id
 		END
 			
 		IF OBJECT_ID('tempdb..#temp_old_new_deal_detail_id') IS NOT NULL
 			DROP TABLE #temp_old_new_deal_detail_id
 				
 		CREATE TABLE #temp_old_new_deal_detail_id (
 			old_source_deal_detail_id  NVARCHAR(500) COLLATE DATABASE_DEFAULT,
 			new_source_deal_detail_id  NVARCHAR(500) COLLATE DATABASE_DEFAULT,
 			term_start DATETIME,
 			term_end   DATETIME,
 			leg INT
 		)
 			
 		IF OBJECT_ID('tempdb..#temp_break_down_data') IS NOT NULL
 			DROP TABLE #temp_break_down_data
 				
 		SELECT * INTO #temp_break_down_data FROM source_deal_detail WHERE 1 = 2			
 		ALTER TABLE #temp_break_down_data ALTER COLUMN source_deal_group_id NVARCHAR(500) COLLATE DATABASE_DEFAULT
		ALTER TABLE #temp_break_down_data ADD added_from_sdd_id NVARCHAR(500) COLLATE DATABASE_DEFAULT
		--ALTER TABLE #temp_break_down_data ALTER COLUMN added_term_or_leg NCHAR(1)
 			
 		SET @sql = 'INSERT INTO #temp_break_down_data (source_deal_header_id, leg, source_deal_group_id, added_from_sdd_id, ' + @insert_list 
 						+ ISNULL(', ' + @hidden_columns, '') 
 						+ ISNULL(@contract_expiration_column, '') 
 						+ ISNULL(@buy_sell_column, '') 
 						+ ISNULL(@fixed_float_leg_column, '')
 					+ ')
 					SELECT ' + CAST(@source_deal_header_id AS NVARCHAR(20)) + ', blotterleg, group_id, added_from_sdd_id, ' + @select_list 
 							+ ISNULL(',' + @hidden_values, '') 
 							+ ISNULL(@contract_expiration_value, '')
 							+ ISNULL(@buy_sell_value, '')
 							+ ISNULL(@fixed_float_leg_value, '') + '
 					FROM ' + @detail_process_table + ' temp
 					WHERE temp.source_deal_detail_id LIKE ''%NEW_%''
 		'
 		--PRINT(@sql)
 		EXEC(@sql)	
 			
 		IF OBJECT_ID('tempdb..#temp_terms_breakdown') IS NOT NULL
 			DROP TABLE #temp_terms_breakdown
 			
 		CREATE TABLE #temp_terms_breakdown (
 			source_deal_groups_id NVARCHAR(500) COLLATE DATABASE_DEFAULT,
 			source_deal_detail_id INT,
 			term_start DATETIME,
 			term_end DATETIME,
 			blotterleg INT
 		)
 			
 		IF EXISTS(SELECT 1 FROM #temp_break_down_data) 
 		BEGIN		
 			IF OBJECT_ID('tempdb..#temp_sdg_update') IS NOT NULL
 				DROP TABLE #temp_sdg_update
 				
 			CREATE TABLE #temp_sdg_update (
 				id INT IDENTITY(1,1),
 				group_id INT,
  				source_deal_header_id INT,
  				group_name NVARCHAR(1000) COLLATE DATABASE_DEFAULT,
				old_group_id NVARCHAR(100)  COLLATE DATABASE_DEFAULT
 			)
 				
 			IF OBJECT_ID('tempdb..#temp_sdg') IS NOT NULL
 				DROP TABLE #temp_sdg
 				
 			CREATE TABLE #temp_sdg (
 				id INT IDENTITY(1,1),
 				old_group_id INT NULL,
 				group_id INT,
 				source_deal_header_id INT
 			)
 				
 			DECLARE @grouping_info NVARCHAR(MAX)
 			DECLARE @grouping_alter_cols NVARCHAR(MAX)
 			DECLARE @grouping_where NVARCHAR(MAX)
 			DECLARE @grouping_info_select NVARCHAR(MAX)
 		
 			SELECT @grouping_info = dgi.grouping_columns
 			FROM deal_grouping_information dgi 
 			WHERE dgi.template_id = @template_id
 			-- tsdg2.row_id = tsdh.row_id
 				
 			--IF @grouping_info IS NULL
 			--	SET @grouping_info = 'term_start,term_end'
 		
 			SELECT @grouping_alter_cols = COALESCE(@grouping_alter_cols + ',', '') + spvc.item + ' NVARCHAR(MAX)  COLLATE DATABASE_DEFAULT',
 					@grouping_where = COALESCE(@grouping_where + ' AND ', '') + 'ISNULL(tsdg.' + spvc.item + ', '''') = ISNULL(tsdd.' + spvc.item + ', '''')',
 					@grouping_info_select = COALESCE(@grouping_info_select + ',', '') + 't1.' + spvc.item
 			FROM dbo.SplitCommaSeperatedValues(@grouping_info) spvc
 	
 			IF @term_frequency <> 'h'
 			BEGIN
				IF @term_frequency = 't'
				BEGIN
					INSERT INTO #temp_terms_breakdown(term_start, term_end, blotterleg, source_deal_detail_id, source_deal_groups_id)
					SELECT [term_start], [term_end], leg, source_deal_detail_id, source_deal_group_id
 					FROM #temp_break_down_data
				END
				ELSE
				BEGIN
 					WITH cte_terms AS (
 						SELECT [term_start], CASE WHEN [term_end] IS NOT NULL THEN CASE WHEN [term_end] < dbo.FNAGetTermEndDate(@term_frequency, [term_start], 0) THEN [term_end] ELSE dbo.FNAGetTermEndDate(@term_frequency, [term_start], 0) END ELSE NULL END [term_end], leg, [term_end] [final_term_start], source_deal_detail_id, source_deal_group_id
 						FROM #temp_break_down_data
 						UNION ALL
 						SELECT dbo.FNAGetTermStartDate(@term_frequency, cte.[term_start], 1), CASE WHEN [final_term_start] < dbo.FNAGetTermEndDate(@term_frequency, dbo.FNAGetTermStartDate(@term_frequency, cte.[term_start], 1), 0) THEN [final_term_start] ELSE dbo.FNAGetTermEndDate(@term_frequency, dbo.FNAGetTermStartDate(@term_frequency, cte.[term_start], 1), 0) END, cte.leg, [final_term_start], source_deal_detail_id, source_deal_group_id
 						FROM cte_terms cte 
 						WHERE dbo.FNAGetTermStartDate(@term_frequency, cte.[term_start], 1) <= [final_term_start]
 					) 
 					INSERT INTO #temp_terms_breakdown(term_start, term_end, blotterleg, source_deal_detail_id, source_deal_groups_id)
 					SELECT term_start, term_end, leg, source_deal_detail_id, source_deal_group_id
 					FROM cte_terms
 					option (maxrecursion 0)
				END
 			END
 				
 			IF @grouping_alter_cols IS NOT NULL
 			BEGIN
 				EXEC('ALTER TABLE #temp_sdg_update ADD ' + @grouping_alter_cols) 
 			END		
 				
  			SET @sql = 'INSERT INTO #temp_sdg_update (group_id, old_group_id, source_deal_header_id, group_name ' + ISNULL(',' + @grouping_info, '') + ')
  						SELECT ROW_NUMBER() OVER(ORDER BY t1.source_deal_header_id ASC),
							    t1.source_deal_group_id,
  								t1.source_deal_header_id,
  								NULLIF(temp.deal_group, ''New Group'')	   
 								' + ISNULL(',' + REPLACE(REPLACE(@grouping_info_select, 't1.term_start', 't2.term_start'), 't1.term_end', 't2.term_end'), '') + '
 						FROM #temp_break_down_data t1
 						INNER JOIN #temp_terms_breakdown t2 ON t1.source_deal_group_id = t2.source_deal_groups_id
  						INNER JOIN ' + @detail_process_table + ' temp ON temp.group_id = t1.source_deal_group_id
  						GROUP BY t1.source_deal_header_id, t1.source_deal_group_id, NULLIF(temp.deal_group, ''New Group'') ' + ISNULL(',' + REPLACE(REPLACE(@grouping_info_select, 't1.term_start', 't2.term_start'), 't1.term_end', 't2.term_end'), '')
 			--PRINT(@sql)	
 			EXEC(@sql)

			IF OBJECT_ID('tempdb..#temp_final_group_breakdown') IS NOT NULL
 				 DROP TABLE #temp_final_group_breakdown
 			
 			SELECT id, source_deal_header_id,
  				    CASE WHEN CHARINDEX(' :: ', group_name) = 0 AND CHARINDEX('x->', group_name) = 0 THEN group_name
 						WHEN CHARINDEX('x->', group_name) <> 0 AND CHARINDEX(' :: ', group_name) = 0
 							THEN SUBSTRING(group_name, CHARINDEX('x->', group_name)+3, LEN(group_name))
 						ELSE SUBSTRING(group_name,  CHARINDEX(' :: ', group_name) + 4, LEN(group_name))
 				   END [source_deal_groups_name],
 			       CASE WHEN CHARINDEX(' :: ', group_name) = 0 THEN NULL
 						WHEN CHARINDEX('x->', group_name) <> 0 AND CHARINDEX(' :: ', group_name) <> 0
 							THEN SUBSTRING(SUBSTRING(group_name, 0, CHARINDEX(' :: ', group_name)), CHARINDEX('x->', group_name)+3, LEN(group_name))
 						ELSE SUBSTRING(group_name,  0, CHARINDEX(' :: ', group_name))
 					END [static_group_name],
 					CASE WHEN CHARINDEX('x->', group_name) = 0 THEN NULL
 						ELSE SUBSTRING(group_name, 0, CHARINDEX('x->', group_name))
 					END [quantity]
 			INTO #temp_final_group_breakdown
 			FROM #temp_sdg_update
 			ORDER BY id ASC
 								
 			INSERT INTO source_deal_groups (
  				source_deal_header_id,
  				source_deal_groups_name, 
  				static_group_name, 
  				quantity
 			)
  			OUTPUT INSERTED.source_deal_groups_id, INSERTED.source_deal_header_id INTO #temp_sdg(group_id, source_deal_header_id)
 			SELECT  tf.source_deal_header_id, tf.source_deal_groups_name, tf.static_group_name, tf.quantity
 			FROM #temp_final_group_breakdown tf
 			LEFT JOIN source_deal_groups sdg 
 				ON ISNULL(sdg.source_deal_groups_name, '') = ISNULL(tf.[source_deal_groups_name], '')
 				AND ISNULL(sdg.static_group_name, '') = ISNULL(tf.static_group_name, '')
 				AND ISNULL(sdg.quantity, -1)  = ISNULL(tf.quantity, -1) 
 				AND sdg.source_deal_header_id = tf.source_deal_header_id
 			WHERE sdg.source_deal_groups_id IS NULL
 			ORDER BY tf.id ASC 
 				
 			IF EXISTS(SELECT 1 FROM #temp_sdg)
			BEGIN
 				UPDATE temp
 				SET old_group_id = t1.group_id
 				FROM #temp_sdg_update t1			
 				LEFT JOIN #temp_sdg temp ON temp.id = t1.id
 				
				SET @sql = '
							UPDATE t1
 							SET source_deal_groups_id = t2.group_id
 							FROM #temp_break_down_data tsdd
 							INNER JOIN #temp_terms_breakdown t1 ON t1.blotterleg = tsdd.leg AND t1.source_deal_detail_id = tsdd.source_deal_detail_id
 							INNER JOIN #temp_sdg_update tsdg 
								ON t1.source_deal_groups_id = tsdg.old_group_id
 								' + ISNULL(' AND ' + REPLACE(REPLACE(@grouping_where, 'tsdd.term_start', 't1.term_start'), 'tsdd.term_end', 't1.term_end'), '') + '
 							INNER JOIN #temp_sdg t2 ON CAST(t2.old_group_id AS NVARCHAR(50)) = tsdg.group_id AND t2.source_deal_header_id = tsdg.source_deal_header_id
 							LEFT JOIN source_deal_groups sdg ON CAST(sdg.source_deal_groups_id AS NVARCHAR(50)) = tsdd.source_deal_group_id AND CAST(sdg.source_deal_header_id AS NVARCHAR(50))= tsdd.source_deal_header_id
 						WHERE sdg.source_deal_groups_id IS NULL
 				'
				--PRINT(@sql)
 				EXEC(@sql)
			END
						
				SET @sql = 'UPDATE t1
 							SET source_deal_groups_id = sdg.source_deal_groups_id
 							FROM #temp_break_down_data tsdd
 							INNER JOIN #temp_terms_breakdown t1 ON t1.blotterleg = tsdd.leg AND t1.source_deal_detail_id = tsdd.source_deal_detail_id
 							INNER JOIN #temp_sdg_update tsdg 
 								ON t1.source_deal_groups_id = tsdg.old_group_id
 								' + ISNULL(' AND ' + REPLACE(REPLACE(@grouping_where, 'tsdd.term_start', 't1.term_start'), 'tsdd.term_end', 't1.term_end'), '') + '
							INNER JOIN #temp_final_group_breakdown tf ON tf.id = tsdg.id AND tf.source_deal_header_id = tsdd.source_deal_header_id
							INNER JOIN source_deal_groups sdg 
 									ON ISNULL(sdg.source_deal_groups_name, '''') = ISNULL(tf.[source_deal_groups_name], '''')
 									AND ISNULL(sdg.static_group_name, '''') = ISNULL(tf.static_group_name, '''')
 									AND ISNULL(sdg.quantity, -1)  = ISNULL(tf.quantity, -1) 
 									AND sdg.source_deal_header_id = tf.source_deal_header_id 									
 						LEFT JOIN #temp_sdg tsdg2 ON tsdg2.group_id = sdg.source_deal_groups_id
			            WHERE tsdg2.id IS NULL
 				'
 			--PRINT(@sql)
 			EXEC(@sql)
 				
 			IF EXISTS(SELECT 1 FROM #temp_terms_breakdown)
 			BEGIN
 				SET @select_list = REPLACE(REPLACE(@select_list, 'temp.term_start', 'tt.term_start'), 'temp.term_end', 'tt.term_end')
 				SET @hidden_values = REPLACE(REPLACE(@hidden_values, 'temp.term_start', 'tt.term_start'), 'temp.term_end', 'tt.term_end')
 						
 				SET @sql = '
 							INSERT INTO source_deal_detail  (source_deal_header_id, leg, source_deal_group_id, ' + @insert_list 
 								+ ISNULL(', ' + @hidden_columns, '') 
 								+ ISNULL(@contract_expiration_column, '') 
 								+ ISNULL(@buy_sell_column, '') 
 								+ ISNULL(@fixed_float_leg_column, '')
 							+ ')
 							OUTPUT INSERTED.source_deal_detail_id, INSERTED.term_start, INSERTED.term_end, INSERTED.leg INTO #temp_old_new_deal_detail_id(new_source_deal_detail_id, term_start, term_end, leg)
 							SELECT ' + CAST(@source_deal_header_id AS NVARCHAR(20)) + ', blotterleg, tt.source_deal_groups_id, ' + @select_list 
 									+ ISNULL(',' + @hidden_values, '') 
 									+ ISNULL(@contract_expiration_value, '')
 									+ ISNULL(@buy_sell_value, '')
 									+ ISNULL(@fixed_float_leg_value, '') + '
 							FROM #temp_terms_breakdown tt
 							INNER JOIN #temp_break_down_data temp ON tt.blotterleg = temp.leg AND tt.source_deal_detail_id = temp.source_deal_detail_id 
 								
 							UPDATE dpt
 							SET source_deal_detail_id = temp.new_source_deal_detail_id
 							FROM #temp_old_new_deal_detail_id temp
 							INNER JOIN #temp_terms_breakdown dpt
 								ON temp.term_start = dpt.term_start
 								AND temp.term_end = dpt.term_end
 								AND temp.leg = dpt.blotterleg
 							'								
 				--PRINT(@sql)
 				EXEC(@sql)
 			END
 		END
 	
 		--Updated deal_volume with best available volume
		UPDATE sdd 
			SET deal_volume = CASE WHEN sdh.is_environmental = 'y' THEN COALESCE(sdd.actual_volume, sdd.schedule_volume, sdd.contractual_volume) --For rec deals
								   WHEN sdh.internal_deal_subtype_value_id = 158 THEN sdd.contractual_volume  --'Physical - Oil and Soft'
			                  ELSE sdd.deal_volume END,
				volume_left = CASE WHEN sdh.is_environmental = 'y' THEN  ISNULL(sdd.volume_left,0)--For rec deals
			                  ELSE sdd.volume_left END
		FROM source_deal_header sdh
		INNER JOIN source_deal_detail sdd 
			ON sdd.source_deal_header_id = sdh.source_deal_header_id
		INNER JOIN #temp_old_new_deal_detail_id tsdd 
			ON tsdd.new_source_deal_detail_id = sdd.source_deal_detail_id

		DECLARE @tbl_deal_detail_new_old_id NVARCHAR(200)
		SET @tbl_deal_detail_new_old_id = dbo.FNAProcessTableName('deal_detail_new_old_id', @user_name, @process_id)
		EXEC('SELECT * INTO ' + @tbl_deal_detail_new_old_id + ' FROM #temp_old_new_deal_detail_id')
	
 		IF EXISTS(		
			SELECT 1
			FROM deal_default_value
			WHERE [deal_type_id] = @deal_type_id
				  AND [commodity] = @commodity_id
				  AND ( ([pricing_type] IS NULL AND @pricing_type IS NULL) OR [pricing_type] = @pricing_type)			
		)
		BEGIN
			SET @sql =  'UPDATE sdd SET pay_opposite = ISNULL(ddv.pay_opposite, sdd.pay_opposite) '
				
			IF NOT EXISTS(SELECT 1 FROM #detail_xml_columns WHERE column_name = 'cycle')
				SET @sql += ' ,cycle = ISNULL(ddv.cycle, sdd.cycle)'
				
			IF NOT EXISTS(SELECT 1 FROM #detail_xml_columns WHERE column_name = 'upstream_counterparty')
				SET @sql += ' ,upstream_counterparty = ISNULL(ddv.upstream_counterparty, sdd.upstream_counterparty)'
				
			IF NOT EXISTS(SELECT 1 FROM #detail_xml_columns WHERE column_name = 'upstream_contract')
				SET @sql += ' ,upstream_contract = ISNULL(ddv.upstream_contract, sdd.upstream_contract)'			
				
			IF NOT EXISTS(SELECT 1 FROM #detail_xml_columns WHERE column_name = 'fx_conversion_rate')
				SET @sql += ' ,fx_conversion_rate = ISNULL(ddv.fx_conversion_rate, sdd.fx_conversion_rate)'

			IF NOT EXISTS(SELECT 1 FROM #detail_xml_columns WHERE column_name = 'settlement_currency')
				SET @sql += ' ,settlement_currency = ISNULL(ddv.settlement_currency, sdd.settlement_currency)'
			
			IF NOT EXISTS(SELECT 1 FROM #detail_xml_columns WHERE column_name = 'settlement_date')
				SET @sql += ' ,settlement_date = ISNULL(ddv.settlement_date, sdd.settlement_date)'

			IF NOT EXISTS(SELECT 1 FROM #detail_xml_columns WHERE column_name = 'physical_financial_flag')
				SET @sql += ' ,physical_financial_flag = ISNULL(ddv.physical_financial_flag, sdd.physical_financial_flag)'

			SET @sql += ' 
					FROM source_deal_detail sdd 
					INNER JOIN #temp_old_new_deal_detail_id temp ON sdd.source_deal_detail_id = temp.new_source_deal_detail_id
					OUTER APPLY (
						SELECT TOP(1) * 
						FROM deal_default_value ddv WHERE ddv.deal_type_id = ' + CAST(@deal_type_id AS NVARCHAR(10)) + ' 
						AND ((pricing_type IS NULL AND ' + ISNULL(CAST(@pricing_type AS NVARCHAR(10)), 'NULL') + ' IS NULL) OR pricing_type = ' + CAST(ISNULL(@pricing_type, 0) AS NVARCHAR(10)) + ')
						AND commodity = ' + CAST(@commodity_id AS NVARCHAR(10)) + ' 
						AND (ddv.buy_sell_flag IS NULL OR ISNULL(ddv.buy_sell_flag, ''x'') = ISNULL(sdd.buy_sell_flag, ''y''))
					) ddv
			'
			EXEC(@sql)
		END
 		
 		SET @sql = '/*
					UPDATE sdd
 					SET deal_volume = COALESCE(sdd.actual_volume, sdd.contractual_volume, sdd.deal_volume),
 						deal_volume_frequency = CASE WHEN sdd.actual_volume IS NOT NULL THEN ''t'' ELSE sdd.deal_volume_frequency END
 					FROM source_deal_detail sdd
 					INNER JOIN (
 						SELECT CAST(new_source_deal_detail_id AS NVARCHAR(20)) AS [source_deal_detail_id] FROM #temp_old_new_deal_detail_id
 						UNION ALL 
 						SELECT source_deal_detail_id FROM ' + @detail_process_table + ' temp WHERE temp.source_deal_detail_id NOT LIKE ''%NEW_%''
 					) t1 
 					ON t1.source_deal_detail_id = CAST(sdd.source_deal_detail_id AS NVARCHAR(20))	
					INNER JOIN source_deal_header sdh 
						ON sdh.source_deal_header_id = sdd.source_deal_header_id
					INNER JOIN source_deal_type sdt ON sdt.source_deal_type_id = sdh.source_deal_type_id
						
 					WHERE COALESCE(sdd.actual_volume, sdd.contractual_volume) IS NOT NULL	
						AND sdt.deal_type_id IN (''RECs'',''Allowance'',''Emission Credits'',''RIN'') 
 					*/
 					UPDATE sdd
 					SET multiplier = sdg.quantity
 					FROM source_deal_detail sdd
 					INNER JOIN (
 						SELECT CAST(new_source_deal_detail_id AS NVARCHAR(20)) AS [source_deal_detail_id] FROM #temp_old_new_deal_detail_id
 						UNION ALL 
 						SELECT source_deal_detail_id FROM ' + @detail_process_table + ' WHERE source_deal_detail_id NOT LIKE ''%NEW_%''
 					) t1 
 					ON t1.source_deal_detail_id = CAST(sdd.source_deal_detail_id AS NVARCHAR(20)) 					
 					INNER JOIN source_deal_groups sdg ON sdg.source_deal_groups_id = sdd.source_deal_group_id
 					WHERE NULLIF(sdg.quantity, 0) IS NOT NULL
 					'
 		EXEC(@sql)
 		/* Removed because not needed in other version except kenkko and oil, for those version we need to discuss*/
 		/*
 		IF COL_LENGTH('' + @detail_process_table + '', 'source_deal_detail_id') IS NOT NULL
 		BEGIN
 			EXEC(@sql)
 		END
 		*/
 		
		--Updated deal_volume by contractual volume
		EXEC('
			UPDATE sdd 
			SET deal_volume = sdd.contractual_volume
			FROM source_deal_header sdh
			INNER JOIN source_deal_detail sdd 
				ON sdd.source_deal_header_id = sdh.source_deal_header_id
			INNER JOIN ' + @detail_process_table + ' tsdd 
				ON tsdd.source_deal_detail_id = CAST(sdd.source_deal_detail_id AS NVARCHAR(100))
			WHERE sdh.internal_deal_subtype_value_id = 158 --Physical - Oil and Soft
		')
		
 		IF @shaped_process_id IS NOT NULL
		BEGIN
			SET @shaped_process_table = dbo.FNAProcessTableName('shaped_volume', @user_name, @shaped_process_id)
				
			IF OBJECT_ID(@shaped_process_table) IS NOT NULL
			BEGIN
				SET @sql = '
					UPDATE temp
					SET source_deal_detail_id = sdd.source_deal_detail_id
					FROM ' + @shaped_process_table + ' temp
					INNER JOIN (
						SELECT sdd.* 
						FROM #temp_old_new_deal_detail_id tsdd
						INNER JOIN source_deal_detail sdd ON tsdd.new_source_deal_detail_id = sdd.source_deal_detail_id
					) sdd
					ON sdd.leg = temp.leg
					AND temp.term_date BETWEEN sdd.term_start AND sdd.term_end	
				'	
				--PRINT(@sql)							
				EXEC(@sql)	
						
				DECLARE @max_term DATETIME
				DECLARE @min_term DATETIME
				
				SELECT @max_term = MAX(sdd.term_end), @min_term = MIN(sdd.term_start)
				FROM #temp_old_new_deal_detail_id tsdd
				INNER JOIN source_deal_detail sdd ON tsdd.new_source_deal_detail_id = sdd.source_deal_detail_id
				
				EXEC spa_update_shaped_volume  @flag='v',@source_deal_header_id=@source_deal_header_id, @process_id=@shaped_process_id, @response = 'n', @term_start = @min_term, @term_end= @max_term
			END
		END
		
 		IF OBJECT_ID('tempdb..#udf_transpose_table') IS NOT NULL
 			DROP TABLE #udf_transpose_table

 		IF OBJECT_ID('tempdb..#udf_table') IS NOT NULL
 			DROP TABLE #udf_table

 		CREATE TABLE #udf_table(sno INT IDENTITY(1,1))
 		CREATE TABLE #udf_transpose_table(
 			source_deal_detail_id     NVARCHAR(500) COLLATE DATABASE_DEFAULT,
 			udf_template_id           NVARCHAR(50) COLLATE DATABASE_DEFAULT,
 			udf_value                 NVARCHAR(150) COLLATE DATABASE_DEFAULT
 		)

 		DECLARE @udf_field            NVARCHAR(MAX),
 				@udf_xml_field        NVARCHAR(MAX), -- remove
 				@udf_add_field        NVARCHAR(MAX),
 				@udf_add_field_label  NVARCHAR(MAX),
 				@udf_update           NVARCHAR(MAX),
 				@udf_from_ut_table    NVARCHAR(MAX)

 		SELECT @udf_field = COALESCE(@udf_field + ',', '') + 'UDF___' + CAST(udft.udf_user_field_id AS NVARCHAR),
 				@udf_add_field = COALESCE(@udf_add_field + ',', '') + 'UDF___' + CAST(udft.udf_user_field_id AS NVARCHAR) + ' NVARCHAR(150) COLLATE DATABASE_DEFAULT',
 				@udf_xml_field = COALESCE(@udf_xml_field + ',', '') + 'UDF___' + CAST(udft.udf_user_field_id AS NVARCHAR) + ' NVARCHAR(150) ''@udf___' + CAST(udft.udf_user_field_id AS NVARCHAR) + '''',
 				@udf_add_field_label = COALESCE(@udf_add_field_label + ',', '') + 'ISNULL([UDF___' + CAST(udft.udf_user_field_id AS NVARCHAR) + '], '''') AS [UDF___' + CAST(udft.udf_user_field_id AS NVARCHAR) + ']',
 				@udf_from_ut_table = COALESCE(@udf_from_ut_table + ',', '') + 'UDF___' + CAST(udft.udf_user_field_id AS NVARCHAR),
 				@udf_update = COALESCE(@udf_update + ',', '') + 'sddt.[UDF___' + CAST(udft.udf_user_field_id AS NVARCHAR) + '] = ut.UDF___' + CAST(udft.udf_user_field_id AS NVARCHAR)
 		FROM   maintain_field_template_detail d
 		INNER JOIN user_defined_fields_template udf_temp ON  d.field_id = udf_temp.udf_template_id
 		INNER JOIN user_defined_deal_fields_template udft
 			ON  udft.udf_user_field_id = udf_temp.udf_template_id
 			AND udft.template_id = @template_id
 		INNER JOIN #detail_xml_columns dxc ON REPLACE(dxc.column_name, 'UDF___', '') = CAST(udf_temp.udf_template_id AS NVARCHAR(20))
 		WHERE  udf_or_system = 'u'
 				AND udf_temp.udf_type = 'd'
 				AND field_template_id = @field_template_id
 				--AND udft.leg = 1

 		SET @udf_field = @udf_field + ',temp.source_deal_detail_id'
 		SET @udf_add_field = @udf_add_field + ',source_deal_detail_id NVARCHAR(500)  COLLATE DATABASE_DEFAULT'
 		SET @udf_add_field_label = @udf_add_field_label + ',source_deal_detail_id'
 		SET @udf_from_ut_table = @udf_from_ut_table + ', source_deal_detail_id'

 		IF @udf_add_field IS NOT NULL
 		BEGIN
 			EXEC ('ALTER TABLE #udf_table ADD ' + @udf_add_field)

 			SET @sql = '
 					INSERT #udf_table (
 						' + @udf_field + '
 					)
 					SELECT ' + @udf_field + '
 					FROM #temp_old_new_deal_detail_id tt
 					INNER JOIN #temp_terms_breakdown temp
 						ON temp.blotterleg = tt.leg
 						AND tt.new_source_deal_detail_id = temp.source_deal_detail_id
 					OUTER APPLY (
 						SELECT *
 						FROM ' + @detail_process_table + ' dpt
 						WHERE dpt.source_deal_detail_id LIKE ''%New_%''
 						AND dpt.term_start <= temp.term_start
 						AND dpt.term_end >= temp.term_start
 						AND temp.blotterleg = dpt.blotterleg
 					) dpt

 					UNION

 					SELECT ' + @udf_field + '
 					FROM ' + @detail_process_table + ' temp
 					WHERE source_deal_detail_id NOT LIKE ''%New_%''

 					'
 			--PRINT(@sql)
 			EXEC (@sql)

 			DECLARE @udf_unpivot_clm NVARCHAR(MAX)
 			SET @udf_unpivot_clm = REPLACE(@udf_field, ',temp.source_deal_detail_id', '')
 			SET @sql = ' INSERT #udf_transpose_table (
 								source_deal_detail_id,
 								udf_template_id,
 								udf_value
 							)
 							SELECT
 							source_deal_detail_id,
 							col,
 							colval
 							FROM   (
 								SELECT ' + @udf_from_ut_table + '
 								FROM   #udf_table
 						) p
 						UNPIVOT(ColVal FOR Col IN (' + @udf_unpivot_clm + ')) AS unpvt'
 			--PRINT(@sql)
 			EXEC (@sql)
 		END

 		UPDATE #udf_transpose_table
 		SET udf_template_id = REPLACE(udf_template_id, 'UDF___', '')
		WHERE 1 = 1

 		UPDATE user_defined_deal_detail_fields
 		SET udf_value = CASE
 			                WHEN uddft.Field_type = 'a' THEN dbo.FNAGetSQLStandardDate(u.udf_value)
 			                ELSE u.udf_value
 			            END
 		FROM user_defined_deal_detail_fields udf
 		LEFT JOIN user_defined_deal_fields_template uddft ON  uddft.udf_template_id = udf.udf_template_id
 		INNER JOIN #udf_transpose_table u
 			ON  u.udf_template_id = uddft.udf_user_field_id
 			AND u.source_deal_detail_id = udf.source_deal_detail_id

 		INSERT INTO user_defined_deal_detail_fields (
 			source_deal_detail_id,
 			udf_template_id,
 			udf_value
 		)
 		SELECT utt.source_deal_detail_id,
 				uddft.udf_template_id,
 				NULLIF(utt.udf_value, '')
 		FROM  #udf_transpose_table utt
 		INNER JOIN user_defined_fields_template udft ON  udft.udf_template_id = utt.udf_template_id
 		INNER JOIN user_defined_deal_fields_template uddft ON  udft.field_name = uddft.field_name
 		LEFT JOIN user_defined_deal_detail_fields udddf ON  utt.source_deal_detail_id = CAST(udddf.source_deal_detail_id AS NVARCHAR(200)) AND uddft.udf_template_id = udddf.udf_template_id
 		WHERE  udddf.source_deal_detail_id IS NULL
 		AND uddft.template_id = @template_id

 		--inserts hidden udfs
 		INSERT INTO [dbo].user_defined_deal_detail_fields (
 			source_deal_detail_id,
 			udf_template_id,
 			[udf_value]
 		)
 		SELECT tsdd.new_source_deal_detail_id,
 				uddft.udf_template_id,
 				uddft.default_value
 		FROM #temp_old_new_deal_detail_id tsdd
 		INNER JOIN user_defined_deal_fields_template uddft ON uddft.template_id = @template_id
 		INNER JOIN user_defined_fields_template udft
 			ON  uddft.udf_user_field_id = udft.udf_template_id
 		LEFT JOIN user_defined_deal_detail_fields udddf
 			ON  uddft.udf_template_id = udddf.udf_template_id
 			AND udddf.source_deal_detail_id = tsdd.new_source_deal_detail_id
 		WHERE  udddf.udf_template_id IS NULL
 				AND udft.udf_type = 'd'

 		IF @formula_process_id IS NOT NULL
		BEGIN
			IF OBJECT_ID(@detail_formula_process_table) IS NOT NULL
			BEGIN
				SET @sql = '

					IF OBJECT_ID(''tempdb..#temp_detail_field_id'') IS NOT NULL
 								DROP TABLE #temp_detail_field_id
					SELECT udft3.udf_template_id,sdd.source_deal_detail_id
					INTO #temp_detail_field_id
					FROM user_defined_deal_detail_fields uddf
					INNER JOIN user_defined_deal_fields_template udft
						ON  uddf.udf_template_id = udft.udf_template_id
					INNER JOIN source_deal_detail sdd
						ON  sdd.source_deal_detail_id = uddf.source_deal_detail_id
					INNER JOIN user_defined_fields_template udft2
						ON udft2.field_name = udft.field_name
					INNER JOIN formula_editor fe
						ON CAST(fe.formula_id AS NVARCHAR(20)) = uddf.udf_value AND udft2.Field_type = ''w''
					INNER JOIN formula_breakdown fb
						ON fb.formula_id = fe.formula_id
					INNER JOIN user_defined_fields_template udft3
						ON udft3.field_name = fb.arg1
					WHERE sdd.source_deal_header_id = ' + CAST(@source_deal_header_id AS NVARCHAR(20)) + ' AND fb.func_name LIKE ''%UDFValue%''
					GROUP BY udft3.udf_template_id,sdd.source_deal_detail_id

					DELETE ddfu
					FROM deal_detail_formula_udf ddfu
					INNER JOIN ' + @detail_formula_process_table + ' temp
						ON temp.source_deal_detail_id = ddfu.source_deal_detail_id
					LEFT JOIN #temp_detail_field_id tdfi
						ON tdfi.udf_template_id = ddfu.udf_template_id
						AND tdfi.source_deal_detail_id = ddfu.source_deal_detail_id
					WHERE tdfi.udf_template_id IS NULL

					--DELETE temp
					--FROM ' + @detail_formula_process_table + ' temp
					--LEFT JOIN #temp_detail_field_id tdfi
					--	ON tdfi.udf_template_id = temp.udf_template_id
					--	AND tdfi.source_deal_detail_id = temp.source_deal_detail_id
					--WHERE tdfi.udf_template_id IS NULL

					UPDATE ddfu
					SET udf_value = t1.udf_value
					FROM deal_detail_formula_udf ddfu
					INNER JOIN #temp_output_updated_detail t2 ON ddfu.source_deal_detail_id = CAST(t2.source_deal_detail_id AS NVARCHAR(20))
					INNER JOIN ' + @detail_formula_process_table + ' t1
						ON ddfu.source_deal_detail_id = t1.source_deal_detail_id
						AND ddfu.udf_template_id = t1.udf_template_id

					INSERT INTO deal_detail_formula_udf (source_deal_detail_id, udf_template_id, udf_value)
					SELECT t2.source_deal_detail_id, t1.udf_template_id, t1.udf_value
					FROM ' + @detail_formula_process_table + ' t1
					INNER JOIN #temp_output_updated_detail t2 ON t1.source_deal_detail_id = CAST(t2.source_deal_detail_id AS NVARCHAR(20))
					LEFT JOIN deal_detail_formula_udf ddfu
						ON ddfu.source_deal_detail_id = t2.source_deal_detail_id
						AND ddfu.udf_template_id = t1.udf_template_id
					WHERE ddfu.deal_detail_formula_udf_id IS NULL

					INSERT INTO deal_detail_formula_udf (source_deal_detail_id, udf_template_id, udf_value)
					SELECT tt.new_source_deal_detail_id, t1.udf_template_id, t1.udf_value
					FROM ' + @detail_formula_process_table + ' t1
					INNER JOIN ' + @detail_process_table + ' t2
						ON t1.source_deal_group_id = t2.group_id
						AND t1.leg = t2.blotterleg
						AND t1.source_deal_detail_id = t2.source_deal_detail_id
					INNER JOIN #temp_terms_breakdown t3
						ON t3.term_start <= t2.term_start
 						AND t3.term_end >= t2.term_start
 						AND t3.blotterleg = t2.blotterleg
 					INNER JOIN #temp_old_new_deal_detail_id tt
 						ON t3.blotterleg = tt.leg
 						AND tt.new_source_deal_detail_id = t3.source_deal_detail_id
					WHERE t1.source_deal_detail_id LIKE ''%New_%''

				'
				EXEC(@sql)

				SET @sql = '
					DELETE FROM ' + @detail_formula_process_table + '

 		  			INSERT INTO ' + @detail_formula_process_table + ' (row_id, leg, source_deal_group_id, source_deal_detail_id, udf_template_id, udf_value)
 		  			SELECT 1, sdd.leg, sdd.source_deal_group_id, sdd.source_deal_detail_id, ddfu.udf_template_id, ddfu.udf_value
 		  			FROM deal_detail_formula_udf ddfu
 		  			INNER JOIN source_deal_detail sdd ON sdd.source_deal_detail_id = ddfu.source_deal_detail_id
 		  			WHERE sdd.source_deal_header_id = ' + CAST(@source_deal_header_id AS NVARCHAR(20)) + '
 		  		'
 		  		EXEC(@sql)
			END
		END

 		--*/

 		IF EXISTS (	SELECT 1
 					FROM   adiha_default_codes_values
 					WHERE  default_code_id = 56
 							AND var_value = 1)
 		BEGIN
 			UPDATE sdd
 			SET curve_id = COALESCE(gm_index.[index], sml.term_pricing_index, sdd.curve_id)
 			FROM source_deal_detail sdd
 			INNER JOIN (
 				SELECT source_deal_detail_id FROM #temp_output_updated_detail
 				UNION ALL
 				SELECT new_source_deal_detail_id FROM #temp_old_new_deal_detail_id
 			) temp ON sdd.source_deal_detail_id = temp.source_deal_detail_id
 			LEFT JOIN source_minor_location sml
 				ON sdd.location_id = sml.source_minor_location_id
 				AND sdd.fixed_float_leg = 't'
 				AND sdd.physical_financial_flag = 'p'
 			LEFT JOIN source_commodity sc ON sc.source_commodity_id = sdd.detail_commodity_id
 			OUTER APPLY (
 				SELECT gmv.clm3_value [index]
 				FROM generic_mapping_header gmh
 				INNER JOIN generic_mapping_values gmv ON gmv.mapping_table_id = gmh.mapping_table_id
 				WHERE gmh.mapping_name = 'Commodity Market Curve Mapping'
 				AND gmv.clm1_value = CAST(sml.source_minor_location_id AS NVARCHAR(20))
 				AND gmv.clm2_value = CAST(sc.source_commodity_id AS NVARCHAR(20))
 			) gm_index
 		END
 	END

	/* Update detail buy/sell flag in case when header buy/sell flag is changed and column buy/sell is not shown in detail grid. Otherwise update value from XML*/
    IF @change_in_buy_sell = 'y' AND EXISTS (SELECT 1 from maintain_field_template_detail mftd
                                            INNER JOIN maintain_field_deal mfd ON mftd.field_id = mfd.field_id
                                            WHERE mftd.field_template_id = @field_template_id
                                            AND mfd.farrms_field_id = 'buy_sell_flag'
                                            AND mfd.header_detail = 'd'
                                            AND mftd.update_required = 'n')
     BEGIN
         IF EXISTS (SELECT 1 FROM source_deal_detail --Switch flag in case of multiple leg
                    WHERE source_deal_header_id = @source_deal_header_id
                    AND Leg > 1
         )
         BEGIN
            UPDATE sdd
            SET buy_sell_flag = CASE WHEN sdd.buy_sell_flag = 'b' THEN 's' ELSE 'b' END
            FROM source_deal_detail sdd
            WHERE source_deal_header_id = @source_deal_header_id
         END
         ELSE
         BEGIN
            UPDATE sdd -- In case of single leg set buy_sell_flag  same as header_buy_sell_flag when header header_buy_sell_flag changed.
                SET buy_sell_flag = sdh.header_buy_sell_flag
            FROM source_deal_header sdh
            INNER JOIN source_deal_detail sdd
            ON sdd.source_deal_header_id = sdh.source_deal_header_id
            WHERE sdh.source_deal_header_id = @source_deal_header_id
         END
 	END

 	IF @enable_escalation_tab = 'y' AND @pricing_process_id IS NOT NULL
 	BEGIN
 		SET @deal_escalation_process_table = dbo.FNAProcessTableName('deal_escalation_process_table', @user_name, @pricing_process_id)
 		SET @sql = '
 			DELETE de
   			FROM deal_escalation de
			INNER JOIN source_deal_detail sdd ON sdd.source_deal_detail_id = de.source_deal_detail_id
   			LEFT JOIN ' + @deal_escalation_process_table + ' temp ON temp.source_deal_detail_id = de.source_deal_detail_id
			WHERE temp.source_deal_detail_id IS NULL AND sdd.source_deal_header_id = ' + CAST(@source_deal_header_id AS NVARCHAR(20)) + '

   			DELETE de
   			FROM deal_escalation de
   			INNER JOIN (SELECT DISTINCT source_deal_detail_id FROM ' + @deal_escalation_process_table + ') temp
   				ON temp.source_deal_detail_id = de.source_deal_detail_id

   			INSERT INTO deal_escalation (
   				source_deal_detail_id,
   				quality,
   				range_from,
   				range_to,
   				increment,
   				cost_increment,
   				operator,
   				[reference],
   				currency
   			)
   			SELECT
   				source_deal_detail_id,
   				quality,
   				range_from,
   				range_to,
   				increment,
   				cost_increment,
   				operator,
   				[reference],
   				currency
   			FROM ' + @deal_escalation_process_table + '

   			'
   		EXEC(@sql)
 	END

 	/*
 	IF @pricing_process_id IS NOT NULL AND (@enable_pricing = 'y' OR @enable_provisional_tab = 'y')
 	BEGIN
 		SET @deemed_process_table = dbo.FNAProcessTableName('deemed_process_table', @user_name, @pricing_process_id)
 		SET @std_event_process_table = dbo.FNAProcessTableName('std_event_process_table', @user_name, @pricing_process_id)
 		SET @custom_event_process_table = dbo.FNAProcessTableName('custom_event_process_table', @user_name, @pricing_process_id)
 		SET @pricing_type_process_table = dbo.FNAProcessTableName('pricing_type_process_table', @user_name, @pricing_process_id)

 		SET @sql = 'DELETE dpd
   					FROM deal_price_deemed dpd
					INNER JOIN source_deal_detail sdd ON sdd.source_deal_detail_id = dpd.source_deal_detail_id
   					LEFT JOIN ' + @deemed_process_table + ' temp ON temp.source_deal_detail_id = dpd.source_deal_detail_id
					WHERE temp.source_deal_detail_id IS NULL AND sdd.source_deal_header_id = ' + CAST(@source_deal_header_id AS NVARCHAR(20)) + '
					' + CASE WHEN ISNULL(@enable_pricing, 'n') = 'y' AND ISNULL(@enable_provisional_tab, 'n') = 'y' THEN ''
 							 WHEN ISNULL(@enable_pricing, 'n') = 'y' AND ISNULL(@enable_provisional_tab, 'n') = 'n' THEN ' AND dpd.pricing_provisional = ''p'' '
 							 WHEN ISNULL(@enable_pricing, 'n') = 'n' AND ISNULL(@enable_provisional_tab, 'n') = 'y' THEN ' AND dpd.pricing_provisional = ''q'' '
 						ELSE '' END
 					+ '

					DELETE dpd
   					FROM deal_price_deemed dpd
   					INNER JOIN (SELECT DISTINCT source_deal_detail_id FROM ' + @deemed_process_table + ') temp
   						ON temp.source_deal_detail_id = dpd.source_deal_detail_id
					WHERE 1 = 1
					' + CASE WHEN ISNULL(@enable_pricing, 'n') = 'y' AND ISNULL(@enable_provisional_tab, 'n') = 'y' THEN ''
 							 WHEN ISNULL(@enable_pricing, 'n') = 'y' AND ISNULL(@enable_provisional_tab, 'n') = 'n' THEN ' AND dpd.pricing_provisional = ''p'' '
 							 WHEN ISNULL(@enable_pricing, 'n') = 'n' AND ISNULL(@enable_provisional_tab, 'n') = 'y' THEN ' AND dpd.pricing_provisional = ''q'' '
 						ELSE '' END
 					+ '

					DELETE dpse
   					FROM deal_price_std_event dpse
					INNER JOIN source_deal_detail sdd ON sdd.source_deal_detail_id = dpse.source_deal_detail_id
   					LEFT JOIN ' + @std_event_process_table + ' temp ON temp.source_deal_detail_id = dpse.source_deal_detail_id
					WHERE temp.source_deal_detail_id IS NULL AND sdd.source_deal_header_id = ' + CAST(@source_deal_header_id AS NVARCHAR(20)) + '
					' + CASE WHEN ISNULL(@enable_pricing, 'n') = 'y' AND ISNULL(@enable_provisional_tab, 'n') = 'y' THEN ''
 							 WHEN ISNULL(@enable_pricing, 'n') = 'y' AND ISNULL(@enable_provisional_tab, 'n') = 'n' THEN ' AND dpse.pricing_provisional = ''p'' '
 							 WHEN ISNULL(@enable_pricing, 'n') = 'n' AND ISNULL(@enable_provisional_tab, 'n') = 'y' THEN ' AND dpse.pricing_provisional = ''q'' '
 						ELSE '' END
 					+ '


   					DELETE dpse
   					FROM deal_price_std_event dpse
   					INNER JOIN (SELECT DISTINCT source_deal_detail_id FROM ' + @std_event_process_table + ') temp
   						ON temp.source_deal_detail_id = dpse.source_deal_detail_id
   					WHERE 1 = 1
   					' + CASE WHEN ISNULL(@enable_pricing, 'n') = 'y' AND ISNULL(@enable_provisional_tab, 'n') = 'y' THEN ''
 							 WHEN ISNULL(@enable_pricing, 'n') = 'y' AND ISNULL(@enable_provisional_tab, 'n') = 'n' THEN ' AND dpse.pricing_provisional = ''p'' '
 							 WHEN ISNULL(@enable_pricing, 'n') = 'n' AND ISNULL(@enable_provisional_tab, 'n') = 'y' THEN ' AND dpse.pricing_provisional = ''q'' '
 						ELSE '' END
 					+ '

					DELETE dpce
   					FROM deal_price_custom_event dpce
					INNER JOIN source_deal_detail sdd ON sdd.source_deal_detail_id = dpce.source_deal_detail_id
   					LEFT JOIN ' + @custom_event_process_table + ' temp ON temp.source_deal_detail_id = dpce.source_deal_detail_id
					WHERE temp.source_deal_detail_id IS NULL AND sdd.source_deal_header_id = ' + CAST(@source_deal_header_id AS NVARCHAR(20)) + '
					' + CASE WHEN ISNULL(@enable_pricing, 'n') = 'y' AND ISNULL(@enable_provisional_tab, 'n') = 'y' THEN ''
 							 WHEN ISNULL(@enable_pricing, 'n') = 'y' AND ISNULL(@enable_provisional_tab, 'n') = 'n' THEN ' AND dpce.pricing_provisional = ''p'' '
 							 WHEN ISNULL(@enable_pricing, 'n') = 'n' AND ISNULL(@enable_provisional_tab, 'n') = 'y' THEN ' AND dpce.pricing_provisional = ''q'' '
 						ELSE '' END
 					+ '

   					DELETE dpce
   					FROM deal_price_custom_event dpce
   					INNER JOIN (SELECT DISTINCT source_deal_detail_id FROM ' + @custom_event_process_table + ') temp
   						ON temp.source_deal_detail_id = dpce.source_deal_detail_id
   					WHERE 1 = 1
   					' + CASE WHEN ISNULL(@enable_pricing, 'n') = 'y' AND ISNULL(@enable_provisional_tab, 'n') = 'y' THEN ''
 							 WHEN ISNULL(@enable_pricing, 'n') = 'y' AND ISNULL(@enable_provisional_tab, 'n') = 'n' THEN ' AND dpce.pricing_provisional = ''p'' '
 							 WHEN ISNULL(@enable_pricing, 'n') = 'n' AND ISNULL(@enable_provisional_tab, 'n') = 'y' THEN ' AND dpce.pricing_provisional = ''q'' '
 						ELSE '' END
 					+ '

   					UPDATE sdd
   					SET pricing_type = temp.pricing_type,
   						pricing_type2 = temp.pricing_type2
   					FROM source_deal_detail sdd
   					INNER JOIN ' + @pricing_type_process_table + ' temp ON temp.source_deal_detail_id = sdd.source_deal_detail_id

   					INSERT INTO deal_price_deemed (
   						source_deal_detail_id,
   						pricing_index,
   						pricing_start,
   						pricing_end,
   						adder,
   						currency,
   						multiplier,
   						volume,
   						uom,
   						pricing_provisional,
  						pricing_period,
  						fixed_price,
  						formula_id,
  						[priority],
  						adder_currency,
  						pricing_uom,
  						formula_currency,
  						fixed_cost,
  						fixed_cost_currency
   					)
   					SELECT  dpd.source_deal_detail_id,
   							dpd.pricing_index,
   							dpd.pricing_start,
   							dpd.pricing_end,
   							dpd.adder,
   							dpd.currency,
   							dpd.multiplier,
   							dpd.volume,
   							dpd.uom,
   							dpd.pricing_provisional,
  							dpd.pricing_period,
  							dpd.fixed_price,
  							dpd.formula_id,
  							dpd.[priority],
  							dpd.adder_currency,
  							dpd.pricing_uom,
  						    dpd.formula_currency,
  						    dpd.fixed_cost,
  						    dpd.fixed_cost_currency
   					FROM ' + @deemed_process_table + ' dpd
   					WHERE 1 = 1
					' + CASE WHEN ISNULL(@enable_pricing, 'n') = 'y' AND ISNULL(@enable_provisional_tab, 'n') = 'y' THEN ''
 							 WHEN ISNULL(@enable_pricing, 'n') = 'y' AND ISNULL(@enable_provisional_tab, 'n') = 'n' THEN ' AND dpd.pricing_provisional = ''p'' '
 							 WHEN ISNULL(@enable_pricing, 'n') = 'n' AND ISNULL(@enable_provisional_tab, 'n') = 'y' THEN ' AND dpd.pricing_provisional = ''q'' '
 						ELSE '' END
 					+ '

   					INSERT INTO deal_price_std_event (
   						source_deal_detail_id,
   						event_type,
   						event_date,
   						event_pricing_type,
   						pricing_index,
   						adder,
   						currency,
   						multiplier,
   						volume,
   						uom,
   						pricing_provisional
   					)
   					SELECT
   						source_deal_detail_id,
   						event_type,
   						event_date,
   						event_pricing_type,
   						pricing_index,
   						adder,
   						currency,
   						multiplier,
   						volume,
   						uom,
   						pricing_provisional
   					FROM ' + @std_event_process_table + ' dpd
   					WHERE 1 = 1
					' + CASE WHEN ISNULL(@enable_pricing, 'n') = 'y' AND ISNULL(@enable_provisional_tab, 'n') = 'y' THEN ''
 							 WHEN ISNULL(@enable_pricing, 'n') = 'y' AND ISNULL(@enable_provisional_tab, 'n') = 'n' THEN ' AND dpd.pricing_provisional = ''p'' '
 							 WHEN ISNULL(@enable_pricing, 'n') = 'n' AND ISNULL(@enable_provisional_tab, 'n') = 'y' THEN ' AND dpd.pricing_provisional = ''q'' '
 						ELSE '' END
 					+ '

   					INSERT INTO deal_price_custom_event (
   						source_deal_detail_id,
   						event_type,
   						event_date,
   						pricing_index,
   						skip_days,
   						quotes_before,
   						quotes_after,
   						include_event_date,
   						include_holidays,
   						adder,
   						currency,
   						multiplier,
   						volume,
   						uom,
   						pricing_provisional
   					)
   					SELECT
   						source_deal_detail_id,
   						event_type,
   						event_date,
   						pricing_index,
   						skip_days,
   						quotes_before,
   						quotes_after,
   						include_event_date,
   						include_holidays,
   						adder,
   						currency,
   						multiplier,
   						volume,
   						uom,
   						pricing_provisional
   					FROM ' + @custom_event_process_table + ' dpd
   					WHERE 1 = 1
					' + CASE WHEN ISNULL(@enable_pricing, 'n') = 'y' AND ISNULL(@enable_provisional_tab, 'n') = 'y' THEN ''
 							 WHEN ISNULL(@enable_pricing, 'n') = 'y' AND ISNULL(@enable_provisional_tab, 'n') = 'n' THEN ' AND dpd.pricing_provisional = ''p'' '
 							 WHEN ISNULL(@enable_pricing, 'n') = 'n' AND ISNULL(@enable_provisional_tab, 'n') = 'y' THEN ' AND dpd.pricing_provisional = ''q'' '
 						ELSE '' END
 					+ '

   					'
   		--PRINT(@sql)
   		EXEC(@sql)
 	END */

 	IF @enable_detail_cost = 'y'
 	BEGIN
 		SET @detail_cost_table = dbo.FNAProcessTableName('detail_cost_table', @user_name, @udf_process_id)

 		SET @sql = 'UPDATE user_defined_deal_detail_fields
 					SET udf_value = u.udf_value,
 						currency_id = u.currency_id,
 						uom_id = u.uom_id,
 						counterparty_id = u.counterparty_id,
						seq_no = u.seq_no,
						contract_id = u.contract_id,
						receive_pay = u.receive_pay
 					FROM user_defined_deal_detail_fields udf
 					LEFT JOIN user_defined_deal_fields_template uddft ON  uddft.udf_template_id = udf.udf_template_id
 					INNER JOIN ' + @detail_cost_table + ' u
 						ON  u.udf_id = udf.udf_template_id
 						AND u.detail_id = udf.source_deal_detail_id
 					'
 		--PRINT(@sql)
 		EXEC(@sql)

		SET @sql = '
			INSERT INTO user_defined_deal_detail_fields (source_deal_detail_id, udf_template_id, udf_value, currency_id, uom_id, counterparty_id, seq_no)
			SELECT sdd.source_deal_detail_id, u.udf_id, u.udf_value, u.currency_id, u.uom_id, u.counterparty_id, u.seq_no
			FROM ' + @detail_cost_table + ' u
			INNER JOIN source_deal_detail sdd ON sdd.source_deal_detail_id = u.detail_id
			INNER JOIN user_defined_fields_template udft ON udft.udf_template_id = ABS(u.udf_id)
			LEFT JOIN user_defined_deal_detail_fields uddf
 				ON  u.udf_id = uddf.udf_template_id
 				AND u.detail_id = uddf.source_deal_detail_id
			WHERE u.udf_id < 0 AND uddf.udf_template_id IS NULL
			AND sdd.source_deal_header_id = ' + CAST(@source_deal_header_id AS NVARCHAR(20)) + '
		'

		EXEC(@sql)

		SET @sql = '
			DELETE uddf
			FROM user_defined_deal_detail_fields uddf
			INNER JOIN source_deal_detail sdd ON sdd.source_deal_detail_id = uddf.source_deal_detail_id
			INNER JOIN user_defined_fields_template udft ON udft.udf_template_id = ABS(uddf.udf_template_id)
			LEFT JOIN ' + @detail_cost_table + ' dct
				ON dct.udf_id = uddf.udf_template_id
				AND dct.detail_id = uddf.source_deal_detail_id
			WHERE sdd.source_deal_header_id = ' + CAST(@source_deal_header_id AS NVARCHAR(20)) + '
			AND ISNULL(udft.deal_udf_type, ''x'') = ''c''
			AND uddf.udf_template_id < 0
			AND dct.udf_id IS NULL
			'
		EXEC(@sql)
 	END

	SET @detail_udf_table = dbo.FNAProcessTableName('detail_udf_table', @user_name, @udf_process_id)

	IF @enable_udf_tab = 'y'
	BEGIN
		IF OBJECT_ID(@detail_udf_table) IS NOT NULL
		BEGIN
			SET @sql = 'UPDATE user_defined_deal_detail_fields
 						SET udf_value = u.udf_value,
							seq_no = u.seq_no
 						FROM user_defined_deal_detail_fields udf
 						INNER JOIN user_defined_fields_template udft ON udft.udf_template_id = ABS(udf.udf_template_id)
 						INNER JOIN ' + @detail_udf_table + ' u
 							ON  u.udf_id = udf.udf_template_id
 							AND u.detail_id = udf.source_deal_detail_id
						WHERE u.udf_id < 0
						AND ISNULL(udft.deal_udf_type, ''x'') <> ''c''
 						'
 			--PRINT(@sql)
 			EXEC(@sql)

			SET @sql = '
				INSERT INTO user_defined_deal_detail_fields (source_deal_detail_id, udf_template_id, udf_value, seq_no)
				SELECT sdd.source_deal_detail_id, u.udf_id, u.udf_value, u.seq_no
				FROM ' + @detail_udf_table + ' u
				INNER JOIN source_deal_detail sdd ON sdd.source_deal_detail_id = u.detail_id
				INNER JOIN user_defined_fields_template udft ON udft.udf_template_id = ABS(u.udf_id)
				LEFT JOIN user_defined_deal_detail_fields uddf
 					ON  u.udf_id = uddf.udf_template_id
 					AND u.detail_id = uddf.source_deal_detail_id
				WHERE u.udf_id < 0
				AND ISNULL(udft.deal_udf_type, ''x'') <> ''c''
				AND uddf.udf_template_id IS NULL
				AND sdd.source_deal_header_id = ' + CAST(@source_deal_header_id AS NVARCHAR(20)) + '
			'

			EXEC(@sql)

			SET @sql = '
				DELETE uddf
				FROM user_defined_deal_detail_fields uddf
				INNER JOIN source_deal_detail sdd ON sdd.source_deal_detail_id = uddf.source_deal_detail_id
				INNER JOIN user_defined_fields_template udft ON udft.udf_template_id = ABS(uddf.udf_template_id)
				LEFT JOIN ' + @detail_udf_table + ' dct
					ON dct.udf_id = uddf.udf_template_id
					AND dct.detail_id = uddf.source_deal_detail_id
				WHERE sdd.source_deal_header_id = ' + CAST(@source_deal_header_id AS NVARCHAR(20)) + '
				AND ISNULL(udft.deal_udf_type, ''x'') <> ''c''
				AND uddf.udf_template_id < 0
				AND dct.udf_id IS NULL
				'
			EXEC(@sql)
		END
	END

	--Logic to update the profile granularity
	SET @sql = '
		UPDATE sdh
		SET	sdh.profile_granularity = COALESCE(
										NULLIF(h.profile_granularity, '''') ,
										ddv.volume_frequency,
										sdh.profile_granularity,
										sdht.profile_granularity,
										CASE
												WHEN sdd.deal_volume_frequency = ''x'' THEN 987
												WHEN sdd.deal_volume_frequency = ''y'' THEN 989
												WHEN sdd.deal_volume_frequency = ''a'' THEN 993
												WHEN sdd.deal_volume_frequency = ''d'' THEN 981
												WHEN sdd.deal_volume_frequency IN (''h'', ''t'') THEN 982
												WHEN sdd.deal_volume_frequency = ''m'' THEN 980
												ELSE 982
										END
									)
		FROM ' + @header_process_table + ' h
		INNER JOIN source_deal_header sdh
			ON sdh.deal_id = h.deal_id
		INNER JOIN source_deal_detail sdd
			ON sdd.source_deal_header_id = sdh.source_deal_header_id
		INNER JOIN source_deal_header_template sdht
			ON sdht.template_id = sdh.template_id
		OUTER APPLY (
			SELECT *
			FROM deal_default_value ddv
			WHERE ddv.deal_type_id = h.source_deal_type_id
				AND ((pricing_type IS NULL AND sdh.pricing_type IS NULL) OR pricing_type = sdh.pricing_type)
				AND commodity = h.commodity_id
				AND (buy_sell_flag IS NULL OR ISNULL(buy_sell_flag, ''x'') = ISNULL(sdh.header_buy_sell_flag, ''y''))
		) ddv
		WHERE sdh.source_deal_header_id = ' + CAST(@source_deal_header_id AS NVARCHAR(20))

	EXEC(@sql)

	--Logic to update detail_commodity field if it is left blank
	UPDATE sdd
	SET sdd.detail_commodity_id = ISNULL(sdd.detail_commodity_id, sdh.commodity_id)
	FROM source_deal_header sdh
	INNER JOIN source_deal_detail sdd ON sdh.source_deal_header_id = sdd.source_deal_header_id
	WHERE sdh.source_deal_header_id = @source_deal_header_id

	--update the value of updated fix prices for all the future casade deals
	UPDATE sdd_c
	SET sdd_c.fixed_price = sdd.fixed_price
	FROM source_deal_header sdh
	INNER JOIN source_deal_detail sdd ON sdd.source_deal_header_id = sdh.source_deal_header_id
	INNER JOIN source_deal_header sdh_c ON sdh_c.ext_deal_id = CAST(sdh.source_deal_header_id AS VARCHAR(10))
	INNER JOIN source_deal_detail sdd_c ON sdd_c.source_deal_header_id = sdh_c.source_deal_header_id
	INNER JOIN source_deal_type sdt ON sdh.source_deal_type_id = sdt.source_deal_type_id
	WHERE sdt.source_deal_type_name = 'Future'
		AND sdh.source_deal_header_id = @source_deal_header_id

	-- clean up junk data, if exists
	DELETE sdg
	FROM source_deal_groups sdg
	LEFT JOIN source_deal_detail sdd ON sdd.source_deal_group_id = sdg.source_deal_groups_id
	WHERE sdg.source_deal_header_id = @source_deal_header_id AND sdd.source_deal_detail_id IS NULL
	-- clean up junk data, if exists

 	-- update audit info
 	UPDATE sdh
 	SET update_user = dbo.FNADBUser(),
 		update_ts =  GETDATE(),
 		entire_term_start = t.term_start,
 		entire_term_end = t.term_end
 	FROM source_deal_header sdh
 	OUTER APPLY (SELECT MIN(sdd.term_start) term_start, MAX(sdd.term_end) term_end FROM source_deal_detail sdd WHERE sdd.source_deal_header_id = @source_deal_header_id) t
 	WHERE sdh.source_deal_header_id = @source_deal_header_id

	UPDATE sdd
 	SET update_user = dbo.FNADBUser(),
			update_ts =  GETDATE()
 	FROM source_deal_detail sdd
 	WHERE sdd.source_deal_header_id = @source_deal_header_id

	-- Saved Year of 'Term Start' in Vintage year field.
	IF EXISTS(
		SELECT 1
		FROM maintain_field_template_detail d
		INNER JOIN maintain_field_deal f
			ON  d.field_id = f.field_id
		INNER JOIN source_deal_header_template sdht
			ON sdht.field_template_id = d.field_template_id
		INNER JOIN source_deal_detail_template sddt
			ON sddt.template_id = sdht.template_id
		WHERE farrms_field_id = 'vintage'
			AND udf_or_system = 's'
			AND sdht.template_id = @template_id
	)
	BEGIN
		IF EXISTS (SELECT 1 FROM source_deal_header sdh INNER JOIN source_deal_header_template sdht ON sdh.template_id = sdht.template_id WHERE sdh.source_deal_header_id = @source_deal_header_id AND sdht.term_frequency_type = 'a')
		BEGIN
			UPDATE sdd
 			SET sdd.term_start = CONVERT(DATE, (sdv.code + '-01-01'), 120),
				sdd.term_end = CONVERT(DATE, (sdv.code + '-12-31'), 120)
			FROM source_deal_detail sdd
			INNER JOIN static_data_value sdv ON sdv.value_id = sdd.vintage
				AND sdv.type_id = 10092
			INNER JOIN source_deal_header sdh ON sdd.source_deal_header_id = sdh.source_deal_header_id
			LEFT JOIN gis_certificate gc ON gc.source_deal_header_id = sdd.source_deal_detail_id
 			WHERE sdd.source_deal_header_id = @source_deal_header_id
				AND sdd.vintage IS NOT NULL AND gc.source_certificate_number IS NULL
		END

		UPDATE sdd
 		SET sdd.vintage = sdv.value_id
		FROM source_deal_detail sdd
		INNER JOIN static_data_value sdv ON sdv.code = YEAR(sdd.term_start)
			AND sdv.type_id = 10092
 		WHERE sdd.source_deal_header_id = @source_deal_header_id
	END
	
	/* Update timestamp and user of child deals(offset/transfer) when parent deal is updated*/
	UPDATE sdh_o
		SET update_user = sdh.update_user
		   ,update_ts = sdh.update_ts
	FROM source_deal_header sdh
	INNER JOIN source_deal_header sdh_t
		ON sdh_t.close_reference_id = sdh.source_deal_header_id
	INNER JOIN source_deal_header sdh_o
		ON sdh_o.close_reference_id = sdh_t.source_deal_header_id
	WHERE sdh.source_deal_header_id = @source_deal_header_id
	AND sdh.close_reference_id IS NULL

	UPDATE sdh_t
		SET update_user = sdh.update_user
		   ,update_ts = sdh.update_ts
	FROM source_deal_header sdh
	INNER JOIN source_deal_header sdh_t
		ON sdh_t.close_reference_id = sdh.source_deal_header_id
	WHERE sdh.source_deal_header_id = @source_deal_header_id
	AND sdh.close_reference_id IS NULL
	/*End of timestamp and user update*/

 	/** Not needed - enable it if needed in some version */
 	/*
 	IF EXISTS (SELECT 1 from source_deal_header sdh INNER JOIN
 				source_deal_header_template sdht ON sdh.template_id = sdht.template_id
 				WHERE template_name = 'Generation Deal Template' AND sdh.source_deal_header_id = @source_deal_header_id)
 	BEGIN
 		DECLARE @maximum_capacity FLOAT
 		SELECT @maximum_capacity = uddf.udf_value FROM user_defined_deal_fields uddf
 		INNER JOIN user_defined_deal_fields_template uddft ON uddf.udf_template_id = uddft.udf_template_id
 		WHERE uddft.Field_label = 'Maximum capacity' AND uddf.source_deal_header_id = @source_deal_header_id

 		UPDATE sddh
 		SET sddh.volume = CASE WHEN po.[type_name] = 'o' THEN 0 WHEN po.[type_name] = 'd' THEN
 							CASE WHEN po.derate_mw IS NOT NULL THEN @maximum_capacity-po.derate_mw ELSE @maximum_capacity * (100-derate_percent)/100 END
 						ELSE @maximum_capacity END
 		FROM source_deal_header sdh
 		INNER JOIN source_deal_detail sdd ON sdh.source_deal_header_id = sdd.source_deal_header_id
 		INNER JOIN source_deal_detail_hour sddh ON sdd.source_deal_detail_id = sddh.source_deal_detail_id
 		LEFT JOIN power_outage po ON sdd.location_id = po.source_generator_id AND DATEADD(hh, CAST(LEFT(sddh.hr, 2) AS INT)-1,sddh.term_date) BETWEEN po.actual_start AND po.actual_end
 		WHERE sdh.source_deal_header_id = @source_deal_header_id

 		IF OBJECT_ID('tempdb..#temp_sddh') IS NOT NULL
 			DROP TABLE #temp_sddh

 		SELECT sdd.source_deal_detail_id, a.term_start INTO #temp_sddh
 		FROM source_deal_header sdh
 		INNER JOIN source_deal_detail sdd ON sdh.source_deal_header_id = sdd.source_deal_header_id
 		CROSS APPLY (Select * FROM dbo.FNATermBreakdown('h', sdd.term_start,DATEADD(hh,23,sdd.term_end))) a
 		WHERE YEAR(a.term_start) = YEAR(sdd.term_start) AND MONTH(a.term_start) = MONTH(sdd.term_start)
 		AND sdh.source_deal_header_id = @source_deal_header_id

 		INSERT INTO source_deal_detail_hour (source_deal_detail_id, term_date, hr, is_dst, volume, granularity)
 		--SELECT tmp.source_deal_detail_id, CAST(tmp.term_start AS DATE), DATEPART(hh,tmp.term_start)+1, 0, @maximum_capacity, 982 FROM #temp_sddh tmp
 		SELECT tmp.source_deal_detail_id, CAST(tmp.term_start AS DATE), REPLACE(STR(DATEPART(hh,tmp.term_start)+1, 2), ' ', '0') + ':00', 0, @maximum_capacity, 982 FROM #temp_sddh tmp
 		LEFT JOIN source_deal_detail_hour sddh ON tmp.term_start = DATEADD(hh, CAST(LEFT(sddh.hr, 2) AS INT)-1, sddh.term_date)
 		AND tmp.source_deal_detail_id = sddh.source_deal_detail_id
 		WHERE sddh.source_deal_detail_id IS NULL
 	END
 	*/

	COMMIT TRAN

	--AUTO DEAL SCHEDULE BLOCK
	BEGIN
		IF EXISTS( SELECT  uddf.udf_value
               FROM source_deal_header sdh
               INNER JOIN user_defined_deal_fields_template_main uddft
                   ON uddft.template_id = sdh.template_id
               INNER JOIN user_defined_deal_fields uddf
                   ON uddf.source_deal_header_id = sdh.source_deal_header_id 
                   AND uddf.udf_template_id = uddft.udf_template_id
               INNER JOIN user_defined_fields_template udft
                   ON udft.field_id = uddft.field_id
				INNER JOIN source_Deal_type sdt
					ON sdt.source_Deal_type_id = sdh.source_Deal_type_id
               WHERE sdh.source_deal_header_id =  @source_deal_header_id --7385 --
                   AND udft.Field_label = 'Delivery Path'
                   AND NULLIF(uddf.udf_value, '') IS NOT NULL
				     AND sdt.deal_type_id <> 'Transportation'
		)
		BEGIN
			WAITFOR DELAY '00:00:30'

			DECLARE @col INT
			DECLARE @job_name1 NVARCHAR(100)

			SET @sql = ' [dbo].[spa_transfer_adjust] ' + 
							CAST(@source_deal_header_id AS VARCHAR(10)) 

			SET @job_name1 = 'transfer_adjust_' + @process_id


 		
			EXEC spa_run_sp_as_job @job_name1, @sql, 'spa_transfer_adjust', @user_name	

		END
	END
	

	DECLARE @return_value NVARCHAR(100)
	SELECT @return_value = CAST(internal_desk_id AS NVARCHAR(10)) + ',' + CAST(profile_granularity AS NVARCHAR(10))
	FROM source_deal_header
	WHERE source_deal_header_id = @source_deal_header_id

	-- Insert data of deal after modification
	;WITH temp_tbl AS (
		SELECT CAST(source_deal_header_id AS VARCHAR(50)) source_deal_header_id,
			CAST(physical_financial_flag AS VARCHAR(50)) [physical_financial_flag],
			CAST(term_frequency AS VARCHAR(50)) term_frequency,
			CAST(header_buy_sell_flag AS VARCHAR(50)) AS header_buy_sell_flag,
			CAST(block_define_id AS VARCHAR(50)) AS block_define_id,
			CAST(source_deal_type_id AS VARCHAR(50)) AS source_deal_type_id,
			CAST(counterparty_id AS VARCHAR(50)) AS counterparty_id,
			CAST(close_reference_id AS VARCHAR(50)) AS close_reference_id,
			CAST(sub_book AS VARCHAR(50)) AS sub_book,
			CAST(source_system_book_id1 AS VARCHAR(50)) AS source_system_book_id1,
			CAST(source_system_book_id2 AS VARCHAR(50)) AS source_system_book_id2,
			CAST(source_system_book_id3 AS VARCHAR(50)) AS source_system_book_id3,
			CAST(source_system_book_id4 AS VARCHAR(50)) AS source_system_book_id4
		FROM source_deal_header
		WHERE source_deal_header_id = @source_deal_header_id
	)
	SELECT unp.[column], unp.[value]
	INTO #temp_post_sdh
	FROM temp_tbl tsdh
	UNPIVOT (
		[value] FOR [column] IN (
			source_deal_header_id, physical_financial_flag, term_frequency, header_buy_sell_flag,
			block_define_id, source_deal_type_id, counterparty_id, close_reference_id, sub_book,
			source_system_book_id1, source_system_book_id2, source_system_book_id3, source_system_book_id4
		)
	) unp
	ORDER BY unp.[column] ASC

	-- Insert data of deal after modification
	;WITH temp_tbl AS (
		SELECT CAST(source_deal_header_id AS VARCHAR(50)) source_deal_header_id,
			CAST(source_deal_detail_id AS VARCHAR(50)) source_deal_detail_id,
			CAST(dbo.FNAGetSQLStandardDate(term_start) AS VARCHAR(50)) term_start,
			CAST(dbo.FNAGetSQLStandardDate(term_end) AS VARCHAR(50)) AS term_end,
			CAST(curve_id AS VARCHAR(50)) AS curve_id,
			CAST(location_id AS VARCHAR(50)) AS location_id,
			CAST(deal_volume AS VARCHAR(50)) AS deal_volume,
			CAST(deal_volume_uom_id AS VARCHAR(50)) AS deal_volume_uom_id,
			CAST(deal_volume_frequency AS VARCHAR(50)) AS deal_volume_frequency,
			CAST(position_uom AS VARCHAR(50)) AS position_uom,
			CAST(multiplier AS VARCHAR(50)) AS multiplier,
			CAST(volume_multiplier2 AS VARCHAR(50)) AS volume_multiplier2,
			CAST(price_multiplier AS VARCHAR(50)) AS price_multiplier,
			CAST(fixed_float_leg AS VARCHAR(50)) AS fixed_float_leg,
			CAST(buy_sell_flag AS VARCHAR(50)) AS buy_sell_flag,
			CAST(standard_yearly_volume AS VARCHAR(50)) AS standard_yearly_volume,
			CAST(formula_curve_id AS VARCHAR(50)) AS formula_curve_id,
			CAST(formula_id AS VARCHAR(50)) AS formula_id,
			CAST(contractual_volume AS VARCHAR(50)) AS contractual_volume,
			CAST(physical_financial_flag AS VARCHAR(50)) AS physical_financial_flag,
			CAST(price_uom_id AS VARCHAR(50)) AS price_uom_id,
			CAST(profile_id AS VARCHAR(50)) AS profile_id
		FROM source_deal_detail
		WHERE source_deal_header_id = @source_deal_header_id
	)
	SELECT unp.[column], unp.[value]
	INTO #temp_post_sdd
	FROM temp_tbl tsdh
	UNPIVOT (
		[value] FOR [column] IN (
			source_deal_header_id, source_deal_detail_id, term_start, term_end, curve_id,
			location_id, deal_volume, deal_volume_uom_id, deal_volume_frequency, position_uom,
			multiplier, volume_multiplier2, price_multiplier, fixed_float_leg, buy_sell_flag,
			standard_yearly_volume, formula_curve_id, formula_id, contractual_volume,
			physical_financial_flag, price_uom_id, profile_id
		)
	) unp
	ORDER BY unp.[column] ASC
	
	DECLARE @calc_position CHAR(1) = 'n'
	DECLARE @exclude_steps VARCHAR(30) = ''

	-- Check if values of specific columns were changed in deal header
	IF EXISTS (
		SELECT 1
		FROM #temp_post_sdh post
		LEFT JOIN #temp_pre_sdh pre ON post.[column] = pre.[column]
			AND post.[value] = pre.[value]
		WHERE ISNULL(post.[value], -1) <> ISNULL(pre.[value], -1)
	)
	BEGIN
		SET @calc_position = 'y'
	END
	
	-- Check if values of specific columns were changed in deal detail
	IF EXISTS (
		SELECT 1
		FROM #temp_post_sdd post
		LEFT JOIN #temp_pre_sdd pre ON post.[column] = pre.[column]
			AND post.[value] = pre.[value]
		WHERE ISNULL(post.[value], -1) <> ISNULL(pre.[value], -1)
	)
	BEGIN
		SET @calc_position = 'y'
	END

	-- Check if complex pricing process id is not null. If it is not null then something might have been changed.
	IF NULLIF(@deal_price_data_process_id, '') IS NOT NULL
	BEGIN
		SET @calc_position = 'y'
	END

	IF ISNULL(@call_from, '') <> 'delivery_path'
 	BEGIN
		EXEC spa_ErrorHandler 0
 		, 'source_deal_header'
 		, 'spa_deal_update_new'
 		, 'Success'
 		, 'Changes have been saved successfully.'
 		, @return_value
 	END

 	DECLARE @after_update_process_table NVARCHAR(300), @job_name NVARCHAR(200), @job_process_id NVARCHAR(200) = dbo.FNAGETNEWID()
 	SET @after_update_process_table = dbo.FNAProcessTableName('after_insert_process_table', @user_name, @job_process_id)

 	--PRINT @after_update_process_table
 	IF OBJECT_ID(@after_update_process_table) IS NOT NULL
 	BEGIN
 		EXEC('DROP TABLE ' + @after_update_process_table)
 	END

 	EXEC ('
		CREATE TABLE ' + @after_update_process_table + ' (
			source_deal_header_id INT,
			detail_process_table NVARCHAR(200) COLLATE DATABASE_DEFAULT,
			complex_price_process_id NVARCHAR(200) COLLATE DATABASE_DEFAULT,
			provisional_price_detail_process_id NVARCHAR(200) COLLATE DATABASE_DEFAULT,
			is_gas_daily NCHAR(1)  COLLATE DATABASE_DEFAULT
		)
	')

 	SET @sql = 'INSERT INTO ' + @after_update_process_table + ' (source_deal_header_id, detail_process_table, complex_price_process_id, provisional_price_detail_process_id, is_gas_daily)
 				SELECT ' + CAST(@source_deal_header_id AS NVARCHAR(20)) + ',
					   ' + ISNULL('''' + NULLIF(@detail_process_table, '') + '''', 'NULL') + ',
					   ' + ISNULL('''' + NULLIF(@deal_price_data_process_id, '') + '''', 'NULL') + ', ' + '
					   ' + ISNULL('''' + NULLIF(@deal_provisional_price_data_process_id, '') + '''', 'NULL') + ',
					   ' + ISNULL('''' + NULLIF(@is_gas_daily, '') + '''', 'NULL') + ''
 	EXEC(@sql)

	IF EXISTS(SELECT 1 FROM #temp_updated_transfer_deals)
	BEGIN
		SET @sql = 'INSERT INTO ' + @after_update_process_table + '(source_deal_header_id)
 					SELECT DISTINCT source_deal_header_id FROM #temp_updated_transfer_deals'
 		EXEC(@sql)
	END

	IF @calc_position = 'y'
	BEGIN
		SET @exclude_steps = '' -- Exclude None
	END
	ELSE
	BEGIN
		SET @exclude_steps = '3' -- Exclude Position Calculation Logic
	END
	

	--TO DO add call_from add
 	--Post deal save processes done via jobs:
 	SET @sql = 'spa_deal_insert_update_jobs ''u'', ''' + @after_update_process_table + ''', ''' + @exclude_steps+ ''' '
 	EXEC (@sql)

	---***Settlement calculation start through event***
	DECLARE @status INT, @is_environmental NCHAR(1) --for the check constraints to call event

	-- commented as code is giving error
	--SELECT TOP 1 @status = sdd.[status] , @is_environmental = sdh.is_environmental
	--FROM #temp_output_updated_detail tmp
	--INNER JOIN source_deal_detail sdd
	--	ON sdd.source_deal_detail_id = tmp.source_deal_detail_id
	--INNER JOIN source_deal_header sdh
	--	ON sdh.source_deal_header_id = sdd.source_deal_header_id

	IF (@status = 25006 AND @is_environmental = 'y') --deal starus is transferred and is_environmental then calculate settlement
	BEGIN
		DECLARE @process_table_to_settlement NVARCHAR(300)
 		SET @process_table_to_settlement = dbo.FNAProcessTableName('process_table_to_settlement', @user_name, @process_id)

		IF OBJECT_ID(@process_table_to_settlement) IS NOT NULL
			EXEC ('DROP TABLE ' + @process_table_to_settlement)

		EXEC('SELECT sdd.source_deal_header_id
			  INTO ' + @process_table_to_settlement + '
			  FROM #temp_output_updated_detail tmp
			  INNER JOIN source_deal_detail sdd
				ON sdd.source_deal_detail_id = tmp.source_deal_detail_id
		')

		EXEC spa_register_event 20601, 20597, @process_table_to_settlement, 1, @process_id
	END
	--***settlement calculation event end***
END TRY
BEGIN CATCH
 	DECLARE @DESC NVARCHAR(500),
			@err_no INT
 	
	IF @@TRANCOUNT > 0
 		ROLLBACK
	
	SET @DESC = dbo.FNAHandleDBError(10131000)
	SELECT @err_no = -1
		
 	EXEC spa_ErrorHandler @err_no, 'source_deal_header', 'spa_deal_update_new', 'Error', @DESC, ''
END CATCH
END
ELSE IF @flag = 't'
BEGIN
	--EXEC spa_deal_update_new @flag='t', @source_deal_header_id=17389, @from_date = '2015-01-01', @to_date = '2016-01-01'
	--EXEC spa_deal_update_new  @flag='t',@source_deal_header_id='17389',@from_date='2015-07-01',@to_date='2015-07-31'
 	
	IF OBJECT_ID('tempdb..#temp_terms') IS NOT NULL
 		DROP TABLE #temp_terms
 	
	CREATE TABLE #temp_terms (id INT IDENTITY(1,1), term_start DATETIME, term_end DATETIME)
 	
	IF @term_frequency <> 'h'
	BEGIN
		IF @term_frequency = 't'
		BEGIN
			INSERT INTO #temp_terms(term_start, term_end)
			SELECT @from_date, @to_date
		END
		ELSE
		BEGIN

 			WITH cte AS (
 				SELECT @from_date [term_start], dbo.FNAGetTermEndDate(@term_frequency, @from_date, 0) [term_end]
 				UNION ALL
 				SELECT dbo.FNAGetTermStartDate(@term_frequency, [term_start], 1), dbo.FNAGetTermEndDate(@term_frequency, dbo.FNAGetTermStartDate(@term_frequency, [term_start], 1), 0) 
 				FROM cte WHERE dbo.FNAGetTermStartDate(@term_frequency, [term_start], 1) <= @to_date
 			) 
 			INSERT INTO #temp_terms(term_start, term_end)
 			SELECT term_start, term_end FROM cte
 			option (maxrecursion 0)
		END
	END
 	
	SELECT @new_id = dbo.FNAGetNewId()
 	
	SELECT 'New Group - ' + dbo.FNADateFormat(MIN(term_start)) + ' - ' + dbo.FNADateFormat(MAX(term_end)) [group], 'New - ' + @new_id [group_id],  dbo.FNAGetSQLStandardDate(term_start) term_start, dbo.FNAGetSQLStandardDate(term_end) term_end FROM #temp_terms ORDER by term_start
END
ELSE IF @flag = 'l'
BEGIN
	UPDATE sdd
	SET sdd.source_deal_group_id = sdg.source_deal_groups_id
	FROM source_deal_detail sdd
	INNER JOIN source_deal_groups sdg ON sdg.source_deal_header_id = sdd.source_deal_header_id
	WHERE sdd.source_deal_group_id IS NULL AND sdg.source_deal_header_id = @source_deal_header_id

	-- insert group if not exists
	IF NOT EXISTS (SELECT 1 FROM source_deal_groups sdg WHERE sdg.source_deal_header_id = @source_deal_header_id)
	BEGIN
 		IF OBJECT_ID('tempdb..#temp_deal_groups_exists') IS NOT NULL
 			DROP TABLE #temp_deal_groups_exists
 	
 		CREATE TABLE #temp_deal_groups_exists (
 			source_deal_groups_id INT,
 			source_deal_header_id INT,
 			leg	INT,
 			location_id INT,
 			curve_id INT
 		)
 
 		INSERT INTO source_deal_groups ( 
 			source_deal_header_id,
 			term_from,
 			term_to,
 			location_id,
 			curve_id,
 			detail_flag,
 			leg
 		)
 		OUTPUT INSERTED.source_deal_groups_id, INSERTED.source_deal_header_id, INSERTED.leg, INSERTED.location_id, INSERTED.curve_id INTO #temp_deal_groups_exists(source_deal_groups_id, source_deal_header_id, leg, location_id, curve_id)	
 		SELECT sdd.source_deal_header_id, MIN(sdd.term_start), MAX(sdd.term_end), sdd.location_id, CASE WHEN sdd.location_id IS NULL THEN sdd.curve_id ELSE NULL END, 0, sdd.Leg
 		FROM source_deal_detail sdd
 		LEFT JOIN source_deal_groups sdg ON sdd.source_deal_header_id = sdg.source_deal_header_id
 		WHERE sdd.source_deal_header_id = @source_deal_header_id AND sdg.source_deal_groups_id IS NULL 
 		GROUP by sdd.source_deal_header_id, sdd.Leg, sdd.location_id, CASE WHEN sdd.location_id IS NULL THEN sdd.curve_id ELSE NULL END
 		ORDER by sdd.source_deal_header_id
 
 		UPDATE sdd
 		SET source_deal_group_id = temp.source_deal_groups_id
 		FROM source_deal_detail sdd
 		INNER JOIN #temp_deal_groups_exists temp
 			ON  temp.source_deal_header_id = sdd.source_deal_header_id
 			AND sdd.Leg = temp.leg	
 			AND ISNULL(sdd.location_id, -1) = ISNULL(temp.location_id, -1)
 			AND (sdd.location_id IS NOT NULL OR ISNULL(sdd.curve_id, -1) = ISNULL(temp.curve_id, -1))
	END	
 	
	DECLARE @disable_term NCHAR(1) = 'n'
	DECLARE @enable_efp NCHAR(1) = 'n'
	DECLARE @enable_trigger NCHAR(1) = 'n'
	DECLARE @disable_certificate NCHAR(1) = 'n'
	DECLARE @enable_exercise NCHAR(1) = 'n'
	DECLARE @enable_product NCHAR(1) = 'n'
 	
 	
	SELECT @enable_efp = ISNULL(sdht.enable_efp, 'n'),
 			@enable_trigger = ISNULL(sdht.enable_trigger, 'n'),
 			@enable_pricing = ISNULL(sdht.enable_pricing_tabs, 'n'), 			
 		    @enable_provisional_tab = ISNULL(sdht.enable_provisional_tab, 'n'),
 		    @enable_escalation_tab = ISNULL(sdht.enable_escalation_tab, 'n'),
			@disable_certificate = ISNULL(sdht.certificate, 'n'),
			@enable_document_tab = ISNULL(sdht.enable_document_tab, 'n'),
			@enable_remarks = ISNULL(sdht.enable_remarks, 'n'),
		    @enable_exercise = ISNULL(sdht.enable_exercise, 'n'),
			@enable_product =ISNULL(sdht.is_environmental, 'n')
	FROM source_deal_header_template sdht
	WHERE sdht.template_id = @template_id
	
	IF EXISTS(
		SELECT 1
	    FROM   deal_type_pricing_maping
	    WHERE template_id             = @template_id
	    AND   source_deal_type_id     = @deal_type_id
	    AND   ((@pricing_type IS NULL AND pricing_type IS NULL) OR pricing_type = @pricing_type)
		AND commodity_id = @commodity_id
	)
	BEGIN
		SELECT @enable_pricing = CASE WHEN dtpm.pricing_tab = 1 THEN 'y' ELSE 'n' END,
			   @enable_efp =  CASE WHEN dtpm.enable_efp = 1 THEN 'y' ELSE 'n' END,
			   @enable_trigger =  CASE WHEN dtpm.enable_trigger = 1 THEN 'y' ELSE 'n' END,
			   @enable_provisional_tab = CASE WHEN dtpm.enable_provisional_tab = 1 THEN 'y' ELSE 'n' END,
			   @enable_escalation_tab = CASE WHEN dtpm.enable_escalation_tab = 1 THEN 'y' ELSE 'n' END,
			   @enable_exercise  = CASE WHEN dtpm.enable_exercise_tab = 1 THEN 'y' ELSE 'n' END,
			   @disable_certificate  = CASE WHEN dtpm.enable_certificate = 1 THEN 'y' ELSE 'n' END,
			   @enable_prepay_tab = CASE WHEN dtpm.enable_prepay_tab = 1 THEN 'y' ELSE 'n' END
		FROM deal_type_pricing_maping dtpm
		WHERE dtpm.template_id = @template_id
		AND dtpm.source_deal_type_id = @deal_type_id
		AND ((@pricing_type IS NULL AND dtpm.pricing_type IS NULL) OR dtpm.pricing_type = @pricing_type)
		AND dtpm.commodity_id = @commodity_id
	END
	
	SELECT @disable_term = ISNULL(mftd.is_disable, 'n') 
	FROM maintain_field_template_detail mftd 
	INNER JOIN maintain_field_deal mfd ON mftd.field_id = mfd.field_id
	WHERE mftd.field_template_id = @field_template_id
	AND mfd.farrms_field_id = 'term_start'
 	
	IF @enable_pricing = 'y' OR @enable_provisional_tab = 'y' OR @enable_escalation_tab = 'y' OR @enable_document_tab = 'y'
 		SET @pricing_process_id = dbo.FNAGetNewId()
 	
 	IF @enable_escalation_tab = 'y'
 	BEGIN 		
 		SET @deal_escalation_process_table = dbo.FNAProcessTableName('deal_escalation_process_table', @user_name, @pricing_process_id)
 		
 		SET @sql = '
 			SELECT de.deal_escalation_id [id], sdd.source_deal_detail_id, de.quality, de.range_from, de.range_to, de.increment, de.cost_increment, de.operator, de.[reference], de.currency, sdd.source_deal_group_id
 			INTO ' + @deal_escalation_process_table + '
 			FROM deal_escalation de
 			INNER JOIN source_deal_detail sdd ON sdd.source_deal_detail_id = de.source_deal_detail_id
 			WHERE sdd.source_deal_header_id = ' + CAST(@source_deal_header_id AS NVARCHAR(20)) + '
 		' 			
 		EXEC(@sql)
 	END
 	
	IF @enable_pricing = 'y' OR @enable_provisional_tab = 'y'
	BEGIN
 		SET @deemed_process_table = dbo.FNAProcessTableName('deemed_process_table', @user_name, @pricing_process_id)
 		SET @std_event_process_table = dbo.FNAProcessTableName('std_event_process_table', @user_name, @pricing_process_id)
 		SET @custom_event_process_table = dbo.FNAProcessTableName('custom_event_process_table', @user_name, @pricing_process_id)
 		SET @pricing_type_process_table = dbo.FNAProcessTableName('pricing_type_process_table', @user_name, @pricing_process_id)
		SET @deemed_provisional_process_table = dbo.FNAProcessTableName('deemed_provisional_process_table', @user_name, @pricing_process_id)
 		SET @std_event_provisional_process_table = dbo.FNAProcessTableName('std_event_provisional_process_table', @user_name, @pricing_process_id)
 		SET @custom_event_provisional_process_table = dbo.FNAProcessTableName('custom_event_provisional_process_table', @user_name, @pricing_process_id)
 		SET @pricing_type_provisional_process_table = dbo.FNAProcessTableName('pricing_type_provisional_process_table', @user_name, @pricing_process_id)
 		 		
 		
 		INSERT INTO #temp_collect_detail_ids
 		SELECT sdd.source_deal_detail_id, sdd.source_deal_group_id
 		FROM source_deal_header sdh 
 		INNER JOIN source_deal_detail sdd ON sdh.source_deal_header_id = sdd.source_deal_header_id
 		WHERE sdh.source_deal_header_id = @source_deal_header_id
 		
 		SET @sql = 'SELECT sdd.source_deal_detail_id,
  						   dpd.pricing_index,
  						   dpd.pricing_start,
  						   dpd.pricing_end,
  						   dpd.adder,
  						   dpd.currency,
  						   dpd.multiplier,
  						   dpd.volume,
  						   dpd.uom,
  						   dpd.pricing_provisional,
  						   sdd.source_deal_group_id,
  						   dpd.pricing_period,
  						   dpd.fixed_price,
  						   dpd.formula_id,
  						   dpd.[priority],
  						   dpd.adder_currency,
  						   dpd.pricing_uom,
  						   dpd.formula_currency,
  						   dpd.fixed_cost,
  						   dpd.fixed_cost_currency
 					INTO ' + @deemed_process_table + '
 					FROM deal_price_deemed dpd
 					INNER JOIN #temp_collect_detail_ids sdd ON sdd.source_deal_detail_id = dpd.source_deal_detail_id
 					WHERE 1 = 1
 			        ' + CASE WHEN ISNULL(@enable_pricing, 'n') = 'y' AND ISNULL(@enable_provisional_tab, 'n') = 'y' THEN '' 
 							 WHEN ISNULL(@enable_pricing, 'n') = 'y' AND ISNULL(@enable_provisional_tab, 'n') = 'n' THEN ' AND dpd.pricing_provisional = ''p'' '
 							 WHEN ISNULL(@enable_pricing, 'n') = 'n' AND ISNULL(@enable_provisional_tab, 'n') = 'y' THEN ' AND dpd.pricing_provisional = ''q'' '
 						ELSE '' END
 					+ '
 					
 					SELECT dpse.deal_price_std_event_id [id], sdd.source_deal_detail_id, event_type, event_date, event_pricing_type, pricing_index, adder, currency, multiplier, volume, uom, pricing_provisional, sdd.source_deal_group_id
 					INTO ' + @std_event_process_table + '
 					FROM deal_price_std_event dpse
 					INNER JOIN #temp_collect_detail_ids sdd ON sdd.source_deal_detail_id = dpse.source_deal_detail_id
 					WHERE 1 = 1
 			        ' + CASE WHEN ISNULL(@enable_pricing, 'n') = 'y' AND ISNULL(@enable_provisional_tab, 'n') = 'y' THEN '' 
 							 WHEN ISNULL(@enable_pricing, 'n') = 'y' AND ISNULL(@enable_provisional_tab, 'n') = 'n' THEN ' AND dpse.pricing_provisional = ''p'' '
 							 WHEN ISNULL(@enable_pricing, 'n') = 'n' AND ISNULL(@enable_provisional_tab, 'n') = 'y' THEN ' AND dpse.pricing_provisional = ''q'' '
 						ELSE '' END
 					+ '
 					
 					SELECT dpce.deal_price_custom_event_id [id], sdd.source_deal_detail_id, event_type, event_date, pricing_index, skip_days, quotes_before, quotes_after, include_event_date, include_holidays, adder, currency, multiplier, volume, uom, pricing_provisional, sdd.source_deal_group_id
 					INTO ' + @custom_event_process_table + '
 					FROM deal_price_custom_event dpce
 					INNER JOIN #temp_collect_detail_ids sdd ON sdd.source_deal_detail_id = dpce.source_deal_detail_id
 					WHERE 1 = 1
 			        ' + CASE WHEN ISNULL(@enable_pricing, 'n') = 'y' AND ISNULL(@enable_provisional_tab, 'n') = 'y' THEN '' 
 							 WHEN ISNULL(@enable_pricing, 'n') = 'y' AND ISNULL(@enable_provisional_tab, 'n') = 'n' THEN ' AND dpce.pricing_provisional = ''p'' '
 							 WHEN ISNULL(@enable_pricing, 'n') = 'n' AND ISNULL(@enable_provisional_tab, 'n') = 'y' THEN ' AND dpce.pricing_provisional = ''q'' '
 						ELSE '' END
 					+ '
 					
 					SELECT sdd.source_deal_detail_id, sdd.pricing_type, sdd.source_deal_group_id, sdd.pricing_type2
 					INTO ' + @pricing_type_process_table + '
 					FROM source_deal_detail sdd 
 					INNER JOIN #temp_collect_detail_ids temp ON temp.source_deal_detail_id = sdd.source_deal_detail_id
 					'
 		--PRINT(@sql)
 		EXEC(@sql)

		Declare @sql_2 NVARCHAR(Max)

		SET @sql_2 = 'SELECT sdd.source_deal_detail_id,
  						   dpd.pricing_index,
  						   dpd.pricing_start,
  						   dpd.pricing_end,
  						   dpd.adder,
  						   dpd.currency,
  						   dpd.multiplier,
  						   dpd.volume,
  						   dpd.uom,
  						   dpd.pricing_provisional,
  						   sdd.source_deal_group_id,
  						   dpd.pricing_period,
  						   dpd.fixed_price,
  						   dpd.formula_id,
  						   dpd.[priority],
  						   dpd.adder_currency,
  						   dpd.pricing_uom,
  						   dpd.formula_currency,
  						   dpd.fixed_cost,
  						   dpd.fixed_cost_currency
 					INTO ' + @deemed_provisional_process_table + '
 					FROM deal_price_deemed_provisional dpd
 					INNER JOIN #temp_collect_detail_ids sdd ON sdd.source_deal_detail_id = dpd.source_deal_detail_id
 					WHERE 1 = 1
 			        ' + CASE WHEN ISNULL(@enable_pricing, 'n') = 'y' AND ISNULL(@enable_provisional_tab, 'n') = 'y' THEN '' 
 							 WHEN ISNULL(@enable_pricing, 'n') = 'y' AND ISNULL(@enable_provisional_tab, 'n') = 'n' THEN ' AND dpd.pricing_provisional = ''p'' '
 							 WHEN ISNULL(@enable_pricing, 'n') = 'n' AND ISNULL(@enable_provisional_tab, 'n') = 'y' THEN ' AND dpd.pricing_provisional = ''q'' '
 						ELSE '' END
 					+ '
 					
 					SELECT dpse.deal_price_std_event_provisional_id [id], sdd.source_deal_detail_id, event_type, event_date, event_pricing_type, pricing_index, adder, currency, multiplier, volume, uom, pricing_provisional, sdd.source_deal_group_id
 					INTO ' + @std_event_provisional_process_table + '
 					FROM deal_price_std_event_provisional dpse
 					INNER JOIN #temp_collect_detail_ids sdd ON sdd.source_deal_detail_id = dpse.source_deal_detail_id
 					WHERE 1 = 1
 			        ' + CASE WHEN ISNULL(@enable_pricing, 'n') = 'y' AND ISNULL(@enable_provisional_tab, 'n') = 'y' THEN '' 
 							 WHEN ISNULL(@enable_pricing, 'n') = 'y' AND ISNULL(@enable_provisional_tab, 'n') = 'n' THEN ' AND dpse.pricing_provisional = ''p'' '
 							 WHEN ISNULL(@enable_pricing, 'n') = 'n' AND ISNULL(@enable_provisional_tab, 'n') = 'y' THEN ' AND dpse.pricing_provisional = ''q'' '
 						ELSE '' END
 					+ '
 					
 					SELECT dpce.deal_price_custom_event_provisional_id [id], sdd.source_deal_detail_id, event_type, event_date, pricing_index, skip_days, quotes_before, quotes_after, include_event_date, include_holidays, adder, currency, multiplier, volume, uom, pricing_provisional, sdd.source_deal_group_id
 					INTO ' + @custom_event_provisional_process_table + '
 					FROM deal_price_custom_event_provisional dpce
 					INNER JOIN #temp_collect_detail_ids sdd ON sdd.source_deal_detail_id = dpce.source_deal_detail_id
 					WHERE 1 = 1
 			        ' + CASE WHEN ISNULL(@enable_pricing, 'n') = 'y' AND ISNULL(@enable_provisional_tab, 'n') = 'y' THEN '' 
 							 WHEN ISNULL(@enable_pricing, 'n') = 'y' AND ISNULL(@enable_provisional_tab, 'n') = 'n' THEN ' AND dpce.pricing_provisional = ''p'' '
 							 WHEN ISNULL(@enable_pricing, 'n') = 'n' AND ISNULL(@enable_provisional_tab, 'n') = 'y' THEN ' AND dpce.pricing_provisional = ''q'' '
 						ELSE '' END
 					+ '
 					
 					SELECT sdd.source_deal_detail_id, sdd.pricing_type, sdd.source_deal_group_id, sdd.pricing_type2
 					INTO ' + @pricing_type_provisional_process_table + '
 					FROM source_deal_detail sdd 
 					INNER JOIN #temp_collect_detail_ids temp ON temp.source_deal_detail_id = sdd.source_deal_detail_id
 					'
 		--PRINT(@sql)
 		EXEC(@sql_2)

	END
 	
	IF @disable_term = 'n'
	BEGIN
 		SELECT @disable_term = ISNULL(mftd.is_disable, 'n') 
 		FROM maintain_field_template_detail mftd 
 		INNER JOIN maintain_field_deal mfd ON mftd.field_id = mfd.field_id
 		WHERE mftd.field_template_id = @field_template_id
 		AND mfd.farrms_field_id = 'term_end'
	END	
 	
	IF @enable_document_tab = 'y'
	BEGIN			
 		SET @deal_required_doc_table = dbo.FNAProcessTableName('deal_required_doc', @user_name, @pricing_process_id)
 		SET @sql = 'CREATE TABLE ' + @deal_required_doc_table + '(
 							deal_required_document_id NVARCHAR(50) NULL,
 							source_deal_header_id INT NULL,
 							document_type INT NULL
 					)
 		
 					INSERT INTO ' + @deal_required_doc_table + '(deal_required_document_id,source_deal_header_id,document_type)
 					SELECT drd.deal_required_document_id,
 							drd.source_deal_header_id,
 							drd.document_type
 					FROM deal_required_document drd
 					WHERE drd.source_deal_header_id = ' + CAST(@source_deal_header_id AS NVARCHAR(20))		
 		--PRINT(@sql)
 		EXEC(@sql)
	END
 	
	IF @enable_remarks = 'y'
	BEGIN
 		SET @deal_remarks_table = dbo.FNAProcessTableName('deal_remarks', @user_name, @pricing_process_id)
 		SET @sql = 'CREATE TABLE ' + @deal_remarks_table + '(
 							deal_remarks_id NVARCHAR(50) NULL,
 							source_deal_header_id INT NULL,
 							deal_remarks NVARCHAR(MAX) NULL
 					)
 		
 					INSERT INTO ' + @deal_remarks_table + '(deal_remarks_id,source_deal_header_id,deal_remarks)
 					SELECT dr.deal_remarks_id,
 							dr.source_deal_header_id,
 							dr.deal_remarks
 					FROM deal_remarks dr
 					WHERE dr.source_deal_header_id = ' + CAST(@source_deal_header_id AS NVARCHAR(20))		
 		--PRINT(@sql)
 		EXEC(@sql)
	END
	
	--Integrated logic for deal lock for trader.
	DECLARE @deal_trade_locked NCHAR(1)
	
	SELECT 
		@deal_trade_locked = 
		CASE WHEN MAX(sdh.deal_locked) = 'y' THEN 'y'          
		ELSE           
			CASE WHEN MAX(dl.id) IS NOT NULL THEN          
				CASE WHEN DATEADD(mi, MIN(dl.hour) * 60 + ISNULL(MIN(dl.minute),0), ISNULL(MIN(sdh.update_ts), MIN(sdh.create_ts))) < GETDATE() THEN 'y' ELSE 'n' END 
			ELSE 'n'          
			END          
		END         
	FROM deal_lock_setup dl          
	INNER JOIN application_role_user aru 
	ON dl.role_id = aru.role_id 	 
	INNER JOIN source_deal_header sdh
	ON dl.deal_type_id = sdh.source_deal_type_id 
	OR  dl.deal_type_id IS NULL      
	WHERE aru.user_login_id = dbo.FNADBUser() 
	AND sdh.source_deal_header_id = @source_deal_header_id GROUP BY aru.user_login_id 
	
	DECLARE @actual_granularity INT
	DECLARE @deal_id VARCHAR(400)
	SELECT @actual_granularity = sdht.actual_granularity,
			@deal_id = sdh.deal_id
	FROM source_deal_header sdh
	INNER JOIN source_deal_header_template sdht On sdht.template_id = sdh.template_id
	WHERE sdh.source_deal_header_id = @source_deal_header_id

	IF EXISTS(
		SELECT 1
		FROM deal_default_value
		WHERE [deal_type_id] = @deal_type_id
				AND [commodity] = @commodity_id
				AND (([pricing_type] IS NULL AND @pricing_type IS NULL) OR [pricing_type] = @pricing_type)
				AND (buy_sell_flag IS NULL OR ISNULL(buy_sell_flag, 'x') = ISNULL(@default_header_buy_sell_flag, 'y'))
	)
	BEGIN
		SELECT @actual_granularity = ISNULL(actual_granularity, @actual_granularity)
		FROM deal_default_value 
		WHERE deal_type_id = @deal_type_id 
		AND ((pricing_type IS NULL AND @pricing_type IS NULL) OR pricing_type = @pricing_type)
		AND commodity = @commodity_id
		AND (buy_sell_flag IS NULL OR ISNULL(buy_sell_flag, 'x') = ISNULL(@default_header_buy_sell_flag, 'y'))
	END
	
	DECLARE @term_freq_int INT
	SET @term_freq_int = CASE @term_frequency
	                          WHEN 'm' THEN 980
	                          WHEN 'q' THEN 991
	                          WHEN 'h' THEN 982
	                          WHEN 's' THEN 992
	                          WHEN 'a' THEN 993
	                          WHEN 'd' THEN 981
	                          WHEN 'z' THEN 0
	                     END

	IF @call_From = 'evergreen_alert'
	BEGIN
		SELECT @pricing_process_id [pricing_process_id]
		RETURN
	END

	-- Check if UDT buttons needs to be shown
	DECLARE @enable_header_udt CHAR(1) = 'n', @enable_detail_udt CHAR(1) = 'n'
	IF EXISTS(
		SELECT 1
		FROM maintain_field_template_detail
		WHERE field_template_id = @field_template_id AND udf_or_system = 't' AND field_group_id IS NOT NULL
			AND ISNULL(show_in_form, 'n') = 'n'
	)
	BEGIN
		SET @enable_header_udt = 'y'
	END

	IF EXISTS(
		SELECT 1 
		FROM maintain_field_template_detail
		WHERE field_template_id = @field_template_id AND udf_or_system = 't' AND detail_group_id IS NOT NULL
	)
	BEGIN
		SET @enable_detail_udt = 'y'
	END

	IF @view_deleted = 'n'      
	BEGIN         
		SELECT ISNULL(deal_locked, 'n') deal_locked,
 				@disable_term [disable_term],
 				dbo.FNAGetSQLStandardDate(sdh.deal_date) deal_date,
 				@enable_efp [enable_efp],
 				@enable_trigger [enable_trigger],
 				sdt.source_deal_type_name [deal_type],
 				@enable_pricing [enable_pricing],
 				@enable_provisional_tab [enable_provisional_tab],
 				@enable_escalation_tab [enable_escalation_tab],
 				@pricing_process_id [pricing_process_id],
 				CASE WHEN sdh.internal_desk_id = 17302 THEN 'y' WHEN sdh.internal_desk_id = 17301 THEN 'f' ELSE 'n' END [is_shaped],
 				@term_frequency [term_frequency],
 				@enable_cost_tab [header_cost_enable],
 				@enable_detail_cost [detail_cost_enable],
 				@disable_certificate [certificate],
 				@enable_document_tab [document_enable],
 				@enable_remarks	[enable_remarks],
 				@deal_trade_locked [deal_trade_locked],
 				@deal_type_id [deal_type_id],
 				@pricing_type [pricing_type_id],
				@enable_exercise [enable_exercise],
				--CASE 
				--	 WHEN @actual_granularity IS NULL THEN NULL
				--	 ELSE CASE 
				--			   WHEN sdh.internal_desk_id = 17301 OR sdd.meter_id IS NOT NULL THEN 'm'
				--			   WHEN sdh.internal_desk_id = 17302 THEN 's'
				--			   ELSE CASE 
				--						 WHEN @term_freq_int = @actual_granularity THEN 'd'
				--						 ELSE 's'
				--					END
				--		  END
				--END [actualization_flag], ## Commented because the logic now completely checked on the basis of deal volume type only which is listed in the select list below.
				NULL [actualization_flag], 
				@udf_process_id [udf_process_id],
				@commodity_id [commodity_id],
				@enable_udf_tab [enable_udf_tab],
				sdh.profile_granularity,
				sdh.internal_desk_id [volume_type],
				IIF(sdd.meter_id IS NULL, 'n', 'y') [profile_gran_with_meter],
                sdh.is_environmental [is_environmental],
				@enable_prepay_tab [enable_prepay_tab],
				@deal_id [deal_reference_id],
				@enable_header_udt [enable_header_udt],
				@enable_detail_udt [enable_detail_udt]
			FROM source_deal_header sdh
			INNER JOIN source_deal_type sdt 
				ON sdt.source_deal_type_id = sdh.source_deal_type_id
			OUTER APPLY (
				SELECT TOP(1) ISNULL(sdd.meter_id, smlm.meter_id) meter_id
				FROM source_deal_detail sdd 
				INNER JOIN source_minor_location sml
					ON sml.source_minor_location_id = sdd.location_id
				LEFT JOIN source_minor_location_meter smlm
					ON smlm.source_minor_location_id = sml.source_minor_location_id
				WHERE sdd.source_deal_header_id = sdh.source_deal_header_id 
					--AND sdd.meter_id IS NOT NULL
			) sdd
			WHERE sdh.source_deal_header_id = @source_deal_header_id
	END
	ELSE
	BEGIN
		SELECT ISNULL(deal_locked, 'n') deal_locked,
 				@disable_term [disable_term],
 				dbo.FNAGetSQLStandardDate(sdh.deal_date) deal_date,
 				@enable_efp [enable_efp],
 				@enable_trigger [enable_trigger],
 				sdt.source_deal_type_name [deal_type],
 				@enable_pricing [enable_pricing],
 				@enable_provisional_tab [enable_provisional_tab],
 				@enable_escalation_tab [enable_escalation_tab],
 				@pricing_process_id [pricing_process_id],
 				CASE WHEN sdh.internal_desk_id = 17302 THEN 'y' WHEN sdh.internal_desk_id = 17301 THEN 'f' ELSE 'n' END [is_shaped],
 				@term_frequency [term_frequency],
 				@enable_cost_tab [header_cost_enable],
 				@enable_detail_cost [detail_cost_enable],
 				@disable_certificate [certificate],
 				@enable_document_tab [document_enable],
 				@enable_remarks	[enable_remarks],
 				@deal_trade_locked [deal_trade_locked],
 				@deal_type_id [deal_type_id],
 				@pricing_type [pricing_type_id],
				@enable_exercise [enable_exercise],
				CASE 
					 WHEN @actual_granularity IS NULL THEN NULL
					 ELSE CASE 
							   WHEN sdh.internal_desk_id = 17301 OR sdd.meter_id IS NOT NULL THEN 'm'
							   WHEN sdh.internal_desk_id = 17302 THEN 's'
							   ELSE CASE 
										 WHEN @term_freq_int = @actual_granularity THEN 'd'
										 ELSE 's'
									END
						  END
				END [actualization_flag],
				@udf_process_id [udf_process_id],
				@commodity_id [commodity_id],
				@enable_udf_tab [enable_udf_tab],
				sdh.is_environmental [is_environmental],
				@deal_id [deal_reference_id],
				@enable_header_udt [enable_header_udt],
				@enable_detail_udt [enable_detail_udt]
		FROM delete_source_deal_header sdh
		INNER JOIN source_deal_type sdt ON  sdt.source_deal_type_id = sdh.source_deal_type_id
		OUTER APPLY (SELECT TOP(1) meter_id FROM delete_source_deal_detail sdd WHERE sdd.source_deal_header_id = sdh.source_deal_header_id AND sdd.meter_id IS NOT NULL) sdd
		WHERE sdh.source_deal_header_id = @source_deal_header_id
	END
END
ELSE IF @flag = 'm'
BEGIN	
	IF @term_frequency = 't'
	BEGIN
		SET @to_date = @from_date
	END
	ELSE
	BEGIN		
		SET @from_date = dbo.FNAGetTermStartDate(@term_frequency, @from_date, 1)
		SET @to_date = dbo.FNAGetTermEndDate(@term_frequency, @from_date, 0)
	END 	
	SELECT dbo.FNAGetSQLStandardDate(@from_date) [from_date], dbo.FNAGetSQLStandardDate(@to_date) [to_date]	
END
ELSE IF @flag = 'x'
BEGIN
	IF @enable_pricing = 'y' OR @enable_provisional_tab = 'y' OR @enable_escalation_tab = 'y'
 		SET @pricing_process_id = dbo.FNAGetNewId()

	DECLARE @deal_date DATETIME = GETDATE()
 	DECLARE @deal_env_copy_check NCHAR(1)
 	
 	IF @copy_deal_id IS NOT NULL
 	BEGIN 		
 		SELECT @deal_date = deal_date 
 		FROM source_deal_header sdh
 		WHERE sdh.source_deal_header_id = @copy_deal_id
		
		SELECT @deal_env_copy_check = is_environmental 
 		FROM source_deal_header sdh
 		WHERE sdh.source_deal_header_id = @copy_deal_id
 	END
 	
	IF @enable_escalation_tab = 'y'
	BEGIN
		SET @deal_escalation_process_table = dbo.FNAProcessTableName('deal_escalation_process_table', @user_name, @pricing_process_id)
		
		SET @sql = '
		SELECT de.deal_escalation_id [id], sdd.source_deal_detail_id, de.quality, de.range_from, de.range_to, de.increment, de.cost_increment, de.operator, de.[reference], de.currency, DENSE_RANK() OVER(ORDER BY sdd.source_deal_group_id ASC) source_deal_group_id
 		INTO ' + @deal_escalation_process_table + '
 		FROM deal_escalation de
 		INNER JOIN source_deal_detail sdd ON sdd.source_deal_detail_id = de.source_deal_detail_id
 		WHERE sdd.source_deal_header_id = ' + CAST(@source_deal_header_id AS NVARCHAR(20)) + '
 		'
 		EXEC(@sql)
	END
 	
	IF @enable_pricing = 'y' OR @enable_provisional_tab = 'y'
	BEGIN
 		SET @deemed_process_table = dbo.FNAProcessTableName('deemed_process_table', @user_name, @pricing_process_id)
 		SET @std_event_process_table = dbo.FNAProcessTableName('std_event_process_table', @user_name, @pricing_process_id)
 		SET @custom_event_process_table = dbo.FNAProcessTableName('custom_event_process_table', @user_name, @pricing_process_id)
 		SET @pricing_type_process_table = dbo.FNAProcessTableName('pricing_type_process_table', @user_name, @pricing_process_id)
		SET @deemed_provisional_process_table = dbo.FNAProcessTableName('deemed_provisional_process_table', @user_name, @pricing_process_id)
 		SET @std_event_provisional_process_table = dbo.FNAProcessTableName('std_event_provisional_process_table', @user_name, @pricing_process_id)
 		SET @custom_event_provisional_process_table = dbo.FNAProcessTableName('custom_event_provisional_process_table', @user_name, @pricing_process_id)
 		SET @pricing_type_provisional_process_table = dbo.FNAProcessTableName('pricing_type_provisional_process_table', @user_name, @pricing_process_id)
 		 		
 		INSERT INTO #temp_collect_detail_ids
 		SELECT sdd.source_deal_detail_id, sdd.source_deal_group_id
 		FROM source_deal_header sdh 
 		INNER JOIN source_deal_detail sdd ON sdh.source_deal_header_id = sdd.source_deal_header_id
 		WHERE sdh.source_deal_header_id = @source_deal_header_id
 		
 		SET @sql = 'SELECT sdd.source_deal_detail_id,
  						   pricing_index,
  						   pricing_start,
  						   pricing_end,
  						   adder,
  						   currency,
  						   multiplier,
  						   volume,
  						   uom,
  						   pricing_provisional,
  						   DENSE_RANK() OVER(ORDER BY sdd.source_deal_group_id ASC) source_deal_group_id,
  						   dpd.pricing_period,
  						   dpd.fixed_price,
  						   dpd.formula_id,
  						   dpd.[priority],
  						   dpd.adder_currency,
  						   dpd.pricing_uom,
  						   dpd.formula_currency,
  						   dpd.fixed_cost,
  						   dpd.fixed_cost_currency
 					INTO ' + @deemed_process_table + '
 					FROM deal_price_deemed dpd
 					INNER JOIN #temp_collect_detail_ids sdd ON sdd.source_deal_detail_id = dpd.source_deal_detail_id
 					WHERE 1 = 1
 			        ' + CASE WHEN ISNULL(@enable_pricing, 'n') = 'y' AND ISNULL(@enable_provisional_tab, 'n') = 'y' THEN '' 
 							 WHEN ISNULL(@enable_pricing, 'n') = 'y' AND ISNULL(@enable_provisional_tab, 'n') = 'n' THEN ' AND dpd.pricing_provisional = ''p'' '
 							 WHEN ISNULL(@enable_pricing, 'n') = 'n' AND ISNULL(@enable_provisional_tab, 'n') = 'y' THEN ' AND dpd.pricing_provisional = ''q'' '
 						ELSE '' END
 					+ '
 					
 					SELECT dpse.deal_price_std_event_id [id], sdd.source_deal_detail_id, event_type, event_date, event_pricing_type, pricing_index, adder, currency, multiplier, volume, uom, pricing_provisional, DENSE_RANK() OVER(ORDER BY sdd.source_deal_group_id ASC) source_deal_group_id
 					INTO ' + @std_event_process_table + '
 					FROM deal_price_std_event dpse
 					INNER JOIN #temp_collect_detail_ids sdd ON sdd.source_deal_detail_id = dpse.source_deal_detail_id
 					WHERE 1 = 1
 			        ' + CASE WHEN ISNULL(@enable_pricing, 'n') = 'y' AND ISNULL(@enable_provisional_tab, 'n') = 'y' THEN '' 
 							 WHEN ISNULL(@enable_pricing, 'n') = 'y' AND ISNULL(@enable_provisional_tab, 'n') = 'n' THEN ' AND dpse.pricing_provisional = ''p'' '
 							 WHEN ISNULL(@enable_pricing, 'n') = 'n' AND ISNULL(@enable_provisional_tab, 'n') = 'y' THEN ' AND dpse.pricing_provisional = ''q'' '
 						ELSE '' END
 					+ '
 					
 					SELECT dpce.deal_price_custom_event_id [id], sdd.source_deal_detail_id, event_type, event_date, pricing_index, skip_days, quotes_before, quotes_after, include_event_date, include_holidays, adder, currency, multiplier, volume, uom, pricing_provisional, DENSE_RANK() OVER(ORDER BY sdd.source_deal_group_id ASC) source_deal_group_id
 					INTO ' + @custom_event_process_table + '
 					FROM deal_price_custom_event dpce
 					INNER JOIN #temp_collect_detail_ids sdd ON sdd.source_deal_detail_id = dpce.source_deal_detail_id
 					WHERE 1 = 1
 			        ' + CASE WHEN ISNULL(@enable_pricing, 'n') = 'y' AND ISNULL(@enable_provisional_tab, 'n') = 'y' THEN '' 
 							 WHEN ISNULL(@enable_pricing, 'n') = 'y' AND ISNULL(@enable_provisional_tab, 'n') = 'n' THEN ' AND dpce.pricing_provisional = ''p'' '
 							 WHEN ISNULL(@enable_pricing, 'n') = 'n' AND ISNULL(@enable_provisional_tab, 'n') = 'y' THEN ' AND dpce.pricing_provisional = ''q'' '
 						ELSE '' END
 					+ '
 					
 					SELECT sdd.source_deal_detail_id, sdd.pricing_type, DENSE_RANK() OVER(ORDER BY sdd.source_deal_group_id ASC) source_deal_group_id, sdd.pricing_type2
 					INTO ' + @pricing_type_process_table + '
 					FROM source_deal_detail sdd 
 					INNER JOIN #temp_collect_detail_ids temp ON temp.source_deal_detail_id = sdd.source_deal_detail_id
 					'
 		--PRINT(@sql)
 		EXEC(@sql)

		Declare @sql_3 NVARCHAR(MAX)
		SET @sql_3 = 'SELECT sdd.source_deal_detail_id,
  						   pricing_index,
  						   pricing_start,
  						   pricing_end,
  						   adder,
  						   currency,
  						   multiplier,
  						   volume,
  						   uom,
  						   pricing_provisional,
  						   DENSE_RANK() OVER(ORDER BY sdd.source_deal_group_id ASC) source_deal_group_id,
  						   dpd.pricing_period,
  						   dpd.fixed_price,
  						   dpd.formula_id,
  						   dpd.[priority],
  						   dpd.adder_currency,
  						   dpd.pricing_uom,
  						   dpd.formula_currency,
  						   dpd.fixed_cost,
  						   dpd.fixed_cost_currency
 					INTO ' + @deemed_provisional_process_table + '
 					FROM deal_price_deemed_provisional dpd
 					INNER JOIN #temp_collect_detail_ids sdd ON sdd.source_deal_detail_id = dpd.source_deal_detail_id
 					WHERE 1 = 1
 			        ' + CASE WHEN ISNULL(@enable_pricing, 'n') = 'y' AND ISNULL(@enable_provisional_tab, 'n') = 'y' THEN '' 
 							 WHEN ISNULL(@enable_pricing, 'n') = 'y' AND ISNULL(@enable_provisional_tab, 'n') = 'n' THEN ' AND dpd.pricing_provisional = ''p'' '
 							 WHEN ISNULL(@enable_pricing, 'n') = 'n' AND ISNULL(@enable_provisional_tab, 'n') = 'y' THEN ' AND dpd.pricing_provisional = ''q'' '
 						ELSE '' END
 					+ '
 					
 					SELECT dpse.deal_price_std_event_provisional_id [id], sdd.source_deal_detail_id, event_type, event_date, event_pricing_type, pricing_index, adder, currency, multiplier, volume, uom, pricing_provisional, DENSE_RANK() OVER(ORDER BY sdd.source_deal_group_id ASC) source_deal_group_id
 					INTO ' + @std_event_provisional_process_table + '
 					FROM deal_price_std_event_provisional dpse
 					INNER JOIN #temp_collect_detail_ids sdd ON sdd.source_deal_detail_id = dpse.source_deal_detail_id
 					WHERE 1 = 1
 			        ' + CASE WHEN ISNULL(@enable_pricing, 'n') = 'y' AND ISNULL(@enable_provisional_tab, 'n') = 'y' THEN '' 
 							 WHEN ISNULL(@enable_pricing, 'n') = 'y' AND ISNULL(@enable_provisional_tab, 'n') = 'n' THEN ' AND dpse.pricing_provisional = ''p'' '
 							 WHEN ISNULL(@enable_pricing, 'n') = 'n' AND ISNULL(@enable_provisional_tab, 'n') = 'y' THEN ' AND dpse.pricing_provisional = ''q'' '
 						ELSE '' END
 					+ '
 					
 					SELECT dpce.deal_price_custom_event_provisional_id [id], sdd.source_deal_detail_id, event_type, event_date, pricing_index, skip_days, quotes_before, quotes_after, include_event_date, include_holidays, adder, currency, multiplier, volume, uom, pricing_provisional, DENSE_RANK() OVER(ORDER BY sdd.source_deal_group_id ASC) source_deal_group_id
 					INTO ' + @custom_event_provisional_process_table + '
 					FROM deal_price_custom_event_provisional dpce
 					INNER JOIN #temp_collect_detail_ids sdd ON sdd.source_deal_detail_id = dpce.source_deal_detail_id
 					WHERE 1 = 1
 			        ' + CASE WHEN ISNULL(@enable_pricing, 'n') = 'y' AND ISNULL(@enable_provisional_tab, 'n') = 'y' THEN '' 
 							 WHEN ISNULL(@enable_pricing, 'n') = 'y' AND ISNULL(@enable_provisional_tab, 'n') = 'n' THEN ' AND dpce.pricing_provisional = ''p'' '
 							 WHEN ISNULL(@enable_pricing, 'n') = 'n' AND ISNULL(@enable_provisional_tab, 'n') = 'y' THEN ' AND dpce.pricing_provisional = ''q'' '
 						ELSE '' END
 					+ '
 					
 					SELECT sdd.source_deal_detail_id, sdd.pricing_type, DENSE_RANK() OVER(ORDER BY sdd.source_deal_group_id ASC) source_deal_group_id, sdd.pricing_type2
 					INTO ' + @pricing_type_provisional_process_table + '
 					FROM source_deal_detail sdd 
 					INNER JOIN #temp_collect_detail_ids temp ON temp.source_deal_detail_id = sdd.source_deal_detail_id
 					'
			EXEC(@sql_3)
	END
 	
	SELECT @term_frequency [term_frequency],
 	       @enable_cost_tab [header_cost_enable],
 	       ISNULL(@enable_detail_cost, 'n') [detail_cost_enable],
 	       @pricing_process_id [pricing_process_id],
 	       @enable_pricing [enable_pricing],
 	       @enable_provisional_tab [enable_provisional_tab],
 	       @enable_escalation_tab [enable_escalation_tab],
 	       dbo.FNAGetSQLStandardDate(@deal_date) [deal_date],
 	       @deal_type_id [deal_type_id],
 	       @pricing_type [pricing_type_id],
 	       CASE WHEN sdht.internal_desk_id = 17302 THEN 'y' WHEN sdht.internal_desk_id = 17301 THEN 'f' ELSE 'n' END [is_shaped],
		   @udf_process_id [udf_process_id],
		   @commodity_id [commodity_id],
		   @enable_udf_tab [enable_udf_tab],
		   @enable_prepay_tab [enable_prepay_tab]
 	FROM source_deal_header_template sdht 
 	WHERE sdht.template_id = @template_id
END
ELSE IF @flag = 'w' -- refresh documents
BEGIN
	SET @sql = 'SELECT drd.deal_required_document_id document_id,
						drd.document_type,
						dt.document_name document_name
 				FROM ' + @deal_required_doc_table + ' drd			
				INNER JOIN documents_type dt ON dt.document_id = drd.document_type				
 				'
	EXEC(@sql)
END
ELSE IF @flag = 'y' -- save doc to process table
BEGIN
BEGIN TRY
 	IF @document_list IS NOT NULL
 	BEGIN
 		SET @sql = '
 				INSERT INTO ' + @deal_required_doc_table + ' (source_deal_header_id, document_type)
 				SELECT ' + CAST(@source_deal_header_id AS NVARCHAR(20)) + ',
 						scsv.item
 				FROM dbo.SplitCommaSeperatedValues(''' + @document_list + ''') scsv
 				LEFT JOIN ' + @deal_required_doc_table + ' drd ON drd.document_type = scsv.item
 				WHERE drd.source_deal_header_id IS NULL			
 		'
 		EXEC(@sql)
 	END
 	
 	EXEC spa_ErrorHandler 0
 			, 'source_deal_header'
 			, 'spa_deal_update_new'
 			, 'Success'
 			, 'Successfully saved data.'
 			, ''
END TRY
BEGIN CATCH 
 	IF @@TRANCOUNT > 0
 		ROLLBACK
  
 	SET @DESC = 'Fail to insert Data ( Errr Description:' + ERROR_MESSAGE() + ').'
  
 	SELECT @err_no = ERROR_NUMBER()
  
 	EXEC spa_ErrorHandler @err_no
 		, 'source_deal_header'
 		, 'spa_deal_update_new'
 		, 'Error'
 		, @DESC
 		, ''
END CATCH
END
ELSE IF @flag = 'z' -- delete document from process table
BEGIN
	IF @document_list IS NOT NULL
	BEGIN
 		SET @sql = '
 				DELETE drd
 				FROM ' + @deal_required_doc_table + ' drd
 				INNER JOIN dbo.SplitCommaSeperatedValues(''' + @document_list + ''') scsv ON drd.document_type = scsv.item
 		'
 		EXEC(@sql)
	END
END
ELSE IF @flag = 'o' -- refresh remarks grid
BEGIN
	SET @sql = 'SELECT drt.deal_remarks_id id,
 						drt.deal_remarks remarks
 				FROM ' + @deal_remarks_table + ' drt			
 				'
	EXEC(@sql)
END
ELSE IF @flag = 'r' -- save remarks to process table
BEGIN
BEGIN TRY
 	IF @remarks_list IS NOT NULL
 	BEGIN
 		SET @sql = '
 				INSERT INTO ' + @deal_remarks_table + ' (deal_remarks_id, source_deal_header_id, deal_remarks)
 				SELECT ''New_'' + CAST(sdv.value_id AS NVARCHAR(20)) + ISNULL(''_'' + CAST(NULLIF(cnt.num, 0) AS NVARCHAR(20)), ''''),
 						' + CAST(@source_deal_header_id AS NVARCHAR(20)) + ',
 						sdv.description
 				FROM dbo.SplitCommaSeperatedValues(''' + @remarks_list + ''') scsv
 				INNER JOIN static_data_value sdv ON sdv.value_id = scsv.item
 				LEFT JOIN ' + @deal_remarks_table + ' dr ON dr.deal_remarks = sdv.code
 				OUTER APPLY (SELECT COUNT(1) num FROM ' + @deal_remarks_table + ' 
 				WHERE 
 				SUBSTRING(REPLACE(deal_remarks_id, ''New_'', ''''), 0, ISNULL(NULLIF(CHARINDEX(''_'',  REPLACE(deal_remarks_id, ''New_'', '''')), 0), LEN(REPLACE(deal_remarks_id, ''New_'', ''''))+1)) = CAST(sdv.value_id AS NVARCHAR(20))) cnt
 					
 				WHERE dr.source_deal_header_id IS NULL			
 		'
 		--PRINT(@sql)
 		EXEC(@sql)
 	END
 	
 	EXEC spa_ErrorHandler 0
 			, 'source_deal_header'
 			, 'spa_deal_update_new'
 			, 'Success'
 			, 'Successfully saved data.'
 			, ''
END TRY
BEGIN CATCH 
 	IF @@TRANCOUNT > 0
 		ROLLBACK
  
 	SET @DESC = 'Fail to insert Data ( Errr Description:' + ERROR_MESSAGE() + ').'
  
 	SELECT @err_no = ERROR_NUMBER()
  
 	EXEC spa_ErrorHandler @err_no
 		, 'source_deal_header'
 		, 'spa_deal_update_new'
 		, 'Error'
 		, @DESC
 		, ''
END CATCH
END
ELSE IF @flag = 'u' -- delete remarks from process table
BEGIN
	IF @remarks_list IS NOT NULL
	BEGIN
 		SET @sql = '
 				DELETE dr
 				FROM ' + @deal_remarks_table + ' dr
 				INNER JOIN dbo.SplitCommaSeperatedValues(''' + @remarks_list + ''') scsv ON dr.deal_remarks_id = scsv.item
 		'
 		--PRINT(@sql)
 		EXEC(@sql)
	END
END
ELSE IF @flag = 'v'
BEGIN
	IF @remarks_list IS NOT NULL
	BEGIN
 		SET @sql = '
 				IF NOT EXISTS(SELECT 1 FROM ' + @deal_remarks_table + ' WHERE deal_remarks_id = ''' + @remarks_list + ''')
 				BEGIN
 					INSERT INTO ' + @deal_remarks_table + ' (deal_remarks_id, source_deal_header_id, deal_remarks)
 					SELECT ''' + @remarks_list + ''', ' + CAST(@source_deal_header_id AS NVARCHAR(20)) + ',''' + @document_list + '''
 				END
 				ELSE 
 				BEGIN
 					UPDATE ' + @deal_remarks_table + ' 
 					SET deal_remarks = ''' + @document_list + '''
 					WHERE deal_remarks_id = ''' + @remarks_list + '''
 				END		
 		'
 		--PRINT(@sql)
 		EXEC(@sql)
	END
END
ELSE IF @flag = 'f'
BEGIN
	BEGIN TRY 		
		DECLARE @new_group_id INT
		INSERT INTO source_deal_groups (source_deal_header_id, source_deal_groups_name)
		SELECT @source_deal_header_id, @group_id

		SET @new_group_id = SCOPE_IDENTITY()

		UPDATE source_deal_detail
		SET source_deal_group_id = @new_group_id
		WHERE source_deal_detail_id = @detail_id
 	
 		EXEC spa_ErrorHandler 0
 				, 'source_deal_header'
 				, 'spa_deal_update_new'
 				, 'Success'
 				, 'Successfully saved data.'
 				, ''
	END TRY
	BEGIN CATCH 
 		IF @@TRANCOUNT > 0
 			ROLLBACK
  
 		SET @DESC = 'Fail to insert Data ( Errr Description:' + ERROR_MESSAGE() + ').'
  
 		SELECT @err_no = ERROR_NUMBER()
  
 		EXEC spa_ErrorHandler @err_no
 			, 'source_deal_header'
 			, 'spa_deal_update_new'
 			, 'Error'
 			, @DESC
 			, ''
	END CATCH
END
ELSE IF @flag = 'g'
BEGIN
	DECLARE @combo_sql_string NVARCHAR(MAX)
	
	IF OBJECT_ID('tempdb..#temp_connector_combo') IS NOT NULL
		DROP TABLE #temp_connector_combo
	
	CREATE TABLE #temp_connector_combo(
		[value]      NVARCHAR(10) COLLATE DATABASE_DEFAULT,
		[text]       NVARCHAR(1000) COLLATE DATABASE_DEFAULT,
		[selected]   NVARCHAR(10) COLLATE DATABASE_DEFAULT,
		[state]      NVARCHAR(10) DEFAULT 'enable' COLLATE DATABASE_DEFAULT
	)
		
	IF @farrms_field_id IN ('contract_id','counterparty_id','counterparty_trader','counterparty2_trader', 'location_id', 'curve_id', 'formula_curve_id', 'detail_commodity_id', 'trader_id', 'deal_volume_uom_id', 'status', 'sub_book', 'vintage', 'tier_value_id', 'reporting_tier_id')
	BEGIN
		DECLARE @mapped_trader_id INT

		SET @combo_process_table = dbo.FNAProcessTableName('combo_process', @combo_user_name, @combo_process_id)		
				
		IF @source_deal_header_id IS NOT NULL
 		BEGIN 		
			EXEC spa_deal_fields_mapping @flag='c',@deal_id=@source_deal_header_id,@deal_fields=@farrms_field_id,@default_value=@selected_value, @process_table = @combo_process_table, @trader_id = @mapped_trader_id
 		END			
 		ELSE
 		BEGIN	
			IF @farrms_field_id = 'trader_id'
				SET @selected_value = ISNULL(@trader_id,@selected_value)
					 		
 			EXEC spa_deal_fields_mapping @flag = 'c',
 			     @template_id = @template_id,
 			     @deal_fields = @farrms_field_id,
 			     @default_value = @selected_value,
 			     @process_table = @combo_process_table,
 			     @deal_type_id = @deal_type_id,
 			     @commodity_id = @commodity_id
 		END
 		
 		SET @sql = 'INSERT INTO #temp_connector_combo ([value], [text], [state], [selected])
 					SELECT [value], [text], [state], [selected]
 					FROM ' + @combo_process_table
 		EXEC(@sql)
	END
	ELSE
	BEGIN
		IF @is_udf = 's'
		BEGIN		
			SELECT @combo_sql_string = mfd.sql_string
			FROM maintain_field_deal mfd
			WHERE mfd.farrms_field_id = @farrms_field_id
		END
		ELSE IF @is_udf = 'e'
		BEGIN
			IF @farrms_field_id = 'logical_term'
				SELECT @combo_sql_string = 'EXEC spa_staticdatavalues @flag = ''h'', @type_id = 19300, @license_not_to_static_value_id = ''19301,19302,19303,19304'''
		END
		ELSE 
		BEGIN
			SELECT @combo_sql_string = ISNULL(NULLIF(udft.sql_string, ''), uds.sql_string)
			FROM user_defined_fields_template udft
			LEFT JOIN udf_data_source uds ON uds.udf_data_source_id = udft.data_source_type_id
			WHERE udft.udf_template_id = ABS(REPLACE(@farrms_field_id, 'UDF___', ''))
		END
		
		IF @required = 'n'
		BEGIN
			INSERT INTO #temp_connector_combo([value], [text])
			SELECT '', ''
		END
		
 		SET @type = SUBSTRING(@combo_sql_string, 1, 1)
	
 		IF @type = '['
 		BEGIN
 			SET @sql_string = REPLACE(@combo_sql_string, NCHAR(13), '')
 			SET @sql_string = REPLACE(@sql_string, NCHAR(10), '')
 			SET @sql_string = REPLACE(@sql_string, NCHAR(32), '')	
 			SET @sql_string = [dbo].[FNAParseStringIntoTable](@sql_string)  
 			EXEC('INSERT INTO #temp_connector_combo([value], [text], [state])
 					SELECT value_id, code, ''enabled'' from (' + @sql_string + ') a(value_id, code)');

 		END 
 		ELSE
 		BEGIN
			BEGIN TRY
 				INSERT INTO #temp_connector_combo([value], [text], [state])
 				EXEC(@combo_sql_string)
			END TRY
			BEGIN CATCH
				INSERT INTO #temp_connector_combo([value], [text])
 				EXEC(@combo_sql_string)
			END CATCH
 		END
		
		UPDATE #temp_connector_combo
		SET [selected] = 'true'
		WHERE [value] IN (@selected_value)
	END
	
	SELECT value,
	        [text],
	        [state],
	        ISNULL(selected, 'false') selected
	FROM #temp_connector_combo
END
ELSE IF @flag = 'get_sub_id_from_field_template'
BEGIN
	SELECT CASE WHEN mfd.farrms_field_id = 'sub_book' THEN mftd.default_value ELSE ISNULL(sdht.source_deal_type_id, mftd.default_value) END default_value
	FROM maintain_field_template_detail mftd
	INNER JOIN maintain_field_deal mfd ON mfd.field_id = mftd.field_id
	INNER JOIN source_deal_header_template sdht ON sdht.field_template_id = mftd.field_template_id
	WHERE mfd.farrms_field_id IN ('sub_book','source_deal_type_id')
	AND sdht.template_id = @template_id
	ORDER BY mfd.farrms_field_id DESC  -- Order: subbook - 0 and source_deal_type_id = 1 always.
END
ELSE IF @flag = 'get_environmental_from_field_template'
BEGIN
	SELECT CASE WHEN mfd.farrms_field_id = 'sub_book' THEN mftd.default_value ELSE ISNULL(sdht.source_deal_type_id, mftd.default_value) END default_value
	FROM maintain_field_template_detail mftd
	INNER JOIN maintain_field_deal mfd ON mfd.field_id = mftd.field_id
	INNER JOIN source_deal_header_template sdht ON sdht.field_template_id = mftd.field_template_id
	WHERE mfd.farrms_field_id IN ('is_environmental')
	AND sdht.template_id = @template_id
END
ELSE IF @flag = 'get_certificate_from_field_template'
BEGIN
	IF @source_deal_header_id IS NOT NULL
	BEGIN
	SELECT CASE WHEN mfd.farrms_field_id = 'sub_book' THEN mftd.default_value ELSE ISNULL(sdht.source_deal_type_id, mftd.default_value) END default_value
	FROM maintain_field_template_detail mftd
	INNER JOIN maintain_field_deal mfd ON mfd.field_id = mftd.field_id
	INNER JOIN source_deal_header_template sdht ON sdht.field_template_id = mftd.field_template_id
		INNER JOIN source_deal_header sdh on sdh.template_id = sdht.template_id
	WHERE mfd.farrms_field_id IN ('is_environmental') 
	AND sdht.template_id = @template_id and sdht.header_buy_sell_flag = 'b'
		AND sdh.source_deal_header_id = @source_deal_header_id
	END
	ELSE 
	BEGIN
		SELECT CASE WHEN mfd.farrms_field_id = 'sub_book' THEN mftd.default_value ELSE ISNULL(sdht.source_deal_type_id, mftd.default_value) END default_value
		FROM maintain_field_template_detail mftd
		INNER JOIN maintain_field_deal mfd ON mfd.field_id = mftd.field_id
		INNER JOIN source_deal_header_template sdht ON sdht.field_template_id = mftd.field_template_id
	WHERE mfd.farrms_field_id IN ('is_environmental') 
	AND sdht.template_id = @template_id and sdht.header_buy_sell_flag = 'b'
END
END

ELSE IF @flag = 'check_environmental'
BEGIN
	SELECT 1 FROM source_deal_header  AS enable_environment WHERE source_deal_header_id = @source_deal_header_id AND is_environmental = 'y'
END

ELSE IF @flag = 'check_buy_sell'
BEGIN
	SELECT 'BUY' FROM source_deal_header  AS enable_environment WHERE source_deal_header_id = @source_deal_header_id AND header_buy_sell_flag = 'b'
END

ELSE IF @flag = 'lock_unlock'
BEGIN
	BEGIN TRY	
		UPDATE source_deal_detail
		SET lock_deal_detail = @detail_lock_status
		WHERE source_deal_detail_id = @detail_id	
		
 		SET @desc = 'Deal detail successfully ' + CASE WHEN @detail_lock_status = 'y' THEN ' locked. ' ELSE ' unlocked.' END
 		
		EXEC spa_ErrorHandler 0
			, 'source_deal_detail'
			, 'spa_deal_update_new'
			, 'Success' 
			, @desc
			, @detail_lock_status
	END TRY
	BEGIN CATCH 
		IF @@TRANCOUNT > 0
		   ROLLBACK
 
		SET @desc = 'Fail to ' + CASE WHEN @detail_lock_status = 'y' THEN 'lock' ELSE 'unlock' END + ' deal detail. ( Errr Description:' + ERROR_MESSAGE() + ').'
 
		SELECT @err_no = ERROR_NUMBER()
	
		EXEC spa_ErrorHandler @err_no
		   , 'source_deal_detail'
			, 'spa_deal_update_new'
		   , 'Error'
		   , @desc
		   , ''
	END CATCH		
END

ELSE IF @flag = 'get_udt_details'
BEGIN
	IF @call_from = 'h'
	BEGIN
		SELECT mftg.field_group_id [tab_id], mftg.group_name [tab_name], agd.grid_name
		FROM maintain_field_template_detail mftd
		INNER JOIN adiha_grid_definition agd ON agd.grid_id = mftd.field_id
		INNER JOIN maintain_field_template_group mftg ON mftg.field_group_id = mftd.field_group_id
		WHERE mftd.field_template_id = @field_template_id
			AND mftd.udf_or_system = 't' AND mftd.field_group_id IS NOT NULL AND ISNULL(mftd.show_in_form, 'n') = 'n'
		ORDER BY mftg.seq_no ASC
	END
	ELSE IF @call_from = 'd'
	BEGIN
		SELECT  mftgd.group_id [tab_id], mftgd.group_name [tab_name], agd.grid_name
		FROM maintain_field_template_detail mftd
		INNER JOIN adiha_grid_definition agd ON agd.grid_id = mftd.field_id
		INNER JOIN maintain_field_template_group_detail mftgd ON mftgd.group_id = mftd.detail_group_id
		WHERE mftd.field_template_id = @field_template_id
			AND mftd.udf_or_system = 't' AND mftd.detail_group_id IS NOT NULL
		ORDER BY mftgd.seq_no ASC
	END
END