IF OBJECT_ID(N'[dbo].[spa_create_begining_balance]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].spa_create_begining_balance
GO
 
SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 



/**   
	Creates storage and transportation deals using templates that are mapped in generic mapping and create shipments accordingly.

	-- Parameters:
	@flag  										:  's' - get product for detail
													   'c' - Creates storage and transportation deals using templates that are mapped in generic mapping and create shipments
													   'a' - Shipment Status to show Delivery Detail Grid
													   'b' - Get Liquidation Location ID of respective counterparty id
	@source_deal_detail_id 						: source deal detail id 
	@commodity_name  							: commodity name from storage grid
	@term_start 								: term start of deal 
	@quantity  									: volume to create shipment and deals
	@location_from_name   						: source location name 
	@location_to  								: destination location 
	@contract_id 								: contract id from storage grid
	@balance_qty  								: total quantity available 
	@deal_detail_id_split_deal_detail_volume_id : deal detail with split id
	@converted_uom  							: conversion UOM
	@counterparty_id  							: counterparty ID from storage grid
	@callfrom  									: call from flag
	@product_type 								: 1 oil : 0 soft commodity
	@contract_id_from_storage  					: contract from storage grid
	@counterparty_from_storage  				: counterparty from storage grid
	@is_pipeline 								: flag to check pipleine
	@mode_of_trans  							: Mode of transportation
	@trans_path_xml_value 						: XML value to create transportaion deal
	@lot										: lot value for storage grid
**/

CREATE PROCEDURE [dbo].spa_create_begining_balance
    @flag CHAR(1),
	@source_deal_detail_id INT = NULL,
	@commodity_name VARCHAR(1000) = NULL,
	@term_start DATETIME = NULL,
	@quantity NUMERIC(38, 18) = NULL,
	@location_from_name VARCHAR(MAX) = NULL,
	@location_to INT = NULL,
	@contract_id INT = NULL,
	@balance_qty  NUMERIC(38, 18) = NULL,
	@deal_detail_id_split_deal_detail_volume_id VARCHAR(1000) = NULL,
	@converted_uom INT = NULL,
	@counterparty_id INT = NULL,
	@callfrom VARCHAR(MAX) = NULL,
	@product_type INT = NULL, --1 oil : 0 soft commodity
	@contract_id_from_storage VARCHAR(MAX) = NULL,
	@counterparty_from_storage VARCHAR(MAX) = NULL,
	@is_pipeline VARCHAR(1000) = NULL,
	@mode_of_trans INT = NULL,
	@trans_path_xml_value VARCHAR(MAX) = NULL,
	@lot VARCHAR(1000) = NULL -- added for inject into storage
AS

 
/* DEBUG
DECLARE @flag CHAR(1),
	@source_deal_detail_id INT = NULL,
	@commodity_name VARCHAR(1000) = NULL,
	@term_start DATETIME = NULL,
	@quantity NUMERIC(38, 18) = NULL,
	@location_from_name VARCHAR(MAX) = NULL,
	@location_to INT = NULL,
	@contract_id INT = NULL,
	@balance_qty  NUMERIC(38, 18) = NULL,
	@deal_detail_id_split_deal_detail_volume_id VARCHAR(1000) = NULL,
	@converted_uom INT = NULL,
	@counterparty_id INT = NULL,
	@callfrom VARCHAR(MAX) = NULL,
	@product_type INT = NULL, --1 oil : 0 soft commodity
	@contract_id_from_storage VARCHAR(MAX) = NULL,
	@counterparty_from_storage VARCHAR(MAX) = NULL,
	@is_pipeline VARCHAR(1000) = NULL,
	@mode_of_trans INT = NULL,
	@trans_path_xml_value VARCHAR(MAX) = NULL

SELECT 
@flag='c',@quantity='10',@location_to='5011',@term_start='2019-03-01',@commodity_name='Crude Oil',@contract_id='11597',@source_deal_detail_id='250201',@balance_qty='980.00',@location_from_name='5010',@deal_detail_id_split_deal_detail_volume_id='250201_16637',@converted_uom='1082',@counterparty_id='10200',@callfrom='from_purchase',@product_type='1',@contract_id_from_storage='',@counterparty_from_storage='Pipeline Counterparty A',
@trans_path_xml_value='<GridXML>
<GridRow delivery_path_name="Pipeline Location A-Pipeline Location B-Truck" delivery_path_id="" path_id="254" receiving_location="Pipeline Location A [Pipeline]" rec_loc_id="5010" delivery_location="Pipeline Location B [Pipeline]" del_loc_id="5011" mode_of_transport="Truck" mode_of_transport_id="50000195" booking_counterparty="7641" carrier_counterparty="" contract_id="11511" rate_schedule="" day="" hour="">
</GridRow>
</GridXML>'
--*/

SET NOCOUNT ON  

DECLARE @sql VARCHAR(MAX)
	DECLARE  @process_id VARCHAR(1000) = dbo.FNAGetNewID()

IF OBJECT_ID('tempdb..#quantity_conversion') IS NOT NULL
	DROP TABLE #quantity_conversion

IF OBJECT_ID('tempdb..#trans_grid_data') IS NOT NULL
	DROP TABLE #trans_grid_data

IF OBJECT_ID('tempdb..#quantity_conversion') IS NULL
	CREATE TABLE #quantity_conversion(from_source_uom_id INT, to_source_uom_id INT, conversion_factor NUMERIC(38,18), uom_name_from VARCHAR(1000) COLLATE DATABASE_DEFAULT)

DECLARE @live_status_setup INT 
SELECT @live_status_setup  = var_value
FROM adiha_default_codes_values 
WHERE default_code_id = 102

IF ISNULL(@live_status_setup, 0) = 1
BEGIN
	SET @is_pipeline = 'Pipeline'
END 
CREATE TABLE #trans_grid_data (booking_counterparty INT , carrier_counterparty INT	
							, contract_id INT, [day] INT, del_loc_id INT, delivery_location VARCHAR(1000) COLLATE DATABASE_DEFAULT
							, delivery_path_id	INT, delivery_path_name VARCHAR(1000) COLLATE DATABASE_DEFAULT, hour INT
							, mode_of_transport	VARCHAR(1000) COLLATE DATABASE_DEFAULT, mode_of_transport_id INT, path_id INT
							, rate_schedule INT, rec_loc_id INT, receiving_location VARCHAR(1000) COLLATE DATABASE_DEFAULT)  

DECLARE @delivery_details_table VARCHAR(300)  
DECLARE @idoc INT
   		 	
IF @trans_path_xml_value = '<GridXML></GridXML>'
	SET @trans_path_xml_value = NULL

IF @trans_path_xml_value IS NOT NULL 
BEGIN 
	SET @delivery_details_table = dbo.FNAProcessTableName('delivery_details', dbo.FNADBUser(), @process_id)	   			
	EXEC spa_parse_xml_file 'b', NULL, @trans_path_xml_value, @delivery_details_table	
    
	SET @sql = 'INSERT INTO #trans_grid_data
				SELECT * FROM ' + @delivery_details_table 

	EXEC spa_print @sql
	EXEC(@sql)
END
  
--select  * from #trans_grid_data 
--  return 

--quantity_conversion
INSERT INTO #quantity_conversion
SELECT from_source_uom_id,to_source_uom_id, MAX(conversion_factor) conversion_factor, uom_name uom_name_from
	FROM (SELECT rvuc.from_source_uom_id, rvuc.to_source_uom_id, rvuc.conversion_factor, su.uom_name
		FROM rec_volume_unit_conversion rvuc
		INNER JOIN source_uom su ON rvuc.from_source_uom_id = su.source_uom_id
		WHERE to_source_uom_id = @converted_uom
		UNION ALL
		SELECT to_source_uom_id from_source_uom_id, from_source_uom_id to_source_uom_id,  1/conversion_factor conversion_factor, su.uom_name
		FROM rec_volume_unit_conversion rvuc
		INNER JOIN source_uom su ON rvuc.to_source_uom_id = su.source_uom_id

		WHERE from_source_uom_id = @converted_uom
	) a
GROUP BY from_source_uom_id,to_source_uom_id, uom_name

IF @contract_id = ''
	SET @contract_id = NULL 

IF @flag = 's' -- product for detail
BEGIN
    SELECT sdd.product_description, sdd.term_start
	FROM source_deal_detail sdd
	--INNER JOIN source_deal_header sdh ON sdh.source_deal_header_id = sdd.source_deal_header_id 
	WHERE source_deal_detail_id = @source_deal_detail_id
END
ELSE IF @flag = 'c'-- save deal
BEGIN
	DECLARE @loc_from_region INT 
	DECLARE @loc_to_region INT

	SELECT @loc_from_region = ISNULL(region, source_minor_location_id) FROM source_minor_location WHERE source_minor_location_id = @location_from_name
	SELECT @loc_to_region = ISNULL(region, source_minor_location_id) FROM source_minor_location WHERE source_minor_location_id = @location_to
 
	IF @commodity_name IS NULL OR @commodity_name = ''
	BEGIN
		EXEC spa_ErrorHandler -1,
             'Matching/Bookout Deals',
             'spa_scheduling_workbench',
             'DB Error',
             'Deal does not have commodity.',
             ''
		RETURN
	END

	IF @location_to = 0
	BEGIN
		EXEC spa_ErrorHandler -1,
			'Matching/Bookout Deals',
			'spa_scheduling_workbench',
			'DB Error',
			'<b>Destination location</b> is not defined.',
			''
			
		RETURN
	END
 
	IF @location_to <> @location_from_name AND @trans_path_xml_value IS NULL
	BEGIN
		IF ISNULL(@loc_from_region, 0) <> ISNULL(@loc_to_region, 0)
		BEGIN 		
			EXEC spa_ErrorHandler -1,
				 'Matching/Bookout Deals',
				 'spa_scheduling_workbench',
				 'DB Error',
				 'Please select transportation path.',
				 ''
			
			RETURN
		END
	END 

	DECLARE @purchase_source_deal_header_id INT 
	 
	IF @callfrom = 'from_storage'
	BEGIN
		SELECT TOP 1 @source_deal_detail_id = sdd_pur.source_deal_detail_id, @purchase_source_deal_header_id = sdd_pur.source_deal_header_id
			--, mgd.lot source_deal_detail_id --, tgt.source_commodity_id, tgt.contract_id, tgt.location_id
			--, mgd.lot, sdd_pur.source_deal_header_id
		FROM source_deal_header sdh
		INNER JOIN source_deal_detail sdd ON sdd.source_deal_header_id = sdh.source_deal_header_id 
		INNER JOIN match_group_detail mgd ON mgd.source_deal_detail_id = sdd.source_deal_detail_id
		INNER JOIN source_deal_type sdt ON sdt.source_deal_type_id = sdh.source_deal_type_id
		INNER JOIN contract_group cg ON cg.[contract_id] = sdh.contract_id AND cg.[contract_name] = @contract_id_from_storage
		INNER JOIN source_deal_detail sdd_pur ON sdd_pur.source_deal_detail_id = mgd.lot	
		INNER JOIN source_minor_location sml ON sml.source_minor_location_id = sdd.location_id 
			AND sml.source_minor_location_id = @location_from_name
		LEFT JOIN general_assest_info_virtual_storage gaivs ON gaivs.agreement = cg.[contract_id] AND gaivs.storage_location = sml.source_minor_location_id
		LEFT JOIN source_commodity sssc ON sssc.source_commodity_id = gaivs.commodity_id
		WHERE 1 = 1  
			AND sdt.deal_type_id = 'Storage'
	END
	ELSE 
	BEGIN 
		SELECT @purchase_source_deal_header_id = source_deal_header_id FROM source_deal_detail WHERE source_deal_detail_id = @source_deal_detail_id
	END

	DECLARE @from_source_deal_header_id INT 
	DECLARE @sub_book INT
	DECLARE @template_id INT
	DECLARE @template_id_str INT
	DECLARE @template_id_tx INT
	DECLARE @commodity_id INT
	DECLARE @new_source_deal_header_id INT
	DECLARE @deal_pre VARCHAR(MAX)
	DECLARE @location_id INT
	DECLARE @new_source_deal_detail_id INT
	DECLARE @user_login_id VARCHAR(250)
 	DECLARE @report_position_deals VARCHAR(5000)		
	DECLARE @total_vol_sql VARCHAR(MAX)
	DECLARE @spa VARCHAR(MAX)
	DECLARE @job_name VARCHAR(MAX)
	DECLARE @mapping_name01 VARCHAR(100)
	DECLARE @mapping_name01_tx VARCHAR(100)
	DECLARE @deal_type01 VARCHAR(100)

	--trans deal not needed if same region
	IF (@loc_from_region = @loc_to_region)
	BEGIN 
		SET @live_status_setup = 0
	END

	SELECT @mapping_name01 = 'Scheduling Storage Mapping'

	SELECT @mapping_name01_tx = CASE WHEN ISNULL(@live_status_setup, 0) = 1 AND @location_to <> @location_from_name THEN 'Scheduling Transportation Mapping' ELSE '' END

	IF OBJECT_ID('tempdb..#temp_generic_mapping_values') IS NOT NULL
				DROP TABLE #temp_generic_mapping_values

	CREATE TABLE #temp_generic_mapping_values(
		mapping_name VARCHAR(50) COLLATE DATABASE_DEFAULT,
		generic_mapping_values_id INT,
		mapping_table_id INT,
		clm1_value VARCHAR(8000) COLLATE DATABASE_DEFAULT,
		clm2_value VARCHAR(8000) COLLATE DATABASE_DEFAULT,
		clm3_value VARCHAR(8000) COLLATE DATABASE_DEFAULT,
		clm4_value VARCHAR(8000) COLLATE DATABASE_DEFAULT,
		clm5_value VARCHAR(8000) COLLATE DATABASE_DEFAULT,
		clm6_value VARCHAR(8000) COLLATE DATABASE_DEFAULT,
		[order] INT
	)


	IF @mapping_name01_tx = 'Scheduling Transportation Mapping'
	BEGIN
		INSERT INTO #temp_generic_mapping_values
		SELECT mapping_name
			  ,generic_mapping_values_id
			  ,mapping_table_id
			  ,clm1_value 
			  ,clm2_value
			  ,clm3_value
			  ,clm4_value
			  ,clm5_value
			  ,clm6_value
			  ,[order]
		FROM (
			SELECT gmh.mapping_name,gmv.*,ROW_NUMBER() OVER (ORDER BY clm3_value,ISNULL(clm5_value,-123456788) desc,ISNULL(clm6_value,-123456789) desc) [order]
			FROM generic_mapping_header gmh 
			INNER JOIN generic_mapping_values gmv
				ON gmv.mapping_table_id = gmh.mapping_table_id
			WHERE 
			1 = 1
			AND  gmh.mapping_name IN (@mapping_name01_tx)
			AND ISNULL(clm5_value, CASE WHEN @callfrom = 'from_withdraw_pipeline' THEN CAST(@location_to AS VARCHAR(100)) ELSE @location_from_name END) = CASE WHEN @callfrom = 'from_withdraw_pipeline' THEN CAST(@location_to AS VARCHAR(100)) ELSE @location_from_name END
			AND ISNULL(clm6_value, CASE WHEN @callfrom = 'from_withdraw_pipeline' THEN @location_from_name ELSE CAST(@location_to AS VARCHAR(100)) END) = CASE WHEN @callfrom = 'from_withdraw_pipeline' THEN @location_from_name ELSE CAST(@location_to AS VARCHAR(100)) END
		) tbl
	END

	DECLARE @is_location_map INT = 0 --take the generic template if location is not mapped
		 
	IF EXISTS (SELECT 1 FROM generic_mapping_header gmh
			   INNER JOIN generic_mapping_values gmv ON gmv.mapping_table_id = gmh.mapping_table_id	
			   WHERE gmh.mapping_name  = 'Scheduling Storage Mapping'
			   	   AND gmv.clm5_value = CASE WHEN @callfrom IN ('from_withdraw_pipeline', 'from_delivery') THEN @location_from_name ELSE CAST(@location_to AS VARCHAR(100)) END   
				   AND clm1_value = CASE WHEN @callfrom IN ('from_storage', 'from_purchase', 'from_delivery')  
										THEN CASE WHEN @callfrom = 'from_purchase' THEN 'i' 
											  WHEN @callfrom = 'from_delivery' THEN 'w' 
											ELSE clm1_value END 
									WHEN @callfrom = 'from_withdraw_pipeline' THEN 'a' ELSE 'b' END )
	BEGIN
		SET @is_location_map = 1
	END			
	-- select @is_location_map 
	--select * from source_minor_location where source_minor_location_id IN (@location_from_name)

	SELECT z.template_name
		, MAX(sub_book) sub_book
		, MAX(z.template_id) template_id
		, inj_with
		, buy_sell_flag
		, MAX(sdht.template_name) selected_template_name
 		INTO #generic_mapping_data
	FROM (
		--b pipeline withdrawal -- a pipeline injection --w withdrawl - i injection
	SELECT gmh.mapping_name AS [template_name],CASE WHEN gmh.mapping_name = @mapping_name01_tx THEN clm4_value ELSE clm2_value END sub_book,   clm3_value template_id
		, CASE WHEN gmh.mapping_name = 'Scheduling Transportation Mapping' THEN 't' ELSE clm1_value END inj_with
		, CASE WHEN clm1_value = 'i' THEN 's' ELSE 'b' END buy_sell_flag
	FROM generic_mapping_header gmh
	INNER JOIN generic_mapping_values gmv ON gmv.mapping_table_id = gmh.mapping_table_id
		WHERE gmh.mapping_name IN (@mapping_name01)
			AND clm1_value = CASE WHEN @callfrom IN ('from_storage', 'from_purchase', 'from_delivery')  
				THEN CASE WHEN @callfrom = 'from_purchase' THEN 'i' 
					  WHEN @callfrom = 'from_delivery' THEN 'w' 
					ELSE clm1_value 
			END  WHEN @callfrom = 'from_withdraw_pipeline' THEN 'a' ELSE 'b' END
		AND ISNULL(clm5_value, '') = CASE WHEN @is_location_map = 1 THEN CASE WHEN @callfrom IN ('from_withdraw_pipeline', 'from_delivery') THEN @location_from_name ELSE CAST(@location_to AS VARCHAR(100)) END ELSE '' END
		UNION
		SELECT tgmv.mapping_name [template_name]
				,CASE WHEN tgmv.mapping_name = 'Scheduling Transportation Mapping' THEN tgmv.clm4_value ELSE tgmv.clm2_value END sub_book
				,tgmv.clm3_value [template_id]
				, 't' inj_with
				, CASE WHEN tgmv.clm1_value = 'i' THEN 's' ELSE 'b' END buy_sell_flag

		FROM (
			SELECT MIN([order]) [order] 
			FROM #temp_generic_mapping_values
			GROUP BY clm3_value
		) tbl
		INNER JOIN #temp_generic_mapping_values tgmv
			ON tgmv.[order] = tbl.[order]
 	) z 
	LEFT JOIN source_deal_header_template sdht ON sdht.template_id = z.template_id 
	GROUP BY z.template_name, inj_with,	buy_sell_flag


	IF @callfrom = 'from_storage'
	BEGIN 
 		DELETE FROM #generic_mapping_data WHERE inj_with IN ('a', 'b')
		
		INSERT INTO #generic_mapping_data(template_name, template_id, sub_book, inj_with, buy_sell_flag, selected_template_name)			
 		SELECT 
			mapping_name template_name
			, clm3_value template_id
			, clm2_value sub_book
			, clm1_value inj_with	
			, CASE WHEN clm1_value = 'i' THEN 's' ELSE 'b' END buy_sell_flag
			, sdht.template_name selected_template_name
		FROM generic_mapping_header gmh
		INNER JOIN generic_mapping_values gmv ON gmv.mapping_table_id = gmh.mapping_table_id
		LEFT JOIN source_deal_header_template sdht ON sdht.template_id = gmv.clm3_value 
		WHERE gmh.mapping_name IN (@mapping_name01)
			AND clm1_value IN ('i', 'w')
			AND clm5_value IS NULL 
			AND clm1_value NOT IN (SELECT inj_with FROM #generic_mapping_data)
	END 

	
	--select * from #generic_mapping_data
	--return 

	IF NOT EXISTS(SELECT 1 FROM #generic_mapping_data)
	BEGIN
		EXEC spa_ErrorHandler -1,
			'Matching/Bookout Deals',
			'spa_scheduling_workbench',
			'DB Error',
			'Generic Book Mapping not found',
			''
		RETURN
	END

	SELECT @template_id_tx = template_id FROM #generic_mapping_data WHERE [template_name] = @mapping_name01_tx	
	SELECT @template_id_str = template_id FROM #generic_mapping_data WHERE [template_name] = @mapping_name01 				  
		 
	SELECT gmd.sub_book fas_book_id
		, source_system_book_id1
		, source_system_book_id2
		, source_system_book_id3
		, source_system_book_id4
		, gmd.template_id
		INTO #source_system_book_id
	FROM source_system_book_map ssbm
	INNER JOIN #generic_mapping_data gmd ON gmd.sub_book = ssbm.book_deal_type_map_id

	DECLARE @deal_type			INT
	DECLARE @sub_type			INT
	DECLARE @internal_deal_type INT
	DECLARE @internal_sub_type	INT
	DECLARE @header_buy_sell_flag CHAR(1)
	DECLARE @template_contract_id INT
	DECLARE @template_header_inco_term	INT
	DECLARE @template_detail_inco_term	INT
	DECLARE @template_deal_locked		CHAR(1)


	SELECT 
		  source_deal_type_id			
		, deal_sub_type_type_id			
		, internal_deal_type_value_id 
		, internal_deal_subtype_value_id
		, header_buy_sell_flag
		, contract_id
		, inco_terms
		, deal_locked
		, sdht.template_id
		INTO #source_deal_header_template_data
	FROM source_deal_header_template sdht
	INNER JOIN #generic_mapping_data gmd ON gmd.template_id = sdht.template_id
	--WHERE template_id = @template_id
	
	SELECT  detail_inco_terms, sddt.template_id, sddt.leg, sddt.buy_sell_flag, sddt.formula_id, sddt.fixed_price
		INTO #source_deal_detail_template_data
	FROM source_deal_detail_template sddt
	INNER JOIN #generic_mapping_data gmd ON gmd.template_id = sddt.template_id
	--WHERE template_id = @template_id

	--SELECT * from #source_deal_detail_template_data
	DECLARE @counterparty_id_from_storage INT

	SELECT @commodity_id = source_commodity_id FROM source_commodity WHERE commodity_id = @commodity_name
	
	IF @callfrom IN ('from_inject_pipeline','from_withdraw_pipeline') 
	BEGIN
		SET @counterparty_id_from_storage = @counterparty_id
	END
	ELSE
	BEGIN
		SELECT @counterparty_id_from_storage = source_counterparty_id FROM source_counterparty WHERE counterparty_name = @counterparty_from_storage
	END
	
	--select @counterparty_id_from_storage
	--SELECT @counterparty_id = pipeline FROM source_minor_location WHERE @callfrom IN ('from_inject_pipeline','from_withdraw_pipeline') AND source_minor_location_id = @location_to
	SELECT @contract_id_from_storage = contract_id FROM contract_group WHERE [contract_name] = @contract_id_from_storage

	IF @contract_id_from_storage = ''
		SET @contract_id_from_storage = @contract_id
	
	SELECT	
			-- header fields
			--distinct
				data_coll.template_id source_deal_header_id, sdh.source_deal_header_id source_deal_header_id_from,  source_system_id, ext_deal_id, sdh.physical_financial_flag
			, structured_deal_id
			, CASE WHEN @callfrom IN ('from_inject_pipeline','from_withdraw_pipeline') AND  ISNULL(data_coll.template_id, -1) <> ISNULL(@template_id_tx, -1) THEN @counterparty_id_from_storage
				WHEN ISNULL(data_coll.template_id, -1) = ISNULL(@template_id_tx, -1) THEN trans.booking_counterparty	
				WHEN @callfrom = 'from_storage' AND data_coll.buy_sell_flag = 'b' THEN @counterparty_id_from_storage		 
				
 				ELSE ISNULL(@counterparty_id, counterparty_id) END counterparty_id
			, @term_start entire_term_start, @term_start  entire_term_end
			, option_flag, option_type, option_excercise_type, description1, description2, description3, deal_category_value_id, trader_id
			, data_coll.template_id, data_coll.header_buy_sell_flag header_buy_sell_flag, broker_id, generator_id, status_value_id
			, status_date, assignment_type_value_id, compliance_year, state_value_id, assigned_date, assigned_by, generation_source
			, aggregate_environment, aggregate_envrionment_comment, rec_price, rec_formula_id, rolling_avg
			, CASE WHEN data_coll.template_id = ISNULL(@template_id_tx, -1) 
					THEN trans.contract_id  
					WHEN @callfrom IN ('from_inject_pipeline','from_withdraw_pipeline') 
						THEN COALESCE(@contract_id, @template_contract_id, sdh.contract_id)  
					WHEN @callfrom = 'from_storage' AND data_coll.buy_sell_flag = 'b' THEN @contract_id_from_storage
					ELSE COALESCE(@contract_id, @template_contract_id, sdh.contract_id) END contract_id
			, legal_entity
			, internal_desk_id, product_id, internal_portfolio_id, @commodity_id commodity_id, reference, data_coll.deal_locked, close_reference_id, block_type
			, block_define_id, granularity_id, Pricing, deal_reference_type_id, unit_fixed_flag, broker_unit_fees, broker_fixed_cost
			, broker_currency_id, deal_status, term_frequency, option_settlement_date, verified_by, verified_date, risk_sign_off_by
			, risk_sign_off_date, back_office_sign_off_by, back_office_sign_off_date, book_transfer_id, confirm_status_type, deal_rules
			, confirm_rule, data_coll.inco_terms, CASE WHEN data_coll.template_id = ISNULL(@template_id_tx, -1) THEN NULLIF(trans.carrier_counterparty, 0) ELSE NULL END counterparty_id2
			--book
			, data_coll.fas_book_id sub_book, data_coll.source_system_book_id1, data_coll.source_system_book_id2, data_coll.source_system_book_id3, data_coll.source_system_book_id4
			, @term_start deal_date
			--source_deal_groups
			, sdg.source_deal_groups_name
			, sdg.static_group_name
			--detail fields
			, @term_start term_start
			, @term_start term_end, @term_start contract_expiration_date, @term_start settlement_date
			, CASE WHEN @callfrom NOT IN ('from_inject_pipeline','from_withdraw_pipeline') AND data_coll.header_buy_sell_flag = 'b' AND data_coll.template_id <> ISNULL(@template_id_tx, -1) THEN @location_from_name
					WHEN @callfrom NOT IN ('from_inject_pipeline','from_withdraw_pipeline') AND data_coll.header_buy_sell_flag <> 'b' AND data_coll.template_id <> ISNULL(@template_id_tx, -1) THEN @location_to
					WHEN data_coll.template_id = ISNULL(@template_id_tx, -1) AND data_coll.buy_sell_flag = 'b' THEN trans.del_loc_id
					WHEN data_coll.template_id = ISNULL(@template_id_tx, -1) AND data_coll.buy_sell_flag = 's' THEN trans.rec_loc_id
					WHEN data_coll.template_id <> ISNULL(@template_id_tx, -1) AND data_coll.buy_sell_flag = 'b' THEN @location_to 
					WHEN data_coll.template_id <> ISNULL(@template_id_tx, -1) AND data_coll.buy_sell_flag = 's' THEN @location_to 
					ELSE @location_from_name 
				END location_id
			--, @quantity total_volume
			, @quantity contractual_volume, @quantity actual_volume, @quantity deal_volume, ISNULL(@commodity_id, detail_commodity_id) detail_commodity_id
			, isnull(data_coll.leg,sdd.Leg) leg, fixed_float_leg, data_coll.buy_sell_flag buy_sell_flag, sdd.curve_id, data_coll.fixed_price 
			, fixed_price_currency_id, option_strike_price, deal_volume_frequency, @converted_uom deal_volume_uom_id, block_description
			, deal_detail_description, data_coll.formula_id, volume_left, settlement_volume, @converted_uom settlement_uom, price_adder
			, price_multiplier, day_count_id, meter_id, sdd.physical_financial_flag physical_financial_flag_detail, Booked
			, process_deal_status, fixed_cost, multiplier, adder_currency_id, fixed_cost_currency_id, formula_currency_id
			, price_adder2, price_adder_currency2, volume_multiplier2, pay_opposite, capacity
			, settlement_currency, standard_yearly_volume, formula_curve_id, price_uom_id, category, profile_code
			, pv_party, [status], lock_deal_detail, contractual_uom_id
			, origin, form, organic, attribute1, attribute2, attribute3, attribute4, attribute5, product_description, crop_year, data_coll.detail_inco_terms
			, cycle, schedule_volume, @converted_uom position_uom, batch_id, buyer_seller_option, lot, detail_sample_control, trans.mode_of_transport_id transportation_method

			--from template
			, data_coll.source_deal_type_id			
			, data_coll.deal_sub_type_type_id		
			, data_coll.internal_deal_type_value_id
			, data_coll.internal_deal_subtype_value_id				 
		INTO #collect_data_to_insert_deal
	FROM source_deal_detail sdd
	INNER JOIN source_deal_header sdh ON sdh.source_deal_header_id = sdd.source_deal_header_id 
	LEFT JOIN source_deal_groups sdg ON sdg.source_deal_header_id = sdh.source_deal_header_id
		AND sdd.source_deal_group_id = sdg.source_deal_groups_id
	CROSS APPLY (SELECT 
					  sdhtd.source_deal_type_id	
					, sdhtd.deal_sub_type_type_id	
					, sdhtd.internal_deal_type_value_id	
					, sdhtd.internal_deal_subtype_value_id	
					, sddtd.buy_sell_flag
					, sdhtd.header_buy_sell_flag
					, sdhtd.contract_id	
					, sdhtd.inco_terms	
					, sdhtd.deal_locked	
					, sdhtd.template_id	
					, sddtd.detail_inco_terms		
					, ssbi.fas_book_id	
					, ssbi.source_system_book_id1	
					, ssbi.source_system_book_id2	
					, ssbi.source_system_book_id3	
					, ssbi.source_system_book_id4	
					, sddtd.leg		
					, sddtd.formula_id
					, sddtd.fixed_price			
				FROM #source_deal_header_template_data  sdhtd
				INNER JOIN #source_deal_detail_template_data sddtd ON sdhtd.template_id = sddtd.template_id
				INNER JOIN #source_system_book_id ssbi ON ssbi.template_id = sdhtd.template_id) data_coll
 	OUTER APPLY #trans_grid_data trans
 	WHERE sdd.source_deal_detail_id = @source_deal_detail_id
		--AND data_coll.template_id <> CASE WHEN @location_from_name = @location_to 
		--								AND @callfrom IN ('from_inject_pipeline','from_withdraw_pipeline') 
		--							THEN @template_id_tx ELSE 0 END --check for ignore transportation deal creation if from & to location is same for injection into pipeline
	  
	--exec spa_drop_all_temp_table
	--select @location_from_name,@location_to, contract_id, counterparty_id, commodity_id, trader_id, counterparty_id2, location_id, * from #collect_data_to_insert_deal 
	--select * from #generic_mapping_data
	--  select  template_id, counterparty_id,counterparty_id2,commodity_id,  detail_commodity_id, contract_id, location_id,* from #collect_data_to_insert_deal
	 --return

	DECLARE @new_source_deal_groups INT 
	DECLARE @trans_deal_id INT
	DECLARE @str_deal_id INT
	DECLARE @to_uom INT 
	DECLARE @term_start_date DATE
	SET @user_login_id = dbo.FNADBUser()	 
	SET @process_id = dbo.FNAGetNewID()

	SET @report_position_deals = dbo.FNAProcessTableName('report_position', @user_login_id,@process_id)
	EXEC ('CREATE TABLE ' + @report_position_deals + '( source_deal_header_id INT, action CHAR(1))')
 
	CREATE TABLE #new_inserted_data(source_deal_header_id INT, header_buy_sell_flag CHAR(1) COLLATE DATABASE_DEFAULT)
	CREATE TABLE #new_inserted_detail_data(source_deal_header_id INT, source_deal_detail_id INT, buy_sell_flag CHAR(1) COLLATE DATABASE_DEFAULT)

	DECLARE @term_start_date1 DATE
	BEGIN TRY 
		BEGIN TRAN 

		DECLARE @source_deal_header_id_cur INT, @buy_sell_flag_cur CHAR(1) ,@template_id_cur INT 
		DECLARE @insert_storage_deal_cur CURSOR
		SET @insert_storage_deal_cur = CURSOR FOR
		SELECT source_deal_header_id, MAX(buy_sell_flag) buy_sell_flag, template_id 
		FROM #collect_data_to_insert_deal 
		GROUP BY source_deal_header_id, template_id
		OPEN @insert_storage_deal_cur
		FETCH NEXT
		FROM @insert_storage_deal_cur INTO @source_deal_header_id_cur, @buy_sell_flag_cur, @template_id_cur
		WHILE @@FETCH_STATUS = 0
		BEGIN
			INSERT INTO source_deal_header(
					deal_id
					, source_system_id, ext_deal_id, sdh.physical_financial_flag
					, structured_deal_id, counterparty_id, entire_term_start,  entire_term_end
					, option_flag, option_type, option_excercise_type, description1, description2, description3, deal_category_value_id, trader_id
					, template_id, header_buy_sell_flag, broker_id, generator_id, status_value_id
					, status_date, assignment_type_value_id, compliance_year, state_value_id, assigned_date, assigned_by, generation_source
					, aggregate_environment, aggregate_envrionment_comment, rec_price, rec_formula_id, rolling_avg, contract_id, legal_entity
					, internal_desk_id, product_id, internal_portfolio_id, commodity_id, reference, deal_locked, close_reference_id, block_type
					, block_define_id, granularity_id, Pricing, deal_reference_type_id, unit_fixed_flag, broker_unit_fees, broker_fixed_cost
					, broker_currency_id, deal_status, term_frequency, option_settlement_date, verified_by, verified_date, risk_sign_off_by
					, risk_sign_off_date, back_office_sign_off_by, back_office_sign_off_date, book_transfer_id, confirm_status_type, deal_rules
					, confirm_rule, inco_terms
					, sub_book, source_system_book_id1, source_system_book_id2, source_system_book_id3, source_system_book_id4, deal_date					
					, source_deal_type_id			
					, deal_sub_type_type_id			
					, internal_deal_type_value_id 
					, internal_deal_subtype_value_id, counterparty_id2
					)
					OUTPUT INSERTED.source_deal_header_id, INSERTED.header_buy_sell_flag INTO #new_inserted_data
			SELECT 
				DISTINCT
				'temp_deal_detail_id1' 
				, source_system_id, ext_deal_id, physical_financial_flag
				, structured_deal_id, counterparty_id, entire_term_start, entire_term_end
				, option_flag, option_type, option_excercise_type, NULL description1, description2, description3, deal_category_value_id, trader_id
				, template_id, header_buy_sell_flag, broker_id, generator_id, status_value_id
				, status_date, assignment_type_value_id, compliance_year, state_value_id, assigned_date, assigned_by, generation_source
				, aggregate_environment, aggregate_envrionment_comment, rec_price, rec_formula_id, rolling_avg, contract_id, legal_entity
				, internal_desk_id, product_id, internal_portfolio_id, @commodity_id commodity_id, reference, deal_locked, close_reference_id, block_type
				, block_define_id, granularity_id, Pricing, deal_reference_type_id, unit_fixed_flag, broker_unit_fees, broker_fixed_cost
				, broker_currency_id, deal_status, term_frequency, option_settlement_date, verified_by, verified_date, risk_sign_off_by
				, risk_sign_off_date, back_office_sign_off_by, back_office_sign_off_date, book_transfer_id, confirm_status_type, deal_rules
				, confirm_rule, inco_terms
				, sub_book, source_system_book_id1, source_system_book_id2, source_system_book_id3, source_system_book_id4
				, deal_date
				, source_deal_type_id			
				, deal_sub_type_type_id			
				, internal_deal_type_value_id 
				, internal_deal_subtype_value_id
				, counterparty_id2
			FROM #collect_data_to_insert_deal
			WHERE source_deal_header_id = @source_deal_header_id_cur
				AND buy_sell_flag =  @buy_sell_flag_cur

			SET @new_source_deal_header_id = IDENT_CURRENT('source_deal_header')

			SELECT @deal_type01 = CASE WHEN @template_id_cur = ISNULL(@template_id_tx, -1) THEN 'Transportation' ELSE 'Storage' END 

			SELECT @deal_pre = ISNULL(prefix, 'ST_') 
			FROM deal_reference_id_prefix drp
			INNER JOIN source_deal_type sdp On sdp.source_deal_type_id = drp.deal_type
			WHERE deal_type_id = @deal_type01

			IF @deal_pre IS NULL 
				SET @deal_pre = 'ST_'
 
			IF @template_id_cur = ISNULL(@template_id_tx, -1)
			BEGIN
				SET @deal_pre = 'TRANS_'
				SET @trans_deal_id = @new_source_deal_header_id
			END
			ELSE
			BEGIN
				SET @deal_pre = 'ST_'
				SET @str_deal_id = @new_source_deal_header_id
			END

			UPDATE source_deal_header
			SET deal_id = ISNULL(@deal_pre, 'ST_') + CAST(source_deal_header_id AS VARCHAR(100))
			WHERE source_deal_header_id = @new_source_deal_header_id

			INSERT INTO source_deal_groups( source_deal_groups_name
											, source_deal_header_id
											, static_group_name										
											, quantity
											)
			SELECT source_deal_groups_name, @new_source_deal_header_id, static_group_name, 1
			FROM #collect_data_to_insert_deal
			WHERE source_deal_header_id = @source_deal_header_id_cur
				AND buy_sell_flag =  @buy_sell_flag_cur

			SET @new_source_deal_groups = IDENT_CURRENT('source_deal_groups')

			INSERT INTO source_deal_detail (
						 source_deal_header_id, term_start
						, term_end, contract_expiration_date, settlement_date, location_id--, total_volume
						, contractual_volume, actual_volume, deal_volume, detail_commodity_id
						, Leg, fixed_float_leg, buy_sell_flag, curve_id, fixed_price
						, fixed_price_currency_id, option_strike_price, deal_volume_frequency, deal_volume_uom_id, block_description
						, deal_detail_description, formula_id, volume_left, settlement_volume, settlement_uom, price_adder
						, price_multiplier, day_count_id, meter_id, physical_financial_flag, Booked
						, process_deal_status, fixed_cost, multiplier, adder_currency_id, fixed_cost_currency_id, formula_currency_id
						, price_adder2, price_adder_currency2, volume_multiplier2, pay_opposite, capacity
						, settlement_currency, standard_yearly_volume, formula_curve_id, price_uom_id, category, profile_code
						, pv_party, status, lock_deal_detail, contractual_uom_id
						, origin, form, organic, attribute1, attribute2, attribute3, attribute4, attribute5, product_description, crop_year, detail_inco_terms
						, cycle, schedule_volume, position_uom, batch_id, buyer_seller_option, lot, detail_sample_control, source_deal_group_id, transportation_method) 
				OUTPUT INSERTED.source_deal_header_id, INSERTED.source_deal_detail_id, INSERTED.buy_sell_flag INTO #new_inserted_detail_data
			SELECT @new_source_deal_header_id, @term_start
				, @term_start, @term_start, @term_start, location_id --, @quantity
				, @quantity, NULL, @quantity, ISNULL(@commodity_id, detail_commodity_id)
				, Leg, fixed_float_leg, buy_sell_flag, curve_id, fixed_price 
				, fixed_price_currency_id, option_strike_price, 'd' deal_volume_frequency, @converted_uom deal_volume_uom_id, block_description
				, deal_detail_description, formula_id, volume_left, settlement_volume, settlement_uom, price_adder
				, price_multiplier, day_count_id, meter_id, physical_financial_flag, Booked
				, process_deal_status, fixed_cost, 1, adder_currency_id, fixed_cost_currency_id, formula_currency_id
				, price_adder2, price_adder_currency2, volume_multiplier2, pay_opposite, capacity
				, settlement_currency, standard_yearly_volume, formula_curve_id, price_uom_id, category, profile_code
				, pv_party, [status], lock_deal_detail, contractual_uom_id
				, origin, form, organic, attribute1, attribute2, attribute3, attribute4, attribute5, product_description, crop_year, detail_inco_terms
				, cycle, schedule_volume, @converted_uom position_uom, batch_id, buyer_seller_option, lot, detail_sample_control, @new_source_deal_groups source_deal_group_id
				, transportation_method
			FROM #collect_data_to_insert_deal
			WHERE source_deal_header_id = @source_deal_header_id_cur
 		 
			SET @new_source_deal_detail_id = IDENT_CURRENT('source_deal_detail')

			--udf header
			INSERT INTO user_defined_deal_fields(source_deal_header_id
												, udf_template_id
												, udf_value)
			SELECT @new_source_deal_header_id, udf_template_id, default_value 
			FROM user_defined_deal_fields_template   
			WHERE template_id = @template_id AND udf_type = 'h'
		
			--udf detail
			INSERT INTO user_defined_deal_detail_fields(source_deal_detail_id
															, udf_template_id
															, udf_value)
			SELECT @new_source_deal_detail_id, udf_template_id, default_value 
			FROM user_defined_deal_fields_template   
			WHERE template_id = @template_id AND udf_type = 'd'
		
			SELECT @from_source_deal_header_id = source_deal_header_id_from 
			FROM #collect_data_to_insert_deal 
			
			IF OBJECT_ID('tempdb..#packing_uom') IS NOT NULL
				DROP TABLE #packing_uom

			--update packaging and package from base deal	 
			SELECT @new_source_deal_detail_id source_deal_detail_id, uddft.udf_template_id, a.udf_value, uddft.Field_label, @template_id template_id
				INTO #packing_uom
			FROM user_defined_deal_fields_template uddft 
			INNER JOIN (
						SELECT udddf.udf_value,udddf.udf_template_id, sdh.template_id, udft.Field_label
						FROM user_defined_deal_detail_fields udddf
						INNER JOIN source_deal_detail sdd ON udddf.source_deal_detail_id = sdd.source_deal_detail_id
						INNER JOIN source_deal_header sdh ON sdd.source_deal_header_id = sdh.source_deal_header_id
						INNER JOIN user_defined_deal_fields_template uddft ON uddft.template_id = sdh.template_id
							AND udddf.udf_template_id = uddft.udf_template_id
						INNER JOIN user_defined_fields_template udft ON udft.field_id = uddft.field_id
						WHERE 1 = 1
						--sdd.source_deal_header_id = @from_source_deal_header_id
							AND sdd.source_deal_detail_id = @source_deal_detail_id
							AND udft.Field_label IN ('Packaging UOM', 'Package#')
						) a ON a.Field_label = uddft.Field_label
			WHERE uddft.template_id = @template_id AND udf_type = 'd'
				AND uddft.Field_label IN ('Packaging UOM', 'Package#')
						 
				
			--SELECT * 
			UPDATE udddf
			SET udddf.udf_value = pu.udf_value
			FROM #packing_uom pu 
			INNER JOIN user_defined_deal_detail_fields udddf ON udddf.source_deal_detail_id = pu.source_deal_detail_id
				AND udddf.udf_template_id = pu.udf_template_id
			
			SELECT @to_uom = udf_value FROM #packing_uom WHERE Field_label IN ('Packaging UOM')

			--select * from #quantity_conversion
			--select @converted_uom,@to_uom
			 --calulate packages..
			--SELECT *  
			UPDATE udddf
			SET udddf.udf_value = CEILING(@quantity/conversion_factor)
			FROM #packing_uom pu 
			INNER JOIN user_defined_deal_detail_fields udddf ON udddf.source_deal_detail_id = pu.source_deal_detail_id
			LEFT JOIN #quantity_conversion qc ON qc.from_source_uom_id = @to_uom
				WHERE 1 =1 
				AND to_source_uom_id =  @converted_uom 
				AND udddf.udf_template_id = pu.udf_template_id
				AND pu.Field_label = 'Package#'

			SET @total_vol_sql = 'INSERT INTO ' + @report_position_deals + '(source_deal_header_id,action) 
									SELECT ' + CAST(@new_source_deal_header_id AS VARCHAR) + ',''i'''
		
			EXEC spa_print @total_vol_sql		
			EXEC (@total_vol_sql) 

			---- deal transfer rule call
			--EXEC spa_auto_transfer @flag = 's', @source_deal_header_id = @new_source_deal_header_id, @est_movement_date = @term_start
		FETCH NEXT
		FROM @insert_storage_deal_cur INTO @source_deal_header_id_cur, @buy_sell_flag_cur, @template_id_cur
		END
		CLOSE @insert_storage_deal_cur
		DEALLOCATE @insert_storage_deal_cur
		
		SET @spa = 'spa_update_deal_total_volume NULL,''' + @process_id  + ''',0,null,''' +@user_login_id+''',''n'''
		SET @job_name = 'spa_update_deal_total_volume_' + @process_id 
		EXEC spa_run_sp_as_job @job_name, @spa, 'spa_update_deal_total_volume', @user_login_id
		
		
	 --  select @from_source_deal_header_id, @new_source_deal_header_id, @quantity, @balance_qty, @location_from_name
	 --  , @source_deal_detail_id, @deal_detail_id_split_deal_detail_volume_id, @converted_uom
		--ROLLBACK TRAN 
		--return 
		--/*

		
		DECLARE @from_source_deal_header_id_str VARCHAR(100)
		DECLARE @new_source_deal_header_id_str VARCHAR(100)


		IF @callfrom IN ('from_inject_pipeline','from_withdraw_pipeline') AND @location_from_name = @location_to
		BEGIN
			SET @from_source_deal_header_id_str = CAST(@from_source_deal_header_id AS VARCHAR(20))
			SET @new_source_deal_header_id_str = CAST(@str_deal_id AS VARCHAR(20))
		END
		ELSE IF @callfrom IN ('from_inject_pipeline','from_withdraw_pipeline')
		BEGIN
			SET @from_source_deal_header_id_str = CAST(@from_source_deal_header_id AS VARCHAR(20)) + ISNULL(',' + CAST(@trans_deal_id AS VARCHAR(20)),'')
			SET @new_source_deal_header_id_str = CAST(@str_deal_id AS VARCHAR(20)) + ISNULL(',' + CAST(@trans_deal_id AS VARCHAR(20)),'')
		END
		ELSE IF @callfrom = 'from_storage'
		BEGIN 
 

			SELECT @from_source_deal_header_id_str = STUFF((SELECT ',' + CAST(header.source_deal_header_id AS VARCHAR(100))
													FROM #new_inserted_data header 
													INNER JOIN #new_inserted_detail_data detail ON detail.source_deal_header_id = header.source_deal_header_id 
													WHERE detail.buy_sell_flag = 'b'
													FOR XML PATH('')), 1, 1, '')

 			SELECT @new_source_deal_header_id_str = STUFF((SELECT ',' + CAST(header.source_deal_header_id AS VARCHAR(100))
													FROM #new_inserted_data header 
													INNER JOIN #new_inserted_detail_data detail ON detail.source_deal_header_id = header.source_deal_header_id 
													WHERE detail.buy_sell_flag = 's'
													FOR XML PATH('')), 1, 1, '')
			
			SELECT @source_deal_detail_id = STUFF((SELECT ',' + CAST(detail.source_deal_detail_id AS VARCHAR(100))
													FROM #new_inserted_data header 
													INNER JOIN #new_inserted_detail_data detail ON detail.source_deal_header_id = header.source_deal_header_id 
													INNER JOIN source_deal_header sdh ON sdh.source_deal_header_id = header.source_deal_header_id							
													INNER JOIN source_deal_type sdt ON sdt.source_deal_type_id = sdh.source_deal_type_id						
													WHERE detail.buy_sell_flag = 'b'
														AND deal_type_id <> 'Transportation'
													FOR XML PATH('')), 1, 1, '')
			 
		END
		ELSE
		BEGIN
 			SET @from_source_deal_header_id_str = CAST(@from_source_deal_header_id AS VARCHAR(20)) + CASE WHEN ISNULL(@live_status_setup, 0) = 1 THEN ISNULL(',' + CAST(@trans_deal_id AS VARCHAR(20)),'') ELSE '' END 
			SET @new_source_deal_header_id_str = CAST(@str_deal_id AS VARCHAR(20)) + CASE WHEN ISNULL(@live_status_setup, 0) = 1 THEN ISNULL(',' + CAST(@trans_deal_id AS VARCHAR(20)),'') ELSE '' END 
		END
		--select * from #new_inserted_data a 
		--INNER JOIN source_deal_header sdh On sdh.source_deal_header_id = a.source_deal_header_id
		--INNER JOIN source_deal_detail sdd ON sdd.source_deal_header_id = sdh.source_deal_header_id 
		
		--select  top 10 * from source_deal_header order by 1 desc
		-- 	select  ' spa_scheduling_workbench_wrapper',
		--'s',
		--@from_source_deal_header_id_str,
		--@new_source_deal_header_id_str,
		--@quantity,
		--@balance_qty,
		--@location_from_name,
		--@source_deal_detail_id,
		--@deal_detail_id_split_deal_detail_volume_id,
		--@converted_uom
		-- rollback tran return 

		EXEC spa_scheduling_workbench_wrapper
				@flag = 's',
				@source_deal_header_id_purchase = @from_source_deal_header_id_str,
				@source_deal_header_id_sell = @new_source_deal_header_id_str,
				@quantity = @quantity,
				@balance_qty = @balance_qty,
				@location_from_name = @location_from_name,
				@source_deal_detail_id_purchase = @source_deal_detail_id,
				@deal_detail_id_split_deal_detail_volume_id = @deal_detail_id_split_deal_detail_volume_id,
				@converted_uom = @converted_uom,
				@is_pipeline = @is_pipeline,
				@lot = @lot
		 
		--*/
		
		 --deal transfer rule call
		DECLARE transfer_deal_cur CURSOR LOCAL 
		FOR
			SELECT source_deal_header_id FROM #new_inserted_data			
        --SELECT @new_source_deal_header_id = source_deal_header_id FROM #new_inserted_data WHERE header_buy_sell_flag = 's'
		OPEN transfer_deal_cur
		FETCH NEXT FROM transfer_deal_cur INTO @new_source_deal_header_id
		WHILE @@FETCH_STATUS = 0
		BEGIN
			
			EXEC spa_auto_transfer @source_deal_header_id = @new_source_deal_header_id--, @est_movement_date = @term_start -- paramater not used in target SP
			FETCH NEXT FROM transfer_deal_cur
 			INTO @new_source_deal_header_id
		END
		CLOSE transfer_deal_cur
 		DEALLOCATE transfer_deal_cur
			
		--rollback tran return 

		COMMIT TRAN 

		--IF @callfrom IN ('from_inject_pipeline','from_withdraw_pipeline')
		--BEGIN
			
		--	EXEC spa_ErrorHandler 0,
		--		'Matching/Bookout Deals',
		--		'spa_scheduling_workbench',
		--		'Success',
		--		'Data Successfully Updated.',
		--		''
		--END
		
	END TRY
	BEGIN CATCH
		--SELECT ERROR_MESSAGE()
		DECLARE @error_msg VARCHAR(1000)
		SELECT @error_msg = ERROR_MESSAGE()
		ROLLBACK TRAN
		EXEC spa_ErrorHandler -1,
             'Matching/Bookout Deals',
             'spa_scheduling_workbench',
             'DB Error',
             @error_msg,
             ''
	END CATCH
END
ELSE IF @flag = 'a' -- Get Shipment Status to show Delivery Detail Grid
BEGIN
	DECLARE @display_grid INT

	IF EXISTS (SELECT 1 FROM adiha_default_codes_values	WHERE default_code_id = 102)
	BEGIN
		SELECT @display_grid = var_value
		FROM adiha_default_codes_values 
		WHERE default_code_id = 102
	END
	ELSE
	BEGIN
		SELECT @display_grid = 0
	END

	SELECT @display_grid [display_grid]
END

ELSE IF @flag = 'b' -- Get Liquidation Location ID of respective counterparty id
BEGIN
	-- 'Pipeline' [-10021] [Type Of Entity]
	SELECT sml.source_minor_location_id [location_to], sml.location_name
	FROM source_counterparty sc
	INNER JOIN source_minor_location sml ON sml.source_minor_location_id = sc.liquidation_loc_id
	INNER JOIN source_major_location smj ON smj.source_major_location_ID = sml.source_major_location_ID
	WHERE sc.type_of_entity = -10021 AND smj.location_name = 'Pipeline' AND sc.source_counterparty_id = @counterparty_id
END

GO
