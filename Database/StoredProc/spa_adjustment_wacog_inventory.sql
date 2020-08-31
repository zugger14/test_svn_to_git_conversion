IF EXISTS ( SELECT * FROM   sys.objects WHERE  OBJECT_ID = OBJECT_ID(N'[dbo].[spa_adjustment_wacog_inventory]') AND TYPE IN (N'P', N'PC') )
    DROP PROCEDURE [dbo].[spa_adjustment_wacog_inventory]

GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

 /**
	Adjust WACOG Inventory

	Parameters : 
	@storage_location : Storage Location
	@contract_name : Contract
	@term_start : Term Start
	@product : Product
	@lot : Lot
	@batch_id : Batch ID,]
	@adj_volume : Adjusting Volume
	@adj_type : Adjustment Method
	@process_id : Process ID
	@storage_seq_no : Storage Seq,
	@adj_type_real : Adjustment Type

  */

CREATE PROC [dbo].[spa_adjustment_wacog_inventory]
	@storage_location INT,
	@contract_name VARCHAR(1000),
	@term_start DATETIME,
	@product VARCHAR(200) = NULL,
	@lot VARCHAR(200) = NULL,
	@batch_id VARCHAR(200) = NULL,
	@adj_volume NUMERIC(20,2),
	@adj_type INT = NULL, --adjustment_method
	@process_id VARCHAR(255) = NULL,
	@storage_seq_no INT = NULL,
	@adj_type_real INT = NULL --adjustment_type
AS

SET NOCOUNT ON
/* -- DEBUG --
DECLARE @storage_location INT,
	@contract_id INT,
	@term_start DATETIME,
	@product VARCHAR(200) = NULL,
	@lot VARCHAR(200) = NULL,
	@batch_id VARCHAR(200) = NULL,
	@adj_volume NUMERIC(20,2),
	@adj_type INT = NULL

SELECT @storage_location = 4995
    ,@contract_id = 11545
    ,@term_start = '2019-04-01'
    ,@product = NULL
    ,@lot = NULL
    ,@batch_id = NULL
    ,@adj_volume = 150000
    ,@adj_type = 108301

EXEC spa_drop_all_temp_table
--108301	108300	Write off quantity and value
--108300	108300	Write off quantity, but keep the value
--*/

DECLARE @Sql_Select VARCHAR(8000),
	@location_group VARCHAR(30),
	@include_product_lot VARCHAR(1),
	@injection_as_long VARCHAR(1),
	@deal_sub_type_type_id INT,
	@currency_id INT,
	@storage_book_mapping VARCHAR(500) = 'Storage Book Mapping',
	@adjustment_template_id INT,
	@changed_wacog NUMERIC(20,10),
	@changed_volume NUMERIC(20,2),
	@volumn_uom INT,
	@commodity_id INT,
	@source_counterparty_id INT,
	@storage_assets_id INT = NULL,
	@sub_book_id INT,
	@contract_id INT

DECLARE @total_inventory_vol NUMERIC(20,2),
	@total_inventory_amt NUMERIC(20,2),
	@wacog NUMERIC(20,10)
DECLARE @sql VARCHAR(MAX)

IF @process_id IS NULL 
SET @process_id = dbo.FNAGetNewID()

/* generic mapping chnages */
DECLARE @final_storage_inventory_grouped VARCHAR(MAX)

SET @final_storage_inventory_grouped = dbo.FNAProcessTableName('final_storage_inventory_grouped', dbo.FNADBUser(), @process_id)

CREATE TABLE #storage_info (source_minor_location_id INT, contract_id INT, source_counterparty_id INT, source_commodity_id INT) 

SET @sql  = 'INSERT INTO #storage_info(source_minor_location_id, contract_id, source_counterparty_id, source_commodity_id)
			SELECT a.source_minor_location_id, cg.contract_id, sc.source_counterparty_id, com.source_commodity_id
			FROM ' + @final_storage_inventory_grouped + ' a
 			LEFT JOIN contract_group cg ON cg.contract_name = a.contract
			LEFT JOIN source_counterparty sc ON sc.counterparty_name = a.operator
			LEFT JOIN source_commodity com ON com.commodity_name = a.product
			WHERE a.seq_no = ' + CAST(@storage_seq_no AS VARCHAR(100))
EXEC spa_print @sql
EXEC(@sql)


DECLARE @storage_source_minor_location_id INT
DECLARE @storage_contract_id INT
DECLARE @storage_source_counterparty_id INT
DECLARE @storage_source_commodity_id INT

SELECT @storage_source_minor_location_id = source_minor_location_id
	, @storage_contract_id = contract_id
	, @storage_source_counterparty_id = source_counterparty_id
	, @storage_source_commodity_id = source_commodity_id 
FROM #storage_info

-- Resolve contract ID from contract Name provided
SELECT @contract_id = contract_id FROM contract_group WHERE [contract_name] = @contract_name

SELECT @injection_as_long = ISNULL(g.injection_as_long, 'y'),
	@include_product_lot = ISNULL(g.include_product_lot, 'n'),
	@storage_assets_id = g.general_assest_id,
	@currency_id = cg.currency,
	@volumn_uom = g.volumn_uom,
	@commodity_id = g.commodity_id,
	@source_counterparty_id = g.source_counterparty_id
FROM general_assest_info_virtual_storage g
LEFT JOIN contract_group cg ON cg.contract_id = g.agreement
LEFT JOIN storage_asset sa ON sa.storage_asset_id = g.storage_asset_id
WHERE g.storage_location=@storage_location
	AND g.agreement = @contract_id
	
	
SELECT TOP(1) @wacog = wacog,
	@total_inventory_vol = total_inventory_vol,
	@total_inventory_amt = total_inventory_amt
-- SELECT *
FROM calcprocess_storage_wacog 
WHERE storage_assets_id = @storage_assets_id
	AND term <= @term_start
	AND ISNULL(product, '-1') = CASE WHEN ISNULL(@include_product_lot,'n')='y' THEN COALESCE(@product,product, '-1') ELSE ISNULL(product, '-1') END
	AND ISNULL(lot, '-1') = CASE WHEN ISNULL(@include_product_lot,'n')='y' THEN COALESCE(@lot,lot, '-1') ELSE ISNULL(lot, '-1') END
	AND ISNULL(batch_id, '-1') = CASE WHEN ISNULL(@include_product_lot,'n')='y' THEN COALESCE(@batch_id,batch_id, '-1') ELSE ISNULL(batch_id, '-1') END 
ORDER BY term DESC
	     
--108301	108300	Write off quantity and value
--108300	108300	Write off quantity, but keep the value

IF @adj_type=108301
BEGIN
	SET @changed_wacog = @wacog
	SET @changed_volume = @adj_volume
END
ELSE
BEGIN
	SET @changed_volume = @adj_volume
	SET @changed_wacog = @total_inventory_amt/(@total_inventory_vol+@adj_volume)
END	
	
/* --new generic mapping setup : required for later purpose : do not remove
DECLARE @str_type VARCHAR(1000)
SET @str_type = CASE WHEN @injection_as_long = 'y' THEN
					CASE WHEN @changed_volume < 0 THEN 'Injection' ELSE 'Withdrawal' END
				ELSE
					CASE WHEN @changed_volume > 0 THEN 'Injection' ELSE 'Withdrawal' END
				END

DECLARE @mapping_name01 VARCHAR(100)
SELECT @mapping_name01 = 'Storage Book Mapping'
	
IF OBJECT_ID('tempdb..#generic_mapping_data') IS NOT NULL 
	DROP TABLE #generic_mapping_data

CREATE TABLE #generic_mapping_data (
		storage_type VARCHAR(1000)
	, template_id INT
	, sub_book INT
	, [location] INT
	, location_to INT
	, counterparty INT
	, [contract] INT
	, buy_sell_flag CHAR(1)
	, combination INT)

SET @sql = '
			INSERT INTO #generic_mapping_data(storage_type, template_id, sub_book, [location], location_to, counterparty, [contract])
			SELECT clm1_value storage_type, clm6_value template, clm7_value sub_book, clm2_value location
				, clm3_value location_to, clm4_value counterparty, clm5_value contract
			FROM generic_mapping_header gmh
			INNER JOIN generic_mapping_values gmv ON gmv.mapping_table_id = gmh.mapping_table_id
			WHERE gmh.mapping_name IN (''' + @mapping_name01 + ''')
				AND clm1_value IN ('''  + @str_type + ''')'
 
EXEC spa_print @sql 
EXEC (@sql)
 
 
UPDATE #generic_mapping_data 
SET combination = CASE WHEN ISNULL([location], @storage_source_minor_location_id) = @storage_source_minor_location_id THEN CASE WHEN [location] IS NULL THEN 1 ELSE 2 END ELSE -5 END 
					+ CASE WHEN ISNULL(counterparty, @storage_source_counterparty_id) = @storage_source_counterparty_id THEN CASE WHEN counterparty IS NULL THEN 1 ELSE 2 END ELSE -5 END 
					+ CASE WHEN ISNULL([contract], @storage_contract_id) = @storage_contract_id THEN CASE WHEN [contract] IS NULL THEN 1 ELSE 2 END ELSE -5 END	


IF OBJECT_ID ('tempdb..#generic_mapping_data_final') IS NOT NULL 
	DROP TABLE #generic_mapping_data_final
 
SELECT z.storage_type, 
	MAX(gmd.template_id) template_id
	, MAX(gmd.sub_book) sub_book
	, MAX([location]) [location]
	, MAX(gmd.location_to) location_to 
	, MAX(counterparty) counterparty
	, MAX([contract]) [contract]
	, MAX(gmd.buy_sell_flag) buy_sell_flag
	, z.combination
INTO #generic_mapping_data_final
FROM #generic_mapping_data gmd
INNER JOIN (SELECT storage_type, MAX(combination) combination
			FROM #generic_mapping_data
 			GROUP BY storage_type) z ON z.storage_type = gmd.storage_type
				AND z.combination = gmd.combination
GROUP BY z.storage_type, z.combination

SELECT @sub_book_id = sub_book FROM #generic_mapping_data_final
SELECT @adjustment_template_id = template_id FROM #generic_mapping_data_final
*/
--select @sub_book_id, @adjustment_template_id
--select * from #generic_mapping_data
--select * from #generic_mapping_data_final
--return 

/* generic mapping chnages end */

 
SELECT @sub_book_id=CAST(clm4_value AS INT)
FROM generic_mapping_header h
INNER JOIN generic_mapping_values v ON  v.mapping_table_id = h.mapping_table_id
	AND h.mapping_name = @storage_book_mapping
WHERE CAST(clm1_value AS INT) =	@storage_location
	AND clm2_value ='n' AND CAST(clm3_value AS INT) = @source_counterparty_id

SELECT @adjustment_template_id = template_id 
FROM source_deal_header_template 
WHERE template_name = 
	CASE WHEN @injection_as_long = 'y' THEN
		CASE WHEN @changed_volume < 0 THEN 'Storage Injection' ELSE 'Storage Withdrawal' END
	ELSE
		CASE WHEN @changed_volume > 0 THEN 'Storage Injection' ELSE 'Storage Withdrawal' END
	END

 
CREATE TABLE #tmp_deal_header(source_deal_header_id INT)
	
BEGIN TRY
	DECLARE @user VARCHAR(20) = dbo.FNADBUSER()
	DECLARE @msg VARCHAR(MAX) = 'Batch process has been scheduled to run.'
	DECLARE @msg_complete VARCHAR(MAX) = 'Batch process has been completed successfully.'
	DECLARE @job_name VARCHAR(MAX) = 'Adjustment_Wacog_Inventory_Job_' + CAST(@storage_location AS VARCHAR(50)) + '_' + @process_id 

	EXEC spa_message_board 'i', @user, NULL, 'Inventory Adjustment' , @msg, '', '', 's', @job_name, NULL , @process_id
		
	-- Insert into source deal header
	INSERT INTO [dbo].[source_deal_header]
	(
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
		[create_user],
		[create_ts],
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
		[Pricing],
		[deal_reference_type_id],
		[unit_fixed_flag],
		[broker_unit_fees],
		[broker_fixed_cost],
		[broker_currency_id],
		[deal_status],
		[term_frequency],
		[option_settlement_date],
		[verified_by],
		[verified_date],
		[risk_sign_off_by],
		[risk_sign_off_date],
		[back_office_sign_off_by],
		[back_office_sign_off_date],
		[book_transfer_id],
		[confirm_status_type],
		[sub_book],
		[deal_rules],
		[confirm_rule],
		[description4],
		[timezone_id]
	)
	OUTPUT INSERTED.[source_deal_header_id] INTO #tmp_deal_header([source_deal_header_id])
	SELECT sdh_tmp.[source_system_id],
		'Adj' + CASE WHEN adj_type.code IS NOT NULL THEN '_'+adj_type.code ELSE '' END,
		@term_start -1  ,
		sdh_tmp.[ext_deal_id],
		sdh_tmp.[physical_financial_flag],
		sdh_tmp.[structured_deal_id],
		@source_counterparty_id [counterparty_id],
		@term_start,
		@term_start,
		sdh_tmp.[source_deal_type_id],
		sdh_tmp.[deal_sub_type_type_id],
		sdh_tmp.[option_flag],
		sdh_tmp.[option_type],
		sdh_tmp.[option_excercise_type],
		ISNULL( ssbm.source_system_book_id1,-1 ),
		ISNULL( ssbm.source_system_book_id2,-2),
		ISNULL( ssbm.source_system_book_id3,-3 ),
		ISNULL( ssbm.source_system_book_id4,-4 ),
		Case When @adj_type=108300 then @adj_type else null end [description1],
		adj_type.[description] [description2],
		sdh_tmp.[description3],
		sdh_tmp.[deal_category_value_id],
		sdh_tmp.[trader_id],
		sdh_tmp.[internal_deal_type_value_id],
		sdh_tmp.[internal_deal_subtype_value_id],
		sdh_tmp.[template_id],
		sdh_tmp.[header_buy_sell_flag],
		sdh_tmp.[broker_id],
		sdh_tmp.[generator_id],
		sdh_tmp.[status_value_id],
		sdh_tmp.[status_date],
		sdh_tmp.[assignment_type_value_id],
		sdh_tmp.[compliance_year],
		sdh_tmp.[state_value_id],
		sdh_tmp.[assigned_date],
		sdh_tmp.[assigned_by],
		sdh_tmp.[generation_source],
		sdh_tmp.[aggregate_environment],
		sdh_tmp.[aggregate_envrionment_comment],
		sdh_tmp.[rec_price],
		sdh_tmp.[rec_formula_id],
		sdh_tmp.[rolling_avg],
		isnull(@contract_id,sdh_tmp.[contract_id]) [contract_id],
		sdh_tmp.[create_user],
		GETDATE(),
		sdh_tmp.[update_user],
		GETDATE(),
		sdh_tmp.[legal_entity],
		sdh_tmp.[internal_desk_id],
		sdh_tmp.[product_id],
		sdh_tmp.[internal_portfolio_id],
		isnull(@commodity_id,sdh_tmp.[commodity_id]) [commodity_id],
		sdh_tmp.[reference],
		'n' [deal_locked],
		sdh_tmp.[close_reference_id],
		sdh_tmp.[block_type],
		sdh_tmp.[block_define_id],
		sdh_tmp.[granularity_id],
		sdh_tmp.[Pricing],
		sdh_tmp.[deal_reference_type_id],
		sdh_tmp.[unit_fixed_flag],
		sdh_tmp.[broker_unit_fees],
		sdh_tmp.[broker_fixed_cost],
		sdh_tmp.[broker_currency_id],
		sdh_tmp.[deal_status],
		sdh_tmp.[term_frequency_type],
		sdh_tmp.[option_settlement_date],
		sdh_tmp.[verified_by],
		sdh_tmp.[verified_date],
		sdh_tmp.[risk_sign_off_by],
		sdh_tmp.[risk_sign_off_date],
		sdh_tmp.[back_office_sign_off_by],
		sdh_tmp.[back_office_sign_off_date],
		sdh_tmp.[book_transfer_id],
		sdh_tmp.[confirm_status_type],
		@sub_book_id,
		sdh_tmp.[deal_rules],
		sdh_tmp.[confirm_rule],
		RIGHT('00000000' + CAST(@storage_assets_id AS VARCHAR(20)), 8) + '~' + ISNULL(@product, 'NULL') + '~' + ISNULL(@lot, 'NULL') + '~' + ISNULL(@batch_id, 'NULL') 
		[description4],
		sdh_tmp.[timezone_id]
	FROM source_deal_header_template sdh_tmp
	LEFT JOIN source_system_book_map ssbm ON ssbm.book_deal_type_map_id = @sub_book_id
	LEFT JOIN static_data_value adj_type ON adj_type.value_id = @adj_type_real
		AND adj_type.[type_id] = 111500
	WHERE sdh_tmp.template_id=@adjustment_template_id	

	-- Insert into source deal detail
	INSERT INTO [dbo].[source_deal_detail]
	(
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
		[Contractual_volume],
		[deal_volume],
		[Total_volume],
		[deal_volume_frequency],
		[deal_volume_uom_id],
		[block_description],
		[deal_detail_description],
		[formula_id],
		[volume_left],
		[settlement_volume],
		[settlement_uom],
		[create_user],
		[create_ts],
		[update_user],
		[update_ts],
		[price_adder],
		[price_multiplier],
		[settlement_date],
		[day_count_id],
		[location_id],
		[meter_id],
		[physical_financial_flag],
		[Booked],
		[process_deal_status],
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
		[formula_curve_id],
		[price_uom_id],
		[category],
		[profile_code],
		[pv_party],
		[status],
		[lock_deal_detail],
		lot,
		product_description,
		batch_id
	) 
	SELECT th.[source_deal_header_id],
		@term_start,
		@term_start,
		sdd_tmp.[Leg],
		@term_start,
		sdd_tmp.[fixed_float_leg],
		sdd_tmp.[buy_sell_flag],
		sdd_tmp.[curve_id],
		--@changed_wacog [fixed_price],
		Case When @adj_type=108300 then NULL else @changed_wacog  end [fixed_price] ,
		isnull(@currency_id,sdd_tmp.[fixed_price_currency_id]) [fixed_price_currency_id],
		sdd_tmp.[option_strike_price],
		abs(@changed_volume) [Contractual_volume],
		abs(@changed_volume) [deal_volume],
		abs(@changed_volume) [total_volume],
		'd',
		--sdd_tmp.[deal_volume_frequency],
		isnull(@volumn_uom,sdd_tmp.[deal_volume_uom_id]) [deal_volume_uom_id],
		sdd_tmp.[block_description],
		sdd_tmp.[deal_detail_description],
		null [formula_id],
		abs(@changed_volume)  [volume_left],
		sdd_tmp.[settlement_volume],
		sdd_tmp.[settlement_uom],
		sdd_tmp.[create_user],
		GETDATE() [create_ts],
		sdd_tmp.[update_user],
		GETDATE() [update_ts],
		sdd_tmp.[price_adder],
		sdd_tmp.[price_multiplier],
		sdd_tmp.[settlement_date],
		sdd_tmp.[day_count_id],
		@storage_location  location_id,
		sdd_tmp.[meter_id],
		sdd_tmp.[physical_financial_flag],
		sdd_tmp.[Booked],
		sdd_tmp.[process_deal_status],
		sdd_tmp.[fixed_cost],
		sdd_tmp.[multiplier],
		isnull(@currency_id,sdd_tmp.[adder_currency_id]) [adder_currency_id],
		isnull(@currency_id,sdd_tmp.[fixed_cost_currency_id]) [fixed_cost_currency_id],
		isnull(@currency_id,sdd_tmp.[formula_currency_id]) [formula_currency_id],
		sdd_tmp.[price_adder2],
		isnull(@currency_id,sdd_tmp.[price_adder_currency2]) [price_adder_currency2],
		sdd_tmp.[volume_multiplier2] ,
		sdd_tmp.[pay_opposite],
		sdd_tmp.[capacity],
		isnull(@currency_id,sdd_tmp.[settlement_currency]) [settlement_currency],
		sdd_tmp.[standard_yearly_volume],
		sdd_tmp.[formula_curve_id],
		sdd_tmp.[price_uom_id],
		sdd_tmp.[category],
		sdd_tmp.[profile_code],
		sdd_tmp.[pv_party],
		sdd_tmp.[status],
		sdd_tmp.[lock_deal_detail],
		@lot,
		@product,
		@batch_id
	FROM 
		(select * from [dbo].[source_deal_detail_template] where template_id=@adjustment_template_id ) sdd_tmp
		cross join #tmp_deal_header th

	UPDATE source_deal_header
	SET deal_id = deal_id + '_' + CAST(sdh.source_deal_header_id AS VARCHAR)
	FROM source_deal_header sdh
	INNER JOIN #tmp_deal_header th ON sdh.source_deal_header_id = th.source_deal_header_id

	DELETE calcprocess_storage_wacog
	WHERE storage_assets_id = @storage_assets_id
		AND term >= @term_start
		AND ISNULL(product, '-1') = CASE WHEN ISNULL(@include_product_lot,'n') = 'y' THEN COALESCE(@product,product, '-1') ELSE ISNULL(product, '-1') END
		AND ISNULL(lot, '-1') = CASE WHEN ISNULL(@include_product_lot,'n') = 'y' THEN COALESCE(@lot,lot, '-1') ELSE ISNULL(lot, '-1') END
		AND ISNULL(batch_id, '-1') = CASE WHEN ISNULL(@include_product_lot,'n') = 'y' THEN COALESCE(@batch_id,batch_id, '-1') ELSE ISNULL(batch_id, '-1') END 

	--Declared new variables to call settlement and wacog
	DECLARE @s_term_start VARCHAR(100), @s_as_of_date VARCHAR(100), @source_deal_header_id VARCHAR(500), @w_term_start DATETIME
	SET @s_term_start = CONVERT(VARCHAR(7), @term_start, 120)+'-01'
	SET @s_as_of_date = CONVERT(VARCHAR(10), @term_start, 120)

	SELECT @source_deal_header_id = COALESCE(@source_deal_header_id + ',', '') + CAST(source_deal_header_id AS VARCHAR)
	FROM #tmp_deal_header 
	GROUP BY source_deal_header_id
	
	--Called settlement for newly created deal
	IF @source_deal_header_id IS NOT NULL
	BEGIN
		EXEC [dbo].[spa_calc_mtm_job]
			@as_of_date = @s_as_of_date,
			@source_deal_header_id = @source_deal_header_id,
			@term_start = @s_term_start,
			@term_end = @s_as_of_date,
			@curve_source_value_id = 4500,
			@pnl_source_value_id = NULL,
			@criteria_id = NULL,
			@calc_type = 's'

		SET @w_term_start = [dbo].[FNAGetContractMonth](@term_start)
		SET @product = CASE WHEN @include_product_lot = 'Y' THEN @product ELSE NULL END
		SET @lot = CASE WHEN @include_product_lot = 'Y' THEN @lot ELSE NULL END
		SET @batch_id = CASE WHEN @include_product_lot = 'Y' THEN @batch_id ELSE NULL END

		--Called wacog for new storage id with given parameters as location, lot etc.
		EXEC [dbo].[spa_calc_storage_wacog]
			@term_start  = @w_term_start,
			@term_end  = @term_start,
			@flag  = 'b', -- 's',  ---'o'=offset;  'b'=both ;
			@as_of_date   = @term_start,
			@storage_assets_id  = @storage_assets_id, --'2',  --general_assest_info_virtual_storage
			@product= @product,
			@lot = @lot,
			@batch_id= @batch_id,
			@contract  = @contract_id,
			@location_id  = @storage_location
	END
	EXEC spa_ErrorHandler 0
		,'WACOG Inventory Adjustment'
		,'spa_adjustment_wacog_inventory'
		,'Success'
		,'Successfully saved adjustment wacog inventory.'
		,''

	EXEC spa_message_board 'i', @user, NULL, 'Inventory Adjustment' , @msg_complete, '', '', 's', @job_name, NULL , @process_id
END TRY

BEGIN CATCH
	--PRINT 'Catch Error:' + ERROR_MESSAGE()	
	EXEC spa_ErrorHandler -1
		,'WACOG Inventory Adjustment'
		,'spa_adjustment_wacog_inventory'
		,'Error'
		,'Fail to save adjustment wacog inventory.'
		,''
END CATCH

GO