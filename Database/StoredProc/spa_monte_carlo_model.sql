IF OBJECT_ID(N'[dbo].[spa_monte_carlo_model]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[spa_monte_carlo_model]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ===========================================================================================================
-- Author: rtuladhar@pioneersolutionsglobal.com  

-- Create date: 2012-03-26
-- Description: select monte carlo models
-- Params:
-- @flag CHAR(1) - Operation flag
-- @id INT - system generated id for model
-- @as_of_date - date 
--EXEC spa_monte_carlo_model 's', NULL, '2012-11-29'
-- ===========================================================================================================
CREATE PROCEDURE [dbo].[spa_monte_carlo_model]
    @flag CHAR(1),
    @monte_carlo_model_parameter_id INT = NULL,
    @as_of_date DATETIME = NULL,
	@xml varchar(max) = NULL    
AS
SET NOCOUNT ON 
DECLARE @sql VARCHAR(8000)

--IF @flag='i'
--BEGIN
--	BEGIN TRY
	
--END
IF @flag = 's'
BEGIN
	SELECT	mcmp.monte_carlo_model_parameter_id AS [ID] 
			, mcmp.monte_carlo_model_parameter_name AS [Name]
			, + CASE WHEN mcmp.volatility = 'e' THEN 'Use Existing'
					WHEN mcmp.volatility = 'c' THEN 'Calculate'
				ELSE mcmp.volatility END AS [Volatility]
			, + CASE WHEN mcmp.drift = 'e' THEN 'Use Existing'
					WHEN mcmp.drift = 'c' THEN 'Calculate'
				ELSE mcmp.drift END AS  [Drift]
			, + CASE WHEN mcmp.seed = 'e' THEN 'Use Most Recent Value'
					WHEN mcmp.seed = 'c' THEN 'Calculate'
				ELSE mcmp.seed END AS  [Seed]
			, data_series.[code] [Data Series]
			, curve_source.code [Curve Source]
			, CASE WHEN mcmp.apply_mean_reversion = 'y' THEN 
				CASE WHEN mcmp.mean_reversion_type = 'a' THEN 'Use Arithmetic Mean Reversion'
					WHEN mcmp.mean_reversion_type = 'g' THEN 'Use Geometric Mean Reversion' 
				ELSE '' END
			ELSE '' END AS [Mean Reversion Type]
			, CASE WHEN mcmp.apply_mean_reversion = 'y' THEN 
				CASE WHEN mcmp.mean_reversion_rate = 'u' THEN 'Use Most Recent Value'
					WHEN mcmp.mean_reversion_rate = 'c' THEN 'Calculate'
				ELSE mcmp.mean_reversion_rate END 
			ELSE '' END AS  [Mean Reversion Rate]
			, CASE WHEN mcmp.apply_mean_reversion = 'y' THEN
				CASE WHEN mcmp.mean_reversion_level = 'u' THEN 'Use Most Recent Value'
						WHEN mcmp.mean_reversion_level = 'c' THEN 'Calculate'
				ELSE mcmp.mean_reversion_level END 
			ELSE '' END AS  [Mean Reversion Level]
			, vs.code AS [Volatility Source]
			--, mcmp.lambda [Lambda]
	FROM monte_carlo_model_parameter mcmp
	INNER JOIN static_data_value curve_source ON  curve_source.value_id = mcmp.curve_source
	INNER JOIN static_data_value data_series ON  data_series.value_id = mcmp.data_series
	LEFT JOIN static_data_value vs ON  vs.value_id = mcmp.volatility_source
	--WHERE CONVERT(DATE, mcmp.create_ts, 110) <= @as_of_date 
	ORDER BY mcmp.monte_carlo_model_parameter_name ASC
END
IF @flag = 'g' --Added For DHTMLX Grid
BEGIN
	SELECT	mcmp.monte_carlo_model_parameter_id AS [ID] 
			, mcmp.monte_carlo_model_parameter_name AS [Name]
			, + CASE WHEN mcmp.volatility = 'e' THEN 'Use Existing'
					WHEN mcmp.volatility = 'c' THEN 'Calculate'
				ELSE mcmp.volatility END AS [Volatility]
			, + CASE WHEN mcmp.drift = 'e' THEN 'Use Existing'
					WHEN mcmp.drift = 'c' THEN 'Calculate'
				ELSE mcmp.drift END AS  [Drift]
			, + CASE WHEN mcmp.seed = 'e' THEN 'Use Most Recent Value'
					WHEN mcmp.seed = 'c' THEN 'Calculate'
				ELSE mcmp.seed END AS  [Seed]
			, data_series.[code] [Data Series]
			, curve_source.code [Curve Source]
			, CASE WHEN mcmp.apply_mean_reversion = 'y' THEN 
				CASE WHEN mcmp.mean_reversion_type = 'a' THEN 'Use Arithmetic Mean Reversion'
					WHEN mcmp.mean_reversion_type = 'g' THEN 'Use Geometric Mean Reversion' 
				ELSE '' END
			ELSE '' END AS [Mean Reversion Type]
			, CASE WHEN mcmp.apply_mean_reversion = 'y' THEN 
				CASE WHEN mcmp.mean_reversion_rate = 'u' THEN 'Use Most Recent Value'
					WHEN mcmp.mean_reversion_rate = 'c' THEN 'Calculate'
				ELSE mcmp.mean_reversion_rate END 
			ELSE '' END AS  [Mean Reversion Rate]
			, CASE WHEN mcmp.apply_mean_reversion = 'y' THEN
				CASE WHEN mcmp.mean_reversion_level = 'u' THEN 'Use Most Recent Value'
						WHEN mcmp.mean_reversion_level = 'c' THEN 'Calculate'
				ELSE mcmp.mean_reversion_level END 
			ELSE '' END AS  [Mean Reversion Level]
			, vs.code AS [Volatility Source]
	FROM monte_carlo_model_parameter mcmp
	INNER JOIN static_data_value curve_source ON  curve_source.value_id = mcmp.curve_source
	INNER JOIN static_data_value data_series ON  data_series.value_id = mcmp.data_series
	LEFT JOIN static_data_value vs ON  vs.value_id = mcmp.volatility_source
END
IF @flag = 'x' --Added for DHTMLX Inner Grid
BEGIN
	SELECT source_curve_def_id AS ID,
			sdv.code AS [Curve Type],
			curve_name AS [Curve Name],
			curve_id AS [Curve ID],
			sdv1.code AS [Granularity]
	FROM source_price_curve_def spcd
	INNER JOIN static_data_value sdv ON spcd.source_curve_type_value_id=sdv.value_id
	INNER JOIN static_data_value sdv1 ON spcd.Granularity=sdv1.value_id
	WHERE  monte_carlo_model_parameter_id IS NOT NULL
	AND monte_carlo_model_parameter_id=CAST(@monte_carlo_model_parameter_id AS VARCHAR (10))
	ORDER BY sdv.code, curve_id, curve_name, sdv1.code ASC
END
IF @flag = 'y' --Added for DHTMLX Curve Grid
BEGIN
	SELECT source_curve_def_id AS ID,
			sdv.code AS [Curve Type],
			curve_name AS [Curve Name],
			curve_id AS [Curve ID],
			sdv1.code AS [Granularity]
	FROM source_price_curve_def spcd
	INNER JOIN static_data_value sdv ON spcd.source_curve_type_value_id=sdv.value_id
	INNER JOIN static_data_value sdv1 ON spcd.Granularity=sdv1.value_id
	WHERE  monte_carlo_model_parameter_id IS NULL 
	ORDER BY sdv.code, curve_id, curve_name, sdv1.code ASC
END
IF @flag = 'f' --Added to fetch data
BEGIN
	SELECT	mcmp.monte_carlo_model_parameter_id
			, mcmp.monte_carlo_model_parameter_name
			, mcmp.monte_carlo_model_parameter_id
			, mcmp.volatility
			, mcmp.volatility_method
			, mcmp.vol_data_series
			, mcmp.vol_data_points
			, case mcmp.vol_long_run_volatility WHEN 0 THEN '' ELSE CAST(mcmp.vol_long_run_volatility AS VARCHAR) END AS [vol_long_run_volatility]
			, case mcmp.vol_alpha WHEN 0 THEN '' ELSE CAST(mcmp.vol_alpha AS VARCHAR) END AS [vol_alpha]
			, case mcmp.vol_beta WHEN 0 THEN '' ELSE CAST(mcmp.vol_beta AS VARCHAR) END AS [vol_beta]
			, case mcmp.vol_gamma WHEN 0 THEN '' ELSE CAST(mcmp.vol_gamma AS VARCHAR) END AS [vol_gamma]
			, mcmp.relative_volatility
			, mcmp.volatility_source
			, mcmp.drift
			, mcmp.seed
			, mcmp.data_series
			, mcmp.curve_source
			, mcmp.lambda
			, mcmp.apply_mean_reversion
			, mcmp.mean_reversion_type
			, mcmp.mean_reversion_rate
			, mcmp.mean_reversion_level
	FROM monte_carlo_model_parameter mcmp
	WHERE mcmp.monte_carlo_model_parameter_id = @monte_carlo_model_parameter_id
END
IF @flag = 'd'
BEGIN
	IF EXISTS (SELECT 1 FROM source_price_curve_def WHERE monte_carlo_model_parameter_id = @monte_carlo_model_parameter_id)
	BEGIN
		EXEC spa_ErrorHandler -1,
			 'monte_carlo_model_parameter',
			 '[spa_monte_carlo_model]',
			 'Error',
			 'Cannot delete Simulation Model as used in Risk Factors.',
			 @monte_carlo_model_parameter_id
	END	
	ELSE 
	BEGIN
		DELETE FROM monte_carlo_model_parameter WHERE monte_carlo_model_parameter_id = @monte_carlo_model_parameter_id
	
		IF @@TRANCOUNT > 0
		EXEC spa_ErrorHandler -1,
			'monte_carlo_model_parameter',
			'[spa_monte_carlo_model]',
			'Error',
			'Monte Carlo Model could not be deleted.',
			@monte_carlo_model_parameter_id
		ELSE
		EXEC spa_ErrorHandler 0,
			'monte_carlo_model_parameter',
			'[spa_monte_carlo_model]',
			'Success',
			'Monte Carlo Model Deleted Successfully.',
			@monte_carlo_model_parameter_id
	END
	
END
IF @flag = 'a'
BEGIN
	SELECT	monte_carlo_model_parameter_name
			,volatility
			,drift
			,seed
			,data_series
			,curve_source
			,mean_reversion_type
			,mean_reversion_rate
			,mean_reversion_level
			,apply_mean_reversion
			,lambda
			,volatility_method
			,vol_data_series
			,vol_data_points
			,vol_long_run_volatility
			,vol_alpha
			,vol_beta
			,vol_gamma
			,relative_volatility
			,volatility_source
	FROM monte_carlo_model_parameter WHERE monte_carlo_model_parameter_id = @monte_carlo_model_parameter_id
END
IF @flag = 'c'
BEGIN
	INSERT INTO monte_carlo_model_parameter (monte_carlo_model_parameter_name, volatility, drift, data_series, mean_reversion_type,
											mean_reversion_rate, mean_reversion_level, create_user, create_ts, update_user,
											update_ts, curve_source, seed, relative_volatility, volatility_source)
	SELECT	mcmp.monte_carlo_model_parameter_name + '_copy', mcmp.volatility,
	        mcmp.drift, mcmp.data_series, mcmp.mean_reversion_type,
	        mcmp.mean_reversion_rate, mcmp.mean_reversion_level,
	        dbo.FNADBUser(), GETDATE(), NULL, NULL, 
	        mcmp.curve_source, mcmp.seed,
	        mcmp.relative_volatility,
			mcmp.volatility_source
	FROM monte_carlo_model_parameter mcmp WHERE mcmp.monte_carlo_model_parameter_id = @monte_carlo_model_parameter_id
	
	IF @@TRANCOUNT > 0
		EXEC spa_ErrorHandler -1,
				 'monte_carlo_model_parameter',
				 '[spa_monte_carlo_model]',
				 'Error',
				 'Monte Carlo Model could not be copied.',
				 @monte_carlo_model_parameter_id
	ELSE
		EXEC spa_ErrorHandler 0,
				 'monte_carlo_model_parameter',
				 '[spa_monte_carlo_model]',
				 'Success',
				 'Monte Carlo Model Copied Successfully.',
				 @monte_carlo_model_parameter_id
END
IF @flag = 'z' --select id and name for drop down purpose
BEGIN
	SELECT mcmp.monte_carlo_model_parameter_id,
	       mcmp.monte_carlo_model_parameter_name
	FROM monte_carlo_model_parameter mcmp
END
GO