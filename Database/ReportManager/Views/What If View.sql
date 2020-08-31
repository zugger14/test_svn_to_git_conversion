BEGIN TRY
		BEGIN TRAN
	
	DECLARE @report_id_data_source_dest INT 
	
	SELECT @report_id_data_source_dest = report_id
	FROM report r
	WHERE r.[name] = NULL
	IF EXISTS (SELECT 1 
	           FROM data_source 
	           WHERE [name] = 'What If View'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
			
	BEGIN
		UPDATE data_source
		SET alias = 'WV', description = ''
		, [tsql] = CAST('' AS VARCHAR(MAX)) + 'DECLARE  @_whatif_criteria_id  VARCHAR(MAX)    
DECLARE @_to_as_of_date VARCHAR(10) 
DECLARE @_sql VARCHAR(MAX)

IF ''@to_as_of_date'' <> ''NULL''
    SET @_to_as_of_date = ''@to_as_of_date''

IF ''@whatif_criteria_id'' <> ''NULL''
    SET @_whatif_criteria_id  = ''@whatif_criteria_id''
ELSE
    SELECT @_whatif_criteria_id  = COALESCE (@_whatif_criteria_id + '','', '''') + CAST(criteria_id AS VARCHAR) FROM maintain_whatif_criteria
    
SET @_sql = ''SELECT 
			sdpw.pnl_as_of_date [to_as_of_date],
			sdpw.pnl_as_of_date [as_of_date],			
			MAX(mwc.criteria_name) [whatif_criteria],
			MAX(msg.scenario_group_id) [scenario_group_id],
			MAX(msg.scenario_group_name) [scenario_group],			 
			CASE MAX(wcm.[MTM]) WHEN ''''y'''' THEN ROUND(SUM(sdpw.und_pnl), 6) ELSE CONVERT(FLOAT, NULL) END [MTM],
			CASE MAX(wcm.Var) WHEN ''''y'''' THEN vrw.VaR ELSE CONVERT(FLOAT, NULL) END [VAR],
			CASE MAX(wcm.Cfar) WHEN ''''y'''' THEN ROUND(SUM(mcsw.cash_flow), 6) ELSE CONVERT(FLOAT, NULL) END [cash_flow],
			CASE MAX(wcm.Cfar) WHEN ''''y'''' THEN crw.cfar ELSE CONVERT(FLOAT, NULL) END [CFaR],
			CASE MAX(wcm.Ear) WHEN ''''y'''' THEN ROUND(SUM(mesw.earning), 6) ELSE CONVERT(FLOAT, NULL) END [earnings],
			CASE MAX(wcm.Ear) WHEN ''''y'''' THEN erw.ear ELSE CONVERT(FLOAT, NULL) END [EaR],
			sc.source_currency_id [currency_id],
			sc.currency_name [currency],
			mwc.criteria_id [whatif_criteria_id],
			MAX(sdpw.pnl_source_value_id) [curve_source_value_id],
			MAX(sdv_cs.code) [curve_source]
			 --[__batch_report__]
		FROM source_deal_pnl_WhatIf sdpw
		INNER JOIN maintain_whatif_criteria mwc ON sdpw.criteria_id = mwc.criteria_id 
			AND sdpw.term_start >= 
				dbo.FNAGetContractMonth(COALESCE(mwc.term_start, CASE WHEN mwc.tenor_from IS NULL THEN sdpw.term_start ELSE DATEADD(MONTH, CAST(mwc.tenor_from AS INT), ''''@as_of_date'''') END))
			AND sdpw.term_end <= 
				dbo.FNALastDayInDate(COALESCE(mwc.term_end, CASE WHEN mwc.tenor_to IS NULL THEN sdpw.term_end ELSE DATEADD(MONTH, CAST(mwc.tenor_to AS INT), ''''@as_of_date'''')END))
		INNER JOIN source_deal_pnl_detail_WhatIf sdpdw ON sdpw.criteria_id = sdpdw.criteria_id 
			AND sdpw.pnl_as_of_date = sdpdw.pnl_as_of_date
			AND sdpw.source_deal_header_id = sdpdw.source_deal_header_id
			AND sdpw.term_start = sdpdw.term_start
			AND sdpw.term_end = sdpdw.term_end
			AND sdpw.Leg = sdpdw.Leg
			AND sdpw.pnl_source_value_id = sdpdw.pnl_source_value_id
		LEFT JOIN source_deal_header sdh ON sdpw.source_deal_header_id = sdh.source_deal_header_id
		LEFT JOIN var_results_whatif vrw ON sdpw.criteria_id = vrw.whatif_criteria_id
			AND vrw.as_of_date = sdpw.pnl_as_of_date
		LEFT JOIN mtm_cfar_simulation_whatif mcsw ON sdpw.criteria_id = mcsw.whatif_criteria_id
			AND mcsw.as_of_date = sdpw.pnl_as_of_date
			AND mcsw.term = sdpw.term_start
			AND mcsw.source_deal_header_id = sdpw.source_deal_header_id
		LEFT JOIN cfar_results_whatif crw ON sdpw.criteria_id = crw.whatif_criteria_id
			AND crw.as_of_date = sdpw.pnl_as_of_date	
		LEFT JOIN mtm_ear_simulation_whatif mesw ON sdpw.criteria_id = mesw.whatif_criteria_id
			AND mesw.as_of_date = sdpw.pnl_as_of_date
			AND mesw.term = sdpw.term_start
			AND mesw.source_deal_header_id = sdpw.source_deal_header_id
		LEFT JOIN ear_results_whatif erw ON sdpw.criteria_id = erw.whatif_criteria_id
			AND erw.as_of_date = sdpw.pnl_as_of_date	
		INNER JOIN source_currency sc ON sdpdw.pnl_currency_id = sc.source_currency_id
		LEFT JOIN maintain_scenario_group msg ON msg.scenario_group_id = mwc.scenario_group_id
		INNER JOIN whatif_criteria_measure wcm ON wcm.criteria_id = mwc.criteria_id
		LEFT JOIN static_data_value sdv_cs ON sdv_cs.value_id = sdpw.pnl_source_value_id
		WHERE 1 = 1 
			AND '' + CASE WHEN @_to_as_of_date IS NULL 
			THEN '' sdpw.pnl_as_of_date = ''''@as_of_date'''' '' 
			ELSE '' sdpw.pnl_as_of_date >= ''''@as_of_date'''' AND sdpw.pnl_as_of_date <= ''''@to_as_of_date'''' ''
			END 
			+ 
			CASE WHEN ''@whatif_criteria_id'' <> ''NULL'' THEN '' AND mwc.criteria_id = ''''@whatif_criteria_id'''''' ELSE '' '' END
			+
		'' GROUP BY 
			sdpw.pnl_as_of_date,
			mwc.criteria_name,
			mwc.criteria_id,
			vrw.VaR,
			crw.cfar,
			erw.ear,
			sc.source_currency_id,
			sc.currency_name,
			wcm.MTM,
			wcm.[Var],
			wcm.Cfar,
			wcm.Ear''
EXEC (@_sql)', report_id = @report_id_data_source_dest 
		WHERE [name] = 'What If View'
			AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1)
	END	
	
	IF NOT EXISTS (SELECT 1 
	           FROM data_source 
	           WHERE [name] = 'What If View'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		INSERT INTO data_source([type_id], [name], [alias], [description], [tsql], report_id)
		SELECT TOP 1 1 AS [type_id], 'What If View' AS [name], 'WV' AS ALIAS, '' AS [description],'DECLARE  @_whatif_criteria_id  VARCHAR(MAX)    
DECLARE @_to_as_of_date VARCHAR(10) 
DECLARE @_sql VARCHAR(MAX)

IF ''@to_as_of_date'' <> ''NULL''
    SET @_to_as_of_date = ''@to_as_of_date''

IF ''@whatif_criteria_id'' <> ''NULL''
    SET @_whatif_criteria_id  = ''@whatif_criteria_id''
ELSE
    SELECT @_whatif_criteria_id  = COALESCE (@_whatif_criteria_id + '','', '''') + CAST(criteria_id AS VARCHAR) FROM maintain_whatif_criteria
    
SET @_sql = ''SELECT 
			sdpw.pnl_as_of_date [to_as_of_date],
			sdpw.pnl_as_of_date [as_of_date],			
			MAX(mwc.criteria_name) [whatif_criteria],
			MAX(msg.scenario_group_id) [scenario_group_id],
			MAX(msg.scenario_group_name) [scenario_group],			 
			CASE MAX(wcm.[MTM]) WHEN ''''y'''' THEN ROUND(SUM(sdpw.und_pnl), 6) ELSE CONVERT(FLOAT, NULL) END [MTM],
			CASE MAX(wcm.Var) WHEN ''''y'''' THEN vrw.VaR ELSE CONVERT(FLOAT, NULL) END [VAR],
			CASE MAX(wcm.Cfar) WHEN ''''y'''' THEN ROUND(SUM(mcsw.cash_flow), 6) ELSE CONVERT(FLOAT, NULL) END [cash_flow],
			CASE MAX(wcm.Cfar) WHEN ''''y'''' THEN crw.cfar ELSE CONVERT(FLOAT, NULL) END [CFaR],
			CASE MAX(wcm.Ear) WHEN ''''y'''' THEN ROUND(SUM(mesw.earning), 6) ELSE CONVERT(FLOAT, NULL) END [earnings],
			CASE MAX(wcm.Ear) WHEN ''''y'''' THEN erw.ear ELSE CONVERT(FLOAT, NULL) END [EaR],
			sc.source_currency_id [currency_id],
			sc.currency_name [currency],
			mwc.criteria_id [whatif_criteria_id],
			MAX(sdpw.pnl_source_value_id) [curve_source_value_id],
			MAX(sdv_cs.code) [curve_source]
			 --[__batch_report__]
		FROM source_deal_pnl_WhatIf sdpw
		INNER JOIN maintain_whatif_criteria mwc ON sdpw.criteria_id = mwc.criteria_id 
			AND sdpw.term_start >= 
				dbo.FNAGetContractMonth(COALESCE(mwc.term_start, CASE WHEN mwc.tenor_from IS NULL THEN sdpw.term_start ELSE DATEADD(MONTH, CAST(mwc.tenor_from AS INT), ''''@as_of_date'''') END))
			AND sdpw.term_end <= 
				dbo.FNALastDayInDate(COALESCE(mwc.term_end, CASE WHEN mwc.tenor_to IS NULL THEN sdpw.term_end ELSE DATEADD(MONTH, CAST(mwc.tenor_to AS INT), ''''@as_of_date'''')END))
		INNER JOIN source_deal_pnl_detail_WhatIf sdpdw ON sdpw.criteria_id = sdpdw.criteria_id 
			AND sdpw.pnl_as_of_date = sdpdw.pnl_as_of_date
			AND sdpw.source_deal_header_id = sdpdw.source_deal_header_id
			AND sdpw.term_start = sdpdw.term_start
			AND sdpw.term_end = sdpdw.term_end
			AND sdpw.Leg = sdpdw.Leg
			AND sdpw.pnl_source_value_id = sdpdw.pnl_source_value_id
		LEFT JOIN source_deal_header sdh ON sdpw.source_deal_header_id = sdh.source_deal_header_id
		LEFT JOIN var_results_whatif vrw ON sdpw.criteria_id = vrw.whatif_criteria_id
			AND vrw.as_of_date = sdpw.pnl_as_of_date
		LEFT JOIN mtm_cfar_simulation_whatif mcsw ON sdpw.criteria_id = mcsw.whatif_criteria_id
			AND mcsw.as_of_date = sdpw.pnl_as_of_date
			AND mcsw.term = sdpw.term_start
			AND mcsw.source_deal_header_id = sdpw.source_deal_header_id
		LEFT JOIN cfar_results_whatif crw ON sdpw.criteria_id = crw.whatif_criteria_id
			AND crw.as_of_date = sdpw.pnl_as_of_date	
		LEFT JOIN mtm_ear_simulation_whatif mesw ON sdpw.criteria_id = mesw.whatif_criteria_id
			AND mesw.as_of_date = sdpw.pnl_as_of_date
			AND mesw.term = sdpw.term_start
			AND mesw.source_deal_header_id = sdpw.source_deal_header_id
		LEFT JOIN ear_results_whatif erw ON sdpw.criteria_id = erw.whatif_criteria_id
			AND erw.as_of_date = sdpw.pnl_as_of_date	
		INNER JOIN source_currency sc ON sdpdw.pnl_currency_id = sc.source_currency_id
		LEFT JOIN maintain_scenario_group msg ON msg.scenario_group_id = mwc.scenario_group_id
		INNER JOIN whatif_criteria_measure wcm ON wcm.criteria_id = mwc.criteria_id
		LEFT JOIN static_data_value sdv_cs ON sdv_cs.value_id = sdpw.pnl_source_value_id
		WHERE 1 = 1 
			AND '' + CASE WHEN @_to_as_of_date IS NULL 
			THEN '' sdpw.pnl_as_of_date = ''''@as_of_date'''' '' 
			ELSE '' sdpw.pnl_as_of_date >= ''''@as_of_date'''' AND sdpw.pnl_as_of_date <= ''''@to_as_of_date'''' ''
			END 
			+ 
			CASE WHEN ''@whatif_criteria_id'' <> ''NULL'' THEN '' AND mwc.criteria_id = ''''@whatif_criteria_id'''''' ELSE '' '' END
			+
		'' GROUP BY 
			sdpw.pnl_as_of_date,
			mwc.criteria_name,
			mwc.criteria_id,
			vrw.VaR,
			crw.cfar,
			erw.ear,
			sc.source_currency_id,
			sc.currency_name,
			wcm.MTM,
			wcm.[Var],
			wcm.Cfar,
			wcm.Ear''
EXEC (@_sql)' AS [tsql], @report_id_data_source_dest AS report_id
	END 
	
	IF OBJECT_ID('tempdb..#data_source_column', 'U') IS NOT NULL
		DROP TABLE #data_source_column	
	CREATE TABLE #data_source_column(column_id INT)	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'What If View'
	            AND dsc.name =  'cash_flow'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Cash Flow'
			   , reqd_param = 0, widget_id = 1, datatype_id = 3, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 2, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'What If View'
			AND dsc.name =  'cash_flow'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'cash_flow' AS [name], 'Cash Flow' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 3 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'What If View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'What If View'
	            AND dsc.name =  'CFaR'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'CFaR'
			   , reqd_param = 0, widget_id = 1, datatype_id = 3, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 2, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'What If View'
			AND dsc.name =  'CFaR'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'CFaR' AS [name], 'CFaR' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 3 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'What If View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'What If View'
	            AND dsc.name =  'currency'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Currency'
			   , reqd_param = 0, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'What If View'
			AND dsc.name =  'currency'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'currency' AS [name], 'Currency' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'What If View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'What If View'
	            AND dsc.name =  'EaR'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'EaR'
			   , reqd_param = 0, widget_id = 1, datatype_id = 3, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 2, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'What If View'
			AND dsc.name =  'EaR'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'EaR' AS [name], 'EaR' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 3 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'What If View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'What If View'
	            AND dsc.name =  'earnings'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Earnings'
			   , reqd_param = 0, widget_id = 1, datatype_id = 3, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 2, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'What If View'
			AND dsc.name =  'earnings'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'earnings' AS [name], 'Earnings' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 3 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'What If View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'What If View'
	            AND dsc.name =  'MTM'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'MTM'
			   , reqd_param = 0, widget_id = 1, datatype_id = 3, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 2, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'What If View'
			AND dsc.name =  'MTM'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'MTM' AS [name], 'MTM' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 3 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'What If View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'What If View'
	            AND dsc.name =  'VAR'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'VaR'
			   , reqd_param = 0, widget_id = 1, datatype_id = 3, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 2, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'What If View'
			AND dsc.name =  'VAR'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'VAR' AS [name], 'VaR' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 3 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'What If View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'What If View'
	            AND dsc.name =  'to_as_of_date'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'As of Date To'
			   , reqd_param = 1, widget_id = 6, datatype_id = 2, param_data_source = NULL, param_default_value = NULL, append_filter = 0, tooltip = NULL, column_template = 4, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'What If View'
			AND dsc.name =  'to_as_of_date'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'to_as_of_date' AS [name], 'As of Date To' AS ALIAS, 1 AS reqd_param, 6 AS widget_id, 2 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 0 AS append_filter, NULL  AS tooltip,4 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'What If View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'What If View'
	            AND dsc.name =  'scenario_group'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Scenario Group'
			   , reqd_param = 0, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'What If View'
			AND dsc.name =  'scenario_group'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'scenario_group' AS [name], 'Scenario Group' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'What If View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'What If View'
	            AND dsc.name =  'as_of_date'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'As of Date'
			   , reqd_param = 1, widget_id = 6, datatype_id = 2, param_data_source = NULL, param_default_value = NULL, append_filter = 0, tooltip = NULL, column_template = 4, key_column = 1
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'What If View'
			AND dsc.name =  'as_of_date'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'as_of_date' AS [name], 'As of Date' AS ALIAS, 1 AS reqd_param, 6 AS widget_id, 2 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 0 AS append_filter, NULL  AS tooltip,4 AS column_template, 1 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'What If View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'What If View'
	            AND dsc.name =  'currency_id'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Currency ID'
			   , reqd_param = 0, widget_id = 1, datatype_id = 4, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 2, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'What If View'
			AND dsc.name =  'currency_id'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'currency_id' AS [name], 'Currency ID' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 4 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'What If View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'What If View'
	            AND dsc.name =  'scenario_group_id'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Scenario Group ID'
			   , reqd_param = 0, widget_id = 1, datatype_id = 4, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 2, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'What If View'
			AND dsc.name =  'scenario_group_id'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'scenario_group_id' AS [name], 'Scenario Group ID' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 4 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'What If View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'What If View'
	            AND dsc.name =  'whatif_criteria_id'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'What If Criteria ID'
			   , reqd_param = 1, widget_id = 2, datatype_id = 4, param_data_source = 'SELECT mwc.criteria_id [value], mwc.criteria_name [label] FROM maintain_whatif_criteria mwc', param_default_value = NULL, append_filter = 0, tooltip = NULL, column_template = 2, key_column = 1
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'What If View'
			AND dsc.name =  'whatif_criteria_id'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'whatif_criteria_id' AS [name], 'What If Criteria ID' AS ALIAS, 1 AS reqd_param, 2 AS widget_id, 4 AS datatype_id, 'SELECT mwc.criteria_id [value], mwc.criteria_name [label] FROM maintain_whatif_criteria mwc' AS param_data_source, NULL AS param_default_value, 0 AS append_filter, NULL  AS tooltip,2 AS column_template, 1 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'What If View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'What If View'
	            AND dsc.name =  'whatif_criteria'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'What if Criteria'
			   , reqd_param = 0, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'What If View'
			AND dsc.name =  'whatif_criteria'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'whatif_criteria' AS [name], 'What if Criteria' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'What If View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'What If View'
	            AND dsc.name =  'curve_source'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Curve Source'
			   , reqd_param = 0, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'What If View'
			AND dsc.name =  'curve_source'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'curve_source' AS [name], 'Curve Source' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'What If View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'What If View'
	            AND dsc.name =  'curve_source_value_id'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Curve Source Value ID'
			   , reqd_param = 0, widget_id = 2, datatype_id = 4, param_data_source = 'EXEC spa_StaticDataValues @flag = ''h'', @type_id = 10007', param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 2, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'What If View'
			AND dsc.name =  'curve_source_value_id'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'curve_source_value_id' AS [name], 'Curve Source Value ID' AS ALIAS, 0 AS reqd_param, 2 AS widget_id, 4 AS datatype_id, 'EXEC spa_StaticDataValues @flag = ''h'', @type_id = 10007' AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'What If View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	DELETE dsc
	FROM data_source_column dsc 
	INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		AND ds.[name] = 'What If View'
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
	