---- =============================================================================================================================
---- Author: lhnepal@pioneersolutionsglobal.com
---- Create date: 2015-11-24
---- Description: Generic SP to insert/update values in the table monte_carlo_model_parameter
 
---- Params:
---- @flag CHAR(1)        -  flag 
----						- 'i' - Insert Data 
----						- 'd' - delete data
---- @xml  VARCHAR(MAX) - @xml string of the Data to be inserted/updated

-- Sample Use = EXEC spa_risk_factor_model 'i',''<Root><PSRecordset user_login_id="test_test" user_pwd="asdasdasd" user_f_name="asd" user_m_name="asd" user_l_name="asd" user_title="asd" entity_id="300797" user_address1="asd" user_address2="asd" state_value_id="300797" user_off_tel="asd" user_main_tel="asd" user_pager_tel="asd" user_mobile_tel="asd" user_emal_add="asd" region_id="1" user_active="0" reports_to="" timezone_id=""  ></PSRecordset></Root>'
-- =============================================================================================================================

IF EXISTS (SELECT * FROM sys.objects WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[spa_risk_factor_model]') AND TYPE IN (N'P', N'PC'))
  DROP PROCEDURE [dbo].[spa_risk_factor_model]
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[spa_risk_factor_model] 
	@flag CHAR(1),
	@xml VARCHAR(max) = NULL,
	@monte_carlo_model_parameter_name AS VARCHAR(100) = NULL,
	@monte_carlo_model_parameter_id AS INT = NULL,
	@volatility AS VARCHAR(40) = NULL,
	@drift AS VARCHAR(40) = NULL,
	@data_series  AS INT = NULL,
	@curve_source  AS INT = NULL,
	@mean_reversion_type AS CHAR = NULL,
	@mean_reversion_rate AS VARCHAR(40) = NULL,
	@mean_reversion_level AS VARCHAR(40) = NULL,
	@seed AS varchar(40) = NULL,
	@apply_mean_reversion AS CHAR = NULL,
	@lambda AS FLOAT = NULL,
	@volatility_method AS CHAR = NULL,
	@vol_data_series AS INT = NULL,
	@vol_data_points  AS INT = NULL,
	@vol_long_run_volatility AS FLOAT = NULL,
	@vol_alpha AS FLOAT = NULL,
	@vol_beta AS FLOAT = NULL,
	@vol_gamma AS FLOAT = NULL,
	@relative_volatility AS CHAR = NULL,
	@volatility_source AS INT = NULL,
	@curve_ids AS VARCHAR(MAX) = NULL,
	@type_id INT = NULL, -- static data type id for data series
	--for multiple delete
	@del_monte_carlo_model_parameter_id VARCHAR(MAX) = NULL
AS

/***************************************************************************************
DECLARE	@flag CHAR(1),
		@xml VARCHAR(max) = NULL,
		@monte_carlo_model_parameter_name AS VARCHAR(100) = NULL,
		@monte_carlo_model_parameter_id AS INT = NULL,
		@volatility AS VARCHAR(40) = NULL,
		@drift AS VARCHAR(40) = NULL,
		@data_series  AS INT = NULL,
		@curve_source  AS INT = NULL,
		@mean_reversion_type AS CHAR = NULL,
		@mean_reversion_rate AS VARCHAR(40) = NULL,
		@mean_reversion_level AS VARCHAR(40) = NULL,
		@seed AS varchar(40) = NULL,
		@apply_mean_reversion AS CHAR = NULL,
		@lambda AS FLOAT = NULL,
		@volatility_method AS CHAR = NULL,
		@vol_data_series AS INT = NULL,
		@vol_data_points  AS INT = NULL,
		@vol_long_run_volatility AS FLOAT = NULL,
		@vol_alpha AS FLOAT = NULL,
		@vol_beta AS FLOAT = NULL,
		@vol_gamma AS FLOAT = NULL,
		@relative_volatility AS CHAR = NULL,
		@volatility_source AS INT = NULL,
		@curve_ids AS VARCHAR(MAX) = NULL,
		@type_id INT = NULL 

SET @flag='u'
SET @xml='<Root function_id="10183000"><FormXML monte_carlo_model_parameter_name="12345" data_series="1563" curve_source="4500" volatility_source="10639" monte_carlo_model_parameter_id="93" volatility="e" drift="e" seed="e" apply_mean_reversion="n" mean_reversion_type="a" vol_data_series="1563" vol_long_run_volatility="1" lambda="0" vol_data_points="30" vol_alpha="1" volatility_method="g" vol_beta="1" relative="y" vol_gamma="1"></FormXML></Root>'
--**************************************************************************************/

  SET NOCOUNT ON
  DECLARE @sql VARCHAR(8000),
          @idoc INT

IF @flag IN ('i', 'u')
BEGIN TRY
BEGIN TRAN
	EXEC sp_xml_preparedocument @idoc OUTPUT, @xml

	IF OBJECT_ID('tempdb..#temp_monte_carlo_model_parameter') IS NOT NULL
		DROP TABLE #temp_monte_carlo_model_parameter

	SELECT
		monte_carlo_model_parameter_name [monte_carlo_model_parameter_name],
		monte_carlo_model_parameter_id [monte_carlo_model_parameter_id],
		volatility [volatility],
		drift [drift],
		data_series [data_series],
		curve_source [curve_source],
		mean_reversion_type [mean_reversion_type],
		mean_reversion_rate [mean_reversion_rate],
		mean_reversion_level [mean_reversion_level],
		seed [seed],
		apply_mean_reversion [apply_mean_reversion],
		CASE lambda WHEN '' THEN NULL WHEN 'null' THEN NULL ELSE lambda END [lambda],
		volatility_method [volatility_method],
		vol_data_series [vol_data_series],
		vol_data_points [vol_data_points],
		CASE vol_long_run_volatility WHEN '' THEN NULL WHEN 'null' THEN NULL ELSE vol_long_run_volatility END [vol_long_run_volatility],
		CASE vol_alpha WHEN '' THEN NULL WHEN 'null' THEN NULL ELSE vol_alpha END [vol_alpha],
		CASE vol_beta WHEN '' THEN NULL WHEN 'null' THEN NULL ELSE vol_beta END [vol_beta],
		CASE vol_gamma WHEN '' THEN NULL WHEN 'null' THEN NULL ELSE vol_gamma END [vol_gamma],
		relative_volatility [relative_volatility],
		volatility_source [volatility_source]
		INTO #temp_monte_carlo_model_parameter
	FROM OPENXML(@idoc, '/Root/FormXML', 1)
	WITH (
		monte_carlo_model_parameter_name VARCHAR (80),
		monte_carlo_model_parameter_id INT,
		volatility VARCHAR(40),
		drift VARCHAR(40),
		data_series INT,
		curve_source  INT,
		mean_reversion_type CHAR,
		mean_reversion_rate VARCHAR(40),
		mean_reversion_level VARCHAR(40),
		seed VARCHAR(40),
		apply_mean_reversion CHAR,
		lambda VARCHAR(100),
		volatility_method CHAR,
		vol_data_series INT,
		vol_data_points  INT,
		vol_long_run_volatility VARCHAR(100),
		vol_alpha VARCHAR(100),
		vol_beta VARCHAR(100),
		vol_gamma VARCHAR(100),
		relative_volatility CHAR,
		volatility_source INT
	)
	IF @flag = 'i'
		BEGIN
			IF NOT EXISTS (SELECT 1 FROM monte_carlo_model_parameter mcmp 
								INNER JOIN #temp_monte_carlo_model_parameter temp ON mcmp.monte_carlo_model_parameter_name = temp.monte_carlo_model_parameter_name)
			BEGIN
				INSERT INTO monte_carlo_model_parameter 
					(monte_carlo_model_parameter_name,
					volatility,
					drift,
					data_series,
					curve_source,
					mean_reversion_type,
					mean_reversion_rate,
					mean_reversion_level,
					seed,
					apply_mean_reversion,
					lambda,
					volatility_method,
					vol_data_series,
					vol_data_points,
					vol_long_run_volatility,
					vol_alpha,
					vol_beta,
					vol_gamma,
					relative_volatility,
					volatility_source)
				SELECT
					monte_carlo_model_parameter_name,
					volatility,
					drift,
					data_series,
					curve_source,
					mean_reversion_type,
					mean_reversion_rate,
					mean_reversion_level,
					seed,
					apply_mean_reversion,
					CASE lambda WHEN '' THEN NULL ELSE lambda END,
					volatility_method,
					vol_data_series,
					vol_data_points,
					CASE vol_long_run_volatility WHEN '' THEN NULL  ELSE vol_long_run_volatility END,
					CASE vol_alpha WHEN '' THEN NULL ELSE vol_alpha END,
					CASE vol_beta WHEN '' THEN NULL  ELSE vol_beta END,
					CASE vol_gamma WHEN '' THEN NULL  ELSE vol_gamma END,
					relative_volatility,
					volatility_source
				FROM #temp_monte_carlo_model_parameter		

				DECLARE @recommendation_return VARCHAR(2000) = SCOPE_IDENTITY()

				EXEC spa_ErrorHandler 0,
				'Risk Factor Insert.',
				'spa_risk_factor_model',
				'Success',
				'Changes have been saved successfully.',
				@recommendation_return
			END
			ELSE
			BEGIN
				IF @@TRANCOUNT > 0
					ROLLBACK

				EXEC spa_ErrorHandler 1, 
				'Limit Header', 
				'spa_limit_header', 
				'DB Error', 
				'Duplicate data in <b>Name</b>.',
				''
			END
		END
		ELSE IF @flag = 'u'
		BEGIN
			DECLARE @risk_factor_model_name VARCHAR(100)
			SELECT @monte_carlo_model_parameter_id = monte_carlo_model_parameter_id, @risk_factor_model_name = monte_carlo_model_parameter_name FROM #temp_monte_carlo_model_parameter
			

			IF NOT EXISTS (SELECT 1 FROM monte_carlo_model_parameter mcmp 
									INNER JOIN #temp_monte_carlo_model_parameter temp ON mcmp.monte_carlo_model_parameter_name = temp.monte_carlo_model_parameter_name 
									AND mcmp.monte_carlo_model_parameter_id <> @monte_carlo_model_parameter_id)
			BEGIN
				UPDATE m
				SET monte_carlo_model_parameter_name = t.monte_carlo_model_parameter_name,
					volatility = t.volatility,
					drift = t.drift,
					data_series = t.data_series,
					curve_source = t.curve_source,
					mean_reversion_type = t.mean_reversion_type,
					mean_reversion_rate = t.mean_reversion_rate,
					mean_reversion_level = t.mean_reversion_level,
					seed = t.seed,
					apply_mean_reversion = t.apply_mean_reversion,
					lambda = t.lambda,
					volatility_method = t.volatility_method,
					vol_data_series = t.vol_data_series,
					vol_data_points = t.vol_data_points,
					vol_long_run_volatility = t.vol_long_run_volatility,
					vol_alpha = t.vol_alpha,
					vol_beta = t.vol_beta,
					vol_gamma = t.vol_gamma,
					relative_volatility = t.relative_volatility,
					volatility_source = t.volatility_source
				FROM #temp_monte_carlo_model_parameter AS t
				INNER JOIN monte_carlo_model_parameter m ON m.monte_carlo_model_parameter_id=t.monte_carlo_model_parameter_id
				
				EXEC spa_ErrorHandler 0,
				'Risk Factor Update.',
				'spa_risk_factor_model',
				'Success',
				'Changes have been saved successfully.',
				''
			END
			ELSE
			BEGIN
				IF @@TRANCOUNT > 0
					ROLLBACK

				SET @risk_factor_model_name = 'Risk Factor Model <b>' + @risk_factor_model_name + '</b> already exists.'
				EXEC spa_ErrorHandler -1,
				'Risk Factor Update.',
				'spa_risk_factor_model',
				'DB Error',
				@risk_factor_model_name,
				''
			END
		END
		COMMIT TRAN
END TRY
BEGIN CATCH
	IF @@TRANCOUNT > 0
			ROLLBACK

	EXEC spa_ErrorHandler 1, 
	'Limit Header', 
	'spa_limit_header', 
	'DB Error', 
	'Failed to save data.',
	''
END CATCH --ends @flag IN ('i', 'u') block

IF @flag = 'd' -- delete row from monte_carlo_model_parameter
BEGIN
	BEGIN TRY
		DELETE mcmp
		FROM monte_carlo_model_parameter mcmp
		INNER JOIN dbo.FNASplit(@del_monte_carlo_model_parameter_id, ',') a
			ON a.item = mcmp.monte_carlo_model_parameter_id

		EXEC spa_ErrorHandler 0,
		'Risk Factor Delete.',
		'spa_risk_factor_model',
		'Success',
		'Changes have been saved successfully.',
		@del_monte_carlo_model_parameter_id
	END TRY
	BEGIN CATCH
		EXEC spa_ErrorHandler -1,
		'Risk Factor Delete.',
		'spa_risk_factor_model',
		'DB Error',
		'Failed to delete Risk Factor Model. Price Curve(s) are entered for this Risk Factor Model.',
		''
	END CATCH
END
IF @flag = 'g' --saves comma separated curve ids dbo.splitCommaSeperatedValues(@curve_ids)
BEGIN
	BEGIN TRY
		UPDATE spcd
		SET monte_carlo_model_parameter_id = @monte_carlo_model_parameter_id
		FROM source_price_curve_def spcd
		INNER JOIN dbo.splitCommaSeperatedValues(@curve_ids) scsv ON spcd.source_curve_def_id = scsv.item
		
		EXEC spa_ErrorHandler 0,
			'Curve ID Save.',
			'spa_risk_factor_model',
			'Success',
			'Changes have been saved successfully.',
			''
	END TRY
	BEGIN CATCH
		EXEC spa_ErrorHandler -1,
		'Curve ID Save.',
		'spa_risk_factor_model',
		'DB Error',
		'Fail to save Curves.',
		''
	END CATCH
END
IF @flag = 'r' --removes courve ids from model parameter
BEGIN
	BEGIN TRY
		UPDATE spcd
		SET monte_carlo_model_parameter_id = NULL
		FROM source_price_curve_def spcd
		INNER JOIN dbo.splitCommaSeperatedValues(@curve_ids) scsv ON spcd.source_curve_def_id = scsv.item

		EXEC spa_ErrorHandler 0,
			'Curve ID Delete.',
			'spa_risk_factor_model',
			'Success',
			'Changes have been saved successfully.',
			''
	END TRY
	BEGIN CATCH	
		EXEC spa_ErrorHandler -1,
		'Curve ID Delete.',
		'spa_risk_factor_model',
		'DB Error',
		'Fail to Delete Curves.',
		''
	END CATCH
END