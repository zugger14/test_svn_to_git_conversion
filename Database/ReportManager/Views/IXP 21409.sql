BEGIN TRY
		BEGIN TRAN
	
	declare @new_ds_alias varchar(10) = 'im'
	/** IF DATA SOURCE ALIAS ALREADY EXISTS ON DESTINATION, RAISE ERROR **/
	if exists(select top 1 1 from data_source where alias = 'im' and name <> '21409')
	begin
		select top 1 @new_ds_alias = 'im' + cast(s.n as varchar(5))
		from seq s
		left join data_source ds on ds.alias = 'im' + cast(s.n as varchar(5))
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
	           WHERE [name] = '21409'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	AND NOT EXISTS (SELECT 1 FROM map_function_category WHERE [function_name] = '21409' AND '106504' = '106501') 
	BEGIN
		INSERT INTO data_source([type_id], [name], [alias], [description], [tsql], report_id, system_defined,category)
		SELECT TOP 1 1 AS [type_id], '21409' AS [name], @new_ds_alias AS ALIAS, 'Email Import Filter' AS [description],null AS [tsql], @report_id_data_source_dest AS report_id,'0' AS [system_defined]
			,'106504' AS [category]
	END

	UPDATE data_source
	SET alias = @new_ds_alias, description = 'Email Import Filter'
	, [tsql] = CAST('' AS VARCHAR(MAX)) + '
DECLARE @_ixp_rules_id VARCHAR(20) 
--SET @_ixp_rules_id = 14178
IF ''@ixp_rules_id''<>''NULL''
    SET @_ixp_rules_id = ''@ixp_rules_id''
	
DECLARE @_sql VARCHAR(MAX), @_final_sql VARCHAR(MAX) = ''''
IF OBJECT_ID(''tempdb..#email_notes_list'') IS NOT NULL
	DROP TABLE #email_notes_list
CREATE TABLE #email_notes_list (notes_id INT)
SET @_sql = ''SELECT DISTINCT en.notes_id 
    FROM email_notes en 
	INNER JOIN attachment_detail_info adi ON en.notes_id = adi.email_id
	OUTER APPLY (SELECT item [send_to_val] FROM dbo.SplitCommaSeperatedValues(REPLACE(send_to,'''';'''','''',''''))) send_to
	OUTER APPLY (SELECT item [send_cc_val] FROM dbo.SplitCommaSeperatedValues(REPLACE(send_cc,'''';'''','''',''''))) send_cc
	OUTER APPLY (SELECT item [send_bcc_val] FROM dbo.SplitCommaSeperatedValues(REPLACE(send_bcc,'''';'''','''',''''))) send_bcc
	WHERE email_type = ''''i'''' AND ISNULL(is_imported,''''n'''') = ''''n''''''
SELECT  @_final_sql = @_final_sql + CASE WHEN @_final_sql = '''' THEN '''' ELSE '' UNION ALL '' END + @_sql + '' '' + 
	STUFF((
     SELECT '''' + CASE 
		WHEN tmp.filter_id = 112200 THEN '' AND send_from IN ('''''' + REPLACE(tmp.filter_value,'';'','''''','''''') + '''''')''
		WHEN tmp.filter_id = 112203 THEN '' AND send_to.send_to_val IN ('''''' + REPLACE(tmp.filter_value,'';'','''''','''''') + '''''')''
		WHEN tmp.filter_id = 112204 THEN '' AND send_cc.send_cc_val IN ('''''' + REPLACE(tmp.filter_value,'';'','''''','''''') + '''''')''
		WHEN tmp.filter_id = 112205 THEN '' AND send_bcc.send_bcc_val IN ('''''' + REPLACE(tmp.filter_value,'';'','''''','''''') + '''''')''
		WHEN tmp.filter_id = 112201 THEN '' AND notes_subject LIKE ''''%'' + tmp.filter_value + ''%''''''
		WHEN tmp.filter_id = 112202 THEN '' AND notes_text LIKE ''''%'' + tmp.filter_value + ''%''''''
		WHEN tmp.filter_id = 112206 THEN '' AND attachment_file_size = '''''' + tmp.filter_value + ''''''''
		WHEN tmp.filter_id = 112207 THEN '' AND attachment_file_size < '''''' + tmp.filter_value + ''''''''
		WHEN tmp.filter_id = 112208 THEN '' AND attachment_file_size > '''''' + tmp.filter_value + ''''''''
		WHEN tmp.filter_id = 112209 THEN '' AND attachment_file_ext = '''''' + tmp.filter_value + ''''''''
		WHEN tmp.filter_id = 112210 THEN '' AND adi.attachment_file_name LIKE ''''%'' + tmp.filter_value + ''''''%''
		ELSE '''' END
        FROM ixp_import_filter tmp
		WHERE tmp.ixp_rules_id = @_ixp_rules_id
		AND tmp.filter_group = ixp.filter_group
        FOR XML PATH('''') , TYPE).value(''.'', ''VARCHAR(MAX)''
     ), 1, 1, '''')
FROM ixp_import_filter ixp
WHERE ixp_rules_id = @_ixp_rules_id
	AND ixp_import_data_source = 21409
GROUP BY filter_group
IF ISNULL(@_final_sql,'''') = ''''
	SET @_final_sql = ''SELECT 1 WHERE 1=2''
SET @_final_sql = ''INSERT INTO #email_notes_list (notes_id) '' + @_final_sql
EXEC (@_final_sql)
SET @_final_sql = ''SELECT * 
	--[__batch_report__] 
	FROM #email_notes_list''
EXEC(@_final_sql)
', report_id = @report_id_data_source_dest,
	system_defined = '0'
	,category = '106504' 
	WHERE [name] = '21409'
		AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1)
		
	
	IF OBJECT_ID('tempdb..#data_source_column', 'U') IS NOT NULL
		DROP TABLE #data_source_column	
	CREATE TABLE #data_source_column(column_id INT)	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = '21409'
	            AND dsc.name =  'notes_id'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Notes Id'
			   , reqd_param = NULL, widget_id = 1, datatype_id = 4, param_data_source = NULL, param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 2, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = '21409'
			AND dsc.name =  'notes_id'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'notes_id' AS [name], 'Notes Id' AS ALIAS, NULL AS reqd_param, 1 AS widget_id, 4 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = '21409'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	DELETE dsc
	FROM data_source_column dsc 
	INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		AND ds.[name] = '21409'
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