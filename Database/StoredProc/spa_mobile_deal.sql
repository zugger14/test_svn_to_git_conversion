	IF OBJECT_ID(N'[dbo].[spa_mobile_deal]', N'P') IS NOT NULL
    	DROP PROCEDURE [dbo].[spa_mobile_deal]
    GO
    
    SET ANSI_NULLS ON
    GO
    
    SET QUOTED_IDENTIFIER ON
    GO
    
	/**
		Actions of deal to link with mobile application

		Parameters
		@flag : Flag
				'i' -- Inserts deal
				's' -- Select a deal
				'z' -- Search deals
				'd' -- Delete deal
				't' -- Select template
				'r' -- Lists traders
				'c' -- Lists counterparties
				'e' -- Lists contracts
				'o' -- Lists UOMs
				'l' -- Lists locations
				'v' -- Lists curves
				'k' -- Lists sub books
				'f' -- Lists frequencies
				'm' -- Lists commodities
				'p' -- Lists deal types
				'h' -- Get SSRS config from connection string
				'a' -- Gets term rule
		@sub_book_id : Subbook Id
		@deal_template_id : Deal template Id
		@deal_date : Deal date
		@location_id : Location Id
		@term_start : Term start
		@term_end : Term End
		@counterparty_id : Counterparty Id
		@buy_sell : Buy/Sell
		@deal_volume : Deal volume
		@deal_term : Term of deal
		@trader : Trader Id
		@contract : Contract
		@uom : UOM
		@fixed_price : Fixed Price
		@source_deal_header_id : Source deal header Id
		@curve_id : Curve Id
		@search_txt	: Text to search
		@runtime_user : Runtime user login Id
		@invoice_id : Invoice Id
		@paramset_id : Paramset Id
	*/
    CREATE PROCEDURE [dbo].[spa_mobile_deal](
    	@flag				CHAR(1) ,
    	@sub_book_id	    INT            = NULL , 
    	@deal_template_id	INT = NULL , 
    	@deal_date			VARCHAR(10) = NULL ,            
    	@location_id	    VARCHAR(10)    = NULL ,            
    	@term_start			VARCHAR(10) = NULL ,           
    	@term_end			VARCHAR(10) = NULL ,             
    	@counterparty_id	INT = NULL ,  
    	@buy_sell			CHAR(1) = NULL ,       
    	@deal_volume		NUMERIC(38,20) = NULL ,
    	@deal_term			INT = NULL,	    
   	@trader				INT = NULL,
   	@contract			INT = NULL,     
   	@uom				INT = NULL,
   	@fixed_price		NUMERIC(38,20) = NULL ,    
   	@source_deal_header_id INT = NULL,
   	@curve_id			INT = NULL ,
   	@search_txt			VARCHAR(1000) = NULL,
   	@runtime_user		VARCHAR(100)  = NULL,
   	@invoice_id INT = NULL,
   	@paramset_id INT = NULL
    )
    AS
    
    SET NOCOUNT ON
    
    IF ISNULL(@runtime_user, '') <> '' AND @runtime_user <> dbo.FNADBUser()   
 	BEGIN
 		--EXECUTE AS USER = @runtime_user;
 		DECLARE @contextinfo VARBINARY(128)
 		SELECT @contextinfo = CONVERT(VARBINARY(128), @runtime_user)
 		SET CONTEXT_INFO @contextinfo
 	END
    
    DECLARE @Sql_Select VARCHAR(5000)
    DECLARE @process_id VARCHAR(200)
    
    IF @flag = 'i'
    BEGIN
    	
    	SET @deal_date = CONVERT(VARCHAR(10), @deal_date, 102)
    	SET @term_start = CONVERT(VARCHAR(10), @term_start, 102)
    	SET @term_end = CONVERT(VARCHAR(10), @term_end, 102)	
    
    	SET @deal_volume = dbo.FNARemoveTrailingZeroes(@deal_volume)
    	SET @deal_volume = ROUND(@deal_volume,3)
    	
    
    	DECLARE @header             VARCHAR(MAX)
    	DECLARE @detail             VARCHAR(MAX)
    	DECLARE @xml                VARCHAR(MAX)	
    	DECLARE @field_template_id  INT
    	DECLARE @no_of_legs         INT
    	
    	SELECT @field_template_id = sdht.field_template_id
    	FROM source_deal_header_template sdht 
    	WHERE sdht.template_id = @deal_template_id
    	
    	SELECT @no_of_legs = MAX(leg)
    	FROM   source_deal_detail_template sddt
    	WHERE  sddt.template_id = @deal_template_id
    	
    	IF OBJECT_ID('tempdb..#header') IS NOT NULL
    	DROP TABLE #header
    	
    	IF OBJECT_ID('tempdb..#detail') IS NOT NULL
    		DROP TABLE #detail
    		
    	IF OBJECT_ID('tempdb..#header_xml') IS NOT NULL
    		DROP TABLE #header_xml
    		
    	IF OBJECT_ID('tempdb..#detail_xml') IS NOT NULL
    		DROP TABLE #detail_xml
    		
    	SELECT sddt.leg, mfd.farrms_field_id + '="' 
    					+ ISNULL(			
    						CASE WHEN sddt.leg > 1 THEN
    								CASE 
    									WHEN mfd.farrms_field_id = 'deal_id' THEN '__ignore__'
    									WHEN mfd.farrms_field_id = 'trader_id' THEN '__ignore__' 
    									WHEN mfd.farrms_field_id = 'deal_date' THEN 'undefined'
    									WHEN mfd.farrms_field_id = 'counterparty_id' THEN '__ignore__'
    									WHEN mfd.farrms_field_id = 'template_id' THEN CAST(@deal_template_id AS VARCHAR)
    									WHEN mfd.farrms_field_id = 'header_buy_sell_flag' THEN '__ignore__'
    									WHEN mfd.farrms_field_id = 'contract_id' THEN '__ignore__'
    									ELSE ISNULL(mftd.default_value,mftd.default_value) 
    								END
    							ELSE
    								CASE 
    								    WHEN mfd.farrms_field_id = 'sub_book' THEN CAST(@sub_book_id AS VARCHAR)
    									WHEN mfd.farrms_field_id = 'trader_id' THEN CAST(ISNULL(@trader ,sdht.trader_id) AS VARCHAR) 
    									WHEN mfd.farrms_field_id = 'deal_date' THEN CAST(@deal_date AS VARCHAR)
    									WHEN mfd.farrms_field_id = 'counterparty_id' THEN CAST(@counterparty_id AS VARCHAR)
    									WHEN mfd.farrms_field_id = 'template_id' THEN CAST(@deal_template_id AS VARCHAR)
    									WHEN mfd.farrms_field_id = 'header_buy_sell_flag' THEN CAST(@buy_sell AS VARCHAR)
    									WHEN mfd.farrms_field_id = 'contract_id' THEN CAST(@contract AS VARCHAR(10))
    									ELSE ISNULL(mftd.default_value,mftd.default_value)
    								END
    							END	
    						, '') + '"'	[farrms_field_id]
    	INTO #header				 
    	FROM maintain_field_deal mfd 
    	INNER JOIN maintain_field_template_detail mftd ON mfd.field_id = mftd.field_id
    		AND mftd.udf_or_system = 's'
    		AND mftd.field_template_id = @field_template_id
    		AND mftd.field_group_id IS NOT NULL
    	INNER JOIN source_deal_header_template sdht ON sdht.field_template_id = mftd.field_template_id
    		AND sdht.template_id = @deal_template_id
    	INNER JOIN source_deal_detail_template sddt ON sddt.template_id = sdht.template_id
    	WHERE mfd.farrms_field_id NOT IN('source_system_id', 'template_id','source_deal_header_id',
    								 'source_system_book_id1', 'source_system_book_id2', 'source_system_book_id3', 'source_system_book_id4',
    								 'physical_financial_flag', 'structured_deal_id', 'entire_term_start', 'entire_term_end',
    								 'source_deal_type_id', 'deal_sub_type_type_id', 'option_flag', 'deal_category_value_id', 'close_reference_id'	
    								)
    
    	IF OBJECT_ID('tempdb..#deal_detail_values') IS NOT NULL
    	DROP TABLE #deal_detail_values	
    		
    	SELECT Leg,
    		   Field,
    		   [Value]
    	INTO #deal_detail_values       
    	FROM   (
    				SELECT  CAST(leg                      AS VARCHAR(2000)) leg                      ,
    						CAST(template_detail_id       AS VARCHAR(2000)) template_detail_id       ,
    						CAST(fixed_float_leg          AS VARCHAR(2000)) fixed_float_leg          ,
    						CAST(buy_sell_flag            AS VARCHAR(2000)) buy_sell_flag            ,
    						CAST(curve_type               AS VARCHAR(2000)) curve_type               ,
    						CAST(curve_id                 AS VARCHAR(2000)) curve_id                 ,
    						CAST(deal_volume_frequency    AS VARCHAR(2000)) deal_volume_frequency    ,
    						CAST(deal_volume_uom_id       AS VARCHAR(2000)) deal_volume_uom_id       ,
    						CAST(currency_id              AS VARCHAR(2000)) currency_id              ,
    						CAST(block_description        AS VARCHAR(2000)) block_description        ,
    						CAST(template_id              AS VARCHAR(2000)) template_id              ,
    						CAST(commodity_id             AS VARCHAR(2000)) commodity_id             ,
    						CAST(day_count                AS VARCHAR(2000)) day_count                ,
    						CAST(physical_financial_flag  AS VARCHAR(2000)) physical_financial_flag  ,
    						CAST(location_id              AS VARCHAR(2000)) location_id              ,
    						CAST(meter_id                 AS VARCHAR(2000)) meter_id                 ,
    						CAST(strip_months_from        AS VARCHAR(2000)) strip_months_from        ,
    						CAST(lag_months               AS VARCHAR(2000)) lag_months               ,
    						CAST(strip_months_to          AS VARCHAR(2000)) strip_months_to          ,
    						CAST(conversion_factor        AS VARCHAR(2000)) conversion_factor        ,
    						CAST(pay_opposite             AS VARCHAR(2000)) pay_opposite             ,
    						CAST(formula                  AS VARCHAR(2000)) formula                  ,
    						CAST(settlement_currency      AS VARCHAR(2000)) settlement_currency      ,
    						CAST(standard_yearly_volume   AS VARCHAR(2000)) standard_yearly_volume   ,
    						CAST(price_uom_id             AS VARCHAR(2000)) price_uom_id             ,
    						CAST(category                 AS VARCHAR(2000)) category                 ,
    						CAST(profile_code             AS VARCHAR(2000)) profile_code             ,
    						CAST(pv_party                 AS VARCHAR(2000)) pv_party                 ,
    						CAST(adder_currency_id        AS VARCHAR(2000)) adder_currency_id        ,
    						CAST(booked                   AS VARCHAR(2000)) booked                   ,
    						CAST(capacity                 AS VARCHAR(2000)) capacity                 ,
    						CAST(day_count_id             AS VARCHAR(2000)) day_count_id             ,
    						CAST(deal_detail_description  AS VARCHAR(2000)) deal_detail_description  ,
    						CAST(fixed_cost               AS VARCHAR(2000)) fixed_cost               ,
    						CAST(fixed_cost_currency_id   AS VARCHAR(2000)) fixed_cost_currency_id   ,
    						CAST(formula_currency_id      AS VARCHAR(2000)) formula_currency_id      ,
    						CAST(formula_curve_id         AS VARCHAR(2000)) formula_curve_id         ,
    						CAST(formula_id               AS VARCHAR(2000)) formula_id               ,
    						CAST(multiplier               AS VARCHAR(2000)) multiplier               ,
    						CAST(option_strike_price      AS VARCHAR(2000)) option_strike_price      ,
    						CAST(price_adder              AS VARCHAR(2000)) price_adder              ,
    						CAST(price_adder_currency2    AS VARCHAR(2000)) price_adder_currency2    ,
    						CAST(price_adder2             AS VARCHAR(2000)) price_adder2             ,
    						CAST(price_multiplier         AS VARCHAR(2000)) price_multiplier         ,
    						CAST(process_deal_status      AS VARCHAR(2000)) process_deal_status      ,
    						CAST(settlement_date          AS VARCHAR(2000)) settlement_date          ,
    						CAST(settlement_uom           AS VARCHAR(2000)) settlement_uom           ,
    						CAST(settlement_volume        AS VARCHAR(2000)) settlement_volume        ,
    						CAST(volume_left              AS VARCHAR(2000)) volume_left              ,
    						CAST(volume_multiplier2       AS VARCHAR(2000)) volume_multiplier2       ,
    						CAST(term_start               AS VARCHAR(2000)) term_start               ,
    						CAST(term_end                 AS VARCHAR(2000)) term_end                 ,
    						CAST(contract_expiration_date AS VARCHAR(2000)) contract_expiration_date ,
    						CAST(fixed_price              AS VARCHAR(2000)) fixed_price              ,
    						CAST(fixed_price_currency_id  AS VARCHAR(2000)) fixed_price_currency_id  ,
    						CAST(deal_volume              AS VARCHAR(2000)) deal_volume              
    				FROM   source_deal_detail_template
    				WHERE  template_id = @deal_template_id
    	) p
    	UNPIVOT(Value FOR Field IN (template_detail_id, fixed_float_leg, buy_sell_flag, curve_type, curve_id, deal_volume_frequency, deal_volume_uom_id
    								, currency_id, block_description, template_id, commodity_id, day_count, physical_financial_flag, location_id
    								, meter_id, strip_months_from, lag_months, strip_months_to, conversion_factor, pay_opposite, formula
    								, settlement_currency, standard_yearly_volume, price_uom_id, category, profile_code, pv_party
    								, adder_currency_id, booked, capacity, day_count_id, deal_detail_description, fixed_cost, fixed_cost_currency_id
    								, formula_currency_id, formula_curve_id, formula_id, multiplier, option_strike_price, price_adder
    								, price_adder_currency2, price_adder2, price_multiplier, process_deal_status, settlement_date, settlement_uom
    								, settlement_volume, volume_left, volume_multiplier2, term_start, term_end, contract_expiration_date
    								, fixed_price, fixed_price_currency_id, deal_volume
    	)
    	) AS unpvt;
    		
    	SELECT sddt.leg, 
    			mfd.farrms_field_id + '="' 
    					+ ISNULL(
    								CASE  
    									WHEN mfd.farrms_field_id = 'term_start' THEN CAST(@term_start AS VARCHAR)
    									WHEN mfd.farrms_field_id = 'term_end' THEN CAST(@term_end AS VARCHAR)						
    									WHEN mfd.farrms_field_id = 'buy_sell_flag' THEN CAST(@buy_sell AS VARCHAR)
    									WHEN mfd.farrms_field_id = 'deal_volume' THEN CAST(@deal_volume AS VARCHAR)
    							WHEN mfd.farrms_field_id = 'location_id' THEN CAST(@location_id AS VARCHAR)
    									ELSE 
    										CASE 
    											WHEN mfd.farrms_field_id = 'fixed_price' THEN dbo.FNARemoveTrailingZeroes(COALESCE(@fixed_price ,mftd.default_value,mftd.default_value,ddv.Value))
    											WHEN mfd.farrms_field_id = 'contract_expiration_date' THEN ''
    											ELSE COALESCE(mftd.default_value,mftd.default_value,ddv.Value)
    										END 
    								END											
    						, '') + '"'	[farrms_field_id]
    	INTO #detail
    	FROM maintain_field_deal mfd 
    	INNER JOIN maintain_field_template_detail mftd ON mfd.field_id = mftd.field_id
    		AND mftd.udf_or_system = 's'
    		AND mftd.field_template_id = @field_template_id	
    		AND mftd.field_group_id IS NULL
    	INNER JOIN source_deal_header_template sdht ON sdht.field_template_id = mftd.field_template_id
    		AND sdht.template_id = @deal_template_id
    	INNER JOIN source_deal_detail_template sddt ON sddt.template_id = sdht.template_id
    	LEFT JOIN #deal_detail_values ddv ON ddv.Leg = sddt.leg
    		AND ddv.Field = mfd.farrms_field_id
    	WHERE mfd.farrms_field_id NOT IN ('fixed_float_leg')
    	
    	SELECT Leg, (
    		SELECT ' ' + farrms_field_id FROM #header j WHERE j.Leg = i.Leg
    		FOR XML PATH(''), TYPE).value('.[1]', 'VARCHAR(8000)'		
    	) [header] 
    	INTO #header_xml
    	FROM #header i  
    	GROUP BY Leg 
    
    	SELECT Leg, (
    		SELECT ' ' + farrms_field_id FROM #detail j WHERE j.Leg = i.Leg
    		FOR XML PATH(''), TYPE).value('.[1]', 'VARCHAR(8000)'		
    	) [detail] 
    	INTO #detail_xml
    	FROM #detail i 
    	GROUP BY Leg
    	
    	--SELECT * FROM #header_xml hx
    	--SELECT * FROM #detail_xml dx 
    	
    	SELECT @xml = STUFF((
    		SELECT ' ' + '<PSRecordset>' + 
    					'<header' + hx.header + ' row_id="' + CAST(dx.Leg AS VARCHAR) + '" blotter_value="1__' + CAST(dx.Leg AS VARCHAR) + '"/>' +
    					'<detail ' + dx.detail + ' row_id="' + CAST(dx.Leg AS VARCHAR) + '" blotter_value="1__' + CAST(dx.Leg AS VARCHAR) + '"/>' +
    				'</PSRecordset>' 
    		FROM #header_xml hx
    		INNER JOIN #detail_xml dx ON dx.Leg = hx.Leg
    	FOR XML PATH(''), TYPE).value('.[1]', 'VARCHAR(5000)'), 1, 1, '')
    
    
    	SET @xml = '<Root>' + @xml + '</Root>'
    	--set @xml = '<Root><PSRecordset><header sub_book="106" deal_id="" deal_date="2014-10-22" counterparty_id="1706" trader_id="47" header_buy_sell_flag="b" contract_id="14" deal_status="5604" confirm_status_type="17200" create_ts="" create_user="" update_ts="" update_user="" internal_desk_id="17300" commodity_id="123" deal_locked="n" block_define_id="" pricing="" description1="" description2="" description3="" broker_id="" timezone_id="" broker_fixed_cost="" back_office_sign_off_by="" row_id="1" blotter_value="1__1"/><detail  term_start="2014-11-01" term_end="2014-11-30" contract_expiration_date="" buy_sell_flag="b" curve_id="292" fixed_price="100.00" fixed_price_currency_id="1" deal_volume="100.00000000000000000000" deal_volume_frequency="h" deal_volume_uom_id="4" physical_financial_flag="p" source_deal_detail_id="" Leg="" total_volume="" price_adder="" pay_opposite="y" settlement_date="Jan  1 1900 12:00AM" price_multiplier="" fixed_cost="" lock_deal_detail="n" status="" multiplier="" price_adder2="" row_id="1" blotter_value="1__1"/></PSRecordset></Root>'
    
    	--PRINT @deal_template_id
    	--PRINT ','
    	--PRINT @xml	
    
    	BEGIN TRY
    		EXEC spa_InsertDealXmlBlotterV2 'i', NULL, @deal_template_id, @xml			
    	END TRY
    	BEGIN CATCH				
    		EXEC spa_ErrorHandler 1, 'Mobile Deal Insert', 'spa_mobile_deal', 'Error', 'Incorrect XML supplied.', ''
            RETURN        
    	END CATCH		
    END
    
    IF @flag = 's'
    BEGIN
    	--EXEC spa_sourcedealtemp_detail 'g', NULL, @source_deal_header_id, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, @deal_template_id
    	
    	DECLARE @sub_book_id_str VARCHAR(2000) = '0'
    		
    	SELECT
         @sub_book_id_str = @sub_book_id_str + ',' + CAST(ssbm.book_deal_type_map_id AS VARCHAR(10))
   	FROM   portfolio_hierarchy book(NOLOCK)
   	INNER JOIN Portfolio_hierarchy stra(NOLOCK)
   		ON  book.parent_entity_id = stra.entity_id
   	INNER JOIN portfolio_hierarchy sub (NOLOCK)
   		ON  stra.parent_entity_id = sub.entity_id
   	INNER JOIN source_system_book_map ssbm
   		ON  ssbm.fas_book_id = book.entity_id
   	-- EXEC spa_mobile_deal 's'
   	
   	/*
   	IF OBJECT_ID('tempdb..#temp_source_deal_header') IS NOT NULL
   				DROP TABLE #temp_source_deal_header
   		
   		
   		CREATE TABLE #temp_source_deal_header (
   			[source_deal_header_id] INT,
   			[deal_id] VARCHAR(500) COLLATE DATABASE_DEFAULT  ,
   			[deal_date] DATETIME,	
   			[buy_sell] VARCHAR(10) COLLATE DATABASE_DEFAULT  ,
   			[physical_financial_flag] VARCHAR(20) COLLATE DATABASE_DEFAULT  ,
   			[commodity] VARCHAR(200) COLLATE DATABASE_DEFAULT  ,
   			[trader] VARCHAR(200) COLLATE DATABASE_DEFAULT  ,
   			[counterparty] VARCHAR(200) COLLATE DATABASE_DEFAULT  ,
   			[contract] VARCHAR(200) COLLATE DATABASE_DEFAULT  ,
   			[term_start] DATETIME,
   			[term_end] DATETIME,
   			[template_name] VARCHAR(200) COLLATE DATABASE_DEFAULT  ,
   			[deal_type] VARCHAR(200) COLLATE DATABASE_DEFAULT  ,
   			[deal_sub_type] VARCHAR(200) COLLATE DATABASE_DEFAULT  ,
   			[location_index] VARCHAR(200) COLLATE DATABASE_DEFAULT  ,
   			[deal_volume] NUMERIC(38,20),
   			[deal_volume_uom_id] VARCHAR(200) COLLATE DATABASE_DEFAULT   ,
   			[formula_curve_id] VARCHAR(200) COLLATE DATABASE_DEFAULT  ,
   			[deal_price] NUMERIC(38,20),
   			[currency] VARCHAR(200) COLLATE DATABASE_DEFAULT  ,
   			[deal_value] NUMERIC(38,20),
   			[estimate_final] VARCHAR(200) COLLATE DATABASE_DEFAULT  ,
   			[deal_status] VARCHAR(200) COLLATE DATABASE_DEFAULT  ,
   			[confirm_status] VARCHAR(200) COLLATE DATABASE_DEFAULT  ,
   			[deal_lock] VARCHAR(200) COLLATE DATABASE_DEFAULT  ,
   			[create_date] DATETIME,
   			[create_user] VARCHAR(200) COLLATE DATABASE_DEFAULT  ,
   			[update_date] DATETIME,
   			[update_user] VARCHAR(200) COLLATE DATABASE_DEFAULT  ,
   			[delete_ts] DATETIME,
   			[delete_user] VARCHAR(200) COLLATE DATABASE_DEFAULT  ,
   			[notes_id] VARCHAR(200) COLLATE DATABASE_DEFAULT  ,
   			[sub_book] VARCHAR(200) COLLATE DATABASE_DEFAULT  ,
   			[subsidiary] VARCHAR(200) COLLATE DATABASE_DEFAULT  ,
   			[strategy] VARCHAR(200) COLLATE DATABASE_DEFAULT  ,
   			[book] VARCHAR(200) COLLATE DATABASE_DEFAULT  ,
   			[percentage_included] FLOAT
   		)
   		*/
   	
   	SET @process_id = dbo.FNAGetNewID()
   	DECLARE @mobile_deals_table VARCHAR(100)
  	DECLARE @mobile_user_login_id VARCHAR(100) = dbo.FNADBUser()
  		
  	SET @mobile_deals_table = + dbo.FNAProcessTableName('mobile_deals', @mobile_user_login_id,@process_id)
  	
  	DECLARE @source_deal_header_id_from VARCHAR(20) = ''
  	DECLARE @source_deal_header_id_to VARCHAR(20) = ''
  	
  	IF @source_deal_header_id IS NOT NULL
  	BEGIN
  		SET @source_deal_header_id_from = CAST(@source_deal_header_id AS VARCHAR(20))
  		SET @source_deal_header_id_to = @source_deal_header_id_from
  	END
  	
   	SET @Sql_Select =' 	
    				EXEC spa_source_deal_header @flag=''s''
   					,@filter_xml=''<Root><FormXML view_detail="y" view_voided="n" filter_mode="a" book_ids="" source_system_book_id1="" source_system_book_id2="" source_system_book_id3="" source_system_book_id4="" sub_book_ids="' + ISNULL(@sub_book_id_str,'') + '" trader_id="" counterparty_id="" contract_id="" broker_id="" source_deal_header_id_from="' + @source_deal_header_id_from + '" source_deal_header_id_to="' + @source_deal_header_id_to + '" deal_id="" view_deleted="n" show_unmapped_deals="n" generator_id="" location_group_id="" location_id="" curve_id="" Index_group_id="" formula_curve_id="" formula_id="" deal_type_id="" deal_sub_type_id="" field_template_id="" template_id="" commodity_id="" physical_financial_id="" product_id="" internal_desk_id="" deal_volume_uom_id="" buy_sell_id="" deal_date_from="" deal_date_to="" term_start="" term_end="" settlement_date_from="" settlement_date_to="" payment_date_from="" payment_date_to="" deal_status="" confirm_status_type="" calc_status="" invoice_status="" deal_locked="" create_ts_from="" create_ts_to="" create_user="" update_ts_from="" update_ts_to="" update_user=""></FormXML></Root>''
   					,@process_id= ''' + ISNULL(@process_id, '') + '''
   					,@call_from = ''mobile''
   					
   					SELECT 
   						*
   					 FROM ' + ISNULL(@mobile_deals_table, '') + '
   					
   					DROP TABLE ' + ISNULL(@mobile_deals_table, '') + '
   					'
   
  	EXEC(@Sql_Select)
  	  
    END
    
    IF @flag = 'z'  -- search deals
    BEGIN
    	
    --		DECLARE @sub_book_id_str1 VARCHAR(2000) = '0'
    		
    --		SELECT
 			--@sub_book_id_str1 = @sub_book_id_str1 + ',' + CAST(ssbm.book_deal_type_map_id AS VARCHAR(10))
   	--	FROM   portfolio_hierarchy book(NOLOCK)
   	--	INNER JOIN Portfolio_hierarchy stra(NOLOCK)
   	--		ON  book.parent_entity_id = stra.entity_id
   	--	INNER JOIN portfolio_hierarchy sub (NOLOCK)
   	--		ON  stra.parent_entity_id = sub.entity_id
   	--	INNER JOIN source_system_book_map ssbm
   	--		ON  ssbm.fas_book_id = book.entity_id
   		
   		
    		--SET @process_id = dbo.FNAGetNewID()
   		--DECLARE @mobile_deals_table1 VARCHAR(100)
  		--DECLARE @mobile_user_login_id1 VARCHAR(100) = dbo.FNADBUser()
  		
  		IF OBJECT_ID('tempdb..#temp_search_deal') IS NOT NULL
  				DROP TABLE #temp_search_deal
  		
  		
  		CREATE TABLE #temp_search_deal (
  			[process_table] VARCHAR(100) COLLATE DATABASE_DEFAULT  ,
  			record_number INT,
  			[object_id] VARCHAR(100) COLLATE DATABASE_DEFAULT  ,
  			[object_name] VARCHAR(100) COLLATE DATABASE_DEFAULT  ,
  			[details] VARCHAR(4000) COLLATE DATABASE_DEFAULT  ,
  			[search_within_search] VARCHAR(200) COLLATE DATABASE_DEFAULT  ,
  			[detail_table] VARCHAR(500) COLLATE DATABASE_DEFAULT  
  		)
 		
 		--SET @mobile_deals_table1 = + dbo.FNAProcessTableName('mobile_deals', @mobile_user_login_id1,@process_id)
 		
 		
 		INSERT #temp_search_deal
 		EXEC spa_search_engine  @flag='s', @searchString = @search_txt , @searchTables='deal',    @callFrom='s' 
 		
 		DECLARE  @detail_table VARCHAR(500)
 		SELECT  @detail_table  = detail_table FROM #temp_search_deal
 		
  		
  		DROP TABLE #temp_search_deal
  		
  		SET @Sql_Select =' SELECT TOP 20 
  									*
  									INTO #tmp_mobile_deal_search
  									 FROM  ' + @detail_table	+ ' 
  									ORDER By CAST(create_ts AS DATE) DESC, CAST(update_ts AS DATE) DESC, source_deal_header_id DESC
  									
  									
  									SELECT 
  									tmds.source_deal_header_id,
  									MAX(tmds.deal_id) deal_id, 
  									
  									dbo.FNADateFormat(MAX(tmds.deal_date)) deal_date, 
  									
  									MAX(tmds.buy_sell) buy_sell,
  									MAX(tmds.physical_financial) physical_financial, 
  									MAX(tmds.commodity) [commodity],
  									MAX(tmds.trader) [trader],
  									MAX(tmds.counterparty) counterparty,
  									MAX(tmds.[CONTRACT]) contract, 									
  									
  									dbo.FNADateFormat(MAX(tmds.entire_term_start)) entire_term_start, dbo.FNADateFormat(MAX(tmds.entire_term_end)) entire_term_end,
  									MAX(tmds.template) [template],
  									MAX(tmds.deal_type) [deal_type],
  									MAX(tmds.deal_sub_type) [deal_sub_type], 
  									MAX(tmds.location) [location],
 									
 									case MAX(dd.deal_volume_frequency)
    										when ''h'' then ''Hourly''
    										when ''d'' then ''Daily''
    										when ''m'' then ''Monthly''
    										when ''a'' then ''Annually''
    										when ''t'' then ''Term''
    										else null
    										  end [deal_volume_frequency_name],							
 									[dbo].[FNARemoveTrailingZeroes](MAX(dd.deal_volume) * CASE WHEN MAX(dd.buy_sell_flag)=''b'' THEN 1 ELSE -1 END) deal_volume,
 									MAX(su.uom_id) [uom_name], 									
 									MAX(tmds.index_name) [curve_name],
 									[dbo].[FNARemoveTrailingZeroes](ISNULL(ABS(ISNULL(MAX(dd.fixed_price),(COALESCE(MAX(ds.settlement_amount), MAX(dp.und_pnl_set))/NULLIF(ISNULL(MAX(ds.sds_volume), MAX(dp.dp_volume)), 0)))),0)) deal_price,
 									CASE WHEN ISNULL(MAX(dd.fixed_price),(COALESCE(MAX(ds.settlement_amount), MAX(dp.und_pnl_set))/NULLIF(ISNULL(MAX(ds.sds_volume), MAX(dp.dp_volume)), 0))) IS NULL THEN NULL ELSE MAX(scur.currency_id) END [Currency],
 									MAX(tmds.deal_status) [deal_status],
 									MAX(sdv_confirm.code) [confirm_status_type],
 									CASE WHEN MAX(tmds.locked_deal) = ''y'' THEN ''Yes'' ELSE ''No'' END [deal_lock],
 									dbo.FNADateFormat(MAX(tmds.create_ts)) create_ts,
 									MAX(tmds.create_user) [create_user],
 									dbo.FNADateFormat(MAX(tmds.update_ts)) update_ts,
 									MAX(tmds.update_user) [update_user],
 									 									
									CASE WHEN MAX(tmds.source_system_book_id4) like ''None%'' THEN MAX(tmds.source_system_book_id1) ELSE MAX(tmds.source_system_book_id4) END [sub_book_name] 									 									
 									--MAX(ISNULL(tmds.source_system_book_id4, tmds.source_system_book_id1)) [sub_book_name]
    									
  									FROM
  									 #tmp_mobile_deal_search tmds
  									 OUTER APPLY (SELECT TOP(1) * FROM source_deal_detail dd WHERE dd.source_deal_header_id = tmds.source_deal_header_id AND leg = 1 ORDER BY term_start) dd
  									 LEFT JOIN source_uom AS su ON su.source_uom_id = dd.deal_volume_uom_id
  									 LEFT JOIN source_currency AS scur ON scur.source_currency_id = dd.fixed_price_currency_id
  									 LEFT JOIN (
 										SELECT sds.source_deal_header_id, 
 											   sum(settlement_amount) settlement_amount, 
 											   SUM(volume) sds_volume
 										FROM source_deal_settlement sds 
 										GROUP BY sds.source_deal_header_id
 									  ) ds ON ds.source_deal_header_id = tmds.source_deal_header_id
 									  LEFT JOIN (
 										SELECT sdp.source_deal_header_id, 
 											   sum(und_pnl_set) und_pnl_set,
 											   SUM(deal_volume) dp_volume
 										FROM source_deal_pnl sdp 
 										GROUP BY sdp.source_deal_header_id
 									  ) dp ON dp.source_deal_header_id = tmds.source_deal_header_id
 									  OUTER APPLY (
										SELECT TOP(1) csr.type 
										FROM confirm_status_recent csr
										WHERE csr.source_deal_header_id = tmds.source_deal_header_id
										ORDER BY csr.create_ts DESC 
									  ) csr
									  LEFT JOIN static_data_value sdv_confirm ON sdv_confirm.value_id = ISNULL(csr.type,17200)
  									GROUP BY tmds.source_deal_header_id
  									ORDER By CAST(MAX(tmds.create_ts) AS DATE) DESC, CAST(MAX(tmds.update_ts) AS DATE) DESC, tmds.source_deal_header_id DESC
  									
  									
  									DROP TABLE ' + @detail_table	+ '
  									 ' 		
  	
  		/*
  		SET @Sql_Select =' 	
    				EXEC spa_source_deal_header @flag=''s''
   					,@filter_xml=''<Root><FormXML filter_mode="g" search_text="' + ISNULL(@search_txt,'') + '" sub_book_ids="' + ISNULL(@sub_book_id_str,'') + '"></FormXML></Root>''
   					,@process_id= ''' + ISNULL(@process_id, '') + '''
   					,@call_from = ''mobile''
   					
   					SELECT 
   						*
   					 FROM ' + ISNULL(@mobile_deals_table1, '') + '
   					
   					DROP TABLE ' + ISNULL(@mobile_deals_table1, '') + '
   					'
 		*/
 		--PRINT(@Sql_Select)
  	EXEC(@Sql_Select) 	
    		
    END	
    
    IF @flag = 'd'
    BEGIN
  	SET @Sql_Select ='EXEC spa_source_deal_header @flag=''d'', @deal_ids=''' + CAST(@source_deal_header_id AS VARCHAR(10)) + ''''
  	EXEC(@Sql_Select)
    END
    
    --IF @flag = 't'
    --BEGIN
    	
    --	IF OBJECT_ID('tempdb..#deal_templates') IS NOT NULL
    --		DROP TABLE #deal_templates
    
    --	CREATE TABLE #deal_templates
    --	(
    --		TemplateID                      INT,
    --		TemplateName                    VARCHAR(1000) COLLATE DATABASE_DEFAULT ,
    --		source_system_id                INT,
    --		header_buy_sell_flag            CHAR(1) COLLATE DATABASE_DEFAULT ,
    --		option_flag                     CHAR(1) COLLATE DATABASE_DEFAULT ,
    --		term_frequency_type             CHAR(1) COLLATE DATABASE_DEFAULT ,
    --		option_type                     CHAR(1) COLLATE DATABASE_DEFAULT ,
    --		option_exercise_type            VARCHAR(10) COLLATE DATABASE_DEFAULT ,
    --		internal_deal_subtype_value_id  INT
    --	)
    --	INSERT INTO #deal_templates EXEC spa_getDealTemplate 'x'
    	
    --	SELECT TemplateID,
    --	       TemplateName,
    --	       sdht.counterparty_id [CounterpartyID],
    --	       sdht.contract_id [ContractID],
    --	       sdht.trader_id [TraderID],
    --		   sddt.location_id [LocationID],
    --		   sddt.deal_volume_uom_id [Uom]
    		   
    		   
    --	FROM   #deal_templates dt
    --	LEFT JOIN source_deal_header_template sdht ON sdht.template_id = dt.TemplateID
    --	LEFT JOIN source_deal_detail_template sddt ON sddt.template_id = dt.TemplateID
    --	WHERE dt.TemplateName LIKE '%Mobile%'
    	
    --	DROP TABLE #deal_templates
    	
    --END
    
    IF @flag = 't'
    BEGIN
    	SELECT 
    		DISTINCT
    	  sdht.template_id, 
    	  sdht.template_name,
    	  sdht.physical_financial_flag,
    	  case sdht.physical_financial_flag
    		when 'p' then 'Physical'
    	when 'f' then 'Financial'
    	  end physical_financial_flag_name,
    	  ssbm.book_deal_type_map_id [sub_book], 
		  ssbm.logical_name [sub_book_name], 
    	  sdht.trader_id, 
    	  st.trader_name,
    	  sdht.counterparty_id, 
    	  sc.counterparty_name,
    	  sdht.contract_id, 
    	  cg.contract_name,
    	  sdht.header_buy_sell_flag, 
    	  case sdht.header_buy_sell_flag
    		when 'b' then 'Buy'
    		when 's' then 'Sell'
    	else null
    	  end header_buy_sell_flag_name, 
    	  CONVERT(VARCHAR(10), isnull(sdht.deal_date, dbo.FNAResolveDate(CONVERT(DATE, GETDATE()),  sdht.deal_date_rule)), 120) [deal_date], 
    	  CONVERT(VARCHAR(10), dbo.FNAResolveDate(isnull(sdht.deal_date, dbo.FNAResolveDate(CONVERT(DATE, GETDATE()),  sdht.deal_date_rule)), sdht.term_rule), 120) [entire_term_start], 
    	  --CONVERT(VARCHAR(10), dbo.FNAResolveDate(isnull(sdht.deal_date, dbo.FNAResolveDate(CONVERT(DATE, GETDATE()),  sdht.deal_date_rule)), sdht.term_rule), 120) [entire_term_end], 
 	  CONVERT(VARCHAR(10), CASE sdht.term_frequency_type WHEN 't' THEN dbo.FNAResolveDate(isnull(sdht.deal_date, dbo.FNAResolveDate(CONVERT(DATE, GETDATE()),  sdht.deal_date_rule)), sdht.term_rule) ELSE dbo.FNAGetTermEndDate(sdht.term_frequency_type, dbo.FNAResolveDate(isnull(sdht.deal_date, dbo.FNAResolveDate(CONVERT(DATE, GETDATE()),  sdht.deal_date_rule)), sdht.term_rule), 0) END, 120) [entire_term_end],
 	   
    	  sddt.location_id,
    	  sml.location_name,
    
    	  sddt.curve_id, -- index
    	  spcd.curve_name,
    	  dbo.FNARemoveTrailingZeroes(sddt.deal_volume) deal_volume, 
    	  sddt.deal_volume_uom_id,
    	  su.uom_name,
    	  sddt.deal_volume_frequency,
    	  case sddt.deal_volume_frequency
    		when 'h' then 'Hourly'
    	when 'd' then 'Daily'
    	when 'm' then 'Monthly'
    	when 'a' then 'Annually'
    	when 't' then 'Term'
    	else null
    	  end deal_volume_frequency_name
  	,sdt.source_deal_type_id
	,sdt.source_deal_type_name
  	,sdt.deal_type_id
  	,sc2.source_commodity_id [commodity_id]
  	,sc2.commodity_id [commodity_name]
  	,sddt.leg leg
  	,dbo.FNARemoveTrailingZeroes(sddt.fixed_price) fixed_price
  	,sddt.fixed_price_currency_id fixed_price_currency_id
  	,sddt.fixed_float_leg
  	,sddt.formula_curve_id 	
  	
    	FROM source_deal_header_template sdht
    		inner join source_deal_detail_template sddt
    		on sdht.template_id = sddt.template_id
    		LEFT JOIN maintain_field_template mft ON mft.field_template_id = sdht.field_template_id
			LEFT join maintain_field_deal mfd on mfd.farrms_field_id = 'sub_book'
			LEFT JOIN maintain_field_template_detail mftd ON mft.field_template_id = mftd.field_template_id AND  mfd.field_id = mftd.field_id
			
			left join source_system_book_map ssbm on ssbm.book_deal_type_map_id = CAST(mftd.default_value as int)
    		LEFT JOIN deal_template_privilages sdp ON sdp.deal_template_id = sdht.template_id
    		left join source_traders st on sdht.trader_id = st.source_trader_id
    		left join source_counterparty sc on sc.source_counterparty_id = sdht.counterparty_id
    		left join contract_group cg on cg.contract_id = sdht.contract_id
    		left join source_minor_location sml on sml.source_minor_location_id = sddt.location_id
    		left join source_price_curve_def spcd on spcd.source_curve_def_id = sddt.curve_id
    		left join source_uom su on su.source_uom_id = sddt.deal_volume_uom_id
  		LEFT JOIN source_deal_type sdt ON sdt.source_deal_type_id = sdht.source_deal_type_id
  		LEFT JOIN source_commodity AS sc2 ON sc2.source_commodity_id = sdht.commodity_id
    	WHERE 
    	sdht.template_id = ISNULL(@deal_template_id,sdht.template_id)
    	AND 
    	mft.is_mobile = 'y' AND mft.active_inactive = 'y'
    	AND (dbo.FNAIsUserOnAdminGroup(dbo.FNADBUser(), 1) = 1 OR sdp.[user_id] = dbo.FNADBUser() OR sdp.role_id IN (SELECT role_id FROM dbo.FNAGetUserRole(dbo.FNADBUser())) OR sdht.create_user = dbo.FNADBUser())
    	ORDER BY sdht.template_name
    	
    END
    
    --REFERENCES TRMTracker_New_Framework_Branch.dbo.maintain_field_template (field_template_id)
    
    IF @flag = 'r' 
    BEGIN
    	SELECT source_trader_id [trader_id], trader_name 
    	FROM dbo.source_traders 
    	WHERE source_trader_id = ISNULL(@trader, source_trader_id)
    	ORDER BY trader_name
    END
    
    IF @flag = 'c' -- counterparty list
  	BEGIN
  		IF OBJECT_ID('tempdb..#temp_source_counterparty') IS NOT NULL
  				DROP TABLE #temp_source_counterparty
  		
  		CREATE TABLE #temp_source_counterparty (
  			[counterparty_id] INT,
  			[counterparty_name] VARCHAR(500) COLLATE DATABASE_DEFAULT  	
  		)
		
		IF EXISTS(SELECT 1 FROM deal_fields_mapping dfm	INNER JOIN source_counterparty sc ON sc.source_counterparty_id = dfm.counterparty_id WHERE dfm.template_id = @deal_template_id)
		BEGIN
			INSERT #temp_source_counterparty
			SELECT sc.source_counterparty_id, 
					CASE WHEN sc.source_system_id = 2 THEN ''
					ELSE ssd.source_system_name + '.'
					END +
					CASE WHEN sc.counterparty_id <> sc.counterparty_name THEN sc.counterparty_id + ' - ' + sc.counterparty_name  
					ELSE sc.counterparty_name 
					END [counterparty]
			FROM deal_fields_mapping dfm
			LEFT JOIN source_counterparty sc ON sc.source_counterparty_id = dfm.counterparty_id
			INNER JOIN source_system_description ssd ON ssd.source_system_id = sc.source_system_id
			WHERE template_id = @deal_template_id
		END
		ELSE
		BEGIN
  			INSERT #temp_source_counterparty
  				EXEC spa_getsourcecounterparty 's'
  		END
			
  		SELECT * FROM #temp_source_counterparty
  			WHERE counterparty_id = ISNULL(@counterparty_id, counterparty_id)
   		ORDER BY counterparty_name
  	END
  
  IF @flag = 'e' -- for contract list.
  BEGIN
  	
  	IF OBJECT_ID('tempdb..#temp_source_contract_detail') IS NOT NULL
  				DROP TABLE #temp_source_contract_detail
  		
  		CREATE TABLE #temp_source_contract_detail (
  			[contract_id] INT,
  			[contract_name] VARCHAR(500) COLLATE DATABASE_DEFAULT ,
  			[status] VARCHAR(20) COLLATE DATABASE_DEFAULT  	 	
  		)
		
		IF EXISTS(SELECT 1 FROM deal_fields_mapping_contracts dfmc
			inner JOIN deal_fields_mapping dfm ON dfm.deal_fields_mapping_id = dfmc.deal_fields_mapping_id
			WHERE dfm.template_id = @deal_template_id AND dfm.counterparty_id = @counterparty_id)
		BEGIN
			INSERT #temp_source_contract_detail
			SELECT dfmc.contract_id [ID], 
					CASE WHEN cg.source_contract_id <> cg.[contract_name] THEN cg.source_contract_id + ' - ' + cg.contract_name 
					ELSE cg.contract_name END + 
					CASE WHEN cg.source_system_id = 2 THEN ''
					ELSE CASE WHEN cg.source_system_id IS NOT NULL THEN  '.' + ssd.source_system_name ELSE '' END
					END [Name],
					'' [status]
			FROM deal_fields_mapping_contracts dfmc
			LEFT JOIN deal_fields_mapping dfm ON dfm.deal_fields_mapping_id = dfmc.deal_fields_mapping_id
			LEFT JOIN contract_group cg ON cg.contract_id = dfmc.contract_id
			LEFT JOIN source_system_description ssd ON  ssd.source_system_id = cg.source_system_id
			WHERE dfm.template_id = @deal_template_id AND dfm.counterparty_id = @counterparty_id
		END
		ELSE IF EXISTS(SELECT 1 FROM deal_fields_mapping_contracts dfmc
			inner JOIN deal_fields_mapping dfm ON dfm.deal_fields_mapping_id = dfmc.deal_fields_mapping_id
			WHERE dfm.template_id = @deal_template_id)
		BEGIN
			INSERT #temp_source_contract_detail
			SELECT dfmc.contract_id [ID], 
					CASE WHEN cg.source_contract_id <> cg.[contract_name] THEN cg.source_contract_id + ' - ' + cg.contract_name 
					ELSE cg.contract_name END + 
					CASE WHEN cg.source_system_id = 2 THEN ''
					ELSE CASE WHEN cg.source_system_id IS NOT NULL THEN  '.' + ssd.source_system_name ELSE '' END
					END [Name],
					'' [status]
			FROM deal_fields_mapping_contracts dfmc
			LEFT JOIN deal_fields_mapping dfm ON dfm.deal_fields_mapping_id = dfmc.deal_fields_mapping_id
			LEFT JOIN contract_group cg ON cg.contract_id = dfmc.contract_id
			LEFT JOIN source_system_description ssd ON  ssd.source_system_id = cg.source_system_id
			WHERE dfm.template_id = @deal_template_id
		END
		BEGIN
  			INSERT #temp_source_contract_detail
  				EXEC spa_source_contract_detail 'r', @is_active= 'y', @counterparty_id = @counterparty_id
  		END
			
  		SELECT * FROM #temp_source_contract_detail
  			WHERE contract_id = ISNULL(@contract, contract_id)
   		ORDER BY contract_name 		
  END
  
  IF @flag = 'o' --uom list
  BEGIN
  	IF OBJECT_ID('tempdb..#temp_source_uom') IS NOT NULL
  			DROP TABLE #temp_source_uom
  		
  	CREATE TABLE #temp_source_uom (
  		[deal_volume_uom_id] INT,
  		[uom_name] VARCHAR(500) COLLATE DATABASE_DEFAULT 
  	)
  
  	INSERT #temp_source_uom
  		EXEC spa_getsourceuom @flag = 's'
  			
  	SELECT * FROM #temp_source_uom
  		--WHERE [deal_volume_uom_id] = ISNULL(@uom, [deal_volume_uom_id])
   	ORDER BY [uom_name] 
  END
  
  IF @flag = 'l' --location list
  BEGIN
  	IF OBJECT_ID('tempdb..#temp_source_minor_location') IS NOT NULL
  			DROP TABLE #temp_source_minor_location
  		
  	CREATE TABLE #temp_source_minor_location (
  		[location_id] INT,
  		[location_name] VARCHAR(500) COLLATE DATABASE_DEFAULT ,
  		[status] VARCHAR(20) COLLATE DATABASE_DEFAULT  	 	
  	)
  
  	INSERT #temp_source_minor_location
  		EXEC spa_source_minor_location 'o', @is_active = 'y'
  			
  	SELECT * FROM #temp_source_minor_location
  		WHERE location_id = ISNULL(@location_id, location_id)
   	ORDER BY [location_name] 
  END
  
  IF @flag = 'v' --curve list
  BEGIN
  	IF OBJECT_ID('tempdb..#temp_price_curve') IS NOT NULL
  			DROP TABLE #temp_price_curve
  		
  	CREATE TABLE #temp_price_curve (
  		[curve_id] INT,
  		[curve_name] VARCHAR(500) COLLATE DATABASE_DEFAULT , 	
		[status] VARCHAR(10) COLLATE DATABASE_DEFAULT  
  	)
  
  	INSERT #temp_price_curve
  		EXEC spa_source_price_curve_def_maintain @flag='l', @is_active='y'
  			
  	SELECT [curve_id], [curve_name] FROM #temp_price_curve
  		WHERE curve_id = ISNULL(@curve_id, curve_id)
   	ORDER BY [curve_name] 
  END
  
  IF @flag = 'k' --sub-book list
  BEGIN	
  	SELECT
        ssbm.book_deal_type_map_id [sub_book]
        ,ssbm.logical_name sub_book_name
  FROM   portfolio_hierarchy book(NOLOCK)
  INNER JOIN Portfolio_hierarchy stra(NOLOCK)
  	ON  book.parent_entity_id = stra.entity_id
  INNER JOIN portfolio_hierarchy sub (NOLOCK)
  	ON  stra.parent_entity_id = sub.entity_id
  INNER JOIN source_system_book_map ssbm
  	ON  ssbm.fas_book_id = book.entity_id
  	WHERE ssbm.book_deal_type_map_id = ISNULL(@sub_book_id, ssbm.book_deal_type_map_id)
  	ORDER BY ssbm.logical_name
  END
  
  
  IF @flag = 'f' --volume frequncy list
  BEGIN
  	IF OBJECT_ID('tempdb..#temp_volume_frequency') IS NOT NULL
  			DROP TABLE #temp_volume_frequency
  		
  	CREATE TABLE #temp_volume_frequency (
  		[id] CHAR(1) COLLATE DATABASE_DEFAULT ,
  		[name] VARCHAR(500) COLLATE DATABASE_DEFAULT  	
  	)
  
  	INSERT #temp_volume_frequency
  		EXEC  spa_getVolumeFrequency NULL,NULL
  			
  	SELECT [id] [deal_volume_frequency], [name] [deal_volume_frequency_name]  FROM #temp_volume_frequency 	
   	ORDER BY [deal_volume_frequency_name] 
  END
  
  
  IF @flag = 'm' --commodity list
  BEGIN
  	IF OBJECT_ID('tempdb..#temp_commodity') IS NOT NULL
  			DROP TABLE #temp_commodity
  		
  	CREATE TABLE #temp_commodity (
  		[commodity_id] INT,
  		[commodity_name] VARCHAR(500) COLLATE DATABASE_DEFAULT ,
  		[status] VARCHAR(20) COLLATE DATABASE_DEFAULT  	 	
  	)
  
  	INSERT #temp_commodity
  		EXEC spa_source_commodity_maintain 'a'
  			
  	SELECT [commodity_id], [commodity_name]  FROM #temp_commodity 	
   	ORDER BY [commodity_name] 
  END
  
  IF @flag = 'p' --deal type list
  BEGIN
  	IF OBJECT_ID('tempdb..#temp_deal_type') IS NOT NULL
  			DROP TABLE #temp_deal_type
  		
  	CREATE TABLE #temp_deal_type (
  		[source_deal_type_id] INT,
  		[source_deal_type_name] VARCHAR(500) COLLATE DATABASE_DEFAULT ,
  		[status] VARCHAR(20) COLLATE DATABASE_DEFAULT  	 	
  	)
  
  	INSERT #temp_deal_type
  		EXEC spa_source_deal_type_maintain 'x'
  			
  	SELECT [source_deal_type_id], [source_deal_type_name]  FROM #temp_deal_type 	
   	ORDER BY [source_deal_type_name] 
  END
  
  
  IF @flag = 'h' --get ssrs config if deal id or invoice id exists
  BEGIN
  	IF EXISTS (SELECT 1 FROM source_deal_header WHERE source_deal_header_id = @source_deal_header_id 
  				UNION
  				SELECT 1 FROM Calc_invoice_Volume_variance WHERE calc_id = @invoice_id 
  				UNION
  				SELECT 1 FROM report_paramset WHERE report_paramset_id = @paramset_id
  	)
  	BEGIN
  		EXEC spa_connection_string 'r'
  	END
	ELSE IF @paramset_id IS NOT NULL
		EXEC spa_connection_string 'r'
	ELSE
		EXEC spa_connection_string 'r'
  END
  IF @flag = 'a'
  BEGIN
	  IF OBJECT_ID('tempdb..#temp_term_start_end') IS NOT NULL
  				DROP TABLE #temp_term_start_end
  
  		CREATE TABLE #temp_term_start_end (
  			[entire_term_start] DATE,
  			[entire_term_end] DATE
 
  		)
  
  	INSERT #temp_term_start_end
	EXEC spa_blotter_deal @flag='t', @template_id = @deal_template_id, @deal_date=@deal_date

	SELECT [entire_term_start],[entire_term_end], 'NEW' [dealId] FROM #temp_term_start_end
  END
