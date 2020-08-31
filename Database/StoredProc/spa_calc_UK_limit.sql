IF OBJECT_ID(N'[dbo].[spa_calc_UK_limit]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[spa_calc_UK_limit]
GO
 
SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
-- ===========================================================================================================
-- Author: rtuladhar@pioneersolutionsglobal.com
-- Create date: 2012-12-06
-- Description: Calc UK static Limit
 
-- Params:
-- @flag CHAR(1) - Operation flag
-- ===========================================================================================================
CREATE PROCEDURE [dbo].[spa_calc_UK_limit]
    @flag CHAR(1)
    , @source_updated_deal_table VARCHAR(150) = NULL
    , @source_updated_deal_ids VARCHAR(MAX) = NULL
    , @batch_process_id VARCHAR(250) = NULL
    , @user_login_id VARCHAR(100) = NULL
    ,@as_of_date datetime=null
AS

/*
spa_calc_UK_limit 'c', NULL, NULL, NULL, 'farrms_admin'  
drop table #power_book_collections   
drop table #summed_volume_power
drop table #volume_gather_power
drop table #gas_book_collections
drop table #summed_volume_gas
drop table #own_use_deal_volumes

declare @flag CHAR(1) 
    , @source_updated_deal_table VARCHAR(150) 
    , @source_updated_deal_ids VARCHAR(MAX) 
    , @batch_process_id VARCHAR(250) 
    , @user_login_id VARCHAR(100)
    
    set @flag = 'c'
    
set @user_login_id = 'farrms_admin'  
--*/

IF @source_updated_deal_table = 'no' AND @source_updated_deal_table IS NOT NULL
	RETURN --deal not matched with books

DECLARE @sql NVARCHAR(MAX)
DECLARE @POWER_IDS_POSITIVE VARCHAR(400)
DECLARE @POWER_IDS_NEGATIVE VARCHAR(400)
DECLARE @NATURAL_GAS_IDS VARCHAR(400)
DECLARE @COAL_IDS VARCHAR(400)

/* Assumption for static limit deals*/
--SET @POWER_IDS_POSITIVE = 'Limit (Power Generation)-Elec'
--SET @POWER_IDS_NEGATIVE = 'Limit (Retail Sales)-Elec'
--SET @NATURAL_GAS_IDS = 'Limit-Nat Gas'
--SET @COAL_IDS = 'Limit-Coal'
/* Assumption for static limit deals*/



SELECT	[clm1_value] AS [sb1]
	, [clm2_value] AS [sb2]
	, [clm3_value] AS [sb3]
	, [clm4_value] AS [sb4] 
INTO #book_power_deal
FROM generic_mapping_values v inner join generic_mapping_header h on v.mapping_table_id=h.mapping_table_id
WHERE mapping_name = 'UK Probable Limit Deal (Power)'

--SELECT	[clm1_value] AS [sb1]
--	, [clm2_value] AS [sb2]
--	, [clm3_value] AS [sb3]
--	, [clm4_value] AS [sb4] 
--INTO #book_power_deal_sale
--FROM generic_mapping_values v inner join generic_mapping_header h on v.mapping_table_id=h.mapping_table_id
--WHERE mapping_name = 'UK Probable Limit Deal (Retail Sales-Elec)'

SELECT	[clm1_value] AS [sb1]
	, [clm2_value] AS [sb2]
	, [clm3_value] AS [sb3]
	, [clm4_value] AS [sb4] 
INTO #book_gas_deal
FROM generic_mapping_values v inner join generic_mapping_header h on v.mapping_table_id=h.mapping_table_id
WHERE mapping_name = 'UK Probable Limit Deal (Gas)'

SELECT	[clm1_value] AS [sb1]
	, [clm2_value] AS [sb2]
	, [clm3_value] AS [sb3]
	, [clm4_value] AS [sb4] 
INTO #book_coal_deal
FROM generic_mapping_values v inner join generic_mapping_header h on v.mapping_table_id=h.mapping_table_id
WHERE mapping_name = 'UK Probable Limit Deal (Coal)'


select @POWER_IDS_POSITIVE=deal_id	
	FROM ( select top(1) sdh.deal_id  from
	source_deal_header sdh
	inner join  #book_power_deal b
	on sdh.source_system_book_id1=b.sb1 and sdh.source_system_book_id2=b.sb2  and sdh.source_system_book_id3=b.sb3 and sdh.source_system_book_id4=b.sb4
	where sdh.header_buy_sell_flag='b'
	 )	 a

 select @POWER_IDS_NEGATIVE=deal_id	
	FROM ( select top(1) sdh.deal_id   from
	source_deal_header sdh
	inner join  #book_power_deal b
	on sdh.source_system_book_id1=b.sb1 and sdh.source_system_book_id2=b.sb2  and sdh.source_system_book_id3=b.sb3 and sdh.source_system_book_id4=b.sb4
		where sdh.header_buy_sell_flag='s'

	 )	 a

select @NATURAL_GAS_IDS=deal_id	
	FROM ( select top(1) sdh.deal_id  from
	source_deal_header sdh
	inner join  #book_gas_deal b
	on sdh.source_system_book_id1=b.sb1 and sdh.source_system_book_id2=b.sb2  and sdh.source_system_book_id3=b.sb3 and sdh.source_system_book_id4=b.sb4
	 )	 a

 select @COAL_IDS=deal_id	
	FROM ( select top(1) sdh.deal_id from  
	source_deal_header sdh
	inner join  #book_coal_deal b
	on sdh.source_system_book_id1=b.sb1 and sdh.source_system_book_id2=b.sb2  and sdh.source_system_book_id3=b.sb3 and sdh.source_system_book_id4=b.sb4
	 )	 a



DECLARE @POWER_LIMIT_ID INT
DECLARE @NATURAL_GAS_LIMIT_ID INT
DECLARE @COAL_LIMIT_ID INT

SELECT @POWER_LIMIT_ID = mapping_table_id FROM generic_mapping_header WHERE mapping_name = 'UK Power Dynamic Limit'
SELECT @NATURAL_GAS_LIMIT_ID = mapping_table_id FROM generic_mapping_header WHERE mapping_name = 'UK Gas Dynamic Limit'
SELECT @COAL_LIMIT_ID = mapping_table_id FROM generic_mapping_header WHERE mapping_name = 'UK Coal Dynamic Limit'

DECLARE @CHECK_POS_NEG numeric(28,10)
DECLARE @own_power_sdh_id INT
DECLARE @own_gas_sdh_id INT
DECLARE @own_coal_sdh_id INT

DECLARE @sb1_power INT
DECLARE @sb2_power INT
DECLARE @sb3_power INT
DECLARE @sb4_power INT
DECLARE @sb1_gas INT
DECLARE @sb2_gas INT
DECLARE @sb3_gas INT
DECLARE @sb4_gas INT
DECLARE @sb1_coal INT
DECLARE @sb2_coal INT
DECLARE @sb3_coal INT
DECLARE @sb4_coal INT

DECLARE @term_start_power DATETIME
DECLARE @term_end_power DATETIME
DECLARE @term_start_gas DATETIME
DECLARE @term_end_gas DATETIME
DECLARE @term_start_coal DATETIME
DECLARE @term_end_coal DATETIME

DECLARE @sb1_limit INT
DECLARE @sb2_limit INT
DECLARE @sb3_limit INT
DECLARE @sb4_limit_gas INT
DECLARE @sb4_limit_power INT
DECLARE @sb4_limit_coal INT
DECLARE @UK_participating_subsidiaries   VARCHAR(150)

SELECT @sb1_limit = sb.source_book_id FROM source_book sb WHERE sb.source_book_name IN('Limit UK')
SELECT @sb2_limit = sb.source_book_id FROM source_book sb WHERE sb.source_book_name IN('none') AND source_system_book_type_value_id = 51
SELECT @sb3_limit = sb.source_book_id FROM source_book sb WHERE sb.source_book_name IN('none') AND source_system_book_type_value_id = 52 
SELECT @sb4_limit_gas = sb.source_book_id FROM source_book sb WHERE sb.source_book_name IN('Natural Gas') 
SELECT @sb4_limit_power = sb.source_book_id FROM source_book sb WHERE sb.source_book_name IN('Electricity') 
SELECT @sb4_limit_coal = sb.source_book_id FROM source_book sb WHERE sb.source_book_name IN('coal') 

set @UK_participating_subsidiaries='UK Participating Subsidiaries'

SELECT	cast([clm1_value] as int) AS sub_id   
INTO #UK_participating_subsidiaries
FROM generic_mapping_values v inner join generic_mapping_header h on v.mapping_table_id=h.mapping_table_id
WHERE mapping_name = @UK_participating_subsidiaries

 

IF @flag = 'c'
BEGIN 
	/*Power calc start*/
	SELECT	[clm1_value] AS [sb1]
			, [clm2_value] AS [sb2]
			, [clm3_value] AS [sb3]
			, [clm4_value] AS [sb4] 
		INTO #power_book_collections
	FROM generic_mapping_values 
	WHERE mapping_table_id = @POWER_LIMIT_ID
	
	SELECT	sdd.term_start, sdd.term_end, sdd.leg
			, SUM(CASE WHEN sdd.buy_sell_flag = 'b' THEN sdd.deal_volume ELSE (-1 * sdd.deal_volume) END) deal_volume  
			, MAX(sdh.source_system_book_id1) source_system_book_id1
			, MAX( sdh.source_system_book_id2) source_system_book_id2
			, MAX(sdh.source_system_book_id3) source_system_book_id3
			, MAX(sdh.source_system_book_id4) source_system_book_id4
		INTO #summed_volume_power  
	FROM source_deal_header sdh 
	INNER JOIN source_deal_detail sdd ON sdd.source_deal_header_id = sdh.source_deal_header_id
		AND sdd.Leg = 1
	INNER JOIN source_system_book_map ssbm ON ssbm.source_system_book_id1 = sdh.source_system_book_id1
		AND ssbm.source_system_book_id2 = sdh.source_system_book_id2
		AND ssbm.source_system_book_id3 = sdh.source_system_book_id3
		AND ssbm.source_system_book_id4 = sdh.source_system_book_id4 AND isnull(sdh.fas_deal_type_value_id,ssbm.fas_deal_type_value_id) IN (410)
	INNER JOIN #power_book_collections pbc ON pbc.[sb1] = sdh.source_system_book_id1
		AND pbc.[sb2] = sdh.source_system_book_id2
		AND pbc.[sb3] = sdh.source_system_book_id3
		AND pbc.[sb4] = sdh.source_system_book_id4
	WHERE sdh.deal_id NOT IN (@POWER_IDS_POSITIVE, @POWER_IDS_NEGATIVE, 'OWN_USE_DEAL_POWER', 'UK_LIMIT_POWER')
	GROUP BY sdd.term_start, sdd.term_end, sdd.Leg
	ORDER BY sdd.term_start, sdd.term_end

	SELECT TOP 1 @sb1_power = source_system_book_id1
				, @sb2_power = source_system_book_id2
				, @sb3_power = source_system_book_id3
				, @sb4_power = source_system_book_id4
	FROM #summed_volume_power 
	
	SELECT @CHECK_POS_NEG = SUM(deal_volume) FROM #summed_volume_power
	
	IF NOT EXISTS (SELECT 1 FROM source_deal_header WHERE deal_id = 'OWN_USE_DEAL_POWER')
	BEGIN
		DECLARE @Params NVARCHAR(500);
		SET @Params = N'@own_power_sdh_id INT OUTPUT';

		SET @sql = '
					INSERT INTO source_deal_header (source_system_id, deal_id, deal_date, ext_deal_id, physical_financial_flag, structured_deal_id
										, counterparty_id, entire_term_start, entire_term_end, source_deal_type_id, deal_sub_type_type_id
										, option_flag, option_type, option_excercise_type, source_system_book_id1, source_system_book_id2
										, source_system_book_id3, source_system_book_id4, description1, description2, description3, deal_category_value_id
										, trader_id , internal_deal_type_value_id, internal_deal_subtype_value_id, template_id, header_buy_sell_flag, broker_id
										, generator_id, status_value_id, status_date, assignment_type_value_id, compliance_year, state_value_id
										, assigned_date, assigned_by, generation_source, aggregate_environment, aggregate_envrionment_comment
										, rec_price, rec_formula_id, rolling_avg, contract_id, create_user, create_ts, update_user, update_ts
										, legal_entity, internal_desk_id, product_id, internal_portfolio_id, commodity_id, reference
										, deal_locked, close_reference_id, block_type, block_define_id, granularity_id, Pricing
										, deal_reference_type_id, unit_fixed_flag, broker_unit_fees, broker_fixed_cost, broker_currency_id
										, deal_status, term_frequency, option_settlement_date, verified_by, verified_date, risk_sign_off_by
										, risk_sign_off_date, back_office_sign_off_by, back_office_sign_off_date, book_transfer_id, [description4])
					SELECT 20, ''OWN_USE_DEAL_POWER'', [deal_date], [ext_deal_id], [physical_financial_flag], [structured_deal_id]
										, [counterparty_id], [entire_term_start], [entire_term_end], [source_deal_type_id], [deal_sub_type_type_id]
										, [option_flag], [option_type], [option_excercise_type], ' + CAST(@sb1_power AS VARCHAR(10)) + ', ' + CAST(@sb2_power AS VARCHAR(10)) + '
										, ' + CAST(@sb3_power AS VARCHAR(10)) + ', ' + CAST(@sb4_power AS VARCHAR(10)) + ', [description1], [description2], [description3]
										, [deal_category_value_id], [trader_id], [internal_deal_type_value_id], [internal_deal_subtype_value_id]
										, [template_id], [header_buy_sell_flag], [broker_id], [generator_id], [status_value_id], [status_date]
										, [assignment_type_value_id], [compliance_year], [state_value_id], [assigned_date], [assigned_by]
										, [generation_source], [aggregate_environment], [aggregate_envrionment_comment], [rec_price], [rec_formula_id]
										, [rolling_avg], [contract_id], [create_user], [create_ts], [update_user], [update_ts], [legal_entity]
										, [internal_desk_id], [product_id], [internal_portfolio_id], [commodity_id], [reference], [deal_locked]
										, [close_reference_id], [block_type], [block_define_id], [granularity_id], [Pricing], [deal_reference_type_id]
										, [unit_fixed_flag], [broker_unit_fees], [broker_fixed_cost], [broker_currency_id], [deal_status], [term_frequency]
										, [option_settlement_date], [verified_by], [verified_date], [risk_sign_off_by], [risk_sign_off_date]
										, [back_office_sign_off_by], [back_office_sign_off_date], [book_transfer_id], [description4]
					FROM source_deal_header WHERE deal_id = ' 

		IF @CHECK_POS_NEG > 0 
			SET @sql = @sql + '''' + @POWER_IDS_POSITIVE + ''''
		ELSE 
			SET @sql = @sql + '''' + @POWER_IDS_NEGATIVE + ''''

		SET @sql = @sql + ' SET @own_power_sdh_id = SCOPE_IDENTITY() '
		
		EXEC spa_print @sql 	
		--EXEC(@sql)
		EXECUTE sp_executesql @sql, @Params, @own_power_sdh_id = @own_power_sdh_id OUTPUT;
		
		SET @sql = '
					INSERT INTO source_deal_detail([source_deal_header_id], [term_start], [term_end], [Leg], [contract_expiration_date], [fixed_float_leg]
							, [buy_sell_flag], [deal_volume_frequency], [deal_volume_uom_id], deal_volume, curve_id)
					SELECT ' + CAST(@own_power_sdh_id AS VARCHAR(100)) + ', sdd.[term_start], sdd.[term_end], sdd.[Leg], [contract_expiration_date], [fixed_float_leg]
							, [buy_sell_flag], [deal_volume_frequency], [deal_volume_uom_id], ISNULL(ABS(svp.deal_volume), 0) deal_volume, curve_id
					FROM source_deal_detail sdd
					INNER JOIN source_deal_header sdh ON sdh.source_deal_header_id = sdd.source_deal_header_id
					LEFT JOIN #summed_volume_power	svp ON svp.term_start = sdd.term_start
						AND svp.term_end = sdd.term_end 
						AND svp.leg = sdd.Leg
					WHERE sdh.deal_id = '

		IF @CHECK_POS_NEG > 0 
			SET @sql = @sql + '''' + @POWER_IDS_POSITIVE + '''' 
		ELSE 
			SET @sql = @sql + '''' + @POWER_IDS_NEGATIVE + ''''  

		EXEC spa_print @sql 	
		EXEC(@sql)
		
		SELECT @term_start_power = MIN(term_start) FROM source_deal_detail WHERE source_deal_header_id = @own_power_sdh_id
		SELECT @term_end_power = MAX(term_end) FROM source_deal_detail WHERE source_deal_header_id = @own_power_sdh_id
		
		UPDATE source_deal_header 
		SET entire_term_start = @term_start_power
			, entire_term_end = @term_end_power
		WHERE source_deal_header_id = @own_power_sdh_id 			
	END
	ELSE
	BEGIN
		SELECT @own_power_sdh_id = source_deal_header_id FROM source_deal_header WHERE deal_id = 'OWN_USE_DEAL_POWER'

		UPDATE sdd
		SET sdd.deal_volume = svp.deal_volume,
			sdd.update_user = dbo.FNADBUser(),
			sdd.update_ts = GETDATE(),
			sdd.buy_sell_flag = CASE WHEN @CHECK_POS_NEG < 0 THEN 's' ELSE 'b' END 
		FROM #summed_volume_power svp 
		INNER JOIN source_deal_detail sdd ON svp.term_start = sdd.term_start
			AND svp.term_end = sdd.term_end 
			AND svp.leg = sdd.Leg
		WHERE sdd.source_deal_header_id = @own_power_sdh_id
		
		UPDATE source_deal_header 
		SET update_user = dbo.FNADBUser()
			, update_ts = GETDATE()
			, header_buy_sell_flag = CASE WHEN @CHECK_POS_NEG < 0 THEN 's' ELSE 'b' END 
		WHERE source_deal_header_id = @own_power_sdh_id
	END
	

	CREATE TABLE #own_use_deal_volumes (term_start DATETIME, term_end DATETIME, buy_sell_flag CHAR(1) COLLATE DATABASE_DEFAULT, deal_volume FLOAT)
	SET @sql = '
				INSERT INTO #own_use_deal_volumes (term_start, term_end, buy_sell_flag, deal_volume )
				SELECT sdd.term_start, sdd.term_end, sdd.buy_sell_flag, sum(sdd.deal_volume) deal_volume
				FROM source_deal_header sdh
				INNER JOIN source_deal_detail sdd ON sdd.source_deal_header_id = sdh.source_deal_header_id
				inner join  #book_power_deal b
					on sdh.source_system_book_id1=b.sb1 and sdh.source_system_book_id2=b.sb2  and sdh.source_system_book_id3=b.sb3 and sdh.source_system_book_id4=b.sb4
				where sdh.header_buy_sell_flag='''+case when @CHECK_POS_NEG > 0 then 'b' else 's' end +'''
				group by sdd.term_start, sdd.term_end, sdd.buy_sell_flag
			'
	EXEC spa_print @sql 	
	EXEC(@sql)
	
	IF NOT EXISTS (SELECT 1 FROM source_deal_header WHERE deal_id = 'UK_LIMIT_POWER')
	BEGIN
		SET @sql = '
				INSERT INTO source_deal_header	(source_system_id, deal_id, deal_date, ext_deal_id, physical_financial_flag, structured_deal_id
												, counterparty_id, entire_term_start, entire_term_end, source_deal_type_id, deal_sub_type_type_id
												, option_flag, option_type, option_excercise_type, source_system_book_id1, source_system_book_id2
												, source_system_book_id3, source_system_book_id4, description1, description2, description3, deal_category_value_id
												, trader_id , internal_deal_type_value_id, internal_deal_subtype_value_id, template_id, header_buy_sell_flag, broker_id
												, generator_id, status_value_id, status_date, assignment_type_value_id, compliance_year, state_value_id
												, assigned_date, assigned_by, generation_source, aggregate_environment, aggregate_envrionment_comment
												, rec_price, rec_formula_id, rolling_avg, contract_id, create_user, create_ts, update_user, update_ts
												, legal_entity, internal_desk_id, product_id, internal_portfolio_id, commodity_id, reference
												, deal_locked, close_reference_id, block_type, block_define_id, granularity_id, Pricing
												, deal_reference_type_id, unit_fixed_flag, broker_unit_fees, broker_fixed_cost, broker_currency_id
												, deal_status, term_frequency, option_settlement_date, verified_by, verified_date, risk_sign_off_by
												, risk_sign_off_date, back_office_sign_off_by, back_office_sign_off_date, book_transfer_id, [description4])
				SELECT 20, ''UK_LIMIT_POWER'', [deal_date], [ext_deal_id], [physical_financial_flag], [structured_deal_id]
												, [counterparty_id], [entire_term_start], [entire_term_end], [source_deal_type_id], [deal_sub_type_type_id]
												, [option_flag], [option_type], [option_excercise_type], ' + CAST(@sb1_limit AS VARCHAR(100)) + ', ' + CAST(@sb2_limit AS VARCHAR(100)) + '
												, ' + CAST(@sb3_limit AS VARCHAR(100)) + ', ' + CAST(@sb4_limit_power AS VARCHAR(100)) + ', [description1], [description2], [description3]
												, [deal_category_value_id], [trader_id], [internal_deal_type_value_id], [internal_deal_subtype_value_id]
												, [template_id], [header_buy_sell_flag], [broker_id], [generator_id], [status_value_id], [status_date]
												, [assignment_type_value_id], [compliance_year], [state_value_id], [assigned_date], [assigned_by]
												, [generation_source], [aggregate_environment], [aggregate_envrionment_comment], [rec_price], [rec_formula_id]
												, [rolling_avg], [contract_id], [create_user], [create_ts], [update_user], [update_ts], [legal_entity]
												, [internal_desk_id], [product_id], [internal_portfolio_id], [commodity_id], [reference], [deal_locked]
												, [close_reference_id], [block_type], [block_define_id], [granularity_id], [Pricing], [deal_reference_type_id]
												, [unit_fixed_flag], [broker_unit_fees], [broker_fixed_cost], [broker_currency_id], [deal_status], [term_frequency]
												, [option_settlement_date], [verified_by], [verified_date], [risk_sign_off_by], [risk_sign_off_date]
												, [back_office_sign_off_by], [back_office_sign_off_date], [book_transfer_id], [description4]
				FROM source_deal_header WHERE deal_id = ' 

		IF @CHECK_POS_NEG > 0 
			SET @sql = @sql + '''' + @POWER_IDS_POSITIVE + ''''
		ELSE 
			SET @sql = @sql + '''' + @POWER_IDS_NEGATIVE + ''''

		SET @sql = @sql + ' SET @own_power_sdh_id = SCOPE_IDENTITY() '

		EXEC spa_print @sql 	
		--EXEC(@sql)
		EXECUTE sp_executesql @sql, @Params, @own_power_sdh_id = @own_power_sdh_id OUTPUT;
 
		SET @sql = '
					INSERT INTO source_deal_detail([source_deal_header_id], [term_start], [term_end], [Leg], [contract_expiration_date], [fixed_float_leg]
						, [buy_sell_flag], [deal_volume_frequency], [deal_volume_uom_id], deal_volume, curve_id)
					SELECT ' + CAST(@own_power_sdh_id AS VARCHAR(100)) + ', sdd.[term_start], sdd.[term_end], sdd.[Leg], [contract_expiration_date], [fixed_float_leg]
							, ''b'', [deal_volume_frequency], [deal_volume_uom_id]
							, CASE WHEN ABS(ISNULL(svp.deal_volume, 0)) > ABS(oudv.deal_volume) 
								THEN ISNULL(oudv.deal_volume, 0) ELSE ISNULL(svp.deal_volume, 0) END, curve_id
					FROM  #own_use_deal_volumes oudv 
					INNER JOIN   source_deal_detail sdd ON oudv.term_start = sdd.term_start
						AND oudv.term_end = sdd.term_end 
					INNER JOIN source_deal_header sdh ON sdh.source_deal_header_id = sdd.source_deal_header_id
					LEFT JOIN #summed_volume_power svp on svp.term_start = oudv.term_start
						AND svp.term_end = oudv.term_end 
						AND svp.leg = sdd.Leg 
										WHERE sdh.deal_id = '
					


		IF @CHECK_POS_NEG > 0 
			SET @sql = @sql + '''' + @POWER_IDS_POSITIVE + '''' 
		ELSE 
			SET @sql = @sql + '''' + @POWER_IDS_NEGATIVE + ''''  

		EXEC spa_print @sql 	
		EXEC(@sql)
		
		SELECT @term_start_power = MIN(term_start) FROM source_deal_detail WHERE source_deal_header_id = @own_power_sdh_id
		SELECT @term_end_power = MAX(term_end) FROM source_deal_detail WHERE source_deal_header_id = @own_power_sdh_id
		
		UPDATE source_deal_header 
		SET entire_term_start = @term_start_power
			, entire_term_end = @term_end_power
		WHERE source_deal_header_id = @own_power_sdh_id 
	END
	ELSE
	BEGIN
		SELECT @own_power_sdh_id = source_deal_header_id FROM source_deal_header WHERE deal_id = 'UK_LIMIT_POWER'

		BEGIN
			SET @sql = '
						UPDATE sdd
						SET sdd.deal_volume = ISNULL(case when abs(svp.deal_volume) > abs(oudv.deal_volume) then oudv.deal_volume else svp.deal_volume end , 0),
							sdd.update_user = dbo.FNADBUser(),
							sdd.update_ts = GETDATE(),
							sdd.buy_sell_flag = ''b''  
						FROM #summed_volume_power svp 
						INNER JOIN #own_use_deal_volumes oudv on svp.term_start = oudv.term_start
							AND svp.term_end = oudv.term_end 
						LEFT JOIN source_deal_detail sdd ON svp.term_start = sdd.term_start
							AND svp.term_end = sdd.term_end 
							AND svp.leg = sdd.Leg
						WHERE sdd.source_deal_header_id = ' + CAST(@own_power_sdh_id AS VARCHAR(1000)) 
			EXEC spa_print @sql 
			EXEC(@sql)	
		END
		
		UPDATE source_deal_header 
		SET update_user = dbo.FNADBUser()
			, update_ts = GETDATE()
			, header_buy_sell_flag = 'b'  
		WHERE source_deal_header_id = @own_power_sdh_id
	END
	/*Power calc end*/
	
	/*Gas calc start*/
	SELECT	[clm1_value] AS [sb1]
			, [clm2_value] AS [sb2]
			, [clm3_value] AS [sb3]
			, [clm4_value] AS [sb4] 
	INTO #gas_book_collections
	FROM generic_mapping_values 
	WHERE mapping_table_id = @NATURAL_GAS_LIMIT_ID
	
	SELECT sdd.term_start, sdd.term_end, sdd.leg
			, SUM(CASE WHEN sdd.buy_sell_flag = 'b' THEN sdd.deal_volume ELSE (-1 * sdd.deal_volume) END) deal_volume
			, MAX(sdh.source_system_book_id1) source_system_book_id1
			, MAX( sdh.source_system_book_id2) source_system_book_id2
			, MAX(sdh.source_system_book_id3) source_system_book_id3
			, MAX(sdh.source_system_book_id4) source_system_book_id4
		INTO #summed_volume_gas
	FROM source_deal_header sdh 
	INNER JOIN source_deal_detail sdd ON sdd.source_deal_header_id = sdh.source_deal_header_id
		AND sdd.Leg = 1
	INNER JOIN source_system_book_map ssbm ON ssbm.source_system_book_id1 = sdh.source_system_book_id1
		AND ssbm.source_system_book_id2 = sdh.source_system_book_id2
		AND ssbm.source_system_book_id3 = sdh.source_system_book_id3
		AND ssbm.source_system_book_id4 = sdh.source_system_book_id4 AND isnull(sdh.fas_deal_type_value_id,ssbm.fas_deal_type_value_id) IN (410)
	INNER JOIN #gas_book_collections gbc ON gbc.[sb1] = sdh.source_system_book_id1
		AND gbc.[sb2] = sdh.source_system_book_id2
		AND gbc.[sb3] = sdh.source_system_book_id3
		AND gbc.[sb4] = sdh.source_system_book_id4
	WHERE sdh.deal_id NOT IN (@NATURAL_GAS_IDS, 'OWN_USE_DEAL_GAS', 'UK_LIMIT_GAS')
	GROUP BY sdd.term_start, sdd.term_end, sdd.Leg	
	ORDER BY sdd.term_start, sdd.term_end
	 
	SELECT TOP 1 @sb1_gas = source_system_book_id1
			, @sb2_gas = source_system_book_id2
			, @sb3_gas = source_system_book_id3
			, @sb4_gas = source_system_book_id4
	FROM #summed_volume_gas
	
	DECLARE @CHECK_POS_NEG_GAS numeric(28,10) 
	SELECT @CHECK_POS_NEG_GAS = SUM(deal_volume) FROM #summed_volume_gas
	
	IF NOT EXISTS(SELECT 1 FROM source_deal_header WHERE deal_id = 'OWN_USE_DEAL_GAS')
	BEGIN
		INSERT INTO source_deal_header	(source_system_id, deal_id, deal_date, ext_deal_id, physical_financial_flag, structured_deal_id
										, counterparty_id, entire_term_start, entire_term_end, source_deal_type_id, deal_sub_type_type_id
										, option_flag, option_type, option_excercise_type, source_system_book_id1, source_system_book_id2
										, source_system_book_id3, source_system_book_id4, description1, description2, description3, deal_category_value_id
										, trader_id , internal_deal_type_value_id, internal_deal_subtype_value_id, template_id, header_buy_sell_flag, broker_id
										, generator_id, status_value_id, status_date, assignment_type_value_id, compliance_year, state_value_id
										, assigned_date, assigned_by, generation_source, aggregate_environment, aggregate_envrionment_comment
										, rec_price, rec_formula_id, rolling_avg, contract_id, create_user, create_ts, update_user, update_ts
										, legal_entity, internal_desk_id, product_id, internal_portfolio_id, commodity_id, reference
										, deal_locked, close_reference_id, block_type, block_define_id, granularity_id, Pricing
										, deal_reference_type_id, unit_fixed_flag, broker_unit_fees, broker_fixed_cost, broker_currency_id
										, deal_status, term_frequency, option_settlement_date, verified_by, verified_date, risk_sign_off_by
										, risk_sign_off_date, back_office_sign_off_by, back_office_sign_off_date, book_transfer_id, [description4])
		SELECT 20, 'OWN_USE_DEAL_GAS', [deal_date], [ext_deal_id], [physical_financial_flag], [structured_deal_id]
									, [counterparty_id], [entire_term_start], [entire_term_end], [source_deal_type_id], [deal_sub_type_type_id]
									, [option_flag], [option_type], [option_excercise_type], @sb1_gas, @sb2_gas
									, @sb3_gas, @sb4_gas, [description1], [description2], [description3]
									, [deal_category_value_id], [trader_id], [internal_deal_type_value_id], [internal_deal_subtype_value_id]
									, [template_id], [header_buy_sell_flag], [broker_id], [generator_id], [status_value_id], [status_date]
									, [assignment_type_value_id], [compliance_year], [state_value_id], [assigned_date], [assigned_by]
									, [generation_source], [aggregate_environment], [aggregate_envrionment_comment], [rec_price], [rec_formula_id]
									, [rolling_avg], [contract_id], [create_user], [create_ts], [update_user], [update_ts], [legal_entity]
									, [internal_desk_id], [product_id], [internal_portfolio_id], [commodity_id], [reference], [deal_locked]
									, [close_reference_id], [block_type], [block_define_id], [granularity_id], [Pricing], [deal_reference_type_id]
									, [unit_fixed_flag], [broker_unit_fees], [broker_fixed_cost], [broker_currency_id], [deal_status], [term_frequency]
									, [option_settlement_date], [verified_by], [verified_date], [risk_sign_off_by], [risk_sign_off_date]
									, [back_office_sign_off_by], [back_office_sign_off_date], [book_transfer_id], [description4]
		FROM source_deal_header WHERE deal_id = @NATURAL_GAS_IDS

		SELECT @own_gas_sdh_id = SCOPE_IDENTITY()
		
		INSERT INTO source_deal_detail([source_deal_header_id], [term_start], [term_end], [Leg], [contract_expiration_date], [fixed_float_leg]
										, [buy_sell_flag], [deal_volume_frequency], [deal_volume_uom_id], deal_volume, curve_id)
		SELECT  @own_gas_sdh_id, sdd.term_start, sdd.term_end, sdd.[Leg], [contract_expiration_date], [fixed_float_leg]
				, [buy_sell_flag], [deal_volume_frequency], [deal_volume_uom_id], ISNULL(svg.deal_volume, 0), curve_id
		FROM source_deal_detail sdd
		INNER JOIN source_deal_header sdh ON sdh.source_deal_header_id = sdd.source_deal_header_id
		LEFT JOIN #summed_volume_gas svg ON svg.term_start = sdd.term_start
			AND svg.term_end = sdd.term_end 
			AND svg.leg = sdd.Leg
		WHERE sdh.deal_id = @NATURAL_GAS_IDS
		
		SELECT @term_start_gas = MIN(term_start) FROM source_deal_detail WHERE source_deal_header_id = @own_gas_sdh_id
		SELECT @term_end_gas = MAX(term_end) FROM source_deal_detail WHERE source_deal_header_id = @own_gas_sdh_id
		
		UPDATE source_deal_header 
		SET entire_term_start = @term_start_gas
			, entire_term_end = @term_end_gas
		WHERE source_deal_header_id = @own_gas_sdh_id 
	END
	ELSE 
	BEGIN
		SELECT @own_gas_sdh_id = source_deal_header_id FROM source_deal_header WHERE deal_id = 'OWN_USE_DEAL_GAS'
		UPDATE sdd
		SET sdd.deal_volume = ISNULL(svp.deal_volume, 0),
			sdd.update_user = dbo.FNADBUser(),
			sdd.update_ts = GETDATE(),
			sdd.buy_sell_flag = CASE WHEN @CHECK_POS_NEG_GAS < 0 THEN 's' ELSE 'b' END
		FROM source_deal_detail sdd
		LEFT JOIN #summed_volume_gas svp ON svp.term_start = sdd.term_start
			AND svp.term_end = sdd.term_end 
			AND svp.leg = sdd.Leg
		WHERE sdd.source_deal_header_id = @own_gas_sdh_id
		
		UPDATE source_deal_header 
		SET update_user = dbo.FNADBUser()
			, update_ts = GETDATE()
			, header_buy_sell_flag = CASE WHEN @CHECK_POS_NEG_GAS < 0 THEN 's' ELSE 'b' END
		WHERE source_deal_header_id = @own_gas_sdh_id
	END
	
	CREATE TABLE #own_use_deal_volumes_gas (term_start DATETIME, term_end DATETIME, buy_sell_flag CHAR(1) COLLATE DATABASE_DEFAULT, deal_volume FLOAT)
	INSERT INTO #own_use_deal_volumes_gas (term_start, term_end, buy_sell_flag, deal_volume)
	SELECT sdd.term_start, sdd.term_end, sdd.buy_sell_flag, sum(sdd.deal_volume)
	FROM source_deal_header sdh
	INNER JOIN source_deal_detail sdd ON sdd.source_deal_header_id = sdh.source_deal_header_id	
	inner join  #book_gas_deal b
	on sdh.source_system_book_id1=b.sb1 and sdh.source_system_book_id2=b.sb2  and sdh.source_system_book_id3=b.sb3 and sdh.source_system_book_id4=b.sb4
	 group by sdd.term_start, sdd.term_end, sdd.buy_sell_flag

	
	IF NOT EXISTS(SELECT 1 FROM source_deal_header WHERE deal_id = 'UK_LIMIT_GAS')
	BEGIN
		INSERT INTO source_deal_header	(source_system_id, deal_id, deal_date, ext_deal_id, physical_financial_flag, structured_deal_id
										, counterparty_id, entire_term_start, entire_term_end, source_deal_type_id, deal_sub_type_type_id
										, option_flag, option_type, option_excercise_type, source_system_book_id1, source_system_book_id2
										, source_system_book_id3, source_system_book_id4, description1, description2, description3, deal_category_value_id
										, trader_id , internal_deal_type_value_id, internal_deal_subtype_value_id, template_id, header_buy_sell_flag, broker_id
										, generator_id, status_value_id, status_date, assignment_type_value_id, compliance_year, state_value_id
										, assigned_date, assigned_by, generation_source, aggregate_environment, aggregate_envrionment_comment
										, rec_price, rec_formula_id, rolling_avg, contract_id, create_user, create_ts, update_user, update_ts
										, legal_entity, internal_desk_id, product_id, internal_portfolio_id, commodity_id, reference
										, deal_locked, close_reference_id, block_type, block_define_id, granularity_id, Pricing
										, deal_reference_type_id, unit_fixed_flag, broker_unit_fees, broker_fixed_cost, broker_currency_id
										, deal_status, term_frequency, option_settlement_date, verified_by, verified_date, risk_sign_off_by
										, risk_sign_off_date, back_office_sign_off_by, back_office_sign_off_date, book_transfer_id, [description4])
		SELECT 20, 'UK_LIMIT_GAS', [deal_date], [ext_deal_id], [physical_financial_flag], [structured_deal_id]
									, [counterparty_id], [entire_term_start], [entire_term_end], [source_deal_type_id], [deal_sub_type_type_id]
									, [option_flag], [option_type], [option_excercise_type], @sb1_limit, @sb2_limit
									, @sb3_limit, @sb4_limit_gas, [description1], [description2], [description3]
									, [deal_category_value_id], [trader_id], [internal_deal_type_value_id], [internal_deal_subtype_value_id]
									, [template_id], [header_buy_sell_flag], [broker_id], [generator_id], [status_value_id], [status_date]
									, [assignment_type_value_id], [compliance_year], [state_value_id], [assigned_date], [assigned_by]
									, [generation_source], [aggregate_environment], [aggregate_envrionment_comment], [rec_price], [rec_formula_id]
									, [rolling_avg], [contract_id], [create_user], [create_ts], [update_user], [update_ts], [legal_entity]
									, [internal_desk_id], [product_id], [internal_portfolio_id], [commodity_id], [reference], [deal_locked]
									, [close_reference_id], [block_type], [block_define_id], [granularity_id], [Pricing], [deal_reference_type_id]
									, [unit_fixed_flag], [broker_unit_fees], [broker_fixed_cost], [broker_currency_id], [deal_status], [term_frequency]
									, [option_settlement_date], [verified_by], [verified_date], [risk_sign_off_by], [risk_sign_off_date]
									, [back_office_sign_off_by], [back_office_sign_off_date], [book_transfer_id], [description4]
		FROM source_deal_header WHERE deal_id = @NATURAL_GAS_IDS
		
		SELECT @own_gas_sdh_id = SCOPE_IDENTITY()

		INSERT INTO source_deal_detail([source_deal_header_id], [term_start], [term_end], [Leg], [contract_expiration_date], [fixed_float_leg]
				, [buy_sell_flag], [deal_volume_frequency], [deal_volume_uom_id], deal_volume, curve_id)
		SELECT  @own_gas_sdh_id, ISNULL(svg.[term_start], sdd.term_start), ISNULL(svg.[term_end], sdd.term_end), ISNULL(svg.[Leg], sdd.leg), [contract_expiration_date], [fixed_float_leg]
				, 'b', [deal_volume_frequency], [deal_volume_uom_id]
				, CASE WHEN ABS(ISNULL(svg.deal_volume, 0)) > ABS(ISNULL(oudvg.deal_volume, 0)) 
					THEN ISNULL(oudvg.deal_volume, 0) ELSE ISNULL(svg.deal_volume, 0) END 
				, curve_id
		FROM #own_use_deal_volumes_gas oudvg
		INNER JOIN source_deal_detail sdd ON oudvg.term_start = sdd.term_start
			AND oudvg.term_end = sdd.term_end 
		INNER JOIN source_deal_header sdh ON sdh.source_deal_header_id = sdd.source_deal_header_id
		LEFT JOIN #summed_volume_gas svg  ON  svg.term_start = oudvg.term_start
			AND svg.term_end = oudvg.term_end 
			AND svg.leg = sdd.Leg
		WHERE sdh.deal_id = @NATURAL_GAS_IDS
		
		SELECT @term_start_gas = MIN(term_start) FROM source_deal_detail WHERE source_deal_header_id = @own_gas_sdh_id
		SELECT @term_end_gas = MAX(term_end) FROM source_deal_detail WHERE source_deal_header_id = @own_gas_sdh_id
		
		UPDATE source_deal_header 
		SET entire_term_start = @term_start_gas
			, entire_term_end = @term_end_gas
		WHERE source_deal_header_id = @own_gas_sdh_id 
	END
	ELSE 
	BEGIN
		SELECT @own_gas_sdh_id = source_deal_header_id FROM source_deal_header WHERE deal_id = 'UK_LIMIT_GAS'
		
		UPDATE sdd
		SET sdd.deal_volume = ISNULL(CASE WHEN ABS(svp.deal_volume) > ABS(oudvg.deal_volume) THEN oudvg.deal_volume ELSE svp.deal_volume END , 0),
			sdd.update_user = dbo.FNADBUser(),
			sdd.update_ts = GETDATE(),
			sdd.buy_sell_flag = 'b'
		FROM #summed_volume_gas svp 
		LEFT JOIN source_deal_detail sdd ON svp.term_start = sdd.term_start
			AND svp.term_end = sdd.term_end 
			AND svp.leg = sdd.Leg
		INNER JOIN #own_use_deal_volumes_gas oudvg ON  svp.term_start = oudvg.term_start
			AND svp.term_end = oudvg.term_end 
		WHERE sdd.source_deal_header_id = @own_gas_sdh_id  
		
		
		UPDATE source_deal_header 
		SET update_user = dbo.FNADBUser()
			, update_ts = GETDATE()
			, header_buy_sell_flag = CASE WHEN @CHECK_POS_NEG_GAS < 0 THEN 's' ELSE 'b' END
		WHERE source_deal_header_id = @own_gas_sdh_id
	END
	/*Gas calc end*/ 
   
	/*Coal calc start*/
	SELECT	[clm1_value] AS [sb1]
			, [clm2_value] AS [sb2]
			, [clm3_value] AS [sb3]
			, [clm4_value] AS [sb4] 
	INTO #coal_book_collections
	FROM generic_mapping_values 
	WHERE mapping_table_id = @COAL_LIMIT_ID
	
	SELECT sdd.term_start, sdd.term_end, sdd.leg
			, SUM(CASE WHEN sdd.buy_sell_flag = 'b' THEN sdd.deal_volume ELSE (-1 * sdd.deal_volume) END) deal_volume
			, MAX(sdh.source_system_book_id1) source_system_book_id1
			, MAX( sdh.source_system_book_id2) source_system_book_id2
			, MAX(sdh.source_system_book_id3) source_system_book_id3
			, MAX(sdh.source_system_book_id4) source_system_book_id4
		INTO #summed_volume_coal
	FROM source_deal_header sdh 
	INNER JOIN source_deal_detail sdd ON sdd.source_deal_header_id = sdh.source_deal_header_id
		AND sdd.Leg = 1
	INNER JOIN source_system_book_map ssbm ON ssbm.source_system_book_id1 = sdh.source_system_book_id1
		AND ssbm.source_system_book_id2 = sdh.source_system_book_id2
		AND ssbm.source_system_book_id3 = sdh.source_system_book_id3
		AND ssbm.source_system_book_id4 = sdh.source_system_book_id4 AND isnull(sdh.fas_deal_type_value_id,ssbm.fas_deal_type_value_id) IN (410)
	INNER JOIN #coal_book_collections gbc ON gbc.[sb1] = sdh.source_system_book_id1
		AND gbc.[sb2] = sdh.source_system_book_id2
		AND gbc.[sb3] = sdh.source_system_book_id3
		AND gbc.[sb4] = sdh.source_system_book_id4
	WHERE sdh.deal_id NOT IN (@COAL_IDS, 'OWN_USE_DEAL_COAL', 'UK_LIMIT_COAL')
	GROUP BY sdd.term_start, sdd.term_end, sdd.Leg	
	ORDER BY sdd.term_start, sdd.term_end
	
	SELECT TOP 1 @sb1_coal = source_system_book_id1
			, @sb2_coal = source_system_book_id2
			, @sb3_coal = source_system_book_id3
			, @sb4_coal = source_system_book_id4
	FROM #summed_volume_coal
	
	DECLARE @CHECK_OWN_TOTAL_COAL numeric(28,10)
	SELECT @CHECK_OWN_TOTAL_COAL = SUM(deal_volume) FROM #summed_volume_coal
	
	IF NOT EXISTS(SELECT 1 FROM source_deal_header WHERE deal_id = 'OWN_USE_DEAL_COAL')
	BEGIN
		INSERT INTO source_deal_header	(source_system_id, deal_id, deal_date, ext_deal_id, physical_financial_flag, structured_deal_id
										, counterparty_id, entire_term_start, entire_term_end, source_deal_type_id, deal_sub_type_type_id
										, option_flag, option_type, option_excercise_type, source_system_book_id1, source_system_book_id2
										, source_system_book_id3, source_system_book_id4, description1, description2, description3, deal_category_value_id
										, trader_id , internal_deal_type_value_id, internal_deal_subtype_value_id, template_id, header_buy_sell_flag, broker_id
										, generator_id, status_value_id, status_date, assignment_type_value_id, compliance_year, state_value_id
										, assigned_date, assigned_by, generation_source, aggregate_environment, aggregate_envrionment_comment
										, rec_price, rec_formula_id, rolling_avg, contract_id, create_user, create_ts, update_user, update_ts
										, legal_entity, internal_desk_id, product_id, internal_portfolio_id, commodity_id, reference
										, deal_locked, close_reference_id, block_type, block_define_id, granularity_id, Pricing
										, deal_reference_type_id, unit_fixed_flag, broker_unit_fees, broker_fixed_cost, broker_currency_id
										, deal_status, term_frequency, option_settlement_date, verified_by, verified_date, risk_sign_off_by
										, risk_sign_off_date, back_office_sign_off_by, back_office_sign_off_date, book_transfer_id, [description4])
		SELECT 20, 'OWN_USE_DEAL_COAL', [deal_date], [ext_deal_id], [physical_financial_flag], [structured_deal_id]
									, [counterparty_id], [entire_term_start], [entire_term_end], [source_deal_type_id], [deal_sub_type_type_id]
									, [option_flag], [option_type], [option_excercise_type], @sb1_coal, @sb2_coal
									, @sb3_coal, @sb4_coal, [description1], [description2], [description3]
									, [deal_category_value_id], [trader_id], [internal_deal_type_value_id], [internal_deal_subtype_value_id]
									, [template_id], [header_buy_sell_flag], [broker_id], [generator_id], [status_value_id], [status_date]
									, [assignment_type_value_id], [compliance_year], [state_value_id], [assigned_date], [assigned_by]
									, [generation_source], [aggregate_environment], [aggregate_envrionment_comment], [rec_price], [rec_formula_id]
									, [rolling_avg], [contract_id], [create_user], [create_ts], [update_user], [update_ts], [legal_entity]
									, [internal_desk_id], [product_id], [internal_portfolio_id], [commodity_id], [reference], [deal_locked]
									, [close_reference_id], [block_type], [block_define_id], [granularity_id], [Pricing], [deal_reference_type_id]
									, [unit_fixed_flag], [broker_unit_fees], [broker_fixed_cost], [broker_currency_id], [deal_status], [term_frequency]
									, [option_settlement_date], [verified_by], [verified_date], [risk_sign_off_by], [risk_sign_off_date]
									, [back_office_sign_off_by], [back_office_sign_off_date], [book_transfer_id], [description4]
		FROM source_deal_header WHERE deal_id = @COAL_IDS


		SELECT @own_coal_sdh_id = SCOPE_IDENTITY()
		INSERT INTO source_deal_detail([source_deal_header_id], [term_start], [term_end], [Leg], [contract_expiration_date], [fixed_float_leg]
					, [buy_sell_flag], [deal_volume_frequency], [deal_volume_uom_id], deal_volume, curve_id)
		SELECT  @own_coal_sdh_id, sdd.[term_start], sdd.[term_end], sdd.[Leg], [contract_expiration_date], [fixed_float_leg]
				, [buy_sell_flag], [deal_volume_frequency], [deal_volume_uom_id], ISNULL(svg.deal_volume, 0), curve_id
		FROM source_deal_detail sdd
		INNER JOIN source_deal_header sdh ON sdh.source_deal_header_id = sdd.source_deal_header_id
		LEFT JOIN #summed_volume_coal svg ON svg.term_start = sdd.term_start
			AND svg.term_end = sdd.term_end 
			AND svg.leg = sdd.Leg
		WHERE sdh.deal_id = @COAL_IDS
		
		SELECT @term_start_coal = MIN(term_start) FROM source_deal_detail WHERE source_deal_header_id = @own_coal_sdh_id
		SELECT @term_end_coal = MAX(term_end) FROM source_deal_detail WHERE source_deal_header_id = @own_coal_sdh_id
		
		UPDATE source_deal_header 
		SET entire_term_start = @term_start_coal
			, entire_term_end = @term_end_coal
		WHERE source_deal_header_id = @own_coal_sdh_id 
	END
	ELSE 
	BEGIN
		SELECT @own_coal_sdh_id = source_deal_header_id FROM source_deal_header WHERE deal_id = 'OWN_USE_DEAL_COAL'
		--SELECT * 
		UPDATE sdd
		SET sdd.deal_volume = ISNULL(svp.deal_volume, 0),
			sdd.update_user = dbo.FNADBUser(),
			sdd.update_ts = GETDATE(),
			sdd.buy_sell_flag = CASE WHEN @CHECK_OWN_TOTAL_COAL < 0 THEN 's' ELSE 'b' END 
		FROM source_deal_detail sdd
		LEFT JOIN #summed_volume_coal svp ON svp.term_start = sdd.term_start
			AND svp.term_end = sdd.term_end 
			AND svp.leg = sdd.Leg
		WHERE sdd.source_deal_header_id = @own_coal_sdh_id
		
		UPDATE source_deal_header 
		SET update_user = dbo.FNADBUser()
			, update_ts = GETDATE()
			, header_buy_sell_flag = CASE WHEN @CHECK_OWN_TOTAL_COAL < 0 THEN 's' ELSE 'b' END
		WHERE source_deal_header_id = @own_coal_sdh_id
	END
	
	CREATE TABLE #own_use_deal_volumes_coal (term_start DATETIME, term_end DATETIME, buy_sell_flag CHAR(1) COLLATE DATABASE_DEFAULT, deal_volume FLOAT)
	INSERT INTO #own_use_deal_volumes_coal (term_start, term_end, buy_sell_flag, deal_volume)
	SELECT sdd.term_start, sdd.term_end, sdd.buy_sell_flag, sum(sdd.deal_volume	)
	FROM source_deal_header sdh
	INNER JOIN source_deal_detail sdd ON sdd.source_deal_header_id = sdh.source_deal_header_id	
	inner join  #book_coal_deal b
	on sdh.source_system_book_id1=b.sb1 and sdh.source_system_book_id2=b.sb2  and sdh.source_system_book_id3=b.sb3 and sdh.source_system_book_id4=b.sb4
	group by sdd.term_start, sdd.term_end, sdd.buy_sell_flag	
		
	IF NOT EXISTS(SELECT 1 FROM source_deal_header WHERE deal_id = 'UK_LIMIT_COAL')
	BEGIN
		INSERT INTO source_deal_header	(source_system_id, deal_id, deal_date, ext_deal_id, physical_financial_flag, structured_deal_id
										, counterparty_id, entire_term_start, entire_term_end, source_deal_type_id, deal_sub_type_type_id
										, option_flag, option_type, option_excercise_type, source_system_book_id1, source_system_book_id2
										, source_system_book_id3, source_system_book_id4, description1, description2, description3, deal_category_value_id
										, trader_id , internal_deal_type_value_id, internal_deal_subtype_value_id, template_id, header_buy_sell_flag, broker_id
										, generator_id, status_value_id, status_date, assignment_type_value_id, compliance_year, state_value_id
										, assigned_date, assigned_by, generation_source, aggregate_environment, aggregate_envrionment_comment
										, rec_price, rec_formula_id, rolling_avg, contract_id, create_user, create_ts, update_user, update_ts
										, legal_entity, internal_desk_id, product_id, internal_portfolio_id, commodity_id, reference
										, deal_locked, close_reference_id, block_type, block_define_id, granularity_id, Pricing
										, deal_reference_type_id, unit_fixed_flag, broker_unit_fees, broker_fixed_cost, broker_currency_id
										, deal_status, term_frequency, option_settlement_date, verified_by, verified_date, risk_sign_off_by
										, risk_sign_off_date, back_office_sign_off_by, back_office_sign_off_date, book_transfer_id, [description4])
		SELECT 20, 'UK_LIMIT_COAL', [deal_date], [ext_deal_id], [physical_financial_flag], [structured_deal_id]
									, [counterparty_id], [entire_term_start], [entire_term_end], [source_deal_type_id], [deal_sub_type_type_id]
									, [option_flag], [option_type], [option_excercise_type], @sb1_limit, @sb2_limit
									, @sb3_limit, @sb4_limit_coal, [description1], [description2], [description3]
									, [deal_category_value_id], [trader_id], [internal_deal_type_value_id], [internal_deal_subtype_value_id]
									, [template_id], [header_buy_sell_flag], [broker_id], [generator_id], [status_value_id], [status_date]
									, [assignment_type_value_id], [compliance_year], [state_value_id], [assigned_date], [assigned_by]
									, [generation_source], [aggregate_environment], [aggregate_envrionment_comment], [rec_price], [rec_formula_id]
									, [rolling_avg], [contract_id], [create_user], [create_ts], [update_user], [update_ts], [legal_entity]
									, [internal_desk_id], [product_id], [internal_portfolio_id], [commodity_id], [reference], [deal_locked]
									, [close_reference_id], [block_type], [block_define_id], [granularity_id], [Pricing], [deal_reference_type_id]
									, [unit_fixed_flag], [broker_unit_fees], [broker_fixed_cost], [broker_currency_id], [deal_status], [term_frequency]
									, [option_settlement_date], [verified_by], [verified_date], [risk_sign_off_by], [risk_sign_off_date]
									, [back_office_sign_off_by], [back_office_sign_off_date], [book_transfer_id], [description4]
		FROM source_deal_header WHERE deal_id = @COAL_IDS


		SELECT @own_coal_sdh_id = SCOPE_IDENTITY()

		INSERT INTO source_deal_detail([source_deal_header_id], [term_start], [term_end], [Leg], [contract_expiration_date], [fixed_float_leg]
				, [buy_sell_flag], [deal_volume_frequency], [deal_volume_uom_id], deal_volume, curve_id)
		SELECT  @own_coal_sdh_id, sdd.[term_start], sdd.[term_end], sdd.[Leg], [contract_expiration_date], [fixed_float_leg]
				, 'b', [deal_volume_frequency], [deal_volume_uom_id]
				, CASE WHEN ABS(ISNULL(svg.deal_volume, 0)) > ABS(ISNULL(oudvg.deal_volume, 0)) 
					THEN ISNULL(oudvg.deal_volume, 0) ELSE ISNULL(svg.deal_volume, 0) END 
				, curve_id
		FROM #own_use_deal_volumes_coal oudvg
		INNER JOIN source_deal_detail sdd ON oudvg.term_start = sdd.term_start
			AND oudvg.term_end = sdd.term_end 
		INNER JOIN source_deal_header sdh ON sdh.source_deal_header_id = sdd.source_deal_header_id
		LEFT JOIN #summed_volume_coal svg  ON  svg.term_start = oudvg.term_start
			AND svg.term_end = oudvg.term_end 
			AND svg.leg = sdd.Leg
		WHERE sdh.deal_id = @COAL_IDS
		
		SELECT @term_start_coal = MIN(term_start) FROM source_deal_detail WHERE source_deal_header_id = @own_coal_sdh_id
		SELECT @term_end_coal = MAX(term_end) FROM source_deal_detail WHERE source_deal_header_id = @own_coal_sdh_id
		
		UPDATE source_deal_header 
		SET entire_term_start = @term_start_coal
			, entire_term_end = @term_end_coal
		WHERE source_deal_header_id = @own_coal_sdh_id 
	END
	ELSE 
	BEGIN
		SELECT @own_coal_sdh_id = source_deal_header_id FROM source_deal_header WHERE deal_id = 'UK_LIMIT_COAL'
		UPDATE sdd
		SET sdd.deal_volume = ISNULL(CASE WHEN ABS(svp.deal_volume) > ABS(oudvg.deal_volume) THEN oudvg.deal_volume ELSE svp.deal_volume END , 0),   
			sdd.update_user = dbo.FNADBUser(),
			sdd.update_ts = GETDATE(),
			sdd.buy_sell_flag = 'b'  
		FROM #summed_volume_coal svp
		LEFT JOIN source_deal_detail sdd ON svp.term_start = sdd.term_start
			AND svp.term_end = sdd.term_end 
			AND svp.leg = sdd.Leg
		INNER JOIN #own_use_deal_volumes_coal oudvg ON  svp.term_start = oudvg.term_start
			AND svp.term_end = oudvg.term_end 
		WHERE sdd.source_deal_header_id = @own_coal_sdh_id  
	
		UPDATE source_deal_header 
		SET update_user = dbo.FNADBUser()
			, update_ts = GETDATE()
			, header_buy_sell_flag =  'b'  
		WHERE source_deal_header_id = @own_coal_sdh_id
	END
	
	DECLARE @url VARCHAR(MAX)
	DECLARE @desc VARCHAR(MAX)
	
	SET @url = './dev/spa_html.php?__user_name__=' + @user_login_id + '&spa=EXEC spa_calc_UK_limit ''r'''
	SET @desc = 'Calculation of ''''UK - Highly Probable Hedge Limit'''' has been completed, Please <a target="_blank" href="' + @url + '">Click Here </a>to check final limit.'
	EXEC spa_message_board 'i', @user_login_id, NULL, 'UK Limit', @desc, '', '', 'c', @batch_process_id
	
	DECLARE @sub_ids VARCHAR(120), @run_date VARCHAR(10)

	SET @run_date = CONVERT(VARCHAR(10),isnull(@as_of_date, GETDATE()), 120)
	
	--SELECT @sub_ids = ISNULL(@sub_ids + ',', '') + CAST(entity_id AS VARCHAR) FROM portfolio_hierarchy
	--WHERE entity_name ='RWEST UK'
	
	
	SELECT	@sub_ids=isnull(@sub_ids+',','')+ cast(sub_id as varchar) from  #UK_participating_subsidiaries
	
	
	--SELECT @sub_ids = ISNULL(@sub_ids + ',', '') + CAST(s.sub_id AS VARCHAR)
	--from (select distinct d.sub_id from fas_eff_hedge_rel_type h inner join fas_eff_hedge_rel_type_detail d on h.eff_test_profile_id=d.eff_test_profile_id
	-- and isnull(h.matching_type,'a')='p' and d.sub_id is not null
	--) s
	
		--WHERE entity_name IN('RWEST UK','RWEST Participations','RWE Trading Services')


	if ISNULL(@sub_ids,'')<>''
		EXEC spa_calc_process_dynamic_limit @sub_ids, @run_date, 'l', 451, 'l','i' , 'n', 'b', 'a', 'i', 'y', 'n', NULL, 'h', @user_login_id,NULL, 'UK'

	else
	begin
		SET @desc = 'Forecasted transactions automation failed as Subsidiary/Perfect Match Type is not found in hedge relationship type.'
		EXEC spa_message_board 'i', @user_login_id, NULL, 'Forecasted transactions', @desc, '', '', 'e', @batch_process_id
	
	end

	/*	
	select @ids=isnull(@ids+book_deal_type_map_id
	from source_system_book_map
	#gas_book_collections
	#coal_book_collections
	#power_book_collections
	
	book_deal_type_map_id
	fas_book_id
	source_system_book_id1
	source_system_book_id2
	source_system_book_id3
	source_system_book_id4
	*/
END
ELSE IF @flag = 'r'
BEGIN
	SELECT sdh.source_deal_header_id AS [Deal ID]
		, sdh.deal_id AS [Ref ID]
		, dbo.FNAStdDate(sdd.term_start) AS [Term Start]
		, dbo.FNAStdDate(sdd.term_start) AS [term End]
		, sdd.Leg AS [Leg]
		, CASE WHEN sdd.fixed_float_leg = 't' THEN 'Float' ELSE 'Fixed' END AS [Fixed/Float] 
		, CASE WHEN sdd.buy_sell_flag = 'b' THEN 'Buy' ELSE 'Sell' END AS [Buy/Sell] 
		, CASE WHEN sdd.physical_financial_flag = 'p' THEN 'Physical' ELSE 'Financial' END AS [Physical/Financial]
		, dbo.FNAAddThousandSeparator(sdd.deal_volume) AS [Volume]
		, sml.Location_Name AS [Location]
		, spc.curve_name AS [Curve]
		, CASE WHEN sdd.deal_volume_frequency = 'm' THEN 'Monthly'
			WHEN sdd.deal_volume_frequency = 'a' THEN 'Annually' 
			WHEN sdd.deal_volume_frequency = 'y' THEN 'Yearly'
			WHEN sdd.deal_volume_frequency = 'd' THEN 'Daily'
		 END
			AS [Frequency]
		, sc.currency_name AS [Currency]
		, su.uom_name AS [UOM]
	FROM source_deal_header sdh
	INNER JOIN source_deal_detail sdd ON sdd.source_deal_header_id = sdh.source_deal_header_id
	LEFT JOIN source_currency sc ON sc.source_currency_id = sdd.fixed_price_currency_id
	LEFT JOIN source_minor_location sml ON sml.source_minor_location_id = sdd.location_id
	LEFT JOIN source_price_curve_def spc ON spc.source_curve_def_id = sdd.curve_id
	LEFT JOIN source_uom su ON su.source_uom_id = sdd.deal_volume_uom_id
	WHERE sdh.deal_id IN ('UK_LIMIT_COAL', 'UK_LIMIT_GAS', 'UK_LIMIT_POWER')
	AND deal_volume <> 0
	ORDER BY sdh.deal_id
END
