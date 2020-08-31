/**
* Copy this code to the sql editor in the application

SELECT [function_id],
       [sub_id],
       [subsidiary],
       [role_id],
       [role_name],
       [role_description],
       [role_type],
       [user],
       [login_id],
      [function_name],
      [active_user]
       --[__batch_report__]
FROM   (
           (
               SELECT DISTINCT af.function_id [function_id],
                      ph.entity_id [sub_id],
                      ISNULL(ph.entity_name, 'All') [subsidiary],
                      afu.role_id [role_id],
                      asr.role_name [role_name],
                      asr.role_description [role_description],
                      sdv.code [role_type],
                      au.user_f_name + ISNULL(au.user_m_name, ' ') + ISNULL(au.user_l_name, ' ') 
                      [user],
                      au.user_login_id [login_id],
                      af.function_name [function_name],
                      au.user_active  [active_user]
               FROM   application_security_role asr
                      INNER JOIN application_role_user aru
                           ON  asr.role_id = aru.role_id
                      INNER JOIN application_users au
                           ON  au.user_login_id = aru.user_login_id
                      INNER JOIN static_data_value sdv
                           ON  asr.role_type_value_id = sdv.value_id
                      INNER JOIN application_functional_users afu
                           ON  afu.role_id = asr.role_id
                      INNER JOIN application_functions af
                           ON  af.function_id = afu.function_id
                      LEFT JOIN portfolio_hierarchy ph
                           ON  afu.entity_id = ph.entity_id
           )
           
           UNION ALL 
           (
               SELECT DISTINCT af.function_id [function_id],
                      ph.entity_id [sub_id],
                      ISNULL(ph.entity_name, 'All') [subsidiary],
                      afu.role_id [role_id],
                      '' [role_name],
                      '' [role_description],
                      '' [role_type],
                      au.user_f_name + ISNULL(au.user_m_name, ' ') + ISNULL(au.user_l_name, ' ') 
                      [user],
                      au.user_login_id [login_id],
                      af.function_name [function_name],
                      au.user_active  [active_user]
               FROM   application_functions af
                      INNER JOIN application_functional_users afu
                           ON  afu.function_id = af.function_id
                      INNER JOIN application_users au
                           ON  au.user_login_id = afu.login_id
                      LEFT  JOIN portfolio_hierarchy ph
                           ON  ph.entity_id = afu.entity_id 
           )
       ) a
            
**/

BEGIN TRY
		BEGIN TRAN
	

	DECLARE @report_id_data_source_dest INT 
	
	SELECT @report_id_data_source_dest = report_id
	FROM report r
	WHERE r.[name] = NULL

	IF EXISTS (SELECT 1 
	           FROM data_source 
	           WHERE [name] = 'User Roles Privileges View'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
			
	BEGIN
		UPDATE data_source
		SET alias = 'URP', description = ''
		, [tsql] = CAST('' AS VARCHAR(MAX)) + 'SELECT [function_id],' + CHAR(13) + '' + CHAR(10) + '       [sub_id],' + CHAR(13) + '' + CHAR(10) + '       [subsidiary],' + CHAR(13) + '' + CHAR(10) + '       [role_id],' + CHAR(13) + '' + CHAR(10) + '       [role_name],' + CHAR(13) + '' + CHAR(10) + '       [role_description],' + CHAR(13) + '' + CHAR(10) + '       [role_type],' + CHAR(13) + '' + CHAR(10) + '       [user],' + CHAR(13) + '' + CHAR(10) + '       [login_id],' + CHAR(13) + '' + CHAR(10) + '      [function_name],' + CHAR(13) + '' + CHAR(10) + '      [active_user]' + CHAR(13) + '' + CHAR(10) + '       --[__batch_report__]' + CHAR(13) + '' + CHAR(10) + 'FROM   (' + CHAR(13) + '' + CHAR(10) + '           (' + CHAR(13) + '' + CHAR(10) + '               SELECT DISTINCT af.function_id [function_id],' + CHAR(13) + '' + CHAR(10) + '                      ph.entity_id [sub_id],' + CHAR(13) + '' + CHAR(10) + '                      ISNULL(ph.entity_name, ''All'') [subsidiary],' + CHAR(13) + '' + CHAR(10) + '                      afu.role_id [role_id],' + CHAR(13) + '' + CHAR(10) + '                      asr.role_name [role_name],' + CHAR(13) + '' + CHAR(10) + '                      asr.role_description [role_description],' + CHAR(13) + '' + CHAR(10) + '                      sdv.code [role_type],' + CHAR(13) + '' + CHAR(10) + '                      au.user_f_name + ISNULL(au.user_m_name, '' '') + ISNULL(au.user_l_name, '' '') ' + CHAR(13) + '' + CHAR(10) + '                      [user],' + CHAR(13) + '' + CHAR(10) + '                      au.user_login_id [login_id],' + CHAR(13) + '' + CHAR(10) + '                      af.function_name [function_name],' + CHAR(13) + '' + CHAR(10) + '                      au.user_active  [active_user]' + CHAR(13) + '' + CHAR(10) + '               FROM   application_security_role asr' + CHAR(13) + '' + CHAR(10) + '                      INNER JOIN application_role_user aru' + CHAR(13) + '' + CHAR(10) + '                           ON  asr.role_id = aru.role_id' + CHAR(13) + '' + CHAR(10) + '                      INNER JOIN application_users au' + CHAR(13) + '' + CHAR(10) + '                           ON  au.user_login_id = aru.user_login_id' + CHAR(13) + '' + CHAR(10) + '                      INNER JOIN static_data_value sdv' + CHAR(13) + '' + CHAR(10) + '                           ON  asr.role_type_value_id = sdv.value_id' + CHAR(13) + '' + CHAR(10) + '                      INNER JOIN application_functional_users afu' + CHAR(13) + '' + CHAR(10) + '                           ON  afu.role_id = asr.role_id' + CHAR(13) + '' + CHAR(10) + '                      INNER JOIN application_functions af' + CHAR(13) + '' + CHAR(10) + '                           ON  af.function_id = afu.function_id' + CHAR(13) + '' + CHAR(10) + '                      LEFT JOIN portfolio_hierarchy ph' + CHAR(13) + '' + CHAR(10) + '                           ON  afu.entity_id = ph.entity_id' + CHAR(13) + '' + CHAR(10) + '           )' + CHAR(13) + '' + CHAR(10) + '           ' + CHAR(13) + '' + CHAR(10) + '           UNION ALL ' + CHAR(13) + '' + CHAR(10) + '           (' + CHAR(13) + '' + CHAR(10) + '               SELECT DISTINCT af.function_id [function_id],' + CHAR(13) + '' + CHAR(10) + '                      ph.entity_id [sub_id],' + CHAR(13) + '' + CHAR(10) + '                      ISNULL(ph.entity_name, ''All'') [subsidiary],' + CHAR(13) + '' + CHAR(10) + '                      afu.role_id [role_id],' + CHAR(13) + '' + CHAR(10) + '                      '''' [role_name],' + CHAR(13) + '' + CHAR(10) + '                      '''' [role_description],' + CHAR(13) + '' + CHAR(10) + '                      '''' [role_type],' + CHAR(13) + '' + CHAR(10) + '                      au.user_f_name + ISNULL(au.user_m_name, '' '') + ISNULL(au.user_l_name, '' '') ' + CHAR(13) + '' + CHAR(10) + '                      [user],' + CHAR(13) + '' + CHAR(10) + '                      au.user_login_id [login_id],' + CHAR(13) + '' + CHAR(10) + '                      af.function_name [function_name],' + CHAR(13) + '' + CHAR(10) + '                      au.user_active  [active_user]' + CHAR(13) + '' + CHAR(10) + '               FROM   application_functions af' + CHAR(13) + '' + CHAR(10) + '                      INNER JOIN application_functional_users afu' + CHAR(13) + '' + CHAR(10) + '                           ON  afu.function_id = af.function_id' + CHAR(13) + '' + CHAR(10) + '                      INNER JOIN application_users au' + CHAR(13) + '' + CHAR(10) + '                           ON  au.user_login_id = afu.login_id' + CHAR(13) + '' + CHAR(10) + '                      LEFT  JOIN portfolio_hierarchy ph' + CHAR(13) + '' + CHAR(10) + '                           ON  ph.entity_id = afu.entity_id ' + CHAR(13) + '' + CHAR(10) + '           )' + CHAR(13) + '' + CHAR(10) + '       ) a', report_id = @report_id_data_source_dest 
		WHERE [name] = 'User Roles Privileges View'
			AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source([type_id], [name], [alias], [description], [tsql], report_id)
		SELECT TOP 1 1 AS [type_id], 'User Roles Privileges View' AS [name], 'URP' AS ALIAS, '' AS [description],'SELECT [function_id],' + CHAR(13) + '' + CHAR(10) + '       [sub_id],' + CHAR(13) + '' + CHAR(10) + '       [subsidiary],' + CHAR(13) + '' + CHAR(10) + '       [role_id],' + CHAR(13) + '' + CHAR(10) + '       [role_name],' + CHAR(13) + '' + CHAR(10) + '       [role_description],' + CHAR(13) + '' + CHAR(10) + '       [role_type],' + CHAR(13) + '' + CHAR(10) + '       [user],' + CHAR(13) + '' + CHAR(10) + '       [login_id],' + CHAR(13) + '' + CHAR(10) + '      [function_name],' + CHAR(13) + '' + CHAR(10) + '      [active_user]' + CHAR(13) + '' + CHAR(10) + '       --[__batch_report__]' + CHAR(13) + '' + CHAR(10) + 'FROM   (' + CHAR(13) + '' + CHAR(10) + '           (' + CHAR(13) + '' + CHAR(10) + '               SELECT DISTINCT af.function_id [function_id],' + CHAR(13) + '' + CHAR(10) + '                      ph.entity_id [sub_id],' + CHAR(13) + '' + CHAR(10) + '                      ISNULL(ph.entity_name, ''All'') [subsidiary],' + CHAR(13) + '' + CHAR(10) + '                      afu.role_id [role_id],' + CHAR(13) + '' + CHAR(10) + '                      asr.role_name [role_name],' + CHAR(13) + '' + CHAR(10) + '                      asr.role_description [role_description],' + CHAR(13) + '' + CHAR(10) + '                      sdv.code [role_type],' + CHAR(13) + '' + CHAR(10) + '                      au.user_f_name + ISNULL(au.user_m_name, '' '') + ISNULL(au.user_l_name, '' '') ' + CHAR(13) + '' + CHAR(10) + '                      [user],' + CHAR(13) + '' + CHAR(10) + '                      au.user_login_id [login_id],' + CHAR(13) + '' + CHAR(10) + '                      af.function_name [function_name],' + CHAR(13) + '' + CHAR(10) + '                      au.user_active  [active_user]' + CHAR(13) + '' + CHAR(10) + '               FROM   application_security_role asr' + CHAR(13) + '' + CHAR(10) + '                      INNER JOIN application_role_user aru' + CHAR(13) + '' + CHAR(10) + '                           ON  asr.role_id = aru.role_id' + CHAR(13) + '' + CHAR(10) + '                      INNER JOIN application_users au' + CHAR(13) + '' + CHAR(10) + '                           ON  au.user_login_id = aru.user_login_id' + CHAR(13) + '' + CHAR(10) + '                      INNER JOIN static_data_value sdv' + CHAR(13) + '' + CHAR(10) + '                           ON  asr.role_type_value_id = sdv.value_id' + CHAR(13) + '' + CHAR(10) + '                      INNER JOIN application_functional_users afu' + CHAR(13) + '' + CHAR(10) + '                           ON  afu.role_id = asr.role_id' + CHAR(13) + '' + CHAR(10) + '                      INNER JOIN application_functions af' + CHAR(13) + '' + CHAR(10) + '                           ON  af.function_id = afu.function_id' + CHAR(13) + '' + CHAR(10) + '                      LEFT JOIN portfolio_hierarchy ph' + CHAR(13) + '' + CHAR(10) + '                           ON  afu.entity_id = ph.entity_id' + CHAR(13) + '' + CHAR(10) + '           )' + CHAR(13) + '' + CHAR(10) + '           ' + CHAR(13) + '' + CHAR(10) + '           UNION ALL ' + CHAR(13) + '' + CHAR(10) + '           (' + CHAR(13) + '' + CHAR(10) + '               SELECT DISTINCT af.function_id [function_id],' + CHAR(13) + '' + CHAR(10) + '                      ph.entity_id [sub_id],' + CHAR(13) + '' + CHAR(10) + '                      ISNULL(ph.entity_name, ''All'') [subsidiary],' + CHAR(13) + '' + CHAR(10) + '                      afu.role_id [role_id],' + CHAR(13) + '' + CHAR(10) + '                      '''' [role_name],' + CHAR(13) + '' + CHAR(10) + '                      '''' [role_description],' + CHAR(13) + '' + CHAR(10) + '                      '''' [role_type],' + CHAR(13) + '' + CHAR(10) + '                      au.user_f_name + ISNULL(au.user_m_name, '' '') + ISNULL(au.user_l_name, '' '') ' + CHAR(13) + '' + CHAR(10) + '                      [user],' + CHAR(13) + '' + CHAR(10) + '                      au.user_login_id [login_id],' + CHAR(13) + '' + CHAR(10) + '                      af.function_name [function_name],' + CHAR(13) + '' + CHAR(10) + '                      au.user_active  [active_user]' + CHAR(13) + '' + CHAR(10) + '               FROM   application_functions af' + CHAR(13) + '' + CHAR(10) + '                      INNER JOIN application_functional_users afu' + CHAR(13) + '' + CHAR(10) + '                           ON  afu.function_id = af.function_id' + CHAR(13) + '' + CHAR(10) + '                      INNER JOIN application_users au' + CHAR(13) + '' + CHAR(10) + '                           ON  au.user_login_id = afu.login_id' + CHAR(13) + '' + CHAR(10) + '                      LEFT  JOIN portfolio_hierarchy ph' + CHAR(13) + '' + CHAR(10) + '                           ON  ph.entity_id = afu.entity_id ' + CHAR(13) + '' + CHAR(10) + '           )' + CHAR(13) + '' + CHAR(10) + '       ) a' AS [tsql], @report_id_data_source_dest AS report_id
	END 
	

	IF OBJECT_ID('tempdb..#data_source_column', 'U') IS NOT NULL
		DROP TABLE #data_source_column	
	CREATE TABLE #data_source_column(column_id INT)	

	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'User Roles Privileges View'
	            AND dsc.name =  'subsidiary'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Subsidiary'
			   , reqd_param = 0, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'User Roles Privileges View'
			AND dsc.name =  'subsidiary'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'subsidiary' AS [name], 'Subsidiary' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'User Roles Privileges View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	

	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'User Roles Privileges View'
	            AND dsc.name =  'user'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'User'
			   , reqd_param = 0, widget_id = 2, datatype_id = 5, param_data_source = 'SELECT user_f_name_ADD_ isnull(user_m_name, '' '') _ADD_ user_l_name, user_f_name_ADD_ isnull(user_m_name, '' '') _ADD_ user_l_name FROM application_users', param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'User Roles Privileges View'
			AND dsc.name =  'user'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'user' AS [name], 'User' AS ALIAS, 0 AS reqd_param, 2 AS widget_id, 5 AS datatype_id, 'SELECT user_f_name_ADD_ isnull(user_m_name, '' '') _ADD_ user_l_name, user_f_name_ADD_ isnull(user_m_name, '' '') _ADD_ user_l_name FROM application_users' AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'User Roles Privileges View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	

	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'User Roles Privileges View'
	            AND dsc.name =  'sub_id'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Subsidiary ID'
			   , reqd_param = 0, widget_id = 3, datatype_id = 4, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 2, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'User Roles Privileges View'
			AND dsc.name =  'sub_id'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'sub_id' AS [name], 'Subsidiary ID' AS ALIAS, 0 AS reqd_param, 3 AS widget_id, 4 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'User Roles Privileges View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	

	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'User Roles Privileges View'
	            AND dsc.name =  'function_id'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Function ID'
			   , reqd_param = 0, widget_id = 1, datatype_id = 4, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 2, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'User Roles Privileges View'
			AND dsc.name =  'function_id'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'function_id' AS [name], 'Function ID' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 4 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'User Roles Privileges View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	

	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'User Roles Privileges View'
	            AND dsc.name =  'function_name'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Function Name'
			   , reqd_param = 0, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'User Roles Privileges View'
			AND dsc.name =  'function_name'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'function_name' AS [name], 'Function Name' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'User Roles Privileges View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	

	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'User Roles Privileges View'
	            AND dsc.name =  'login_id'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Login ID'
			   , reqd_param = 0, widget_id = 2, datatype_id = 5, param_data_source = 'SELECT user_login_id,user_login_id FROM application_users', param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'User Roles Privileges View'
			AND dsc.name =  'login_id'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'login_id' AS [name], 'Login ID' AS ALIAS, 0 AS reqd_param, 2 AS widget_id, 5 AS datatype_id, 'SELECT user_login_id,user_login_id FROM application_users' AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'User Roles Privileges View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	

	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'User Roles Privileges View'
	            AND dsc.name =  'role_description'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Role Description'
			   , reqd_param = 0, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'User Roles Privileges View'
			AND dsc.name =  'role_description'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'role_description' AS [name], 'Role Description' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'User Roles Privileges View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	

	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'User Roles Privileges View'
	            AND dsc.name =  'role_id'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Role ID'
			   , reqd_param = 0, widget_id = 2, datatype_id = 4, param_data_source = 'SELECT role_id, role_name FROM application_security_role', param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 2, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'User Roles Privileges View'
			AND dsc.name =  'role_id'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'role_id' AS [name], 'Role ID' AS ALIAS, 0 AS reqd_param, 2 AS widget_id, 4 AS datatype_id, 'SELECT role_id, role_name FROM application_security_role' AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'User Roles Privileges View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	

	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'User Roles Privileges View'
	            AND dsc.name =  'role_name'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Role Name'
			   , reqd_param = 0, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'User Roles Privileges View'
			AND dsc.name =  'role_name'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'role_name' AS [name], 'Role Name' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'User Roles Privileges View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	

	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'User Roles Privileges View'
	            AND dsc.name =  'role_type'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Role Type'
			   , reqd_param = 0, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'User Roles Privileges View'
			AND dsc.name =  'role_type'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'role_type' AS [name], 'Role Type' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'User Roles Privileges View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	

	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'User Roles Privileges View'
	            AND dsc.name =  'active_user'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Status'
			   , reqd_param = 0, widget_id = 2, datatype_id = 5, param_data_source = 'SELECT ''y'', ''Active'' UNION ALL' + CHAR(10) + 'SELECT ''n'', ''Inactive''', param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'User Roles Privileges View'
			AND dsc.name =  'active_user'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'active_user' AS [name], 'Status' AS ALIAS, 0 AS reqd_param, 2 AS widget_id, 5 AS datatype_id, 'SELECT ''y'', ''Active'' UNION ALL' + CHAR(10) + 'SELECT ''n'', ''Inactive''' AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'User Roles Privileges View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	

	DELETE dsc
	FROM data_source_column dsc 
	INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		AND ds.[name] = 'User Roles Privileges View'
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
	