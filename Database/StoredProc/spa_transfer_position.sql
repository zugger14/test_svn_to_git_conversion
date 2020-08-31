IF OBJECT_ID(N'[dbo].[spa_transfer_position]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[spa_transfer_position]
GO
 
SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO

/**
	Imbalance related operations. Trasnfer deal creation. Cashout deal creation.
	Parameters
	@from_contract_id		: From Contract ID
	@to_contract_id			: To Contract ID
	@from_date				: From Date
	@to_date				: To Date
	@source_book_mapping_id	: Sub book ID
	@volume					: Transfer Volume
	@counterparty_id		: Counterparty ID
	@is_create_cashout_deal	: Flag for cashout deal creation
	@cashout_volume			: Cashout Volume
	@nominated_volume		: Nominated Volume
	@actual_volume			: Actual Volume
	@cashout_percent		: Cashout Percent
	@location_id			: Location ID
*/
CREATE PROCEDURE [dbo].[spa_transfer_position]
	@from_contract_id INT = NULL,
	@to_contract_id INT = NULL,	
	@from_date DATETIME = NULL,
	@to_date DATETIME = NULL,
	@source_book_mapping_id INT = NULL,
	@volume FLOAT = NULL,
	@counterparty_id INT=null,
	@is_create_cashout_deal int=0,
	@cashout_volume numeric(30,5)=null,
	@nominated_volume numeric(30,5)=null,
	@actual_volume numeric(30,5)=null,
	@cashout_percent float=null,
	@location_id int=null
AS
SET NOCOUNT ON
/*
declare
	@from_contract_id INT = NULL,
	@to_contract_id INT = NULL,	
	@from_date DATETIME = NULL,
	@to_date DATETIME = NULL,
	@source_book_mapping_id INT = NULL,
	@volume FLOAT = NULL,
	@counterparty_id INT=null,
	@is_create_cashout_deal int=0,
	@cashout_volume numeric(30,5)=null,
	@nominated_volume numeric(30,5)=null,
	@actual_volume numeric(30,5)=null,
	@cashout_percent float=null,
	@location_id int=null

select @from_contract_id='8193',@to_contract_id='8193',@from_date='2018-06-30',@to_date='2018-07-01',@volume='-2000',@source_book_mapping_id='19',@counterparty_id='7724',@is_create_cashout_deal='0',@cashout_volume='',@nominated_volume='100000',@actual_volume='106000',@cashout_percent='',@location_id='2769'


--*/

BEGIN TRY
	
	DECLARE @sql                    VARCHAR(MAX)
	DECLARE @process_id             VARCHAR(100)  
	
	DECLARE @book_map_id1           INT
	DECLARE @book_map_id2           INT 
	DECLARE @book_map_id3           INT 
	DECLARE @book_map_id4           INT
	DECLARE @book_transfer_id       INT  
	DECLARE @new_header_id          INT  
	DECLARE @deal_offset_id         INT 
	DECLARE @report_position_deals  VARCHAR(300)
	DECLARE @user_login_id          VARCHAR(50)
	DECLARE @job_name               VARCHAR(500)
	
	DECLARE @term_from        DATETIME
	DECLARE @term_to          DATETIME
	DECLARE @deal_date_from   DATETIME
	DECLARE @deal_date_to     DATETIME
	DECLARE @as_of_date_from  DATETIME		
	DECLARE @as_of_date_to    DATETIME
	
	DECLARE @from_template_id       INT
	DECLARE @to_template_id         INT
	
	DECLARE @from_location_id       INT
	DECLARE @to_location_id         INT

	set @is_create_cashout_deal = isnull(@is_create_cashout_deal, 0)

	DECLARE @transferred_deal_sub_type_id INT 
	SELECT @transferred_deal_sub_type_id = sdt.source_deal_type_id
	FROM   source_deal_type sdt
	WHERE  sdt.source_deal_type_name = 'Imb Beg Bal' AND sdt.sub_type = 'y' 
	
	SELECT @from_template_id = max(gmv.clm7_value), @from_location_id = max(gmv.clm3_value)
	FROM generic_mapping_values gmv
	INNER JOIN generic_mapping_definition gmd ON  gmv.mapping_table_id = gmd.mapping_table_id
	INNER JOIN generic_mapping_header gmh ON  gmd.mapping_table_id = gmh.mapping_table_id
	WHERE gmh.mapping_name = 'Imbalance Deal' 
		AND gmv.clm9_value = CAST(@from_contract_id AS VARCHAR(10)) --match reporting contract
		and gmv.clm2_value = CAST(@counterparty_id AS VARCHAR(10)) --match counterparty
		and gmv.clm3_value = CAST(@location_id AS VARCHAR(10)) --match location
	
	SELECT @to_template_id = max(gmv.clm8_value), @to_location_id = max(gmv.clm3_value)
	FROM generic_mapping_values gmv
	INNER JOIN generic_mapping_definition gmd ON  gmv.mapping_table_id = gmd.mapping_table_id
	INNER JOIN generic_mapping_header gmh ON  gmd.mapping_table_id = gmh.mapping_table_id
	WHERE gmh.mapping_name = 'Imbalance Deal' 
		AND gmv.clm9_value = CAST(@to_contract_id AS VARCHAR(10)) --match reporting contract
		and gmv.clm2_value = CAST(@counterparty_id AS VARCHAR(10)) --match counterparty
		and gmv.clm3_value = CAST(@location_id AS VARCHAR(10)) --match location
	
	declare @template_id_imb_cashout int
	
	--GET IMBALANCE CASHOUT TEMPLATE FROM GENERIC MAPPING 'Imbalance Report', TYPE NAME 'Cash out', TO CREATE CASH OUT DEAL IF MENTIONED
	select @template_id_imb_cashout = max(clm3_value)
	FROM generic_mapping_values gmv
	INNER JOIN generic_mapping_definition gmd ON  gmv.mapping_table_id = gmd.mapping_table_id
	INNER JOIN generic_mapping_header gmh ON  gmd.mapping_table_id = gmh.mapping_table_id
	WHERE gmh.mapping_name = 'Imbalance Report' and gmv.clm2_value = 'Cash Out'

	--return if template id is null
	--IF(@from_template_id IS NULL OR @to_template_id IS NULL)
	IF(@from_template_id IS NULL)
	BEGIN
		EXEC spa_ErrorHandler -1
			   , 'Transfer Deal'
				, 'spa_transfer_position'
			   , 'Error'
			   , 'Gerneric mapping is not properly setup.'
			   , ''
		RETURN
	END	
	
	SET @term_from = dbo.FNALastDayInDate(@from_date)
	SET @term_to = @to_date
	SET @deal_date_from = @term_from
	SET @deal_date_to = @term_to
	SET @as_of_date_from = @term_from
	SET @as_of_date_to = @term_to
	
	SET @user_login_id = dbo.FNADBUser()  
	SET @process_id = REPLACE(NEWID(), '-', '_')
	SET @report_position_deals = dbo.FNAProcessTableName('report_position', @user_login_id, @process_id)  
	EXEC ('CREATE TABLE ' + @report_position_deals + '( source_deal_header_id INT, action CHAR(1))')  
	 	  
	SET @book_transfer_id = 1  

	SELECT @book_transfer_id = ISNULL(MAX(book_transfer_id), 0) + 1 FROM source_deal_header

	SELECT @book_map_id1 = ssbm.source_system_book_id1,
		   @book_map_id2 = ssbm.source_system_book_id2,
		   @book_map_id3 = ssbm.source_system_book_id3,
		   @book_map_id4 = ssbm.source_system_book_id4
	FROM   source_system_book_map ssbm
	WHERE  ssbm.book_deal_type_map_id = @source_book_mapping_id

	BEGIN TRAN 
	--goto cashoutdeal

	--ceate offset deal
	INSERT INTO source_deal_header (
		source_system_id,
		deal_id,
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
		contract_id
	  )
	SELECT 2,
	       @process_id,
	       @deal_date_from,
	       @from_template_id,
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
	       deal_status,
	       term_frequency_type,
	       option_exercise_type,
	       trader_id,
	       @counterparty_id,
	       sdht.physical_financial_flag,
	       @term_from,
	       @term_from,
	       @book_map_id1,
	       @book_map_id2,
	       @book_map_id3,
	       @book_map_id4,
	       dbo.FNADBUser(),
	       GETDATE(),
	       dbo.FNADBUser(),
	       GETDATE(),
	       CASE WHEN @volume > 0 THEN 's' ELSE 'b' END [header_buy_sell_flag],
	       12500,
	       sdht.book_transfer_id,
	       17200,
	       block_define_id,
	       @from_contract_id
	FROM   source_deal_header_template sdht
	LEFT JOIN source_deal_detail_template sddt ON  sddt.template_id = sdht.template_id
	WHERE  sdht.template_id = @from_template_id and @volume <> 0
		   
	--SELECT term_frequency_type,* FROM source_deal_header_template
	--SELECT * FROM source_deal_detail_template  
	IF @@ROWCOUNT > 0
		SET @new_header_id = IDENT_CURRENT('source_deal_header') --SCOPE_IDENTITY()
														  --select @new_header_id  
	EXEC spa_print 'INSERTED deal header - ', @new_header_id
		 --select * from #temp  
	EXEC spa_print 'new_id:', @new_header_id 

	INSERT INTO source_deal_detail (
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
	    formula_currency_id,
	    fixed_cost_currency_id,
	    adder_currency_id,
	    capacity,
	    deal_detail_description,
	    fixed_cost,
	    formula_curve_id,
		option_strike_price,
		price_adder,
		price_adder2,
		price_adder_currency2,
		settlement_uom,
		settlement_volume 
	  )
	SELECT @new_header_id,
	       @deal_date_from,
	       @deal_date_from,
	       sddt.leg,
	       @deal_date_from contract_expiration_date,
	       fixed_float_leg,
	       CASE WHEN @volume > 0 THEN 's' ELSE 'b' END [buy_sell_flag],
	       sddt.physical_financial_flag,
	       sddt.curve_id,
	      -- ISNULL(CAST(spc.curve_value AS NUMERIC(38, 20)), sddt.fixed_price) 
	      0 [fixed_price],
	       sddt.fixed_price_currency_id,
	       CASE WHEN @volume < 0 THEN @volume * -1 ELSE @volume END,
	       sddt.deal_volume_frequency,
	       sddt.deal_volume_uom_id,
	       block_description,
	       @deal_date_from,
	       dbo.FNADBUser(),
	       GETDATE(),
	       dbo.FNADBUser(),
	       GETDATE(),
	       12500,
	       isnull(@from_location_id,sddt.location_id),
	       sddt.pay_opposite,
	       ISNULL(sddt.multiplier, 1),
	       ISNULL(sddt.volume_multiplier2, 1),
	       sddt.meter_id,
	       ISNULL(sddt.price_multiplier, 1),
	       sddt.pv_party,
	       sddt.profile_code,
	       sddt.category,
	       sddt.settlement_currency,
	       sddt.standard_yearly_volume,
	       sddt.price_uom_id,
	       sddt.formula_id,
	       sddt.formula_currency_id,
	       sddt.fixed_cost_currency_id,
	       sddt.adder_currency_id,
	       sddt.capacity,
	       sddt.deal_detail_description,
	       sddt.fixed_cost,
	       sddt.formula_curve_id,
	       sddt.option_strike_price,
	       ISNULL(sddt.price_adder, 0),
	       ISNULL(sddt.price_adder2, 0),
	       sddt.price_adder_currency2,
	       sddt.settlement_uom,
	       sddt.settlement_volume
	FROM source_deal_detail_template sddt 
	INNER JOIN  source_deal_header_template sdht ON sddt.template_id = sdht.template_id  
	LEFT JOIN source_price_curve_def spcd ON spcd.source_curve_def_id = sddt.curve_id  
	LEFT JOIN source_price_curve spc ON spc.source_curve_def_id = spcd.source_curve_def_id  
		AND spc.as_of_date = @as_of_date_from  
		AND spc.maturity_date = @deal_date_from  
		AND spc.curve_source_value_id = 4500  
	WHERE @volume <> 0  AND sdht.template_id = @from_template_id  
			 
	SET @deal_offset_id = @new_header_id  
		
	UPDATE source_deal_header
	SET    deal_id = 'ICLO_' + CAST(@deal_offset_id AS VARCHAR) + '_offset'
	WHERE  source_deal_header_id = @deal_offset_id  

	SET @sql = 'INSERT INTO ' + @report_position_deals + '(source_deal_header_id,action) SELECT ' + CAST(@new_header_id AS VARCHAR) + ',''i'''  
	EXEC (@sql)  

	DECLARE @temp_source_deal_header_id VARCHAR(MAX)
	SET  @temp_source_deal_header_id = COALESCE(@temp_source_deal_header_id + ',', '') + CAST(@deal_offset_id AS VARCHAR)
	 
	 
	DECLARE @sql_stmt VARCHAR(MAX)
	SET @sql_stmt = 'spa_master_deal_view ''i'',''' + CAST(@deal_offset_id AS VARCHAR(200)) + ''''	 
	SET @job_name = 'update_master_deal_view_offset' + @process_id
	EXEC spa_run_sp_as_job @job_name, @sql_stmt, 'update_master_deal_view_offset', @user_login_id
		
	SET @new_header_id=NULL
	
	--create transfer deal		
	IF @to_template_id IS NOT NULL 
	BEGIN 		 
			 -- Transfer  
		INSERT INTO source_deal_header (
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
			contract_id
		  )
		SELECT 2,
			   @process_id,
			   @deal_date_to,
			   @to_template_id,
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
			   ISNULL(@transferred_deal_sub_type_id, deal_sub_type_type_id),
			   product_id,
			   internal_desk_id,
			   deal_status,
			   term_frequency_type,
			   option_exercise_type,
			   trader_id,
			   @counterparty_id,
			   sdht.physical_financial_flag,
			   @term_to,
			   @term_to,
			   @book_map_id1,
			   @book_map_id2,
			   @book_map_id3,
			   @book_map_id4,
			   dbo.FNADBUser(),
			   GETDATE(),
			   dbo.FNADBUser(),
			   GETDATE(),
			   CASE WHEN @volume > 0 THEN 'b' ELSE 's' END [buy_sell_flag],
			   12503,
			   sdht.book_transfer_id,
			   17200,
			   block_define_id,
			   @to_contract_id
		FROM   source_deal_header_template sdht
		LEFT JOIN source_deal_detail_template sddt ON  sddt.template_id = sdht.template_id
		WHERE  sdht.template_id = @to_template_id  and @volume <> 0
		
		IF @@ROWCOUNT > 0
			SET @new_header_id = IDENT_CURRENT('source_deal_header') --SCOPE_IDENTITY()  
		EXEC spa_print 'INSERTED'   
		EXEC spa_print 'new_id:', @new_header_id
			  
		INSERT INTO source_deal_detail (
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
			formula_currency_id,
			fixed_cost_currency_id,
			adder_currency_id,
			capacity,
			deal_detail_description,
			fixed_cost,
			formula_curve_id,
			option_strike_price,
			price_adder,
			price_adder2,
			price_adder_currency2,
			settlement_uom,
			settlement_volume 
		  )
		SELECT @new_header_id,
			   @deal_date_to,
			   @deal_date_to,
			   sddt.leg,
			   @deal_date_to contract_expiration_date,
			   fixed_float_leg,
			   CASE WHEN @volume > 0 THEN 'b' ELSE 's' END [buy_sell_flag],
			   sddt.physical_financial_flag,
			   sddt.curve_id,
			   ISNULL(CAST(spc.curve_value AS NUMERIC(38, 20)), sddt.fixed_price) [fixed_price],
			   sddt.fixed_price_currency_id,
			   CASE WHEN @volume < 0 THEN @volume * -1 ELSE @volume END,
			   sddt.deal_volume_frequency,
			   sddt.deal_volume_uom_id,
			   block_description,
			   @deal_date_to,
			   dbo.FNADBUser(),
			   GETDATE(),
			   dbo.FNADBUser(),
			   GETDATE(),
			   12500,
			   isnull(@to_location_id,sddt.location_id),
			   sddt.pay_opposite,
			   ISNULL(sddt.multiplier, 1),
			   ISNULL(sddt.volume_multiplier2, 1),
			   sddt.meter_id,
			   ISNULL(sddt.price_multiplier, 1),
			   sddt.pv_party,
			   sddt.profile_code,
			   sddt.category,
			   sddt.settlement_currency,
			   sddt.standard_yearly_volume,
			   sddt.price_uom_id,
			   sddt.formula_id,
			   sddt.formula_currency_id,
			   sddt.fixed_cost_currency_id,
			   sddt.adder_currency_id,
			   sddt.capacity,
			   sddt.deal_detail_description,
			   sddt.fixed_cost,
			   sddt.formula_curve_id,
			   sddt.option_strike_price,
			   ISNULL(sddt.price_adder, 0),
			   ISNULL(sddt.price_adder2, 0),
			   sddt.price_adder_currency2,
			   sddt.settlement_uom,
			   sddt.settlement_volume
		 FROM source_deal_detail_template sddt 
		INNER JOIN  source_deal_header_template sdht ON sddt.template_id = sdht.template_id  
		LEFT JOIN source_price_curve_def spcd ON spcd.source_curve_def_id = sddt.curve_id  
		LEFT JOIN source_price_curve spc ON spc.source_curve_def_id = spcd.source_curve_def_id  
			AND spc.as_of_date = @as_of_date_to  
			AND spc.maturity_date = @deal_date_to 
			AND spc.curve_source_value_id = 4500  
		WHERE @volume <> 0 AND sdht.template_id = @to_template_id  
			 
			 
		UPDATE source_deal_header
		SET    deal_id = 'ICLO_' + CAST(@new_header_id AS VARCHAR) + '_xfer',
			-- ext_deal_id = CAST(@deal_offset_id AS VARCHAR) + '-farrms_Offset',  
			close_reference_id = @deal_offset_id
		WHERE  source_deal_header_id = @new_header_id      

		EXEC spa_print 'updated Xfer'   		 
			 
			 
		UPDATE source_deal_header
		SET    close_reference_id = @new_header_id
		WHERE  source_deal_header_id = @deal_offset_id
		 
		EXEC spa_print 'updated Offset'
		  
		SET @temp_source_deal_header_id = @temp_source_deal_header_id + ',' + CAST(@new_header_id AS VARCHAR)  
	

	END 	
	
	/****** CASHOUT DEAL CREATE - START *****/
	--cashoutdeal:
	--return
	if @is_create_cashout_deal = 1 and @cashout_volume <> 0
	begin
	
		INSERT INTO source_deal_header (
			source_system_id,
			deal_id,
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
			contract_id
		  )
		SELECT 2,
			   @process_id,
			   @deal_date_from,
			   sdht.template_id,
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
			   deal_status,
			   term_frequency_type,
			   option_exercise_type,
			   trader_id,
			   @counterparty_id,
			   sdht.physical_financial_flag,
			   @term_from,
			   @term_from,
			   @book_map_id1,
			   @book_map_id2,
			   @book_map_id3,
			   @book_map_id4,
			   dbo.FNADBUser(),
			   GETDATE(),
			   dbo.FNADBUser(),
			   GETDATE(),
			   CASE WHEN @cashout_volume > 0 THEN 's' ELSE 'b' END [header_buy_sell_flag],
			   12500,
			   sdht.book_transfer_id,
			   17200,
			   block_define_id,
			   @from_contract_id
		FROM   source_deal_header_template sdht
		LEFT JOIN source_deal_detail_template sddt ON  sddt.template_id = sdht.template_id
		WHERE  sdht.template_id = @template_id_imb_cashout and @cashout_volume <> 0
		IF @@ROWCOUNT > 0
			SET @new_header_id = IDENT_CURRENT('source_deal_header') --SCOPE_IDENTITY()
															  --select @new_header_id  
		EXEC spa_print 'INSERTED deal header - ', @new_header_id
			 --select * from #temp  
		EXEC spa_print 'new_id:', @new_header_id 

		INSERT INTO source_deal_detail (
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
			formula_currency_id,
			fixed_cost_currency_id,
			adder_currency_id,
			capacity,
			deal_detail_description,
			fixed_cost,
			formula_curve_id,
			option_strike_price,
			price_adder,
			price_adder2,
			price_adder_currency2,
			settlement_uom,
			settlement_volume 
		  )
		SELECT @new_header_id,
			   @deal_date_from,
			   @deal_date_from,
			   sddt.leg,
			   @deal_date_from contract_expiration_date,
			   fixed_float_leg,
			   CASE WHEN @cashout_volume > 0 THEN 's' ELSE 'b' END [buy_sell_flag],
			   sddt.physical_financial_flag,
			   sddt.curve_id,
			   -- ISNULL(CAST(spc.curve_value AS NUMERIC(38, 20)), sddt.fixed_price) 
			   0 [fixed_price],
			   sddt.fixed_price_currency_id,
			   abs(@cashout_volume) [deal_volume],
			   sddt.deal_volume_frequency,
			   sddt.deal_volume_uom_id,
			   block_description,
			   @deal_date_from,
			   dbo.FNADBUser(),
			   GETDATE(),
			   dbo.FNADBUser(),
			   GETDATE(),
			   12500,
			   coalesce(@location_id,@from_location_id,sddt.location_id),
			   sddt.pay_opposite,
			   ISNULL(sddt.multiplier, 1),
			   ISNULL(sddt.volume_multiplier2, 1),
			   sddt.meter_id,
			   ISNULL(sddt.price_multiplier, 1),
			   sddt.pv_party,
			   sddt.profile_code,
			   sddt.category,
			   sddt.settlement_currency,
			   sddt.standard_yearly_volume,
			   sddt.price_uom_id,
			   sddt.formula_id,
			   sddt.formula_currency_id,
			   sddt.fixed_cost_currency_id,
			   sddt.adder_currency_id,
			   sddt.capacity,
			   sddt.deal_detail_description,
			   sddt.fixed_cost,
			   sddt.formula_curve_id,
			   sddt.option_strike_price,
			   ISNULL(sddt.price_adder, 0),
			   ISNULL(sddt.price_adder2, 0),
			   sddt.price_adder_currency2,
			   sddt.settlement_uom,
			   sddt.settlement_volume
		FROM source_deal_detail_template sddt 
		INNER JOIN  source_deal_header_template sdht ON sddt.template_id = sdht.template_id  
		LEFT JOIN source_price_curve_def spcd ON spcd.source_curve_def_id = sddt.curve_id  
		LEFT JOIN source_price_curve spc ON spc.source_curve_def_id = spcd.source_curve_def_id  
			AND spc.as_of_date = @as_of_date_from  
			AND spc.maturity_date = @deal_date_from  
			AND spc.curve_source_value_id = 4500  
		WHERE @cashout_volume <> 0  AND sdht.template_id = @template_id_imb_cashout  
		
		UPDATE source_deal_header
		SET    deal_id = 'IMB_CASHOUT_' + CAST(@new_header_id AS VARCHAR)
		WHERE  source_deal_header_id = @new_header_id  

		SET @sql = 'INSERT INTO ' + @report_position_deals + '(source_deal_header_id,action) SELECT ' + CAST(@new_header_id AS VARCHAR) + ',''i'''  
		EXEC (@sql)  

		SET @temp_source_deal_header_id = COALESCE(@temp_source_deal_header_id + ',', '') + CAST(@new_header_id AS VARCHAR)
	end
	
	/****** CASHOUT DEAL CREATE - END *****/

		
		--## deal confirmation workflow
	EXEC dbo.spa_callDealConfirmationRule @temp_source_deal_header_id, 19501, NULL, NULL
		 	
	IF @to_template_id IS NOT NULL 
	BEGIN 		 

		SET @sql = 'INSERT INTO ' + @report_position_deals + '(source_deal_header_id,action)   
			 SELECT ' + CAST(@new_header_id AS VARCHAR) + ',''i'''

		EXEC (@sql)   
		   
		EXEC spa_print 'ccccccccccccccccccccccccccccccc'
		SET @sql_stmt = 'spa_master_deal_view ''i'',''' + CAST(@new_header_id AS VARCHAR(200)) + ''''

		SET @job_name = 'update_master_deal_view_transfer' + @process_id
		EXEC spa_run_sp_as_job @job_name, @sql_stmt, 'update_master_deal_view_transfer', @user_login_id
	END 
	
	
	EXEC spa_print 'dddddddddddddddddddddddddddddddddd'
	EXEC spa_master_deal_view 'i', @temp_source_deal_header_id
	EXEC spa_print 'eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee'
	EXEC spa_insert_update_audit 'i', @deal_offset_id		 

	DECLARE @spa VARCHAR(MAX)
		 
	SET @spa = 'spa_update_deal_total_volume NULL,''' + @process_id + ''',0,null,''' + @user_login_id + ''',''n'''
		 
	SET @job_name = 'spa_update_deal_total_volume_' + @process_id   
	EXEC spa_run_sp_as_job @job_name, @spa, 'spa_update_deal_total_volume', @user_login_id 
	--SOME SQL INSERT, UPDATE or DELETE operations	
	EXEC spa_print 'fffffffffffffffffffffffffffffffffffffff'	
	EXEC spa_ErrorHandler 0
		, 'Transfer Deal'
		, 'spa_transfer_position'
		, 'Success' 
		, 'Successfully saved data.'
		, ''

	COMMIT
END TRY
BEGIN CATCH
	DECLARE @desc VARCHAR(500)
	DECLARE @err_no INT
 
	IF @@TRANCOUNT > 0
	   ROLLBACK
 
	SET @DESC = 'Fail to insert Data ( Errr Description:' + ERROR_MESSAGE() + ').'
 
	SELECT @err_no = ERROR_NUMBER()
 
	EXEC spa_ErrorHandler @err_no
	   , 'Transfer Deal'
		, 'spa_transfer_position'
	   , 'Error'
	   , @desc
	   , ''
END CATCH	 