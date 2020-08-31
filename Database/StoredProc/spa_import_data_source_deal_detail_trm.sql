IF OBJECT_ID('[dbo].[spa_import_data_source_deal_detail_trm]', 'p') IS NOT NULL
    DROP PROCEDURE [dbo].[spa_import_data_source_deal_detail_trm]
GO 

-- ===========================================================================================================
-- Author: ssingh@pioneersolutionsglobal.com
-- Create date: 2012-08-01
-- Description: procedure to update temporary table with value from source_deal_header_template and source_deal_detail_template
--				if the data passed in the import file is NULL.
--	Params:
--	@PathFileName VARCHAR(MAX): name of the adhiha staging table 
--  @table_no  VARCHAR(100): table no.
--	@job_name VARCHAR(100) : name of the job
--	@process_id VARCHAR(50):process_id
--	@user_login_id VARCHAR(50): user logged in 
-- ===========================================================================================================

CREATE PROCEDURE [dbo].[spa_import_data_source_deal_detail_trm]
	@PathFileName VARCHAR(MAX) ,
	@table_no  VARCHAR(100),
	@job_name VARCHAR(100),
	@process_id VARCHAR(50),
	@user_login_id VARCHAR(50) = 'farrms_admin'
AS 
BEGIN
	DECLARE @sql VARCHAR(MAX)
			 
	SET @sql ='UPDATE a  
				set a.deal_id = CASE WHEN Intrabook_deal_flag = ''T'' THEN ISNULL(a.deal_id,''$xfr$_'' + a.deal_seperator_id)
					WHEN Intrabook_deal_flag = ''O'' THEN ISNULL(a.deal_id,''$off$_'' + a.deal_seperator_id)	
					ELSE ISNULL(a.deal_id,''$tmp$_'' + a.deal_seperator_id) END 	
				, a.source_deal_type_id = ISNULL(a.source_deal_type_id, sdt.deal_type_id) 
				, a.source_deal_sub_type_id = ISNULL(a.source_deal_sub_type_id, sdt2.deal_type_id) 
				, a.deal_category_value_id = ISNULL(a.deal_category_value_id, sdht.deal_category_value_id)
				, a.commodity_id = ISNULL(a.commodity_id, sc.commodity_id) 
				, a.internal_desk_id = ISNULL(a.internal_desk_id, sdv_internal_desk.code) 
				, a.Pricing = ISNULL(a.Pricing, sdv_pricing.code) 
				, a.leg = ISNULL(a.leg, sddt.leg) 
				, a.product_id = ISNULL(a.product_id, sdv_product_id.code)
				, a.block_define_id = ISNULL(a.block_define_id, sdv_block_define.code) 
				, a.deal_status = ISNULL(sdv_dealstatus_a.value_id, sdv_dealstatus.value_id) 
				, a.contract_id = ISNULL(a.contract_id, cg.source_contract_id)
				, a.physical_financial_flag = ISNULL(a.physical_financial_flag, sdht.physical_financial_flag)
				, a.header_buy_sell_flag = ISNULL(a.header_buy_sell_flag,sdht.buy_sell_flag)
				, a.option_flag = ISNULL(a.option_flag, sdht.option_flag)
				, a.fixed_float_leg = ISNULL(a.fixed_float_leg, sddt.fixed_float_leg)
				, a.buy_sell_flag = ISNULL(a.buy_sell_flag, sddt.buy_sell_flag) 
				, a.curve_id = ISNULL(a.curve_id,spcd.curve_id) 
				, a.deal_volume_frequency = ISNULL(a.deal_volume_frequency, sddt.deal_volume_frequency) 
				, a.deal_volume_uom_id = ISNULL(a.deal_volume_uom_id, su.uom_id ) 
				, a.physical_financial_flag_detail = ISNULL(a.physical_financial_flag_detail, sddt.physical_financial_flag) 
				, a.location_id = ISNULL(a.location_id, sml.Location_Name) 
				, a.pay_opposite = ISNULL(a.pay_opposite, sddt.pay_opposite) 
				, a.internal_portfolio_id = ISNULL(a.internal_portfolio_id,sip.internal_portfolio_id)  
				, a.contract_expiration_date = CONVERT(DATETIME, ISNULL(a.contract_expiration_date, a.term_end),103)
				, a.price_multiplier = ISNULL(a.price_multiplier, 1)
				, a.multiplier = ISNULL(a.multiplier, 1)
				, a.volume_multiplier2 = ISNULL(a.volume_multiplier2, 1)
				, a.settlement_date  = CONVERT(DATETIME, ISNULL(a.settlement_date, a.term_end), 103)
				, a.settlement_currency = ISNULL(sc_settlement_currency.source_currency_id, sddt.settlement_currency)
				, a.price_uom_id = ISNULL(sup.source_uom_id, sddt.price_uom_id)
				, a.category = ISNULL(sdv_category.value_id, sddt.category)
				, a.profile_code = ISNULL(sdv_profile_code.value_id, sddt.profile_code)
				, a.pv_party = ISNULL(sdv_pv_party.value_id, sddt.pv_party)
				, a.fixed_price_currency_id = ISNULL(a.fixed_price_currency_id, sc_currency_id.currency_id)
				, a.standard_yearly_volume = ISNULL(a.standard_yearly_volume, sddt.standard_yearly_volume)
				, a.term_start = convert(DATETIME, a.term_start, 103)
				, a.term_end = convert(DATETIME,a.term_end, 103)
				, a.option_settlement_date = convert(DATETIME, a.option_settlement_date, 103) 
				, a.deal_date = convert(DATETIME, a.deal_date, 103)
			   FROM '  + @PathFileName +
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
		LEFT JOIN source_uom sup ON a.source_system_id = sup.source_system_id
			AND a.[price_uom_id] = sup.uom_id
		LEFT JOIN  source_currency sc_currency_id ON a.source_system_id =  sc_currency_id .source_system_id
			AND sddt.currency_id = sc_currency_id.source_currency_id
		'
		
	EXEC spa_print @sql 
	EXEC(@sql)
	--update the Buy/Sell flag(header and detail) of the Offset deal to the opposite of Transferred deal	
	SET @sql = 'IF EXISTS(SELECT 1 FROM ' + @PathFileName +
				' WHERE Intrabook_deal_flag IN (''T'',''O''))
				BEGIN	
					UPDATE O set O.header_buy_sell_flag = CASE WHEN T.header_buy_sell_flag = ''b''  THEN ''s'' 
													ELSE ''b'' END , 
								O.buy_sell_flag =	CASE WHEN T.buy_sell_flag = ''b''  THEN ''s''
													ELSE ''b'' END 
					FROM 
						(SELECT header_buy_sell_flag,buy_sell_flag,intrabook_deal_flag
						,deal_seperator_id ,close_reference_id FROM '+ @PathFileName +
						' WHERE intrabook_deal_flag = ''T'') T
					INNER JOIN 
						(SELECT header_buy_sell_flag,buy_sell_flag,intrabook_deal_flag
						,deal_seperator_id ,close_reference_id FROM ' + @PathFileName +
						' WHERE intrabook_deal_flag = ''O'') O 
					ON T.deal_seperator_id = O.close_reference_id
				END '
		
	EXEC spa_print @sql
	EXEC(@sql)	
	
	EXEC spa_print 'spa_import_data_job  ''', @PathFileName, ''',''', @table_no, ''', ''' 
				, @job_name, ''', ''', @process_id, ''',''', @user_login_id, ''',''n'',12'
	EXEC ('spa_import_data_job  ''' + @PathFileName + ''',''' + @table_no + ''', ''' 
				+ @job_name + ''', ''' + @process_id + ''',''' + @user_login_id + ''',''n'',12')
END

