BEGIN TRY
		BEGIN TRAN
	

	declare @new_ds_alias varchar(10) = 'JMIV'
	/** IF DATA SOURCE ALIAS ALREADY EXISTS ON DESTINATION, RAISE ERROR **/
	if exists(select top 1 1 from data_source where alias = 'JMIV' and name <> 'Jurisdiction Market Information View')
	begin
		select top 1 @new_ds_alias = 'JMIV' + cast(s.n as varchar(5))
		from seq s
		left join data_source ds on ds.alias = 'JMIV' + cast(s.n as varchar(5))
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
	           WHERE [name] = 'Jurisdiction Market Information View'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	AND NOT EXISTS (SELECT 1 FROM map_function_category WHERE [function_name] = 'Jurisdiction Market Information View' AND '106500' = '106501') 
	BEGIN
		INSERT INTO data_source([type_id], [name], [alias], [description], [tsql], report_id, system_defined,category)
		SELECT TOP 1 1 AS [type_id], 'Jurisdiction Market Information View' AS [name], @new_ds_alias AS ALIAS, 'Jurisdiction Market Information View' AS [description],null AS [tsql], @report_id_data_source_dest AS report_id,'1' AS [system_defined]
			,'106500' AS [category]
	END

	UPDATE data_source
	SET alias = @new_ds_alias, description = 'Jurisdiction Market Information View'
	, [tsql] = CAST('' AS VARCHAR(MAX)) + 'SET QUOTED_IDENTIFIER ON;

DECLARE @_jurisdiction_id VARCHAR(1000) = NULL, 

@_region_id VARCHAR(1000) = NULL, 

@_program_scope_id VARCHAR(1000)= NULL, 

@_compliance_calendar_month_from VARCHAR(50)= NULL,

@_complianc_calendar_month_to VARCHAR(50)= NULL,

@_sql VARCHAR(MAX)



IF ''@region_id'' <> ''NULL''

	SET @_region_id = ''@region_id''



IF ''@jurisdiction_id'' <> ''NULL''

	SET @_jurisdiction_id = ''@jurisdiction_id''



IF ''@program_scope_id'' <> ''NULL''

	SET @_program_scope_id = ''@program_scope_id''



IF ''@compliance_calendar_month_from'' <> ''NULL''

	SET @_compliance_calendar_month_from = ''@compliance_calendar_month_from''



IF ''@complianc_calendar_month_to'' <> ''NULL''

	SET @_complianc_calendar_month_to = ''@complianc_calendar_month_to''





SET @_sql = '' SELECT   sdv_jur.code [jurisdiction],

			sdv_jur.description [description],

			''''@region_id'''' region_id,

			dbo.FNADateFormat(emtd.begin_date) [program_beginning_date],

			CASE 

				WHEN ISNULL(emtd.calendar_from_month, '''''''') = 1 THEN ''''Jan'''' 

				WHEN ISNULL(emtd.calendar_from_month, '''''''') = 2 THEN ''''Feb'''' 

				WHEN ISNULL(emtd.calendar_from_month, '''''''') = 3 THEN ''''Mar'''' 

				WHEN ISNULL(emtd.calendar_from_month, '''''''') = 4 THEN ''''Apr'''' 

				WHEN ISNULL(emtd.calendar_from_month, '''''''') = 5 THEN ''''May'''' 

				WHEN ISNULL(emtd.calendar_from_month, '''''''') = 6 THEN ''''Jun'''' 

				WHEN ISNULL(emtd.calendar_from_month, '''''''') = 7 THEN ''''Jul'''' 

				WHEN ISNULL(emtd.calendar_from_month, '''''''') = 8 THEN ''''Aug'''' 

				WHEN ISNULL(emtd.calendar_from_month, '''''''') = 9 THEN ''''Sep'''' 

				WHEN ISNULL(emtd.calendar_from_month, '''''''') = 10 THEN ''''Oct'''' 

				WHEN ISNULL(emtd.calendar_from_month, '''''''') = 11 THEN ''''Nov'''' 

				WHEN ISNULL(emtd.calendar_from_month, '''''''') = 12 THEN ''''Dec''''

			ELSE 

				''''''''

			END 

			+ '''''''' + 

			CASE 

				WHEN ISNULL(emtd.calendar_to_month, '''''''') = 1 THEN ''''-Jan'''' 

				WHEN ISNULL(emtd.calendar_to_month, '''''''') = 2 THEN ''''-Feb'''' 

				WHEN ISNULL(emtd.calendar_to_month, '''''''') = 3 THEN ''''-Mar'''' 

				WHEN ISNULL(emtd.calendar_to_month, '''''''') = 4 THEN ''''-Apr'''' 

				WHEN ISNULL(emtd.calendar_to_month, '''''''') = 5 THEN ''''-May'''' 

				WHEN ISNULL(emtd.calendar_to_month, '''''''') = 6 THEN ''''-Jun'''' 

				WHEN ISNULL(emtd.calendar_to_month, '''''''') = 7 THEN ''''-Jul'''' 

				WHEN ISNULL(emtd.calendar_to_month, '''''''') = 8 THEN ''''-Aug'''' 

				WHEN ISNULL(emtd.calendar_to_month, '''''''') = 9 THEN ''''-Sep'''' 

				WHEN ISNULL(emtd.calendar_to_month, '''''''') = 10 THEN ''''-Oct'''' 

				WHEN ISNULL(emtd.calendar_to_month, '''''''') = 11 THEN ''''-Nov'''' 

				WHEN ISNULL(emtd.calendar_to_month, '''''''') = 12 THEN ''''-Dec''''

			ELSE 

				''''''''

			END [compliance_calendar_year],

			''''@jurisdiction_id'''' [jurisdiction_id],

			sdv_program_scope.code [program_scope],

			''''@program_scope_id'''' [program_scope_id],

			''''@compliance_calendar_month_from'''' [compliance_calendar_month_from],

			''''@complianc_calendar_month_to'''' [complianc_calendar_month_to],

			region.region

		--[__batch_report__]	

		FROM state_properties emtd

		INNER JOIN static_data_value sdv_jur 

			ON ISNULL(sdv_jur.value_id,'''''''') = ISNULL(emtd.state_value_id,'''''''') 

				AND sdv_jur.type_id = 10002

		LEFT JOIN static_data_value sdv_program_scope  

			ON ISNULL(sdv_program_scope.value_id,'''''''') = ISNULL(emtd.program_scope, '''''''') 

				AND sdv_program_scope.type_id = 3100

		OUTER APPLY (

		SELECT STUFF(

               (

                   SELECT '''','''' + ISNULL(NULLIF(sdv.code, ''''-1''''), '''''''')

                   FROM  dbo.SplitCommaSeperatedValues(emtd.region_id) a 

				   INNER JOIN static_data_Value sdv

					ON ISNULL(sdv.value_id,'''''''') =ISNULL(a.item,'''''''') AND sdv.type_id = 11150  FOR XML PATH,

                          type

               ).value(''''.[1]'''', ''''VARCHAR(MAX)''''),

               1,

               1,

               ''''''''

           ) AS region) region 

		   OUTER APPLY (SELECT item as region_id from dbo.SplitCommaSeperatedValues(emtd.region_id)) aa

		   WHERE 1=1  ''

		IF @_jurisdiction_id IS NOT NULL 

			SET @_sql+= '' AND emtd.state_value_id IN ('' + @_jurisdiction_id + '')''



		IF @_program_scope_id IS NOT NULL 

			SET @_sql+= '' AND emtd.program_scope IN ('' + @_program_scope_id + '')''



		

		IF @_compliance_calendar_month_from IS NOT NULL 

			SET @_sql+= '' AND emtd.calendar_from_month IN ('' + @_compliance_calendar_month_from + '')''



		IF @_complianc_calendar_month_to IS NOT NULL 

			SET @_sql+= '' AND emtd.calendar_to_month IN ('' + @_complianc_calendar_month_to + '')''



		IF @_region_id IS NOT NULL 

			SET @_sql+= '' AND aa.region_id IN (''  + @_region_id + '')''

		

		SET @_sql += '' GROUP BY  sdv_jur.code ,sdv_jur.description ,emtd.begin_date,emtd.calendar_from_month,emtd.calendar_to_month,sdv_program_scope.code,region.region''



EXEC (@_sql)', report_id = @report_id_data_source_dest,
	system_defined = '1'
	,category = '106500' 
	WHERE [name] = 'Jurisdiction Market Information View'
		AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1)
	

	IF OBJECT_ID('tempdb..#data_source_column', 'U') IS NOT NULL
		DROP TABLE #data_source_column	
	CREATE TABLE #data_source_column(column_id INT)	

	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Jurisdiction Market Information View'
	            AND dsc.name =  'complianc_calendar_month_to'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Complianc Calendar Month To'
			   , reqd_param = NULL, widget_id = 2, datatype_id = 5, param_data_source = 'SELECT 1             AS [value],' + CHAR(10) + '    ''01-January''  AS [key] UNION ALL ' + CHAR(10) + 'SELECT 2              AS [value],' + CHAR(10) + '    ''02-February''  AS [key] UNION ALL ' + CHAR(10) + 'SELECT 3        AS [value],' + CHAR(10) + '    ''03-March''  AS [key] UNION ALL ' + CHAR(10) + 'SELECT 4        AS [value],' + CHAR(10) + '    ''04-April''  AS [key] UNION ALL ' + CHAR(10) + 'SELECT 5      AS [value],' + CHAR(10) + '    ''05-May''  AS [key] UNION ALL ' + CHAR(10) + 'SELECT 6       AS [value],' + CHAR(10) + '    ''06-June''  AS [key] UNION ALL ' + CHAR(10) + 'SELECT 7       AS [value],' + CHAR(10) + '    ''07-July''  AS [key] UNION ALL ' + CHAR(10) + 'SELECT 8         AS [value],' + CHAR(10) + '    ''08-August''  AS [key] UNION ALL ' + CHAR(10) + 'SELECT 9            AS [value],' + CHAR(10) + '    ''09-September''  AS [key] UNION ALL ' + CHAR(10) + 'SELECT 10         AS [value],' + CHAR(10) + '    ''10-October''  AS [key] UNION ALL ' + CHAR(10) + 'SELECT 11          AS [value],' + CHAR(10) + '    ''11-November''  AS [key] UNION ALL ' + CHAR(10) + 'SELECT 12          AS [value],' + CHAR(10) + '    ''12-December''  AS [key]' + CHAR(10) + 'ORDER BY' + CHAR(10) + '    [value]', param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 2, key_column = 0, required_filter = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Jurisdiction Market Information View'
			AND dsc.name =  'complianc_calendar_month_to'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'complianc_calendar_month_to' AS [name], 'Complianc Calendar Month To' AS ALIAS, NULL AS reqd_param, 2 AS widget_id, 5 AS datatype_id, 'SELECT 1             AS [value],' + CHAR(10) + '    ''01-January''  AS [key] UNION ALL ' + CHAR(10) + 'SELECT 2              AS [value],' + CHAR(10) + '    ''02-February''  AS [key] UNION ALL ' + CHAR(10) + 'SELECT 3        AS [value],' + CHAR(10) + '    ''03-March''  AS [key] UNION ALL ' + CHAR(10) + 'SELECT 4        AS [value],' + CHAR(10) + '    ''04-April''  AS [key] UNION ALL ' + CHAR(10) + 'SELECT 5      AS [value],' + CHAR(10) + '    ''05-May''  AS [key] UNION ALL ' + CHAR(10) + 'SELECT 6       AS [value],' + CHAR(10) + '    ''06-June''  AS [key] UNION ALL ' + CHAR(10) + 'SELECT 7       AS [value],' + CHAR(10) + '    ''07-July''  AS [key] UNION ALL ' + CHAR(10) + 'SELECT 8         AS [value],' + CHAR(10) + '    ''08-August''  AS [key] UNION ALL ' + CHAR(10) + 'SELECT 9            AS [value],' + CHAR(10) + '    ''09-September''  AS [key] UNION ALL ' + CHAR(10) + 'SELECT 10         AS [value],' + CHAR(10) + '    ''10-October''  AS [key] UNION ALL ' + CHAR(10) + 'SELECT 11          AS [value],' + CHAR(10) + '    ''11-November''  AS [key] UNION ALL ' + CHAR(10) + 'SELECT 12          AS [value],' + CHAR(10) + '    ''12-December''  AS [key]' + CHAR(10) + 'ORDER BY' + CHAR(10) + '    [value]' AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column, 0 AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Jurisdiction Market Information View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	

	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Jurisdiction Market Information View'
	            AND dsc.name =  'compliance_calendar_month_from'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Compliance Calendar Month From'
			   , reqd_param = NULL, widget_id = 2, datatype_id = 5, param_data_source = 'SELECT 1             AS [value],' + CHAR(10) + '    ''01-January''  AS [key] UNION ALL ' + CHAR(10) + 'SELECT 2              AS [value],' + CHAR(10) + '    ''02-February''  AS [key] UNION ALL ' + CHAR(10) + 'SELECT 3        AS [value],' + CHAR(10) + '    ''03-March''  AS [key] UNION ALL ' + CHAR(10) + 'SELECT 4        AS [value],' + CHAR(10) + '    ''04-April''  AS [key] UNION ALL ' + CHAR(10) + 'SELECT 5      AS [value],' + CHAR(10) + '    ''05-May''  AS [key] UNION ALL ' + CHAR(10) + 'SELECT 6       AS [value],' + CHAR(10) + '    ''06-June''  AS [key] UNION ALL ' + CHAR(10) + 'SELECT 7       AS [value],' + CHAR(10) + '    ''07-July''  AS [key] UNION ALL ' + CHAR(10) + 'SELECT 8         AS [value],' + CHAR(10) + '    ''08-August''  AS [key] UNION ALL ' + CHAR(10) + 'SELECT 9            AS [value],' + CHAR(10) + '    ''09-September''  AS [key] UNION ALL ' + CHAR(10) + 'SELECT 10         AS [value],' + CHAR(10) + '    ''10-October''  AS [key] UNION ALL ' + CHAR(10) + 'SELECT 11          AS [value],' + CHAR(10) + '    ''11-November''  AS [key] UNION ALL ' + CHAR(10) + 'SELECT 12          AS [value],' + CHAR(10) + '    ''12-December''  AS [key]' + CHAR(10) + 'ORDER BY' + CHAR(10) + '    [value]', param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 2, key_column = 0, required_filter = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Jurisdiction Market Information View'
			AND dsc.name =  'compliance_calendar_month_from'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'compliance_calendar_month_from' AS [name], 'Compliance Calendar Month From' AS ALIAS, NULL AS reqd_param, 2 AS widget_id, 5 AS datatype_id, 'SELECT 1             AS [value],' + CHAR(10) + '    ''01-January''  AS [key] UNION ALL ' + CHAR(10) + 'SELECT 2              AS [value],' + CHAR(10) + '    ''02-February''  AS [key] UNION ALL ' + CHAR(10) + 'SELECT 3        AS [value],' + CHAR(10) + '    ''03-March''  AS [key] UNION ALL ' + CHAR(10) + 'SELECT 4        AS [value],' + CHAR(10) + '    ''04-April''  AS [key] UNION ALL ' + CHAR(10) + 'SELECT 5      AS [value],' + CHAR(10) + '    ''05-May''  AS [key] UNION ALL ' + CHAR(10) + 'SELECT 6       AS [value],' + CHAR(10) + '    ''06-June''  AS [key] UNION ALL ' + CHAR(10) + 'SELECT 7       AS [value],' + CHAR(10) + '    ''07-July''  AS [key] UNION ALL ' + CHAR(10) + 'SELECT 8         AS [value],' + CHAR(10) + '    ''08-August''  AS [key] UNION ALL ' + CHAR(10) + 'SELECT 9            AS [value],' + CHAR(10) + '    ''09-September''  AS [key] UNION ALL ' + CHAR(10) + 'SELECT 10         AS [value],' + CHAR(10) + '    ''10-October''  AS [key] UNION ALL ' + CHAR(10) + 'SELECT 11          AS [value],' + CHAR(10) + '    ''11-November''  AS [key] UNION ALL ' + CHAR(10) + 'SELECT 12          AS [value],' + CHAR(10) + '    ''12-December''  AS [key]' + CHAR(10) + 'ORDER BY' + CHAR(10) + '    [value]' AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column, 0 AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Jurisdiction Market Information View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	

	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Jurisdiction Market Information View'
	            AND dsc.name =  'compliance_calendar_year'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Compliance Calendar Year'
			   , reqd_param = NULL, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 0, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Jurisdiction Market Information View'
			AND dsc.name =  'compliance_calendar_year'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'compliance_calendar_year' AS [name], 'Compliance Calendar Year' AS ALIAS, NULL AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Jurisdiction Market Information View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	

	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Jurisdiction Market Information View'
	            AND dsc.name =  'description'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Description'
			   , reqd_param = NULL, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 0, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Jurisdiction Market Information View'
			AND dsc.name =  'description'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'description' AS [name], 'Description' AS ALIAS, NULL AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Jurisdiction Market Information View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	

	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Jurisdiction Market Information View'
	            AND dsc.name =  'jurisdiction'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Jurisdiction'
			   , reqd_param = NULL, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 0, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Jurisdiction Market Information View'
			AND dsc.name =  'jurisdiction'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'jurisdiction' AS [name], 'Jurisdiction' AS ALIAS, NULL AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Jurisdiction Market Information View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	

	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Jurisdiction Market Information View'
	            AND dsc.name =  'jurisdiction_id'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Jurisdiction ID'
			   , reqd_param = NULL, widget_id = 2, datatype_id = 5, param_data_source = 'EXEC spa_StaticDataValues @flag = ''h'', @type_id = 10002', param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 2, key_column = 0, required_filter = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Jurisdiction Market Information View'
			AND dsc.name =  'jurisdiction_id'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'jurisdiction_id' AS [name], 'Jurisdiction ID' AS ALIAS, NULL AS reqd_param, 2 AS widget_id, 5 AS datatype_id, 'EXEC spa_StaticDataValues @flag = ''h'', @type_id = 10002' AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column, 0 AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Jurisdiction Market Information View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	

	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Jurisdiction Market Information View'
	            AND dsc.name =  'program_beginning_date'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Program Beginning Date'
			   , reqd_param = NULL, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 0, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Jurisdiction Market Information View'
			AND dsc.name =  'program_beginning_date'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'program_beginning_date' AS [name], 'Program Beginning Date' AS ALIAS, NULL AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Jurisdiction Market Information View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	

	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Jurisdiction Market Information View'
	            AND dsc.name =  'program_scope'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Program Scope'
			   , reqd_param = NULL, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 0, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Jurisdiction Market Information View'
			AND dsc.name =  'program_scope'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'program_scope' AS [name], 'Program Scope' AS ALIAS, NULL AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Jurisdiction Market Information View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	

	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Jurisdiction Market Information View'
	            AND dsc.name =  'program_scope_id'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Program Scope ID'
			   , reqd_param = NULL, widget_id = 2, datatype_id = 5, param_data_source = 'EXEC spa_StaticDataValues @flag = ''h'', @type_id = 3100', param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 2, key_column = 0, required_filter = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Jurisdiction Market Information View'
			AND dsc.name =  'program_scope_id'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'program_scope_id' AS [name], 'Program Scope ID' AS ALIAS, NULL AS reqd_param, 2 AS widget_id, 5 AS datatype_id, 'EXEC spa_StaticDataValues @flag = ''h'', @type_id = 3100' AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column, 0 AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Jurisdiction Market Information View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	

	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Jurisdiction Market Information View'
	            AND dsc.name =  'region'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Region'
			   , reqd_param = NULL, widget_id = 2, datatype_id = 5, param_data_source = 'EXEC spa_StaticDataValues @flag = ''h'', @type_id = 11150', param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 0, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Jurisdiction Market Information View'
			AND dsc.name =  'region'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'region' AS [name], 'Region' AS ALIAS, NULL AS reqd_param, 2 AS widget_id, 5 AS datatype_id, 'EXEC spa_StaticDataValues @flag = ''h'', @type_id = 11150' AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Jurisdiction Market Information View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	

	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Jurisdiction Market Information View'
	            AND dsc.name =  'region_id'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Region ID'
			   , reqd_param = NULL, widget_id = 2, datatype_id = 5, param_data_source = 'EXEC spa_StaticDataValues @flag = ''h'', @type_id = 11150', param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 0, key_column = 0, required_filter = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Jurisdiction Market Information View'
			AND dsc.name =  'region_id'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'region_id' AS [name], 'Region ID' AS ALIAS, NULL AS reqd_param, 2 AS widget_id, 5 AS datatype_id, 'EXEC spa_StaticDataValues @flag = ''h'', @type_id = 11150' AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, 0 AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Jurisdiction Market Information View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	

	DELETE dsc
	FROM data_source_column dsc 
	INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		AND ds.[name] = 'Jurisdiction Market Information View'
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
	