IF OBJECT_ID(N'[dbo].[spa_maintain_criteria_dhx]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[spa_maintain_criteria_dhx]
GO

-- ===========================================================================================================
-- Author: bmaharjan@pioneersolutionsglobal.com
-- Create date: 2016-03-03
-- Description: CRUD operation for Setup Whatif criteria
 
-- Params:
-- @flag     CHAR - Operation flag

-- ===========================================================================================================

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[spa_maintain_criteria_dhx]
	@flag CHAR(1),
	@criteria_id VARCHAR(MAX) = NULL,
	@xml xml = NULL,
	@scenario_type CHAR(1) = NULL,
	@portfolio_xml VARCHAR(MAX) = NULL,
	@whatif_criteria_other_id VARCHAR(200) = NULL,
	@criteria_other_xml xml = NULL
AS
/*-------------------Debug Section-----------------------
DECLARE @flag CHAR(1),
		@criteria_id VARCHAR(100) = NULL,
		@xml xml = NULL,
		@scenario_type CHAR(1) = NULL,
		@portfolio_xml VARCHAR(MAX) = NULL,
		@whatif_criteria_other_id VARCHAR(200) = NULL,
		@criteria_other_xml xml = NULL

SELECT @flag='u',@criteria_id='102',@xml='<Root><CriteriaDefinition  criteria_id="102" criteria_name="0 Test1222018" criteria_description="" role="107" user="3163" active="y" public="n" scenario_type="i" source="4500" revaluation="n" specified_shift="n" Volatility_source="10639" scenario_group_id="" hold_to_maturity="n" use_market_value="n" use_discounted_value="n" scenario_criteria_group=""/><CriteriaDetail  id="54" risk_factor="p" shift="24003" shift_item="50" shift_by="p" shift_value="5" month_from="" month_to="" use_existing="0" shift1="" shift2="" shift3="" shift4="" shift5="" shift6="" shift7="" shift8="" shift9="" shift10="" scenario_type="i"/><CriteriaDetail  id="55" risk_factor="p" shift="24003" shift_item="123" shift_by="p" shift_value="5" month_from="" month_to="" use_existing="0" shift1="" shift2="" shift3="" shift4="" shift5="" shift6="" shift7="" shift8="" shift9="" shift10="" scenario_type="i"/><CriteriaMeasure  position="y" mtm="y" var="n" cfar="n" ear="n" pfe="n" gmar="n" credit="n" var_approach="" confidence_interval="" holding_days="" no_of_simulations=""/><CriteriaMigration  whatif_criteria_migration_id="65" counterparty_id="7642" risk_rating="11100" migration="0" internal_counterparty_id="7486" contract_id="9125"/></Root>',@scenario_type='i',@portfolio_xml='<Root><MappingXML  sub_book_id="3731,3702,3703,3707,3708,3704,3706,3718,3759" deal_ids="" portfolio_group_id="" trader="" deal_type_id="" region_id="" commodity_id="" counterparty_id="" internal_counterparty_id="" contract_id="" entity_type_id="" industry1="" industry2="" sic_code="" rating_type="" rating="" fixed_term="0" term_start="" term_end="" relative_term="0" starting_month="" no_of_month=""></MappingXML></Root>'
DROP TABLE #temp_criteria_definition
DROP TABLE #temp_criteria_detail
DROP TABLE #temp_criteria_measure
DROP TABLE #temp_criteria_migration
---------------------------------------------------------*/

SET NOCOUNT ON

DECLARE @idoc INT
DECLARE @DESC VARCHAR(500)
DECLARE @err_no INT 
DECLARE @portfolio_mapping_source INT = 23201 --WhatIF Mapping Source

EXEC sp_xml_preparedocument @idoc OUTPUT, @xml
	
SELECT * INTO #temp_criteria_definition
FROM   OPENXML(@idoc, '/Root/CriteriaDefinition', 1)
		WITH (
			criteria_id INT '@criteria_id',
			criteria_name VARCHAR(100) '@criteria_name',
			criteria_description VARCHAR(200) '@criteria_description',
			[role] VARCHAR(20) '@role',
			[user] VARCHAR(100) '@user',
			active CHAR(1) '@active',
			[public] CHAR(1) '@public',
			scenario_type CHAR(1) '@scenario_type',
			source VARCHAR(20) '@source',
			Volatility_source VARCHAR(20) '@Volatility_source',
			scenario_group_id INT '@scenario_group_id',
			revaluation CHAR(1) '@revaluation',
			hold_to_maturity CHAR(1) '@hold_to_maturity',
			use_market_value CHAR(1) '@use_market_value',
			counterparty_id	INT '@counterparty_id',
			debt_rating INT '@debt_rating',
			migration INT '@migration',
			use_discounted_value CHAR(1) '@use_discounted_value',
			scenario_criteria_group INT '@scenario_criteria_group'
		)

SELECT * INTO #temp_criteria_detail
FROM   OPENXML(@idoc, '/Root/CriteriaDetail', 1)
		WITH (
			id INT '@id',
			risk_factor CHAR(1) '@risk_factor',
			[shift] VARCHAR(20) '@shift',
			shift_item VARCHAR(20) '@shift_item',
			shift_by CHAR(1) '@shift_by',
			shift_value VARCHAR(20) '@shift_value',
			month_from VARCHAR(20) '@month_from',
			month_to VARCHAR(20) '@month_to',
			use_existing VARCHAR(20) '@use_existing',
			scenario_type CHAR(1) '@scenario_type',
			[shift1] VARCHAR(20) '@shift1',
			[shift2] VARCHAR(20) '@shift2',
			[shift3] VARCHAR(20) '@shift3',
			[shift4] VARCHAR(20) '@shift4',
			[shift5] VARCHAR(20) '@shift5',
			[shift6] VARCHAR(20) '@shift6',
			[shift7] VARCHAR(20) '@shift7',
			[shift8] VARCHAR(20) '@shift8',
			[shift9] VARCHAR(20) '@shift9',
			[shift10] VARCHAR(20) '@shift10'				
		)
--select * from #temp_criteria_detail
--return
SELECT * INTO #temp_criteria_measure
FROM   OPENXML(@idoc, '/Root/CriteriaMeasure', 1)
		WITH (
			position CHAR(1) '@position',
			mtm CHAR(1) '@mtm',
			[var] CHAR(1) '@var',
			cfar CHAR(1) '@cfar',
			ear CHAR(1) '@ear',
			pfe CHAR(1) '@pfe',
			gmar CHAR(1) '@gmar',
			credit CHAR(1) '@credit',
			var_approach INT '@var_approach',
			confidence_interval INT '@confidence_interval',
			holding_days VARCHAR(10) '@holding_days',
			no_of_simulations INT '@no_of_simulations'
		)
		
SELECT * INTO #temp_criteria_migration
FROM   OPENXML(@idoc, '/Root/CriteriaMigration', 1)
       WITH (
           whatif_criteria_migration_id INT '@whatif_criteria_migration_id',
           counterparty_id INT '@counterparty_id',
           risk_rating INT '@risk_rating',
           migration INT '@migration',
		   internal_counterparty_id INT '@internal_counterparty_id',
		   contract_id INT '@contract_id'
       )	
       
     
IF @flag = 'g'
BEGIN
	SELECT	mwc.criteria_id [Criteria ID],
			mwc.criteria_name [Criteria Name],
			mwc.criteria_description [Criteria Description],
			mwc.[user] [User],
			asr.role_name [Role],
			CASE WHEN mwc.[active] = 'y' THEN 'Yes' ELSE 'No' END [Active],
			CASE WHEN mwc.[public] = 'y' THEN 'Yes' ELSE 'No' END [Public],
			sdv.code AS [Source],
			sdv1.code AS [Volatility Source]
	 FROM maintain_whatif_criteria mwc
	 LEFT JOIN static_data_value sdv ON mwc.source = sdv.value_id
	 LEFT JOIN static_data_value sdv1 ON mwc.volatility_source = sdv1.value_id
	 LEFT JOIN application_security_role asr ON asr.role_id= mwc.[role]
	 ORDER BY mwc.criteria_name
END

IF @flag = 'm'
BEGIN
	SELECT	wcm.MTM,
			wcm.position,
			wcm.[Var],
			wcm.Cfar,
			wcm.Ear,
			wcm.PFE,
			wcm.Gmar,
			wcm.credit,
			wcm.var_approach,
			wcm.confidence_interval,
			wcm.holding_days,
			wcm.no_of_simulations,
			mwc.hold_to_maturity,
			mwc.use_market_value,
			mwc.use_discounted_value
	 FROM whatif_criteria_measure  wcm
	 INNER JOIN maintain_whatif_criteria mwc ON wcm.criteria_id = mwc.criteria_id
	WHERE mwc.criteria_id = @criteria_id
END

IF @flag = 'd'
BEGIN
	BEGIN TRY
		BEGIN TRAN
			--DELETE wco FROM whatif_criteria_other wco
			--INNER JOIN dbo.SplitCommaSeperatedValues(@criteria_id) a ON wco.criteria_id = a.item
			
			DELETE pms FROM portfolio_mapping_source pms
			INNER JOIN dbo.SplitCommaSeperatedValues(@criteria_id) a ON pms.mapping_source_usage_id = a.item
				AND pms.mapping_source_value_id = @portfolio_mapping_source
			
			DELETE wcmi FROM whatif_criteria_migration wcmi
			INNER JOIN dbo.SplitCommaSeperatedValues(@criteria_id) a ON wcmi.maintain_whatif_criteria_id = a.item

			DELETE wcs FROM whatif_criteria_scenario wcs
			INNER JOIN dbo.SplitCommaSeperatedValues(@criteria_id) a ON wcs.criteria_id = a.item
			
    		DELETE wcm FROM whatif_criteria_measure wcm
			INNER JOIN dbo.SplitCommaSeperatedValues(@criteria_id) a ON wcm.criteria_id = a.item
			
			DELETE mwc FROM maintain_whatif_criteria mwc
			INNER JOIN dbo.SplitCommaSeperatedValues(@criteria_id) a ON mwc.criteria_id = a.item
    	COMMIT
		EXEC spa_ErrorHandler 0
			, 'maintain_whatif_criteria'
			, 'spa_maintain_criteria_dhx'
			, 'Success'
			, 'Changes have been saved successfully.'
			, ''
    END TRY
    BEGIN CATCH
    	ROLLBACK
		EXEC spa_ErrorHandler -1
			, 'maintain_whatif_criteria'
			, 'spa_maintain_criteria_dhx'
			, 'Error'
			, 'Failed to delete.'
			, ''
	END CATCH
END

IF @flag = 'i'
BEGIN
	BEGIN TRY
		BEGIN TRAN
			IF NOT EXISTS (SELECT 1 FROM maintain_whatif_criteria mwc INNER JOIN #temp_criteria_definition temp ON mwc.criteria_name = temp.criteria_name)
			BEGIN
			INSERT INTO maintain_whatif_criteria 
			(
				criteria_name,
				criteria_description,
				[role],
				[user],
				active,
				[public],
				scenario_type,
				source,
				Volatility_source,
				scenario_group_id,
				revaluation,
				hold_to_maturity,
				use_market_value,
				counterparty_id,
				debt_rating,
				migration,
				use_discounted_value,
				scenario_criteria_group
			)
			SELECT 
				criteria_name,
				criteria_description,
				[role],
				[user],
				active,
				[public],
				scenario_type,
				source,
				Volatility_source,
				NULLIF(scenario_group_id,'') scenario_group_id,
				revaluation,
				hold_to_maturity,
				use_market_value,
				counterparty_id,
				debt_rating,
				migration,
				use_discounted_value,
				scenario_criteria_group
			FROM #temp_criteria_definition

			DECLARE @new_criteria_id INT
			SET @new_criteria_id = SCOPE_IDENTITY()
		
			INSERT INTO whatif_criteria_scenario
			(
				risk_factor,
				shift_group,
				shift_item,
				shift_by,
				shift_value,
				month_from,
				month_to,
				use_existing_values,
				scenario_type,
				criteria_id,
				[shift1],
				[shift2],
				[shift3],
				[shift4],
				[shift5],
				[shift6],
				[shift7],
				[shift8],
				[shift9],
				[shift10]
			) 

			SELECT 
				risk_factor,
				NULLIF(shift,''),
				NULLIF(shift_item,''),
				NULLIF(shift_by,''),
				CAST(NULLIF(shift_value,'') AS FLOAT),
				NULLIF(month_from,''),
				NULLIF(month_to,''),
				use_existing,
				scenario_type,
				@new_criteria_id,
				NULLIF([shift1],''),
				NULLIF([shift2],''),
				NULLIF([shift3],''),
				NULLIF([shift4],''),
				NULLIF([shift5],''),
				NULLIF([shift6],''),
				NULLIF([shift7],''),
				NULLIF([shift8],''),
				NULLIF([shift9],''),
				NULLIF([shift10],'')
			FROM #temp_criteria_detail


			INSERT INTO whatif_criteria_measure
			(
				position,
				MTM,
				[Var],
				Cfar,
				Ear,
				PFE,
				Gmar,
				credit,
				var_approach,
				confidence_interval,
				holding_days,
				no_of_simulations,
				criteria_id	
			)
			SELECT
				position,
				mtm,
				[var],
				cfar,
				ear,
				pfe,
				Gmar,
				credit,
				var_approach,
				NULLIF(confidence_interval,''),
				--NULLIF(holding_days, ''),
				CASE WHEN holding_days = 'NULL' THEN NULL ELSE CAST(holding_days AS INT) END,
				NULLIF(no_of_simulations,''),
				@new_criteria_id
			FROM #temp_criteria_measure
			
			INSERT INTO whatif_criteria_migration
			(
				maintain_whatif_criteria_id,
				counterparty_id,
				risk_rating,
				migration,
				internal_counterparty_id,
				contract_id	
			)
			SELECT 
				@new_criteria_id,
				NULLIF(counterparty_id, 0),
				NULLIF(risk_rating, 0),
				NULLIF(migration, 0),
				NULLIF(internal_counterparty_id, 0),
				NULLIF(contract_id, 0)
			FROM #temp_criteria_migration

			EXEC spa_generic_portfolio_mapping_template @flag = @flag, @mapping_source_id = @portfolio_mapping_source, @mapping_source_value_id = @new_criteria_id, @xml = @portfolio_xml 
			END
			ELSE
			BEGIN
				EXEC spa_ErrorHandler 1, 
				'maintain_whatif_criteria', 
				'spa_maintain_criteria_dhx', 
				'DB Error', 
				'Duplicate data in <b>Criteria Name</b>.',
				''
			END
		COMMIT TRAN

		EXEC spa_ErrorHandler 0
				, 'maintain_whatif_criteria'
				, 'spa_maintain_criteria_dhx'
				, 'Success' 
				, 'Changes have been saved successfully.'
				, @new_criteria_id
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
			ROLLBACK

		SET @DESC = 'Fail to insert Data ( Errr Description:' + ERROR_MESSAGE() + ').'

		SELECT @err_no = ERROR_NUMBER()

		EXEC spa_ErrorHandler @err_no
			, 'maintain_whatif_criteria'
			, 'spa_maintain_criteria_dhx'
			, 'Error'
			, @DESC
			, ''
	END CATCH
END

ELSE IF @flag = 'u'
BEGIN
	BEGIN TRY
		BEGIN TRAN
			UPDATE mwc
			SET mwc.criteria_name = tcd.criteria_name,
				mwc.criteria_description = tcd.criteria_description,
				mwc.[role] = tcd.[role],
				mwc.[user] = tcd.[user],
				mwc.active = tcd.active,
				mwc.[public] = tcd.[public],
				mwc.scenario_type = tcd.scenario_type,
				mwc.source = tcd.source,
				mwc.Volatility_source = tcd.Volatility_source,
				mwc.scenario_group_id = NULLIF(tcd.scenario_group_id,''),
				mwc.revaluation = tcd.revaluation,
				mwc.hold_to_maturity = tcd.hold_to_maturity,
				mwc.use_market_value = tcd.use_market_value,
				mwc.counterparty_id = tcd.counterparty_id,
				mwc.debt_rating = tcd.debt_rating,
				mwc.migration = tcd.migration,
				mwc.use_discounted_value = tcd.use_discounted_value,
				mwc.scenario_criteria_group = tcd.scenario_criteria_group
			FROM #temp_criteria_definition tcd
			INNER JOIN maintain_whatif_criteria mwc
			ON tcd.criteria_id = mwc.criteria_id

			DELETE wcs 
			FROM whatif_criteria_scenario wcs
			LEFT JOIN #temp_criteria_detail tcd ON tcd.id = wcs.whatif_criteria_scenario_id
			WHERE (tcd.id IS NULL OR tcd.scenario_type <> @scenario_type) AND wcs.criteria_id = @criteria_id
			
			
			INSERT INTO whatif_criteria_scenario
			(
				risk_factor,
				shift_group,
				shift_item,
				shift_by,
				shift_value,
				month_from,
				month_to,
				use_existing_values,
				scenario_type,
				criteria_id,
				[shift1],
				[shift2],
				[shift3],
				[shift4],
				[shift5],
				[shift6],
				[shift7],
				[shift8],
				[shift9],
				[shift10]
			) 
			SELECT 
				risk_factor,
				NULLIF(shift,''),
				NULLIF(shift_item,''),
				NULLIF(shift_by,''),
				CAST(NULLIF(shift_value,'') AS FLOAT),
				NULLIF(month_from,''),
				NULLIF(month_to,''),
				use_existing,
				scenario_type,
				@criteria_id,
				NULLIF([shift1],''),
				NULLIF([shift2],''),
				NULLIF([shift3],''),
				NULLIF([shift4],''),
				NULLIF([shift5],''),
				NULLIF([shift6],''),
				NULLIF([shift7],''),
				NULLIF([shift8],''),
				NULLIF([shift9],''),
				NULLIF([shift10],'')
			FROM #temp_criteria_detail tcd
			WHERE tcd.id = 0
			
			UPDATE wcs 
			SET 
				wcs.risk_factor = tcd.risk_factor,
				wcs.shift_group = NULLIF(tcd.[shift],''),
				wcs.shift_item = NULLIF(tcd.shift_item,''),
				wcs.shift_by = NULLIF(tcd.shift_by,''),
				wcs.shift_value = CAST(NULLIF(tcd.shift_value,'') AS FLOAT),
				wcs.month_from = NULLIF(tcd.month_from,''),
				wcs.month_to = NULLIF(tcd.month_to,''),
				wcs.use_existing_values = tcd.use_existing,
				wcs.scenario_type = tcd.scenario_type,
				wcs.[shift1] = NULLIF(tcd.[shift1],''),
				wcs.[shift2] = NULLIF(tcd.[shift2],''),
				wcs.[shift3] = NULLIF(tcd.[shift3],''),
				wcs.[shift4] = NULLIF(tcd.[shift4],''),
				wcs.[shift5] = NULLIF(tcd.[shift5],''),
				wcs.[shift6] = NULLIF(tcd.[shift6],''),
				wcs.[shift7] = NULLIF(tcd.[shift7],''),
				wcs.[shift8] = NULLIF(tcd.[shift8],''),
				wcs.[shift9] = NULLIF(tcd.[shift9],''),
				wcs.[shift10] = NULLIF(tcd.[shift10],'')
			FROM #temp_criteria_detail tcd
			INNER JOIN whatif_criteria_scenario wcs ON tcd.id = wcs.whatif_criteria_scenario_id 
			WHERE tcd.scenario_type = @scenario_type

			UPDATE wcm
			SET wcm.position = tcm.position,
				wcm.mtm = tcm.mtm,
				wcm.[var] = tcm.[var],
				wcm.cfar = tcm.cfar,
				wcm.ear = tcm.ear,
				wcm.pfe = tcm.pfe,
				wcm.gmar = tcm.gmar,
				wcm.credit = tcm.credit,
				wcm.var_approach = tcm.var_approach,
				wcm.confidence_interval = tcm.confidence_interval,
				wcm.holding_days = CASE WHEN tcm.holding_days = 'NULL' THEN NULL ELSE CAST(tcm.holding_days AS INT) END,
				wcm.no_of_simulations= tcm.no_of_simulations
			FROM #temp_criteria_measure tcm
			INNER JOIN whatif_criteria_measure wcm
			ON wcm.criteria_id = @criteria_id
			
			DELETE wcmi 
			FROM whatif_criteria_migration wcmi
			LEFT JOIN #temp_criteria_migration tcmi ON tcmi.whatif_criteria_migration_id = wcmi.whatif_criteria_migration_id
			WHERE tcmi.whatif_criteria_migration_id IS NULL AND wcmi.maintain_whatif_criteria_id = @criteria_id
			
			INSERT INTO whatif_criteria_migration
			(
				maintain_whatif_criteria_id,
				counterparty_id,
				risk_rating,
				migration,
				internal_counterparty_id,
				contract_id	
			)
			SELECT 
				@criteria_id,
				NULLIF(counterparty_id, 0),
				NULLIF(risk_rating, 0),
				NULLIF(migration, 0),
				NULLIF(internal_counterparty_id, 0),
				NULLIF(contract_id, 0)
			FROM #temp_criteria_migration tcmi 
			WHERE tcmi.whatif_criteria_migration_id = 0
			
			UPDATE wcmi
			SET    wcmi.maintain_whatif_criteria_id = @criteria_id,
			       wcmi.counterparty_id = tcmi.counterparty_id,
			       wcmi.risk_rating = tcmi.risk_rating,
			       wcmi.migration = tcmi.migration
			FROM   #temp_criteria_migration tcmi
			       INNER JOIN whatif_criteria_migration wcmi
			            ON  wcmi.whatif_criteria_migration_id = tcmi.whatif_criteria_migration_id

			EXEC spa_generic_portfolio_mapping_template @flag = @flag, @mapping_source_id = @portfolio_mapping_source, @mapping_source_value_id = @criteria_id, @xml = @portfolio_xml 
			
		COMMIT TRAN

		EXEC spa_ErrorHandler 0
				, 'maintain_whatif_criteria'
				, 'spa_maintain_criteria_dhx'
				, 'Success' 
				, 'Changes have been saved successfully.'
				, ''
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
			ROLLBACK

		SET @DESC = 'Fail to insert Data ( Errr Description:' + ERROR_MESSAGE() + ').'

		SELECT @err_no = ERROR_NUMBER()

		EXEC spa_ErrorHandler @err_no
			, 'maintain_whatif_criteria'
			, 'spa_maintain_criteria_dhx'
			, 'Error'
			, @DESC
			, ''
	END CATCH
END

--Load the scenario grid (inside scenario tab)
ELSE IF @flag = 's'
BEGIN
	SELECT	wcs.whatif_criteria_scenario_id,
			wcs.risk_factor,
			wcs.shift_group,
			wcs.shift_item,
			wcs.shift_by,
			CASE WHEN (wcs.shift_by = 'c' OR wcs.shift_by = 'u') THEN CAST(wcs.shift_value AS INT) ELSE CAST(dbo.FNARemoveTrailingZeroes(wcs.shift_value) AS FLOAT) END,
			wcs.month_from,
			wcs.month_to,
			wcs.use_existing_values,
			wcs.shift1,
			wcs.shift2,
			wcs.shift3,
			wcs.shift4,
			wcs.shift5,
			wcs.shift6,
			wcs.shift7,
			wcs.shift8,
			wcs.shift9,
			wcs.shift10
	FROM whatif_criteria_scenario wcs
	WHERE wcs.criteria_id = @criteria_id
	AND wcs.scenario_type = @scenario_type
END

--Load the data in migration tab grid
ELSE IF @flag = 'z'
BEGIN
	SELECT whatif_criteria_migration_id,
	       counterparty_id,
		   internal_counterparty_id,
		   contract_id,
	       risk_rating,
	       migration
	FROM   whatif_criteria_migration
	WHERE  maintain_whatif_criteria_id = @criteria_id
END

-- Load the data in hypothetical tab grid
ELSE IF @flag = 'h'
BEGIN
	SELECT	pmo.portfolio_mapping_other_id id,
		ssbm.logical_name sub_book,
		sdht.template_name template,
		sdv_block.code block_definition,
		sc.counterparty_name counterparty,		
		spcd_m.curve_name buy_index,
		round(cast(pmo.buy_price as decimal(10,2)),2) buy_price,		
		spcd_p.curve_name buy_pricing_index,
		round(cast(pmo.buy_volume as decimal(10,2)),2) buy_volume,
		round(cast(pmo.buy_total_volume as decimal(10,2)),2) buy_total_volume,		
		dbo.FNADateFormat(pmo.buy_term_start) buy_term_start,
		dbo.FNADateFormat(pmo.buy_term_end) buy_term_end,
		spcd_ms.curve_name sell_index,
		round(cast(pmo.sell_price as decimal(10,2)),2) sell_price,		
		spcd_ps.curve_name sell_pricing_index,
		round(cast(pmo.sell_volume as decimal(10,2)),2) sell_volume,
		round(cast(pmo.sell_total_volume as decimal(10,2)),2) sell_total_volume,	
		dbo.FNADateFormat(pmo.sell_term_start) sell_term_start,
		dbo.FNADateFormat(pmo.sell_term_end) sell_term_end
	FROM portfolio_mapping_other pmo
		LEFT JOIN portfolio_mapping_source pms
			ON pmo.portfolio_mapping_source_id = pms.portfolio_mapping_source_id
		LEFT JOIN source_counterparty sc 
			ON pmo.counterparty = sc.source_counterparty_id
		LEFT JOIN source_system_book_map ssbm
			ON ssbm.book_deal_type_map_id = pmo.sub_book_id
		LEFT JOIN source_deal_header_template sdht
			ON sdht.template_id = pmo.template_id
		LEFT JOIN static_data_value sdv_block
			ON sdv_block.value_id = pmo.block_definition
				AND type_id = 10018
		LEFT JOIN source_price_curve_def spcd_m
			ON spcd_m.source_curve_def_id = pmo.buy_index
		LEFT JOIN source_price_curve_def spcd_p
			ON spcd_p.source_curve_def_id = pmo.buy_pricing_index
		LEFT JOIN source_price_curve_def spcd_ms
			ON spcd_ms.source_curve_def_id = pmo.sell_index
		LEFT JOIN source_price_curve_def spcd_ps
			ON spcd_ps.source_curve_def_id = pmo.sell_pricing_index
	WHERE pms.mapping_source_usage_id = @criteria_id
END


-- DELETE the data in hypothetical tab grid
ELSE IF @flag = 'o'
BEGIN
	BEGIN TRY
		DELETE wco FROM portfolio_mapping_other wco
		INNER JOIN dbo.SplitCommaSeperatedValues(@whatif_criteria_other_id) a ON wco.portfolio_mapping_other_id = a.item

		EXEC spa_ErrorHandler 0
				, 'whatif_criteria_other'
				, 'spa_maintain_criteria_dhx'
				, 'Success'
				, 'Changes have been saved successfully.'
				, ''
    END TRY
    BEGIN CATCH
		EXEC spa_ErrorHandler -1
			, 'whatif_criteria_other'
			, 'spa_maintain_criteria_dhx'
			, 'Error'
			, 'Failed to delete.'
			, ''
	END CATCH
END

-- Get the whatif_criteria_other data from update mode
ELSE IF @flag = 'a'
BEGIN
	SELECT	wco.sub_book_id,
			wco.template_id,
			wco.counterparty,
			wco.block_definition,
			wco.buy,
			wco.buy_index,
			CAST(wco.buy_price AS NUMERIC(32,2)) buy_price,
			wco.buy_pricing_index,
			wco.buy_currency,
			CAST(wco.buy_volume AS NUMERIC(32,2)) buy_volume,
			CAST(wco.buy_total_volume AS NUMERIC(32,2)) buy_total_volume,
			wco.buy_volume_frequency,
			wco.buy_uom,
			dbo.FNACovertToSTDDate(wco.buy_term_start) buy_term_start,
			dbo.FNACovertToSTDDate(wco.buy_term_end) buy_term_end,
			wco.sell,
			wco.sell_index,
			CAST(wco.sell_price AS NUMERIC(32,2)) sell_price,
			wco.sell_pricing_index,
			wco.sell_currency,
			CAST(wco.sell_volume AS NUMERIC(32,2)) sell_volume,
			CAST(wco.sell_total_volume AS NUMERIC(32,2)) sell_total_volume,
			wco.sell_volume_frequency,
			wco.sell_uom,
			dbo.FNACovertToSTDDate(wco.sell_term_start) sell_term_start,
			dbo.FNACovertToSTDDate(wco.sell_term_end) sell_term_end
	FROM portfolio_mapping_other wco
	WHERE wco.portfolio_mapping_other_id = @whatif_criteria_other_id
END

ELSE IF @flag = 'w'
BEGIN
	BEGIN TRY
		BEGIN TRAN
		DECLARE @idoc1 INT
		DECLARE @new_id INT = ''
		

		IF OBJECT_ID('tempdb..#total_volume') IS NOT NULL
			DROP TABLE #total_volume

		CREATE TABLE #total_volume (
			buy_total_volume NUMERIC(38, 20),
			sell_total_volume NUMERIC(38, 20)
		)

		EXEC sp_xml_preparedocument @idoc1 OUTPUT, @criteria_other_xml
	
		SELECT * INTO #temp_criteria_others
		FROM   OPENXML(@idoc1, '/Root/CriteriaOther', 1)
			WITH (
				whatif_criteria_other_id INT '@whatif_criteria_other_id',
				counterparty INT '@counterparty',
				buy CHAR(1) '@buy',
				market_index_buy INT '@market_index_buy',
				price_buy VARCHAR(20) '@price_buy',
				pricing_index_buy INT '@pricing_index_buy',
				currency_buy INT '@currency_buy',
				volume_buy VARCHAR(20) '@volume_buy',
				volume_frequency_buy CHAR(1) '@volume_frequency_buy',
				uom_buy INT '@uom_buy',
				term_start_buy VARCHAR(20) '@term_start_buy',
				term_end_buy VARCHAR(20) '@term_end_buy',
				block_definition INT '@block_definition',
				sell CHAR(1) '@sell',
				market_index_sell INT '@market_index_sell',
				price_sell VARCHAR(20) '@price_sell',
				pricing_index_sell INT '@pricing_index_sell',
				currency_sell INT '@currency_sell',
				volume_sell VARCHAR(20) '@volume_sell',
				volume_frequency_sell CHAR(1) '@volume_frequency_sell',
				uom_sell INT '@uom_sell',
				term_start_sell VARCHAR(20) '@term_start_sell',
				term_end_sell VARCHAR(20) '@term_end_sell',
				sub_book_id INT '@sub_book',
				template_id INT '@template'
			)

		IF EXISTS( SELECT 1 
					FROM  #temp_criteria_others 
					WHERE (term_start_buy > term_end_buy OR term_start_sell > term_end_sell) 
				)
		BEGIN
			IF @@TRANCOUNT > 0
				ROLLBACK
	 
			EXEC spa_ErrorHandler -1
				, 'whatif_criteria_other'
				, 'spa_maintain_criteria_dhx'
				, 'Error'
				, 'Term start cannot be greater than term end.'
				, ''
			RETURN;
		END
		

		UPDATE wco
		SET	wco.counterparty = tco.counterparty,
			wco.buy = tco.buy,
			wco.buy_index = NULLIF(tco.market_index_buy, ''),
			wco.buy_price = NULLIF(CAST(tco.price_buy AS VARCHAR),''),
			wco.buy_pricing_index = NULLIF(tco.pricing_index_buy, ''),
			wco.buy_currency = NULLIF(tco.currency_buy, ''),
			wco.buy_volume = NULLIF(CAST(tco.volume_buy AS VARCHAR),''),
			wco.buy_volume_frequency = NULLIF(tco.volume_frequency_buy, ''),
			wco.buy_uom = NULLIF(tco.uom_buy, ''),
			wco.buy_term_start = tco.term_start_buy,
			wco.buy_term_end = tco.term_end_buy,
			wco.block_definition = NULLIF(tco.block_definition,''),
			wco.sell = tco.sell,
			wco.sell_index = NULLIF(tco.market_index_sell, ''),
			wco.sell_price = NULLIF(CAST(tco.price_sell AS VARCHAR),''),
			wco.sell_pricing_index = NULLIF(tco.pricing_index_sell, ''),
			wco.sell_currency = NULLIF(tco.currency_sell, ''),
			wco.sell_volume = NULLIF(CAST(tco.volume_sell AS VARCHAR),''),
			wco.sell_volume_frequency = NULLIF(tco.volume_frequency_sell, ''),
			wco.sell_uom = tco.uom_sell,
			wco.sell_term_start = NULLIF(tco.term_start_sell,''),
			wco.sell_term_end = NULLIF(tco.term_end_sell,''),
			wco.sub_book_id = NULLIF(tco.sub_book_id,''),
			wco.template_id = NULLIF(tco.template_id,'')
		FROM portfolio_mapping_other wco
		INNER JOIN #temp_criteria_others tco ON wco.portfolio_mapping_other_id = tco.whatif_criteria_other_id

		INSERT INTO portfolio_mapping_other
		(
			counterparty,
			buy,
			buy_index,
			buy_price,
			buy_currency,
			buy_volume,
			buy_volume_frequency,
			buy_uom,
			buy_term_start,
			buy_term_end,
			block_definition,
			sell,
			sell_index,
			sell_price,
			sell_currency,
			sell_volume,
			sell_volume_frequency,
			sell_uom,
			sell_term_start,
			sell_term_end,
			portfolio_mapping_source_id,
			sub_book_id,
			template_id,
			buy_pricing_index,
			sell_pricing_index
		)
		SELECT	counterparty,
				buy,
				NULLIF(market_index_buy, ''),
				NULLIF(CAST(price_buy AS FLOAT),''),
				NULLIF(currency_buy, ''),
				NULLIF(CAST(volume_buy AS FLOAT),''),
				NULLIF(volume_frequency_buy, ''),
				NULLIF(uom_buy, ''),
				term_start_buy,
				term_end_buy,
				NULLIF(block_definition,''),
				sell,
				market_index_sell,
				NULLIF(CAST(price_sell AS FLOAT),''),				
				NULLIF(currency_sell, ''),
				NULLIF(CAST(volume_sell AS FLOAT),''),
				NULLIF(volume_frequency_sell, ''),
				uom_sell,
				NULLIF(term_start_sell,''),
				NULLIF(term_end_sell,''),
				pms.portfolio_mapping_source_id,
				NULLIF(sub_book_id, ''),
				NULLIF(template_id, ''),
				NULLIF(pricing_index_buy, ''),
				NULLIF(pricing_index_sell, '')
		FROM #temp_criteria_others tco
			LEFT JOIN portfolio_mapping_source pms
				ON pms.mapping_source_value_id = @portfolio_mapping_source
					AND mapping_source_usage_id = @criteria_id
		WHERE whatif_criteria_other_id = NULL 
			OR whatif_criteria_other_id = 0

		IF EXISTS (SELECT 1 FROM #temp_criteria_others WHERE whatif_criteria_other_id = NULL OR whatif_criteria_other_id = 0)
			SET @new_id = SCOPE_IDENTITY()
		ELSE
			SET @new_id = (SELECT TOP(1) whatif_criteria_other_id FROM #temp_criteria_others) 		
		
		INSERT INTO #total_volume (buy_total_volume, sell_total_volume)
		EXEC spa_update_total_volume_hypo @new_id, 1	
		
		DECLARE @return_value VARCHAR(100)

		SELECT @return_value = CAST(@new_id AS VARCHAR(10)) + ',' + ISNULL(CAST(CAST(buy_total_volume AS NUMERIC(38,2)) AS VARCHAR(50)), '') +  ','  + 
										ISNULL(CAST(CAST(sell_total_volume AS NUMERIC(38,2)) AS VARCHAR(50)), '')
		FROM #total_volume

		COMMIT
		EXEC spa_ErrorHandler 0
				, 'whatif_criteria_other'
				, 'spa_maintain_criteria_dhx'
				, 'Success'
				, 'Changes have been saved successfully.'
				, @return_value
    END TRY
    BEGIN CATCH
		IF @@TRANCOUNT > 0
		   ROLLBACK
	 
		EXEC spa_ErrorHandler -1
			, 'whatif_criteria_other'
			, 'spa_maintain_criteria_dhx'
			, 'Error'
			, 'Failed to save.'
			, ''
	END CATCH
END