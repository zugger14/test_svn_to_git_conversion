/*
* Copy the code in the sql multiline textbox
--[__batch_report__]
SELECT *
FROM   (
           --Static data types
           SELECT sdv.type_id [type_id],
                  value_id [value_id],
                  sdt.[type_name] [data_type],
                  CASE value_id
                       WHEN 50 THEN sdv.code + ' (Group 1)'
                       WHEN 51 THEN sdv.code + ' (Group 2)'
                       WHEN 52 THEN sdv.code + ' (Group 3)'
                       WHEN 53 THEN sdv.code + ' (Group 4)'
                       ELSE sdv.code
                  END AS [name],
                  sdv.DESCRIPTION AS [description],
                  dbo.FNADateFormat(sdv.create_ts) [create_ts],
                  sdv.create_user,
                  sdv.update_user,
                  dbo.FNADateFormat(sdv.update_ts) [update_ts],
                  NULL [id]
           FROM   static_data_type sdt
                  INNER JOIN static_data_value sdv
                       ON  sdv.type_id = sdt.type_id
                  LEFT OUTER JOIN static_data_category sdc
                       ON  sdc.category_id = sdv.category_id
           WHERE  entity_id IS NULL
                  AND sdt.internal = 0
           UNION ALL --Book Attribute
           SELECT 4000 [type_id],
                  source_book.source_book_id [value_id],
                  'Book Attribute' [data_type],
                  source_book.source_book_name + CASE 
                                                      WHEN source_book.source_system_id 
                                                           = 2 THEN ''
                                                      ELSE '.' +
                                                           source_system_description.source_system_name
                                                 END AS NAME,
                  source_book.source_book_desc AS DESCRIPTION,
                  dbo.FNADateFormat(source_book.create_ts) [create_ts],
                  source_book.create_user [create_user],
                  dbo.FNADateFormat(source_book.update_ts) [updated_ts],
                  source_book.update_user [update_user],
                  source_system_book_id [id]
           FROM   source_book
                  INNER JOIN source_system_description
                       ON  source_system_description.source_system_id = 
                           source_book.source_system_id
           UNION ALL --Broker
           SELECT 4014 [type_id],
                  sb.source_broker_id AS [Source Broker ID],
                  'Broker' [data_type],
                  broker_name + CASE 
                                     WHEN sb.source_system_id = 2 THEN ''
                                     ELSE '.' + ssd.source_system_name
                                END AS NAME,
                  sb.broker_desc AS DESCRIPTION,
                  dbo.FNADateFormat(sb.create_ts) create_ts,
                  sb.create_user,
                  sb.update_user,
                  dbo.FNADateFormat(sb.update_ts) update_ts,
                  sb.broker_id [id]
           FROM   source_brokers sb
                  INNER JOIN source_system_description ssd
                       ON  ssd.source_system_id = sb.source_system_id
           UNION ALL --Commodity
           SELECT 4001 [type_id],
                  sc.source_commodity_id,
                  'Commodity' [data_type],
                  sc.commodity_name + CASE 
                                           WHEN sc.source_system_id 
                                                = 2 THEN ''
                                           ELSE '.' +
                                                source_system_description.source_system_name
                                      END AS NAME,
                  sc.commodity_desc AS DESCRIPTION,
                  dbo.FNADateFormat(sc.create_ts) create_ts,
                  sc.create_user,
                  sc.update_user,
                  dbo.FNADateFormat(sc.update_ts) update_ts,
                  sc.commodity_id [id]
           FROM   source_commodity sc
                  INNER JOIN source_system_description
                       ON  source_system_description.source_system_id = sc.source_system_id
           UNION ALL --Contract
           SELECT DISTINCT 4016 [type_id],
                  cg.contract_id [value_id],
                  'Contract' [data_type],
                  cg.contract_name + CASE 
                                          WHEN cg.source_system_id = 2 THEN ''
                                          ELSE '.' + source_system_description.source_system_name
                                     END AS [name],
                  cg.contract_desc AS [description],
                  dbo.FNADateTimeFormat(cg.create_ts, 1) [create_ts],
                  cg.create_user [create_user],
                  cg.update_user [update_user],
                  dbo.FNADateTimeFormat(cg.update_ts, 1) [update_ts],
                  source_contract_id [id]
           FROM   contract_group cg
                  INNER JOIN source_system_description
                       ON  source_system_description.source_system_id = cg.source_system_id
           UNION ALL --Counterparty   
           SELECT 4002 [type_id],
                  source_counterparty.source_counterparty_id ID,
                  'Counterparty' [data_type],
                  source_counterparty.counterparty_name + CASE 
                                                               WHEN 
                                                                    source_counterparty.source_system_id
                                                                    = 2 THEN ''
                                                               ELSE '.' +
                                                                    source_system_description.source_system_name
                                                          END AS NAME,
                  source_counterparty.counterparty_desc AS DESCRIPTION,
                  dbo.FNADateTimeFormat(source_counterparty.create_ts, 1) 
                  [Created Date],
                  source_counterparty.create_user [Created User],
                  source_counterparty.update_user [Updated User],
                  dbo.FNADateTimeFormat(source_counterparty.update_ts, 1) 
                  [Updated Date],
                  counterparty_id
           FROM   source_counterparty
                  INNER JOIN source_system_description
                       ON  source_system_description.source_system_id = 
                           source_counterparty.source_system_id
           UNION ALL --Currency  
           SELECT DISTINCT 4003 [type_id],
                  source_currency.source_currency_id,
                  'Currency' [data_type],
                  source_currency.currency_name + CASE 
                                                       WHEN 
                                                            source_system_description.source_system_id
                                                            = 2 THEN ''
                                                       ELSE '.' + 
                                                            source_system_description.source_system_name
                                                  END AS NAME,
                  source_currency.currency_desc AS DESCRIPTION,
                  dbo.FNADateTimeFormat(source_currency.create_ts, 1) 
                  [Created Date],
                  source_currency.create_user [Created User],
                  source_currency.update_user [Updated User],
                  dbo.FNADateTimeFormat(source_currency.update_ts, 1) 
                  [Updated Date],
                  currency_id [id]
           FROM   source_currency
                  INNER JOIN source_system_description
                       ON  source_system_description.source_system_id = 
                           source_currency.source_system_id
                  LEFT JOIN fas_strategy fs
                       ON  fs.source_system_id = source_currency.source_system_id
           UNION ALL --Deal Type
           SELECT 4004 [type_id],
                  source_deal_type.source_deal_type_id [Deal ID],
                  'Deal Type' [data_type],
                  source_deal_type_name + CASE 
                                               WHEN source_system_description.source_system_id 
                                                    = 2 THEN ''
                                               ELSE '.' + 
                                                    source_system_description.source_system_name
                                          END AS NAME,
                  source_deal_type.source_deal_desc AS DESCRIPTION,
                  dbo.FNADateTimeFormat(source_deal_type.create_ts, 1) 
                  [Created Date],
                  source_deal_type.create_user [Created User],
                  source_deal_type.update_user [Updated User],
                  dbo.FNADateTimeFormat(source_deal_type.update_ts, 1) 
                  [Updated Date],
                  deal_type_id [id]
           FROM   source_deal_type
                  INNER JOIN source_system_description
                       ON  source_system_description.source_system_id = 
                           source_deal_type.source_system_id 
           UNION ALL --Internal Desk
           SELECT 4019 [type_id],
                  source_internal_desk_id IDS,
                  'Internal Desk' [data_type],
                  internal_desk_name + CASE 
                                            WHEN source_system_description.source_system_id
                                                 = 2 THEN ''
                                            ELSE '.' + source_system_description.source_system_name
                                       END AS NAME,
                  internal_desk_desc DESCRIPTION,
                  dbo.FNADateTimeFormat(s.create_ts, 1) [Created Date],
                  s.create_user [Created User],
                  dbo.FNADateTimeFormat(s.update_ts, 1) [Updated Date],
                  s.update_user [Updated User],
                  internal_desk_id [id]
           FROM   source_internal_desk s
                  INNER JOIN source_system_description
                       ON  source_system_description.source_system_id = s.source_system_id
           UNION ALL--Internal Portfolio
           SELECT 4021 [type_id],
                  source_internal_portfolio_id ID,
                  'Internal Portfolio' [data_type],
                  internal_portfolio_name + CASE 
                                                 WHEN source_system_description.source_system_id
                                                      = 2 THEN ''
                                                 ELSE '.' + 
                                                      source_system_description.source_system_name
                                            END AS NAME,
                  internal_portfolio_desc DESCRIPTION,
                  dbo.FNADateTimeFormat(s.create_ts, 1) [Created Date],
                  s.create_user [Created User],
                  s.update_user [Updated User],
                  dbo.FNADateTimeFormat(s.update_ts, 1) [Updated Date],
                  internal_portfolio_id
           FROM   source_internal_portfolio s
                  INNER JOIN source_system_description
                       ON  source_system_description.source_system_id = s.source_system_id 
           UNION ALL --Legal Entity
           SELECT 4017 [type_id],
                  sle.source_legal_entity_id,
                  'Legal Entity' [data_type],
                  legal_entity_Name + CASE 
                                           WHEN source_System_Description.source_System_id 
                                                = 2 THEN ''
                                           ELSE '.' + source_System_Description.source_System_Name
                                      END AS NAME,
                  sle.legal_entity_desc AS DESCRIPTION,
                  dbo.FNADateTimeFormat(sle.create_ts, 1) [Created Date],
                  sle.create_user [Created User],
                  sle.update_user [Updated User],
                  dbo.FNADateTimeFormat(sle.update_ts, 1) [Updated Date],
                  legal_entity_id [id]
           FROM   source_legal_entity sle
                  INNER JOIN source_System_Description
                       ON  source_System_Description.source_System_id = sle.source_System_id 
           UNION ALL --Location Group
           SELECT 4030 [type_id],
                  sm.[source_major_location_ID] AS [Source Major Location ID],
                  'Location Group' [data_type],
                  sm.[location_name] AS [Name],
                  sm.[location_description] AS [Description],
                  dbo.FNADateTimeFormat(sm.create_ts, 1) [Created Date],
                  sm.create_user [Created User],
                  sm.update_user [Updated User],
                  dbo.FNADateTimeFormat(sm.update_ts, 1) [Updated Date],
                  sm.[location_name] [id]
           FROM   source_major_location sm
           WHERE  sm.source_system_id = 2 
           UNION ALL --product       
           SELECT 4020 [type_id],
                  source_product_id ID,
                  'Product' [data_type],
                  product_name + CASE 
                                      WHEN source_system_description.source_system_id 
                                           = 2 THEN ''
                                      ELSE '.' + source_system_description.source_system_name
                                 END AS NAME,
                  product_desc DESCRIPTION,
                  dbo.FNADateTimeFormat(s.create_ts, 1) [Created Date],
                  s.create_user [Created User],
                  s.update_user [Updated User],
                  dbo.FNADateTimeFormat(s.update_ts, 1) [Updated Date],
                  product_id [id]
           FROM   source_product s
                  INNER JOIN source_system_description
                       ON  source_system_description.source_system_id = s.source_system_id 
           UNION ALL--Trader        
           SELECT 4010 [type_id],
                  source_traders.source_trader_id,
                  'Trader' [data_type],
                  trader_name + CASE 
                                     WHEN source_system_description.source_system_id 
                                          = 2 THEN ''
                                     ELSE '.' + source_system_description.source_system_name
                                END AS NAME,
                  source_traders.trader_desc AS DESCRIPTION,
                  dbo.FNADateTimeFormat(source_traders.create_ts, 1) 
                  [Created Date],
                  source_traders.create_user [Created User],
                  source_traders.update_user [Updated User],
                  dbo.FNADateTimeFormat(source_traders.update_ts, 1) 
                  [Updated Date],
                  trader_id [id]
           FROM   source_traders
                  INNER JOIN source_system_description
                       ON  source_system_description.source_system_id = 
                           source_traders.source_system_id 
           UNION ALL-- UOM
           SELECT 4011 [type_id],
                  source_uom.source_uom_id ID,
                  'UOM' [data_type],
                  uom_name + CASE 
                                  WHEN source_system_description.source_system_id 
                                       = 2 THEN ''
                                  ELSE '.' + source_system_description.source_system_name
                             END AS NAME,
                  source_uom.uom_desc AS DESCRIPTION,
                  dbo.FNADateTimeFormat(source_uom.create_ts, 1) [Created Date],
                  source_uom.create_user [Created User],
                  source_uom.update_user [Updated User],
                  dbo.FNADateTimeFormat(source_uom.update_ts, 1) [Updated Date],
                  source_uom.uom_id [id]
           FROM   source_uom
                  INNER JOIN source_system_description
                       ON  source_system_description.source_system_id = 
                           source_uom.source_system_id
       ) sdev
*/
BEGIN TRY    BEGIN TRAN   
   DECLARE @report_id_data_source_dest INT       SELECT @report_id_data_source_dest = report_id   FROM report r   WHERE r.[name] = NULL
   IF EXISTS (SELECT 1               FROM data_source               WHERE [name] = 'Static Data Export View'      AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))        BEGIN    UPDATE data_source    SET alias = 'sdev', description = ''    , [tsql] = CAST('' AS VARCHAR(MAX)) + 'Please Copy the view code from the export file', report_id = @report_id_data_source_dest     WHERE [name] = 'Static Data Export View'     AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1)   END    ELSE   BEGIN    INSERT INTO data_source([type_id], [name], [alias], [description], [tsql], report_id)    SELECT TOP 1 1 AS [type_id], 'Static Data Export View' AS [name], 'sdev' AS ALIAS, '' AS [description],'Please Copy the view code from the export file' AS [tsql], @report_id_data_source_dest AS report_id   END    
   IF OBJECT_ID('tempdb..#data_source_column', 'U') IS NOT NULL    DROP TABLE #data_source_column    CREATE TABLE #data_source_column(column_id INT) 
   IF EXISTS (SELECT 1               FROM data_source_column dsc               INNER JOIN data_source ds on ds.data_source_id = dsc.source_id               WHERE ds.[name] = 'Static Data Export View'               AND dsc.name =  'create_ts'      AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))   BEGIN    UPDATE dsc      SET alias = 'Create Ts'        , reqd_param = 0, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0    OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)    FROM data_source_column dsc    INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id     WHERE ds.[name] = 'Static Data Export View'     AND dsc.name =  'create_ts'     AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)   END    ELSE   BEGIN    INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id    , datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template)    OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)    SELECT TOP 1 ds.data_source_id AS source_id, 'create_ts' AS [name], 'Create Ts' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,0 AS column_template  FROM sys.objects o    INNER JOIN data_source ds ON ds.[name] = 'Static Data Export View'     AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)    LEFT JOIN report r ON r.report_id = ds.report_id     AND ds.[type_id] = 2     AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)    WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)   END       
   IF EXISTS (SELECT 1               FROM data_source_column dsc               INNER JOIN data_source ds on ds.data_source_id = dsc.source_id               WHERE ds.[name] = 'Static Data Export View'               AND dsc.name =  'create_user'      AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))   BEGIN    UPDATE dsc      SET alias = 'Create User'        , reqd_param = 0, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0    OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)    FROM data_source_column dsc    INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id     WHERE ds.[name] = 'Static Data Export View'     AND dsc.name =  'create_user'     AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)   END    ELSE   BEGIN    INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id    , datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template)    OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)    SELECT TOP 1 ds.data_source_id AS source_id, 'create_user' AS [name], 'Create User' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,0 AS column_template  FROM sys.objects o    INNER JOIN data_source ds ON ds.[name] = 'Static Data Export View'     AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)    LEFT JOIN report r ON r.report_id = ds.report_id     AND ds.[type_id] = 2     AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)    WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)   END       
   IF EXISTS (SELECT 1               FROM data_source_column dsc               INNER JOIN data_source ds on ds.data_source_id = dsc.source_id               WHERE ds.[name] = 'Static Data Export View'               AND dsc.name =  'data_type'      AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))   BEGIN    UPDATE dsc      SET alias = 'Data Type'        , reqd_param = 0, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0    OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)    FROM data_source_column dsc    INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id     WHERE ds.[name] = 'Static Data Export View'     AND dsc.name =  'data_type'     AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)   END    ELSE   BEGIN    INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id    , datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template)    OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)    SELECT TOP 1 ds.data_source_id AS source_id, 'data_type' AS [name], 'Data Type' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,0 AS column_template  FROM sys.objects o    INNER JOIN data_source ds ON ds.[name] = 'Static Data Export View'     AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)    LEFT JOIN report r ON r.report_id = ds.report_id     AND ds.[type_id] = 2     AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)    WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)   END       
   IF EXISTS (SELECT 1               FROM data_source_column dsc               INNER JOIN data_source ds on ds.data_source_id = dsc.source_id               WHERE ds.[name] = 'Static Data Export View'               AND dsc.name =  'description'      AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))   BEGIN    UPDATE dsc      SET alias = 'Description'        , reqd_param = 0, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0    OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)    FROM data_source_column dsc    INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id     WHERE ds.[name] = 'Static Data Export View'     AND dsc.name =  'description'     AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)   END    ELSE   BEGIN    INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id    , datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template)    OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)    SELECT TOP 1 ds.data_source_id AS source_id, 'description' AS [name], 'Description' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,0 AS column_template  FROM sys.objects o    INNER JOIN data_source ds ON ds.[name] = 'Static Data Export View'     AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)    LEFT JOIN report r ON r.report_id = ds.report_id     AND ds.[type_id] = 2     AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)    WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)   END       
   IF EXISTS (SELECT 1               FROM data_source_column dsc               INNER JOIN data_source ds on ds.data_source_id = dsc.source_id               WHERE ds.[name] = 'Static Data Export View'               AND dsc.name =  'name'      AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))   BEGIN    UPDATE dsc      SET alias = 'Name'        , reqd_param = 0, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0    OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)    FROM data_source_column dsc    INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id     WHERE ds.[name] = 'Static Data Export View'     AND dsc.name =  'name'     AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)   END    ELSE   BEGIN    INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id    , datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template)    OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)    SELECT TOP 1 ds.data_source_id AS source_id, 'name' AS [name], 'Name' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,0 AS column_template  FROM sys.objects o    INNER JOIN data_source ds ON ds.[name] = 'Static Data Export View'     AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)    LEFT JOIN report r ON r.report_id = ds.report_id     AND ds.[type_id] = 2     AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)    WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)   END       
   IF EXISTS (SELECT 1               FROM data_source_column dsc               INNER JOIN data_source ds on ds.data_source_id = dsc.source_id               WHERE ds.[name] = 'Static Data Export View'               AND dsc.name =  'type_id'      AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))   BEGIN    UPDATE dsc      SET alias = 'Type ID'        , reqd_param = 0, widget_id = 1, datatype_id = 4, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 2    OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)    FROM data_source_column dsc    INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id     WHERE ds.[name] = 'Static Data Export View'     AND dsc.name =  'type_id'     AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)   END    ELSE   BEGIN    INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id    , datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template)    OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)    SELECT TOP 1 ds.data_source_id AS source_id, 'type_id' AS [name], 'Type ID' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 4 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,2 AS column_template  FROM sys.objects o    INNER JOIN data_source ds ON ds.[name] = 'Static Data Export View'     AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)    LEFT JOIN report r ON r.report_id = ds.report_id     AND ds.[type_id] = 2     AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)    WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)   END       
   IF EXISTS (SELECT 1               FROM data_source_column dsc               INNER JOIN data_source ds on ds.data_source_id = dsc.source_id               WHERE ds.[name] = 'Static Data Export View'               AND dsc.name =  'update_ts'      AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))   BEGIN    UPDATE dsc      SET alias = 'Update Ts'        , reqd_param = 0, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0    OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)    FROM data_source_column dsc    INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id     WHERE ds.[name] = 'Static Data Export View'     AND dsc.name =  'update_ts'     AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)   END    ELSE   BEGIN    INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id    , datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template)    OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)    SELECT TOP 1 ds.data_source_id AS source_id, 'update_ts' AS [name], 'Update Ts' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,0 AS column_template  FROM sys.objects o    INNER JOIN data_source ds ON ds.[name] = 'Static Data Export View'     AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)    LEFT JOIN report r ON r.report_id = ds.report_id     AND ds.[type_id] = 2     AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)    WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)   END       
   IF EXISTS (SELECT 1               FROM data_source_column dsc               INNER JOIN data_source ds on ds.data_source_id = dsc.source_id               WHERE ds.[name] = 'Static Data Export View'               AND dsc.name =  'update_user'      AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))   BEGIN    UPDATE dsc      SET alias = 'Update User'        , reqd_param = 0, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0    OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)    FROM data_source_column dsc    INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id     WHERE ds.[name] = 'Static Data Export View'     AND dsc.name =  'update_user'     AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)   END    ELSE   BEGIN    INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id    , datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template)    OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)    SELECT TOP 1 ds.data_source_id AS source_id, 'update_user' AS [name], 'Update User' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,0 AS column_template  FROM sys.objects o    INNER JOIN data_source ds ON ds.[name] = 'Static Data Export View'     AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)    LEFT JOIN report r ON r.report_id = ds.report_id     AND ds.[type_id] = 2     AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)    WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)   END       
   IF EXISTS (SELECT 1               FROM data_source_column dsc               INNER JOIN data_source ds on ds.data_source_id = dsc.source_id               WHERE ds.[name] = 'Static Data Export View'               AND dsc.name =  'value_id'      AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))   BEGIN    UPDATE dsc      SET alias = 'Value ID'        , reqd_param = 0, widget_id = 1, datatype_id = 4, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 2    OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)    FROM data_source_column dsc    INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id     WHERE ds.[name] = 'Static Data Export View'     AND dsc.name =  'value_id'     AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)   END    ELSE   BEGIN    INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id    , datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template)    OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)    SELECT TOP 1 ds.data_source_id AS source_id, 'value_id' AS [name], 'Value ID' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 4 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,2 AS column_template  FROM sys.objects o    INNER JOIN data_source ds ON ds.[name] = 'Static Data Export View'     AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)    LEFT JOIN report r ON r.report_id = ds.report_id     AND ds.[type_id] = 2     AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)    WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)   END       
   IF EXISTS (SELECT 1               FROM data_source_column dsc               INNER JOIN data_source ds on ds.data_source_id = dsc.source_id               WHERE ds.[name] = 'Static Data Export View'               AND dsc.name =  'id'      AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))   BEGIN    UPDATE dsc      SET alias = 'ID'        , reqd_param = 0, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0    OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)    FROM data_source_column dsc    INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id     WHERE ds.[name] = 'Static Data Export View'     AND dsc.name =  'id'     AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)   END    ELSE   BEGIN    INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id    , datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template)    OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)    SELECT TOP 1 ds.data_source_id AS source_id, 'id' AS [name], 'ID' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,0 AS column_template  FROM sys.objects o    INNER JOIN data_source ds ON ds.[name] = 'Static Data Export View'     AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)    LEFT JOIN report r ON r.report_id = ds.report_id     AND ds.[type_id] = 2     AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)    WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)   END       
   DELETE dsc   FROM data_source_column dsc    INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id     AND ds.[name] = 'Static Data Export View'    AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1)   LEFT JOIN #data_source_column tdsc ON tdsc.column_id = dsc.data_source_column_id   WHERE tdsc.column_id IS NULL   
COMMIT TRAN    END TRY   BEGIN CATCH    IF @@TRANCOUNT > 0     ROLLBACK TRAN;         DECLARE @error_msg VARCHAR(1000)                SET @error_msg = ERROR_MESSAGE()                RAISERROR (@error_msg, 16, 1);   END CATCH      