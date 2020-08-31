

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_transfer_book_position]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_transfer_book_position]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROC [dbo].[spa_transfer_book_position]  
@template_id INT,  
@book_map_id_offset INT = NULL,  
@book_map_id_transfer INT,  
@counterparty_from INT = NULL,  
@trader_from INT = NULL,  
@counterparty_to INT = NULL,  
@trader_to INT = NULL,  
@fixed_price NUMERIC(38, 20) = NULL,  
@transfer_pricing_option CHAR(1) = 'd',  
@as_of_date VARCHAR(50),   
@sub_entity_id VARCHAR(100),   
@strategy_entity_id VARCHAR(100) = NULL,   
@book_entity_id VARCHAR(100) = NULL,   
@source_system_book_id1 INT = NULL,   
@source_system_book_id2 INT = NULL,   
@source_system_book_id3 INT = NULL,   
@source_system_book_id4 INT = NULL,  
@commodity_id INT = NULL,  
@trader_id INT = NULL,  
@term_start VARCHAR(20) = NULL,  
@term_end VARCHAR(20) = NULL,  
@counterparty_id INT = NULL,  
@use_existing_deal CHAR(1) = 'y',  
@curve_id INT = NULL,  
@volume NUMERIC(38, 20) = NULL,  
@volume_frequency CHAR(1) = 'm',  
@volume_uom INT = NULL,
@book_map_entity_id VARCHAR(200) = NULL, 
@round INT = NULL,
@contract_id_from INT = NULL,
@contract_id_to INT = NULL  
AS   

	/*  
	declare   
	 @template_id INT  
	 ,@book_map_id_offset INT   
	 ,@book_map_id_transfer INT  
	 ,@counterparty_from INT  
	 ,@trader_from INT   
	 ,@counterparty_to INT  
	 ,@trader_to INT  
	 ,@fixed_price FLOAT   
	 ,@transfer_pricing_option CHAR(1)   
	   
	 ,@as_of_date VARCHAR(50)  
	 ,@sub_entity_id VARCHAR(100)  
	 ,@strategy_entity_id VARCHAR(100)   
	 ,@book_entity_id VARCHAR(100)   
	 ,@source_system_book_id1 INT  
	 ,@source_system_book_id2 INT  
	 ,@source_system_book_id3 INT  
	 ,@source_system_book_id4 INT  
	 ,@commodity_id INT  
	 ,@trader_id INT  
	 ,@term_start VARCHAR(20)  
	 ,@term_end VARCHAR(20)  
	 ,@counterparty_id INT   
	   
	 ,@use_existing_deal CHAR(1)  
	 ,@curve_id INT  
	 ,@volume numeric(38,20)  
	 ,@volume_frequency char(1)  
	 ,@volume_uom INT  
	  
	select   
	 @template_id =77,  
	 @book_map_id_offset  = 96,  
	 @book_map_id_transfer =96,  
	 @counterparty_from  = 30,  
	 @trader_from  =1 ,  
	 @counterparty_to  = 30,  
	 @trader_to  =1 ,  
	 @fixed_price  = NULL,  
	 @transfer_pricing_option = 'm',  
	   
	 @as_of_date ='2011-06-27',   
	 @sub_entity_id ='148',   
	 @strategy_entity_id =NULL,   
	 @book_entity_id ='158',   
	 @source_system_book_id1 =null,   
	 @source_system_book_id2 =null,   
	 @source_system_book_id3 =null,   
	 @source_system_book_id4 =null,  
	 @commodity_id =null,  
	 @trader_id =null,  
	 @term_start ='2011-06-01',  
	 @term_end ='2011-07-31',  
	 @counterparty_id =null  
	   
	 ,@use_existing_deal ='n'  
	 ,@curve_id =23  
	 ,@volume =1000  
	 ,@volume_frequency ='m'  
	 ,@volume_uom =11  
	  
	--*/  
	DECLARE @process_id VARCHAR(100)  
	SET @process_id = dbo.FNAGetNewID() 
	  
	DECLARE @report_position_deals  VARCHAR(300),  
			@sql                    VARCHAR(MAX),  
			@user_login_id          VARCHAR(39),  
			@spa                    VARCHAR(2000),  
			@job_name               VARCHAR(200),
			@tx_deals				VARCHAR(MAX),
			@offset_deals			VARCHAR(MAX)
			
	DECLARE @deal_offset_id         INT 	
	DECLARE @temp_source_deal_header_id  VARCHAR(MAX)
	DECLARE @sql_stmt  
	                  VARCHAR(MAX) 

	
	SET @user_login_id = dbo.fnadbuser()  
	SET @report_position_deals = dbo.FNAProcessTableName('report_position', @user_login_id, @process_id)  
	SET NOCOUNT ON 	  
	-- #temp_transfer_book table holds Position Report data  
	CREATE TABLE #temp_transfer_book
	(
		row_id            INT IDENTITY(1, 1),
		curve_id          INT,
		term              VARCHAR(20) COLLATE DATABASE_DEFAULT ,
		volume            NUMERIC(38, 20),
		volume_frequency  CHAR(1) COLLATE DATABASE_DEFAULT ,
		volume_uom        INT
	)  
	  
	IF ISNULL(@use_existing_deal,'y') = 'y'
	BEGIN
		CREATE TABLE #report_position_deals (source_deal_header_id INT, [type] CHAR(1) COLLATE DATABASE_DEFAULT )
		INSERT INTO #temp_transfer_book
		EXEC spa_Create_Position_Report  @as_of_date, @sub_entity_id, @strategy_entity_id, @book_entity_id, 't', NULL, 'f', @source_system_book_id1, @source_system_book_id2, @source_system_book_id3, @source_system_book_id4, NULL, NULL, NULL, NULL, 'n', NULL, NULL, NULL, NULL, @curve_id, @commodity_id, NULL, 'i', 'b', NULL, @trader_id, @term_start, @term_end, 'n', NULL, NULL, '20', 'y', NULL,  NULL, 'n', NULL, NULL, 'n', NULL, @book_map_entity_id

	END  
	ELSE  
	BEGIN
		INSERT INTO #temp_transfer_book(curve_id ,term ,volume,volume_frequency,volume_uom ) SELECT @curve_id,@term_start,@volume ,ISNULL(@volume_frequency,'m'),@volume_uom   
		EXEC ('CREATE TABLE ' + @report_position_deals +'( source_deal_header_id INT, action CHAR(1))')  
	
	END
		
	IF NOT EXISTS (SELECT 1 FROM #temp_transfer_book)  
	BEGIN  
	 EXEC spa_ErrorHandler -1, 'Error',   
	  'spa_transfer_book_position', 'Error',   
	  'Position not found', ''  
	  RETURN  
	END   
	-- Initialize source book variables for Source System Book Map Offset and Transfer  
	DECLARE @to_book_map_id1      INT,
	        @to_book_map_id2      INT,
	        @to_book_map_id3      INT,
	        @to_book_map_id4      INT  
	
	DECLARE @offset_book_map_id1  INT,
	        @offset_book_map_id2  INT,
	        @offset_book_map_id3  INT,
	        @offset_book_map_id4  INT  
	
	SELECT @offset_book_map_id1 = source_system_book_id1,
	       @offset_book_map_id2 = source_system_book_id2,
	       @offset_book_map_id3 = source_system_book_id3,
	       @offset_book_map_id4 = source_system_book_id4
	FROM   source_system_book_map
	WHERE  book_deal_type_map_id = @book_map_id_offset  
	
	SELECT @to_book_map_id1 = source_system_book_id1,
	       @to_book_map_id2 = source_system_book_id2,
	       @to_book_map_id3 = source_system_book_id3,
	       @to_book_map_id4 = source_system_book_id4
	FROM   source_system_book_map
	WHERE  book_deal_type_map_id = @book_map_id_transfer  
	  
	-- book_transfer_id in source_deal_header table identifies the batch for the current Book Position Transfer  
	DECLARE @book_transfer_id  INT,  
			@new_header_id     INT  
	  
	SET @book_transfer_id = 1  
	  
	SELECT @book_transfer_id = ISNULL(MAX(book_transfer_id), 0) + 1  
	FROM   source_deal_header   
	  
	BEGIN TRY   
		BEGIN TRAN  
		IF ISNULL(@use_existing_deal,'y') = 'y'
		BEGIN
			-- Offset  
			INSERT INTO source_deal_header
			  (
			    source_system_id,
			    deal_id,	--  
			    deal_date,
			    template_id,
			    description1,
			    description2,
			    description3,
			    deal_category_value_id,
			    legal_entity,
			    commodity_id,
			    internal_portfolio_id,
			    granularity_id,
			    Pricing,
			    option_flag,
			    option_type,
			    internal_deal_type_value_id,
			    internal_deal_subtype_value_id,
			    source_deal_type_id,
			    deal_sub_type_type_id,
			    product_id,
			    internal_desk_id,
			    deal_status,
			    term_frequency,
			    option_excercise_type,
			    trader_id,
			    counterparty_id,
			    physical_financial_flag,
			    entire_term_start,
			    entire_term_end,
			    [source_system_book_id1],
			    [source_system_book_id2],
			    [source_system_book_id3],
			    [source_system_book_id4],
			    [create_user],
			    [create_ts],
			    [update_user],
			    [update_ts],
			    header_buy_sell_flag,
			    deal_reference_type_id,
			    book_transfer_id, 
			    close_reference_id, 
			    deal_locked,
			    broker_id,
			    contract_id,
			    block_define_id,
			    broker_unit_fees,
			    broker_fixed_cost,
			    broker_currency_id
			  )OUTPUT INSERTED.source_deal_header_id, 'O' INTO 
			   #report_position_deals(source_deal_header_id, [type])
			SELECT 2,
			       @process_id + '__' + CAST(row_id AS VARCHAR),
			       @as_of_date,
			       @template_id,
			       description1,
			       description2,
			       description3,
			       deal_category_value_id,
			       legal_entity,
			       sdht.commodity_id,
			       internal_portfolio_id,
			       granularity_id,
			       Pricing,
			       option_flag,
			       option_type,
			       internal_deal_type_value_id,
			       internal_deal_subtype_value_id,
			       source_deal_type_id,
			       deal_sub_type_type_id,
			       product_id,
			       internal_desk_id,
			       ISNULL(deal_status, 5604), --Deal status is New if not set in template
			       term_frequency_type,
			       option_excercise_type,
			       @trader_from,
			       @counterparty_from,
			       sdht.physical_financial_flag,
			       dbo.FNAStdDate(term),
			       dbo.FNAGetTermEndDate('m', dbo.FNAStdDate(term), 0),
			       @offset_book_map_id1,
			       @offset_book_map_id2,
			       @offset_book_map_id3,
			       @offset_book_map_id4,
			       dbo.FNADBUser(),
			       GETDATE(),
			       dbo.FNADBUser(),
			       GETDATE(),
			       --   CASE sdht.buy_sell_flag WHEN 'b' THEN 's' ELSE 'b' END [header_buy_sell_flag],  
			       CASE 
			            WHEN volume > 0 THEN 's'
			            ELSE 'b'
			       END [header_buy_sell_flag],
			       12500,
			       @book_transfer_id, 
			       t.row_id, 
			       'y',
			       sdht.broker_id,
			       @contract_id_from,
			       sdht.block_define_id,
			       broker_unit_fees,
				   broker_fixed_cost,
				   broker_currency_id
			FROM   #temp_transfer_book t
			       LEFT JOIN source_deal_header_template sdht
			            ON  sdht.template_id = @template_id
			       LEFT JOIN source_deal_detail_template sddt
			            ON  sddt.template_id = sdht.template_id
			WHERE  ABS(volume) >= .001  
			
			--user_defined_deal_fields  for offset deals
			INSERT INTO user_defined_deal_fields
			  (
			    source_deal_header_id,
			    udf_template_id
			  )
			SELECT sdh.source_deal_header_id,
			       uddft.udf_template_id
			FROM   #temp_transfer_book t
			       INNER JOIN source_deal_header sdh
			            ON  sdh.deal_id = @process_id + '__' + CAST(t.row_id AS VARCHAR)
			       LEFT JOIN user_defined_deal_fields_template uddft
			            ON  uddft.template_id = @template_id
			WHERE  ABS(volume) >= .001
			       AND uddft.udf_type = 'h'
		  --  
		    
			INSERT INTO source_deal_detail
			  (
			    source_deal_header_id,
			    term_start,
			    term_end,
			    leg,
			    contract_expiration_date,
			    fixed_float_leg,
			    buy_sell_flag,
			    physical_financial_flag,
			    curve_id,
			    fixed_price,
			    fixed_price_currency_id,
			    deal_volume,
			    deal_volume_frequency,
			    deal_volume_uom_id,
			    block_description,
			    settlement_date,
			    [create_user],
			    [create_ts],
			    [update_user],
			    [update_ts],
			    process_deal_status,
			    location_id,
			    option_strike_price,
			    formula_id,
			    price_adder,
			    price_multiplier, 
			    meter_id,
			    fixed_cost,
			    multiplier,
			    adder_currency_id,
			    fixed_cost_currency_id,
			    formula_currency_id,
			    price_adder2,
			    price_adder_currency2,
			    volume_multiplier2,
			    pay_opposite, 
			    capacity,
			    profile_code,
			    pv_party			    
			  )
			SELECT sdh.source_deal_header_id,
			       dbo.FNAStdDate(term),
			       dbo.FNAGetTermEndDate('m', dbo.FNAStdDate(term), 0) term_end,
			       leg,
			       --   dbo.FNAGetTermStartDate('m', dbo.FNAGetTermEndDate('m',term,0) ,0) AS contract_expiration_date,
			       --   dbo.FNAGetTermStartDate('m',term,0) AS contract_expiration_date,  
			       --COALESCE(
			       --    hd.exp_date,
			       --    hd2.exp_date,
			       --    dbo.FNAGetTermEndDate('m', dbo.FNAStdDate(term), 0)
			       --) contract_expiration_date,
			       --exp_date from holiday_group was not taken since there are duplicate data in the table 			       
			       dbo.FNAGetTermEndDate('m', dbo.FNAStdDate(term), 0) contract_expiration_date,
			       fixed_float_leg,
			       CASE 
			            WHEN volume > 0 THEN 's'
			            ELSE 'b'
			       END [buy_sell_flag],
			       sddt.physical_financial_flag,
			       t.curve_id,
			       CASE @transfer_pricing_option
			            WHEN 'x' THEN @fixed_price
			            ELSE spc.curve_value
			       END [fixed_price],
			       sddt.fixed_price_currency_id,
			       ROUND(ABS(volume), ISNULL(@round, 12)),
			       --'t',
			       sddt.deal_volume_frequency,
			       t.volume_uom,
			       block_description,
			       --   dbo.FNAGetTermEndDate('m',term,0) settlement_date,  
			       --COALESCE(
			       --    hd.settlement_date,
			       --    hd.exp_date,
			       --    dbo.FNAGetTermEndDate('m', dbo.FNAStdDate(term), 0)
			       --) settlement_date,
			       --settlement_date from holiday_group was not taken since there are duplicate data in the table 
			       dbo.FNAGetTermEndDate('m', dbo.FNAStdDate(term), 0) settlement_date,
			       dbo.FNADBUser(),
			       GETDATE(),
			       dbo.FNADBUser(),
			       GETDATE(),
			       12500,
			       sddt.location_id,
			       sddt.option_strike_price,
			       sddt.formula_id,
			       sddt.price_adder,
				   sddt.price_multiplier,
				   sddt.meter_id,
				   sddt.fixed_cost,
				   sddt.multiplier,
				   sddt.adder_currency_id,
				   sddt.fixed_cost_currency_id,
				   sddt.formula_currency_id,
				   sddt.price_adder2,
				   sddt.price_adder_currency2,
				   sddt.volume_multiplier2,
				   sddt.pay_opposite,
				   sddt.capacity,
				   sddt.profile_code,
				   sddt.pv_party	
			FROM   #temp_transfer_book t
			       INNER JOIN source_deal_header sdh
			            ON  sdh.deal_id = @process_id + '__' + CAST(t.row_id AS VARCHAR)
			       LEFT JOIN source_deal_detail_template sddt
			            ON  sddt.template_id = @template_id
			       LEFT JOIN source_price_curve_def spcd
			            ON  spcd.source_curve_def_id = t.curve_id
			       --LEFT JOIN holiday_group hd
			       --     ON  hd.hol_date = dbo.FNAStdDate(t.term)
			       --     AND spcd.exp_calendar_id = hd.hol_group_value_id
			       --LEFT JOIN holiday_group hd2
			       --     ON  hd2.hol_date = dbo.FNAGetContractMonth(dbo.FNAStdDate(t.term))
			       --     AND spcd.exp_calendar_id = hd2.hol_group_value_id
			       LEFT OUTER JOIN source_price_curve spc
			            ON  spc.source_curve_def_id = t.curve_id
			            AND spc.as_of_date = @as_of_date
			            AND spc.maturity_date = dbo.FNAStdDate(t.term)
			            AND spc.curve_source_value_id = 4500
			WHERE  ABS(volume) >= .001  
		   
			--user_defined_deal_detail_fields
			INSERT INTO user_defined_deal_detail_fields
			  (
			    source_deal_detail_id,
			    udf_template_id
			  )
			SELECT sdd.source_deal_detail_id,
			       uddft.udf_template_id
			FROM   #temp_transfer_book t
			       INNER JOIN source_deal_header sdh
			            ON  sdh.deal_id = @process_id + '__' + CAST(t.row_id AS VARCHAR)
			       LEFT JOIN source_deal_detail sdd
			            ON  sdh.source_deal_header_id = sdd.source_deal_header_id
			       LEFT JOIN user_defined_deal_fields_template uddft
			            ON  uddft.template_id = @template_id
			WHERE  ABS(volume) >= .001
			       AND uddft.udf_type = 'd'
			
			UPDATE source_deal_header
			SET    deal_id = CAST(source_deal_header_id AS VARCHAR) + 
			       '-farrms_Offset'
			WHERE  deal_id LIKE @process_id + '__%'   
			
		  -- Transfer  
			INSERT INTO source_deal_header
			  (
			    source_system_id,
			    deal_id,	--  
			    deal_date,
			    template_id,
			    description1,
			    description2,
			    description3,
			    deal_category_value_id,
			    legal_entity,
			    commodity_id,
			    internal_portfolio_id,
			    granularity_id,
			    Pricing,
			    option_flag,
			    option_type,
			    internal_deal_type_value_id,
			    internal_deal_subtype_value_id,
			    source_deal_type_id,
			    deal_sub_type_type_id,
			    product_id,
			    internal_desk_id,
			    deal_status,
			    term_frequency,
			    option_excercise_type,
			    trader_id,
			    counterparty_id,
			    physical_financial_flag,
			    entire_term_start,
			    entire_term_end,
			    [source_system_book_id1],
			    [source_system_book_id2],
			    [source_system_book_id3],
			    [source_system_book_id4],
			    [create_user],
			    [create_ts],
			    [update_user],
			    [update_ts],
			    header_buy_sell_flag,
			    deal_reference_type_id,
			    book_transfer_id, 
			    close_reference_id,
			    broker_id,
			    contract_id,
			    block_define_id,
			    broker_unit_fees,
			    broker_fixed_cost,
			    broker_currency_id
			  )OUTPUT INSERTED.source_deal_header_id, 'T' INTO 
			   #report_position_deals(source_deal_header_id, [type])
			SELECT 2,
			       @process_id + '__' + CAST(row_id AS VARCHAR),
			       @as_of_date,
			       @template_id,
			       description1,
			       description2,
			       description3,
			       deal_category_value_id,
			       legal_entity,
			       sdht.commodity_id,
			       internal_portfolio_id,
			       granularity_id,
			       Pricing,
			       option_flag,
			       option_type,
			       internal_deal_type_value_id,
			       internal_deal_subtype_value_id,
			       source_deal_type_id,
			       deal_sub_type_type_id,
			       product_id,
			       internal_desk_id,
			       ISNULL(deal_status, 5604), --Deal status is New if not set in template
			       term_frequency_type, 
			       sdht.option_excercise_type,
			       @trader_to,
			       @counterparty_to,
			       sdht.physical_financial_flag,
			       dbo.FNAStdDate(term) term_start,
			       dbo.FNAGetTermEndDate('m', dbo.FNAStdDate(term), 0) term_end,
			       @to_book_map_id1,
			       @to_book_map_id2,
			       @to_book_map_id3,
			       @to_book_map_id4,
			       dbo.FNADBUser(),
			       GETDATE(),
			       dbo.FNADBUser(),
			       GETDATE(),
			       --   sdht.buy_sell_flag,  
			       CASE 
			            WHEN volume > 0 THEN 'b'
			            ELSE 's'
			       END [buy_sell_flag],
			       12503,
			       @book_transfer_id, 
			       t.row_id,
			       sdht.broker_id,
			       @contract_id_to,
			       sdht.block_define_id,
			       broker_unit_fees,
				   broker_fixed_cost,
				   broker_currency_id
			FROM   #temp_transfer_book t
			       LEFT JOIN source_deal_header_template sdht
			            ON  sdht.template_id = @template_id
			       LEFT JOIN source_deal_detail_template sddt
			            ON  sddt.template_id = sdht.template_id
			WHERE  ABS(volume) >= .001  
		  
			--user_defined_deal_fields  for transfer deals
			INSERT INTO user_defined_deal_fields
			  (
			    source_deal_header_id,
			    udf_template_id
			  )
			SELECT sdh.source_deal_header_id,
			       uddft.udf_template_id
			FROM   #temp_transfer_book t
			       INNER JOIN source_deal_header sdh
			            ON  sdh.deal_id = @process_id + '__' + CAST(t.row_id AS VARCHAR)
			       LEFT JOIN user_defined_deal_fields_template uddft
			            ON  uddft.template_id = @template_id
			WHERE  ABS(volume) >= .001 AND uddft.udf_type = 'h'
			
			INSERT INTO source_deal_detail
			  (
			    source_deal_header_id,
			    term_start,
			    term_end,
			    leg,
			    contract_expiration_date,
			    fixed_float_leg,
			    buy_sell_flag,
			    physical_financial_flag,
			    curve_id,
			    fixed_price,
			    fixed_price_currency_id,
			    deal_volume,
			    deal_volume_frequency,
			    deal_volume_uom_id,
			    block_description,
			    settlement_date,
			    [create_user],
			    [create_ts],
			    [update_user],
			    [update_ts],
			    process_deal_status,
			    location_id,
			    option_strike_price,
			    formula_id,
			    price_adder,
			    price_multiplier, 
			    meter_id,
			    fixed_cost,
			    multiplier,
			    adder_currency_id,
			    fixed_cost_currency_id,
			    formula_currency_id,
			    price_adder2,
			    price_adder_currency2,
			    volume_multiplier2,
			    pay_opposite, 
			    capacity,
			    profile_code,
			    pv_party	
			  )
			SELECT sdh.source_deal_header_id,
			       dbo.FNAStdDate(term),
			       dbo.FNAGetTermEndDate('m', dbo.FNAStdDate(term), 0) term_end,
			       leg,
			       --   dbo.FNAGetTermStartDate('m', dbo.FNAGetTermEndDate('m',term,0) ,0) AS contract_expiration_date,
			       --   dbo.FNAGetTermStartDate('m', term ,0) AS contract_expiration_date,  
			       --COALESCE(
			       --    hd.exp_date,
			       --    hd2.exp_date,
			       --    dbo.FNAGetTermEndDate('m', dbo.FNAStdDate(term), 0)
			       --) contract_expiration_date,
			       --exp_date from holiday_group was not taken since there use duplicate data in the table 
			       dbo.FNAGetTermEndDate('m', dbo.FNAStdDate(term), 0) contract_expiration_date,
			       fixed_float_leg,
			       CASE 
			            WHEN volume > 0 THEN 'b'
			            ELSE 's'
			       END [buy_sell_flag],
			       sddt.physical_financial_flag,
			       t.curve_id,
			       CASE @transfer_pricing_option
			            WHEN 'x' THEN @fixed_price
			            ELSE spc.curve_value
			       END [fixed_price],
			       sddt.fixed_price_currency_id,
			       ROUND(ABS(volume), ISNULL(@round, 12)),
			       --'t',
			       sddt.deal_volume_frequency,
			       t.volume_uom,
			       block_description,
			       --   dbo.FNAGetTermEndDate('m',term,0) settlement_date,  
			       --COALESCE(
			       --    hd.settlement_date,
			       --    hd.exp_date,
			       --    dbo.FNAGetTermEndDate('m', dbo.FNAStdDate(t.term), 0)
			       --) settlement_date,
				   --settlement_date from holiday_group was not taken since there use duplicate data in the table 
				   dbo.FNAGetTermEndDate('m', dbo.FNAStdDate(t.term), 0) settlement_date,
			       dbo.FNADBUser(),
			       GETDATE(),
			       dbo.FNADBUser(),
			       GETDATE(),
			       12503,
			       sddt.location_id,
			       sddt.option_strike_price,
			       sddt.formula_id,
			       sddt.price_adder,
				   sddt.price_multiplier,
				   sddt.meter_id,
				   sddt.fixed_cost,
				   sddt.multiplier,
				   sddt.adder_currency_id,
				   sddt.fixed_cost_currency_id,
				   sddt.formula_currency_id,
				   sddt.price_adder2,
				   sddt.price_adder_currency2,
				   sddt.volume_multiplier2,
				   sddt.pay_opposite,
				   sddt.capacity,
				   sddt.profile_code,
				   sddt.pv_party
			FROM   #temp_transfer_book t
			       INNER JOIN source_deal_header sdh
			            ON  sdh.deal_id = @process_id + '__' + CAST(t.row_id AS VARCHAR)
			       LEFT JOIN source_deal_detail_template sddt
			            ON  sddt.template_id = @template_id
			       LEFT JOIN source_price_curve_def spcd
			            ON  spcd.source_curve_def_id = t.curve_id
			       --LEFT JOIN holiday_group hd
			       --     ON  hd.hol_date = dbo.FNAStdDate(t.term)
			       --     AND spcd.exp_calendar_id = hd.hol_group_value_id
			       --LEFT JOIN holiday_group hd2
			       --     ON  dbo.FNAGetContractMonth(hd2.hol_date) = dbo.FNAStdDate(t.term)
			       --     AND spcd.exp_calendar_id = hd2.hol_group_value_id
			       LEFT OUTER JOIN source_price_curve spc
			            ON  spc.source_curve_def_id = t.curve_id
			            AND spc.as_of_date = @as_of_date
			            AND spc.maturity_date = dbo.FNAStdDate(t.term)
			            AND spc.curve_source_value_id = 4500
			WHERE  ABS(volume) >= .001  
		  
			--user_defined_deal_detail_fields for transfer deal
			INSERT INTO user_defined_deal_detail_fields
			  (
			    source_deal_detail_id,
			    udf_template_id
			  )
			SELECT sdd.source_deal_detail_id,
			       uddft.udf_template_id
			FROM   #temp_transfer_book t
			       INNER JOIN source_deal_header sdh
			            ON  sdh.deal_id = @process_id + '__' + CAST(t.row_id AS VARCHAR)
			       LEFT JOIN source_deal_detail sdd
			            ON  sdh.source_deal_header_id = sdd.source_deal_header_id
			       LEFT JOIN user_defined_deal_fields_template uddft
			            ON  uddft.template_id = @template_id
			                WHERE ABS(volume) >= .001 AND uddft.udf_type = 'd'
		  
			UPDATE source_deal_header
			SET    deal_id = CAST(source_deal_header_id AS VARCHAR) + 
			       '-farrms_Xferred',
			       ext_deal_id = CAST(source_deal_header_id AS VARCHAR) + 
			       '-farrms_Offset'
			WHERE  deal_id LIKE @process_id + '__%'   
		  
			SET @sql = '   
			SELECT source_deal_header_id ,''i'' action INTO ' + @report_position_deals 
			    + ' FROM #report_position_deals'
			
			EXEC (@sql) 
			
			SELECT @temp_source_deal_header_id = COALESCE(@temp_source_deal_header_id + ',', '') 
			       + CAST(source_deal_header_id AS VARCHAR(20))
			FROM   #report_position_deals
			
			SET @sql_stmt = 'spa_master_deal_view ''i'',''' + @temp_source_deal_header_id 
			    + ''''
			
			SET @job_name = 'update_master_deal_view_transfer_' + @process_id
			EXEC spa_run_sp_as_job @job_name,
			     @sql_stmt,
			     'update_master_deal_view_transfer',
			     @user_login_id

				--EXEC spa_master_deal_view 'i', @temp_source_deal_header_id
			 SELECT sdh_o.source_deal_header_id,
					sdh_o.close_reference_id,
					rpd.[type] INTO #temp_transfer_ref
			 FROM   #report_position_deals rpd
					INNER JOIN source_deal_header sdh_o
						 ON  rpd.source_deal_header_id = sdh_o.source_deal_header_id
						 AND rpd.[type] = 'o'
			 
			 
			 SELECT sdh_t.source_deal_header_id,
					sdh_t.close_reference_id,
					rpd.[type] INTO #temp_offset_ref
			 FROM   #report_position_deals rpd
					INNER JOIN source_deal_header sdh_t
						 ON  rpd.source_deal_header_id = sdh_t.source_deal_header_id
						 AND rpd.[type] = 't'
			 
			 
			 SELECT ttr.source_deal_header_id source_deal_header_id_tran,
					tor.source_deal_header_id source_deal_header_id_off INTO 
					#temp_trans_off_rel
			 FROM   #temp_transfer_ref ttr
					INNER JOIN #temp_offset_ref tor
						 ON  ttr.close_reference_id = tor.close_reference_id
			 
			 
			 UPDATE sdh
			 SET    close_reference_id = source_deal_header_id_tran
			 FROM   source_deal_header sdh
					INNER JOIN #temp_trans_off_rel ttor
						 ON  sdh.source_deal_header_id = ttor.source_deal_header_id_off
			 
			 UPDATE sdh
			 SET    close_reference_id = source_deal_header_id_off
			 FROM   source_deal_header sdh
					INNER JOIN #temp_trans_off_rel ttor
						 ON  sdh.source_deal_header_id = ttor.source_deal_header_id_tran
		 
		
			COMMIT
		  
			SELECT @tx_deals = STUFF(
			           (
			               SELECT ',' + CAST(source_deal_header_id AS VARCHAR(10))
			               FROM   #report_position_deals
			               WHERE  [type] = 'T' 
			                      FOR XML PATH('')
			           ), 1, 1, ''
			       )
			
			SELECT @offset_deals = STUFF(
			           (
			               SELECT ',' + CAST(source_deal_header_id AS VARCHAR(10))
			               FROM   #report_position_deals
			               WHERE  [type] = 'O' 
			                      FOR XML PATH('')
			           ), 1, 1, ''
			       )
		 
			EXEC spa_insert_update_audit 'i', @tx_deals  
			EXEC spa_insert_update_audit 'i', @offset_deals   
			
			DECLARE @total_tranfer_offset_deals VARCHAR(MAX)
			SET @total_tranfer_offset_deals = @tx_deals + ',' + @offset_deals
			
			EXEC dbo.spa_callDealConfirmationRule @total_tranfer_offset_deals,
			     19501,
			     NULL,
			     NULL 
		END  
		ELSE  
		BEGIN	
			-- Offset  
			INSERT INTO source_deal_header
			  (
			    source_system_id,
			    deal_id,	--  
			    deal_date,
			    template_id,
			    description1,
			    description2,
			    description3,
			    deal_category_value_id,
			    legal_entity,
			    commodity_id,
			    internal_portfolio_id,
			    granularity_id,
			    Pricing,
			    option_flag,
			    option_type,
			    internal_deal_type_value_id,
			    internal_deal_subtype_value_id,
			    source_deal_type_id,
			    deal_sub_type_type_id,
			    product_id,
			    internal_desk_id,
			    deal_status,
			    term_frequency,
			    option_excercise_type,
			    trader_id,
			    counterparty_id,
			    physical_financial_flag,
			    entire_term_start,
			    entire_term_end,
			    [source_system_book_id1],
			    [source_system_book_id2],
			    [source_system_book_id3],
			    [source_system_book_id4],
			    [create_user],
			    [create_ts],
			    [update_user],
			    [update_ts],
			    header_buy_sell_flag,
			    deal_reference_type_id,
			    book_transfer_id,
			    confirm_status_type,
			    block_define_id,
			    contract_id,
			    deal_locked, 
			    broker_id,
			    broker_unit_fees,
			    broker_fixed_cost,
			    broker_currency_id
			    
			  )
			SELECT 2,
			       @process_id,
			       @as_of_date,
			       @template_id,
			       description1,
			       description2,
			       description3,
			       deal_category_value_id,
			       legal_entity,
			       sdht.commodity_id,
			       internal_portfolio_id,
			       granularity_id,
			       Pricing,
			       option_flag,
			       option_type,
			       internal_deal_type_value_id,
			       internal_deal_subtype_value_id,
			       source_deal_type_id,
			       deal_sub_type_type_id,
			       product_id,
			       internal_desk_id,
			       ISNULL(deal_status, 5604), --Deal status is New if not set in template
			       term_frequency_type,
			       option_excercise_type,
			       @trader_from,
			       @counterparty_from,
			       sdht.physical_financial_flag,
			       t.term_start,
			       CASE 
			            WHEN ISNULL(@use_existing_deal, 'y') = 'y' THEN dbo.FNAGetTermEndDate('m', t.term_end, 0)
			            ELSE @term_end
			       END,
			       @offset_book_map_id1,
			       @offset_book_map_id2,
			       @offset_book_map_id3,
			       @offset_book_map_id4,
			       dbo.FNADBUser(),
			       GETDATE(),
			       dbo.FNADBUser(),
			       GETDATE(),
			       CASE 
			            WHEN t.volume > 0 THEN 's'
			            ELSE 'b'
			       END [header_buy_sell_flag],
			       12500,
			       @book_transfer_id,
			       17200,
			       block_define_id,
			       @contract_id_from,
			       'y',
			       sdht.broker_id,
			       sdht.broker_unit_fees,
			       sdht.broker_fixed_cost,
			       sdht.broker_currency_id
			FROM   (
			           SELECT MIN(term) term_start,
			                  MAX(term) term_end,
			                  SUM(volume) volume
			           FROM   #temp_transfer_book
			       ) t
			       CROSS JOIN (
			                SELECT *
			                FROM   source_deal_header_template
			                WHERE  template_id = @template_id --AND blotter_supported='y'
			            ) sdht
			       LEFT JOIN source_deal_detail_template sddt
			            ON  sddt.template_id = sdht.template_id
			WHERE  ABS(volume) >= .001 
		  

		   
			--SELECT term_frequency_type,* FROM source_deal_header_template
			--SELECT * FROM source_deal_detail_template  
			SET @new_header_id = SCOPE_IDENTITY()
		                                                          --select @new_header_id  
			EXEC spa_print 'INSERTED'   
		 
		 
			--select * from #temp_transfer_book  
			EXEC spa_print 'new_id:', @new_header_id 

			INSERT INTO source_deal_detail
			  (
			    source_deal_header_id,
			    term_start,
			    term_end,
			    leg,
			    contract_expiration_date,
			    fixed_float_leg,
			    buy_sell_flag,
			    physical_financial_flag,
			    curve_id,
			    fixed_price,
			    fixed_price_currency_id,
			    deal_volume,
			    deal_volume_frequency,
			    deal_volume_uom_id,
			    block_description,
			    settlement_date,
			    [create_user],
			    [create_ts],
			    [update_user],
			    [update_ts],
			    process_deal_status,
			    location_id,
			    pay_opposite,
			    multiplier,
			    volume_multiplier2,
			    meter_id,
			    price_multiplier,
			    pv_party,
			    profile_code,
			    category,
			    settlement_currency,
			    standard_yearly_volume,
			    price_uom_id,
			    formula_id,
			    option_strike_price,
			    price_adder,
			    fixed_cost,
			    formula_currency_id,
			    price_adder2,
			    price_adder_currency2, 
			    capacity
			    
			  )
			SELECT @new_header_id,
			       trm.term_start,
			       trm.term_end,
			       idx.leg,
			       COALESCE(hd.exp_date, hd2.exp_date, trm.term_end) 
			       contract_expiration_date,
			       fixed_float_leg,
			       CASE 
			            WHEN volume > 0 THEN 's'
			            ELSE 'b'
			       END [buy_sell_flag],
			       sddt.physical_financial_flag,
			       t.curve_id,
			       CASE @transfer_pricing_option
			            WHEN 'x' THEN @fixed_price
			            ELSE CAST(spc.curve_value AS NUMERIC(38, 20))
			       END [fixed_price],
			       sddt.fixed_price_currency_id,
			       ABS(volume),
			       ISNULL(@volume_frequency, volume_frequency),
			       t.volume_uom,
			       block_description,
			       COALESCE(hd.settlement_date, hd.exp_date, trm.term_end) 
			       settlement_date,
			       dbo.FNADBUser(),
			       GETDATE(),
			       dbo.FNADBUser(),
			       GETDATE(),
			       12500,
			       sddt.location_id,
			       sddt.pay_opposite,
			       1,
			       1,
			       sddt.meter_id,
			       1,
			       sddt.pv_party,
			       sddt.profile_code,
			       sddt.category,
			       sddt.settlement_currency,
			       sddt.standard_yearly_volume,
			       sddt.price_uom_id,
			       sddt.formula,
			       sddt.option_strike_price,
			       sddt.price_adder,
			       sddt.fixed_cost,
			       sddt.formula_currency_id,			       
			       sddt.price_adder2, 
			       sddt.price_adder_currency2,
			       sddt.capacity
			FROM   #temp_transfer_book t
			       INNER JOIN (
			                SELECT curve_id,
			                       ROW_NUMBER() OVER(ORDER BY curve_id) leg
			                FROM   #temp_transfer_book
			                GROUP BY
			                       curve_id
			            ) idx
			            ON  t.curve_id = idx.curve_id
			       CROSS JOIN (
			                SELECT *
			                FROM   source_deal_detail_template
			                WHERE  leg = 1
			                       AND template_id = @template_id
			            )sddt
			       INNER JOIN source_deal_header_template sdht
			            ON  sddt.template_id = sdht.template_id
			       CROSS APPLY dbo.[FNATermBreakdown](sdht.term_frequency_type, t.term, @term_end) 
			trm 
			LEFT JOIN source_price_curve_def spcd
			            ON  spcd.source_curve_def_id = t.curve_id
			       LEFT JOIN holiday_group hd
			            ON  hd.hol_date = trm.term_start
			            AND spcd.exp_calendar_id = hd.hol_group_value_id
			       LEFT JOIN holiday_group hd2
			            ON  hd2.hol_date = dbo.FNAGetContractMonth(trm.term_start)
			            AND spcd.exp_calendar_id = hd2.hol_group_value_id
			       LEFT JOIN source_price_curve spc
			            ON  spc.source_curve_def_id = t.curve_id
			            AND spc.as_of_date = @as_of_date
			            AND spc.maturity_date = trm.term_start
			            AND spc.curve_source_value_id = 4500
			WHERE  ABS(volume) >= .001 
			
			EXEC spa_print 'DETAIL'   
		
		 
			SET @deal_offset_id = @new_header_id  
			UPDATE source_deal_header
			SET    deal_id = CAST(@deal_offset_id AS VARCHAR) + '-farrms_Offset'
			WHERE  source_deal_header_id = @deal_offset_id  
			
			SET @sql = 'INSERT INTO ' + @report_position_deals + 
			    '(source_deal_header_id,action) SELECT ' + CAST(@new_header_id AS VARCHAR) 
			    + ',''i'''
			
			EXEC (@sql)  
			SET @temp_source_deal_header_id = COALESCE(@temp_source_deal_header_id + ',', '') 
			    + CAST(@deal_offset_id AS VARCHAR)
			
			SET @sql_stmt = 'spa_master_deal_view ''i'',''' + CAST(@deal_offset_id AS VARCHAR(200)) 
			    + ''''
			
			SET @job_name = 'update_master_deal_view_offset' + @process_id
			EXEC spa_run_sp_as_job @job_name,
			     @sql_stmt,
			     'update_master_deal_view_offset',
			     @user_login_id
			     
			     --EXEC spa_master_deal_view 'i', @temp_source_deal_header_id  
			     
		 
			-- Transfer  
			INSERT INTO source_deal_header
			  (
			    source_system_id,
			    deal_id,	--  
			    deal_date,
			    template_id,
			    description1,
			    description2,
			    description3,
			    deal_category_value_id,
			    legal_entity,
			    commodity_id,
			    internal_portfolio_id,
			    granularity_id,
			    Pricing,
			    option_flag,
			    option_type,
			    internal_deal_type_value_id,
			    internal_deal_subtype_value_id,
			    source_deal_type_id,
			    deal_sub_type_type_id,
			    product_id,
			    internal_desk_id,
			    deal_status,
			    term_frequency,
			    option_excercise_type,
			    trader_id,
			    counterparty_id,
			    physical_financial_flag,
			    entire_term_start,
			    entire_term_end,
			    [source_system_book_id1],
			    [source_system_book_id2],
			    [source_system_book_id3],
			    [source_system_book_id4],
			    [create_user],
			    [create_ts],
			    [update_user],
			    [update_ts],
			    header_buy_sell_flag,
			    deal_reference_type_id,
			    book_transfer_id,
			    confirm_status_type,
			    block_define_id,
			    contract_id,
			    broker_id,
			    broker_unit_fees,
			    broker_fixed_cost,
			    broker_currency_id
			  )
			SELECT 2,
			       @process_id,
			       @as_of_date,
			       @template_id,
			       description1,
			       description2,
			       description3,
			       deal_category_value_id,
			       legal_entity,
			       sdht.commodity_id,
			       internal_portfolio_id,
			       granularity_id,
			       Pricing,
			       option_flag,
			       option_type,
			       internal_deal_type_value_id,
			       internal_deal_subtype_value_id,
			       source_deal_type_id,
			       deal_sub_type_type_id,
			       product_id,
			       internal_desk_id,
			       ISNULL(deal_status, 5604), --Deal status is New if not set in template
			       term_frequency_type,
			       option_excercise_type,
			       @trader_to,
			       @counterparty_to,
			       sdht.physical_financial_flag,
			       t.term_start,
			       CASE 
			            WHEN ISNULL(@use_existing_deal, 'y') = 'y' THEN dbo.FNAGetTermEndDate('m', t.term_end, 0)
			            ELSE @term_end
			       END,
			       @to_book_map_id1,
			       @to_book_map_id2,
			       @to_book_map_id3,
			       @to_book_map_id4,
			       dbo.FNADBUser(),
			       GETDATE(),
			       dbo.FNADBUser(),
			       GETDATE(),
			       CASE 
			            WHEN volume > 0 THEN 'b'
			            ELSE 's'
			       END [buy_sell_flag],
			       12503,
			       @book_transfer_id,
			       17200,
			       block_define_id,
			       @contract_id_to,
			       sdht.broker_id,
			       sdht.broker_unit_fees,
			       sdht.broker_fixed_cost,
			       sdht.broker_currency_id
			FROM   (
			           SELECT MIN(term) term_start,
			                  MAX(term) term_end,
			                  SUM(volume) volume
			           FROM   #temp_transfer_book
			       ) t
			       CROSS JOIN (
			                SELECT *
			                FROM   source_deal_header_template
			                WHERE  template_id = @template_id --AND blotter_supported='y'
			            ) sdht
			       LEFT JOIN source_deal_detail_template sddt
			            ON  sddt.template_id = sdht.template_id
			WHERE  ABS(volume) >= .001
			
			SET @new_header_id = SCOPE_IDENTITY()
		 EXEC spa_print 'INSERTED'   
			EXEC spa_print 'new_id:', @new_header_id
			
			INSERT INTO source_deal_detail
			  (
			    source_deal_header_id,
			    term_start,
			    term_end,
			    leg,
			    contract_expiration_date,
			    fixed_float_leg,
			    buy_sell_flag,
			    physical_financial_flag,
			    curve_id,
			    fixed_price,
			    fixed_price_currency_id,
			    deal_volume,
			    deal_volume_frequency,
			    deal_volume_uom_id,
			    block_description,
			    settlement_date,
			    [create_user],
			    [create_ts],
			    [update_user],
			    [update_ts],
			    process_deal_status,
			    location_id,
			    pay_opposite,
			    multiplier,
			    volume_multiplier2,
			    meter_id,
			    price_multiplier,
			    pv_party,
			    profile_code,
			    category,
			    settlement_currency,
			    standard_yearly_volume,
			    price_uom_id,
			    formula_id,
			    option_strike_price,
			    price_adder,
			    fixed_cost,
			    formula_currency_id,
			    price_adder2,
			    price_adder_currency2, 
			    capacity
			    
			  )
			SELECT @new_header_id,
			       trm.term_start,
			       trm.term_end,
			       idx.leg,
			       COALESCE(hd.exp_date, hd2.exp_date, trm.term_end) 
			       contract_expiration_date,
			       fixed_float_leg,
			       CASE 
			            WHEN volume > 0 THEN 'b'
			            ELSE 's'
			       END [buy_sell_flag],
			       sddt.physical_financial_flag,
			       t.curve_id,
			       CASE @transfer_pricing_option
			            WHEN 'x' THEN @fixed_price
			            ELSE CAST(spc.curve_value AS NUMERIC(38, 20))
			       END [fixed_price],
			       sddt.fixed_price_currency_id,
			       ABS(volume),
			       ISNULL(@volume_frequency, volume_frequency),
			       t.volume_uom,
			       block_description,
			       COALESCE(hd.settlement_date, hd.exp_date, trm.term_end) 
			       settlement_date,
			       dbo.FNADBUser(),
			       GETDATE(),
			       dbo.FNADBUser(),
			       GETDATE(),
			       12503,
			       sddt.location_id,
			       sddt.pay_opposite,
			       1,
			       1,
			       sddt.meter_id,
			       1,
			       sddt.pv_party,
			       sddt.profile_code,
			       sddt.category,
			       sddt.settlement_currency,
			       sddt.standard_yearly_volume,
			       sddt.price_uom_id,
			       sddt.formula,
			       sddt.option_strike_price,
			       sddt.price_adder,
			       sddt.fixed_cost,
			       sddt.formula_currency_id,			       
			       sddt.price_adder2, 
			       sddt.price_adder_currency2,
			       sddt.capacity
			FROM   #temp_transfer_book t
			       INNER JOIN (
			                SELECT curve_id,
			                       ROW_NUMBER() OVER(ORDER BY curve_id) leg
			                FROM   #temp_transfer_book
			                GROUP BY
			                       curve_id
			            ) idx
			            ON  t.curve_id = idx.curve_id
			       CROSS JOIN (
			                SELECT *
			                FROM   source_deal_detail_template
			                WHERE  leg = 1
			                       AND template_id = @template_id
			            )sddt
			       INNER JOIN source_deal_header_template sdht
			            ON  sddt.template_id = sdht.template_id
			       CROSS APPLY dbo.[FNATermBreakdown](sdht.term_frequency_type, t.term, @term_end) 
			trm 
			LEFT JOIN source_price_curve_def spcd
			            ON  spcd.source_curve_def_id = t.curve_id
			       LEFT JOIN holiday_group hd
			            ON  hd.hol_date = trm.term_start
			            AND spcd.exp_calendar_id = hd.hol_group_value_id
			       LEFT JOIN holiday_group hd2
			            ON  hd2.hol_date = dbo.FNAGetContractMonth(trm.term_start)
			            AND spcd.exp_calendar_id = hd2.hol_group_value_id
			       LEFT JOIN source_price_curve spc
			            ON  spc.source_curve_def_id = t.curve_id
			            AND spc.as_of_date = @as_of_date
			            AND spc.maturity_date = trm.term_start
			            AND spc.curve_source_value_id = 4500
			WHERE  ABS(volume) >= .001
			
			EXEC spa_print 'DETAIL'   
			
			UPDATE source_deal_header
			SET    close_reference_id = @new_header_id
			WHERE  source_deal_header_id = @deal_offset_id
			
			EXEC spa_print 'updated Offset'  
			
			UPDATE source_deal_header
			SET    deal_id = CAST(@new_header_id AS VARCHAR) + '-farrms_Xferred',
			       -- ext_deal_id = CAST(@deal_offset_id AS VARCHAR) + '-farrms_Offset',  
			       close_reference_id = @deal_offset_id
			WHERE  source_deal_header_id = @new_header_id      
			
			EXEC spa_print 'updated Xfer'   
		
			--## deal confirmation workflow
			SET @temp_source_deal_header_id = @temp_source_deal_header_id + ',' 
			    +
			    CAST(@new_header_id AS VARCHAR)  
			
			EXEC dbo.spa_callDealConfirmationRule @temp_source_deal_header_id,
			     19501,
			     NULL,
			     NULL 
			
			SET @sql = 'INSERT INTO ' + @report_position_deals +
			    '(source_deal_header_id,action)   
			SELECT ' + CAST(@new_header_id AS VARCHAR) + ',''i'''
			
			EXEC (@sql)  
			
			COMMIT     
			SET @temp_source_deal_header_id = COALESCE(@temp_source_deal_header_id + ',', '') 
			    + CAST(@new_header_id AS VARCHAR)
			
			SET @sql_stmt = 'spa_master_deal_view ''i'',''' + CAST(@new_header_id AS VARCHAR(200)) 
			    + ''''
			
			SET @job_name = 'update_master_deal_view_transfer' + @process_id
			EXEC spa_run_sp_as_job @job_name,
			     @sql_stmt,
			     'update_master_deal_view_transfer',
			     @user_login_id

			--EXEC spa_master_deal_view 'i', @temp_source_deal_header_id

			EXEC spa_insert_update_audit 'i',
			     @deal_offset_id
			
			EXEC spa_insert_update_audit 'i',
			     @new_header_id   
		END   
		SET @spa = 'spa_update_deal_total_volume NULL,''' + @process_id + ''',0,null,''' + @user_login_id + ''',''n'''
		
		SET @job_name = 'spa_update_deal_total_volume_' + @process_id   
		EXEC spa_run_sp_as_job @job_name,
		     @spa,
		     'spa_update_deal_total_volume',
		     @user_login_id   
		
		EXEC spa_ErrorHandler 0,
		     'Success',
		     'spa_transfer_book_position',
		     'Success',
		     'The positions have been successfully transferred.',
		     ''  
	    
	END TRY   
	BEGIN CATCH  
		 IF @@TRANCOUNT > 0  
			 ROLLBACK   
		   
		 DECLARE @err_no INT  
		 SELECT @err_no = ERROR_NUMBER()  
		   
		 EXEC spa_ErrorHandler @err_no,  
			  'Error',  
			  'spa_transfer_book_position',  
			  'Error',  
			  'Error in Position Transfer',  
			  ''  
	END CATCH   
  
 /************************************* Object: 'spa_transfer_book_position' END *************************************/ 
