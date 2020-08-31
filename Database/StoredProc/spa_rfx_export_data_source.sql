IF OBJECT_ID(N'[dbo].[spa_rfx_export_data_source]', N'P') IS NOT NULL
   DROP PROCEDURE [dbo].[spa_rfx_export_data_source]
GO
 
SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
-- ===========================================================================================================
-- Author: sssingh@pioneersolutionsglobal.com
-- Create date: 2012-10-3
-- Description: Export logic of data_source
 
-- Params:
--@data_source_names	VARCHAR(MAX) : CSV values of data_sources
--@report_name		VARCHAR(100) : name of the report
--@mode				VARCHAR(2)	 : e = Export ,c = Copy

/*
* The @data_source_names parameter  will only be provided while exporting data_source of View and Table Type.
* The @report_name parameter will be provided while exporting data_source of SQL reports
*/


-- ===========================================================================================================
CREATE PROCEDURE [dbo].[spa_rfx_export_data_source]
	@data_source_names	VARCHAR(MAX),	--View & Table names in CSV format
	@report_name		VARCHAR(100) = NULL	,--report name so that all of its SQL sources are exported
	@mode				VARCHAR(2) = 'e',
	@is_report_export   VARCHAR(2) = 'n' --'y' if called from spa_rfx_export_report else 'n'

AS
/*-------------------------------------------------Test Script-------------------------------------------------------*/
/*
 DECLARE
 	@data_source_names	VARCHAR(MAX),
	@report_name		VARCHAR(100),
	@mode				VARCHAR(2) = 'e',
	@is_report_export   VARCHAR(2) = 'y'
	
	--SET @report_name = 'MTM'
	SET @report_name = 'Earning Report'
	--SET @data_source_names = 'MTM_view,Settlement_View,Deal_Header_View,Deal_Detail_View,Deal_Detail_Table,Deal_Header_Table,Source_Price_Curve_Def,Source_Price_curve'
	--SET @data_source_names = 'source_deal_header1' 

	IF OBJECT_ID('tempdb..#final_query') IS NOT NULL
		DROP TABLE #final_query
	
	IF OBJECT_ID('tempdb..#data_source', 'U') IS NOT NULL
		DROP TABLE #data_source

--*/
--/*-------------------------------------------------Test Script END -------------------------------------------------------*/
BEGIN
	DECLARE @report_id_src INT 
	
	SELECT @report_id_src = report_id
	FROM report r
	WHERE r.[name] = @report_name
	
	CREATE TABLE #final_query(row_id INT IDENTITY(1, 1), line_query VARCHAR(MAX) COLLATE DATABASE_DEFAULT)
	 
	CREATE TABLE #data_source(
		data_source_name VARCHAR(200) COLLATE DATABASE_DEFAULT
		, report_id_src INT
	)
	
	--collect all data sources to be exported (View, Sql, Table)
	INSERT INTO #data_source(data_source_name, report_id_src)
	SELECT item, NULL FROM dbo.splitcommaseperatedvalues(@data_source_names)
	UNION
	SELECT ds.name, r.report_id
	FROM data_source ds
	INNER JOIN report r ON r.report_id = ds.report_id
	WHERE r.report_id =  @report_id_src
		 --AND @data_source_names IS NULL
		 	
	INSERT INTO #final_query (line_query)
	SELECT 'BEGIN TRY
		BEGIN TRAN
	'

	declare @ds_alias varchar(100)
	SELECT top 1 @ds_alias =  ds.alias, @data_source_names = dst.data_source_name 
	from data_source ds
	inner join #data_source dst on dst.data_source_name = ds.name
		
	INSERT INTO #final_query (line_query)
	SELECT 
	'
	declare @new_ds_alias varchar(10) = ''' + @ds_alias + '''
	/** IF DATA SOURCE ALIAS ALREADY EXISTS ON DESTINATION, RAISE ERROR **/
	if exists(select top 1 1 from data_source where alias = ''' + @ds_alias + ''' and name <> ''' + @data_source_names + ''')
	begin
		select top 1 @new_ds_alias = ''' + @ds_alias + ''' + cast(s.n as varchar(5))
		from seq s
		left join data_source ds on ds.alias = ''' + @ds_alias + ''' + cast(s.n as varchar(5))
		where ds.data_source_id is null
			and s.n < 10

		--RAISERROR (''Datasource alias already exists on system.'', 16, 1);
	end

	DECLARE @report_id_data_source_dest INT 
	
	SELECT @report_id_data_source_dest = report_id
	FROM report r
	WHERE r.[name] = ' + ISNULL('''' + CASE WHEN @mode = 'e' THEN @report_name ELSE 'Copy of '+ @report_name END  + '''', 'NULL')
	from #data_source ds
	
	--DECLARE @tsql_length INT
	
	--SELECT @tsql_length = LEN([tsql]) 
	--FROM data_source ds
	--INNER JOIN #data_source tds ON tds.data_source_name = ds.[name]
	--	AND ISNULL(ds.report_id, -1) = ISNULL(tds.report_id_src, -1)
	--LEFT JOIN report r ON r.report_id = ISNULL(ds.report_id, r.report_id)
	--	AND ds.[type_id] = 2
	
	
	INSERT INTO #final_query (line_query)
	SELECT 
	'
	IF NOT EXISTS (SELECT 1 
	           FROM data_source 
	           WHERE [name] = ''' + ds.[name] + '''
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	AND NOT EXISTS (SELECT 1 FROM map_function_category WHERE [function_name] = ''' + ds.[name] + ''' AND ''' + ISNULL('' + CAST(ds.[category] AS VARCHAR(20)) + '', '106500') + ''' = ''106501'') 
	BEGIN
		INSERT INTO data_source([type_id], [name], [alias], [description], [tsql], report_id, system_defined,category)
		SELECT TOP 1 ' + CAST(ds.[type_id] AS VARCHAR(10)) + ' AS [type_id], ''' + ds.name + ''' AS [name], @new_ds_alias AS ALIAS, ' + ISNULL('''' + ds.[description] + '''', 'NULL') + ' AS [description],null AS [tsql], @report_id_data_source_dest AS report_id,' + ISNULL('''' + CAST(ds.[system_defined] AS VARCHAR(10)) + '''', 'NULL') + ' AS [system_defined]
			,' + ISNULL('''' + CAST(ds.[category] AS VARCHAR(20)) + '''', '106500') + ' AS [category]
	END

	UPDATE data_source
	SET alias = @new_ds_alias, description = ' + ISNULL('''' + ds.[description] + '''', 'NULL') + '
	, [tsql] = CAST('''' AS VARCHAR(MAX)) + ''' + 
	--TODO: This works for SQL Server 2012 onwards only as it preservs new line chars when selecting.
	--We still need to find some solution for 2008
	--CASE WHEN @tsql_length >8000 THEN 'Please Copy the view code from the export file'
	--	ELSE
				--TODO: SQL 2012 preserves new line, so no need to replace with CHAR() functions
				--REPLACE(
				--	REPLACE(
				--		REPLACE(
							REPLACE(ISNULL(ds.[tsql], ''), '''', '''''')
				--		, CHAR(9), ''' + CHAR(9) + ''')
				--	, CHAR(10), ''' + CHAR(10) + ''')
				--, CHAR(13), ''' + CHAR(13) + ''') 
				--END
			
	+ ''', report_id = @report_id_data_source_dest,
	system_defined = ' + ISNULL('''' + CAST(ds.[system_defined] AS VARCHAR(10)) + '''', 'NULL') + '
	,category = ' + ISNULL('''' + CAST(ds.[category] AS VARCHAR(20)) + '''', '106500') + ' 
	WHERE [name] = ''' + ds.[name] + '''
		AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1)
		
	'
	FROM data_source ds
	INNER JOIN #data_source tds ON tds.data_source_name = ds.[name]
		AND ISNULL(ds.report_id, -1) = ISNULL(tds.report_id_src, -1)
	LEFT JOIN report r ON r.report_id = ISNULL(ds.report_id, r.report_id)
		AND ds.[type_id] = 2
	 --Alert definition 
	INSERT INTO #final_query(line_query)
	SELECT
	'
	IF (' + CAST(ds.category AS VARCHAR) + ' = 106502)
	BEGIN
		DECLARE @new_data_source_id INT
		SELECT  @new_data_source_id = data_source_id FROM data_source WHERE [name] = ''' + ds.[name] + '''

		IF NOT EXISTS (SELECT 1 FROM alert_table_definition atd INNER JOIN data_source ds ON atd.logical_table_name = ds.name WHERE ds.name = ''' + ISNULL(atd.logical_table_name,'-1') + ''')
		BEGIN
			INSERT INTO alert_table_definition (logical_table_name, physical_table_name, data_source_id, is_action_view, primary_column)
			SELECT ''' + atd.logical_table_name + ''',''' + atd.physical_table_name + ''',@new_data_source_id,''' + atd.is_action_view + ''',''' + atd.primary_column + '''
		END
		ELSE 
		BEGIN
			UPDATE alert_table_definition
			SET data_source_id = @new_data_source_id,
				is_action_view = ''' + atd.is_action_view + ''',
				primary_column = ''' + atd.primary_column + ''',
				physical_table_name  = ''' + atd.physical_table_name +'''
			WHERE logical_table_name = ''' + atd.logical_table_name + '''
		END
		IF NOT EXISTS (
		SELECT 1
		FROM workflow_module_rule_table_mapping wmrtm
		INNER JOIN alert_table_definition atd
			ON wmrtm.rule_table_id = atd.alert_table_definition_id
		WHERE atd.logical_table_name = ''' + ds.[name] + '''
		)
		BEGIN
			INSERT INTO workflow_module_rule_table_mapping (
				module_id
				, rule_table_id
				, is_active
				)
			SELECT ' + CAST(wmrtm.module_id AS varchar(20)) + ' , atd.alert_table_definition_id, 1 
			FROM alert_table_definition atd
		    WHERE atd.logical_table_name = ''' + ds.[name] + '''

		END
	 ELSE
		BEGIN
			UPDATE wmrtm
			SET wmrtm.module_id = ' + CAST(wmrtm.module_id AS varchar(20)) + '
			FROM workflow_module_rule_table_mapping wmrtm
			INNER JOIN alert_table_definition atd
				ON wmrtm.rule_table_id = atd.alert_table_definition_id
			WHERE atd.logical_table_name = ''' + ds.[name] + '''
		END
	END	
	'
	FROM data_source ds
	INNER JOIN #data_source tds ON tds.data_source_name = ds.[name]
	INNER JOIN alert_table_definition atd ON atd.data_source_id = ds.data_source_id
	INNER JOIN workflow_module_rule_table_mapping wmrtm ON wmrtm.rule_table_id = atd.alert_table_definition_id
	
	--store inserted columns. All other columns other than these should be deleted
	INSERT INTO #final_query (line_query)
	SELECT 
	'
	IF OBJECT_ID(''tempdb..#data_source_column'', ''U'') IS NOT NULL
		DROP TABLE #data_source_column	
	CREATE TABLE #data_source_column(column_id INT)	'	
	
	--migrate data_source_columns
	INSERT INTO #final_query (line_query)
	SELECT 
	'
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = ''' + ds.[name] + '''
	            AND dsc.name =  ''' + dsc.name  + '''
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = ''' + dsc.alias + '''
			   , reqd_param = ' + ISNULL(CAST(dsc.reqd_param AS VARCHAR(10)), 'NULL') 
			+ ', widget_id = ' + ISNULL(CAST(dsc.widget_id AS VARCHAR(10)), 'NULL') 
			+ ', datatype_id = ' + ISNULL(CAST(dsc.datatype_id AS VARCHAR(10)) , 'NULL') 
			+ ', param_data_source = ' +  
				REPLACE(
						REPLACE(
							REPLACE(
								ISNULL('''' + NULLIF(REPLACE(dsc.param_data_source, '''', ''''''), '') + '''', 'NULL')
							, CHAR(9), ''' + CHAR(9) + ''')
						, CHAR(10), ''' + CHAR(10) + ''')
					, CHAR(13), ''' + CHAR(13) + ''') 
			+ ', param_default_value = ' + ISNULL('''' + NULLIF(dsc.param_default_value, '') + '''' , 'NULL') 
			+ ', append_filter = ' + ISNULL(CAST(dsc.append_filter AS VARCHAR(10)), 'NULL')	+ 
			+ ', tooltip = ' + ISNULL('''' + NULLIF(dsc.tooltip,'') + '''', 'NULL')	+ 
			+ ', column_template = ' + ISNULL(CAST(dsc.column_template AS VARCHAR(10)) , 'NULL') +
			+ ', key_column = ' + ISNULL(CAST(dsc.key_column AS VARCHAR(10)) , 'NULL') + 
			+ ', required_filter = ' + ISNULL(CAST(dsc.required_filter AS VARCHAR(10)) , 'NULL') + '
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = ''' + ds.[name] + '''
			AND dsc.name =  ''' + dsc.name  + '''
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, ''' + dsc.name + ''' AS [name], ''' + dsc.alias + ''' AS ALIAS, ' + ISNULL(CAST(dsc.reqd_param AS VARCHAR(10)), 'NULL') + ' AS reqd_param, ' 
		+ ISNULL(CAST(dsc.widget_id AS VARCHAR(10)), 'NULL') + ' AS widget_id, ' +  ISNULL(CAST(dsc.datatype_id AS VARCHAR(10)) , 'NULL') + ' AS datatype_id, ' 
		+ REPLACE(
						REPLACE(
							REPLACE(
								ISNULL('''' + NULLIF(REPLACE(dsc.param_data_source, '''', ''''''), '') + '''', 'NULL')
							, CHAR(9), ''' + CHAR(9) + ''')
						, CHAR(10), ''' + CHAR(10) + ''')
					, CHAR(13), ''' + CHAR(13) + ''')  + ' AS param_data_source, ' 
		+ ISNULL('''' + NULLIF(dsc.param_default_value, '') + '''' , 'NULL') + ' AS param_default_value, '
		+ ISNULL(CAST(dsc.append_filter AS VARCHAR(10)), 'NULL') + ' AS append_filter, '
		+ ISNULL('''' + NULLIF(dsc.tooltip,'') + '''', 'NULL')	 + '  AS tooltip,'
		+ ISNULL(CAST(dsc.column_template AS VARCHAR(10)) , 'NULL') + ' AS column_template, '
		+ ISNULL(CAST(dsc.key_column AS VARCHAR(10)) , 'NULL') + ' AS key_column, '
		+ ISNULL(CAST(dsc.required_filter AS VARCHAR(10)) , 'NULL') + ' AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = ''' + ds.name + '''
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	'
	FROM data_source_column dsc
	INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id
	INNER JOIN #data_source tds ON tds.data_source_name = ds.[name]
		AND ISNULL(ds.report_id, -1) = ISNULL(tds.report_id_src, -1)
	LEFT JOIN report r ON r.report_id = ISNULL(ds.report_id, r.report_id)
		AND ds.[type_id] = 2
		
	
	--delete removed columns
	--migrate data_source_columns
	INSERT INTO #final_query (line_query)
	SELECT 
	'
	DELETE dsc
	FROM data_source_column dsc 
	INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		AND ds.[name] = ''' + ds.[name] + '''
		AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1)
	LEFT JOIN #data_source_column tdsc ON tdsc.column_id = dsc.data_source_column_id
	WHERE tdsc.column_id IS NULL
	'
	FROM data_source ds
	INNER JOIN #data_source tds ON tds.data_source_name = ds.[name]
		AND ISNULL(ds.report_id, -1) = ISNULL(tds.report_id_src, -1)
	LEFT JOIN report r ON r.report_id = ISNULL(ds.report_id, r.report_id)
		AND ds.[type_id] = 2
		
	INSERT INTO #final_query (line_query)
	SELECT 'COMMIT TRAN' + CHAR(10) + '
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
			ROLLBACK TRAN;
		
			DECLARE @error_msg VARCHAR(1000)
             	SET @error_msg = ERROR_MESSAGE()
             	RAISERROR (@error_msg, 16, 1);
	END CATCH
	
	IF OBJECT_ID(''tempdb..#data_source_column'', ''U'') IS NOT NULL
		DROP TABLE #data_source_column	
	'
	
	/*
	SSMS Grid view limits character upto 65535 chars only, thus truncating the display when this limit is exceeded even
	if the data itself isn't truncated. Using XML type doesn't have such limit if property 
	Query Results > SQL Server > Result to Grid > XML Data = Unlimited
	Clicking the xml data will open the actual data in the new window.
	
	Used XML PATH('') with TYPE so that no encoding is made
	Actual Data is wrapped with xml tag <? .. ?>
	*/

	IF @is_report_export = 'n'
	BEGIN
		IF EXISTS (SELECT 1 FROM #final_query WHERE LEN(line_query) > 8000)
		BEGIN
			SELECT STUFF(
				(
					SELECT '' + line_query
					FROM   #final_query fq
					ORDER BY
							fq.row_id 
							FOR XML PATH(''),
							TYPE
				).value('.[1]', 'VARCHAR(MAX)'),
				1,
				0,
				''
			) AS [processing-instruction(x)] FOR XML PATH(''), TYPE;

		END
		ELSE
		BEGIN
			SELECT line_query FROM #final_query AS query
			ORDER BY row_id 
		END
	END
	ELSE 
	BEGIN
		SELECT line_query FROM #final_query AS query
		ORDER BY row_id 
	END
END

