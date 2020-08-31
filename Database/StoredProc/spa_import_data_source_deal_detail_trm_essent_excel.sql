
IF OBJECT_ID('spa_import_data_source_deal_detail_trm_essent_excel', 'p') IS NOT NULL
    DROP PROCEDURE spa_import_data_source_deal_detail_trm_essent_excel
GO 
  
-- ===========================================================================================================  
-- Author: ssingh@pioneersolutionsglobal.com  
-- Create date: 2012-08-01  
-- Modified date : 2013-01-18
-- Description: procedure to insert the values from the staging table to a final staging table(including removed cloumns from the import file)
--				with value from source_deal_header_template and source_deal_detail_template when the data passed in the import file is NULL.  
-- Params:  
-- @PathFileName VARCHAR(MAX): name of the adhiha staging table   
--  @table_no  VARCHAR(100): table no.  
-- @job_name VARCHAR(100) : name of the job  
-- @process_id VARCHAR(50):process_id  
-- @user_login_id VARCHAR(50): user logged in   
-- ===========================================================================================================  
  
CREATE PROCEDURE [dbo].[spa_import_data_source_deal_detail_trm_essent_excel]  
	 @PathFileName		VARCHAR(MAX), 
	 @table_no			VARCHAR(100),  
	 @job_name			VARCHAR(100),  
	 @process_id		VARCHAR(50),  
	 @user_login_id		VARCHAR(50) = 'farrms_admin'  
AS   
BEGIN  
	DECLARE @sql				VARCHAR(MAX)  
	DECLARE @finaltemptablename VARCHAR(200)
	  
	SET @finaltemptablename=dbo.FNAProcessTableName('source_deal_detail_trm_final', @user_login_id, @process_id)  
   
	SET @sql='CREATE TABLE '+ @finaltemptablename + '(  
		 [source_system_id] [varchar] (100), 
		 [deal_id] [varchar] (100),  
		 [physical_financial_flag] [varchar] (100),  
		 [counterparty_id] [varchar] (100), 
		 [source_deal_type_id] [varchar] (100), 
		 [source_deal_sub_type_id] [varchar] (100),  
		 [option_flag] [varchar] (100),  
		 [option_type] [varchar] (100),  
		 [option_excercise_type] [varchar] (100),  
		 [broker_id] [varchar] (100),  
		 [unit_fixed_flag] [varchar] (100),  
		 [broker_unit_fees] [varchar] (100),  
		 [broker_fixed_cost] [varchar] (100),  
		 [broker_currency_id] [varchar] (250), --scur  
		 [term_frequency] [varchar] (100), 
		 [option_settlement_date] [varchar](50),  
		 [ext_deal_id] [varchar] (100),  
		 [source_system_book_id1] [varchar] (100),  
		 [source_system_book_id2] [varchar] (100),  
		 [source_system_book_id3] [varchar] (100),  
		 [source_system_book_id4] [varchar] (100),  
		 [description1] [varchar] (260), 
		 [description2] [varchar] (260), 
		 [description3] [varchar] (260), 
		 [deal_category_value_id] [varchar] (100),  
		 [trader_id] [varchar] (100),  
		 [header_buy_sell_flag] [varchar] (100),  
		 [contract_id] [varchar] (100),  
		 legal_entity varchar(100),   
		 internal_desk_id [varchar] (100),   
		 product_id [varchar] (100),  
		 internal_portfolio_id [varchar] (100),  
		 commodity_id [varchar] (100),   
		 reference varchar(250),  
		 [block_type] [varchar] (100),  
		 [close_reference_id] varchar(50), 
		 [block_define_id] [varchar] (100), --sdv  
		 [granularity_id] [varchar] (100), --sdv  
		 [Pricing] [varchar] (100), --sdv  
		 [deal_status] varchar(50),  
		 [block_description] [varchar] (260),  
		 [structured_deal_id] [varchar] (100),  
		 [template] [varchar] (250),  
		 [deal_date] [varchar] (100),  
		 [term_start] [varchar] (100),  
		 [term_end] [varchar] (100),  
		 [Leg] [varchar] (100),  
		 [contract_expiration_date] [varchar] (100), 
		 [fixed_float_leg] [varchar] (100),  
		 [buy_sell_flag] [varchar] (100),  
		 [curve_id] [varchar] (100),  
		 [fixed_price] [varchar] (100),     
		 [fixed_price_currency_id] [varchar] (100),  
		 [option_strike_price] [varchar] (100),  
		 [deal_volume] float,    
		 [deal_volume_frequency] [varchar] (100),  
		 [deal_volume_uom_id] [varchar] (100),  
		 [deal_detail_description] [varchar] (260),  
		 [formula_id] [varchar] (100),  
		 [price_adder] [varchar] (100),  
		 [price_multiplier] [varchar] (100),  
		 [settlement_volume] float,    
		 [settlement_uom] [varchar] (100), 
		 [settlement_date] [varchar] (100),  
		 [day_count_id] [varchar] (100),    
		 [location_id] [varchar] (250),   
		 [meter_id] [varchar] (250),     
		 [physical_financial_flag_detail] [varchar] (100) , 
		 [fixed_cost] [varchar] (100),  
		 [multiplier] numeric (38,20),  
		 [adder_currency_id] varchar(50),  
		 [fixed_cost_currency_id] varchar(50),  
		 [formula_currency_id] varchar(50), 
		 [price_adder2] numeric(38,20),  
		 [price_adder_currency2] varchar(50), 
		 [volume_multiplier2] numeric(38,20),  
		 [pay_opposite] varchar(1),  
		 [capacity] numeric(38,20), 
		 [settlement_currency] varchar(50),  
		 [standard_yearly_volume] float, 
		 [price_uom_id] varchar(50),  
		 [category] varchar(50),  
		 [profile_code] varchar(50),  
		 [pv_party] varchar(100),  
		 [Intrabook_deal_flag] char(2),  
		 [deal_seperator_id] varchar(100))'  
	EXEC spa_print @sql  
	EXEC(@sql)  
	
	BEGIN TRY
		CREATE TABLE #date_format_check (
			[deal_date] VARCHAR(50) COLLATE DATABASE_DEFAULT,  
			[term_start] VARCHAR(50) COLLATE DATABASE_DEFAULT,  
			[term_end] VARCHAR(50) COLLATE DATABASE_DEFAULT,  
			[contract_expiration_date]VARCHAR(50) COLLATE DATABASE_DEFAULT,	
			[settlement_date]VARCHAR(50) COLLATE DATABASE_DEFAULT
		)
		SET @sql = 
			'INSERT INTO #date_format_check 
			SELECT [dbo].[FNAClientToSqlDate](deal_date)
				,[dbo].[FNAClientToSqlDate](term_start)
				,[dbo].[FNAClientToSqlDate](term_end)
				,[dbo].[FNAClientToSqlDate](contract_expiration_date)
				,[dbo].[FNAClientToSqlDate](settlement_date)
			 FROM
			 ' + @PathFileName 
		EXEC spa_print @sql
		EXEC(@sql)
	
	END TRY
	BEGIN CATCH
		DECLARE @error_msg  VARCHAR(1000)
		DECLARE @error_code VARCHAR(5)
		DECLARE  @url_desc  VARCHAR(250)
		DECLARE @desc  VARCHAR(1000)
		
		
		SET @error_msg = 'Error: ' + ERROR_MESSAGE()
		SET @error_code = 'e'
		EXEC spa_print @error_msg
		
		INSERT INTO source_system_data_import_status (
			process_id,
			code,
			MODULE,
			[source],
			[TYPE],
			[description],
			recommendation
		  )
		  EXEC (
				 'SELECT DISTINCT ' 
				 + '''' + @process_id + '''' + ',' 
				 + '''Error'''  + ',' 
				 + '''Import Data''' + ',' 
				 + '''source_deal_header''' + ',' 
				 +  '''Import''' + ',' 
				 + '''' + @error_msg + '''' + ',' + 
				 '''Please check if the date format provided matches the Users Date format.''' + 
				 ' FROM ' + @PathFileName
		  )
		  
		SELECT @url_desc = './dev/spa_html.php?__user_name__=' + @user_login_id +
			   '&spa=exec spa_get_import_process_status ''' + @process_id + ''',''' 
			   + @user_login_id + ''''
		
		SELECT @desc = '<a target="_blank" href="' + @url_desc + '">' +
			   	'Import process Completed for as of date:' + dbo.FNAUserDateFormat(GETDATE(), @user_login_id) + 
			   CASE 
					WHEN (@error_code = 'e') THEN ' (ERRORS found)'
					ELSE ''
			   END +  ' </a>'
		
		EXEC spa_NotificationUserByRole 2, @process_id, 'Import Data', @desc , @error_code, @job_name, 1
		
		RETURN
	END CATCH	
  
	SET @sql = 'INSERT INTO ' +  @finaltemptablename +   
		 '(  
		 [source_system_id], 
		 [deal_id],  
		 [physical_financial_flag],  
		 [counterparty_id], 
		 [source_deal_type_id], 
		 [source_deal_sub_type_id],  
		 [option_flag],  
		 [option_type],  
		 [option_excercise_type],  
		 [broker_id],  
		 [unit_fixed_flag], 
		 [broker_unit_fees], 
		 [broker_fixed_cost], 
		 [broker_currency_id],  
		 [term_frequency], 
		 [option_settlement_date], 
		 [ext_deal_id],  
		 [source_system_book_id1],  
		 [source_system_book_id2],  
		 [source_system_book_id3],  
		 [source_system_book_id4],  
		 [description1], 
		 [description2], 
		 [description3], 
		 [deal_category_value_id],  
		 [trader_id],  
		 [header_buy_sell_flag],  
		 [contract_id], 
		 legal_entity,  
		 internal_desk_id,  
		 product_id, 
		 internal_portfolio_id, 
		 commodity_id,  
		 reference, 
		 [block_type], 
		 [close_reference_id],  
		 [block_define_id],  
		 [granularity_id],  
		 [Pricing],  
		 [deal_status], 
		 [block_description],  
		 [structured_deal_id],  
		 [template], 
		 [deal_date],  
		 [term_start],  
		 [term_end],  
		 [Leg],  
		 [contract_expiration_date], 
		 [fixed_float_leg],  
		 [buy_sell_flag],  
		 [curve_id],  
		 [fixed_price],    
		 [fixed_price_currency_id],  
		 [option_strike_price],  
		  [deal_volume],    
		 [deal_volume_frequency],  
		 [deal_volume_uom_id],  
		 [deal_detail_description],  
		 [formula_id],  
		 [price_adder], 
		 [price_multiplier], 
		 [settlement_volume], 
		 [settlement_uom], 
		 [settlement_date], 
		 [day_count_id],   
		 [location_id],  
		 [meter_id],    
		 [physical_financial_flag_detail], 
		 [fixed_cost], 
		 [multiplier], 
		 [adder_currency_id], 
		 [fixed_cost_currency_id], 
		 [formula_currency_id],  
		 [price_adder2], 
		 [price_adder_currency2],  
		 [volume_multiplier2], 
		 [pay_opposite], 
		 [capacity], 
		 [settlement_currency], 
		 [standard_yearly_volume], 
		 [price_uom_id], 
		 [category], 
		 [profile_code], 
		 [pv_party], 
		 [Intrabook_deal_flag], 
		 [deal_seperator_id]   
		 )  
	   SELECT   
		 a.[source_system_id],  
		 CASE WHEN Intrabook_deal_flag = ''T'' THEN ISNULL(a.deal_id,''$xfr$_'' + a.deal_seperator_id)  
		 WHEN Intrabook_deal_flag = ''O'' THEN ISNULL(a.deal_id,''$off$_'' + a.deal_seperator_id)   
		 ELSE ISNULL(a.deal_id,''$tmp$_'' + a.deal_seperator_id) END   AS [deal_id],   
		 ISNULL(a.physical_financial_flag, sdht.physical_financial_flag) AS [physical_financial_flag],   
		 a.[counterparty_id],  
		 ISNULL(a.source_deal_type_id, sdt.deal_type_id) AS [source_deal_type_id], 
		 ISNULL(a.source_deal_sub_type_id, sdt2.deal_type_id) AS [source_deal_sub_type_id],   
		 sdht.option_flag AS [option_flag], --removed   
		 NULL  AS [option_type], --removed  
		 NULL  AS [option_excercise_type],--removed  
		 a.[broker_id] AS [broker_id],  
		 NULL  AS [unit_fixed_flag],--removed  
		 NULL  AS [broker_unit_fees],--removed  
		 NULL  AS [broker_fixed_cost],--removed  
		 NULL  AS [broker_currency_id],--removed   
		 a.[term_frequency],  
		 NULL  AS [option_settlement_date],--removed  
		 NULL  AS [ext_deal_id],--removed  
		 a.[source_system_book_id1],   
		 a.[source_system_book_id2],   
		 a.[source_system_book_id3],   
		 a.[source_system_book_id4],   
		 a.[description1],  
		 a.[description2],  
		 a.[description3],  
		 ISNULL(sdv_deal_category.value_id, sdht.deal_category_value_id) AS [deal_category_value_id],   
		 a.[trader_id],   
		 ISNULL(a.header_buy_sell_flag,sdht.header_buy_sell_flag) AS [header_buy_sell_flag],   
		 ISNULL(a.contract_id, cg.source_contract_id) AS [contract_id],  
		 a.legal_entity,  
		 ISNULL(a.internal_desk_id, sdv_internal_desk.code) AS [internal_desk_id],   
		 ISNULL(a.product_id, sdv_product_id.code)as [product_id],  
		 ISNULL(a.internal_portfolio_id,sip.internal_portfolio_id) AS [internal_portfolio_id],  
		 ISNULL(a.commodity_id, sc.commodity_id) AS [commodity_id],   
		 a.reference,  
		 NULL  AS [block_type],--removed  
		 a.[close_reference_id],  
		 ISNULL(a.block_define_id, sdv_block_define.code) AS [block_define_id],  
		 ISNULL(a.[granularity_id], sdv_granularity.code) as [granularity_id],  
		 ISNULL(a.Pricing, sdv_pricing.code) AS [Pricing],  
		 ISNULL(sdv_dealstatus_a.value_id, sdv_dealstatus.value_id) AS [deal_status], 
		 NULL  AS [block_description], --removed  
		 a.[structured_deal_id],  
		 a.[template], 
		 dbo.FNAGetSQLStandardDate([dbo].[FNAClientToSqlDate](a.deal_date))AS [deal_date],
		 dbo.FNAGetSQLStandardDate([dbo].[FNAClientToSqlDate](a.term_start))AS [term_start], 
		 dbo.FNAGetSQLStandardDate([dbo].[FNAClientToSqlDate](a.term_end))AS [term_end], 
		 ISNULL(a.leg, sddt.leg)AS [Leg],  
		 dbo.FNAGetSQLStandardDate([dbo].[FNAClientToSqlDate](a.term_end))AS [contract_expiration_date],
		 ISNULL(a.fixed_float_leg, sddt.fixed_float_leg) AS [fixed_float_leg],  
		 ISNULL(a.buy_sell_flag, sddt.buy_sell_flag)AS [buy_sell_flag],  
		 ISNULL(a.curve_id,spcd.curve_id) AS [curve_id],  
		 a.[fixed_price],    
		 ISNULL(a.fixed_price_currency_id, sc_currency_id.currency_id) AS [fixed_price_currency_id],  
		 a.[option_strike_price],  
		 a.[deal_volume],    
		 ISNULL(a.deal_volume_frequency, sddt.deal_volume_frequency) AS [deal_volume_frequency],  
		 ISNULL(a.deal_volume_uom_id, su.uom_id ) AS [deal_volume_uom_id],  
		 NULL  AS [deal_detail_description],--removed  
		 a.[formula_id],  
		 a.[price_adder], 
		 ISNULL(a.price_multiplier, 1) AS [price_multiplier], 
		 NULL  AS [settlement_volume],--removed  
		 NULL  AS [settlement_uom],--removed  
		 dbo.FNAGetSQLStandardDate([dbo].[FNAClientToSqlDate](a.term_end))AS [settlement_date],
		 NULL  AS [day_count_id],--removed   
		 ISNULL(a.location_id, sml.Location_Name) AS [location_id],  
		 a.[meter_id],    
		 ISNULL(a.physical_financial_flag_detail, sddt.physical_financial_flag) AS [physical_financial_flag_detail], 
		 a.[fixed_cost], 
		 ISNULL(a.multiplier, 1) AS [multiplier], 
		 a.[adder_currency_id], 
		 a.[fixed_cost_currency_id], 
		 a.[formula_currency_id],  
		 a.[price_adder2], 
		 a.[price_adder_currency2],  
		 ISNULL(a.volume_multiplier2, 1) AS [volume_multiplier2], 
		 ISNULL(a.pay_opposite, sddt.pay_opposite) AS [pay_opposite], 
		 a.[capacity], 
		 ISNULL(sc_settlement_currency.source_currency_id, sddt.settlement_currency) AS [settlement_currency], 
		 ISNULL(a.standard_yearly_volume, sddt.standard_yearly_volume) AS [standard_yearly_volume], 
		 ISNULL(sup.source_uom_id, sddt.price_uom_id) AS [price_uom_id], 
		 ISNULL(sdv_category.value_id, sddt.category) AS [category], 
		 ISNULL(sdv_profile_code.value_id, sddt.profile_code) AS [profile_code], 
		 ISNULL(sdv_pv_party.value_id, sddt.pv_party) AS [pv_party], 
		 a.[Intrabook_deal_flag], 
		 a.[deal_seperator_id]   
		FROM ' + @PathFileName +   
		 '  a    
		 INNER JOIN source_deal_header_template sdht ON a.template = sdht.template_name  
		 INNER JOIN source_deal_detail_template sddt ON sdht.template_id = sddt.template_id  
			AND ISNULL(a.leg,sddt.leg) = sddt.leg   
		 INNER JOIN source_uom su ON a.source_system_id =su.source_system_id  
			AND sddt.deal_volume_uom_id = su.source_uom_id  
		 INNER  JOIN source_deal_type sdt ON a.source_system_id = sdt.source_system_id  
			AND sdht.source_deal_type_id = sdt.source_deal_type_id  
		 INNER  JOIN source_deal_type sdt2 ON a.source_system_id =sdt2.source_system_id  
			AND  sdht.deal_sub_type_type_id = sdt2.source_deal_type_id  
		 LEFT JOIN source_minor_location sml ON a.source_system_id = sml.source_system_id  
			AND sddt.location_id = sml.source_minor_location_id  
		 LEFT JOIN  source_price_curve_def spcd  ON a.source_system_id = spcd.source_system_id  
			AND sddt.curve_id = spcd.source_curve_def_id  
		 LEFT JOIN source_internal_portfolio sip ON a.source_system_id = sip.source_system_id  
			AND sdht.internal_portfolio_id = sip.source_internal_portfolio_id  
		 LEFT JOIN source_commodity sc ON a.source_system_id = sc.source_system_id  
			AND sdht.commodity_id = sc.source_commodity_id   
		 LEFT JOIN contract_group cg ON sdht.contract_id = cg.contract_id  
		 LEFT JOIN static_data_value sdv_internal_desk ON sdv_internal_desk.value_id = sdht.internal_desk_id  
		 LEFT JOIN static_data_value sdv_product_id ON sdv_product_id.value_id = sdht.product_id  
		 LEFT JOIN static_data_value sdv_block_define ON sdv_block_define.value_id = sdht.block_define_id  
		 LEFT JOIN static_data_value sdv_pricing ON sdv_pricing.value_id = sdht.Pricing  
		 LEFT JOIN static_data_value sdv_dealstatus_a ON sdv_dealstatus_a.code = a.deal_status  
		 LEFT JOIN static_data_value sdv_dealstatus ON sdv_dealstatus.value_id = sdht.deal_status  
		 LEFT JOIN source_currency sc_settlement_currency ON  a.source_system_id = sc_settlement_currency .source_system_id  
			AND a.[settlement_currency] = sc_settlement_currency.currency_id  
		 LEFT JOIN static_data_value  sdv_category ON a.[category] = sdv_category.code  
		 LEFT JOIN static_data_value  sdv_profile_code ON a.[profile_code] = sdv_profile_code.code  
		 LEFT JOIN static_data_value  sdv_pv_party ON a.[pv_party] = sdv_pv_party.code  
		 LEFT JOIN static_data_value  sdv_deal_category  ON a.deal_category_value_id = sdv_deal_category.code  
		 LEFT JOIN static_data_value  sdv_granularity  ON sdv_granularity.value_id = sdht.granularity_id  
		 LEFT JOIN source_uom sup ON a.source_system_id = sup.source_system_id  
			AND a.[price_uom_id] = sup.uom_id  
		 LEFT JOIN  source_currency sc_currency_id ON a.source_system_id =  sc_currency_id .source_system_id  
			AND sddt.currency_id = sc_currency_id.source_currency_id  
		 '  
	    
	 EXEC spa_print @sql   
	   
	 EXEC(@sql)  
	--exec ('SELECT  * from ' + @finaltemptablename)  
	--RETURN  
	   
	--update the Buy/Sell flag(header and detail) of the Offset deal to the opposite of Transferred deal   
	SET @sql = 'IF EXISTS(SELECT 1 FROM ' + @finaltemptablename + ' WHERE Intrabook_deal_flag IN (''T'',''O''))  
				BEGIN   
					 UPDATE O SET O.header_buy_sell_flag = CASE WHEN T.header_buy_sell_flag = ''b''  THEN ''s''   
									 ELSE ''b'' END,  
								O.buy_sell_flag = CASE WHEN T.buy_sell_flag = ''b''  THEN ''s''  
									 ELSE ''b'' END   
					 FROM   
						  (SELECT header_buy_sell_flag,buy_sell_flag,intrabook_deal_flag  
						  ,deal_seperator_id ,close_reference_id FROM '+ @finaltemptablename +  
						  ' WHERE intrabook_deal_flag = ''T'') T  
					 INNER JOIN   
						  (SELECT header_buy_sell_flag,buy_sell_flag,intrabook_deal_flag  
						  ,deal_seperator_id ,close_reference_id FROM ' + @finaltemptablename +  
						  ' WHERE intrabook_deal_flag = ''O'') O   
							ON T.deal_seperator_id = O.close_reference_id  
				END '  

	EXEC spa_print @sql  
	EXEC(@sql)   

	EXEC spa_print 'spa_import_data_job  ''', @finaltemptablename, ''',''', @table_no, ''', '''   
		, @job_name, ''', ''', @process_id, ''',''', @user_login_id, ''',''n'',12'  
	EXEC ('spa_import_data_job  ''' + @finaltemptablename + ''',''' + @table_no + ''', '''   
		+ @job_name + ''', ''' + @process_id + ''',''' + @user_login_id + ''',''n'',12')  
		
/*-----------------to update the deal_id of deal according to the source_deal_header_id  ---------------------------------------------*/
	IF CHARINDEX('4005',@table_no,1)<>0
	BEGIN 
	/*-----------------------------------------Total Deal vloume update for the imported deals ----------------------------------------------------------------------------*/	
		DECLARE @spa                    VARCHAR(1000)
			DECLARE @report_position_deals  VARCHAR(150)
    	
			SET @report_position_deals = dbo.FNAProcessTableName('report_position', @user_login_id, @process_id)
			EXEC spa_print @report_position_deals
			EXEC (
					 'CREATE TABLE ' + @report_position_deals + 
					 '( source_deal_header_id INT, action CHAR(1))'
				 )
    	
			SET @sql = 'INSERT INTO ' + @report_position_deals + 
					'(source_deal_header_id,action)
					SELECT DISTINCT source_deal_header_id ,''u''
					FROM ' +  @finaltemptablename + ' t 
					INNER JOIN source_deal_header sdh 
						on t.deal_id = sdh.deal_id'
					
			EXEC (@sql)
    	
			SET @spa = 'spa_update_deal_total_volume NULL,''' + CAST(@process_id AS VARCHAR(1000)) 
				+ ''''
		EXEC spa_print @spa
			SET @job_name = 'spa_update_deal_total_volume_' + @process_id 
			EXEC spa_run_sp_as_job @job_name,
				 @spa,
				 'spa_update_deal_total_volume',
				 @user_login_id
			     
		UPDATE 	source_deal_header 
		SET deal_id = CASE 
						WHEN SUBSTRING(deal_id,1,6) = '$xfr$_' THEN CAST(source_deal_header_id AS VARCHAR(50)) + ' -farrms_Xferred' 						WHEN SUBSTRING(deal_id,1,6) = '$off$_' THEN CAST(source_deal_header_id AS VARCHAR(50)) + ' -farrms_Offset' 
						WHEN SUBSTRING(deal_id,1,6) = '$tmp$_' THEN CAST(source_deal_header_id AS VARCHAR(50)) + ' -farrms' 
					  END 		WHERE SUBSTRING(deal_id,1,6) = CASE 
											WHEN SUBSTRING(deal_id,1,6) = '$xfr$_' THEN '$xfr$_'											WHEN SUBSTRING(deal_id,1,6) = '$off$_' THEN '$off$_'
											WHEN SUBSTRING(deal_id,1,6) = '$tmp$_' THEN '$tmp$_' 
										END 
	END  
END 
  
