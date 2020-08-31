BEGIN TRY
		BEGIN TRAN
	
	declare @new_ds_alias varchar(10) = '21400'
	/** IF DATA SOURCE ALIAS ALREADY EXISTS ON DESTINATION, RAISE ERROR **/
	if exists(select top 1 1 from data_source where alias = '21400' and name <> '21400')
	begin
		select top 1 @new_ds_alias = '21400' + cast(s.n as varchar(5))
		from seq s
		left join data_source ds on ds.alias = '21400' + cast(s.n as varchar(5))
		where ds.data_source_id is null
			and s.n < 10

		--RAISERROR ('Datasource alias already exists on system.', 16, 1);
	end

	DECLARE @report_id_data_source_dest INT 
	
	SELECT @report_id_data_source_dest = report_id
	FROM report r
	WHERE r.[name] = NULL
	IF NOT EXISTS (SELECT 1 
	           FROM data_source 
	           WHERE [name] = '21400'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	AND NOT EXISTS (SELECT 1 FROM map_function_category WHERE [function_name] = '21400' AND '106504' = '106501') 
	BEGIN
		INSERT INTO data_source([type_id], [name], [alias], [description], [tsql], report_id, system_defined,category)
		SELECT TOP 1 1 AS [type_id], '21400' AS [name], @new_ds_alias AS ALIAS, 'File Filter' AS [description],null AS [tsql], @report_id_data_source_dest AS report_id,'0' AS [system_defined]
			,'106504' AS [category]
	END

	UPDATE data_source
	SET alias = @new_ds_alias, description = 'File Filter'
	, [tsql] = CAST('' AS VARCHAR(MAX)) + '
DECLARE @_ixp_rules_id VARCHAR(20) 
DECLARE @_folder_location VARCHAR(1000)
DECLARE @_is_ftp VARCHAR(20) = ''-1''

--SET @_ixp_rules_id = ''14084''
--SET @_folder_location = ''C://''
IF ''@ixp_rules_id''<>''NULL''
    SET @_ixp_rules_id = ''@ixp_rules_id''

IF ''@folder_location'' <> ''NULL''
	SET @_folder_location = ''@folder_location''

IF ''@is_ftp'' <> ''NULL''
	SET @_is_ftp = ''@is_ftp''
	
DECLARE @_sql VARCHAR(MAX), @_final_sql VARCHAR(MAX) = ''''

IF OBJECT_ID(''tempdb..#filename_list'') IS NOT NULL
	DROP TABLE #filename_list
CREATE TABLE #filename_list ([filename] VARCHAR(1000))

SET @_sql = ''SELECT ff.[filename] FROM dbo.FNAListFiles('''''' + @_folder_location + '''''', ''''*.*'''', ''''n'''') ff WHERE 1=1 ''

SELECT  @_final_sql = @_final_sql + CASE WHEN @_final_sql = '''' THEN '''' ELSE '' UNION ALL '' END + @_sql + '' '' + 
	STUFF((
     SELECT '''' + CASE 
		WHEN tmp.filter_id = IIF(@_is_ftp = 1, 112211, 112213) THEN '' AND ff.[filename] LIKE '''''' + @_folder_location + ''\'' + tmp.filter_value + ''%''''''
		WHEN tmp.filter_id = IIF(@_is_ftp = 1, 112212, 112214) THEN '' AND ff.[filename] LIKE ''''%'' + tmp.filter_value + ''''''''
		ELSE '''' END
        FROM ixp_import_filter tmp
		WHERE tmp.ixp_rules_id = @_ixp_rules_id
		AND tmp.filter_group = ixp.filter_group
        FOR XML PATH('''')
     ), 1, 1, '''')
FROM ixp_import_filter ixp
WHERE ixp_rules_id = @_ixp_rules_id
	AND ixp_import_data_source = IIF(@_is_ftp = 1, -1, 21400)
GROUP BY filter_group

IF NULLIF(@_final_sql, '''') IS NULL
	SET @_final_sql = @_sql

SET @_final_sql = ''INSERT INTO #filename_list ([filename]) '' + @_final_sql


EXEC (@_final_sql)


SET @_final_sql = ''SELECT * 
	--[__batch_report__] 
	FROM #filename_list''
EXEC(@_final_sql)
', report_id = @report_id_data_source_dest,
	system_defined = '0'
	,category = '106504' 
	WHERE [name] = '21400'
		AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1)
		
	
	IF OBJECT_ID('tempdb..#data_source_column', 'U') IS NOT NULL
		DROP TABLE #data_source_column	
	CREATE TABLE #data_source_column(column_id INT)	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = '21400'
	            AND dsc.name =  'filename'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Filename'
			   , reqd_param = NULL, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 0, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = '21400'
			AND dsc.name =  'filename'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'filename' AS [name], 'Filename' AS ALIAS, NULL AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = '21400'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	DELETE dsc
	FROM data_source_column dsc 
	INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		AND ds.[name] = '21400'
		AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1)
	LEFT JOIN #data_source_column tdsc ON tdsc.column_id = dsc.data_source_column_id
	WHERE tdsc.column_id IS NULL
	COMMIT TRAN

	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
			ROLLBACK TRAN;
		
			DECLARE @error_msg VARCHAR(1000)
             	SET @error_msg = ERROR_MESSAGE()
             	RAISERROR (@error_msg, 16, 1);
	END CATCH
	
	IF OBJECT_ID('tempdb..#data_source_column', 'U') IS NOT NULL
		DROP TABLE #data_source_column