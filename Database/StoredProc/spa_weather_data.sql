
IF OBJECT_ID(N'[dbo].[spa_weather_data]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[spa_weather_data]
GO

SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON
GO
GO

CREATE PROCEDURE [dbo].[spa_weather_data]
	@flag CHAR(1),
	@time_series_definition_id VARCHAR(200) = NULL,
	@xml VARCHAR(MAX) = NULL,
	@effective_date VARCHAR(20) = NULL,
	@tenor_from VARCHAR(20) = NULL,
	@tenor_to VARCHAR(20) = NULL,
	@curve_source VARCHAR(100) = NULL,
	@show_effective_data CHAR(1) = NULL,
	@round_value INT = 4,
	@series_type INT = NULL,
	@effective_date_applicable CHAR(1) = NULL,
	@maturity_applicable CHAR(1) = NULL,
	@granularity VARCHAR(20) = NULL,
	@group_id INT = NULL,
	@for_batch CHAR(1) = NULL,
	@function_id VARCHAR(20) = NULL,
	@report_name VARCHAR(50) = NULL,
	@batch_process_id VARCHAR(100) = NULL,
	@batch_report_param VARCHAR(1000)  = NULL
	
AS

SET NOCOUNT ON


DECLARE @column_name_list VARCHAR(2000)

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
	IF EXISTS (SELECT 1 FROM time_series_definition tsd WHERE tsd.time_series_type_value_id = @series_type AND tsd.group_id IS NOT NULL)	
	BEGIN
	 SET @sql = 'SELECT	MAX(sdv.code) [series_type], 
						MAX(sdv2.code) [weather_data_name]
						, sdv2.value_id [weather_data_definition_id]
						--, sdv.value_id [type_id]
						, MAX(tsd.granulalrity) granulalrity
						, MAX(tsd.effective_date_applicable) effective_date_applicable
						, MAX(tsd.maturity_applicable) maturity_applicable
 
				FROM time_series_definition tsd
				INNER JOIN static_data_value sdv ON tsd.time_series_type_value_id = sdv.value_id
				INNER JOIN static_data_value sdv2 ON sdv2.type_id = tsd.group_id ' +
				+ CASE WHEN @series_type = '' THEN '' ELSE ' WHERE tsd.time_series_type_value_id = ''' +  CAST(@series_type AS VARCHAR) + '''' END +
				'GROUP BY sdv.value_id,sdv2.value_id'
	END
	ELSE
	BEGIN
		SET @sql = 'SELECT	sdv.code [series_type],
						NULL [weather_data_name]
						,NULL [weather_data_id]
						,NULL [type_id]
						FROM
						static_data_value sdv '
				+ CASE WHEN @series_type = '' THEN '' ELSE ' WHERE sdv.value_id = ''' +  CAST(@series_type AS VARCHAR) + '''' END +
				''
	END
	 
	EXEC(@sql) 
END


IF @flag = 'h'
BEGIN
	
	SET @sql = 'SELECT							
						tsd.time_series_definition_id [time_series_definition_id],
						tsd.time_series_name [time_series_name],
						tsd.time_series_id [time_series_id],
						tsd.time_series_description [description],
						sc.source_currency_id [currency],
						su.source_uom_id [uom],						
						tsd.static_data_type_id [static_data_type_id],
						CASE tsd.value_required  WHEN ''y'' THEN 1 ELSE 0 END [value_required]

				FROM time_series_definition tsd
				INNER JOIN static_data_value sdv ON tsd.time_series_type_value_id = sdv.value_id
				LEFT JOIN static_data_value sdv1 ON tsd.granulalrity = sdv1.value_id
				LEFT JOIN source_currency sc ON tsd.currency_id = sc.source_currency_id
				LEFT JOIN source_uom su ON tsd.uom_id = su.source_uom_id ' +
				+ CASE WHEN @series_type = '' THEN '' ELSE ' WHERE tsd.time_series_type_value_id = ''' +  CAST(@series_type AS VARCHAR) + '''' END

	EXEC spa_print @sql
	EXEC(@sql) 
END


IF @flag = 'i'
BEGIN
	DECLARE @idoc INT
	EXEC sp_xml_preparedocument @idoc OUTPUT, @xml
	
	SELECT * INTO #temp_time_series
	FROM   OPENXML(@idoc, 'Root/Grid/GridRow', 3)
			WITH (
				time_series_definition_id INT '@time_series_definition_id',
				time_series_id VARCHAR(100) '@series_id',
				time_series_name VARCHAR(100) '@time_series_name',
				time_series_description VARCHAR(100) '@description',
				time_series_type_value_id INT '@time_series_type_value_id',
				granulalrity INT '@granulalrity',
				uom_id INT '@uom',
				currency_id INT '@currency',
				effective_date_applicable CHAR(1) '@effective_date_applicable',
				maturity_applicable CHAR(1) '@maturity_applicable',
				static_data_type_id INT '@static_data',
				group_id INT '@group_id',
				value_required CHAR(1) '@value_required'
			)

	
	SELECT * INTO #temp_time_series_del
	FROM   OPENXML(@idoc, 'Root/GridDelete/GridRow', 3)
			WITH (
				time_series_definition_id VARCHAR(2000) '@time_series_definition_id'
			)
										
	BEGIN TRY
		
		IF EXISTS(SELECT 1 FROM 
			#temp_time_series tts 
				INNER JOIN  time_series_definition tsd ON (tsd.time_series_id = tts.time_series_id OR tsd.time_series_name = tts.time_series_name)
					AND tsd.time_series_type_value_id = @series_type AND tsd.time_series_definition_id <> tts.time_series_definition_id)
		BEGIN
			EXEC spa_ErrorHandler -1
				, 'time_series_definition'
				, 'spa_time_series'
				, 'Error' 
				, 'Duplicate data in (<b>Series Name/ID</b>) in <b>Series Definition</b> grid.'
				, ''
				
				RETURN
		END	
		
		IF EXISTS(SELECT 1
				FROM time_series_data tsd2
				INNER JOIN time_series_definition tsd ON tsd.time_series_definition_id = tsd2.time_series_definition_id
				INNER JOIN 
				(
					SELECT time_series_definition_id FROM #temp_time_series_del UNION ALL 
					SELECT time_series_definition_id FROM #temp_time_series 
				) ttsd ON ttsd.time_series_definition_id = tsd2.time_series_definition_id				
				WHERE tsd.time_series_type_value_id = @series_type AND tsd2.time_series_group = @group_id)
		BEGIN
			EXEC spa_ErrorHandler -1
				, 'time_series_definition'
				, 'spa_time_series'
				, 'Error' 
				, 'Please delete the series data values before change.'
				, ''
				
				RETURN
		END	
		
		BEGIN TRAN
			
		IF EXISTS (SELECT 1 FROM #temp_time_series WHERE time_series_definition_id = 0)
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
					static_data_type_id,
					group_id,
					value_required
				)
				SELECT  CASE tts.time_series_id WHEN '' THEN tts.time_series_name ELSE tts.time_series_id END,
						tts.time_series_name,
						CASE tts.time_series_description WHEN '' THEN tts.time_series_name ELSE tts.time_series_description END,						
						tts.time_series_type_value_id,
						tts.granulalrity,
						tts.uom_id,
						tts.currency_id,
						tts.effective_date_applicable,
						tts.maturity_applicable,
						CASE WHEN tts.static_data_type_id = 0 THEN NULL ELSE tts.static_data_type_id END,
						tts.group_id,
						tts.value_required
				FROM  #temp_time_series tts
				WHERE tts.time_series_definition_id = 0 AND tts.time_series_name <> ''
		END
		ELSE
		BEGIN

			UPDATE tsd 
				SET 
					time_series_id = CASE tts.time_series_id WHEN '' THEN tts.time_series_name ELSE tts.time_series_id END,
					time_series_name = tts.time_series_name,
					time_series_description = CASE tts.time_series_description WHEN '' THEN tts.time_series_name ELSE tts.time_series_description END,
					time_series_type_value_id = tts.time_series_type_value_id,
					granulalrity = tts.granulalrity,
					uom_id = tts.uom_id,
					currency_id = tts.currency_id,
					effective_date_applicable = tts.effective_date_applicable,
					maturity_applicable = tts.maturity_applicable,
					static_data_type_id = CASE WHEN tts.static_data_type_id = 0 THEN NULL ELSE tts.static_data_type_id END,
					group_id = tts.group_id,
					value_required = tts.value_required
				FROM #temp_time_series tts
				INNER JOIN time_series_definition tsd
				ON tts.time_series_definition_id = tsd.time_series_definition_id
				WHERE tts.time_series_definition_id > 0				
				

			DELETE tsd FROM time_series_definition tsd
			INNER JOIN #temp_time_series tts ON tts.time_series_definition_id = tsd.time_series_definition_id
			WHERE tts.time_series_id IS NULL OR tts.time_series_name = ''

		END
		
		UPDATE tsd 
				SET 
					granulalrity = @granularity,
					effective_date_applicable = @effective_date_applicable,
					maturity_applicable = @maturity_applicable,
					group_id = @group_id
				FROM time_series_definition tsd
				WHERE time_series_type_value_id = @series_type
				

		DELETE tsd FROM time_series_definition tsd
		INNER JOIN #temp_time_series_del ttsd ON ttsd.time_series_definition_id = tsd.time_series_definition_id
		
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

		SET @DESC = 'Fail to insert Data ( Errr Description:' + ERROR_MESSAGE() + ').'

		SELECT @err_no = ERROR_NUMBER()

		EXEC spa_ErrorHandler @err_no
			, 'time_series_definition'
			, 'spa_weather_data'
			, 'Error'
			, @DESC
			, ''
	END CATCH
END

IF @flag = 'd'
BEGIN
	BEGIN TRY
		DELETE FROM time_series_definition 
		WHERE time_series_definition_id IN (@time_series_definition_id) 

		EXEC spa_ErrorHandler 0
				, 'time_series_definition'
				, 'spa_weather_data'
				, 'Success' 
				, 'Changes have been saved successfully.'
				, ''
	END TRY
	BEGIN CATCH	
		SET @desc = dbo.FNAHandleDBError('10106100')
		EXEC spa_ErrorHandler -1, 'time_series_definition', 
					'spa_weather_data', 'Error', 
					@desc, ''
	END CATCH
END

IF @flag = 's'
BEGIN

	CREATE TABLE #temp_series_data
	(
		time_series_data_id INT,
		effective_date		VARCHAR(10) COLLATE DATABASE_DEFAULT,
		maturity			VARCHAR(10) COLLATE DATABASE_DEFAULT,
		[hour]				VARCHAR(5) COLLATE DATABASE_DEFAULT,
		[value]				VARCHAR(100),
		is_dst				INT,
		time_series_definition_id				INT,
		time_series_name				varchar(100) COLLATE DATABASE_DEFAULT
	)	

	--SELECT dbo.FNADateFormat(@effective_date)
	SET @sql = '
				INSERT INTO #temp_series_data (
					time_series_data_id,
					effective_date,
					maturity,
					[hour],
					[value],
					is_dst
					,time_series_definition_id
					,time_series_name

				)	
				SELECT	tsd.time_series_data_id,
						dbo.FNADateFormat(tsd.effective_date) [effective_date], 
						dbo.FNADateFormat(tsd.maturity) [maturity],
						CASE WHEN dbo.FNADateFormat(tsd.maturity) IS NOT NULL THEN
							RIGHT(''0'' + CONVERT(VARCHAR(2), DATEPART(HOUR, tsd.maturity)), 2) + '':'' + RIGHT(''0'' + CONVERT(VARCHAR(2), DATEPART(MI, tsd.maturity)), 2)
						ELSE '''' END AS [hour],'
					
			IF @for_batch = 'y'
			BEGIN
				SET @sql = @sql + 'CASE WHEN tsdd.static_data_type_id IS NULL THEN cast(ROUND(tsd.value,'+CAST(@round_value AS VARCHAR)+') as varchar) ELSE sdv.code END AS [value],'
			END	
			ELSE
			BEGIN
				SET @sql =	@sql + 'ROUND(tsd.value,'+CAST(@round_value AS VARCHAR)+') AS [value],'	
			END		
			SET @sql =	@sql +'	tsd.is_dst AS [is_dst]
						,tsd.time_series_definition_id [time_series_definition_id]
						,''['' + tsdd.time_series_name + '']'' time_series_name

				FROM time_series_data tsd
				left join time_series_definition tsdd on tsdd.time_series_definition_id = tsd.time_series_definition_id
				left join static_data_value sdv ON sdv.value_id = tsd.value
				WHERE tsd.time_series_group = ' + @time_series_definition_id
				+ ' AND tsd.curve_source_value_id = ' + @curve_source
				+ CASE WHEN @maturity_applicable = 'y' AND @tenor_from <> '' THEN ' AND tsd.maturity >= ''' +  @tenor_from + '''' ELSE '' END
				+ CASE WHEN @maturity_applicable = 'y' AND @tenor_to <> '' THEN ' AND tsd.maturity <= ''' +  @tenor_to + ' 23:59' + '''' ELSE '' END
				+ CASE WHEN @show_effective_data = 'n' THEN CASE WHEN @effective_date_applicable = 'y' AND @effective_date <> '' THEN ' AND tsd.effective_date ='''+CAST((SELECT CONVERT(DATETIME,MAX(effective_date),103) FROM time_series_data ts WHERE ts.time_series_group = @time_series_definition_id AND ts.effective_date <= @effective_date)  AS VARCHAR(200))+'''' ELSE '' END
					ELSE ' AND tsd.effective_date = ''' + @effective_date + '''' END
				+ ' ORDER BY tsd.effective_date, tsd.maturity'
	EXEC(@sql)
	DECLARE @column_name_list2 varchar(MAX) 
	DECLARE @column_name_list3 varchar(MAX) 
	DECLARE @process_table_name VARCHAR(500)

	SET @process_table_name = 'adiha_process.dbo.tmp_weather_data_' + dbo.FNAGetNewID()

	select 
		@column_name_list =  COALESCE(@column_name_list + ',', '') + '[' + replace(lower(tsd.time_series_name), ' ', '_' ) + ']'
		,@column_name_list3 =  COALESCE(@column_name_list3 + ',', '') + '[' + tsd.time_series_name + ']'			
		,@column_name_list2 =  COALESCE(@column_name_list2 + ',', '') + 'case when MAX(' + '[' + replace(lower(tsd.time_series_name), ' ', '_' ) + ']' + ') is null then '''' ELSE MAX(' + '[' + replace(lower(tsd.time_series_name), ' ', '_' ) + ']' + ') END' + '[' + replace(lower(tsd.time_series_name), ' ', '_' ) + ']'
	from time_series_definition tsd
	inner join static_data_type sdt on sdt.type_id = tsd.group_id
	inner join static_data_value sdv on sdv.type_id = sdt.type_id
	where sdv.value_id = @time_series_definition_id

	
	DECLARE @DynamicPivotQuery AS NVARCHAR(MAX)
	DECLARE @ColumnName AS VARCHAR(MAX)
		
	SET @ColumnName = @column_name_list

	SET @DynamicPivotQuery = 
				N'
				
				
				select 
					tsdd1.effective_date
					,tsdd1.maturity
					,tsdd1.[hour]
					,tsdd1.is_dst
					into #temp_series_common						
				 from 	  
				 #temp_series_data tsdd1				 
				group by tsdd1.effective_date
						,tsdd1.maturity
						,tsdd1.[hour]
						,tsdd1.is_dst				
				
				 				 
				select * 
				into
				#temp_series_common1
				from  #temp_series_common
				cross join dbo.SplitCommaSeperatedValues(''' + @column_name_list3 + ''') scsv
				
				--select * from #temp_series_common1
				
				--select * from #temp_series_data
															
				select 
					t2.time_series_data_id	
					,t1.effective_date	
					,t1.maturity	
					,t1.hour	
					,t2.value	
					,t1.is_dst	
					,t2.time_series_definition_id	
					,REPLACE(REPLACE(REPLACE(t1.item, '' '', ''_''), ''['',''''), '']'','''') time_series_name
					,ROW_NUMBER() OVER (Order by  t2.effective_date	
								,t1.maturity	
								,t1.hour	
								,t1.is_dst,tsd.time_series_definition_id) AS row_number
					,dense_rank() OVER (Order by  t2.effective_date	
								,t1.maturity	
								,t1.hour	
								,t1.is_dst) AS rank_number
					into #temp_series_data_pre
				from #temp_series_common1 t1
				LEFT join #temp_series_data t2 on  ISNULL(t1.effective_date,1) = ISNULL(t2.effective_date,1)
						AND ISNULL(t1.maturity,1) = ISNULL(t2.maturity,1)
						AND ISNULL(t1.[hour],1) = ISNULL(t2.[hour],1)
						AND ISNULL(t1.[is_dst],1) = ISNULL(t2.[is_dst],1)
						AND t1.item = t2.time_series_name
				LEFT JOIN time_series_definition tsd ON  t1.item = tsd.time_series_name AND tsd.time_series_type_value_id = ' + CAST(@series_type AS VARCHAR(10)) + '
	
				--select * from #temp_series_data_pre
				
				SELECT 
					time_series_data_id,
					effective_date,
					maturity,
					[hour],
					is_dst,
					row_number,
					' + @ColumnName + '
				into #temp_series_data1
				FROM #temp_series_data_pre t1
				PIVOT(MAX([value]) 
						FOR time_series_name IN (' + @ColumnName + ')) AS PVTTable
						
				--select * from #temp_series_data1
				
				SELECT 
					--STUFF((SELECT ''. '' + CAST(ISNULL(time_series_data_id,0) AS VARCHAR(10)) [text()]
					STUFF((SELECT ''. '' + CAST(time_series_data_id  AS VARCHAR(10)) [text()]
					FROM #temp_series_data1 
					WHERE ISNULL(effective_date,1) = ISNULL(t.effective_date,1)
						AND ISNULL(maturity,1) = ISNULL(t.maturity,1)
						AND ISNULL([hour],1) = ISNULL(t.[hour],1)
						AND ISNULL([is_dst],1) = ISNULL(t.[is_dst],1)
					       ORDER BY row_number
					FOR XML PATH(''''), TYPE)
				.value(''.'',''NVARCHAR(MAX)''),1,2,'' '') time_series_data_id
				,MAX(isnull(effective_date,''NULL'')) effective_date,
				MAX(maturity) maturity,
				MAX([hour]) [hour],					
				' + @column_name_list2 + '
				,MAX(is_dst) is_dst
			INTO ' + @process_table_name + '
			FROM #temp_series_data1 t
			GROUP BY 
				effective_date 
				,maturity
				,[hour]
				,[is_dst]
				
				--select * into adiha_process.dbo.test1 from #temp_series_data_pre
				--select  * into adiha_process.dbo.test2  from #temp_series_data1
			'
	--select  @ColumnName			
	--print @DynamicPivotQuery 

	EXEC sp_executesql @DynamicPivotQuery
	
	IF @for_batch IS NULL
	BEGIN
		SET @DynamicPivotQuery = 'SELECT * FROM ' + @process_table_name + 
									' ORDER BY effective_date,	maturity,	hour
									DROP TABLE ' + @process_table_name + ' '
		
		EXEC sp_executesql @DynamicPivotQuery
	END
	ELSE 
	BEGIN
		SET @sql = 'SELECT ' 
					+ CASE WHEN @effective_date_applicable = 'y' THEN 'tsd.effective_date [Effective From]' ELSE '' END + ',' 
					+ CASE WHEN @maturity_applicable = 'y' THEN 'tsd.maturity [Date]' ELSE '' END + ',' 
					+ CASE WHEN (@maturity_applicable = 'y' AND (@granularity = 987 OR @granularity = 989 OR @granularity = 982 OR @granularity = 980)) THEN 'tsd.hour [Hour]' ELSE '' END	+ ',' 
					+ @ColumnName + @str_batch_table + ' FROM ' + @process_table_name + ' tsd'
		EXEC(@sql)
		SET @DynamicPivotQuery = 'DROP TABLE ' + @process_table_name + ' '
		
		EXEC sp_executesql @DynamicPivotQuery

		IF @is_batch = 1
 		BEGIN
 			SELECT @str_batch_table = dbo.FNABatchProcess ('u', @batch_process_id, @batch_report_param, GETDATE(), NULL, NULL) 
 			EXEC (@str_batch_table)
			SELECT @str_batch_table = dbo.FNABatchProcess ('c', @batch_process_id, @batch_report_param, 
						   GETDATE(), 'spa_weather_data', ISNULL(@report_name,'Time Series')) 
			EXEC (@str_batch_table)
			RETURN
		END
	END
END

IF @flag = 't'
BEGIN
	BEGIN TRY
	/*
	select 
		sdv.code, sdv.value_id,
		tsd.time_series_definition_id, 
		replace(lower(tsd.time_series_name), ' ', '_' ) time_series_name
	from time_series_definition tsd
	inner join static_data_type sdt on sdt.type_id = tsd.group_id
	inner join static_data_value sdv on sdv.type_id = sdt.type_id
	where sdv.value_id = @time_series_definition_id
	return
	*/
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
					time_series_definition_id INT '@time_series_definition_id',
					time_series_group INT '@time_series_group'
				)

		SELECT * INTO #temp_series_values_del
		FROM   OPENXML(@idoc1, 'Root/GridDelete/GridRow', 3)
				WITH (
					time_series_data_id VARCHAR(2000) '@time_series_data_id'
				)
		
		--IF EXISTS (SELECT 1 FROM #temp_series_values WHERE time_series_data_id = 0)
		--BEGIN
			INSERT INTO time_series_data 
			(
				effective_date,
				maturity,
				curve_source_value_id,
				value,
				is_dst,
				time_series_definition_id,
				time_series_group
			)
			SELECT  CASE WHEN tsv.effective_from = '' THEN NULL ELSE dbo.FNAGetSQLStandardDateTime(tsv.effective_from) END,
					CASE WHEN tsv.[date] = '' THEN NULL ELSE dbo.FNAGetSQLStandardDateTime(DATEADD(mi,tsv.[hour],tsv.[date])) END,
					tsv.curve_source,
					tsv.curve_value,
					tsv.is_dst,
					tsv.time_series_definition_id,
					tsv.time_series_group
			FROM  #temp_series_values tsv
			WHERE tsv.time_series_data_id = 0 AND tsv.curve_value <> ''
		--END
		--ELSE
		--BEGIN
			UPDATE tsd 
			SET 
				effective_date = CASE WHEN tsv.effective_from = '' THEN NULL ELSE dbo.FNAGetSQLStandardDateTime(tsv.effective_from) END,
				maturity = CASE WHEN tsv.[date] = '' THEN NULL ELSE dbo.FNAGetSQLStandardDateTime(DATEADD(mi,tsv.[hour],tsv.[date])) END,
				curve_source_value_id = tsv.curve_source,
				value = tsv.curve_value,
				is_dst = tsv.is_dst,
				time_series_definition_id = tsv.time_series_definition_id,
				time_series_group = tsv.time_series_group
			FROM #temp_series_values tsv
			INNER JOIN time_series_data tsd
			ON tsv.time_series_data_id = tsd.time_series_data_id
			WHERE tsv.time_series_data_id > 0

			DELETE tsd FROM time_series_data tsd
			INNER JOIN #temp_series_values tsv ON tsv.time_series_data_id = tsd.time_series_data_id
			WHERE tsv.curve_value IS NULL OR tsv.curve_value = ''
		--END

		
		DECLARE @time_series_data_ids varchar(2000)
		DECLARE time_series_data_ids CURSOR FOR
		SELECT time_series_data_id FROM #temp_series_values_del tsvd

		OPEN time_series_data_ids
		FETCH NEXT FROM time_series_data_ids
		INTO @time_series_data_ids 
		WHILE @@FETCH_STATUS = 0
		BEGIN
			SET @sql = '
					DELETE tsd FROM time_series_data tsd WHERE time_series_data_id IN (' + @time_series_data_ids + ')'
			EXEC(@sql)

		FETCH NEXT FROM time_series_data_ids
			INTO @time_series_data_ids	
		END
		CLOSE time_series_data_ids
		DEALLOCATE time_series_data_ids
		
		EXEC spa_ErrorHandler 0
				, 'time_series_definition'
				, 'spa_weather_data'
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
			, 'spa_weather_data'
			, 'Error'
			, @DESC
			, ''
	END CATCH
END

ELSE IF @flag = 'c'
BEGIN
	IF EXISTS (SELECT 1
				FROM time_series_definition tsd
				INNER JOIN time_series_data tsd2 ON tsd2.time_series_definition_id = tsd.time_series_definition_id
				WHERE tsd.time_series_type_value_id = @series_type)
	BEGIN
		SELECT TOP 1 2, tsd.granulalrity, tsd.group_id, tsd.effective_date_applicable, tsd.maturity_applicable
		  FROM time_series_definition tsd WHERE tsd.time_series_type_value_id = @series_type AND tsd.group_id IS NOT null
	END	 
	ELSE IF EXISTS(SELECT 1 FROM time_series_definition WHERE time_series_type_value_id = @series_type)
	BEGIN
		SELECT TOP 1 1, tsd.granulalrity, tsd.group_id, tsd.effective_date_applicable, tsd.maturity_applicable
		  FROM time_series_definition tsd WHERE tsd.time_series_type_value_id = @series_type AND tsd.group_id IS NOT null
	END
	ELSE
	BEGIN
		SELECT 0
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

IF @flag = 'm' 
	BEGIN	
			
		DECLARE @column_label_list VARCHAR(2000)
		DECLARE @column_txt_align_list VARCHAR(2000)
		DECLARE @column_type_list VARCHAR(2000)
		DECLARE @column_visibility VARCHAR(2000)
		DECLARE @header_styles VARCHAR(2000)
		DECLARE @column_width VARCHAR(5000)
		DECLARE @column_validator VARCHAR(5000)

		--DECLARE @sql_stmt VARCHAR(5000)
		DECLARE @dropdown_columns VARCHAR(2000)
		DECLARE @combo_sql VARCHAR(8000)
		DECLARE @column_id VARCHAR(8000)
		DECLARE @id VARCHAR(8000)
		DECLARE @eff_date_applicable char(1)
		DECLARE @mat_applicable char(1)
		DECLARE @granularity_val varchar(20)
		DECLARE @definition_ids varchar(2000)   

		
		SET @column_name_list = 'Time Series Data ID, Effective From,Date,Hour'
		SET @column_id = 'time_series_data_id,effective_from,date,hour'
		SET @column_type_list = 'ro,dhxCalendarA,dhxCalendarA,ed'
		SET @column_width = '150,150,150,150'
		SET @column_txt_align_list = 'left,left,left,left'
		SET @column_visibility = 'true,false,true,false'
		SET @header_styles = '["text-align:left;","text-align:left;","text-align:left;","text-align:left;"'
		SET @column_validator = 'NotEmpty,NotEmpty,NotEmpty,NotEmpty'

		select 
			 @column_name_list =  COALESCE(@column_name_list + ',', '') + tsd.time_series_name 
			 ,@column_txt_align_list = COALESCE(@column_txt_align_list + ',', '') + 'right'
			 ,@column_id = COALESCE(@column_id + ',', '') + replace(lower(tsd.time_series_name), ' ', '_' )
			 ,@column_type_list = COALESCE(@column_type_list + ',', '') + CASE WHEN tsd.static_data_type_id IS NULL THEN 'ed' ELSE 'combo' END
			 ,@column_width = COALESCE(@column_width + ',', '') + CAST(150 AS VARCHAR(500))
			 ,@column_visibility = COALESCE(@column_visibility + ',', '') + 'false'
			 ,@header_styles = COALESCE(@header_styles + ',', '') + '"text-align:right;"'
			 ,@column_validator = COALESCE(@column_validator + ',', '') + CASE tsd.value_required WHEN 'y' THEN 'ValidNumeric' ELSE '' END
			 ,@eff_date_applicable = tsd.effective_date_applicable
			 ,@mat_applicable = tsd.maturity_applicable
			 ,@granularity_val = tsd.granulalrity
			 ,@definition_ids = COALESCE(@definition_ids + ',', '') + CAST(tsd.time_series_definition_id AS VARCHAR(20)) + ':' + replace(lower(tsd.time_series_name), ' ', '_' )
		from
		 time_series_definition tsd
		 inner join static_data_type sdt on sdt.type_id = tsd.group_id
		 inner join static_data_value sdv on sdv.type_id = sdt.type_id
		 where sdv.value_id = CAST(@time_series_definition_id AS INT)
		 
		 SELECT @dropdown_columns = COALESCE(@dropdown_columns + ',', '') + replace(lower(tsd.time_series_name), ' ', '_' )
		,  @combo_sql = COALESCE(@combo_sql + ':', '') + 'SELECT value_id, code from static_data_value where type_id = ' + CAST(tsd.static_data_type_id AS VARCHAR(10))
		FROM time_series_definition tsd
		 inner join static_data_type sdt on sdt.type_id = tsd.group_id
		 inner join static_data_value sdv on sdv.type_id = sdt.type_id
		 where sdv.value_id = CAST(@time_series_definition_id AS INT) AND tsd.static_data_type_id IS NOT NULL
		 		 
		 SELECT  
			@column_name_list + ',DST' name_list, 
			@column_txt_align_list + ',center' column_align, 
			@column_id + ',is_dst' column_id, 
			@column_type_list + ',ro' field_type, 
			@column_width + ',150' width, 
			@column_visibility + ',true' column_visibility,
			@header_styles + ',"text-align:center;"]' header_styles,
			@column_validator + ',NotEmpty' column_validator,
			@dropdown_columns combo_columns,
			@combo_sql combo_sql,
			@eff_date_applicable effective_date_applicable,
			@mat_applicable maturity_applicable,
			@granularity_val granularity,
			@definition_ids definition_ids 	 	
		 		
	END
