
IF OBJECT_ID(N'[dbo].[spa_time_series]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[spa_time_series]
GO

SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON
GO
GO

CREATE PROCEDURE [dbo].[spa_time_series]
	@flag CHAR(1),
	@time_series_definition_id VARCHAR(200) = NULL,
	@xml VARCHAR(MAX) = NULL,
	@effective_date VARCHAR(20) = NULL,
	@tenor_from VARCHAR(20) = NULL,
	@tenor_to VARCHAR(20) = NULL,
	@curve_source VARCHAR(100) = NULL,
	@show_effective_data CHAR(1) = NULL,
	@round_value INT = NULL,
	@series_type INT = NULL,
	@effective_date_applicable CHAR(1) = NULL,
	@maturity_applicable CHAR(1) = NULL,
	@granularity VARCHAR(20) = NULL,
	@for_batch CHAR(1) = NULL,
	@function_id VARCHAR(20) = NULL,
	@report_name VARCHAR(50) = NULL,
	@filter CHAR(1) = NULL,
	@batch_process_id VARCHAR(100) = NULL,
	@batch_report_param VARCHAR(1000)  = NULL
	
AS

SET NOCOUNT ON

DECLARE @sql VARCHAR(MAX)
DECLARE @DESC VARCHAR(500)
DECLARE @err_no INT 

DECLARE @str_batch_table VARCHAR (8000)
DECLARE @user_login_id VARCHAR (50)
DECLARE @is_batch BIT
 
SET @str_batch_table = ''
SET @user_login_id = dbo.FNADBUser() 
SET @is_batch = CASE WHEN @batch_process_id IS NOT NULL AND @batch_report_param IS NOT NULL THEN 1 ELSE 0 END 
 
IF @is_batch = 1
BEGIN
	SET @str_batch_table = ' INTO ' + dbo.FNAProcessTableName('batch_report', @user_login_id, @batch_process_id)
END

IF @flag = 'g'
BEGIN
	--SELECT * FROM time_series_definition

	SET @sql = 'SELECT	sdv.code [series_type], 
						tsd.time_series_name [time_series_name],
						tsd.time_series_definition_id [time_series_definition_id],
						tsd.time_series_id [time_series_id],
						sdv1.code [ganularity],
						tsd.effective_date_applicable [effective_date_applicable],
						tsd.maturity_applicable [maturity_applicable],
						tsd.time_series_description [description],
						su.uom_id [uom],
						sc.currency_name [currency] 
				FROM time_series_definition tsd
				INNER JOIN static_data_value sdv ON tsd.time_series_type_value_id = sdv.value_id
				LEFT JOIN static_data_value sdv1 ON tsd.granulalrity = sdv1.value_id
				LEFT JOIN source_currency sc ON tsd.currency_id = sc.source_currency_id
				LEFT JOIN source_uom su ON tsd.uom_id = su.source_uom_id ' +
				+ CASE WHEN @series_type = '' THEN '' ELSE ' WHERE tsd.time_series_type_value_id = ''' +  CAST(@series_type AS VARCHAR) + '''' END
	EXEC(@sql) 
END


IF @flag = 'i'
BEGIN
	DECLARE @idoc INT
	EXEC sp_xml_preparedocument @idoc OUTPUT, @xml

	SELECT * INTO #temp_time_series
	FROM   OPENXML(@idoc, 'Root/FormXML', 2)
			WITH (
				time_series_definition_id INT '@time_series_definition_id',
				time_series_id VARCHAR(100) '@time_series_id',
				time_series_name VARCHAR(100) '@time_series_name',
				time_series_description VARCHAR(100) '@time_series_description',
				time_series_type_value_id INT '@time_series_type_value_id',
				granulalrity INT '@granulalrity',
				uom_id INT '@uom_id',
				currency_id INT '@currency_id',
				effective_date_applicable CHAR(1) '@effective_date_applicable',
				maturity_applicable CHAR(1) '@maturity_applicable',
				static_data_type_id INT '@static_data_type_id'
			)
	
	BEGIN TRY
		IF EXISTS (SELECT 1 FROM #temp_time_series tts WHERE tts.time_series_definition_id IS NULL)
		BEGIN
			IF EXISTS (SELECT 1 FROM time_series_definition WHERE time_series_id = (SELECT time_series_id FROM #temp_time_series))
			BEGIN
				EXEC spa_ErrorHandler -1
					, 'time_series_definition'
					, 'spa_time_series'
					, 'Error'
					, 'Duplicate data in (<b>Series ID<b>).'
					, ''
			END 
			ELSE
			BEGIN
				INSERT INTO time_series_definition 
				(
					time_series_id,
					time_series_name,
					time_series_description,
					time_series_type_value_id,
					granulalrity,
					uom_id,
					currency_id,
					effective_date_applicable,
					maturity_applicable,
					static_data_type_id
				)
				SELECT  tts.time_series_id,
						tts.time_series_name,
						tts.time_series_description,
						tts.time_series_type_value_id,
						tts.granulalrity,
						tts.uom_id,
						tts.currency_id,
						tts.effective_date_applicable,
						tts.maturity_applicable,
						tts.static_data_type_id
				FROM  #temp_time_series tts

				DECLARE @new_time_series_definition_id INT
				SET @new_time_series_definition_id = SCOPE_IDENTITY()

				EXEC spa_ErrorHandler 0
					, 'time_series_definition'
					, 'spa_time_series'
					, 'Success' 
					, 'Changes have been saved successfully.'
					, @new_time_series_definition_id
			END
		END
		ELSE
		BEGIN
			IF EXISTS (SELECT 1 FROM time_series_definition WHERE time_series_id = (SELECT time_series_id FROM #temp_time_series) AND time_series_definition_id <> (SELECT time_series_definition_id FROM #temp_time_series))
			BEGIN
				EXEC spa_ErrorHandler -1
					, 'time_series_definition'
					, 'spa_time_series'
					, 'Error'
					, 'Duplicate data in (<b>Series ID<b>).'
					, ''
			END 
			ELSE
			BEGIN
				UPDATE tsd 
				SET 
					time_series_id = tts.time_series_id,
					time_series_name = tts.time_series_name,
					time_series_description = tts.time_series_description,
					time_series_type_value_id = tts.time_series_type_value_id,
					granulalrity = tts.granulalrity,
					uom_id = tts.uom_id,
					currency_id = tts.currency_id,
					effective_date_applicable = tts.effective_date_applicable,
					maturity_applicable = tts.maturity_applicable,
					static_data_type_id = tts.static_data_type_id
				FROM #temp_time_series tts
				INNER JOIN time_series_definition tsd
				ON tts.time_series_definition_id = tsd.time_series_definition_id

				EXEC spa_ErrorHandler 0
					, 'time_series_definition'
					, 'spa_time_series'
					, 'Success' 
					, 'Changes have been saved successfully.'
					, ''
			END
		END
	END TRY
	BEGIN CATCH	
		IF @@TRANCOUNT > 0
			ROLLBACK

		SET @DESC = 'Fail to insert Data ( Errr Description:' + ERROR_MESSAGE() + ').'

		SELECT @err_no = ERROR_NUMBER()

		EXEC spa_ErrorHandler @err_no
			, 'time_series_definition'
			, 'spa_time_series'
			, 'Error'
			, @DESC
			, ''
	END CATCH
END

IF @flag = 'd'
BEGIN
	BEGIN TRY
		DELETE tsd
		FROM dbo.FNASplit(@time_series_definition_id,',') tsdi
		INNER JOIN time_series_definition tsd
		ON tsd.time_series_definition_id = tsdi.item

		EXEC spa_ErrorHandler 0
			, 'time_series_definition'
			, 'spa_time_series'
			, 'Success' 
			, 'Changes have been saved successfully.'
			, ''
	END TRY
	BEGIN CATCH
		SET @desc = dbo.FNAHandleDBError('10106100')
		EXEC spa_ErrorHandler -1, 'time_series_definition', 
			'spa_time_series', 'Error', 
			@desc, ''
	END CATCH
END

IF @flag = 's'
BEGIN
	DECLARE @series_name VARCHAR(20)
	SET @series_name = (SELECT time_series_name FROM time_series_definition AS tsd WHERE tsd.time_series_definition_id =  @time_series_definition_id)
 
	CREATE TABLE #temp_series_data
	(
		time_series_data_id INT,
		effective_date		VARCHAR(10) COLLATE DATABASE_DEFAULT,
		maturity			VARCHAR(10) COLLATE DATABASE_DEFAULT,
		[hour]				VARCHAR(5) COLLATE DATABASE_DEFAULT,
		[value]				FLOAT,
		is_dst				INT
	)	

	--SELECT dbo.FNADateFormat(@effective_date)
	SET @sql = 'INSERT INTO #temp_series_data (
					time_series_data_id,
					effective_date,
					maturity,
					[hour],
					[value],
					is_dst
				)	
				SELECT	tsd.time_series_data_id,
						dbo.FNADateFormat(tsd.effective_date) [effective_date], 
						dbo.FNADateFormat(tsd.maturity) [maturity],
						CASE WHEN dbo.FNADateFormat(tsd.maturity) IS NOT NULL THEN
							RIGHT(''0'' + CONVERT(VARCHAR(2), DATEPART(HOUR, tsd.maturity)), 2) + '':'' + RIGHT(''0'' + CONVERT(VARCHAR(2), DATEPART(MI, tsd.maturity)), 2)
						ELSE '''' END AS [hour],
						CASE WHEN '+ CAST(ISNULL(@round_value,-1) AS VARCHAR) +' <> -1 THEN ROUND(tsd.value,'+CAST(ISNULL(@round_value,0) AS VARCHAR)+') ELSE tsd.value END [value],
						tsd.is_dst AS [is_dst] 
				FROM time_series_data tsd
				WHERE tsd.time_series_definition_id = ' + @time_series_definition_id
				+ ' AND tsd.curve_source_value_id = ' + @curve_source
				+ CASE WHEN @maturity_applicable = 'y' AND @tenor_from <> '' THEN ' AND tsd.maturity >= ''' +  @tenor_from + '''' ELSE '' END
				+ CASE WHEN @maturity_applicable = 'y' AND @tenor_to <> '' THEN ' AND tsd.maturity <= ''' +  @tenor_to + ' 23:59' + '''' ELSE '' END
				+ CASE WHEN @show_effective_data = 'n' THEN CASE WHEN @effective_date_applicable = 'y' AND @effective_date <> '' THEN ' AND tsd.effective_date ='''+CAST((SELECT CONVERT(DATETIME,MAX(effective_date),103) FROM time_series_data ts WHERE ts.time_series_definition_id = @time_series_definition_id AND ts.effective_date <= @effective_date)  AS VARCHAR(200))+'''' ELSE '' END
					ELSE ' AND tsd.effective_date = ''' + @effective_date + '''' END
				+ ' ORDER BY tsd.effective_date, tsd.maturity'
	EXEC(@sql)
	--PRINT(@sql)

	
	IF @for_batch IS NULL
		SELECT	time_series_data_id,
				effective_date,
				maturity,
				[hour],
				[value],
				is_dst 
		FROM #temp_series_data
		ORDER BY effective_date, maturity, [hour]
	ELSE 
	BEGIN
		SET @sql = 'SELECT ' 
					+ CASE WHEN @effective_date_applicable = 'y' THEN 'tsd.effective_date [Effective From],' ELSE '' END	
					+ CASE WHEN @maturity_applicable = 'y' THEN 'tsd.maturity [Date],' ELSE '' END	
					+ CASE WHEN (@maturity_applicable = 'y' AND (@granularity = '15Min' OR @granularity = '30Min' OR @granularity = 'Hourly')) THEN 'tsd.hour [Hour],' ELSE '' END	
					+ ' tsd.value ['+@series_name+'] ' + @str_batch_table + ' FROM #temp_series_data tsd'
		EXEC(@sql)

		IF @is_batch = 1
 		BEGIN
 			SELECT @str_batch_table = dbo.FNABatchProcess ('u', @batch_process_id, @batch_report_param, GETDATE(), NULL, NULL) 
 			EXEC (@str_batch_table)
			SELECT @str_batch_table = dbo.FNABatchProcess ('c', @batch_process_id, @batch_report_param, 
						   GETDATE(), 'spa_time_series', ISNULL(@report_name,'Time Series')) 
			EXEC (@str_batch_table)
			RETURN
		END
	END
END

IF @flag = 't'
BEGIN
	BEGIN TRY
	BEGIN TRAN
		DECLARE @idoc1 INT
		EXEC sp_xml_preparedocument @idoc1 OUTPUT, @xml

		SELECT * INTO #temp_series_values
		FROM   OPENXML(@idoc1, 'Root/Grid/GridRow', 3)
				WITH (
					time_series_data_id INT '@time_series_data_id',
					effective_from VARCHAR(100) '@effective_from',
					[date] VARCHAR(100) '@date',
					[hour] INT '@hour',
					curve_value VARCHAR(20) '@curve_value',
					curve_source INT '@curve_source',
					is_dst INT '@is_dst',
					time_series_definition_id INT '@time_series_definition_id'
				)

		SELECT * INTO #temp_series_values_del
		FROM   OPENXML(@idoc1, 'Root/GridDelete/GridRow', 3)
				WITH (
					time_series_data_id INT '@time_series_data_id'
				)
		
		IF EXISTS (SELECT 1 FROM #temp_series_values WHERE time_series_data_id = 0)
		BEGIN
			INSERT INTO time_series_data 
			(
				effective_date,
				maturity,
				curve_source_value_id,
				value,
				is_dst,
				time_series_definition_id
			)
			SELECT  CASE WHEN tsv.effective_from = '' THEN NULL ELSE dbo.FNAGetSQLStandardDateTime(tsv.effective_from) END,
					CASE WHEN tsv.[date] = '' THEN NULL ELSE dbo.FNAGetSQLStandardDateTime(DATEADD(mi,tsv.[hour],tsv.[date])) END,
					tsv.curve_source,
					tsv.curve_value,
					tsv.is_dst,
					tsv.time_series_definition_id
			FROM  #temp_series_values tsv
			WHERE tsv.time_series_data_id = 0 AND tsv.curve_value <> ''
		END
		ELSE
		BEGIN
			UPDATE tsd 
			SET 
				effective_date = CASE WHEN tsv.effective_from = '' THEN NULL ELSE dbo.FNAGetSQLStandardDateTime(tsv.effective_from) END,
				maturity = CASE WHEN tsv.[date] = '' THEN NULL ELSE dbo.FNAGetSQLStandardDateTime(DATEADD(mi,tsv.[hour],tsv.[date])) END,
				curve_source_value_id = tsv.curve_source,
				value = tsv.curve_value,
				is_dst = tsv.is_dst,
				time_series_definition_id = tsv.time_series_definition_id
			FROM #temp_series_values tsv
			INNER JOIN time_series_data tsd
			ON tsv.time_series_data_id = tsd.time_series_data_id
			WHERE tsv.time_series_data_id > 0

			DELETE tsd FROM time_series_data tsd
			INNER JOIN #temp_series_values tsv ON tsv.time_series_data_id = tsd.time_series_data_id
			WHERE tsv.curve_value IS NULL OR tsv.curve_value = ''
		END

		DELETE tsd FROM time_series_data tsd
		INNER JOIN #temp_series_values_del tsvd ON tsvd.time_series_data_id = tsd.time_series_data_id
		
		EXEC spa_ErrorHandler 0
				, 'time_series_definition'
				, 'spa_time_series'
				, 'Success' 
				, 'Changes have been saved successfully.'
				, ''
	COMMIT TRAN
	END TRY
	BEGIN CATCH	
		IF @@TRANCOUNT > 0
			ROLLBACK

		SELECT @err_no = ERROR_NUMBER()
		IF @err_no =2627 
			SET @DESC = 'Duplicate data in (<b>Series Values </b>) grid.'
		ELSE 
			SET @DESC = 'Fail to insert Data ( Errr Description:' + ERROR_MESSAGE() + ').'

		EXEC spa_ErrorHandler -1
			, 'time_series_definition'
			, 'spa_time_series'
			, 'Error'
			, @DESC
			, ''
	END CATCH
END

ELSE IF @flag = 'c'
BEGIN
	IF EXISTS(SELECT * FROM time_series_data WHERE time_series_definition_id IN (@time_series_definition_id))
	BEGIN
		SELECT 0
	END
	ELSE
	BEGIN
		SELECT 1
	END
END

ELSE IF @flag = 'f'
BEGIN
	SELECT	gmv.clm2_value [Series Type],
			gmv.clm3_value [Definition Add],
			gmv.clm4_value [Definition Delete],
			gmv.clm5_value [Value Add],
			CASE WHEN sdv.code IS NULL THEN 'Time Series' ELSE sdv.code END [Label]
	FROM generic_mapping_values gmv
			INNER JOIN generic_mapping_header gmh ON gmv.mapping_table_id = gmh.mapping_table_id
			LEFT JOIN static_data_value sdv ON gmv.clm2_value = sdv.value_id
	WHERE gmh.mapping_name = 'Time Series Function ID Mapping' AND gmv.clm1_value = @function_id
END

ELSE IF @flag = 'b'
BEGIN
	SELECT ISNULL(static_data_type_id, '') AS static_data_type_id
	FROM time_series_definition WHERE time_series_definition_id = @time_series_definition_id
END

ELSE IF @flag = 'm'
BEGIN
	
	IF @filter = 'y'
	BEGIN
		SELECT value_id, code FROM static_data_value WHERE type_id = 44000 AND value_id <> 44001
		return
	END
	SELECT value_id, code FROM static_data_value WHERE type_id = 44000
	UNION
	SELECT VALUE_ID, CODE FROM static_data_value WHERE value_id = 44105 
END

ELSE IF @flag = 'p'
BEGIN
	IF @series_type = 44001
	BEGIN 
		SELECT value_id, code FROM static_data_value 
			WHERE type_id = 44100 
		AND value_id IN (44102, 44101)
	END
	ELSE IF @series_type = 44002
	BEGIN
		SELECT tsd.time_series_definition_id, sdv.code+' - '+tsd.time_series_name [series_type]
		FROM time_series_definition tsd
		INNER JOIN static_data_value sdv ON tsd.time_series_type_value_id = sdv.value_id
	END 
	ELSE IF @series_type = 44005
	BEGIN
	   SELECT 
              udtm.udtm_id column_metadata_id,
              udt.udt_descriptions + ' - '+ udtm.column_name [column_name]   
       FROM 
              user_defined_tables udt
              INNER JOIN user_defined_tables_metadata udtm ON udt.udt_id = udtm.udt_id

	END
END

ELSE IF @flag = 'q'
BEGIN 
	SELECT time_series_definition_id, time_series_name 
		FROM time_series_definition 
	WHERE time_series_name IS NOT NULL
	UNION SELECT value_id, code 
		FROM static_data_value 
	WHERE type_id = 44100
END 

