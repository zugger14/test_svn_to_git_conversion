IF OBJECT_ID(N'[dbo].[spa_storage_assets]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[spa_storage_assets]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

/**
	Stored procedure for Storage assets

	Parameters
	@flag: Operational flag
	@general_assets_id: General asset id
	@general_xml: General from XML
	@constraints_xml: Constraints grid XML
	@ratchet_grid_xml: Ratchet grid XML
	@asset_ids: Coma separated storage asset ids
	@process_id: Process id
	@storage_asset_id: Storage Asset id
	@general_assets_parent_id: Parent storage asset id
	@agreement: Contract id
	@filter_value: Filter value

*/
CREATE PROCEDURE [dbo].[spa_storage_assets]
	@flag CHAR(1),
	@general_assets_id VARCHAR(1000) = NULL,
	@general_xml TEXT = NULL,
	@constraints_xml TEXT = NULL,
	@ratchet_grid_xml TEXT = NULL,
	@asset_ids VARCHAR(MAX) = NULL,
	@process_id VARCHAR(MAX) = NULL, 
	@storage_asset_id VARCHAR(200) = NULL,
	@general_assets_parent_id VARCHAR(MAX) = NULL,
	@agreement VARCHAR(MAX) = NULL,
	@filter_value VARCHAR(1000) = NULL
AS

/*
DECLARE
	@flag						CHAR(1),
	@general_assets_id VARCHAR(1000) = NULL,
	@general_xml				VARCHAR(MAX)			=	NULL,
	@constraints_xml			VARCHAR(MAX)			=	NULL,
	@ratchet_grid_xml			VARCHAR(MAX)			=	NULL,
	@asset_ids VARCHAR(MAX) = NULL,
	@process_id VARCHAR(MAX) = NULL, 
	@storage_asset_id VARCHAR(200) = NULL,
	@general_assets_parent_id VARCHAR(MAX) = NULL,
	@agreement VARCHAR(MAX) = NULL
  
SELECT @flag='u',@general_assets_id='1156',@general_xml='<FormXML  general_assest_id="1156" storage_asset_id="92" storage_location="2794" agreement="11423" logical_name="Egan Storage/tester1/" source_counterparty_id="7686" beg_storage_volume="" storage_type="18502" beg_storage_cost="" cost_currency="1141" schedule_injection_id="0" nomination_injection_id="0" actual_injection_id="0" schedule_withdrawl_id="0" nomination_withdrawl_id="0" actual_withdrawl_id="0" accounting_type="45400" ownership_type="45300" storage_capacity="" volumn_uom="1082" injection_template_id="2750" withdrawal_template_id="2750" injection_as_long="n" include_product_lot="n" include_fees="n" calculate_mtm="n" include_non_standard_deals="n"></FormXML>',@constraints_xml='<GridGroup></GridGroup>',@ratchet_grid_xml='<GridGroupRatchet></GridGroupRatchet>',@storage_asset_id='tester1_0_4619'
--*/
  
SET NOCOUNT ON

DECLARE @idoc INT
DECLARE @idoc1 INT
DECLARE @idoc2 INT
DECLARE @DESC VARCHAR(500)
DECLARE @err_no INT 
DECLARE @sql VARCHAR(MAX)
DECLARE @ids	VARCHAR(MAX)
DECLARE @labels	VARCHAR(MAX)
SELECT @filter_value = NULLIF(NULLIF(@filter_value, '<FILTER_VALUE>'), '')
DECLARE @sql_select VARCHAR(MAX)
		
EXEC sp_xml_preparedocument @idoc OUTPUT, @general_xml
EXEC sp_xml_preparedocument @idoc1 OUTPUT, @constraints_xml
EXEC sp_xml_preparedocument @idoc2 OUTPUT, @ratchet_grid_xml

SELECT @filter_value = NULLIF(NULLIF(@filter_value, '<FILTER_VALUE>'), '')

IF OBJECT_ID('tempdb..#temp_general_form') IS NOT NULL
DROP TABLE #temp_general_form
SELECT 
	NULLIF(general_assest_id, 0)		[general_assest_id],
	storage_location,
	NULLIF(agreement, 0)				[agreement],
	NULLIF(source_counterparty_id, 0)	[source_counterparty_id],
	NULLIF(beg_storage_volume, 0)		[beg_storage_volume],
	NULLIF(volumn_uom, 0)				[volumn_uom],
	NULLIF(storage_type, 0)				[storage_type],
	NULLIF(beg_storage_cost, 0)			[beg_storage_cost],
	NULLIF(cost_currency, 0)				[cost_currency],
	NULLIF(fees,0)						[fees],
	NULLIF(commodity_id,0)				[commodity_id],
	schedule_injection_id	,
	nomination_injection_id	,
	actual_injection_id		,
	schedule_withdrawl_id	,
	nomination_withdrawl_id	,
	actual_withdrawl_id		,
	wacog_option,
	NULLIF(accounting_type, 0)			[accounting_type],
	NULLIF(ownership_type, 0)			[ownership_type],
	injection_as_long		,
	include_fees			,
	NULLIF(negative_inventory, 0)		[negative_inventory],
	NULLIF(storage_capacity, 0)			[storage_capacity],
	NULLIF(injection_deal, 0)			[injection_deal],
	NULLIF(withdrawal_deal, 0)			[withdrawal_deal],
	actualize_projection,
	logical_name,
	include_product_lot,		
	storage_asset_id,
	calculate_mtm,
	include_non_standard_deals,
	NULLIF(injection_template_id, '') [injection_template_id],
	NULLIF(withdrawal_template_id, '') [withdrawal_template_id],
	sub_book

INTO #temp_general_form
FROM   OPENXML(@idoc, '/FormXML', 1)
		WITH (
			general_assest_id INT '@general_assest_id',
			storage_location VARCHAR(100) '@storage_location',
			agreement INT '@agreement',
			source_counterparty_id INT '@source_counterparty_id',
			beg_storage_volume INT '@beg_storage_volume',
			volumn_uom INT '@volumn_uom',
			storage_type INT '@storage_type',
			beg_storage_cost FLOAT '@beg_storage_cost',
			cost_currency INT '@cost_currency',
			fees INT '@fees',
			commodity_id INT '@commodity_id',
			schedule_injection_id VARCHAR(500) '@schedule_injection_id',
			nomination_injection_id VARCHAR(500) '@nomination_injection_id',
			actual_injection_id VARCHAR(500) '@actual_injection_id',
			schedule_withdrawl_id VARCHAR(500) '@schedule_withdrawl_id',
			nomination_withdrawl_id VARCHAR(500) '@nomination_withdrawl_id',
			actual_withdrawl_id VARCHAR(500) '@actual_withdrawl_id',
			wacog_option VARCHAR(500) '@wacog_option',
			accounting_type INT '@accounting_type', -- w, f, l
			ownership_type INT '@ownership_type',
			injection_as_long CHAR '@injection_as_long', -- y, n
			include_fees CHAR '@include_fees', -- y, n
			negative_inventory INT '@negative_inventory',
			storage_capacity INT '@storage_capacity',
			injection_deal INT '@injection_deal',
			withdrawal_deal INT '@withdrawal_deal',
			actualize_projection CHAR '@actualize_projection',
			logical_name VARCHAR(100) '@logical_name',
			include_product_lot CHAR(1) '@include_product_lot',
			storage_asset_id		CHAR(20)		'@storage_asset_id',
			calculate_mtm			VARCHAR(1)		'@calculate_mtm',
			include_non_standard_deals CHAR(1)  '@include_non_standard_deals',
			injection_template_id INT '@injection_template_id',
			withdrawal_template_id INT '@withdrawal_template_id',
			sub_book INT '@sub_book'
		)
--SELECT * FROM #temp_general_form RETURN 
--RETURN 

IF OBJECT_ID('tempdb..#temp_constraints_grid') IS NOT NULL
DROP TABLE #temp_constraints_grid
SELECT 
	NULLIF(constraint_id, 0) [constraint_id],
	NULLIF(constraint_type, 0) [constraint_type],
	[value],
	NULLIF(uom, 0) [uom],
	frequency,
	effective_date
 
INTO #temp_constraints_grid
FROM   OPENXML(@idoc1, '/GridGroup/PSRecordset', 2)
		WITH (
			constraint_id INT '@constraint_id',
			constraint_type INT '@constraint_type',
	[value]			VARCHAR(100)	'@value',
			uom INT '@uom',
			frequency CHAR(1) '@frequency',
			effective_date VARCHAR(50) '@effective_date'
		)

IF OBJECT_ID('tempdb..#temp_ratchet_grid') IS NOT NULL
DROP TABLE #temp_ratchet_grid	
SELECT 
	NULLIF(storage_ratchet_id, 0) [storage_ratchet_id],
	IIF(term_from='', NULL, term_from) [term_from],
	IIF(term_to='', NULL, term_to) [term_to],
	IIF(inventory_level_from='', NULL, inventory_level_from) [inventory_level_from],
	IIF(inventory_level_to='', NULL, inventory_level_to) [inventory_level_to],
	IIF(gas_in_storage_perc_from='', NULL, gas_in_storage_perc_from) [gas_in_storage_perc_from],
	IIF(gas_in_storage_perc_to='', NULL, gas_in_storage_perc_to) [gas_in_storage_perc_to],
	[type],
	fixed_value,
	IIF(perc_of_contracted_storage_space='', NULL, perc_of_contracted_storage_space) [perc_of_contracted_storage_space]
INTO #temp_ratchet_grid
FROM OPENXML(@idoc2, '/GridGroupRatchet/PSRecordset', 2)
WITH (
	storage_ratchet_id INT '@storage_ratchet_id',
	term_from VARCHAR(100) '@term_from',
	term_to VARCHAR(100) '@term_to',
	inventory_level_from VARCHAR(10) '@inventory_level_from',
	inventory_level_to VARCHAR(10) '@inventory_level_to',
	gas_in_storage_perc_from VARCHAR(10) '@gas_in_storage_perc_from',
	gas_in_storage_perc_to VARCHAR(10) '@gas_in_storage_perc_to',
	[type] CHAR '@type',
	fixed_value INT '@fixed_value',
	perc_of_contracted_storage_space VARCHAR(10) '@perc_of_contracted_storage_space'
)

DECLARE @logical_name_generated VARCHAR(2000) = ''

IF @flag = 'i'
BEGIN
	BEGIN TRY
		BEGIN TRAN
			--SELECT @storage_asset_id = storage_asset_id FROM storage_asset WHERE asset_name = @storage_asset_id
			INSERT INTO general_assest_info_virtual_storage
			(
				storage_location,
				agreement,
				source_counterparty_id,
				beg_storage_volume,
				volumn_uom,
				storage_type,
				beg_storage_cost,
				cost_currency,
				fees,
				schedule_injection_id,
				nomination_injection_id,
				actual_injection_id,
				schedule_withdrawl_id,
				nomination_withdrawl_id,
				actual_withdrawl_id,
				commodity_id,
				accounting_type,
				ownership_type,
				injection_as_long,
				include_fees,
				negative_inventory,
				storage_capacity,
				injection_deal,
				withdrawal_deal,
				actualize_projection,
				logical_name,
				include_product_lot,				
				storage_asset_id,
				calculate_mtm,
				include_non_standard_deals,
				injection_template_id,
				withdrawal_template_id,
				sub_book,
				wacog_option
			)
			SELECT  tgf.storage_location,
					tgf.agreement,
					tgf.source_counterparty_id,
					tgf.beg_storage_volume,
					tgf.volumn_uom,
					tgf.storage_type,
					tgf.beg_storage_cost,
					tgf.cost_currency,
					tgf.fees,
					tgf.schedule_injection_id,
					tgf.nomination_injection_id,
					tgf.actual_injection_id,
					tgf.schedule_withdrawl_id,
					tgf.nomination_withdrawl_id,
					tgf.actual_withdrawl_id,
					tgf.commodity_id,
					tgf.accounting_type,
					tgf.ownership_type,
					tgf.injection_as_long,
					tgf.include_fees,
					tgf.negative_inventory,
					tgf.storage_capacity,
					tgf.injection_deal,
					tgf.withdrawal_deal,
					tgf.actualize_projection,
					tgf.logical_name,
					tgf.include_product_lot,				
					tgf.storage_asset_id,
					tgf.calculate_mtm,
					tgf.include_non_standard_deals,
					tgf.injection_template_id,
					tgf.withdrawal_template_id,
					tgf.sub_book,
					tgf.wacog_option
				
			FROM #temp_general_form tgf

			DECLARE @new_general_assets_id INT
			SET @new_general_assets_id = SCOPE_IDENTITY()

			INSERT INTO virtual_storage_constraint 
			(
				constraint_type,
				value,
				uom,
				frequency,
				effective_date,
				general_assest_id
			)
			SELECT  tcg.constraint_type,
					tcg.value,
					tcg.uom,
					tcg.frequency,
					dbo.FNAGetSQLStandardDateTime(tcg.effective_date),
					@new_general_assets_id
			FROM  #temp_constraints_grid tcg
			
			-- Append Incrementing number to logical_name in case of duplicate data
			IF OBJECT_ID('tempdb..#temp_storage') IS NOT NULL
				DROP TABLE #temp_storage
    
			CREATE TABLE #temp_storage (storage_id INT, logical_name VARCHAR(500) COLLATE DATABASE_DEFAULT)
			INSERT INTO #temp_storage
			SELECT
				gaivs.general_assest_id,
				IIF( gaivs.logical_name = '',
					CONCAT(sml.Location_Name, '/', cg.contract_name, '/', sc.commodity_name,
						CASE
							WHEN (ROW_NUMBER() OVER (PARTITION BY gaivs.storage_location, gaivs.agreement, gaivs.commodity_id ORDER BY gaivs.general_assest_id) - 1) = 0 THEN ''
							ELSE CAST(FORMAT(ROW_NUMBER() OVER (PARTITION BY gaivs.storage_location, gaivs.agreement, gaivs.commodity_id ORDER BY gaivs.general_assest_id) - 1,'00','en-US') AS VARCHAR(10))
						END
					), gaivs.logical_name
					--CASE
					--		WHEN (ROW_NUMBER() OVER (PARTITION BY gaivs.logical_name ORDER BY gaivs.general_assest_id) - 1) = 0 THEN ''
					--		ELSE CAST(FORMAT(ROW_NUMBER() OVER (PARTITION BY gaivs.logical_name ORDER BY gaivs.general_assest_id) - 1,'00','en-US') AS VARCHAR(10))
					--	END
				)
				log_name_suffix
			FROM general_assest_info_virtual_storage AS gaivs
			LEFT JOIN source_minor_location AS sml
				ON sml.source_minor_location_id = gaivs.storage_location
			LEFT JOIN contract_group AS cg
				ON cg.contract_id = gaivs.agreement
			LEFT JOIN source_commodity AS sc
				ON sc.source_commodity_id = gaivs.commodity_id

			UPDATE gaivs
			SET gaivs.logical_name = ts.logical_name
			FROM general_assest_info_virtual_storage AS gaivs
			INNER JOIN #temp_storage AS ts
				ON gaivs.general_assest_id = TS.storage_id

			UPDATE gmv
			SET gmv.clm4_value = tgf.sub_book
			--SELECT * 
			FROM generic_mapping_values gmv
			INNER JOIN #temp_general_form tgf ON gmv.clm1_value = tgf.storage_location
				AND gmv.clm2_value = 'i'
				AND gmv.clm3_value = tgf.source_counterparty_id
			INNER JOIN generic_mapping_header gmh ON gmh.mapping_table_id = gmv.mapping_table_id
			WHERE gmh.mapping_name = 'Storage Book Mapping'


			INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value) 
			SELECT gmh.mapping_table_id, tgf.storage_location, 'i', tgf.source_counterparty_id, tgf.sub_book
			--select * 
			FROM #temp_general_form tgf 
			LEFT JOIN generic_mapping_values gmv 
			ON gmv.clm1_value = tgf.storage_location
				AND gmv.clm2_value = 'i'-- i for inventory
				AND gmv.clm3_value = tgf.source_counterparty_id
			OUTER APPLY(SELECT mapping_table_id FROM generic_mapping_header WHERE mapping_name = 'Storage Book Mapping') gmh
			WHERE gmv.generic_mapping_values_id IS NULL

		COMMIT TRAN

		EXEC spa_ErrorHandler 0
				, @logical_name_generated
				, 'spa_storage_assets'
				, 'Success' 
				, 'Changes have been saved successfully.'
				, @new_general_assets_id
	END TRY
	BEGIN CATCH	
		IF @@TRANCOUNT > 0
			ROLLBACK

		SET @DESC = 'Fail to insert Data ( Errr Description:' + ERROR_MESSAGE() + ').'

		SELECT @err_no = ERROR_NUMBER()

		EXEC spa_ErrorHandler @err_no
			, 'storage_assets'
			, 'spa_storage_assets'
			, 'Error'
			, @DESC
			, ''
	END CATCH
END

IF @flag = 'u'
BEGIN
	BEGIN TRY
		BEGIN TRAN
			UPDATE ga 
			SET 
				storage_location = tgf.storage_location,
				agreement = tgf.agreement,
				source_counterparty_id = tgf.source_counterparty_id,
				beg_storage_volume = tgf.beg_storage_volume,
				volumn_uom = tgf.volumn_uom,
				storage_type = tgf.storage_type,
				beg_storage_cost = tgf.beg_storage_cost,
				cost_currency = tgf.cost_currency,
				fees = tgf.fees,
				commodity_id = tgf.commodity_id,
				schedule_injection_id = tgf.schedule_injection_id,
				nomination_injection_id = tgf.nomination_injection_id,
				actual_injection_id = tgf.actual_injection_id,
				schedule_withdrawl_id = tgf.schedule_withdrawl_id,
				nomination_withdrawl_id = tgf.nomination_withdrawl_id,
				actual_withdrawl_id = tgf.actual_withdrawl_id,
				accounting_type = tgf.accounting_type,
				ownership_type = tgf.ownership_type,
				injection_as_long = tgf.injection_as_long,
				include_fees = tgf.include_fees,
				negative_inventory = tgf.negative_inventory,
				storage_capacity = tgf.storage_capacity,
				injection_deal = tgf.injection_deal,
				withdrawal_deal = tgf.withdrawal_deal,
				actualize_projection = tgf.actualize_projection,
				logical_name = tgf.logical_name,
				include_product_lot = tgf.include_product_lot,
				storage_asset_id = tgf.storage_asset_id,
				calculate_mtm = tgf.calculate_mtm,
				include_non_standard_deals = tgf.include_non_standard_deals,
				injection_template_id = tgf.injection_template_id,
				withdrawal_template_id = tgf.withdrawal_template_id,
				sub_book = tgf.sub_book,
				wacog_option = tgf.wacog_option
			FROM #temp_general_form tgf
			INNER JOIN general_assest_info_virtual_storage ga
			ON tgf.general_assest_id = ga.general_assest_id
	
			IF EXISTS (SELECT 1 FROM #temp_constraints_grid WHERE constraint_id IS NULL)
			BEGIN
				INSERT INTO virtual_storage_constraint 
				(
					constraint_type,
					value,
					uom,
					frequency,
					effective_date,
					general_assest_id
				)
				SELECT  tcg.constraint_type,
						tcg.value,
						tcg.uom,
						tcg.frequency,
						dbo.FNAGetSQLStandardDateTime(tcg.effective_date),
						@general_assets_id
				FROM  #temp_constraints_grid tcg
				LEFT JOIN virtual_storage_constraint vsc 
					ON tcg.constraint_id = vsc.constraint_id
				WHERE vsc.constraint_id IS NULL
			END 
			ELSE 
			BEGIN
				UPDATE vsc 
				SET 
					constraint_type = tcg.constraint_type,
					value = tcg.value,
					uom = tcg.uom,
					frequency = tcg.frequency,
					effective_date = dbo.FNAGetSQLStandardDateTime(tcg.effective_date)
				FROM #temp_constraints_grid tcg
				INNER JOIN virtual_storage_constraint vsc
				ON tcg.constraint_id = vsc.constraint_id

				DELETE vsc FROM virtual_storage_constraint vsc
				LEFT JOIN #temp_constraints_grid tcg 
					ON tcg.constraint_id = vsc.constraint_id
				WHERE tcg.constraint_id IS NULL 
					AND vsc.general_assest_id = @general_assets_id
			END
			
			DELETE FROM storage_ratchet WHERE general_assest_id = @general_assets_id

			INSERT INTO storage_ratchet
			(
				term_from,
				term_to,
				inventory_level_from,
				inventory_level_to,
				gas_in_storage_perc_from,
				gas_in_storage_perc_to,
				[type],
				fixed_value,
				perc_of_contracted_storage_space,
				general_assest_id
			)
			SELECT  
				CAST(trg.term_from AS DATETIME),
				CAST(trg.term_to AS DATETIME),
				trg.inventory_level_from,
				trg.inventory_level_to,
				trg.gas_in_storage_perc_from,
				trg.gas_in_storage_perc_to,
				trg.[type],
				trg.fixed_value,
				trg.perc_of_contracted_storage_space,
				@general_assets_id
			FROM  #temp_ratchet_grid trg

		-- Append Incrementing number to logical_name in case of duplicate data
			IF OBJECT_ID('tempdb..#temp_storage1') IS NOT NULL
				DROP TABLE #temp_storage1
    
			-- Append Incrementing number to logical_name in case of duplicate data
			IF OBJECT_ID('tempdb..#temp_storage1') IS NOT NULL
				DROP TABLE #temp_storage1
    
			CREATE TABLE #temp_storage1 (storage_id INT, logical_name VARCHAR(500) COLLATE DATABASE_DEFAULT)
			INSERT INTO #temp_storage1
			SELECT
				gaivs.general_assest_id,
				IIF( gaivs.logical_name = '' OR CONCAT(sml.Location_Name, '/', cg.contract_name, '/', sc.commodity_name) = gaivs.logical_name,
					CONCAT(sml.Location_Name, '/', cg.contract_name, '/', sc.commodity_name,
						CASE
							WHEN (ROW_NUMBER() OVER (PARTITION BY gaivs.storage_location, gaivs.agreement, gaivs.commodity_id ORDER BY gaivs.general_assest_id) - 1) = 0 THEN ''
							ELSE CAST(FORMAT(ROW_NUMBER() OVER (PARTITION BY gaivs.storage_location, gaivs.agreement, gaivs.commodity_id ORDER BY gaivs.general_assest_id) - 1,'00','en-US') AS VARCHAR(10))
						END
					),
					CONCAT(gaivs.logical_name,
						CASE
							WHEN (ROW_NUMBER() OVER (PARTITION BY gaivs.logical_name ORDER BY gaivs.general_assest_id) - 1) = 0 THEN ''
							ELSE CAST(FORMAT(ROW_NUMBER() OVER (PARTITION BY gaivs.logical_name ORDER BY gaivs.general_assest_id) - 1,'00','en-US') AS VARCHAR(10))
						END
					)
				)
				log_name_suffix
			FROM general_assest_info_virtual_storage AS gaivs
			LEFT JOIN source_minor_location AS sml
				ON sml.source_minor_location_id = gaivs.storage_location
			LEFT JOIN contract_group AS cg
				ON cg.contract_id = gaivs.agreement
			LEFT JOIN source_commodity AS sc
				ON sc.source_commodity_id = gaivs.commodity_id

			UPDATE gaivs
			SET gaivs.logical_name = ts.logical_name
			FROM general_assest_info_virtual_storage AS gaivs
			INNER JOIN #temp_storage1 AS ts
				ON gaivs.general_assest_id = TS.storage_id
				
			SELECT @logical_name_generated = logical_name FROM #temp_storage1 AS ts WHERE storage_id = @general_assets_id

			UPDATE gmv
			SET gmv.clm4_value = tgf.sub_book
			--SELECT * 
			FROM generic_mapping_values gmv
			INNER JOIN #temp_general_form tgf ON gmv.clm1_value = tgf.storage_location
				AND gmv.clm2_value = 'i'
				AND gmv.clm3_value = tgf.source_counterparty_id
			INNER JOIN generic_mapping_header gmh ON gmh.mapping_table_id = gmv.mapping_table_id
			WHERE gmh.mapping_name = 'Storage Book Mapping'


			INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value) 
			SELECT gmh.mapping_table_id, tgf.storage_location, 'i', tgf.source_counterparty_id, tgf.sub_book
			--select * 
			FROM #temp_general_form tgf 
			LEFT JOIN generic_mapping_values gmv 
			ON gmv.clm1_value = tgf.storage_location
				AND gmv.clm2_value = 'i'-- i for inventory
				AND gmv.clm3_value = tgf.source_counterparty_id
			OUTER APPLY(SELECT mapping_table_id FROM generic_mapping_header WHERE mapping_name = 'Storage Book Mapping') gmh
			WHERE gmv.generic_mapping_values_id IS NULL
			
		COMMIT TRAN

		EXEC spa_ErrorHandler 0
				, 'storage_assets'
				, 'spa_storage_assets'
				, 'Success' 
				, 'Changes have been saved successfully.'
				, @logical_name_generated
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
			ROLLBACK

		SET @DESC = 'Fail to insert Data ( Errr Description:' + ERROR_MESSAGE() + ').'

		SELECT @err_no = ERROR_NUMBER()

		EXEC spa_ErrorHandler @err_no
			, 'storage_assets'
			, 'spa_storage_assets'
			, 'Error'
			, @DESC
			, ''
	END CATCH
END

IF @flag = 'd'
BEGIN
	BEGIN TRY
		BEGIN TRAN
			IF OBJECT_ID('tempdb..#temp_contract') IS NOT NULL
				DROP TABLE #temp_contract	
			CREATE TABLE #temp_contract(contract_name VARCHAR(500) COLLATE DATABASE_DEFAULT)
			INSERT INTO #temp_contract
			SELECT TOP 1 cg.contract_name FROM general_assest_info_virtual_storage gaivs
			INNER JOIN contract_group cg
				ON gaivs.agreement = cg.contract_id
			INNER JOIN dbo.FNASplit(@general_assets_id, ',') dis ON dis.item = gaivs.general_assest_id

			INSERT INTO #temp_contract
			SELECT cg.contract_name
			FROM storage_asset sa
			INNER JOIN dbo.SplitCommaSeperatedValues(@general_assets_parent_id) a
				ON sa.asset_name = a.item
			INNER JOIN general_assest_info_virtual_storage gaivs
				ON gaivs.storage_asset_id = sa.storage_asset_id
			INNER JOIN contract_group cg
				ON gaivs.agreement = cg.contract_id

			IF NOT EXISTS(
				SELECT 1 FROM #temp_contract
			)
			BEGIN
				DELETE vsc FROM virtual_storage_constraint vsc
				INNER JOIN dbo.SplitCommaSeperatedValues(@general_assets_id) a
				ON vsc.general_assest_id = a.item
			
				DELETE FROM storage_ratchet WHERE general_assest_id = @general_assets_id
			
				DELETE gvs FROM general_assest_info_virtual_storage gvs
				INNER JOIN dbo.SplitCommaSeperatedValues(@general_assets_id) a
				ON gvs.general_assest_id = a.item

				DELETE sao FROM storage_asset_owner sao
				INNER JOIN storage_asset sa
					ON sa.storage_asset_id = sao.storage_asset_id
				INNER JOIN dbo.SplitCommaSeperatedValues(@general_assets_parent_id) a
				ON sa.asset_name = a.item

				DELETE sac FROM storage_asset_capacity sac
				INNER JOIN storage_asset sa
					ON sa.storage_asset_id = sac.storage_asset_id
				INNER JOIN dbo.SplitCommaSeperatedValues(@general_assets_parent_id) a
				ON sa.asset_name = a.item

				DELETE sa FROM storage_asset sa
				INNER JOIN dbo.SplitCommaSeperatedValues(@general_assets_parent_id) a
				ON sa.asset_name = a.item

				EXEC spa_ErrorHandler 0
					, 'storage_assets'
					, 'spa_storage_assets'
					, 'Success' 
					, 'Changes have been saved successfully.'
					, @general_assets_id
			END
			ELSE
			BEGIN
				SELECT @DESC = 'The selected Storage Asset cannot be deleted. It has been mapped in Storage Contract: ' + contract_name FROM #temp_contract

				EXEC spa_ErrorHandler 1
				, 'storage_assets'
				, 'spa_storage_assets'
				, 'Error'
				, @DESC
				, ''
			END

		COMMIT TRAN
		
		
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
			ROLLBACK

		SET @DESC = 'Fail to insert Data ( Errr Description:' + ERROR_MESSAGE() + ').'

		SELECT @err_no = ERROR_NUMBER()

		EXEC spa_ErrorHandler @err_no
			, 'storage_assets'
			, 'spa_storage_assets'
			, 'Error'
			, @DESC
			, ''
	END CATCH
END

IF @flag = 'g'
BEGIN
	SELECT	constraint_id, 
			constraint_type, 
			value, 
			uom, 
			effective_date effective_date, 
			frequency
	FROM virtual_storage_constraint 
	WHERE general_assest_id = @general_assets_id
END

IF @flag = 'r'
BEGIN
	SELECT 
		storage_ratchet_id, 
		IIF(term_from = '1990-01-01', '',term_from)  term_from, 
		IIF(term_to = '1990-01-01', '',term_to) term_to,
		inventory_level_from inventory_level_from,
		inventory_level_to inventory_level_to,
		gas_in_storage_perc_from gas_in_storage_perc_from, 
		gas_in_storage_perc_to gas_in_storage_perc_to, 
		[type], 
		perc_of_contracted_storage_space perc_of_contracted_storage_space, 
		fixed_value fixed_value
	FROM storage_ratchet
	WHERE general_assest_id = @general_assets_id
END

IF @flag = 't'
BEGIN
	SELECT * FROM
	(
	SELECT	ISNULL(sa.asset_name, 'Others') [asset_description],
			sml.Location_Name AS [location_name] ,
			general_assest_id AS [id],
			cg.contract_name AS [contract_name],
			sdv.code AS [storage_type],
			--sdv1.code AS [fees],
			--gaivs.commodity_id AS [Commodity],
			sa.storage_asset_id AS [storage_asset_id]
	FROM [general_assest_info_virtual_storage] gaivs 
	INNER JOIN contract_group cg ON cg.contract_id = gaivs.agreement 
	INNER JOIN source_minor_location sml ON sml.source_minor_location_id = gaivs.storage_location
	INNER JOIN static_data_value sdv ON sdv.value_id = gaivs.storage_type
	LEFT JOIN static_data_value sdv1 ON sdv.value_id = gaivs.fees
	LEFT JOIN storage_asset sa ON sa.storage_asset_id = gaivs.storage_asset_id
	LEFT JOIN source_counterparty sc ON sc.source_counterparty_id = gaivs.source_counterparty_id	
	UNION ALL
	SELECT	sa.asset_name,
			--NULL,
			--NULL,
			NULL,
			NULL,
			NULL,
			NULL,
			sa.storage_asset_id
	FROM storage_asset sa 
	LEFT JOIN [general_assest_info_virtual_storage] gaivs 
		ON sa.storage_asset_id = gaivs.storage_asset_id 
	WHERE gaivs.storage_asset_id IS NULL
	)aa ORDER BY aa.storage_asset_id

END

IF @flag = 'x'
BEGIN
	--SELECT 
	--	storage_ratchet_id [ratchet_id], 
	--	gas_in_storage_perc_from [gas_storage_filled_from], 
	--	gas_in_storage_perc_to [gas_storage_filled_to], 
	--	[type] [ratchet_type], 
	--	fixed_value [ratchet]
	--FROM storage_ratchet
	--WHERE general_assest_id = @general_assets_id  // Code for late purpose
	DECLARE @table_name VARCHAR(100)
	IF @process_id IS NOT NULL AND @process_id <> ''
	BEGIN
		SET @table_name = 'run_storage_input_ratchets'
	END
	ELSE
	BEGIN
		SET @table_name = 'run_storage_temp_ratchets'
	END

	SET @sql = 'SELECT id [ratchet_id]
						,gas_storage_from * 100 [gas_storage_filled_from]
						,gas_storage_to * 100 [gas_storage_filled_to]
						,contracted_storage_space * 100 [contracted_storage_space]
						,ratchet_type [ratchet_type]
						,value [ratchet]
						,contract [contract]
				FROM ' + @table_name + '
				WHERE 1 = 1 
	'
	IF @process_id IS NOT NULL AND @process_id <> ''
	BEGIN
		SET @sql += 'AND batch_process_id = ''' + CAST(@process_id AS VARCHAR(100)) + ''''
	END
	EXEC(@sql)
END

IF @flag = 'z'
BEGIN
 IF @process_id IS NOT NULL AND @process_id <> ''
	BEGIN
		SELECT  max_capacity [storage_capacity],
				current_balance [current_balance],
				injection_charge [injection_cost],
				withdraw_charge [withdrawl_cost],
				injection_transport_charge [injection_transport_cost],
				withdraw_transport_charge [withdraw_transport_cost],
				minimum_injection_daily_quantity [minimum_injection_daily_quantity ],
				minimum_withdrawal_daily_quantity[minimum_withdrawal_daily_quantity],
				minimum_working_gas				 [minimum_working_gas],
				maximum_working_gas 			 [maximum_working_gas],
				optimization_term				 [optimization_term],
				obj_function					 [objective_function],
				currency						 [currency],
				CAST(as_of_date AS DATETIME)	 [as_of_date]
		 FROM  run_storage_input_storage
		 WHERE batch_process_id = @process_id
	END
ELSE
	BEGIN
		 SELECT TOP 1 max_capacity [storage_capacity],
				current_balance [current_balance],
				injection_charge [injection_cost],
				withdraw_charge [withdrawl_cost],
				injection_transport_charge [injection_transport_cost],
				withdraw_transport_charge [withdraw_transport_cost],
				minimum_injection_daily_quantity [minimum_injection_daily_quantity ],
				minimum_withdrawal_daily_quantity[minimum_withdrawal_daily_quantity],
				minimum_working_gas				 [minimum_working_gas],
				maximum_working_gas 			 [maximum_working_gas],
				optimization_term				 [optimization_term]
		FROM  run_storage_temp_storage
	END

END

IF @flag = 'q'
BEGIN
	SELECT sml.term_pricing_index [index]
	FROM general_assest_info_virtual_storage gaivs
	INNER JOIN source_minor_location sml 
		ON sml.source_minor_location_id = gaivs.storage_location
	WHERE general_assest_id = @general_assets_id
END

-- For browse grid.
IF @flag = 'v'
BEGIN
	SET @sql_select = 'SELECT	 
			general_assest_id AS [id],
		gaivs.logical_name		AS	[logical_name],
			sml.Location_Name AS [location_name] ,
		cg.[contract_name]		AS	[contract_name],
			sc.counterparty_name AS [counterparty_name],
			sdv.code AS [storage_type]
	FROM [general_assest_info_virtual_storage] gaivs 
	INNER JOIN contract_group cg 
		ON cg.contract_id = gaivs.agreement 
	INNER JOIN source_minor_location sml 
		ON sml.source_minor_location_id = gaivs.storage_location
	INNER JOIN static_data_value sdv 
		ON sdv.value_id = gaivs.storage_type
	LEFT JOIN static_data_value sdv1 
		ON sdv.value_id = gaivs.fees
	LEFT JOIN source_counterparty sc 
		ON sc.source_counterparty_id = gaivs.source_counterparty_id'

	IF @filter_value IS NOT NULL AND @filter_value <> '-1'
	BEGIN
		SET @sql_select += ' INNER JOIN dbo.SplitCommaSeperatedValues(''' + @filter_value + ''') s ON s.item = general_assest_id'
	END
	EXEC(@sql_select)
END

IF @flag = 'w'
BEGIN
	SET @sql_select = 'SELECT cg.contract_id ID, 
	CASE WHEN cg.source_contract_id <> cg.[contract_name] THEN cg.source_contract_id + '' - '' + cg.[contract_name] 
	ELSE cg.[contract_name] END + 
	CASE WHEN cg.source_system_id=2 THEN '''' 
		ELSE CASE WHEN cg.source_system_id IS NULL THEN '''' 
			ELSE ''.'' + ssd.source_system_name 
		END 
	END AS [Name]
FROM contract_group  cg 
LEFT JOIN source_system_description ssd 
		ON ssd.source_system_id = cg.source_system_id '

	IF @filter_value IS NOT NULL AND @filter_value <> '-1'
	BEGIN
		SET @sql_select += ' INNER JOIN dbo.SplitCommaSeperatedValues(''' + @filter_value + ''') s ON s.item = sdd.location_id'
	END
	SET @sql_select +=  ' WHERE 1= 1 
	AND cg.is_active = ''y'' 
	AND contract_type_def_id = 38402
	AND contract_type = ''s''
	ORDER BY [Name]'
	Exec(@sql_select)
END

IF @flag = 'p' -- get location for storage asset
BEGIN
	SELECT @ids = ISNULL(@ids + ',', '') + CAST(sml.source_minor_location_id AS VARCHAR(MAX)),
		@labels = ISNULL(@labels + ',', '') + 
		CASE 
			WHEN sml.Location_Name <> sml.location_id THEN sml.location_id + ' - ' + sml.Location_Name 
			ELSE sml.Location_Name 
		END + 
		CASE
			WHEN sml.location_name IS NULL THEN '' 
			ELSE  ' [' + smjl.location_name + ']' 
		END
	FROM general_assest_info_virtual_storage AS gaivs 
	INNER JOIN source_minor_location AS sml 
		ON  sml.source_minor_location_id = gaivs.storage_location
	INNER JOIN dbo.SplitCommaSeperatedValues(@asset_ids) scsv 
		ON scsv.item = gaivs.general_assest_id
	LEFT JOIN source_major_location smjl 
		ON sml.source_major_location_ID = smjl.source_major_location_ID 
	WHERE smjl.location_name = 'Storage'

	SELECT @ids [id], @labels [label]
END

IF @flag = 'y' -- get contract for storage asset
BEGIN
	SELECT @ids = ISNULL(@ids + ',', '') + CAST(cg.contract_id AS VARCHAR(MAX)),
		@labels = ISNULL(@labels + ',', '') + cg.contract_name
	FROM general_assest_info_virtual_storage AS gaivs  
	INNER JOIN contract_group cg 
		ON cg.contract_id = gaivs.agreement
	INNER JOIN dbo.SplitCommaSeperatedValues(@asset_ids) scsv 
		ON scsv.item = gaivs.general_assest_id

	SELECT @ids [id], @labels [label]
END

IF @flag = 's' --save storage owner
BEGIN
	EXEC sp_xml_preparedocument @idoc OUTPUT, @general_xml
	
	CREATE TABLE #temp_storage_asset_owner(				
		effective_date VARCHAR(10) COLLATE DATABASE_DEFAULT, 
		counterparty_id VARCHAR(100) COLLATE DATABASE_DEFAULT, 
		[percentage]	VARCHAR(10) COLLATE DATABASE_DEFAULT,
		storage_asset VARCHAR(100) COLLATE DATABASE_DEFAULT 
	)
	
	INSERT INTO #temp_storage_asset_owner(								
		effective_date
		,counterparty_id
		,percentage
		,storage_asset		
	)
	SELECT 
		NULLIF(effective_date, ''),
		NULLIF(counterparty_id, ''),
		NULLIF(percentage, ''),
		NULLIF(storage_asset, '')
	FROM   OPENXML (@idoc, '/Grid/GridRow', 2)
	WITH (							
			effective_date VARCHAR(100) '@effective_date',
			counterparty_id VARCHAR(100) '@counterparty_id', 
		[percentage]	VARCHAR(10)		'@percentage',
			storage_asset VARCHAR(100) '@storage_asset'
	)

	DELETE 
	FROM storage_asset_owner 
	WHERE storage_asset_id = @storage_asset_id

	INSERT INTO storage_asset_owner (effective_date, counterparty_id, percentage, storage_asset_id)
	SELECT temp.effective_date
		  ,temp.counterparty_id
		  ,temp.percentage
		  ,sa.storage_asset_id
	FROM #temp_storage_asset_owner temp
	INNER JOIN storage_asset sa
		ON REPLACE(asset_name,' ','') =  temp.storage_asset

	EXEC spa_ErrorHandler 0,
				 'storage asset parent',
				 'spa_storage_assets',
				 'Success',
				 'Changes have been saved successfully.',
				 ''	
				 	
END

IF @flag = 'f'
BEGIN
	SELECT storage_asset_id FROM storage_asset WHERE REPLACE(asset_name,' ','') = @storage_asset_id
END

IF @flag = 'k'
BEGIN
	--IF @agreement IS NOT NULL
	--BEGIN
	SET @sql = '	
		SELECT general_assest_id, asset_name
		FROM general_assest_info_virtual_storage AS gaivs
		RIGHT JOIN storage_asset AS sa
			ON sa.storage_asset_id = gaivs.storage_asset_id AND gaivs.agreement = ' + @agreement + '
		WHERE sa.storage_asset_id = ' + @storage_asset_id
			
	--END
	--ELSE
	--BEGIN
	--	SET @sql = 'SELECT asset_name FROM storage_asset WHERE storage_asset_id = ' + @storage_asset_id
	--END
	
	--PRINT @sql
	EXEC(@sql)
END

IF @flag = 'o'
BEGIN
	SELECT sao.storage_asset_owner_id,sao.effective_date, sao.counterparty_id, sao.percentage 
	FROM storage_asset_owner sao
	INNER JOIN storage_asset sa 
	ON sa.storage_asset_id = sao.storage_asset_id
	WHERE REPLACE(asset_name,' ','') = @storage_asset_id
END

IF @flag = 'n'
BEGIN
	DECLARE @fees         INT,
	        @currency     INT,
	        @logical_name VARCHAR(100)
	
	SELECT @fees = MAX(value_id)
	FROM   transportation_rate_category
	
	SELECT @currency = MAX(source_currency_id)
	FROM   source_currency
	
	SELECT @logical_name = sml.Location_Description  FROM storage_asset AS sa
	INNER JOIN source_minor_location AS sml
		ON sa.location_id = sml.source_minor_location_id 
	WHERE sa.storage_asset_id = @storage_asset_id
	
	SELECT @logical_name = @logical_name + '/' + contract_name + '/' FROM contract_group WHERE contract_id = @agreement

	DELETE FROM general_assest_info_virtual_storage WHERE storage_asset_id = @storage_asset_id AND agreement = @agreement

	INSERT INTO general_assest_info_virtual_storage
		(
		storage_asset_id,
		storage_location,
		agreement,                                                                                                                                                                                                                                                                                                                                                                                                                                    
		storage_type,
		--fees,
		accounting_type,
		ownership_type,
		volumn_uom,
		cost_currency,
		logical_name,
		source_counterparty_id,
		include_product_lot,
		injection_as_long,
		include_fees,
		calculate_mtm,
		include_non_standard_deals
		)
	SELECT sa.storage_asset_id,
		sa.location_id,
		@agreement,
		18502,
		--@fees,
		45400,
		45300,
		cg.volume_uom,
		@currency,
		@logical_name,
		cg.pipeline,
		'n',
		'n',
		'n',
		'n',
		'n'
	FROM   contract_group cg
	LEFT JOIN storage_asset AS sa
		ON  cg.storage_asset_id = sa.storage_asset_id
	LEFT JOIN general_assest_info_virtual_storage AS gaivs
		ON gaivs.storage_asset_id = sa.storage_asset_id	
			AND gaivs.agreement = @agreement		
	WHERE  sa.storage_asset_id = @storage_asset_id
		AND cg.contract_id = @agreement
		AND gaivs.agreement IS NULL
		
	SELECT cg.pipeline [counterparty_id], cg.contract_id [contract_id] FROM contract_group AS cg where cg.contract_id = @agreement
END

IF @flag = 'b'
BEGIN
	SELECT TOP 1 SUM(capacity) capacity 
	FROM   storage_asset_capacity 
	GROUP BY effective_date, 
		storage_asset_id 
	HAVING storage_asset_id = @storage_asset_id
	ORDER BY effective_date DESC 
END

GO
