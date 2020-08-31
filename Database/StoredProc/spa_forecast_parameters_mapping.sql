IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_forecast_parameters_mapping]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[spa_forecast_parameters_mapping]
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[spa_forecast_parameters_mapping]
	@flag CHAR(1),
	@forecast_mapping_id INT = NULL,
	@forecast_model_id INT = NULL,
	@xml_data xml = NULL,
	@date_from VARCHAR(20) = NULL,
	@date_to VARCHAR(20) = NULL,
	@status CHAR(1) = NULL,
	@process_id VARCHAR(100) = NULL,
	@forecast_model_id_val INT = NULL,
	@model_id INT = NULL,
	@series_typ CHAR = NUll,

	@del_forecast_mapping_id VARCHAR(MAX) = NULL
AS 
/*
DECLARE 	@flag CHAR(1)='v',
	@forecast_mapping_id INT = 12,
	@forecast_model_id INT = NULL,
	@xml_data xml = NULL,
	@date_from VARCHAR(20) = NULL,
	@date_to VARCHAR(20) = NULL,
	@status CHAR(1) = NULL,
	@process_id VARCHAR(100) = 'B803F4A7_7F2F_4361_B555_68DA911C3A94',
	@forecast_model_id_val INT = NULL,
	@model_id INT = NULL,
	@series_typ CHAR = NUll	*/
SET NOCOUNT ON

DECLARE @idoc INT
DECLARE @n_forecast_mapping_id INT
DECLARE @forecast_type1 INT
DECLARE @output_id INT
DECLARE @source_id INT
DECLARE @assessment_curve_type_value INT
IF @flag = 's'
BEGIN
	SELECT	sdv.code [forecast_type], 
				--sdv.code + ' - ' + fp.profile_name + ' - ' + sdv1.code [name],
				sdv.code + ' - ' + spcd.curve_name + ' - ' + sdv1.code [name],
				fm.forecast_mapping_id [forecast_mapping_id],
				sdv2.code,
				CASE WHEN fm.approval_required = 'y' THEN 'Yes' ELSE 'No' END [approval_required],
				CASE WHEN fm.active = 'y' THEN 'Yes' ELSE 'No' END [active]
		FROM forecast_mapping fm
		INNER JOIN forecast_model fmm ON fm.forecast_model_id = fmm.forecast_model_id
		INNER JOIN static_data_value sdv ON sdv.value_id = fmm.forecast_type
		INNER JOIN static_data_value sdv1 ON sdv1.value_id = fmm.forecast_category
		--INNER JOIN forecast_profile fp ON fp.profile_id = fm.output_id
		INNER JOIN source_price_curve_def spcd ON spcd.source_curve_def_id = fm.output_id
		LEFT JOIN static_data_value sdv2 ON sdv2.value_id = fm.source_id
	UNION ALL 
	SELECT	sdv.code [forecast_type], 
				CASE WHEN sdv.value_id = 43803 AND tsd.time_series_name IS NOT NULL
				THEN
					ISNULL(tsdv.code + ' - ','')  + ISNULL(tsd.time_series_name + ' - ','') + ISNULL(outp.code + ' - ','')  + sdv1.code
				ELSE
					sdv.code + CASE WHEN fp.profile_name IS NOT NULL THEN ' - ' + fp.profile_name + ' - ' ELSE  ' - ' END + sdv1.code 
				END [name],
				fm.forecast_mapping_id [forecast_mapping_id],
				sdv2.code,
				CASE WHEN fm.approval_required = 'y' THEN 'Yes' ELSE 'No' END [approval_required],
				CASE WHEN fm.active = 'y' THEN 'Yes' ELSE 'No' END [active]
		FROM forecast_mapping fm
		INNER JOIN forecast_model fmm ON fm.forecast_model_id = fmm.forecast_model_id
		INNER JOIN static_data_value sdv ON sdv.value_id = fmm.forecast_type
		INNER JOIN static_data_value sdv1 ON sdv1.value_id = fmm.forecast_category and sdv.value_id <> 43802
		LEFT JOIN forecast_profile fp ON fp.profile_id = fm.output_id
		--INNER JOIN source_price_curve_def spcd ON spcd.source_curve_def_id = fm.output_id
		LEFT JOIN static_data_value sdv2 ON sdv2.value_id = fm.source_id
		LEFT JOIN time_series_definition tsd ON tsd.time_series_definition_id = fmm.time_series
		LEFT JOIN static_data_value tsdv ON tsd.time_series_type_value_id = tsdv.value_id 
		LEFT JOIN static_data_value outp ON outp.value_id = fm.output_id
		WHERE sdv.value_id <> 43802
END

ELSE IF @flag = 'i'
BEGIN
	BEGIN TRY
		EXEC sp_xml_preparedocument @idoc OUTPUT, @xml_data

		IF OBJECT_ID('tempdb..#tmp_forecast_mapping') IS NOT NULL
			DROP TABLE #tmp_forecast_mapping
		
		SELECT	forecast_mapping_id		[forecast_mapping_id],
				forecast_model_id		[forecast_model_id],
				output_id				[output_id],
				approval_required		[approval_required],
				source_id				[source_id],
				active                  [active] 
		INTO #tmp_forecast_mapping
		FROM OPENXML(@idoc, '/Root/ForecastMapping', 1)
		WITH (
				forecast_mapping_id		INT,
				forecast_model_id		INT,
				output_id				INT,
				approval_required		CHAR,
				source_id				INT,
				active                  CHAR 
		)

		IF OBJECT_ID('tempdb..#tmp_parameters') IS NOT NULL
			DROP TABLE #tmp_parameters
	
		SELECT	id			[id],
				series		[series],
				input		[input],
				forecast	[forecast],
				forecast_model_input_id [forecast_model_input_id],
				input_function [input_function],
				forecast_function [forecast_function]
		INTO #tmp_parameters
		FROM OPENXML(@idoc, '/Root/ParameterGrid', 1)
		WITH (
				id			INT,
				series		INT,
				input		VARCHAR(100),
				forecast	VARCHAR(100),
				forecast_model_input_id INT,
				input_function INT,
				forecast_function INT 
		)
		
		-- Check Granuality mismatch
		DECLARE @granuality INT --  For output
		DECLARE @granuality2 INT -- For forecast model
		DECLARE @forecast_type INT
		
		SET @forecast_type = (SELECT forecast_type FROM forecast_model fm 
		INNER JOIN #tmp_forecast_mapping tp ON fm.forecast_model_id = tp.forecast_model_id)
		
		IF EXISTS(SELECT tp.output_id FROM #tmp_forecast_mapping tp where tp.output_id <> 0)
		BEGIN 
			IF @forecast_type = 43802 --Price Forecast
			BEGIN
				SET @granuality = (SELECT sdc.Granularity FROM source_price_curve_def sdc
								   INNER JOIN #tmp_forecast_mapping tp ON sdc.source_curve_def_id = tp.output_id)
			END 
			ELSE IF @forecast_type = 43803 --Time Series Forecast
			BEGIN 
				-- No granuality checking so @granuality = @granuality2 [same]
				SET @granuality = (SELECT fm.forecast_granularity FROM forecast_model fm
									INNER JOIN #tmp_forecast_mapping tp ON fm.forecast_model_id = tp.forecast_model_id)
			END
			ELSE 
			BEGIN  -- For Load forecast, Checking from profile
				SET @granuality = (SELECT fp.granularity FROM forecast_profile fp 
									 INNER JOIN #tmp_forecast_mapping tp ON	fp.profile_id = tp.output_id)
			END
		
			SET @granuality2 = (SELECT fm.forecast_granularity FROM forecast_model fm
									INNER JOIN #tmp_forecast_mapping tp ON fm.forecast_model_id = tp.forecast_model_id)
								
			IF @granuality <> @granuality2 OR @granuality IS NULL OR @granuality2 IS NULL
			BEGIN 
				EXEC spa_ErrorHandler -1,
					 'Forecast Parameter Mapping',
					 'spa_forecast_parameter_mapping',
					 'Error',
					 'Mismatch of forecast granularity and output granularity.',
					 ''
				RETURN
			END
		END 
		
		IF OBJECT_ID('tempdb..#tmp_datarange') IS NOT NULL
			DROP TABLE #tmp_datarange
	
		SELECT	id			[id],
				data_type	[data_type],
				value		[value],
				granularity	[granularity]
		INTO #tmp_datarange
		FROM OPENXML(@idoc, '/Root/DataRangeGrid', 1)
		WITH (
				id			INT,
				data_type	INT,
				value		VARCHAR(200),
				granularity	INT
		)

		-- Forecast Mapping
		INSERT INTO forecast_mapping (
			forecast_model_id,
			output_id,
			approval_required,
			source_id,
			active
		)
		SELECT	tmp.forecast_model_id,
				tmp.output_id,
				tmp.approval_required,
				tmp.source_id,
				tmp.active
		FROM #tmp_forecast_mapping tmp
		LEFT JOIN forecast_mapping fm ON tmp.forecast_mapping_id = fm.forecast_mapping_id
		WHERE fm.forecast_mapping_id IS NULL

		IF EXISTS (SELECT 1 FROM #tmp_forecast_mapping WHERE forecast_mapping_id = 0)
			SET @n_forecast_mapping_id = SCOPE_IDENTITY()
		ELSE
			SELECT @n_forecast_mapping_id = forecast_mapping_id FROM #tmp_forecast_mapping
	
		UPDATE fm
		SET fm.forecast_model_id = tmp.forecast_model_id,
			fm.output_id = tmp.output_id,
			fm.approval_required = tmp.approval_required,
			fm.source_id = tmp.source_id,
			fm.active = tmp.active
		FROM #tmp_forecast_mapping tmp
		INNER JOIN forecast_mapping fm ON tmp.forecast_mapping_id = fm.forecast_mapping_id


		-- Forecast Mapping Input
		DELETE fmi
		FROM forecast_mapping_input fmi
		LEFT JOIN #tmp_parameters tmp ON tmp.id = fmi.forecast_mapping_input_id
		WHERE tmp.id IS NULL AND fmi.forecast_mapping_id = @forecast_mapping_id

		INSERT INTO forecast_mapping_input (
				forecast_mapping_id, 
				forecast_model_input_id,
				input,
				forecast,
				input_function,
				forecast_function
		)
		SELECT	@n_forecast_mapping_id, 
				tmp.id,
				tmp.input,
				tmp.forecast,
				tmp.input_function,
				tmp.forecast_function
		FROM #tmp_parameters tmp
		LEFT JOIN forecast_mapping_input fmi ON tmp.id = fmi.forecast_mapping_input_id
		WHERE fmi.forecast_mapping_input_id IS NULL

		UPDATE fmi
		SET fmi.forecast_model_input_id = tmp.id,
			fmi.input = tmp.input,
			fmi.forecast = tmp.forecast,
			fmi.input_function = tmp.input_function,
			fmi.forecast_function = tmp.forecast_function
		FROM #tmp_parameters tmp
		INNER JOIN forecast_mapping_input fmi ON tmp.id = fmi.forecast_mapping_input_id


		-- Forecast Mapping Datarange
		DELETE fmi
		FROM forecast_mapping_datarange fmi
		LEFT JOIN #tmp_datarange tmp ON tmp.id = fmi.forecast_mapping_datarange_id
		WHERE tmp.id IS NULL AND fmi.forecast_mapping_id = @forecast_mapping_id

		INSERT INTO forecast_mapping_datarange(
				forecast_mapping_id, 
				forecast_mapping_data_type,
				value,
				granularity
		)
		SELECT	@n_forecast_mapping_id, 
				NULLIF(tmp.data_type,0),
				NULLIF(tmp.value,0),
				NULLIF(tmp.granularity,0)
		FROM #tmp_datarange tmp
		LEFT JOIN forecast_mapping_datarange fmi ON tmp.id = fmi.forecast_mapping_datarange_id
		WHERE fmi.forecast_mapping_datarange_id IS NULL

		UPDATE fmi
		SET fmi.forecast_mapping_data_type = tmp.data_type,
			fmi.value = NULLIF(tmp.value,0),
			fmi.granularity = tmp.granularity
		FROM #tmp_datarange tmp
		INNER JOIN forecast_mapping_datarange fmi ON tmp.id = fmi.forecast_mapping_datarange_id

		EXEC spa_ErrorHandler 0,
             'Forecast Parameter Mapping',
             'spa_forecast_parameter_mapping',
             'Success',
             'Changes have been saved successfully.',
             @n_forecast_mapping_id
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
		   ROLLBACK
		   
		EXEC spa_ErrorHandler -1,
             'Forecast Parameter Mapping',
             'spa_forecast_parameter_mapping',
             'Error',
             'Failed to save forecast parameter mapping.',
             ''
	END CATCH
END


ELSE IF @flag = 'd'
BEGIN
	BEGIN TRY
		BEGIN TRAN

			DELETE fmd 
			FROM dbo.FNASplit(@del_forecast_mapping_id, ',') a
			INNER JOIN forecast_mapping_datarange fmd
				ON fmd.forecast_mapping_id = a.item

			DELETE fmi
			FROM dbo.FNASplit(@del_forecast_mapping_id, ',') b
			INNER JOIN forecast_mapping_input fmi
				ON fmi.forecast_mapping_id = b.item

			DELETE fm
			FROM dbo.FNASplit(@del_forecast_mapping_id, ',') c
			INNER JOIN forecast_mapping fm
				ON fm.forecast_mapping_id = c.item

		COMMIT TRAN
		EXEC spa_ErrorHandler 0,
				 'Forecast Parameter Mapping',
				 'spa_forecast_parameter_mapping',
				 'Success',
				 'Forecast parameter mapping has been successfully deleted.',
				 @del_forecast_mapping_id

		
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
		   ROLLBACK
		   
		EXEC spa_ErrorHandler -1,
             'Forecast Parameter Mapping',
             'spa_forecast_parameter_mapping',
             'Error',
             'Failed to delete forecast parameter mapping.',
             ''
	END CATCH
END

ELSE IF @flag = 'p'
BEGIN
	SELECT forecast_model_input_id, sdv.code + ' - ' + sdv1.code [series] FROM forecast_model_input fmi
	INNER JOIN static_data_value sdv ON fmi.series_type = sdv.value_id
	INNER JOIN static_data_value sdv1 ON fmi.series = sdv1.value_id
	WHERE fmi.forecast_model_id = @forecast_model_id
END

ELSE IF @flag = 'm'
BEGIN
	IF @status = 'n' -- NO value
	BEGIN
		RETURN
	END
	ELSE IF @status = 'z'
	BEGIN
		IF(@forecast_model_id = 44102) --Holiday , input
		BEGIN 
			SELECT value_id, code FROM static_data_value WHERE TYPE_ID = 10017 AND category_id = 38700
			RETURN
		END
		ELSE IF(@forecast_model_id = 44105) --Peakness , input
		BEGIN 
			SELECT value_id, code FROM static_data_value WHERE TYPE_ID = 10018 ORDER BY  CODE
			RETURN
		END
		ELSE IF (@forecast_model_id = 44004) -- load , input
		BEGIN
			SELECT meter_id, description FROM meter_id
			RETURN
		END
		ELSE IF (@forecast_model_id = 44003) -- price , input
		BEGIN
			SELECT source_curve_def_id, curve_name 
				FROM source_price_curve_def 
			WHERE Forward_Settle = 's'
			RETURN
		END
		ELSE 
		BEGIN
			SELECT DISTINCT time_series_group, sdv.code FROM time_series_data tsd 
			INNER JOIN time_series_definition tsde ON tsde.time_series_definition_id = tsd.time_series_definition_id
			INNER JOIN static_data_value sdv ON sdv.value_id = tsd.time_series_group
				WHERE tsde.time_series_definition_id = @forecast_model_id -- tmp_o
		RETURN
		END
	END 
	ELSE IF (@status = 'x') -- Load, forcast
	BEGIN
		SELECT profile_id, profile_name FROM forecast_profile fp
		INNER JOIN static_data_value sdv ON sdv.value_id = fp.profile_type
		WHERE 1=1 
		RETURN
						
	END
	ELSE IF (@status = 'w') -- price, forecast
	BEGIN
		SELECT source_curve_def_id, curve_name 
			FROM source_price_curve_def 
		WHERE Forward_Settle = 'f'
		RETURN
	END
	ELSE IF (@status = 'm') -- For input and forecast function. 
	BEGIN
		DECLARE @forecast_granularity INT 
		DECLARE @forecast_granularity1 INT
		
		--Forecast model granuality
		SET @forecast_granularity = (SELECT forecast_granularity FROM forecast_model 
										WHERE forecast_model_id = @forecast_model_id) 
        DECLARE @series_type INT
        SET @series_type = (SELECT fmi.series_type FROM forecast_model_input fmi								
								WHERE fmi.forecast_model_input_id = @model_id)
								
		IF(@series_type = 44003) --For Price Forecast 
		BEGIN
			SET @forecast_granularity1 = (SELECT Granularity FROM source_price_curve_def 
								WHERE source_curve_def_id = @forecast_model_id_val)
		END	
		ELSE IF (@series_type = 44004) -- For Load forecast
		BEGIN  
			IF (@series_typ = 'f') -- Check for 'forecast function'.
			BEGIN 
				SET @forecast_granularity1 = (SELECT granularity FROM forecast_profile 
												WHERE profile_id = @forecast_model_id_val)
			END 
			ELSE 
			BEGIN 
				SET @forecast_granularity1 = (SELECT mi.granularity FROM meter_id mi 
									WHERE mi.meter_id = @forecast_model_id_val)
			END	
		END 
		ELSE--For Time Series Forecast
		BEGIN 
			--For time series checking granuality from 'input series' and 'forecast series'.
			DECLARE @id INT 
			SET @id = (SELECT CASE WHEN @series_typ = 'f' THEN output_series ELSE series END FROM forecast_model_input WHERE forecast_model_input_id = @model_id)
			
			SET @forecast_granularity1 = (SELECT granulalrity FROM time_series_definition 
								WHERE time_series_definition_id = @id)
		END
										
		IF (@forecast_granularity = 995) BEGIN SET @forecast_granularity = 1 END 
		ELSE IF (@forecast_granularity = 994) BEGIN SET @forecast_granularity = 2 END 
		ELSE IF (@forecast_granularity = 987) BEGIN SET @forecast_granularity = 3 END 
		ELSE IF (@forecast_granularity = 989) BEGIN SET @forecast_granularity = 4 END 
		ELSE IF (@forecast_granularity = 982) BEGIN SET @forecast_granularity = 5 END 
		ELSE IF (@forecast_granularity = 981) BEGIN SET @forecast_granularity = 6 END 
		ELSE IF (@forecast_granularity = 990) BEGIN SET @forecast_granularity = 7 END 
		ELSE IF (@forecast_granularity = 980) BEGIN SET @forecast_granularity = 8 END 
		ELSE IF (@forecast_granularity = 991) BEGIN SET @forecast_granularity = 9 END
		ELSE IF (@forecast_granularity = 992) BEGIN SET @forecast_granularity = 10 END
		ELSE IF (@forecast_granularity = 993) BEGIN SET @forecast_granularity = 11 END
		
		IF (@forecast_granularity1 = 995) BEGIN SET @forecast_granularity1 = 1 END 
		ELSE IF (@forecast_granularity1 = 994) BEGIN SET @forecast_granularity1 = 2 END 
		ELSE IF (@forecast_granularity1 = 987) BEGIN SET @forecast_granularity1 = 3 END 
		ELSE IF (@forecast_granularity1 = 989) BEGIN SET @forecast_granularity1 = 4 END 
		ELSE IF (@forecast_granularity1 = 982) BEGIN SET @forecast_granularity1 = 5 END 
		ELSE IF (@forecast_granularity1 = 981) BEGIN SET @forecast_granularity1 = 6 END 
		ELSE IF (@forecast_granularity1 = 990) BEGIN SET @forecast_granularity1 = 7 END 
		ELSE IF (@forecast_granularity1 = 980) BEGIN SET @forecast_granularity1 = 8 END 
		ELSE IF (@forecast_granularity1 = 991) BEGIN SET @forecast_granularity1 = 9 END
		ELSE IF (@forecast_granularity1 = 992) BEGIN SET @forecast_granularity1 = 10 END
		ELSE IF (@forecast_granularity1 = 993) BEGIN SET @forecast_granularity1 = 11 END
				
		IF @forecast_granularity <> @forecast_granularity1
		BEGIN 
			IF(@forecast_granularity > @forecast_granularity1) -- Lower Granularity -> Higher 
			BEGIN
				SELECT value_id AS ID, description AS VALUE FROM static_data_value WHERE TYPE_ID = 46400 AND category_id = 1
			END
			ELSE 
			BEGIN 
				SELECT value_id AS ID, description AS VALUE FROM static_data_value WHERE TYPE_ID = 46400 AND category_id = 2 
			END 
		END
		RETURN 
	END                         
	
	IF @status = 'g'
	BEGIN
		SELECT 
		  fmi.forecast_model_input_id,
		  CASE fmi.series_type 
		   WHEN '44004' THEN fmi.series_type -- For load
		   WHEN '44003' THEN fmi.series_type -- For Price
		   WHEN '44105' THEN '44105' -- For Peakness
		   ELSE fmi.series 
		  END series,
		  fmi.output_series,fmi1.input,
		  nullif(fmi1.forecast, 0) forecast,
		  nullif(fmi1.input_function,0) input_function, 
		  nullif(fmi1.forecast_function,0) forecast_function
		  FROM 
		   forecast_model_input fmi   
		   LEFT JOIN forecast_mapping fm ON fm.forecast_model_id = fmi.forecast_model_id AND fm.forecast_mapping_id=@forecast_mapping_id
		   LEFT JOIN forecast_mapping_input fmi1 ON fmi1.forecast_mapping_id = fm.forecast_mapping_id   AND fmi1.forecast_model_input_id = fmi.forecast_model_input_id
		  WHERE
		   fmi.forecast_model_id=@forecast_model_id AND
		   fmi.use_in_model = 1
		ORDER BY fmi.s_order
		RETURN
	END 
	
	SELECT DISTINCT tsd.time_series_definition_id, sdv.code+' - '+tsd.time_series_name [series_type]
	FROM time_series_definition tsd
	INNER JOIN static_data_value sdv ON tsd.time_series_type_value_id = sdv.value_id
	INNER JOIN forecast_model_input fmi ON fmi.series = tsd.time_series_definition_id
		WHERE fmi.forecast_model_id = @forecast_model_id
	UNION 
	SELECT DISTINCT tsd.time_series_definition_id, sdv.code+' - '+tsd.time_series_name [series_type]
		FROM time_series_definition tsd
	INNER JOIN static_data_value sdv ON tsd.time_series_type_value_id = sdv.value_id
	INNER JOIN forecast_model_input fmi ON fmi.output_series = tsd.time_series_definition_id
		WHERE fmi.forecast_model_id = @forecast_model_id 
	UNION      
	SELECT sdv.value_id, sdv.code FROM static_data_value sdv
	INNER JOIN forecast_model_input smi ON smi.series = sdv.value_id
		WHERE sdv.type_id = 44100 AND smi.forecast_model_id = @forecast_model_id   
	UNION 
	SELECT sdv.value_id, sdv.code FROM static_data_value sdv
	INNER JOIN forecast_model_input smi ON smi.series_type = sdv.value_id
		WHERE sdv.type_id = 44000 AND smi.forecast_model_id = @forecast_model_id   
	UNION 
	SELECT VALUE_ID, CODE FROM static_data_value WHERE value_id = 44105 
	
	
END

ELSE IF @flag = 'r'
BEGIN
	SELECT forecast_mapping_datarange_id, forecast_mapping_data_type, value, granularity 
	FROM forecast_mapping_datarange
	WHERE forecast_mapping_id = @forecast_mapping_id
END

ELSE IF @flag = 'f'
BEGIN
	SELECT tsd.time_series_definition_id, sdv.code+' - '+tsd.time_series_name [series_type] 
	INTO #temp_table1
	FROM time_series_definition tsd
	INNER JOIN static_data_value sdv ON tsd.time_series_type_value_id = sdv.value_id 

	SELECT 
		forecast_model_id,
		--sdv.value_id,
		--tbl1.series_type,
		CASE WHEN sdv.value_id = '43803' THEN tbl1.series_type + ' - '
		ELSE sdv.code + ' - ' END + sdv1.code + ' - ' + forecast_model_name [forecast_model]
		
	FROM forecast_model fm
	INNER JOIN static_data_value sdv ON fm.forecast_type = sdv.value_id
	INNER JOIN static_data_value sdv1 ON fm.forecast_category = sdv1.value_id
	LEFT JOIN #temp_table1 tbl1 on tbl1.time_series_definition_id = fm.time_series
	WHERE fm.active = 'y'
END 

ELSE IF @flag = 'c'
BEGIN
	
	IF(@forecast_mapping_id IS NOT NULL)
	BEGIN 
		SELECT output_id FROM forecast_mapping
			WHERE forecast_mapping_id = @forecast_mapping_id
		RETURN
	END
		
	DECLARE @forecast_category INT
	SET @forecast_category = (SELECT sdv.value_id FROM static_data_value sdv 
								INNER JOIN forecast_model fm ON fm.forecast_type = sdv.value_id 
	                          WHERE fm.forecast_model_id = @forecast_model_id_val)
	--SELECT @forecast_category
	IF (@forecast_category = 43802) -- combo price forecast
	BEGIN
		 SELECT source_curve_def_id, curve_name FROM source_price_curve_def
	END
	ELSE IF(@forecast_category = 43801)
	BEGIN 
		SELECT profile_id, profile_name FROM forecast_profile fp
		INNER JOIN static_data_value sdv ON sdv.value_id = fp.profile_type
		WHERE 1=1 
	END 
	ELSE IF (@forecast_category = 43803) -- time series forecast
	BEGIN
		SELECT value_id, code FROM static_data_value WHERE TYPE_ID = 40000
	END
	
END 

ELSE IF @flag = 'z'
BEGIN
	DECLARE @sql NVARCHAR(MAX)
	
	SET @sql = 'SELECT dbo.FNADateTimeFormat(frs.create_ts, 0) [datetime],
					   frs.create_user [user],
					   CASE WHEN frs.is_approved = 0 THEN ''Unapproved'' ELSE ''Approved'' END [status],
					   frs.process_id [process_id],
					   frs.process_id + ''^javascript:run_forecasting.grid_link_click("'' + frs.process_id + ''","'' + CAST(fmo.forecast_granularity AS VARCHAR) + ''")^'' [process_id_link]
				FROM forecast_result_summary frs
				INNER JOIN forecast_mapping fm ON frs.forecast_mapping_id = fm.forecast_mapping_id
				INNER JOIN forecast_model fmo ON fm.forecast_model_id = fmo.forecast_model_id
				WHERE frs.forecast_mapping_id = ' + CAST(@forecast_mapping_id AS VARCHAR(10))
	

	IF NULLIF(@date_from, '') IS NOT NULL
		SET @sql += ' AND CAST(dbo.FNADateTimeFormat(frs.create_ts, 0) AS VARCHAR(10)) >= ''' +  CAST(dbo.FNADateTimeFormat(CONVERT(VARCHAR(10), @date_from, 120), 0) AS VARCHAR(10)) + ''''
	
	IF NULLIF(@date_to, '') IS NOT NULL
		SET @sql += ' AND CAST(dbo.FNADateTimeFormat(frs.create_ts, 0) AS VARCHAR(10)) <= ''' +  CAST(dbo.FNADateTimeFormat(CONVERT(VARCHAR(10), @date_to, 120), 0) AS VARCHAR(10)) + ''''

	IF NULLIF(@status, '') IS NOT NULL
		SET @sql += ' AND frs.is_approved = ' + CAST(CASE WHEN @status = 'a' THEN 1 ELSE 0 END AS VARCHAR(10))
	
	SET @sql += ' ORDER BY datetime desc'

	EXEC(@sql)

	/*
	SELECT DISTINCT
		dbo.FNADateTimeFormat(d.create_ts, 0) [datetime]
		, d.create_user [user]
		, d.type [status]
		, d.process_id [process_id]
		, d.process_id + '^javascript:run_forecasting.grid_link_click("' + d.process_id + '")^' [process_id_link]
	FROM source_system_data_import_status d
	LEFT JOIN forecast_result fr ON d.Process_id = fr.process_id
	WHERE d.source = 'Forecast File' AND
	CAST(d.create_ts AS DATE) BETWEEN CAST(ISNULL(NULLIF(@date_from,''), d.create_ts) AS DATE) AND CAST(ISNULL(NULLIF(@date_to,''), d.create_ts) AS DATE) AND
	CASE WHEN @status IS NULL OR @status = '' THEN '' 
		WHEN d.type = 'Approved' THEN 'a'
		WHEN d.type = 'Unapproved' Then 'u'
	ELSE d.type END = ISNULL(@status, '') AND
	CASE WHEN ISNULL(@forecast_mapping_id,'') = '' THEN '' ELSE ISNULL(fr.forecasted_data_id,'') END = ISNULL(@forecast_mapping_id, '')
	*/
END

ELSE IF @flag = 't'
BEGIN
	IF OBJECT_ID('tempdb..#tmp_forcast_data') IS NOT NULL
			DROP TABLE #tmp_forcast_data

	CREATE TABLE #tmp_forcast_data (
		maturity DATE,
		[hour] INT,
		[minute] INT,
		predication_data FLOAT,
		hour_min VARCHAR(20) COLLATE DATABASE_DEFAULT
	)
	SET @sql ='
	INSERT INTO #tmp_forcast_data
	SELECT dbo.fnadateformat(maturity), DATEPART(hh,maturity), DATEPART(mi,maturity), predicition_data, RIGHT(''0''+CAST(DATEPART(hh,maturity) AS VARCHAR),2) + '':'' + RIGHT(''0'' + CAST(DATEPART(mi,maturity) AS VARCHAR),2)
	FROM forecast_result WHERE test_data IS NULL AND process_id = '''+@process_id+''''
	
	SET @sql = @sql+
	' '+CASE WHEN NULLIF(@date_From,'') IS NULL THEN '' ELSE ' AND maturity>= ISNULL('''+@date_from +' 00:00:00:000'+''','''')' END
	+' '+ CASE WHEN NULLIF(@date_to,'') IS NULL THEN '' ELSE ' AND maturity <= ISNULL('''+@date_to+' 23:59:00:000'+''','''')' END
	
	EXEC(@sql)
	
	-- Selecting date and time
	DECLARE @hourdate datetime
	SET @hourdate = (SELECT DATEADD(hour,mvd.hour,frr.maturity)
	FROM forecast_result frr
	inner join MV90_Dst mvd on mvd.date = frr.maturity  where process_id = ''+@process_id+''
	and frr.test_data IS NULL)

	-- Adding 24 hr
	SET @sql ='
	insert into #tmp_forcast_data
	SELECT distinct dbo.fnadateformat(maturity), 24, 0, predicition_data, ''24 : 00'' 
	FROM forecast_result fr where fr.process_id = '''+@process_id+'''
	and fr.test_data IS NULL and maturity = '''+cast(@hourdate as varchar)+''''
	exec(@sql)
	
	-- Updating existing hour value.
	UPDATE #tmp_forcast_data SET predication_data = predication_data / 2 
		WHERE maturity = ''+dbo.fnadateformat(@hourdate)+'' 
	AND hour = ''+DATEPART(hh,@hourdate)+''
	
	DECLARE @min_date VARCHAR(30)
	DECLARE @max_date VARCHAR(30)
	SELECT	@min_date = CAST(MIN(maturity) AS VARCHAR) + ' 00:00:00:000',
			@max_date = CAST(MAX(maturity) AS VARCHAR) + ' 23:59:59:000' 
	FROM #tmp_forcast_data
	
	DECLARE @granularity INT
	SELECT DISTINCT @granularity = fmo.forecast_granularity FROM forecast_result_summary fr
	INNER JOIN forecast_mapping fm ON fr.forecast_mapping_id = fm.forecast_mapping_id
	INNER JOIN forecast_model fmo ON fmo.forecast_model_id = fm.forecast_model_id
	WHERE fr.process_id = @process_id

	DECLARE @gan CHAR(1)
	IF @granularity = 993 SET @gan = 'a' --Annually
	IF @granularity = 980 SET @gan = 'm' --Monthly
	IF @granularity = 981 SET @gan = 'd' --Daily
	IF @granularity = 982 SET @gan = 'h' --Hourly
	IF @granularity = 989 SET @gan = 't' --30 Mins
	IF @granularity = 987 SET @gan = 'f' --15 Mins
	IF @granularity = 994 SET @gan = 'r' --10 Mins
	IF @granularity = 994 SET @gan = 'z' --5 Mins

	INSERT INTO #tmp_forcast_data
	SELECT CAST(tmp.term_start AS DATE) [maturity], DATEPART(HOUR, tmp.term_start) [hour],  DATEPART(mi, tmp.term_start) [minute], '' [prediction_data], 
	RIGHT('0'+CAST(DATEPART(HOUR, tmp.term_start) AS VARCHAR),2) + ':' + RIGHT('0'+CAST(DATEPART(mi, tmp.term_start) AS VARCHAR),2)
	FROM dbo.FNATermBreakdown(@gan,@min_date, @max_date) tmp
	LEFT JOIN #tmp_forcast_data tfd ON CAST(tmp.term_start AS DATE) = CAST(tfd.maturity AS DATE) AND DATEPART(HOUR, tmp.term_start) =  tfd.hour 
	AND DATEPART(mi, tmp.term_start) =  tfd.minute
	WHERE tfd.predication_data IS NULL
	
	IF @granularity = 982 -- Hourly
	BEGIN
		SELECT	maturity, 
				NULLIF([0],0) [0],
				NULLIF([1],0) [1],
				NULLIF([2],0) [2],
				NULLIF([3],0) [3],
				NULLIF([4],0) [4],
				NULLIF([5],0) [5],
				NULLIF([6],0) [6],
				NULLIF([7],0) [7],
				NULLIF([8],0) [8],
				NULLIF([9],0) [9],
				NULLIF([10],0) [10],
				NULLIF([11],0) [11],
				NULLIF([12],0) [12],
				NULLIF([12],0) [13],
				NULLIF([14],0) [14],
				NULLIF([15],0) [15],
				NULLIF([16],0) [16],
				NULLIF([17],0) [17],
				NULLIF([18],0) [18],
				NULLIF([19],0) [19],
				NULLIF([20],0) [20],
				NULLIF([21],0) [21],
				NULLIF([22],0) [22],
				NULLIF([23],0) [23],
				NULLIF([24],0) [24]
				
		FROM
		(SELECT maturity, [hour], predication_data 
			FROM #tmp_forcast_data) AS forecast_data
		PIVOT
		(
		SUM(predication_data)
		FOR [hour] IN ([0],[1],[2],[3],[4],[5],[6],[7],[8],[9],[10],[11],[12],[13],[14],[15],[16],[17],[18],[19],[20],[21],[22],[23], [24])
		) AS [hour] ORDER BY maturity;
	END
	ELSE IF @granularity = 989 --30 Minutes
	BEGIN
		SELECT	maturity, 
				NULLIF([00:00],0) [00:00],NULLIF([00:30],0) [00:30],
				NULLIF([01:00],0) [01:00],NULLIF([01:30],0) [01:30],
				NULLIF([02:00],0) [02:00],NULLIF([02:30],0) [02:30],
				NULLIF([03:00],0) [03:00],NULLIF([03:30],0) [03:30],
				NULLIF([04:00],0) [04:00],NULLIF([04:30],0) [04:30],
				NULLIF([05:00],0) [05:00],NULLIF([05:30],0) [05:30],
				NULLIF([06:00],0) [06:00],NULLIF([06:30],0) [06:30],
				NULLIF([07:00],0) [07:00],NULLIF([07:30],0) [07:30],
				NULLIF([08:00],0) [08:00],NULLIF([08:30],0) [08:30],
				NULLIF([09:00],0) [09:00],NULLIF([09:30],0) [09:30],
				NULLIF([10:00],0) [10:00],NULLIF([10:30],0) [10:30],
				NULLIF([11:00],0) [11:00],NULLIF([11:30],0) [11:30],
				NULLIF([12:00],0) [12:00],NULLIF([12:30],0) [12:30],
				NULLIF([13:00],0) [13:00],NULLIF([13:30],0) [13:30],
				NULLIF([14:00],0) [14:00],NULLIF([14:30],0) [14:30],
				NULLIF([15:00],0) [15:00],NULLIF([15:30],0) [15:30],
				NULLIF([16:00],0) [16:00],NULLIF([16:30],0) [16:30],
				NULLIF([17:00],0) [17:00],NULLIF([17:30],0) [17:30],
				NULLIF([18:00],0) [18:00],NULLIF([18:30],0) [18:30],
				NULLIF([19:00],0) [19:00],NULLIF([19:30],0) [19:30],
				NULLIF([20:00],0) [20:00],NULLIF([20:30],0) [20:30],
				NULLIF([21:00],0) [21:00],NULLIF([21:30],0) [21:30],
				NULLIF([22:00],0) [22:00],NULLIF([22:30],0) [22:30],
				NULLIF([23:00],0) [23:00],NULLIF([23:30],0) [23:30]
		FROM
		(SELECT maturity, [hour_min], predication_data 
			FROM #tmp_forcast_data) AS forecast_data
		PIVOT
		(
		SUM(predication_data)
		FOR [hour_min] IN (	[00:00],[00:30],
							[01:00],[01:30],
							[02:00],[02:30],
							[03:00],[03:30],
							[04:00],[04:30],
							[05:00],[05:30],
							[06:00],[06:30],
							[07:00],[07:30],
							[08:00],[08:30],
							[09:00],[09:30],
							[10:00],[10:30],
							[11:00],[11:30],
							[12:00],[12:30],
							[13:00],[13:30],
							[14:00],[14:30],
							[15:00],[15:30],
							[16:00],[16:30],
							[17:00],[17:30],
							[18:00],[18:30],
							[19:00],[19:30],
							[20:00],[20:30],
							[21:00],[21:30],
							[22:00],[22:30],
							[23:00],[23:30]
							)
		) AS [hour] ORDER BY maturity;
		
	END
	ELSE IF @granularity = 987 --15 Minutes
	BEGIN
		SELECT	maturity, 
				NULLIF([00:00],0) [00:00],NULLIF([00:15],0) [00:15],NULLIF([00:30],0) [00:30],NULLIF([00:45],0) [00:45],
				NULLIF([01:00],0) [01:00],NULLIF([01:15],0) [01:15],NULLIF([01:30],0) [01:30],NULLIF([01:45],0) [01:45],
				NULLIF([02:00],0) [02:00],NULLIF([02:15],0) [02:15],NULLIF([02:30],0) [02:30],NULLIF([02:45],0) [02:45],
				NULLIF([03:00],0) [03:00],NULLIF([03:15],0) [03:15],NULLIF([03:30],0) [03:30],NULLIF([03:45],0) [03:45],
				NULLIF([04:00],0) [04:00],NULLIF([04:15],0) [04:15],NULLIF([04:30],0) [04:30],NULLIF([04:45],0) [04:45],
				NULLIF([05:00],0) [05:00],NULLIF([05:15],0) [05:15],NULLIF([05:30],0) [05:30],NULLIF([05:45],0) [05:45],
				NULLIF([06:00],0) [06:00],NULLIF([06:15],0) [06:15],NULLIF([06:30],0) [06:30],NULLIF([06:45],0) [06:45],
				NULLIF([07:00],0) [07:00],NULLIF([07:15],0) [07:15],NULLIF([07:30],0) [07:30],NULLIF([07:45],0) [07:45],
				NULLIF([08:00],0) [08:00],NULLIF([08:15],0) [08:15],NULLIF([08:30],0) [08:30],NULLIF([08:45],0) [08:45],
				NULLIF([09:00],0) [09:00],NULLIF([09:15],0) [09:15],NULLIF([09:30],0) [09:30],NULLIF([09:45],0) [09:45],
				NULLIF([10:00],0) [10:00],NULLIF([10:15],0) [10:15],NULLIF([10:30],0) [10:30],NULLIF([10:45],0) [10:45],
				NULLIF([11:00],0) [11:00],NULLIF([11:15],0) [11:15],NULLIF([11:30],0) [11:30],NULLIF([11:45],0) [11:45],
				NULLIF([12:00],0) [12:00],NULLIF([12:15],0) [12:15],NULLIF([12:30],0) [12:30],NULLIF([12:45],0) [12:45],
				NULLIF([13:00],0) [13:00],NULLIF([13:15],0) [13:15],NULLIF([13:30],0) [13:30],NULLIF([13:45],0) [13:45],
				NULLIF([14:00],0) [14:00],NULLIF([14:15],0) [14:15],NULLIF([14:30],0) [14:30],NULLIF([14:45],0) [14:45],
				NULLIF([15:00],0) [15:00],NULLIF([15:15],0) [15:15],NULLIF([15:30],0) [15:30],NULLIF([15:45],0) [15:45],
				NULLIF([16:00],0) [16:00],NULLIF([16:15],0) [16:15],NULLIF([16:30],0) [16:30],NULLIF([16:45],0) [16:45],
				NULLIF([17:00],0) [17:00],NULLIF([17:15],0) [17:15],NULLIF([17:30],0) [17:30],NULLIF([17:45],0) [17:45],
				NULLIF([18:00],0) [18:00],NULLIF([18:15],0) [18:15],NULLIF([18:30],0) [18:30],NULLIF([18:45],0) [18:45],
				NULLIF([19:00],0) [19:00],NULLIF([19:15],0) [19:15],NULLIF([19:30],0) [19:30],NULLIF([19:45],0) [19:45],
				NULLIF([20:00],0) [20:00],NULLIF([20:15],0) [20:15],NULLIF([20:30],0) [20:30],NULLIF([20:45],0) [20:45],
				NULLIF([21:00],0) [21:00],NULLIF([21:15],0) [21:15],NULLIF([21:30],0) [21:30],NULLIF([21:45],0) [21:45],
				NULLIF([22:00],0) [22:00],NULLIF([22:15],0) [22:15],NULLIF([22:30],0) [22:30],NULLIF([22:45],0) [22:45],
				NULLIF([23:00],0) [23:00],NULLIF([23:15],0) [23:15],NULLIF([23:30],0) [23:30],NULLIF([23:45],0) [23:45]
		FROM
		(SELECT maturity, [hour_min], predication_data 
			FROM #tmp_forcast_data) AS forecast_data

		PIVOT
		(
		SUM(predication_data)
		FOR [hour_min] IN (	[00:00],[00:15],[00:30],[00:45],
							[01:00],[01:15],[01:30],[01:45],
							[02:00],[02:15],[02:30],[02:45],
							[03:00],[03:15],[03:30],[03:45],
							[04:00],[04:15],[04:30],[04:45],
							[05:00],[05:15],[05:30],[05:45],
							[06:00],[06:15],[06:30],[06:45],
							[07:00],[07:15],[07:30],[07:45],
							[08:00],[08:15],[08:30],[08:45],
							[09:00],[09:15],[09:30],[09:45],
							[10:00],[10:15],[10:30],[10:45],
							[11:00],[11:15],[11:30],[11:45],
							[12:00],[12:15],[12:30],[12:45],
							[13:00],[13:15],[13:30],[13:45],
							[14:00],[14:15],[14:30],[14:45],
							[15:00],[15:15],[15:30],[15:45],
							[16:00],[16:15],[16:30],[16:45],
							[17:00],[17:15],[17:30],[17:45],
							[18:00],[18:15],[18:30],[18:45],
							[19:00],[19:15],[19:30],[19:45],
							[20:00],[20:15],[20:30],[20:45],
							[21:00],[21:15],[21:30],[21:45],
							[22:00],[22:15],[22:30],[22:45],
							[23:00],[23:15],[23:30],[23:45]

							)
		) AS [hour] ORDER BY maturity;
		
	END
	ELSE IF @granularity = 994 -- 10 Minutes
	BEGIN
		SELECT	maturity, 
				NULLIF([00:00],0) [00:00],NULLIF([00:10],0) [00:10],NULLIF([00:20],0) [00:20],NULLIF([00:30],0) [00:30],NULLIF([00:40],0) [00:40],NULLIF([00:50],0) [00:50],
				NULLIF([01:00],0) [01:00],NULLIF([01:10],0) [01:10],NULLIF([01:20],0) [01:20],NULLIF([01:30],0) [01:30],NULLIF([01:40],0) [01:40],NULLIF([01:50],0) [01:50],
				NULLIF([02:00],0) [02:00],NULLIF([02:10],0) [02:10],NULLIF([02:20],0) [02:20],NULLIF([02:30],0) [02:30],NULLIF([02:40],0) [02:40],NULLIF([02:50],0) [02:50],
				NULLIF([03:00],0) [03:00],NULLIF([03:10],0) [03:10],NULLIF([03:20],0) [03:20],NULLIF([03:30],0) [03:30],NULLIF([03:40],0) [03:40],NULLIF([03:50],0) [03:50],
				NULLIF([04:00],0) [04:00],NULLIF([04:10],0) [04:10],NULLIF([04:20],0) [04:20],NULLIF([04:30],0) [04:30],NULLIF([04:40],0) [04:40],NULLIF([04:50],0) [04:50],
				NULLIF([05:00],0) [05:00],NULLIF([05:10],0) [05:10],NULLIF([05:20],0) [05:20],NULLIF([05:30],0) [05:30],NULLIF([05:40],0) [05:40],NULLIF([05:50],0) [05:50],
				NULLIF([06:00],0) [06:00],NULLIF([06:10],0) [06:10],NULLIF([06:20],0) [06:20],NULLIF([06:30],0) [06:30],NULLIF([06:40],0) [06:40],NULLIF([06:50],0) [06:50],
				NULLIF([07:00],0) [07:00],NULLIF([07:10],0) [07:10],NULLIF([07:20],0) [07:20],NULLIF([07:30],0) [07:30],NULLIF([07:40],0) [07:40],NULLIF([07:50],0) [07:50],
				NULLIF([08:00],0) [08:00],NULLIF([08:10],0) [08:10],NULLIF([08:20],0) [08:20],NULLIF([08:30],0) [08:30],NULLIF([08:40],0) [08:40],NULLIF([08:50],0) [08:50],
				NULLIF([09:00],0) [09:00],NULLIF([09:10],0) [09:10],NULLIF([09:20],0) [09:20],NULLIF([09:30],0) [09:30],NULLIF([09:40],0) [09:40],NULLIF([09:50],0) [09:50],
				NULLIF([10:00],0) [10:00],NULLIF([10:10],0) [10:10],NULLIF([10:20],0) [10:20],NULLIF([10:30],0) [10:30],NULLIF([10:40],0) [10:40],NULLIF([10:50],0) [10:50],
				NULLIF([11:00],0) [11:00],NULLIF([11:10],0) [11:10],NULLIF([11:20],0) [11:20],NULLIF([11:30],0) [11:30],NULLIF([11:40],0) [11:40],NULLIF([11:50],0) [11:50],
				NULLIF([12:00],0) [12:00],NULLIF([12:10],0) [12:10],NULLIF([12:20],0) [12:20],NULLIF([12:30],0) [12:30],NULLIF([12:40],0) [12:40],NULLIF([12:50],0) [12:50],
				NULLIF([13:00],0) [13:00],NULLIF([13:10],0) [13:10],NULLIF([13:20],0) [13:20],NULLIF([13:30],0) [13:30],NULLIF([13:40],0) [13:40],NULLIF([13:50],0) [13:50],
				NULLIF([14:00],0) [14:00],NULLIF([14:10],0) [14:10],NULLIF([14:20],0) [14:20],NULLIF([14:30],0) [14:30],NULLIF([14:40],0) [14:40],NULLIF([14:50],0) [14:50],
				NULLIF([15:00],0) [15:00],NULLIF([15:10],0) [15:10],NULLIF([15:20],0) [15:20],NULLIF([15:30],0) [15:30],NULLIF([15:40],0) [15:40],NULLIF([15:50],0) [15:50],
				NULLIF([16:00],0) [16:00],NULLIF([16:10],0) [16:10],NULLIF([16:20],0) [16:20],NULLIF([16:30],0) [16:30],NULLIF([16:40],0) [16:40],NULLIF([16:50],0) [16:50],
				NULLIF([17:00],0) [17:00],NULLIF([17:10],0) [17:10],NULLIF([17:20],0) [17:20],NULLIF([17:30],0) [17:30],NULLIF([17:40],0) [17:40],NULLIF([17:50],0) [17:50],
				NULLIF([18:00],0) [18:00],NULLIF([18:10],0) [18:10],NULLIF([18:20],0) [18:20],NULLIF([18:30],0) [18:30],NULLIF([18:40],0) [18:40],NULLIF([18:50],0) [18:50],
				NULLIF([19:00],0) [19:00],NULLIF([19:10],0) [19:10],NULLIF([19:20],0) [19:20],NULLIF([19:30],0) [19:30],NULLIF([19:40],0) [19:40],NULLIF([19:50],0) [19:50],
				NULLIF([20:00],0) [20:00],NULLIF([20:10],0) [20:10],NULLIF([20:20],0) [20:20],NULLIF([20:30],0) [20:30],NULLIF([20:40],0) [20:40],NULLIF([20:50],0) [20:50],
				NULLIF([21:00],0) [21:00],NULLIF([21:10],0) [21:10],NULLIF([21:20],0) [21:20],NULLIF([21:30],0) [21:30],NULLIF([21:40],0) [21:40],NULLIF([21:50],0) [21:50],
				NULLIF([22:00],0) [22:00],NULLIF([22:10],0) [22:10],NULLIF([22:20],0) [22:20],NULLIF([22:30],0) [22:30],NULLIF([22:40],0) [22:40],NULLIF([22:50],0) [22:50],
				NULLIF([23:00],0) [23:00],NULLIF([23:10],0) [23:10],NULLIF([23:20],0) [23:20],NULLIF([23:30],0) [23:30],NULLIF([23:40],0) [23:40],NULLIF([23:50],0) [23:50]
		FROM
		(SELECT maturity, [hour_min], predication_data 
			FROM #tmp_forcast_data) AS forecast_data
		PIVOT
		(
		SUM(predication_data)
		FOR [hour_min] IN (	[00:00],[00:10],[00:20],[00:30],[00:40],[00:50],
							[01:00],[01:10],[01:20],[01:30],[01:40],[01:50],
							[02:00],[02:10],[02:20],[02:30],[02:40],[02:50],
							[03:00],[03:10],[03:20],[03:30],[03:40],[03:50],
							[04:00],[04:10],[04:20],[04:30],[04:40],[04:50],
							[05:00],[05:10],[05:20],[05:30],[05:40],[05:50],
							[06:00],[06:10],[06:20],[06:30],[06:40],[06:50],
							[07:00],[07:10],[07:20],[07:30],[07:40],[07:50],
							[08:00],[08:10],[08:20],[08:30],[08:40],[08:50],
							[09:00],[09:10],[09:20],[09:30],[09:40],[09:50],
							[10:00],[10:10],[10:20],[10:30],[10:40],[10:50],
							[11:00],[11:10],[11:20],[11:30],[11:40],[11:50],
							[12:00],[12:10],[12:20],[12:30],[12:40],[12:50],
							[13:00],[13:10],[13:20],[13:30],[13:40],[13:50],
							[14:00],[14:10],[14:20],[14:30],[14:40],[14:50],
							[15:00],[15:10],[15:20],[15:30],[15:40],[15:50],
							[16:00],[16:10],[16:20],[16:30],[16:40],[16:50],
							[17:00],[17:10],[17:20],[17:30],[17:40],[17:50],
							[18:00],[18:10],[18:20],[18:30],[18:40],[18:50],
							[19:00],[19:10],[19:20],[19:30],[19:40],[19:50],
							[20:00],[20:10],[20:20],[20:30],[20:40],[20:50],
							[21:00],[21:10],[21:20],[21:30],[21:40],[21:50],
							[22:00],[22:10],[22:20],[22:30],[22:40],[22:50],
							[23:00],[23:10],[23:20],[23:30],[23:40],[23:50]
						)
		) AS [hour] ORDER BY maturity;
		
	END
	ELSE IF @granularity = 995 -- 5 Minutes
	BEGIN
		SELECT	maturity, 
				NULLIF([00:00],0) [00:00],NULLIF([00:05],0) [00:05],NULLIF([00:10],0) [00:10],NULLIF([00:15],0) [00:15],NULLIF([00:20],0) [00:20],NULLIF([00:25],0) [00:25],NULLIF([00:30],0) [00:30],NULLIF([00:35],0) [00:35],NULLIF([00:40],0) [00:40],NULLIF([00:45],0) [00:45],NULLIF([00:50],0) [00:50],NULLIF([00:55],0) [00:55],
				NULLIF([01:00],0) [01:00],NULLIF([01:05],0) [01:05],NULLIF([01:10],0) [01:10],NULLIF([01:15],0) [01:15],NULLIF([01:20],0) [01:20],NULLIF([01:25],0) [01:25],NULLIF([01:30],0) [01:30],NULLIF([01:35],0) [01:35],NULLIF([01:40],0) [01:40],NULLIF([01:45],0) [01:45],NULLIF([01:50],0) [01:50],NULLIF([01:55],0) [01:55],
				NULLIF([02:00],0) [02:00],NULLIF([02:05],0) [02:05],NULLIF([02:10],0) [02:10],NULLIF([02:15],0) [02:15],NULLIF([02:20],0) [02:20],NULLIF([02:25],0) [02:25],NULLIF([02:30],0) [02:30],NULLIF([02:35],0) [02:35],NULLIF([02:40],0) [02:40],NULLIF([02:45],0) [02:45],NULLIF([02:50],0) [02:50],NULLIF([02:55],0) [02:55],
				NULLIF([03:00],0) [03:00],NULLIF([03:05],0) [03:05],NULLIF([03:10],0) [03:10],NULLIF([03:15],0) [03:15],NULLIF([03:20],0) [03:20],NULLIF([03:25],0) [03:25],NULLIF([03:30],0) [03:30],NULLIF([03:35],0) [03:35],NULLIF([03:40],0) [03:40],NULLIF([03:45],0) [03:45],NULLIF([03:50],0) [03:50],NULLIF([03:55],0) [03:55],
				NULLIF([04:00],0) [04:00],NULLIF([04:05],0) [04:05],NULLIF([04:10],0) [04:10],NULLIF([04:15],0) [04:15],NULLIF([04:20],0) [04:20],NULLIF([04:25],0) [04:25],NULLIF([04:30],0) [04:30],NULLIF([04:35],0) [04:35],NULLIF([04:40],0) [04:40],NULLIF([04:45],0) [04:45],NULLIF([04:50],0) [04:50],NULLIF([04:55],0) [04:55],
				NULLIF([05:00],0) [05:00],NULLIF([05:05],0) [05:05],NULLIF([05:10],0) [05:10],NULLIF([05:15],0) [05:15],NULLIF([05:20],0) [05:20],NULLIF([05:25],0) [05:25],NULLIF([05:30],0) [05:30],NULLIF([05:35],0) [05:35],NULLIF([05:40],0) [05:40],NULLIF([05:45],0) [05:45],NULLIF([05:50],0) [05:50],NULLIF([05:55],0) [05:55],
				NULLIF([06:00],0) [06:00],NULLIF([06:05],0) [06:05],NULLIF([06:10],0) [06:10],NULLIF([06:15],0) [06:15],NULLIF([06:20],0) [06:20],NULLIF([06:25],0) [06:25],NULLIF([06:30],0) [06:30],NULLIF([06:35],0) [06:35],NULLIF([06:40],0) [06:40],NULLIF([06:45],0) [06:45],NULLIF([06:50],0) [06:50],NULLIF([06:55],0) [06:55],
				NULLIF([07:00],0) [07:00],NULLIF([07:05],0) [07:05],NULLIF([07:10],0) [07:10],NULLIF([07:15],0) [07:15],NULLIF([07:20],0) [07:20],NULLIF([07:25],0) [07:25],NULLIF([07:30],0) [07:30],NULLIF([07:35],0) [07:35],NULLIF([07:40],0) [07:40],NULLIF([07:45],0) [07:45],NULLIF([07:50],0) [07:50],NULLIF([07:55],0) [07:55],
				NULLIF([08:00],0) [08:00],NULLIF([08:05],0) [08:05],NULLIF([08:10],0) [08:10],NULLIF([08:15],0) [08:15],NULLIF([08:20],0) [08:20],NULLIF([08:25],0) [08:25],NULLIF([08:30],0) [08:30],NULLIF([08:35],0) [08:35],NULLIF([08:40],0) [08:40],NULLIF([08:45],0) [08:45],NULLIF([08:50],0) [08:50],NULLIF([08:55],0) [08:55],
				NULLIF([09:00],0) [09:00],NULLIF([09:05],0) [09:05],NULLIF([09:10],0) [09:10],NULLIF([09:15],0) [09:15],NULLIF([09:20],0) [09:20],NULLIF([09:25],0) [09:25],NULLIF([09:30],0) [09:30],NULLIF([09:35],0) [09:35],NULLIF([09:40],0) [09:40],NULLIF([09:45],0) [09:45],NULLIF([09:50],0) [09:50],NULLIF([09:55],0) [09:55],
				NULLIF([10:00],0) [10:00],NULLIF([10:05],0) [10:05],NULLIF([10:10],0) [10:10],NULLIF([10:15],0) [10:15],NULLIF([10:20],0) [10:20],NULLIF([10:25],0) [10:25],NULLIF([10:30],0) [10:30],NULLIF([10:35],0) [10:35],NULLIF([10:40],0) [10:40],NULLIF([10:45],0) [10:45],NULLIF([10:50],0) [10:50],NULLIF([10:55],0) [10:55],
				NULLIF([11:00],0) [11:00],NULLIF([11:05],0) [11:05],NULLIF([11:10],0) [11:10],NULLIF([11:15],0) [11:15],NULLIF([11:20],0) [11:20],NULLIF([11:25],0) [11:25],NULLIF([11:30],0) [11:30],NULLIF([11:35],0) [11:35],NULLIF([11:40],0) [11:40],NULLIF([11:45],0) [11:45],NULLIF([11:50],0) [11:50],NULLIF([11:55],0) [11:55],
				NULLIF([12:00],0) [12:00],NULLIF([12:05],0) [12:05],NULLIF([12:10],0) [12:10],NULLIF([12:15],0) [12:15],NULLIF([12:20],0) [12:20],NULLIF([12:25],0) [12:25],NULLIF([12:30],0) [12:30],NULLIF([12:35],0) [12:35],NULLIF([12:40],0) [12:40],NULLIF([12:45],0) [12:45],NULLIF([12:50],0) [12:50],NULLIF([12:55],0) [12:55],
				NULLIF([13:00],0) [13:00],NULLIF([13:05],0) [13:05],NULLIF([13:10],0) [13:10],NULLIF([13:15],0) [13:15],NULLIF([13:20],0) [13:20],NULLIF([13:25],0) [13:25],NULLIF([13:30],0) [13:30],NULLIF([13:35],0) [13:35],NULLIF([13:40],0) [13:40],NULLIF([13:45],0) [13:45],NULLIF([13:50],0) [13:50],NULLIF([13:55],0) [13:55],
				NULLIF([14:00],0) [14:00],NULLIF([14:05],0) [14:05],NULLIF([14:10],0) [14:10],NULLIF([14:15],0) [14:15],NULLIF([14:20],0) [14:20],NULLIF([14:25],0) [14:25],NULLIF([14:30],0) [14:30],NULLIF([14:35],0) [14:35],NULLIF([14:40],0) [14:40],NULLIF([14:45],0) [14:45],NULLIF([14:50],0) [14:50],NULLIF([14:55],0) [14:55],
				NULLIF([15:00],0) [15:00],NULLIF([15:05],0) [15:05],NULLIF([15:10],0) [15:10],NULLIF([15:15],0) [15:15],NULLIF([15:20],0) [15:20],NULLIF([15:25],0) [15:25],NULLIF([15:30],0) [15:30],NULLIF([15:35],0) [15:35],NULLIF([15:40],0) [15:40],NULLIF([15:45],0) [15:45],NULLIF([15:50],0) [15:50],NULLIF([15:55],0) [15:55],
				NULLIF([16:00],0) [16:00],NULLIF([16:05],0) [16:05],NULLIF([16:10],0) [16:10],NULLIF([16:15],0) [16:15],NULLIF([16:20],0) [16:20],NULLIF([16:25],0) [16:25],NULLIF([16:30],0) [16:30],NULLIF([16:35],0) [16:35],NULLIF([16:40],0) [16:40],NULLIF([16:45],0) [16:45],NULLIF([16:50],0) [16:50],NULLIF([16:55],0) [16:55],
				NULLIF([17:00],0) [17:00],NULLIF([17:05],0) [17:05],NULLIF([17:10],0) [17:10],NULLIF([17:15],0) [17:15],NULLIF([17:20],0) [17:20],NULLIF([17:25],0) [17:25],NULLIF([17:30],0) [17:30],NULLIF([17:35],0) [17:35],NULLIF([17:40],0) [17:40],NULLIF([17:45],0) [17:45],NULLIF([17:50],0) [17:50],NULLIF([17:55],0) [17:55],
				NULLIF([18:00],0) [18:00],NULLIF([18:05],0) [18:05],NULLIF([18:10],0) [18:10],NULLIF([18:15],0) [18:15],NULLIF([18:20],0) [18:20],NULLIF([18:25],0) [18:25],NULLIF([18:30],0) [18:30],NULLIF([18:35],0) [18:35],NULLIF([18:40],0) [18:40],NULLIF([18:45],0) [18:45],NULLIF([18:50],0) [18:50],NULLIF([18:55],0) [18:55],
				NULLIF([19:00],0) [19:00],NULLIF([19:05],0) [19:05],NULLIF([19:10],0) [19:10],NULLIF([19:15],0) [19:15],NULLIF([19:20],0) [19:20],NULLIF([19:25],0) [19:25],NULLIF([19:30],0) [19:30],NULLIF([19:35],0) [19:35],NULLIF([19:40],0) [19:40],NULLIF([19:45],0) [19:45],NULLIF([19:50],0) [19:50],NULLIF([19:55],0) [19:55],
				NULLIF([20:00],0) [20:00],NULLIF([20:05],0) [20:05],NULLIF([20:10],0) [20:10],NULLIF([20:15],0) [20:15],NULLIF([20:20],0) [20:20],NULLIF([20:25],0) [20:25],NULLIF([20:30],0) [20:30],NULLIF([20:35],0) [20:35],NULLIF([20:40],0) [20:40],NULLIF([20:45],0) [20:45],NULLIF([20:50],0) [20:50],NULLIF([20:55],0) [20:55],
				NULLIF([21:00],0) [21:00],NULLIF([21:05],0) [21:05],NULLIF([21:10],0) [21:10],NULLIF([21:15],0) [21:15],NULLIF([21:20],0) [21:20],NULLIF([21:25],0) [21:25],NULLIF([21:30],0) [21:30],NULLIF([21:35],0) [21:35],NULLIF([21:40],0) [21:40],NULLIF([21:45],0) [21:45],NULLIF([21:50],0) [21:50],NULLIF([21:55],0) [21:55],
				NULLIF([22:00],0) [22:00],NULLIF([22:05],0) [22:05],NULLIF([22:10],0) [22:10],NULLIF([22:15],0) [22:15],NULLIF([22:20],0) [22:20],NULLIF([22:25],0) [22:25],NULLIF([22:30],0) [22:30],NULLIF([22:35],0) [22:35],NULLIF([22:40],0) [22:40],NULLIF([22:45],0) [22:45],NULLIF([22:50],0) [22:50],NULLIF([22:55],0) [22:55],
				NULLIF([23:00],0) [23:00],NULLIF([23:05],0) [23:05],NULLIF([23:10],0) [23:10],NULLIF([23:15],0) [23:15],NULLIF([23:20],0) [23:20],NULLIF([23:25],0) [23:25],NULLIF([23:30],0) [23:30],NULLIF([23:35],0) [23:35],NULLIF([23:40],0) [23:40],NULLIF([23:45],0) [23:45],NULLIF([23:50],0) [23:50],NULLIF([23:55],0) [23:55]
		FROM
		(SELECT maturity, [hour_min], predication_data 
			FROM #tmp_forcast_data) AS forecast_data
		PIVOT
		(
		SUM(predication_data)
		FOR [hour_min] IN (	[00:00],[00:05],[00:10],[00:15],[00:20],[00:25],[00:30],[00:35],[00:40],[00:45],[00:50],[00:55],
							[01:00],[01:05],[01:10],[01:15],[01:20],[01:25],[01:30],[01:35],[01:40],[01:45],[01:50],[01:55],
							[02:00],[02:05],[02:10],[02:15],[02:20],[02:25],[02:30],[02:35],[02:40],[02:45],[02:50],[02:55],
							[03:00],[03:05],[03:10],[03:15],[03:20],[03:25],[03:30],[03:35],[03:40],[03:45],[03:50],[03:55],
							[04:00],[04:05],[04:10],[04:15],[04:20],[04:25],[04:30],[04:35],[04:40],[04:45],[04:50],[04:55],
							[05:00],[05:05],[05:10],[05:15],[05:20],[05:25],[05:30],[05:35],[05:40],[05:45],[05:50],[05:55],
							[06:00],[06:05],[06:10],[06:15],[06:20],[06:25],[06:30],[06:35],[06:40],[06:45],[06:50],[06:55],
							[07:00],[07:05],[07:10],[07:15],[07:20],[07:25],[07:30],[07:35],[07:40],[07:45],[07:50],[07:55],
							[08:00],[08:05],[08:10],[08:15],[08:20],[08:25],[08:30],[08:35],[08:40],[08:45],[08:50],[08:55],
							[09:00],[09:05],[09:10],[09:15],[09:20],[09:25],[09:30],[09:35],[09:40],[09:45],[09:50],[09:55],
							[10:00],[10:05],[10:10],[10:15],[10:20],[10:25],[10:30],[10:35],[10:40],[10:45],[10:50],[10:55],
							[11:00],[11:05],[11:10],[11:15],[11:20],[11:25],[11:30],[11:35],[11:40],[11:45],[11:50],[11:55],
							[12:00],[12:05],[12:10],[12:15],[12:20],[12:25],[12:30],[12:35],[12:40],[12:45],[12:50],[12:55],
							[13:00],[13:05],[13:10],[13:15],[13:20],[13:25],[13:30],[13:35],[13:40],[13:45],[13:50],[13:55],
							[14:00],[14:05],[14:10],[14:15],[14:20],[14:25],[14:30],[14:35],[14:40],[14:45],[14:50],[14:55],
							[15:00],[15:05],[15:10],[15:15],[15:20],[15:25],[15:30],[15:35],[15:40],[15:45],[15:50],[15:55],
							[16:00],[16:05],[16:10],[16:15],[16:20],[16:25],[16:30],[16:35],[16:40],[16:45],[16:50],[16:55],
							[17:00],[17:05],[17:10],[17:15],[17:20],[17:25],[17:30],[17:35],[17:40],[17:45],[17:50],[17:55],
							[18:00],[18:05],[18:10],[18:15],[18:20],[18:25],[18:30],[18:35],[18:40],[18:45],[18:50],[18:55],
							[19:00],[19:05],[19:10],[19:15],[19:20],[19:25],[19:30],[19:35],[19:40],[19:45],[19:50],[19:55],
							[20:00],[20:05],[20:10],[20:15],[20:20],[20:25],[20:30],[20:35],[20:40],[20:45],[20:50],[20:55],
							[21:00],[21:05],[21:10],[21:15],[21:20],[21:25],[21:30],[21:35],[21:40],[21:45],[21:50],[21:55],
							[22:00],[22:05],[22:10],[22:15],[22:20],[22:25],[22:30],[22:35],[22:40],[22:45],[22:50],[22:55],
							[23:00],[23:05],[23:10],[23:15],[23:20],[23:25],[23:30],[23:35],[23:40],[23:45],[23:50],[23:55]
						)
		) AS [hour] ORDER BY maturity;
		
	END

	ELSE IF @granularity = 981 
	BEGIN
		UPDATE #tmp_forcast_data
		SET [hour] = MONTH(maturity),
			[minute] = DAY(maturity),
			[hour_min] = YEAR(maturity)

		SELECT	DATENAME(month , DATEADD(month , [hour] , -1)) + ' ' + [hour_min] [Maturity], 
				NULLIF([1],0) [1],
				NULLIF([2],0) [2],
				NULLIF([3],0) [3],
				NULLIF([4],0) [4],
				NULLIF([5],0) [5],
				NULLIF([6],0) [6],
				NULLIF([7],0) [7],
				NULLIF([8],0) [8],
				NULLIF([9],0) [9],
				NULLIF([10],0) [10],
				NULLIF([11],0) [11],
				NULLIF([12],0) [12],
				NULLIF([12],0) [13],
				NULLIF([14],0) [14],
				NULLIF([15],0) [15],
				NULLIF([16],0) [16],
				NULLIF([17],0) [17],
				NULLIF([18],0) [18],
				NULLIF([19],0) [19],
				NULLIF([20],0) [20],
				NULLIF([21],0) [21],
				NULLIF([22],0) [22],
				NULLIF([23],0) [23],
				NULLIF([24],0) [24],
				NULLIF([25],0) [25],
				NULLIF([26],0) [26],
				NULLIF([27],0) [27],
				NULLIF([28],0) [28],
				NULLIF([29],0) [29],
				NULLIF([30],0) [30],
				NULLIF([31],0) [31]
    	FROM
		(SELECT [hour_min],[hour],[minute], predication_data 
			FROM #tmp_forcast_data) AS forecast_data
		PIVOT
		(
			SUM(predication_data)
			FOR [minute] IN ([1],[2],[3],[4],[5],[6],[7],[8],[9],[10],[11],[12],[13],[14],[15],[16],[17],[18],[19],[20],[21],[22],[23],[24],[25],[26],[27],[28],[29],[30],[31])
		) AS [days] ORDER BY [hour];

	END
 ELSE IF @granularity = 980 OR @granularity = 993
	BEGIN
		SELECT dbo.FNADateFormat(maturity), predication_data
		FROM #tmp_forcast_data
		ORDER by maturity
	END

END

ELSE IF @flag = 'y'
BEGIN
	BEGIN TRY
		EXEC sp_xml_preparedocument @idoc OUTPUT, @xml_data

		IF OBJECT_ID('tempdb..#tmp_edit_forecast') IS NOT NULL
			DROP TABLE #tmp_edit_forecast
		
		SELECT	maturity	[maturity],
				[hour]		[hour],
				data		[data]
		INTO #tmp_edit_forecast
		FROM OPENXML(@idoc, '/Root/GridRow', 1)
		WITH (
				maturity	VARCHAR(20),
				[hour]		INT,
				data		INT
		)

		UPDATE fr
			SET fr.predicition_data = tdf.data
		FROM #tmp_edit_forecast tdf
		INNER JOIN forecast_result fr ON tdf.maturity = CAST(fr.maturity AS DATE) AND tdf.[hour] = fr.[hour] AND fr.process_id = @process_id 

		--UPDATE forecast_result
		--SET is_approved = 1
		--WHERE process_id = @process_id

		--UPDATE source_system_data_import_status
		--SET type = 'Approved'
		--WHERE process_id = @process_id

	EXEC spa_ErrorHandler 0,
             'Forecast Parameter Mapping',
             'spa_forecast_parameter_mapping',
             'Success',
             'Changes has been successfully saved.',
             @n_forecast_mapping_id
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
		   ROLLBACK
		   
		EXEC spa_ErrorHandler -1,
             'Forecast Parameter Mapping',
             'spa_forecast_parameter_mapping',
             'Error',
             'Failed to save changes.',
             ''
	END CATCH
END

ELSE IF @flag = 'v'
BEGIN
	BEGIN TRY
		IF NULLIF(@forecast_mapping_id,'') IS NULL 
		BEGIN
				SELECT @forecast_mapping_id = forecast_mapping_id FROM forecast_result_summary frs WHERE frs.process_id = @process_id
		END
		SELECT @forecast_model_id = forecast_model_id,
			   @source_id = source_id,
			   @output_id = output_id
		FROM forecast_mapping
		WHERE forecast_mapping_id = @forecast_mapping_id
		
		SELECT @forecast_type1 = forecast_type
		FROM forecast_model
		WHERE forecast_model_id = @forecast_model_id
		
	
		IF @forecast_type1 =  43801
		BEGIN
			IF OBJECT_ID('tempdb..#forecast_result_stagin') IS NOT NULL
				DROP TABLE #forecast_result_stagin

			SELECT process_id
				,cast(maturity AS DATE) date
				,CAST(LEFT(CAST(maturity as TIME),2) as INT) hour
				,CAST(predicition_data as numeric(38,20)) predicition_data
			INTO #forecast_result_stagin
		FROM forecast_result
			WHERE process_id = @process_id
				AND is_approved = 0
			 ORDER BY create_ts

			 INSERT INTO deal_detail_hour (
				term_date
				,profile_id
				,Hr1
				,Hr2
				,Hr3
				,Hr4
				,Hr5
				,Hr6
				,Hr7
				,Hr8
				,Hr9
				,Hr10
				,Hr11
				,Hr12
				,Hr13
				,Hr14
				,Hr15
				,Hr16
				,Hr17
				,Hr18
				,Hr19
				,Hr20
				,Hr21
				,Hr22
				,Hr23
				,Hr24
				,Hr25
				)
			SELECT DATE
				,@output_Id
				,[0]
				,[1]
				,[2]
				,[3]
				,[4]
				,[5]
				,[6]
				,[7]
				,[8]
				,[9]
				,[10]
				,[11]
				,[12]
				,[13]
				,[14]
				,[15]
				,[16]
				,[17]
				,[18]
				,[19]
				,[20]
				,[21]
				,[22]
				,[23]
				,[24]
				
			FROM (
				SELECT *
				FROM #forecast_result_stagin
				) AS s
			PIVOT(SUM(predicition_data) FOR hour IN (
						[0]
						,[1]
						,[2]
						,[3]
						,[4]
						,[5]
						,[6]
						,[7]
						,[8]
						,[9]
						,[10]
						,[11]
						,[12]
						,[13]
						,[14]
						,[15]
						,[16]
						,[17]
						,[18]
						,[19]
						,[20]
						,[21]
						,[22]
						,[23]
						,[24]
						)) PVT
		END
		ELSE IF @forecast_type1 = 43802
		BEGIN
			SET @assessment_curve_type_value = 77 
			INSERT INTO source_price_curve (
				source_curve_def_id,
				as_of_date
				,Assessment_curve_type_value_id
				,curve_source_value_id
				,maturity_date
				,curve_value
				)
			SELECT @output_id
				 ,maturity
				,@assessment_curve_type_value
				,@source_id
				,maturity
				,predicition_data
			FROM forecast_result
			WHERE process_id = @process_id
				AND is_approved = 0
			ORDER BY create_ts
		END
		ELSE IF @forecast_type1 = 43803
		BEGIN 
			INSERT INTO time_series_data (
				time_series_definition_id
				,effective_date
				,maturity
				,curve_source_value_id
				,value
				)
			SELECT @output_id
				,maturity
				,maturity
				,@source_id
				,predicition_data
			FROM forecast_result
			WHERE process_id =  @process_id
				AND is_approved = 0
			ORDER BY create_ts
		END
		
		UPDATE forecast_result
		SET is_approved = 1
		WHERE process_id = @process_id

		UPDATE forecast_result_summary
		SET is_approved = 1
		WHERE process_id = @process_id

		UPDATE source_system_data_import_status
		SET type = 'Approved'
		WHERE process_id = @process_id

	EXEC spa_ErrorHandler 0,
             'Forecast Parameter Mapping',
             'spa_forecast_parameter_mapping',
             'Success',
             'Forecast data has been approved.',
             @n_forecast_mapping_id
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
		   ROLLBACK
		   
		EXEC spa_ErrorHandler -1,
             'Forecast Parameter Mapping',
             'spa_forecast_parameter_mapping',
             'Error',
             'Failed to approve forecast data.',
             ''
	END CATCH
END

ELSE IF @flag = 'n'
BEGIN
	SELECT	maturity [maturity],
			predicition_data
	FROM forecast_result fr WHERE process_id = @process_id 
	AND fr.maturity >= CASE WHEN @date_from = '' THEN fr.maturity ELSE @date_from + ' 00:00:00:000' END
	AND fr.maturity <= CASE WHEN @date_to = '' THEN fr.maturity ELSE @date_to + ' 23:59:59:000' END
	AND test_data IS NULL
	ORDER BY maturity
END


ELSE IF @flag = 'o'
BEGIN
	SELECT	maturity [maturity],
			predicition_data,
			test_data
	FROM forecast_result fr WHERE process_id = @process_id
	AND fr.maturity >= CASE WHEN @date_from = '' THEN fr.maturity ELSE @date_from + ' 00:00:00:000' END
	AND fr.maturity <= CASE WHEN @date_to = '' THEN fr.maturity ELSE @date_to + ' 23:59:59:000' END
	AND test_data IS NOT NULL
	ORDER BY maturity
END

ELSE IF @flag = 'e'
BEGIN
	SELECT	MIN(maturity) [min_date],
			MAX(maturity) [max_date],
			MAX(dbo.FNADateFormat(fr.create_ts)) [run_date],
			MAX(sdv.code) [forecast_type],
			CASE 
				WHEN MAX(fmo.forecast_type) = 43803 THEN MAX(tsd.time_series_name) 
				WHEN MAX(fmo.forecast_type) = 43802 THEN MAX(spc.curve_name) 	
				WHEN MAX(fmo.forecast_type) = 43801 THEN MAX(fp.external_id) 	
			END [output]
	FROM forecast_result fr
	INNER JOIN forecast_result_summary frs ON fr.forecast_summary_id = frs.forecast_result_summary_id
	INNER JOIN forecast_mapping fm ON frs.forecast_mapping_id = fm.forecast_mapping_id
	INNER JOIN forecast_model fmo ON fm.forecast_model_id = fmo.forecast_model_id
	LEFT JOIN static_data_value sdv ON sdv.value_id = fmo.forecast_type
	LEFT JOIN source_price_curve_def spc ON spc.source_curve_def_id = fm.output_id AND fmo.forecast_type = 43802
	LEFT JOIN time_series_definition tsd ON tsd.time_series_definition_id = fm.output_id AND fmo.forecast_type = 43803
	LEFT JOIN forecast_profile fp ON fp.profile_id = fm.output_id AND fmo.forecast_type = 43801
	WHERE fr.process_id = @process_id
END

ELSE IF @flag = 'b'
BEGIN
	BEGIN TRY
		BEGIN TRAN
			DELETE FROM forecast_result WHERE process_id = @process_id
			DELETE FROM forecast_result_summary WHERE process_id = @process_id

		COMMIT TRAN
		EXEC spa_ErrorHandler 0,
				 'Run Forecassting',
				 'spa_forecast_parameter_mapping',
				 'Success',
				 'Changes has been successfully deleted.',
				 @n_forecast_mapping_id

		
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
		   ROLLBACK
		   
		EXEC spa_ErrorHandler -1,
             'Run Forecassting',
             'spa_forecast_parameter_mapping',
             'Error',
             'Failed to delete.',
             ''
	END CATCH
END