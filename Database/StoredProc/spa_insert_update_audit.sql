IF OBJECT_ID('spa_insert_update_audit') IS NOT NULL 
	DROP PROC [dbo].[spa_insert_update_audit]  
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/**  
	Maintain deal audit.
	Parameters
	@flag : 
		'i' - Saves audit data for deal insert
		'u' - Saves audit data for deal update
		'd' - Saves audit data for deal delete

	@deal_id : ID of deal whose audit should be maintained
	@comments : Comments saved in audit
	@deal_process_table : Process table name with deal id to process.
*/
  
CREATE PROC [dbo].[spa_insert_update_audit]  
	@flag CHAR(1),  
	@deal_id VARCHAR(MAX),  
	@comments TEXT = NULL,
	@deal_process_table VARCHAR(400) = NULL   
AS  
SET NOCOUNT ON

/*
	DECLARE @flag CHAR(1)='i',
    @deal_id VARCHAR(MAX) = NULL,
	@comments VARCHAR(MAX) = NULL,
    @deal_process_table VARCHAR(400) = 'adiha_process.dbo.search_table_farrms_admin_229DA65D_D16D_4540_973B_0E696D5391FE'
--*/

DECLARE @state VARCHAR(100)  
  
IF OBJECT_ID('tempdb..#tmp_deals_sel') IS NOT NULL
	DROP TABLE #tmp_deals_sel	
CREATE TABLE #tmp_deals_sel (source_deal_header_id INT)
	
IF NULLIF(@deal_id,'') IS NOT NULL
BEGIN
	INSERT INTO #tmp_deals_sel(source_deal_header_id)
	SELECT scsv.item FROM dbo.SplitCommaSeperatedValues(@deal_id) scsv
END
ELSE IF NULLIF(@deal_process_table,'') IS NOT NULL
BEGIN
	DECLARE @sql VARCHAR(MAX)
	SET @sql = 'INSERT INTO #tmp_deals_sel (source_deal_header_id)
				SELECT DISTINCT source_deal_header_id FROM ' + @deal_process_table
	EXEC(@sql)
END

CREATE INDEX ind_tmp_deals_sel_source_deal_header_id ON #tmp_deals_sel(source_deal_header_id)
 
SELECT a.source_deal_header_id,MAX(audit_id) [max_audit_id]  
  INTO #max_audit_id   
FROM   source_deal_header_audit  a
    INNER JOIN #tmp_deals_sel csv2  
          ON  a.source_deal_header_id = csv2.source_deal_header_id  
GROUP BY  
        a.source_deal_header_id  
        
    
SELECT a.source_deal_header_id,MAX(audit_id) [max_audit_id]  
  INTO #max_audit_id_detail   
FROM   source_deal_detail_audit  a
    INNER JOIN #tmp_deals_sel csv2  
          ON  a.source_deal_header_id = csv2.source_deal_header_id  
GROUP BY  
        a.source_deal_header_id    
      
IF @flag = 'i'  
BEGIN  
    SET @state = 'Insert'  
END  
ELSE   
IF @flag = 'u'  
BEGIN  
    SET @state = 'Update'  
END  
  
DECLARE @audit_id INT ,@udf_audit_id INT
SELECT @audit_id= MAX(audit_id) FROM source_deal_detail_audit sdda
SELECT @udf_audit_id=MAX(udf_audit_id) FROM user_defined_deal_fields_audit uddfa
  
IF @flag = 'd'  
BEGIN  
    SET @state = 'Delete' 
    INSERT INTO [source_deal_header_audit]  
      (  
        [source_deal_header_id],  
        [source_system_id],  
        [deal_id],  
        [deal_date],  
        [ext_deal_id],  
        [physical_financial_flag],  
        [structured_deal_id],  
        [counterparty_id],  
        [entire_term_start],  
        [entire_term_end],  
        [source_deal_type_id],  
        [deal_sub_type_type_id],  
        [option_flag],  
        [option_type],  
        [option_excercise_type],  
        [source_system_book_id1],  
        [source_system_book_id2],  
        [source_system_book_id3],  
        [source_system_book_id4],  
        [description1],  
        [description2],  
        [description3],  
        [deal_category_value_id],  
        [trader_id],  
        [internal_deal_type_value_id],  
        [internal_deal_subtype_value_id],  
        [template_id],  
        [header_buy_sell_flag],  
        [broker_id],  
        [generator_id],  
        [status_value_id],  
        [status_date],  
        [assignment_type_value_id],  
        [compliance_year],  
        [state_value_id],  
        [assigned_date],  
        [assigned_by],  
        [generation_source],  
        [aggregate_environment],  
        [aggregate_envrionment_comment],  
        [rec_price],  
        [rec_formula_id],  
        [rolling_avg],  
        [contract_id],  
        [update_user],  
        [update_ts],  
        [legal_entity],  
        [internal_desk_id],  
        [product_id],  
        [internal_portfolio_id],  
        [commodity_id],  
        [reference],  
        [deal_locked],  
        [close_reference_id],  
        [block_type],  
        [block_define_id],  
        [granularity_id],  
        [pricing],  
        [verified_by],  
        [verified_date],  
        [user_action],  
        [term_frequency],  
        [unit_fixed_flag],  
        [broker_unit_fees],  
        [broker_fixed_cost],  
        [broker_currency_id],  
        [option_settlement_date],  
        [deal_status],  
        [confirm_status_type],
        [timezone_id], 
        counterparty_trader, 
        internal_counterparty,
        settlement_vol_type, 
        counterparty_id2, 
        trader_id2,
		inco_terms,
		scheduler,
		sample_control,
		payment_term,
		payment_days,
		governing_law,
		arbitration,
		counterparty2_trader,
		underlying_options,
		clearing_counterparty_id,
		pricing_type,
		confirmation_type,
		confirmation_template,
		sdr,
		profile_granularity,
		certificate,
		tier_value_id,
		holiday_calendar,
		collateral_amount,
		collateral_req_per,
		collateral_months,
		fx_conversion_market,
		fas_deal_type_value_id,
		match_type,
		reporting_tier_id,
		reporting_jurisdiction_id,
		reporting_group1, 
		reporting_group2, 
		reporting_group3, 
		reporting_group4, 
		reporting_group5 

      )  
    SELECT sdh.[source_deal_header_id],  
           [source_system_id],  
           [deal_id],  
           [deal_date],  
           [ext_deal_id],  
           [physical_financial_flag],  
           [structured_deal_id],  
           [counterparty_id],  
           [entire_term_start],  
           [entire_term_end],  
           [source_deal_type_id],  
           [deal_sub_type_type_id],  
           [option_flag],  
           [option_type],  
           [option_excercise_type],  
           [source_system_book_id1],  
           [source_system_book_id2],  
           [source_system_book_id3],  
           [source_system_book_id4],  
           [description1],  
           [description2],  
           [description3],  
           [deal_category_value_id],  
           [trader_id],  
           [internal_deal_type_value_id],  
           [internal_deal_subtype_value_id],  
           [template_id],  
           [header_buy_sell_flag],  
           [broker_id],  
           [generator_id],  
           [status_value_id],  
           [status_date],  
           [assignment_type_value_id],  
           [compliance_year],  
           [state_value_id],  
           [assigned_date],  
           [assigned_by],  
           [generation_source],  
           [aggregate_environment],  
           [aggregate_envrionment_comment],  
           [rec_price],  
           [rec_formula_id],  
           [rolling_avg],  
           [contract_id],  
           dbo.FNADBUser(),  
           GETDATE(),  
           [legal_entity],  
           [internal_desk_id],  
           [product_id],  
           [internal_portfolio_id],  
           [commodity_id],  
           [reference],  
			[deal_locked],  
           [close_reference_id],  
           [block_type],  
           [block_define_id],  
           [granularity_id],  
           [pricing],  
           [verified_by],  
           [verified_date],  
           @state,  
           [term_frequency],  
           [unit_fixed_flag],  
           [broker_unit_fees],  
           [broker_fixed_cost],  
           [broker_currency_id],  
           [option_settlement_date],  
           [deal_status],  
           [confirm_status_type],
           [timezone_id],
			counterparty_trader, 
			internal_counterparty,
			settlement_vol_type, 
			counterparty_id2, 
			trader_id2,
			inco_terms,
			scheduler,
			sample_control,
			payment_term,
			payment_days,
			governing_law,
			arbitration,
			counterparty2_trader,
			underlying_options,
			clearing_counterparty_id,
			pricing_type,
			confirmation_type,
			confirmation_template,
			sdr,
			profile_granularity,
			certificate,
			tier_value_id,
			holiday_calendar,
			collateral_amount,
			collateral_req_per,
			collateral_months,
			fx_conversion_market,
			fas_deal_type_value_id,
			match_type,
			reporting_tier_id,
			reporting_jurisdiction_id,
			reporting_group1, 
			reporting_group2, 
			reporting_group3, 
			reporting_group4, 
			reporting_group5 
    FROM   source_deal_header_audit sdh  
           INNER JOIN #tmp_deals_sel csv  
                ON  sdh.source_deal_header_id = csv.source_deal_header_id  
           INNER JOIN #max_audit_id max_audit  
                ON  max_audit.source_deal_header_id = sdh.source_deal_header_id  
                AND max_audit.max_audit_id = sdh.audit_id  
      

	 SELECT   
		  scsv.[source_deal_header_id],  
		  MAX(sdha.audit_id) AS [max_header_audit_it],  
		  @audit_id AS [prev_max_detail_audit_id],  
		  @udf_audit_id AS [prev_max_udf_audit_id]  
	 INTO #del_max_log_table  
	 FROM   source_deal_header_audit sdha INNER JOIN #tmp_deals_sel scsv ON sdha.source_deal_header_id = scsv.source_deal_header_id  
	 GROUP BY scsv.source_deal_header_id  
   
	CREATE  INDEX idx_del_max_log_table_deal_header_id ON #del_max_log_table(source_deal_header_id)
	CREATE  INDEX idx_del_max_log_table_prev_max_detail_audit_id ON .#del_max_log_table(prev_max_detail_audit_id)
	CREATE  INDEX idx_del_max_log_table_prev_max_udf_audit_id ON .#del_max_log_table(prev_max_udf_audit_id)
   
--    SELECT * FROM #del_max_log_table  
      
    IF @comments IS NOT NULL  
    BEGIN  
        UPDATE sdha  
        SET    comments = @comments  
        FROM   source_deal_header_audit sdha  
               INNER JOIN source_deal_header_template sdht  
                    ON  sdha.template_id = sdht.template_id  
                    AND sdht.comments = 'y'  
               INNER JOIN #tmp_deals_sel csv  
                    ON  csv.source_deal_header_id = sdha.source_deal_header_id  
               INNER JOIN #max_audit_id  max_audit  
                    ON  max_audit.max_audit_id = sdha.audit_id  
    END   
      
      
    INSERT INTO [source_deal_detail_audit]  
      (  
        [source_deal_detail_id],  
        [source_deal_header_id],  
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
		[schedule_volume],
		[actual_volume],
		[cycle],
        [deal_volume_frequency],  
        [deal_volume_uom_id],  
        [block_description],  
        [deal_detail_description],  
        [formula_id],  
        [volume_left],  
        [settlement_volume],  
        [settlement_uom],  
        [update_user],  
        [update_ts],  
        [user_action],  
        price_adder,  
        price_multiplier,  
        settlement_date,  
        day_count_id,  
        [physical_financial_flag],  
        fixed_cost,  
        multiplier,  
        adder_currency_id,  
        fixed_cost_currency_id,  
        formula_currency_id,  
        price_adder2,  
        price_adder_currency2,  
        volume_multiplier2,  
        total_volume,  
        pay_opposite,  
		formula_text,  
        capacity ,
		settlement_currency,
		standard_yearly_volume,
		price_uom_id,
		category,
		profile_code,
		pv_party,
		[status],
		[lock_deal_detail],
		contractual_uom_id, detail_commodity_id, detail_pricing,
		pricing_start, pricing_end, origin, form, organic,
		attribute1, attribute2, attribute3, attribute4, attribute5, position_uom, position_formula_id,
		detail_inco_terms,
		crop_year,
		lot,
		batch_id,
		detail_sample_control,
		buyer_seller_option,
		product_description,
		profile_id,
		premium_settlement_date,
		strike_granularity,
		no_of_strikes,
		delivery_date,
		payment_date,
		pricing_type2,
		fx_conversion_rate,
		upstream_counterparty,
		upstream_contract,
		vintage,
		delivery_date_to,
		actual_delivery_date,
		pnl_date,
		shipper_code1,
		shipper_code2
	)  
    SELECT [source_deal_detail_id],  
           sdd.[source_deal_header_id],  
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
		   [schedule_volume],
		   [actual_volume],
		   [cycle],
           [deal_volume_frequency],  
           [deal_volume_uom_id],  
           [block_description],  
           [deal_detail_description],  
           [formula_id],  
           [volume_left],  
           [settlement_volume],  
           [settlement_uom],  
           dbo.FNADBUser(),  
           GETDATE(),  
           @state,  
           price_adder,  
           price_multiplier,  
           settlement_date,  
           day_count_id,  
           [physical_financial_flag],  
           fixed_cost,  
           multiplier,  
           adder_currency_id,  
           fixed_cost_currency_id,  
           formula_currency_id,  
           price_adder2,  
           price_adder_currency2,  
           volume_multiplier2,  
           total_volume,  
           pay_opposite,  
           formula_text,  
           capacity ,
           sdd.settlement_currency,
			sdd.standard_yearly_volume,
			sdd.price_uom_id,
			sdd.category,
			sdd.profile_code,
			sdd.pv_party,
			[status],
			[lock_deal_detail],
			sdd.contractual_uom_id,
			sdd.detail_commodity_id,
			sdd.detail_pricing,
			sdd.pricing_start,
			sdd.pricing_end,
			sdd.origin,
			sdd.form,
			sdd.organic,
			sdd.attribute1,
			sdd.attribute2,
			sdd.attribute3,
			sdd.attribute4,
			sdd.attribute5,
			sdd.position_uom,
			sdd.position_formula_id,
			sdd.detail_inco_terms,
			sdd.crop_year,
			sdd.lot,
			sdd.batch_id,
			sdd.detail_sample_control,
			sdd.buyer_seller_option,
			sdd.product_description,
			sdd.profile_id,
			sdd.premium_settlement_date,
			sdd.strike_granularity,
			sdd.no_of_strikes,
			sdd.delivery_date,
			sdd.payment_date,
			sdd.pricing_type2,
			sdd.fx_conversion_rate,
			sdd.upstream_counterparty,
			sdd.upstream_contract,
			sdd.vintage,
			sdd.delivery_date_to,
			sdd.actual_delivery_date,
			sdd.pnl_date,
			sdd.shipper_code1,
			sdd.shipper_code2
		FROM   source_deal_detail_audit sdd  
           INNER JOIN #tmp_deals_sel csv  
                ON  sdd.source_deal_header_id = csv.source_deal_header_id  
           INNER JOIN #max_audit_id_detail max_audit  
                ON  max_audit.source_deal_header_id = sdd.source_deal_header_id  
                AND max_audit.max_audit_id = sdd.audit_id  
      
      
     
      
-- UPDATE sdda  
--  SET sdda.header_audit_id = dmlt.max_header_audit_it  
--    FROM #del_max_log_table dmlt  
--  INNER JOIN source_deal_detail_audit sdda  
--   ON  dmlt.source_deal_header_id = sdda.source_deal_header_id  
--  INNER JOIN dbo.SplitCommaSeperatedValues(@deal_id) scsv  
--   ON sdda.source_deal_header_id = scsv.Item  
-- WHERE sdda.audit_id > dmlt.prev_max_detail_audit_id      
      
      
--    UPDATE sdda  
--    SET    sdda.header_audit_id = s.header_audit_id  
--    FROM   (  
--               SELECT sdha.source_deal_header_id,  
--                      MAX(sdda.audit_id) [detail_audit_id],  
--                      MAX(sdha.audit_id) [header_audit_id]  
--               FROM   source_deal_header_audit sdha  
--                      INNER JOIN source_deal_detail_audit sdda  
--                           ON  sdda.source_deal_header_id = sdha.source_deal_header_id  
--                      INNER JOIN dbo.SplitCommaSeperatedValues(@deal_id) csv  
--                           ON  csv.item = sdha.source_deal_header_id  
--               GROUP BY  
--                      sdha.source_deal_header_id  
--           ) AS s  
--           INNER JOIN source_deal_detail_audit sdda  
--                ON  s.detail_audit_id = sdda.audit_id  
                  
                  
  
	 UPDATE sdda  
	  SET sdda.header_audit_id = dmlt.max_header_audit_it  
		FROM #del_max_log_table dmlt  
	  INNER JOIN source_deal_detail_audit sdda  
	   ON  dmlt.source_deal_header_id = sdda.source_deal_header_id  
	 WHERE sdda.audit_id > dmlt.prev_max_detail_audit_id                     
	                  
                 
    INSERT  INTO [user_defined_deal_fields_audit]  
    (  
      [udf_deal_id],  
      [source_deal_header_id],  
      [udf_template_id],  
      [udf_value],  
      [create_user],  
      [create_ts],  
      [update_user],  
      [update_ts],  
      [user_action] ,
	  counterparty_id,
	  currency_id,
	  uom_id,
	  contract_id,
	  receive_pay 
    )  
    SELECT  uddf.[udf_deal_id],  
          uddf.[source_deal_header_id],  
            uddf.[udf_template_id],  
            uddf.[udf_value],  
            uddf.[create_user],  
            uddf.[create_ts],  
            dbo.FNADBUser(),  
            GETDATE(),  
            @state ,
			uddf.counterparty_id,
			uddf.currency_id,
			uddf.uom_id,
			uddf.contract_id,
			uddf.receive_pay 
    FROM user_defined_deal_fields uddf  
  INNER JOIN #tmp_deals_sel scsv2  
  ON uddf.source_deal_header_id = scsv2.source_deal_header_id  
    WHERE uddf.source_deal_header_id = scsv2.source_deal_header_id     
      
      
 UPDATE uddfa  
  SET uddfa.header_audit_id = dmlt.max_header_audit_it  
    FROM #del_max_log_table dmlt  
  INNER JOIN user_defined_deal_fields_audit uddfa  
   ON dmlt.source_deal_header_id = uddfa.source_deal_header_id  
 WHERE uddfa.udf_audit_id > dmlt.prev_max_udf_audit_id      
              
                  
                  
  
END  
ELSE  
BEGIN  
    INSERT INTO [source_deal_header_audit]  
      (  
        [source_deal_header_id],  
        [source_system_id],  
        [deal_id],  
        [deal_date],  
        [ext_deal_id],  
        [physical_financial_flag],  
        [structured_deal_id],  
        [counterparty_id],  
        [entire_term_start],  
        [entire_term_end],  
        [source_deal_type_id],  
        [deal_sub_type_type_id],  
        [option_flag],  
        [option_type],  
        [option_excercise_type],  
        [source_system_book_id1],  
        [source_system_book_id2],  
        [source_system_book_id3],  
        [source_system_book_id4],  
        [description1],  
        [description2],  
        [description3],  
        [deal_category_value_id],  
        [trader_id],  
        [internal_deal_type_value_id],  
        [internal_deal_subtype_value_id],  
        [template_id],  
        [header_buy_sell_flag],  
        [broker_id],  
        [generator_id],  
        [status_value_id],  
        [status_date],  
        [assignment_type_value_id],  
        [compliance_year],  
        [state_value_id],  
        [assigned_date],  
        [assigned_by],  
        [generation_source],  
        [aggregate_environment],  
        [aggregate_envrionment_comment],  
        [rec_price],  
        [rec_formula_id],  
        [rolling_avg],  
        [contract_id],  
        [update_user],  
        [update_ts],  
        [legal_entity],  
        [internal_desk_id],  
        [product_id],  
        [internal_portfolio_id],  
        [commodity_id],  
        [reference],  
        [deal_locked],  
        [close_reference_id],  
        [block_type],  
        [block_define_id],  
        [granularity_id],  
        [pricing],  
        [verified_by],  
        [verified_date],  
        [user_action],  
        [term_frequency],  
        [unit_fixed_flag],  
        [broker_unit_fees],  
        [broker_fixed_cost],  
        [broker_currency_id],  
        [option_settlement_date],  
        [deal_status],  
        [confirm_status_type],
        [timezone_id],
        counterparty_trader, 
        internal_counterparty,
        settlement_vol_type, 
        counterparty_id2, 
        trader_id2,
		inco_terms,
		scheduler,
		sample_control,
		payment_term,
		payment_days,
		governing_law,
		arbitration,
		counterparty2_trader,
		underlying_options,
		clearing_counterparty_id,
		pricing_type,
		confirmation_type,
		confirmation_template,
		sdr,
		profile_granularity,
		certificate,
		tier_value_id,
		holiday_calendar,
		collateral_amount,
		collateral_req_per,
		collateral_months,
		fx_conversion_market,
		fas_deal_type_value_id,
		reporting_tier_id,
		reporting_jurisdiction_id,
		reporting_group1, 
		reporting_group2, 
		reporting_group3, 
		reporting_group4, 
		reporting_group5 
      )  
   
         SELECT sdh.[source_deal_header_id],  
           MAX([source_system_id]),  
           MAX([deal_id]),  
           MAX([deal_date]),  
           MAX([ext_deal_id]),  
           MAX([physical_financial_flag]),  
           MAX([structured_deal_id]),  
           MAX([counterparty_id]),  
           MAX([entire_term_start]),  
           MAX([entire_term_end]),  
           MAX([source_deal_type_id]),  
           MAX([deal_sub_type_type_id]),  
           MAX([option_flag]),  
           MAX([option_type]),  
           MAX([option_excercise_type]),  
           MAX([source_system_book_id1]),  
           MAX([source_system_book_id2]),  
           MAX([source_system_book_id3]),  
           MAX([source_system_book_id4]),  
           MAX([description1]),  
           MAX([description2]),  
           MAX([description3]),  
           MAX([deal_category_value_id]),  
           MAX([trader_id]),  
           MAX([internal_deal_type_value_id]),  
           MAX([internal_deal_subtype_value_id]),  
           MAX([template_id]),  
           MAX([header_buy_sell_flag]),  
           MAX([broker_id]),  
           MAX([generator_id]),  
           MAX([status_value_id]),  
           MAX([status_date]),  
           MAX([assignment_type_value_id]),  
           MAX([compliance_year]),  
           MAX([state_value_id]),  
           MAX([assigned_date]),  
			 MAX([assigned_by]),  
           MAX([generation_source]),  
           MAX([aggregate_environment]),  
           MAX([aggregate_envrionment_comment]),  
           MAX([rec_price]),  
           MAX([rec_formula_id]),  
           MAX([rolling_avg]),  
           MAX([contract_id]),  
           dbo.FNADBUser(),  
           GETDATE(),  
           MAX([legal_entity]),  
           MAX([internal_desk_id]),  
           MAX([product_id]),  
           MAX([internal_portfolio_id]),  
           MAX([commodity_id]),  
           MAX([reference]),  
           MAX([deal_locked]),  
           MAX([close_reference_id]),  
           MAX([block_type]),  
           MAX([block_define_id]),  
           MAX([granularity_id]),  
           MAX([pricing]),  
           MAX([verified_by]),  
           MAX([verified_date]),  
           @state,  
           MAX([term_frequency]),  
           MAX([unit_fixed_flag]),  
           MAX([broker_unit_fees]),  
           MAX([broker_fixed_cost]),  
           MAX([broker_currency_id]),  
           MAX([option_settlement_date]),  
           MAX([deal_status]),  
           MAX([confirm_status_type])  ,
           MAX([timezone_id]), 
			MAX(counterparty_trader), 
			MAX(internal_counterparty),
			MAX(settlement_vol_type), 
			MAX(counterparty_id2), 
			MAX(trader_id2),
			MAX(inco_terms),
			MAX(scheduler),
			MAX(sample_control),
			MAX(payment_term),
			MAX(payment_days),
			MAX(governing_law),
			MAX(arbitration),
			MAX(counterparty2_trader),
			MAX(underlying_options),
			MAX(clearing_counterparty_id),
			MAX(pricing_type),
			MAX(confirmation_type),
			MAX(confirmation_template),
			MAX(sdr),
			MAX(profile_granularity),
			MAX(certificate),
			MAX(tier_value_id),
			MAX(holiday_calendar),
			MAX(collateral_amount),
			MAX(collateral_req_per),
			MAX(collateral_months),
			MAX(fx_conversion_market),
			MAX(fas_deal_type_value_id),
			MAX(reporting_tier_id),
			MAX(reporting_jurisdiction_id),
			MAX(reporting_group1), 
			MAX(reporting_group2), 
			MAX(reporting_group3), 
			MAX(reporting_group4), 
			MAX(reporting_group5) 
    FROM   source_deal_header sdh (NOLOCK)  
           INNER JOIN #tmp_deals_sel csv  
                ON  sdh.source_deal_header_id = csv.source_deal_header_id 
         GROUP BY sdh.source_deal_header_id
                  
IF OBJECT_ID('tempdb..#iu_max_log_table') IS NOT NULL
	DROP TABLE #iu_max_log_table

CREATE TABLE #iu_max_log_table ( source_deal_header_id INT, max_header_audit_it INT, prev_max_detail_audit_id INT, prev_max_udf_audit_id INT)

INSERT INTO #iu_max_log_table (source_deal_header_id)
SELECT source_deal_header_id FROM #tmp_deals_sel
  
UPDATE temp
SET max_header_audit_it = sdha.audit_id
, prev_max_detail_audit_id = ISNULL(sdda.audit_id,-1)
, prev_max_udf_audit_id = ISNULL(udfa.audit_id,-1)
FROM #iu_max_log_table temp 
OUTER APPLY (SELECT MAX(sdha.audit_id) audit_id FROM source_deal_header_audit sdhA WHERE  sdha.source_deal_header_id = temp.source_deal_header_id) sdha
OUTER APPLY (SELECT MAX(sdda.audit_id) audit_id FROM source_deal_detail_audit sddA WHERE  sdda.source_deal_header_id = temp.source_deal_header_id) sdda
OUTER APPLY (SELECT MAX(udfa.udf_audit_id) audit_id FROM user_defined_deal_fields_audit udfa WHERE  udfa.source_deal_header_id = temp.source_deal_header_id) udfa
   
CREATE INDEX idx_iu_max_log_table_source_deal_header_id ON  #iu_max_log_table(source_deal_header_id)
CREATE INDEX idx_iu_max_log_table_prev_max_detail_audit_id ON  #iu_max_log_table([prev_max_detail_audit_id])
CREATE INDEX idx_iu_max_log_table_prev_max_udf_audit_id ON  #iu_max_log_table([prev_max_udf_audit_id])


CREATE TABLE #tmp_deal_detail_audit_map (
	audit_id INT
	, source_deal_detail_id INT
	, udf_template_id INT 
)      
    INSERT INTO [source_deal_detail_audit]  
      (  
        [source_deal_detail_id],  
        [source_deal_header_id],  
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
		[schedule_volume],
		[actual_volume],
		[cycle],
        [deal_volume_frequency],  
        [deal_volume_uom_id],  
        [block_description],  
        [deal_detail_description],  
        [formula_id],  
        [volume_left],  
        [settlement_volume],  
        [settlement_uom],  
        [update_user],  
        [update_ts],  
        [user_action],  
        price_adder,  
        price_multiplier,  
        settlement_date,  
        day_count_id,  
        [physical_financial_flag],  
        fixed_cost,  
        multiplier,  
        adder_currency_id,  
        fixed_cost_currency_id,  
        formula_currency_id,  
        price_adder2,  
        price_adder_currency2,  
        volume_multiplier2,  
        total_volume,  
        pay_opposite,  
        formula_text,  
        capacity,  
        location_id,  
        meter_id ,
        settlement_currency,
		standard_yearly_volume,
		price_uom_id,
		category,
		profile_code,
		pv_party,
		formula_curve_id,
		[status],
		[lock_deal_detail],
		contractual_uom_id, detail_commodity_id, detail_pricing,
		pricing_start, pricing_end, origin, form, organic,
		attribute1, attribute2, attribute3, attribute4, attribute5, position_uom, position_formula_id,
		detail_inco_terms,
		crop_year,
		lot,
		batch_id,
		detail_sample_control,
		buyer_seller_option,
		product_description,
		profile_id,
		premium_settlement_date,
		strike_granularity,
		no_of_strikes,
		delivery_date,
		payment_date,
		pricing_type2,
		fx_conversion_rate,
		upstream_counterparty,
		upstream_contract,
		vintage,
		delivery_date_to,
		actual_delivery_date,
		pnl_date,
		shipper_code1,
		shipper_code2
      ) 
      OUTPUT INSERTED.audit_id, INSERTED.source_deal_detail_id INTO #tmp_deal_detail_audit_map(audit_id, source_deal_detail_id)
   SELECT	[source_deal_detail_id],  
			sdd.[source_deal_header_id],  
			MAX([term_start]),  
			MAX([term_end]),  
			MAX([Leg]),  
			MAX([contract_expiration_date]),  
			MAX([fixed_float_leg]),  
			MAX([buy_sell_flag]),  
			MAX([curve_id]),  
			MAX([fixed_price]),  
			MAX([fixed_price_currency_id]),  
			MAX([option_strike_price]),  
			MAX([deal_volume]),  
			MAX([schedule_volume]),
			MAX([actual_volume]),
			MAX([cycle]),  
			MAX([deal_volume_frequency]),  
			MAX([deal_volume_uom_id]),  
			MAX([block_description]),  
			MAX([deal_detail_description]),  
			MAX(sdd.[formula_id]),  
			MAX([volume_left]),  
			MAX([settlement_volume]),  
			MAX([settlement_uom]),  
			dbo.FNADBUser(),  
			GETDATE(),  
			@state,  
			MAX(price_adder),  
			MAX(price_multiplier),  
			MAX(settlement_date),  
			MAX(day_count_id),  
			MAX([physical_financial_flag]),  
			MAX(fixed_cost),  
			MAX(multiplier),  
			MAX(adder_currency_id),  
			MAX(fixed_cost_currency_id),  
			MAX(formula_currency_id),  
			MAX(price_adder2),  
			MAX(price_adder_currency2),  
			MAX(volume_multiplier2),  
			MAX(total_volume),  
			MAX(pay_opposite),  
			MAX(fe.formula),  
			MAX(capacity),  
			MAX(sdd.location_id),  
			MAX(sdd.meter_id) ,
			MAX(sdd.settlement_currency),
			MAX(sdd.standard_yearly_volume),
			MAX(sdd.price_uom_id),
			MAX(sdd.category),
			MAX(sdd.profile_code),
			MAX(sdd.pv_party),
			MAX(formula_curve_id),
			MAX([status]),
			MAX([lock_deal_detail]),
			MAX(sdd.contractual_uom_id),
			MAX(sdd.detail_commodity_id),
			MAX(sdd.detail_pricing),
			MAX(sdd.pricing_start),
			MAX(sdd.pricing_end),
			MAX(sdd.origin),
			MAX(sdd.form),
			MAX(sdd.organic),
			MAX(sdd.attribute1),
			MAX(sdd.attribute2),
			MAX(sdd.attribute3),
			MAX(sdd.attribute4),
			MAX(sdd.attribute5),
			MAX(sdd.position_uom),
			MAX(sdd.position_formula_id),       
			MAX(detail_inco_terms),
			MAX(crop_year),
			MAX(lot),
			MAX(batch_id),
			MAX(detail_sample_control),
			MAX(buyer_seller_option),
			MAX(product_description),
			MAX(profile_id),
			MAX(premium_settlement_date),
			MAX(strike_granularity),
			MAX(no_of_strikes),
			MAX(delivery_date),
			MAX(payment_date),
			MAX(pricing_type2),
			MAX(fx_conversion_rate),
			MAX(upstream_counterparty),
			MAX(upstream_contract),
			MAX(sdd.vintage),
			MAX(delivery_date_to),
			MAX(actual_delivery_date),
			MAX(pnl_date),
			MAX(shipper_code1),
			MAX(shipper_code2)

    FROM   source_deal_detail sdd  (NOLOCK)
           INNER JOIN  #tmp_deals_sel csv  
                ON  sdd.source_deal_header_id = csv.source_deal_header_id  
           LEFT JOIN formula_editor fe  
    ON fe.formula_id = sdd.formula_id 
     GROUP BY sdd.source_deal_header_id, sdd.source_deal_detail_id
     
UPDATE tddam SET tddam.udf_template_id = udddf.udf_template_id
FROM #tmp_deal_detail_audit_map tddam 
INNER JOIN user_defined_deal_detail_fields udddf ON udddf.source_deal_detail_id = tddam.source_deal_detail_id
    
      
--    
-- UPDATE sdda  
--  SET sdda.header_audit_id = imlt.max_header_audit_it  
--    FROM #iu_max_log_table imlt  
--  INNER JOIN source_deal_detail_audit sdda  
--   ON  imlt.source_deal_header_id = sdda.source_deal_header_id  
-- WHERE sdda.audit_id > imlt.prev_max_detail_audit_id      
  
  
--    UPDATE sdda  
--    SET    sdda.header_audit_id = s.header_audit_id  
--    FROM   (  
--               SELECT sdha.source_deal_header_id,  
--                      MAX(sdda.audit_id) [detail_audit_id],  
--                      MAX(sdha.audit_id) [header_audit_id]  
--               FROM   source_deal_header_audit sdha  
--                      INNER JOIN source_deal_detail_audit sdda  
--                           ON  sdda.source_deal_header_id = sdha.source_deal_header_id  
--                      INNER JOIN dbo.SplitCommaSeperatedValues(@deal_id) csv  
--                           ON  csv.item = sdha.source_deal_header_id  
--               GROUP BY  
--                      sdha.source_deal_header_id  
--           ) AS s  
--           INNER JOIN source_deal_detail_audit sdda  
--                ON  s.detail_audit_id = sdda.audit_id  
 
    
 UPDATE sdda  
  SET sdda.header_audit_id = imlt.max_header_audit_it  
    FROM #iu_max_log_table imlt  
  INNER JOIN source_deal_detail_audit sdda  
   ON  imlt.source_deal_header_id = sdda.source_deal_header_id  
 WHERE sdda.audit_id > imlt.prev_max_detail_audit_id                     
                  
    INSERT  INTO [user_defined_deal_fields_audit]  
    (  
      [udf_deal_id],  
      [source_deal_header_id],  
      [udf_template_id],  
      [udf_value],  
      [create_user],  
      [create_ts],  
      [update_user],  
      [update_ts],  
      [user_action] ,
	  counterparty_id,
	  currency_id,
	  uom_id,
	  contract_id,
	  receive_pay   
    )  
    SELECT  uddf.[udf_deal_id],  
            uddf.[source_deal_header_id],  
            uddf.[udf_template_id],  
            uddf.[udf_value],  
            uddf.[create_user],  
            uddf.[create_ts],  
            dbo.FNADBUser(),  
            GETDATE(),  
            @state  ,
			uddf.counterparty_id,
			uddf.currency_id,
			uddf.uom_id,
			uddf.contract_id,
			uddf.receive_pay  
    FROM user_defined_deal_fields uddf  
  INNER JOIN #tmp_deals_sel scsv2  
  ON uddf.source_deal_header_id = scsv2.source_deal_header_id  
--    WHERE uddf.source_deal_header_id = scsv2.Item    
--      
  
      
  
     
 UPDATE uddfa  
  SET uddfa.header_audit_id = imlt.max_header_audit_it  
    FROM #iu_max_log_table imlt  
  INNER JOIN user_defined_deal_fields_audit uddfa  
   ON imlt.source_deal_header_id = uddfa.source_deal_header_id  
 WHERE uddfa.udf_audit_id > imlt.prev_max_udf_audit_id   
 
  INSERT  INTO [user_defined_deal_detail_fields_audit]
                (
                	
                  [udf_deal_id],
                  [source_deal_detail_id],
                  [udf_template_id],
                  [udf_value],
                  [create_user],
                  [create_ts],
                  [update_user],
                  [update_ts],
                  [user_action],
				  header_audit_id	,
				  counterparty_id,
				  currency_id,
				  uom_id,
				  contract_id,
				  receive_pay	
                )
                SELECT  udddf.[udf_deal_id],
                        udddf.[source_deal_detail_id],
                        udddf.[udf_template_id],
                        udddf.[udf_value],
                        udddf.[create_user],
                        udddf.[create_ts],
                        dbo.FNADBUser(),
                        GETDATE(),
                        @state,
                        tddam.audit_id,
					  udddf.counterparty_id,
					  udddf.currency_id,
					  udddf.uom_id,
					  udddf.contract_id,
					  udddf.receive_pay
                 FROM user_defined_deal_detail_fields udddf  
   INNER JOIN #tmp_deal_detail_audit_map tddam ON tddam.source_deal_detail_id = udddf.source_deal_detail_id
END  

GO