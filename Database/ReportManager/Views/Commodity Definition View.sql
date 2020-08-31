BEGIN TRY
		BEGIN TRAN
	

	DECLARE @report_id_data_source_dest INT 
	
	SELECT @report_id_data_source_dest = report_id
	FROM report r
	WHERE r.[name] = NULL

	IF NOT EXISTS (SELECT 1 
	           FROM data_source 
	           WHERE [name] = 'Commodity Definition View'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	AND NOT EXISTS (SELECT 1 FROM map_function_category WHERE [function_name] = 'Commodity Definition View' AND '106500' = '106501') 
	BEGIN
		INSERT INTO data_source([type_id], [name], [alias], [description], [tsql], report_id, system_defined,category)
		SELECT TOP 1 1 AS [type_id], 'Commodity Definition View' AS [name], 'CODV' AS ALIAS, 'Standard Commodity Definition View' AS [description],null AS [tsql], @report_id_data_source_dest AS report_id,'1' AS [system_defined]
			,'106500' AS [category]
	END

	UPDATE data_source
	SET alias = 'CODV', description = 'Standard Commodity Definition View'
	, [tsql] = CAST('' AS VARCHAR(MAX)) + 'DECLARE @_commodity_name INT,
	    @_valuation_curve  VARCHAR(MAX), 
	    @_commodity_type INT , 
	    @_commodity_group1 INT, 
	    @_commodity_group2 INT, 
	    @_commodity_group3 INT, 
	    @_commodity_group4 INT,
	    @_sql VARCHAR(MAX)

IF ''@commodity_name'' <> ''NULL''
	SET @_commodity_name = ''@commodity_name''
IF ''@valuation_curve'' <> ''NULL''
	SET @_valuation_curve = ''@valuation_curve''
IF ''@commodity_type'' <> ''NULL''
	SET @_commodity_type = ''@commodity_type''
IF ''@commodity_group1'' <> ''NULL''
	SET @_commodity_group1 = ''@commodity_group1''
IF ''@commodity_group2'' <> ''NULL''
	SET @_commodity_group2 = ''@commodity_group2''
IF ''@commodity_group3'' <> ''NULL''
	SET @_commodity_group3 = ''@commodity_group3''
IF ''@commodity_group4'' <> ''NULL''
	SET @_commodity_group4 = ''@commodity_group4''

SET @_sql = '' SELECT sc.commodity_name [commodity_name],
					 sc.commodity_id [commodity_id],
					 spcd.curve_id [valuation_curve],
					 ct.commodity_name [commodity_type],
					 cg1.code [commodity_group1],
					 cg2.code [commodity_group2],
					 cg3.code [commodity_group3],
					 cg4.code [commodity_group4]
			  --[__batch_report__]
			  FROM source_commodity sc
			  LEFT JOIN source_price_curve_def spcd
                   ON  spcd.source_curve_def_id = sc.valuation_curve 
			  LEFT JOIN commodity_type ct
                  ON  ct.commodity_type_id = sc.commodity_type --commodity_name 
			  OUTER APPLY( SELECT sdv.code, sdv.value_id
			  			  FROM static_data_value sdv
			  			  INNER JOIN static_data_type sdt
			  				  ON sdv.type_id = sdt.type_id
			  				  AND sdt.type_name = ''''Commodity Group''''
			  			  WHERE sdv.value_id = sc.commodity_group1
			  ) cg1
			  OUTER APPLY( SELECT sdv.code, sdv.value_id
			  			  FROM static_data_value sdv
			  			  INNER JOIN static_data_type sdt
			  				  ON sdv.type_id = sdt.type_id
			  				  AND sdt.type_name = ''''Commodity Group 2''''
			  			  WHERE sdv.value_id = sc.commodity_group2
			  ) cg2
			  OUTER APPLY( SELECT sdv.code, sdv.value_id
			  			  FROM static_data_value sdv
			  			  INNER JOIN static_data_type sdt
			  				  ON sdv.type_id = sdt.type_id
			  				  AND sdt.type_name = ''''Commodity Group 3''''
			  			  WHERE sdv.value_id = sc.commodity_group3
			  ) cg3
			  OUTER APPLY( SELECT sdv.code, sdv.value_id
			  			  FROM static_data_value sdv
			  			  INNER JOIN static_data_type sdt
			  				  ON sdv.type_id = sdt.type_id
			  				  AND sdt.type_name = ''''Commodity Group 4''''
			  			  WHERE sdv.value_id = sc.commodity_group4
			  ) cg4
			  WHERE 1 = 1
		  '' 
		  + CASE 
		  	WHEN @_commodity_name IS NOT NULL
		  		THEN '' AND sc.source_commodity_id ='' + CAST( @_commodity_name  AS VARCHAR(10))
		  	ELSE ''''
		  	END + CASE 
		  	WHEN @_valuation_curve IS NOT NULL
		  		THEN '' AND spcd.source_curve_def_id IN ('' + @_valuation_curve + '')''
		  	ELSE ''''
		  	END + CASE 
		  	WHEN @_commodity_type IS NOT NULL
		  		THEN '' AND ct.commodity_type_id = '' + CAST(@_commodity_type AS VARCHAR(10))
		  	ELSE ''''
		  	END + CASE 
		  	WHEN @_commodity_group1 IS NOT NULL
		  		THEN '' AND cg1.value_id = '' + CAST(@_commodity_group1 AS VARCHAR(10))
		  	ELSE ''''
		  	END + CASE 
		  	WHEN @_commodity_group2 IS NOT NULL
		  		THEN '' AND cg2.value_id = '' + CAST(@_commodity_group2 AS VARCHAR(10))
		  	ELSE ''''
		  	END + CASE 
		  	WHEN @_commodity_group3 IS NOT NULL
		  		THEN '' AND cg3.value_id = '' + CAST(@_commodity_group3 AS VARCHAR(10))
		  	ELSE ''''
		  	END + CASE 
		  	WHEN @_commodity_group4 IS NOT NULL
		  		THEN '' AND cg4.value_id = '' + CAST(@_commodity_group4 AS VARCHAR(10))
		  	ELSE ''''
		  	END

EXEC (@_sql)', report_id = @report_id_data_source_dest,
	system_defined = '1'
	,category = '106500' 
	WHERE [name] = 'Commodity Definition View'
		AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1)
		
	

	IF OBJECT_ID('tempdb..#data_source_column', 'U') IS NOT NULL
		DROP TABLE #data_source_column	
	CREATE TABLE #data_source_column(column_id INT)	

	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Commodity Definition View'
	            AND dsc.name =  'commodity_group1'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Commodity Group 1'
			   , reqd_param = NULL, widget_id = 2, datatype_id = 5, param_data_source = 'SELECT sdv.value_id, sdv.code' + CHAR(10) + 'FROM static_data_value sdv' + CHAR(10) + 'INNER JOIN static_data_type sdt' + CHAR(10) + '' + CHAR(9) + 'ON sdv.type_id = sdt.type_id' + CHAR(10) + '' + CHAR(9) + 'AND sdt.type_name = ''Commodity Group''', param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 0, key_column = 0, required_filter = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Commodity Definition View'
			AND dsc.name =  'commodity_group1'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'commodity_group1' AS [name], 'Commodity Group 1' AS ALIAS, NULL AS reqd_param, 2 AS widget_id, 5 AS datatype_id, 'SELECT sdv.value_id, sdv.code' + CHAR(10) + 'FROM static_data_value sdv' + CHAR(10) + 'INNER JOIN static_data_type sdt' + CHAR(10) + '' + CHAR(9) + 'ON sdv.type_id = sdt.type_id' + CHAR(10) + '' + CHAR(9) + 'AND sdt.type_name = ''Commodity Group''' AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, 0 AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Commodity Definition View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	

	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Commodity Definition View'
	            AND dsc.name =  'commodity_group2'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Commodity Group 2'
			   , reqd_param = NULL, widget_id = 2, datatype_id = 5, param_data_source = 'SELECT sdv.value_id, sdv.code' + CHAR(10) + 'FROM static_data_value sdv' + CHAR(10) + 'INNER JOIN static_data_type sdt' + CHAR(10) + '' + CHAR(9) + 'ON sdv.type_id = sdt.type_id' + CHAR(10) + '' + CHAR(9) + 'AND sdt.type_name = ''Commodity Group 2''', param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 0, key_column = 0, required_filter = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Commodity Definition View'
			AND dsc.name =  'commodity_group2'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'commodity_group2' AS [name], 'Commodity Group 2' AS ALIAS, NULL AS reqd_param, 2 AS widget_id, 5 AS datatype_id, 'SELECT sdv.value_id, sdv.code' + CHAR(10) + 'FROM static_data_value sdv' + CHAR(10) + 'INNER JOIN static_data_type sdt' + CHAR(10) + '' + CHAR(9) + 'ON sdv.type_id = sdt.type_id' + CHAR(10) + '' + CHAR(9) + 'AND sdt.type_name = ''Commodity Group 2''' AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, 0 AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Commodity Definition View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	

	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Commodity Definition View'
	            AND dsc.name =  'commodity_group3'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Commodity Group 3'
			   , reqd_param = NULL, widget_id = 2, datatype_id = 5, param_data_source = 'SELECT sdv.value_id, sdv.code' + CHAR(10) + 'FROM static_data_value sdv' + CHAR(10) + 'INNER JOIN static_data_type sdt' + CHAR(10) + '' + CHAR(9) + 'ON sdv.type_id = sdt.type_id' + CHAR(10) + '' + CHAR(9) + 'AND sdt.type_name = ''Commodity Group 3''', param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 0, key_column = 0, required_filter = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Commodity Definition View'
			AND dsc.name =  'commodity_group3'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'commodity_group3' AS [name], 'Commodity Group 3' AS ALIAS, NULL AS reqd_param, 2 AS widget_id, 5 AS datatype_id, 'SELECT sdv.value_id, sdv.code' + CHAR(10) + 'FROM static_data_value sdv' + CHAR(10) + 'INNER JOIN static_data_type sdt' + CHAR(10) + '' + CHAR(9) + 'ON sdv.type_id = sdt.type_id' + CHAR(10) + '' + CHAR(9) + 'AND sdt.type_name = ''Commodity Group 3''' AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, 0 AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Commodity Definition View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	

	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Commodity Definition View'
	            AND dsc.name =  'commodity_id'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Commodity ID'
			   , reqd_param = NULL, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 0, key_column = 1, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Commodity Definition View'
			AND dsc.name =  'commodity_id'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'commodity_id' AS [name], 'Commodity ID' AS ALIAS, NULL AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,0 AS column_template, 1 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Commodity Definition View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	

	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Commodity Definition View'
	            AND dsc.name =  'commodity_name'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Commodity'
			   , reqd_param = NULL, widget_id = 2, datatype_id = 5, param_data_source = 'SELECT source_commodity_id, commodity_name FROM source_commodity', param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 0, key_column = 0, required_filter = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Commodity Definition View'
			AND dsc.name =  'commodity_name'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'commodity_name' AS [name], 'Commodity' AS ALIAS, NULL AS reqd_param, 2 AS widget_id, 5 AS datatype_id, 'SELECT source_commodity_id, commodity_name FROM source_commodity' AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, 0 AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Commodity Definition View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	

	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Commodity Definition View'
	            AND dsc.name =  'commodity_type'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Commodity Type'
			   , reqd_param = NULL, widget_id = 2, datatype_id = 5, param_data_source = 'select commodity_type_id, commodity_name From commodity_type', param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 0, key_column = 0, required_filter = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Commodity Definition View'
			AND dsc.name =  'commodity_type'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'commodity_type' AS [name], 'Commodity Type' AS ALIAS, NULL AS reqd_param, 2 AS widget_id, 5 AS datatype_id, 'select commodity_type_id, commodity_name From commodity_type' AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, 0 AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Commodity Definition View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	

	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Commodity Definition View'
	            AND dsc.name =  'valuation_curve'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Valuation Curve'
			   , reqd_param = NULL, widget_id = 7, datatype_id = 5, param_data_source = 'browse_curve', param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 0, key_column = 0, required_filter = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Commodity Definition View'
			AND dsc.name =  'valuation_curve'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'valuation_curve' AS [name], 'Valuation Curve' AS ALIAS, NULL AS reqd_param, 7 AS widget_id, 5 AS datatype_id, 'browse_curve' AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, 0 AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Commodity Definition View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	

	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Commodity Definition View'
	            AND dsc.name =  'commodity_group4'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Commodity Group 4'
			   , reqd_param = NULL, widget_id = 2, datatype_id = 5, param_data_source = 'SELECT sdv.value_id, sdv.code' + CHAR(10) + 'FROM static_data_value sdv' + CHAR(10) + 'INNER JOIN static_data_type sdt' + CHAR(10) + '' + CHAR(9) + 'ON sdv.type_id = sdt.type_id' + CHAR(10) + '' + CHAR(9) + 'AND sdt.type_name = ''Commodity Group 4''', param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 0, key_column = 0, required_filter = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Commodity Definition View'
			AND dsc.name =  'commodity_group4'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'commodity_group4' AS [name], 'Commodity Group 4' AS ALIAS, NULL AS reqd_param, 2 AS widget_id, 5 AS datatype_id, 'SELECT sdv.value_id, sdv.code' + CHAR(10) + 'FROM static_data_value sdv' + CHAR(10) + 'INNER JOIN static_data_type sdt' + CHAR(10) + '' + CHAR(9) + 'ON sdv.type_id = sdt.type_id' + CHAR(10) + '' + CHAR(9) + 'AND sdt.type_name = ''Commodity Group 4''' AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, 0 AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Commodity Definition View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	

	DELETE dsc
	FROM data_source_column dsc 
	INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		AND ds.[name] = 'Commodity Definition View'
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
	