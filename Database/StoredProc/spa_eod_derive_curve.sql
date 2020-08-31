
IF EXISTS (SELECT * FROM   sys.objects WHERE  OBJECT_ID = OBJECT_ID(N'[dbo].[spa_eod_derive_curve]')AND TYPE IN (N'P', N'PC'))
    DROP PROCEDURE [dbo].[spa_eod_derive_curve]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- ============================================================================================================================
-- Author: Pawan Adhikari
-- Create date: 2012-03-09 08:45PM
-- Description: Calculate Derived Prices.
--              
-- Params:
-- ============================================================================================================================
CREATE PROC [dbo].[spa_eod_derive_curve]
AS
BEGIN
	BEGIN TRY

	DECLARE @as_of_date DATETIME
	SET @as_of_date = CONVERT(VARCHAR(10), GETDATE(), 120)

	--MAKE SURE TO CHANGE THE from_curve_id in PROD   145, 97, 113, 131
	CREATE TABLE #convert_curves_to_eur_mwh (from_curve_id INT, to_curve_id INT, fx_curve_id INT, fx_type VARCHAR(1) COLLATE DATABASE_DEFAULT)
	INSERT INTO #convert_curves_to_eur_mwh SELECT 145, 355, 83, 'd' -- vG-ZBR-DowJones-D(EUR/MWH)
	INSERT INTO #convert_curves_to_eur_mwh SELECT 97, 352, 105, 'm' -- vG-ZBR-Forward(EUR/MWH)
	INSERT INTO #convert_curves_to_eur_mwh SELECT 113, 353, 105, 'm' -- G-ZBR-Forward-Monthly only(EUR/MWH)
	INSERT INTO #convert_curves_to_eur_mwh SELECT 131, 354, 105, 'm' -- G-ZBR-Forward BOM Monthly(EUR/MWH)

	--TH TO MWh conversion
	DECLARE @cf FLOAT
	SELECT @cf = conversion_factor
	FROM   rec_volume_unit_conversion
	WHERE  from_source_uom_id = 16
	       AND to_source_uom_id = 1
	
	SELECT c.to_curve_id source_curve_def_id,
	       s.as_of_date,
	       s.Assessment_curve_type_value_id,
	       s.curve_source_value_id,
	       s.maturity_date,
	       s.curve_value / (@cf * 100 * fx.curve_value) curve_value,
	       s.bid_value / (@cf * 100 * fx.curve_value) bid_value,
	       s.ask_value / (@cf * 100 * fx.curve_value) ask_value,
	       s.is_dst 
	INTO #gas_prices_in_eur_mwh
	FROM   #convert_curves_to_eur_mwh c
	INNER JOIN source_price_curve s ON  s.source_curve_def_id = c.from_curve_id
	INNER JOIN source_price_curve fx ON  fx.source_curve_def_id = c.fx_curve_id
		AND fx.as_of_date = s.as_of_date
		AND s.curve_source_value_id = fx.curve_source_value_id
		AND fx.maturity_date = CASE WHEN (c.fx_type = 'd') 
									THEN @as_of_date 
									ELSE CAST(CONVERT(VARCHAR(8), s.maturity_date, 120)+ '01' AS DATETIME)
							   END
	WHERE  s.as_of_date = @as_of_date AND s.curve_source_value_id = 4500
 

	DELETE FROM source_price_curve
	FROM source_price_curve s
	INNER JOIN #gas_prices_in_eur_mwh c ON  s.source_curve_def_id = c.source_curve_def_id
	    AND s.as_of_date = c.as_of_date
	    AND s.maturity_date = s.maturity_date
	    AND s.Assessment_curve_type_value_id = c.Assessment_curve_type_value_id
							
	INSERT INTO source_price_curve
	  (
	    source_curve_def_id,
	    as_of_date,
	    Assessment_curve_type_value_id,
	    curve_source_value_id,
	    maturity_date,
	    curve_value,
	    bid_value,
	    ask_value,
	    is_dst
	  )
	SELECT * FROM #gas_prices_in_eur_mwh
	
	EXEC spa_ErrorHandler 0
				, 'Derived Curve'
				, 'spa_eod_derive_curve'
				, 'Success' 
				, 'Derived Curve Successfully.'
				, ''
		
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
			ROLLBACK
	 
		EXEC spa_ErrorHandler -1
			, 'Derived Curve'
			, 'spa_eod_derive_curve'
			, 'Error'
			, 'Derived Curve Failed'
			, ''
	END CATCH						
END

GO


