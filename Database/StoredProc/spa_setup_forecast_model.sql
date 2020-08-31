IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_setup_forecast_model]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[spa_setup_forecast_model]
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- spa_forecast_parameters_mapping @flag ='i',@call_from = 'ssis',@error_msg = 'this', @acknowledge = 'A',@process_id = '123123'

CREATE PROCEDURE [dbo].[spa_setup_forecast_model]
	@flag CHAR(1),
	@forecast_model_id INT = NULL,
	@xml_data xml = null
	

AS 

SET NOCOUNT ON;

DECLARE @idoc INT
DECLARE @n_forecast_model_id INT

IF @flag = 's'
BEGIN
	SELECT	sdv.code [forecast_type],
			forecast_model_name [model_name],
			forecast_model_id [Model ID],
			sdv1.code [Forecast Category],
			sdv2.code [Forecast Granuality],
			CASE WHEN active = 'y' THEN 'Yes' ELSE 'No' END
	 FROM forecast_model fm
	 INNER JOIN static_data_value sdv ON sdv.value_id = fm.forecast_type
	 INNER JOIN static_data_value sdv1 ON sdv1.value_id = fm.forecast_category
	 INNER JOIN static_data_value sdv2 ON sdv2.value_id = fm.forecast_granularity
END

ELSE IF @flag = 'i'
BEGIN
	BEGIN TRY
		EXEC sp_xml_preparedocument @idoc OUTPUT, @xml_data

		IF OBJECT_ID('tempdb..#tmp_forecast_model') IS NOT NULL
			DROP TABLE #tmp_forecast_model
		
		SELECT	forecast_model_id		[forecast_model_id],
				forecast_model_name		[forecast_model_name],
				forecast_type			[forecast_type],
				forecast_category		[forecast_category],
				forecast_granularity	[forecast_granularity],
				threshold				[threshold],
				maximum_step			[maximum_step],
				learning_rate			[learning_rate],
				repetition				[repetition],
				hidden_layer			[hidden_layer],
				[algorithm]				[algorithm],
				error_function			[error_function],
				active                  [active],
				sequential_forecast     [sequential_forecast],
				time_series             [time_series]
		INTO #tmp_forecast_model
		FROM OPENXML(@idoc, '/Root/ForecastModel', 1)
		WITH (
				forecast_model_id		INT,
				forecast_model_name		VARCHAR(300),
				forecast_type			INT,
				forecast_category		INT,
				forecast_granularity	INT,
				threshold				VARCHAR(300),
				maximum_step			VARCHAR(300),
				learning_rate			VARCHAR(300),
				repetition				VARCHAR(300),
				hidden_layer			VARCHAR(300),
				[algorithm]				VARCHAR(300),
				error_function			VARCHAR(300),
				active					CHAR,
				sequential_forecast     CHAR,
				time_series             INT 
		)

		IF OBJECT_ID('tempdb..#tmp_parameters') IS NOT NULL
			DROP TABLE #tmp_parameters
	
		SELECT	id			[id],
				series_type	[series_type],
				series		[series],
				output_series [output_series],
				formula		[formula],
				use_in_model [use_in_model],
				s_order		 [s_order]
		INTO #tmp_parameters
		FROM OPENXML(@idoc, '/Root/ParameterGrid', 1)
		WITH (
				id			INT,
				series_type	INT,
				series		INT,
				output_series INT,
				formula		INT,
				use_in_model INT,
				s_order		INT
		)

		INSERT INTO forecast_model (
			forecast_model_name,
			forecast_type,
			forecast_category,
			forecast_granularity,
			threshold,
			maximum_step,
			learning_rate,
			repetition,
			hidden_layer,
			[algorithm],
			error_function,
			active,
			sequential_forecast,
			time_series
		)
		SELECT	tmp.forecast_model_name,
				tmp.forecast_type,
				tmp.forecast_category,
				tmp.forecast_granularity,
				tmp.threshold,
				tmp.maximum_step,
				tmp.learning_rate,
				tmp.repetition,
				tmp.hidden_layer,
				tmp.[algorithm],
				tmp.error_function,
				tmp.active,
				tmp.sequential_forecast,
				nullif(tmp.time_series, '')
		FROM #tmp_forecast_model tmp
		LEFT JOIN forecast_model fm ON tmp.forecast_model_id = fm.forecast_model_id
		WHERE fm.forecast_model_id IS NULL

		IF EXISTS (SELECT 1 FROM #tmp_forecast_model WHERE forecast_model_id = 0)
			SET @n_forecast_model_id = SCOPE_IDENTITY()
		ELSE
			SELECT @n_forecast_model_id = forecast_model_id FROM #tmp_forecast_model
	
		UPDATE fm
		SET fm.forecast_model_name = tmp.forecast_model_name,
			fm.forecast_type = tmp.forecast_type,
			fm.forecast_category = tmp.forecast_category,
			fm.forecast_granularity = tmp.forecast_granularity,
			fm.threshold = tmp.threshold,
			fm.maximum_step = tmp.maximum_step,
			fm.learning_rate = tmp.learning_rate,
			fm.repetition = tmp.repetition,
			fm.hidden_layer = tmp.hidden_layer,
			fm.[algorithm] = tmp.[algorithm],
			fm.error_function = tmp.error_function,
			fm.active = tmp.active,
			fm.sequential_forecast = tmp.sequential_forecast,
			fm.time_series = nullif(tmp.time_series, '')
		FROM #tmp_forecast_model tmp
		INNER JOIN forecast_model fm ON tmp.forecast_model_id = fm.forecast_model_id

		DELETE fmi
		FROM forecast_model_input fmi
		LEFT JOIN #tmp_parameters tmp ON tmp.id = fmi.forecast_model_input_id
		WHERE tmp.id IS NULL AND fmi.forecast_model_id = @forecast_model_id

		INSERT INTO forecast_model_input (
				forecast_model_id, 
				series_type,
				series,
				output_series,
				formula,
				use_in_model,
				s_order
		)
		SELECT	@n_forecast_model_id, 
				tmp.series_type,
				NULLIF(tmp.series, 0),
				NULLIF(tmp.output_series, 0),
				NULLIF(tmp.formula, 0),
				tmp.use_in_model,
				tmp.s_order
		FROM #tmp_parameters tmp
		LEFT JOIN forecast_model_input fmi ON tmp.id = fmi.forecast_model_input_id
		WHERE fmi.forecast_model_input_id IS NULL

		UPDATE fmi
		SET fmi.series_type = tmp.series_type,
			fmi.series = NULLIF(tmp.series, 0),
			fmi.output_series = NULLIF(tmp.output_series, 0),
			fmi.formula = NULLIF(tmp.formula, 0),
			fmi.use_in_model = tmp.use_in_model,
			fmi.s_order = tmp.s_order
		FROM #tmp_parameters tmp
		INNER JOIN forecast_model_input fmi ON tmp.id = fmi.forecast_model_input_id

		EXEC spa_ErrorHandler 0,
             'Setup Forecast Model',
             'spa_setup_forecast_model',
             'Success',
             'Forecast model has been successfully saved.',
             @n_forecast_model_id
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
		   ROLLBACK

		DECLARE @desc VARCHAR(1024)
		SET @desc = dbo.FNAHandleDBError(10167300)  
		EXEC spa_ErrorHandler -1, 'spa_setup_forecast_model', 'spa_setup_forecast_model', 'Error', @desc, ''

	END CATCH
END

ELSE IF @flag = 'p'
BEGIN
	SELECT	forecast_model_input_id,
			series_type,
			series,
			output_series,
			formula,
			use_in_model,
			s_order
	FROM forecast_model_input 
	WHERE forecast_model_id = @forecast_model_id
	ORDER BY s_order 
END



ELSE IF @flag = 'c'
BEGIN
	DECLARE @new_forecast_model_id INT
	DECLARE @copy_forecast_model_name VARCHAR(500),
			@new_forecast_model_name VARCHAR(300)
		BEGIN TRY	
		SELECT @copy_forecast_model_name = forecast_model_name
		FROM   forecast_model
		WHERE  forecast_model_id = @forecast_model_id

		EXEC [spa_GetUniqueCopyName] @copy_forecast_model_name, 'contract_charge_desc','contract_charge_type', NULL, @new_forecast_model_name OUTPUT
		 
		INSERT INTO forecast_model (
				forecast_model_name,
				forecast_type,
				forecast_category,
				forecast_granularity,
				threshold,
				maximum_step,
				learning_rate,
				repetition,
				hidden_layer,
				algorithm,
				error_function,
				active,
				time_series
				)
			SELECT
				@new_forecast_model_name,
				forecast_type,
				forecast_category,
				forecast_granularity,
				threshold,
				maximum_step,
				learning_rate,
				repetition,
				hidden_layer,
				algorithm,
				error_function,
				'y',
				time_series
		FROM forecast_model
		WHERE forecast_model_id = @forecast_model_id
		
		SET @new_forecast_model_id = SCOPE_IDENTITY()

		INSERT INTO forecast_model_input (
				forecast_model_id, 
				series_type,
				series,
				formula,
				output_series,
				use_in_model,
				s_order
		)
		SELECT	@new_forecast_model_id, 
				series_type,
				series,
				NULLIF(formula, 0),
				output_series,
				use_in_model,
				s_order
		FROM forecast_model_input 
		WHERE forecast_model_id = @forecast_model_id
		
		IF @@ERROR <> 0
			EXEC spa_ErrorHandler -1, 'Forcast Model', 'spa_setup_forecast_model', 'DB Error', 'Error Copying.', ''
			ELSE
			Exec spa_ErrorHandler 0, 'Forcast Model', 'spa_setup_forecast_model', 'Success', 'Changes have been saved successfully.', @new_forecast_model_id
			
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
		   ROLLBACK
		   
		SET @desc = dbo.FNAHandleDBError(10167300)  
		EXEC spa_ErrorHandler -1, 'spa_setup_forecast_model', 'spa_setup_forecast_model', 'Error', @desc, ''
		
	END CATCH
			
END 

ELSE IF @flag = 'z'
BEGIN 
	IF EXISTS(SELECT 1 FROM forecast_mapping 
		WHERE forecast_model_id = @forecast_model_id)
	BEGIN
		select 'true';
	END
	ELSE
	BEGIN
		select 'false';		
	END
END
