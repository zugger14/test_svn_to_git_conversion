-- =============================================================================================================================
-- Author: msingh@pioneersolutionsglobal.com
-- Create date: 2016-03-08
-- Description: Generic SP for insert/update values in the table var_measurement_criteria_detail
 
-- Params:
-- @flag CHAR(1)        -  flag 
--						- 'i' - Insert Data 
--						- 'd' - delete data
-- @form_xml  VARCHAR(MAX) - @form_xml string of the Data to be inserted/updated

---- Sample Use = EXEC spa_risk_measurement_criteria @flag='i',@limit_id=NULL
--					,@form_xml='<Root>
	--						<FormXML  Name="Combined EaR Calculation" Measure="17353" var_approach="1522" Category="" id="15" confidence_interval="1504" holding_period="1" price_curve_source="4500" volatility_source="10639" vol_cor="null" daily_return_data_series="" simulation_days="1000" hold_to_maturity="n" active="y"></FormXML></Root>
	--					</Root> '
--					,@portfolio_xml= '<Root>
--							<MappingXML  sub_book_id="270" deal_ids="34898,34896,34895,34862,34854,34853,34851,34850,34849,34848,34846,34839,34835,34912,34911,34910,34909,34908,34906,34905,34904,34890,34889,34888,34886,34885" trader="133" commodity_id="" deal_type_id="" counterparty_id="" fixed_term="0" term_start="" term_end="" relative_term="0" starting_month="" no_of_month="">
--</MappingXML>
--						</Root>'
-- =============================================================================================================================
IF OBJECT_ID(N'[dbo].[spa_risk_measurement_criteria]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[spa_risk_measurement_criteria]
GO 
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[spa_risk_measurement_criteria]
    @flag							CHAR(1),
    @criteria_id					INT = NULL,
	@form_xml						VARCHAR(MAX) = NULL,
	@portfolio_xml					VARCHAR(MAX) = NULL,
	--for multiple delete
	@del_criteria_id				VARCHAR(MAX) = NULL
AS
SET NOCOUNT ON
DECLARE @SQL VARCHAR(MAX)
	, @portfolio_mapping_source INT
	, @idoc INT

--PRINT 'Process table' + @process_table

--select * from static_data_value where type_id = 23200

SET @portfolio_mapping_source = 23203	-- Risk Measurement portfolio mapping source

IF @flag IN ('i', 'u')
	BEGIN
		BEGIN TRY

		EXEC sp_xml_preparedocument @idoc OUTPUT, @form_xml
		IF OBJECT_ID('tempdb..#temp_risk_measurement_criteria') IS NOT NULL
		DROP TABLE #temp_risk_measurement_criteria

		SELECT
			id,
			name,
			measure,
			var_approach,
			category,
			confidence_interval,
			NULLIF(holding_period, '') holding_period,
			price_curve_source,
			volatility_source,
			NULLIF(vol_cor, 'null') vol_cor,
			hold_to_maturity,
			use_discounted_value,
			active,
			NULLIF(daily_return_data_series, '') daily_return_data_series,
			NULLIF(simulation_days, '') simulation_days,
			use_market_value use_market_value
		INTO #temp_risk_measurement_criteria
		FROM OPENXML(@idoc, '/Root/FormXML', 1)
		WITH (
			id							INT,
			name						VARCHAR(100),
			measure						VARCHAR(100),
			var_approach				VARCHAR(100),
			category					VARCHAR(100),
			confidence_interval			VARCHAR(100),
			holding_period				INT,
			price_curve_source			VARCHAR(100),
			volatility_source			INT,
			vol_cor						VARCHAR(100),
			hold_to_maturity			CHAR(1),
			use_discounted_value		CHAR(1),
			active						CHAR(1),
			daily_return_data_series	VARCHAR(100),
			simulation_days				VARCHAR(100),
			use_market_value			char(1)
		)
		
		BEGIN TRAN
		IF @flag = 'i'
		BEGIN		
			IF NOT EXISTS (SELECT 1 FROM var_measurement_criteria_detail lh INNER JOIN #temp_risk_measurement_criteria temp ON lh.name = temp.name)
			BEGIN
				INSERT INTO var_measurement_criteria_detail(
					name,					
					measure,			
					var_approach,			
					category,				
					confidence_interval,		
					holding_period,			
					price_curve_source,		
					volatility_source,		
					vol_cor,					
					hold_to_maturity,	
					use_discounted_value,			
					active,					
					daily_return_data_series,
					simulation_days,
					use_market_value)
				SELECT
					name,					
					measure,			
					var_approach,			
					category,				
					confidence_interval,		
					NULLIF(holding_period, ''),			
					price_curve_source,		
					volatility_source,		
					vol_cor,					
					hold_to_maturity,	
					use_discounted_value,			
					active,					
					daily_return_data_series,
					simulation_days,
					use_market_value
				FROM #temp_risk_measurement_criteria

				SET @criteria_id = SCOPE_IDENTITY()
				
				EXEC spa_generic_portfolio_mapping_template @flag = @flag, @mapping_source_id = @portfolio_mapping_source, @mapping_source_value_id = @criteria_id, @xml = @portfolio_xml 

				EXEC spa_ErrorHandler 0, 
					'spa_risk_measurement_criteria', 
					'spa_risk_measurement_criteria', 
					'Success', 
					'Changes have been saved successfully.',
					@criteria_id
			END
			ELSE
			BEGIN
				EXEC spa_ErrorHandler 1, 
				'spa_risk_measurement_criteria', 
				'spa_risk_measurement_criteria', 
				'DB Error', 
				'Duplicate data in <b>Name</b>.',
				''
			END
		END
		ELSE IF @flag = 'u'
		BEGIN
			SELECT @criteria_id = id FROM #temp_risk_measurement_criteria

			IF NOT EXISTS (SELECT 1 FROM var_measurement_criteria_detail lh INNER JOIN #temp_risk_measurement_criteria temp ON lh.name = temp.name AND lh.id <> @criteria_id)
			BEGIN
				UPDATE lh
				SET name = t.name,					
					measure = t.measure,			
					var_approach = t.var_approach,			
					category = t.category,				
					confidence_interval = t.confidence_interval,		
					holding_period = NULLIF(t.holding_period, ''),			
					price_curve_source = t.price_curve_source,		
					volatility_source = t.volatility_source,		
					vol_cor = t.vol_cor,					
					hold_to_maturity = t.hold_to_maturity,	
					use_discounted_value = t.use_discounted_value,	
					active = t.active,					
					daily_return_data_series = t.daily_return_data_series,
					simulation_days = t.simulation_days,
					use_market_value = t.use_market_value
				FROM #temp_risk_measurement_criteria AS t
				INNER JOIN var_measurement_criteria_detail lh ON lh.id = t.id
				
				--select @flag,  @portfolio_mapping_source,  @criteria_id,  @portfolio_xml 
				EXEC spa_generic_portfolio_mapping_template @flag = @flag, @mapping_source_id = @portfolio_mapping_source, @mapping_source_value_id = @criteria_id, @xml = @portfolio_xml 

				EXEC spa_ErrorHandler 0, 
					'spa_risk_measurement_criteria', 
					'spa_risk_measurement_criteria', 
					'Success', 
					'Changes have been saved successfully.',
					''
			END
			ELSE
			BEGIN
				EXEC spa_ErrorHandler 1, 
				'spa_risk_measurement_criteria', 
				'spa_risk_measurement_criteria', 
				'DB Error', 
				'Duplicate data in <b>Name</b>.',
				''
			END
		END	-- ends flag u block
		COMMIT
	END TRY
	BEGIN CATCH
		ROLLBACK
		EXEC spa_ErrorHandler 1, 
			'spa_risk_measurement_criteria', 
			'spa_risk_measurement_criteria', 
			'DB Error', 
			'Failed to save data.',
			''
	END CATCH
END --ends @flag IN ('i', 'u') block
ELSE IF @flag = 'd'
BEGIN
	BEGIN TRY
	BEGIN TRAN

		DELETE ltc
		FROM limit_tracking_curve ltc 
		INNER JOIN limit_tracking lt 
			ON lt.limit_id = ltc.limit_id
		INNER JOIN dbo.FNASplit(@del_criteria_id, ',') a
			ON lt.var_crit_det_id = a.item

		DELETE cc
		FROM curve_correlation cc
		INNER JOIN vol_cor_header vch
			ON vch.id = cc.vol_cor_header_id
		INNER JOIN dbo.FNASplit(@del_criteria_id, ',') b
			ON vch.var_criteria_id = b.item

		DELETE cv 
		FROM curve_volatility cv 
		INNER JOIN vol_cor_header vch 
			ON vch.id = cv.vol_cor_header_id
		INNER JOIN dbo.FNASplit(@del_criteria_id, ',') c
			ON vch.var_criteria_id = c.item
	
		DELETE vlc 
		FROM vol_cor_header vlc
		INNER JOIN dbo.FNASplit(@del_criteria_id, ',') d
			ON vlc.var_criteria_id = d.item

		DELETE lt
		FROM limit_tracking lt
		INNER JOIN dbo.FNASplit(@del_criteria_id, ',') e
			ON e.item = lt.var_crit_det_id

		DELETE pms
		FROM portfolio_mapping_source pms
		INNER JOIN dbo.FNASplit(@del_criteria_id, ',') f
			ON pms.mapping_source_usage_id = @criteria_id AND mapping_source_value_id = @portfolio_mapping_source

		DELETE vmcd
		FROM var_measurement_criteria_detail vmcd
		INNER JOIN dbo.FNASplit(@del_criteria_id, ',') g
			ON g.item = vmcd.id
		
	COMMIT
	EXEC spa_ErrorHandler 0, 
		'spa_risk_measurement_criteria', 
		'spa_risk_measurement_criteria', 
		'Success', 
		'Changes have been saved successfully.',
		@del_criteria_id
	END TRY
	BEGIN CATCH
	ROLLBACK
	EXEC spa_ErrorHandler 1, 
		'spa_risk_measurement_criteria', 
		'spa_risk_measurement_criteria', 
		'DB Error', 
		'Failed to delete limit header data.',
		''
	END CATCH
END
