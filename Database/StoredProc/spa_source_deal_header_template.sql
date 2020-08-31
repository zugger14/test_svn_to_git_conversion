SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID(N'[dbo].[spa_source_deal_header_template]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[spa_source_deal_header_template]
GO

/**
	Generic stored procedure to handle deal template.

	Parameters 
	@flag : 'b' - Returns deal templates with storage deal type 
			's' - Returns role based deal template according to different parameters
			'y' - Returns all active deal template according to different parameters
			'a' - Returns deal tempate with UDFs
			'i' - Inserts new deal template
			'u' - Updates deal template
			'd' - Deletes deal template
			'c' - Copies deal template
			'z' - Returns default entire_term_start and entire_term_end
			'p' - Returns default select priveleged deal template
			't' - Returns setups of term_start and term_end
	@template_id : Deal Template Id
	@template_name : Deal Template Name
	@physical_financial_flag : Physical Financial Flag
	@term_frequency_value : Term Frequency Value
	@term_frequency_type : Term Frequency Type
	@option_flag : Option Flag
	@option_type : Option Type
	@option_exercise_type : Option Exercise Type
	@description1 : Description1
	@description2 : Description2
	@description3 : Description3
	@buy_sell_flag : Buy Sell Flag
	@source_deal_type_id : Source Deal Type Id
	@deal_sub_type_type_id : Deal Sub Type Type Id
	@is_active : Is Active
	@internal_flag : Internal Flag
	@internal_deal_type_value_id : Internal Deal Type Value Id
	@internal_deal_subtype_value_id : Internal Deal Subtype Value Id
	@allow_edit_term : Allow Edit Term
	@blotter_support : Blotter Support
	@rollover_to_spot : Rollover To Spot
	@discounting_applies : Discounting Applies
	@term_end_flag : Term End Flag
	@is_public : Is Public
	@deal_status : Deal Status
	@deal_category_value_id : Deal Category Value Id
	@legal_entity : Legal Entity
	@commodity_id : Commodity Id
	@internal_portfolio_id : Internal Portfolio Id
	@product_id : Product Id
	@internal_desk_id : Internal Desk Id
	@blocktypecombo : Blocktypecombo
	@blockdefinitioncombo : Blockdefinitioncombo
	@granularitycombo : Granularitycombo
	@price : Price
	@model_id : Model Id
	@comments : Comments
	@trade_ticket_template : Trade Ticket Template
	@hourly_position_breakdown : Hourly Position Breakdown
	@counterparty_id : Counterparty Id
	@contract_id : Contract Id
	@fieldTemplateId : FieldTemplateId
	@trader_id : Trader Id
	@source_deal_header_id : Source Deal Header Id
	@source_system_id : Source System Id
	@deal_id : Deal Id
	@deal_date : Deal Date
	@ext_deal_id : Ext Deal Id
	@structured_deal_id : Structured Deal Id
	@entire_term_start : Entire Term Start
	@entire_term_end : Entire Term End
	@option_excercise_type : Option Excercise Type
	@broker_id : Broker Id
	@generator_id : Generator Id
	@status_value_id : Status Value Id
	@status_date : Status Date
	@assignment_type_value_id : Assignment Type Value Id
	@compliance_year : Compliance Year
	@state_value_id : State Value Id
	@assigned_date : Assigned Date
	@assigned_by : Assigned By
	@generation_source : Generation Source
	@aggregate_environment : Aggregate Environment
	@aggregate_envrionment_comment : Aggregate Envrionment Comment
	@rec_price : Rec Price
	@rec_formula_id : Rec Formula Id
	@rolling_avg : Rolling Avg
	@reference : Reference
	@deal_locked : Deal Locked
	@close_reference_id : Close Reference Id
	@deal_reference_type_id : Deal Reference Type Id
	@unit_fixed_flag : Unit Fixed Flag
	@broker_unit_fees : Broker Unit Fees
	@broker_fixed_cost : Broker Fixed Cost
	@broker_currency_id : Broker Currency Id
	@term_frequency : Term Frequency
	@option_settlement_date : Option Settlement Date
	@verified_by : Verified By
	@verified_date : Verified Date
	@risk_sign_off_by : Risk Sign Off By
	@risk_sign_off_date : Risk Sign Off Date
	@back_office_sign_off_by : Back Office Sign Off By
	@back_office_sign_off_date : Back Office Sign Off Date
	@book_transfer_id : Book Transfer Id
	@confirm_status_type : Confirm Status Type
	@udf_field : Udf Field
	@udf_value : Udf Value
	@deal_rules : Deal Rules
	@confirm_rule : Confirm Rule
	@role_id : Role Id
	@batch_process_id : Batch Process Id
	@batch_report_param : Batch Report Param
	@enable_paging : Enable Paging
	@page_size : Page Size
	@page_no : Page No
	@calculate_position_based_on_actual : Calculate Position Based On Actual
	@save_mtm_at_calculation_granularity : Save Mtm At Calculation Granularity
	@timezone_id : Timezone Id
	@ignore_bom : Ignore Bom
	@year : Year
	@month : Month
	@certificate : Certificate
	@counterparty_id2 : Counterparty Id2
	@trader_id2 : Trader Id2
	@scheduler : Scheduler
	@inco_terms : Inco Terms
	@governing_law : Governing Law
	@sample_control : Sample Control
	@payment_term : Payment Term
	@payment_days : Payment Days
	@arbitration : Arbitration
	@counterparty2_trader : Counterparty2 Trader
	@options_calc_method : Options Calc Method
	@attribute_type : Attribute Type
	@pricing_type : Pricing Type
	@clearing_counterparty_id : Clearing Counterparty Id
	@underlying_options : Underlying Options
	@confirmation_type : Confirmation Type
	@confirmation_template : Confirmation Template
	@sdr : Sdr
	@tier_value_id : Tier Value Id
	@fx_conversion_market : Fx Conversion Market
	@bid_n_ask_price : Bid N Ask Price
	@holiday_calendar : Holiday Calendar
	@collateral_amount : Collateral Amount
	@collateral_req_per : Collateral Req Per
	@collateral_months : Collateral Months
	@product_classification : Product Classification
	@fas_deal_type_value_id : Fas Deal Type Value Id
	@match_type : Match Type
	@reporting_tier_id : Reporting Tier Id
	@reporting_jurisdiction_id : Reporting Jurisdiction Id
	@reporting_group1 : Reporting Group 1
	@reporting_group2 : Reporting Group 2
	@reporting_group3 : Reporting Group 3
	@reporting_group4 : Reporting Group 4
	@reporting_group5 : Reporting Group 5

*/
CREATE PROCEDURE [dbo].[spa_source_deal_header_template] 
	@flag NCHAR(1)
	, @template_id INT = NULL
	, @template_name AS NVARCHAR(50) = NULL
	, @physical_financial_flag AS NCHAR(1) = NULL
	, @term_frequency_value AS NCHAR(1) = NULL
	, @term_frequency_type AS NCHAR(1) = NULL
	, @option_flag AS NCHAR(1) = NULL
	, @option_type AS NCHAR(1) = NULL
	, @option_exercise_type AS NCHAR(1) = NULL
	, @description1 NVARCHAR(50) = NULL
	, @description2 NVARCHAR(50) = NULL
	, @description3 NVARCHAR(50) = NULL
	, @buy_sell_flag NCHAR(1) = NULL
	, @source_deal_type_id INT = NULL
	, @deal_sub_type_type_id INT = NULL
	, @is_active NCHAR(1) = NULL
	, @internal_flag NCHAR(1) = NULL
	, @internal_deal_type_value_id INT = NULL
	, @internal_deal_subtype_value_id INT = NULL
	, @allow_edit_term NCHAR(1) = NULL
	, @blotter_support NCHAR(1) = NULL
	, @rollover_to_spot NCHAR(1) = NULL
	, @discounting_applies NCHAR(1) = NULL
	, @term_end_flag NCHAR(1) = NULL
	, @is_public NCHAR(1) = NULL
	, @deal_status INT = NULL
	, @deal_category_value_id INT = NULL
	, @legal_entity INT = NULL
	, @commodity_id INT = NULL
	, @internal_portfolio_id INT = NULL
	, @product_id INT = NULL
	, @internal_desk_id INT = NULL
	, @blocktypecombo INT = NULL
	, @blockdefinitioncombo INT = NULL
	, @granularitycombo INT = NULL
	, @price INT = NULL
	, @model_id INT = NULL
	, @comments NCHAR(1) = NULL
	, @trade_ticket_template NCHAR(1) = NULL
	, @hourly_position_breakdown NVARCHAR(10) = NULL
	, @counterparty_id INT = NULL
	, @contract_id INT = NULL
	, @fieldTemplateId INT = NULL
	, @trader_id INT = NULL
	, @source_deal_header_id INT = NULL
	, @source_system_id INT = NULL
	, @deal_id NVARCHAR(50) = NULL
	, @deal_date DATETIME = NULL
	, @ext_deal_id NVARCHAR(50) = NULL
	, @structured_deal_id NVARCHAR(50) = NULL
	, @entire_term_start DATETIME = NULL
	, @entire_term_end DATETIME = NULL
	, @option_excercise_type NCHAR(1) = NULL
	, @broker_id INT = NULL
	, @generator_id INT = NULL
	, @status_value_id INT = NULL
	, @status_date DATETIME = NULL
	, @assignment_type_value_id INT = NULL
	, @compliance_year INT = NULL
	, @state_value_id INT = NULL
	, @assigned_date DATETIME = NULL
	, @assigned_by NVARCHAR(50) = NULL
	, @generation_source NVARCHAR(250) = NULL
	, @aggregate_environment NVARCHAR(1) = NULL
	, @aggregate_envrionment_comment NVARCHAR(250) = NULL
	, @rec_price FLOAT = NULL
	, @rec_formula_id INT = NULL
	, @rolling_avg NCHAR(1) = NULL
	, @reference NVARCHAR(250) = NULL
	, @deal_locked NCHAR(1) = NULL
	, @close_reference_id INT = NULL
	, @deal_reference_type_id INT = NULL
	, @unit_fixed_flag NCHAR = NULL
	, @broker_unit_fees FLOAT = NULL
	, @broker_fixed_cost FLOAT = NULL
	, @broker_currency_id INT = NULL
	, @term_frequency NCHAR(1) = NULL
	, @option_settlement_date DATETIME = NULL
	, @verified_by NVARCHAR(50) = NULL
	, @verified_date DATETIME = NULL
	, @risk_sign_off_by NVARCHAR(50) = NULL
	, @risk_sign_off_date DATETIME = NULL
	, @back_office_sign_off_by NVARCHAR(50) = NULL
	, @back_office_sign_off_date DATETIME = NULL
	, @book_transfer_id INT = NULL
	, @confirm_status_type INT = NULL
	, @udf_field NVARCHAR(max) = NULL
	, @udf_value NVARCHAR(max) = NULL
	, @deal_rules INT = NULL
	, @confirm_rule INT = NULL
	, @role_id INT = NULL
	, @batch_process_id NVARCHAR(250) = NULL
	, @batch_report_param NVARCHAR(500) = NULL
	, @enable_paging INT = 0
	, @page_size INT = NULL
	, @page_no INT = NULL
	, @calculate_position_based_on_actual NCHAR(1) = NULL
	, @save_mtm_at_calculation_granularity INT = NULL
	, @timezone_id INT = NULL
	, @ignore_bom NCHAR(1) = NULL
	, @year INT = NULL
	, @month INT = NULL
	, @certificate NCHAR(1) = NULL
	, @counterparty_id2 INT = NULL
	, @trader_id2 INT = NULL
	, @scheduler INT = NULL
	, @inco_terms INT = NULL
	, @governing_law INT = NULL
	, @sample_control NCHAR(1) = NULL
	, @payment_term INT = NULL
	, @payment_days INT = NULL
	, @arbitration INT = NULL
	, @counterparty2_trader INT = NULL
	, @options_calc_method INT = NULL
	, @attribute_type INT = NULL
	, @pricing_type INT = NULL
	, @clearing_counterparty_id INT = NULL
	, @underlying_options INT = NULL
	, @confirmation_type INT = NULL
	, @confirmation_template INT = NULL
	, @sdr NCHAR(1) = NULL
	, @tier_value_id INT = NULL
	, @fx_conversion_market INT = NULL
	, @bid_n_ask_price NCHAR(1) = NULL
	, @holiday_calendar INT = NULL
	, @collateral_amount NUMERIC(38, 20) = NULL
	, @collateral_req_per FLOAT = NULL
	, @collateral_months INT = NULL
	, @product_classification INT = NULL
	, @fas_deal_type_value_id INT = NULL
    , @match_type NCHAR(1) = NULL
	, @reporting_tier_id INT = NULL
	, @reporting_jurisdiction_id INT = NULL
	, @reporting_group1 NVARCHAR(1000) = NULL 
	, @reporting_group2 NVARCHAR(1000) = NULL 
	, @reporting_group3 NVARCHAR(1000) = NULL 
	, @reporting_group4 NVARCHAR(1000) = NULL 
	, @reporting_group5 NVARCHAR(1000) = NULL 

AS
/*----------------------------------------------test ------------------------------------------------------*/
/*
  declare 
  	@flag NCHAR(1),
		@template_id INT ,
		@template_name AS NVARCHAR(50),
		@physical_financial_flag AS NCHAR(1),
		@term_frequency_value AS NCHAR(1) ,
		@term_frequency_type AS NCHAR(1) ,
		@option_flag AS NCHAR(1)  ,
		@option_type AS NCHAR(1)  ,
		@option_exercise_type AS NCHAR(1)  ,
		@description1 NVARCHAR(50) ,
		@description2 NVARCHAR(50) ,
		@description3 NVARCHAR(50) ,
		@buy_sell_flag NCHAR(1)  ,
		@source_deal_type_id INT  ,
		@deal_sub_type_type_id INT  ,
		@is_active NCHAR(1) ,
		@internal_flag NCHAR(1),
		@internal_deal_type_value_id INT,
		@internal_deal_subtype_value_id INT,
		@allow_edit_term NCHAR(1),
		@blotter_support NCHAR(1),
		@rollover_to_spot NCHAR(1),
		@discounting_applies NCHAR(1),
		@term_end_flag NCHAR(1),
		@is_public NCHAR(1) ,
		@deal_status INT,
		@deal_category_value_id INT,
		@legal_entity INT,
		@commodity_id INT,
		@internal_portfolio_id INT,
		@product_id INT,
		@internal_desk_id INT,
		@blocktypecombo INT,
		@blockdefinitioncombo INT,
		@granularitycombo INT,
		@price INT,
		@model_id INT,
		@comments NCHAR(1),
		@trade_ticket_template NCHAR(1) ,
		@hourly_position_breakdown NCHAR(1) ,
		@counterparty_id INT ,
		@contract_id INT ,
		@fieldTemplateId INT ,
		@trader_id INT,
		@source_deal_header_id INT ,
		@source_system_id INT ,
		@deal_id NVARCHAR(50) ,
		@deal_date DateTime ,
		@ext_deal_id NVARCHAR(50) ,
		@structured_deal_id NVARCHAR(50) ,
		@entire_term_start DateTime ,
		@entire_term_end DateTime ,
		@option_excercise_type NCHAR(1) ,		
		@broker_id INT ,
		@generator_id INT ,
		@status_value_id INT ,
		@status_date DateTime ,
		@assignment_type_value_id INT ,
		@compliance_year INT ,
		@state_value_id INT ,
		@assigned_date DateTime ,
		@assigned_by NVARCHAR(50) ,
		@generation_source NVARCHAR(250) ,
		@aggregate_environment NVARCHAR(1) ,
		@aggregate_envrionment_comment NVARCHAR(250) ,
		@rec_price FLOAT ,
		@rec_formula_id INT ,
		@rolling_avg NCHAR(1) ,
		@reference NVARCHAR(250) ,
		@deal_locked NCHAR(1) ,
		@close_reference_id INT ,
		@deal_reference_type_id INT ,
		@unit_fixed_flag NCHAR ,
		@broker_unit_fees FLOAT ,
		@broker_fixed_cost FLOAT ,
		@broker_currency_id INT ,
		@term_frequency NCHAR(1) ,
		@option_settlement_date DateTime ,
		@verified_by NVARCHAR(50) ,
		@verified_date DateTime ,
		@risk_sign_off_by NVARCHAR(50) ,
		@risk_sign_off_date DateTime ,
		@back_office_sign_off_by NVARCHAR(50) ,
		@back_office_sign_off_date DateTime ,
		@book_transfer_id INT ,
		@confirm_status_type INT ,
		@udf_field NVARCHAR(max) ,
		@udf_value NVARCHAR(max) ,
		@deal_rules INT ,
		@confirm_rule INT ,
		@role_id INT   ,
		@batch_process_id NVARCHAR(250) ,
		@batch_report_param NVARCHAR(500) , 
		@enable_paging INT = 0,  --'1' = enable, '0' = disable
		@page_size INT ,
		@page_no INT 
		
		 set @flag = 'u' 
		set @template_id  = 1592 
		set @template_name  =  'Index Spread Option NG' 
		set @physical_financial_flag  = 'f' 
		set @term_frequency_value   = NULL 
		set @term_frequency_type   = 'm' 
		set @option_flag    = 'y' 
		set @option_type    = NULL 
		set @option_exercise_type    = NULL 
		set @description1  = NULL 
		set @description2  = NULL 
		set @description3  = NULL 
		set @buy_sell_flag   = 'b' 
		set @source_deal_type_id   = 1177 
		set @deal_sub_type_type_id   = NULL 
		set @is_active  = 'y' 
		set @internal_flag = NULL 
		set @internal_deal_type_value_id = 2 
		set @internal_deal_subtype_value_id = NULL 
		set @allow_edit_term = NULL 
		set @blotter_support = NULL 
		set @rollover_to_spot = NULL 
		set @discounting_applies = 'n' 
		set @term_end_flag = NULL 
		set @is_public  = 'n' 
		set @deal_status = NULL 
		set @deal_category_value_id = 475 
		set @legal_entity = NULL 
		set @commodity_id = 50 
		set @internal_portfolio_id = NULL 
		set @product_id = NULL 
		set @internal_desk_id = 17300 
		set @blocktypecombo = NULL 
		set @blockdefinitioncombo = NULL 
		set @granularitycombo = NULL 
		set @price = NULL 
		set @model_id = NULL 
		set @comments = NULL 
		set @trade_ticket_template  = NULL 
		set @hourly_position_breakdown  = '982' 
		set @counterparty_id  = 4300 
		set @contract_id  = 3739 
		set @fieldTemplateId  = 1293 
		set @trader_id = NULL 
		set @source_deal_header_id  = NULL 
		set @source_system_id  = 2 
		set @deal_id  = NULL 
		set @deal_date  = NULL 
		set @ext_deal_id  = NULL 
		set @structured_deal_id  = NULL 
		set @entire_term_start  = NULL 
		set @entire_term_end  = NULL 
		set @option_excercise_type  = NULL 		
		set @broker_id  = NULL 
		set @generator_id  = NULL 
		set @status_value_id  = NULL 
		set @status_date  = NULL 
		set @assignment_type_value_id  = NULL 
		set @compliance_year  = NULL 
		set @state_value_id  = NULL 
		set @assigned_date  = NULL 
		set @assigned_by  = NULL 
		set @generation_source  = NULL 
		set @aggregate_environment  = NULL 
		set @aggregate_envrionment_comment  = NULL 
		set @rec_price  = NULL 
		set @rec_formula_id  = NULL 
		set @rolling_avg  = NULL 
		set @reference  = NULL 
		set @deal_locked  = NULL 
		set @close_reference_id  = NULL 
		set @deal_reference_type_id  = 'n' 
		set @unit_fixed_flag  = NULL 
		set @broker_unit_fees  = NULL 
		set @broker_fixed_cost  = NULL 
		set @broker_currency_id  = NULL 
		set @term_frequency  = NULL 
		set @option_settlement_date  = NULL 
		set @verified_by  = NULL 
		set @verified_date  = NULL 
		set @risk_sign_off_by  = NULL 
		set @risk_sign_off_date  = NULL 
		set @back_office_sign_off_by  = NULL 
		set @back_office_sign_off_date  = NULL 
		set @book_transfer_id  = NULL 
		set @confirm_status_type  = NULL 
		set @udf_field  = NULL 
		set @udf_value  = 17200 

		set @deal_rules  = NULL 
		set @confirm_rule  = NULL 
		set @role_id    = NULL 
		
		set @batch_process_id  = '463F25C3_4597_4B64_9E98_553F441225C6' 
		set @batch_report_param  = NULL  
		set @enable_paging  = 1  --'1' = enable= NULL  '0' = disable
		set @page_size  = 27 
		set @page_no  =1
		
		/*
		drop table #tempUDFField
		drop table #t2
		drop table #tempUDFFieldValue
		*/

--*/
/*----------------------------------------------test ------------------------------------------------------*/
DECLARE @deal_temp_id INT

SET NOCOUNT ON

DECLARE @sql NVARCHAR(3000)
		,@msg_err NVARCHAR(2000)
DECLARE @stmt NVARCHAR(max)  
DECLARE @split_char NCHAR(1)  
DECLARE @db_user NVARCHAR(MAX)

SET @db_user = dbo.fnadbuser()

DECLARE @check_admin_role INT

SELECT @check_admin_role = ISNULL(dbo.FNAAppAdminRoleCheck(dbo.FNADBUser()), 0)


IF @flag = 'b'
BEGIN
	SELECT template_id, 
			template_name
	FROM source_deal_header_template sdht
	INNER JOIN source_deal_type sdt
		ON sdht.source_deal_type_id = sdt.source_deal_type_id
	WHERE deal_type_id like '%storage%'

	RETURN	
END

/*******************************************1st Paging Batch START**********************************************/
DECLARE @IntVariable INT;
DECLARE @SQLString NVARCHAR(MAX);
DECLARE @ParmDefinition NVARCHAR(MAX);
DECLARE @return NCHAR(1);

SET @IntVariable = 197;   

DECLARE @fields NVARCHAR(1000)
DECLARE @str_batch_table NVARCHAR (MAX)
DECLARE @user_login_id NVARCHAR (50)
DECLARE @sql_paging NVARCHAR (MAX)
DECLARE @is_batch BIT

SET @str_batch_table = ''
SET @user_login_id = dbo.FNADBUser() 
SET @is_batch = CASE 
		WHEN @batch_process_id IS NOT NULL
			AND @batch_report_param IS NOT NULL
			THEN 1
		ELSE 0
		END

IF @is_batch = 1
	SET @str_batch_table = ' INTO ' + dbo.FNAProcessTableName('batch_report', @user_login_id, @batch_process_id)
	
IF @enable_paging = 1 --paging processing
BEGIN
	IF @batch_process_id IS NULL
	SET @batch_process_id = dbo.FNAGetNewID ()
	
	SET @str_batch_table = dbo.FNAPagingProcess ('p', @batch_process_id, @page_size, @page_no)

	IF @page_no IS NOT NULL 
		BEGIN
			SET @sql_paging = dbo.FNAPagingProcess ('s', @batch_process_id, @page_size, @page_no) 
			EXEC spa_print @sql_paging
			EXEC (@sql_paging) 
			RETURN 
		END
END 

/*******************************************1st Paging Batch END**********************************************/
SET @split_char = '|'  
  
CREATE TABLE #tempUDFField (
	id INT IDENTITY(1, 1) NOT NULL
	,udf_field NVARCHAR(50) COLLATE DATABASE_DEFAULT
)
  
SELECT @stmt = 'insert into #tempUDFField select ''' + REPLACE(@udf_field, @split_char, ''' union all select ''')
SET @stmt = @stmt + ''''  
EXEC spa_print @stmt
EXEC (@stmt)  

UPDATE #tempUDFField
SET udf_field = REPLACE(udf_field, 'udf___', '')

SET @udf_value = REPLACE(@udf_value, '''', '''''')

CREATE TABLE #t2 (
	id INT IDENTITY(1, 1) NOT NULL
	,udf_value NVARCHAR(max) COLLATE DATABASE_DEFAULT
)

SELECT @stmt = 'insert into #t2 select ''' + REPLACE(ISNULL(@udf_value, 'NULL'), @split_char, ''' union all select ''')
SET @stmt = @stmt + ''''  
EXEC spa_print @stmt
EXEC (@stmt)

SELECT t.udf_field
	,NULLIF(t2.udf_value, 'NULL') udf_value
INTO #tempUDFFieldValue
FROM #tempUDFField t
INNER JOIN #t2 t2 ON t.id = t2.id

IF @flag='s' -- show role based templates
BEGIN
	DECLARE @sql_stmt NVARCHAR(max)

	SET @sql_stmt = 
		'SELECT DISTINCT a.template_id as [Template ID],
							dbo.FNAHyperLinkText2(10101400,  a.template_name , a.template_id,source_deal_type.source_system_id) AS [Template Name],
							case when  	a.physical_financial_flag =''p'' then ''Physical''	else ''Financial''	End	as [Physical/Financial]
							,Case when a.term_frequency_type =''m'' then ''Monthly'' when a.term_frequency_type =''q'' then ''Quarterly''    
										when a.term_frequency_type =''h'' then ''Hourly''
									 when a.term_frequency_type =''s'' then ''Semi-Annually''
									 when a.term_frequency_type =''a'' then ''Annually'' else ''Daily''	End as [Frequency Type]
							, a.option_flag as [Option Flag],
							case when a.option_type =''p'' then ''Put''	 when a.option_type =''c'' then ''Call'' End as [Option Type],
							case when a.option_exercise_type =''a'' then ''American''	when a.option_exercise_type =''e'' then ''European'' End
							as [Exercise Type],
							a.description1 as Desc1,
							a.description2 as Desc2,a.Description3 as Desc3,
							case when a.header_buy_sell_flag =''b'' then ''Buy'' else ''Sell'' End
							as [Buy/Sell],source_deal_type.deal_type_id as [Deal Type],
							sdt1.source_deal_type_name [Deal Sub Type],
							a.is_active as Active, 
							a.internal_flag as [Internal Flag],
							a.internal_deal_type_value_id as [Internal Deal Type ID],
							a.internal_deal_subtype_value_id as [Internal Deal Sub Type ID],
							a.blotter_supported as [Blotter Supported],
							a.rollover_to_spot as [Rollover to spot],
							a.discounting_applies as [Discounting Does Not Applies],
							a .term_end_flag as [Donot show Term End],
							a.is_public as [Public],
							sdv.code [Block],
							sdv2.code [Block define],
							sdv3.code as [Granularity],
							sdv4.code as [Price],
							cfmt.model_name as [Model Name],
							CASE WHEN a.trade_ticket_template = ''t'' THEN ''Trade Ticket''
								 WHEN  a.trade_ticket_template = ''i'' THEN ''Trade Ticket Index Swap''
							END AS [Trade Ticket Template]
							,a.attribute_type
							,sdv_option.code
					FROM source_deal_header_template a 
					LEFT JOIN deal_template_privilages sdp ON sdp.deal_template_id = a.template_id
					LEFT OUTER JOIN source_deal_type ON a.source_deal_type_id = source_deal_type.source_deal_type_id
					LEFT OUTER JOIN static_data_value sdv ON a.block_type = sdv.value_id 
					LEFT OUTER JOIN static_data_value sdv2 ON a.block_define_id = sdv2.value_id 
					LEFT OUTER JOIN static_data_value sdv3 ON a.granularity_id = sdv3.value_id
					LEFT OUTER JOIN static_data_value sdv4 ON a.pricing = sdv4.value_id
					LEFT OUTER JOIN cash_flow_model_type cfmt ON a.model_id = cfmt.model_id					
					LEFT JOIN source_deal_type sdt1 ON sdt1.source_deal_type_id = a.deal_sub_type_type_id
					LEFT JOIN static_data_value sdv_option ON sdv_option.value_id = a.options_calc_method
					--INNER JOIN	deal_template_users dtu ON dtu.function_id  = a.template_id
					WHERE 1 = 1 '

	IF @fieldTemplateId IS NOT NULL
		SET @sql_stmt=@sql_stmt +' and  a.field_template_id='+CAST(@fieldTemplateId AS  NVARCHAR(20))
	
	IF @template_id IS NOT NULL
		SET @sql_stmt=@sql_stmt +' and  a.template_id='+CAST(@template_id AS  NVARCHAR(20))
	
	IF @template_name IS NOT NULL
		SET @sql_stmt=@sql_stmt +' and  a.template_name='''+@template_name +''''
		
	IF @source_deal_type_id IS NOT NULL
		SET @sql_stmt=@sql_stmt +' and  a.source_deal_type_id='+CAST(@source_deal_type_id AS  NVARCHAR(20))
	
	IF @deal_sub_type_type_id IS NOT NULL
		SET @sql_stmt=@sql_stmt +' and a.deal_sub_type_type_id='+CAST(@deal_sub_type_type_id AS  NVARCHAR(20)) 
	
	IF @is_active IS NOT NULL
		AND @source_deal_type_id IS NULL
		SET @sql_stmt=@sql_stmt +' and a.is_active='''+@is_active +''''
	
	IF @is_active IS NOT NULL
		AND @source_deal_type_id IS NOT NULL
		SET @sql_stmt=@sql_stmt +' and a.is_active='''+@is_active +''''

	IF @blotter_support = 'y'
		SET @sql_stmt=@sql_stmt +' and a.blotter_supported=''y'''
	
	IF @is_public = 'y'
		SET @sql_stmt=@sql_stmt +' and a.is_public=''y'''

	IF @trade_ticket_template IS NOT NULL
		SET @sql_stmt = @sql_stmt + ' AND a.trade_ticket_template = ''' + @trade_ticket_template + ''''
	
	IF @check_admin_role <> 1 -- does not have admin role
	BEGIN
		SET @sql_stmt = @sql_stmt + ' AND (sdp.user_id = dbo.FNADBUser() OR sdp.role_id IN (SELECT role_id FROM dbo.FNAGetUserRole(dbo.FNADBUser())) OR a.create_user = dbo.FNADBUser())'
	END

	SET @sql_stmt  ='SELECT c.* ' + @str_batch_table + ' FROM (' + @sql_stmt + ')c order by c.[Template ID] desc' 

	EXEC spa_print @sql_stmt
	EXEC(@sql_stmt)
END

IF @flag='y' --show all active templates
BEGIN
	SET @sql_stmt = 
		'select 
	a.template_id as TemplateID,
	dbo.FNAHyperLinkText2(10101400,  a.template_name , a.template_id,source_deal_type.source_system_id) AS TemplateName,
	case when  	a.physical_financial_flag =''p'' then ''Physical''	else ''Financial''	End	as PhysicalFinancialFlag
	,Case when a.term_frequency_type =''m'' then ''Monthly'' when a.term_frequency_type =''q'' then ''Quarterly''    
				when a.term_frequency_type =''h'' then ''Hourly''
		     when a.term_frequency_type =''s'' then ''Semi-Annually''
		     when a.term_frequency_type =''a'' then ''Annually'' else ''Daily''	End as FrequencyType
	, a.option_flag as OptionFlag,
	case when a.option_type =''p'' then ''Put''	 when a.option_type =''c'' then ''Call'' End as OptionType,
	case when a.option_exercise_type =''a'' then ''American''	when a.option_exercise_type =''e'' then ''European'' End
	as ExcerciseType,
	a.description1 as Desc1,
	a.description2 as Desc2,a.Description3 as Desc3,
	case when a.header_buy_sell_flag =''b'' then ''Buy'' else ''Sell'' End
	as BuySellFlag,source_deal_type.deal_type_id as DealType,a.deal_sub_type_type_id DealSubType,
	a.is_active as Active, a.internal_flag as InternalFlag,a.internal_deal_type_value_id as InternalDealTypeID,
	a.internal_deal_subtype_value_id as InternalDealSubTypeID,
	a.blotter_supported as BlotterSupported,
	a.rollover_to_spot as [Rollover to spot],
	a.discounting_applies as [Discounting Does Not Applies],
	a .term_end_flag as [Do not show term end],
	a.is_public as [Public],
	sdv.code [Block],
	sdv2.code [Block define],
--	a.block_type as [Block],
--	a.block_define_id as [Block define],
	sdv3.code as [Granularity],
	sdv4.code as [Price],
	cfmt.model_name as [Model Name],
	CASE WHEN a.trade_ticket_template = ''t'' THEN ''Trade Ticket''
		 WHEN  a.trade_ticket_template = ''i'' THEN ''Trade Ticket Index Swap''
	END AS [Trade Ticket Template]
	,a.attribute_type
	,NULLIF(a.options_calc_method,0)
	FROM         source_deal_header_template a 
	LEFT OUTER JOIN source_deal_type ON a.source_deal_type_id = source_deal_type.source_deal_type_id
	LEFT OUTER JOIN static_data_value sdv ON a.block_type = sdv.value_id 
	LEFT OUTER JOIN static_data_value sdv2 ON a.block_define_id = sdv2.value_id 
	LEFT OUTER JOIN static_data_value sdv3 ON a.granularity_id = sdv3.value_id
	LEFT OUTER JOIN static_data_value sdv4 ON a.pricing = sdv4.value_id
	LEFT OUTER JOIN cash_flow_model_type cfmt ON a.model_id = cfmt.model_id
	where 1 = 1'

--	 from source_deal_header_template 
	IF @source_deal_type_id IS NOT NULL
		SET @sql_stmt=@sql_stmt +' and  a.source_deal_type_id='+CAST(@source_deal_type_id AS  NVARCHAR(20))

	IF @deal_sub_type_type_id IS NOT NULL
	SET @sql_stmt=@sql_stmt +' and a.deal_sub_type_type_id='+CAST(@deal_sub_type_type_id AS  NVARCHAR(20)) 
	
	IF @is_active IS NOT NULL
		AND @source_deal_type_id IS NULL
		SET @sql_stmt=@sql_stmt +' and a.is_active='''+@is_active +''''

	IF @is_active IS NOT NULL
		AND @source_deal_type_id IS NOT NULL
		SET @sql_stmt=@sql_stmt +' and a.is_active='''+@is_active +''''

	IF @blotter_support = 'y'
		SET @sql_stmt=@sql_stmt +' and a.blotter_supported=''y'''
	
	IF @is_public = 'y'
		SET @sql_stmt=@sql_stmt +' and a.is_public=''y'''
	ELSE
		SET @sql_stmt=@sql_stmt +' and (a.is_public=''n'' or a.is_public is null)'

	IF @trade_ticket_template IS NOT NULL
		SET @sql_stmt = @sql_stmt + ' AND a.trade_ticket_template = ''' + @trade_ticket_template + ''''
		
	EXEC spa_print @sql_stmt

	EXEC(@sql_stmt)
END
ELSE IF @flag='a' 
BEGIN

	SET @user_login_id = dbo.FNADBUser()
	
	DECLARE @field_label AS NVARCHAR(MAX)
		,@sql_string NVARCHAR(max)

	SELECT @field_label = COALESCE(@field_label + ', ', '') + 'UDF___' + CAST(udft.udf_template_id AS NVARCHAR(10))
	FROM   user_defined_deal_fields_template_main uddft
	INNER  JOIN user_defined_fields_template udft ON udft.field_name = uddft.field_name
	WHERE  uddft.udf_type = 'h'
	       AND uddft.template_id = @template_id 

EXEC spa_print @field_label

	EXEC spa_print 'template_id'
		,@template_id

	EXEC spa_print '@field_label'
		,@field_label

	EXEC spa_print '@user_login_id'
		,@user_login_id
	
	SET @sql_string = '
	SELECT * INTO #temp_UDF
	FROM   (
	           SELECT uddft.template_id,
	                  ''UDF___'' + CAST(udft.udf_template_id AS NVARCHAR(10)) udf_template_id,	                  
	                  uddft.default_value default_value
	           FROM   user_defined_deal_fields_template_main uddft
	                  LEFT JOIN user_defined_fields_template udft
	                       ON  udft.field_name = uddft.field_name
	                  LEFT JOIN maintain_field_template_detail mftd
	                       ON  udft.udf_template_id = mftd.field_id
	                       AND mftd.udf_or_system = ''u''
	                  INNER JOIN source_deal_header_template sdht
	                       ON  sdht.template_id = uddft.template_id
	                       AND sdht.field_template_id = mftd.field_template_id
	           WHERE  uddft.udf_type = ''h''
	                  AND uddft.template_id = 
	                      ' + CAST(@template_id AS NVARCHAR(10)) + 
		'
	                  
	       ) AS a
	       PIVOT(
	           MAX(default_value) FOR udf_template_id IN (' + ISNULL(@field_label, ' non_exsisting_field_id ') + 
		')
	       ) AS b 

	
	SELECT a.template_id,
	       template_name,
	       physical_financial_flag,
	       term_frequency_value,
	       term_frequency_type,
	       option_flag,
	       option_type,
	       option_exercise_type,
	       description1,
	       description2,
	       description3,
	       header_buy_sell_flag [buy_sell_flag],
	       source_deal_type_id,
	       deal_sub_type_type_id,
	       is_active,
	       internal_flag,
	       internal_deal_type_value_id,
	       internal_deal_subtype_value_id,
	       internal_template_id,
	       a.create_user,
	       a.create_ts,
	       a.update_user,
	       a.update_ts,
	       allow_edit_term,
	       blotter_supported,
	       rollover_to_spot,
	       discounting_applies,
	       term_end_flag,
	       is_public,
	       deal_status,
	       deal_category_value_id,
	       legal_entity,
	       commodity_id,
	       internal_portfolio_id,
	       product_id,
	       internal_desk_id,
	       block_type,
	       block_define_id,
	       granularity_id,
	       Pricing,
	       make_comment_mandatory_on_save,
	       model_id,
	       comments,
	       trade_ticket_template,
	       hourly_position_breakdown,
	       field_template_id,
	       counterparty_id,
	       contract_id,
	       trader_id,
	       source_deal_header_id,
	       source_system_id,
	       deal_id,
	       dbo.FNAGetSQLStandardDate(deal_date) deal_date,
	       ext_deal_id,
	       structured_deal_id,
	       dbo.FNAGetSQLStandardDate(entire_term_start) entire_term_start,
	       dbo.FNAGetSQLStandardDate(entire_term_end) entire_term_end,
	       option_excercise_type,
	       broker_id,
	       generator_id,
	       status_value_id,
	       dbo.FNAGetSQLStandardDate(status_date) status_date,
	       assignment_type_value_id,
	       compliance_year,
	       state_value_id,
	       dbo.FNAGetSQLStandardDate(assigned_date) assigned_date,
	       assigned_by,
	       generation_source,
	       aggregate_environment,
	       aggregate_envrionment_comment,
	       rec_price,
	       rec_formula_id,
	       rolling_avg,
	       reference,
	       deal_locked,
	       close_reference_id,
	       deal_reference_type_id,
	       unit_fixed_flag,
	       broker_unit_fees,
	       broker_fixed_cost,
	       term_frequency,
	       dbo.FNAGetSQLStandardDate(option_settlement_date) option_settlement_date,
	       verified_by,
	       dbo.FNAGetSQLStandardDate(verified_date) verified_date,
	       risk_sign_off_by,
	       dbo.FNAGetSQLStandardDate(risk_sign_off_date) risk_sign_off_date,
	       back_office_sign_off_by,
	       dbo.FNAGetSQLStandardDate(back_office_sign_off_date) back_office_sign_off_date,
	       book_transfer_id,
	       confirm_status_type,
	       broker_currency_id,
	       deal_rules,
	       confirm_rule,
	       calculate_position_based_on_actual,
	       save_mtm_at_calculation_granularity,
	       timezone_id,
	       ignore_bom,
	       year,
	       month,
           certificate,
           counterparty_id2,
           trader_id2,
           scheduler,
			inco_terms,
			governing_law,
			sample_control,
			payment_term,
			payment_days,
			arbitration,
			counterparty2_trader,
			pricing_type,
			clearing_counterparty_id,
			underlying_options,
			confirmation_type,
			confirmation_template,
			sdr,
			tier_value_id,
			fx_conversion_market
	       ' 
		+ ISNULL(',' + @field_label, '') + '
	      	, CASE WHEN a.attribute_type = ''a'' THEN  45902 WHEN a.attribute_type = ''f'' THEN 45901 ELSE '''' END  attribute_type
			, NULLIF(a.options_calc_method,0) options_calc_method
            , bid_n_ask_price
			, match_type
			, product_classification
			, fas_deal_type_value_id
			, reporting_tier_id
			, reporting_jurisdiction_id
			, reporting_group1 
			, reporting_group2 
			, reporting_group3 
			, reporting_group4 
			, reporting_group5 

	FROM   source_deal_header_template a 
	LEFT JOIN #temp_UDF t
	ON a.template_id = t.template_id
	WHERE   a.template_id =' +  CAST(@template_id AS NVARCHAR(10)) 
	
	EXEC spa_print @sql_string

	EXEC (@sql_string)
END
ELSE IF @flag='i'
BEGIN
	-----------------------------------Start of Min and Max value validation-------------------------------------------------
	SELECT @template_name AS template_name
		,@physical_financial_flag AS physical_financial_flag
		,@term_frequency_value AS term_frequency_value
		,@term_frequency_type AS term_frequency_type
		,@option_flag AS option_flag
		,@option_type AS option_type
		,@option_exercise_type AS option_exercise_type
		,@description1 AS description1
		,@description2 AS description2
		,@description3 AS description3
		,@buy_sell_flag AS buy_sell_flag
		,@source_deal_type_id AS source_deal_type_id
		,@deal_sub_type_type_id AS deal_sub_type_type_id
		,@is_active AS is_active
		,'n' AS internal_flag
		,@internal_deal_type_value_id AS internal_deal_type_value_id
		,@internal_deal_subtype_value_id AS internal_deal_subtype_value_id
		,@allow_edit_term AS allow_edit_term
		,@blotter_support AS blotter_support
		,@rollover_to_spot AS rollover_to_spot
		,@discounting_applies AS discounting_applies
		,@term_end_flag AS term_end_flag
		,'n' AS is_public
		,@deal_status AS deal_status
		,@deal_category_value_id AS deal_category_value_id
		,@legal_entity AS legal_entity
		,@commodity_id AS commodity_id
		,@internal_portfolio_id AS internal_portfolio_id
		,@product_id AS product_id
		,@internal_desk_id AS internal_desk_id
		,@blocktypecombo AS blocktypecombo
		,@blockdefinitioncombo AS blockdefinitioncombo
		,@granularitycombo AS granularitycombo
		,@price AS price
		,@model_id AS model_id
		,@comments AS comments
		,@trade_ticket_template AS trade_ticket_template
		,@hourly_position_breakdown AS hourly_position_breakdown
		,@counterparty_id AS counterparty_id
		,@contract_id AS contract_id
		,@fieldTemplateId AS fieldTemplateId
		,@trader_id AS trader_id
		,@source_deal_header_id AS source_deal_header_id
		,@source_system_id AS source_system_id
		,@deal_id AS deal_id
		,@deal_date AS deal_date
		,@ext_deal_id AS ext_deal_id
		,@structured_deal_id AS structured_deal_id
		,@entire_term_start AS entire_term_start
		,@entire_term_end AS entire_term_end
		,@option_excercise_type AS option_excercise_type
		,@broker_id AS broker_id
		,@generator_id AS generator_id
		,@status_value_id AS status_value_id
		,@status_date AS status_date
		,@assignment_type_value_id AS assignment_type_value_id
		,@compliance_year AS compliance_year
		,@state_value_id AS state_value_id
		,@assigned_date AS assigned_date
		,@assigned_by AS assigned_by
		,@generation_source AS generation_source
		,@aggregate_environment AS aggregate_environment
		,@aggregate_envrionment_comment AS aggregate_envrionment_comment
		,@rec_price AS rec_price
		,@rec_formula_id AS rec_formula_id
		,@rolling_avg AS rolling_avg
		,@reference AS reference
		,@deal_locked AS deal_locked
		,@close_reference_id AS close_reference_id
		,@deal_reference_type_id AS deal_reference_type_id
		,@unit_fixed_flag AS unit_fixed_flag
		,@broker_unit_fees AS broker_unit_fees
		,@broker_fixed_cost AS broker_fixed_cost
		,@broker_currency_id AS broker_currency_id
		,@term_frequency AS term_frequency
		,@option_settlement_date AS option_settlement_date
		,@verified_by AS verified_by
		,@verified_date AS verified_date
		,@risk_sign_off_by AS risk_sign_off_by
		,@risk_sign_off_date AS risk_sign_off_date
		,@back_office_sign_off_by AS back_office_sign_off_by
		,@back_office_sign_off_date AS back_office_sign_off_date
		,@book_transfer_id AS book_transfer_id
		,@confirm_status_type AS confirm_status_type
		,@deal_rules AS deal_rules
		,@confirm_rule AS confirm_rule
		,@calculate_position_based_on_actual AS calculate_position_based_on_actual
		,@timezone_id AS timezone_id
		,@ignore_bom AS ignore_bom
		,@year AS [year]
		,@month AS [month]
		,@certificate AS [certificate]
		,@counterparty_id2 AS [counterparty_id2]
		,@trader_id2 AS [trader_id2]
		,@scheduler AS [scheduler]
		,@inco_terms AS [inco_terms]
		,@governing_law AS [governing_law]
		,@sample_control AS [sample_control]
		,@payment_term AS [payment_term]
		,@payment_days AS [payment_days]
		,@arbitration AS [arbitration]
		,@counterparty2_trader AS [counterparty2_trader]
		,@pricing_type AS [pricing_type]
		,@clearing_counterparty_id AS [clearing_counterparty_id]
		,@underlying_options AS [underlying_options]
		,@confirmation_type AS [confirmation_type]
		,@confirmation_template AS [confirmation_template]
		,@sdr AS [sdr]
		,@tier_value_id AS [tier_value_id]
		,@fx_conversion_market AS [fx_conversion_market]
		,CASE 
			WHEN @attribute_type = '45902'
				THEN 'a'
			WHEN @attribute_type = '45901'
				THEN 'f'
			ELSE ''
			END AS [attribute_type]
		, NULLIF(@options_calc_method, 0) AS [options_calc_method]
		, @bid_n_ask_price AS [bid_n_ask_price]
		, @holiday_calendar AS [holiday_calendar]
		, @collateral_amount AS [collateral_amount]
		, @collateral_req_per AS [collateral_req_per]
		, @collateral_months AS [collateral_months]
		, @product_classification AS [product_classification]
		, @fas_deal_type_value_id AS [fas_deal_type_value_id]
        , @match_type AS [match_type]
		, @reporting_tier_id AS [reporting_tier_id]
		, @reporting_jurisdiction_id AS [reporting_jurisdiction_id]
		, @reporting_group1 AS [reporting_group1]
		, @reporting_group2 AS [reporting_group2]
		, @reporting_group3 AS [reporting_group3]
		, @reporting_group4 AS [reporting_group4]
		, @reporting_group5 AS [reporting_group5]
	INTO #temp_sdht
	
	SELECT @fields = COALESCE(@fields + ',', ' ') + cast(mfd.farrms_field_id AS NVARCHAR(30))
FROM   maintain_field_template_detail mftd
	INNER JOIN maintain_field_deal mfd ON mftd.field_id = mfd.field_id
            AND mftd.udf_or_system = 's'
            AND mfd.header_detail = 'h'
WHERE  mftd.field_template_id = @fieldTemplateId
		AND (
			NULLIF(mftd.min_value, 0) IS NOT NULL
			OR NULLIF(mftd.max_value, 0) IS NOT NULL
			)

SET @SQLString =  '
			DECLARE @error_field NVARCHAR(100)
			DECLARE @min_value FLOAT
			DECLARE @max_value FLOAT
			DECLARE @msg NVARCHAR(1000)
			
			SELECT @error_field = mfd.default_label,
					@min_value = mftd.min_value,
					@max_value = mftd.max_value
			FROM   maintain_field_template_detail mftd
			       INNER JOIN maintain_field_deal mfd
			            ON  mftd.field_id = mfd.field_id
			            AND mftd.udf_or_system = ''s''
			            AND mfd.header_detail = ''h''
			       INNER JOIN (
			                SELECT ' +  @fields + '
			                FROM   #temp_sdht
			            )p
			            UNPIVOT(col_value FOR field IN (' +  @fields + ')) AS 
			            unpvt
			            ON  unpvt.field = mfd.farrms_field_id
			            AND (
			                    unpvt.col_value < mftd.min_value
			                    OR unpvt.col_value > mftd.max_value
			                )
			WHERE  mftd.field_template_id = ' + CAST(@fieldTemplateId AS NVARCHAR(10)) + 
		'
			       AND (mftd.min_value IS NOT NULL OR mftd.max_value IS NOT NULL)
			
			IF @error_field IS NOT NULL 
				SET @msg = ''The value for '' + cast(@error_field as NVARCHAR(100)) + '' should be between '' + cast(@min_value as NVARCHAR(100)) + '' and '' + cast(@max_value as NVARCHAR(100)) + ''.'' 
			
			SET @max_titleOUT = 0
			IF  @msg IS NOT NULL 
			BEGIN
				EXEC spa_ErrorHandler -1, ''Error'', 
								''spa_InsertDealXmlBlotter'', ''DB Error'', 
								@msg, @msg						
				
				SET @max_titleOUT = 1	
			END
		
   '
	SET @ParmDefinition = N'@level tinyint, @max_titleOUT NVARCHAR(30) OUTPUT';

EXEC spa_print '---------------------------------------------------------------------------------------'

	EXECUTE sp_executesql @SQLString
		,@ParmDefinition
		,@level = @IntVariable
		,@max_titleOUT = @return OUTPUT;

--Return if column value is not between min and max value
IF @return = 1
    RETURN 

-----------------------------------End of Min and Max value validation-------------------------------------------------
	IF EXISTS (
			SELECT 'x'
			FROM source_deal_header_template
			WHERE template_name = @template_name
			)
	BEGIN
		EXEC spa_ErrorHandler - 1
			,'Source Deal Header Template'
			,'spa_source_deal_header_template'
			,'DB Error'
			,'Template with same name already exists.'
			,''

		RETURN 		
	END

	SELECT udf.udf_template_id
	,udf.field_name
	,udf.Field_label
	,udf.Field_type
	,udf.data_type
	,udf.is_required
	,ISNULL(NULLIF(udf.sql_string, ''), uds.sql_string) sql_string
	,udf.create_user
	,udf.create_ts
	,udf.update_user
	,udf.update_ts
	,udf.udf_type
	,udf.field_size
	,udf.field_id
	,tufv.udf_value [default_value]
	,udf.book_id
	,udf.udf_group
	,udf.udf_tabgroup
	,udf.formula_id
	,udf.internal_field_type
		,udf.leg
	INTO #tempUDF
	FROM #tempUDFFieldValue tufv
	INNER JOIN user_defined_fields_template udf ON udf.udf_template_id = tufv.udf_field
	LEFT JOIN udf_data_source uds ON uds.udf_data_source_id = udf.data_source_type_id

	INSERT INTO source_deal_header_template (
		template_name
		,physical_financial_flag
		,term_frequency_value
		,term_frequency_type
		,option_flag
		,option_type
		,option_exercise_type
		,description1
		,description2
		,description3
		,header_buy_sell_flag
		,source_deal_type_id
		,deal_sub_type_type_id
		,is_active
		,internal_flag
		,internal_deal_type_value_id
		,internal_deal_subtype_value_id
		,allow_edit_term
		,blotter_supported
		,rollover_to_spot
		,discounting_applies
		,term_end_flag
		,is_public
		,Deal_Status
		,deal_category_value_id
		,legal_entity
		,commodity_id
		,internal_portfolio_id
		,product_id
		,internal_desk_id
		,block_type
		,block_define_id
		,granularity_id
		,Pricing
		,model_id
		,comments
		,trade_ticket_template
		,hourly_position_breakdown
		,counterparty_id
		,contract_id
		,field_template_id
		,trader_id
		,source_deal_header_id
		,source_system_id
		,Deal_ID
		,deal_date
		,ext_deal_id
		,structured_deal_id
		,entire_term_start
		,entire_term_end
		,option_excercise_type
		,broker_id
		,generator_id
		,status_value_id
		,status_date
		,assignment_type_value_id
		,compliance_year
		,state_value_id
		,assigned_date
		,assigned_by
		,generation_source
		,aggregate_environment
		,aggregate_envrionment_comment
		,rec_price
		,rec_formula_id
		,rolling_avg
		,reference
		,deal_locked
		,close_reference_id
		,deal_reference_type_id
		,unit_fixed_flag
		,broker_unit_fees
		,broker_fixed_cost
		,broker_currency_id
		,term_frequency
		,option_settlement_date
		,verified_by
		,verified_date
		,risk_sign_off_by
		,risk_sign_off_date
		,back_office_sign_off_by
		,back_office_sign_off_date
		,book_transfer_id
		,confirm_status_type
		,deal_rules
		,confirm_rule
		,calculate_position_based_on_actual
		,save_mtm_at_calculation_granularity
		,timezone_id
		,ignore_bom
		,[year]
		,[month]
		,[certificate]
		,counterparty_id2
		,trader_id2
		,scheduler
		,inco_terms
		,governing_law
		,sample_control
		,payment_term
		,payment_days
		,arbitration
		,counterparty2_trader
		,attribute_type
		,options_calc_method
		,pricing_type
		,clearing_counterparty_id
		,underlying_options
		,confirmation_type
		,confirmation_template
		,sdr
		,tier_value_id
		,fx_conversion_market
		,bid_n_ask_price
		,holiday_calendar
		,collateral_amount
		,collateral_req_per
		,collateral_months
		,product_classification
		,fas_deal_type_value_id
        ,match_type
		,reporting_tier_id
		,reporting_jurisdiction_id
		, reporting_group1
		, reporting_group2
		, reporting_group3
		, reporting_group4
		, reporting_group5
	  )
	VALUES (
		@template_name
		,@physical_financial_flag
		,@term_frequency_value
		,@term_frequency_type
		,@option_flag
		,@option_type
		,@option_exercise_type
		,@description1
		,@description2
		,@description3
		,@buy_sell_flag
		,@source_deal_type_id
		,@deal_sub_type_type_id
		,@is_active
		,'n'
		,@internal_deal_type_value_id
		,@internal_deal_subtype_value_id
		,@allow_edit_term
		,@blotter_support
		,@rollover_to_spot
		,@discounting_applies
		,@term_end_flag
		,'n'
		,@deal_status
		,@deal_category_value_id
		,@legal_entity
		,@commodity_id
		,@internal_portfolio_id
		,@product_id
		,@internal_desk_id
		,@blocktypecombo
		,@blockdefinitioncombo
		,@granularitycombo
		,@price
		,@model_id
		,@comments
		,@trade_ticket_template
		,@hourly_position_breakdown
		,@counterparty_id
		,@contract_id
		,@fieldTemplateId
		,@trader_id
		,@source_deal_header_id
		,@source_system_id
		,@deal_id
		,@deal_date
		,@ext_deal_id
		,@structured_deal_id
		,@entire_term_start
		,@entire_term_end
		,@option_excercise_type
		,@broker_id
		,@generator_id
		,@status_value_id
		,@status_date
		,@assignment_type_value_id
		,@compliance_year
		,@state_value_id
		,@assigned_date
		,@assigned_by
		,@generation_source
		,@aggregate_environment
		,@aggregate_envrionment_comment
		,@rec_price
		,@rec_formula_id
		,@rolling_avg
		,@reference
		,@deal_locked
		,@close_reference_id
		,@deal_reference_type_id
		,@unit_fixed_flag
		,@broker_unit_fees
		,@broker_fixed_cost
		,@broker_currency_id
		,@term_frequency
		,@option_settlement_date
		,@verified_by
		,@verified_date
		,@risk_sign_off_by
		,@risk_sign_off_date
		,@back_office_sign_off_by
		,@back_office_sign_off_date
		,@book_transfer_id
		,@confirm_status_type
		,@deal_rules
		,@confirm_rule
		,@calculate_position_based_on_actual
		,@save_mtm_at_calculation_granularity
		,@timezone_id
		,@ignore_bom
		,@year
		,@month
		,@certificate
		,@counterparty_id2
		,@trader_id2
		,@scheduler
		,@inco_terms
		,@governing_law
		,@sample_control
		,@payment_term
		,@payment_days
		,@arbitration
		,@counterparty2_trader
		,CASE 
			WHEN @attribute_type = '45902'
				THEN 'a'
			WHEN @attribute_type = '45901'
				THEN 'f'
			ELSE ''
			END
		,NULLIF(@options_calc_method, 0)
		,@pricing_type
		,@clearing_counterparty_id
		,@underlying_options
		,@confirmation_type
		,@confirmation_template
		,@sdr
		,@tier_value_id
		,@fx_conversion_market
		,@bid_n_ask_price
		,@holiday_calendar
		,@collateral_amount
		,@collateral_req_per
		,@collateral_months
		,@product_classification
		,@fas_deal_type_value_id
        ,@match_type
		,@reporting_tier_id
		,@reporting_jurisdiction_id
		, @reporting_group1
		, @reporting_group2
		, @reporting_group3
		, @reporting_group4
		, @reporting_group5
	  )
	
	SET @deal_temp_id=SCOPE_IDENTITY()

	INSERT INTO user_defined_deal_fields_template_main (
		field_name
		,Field_label
		,Field_type
		,data_type
		,is_required
		,sql_string
		,udf_type
		,field_size
		,field_id
		,default_value
		,udf_group
		,udf_tabgroup
		,formula_id
		,template_id
		,udf_user_field_id
		,leg
				)
	SELECT field_name
		,Field_label
		,Field_type
		,data_type
		,is_required
		,sql_string
		,udf_type
		,field_size
		,field_id
		,default_value
		,udf_group
		,udf_tabgroup
		,formula_id
		,@deal_temp_id
		,udf_template_id
		,leg
			FROM  #tempUDF
						
	IF @@ERROR <> 0
		EXEC spa_ErrorHandler @@ERROR
			,'Source Deal Header Template'
			,'spa_source_deal_header_template'
			,'DB Error'
			,'Failed to Insert the new Source Deal Header Template.'
			,''
	ELSE
		EXEC spa_ErrorHandler 0
			,'Source Deal Header Template'
			,'spa_source_deal_header_template'
			,'Success'
			,'New Source Deal Header Template is successfully Inserted.'
			,@deal_temp_id
END
ELSE IF @flag='u'
BEGIN
		-----------------------------------Start of Min and Max value validation-------------------------------------------------
	SELECT @template_name AS template_name
		, @physical_financial_flag AS physical_financial_flag
		, @term_frequency_value AS term_frequency_value
		, @term_frequency_type AS term_frequency_type
		, @option_flag AS option_flag
		, @option_type AS option_type
		, @option_exercise_type AS option_exercise_type
		, @description1 AS description1
		, @description2 AS description2
		, @description3 AS description3
		, @buy_sell_flag AS buy_sell_flag
		, @source_deal_type_id AS source_deal_type_id
		, @deal_sub_type_type_id AS deal_sub_type_type_id
		, @is_active AS is_active
		, 'n' AS internal_flag
		, @internal_deal_type_value_id AS internal_deal_type_value_id
		, @internal_deal_subtype_value_id AS internal_deal_subtype_value_id
		, @allow_edit_term AS allow_edit_term
		, @blotter_support AS blotter_support
		, @rollover_to_spot AS rollover_to_spot
		, @discounting_applies AS discounting_applies
		, @term_end_flag AS term_end_flag
		, 'n' AS is_public
		, @deal_status AS deal_status
		, @deal_category_value_id AS deal_category_value_id
		, @legal_entity AS legal_entity
		, @commodity_id AS commodity_id
		, @internal_portfolio_id AS internal_portfolio_id
		, @product_id AS product_id
		, @internal_desk_id AS internal_desk_id
		, @blocktypecombo AS blocktypecombo
		, @blockdefinitioncombo AS blockdefinitioncombo
		, @granularitycombo AS granularitycombo
		, @price AS price
		, @model_id AS model_id
		, @comments AS comments
		, @trade_ticket_template AS trade_ticket_template
		, @hourly_position_breakdown AS hourly_position_breakdown
		, @counterparty_id AS counterparty_id
		, @contract_id AS contract_id
		, @fieldTemplateId AS fieldTemplateId
		, @trader_id AS trader_id
		, @source_deal_header_id AS source_deal_header_id
		, @source_system_id AS source_system_id
		, @deal_id AS deal_id
		, @deal_date AS deal_date
		, @ext_deal_id AS ext_deal_id
		, @structured_deal_id AS structured_deal_id
		, @entire_term_start AS entire_term_start
		, @entire_term_end AS entire_term_end
		, @option_excercise_type AS option_excercise_type
		, @broker_id AS broker_id
		, @generator_id AS generator_id
		, @status_value_id AS status_value_id
		, @status_date AS status_date
		, @assignment_type_value_id AS assignment_type_value_id
		, @compliance_year AS compliance_year
		, @state_value_id AS state_value_id
		, @assigned_date AS assigned_date
		, @assigned_by AS assigned_by
		, @generation_source AS generation_source
		, @aggregate_environment AS aggregate_environment
		, @aggregate_envrionment_comment AS aggregate_envrionment_comment
		, @rec_price AS rec_price
		, @rec_formula_id AS rec_formula_id
		, @rolling_avg AS rolling_avg
		, @reference AS reference
		, @deal_locked AS deal_locked
		, @close_reference_id AS close_reference_id
		, @deal_reference_type_id AS deal_reference_type_id
		, @unit_fixed_flag AS unit_fixed_flag
		, @broker_unit_fees AS broker_unit_fees
		, @broker_fixed_cost AS broker_fixed_cost
		, @broker_currency_id AS broker_currency_id
		, @term_frequency AS term_frequency
		, @option_settlement_date AS option_settlement_date
		, @verified_by AS verified_by
		, @verified_date AS verified_date
		, @risk_sign_off_by AS risk_sign_off_by
		, @risk_sign_off_date AS risk_sign_off_date
		, @back_office_sign_off_by AS back_office_sign_off_by
		, @back_office_sign_off_date AS back_office_sign_off_date
		, @book_transfer_id AS book_transfer_id
		, @confirm_status_type AS confirm_status_type
		, @deal_rules AS deal_rules
		, @confirm_rule AS confirm_rule
		, @calculate_position_based_on_actual AS calculate_position_based_on_actual
		, @timezone_id AS timezone_id
		, @ignore_bom AS ignore_bom
		, @year AS [year]
		, @month AS [month]
		, @certificate AS [certificate]
		, @counterparty_id2 AS [counterparty_id2]
		, @trader_id2 AS [trader_id2]
		, @scheduler AS [scheduler]
		, @inco_terms AS [inco_terms]
		, @governing_law AS [governing_law]
		, @sample_control AS [sample_control]
		, @payment_term AS [payment_term]
		, @payment_days AS payment_days
		, @arbitration AS [arbitration]
		, @counterparty2_trader AS [counterparty2_trader]
		, NULLIF(@options_calc_method, 0) AS options_calc_method
		, @attribute_type AS attribute_type
		, @pricing_type AS [pricing_type]
		, @clearing_counterparty_id AS [clearing_counterparty_id]
		, @underlying_options AS [underlying_options]
		, @confirmation_type AS [confirmation_type]
		, @confirmation_template AS [confirmation_template]
		, @sdr AS [sdr]
		, @fx_conversion_market AS [fx_conversion_market]
		, @bid_n_ask_price AS [bid_n_ask_price]
		, @holiday_calendar AS [holiday_calendar]
		, @collateral_amount AS [collateral_amount]
		, @collateral_req_per AS [collateral_req_per]
		, @collateral_months AS [collateral_months]
		, @product_classification AS [product_classification]
		, @fas_deal_type_value_id AS [fas_deal_type_value_id]
        , @match_type AS [match_type]
		, @reporting_tier_id AS [reporting_tier_id]
		, @reporting_jurisdiction_id AS [reporting_jurisdiction_id]
		, @reporting_group1	AS reporting_group1
		, @reporting_group2	AS reporting_group2
		, @reporting_group3	AS reporting_group3
		, @reporting_group4	AS reporting_group4
		, @reporting_group5	AS reporting_group5
	INTO #temp_sdhtu
	
	SELECT @fields = COALESCE(@fields + ',', ' ') + cast(mfd.farrms_field_id AS NVARCHAR(30))
FROM   maintain_field_template_detail mftd
	INNER JOIN maintain_field_deal mfd ON mftd.field_id = mfd.field_id
            AND mftd.udf_or_system = 's'
            AND mfd.header_detail = 'h'
WHERE  mftd.field_template_id = @fieldTemplateId
		AND (
			NULLIF(mftd.min_value, 0) IS NOT NULL
			OR NULLIF(mftd.max_value, 0) IS NOT NULL
			)

SET @SQLString =  '
			DECLARE @error_field NVARCHAR(100)
			DECLARE @min_value FLOAT
			DECLARE @max_value FLOAT
			DECLARE @msg NVARCHAR(1000)
			
			SELECT @error_field = mfd.default_label,
					@min_value = mftd.min_value,
					@max_value = mftd.max_value
			FROM   maintain_field_template_detail mftd
			       INNER JOIN maintain_field_deal mfd
			            ON  mftd.field_id = mfd.field_id
			            AND mftd.udf_or_system = ''s''
			            AND mfd.header_detail = ''h''
			       INNER JOIN (
			                SELECT ' +  @fields + '
			                FROM  #temp_sdhtu
			            )p
			            UNPIVOT(col_value FOR field IN (' +  @fields + ')) AS 
			            unpvt
			            ON  unpvt.field = mfd.farrms_field_id
			            AND (
			                    unpvt.col_value < mftd.min_value
			                    OR unpvt.col_value > mftd.max_value
			                )
			WHERE  mftd.field_template_id = ' + CAST(@fieldTemplateId AS NVARCHAR(10)) + 
		'
			       AND (mftd.min_value IS NOT NULL OR mftd.max_value IS NOT NULL)
			
			IF @error_field IS NOT NULL 
				SET @msg = ''The value for '' + cast(@error_field as NVARCHAR(100)) + '' should be between '' + cast(@min_value as NVARCHAR(100)) + '' and '' + cast(@max_value as NVARCHAR(100)) + ''.'' 
			
			SET @max_titleOUT = 0
			IF  @msg IS NOT NULL 
			BEGIN
				EXEC spa_ErrorHandler -1, ''Error'', 
								''spa_InsertDealXmlBlotter'', ''DB Error'', 
								@msg, @msg						
				
				SET @max_titleOUT = 1	
			END
		
   '
	SET @ParmDefinition = N'@level tinyint, @max_titleOUT NVARCHAR(30) OUTPUT';

EXEC spa_print '---------------------------------------------------------------------------------------'

	EXECUTE sp_executesql @SQLString
		,@ParmDefinition
		,@level = @IntVariable
		,@max_titleOUT = @return OUTPUT;

--Return if column value is not between min and max value
IF @return = 1
    RETURN 

-----------------------------------End of Min and Max value validation-------------------------------------------------
	IF EXISTS (
			SELECT 'x'
			FROM source_deal_header_template
			WHERE template_name = @template_name
				AND template_id <> @template_id
			)
	BEGIN
		EXEC spa_ErrorHandler - 1
			,'Source Deal Header Template'
			,'spa_source_deal_header_template'
			,'DB Error'
			,'Template with same name already exists.'
			,''

		RETURN 
	END	
	
	UPDATE source_deal_header_template
	SET template_name = @template_name
		,physical_financial_flag = @physical_financial_flag
		,term_frequency_value = @term_frequency_value
		,term_frequency_type = @term_frequency_type
		,option_flag = @option_flag
		,option_type = @option_type
		,option_exercise_type = @option_exercise_type
		,description1 = @description1
		,description2 = @description2
		,description3 = @description3
		,header_buy_sell_flag = @buy_sell_flag
		,source_deal_type_id = @source_deal_type_id
		,deal_sub_type_type_id = @deal_sub_type_type_id
		,is_active = @is_active
		,internal_deal_type_value_id = @internal_deal_type_value_id
		,internal_deal_subtype_value_id = @internal_deal_subtype_value_id
		,allow_edit_term = @allow_edit_term
		,rollover_to_spot = @rollover_to_spot
		,discounting_applies = @discounting_applies
		,term_end_flag = @term_end_flag
		,is_public = @is_public
		,Deal_Status = @deal_status
		,deal_category_value_id = @deal_category_value_id
		,legal_entity = @legal_entity
		,commodity_id = @commodity_id
		,internal_portfolio_id = @internal_portfolio_id
		,product_id = @product_id
		,internal_desk_id = @internal_desk_id
		,block_type = @blocktypecombo
		,block_define_id = @blockdefinitioncombo
		,granularity_id = @granularitycombo
		,Pricing = @price
		,model_id = @model_id
		,comments = @comments
		,trade_ticket_template = @trade_ticket_template
		,hourly_position_breakdown = @hourly_position_breakdown
		,counterparty_id = @counterparty_id
		,contract_id = @contract_id
		,field_template_id = @fieldTemplateId
		,trader_id = @trader_id
		,source_deal_header_id = @source_deal_header_id
		,source_system_id = @source_system_id
		,Deal_ID = @deal_id
		,deal_date = @deal_date
		,ext_deal_id = @ext_deal_id
		,structured_deal_id = @structured_deal_id
		,entire_term_start = @entire_term_start
		,entire_term_end = @entire_term_end
		,option_excercise_type = @option_excercise_type
		,broker_id = @broker_id
		,generator_id = @generator_id
		,status_value_id = @status_value_id
		,status_date = @status_date
		,assignment_type_value_id = @assignment_type_value_id
		,compliance_year = @compliance_year
		,state_value_id = @state_value_id
		,assigned_date = @assigned_date
		,assigned_by = @assigned_by
		,generation_source = @generation_source
		,aggregate_environment = @aggregate_environment
		,aggregate_envrionment_comment = @aggregate_envrionment_comment
		,rec_price = @rec_price
		,rec_formula_id = @rec_formula_id
		,rolling_avg = @rolling_avg
		,reference = @reference
		,deal_locked = @deal_locked
		,close_reference_id = @close_reference_id
		,deal_reference_type_id = @deal_reference_type_id
		,unit_fixed_flag = @unit_fixed_flag
		,broker_unit_fees = @broker_unit_fees
		,broker_fixed_cost = @broker_fixed_cost
		,broker_currency_id = @broker_currency_id
		,term_frequency = @term_frequency
		,option_settlement_date = @option_settlement_date
		,verified_by = @verified_by
		,verified_date = @verified_date
		,risk_sign_off_by = @risk_sign_off_by
		,risk_sign_off_date = @risk_sign_off_date
		,back_office_sign_off_by = @back_office_sign_off_by
		,back_office_sign_off_date = @back_office_sign_off_date
		,book_transfer_id = @book_transfer_id
		,confirm_status_type = @confirm_status_type
		,deal_rules = @deal_rules
		,confirm_rule = @confirm_rule
		,calculate_position_based_on_actual = @calculate_position_based_on_actual
		,save_mtm_at_calculation_granularity = @save_mtm_at_calculation_granularity
		,timezone_id = @timezone_id
		,ignore_bom = @ignore_bom
		,[year] = @year
		,[month] = @month
		,[certificate] = @certificate
		,counterparty_id2 = @counterparty_id2
		,trader_id2 = @trader_id2
		,scheduler = @scheduler
		,inco_terms = @inco_terms
		,governing_law = @governing_law
		,sample_control = @sample_control
		,payment_term = @payment_term
		,payment_days = @payment_days
		,arbitration = @arbitration
		,counterparty2_trader = @counterparty2_trader
		,pricing_type = @pricing_type
		,clearing_counterparty_id = @clearing_counterparty_id
		,underlying_options = @underlying_options
		,confirmation_type = @confirmation_type
		,confirmation_template = @confirmation_template
		,sdr = @sdr
		,tier_value_id = @tier_value_id
		,fx_conversion_market = @fx_conversion_market
		,attribute_type = CASE 
			WHEN @attribute_type = '45902'
				THEN 'a'
			WHEN @attribute_type = '45901'
				THEN 'f'
			ELSE ''
			END
		, options_calc_method = @options_calc_method
		, bid_n_ask_price = @bid_n_ask_price
		, holiday_calendar = @holiday_calendar
		, collateral_amount = @collateral_amount
		, collateral_req_per = @collateral_req_per
		, collateral_months = @collateral_months
		, blotter_supported = @blotter_support
		, product_classification = @product_classification
		, fas_deal_type_value_id = @fas_deal_type_value_id
        , match_type = @match_type
		, reporting_tier_id = @reporting_tier_id
		, reporting_jurisdiction_id = @reporting_jurisdiction_id
		, reporting_group1 = @reporting_group1
		, reporting_group2 = @reporting_group2
		, reporting_group3 = @reporting_group3
		, reporting_group4 = @reporting_group4
		, reporting_group5 = @reporting_group5
	WHERE  template_id = @template_id

	UPDATE uddft
	SET uddft.default_value = t.udf_value	
	FROM user_defined_deal_fields_template_main uddft
	INNER JOIN #tempUDFFieldValue t ON uddft.udf_user_field_id = t.udf_field
	WHERE uddft.template_id = @template_id
	
SELECT udf.udf_template_id
	,udf.field_name
	,udf.Field_label
	,udf.Field_type
	,udf.data_type
	,udf.is_required
	,ISNULL(NULLIF(udf.sql_string, ''), uds.sql_string) sql_string
	,udf.create_user
	,udf.create_ts
	,udf.update_user
	,udf.update_ts
	,udf.udf_type
	,udf.field_size
	,udf.field_id
	,tufv.udf_value [default_value]
	,udf.book_id
	,udf.udf_group
	,udf.udf_tabgroup
	,udf.formula_id
		,udf.internal_field_type
	INTO #tempUDFUpdate
	FROM #tempUDFFieldValue tufv
	INNER JOIN user_defined_fields_template udf ON udf.udf_template_id = tufv.udf_field
	LEFT JOIN user_defined_deal_fields_template_main ut ON udf.field_name = ut.field_name
		AND ut.template_id = @template_id
	LEFT JOIN udf_data_source uds 
		ON uds.udf_data_source_id = udf.data_source_type_id
WHERE ut.udf_template_id IS NULL 
	
	IF @@ERROR <> 0
		EXEC spa_ErrorHandler @@ERROR
			,'Source Deal Header Template'
			,'spa_source_deal_header_template'
			,'DB Error'
			,'Failed to Update the  Source Deal Header Template.'
			,''
	ELSE
		EXEC spa_ErrorHandler 0
			,'Source Deal Header Template'
			,'spa_source_deal_header_template'
			,'Success'
			,'Source Deal Header Template is successfully Updated.'
			,''
	RETURN
END
ELSE IF @flag='d'
BEGIN
	IF NOT EXISTS (
			SELECT *
			FROM source_deal_header
			WHERE template_id = @template_id
			)
	BEGIN
		DELETE
		FROM user_defined_deal_fields_template_main
		WHERE  template_id = @template_id  		
		
		DELETE
		FROM source_deal_detail_template
		WHERE template_id = @template_id
 		
		DELETE
		FROM deal_transfer_mapping
		WHERE template_id = @template_id
 						
		DELETE
		FROM source_deal_header_template
		WHERE template_id = @template_id	
		
		EXEC spa_ErrorHandler 0
			,'Source Deal Header - Detail Template'
			,'spa_source_deal_header_template'
			,'Success'
			,'Selected Source Deal Template is successfully Deleted.'
			,''
	END
	ELSE
		EXEC spa_ErrorHandler - 1
			,'The selected template cannot be deleted.'
			,'spa_source_deal_header_template'
			,'DB Error'
			,'Source Deal Detail Template can not be deleted, it is used'
			,''
		
END
ELSE IF @flag='c'
BEGIN
	BEGIN TRANSACTION

	INSERT INTO source_deal_header_template (
		template_name
		,physical_financial_flag
		,term_frequency_value
		,term_frequency_type
		,option_flag
		,option_type
		,option_exercise_type
		,description1
		,description2
		,description3
		,header_buy_sell_flag
		,source_deal_type_id
		,deal_sub_type_type_id
		,is_active
		,internal_flag
		,internal_deal_type_value_id
		,internal_deal_subtype_value_id
		,internal_template_id
		,allow_edit_term
		,blotter_supported
		,rollover_to_spot
		,discounting_applies
		,term_end_flag
		,is_public
		,deal_status
		,deal_category_value_id
		,legal_entity
		,commodity_id
		,internal_portfolio_id
		,product_id
		,internal_desk_id
		,block_type
		,block_define_id
		,granularity_id
		,Pricing
		,make_comment_mandatory_on_save
		,model_id
		,comments
		,trade_ticket_template
		,hourly_position_breakdown
		,contract_id
		,counterparty_id
		,deal_rules
		,confirm_rule
		,trader_id
		,source_deal_header_id
		,source_system_id
		,deal_id
		,deal_date
		,ext_deal_id
		,structured_deal_id
		,entire_term_start
		,entire_term_end
		,option_excercise_type
		,broker_id
		,generator_id
		,status_value_id
		,status_date
		,assignment_type_value_id
		,compliance_year
		,state_value_id
		,assigned_date
		,assigned_by
		,generation_source
		,aggregate_environment
		,aggregate_envrionment_comment
		,rec_price
		,rec_formula_id
		,rolling_avg
		,reference
		,deal_locked
		,close_reference_id
		,deal_reference_type_id
		,unit_fixed_flag
		,broker_unit_fees
		,broker_fixed_cost
		,broker_currency_id
		,term_frequency
		,option_settlement_date
		,verified_by
		,verified_date
		,risk_sign_off_by
		,risk_sign_off_date
		,back_office_sign_off_by
		,back_office_sign_off_date
		,book_transfer_id
		,confirm_status_type
		,field_template_id
		,timezone_id
		,attribute_type
		,options_calc_method
		,product_classification
		,fas_deal_type_value_id
        ,match_type
		,reporting_tier_id
		,reporting_jurisdiction_id
		, reporting_group1
		, reporting_group2
		, reporting_group3
		, reporting_group4
		, reporting_group5
	  )
	SELECT 'Copy of ' + template_name
		,physical_financial_flag
		,term_frequency_value
		,term_frequency_type
		,option_flag
		,option_type
		,option_exercise_type
		,description1
		,description2
		,description3
		,header_buy_sell_flag
		,source_deal_type_id
		,deal_sub_type_type_id
		,is_active
		,internal_flag
		,internal_deal_type_value_id
		,internal_deal_subtype_value_id
		,internal_template_id
		,allow_edit_term
		,blotter_supported
		,rollover_to_spot
		,discounting_applies
		,term_end_flag
		,is_public
		,deal_status
		,deal_category_value_id
		,legal_entity
		,commodity_id
		,internal_portfolio_id
		,product_id
		,internal_desk_id
		,block_type
		,block_define_id
		,granularity_id
		,Pricing
		,make_comment_mandatory_on_save
		,model_id
		,comments
		,trade_ticket_template
		,hourly_position_breakdown
		,contract_id
		,counterparty_id
		,deal_rules
		,confirm_rule
		,trader_id
		,source_deal_header_id
		,source_system_id
		,deal_id
		,deal_date
		,ext_deal_id
		,structured_deal_id
		,entire_term_start
		,entire_term_end
		,option_excercise_type
		,broker_id
		,generator_id
		,status_value_id
		,status_date
		,assignment_type_value_id
		,compliance_year
		,state_value_id
		,assigned_date
		,assigned_by
		,generation_source
		,aggregate_environment
		,aggregate_envrionment_comment
		,rec_price
		,rec_formula_id
		,rolling_avg
		,reference
		,deal_locked
		,close_reference_id
		,deal_reference_type_id
		,unit_fixed_flag
		,broker_unit_fees
		,broker_fixed_cost
		,broker_currency_id
		,term_frequency
		,option_settlement_date
		,verified_by
		,verified_date
		,risk_sign_off_by
		,risk_sign_off_date
		,back_office_sign_off_by
		,back_office_sign_off_date
		,book_transfer_id
		,confirm_status_type
		,field_template_id
		,timezone_id
		,attribute_type
		,options_calc_method
		,product_classification
		,fas_deal_type_value_id
        ,match_type
		,reporting_tier_id
		,reporting_jurisdiction_id
		, reporting_group1
		, reporting_group2
		, reporting_group3
		, reporting_group4
		, reporting_group5
	FROM   source_deal_header_template a
	WHERE  template_id = @template_id
	
	SET @deal_temp_id=SCOPE_IDENTITY()

	IF @@ERROR <> 0
		BEGIN
		EXEC spa_ErrorHandler @@ERROR
			,'Source Deal Header Template'
			,'spa_source_deal_header_template'
			,'DB Error'
			,'Failed to Insert the new Source Deal Header Template.'
			,''

		ROLLBACK TRANSACTION
		END
	ELSE
	BEGIN
		INSERT INTO source_deal_detail_template (
			leg
			,fixed_float_leg
			,buy_sell_flag
			,curve_type
			,curve_id
			,deal_volume_frequency
			,deal_volume_uom_id
			,currency_id
			,block_description
			,template_id
			,commodity_id
			,day_count
			,physical_financial_flag
			,location_id
			,meter_id
			,strip_months_from
			,lag_months
			,strip_months_to
			,conversion_factor
			,pay_opposite
			,formula
			,settlement_currency
			,standard_yearly_volume
			,price_uom_id
			,category
			,profile_code
			,pv_party
			,adder_currency_id
			,booked
			,capacity
			,day_count_id
			,deal_detail_description
			,fixed_cost
			,fixed_cost_currency_id
			,formula_currency_id
			,formula_curve_id
			,formula_id
			,multiplier
			,option_strike_price
			,price_adder
			,price_adder_currency2
			,price_adder2
			,price_multiplier
			,process_deal_status
			,settlement_date
			,settlement_uom
			,settlement_volume
			,total_volume
			,volume_left
			,volume_multiplier2
			,term_start
			,term_end
			,contract_expiration_date
			,fixed_price
			,fixed_price_currency_id
			,deal_volume
		  )
		SELECT leg
			,fixed_float_leg
			,buy_sell_flag
			,curve_type
			,curve_id
			,deal_volume_frequency
			,deal_volume_uom_id
			,currency_id
			,block_description
			,@deal_temp_id
			,commodity_id
			,day_count
			,physical_financial_flag
			,location_id
			,meter_id
			,strip_months_from
			,lag_months
			,strip_months_to
			,conversion_factor
			,pay_opposite
			,formula
			,settlement_currency
			,standard_yearly_volume
			,price_uom_id
			,category
			,profile_code
			,pv_party
			,adder_currency_id
			,booked
			,capacity
			,day_count_id
			,deal_detail_description
			,fixed_cost
			,fixed_cost_currency_id
			,formula_currency_id
			,formula_curve_id
			,formula_id
			,multiplier
			,option_strike_price
			,price_adder
			,price_adder_currency2
			,price_adder2
			,price_multiplier
			,process_deal_status
			,settlement_date
			,settlement_uom
			,settlement_volume
			,total_volume
			,volume_left
			,volume_multiplier2
			,term_start
			,term_end
			,contract_expiration_date
			,fixed_price
			,fixed_price_currency_id
			,deal_volume
		FROM   source_deal_detail_template
		WHERE  template_id = @template_id
		
			IF @@ERROR <> 0
			BEGIN
			EXEC spa_ErrorHandler @@ERROR
				,'Source Deal Header Template'
				,'spa_source_deal_header_template'
				,'DB Error'
				,'Failed to Insert the new Source Deal Header Template.'
				,''

			ROLLBACK TRANSACTION
			END
			ELSE
			BEGIN
				EXEC spa_print 'insert into user_defined_deal_fields_template_main'

			INSERT INTO user_defined_deal_fields_template_main (
				template_id
				,field_name
				,Field_label
				,Field_type
				,data_type
				,is_required
				,sql_string
				,create_user
				,create_ts
				,update_user
				,update_ts
				,udf_type
				,sequence
				,field_size
				,field_id
				,default_value
				,book_id
				,udf_group
				,udf_tabgroup
				,formula_id
				,internal_field_type
				,currency_field_id
				,udf_user_field_id
				,leg
				  )
			SELECT @deal_temp_id
				,--template_id,
				field_name
				,Field_label
				,Field_type
				,data_type
				,is_required
				,sql_string
				,create_user
				,create_ts
				,update_user
				,update_ts
				,udf_type
				,sequence
				,field_size
				,field_id
				,default_value
				,book_id
				,udf_group
				,udf_tabgroup
				,formula_id
				,internal_field_type
				,currency_field_id
				,udf_user_field_id
				,leg
				FROM   user_defined_deal_fields_template_main
				WHERE  template_id = @template_id --@deal_temp_id
				
				IF @@ERROR <> 0
				BEGIN
				EXEC spa_ErrorHandler @@ERROR
					,'Source Deal Header Template'
					,'spa_source_deal_header_template'
					,'DB Error'
					,'Failed to Insert the new User Defined Deal Fields Template.'
					,''
					
				ROLLBACK TRANSACTION
				END
				ELSE
				BEGIN
					EXEC spa_print 'insert into deal_transfer_mapping'

				DECLARE @deal_transfer_mapping_id INT
				INSERT INTO deal_transfer_mapping (
					source_deal_type_id
					,source_deal_sub_type_id
					,source_book_mapping_id_from
					,trader_id_from
					,counterparty_id_from
					,counterparty_id_to
					,unapprove
					,offset
					,transfer
					,transfer_pricing_option
					,formula_id
					,template_id
					)
				SELECT source_deal_type_id
					,source_deal_sub_type_id
					,source_book_mapping_id_from
					,trader_id_from
					,counterparty_id_from
					,counterparty_id_to
					,unapprove
					,offset
					,transfer
					,transfer_pricing_option
					,formula_id
					,@deal_temp_id
							FROM deal_transfer_mapping 
							WHERE template_id= @template_id --@deal_temp_id

					SET @deal_transfer_mapping_id = SCOPE_IDENTITY()

					INSERT INTO deal_transfer_mapping_detail(
						deal_transfer_mapping_id,
						transfer_sub_book,
						transfer_trader_id,
						sub_book
					)
					SELECT @deal_transfer_mapping_id,
						   dtmd.transfer_sub_book,
						   dtmd.transfer_trader_id,
						   dtmd.sub_book
					FROM deal_transfer_mapping  dtm
					INNER JOIN deal_transfer_mapping_detail dtmd
										ON dtmd.deal_transfer_mapping_id = dtm.deal_transfer_mapping_id
							WHERE dtm.template_id= @template_id
						
					IF @@ERROR <> 0
					BEGIN
					EXEC spa_ErrorHandler @@ERROR
						,'Source Deal Header Template'
						,'spa_source_deal_header_template'
						,'DB Error'
						,'Failed to Insert the deal transfer mapping.'
						,''
							
					ROLLBACK TRANSACTION
					END
					ELSE
					BEGIN
					EXEC spa_ErrorHandler 0
						,'Source Deal Header Template'
						,'spa_source_deal_header_template'
						,'Success'
						,'New Source Deal Header Template is successfully Inserted.'
						,@deal_temp_id
				
					COMMIT TRANSACTION
					END
				END 
			END
	END	
END
ELSE IF @flag = 'z' --gets default entire_term_start and entire_term_end
BEGIN
	SET @user_login_id = dbo.FNADBUser()

	SELECT dbo.FNAUserDateFormat(entire_term_start, @user_login_id)
		,dbo.FNAUserDateFormat(sdht.entire_term_end, @user_login_id)
		,dbo.FNAUserDateFormat(sdht.deal_date, @user_login_id)
	FROM source_deal_header_template sdht
	WHERE sdht.template_id = @template_id
END
ELSE IF @flag = 'p' --Default select priveleged deal template
BEGIN
	SELECT a.template_id AS TemplateID
		,dtu.function_id
		,ROW_NUMBER() OVER (
			ORDER BY template_id
			) row_num
	INTO #temp
	FROM   source_deal_header_template a
	LEFT JOIN deal_template_users dtu ON dtu.function_id = a.template_id
				AND role_id = @role_id
	WHERE  1 = 1
		AND (
			a.is_public = 'n'
			OR a.is_public IS NULL
			)

	DECLARE @deal_template NVARCHAR(MAX)

	SELECT @deal_template = COALESCE(@deal_template + CASE 
				WHEN function_id IS NOT NULL
					THEN ','
									 ELSE ''
				END, '') + CASE 
			WHEN function_id IS NOT NULL
				THEN CAST(row_num AS NVARCHAR(10))
					ELSE ''
			   END
	FROM   #temp

	SELECT @deal_template
END

IF @is_batch = 1
BEGIN
	SELECT @str_batch_table = dbo.FNABatchProcess ('u', @batch_process_id, @batch_report_param, GETDATE(), NULL, NULL) 
	EXEC (@str_batch_table)
	SELECT @str_batch_table = dbo.FNABatchProcess ('c', @batch_process_id, @batch_report_param, GETDATE(), 'spa_source_deal_header_template', 'Maintain Deal Template') --TODO: modify sp and report name
	EXEC (@str_batch_table)

	RETURN
END

--if it is first call from paging, return total no. of rows and process id instead of actual data
IF @enable_paging = 1
	AND @page_no IS NULL
BEGIN
	SET @sql_paging = dbo.FNAPagingProcess ('t', @batch_process_id, @page_size, @page_no)

	EXEC (@sql_paging)
END

IF @flag = 't'
BEGIN 	
	SELECT field_id
		,field_caption
		,[insert_required]
		,[hide_control]
		,[default_value]
	FROM   source_deal_header_template sdht
	INNER JOIN [maintain_field_template_detail] mftd ON sdht.field_template_id = mftd.field_template_id
	WHERE  sdht.template_id = @template_id
		AND field_id IN (
			82
			,83
			)
	ORDER BY mftd.field_id	
END


GO

