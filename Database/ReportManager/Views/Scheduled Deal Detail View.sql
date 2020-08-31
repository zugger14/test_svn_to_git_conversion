BEGIN TRY
		BEGIN TRAN
	

	DECLARE @report_id_data_source_dest INT 
	
	SELECT @report_id_data_source_dest = report_id
	FROM report r
	WHERE r.[name] = NULL

	IF EXISTS (SELECT 1 
	           FROM data_source 
	           WHERE [name] = 'Scheduled Deal Detail View'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
			
	BEGIN
		UPDATE data_source
		SET alias = 'SDDR', description = 'Scheduled Deal Detail View'
		, [tsql] = CAST('' AS VARCHAR(MAX)) + '

DECLARE @_flow_date_from			DATETIME 
	, @_flow_date_to			DATETIME
	, @_sql				VARCHAR(MAX)
	, @_sdv_from_deal			INT
	, @_sdv_to_deal			INT
	
	
IF ''@flow_date_from'' <> ''NULL''
SELECT @_flow_date_from = dbo.FNAClientToSqlDate(''@flow_date_from'')

IF ''@flow_date_to'' <> ''NULL''
SELECT @_flow_date_to = dbo.FNAClientToSqlDate(''@flow_date_to'')

IF OBJECT_ID ( ''tempdb..#books'') IS NOT NULL DROP TABLE #books

SELECT DISTINCT sub.entity_id sub_id,
	   stra.entity_id stra_id,
       book.entity_id book_id,
	   sub.entity_name AS sub,
	   stra.entity_name AS stra,
	   book.entity_name AS book,
        ssbm.source_system_book_id1,
       ssbm.source_system_book_id2,
       ssbm.source_system_book_id3,
       ssbm.source_system_book_id4,
	   ssbm.book_deal_type_map_id
INTO #books
FROM   portfolio_hierarchy book(NOLOCK)
INNER JOIN Portfolio_hierarchy stra(NOLOCK)
	ON  book.parent_entity_id = stra.entity_id
INNER JOIN portfolio_hierarchy sub (NOLOCK)
	ON  stra.parent_entity_id = sub.entity_id
INNER JOIN source_system_book_map ssbm
	ON  ssbm.fas_book_id = book.entity_id
WHERE 1 = 1
AND (''@sub_id'' = ''NULL'' OR sub.entity_id IN (@sub_id)) 
AND (''@stra_id'' = ''NULL'' OR stra.entity_id IN (@stra_id)) 
AND (''@book_id'' = ''NULL'' OR book.entity_id IN (@book_id))
AND (''@sub_book_id'' = ''NULL'' OR ssbm.book_deal_type_map_id IN (@sub_book_id))

			
SELECT @_sdv_from_deal = value_id
FROM static_data_value
WHERE [TYPE_ID] = 5500 AND code = ''From Deal''

SELECT @_sdv_to_deal = value_id
FROM static_data_value
WHERE [TYPE_ID] = 5500 AND code = ''To Deal''

IF OBJECT_ID (''tempdb..#total_phy_deals'') IS NOT NULL DROP TABLE #total_phy_deals
IF OBJECT_ID (''tempdb..#total_scheduled_deals'') IS NOT NULL DROP TABLE #total_scheduled_deals
IF OBJECT_ID (''tempdb..#list_template'') IS NOT NULL DROP TABLE #list_template
IF OBJECT_ID (''tempdb..#deal_detail'') IS NOT NULL DROP TABLE #deal_detail

SELECT sdh.source_deal_header_id
INTO #total_phy_deals
FROM source_deal_header sdh
INNER JOIN #books sb ON sb.source_system_book_id1 = sdh.source_system_book_id1
	AND sb.source_system_book_id2 = sdh.source_system_book_id2
	AND sb.source_system_book_id3 = sdh.source_system_book_id3
	AND sb.source_system_book_id4 = sdh.source_system_book_id4
WHERE sdh.source_deal_type_id = 2 --physical deals

SELECT gmv.clm1_value [type id],
	sdht.template_id
INTO #list_template	
FROM generic_mapping_header gmh
INNER JOIN generic_mapping_values gmv ON gmh.mapping_table_id = gmv.mapping_table_id 
	AND gmh.mapping_name = ''Imbalance Report''
LEFT JOIN source_deal_header_template sdht ON cast(sdht.template_id AS VARCHAR(100)) = gmv.clm3_value
WHERE gmv.clm1_value IN (''1'', ''5'')	--1 for transportaion and 5 for MR

SELECT * 
INTO #total_scheduled_deals
FROM (
	SELECT sdh.source_deal_header_id			
			, uddft_sch.Field_label
			, uddf_sch.udf_value [udf_value]
			, sdh.template_id
			, tpd.source_deal_header_id [phy_deal_id]
			, sdh.contract_id
			, uddf_to.udf_value to_deal
	FROM [user_defined_deal_fields_template] uddft
	INNER JOIN source_deal_header_template sdht ON sdht.template_id = uddft.template_id
	INNER JOIN #list_template lt ON lt.template_id = sdht.template_id
	INNER JOIN  user_defined_deal_fields uddf ON uddf.udf_template_id = uddft.udf_template_id 
		AND uddft.field_name = @_sdv_from_deal 
	INNER JOIN #total_phy_deals tpd ON CAST(tpd.source_deal_header_id AS VARCHAR) = uddf.udf_value		
	INNER JOIN source_deal_header sdh ON sdh.source_deal_header_id = uddf.source_deal_header_id
	INNER JOIN user_defined_deal_fields_template uddft_sch ON sdh.template_id = uddft_sch.template_id
	INNER JOIN user_defined_deal_fields uddf_sch ON uddf_sch.udf_template_id = uddft_sch.udf_template_id 
		AND sdh.source_deal_header_id = uddf_sch.source_deal_header_id
	INNER JOIN user_defined_deal_fields_template uddft_to ON uddft_sch.template_id = uddft_to.template_id
	AND uddft_to.field_name = @_sdv_to_deal
	INNER JOIN  user_defined_deal_fields uddf_to ON uddf_to.udf_template_id = uddft_to.udf_template_id 
		AND uddf_sch.source_deal_header_id = uddf_to.source_deal_header_id
) s1
PIVOT(MAX(udf_value) FOR Field_label IN ([Scheduled ID], [Path Detail ID])) AS a	  

CREATE TABLE #deal_detail(
	source_deal_header_id	INT
	, path_code				VARCHAR(50)
	, path_id				INT
	, receipt_location		VARCHAR(100)
	, delivery_location		VARCHAR(100)
    , delivery_location_id	INT
	, receipt_volume		NUMERIC(38,20)
	, delivery_volume		NUMERIC(38,20)
	, term_start			DATETIME
	, term_end				DATETIME
	, deal_volume_uom_id	INT
	, phy_deal_id			INT
    , path_detail_id		INT
    , contract_id			INT
    , from_location			VARCHAR(150)
    , to_location			VARCHAR(150)
    , groupPath				CHAR
    , template_name			VARCHAR(150)
    ,to_deal int
)

SET @_sql = ''
INSERT INTO #deal_detail (
	source_deal_header_id	
	, path_code				
	, path_id				
	, receipt_location		
	, delivery_location
    , delivery_location_id		
	, receipt_volume		
	, delivery_volume		
	, term_start			
	, term_end				
	, deal_volume_uom_id	
	, phy_deal_id
    , path_detail_id
    , contract_id
    , from_location
    , to_location
    , groupPath
    , template_name
    , to_deal 
	)
SELECT tsd.source_deal_header_id
	, dp.path_code
	, dp.path_id 
	, CASE WHEN sdd.leg = 1 THEN sm1.Location_Name ELSE NULL END receipt_location
	, CASE WHEN sdd.leg = 2 THEN sm1.Location_Name ELSE NULL END delivery_location
    ,CASE WHEN sdd.leg = 2 THEN sm1.source_minor_location_id ELSE NULL END delivery_location_id
	, CASE WHEN sdd.leg = 1 THEN sdd.deal_volume ELSE NULL END receipt_volume
	, CASE WHEN sdd.leg = 2 THEN sdd.deal_volume ELSE NULL END delivery_volume
	, sdd.term_start
	, sdd.term_end
	, sdd.deal_volume_uom_id
	, tsd.phy_deal_id
	, tsd.[Path Detail ID]
	, tsd.contract_id
	, sml_from.Location_Name
    , sml_to.Location_Name
    , dp.groupPath
    , sdht.template_name
    , tsd.to_deal
FROM  #total_scheduled_deals tsd 
	INNER JOIN source_deal_detail sdd ON sdd.source_deal_header_id = tsd.source_deal_header_id
	INNER JOIN source_deal_header_template sdht ON sdht.template_id = tsd.template_id
	INNER JOIN deal_schedule ds ON ds.deal_schedule_id = tsd.[Scheduled ID]	
	INNER JOIN delivery_path dp ON dp.path_id = ds.path_id
	LEFT JOIN source_minor_location sm1 ON sm1.source_minor_location_id = sdd.location_id
	LEFT JOIN source_minor_location sml_from ON sml_from.source_minor_location_id = dp.from_location
	LEFT JOIN source_minor_location sml_to ON sml_to.source_minor_location_id = dp.to_location
WHERE 1 = 1 '' +
CASE WHEN @_flow_date_from IS NOT NULL THEN '' AND sdd.term_start >= '''''' + CAST(@_flow_date_from AS VARCHAR) + '''''''' ELSE '''' END
+ CASE WHEN @_flow_date_to IS NOT NULL THEN '' AND sdd.term_end <= '''''' + CAST(@_flow_date_to AS VARCHAR) + '''''''' ELSE '''' END

EXEC(@_sql)

SELECT 
		dd.phy_deal_id [from_source_deal_header_id],
		dbo.FNADateFormat(dd.term_start) [flow_date_from],
		dbo.FNADateFormat(dd.term_end) [flow_date_to],
		dd.source_deal_header_id  [source_deal_header_id]
		,  MAX(path_code) [path]
		, MAX(receipt_location) [receipt_location]	
		, MAX(delivery_location)[delivery_location]
        , MAX(delivery_location_id)[delivery_location_id]
		, SUM(receipt_volume) [receipt_volume]
		, SUM(delivery_volume) [delivery_volume] 
		, MAX(su.uom_name) [uom]
		, MAX(b.sub_id) sub_id	--physical deal sub_id
		, MAX(b.stra_id) stra_id
		, MAX(b.book_id) book_id
		, MAX(b.book_deal_type_map_id) sub_book_id
		, MAX(sdh.counterparty_id) counterparty_id
		, MAX(sc.counterparty_name) [counterparty]
		, MAX(cg.contract_id) contract_id
		, MAX(cg.contract_name) [contract]
		, MAX(dd.from_location) [from_location]
		, MAX(dd.to_location) [to_location]
		, MAX(dd.groupPath) [group_path]
		, MAX(dd.template_name) template_name
		, MAX(dd.to_deal) to_deal
		--[__batch_report__]		
FROM  #deal_detail dd
	INNER JOIN source_deal_header sdh ON sdh.source_deal_header_id = dd.phy_deal_id
	INNER JOIN #books b ON b.source_system_book_id1 = sdh.source_system_book_id1
		AND b.source_system_book_id2 = sdh.source_system_book_id2
		AND b.source_system_book_id3 = sdh.source_system_book_id3
		AND b.source_system_book_id4 = sdh.source_system_book_id4
	LEFT JOIN source_uom su ON su.source_uom_id = dd.deal_volume_uom_id
	LEFT JOIN source_counterparty sc ON sc.source_counterparty_id = sdh.counterparty_id
	LEFT JOIN contract_group cg ON cg.contract_id = dd.contract_id
	GROUP BY dd.term_start, dd.term_end, dd.source_deal_header_id, dd.phy_deal_id, dd.path_detail_id
	ORDER BY dd.phy_deal_id, dd.term_start, dd.path_detail_id
	
	', report_id = @report_id_data_source_dest 
		WHERE [name] = 'Scheduled Deal Detail View'
			AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1)
	END	
	

	IF NOT EXISTS (SELECT 1 
	           FROM data_source 
	           WHERE [name] = 'Scheduled Deal Detail View'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		INSERT INTO data_source([type_id], [name], [alias], [description], [tsql], report_id)
		SELECT TOP 1 1 AS [type_id], 'Scheduled Deal Detail View' AS [name], 'SDDR' AS ALIAS, 'Scheduled Deal Detail View' AS [description],'

DECLARE @_flow_date_from			DATETIME 
	, @_flow_date_to			DATETIME
	, @_sql				VARCHAR(MAX)
	, @_sdv_from_deal			INT
	, @_sdv_to_deal			INT
	
	
IF ''@flow_date_from'' <> ''NULL''
SELECT @_flow_date_from = dbo.FNAClientToSqlDate(''@flow_date_from'')

IF ''@flow_date_to'' <> ''NULL''
SELECT @_flow_date_to = dbo.FNAClientToSqlDate(''@flow_date_to'')

IF OBJECT_ID ( ''tempdb..#books'') IS NOT NULL DROP TABLE #books

SELECT DISTINCT sub.entity_id sub_id,
	   stra.entity_id stra_id,
       book.entity_id book_id,
	   sub.entity_name AS sub,
	   stra.entity_name AS stra,
	   book.entity_name AS book,
        ssbm.source_system_book_id1,
       ssbm.source_system_book_id2,
       ssbm.source_system_book_id3,
       ssbm.source_system_book_id4,
	   ssbm.book_deal_type_map_id
INTO #books
FROM   portfolio_hierarchy book(NOLOCK)
INNER JOIN Portfolio_hierarchy stra(NOLOCK)
	ON  book.parent_entity_id = stra.entity_id
INNER JOIN portfolio_hierarchy sub (NOLOCK)
	ON  stra.parent_entity_id = sub.entity_id
INNER JOIN source_system_book_map ssbm
	ON  ssbm.fas_book_id = book.entity_id
WHERE 1 = 1
AND (''@sub_id'' = ''NULL'' OR sub.entity_id IN (@sub_id)) 
AND (''@stra_id'' = ''NULL'' OR stra.entity_id IN (@stra_id)) 
AND (''@book_id'' = ''NULL'' OR book.entity_id IN (@book_id))
AND (''@sub_book_id'' = ''NULL'' OR ssbm.book_deal_type_map_id IN (@sub_book_id))

			
SELECT @_sdv_from_deal = value_id
FROM static_data_value
WHERE [TYPE_ID] = 5500 AND code = ''From Deal''

SELECT @_sdv_to_deal = value_id
FROM static_data_value
WHERE [TYPE_ID] = 5500 AND code = ''To Deal''

IF OBJECT_ID (''tempdb..#total_phy_deals'') IS NOT NULL DROP TABLE #total_phy_deals
IF OBJECT_ID (''tempdb..#total_scheduled_deals'') IS NOT NULL DROP TABLE #total_scheduled_deals
IF OBJECT_ID (''tempdb..#list_template'') IS NOT NULL DROP TABLE #list_template
IF OBJECT_ID (''tempdb..#deal_detail'') IS NOT NULL DROP TABLE #deal_detail

SELECT sdh.source_deal_header_id
INTO #total_phy_deals
FROM source_deal_header sdh
INNER JOIN #books sb ON sb.source_system_book_id1 = sdh.source_system_book_id1
	AND sb.source_system_book_id2 = sdh.source_system_book_id2
	AND sb.source_system_book_id3 = sdh.source_system_book_id3
	AND sb.source_system_book_id4 = sdh.source_system_book_id4
WHERE sdh.source_deal_type_id = 2 --physical deals

SELECT gmv.clm1_value [type id],
	sdht.template_id
INTO #list_template	
FROM generic_mapping_header gmh
INNER JOIN generic_mapping_values gmv ON gmh.mapping_table_id = gmv.mapping_table_id 
	AND gmh.mapping_name = ''Imbalance Report''
LEFT JOIN source_deal_header_template sdht ON cast(sdht.template_id AS VARCHAR(100)) = gmv.clm3_value
WHERE gmv.clm1_value IN (''1'', ''5'')	--1 for transportaion and 5 for MR

SELECT * 
INTO #total_scheduled_deals
FROM (
	SELECT sdh.source_deal_header_id			
			, uddft_sch.Field_label
			, uddf_sch.udf_value [udf_value]
			, sdh.template_id
			, tpd.source_deal_header_id [phy_deal_id]
			, sdh.contract_id
			, uddf_to.udf_value to_deal
	FROM [user_defined_deal_fields_template] uddft
	INNER JOIN source_deal_header_template sdht ON sdht.template_id = uddft.template_id
	INNER JOIN #list_template lt ON lt.template_id = sdht.template_id
	INNER JOIN  user_defined_deal_fields uddf ON uddf.udf_template_id = uddft.udf_template_id 
		AND uddft.field_name = @_sdv_from_deal 
	INNER JOIN #total_phy_deals tpd ON CAST(tpd.source_deal_header_id AS VARCHAR) = uddf.udf_value		
	INNER JOIN source_deal_header sdh ON sdh.source_deal_header_id = uddf.source_deal_header_id
	INNER JOIN user_defined_deal_fields_template uddft_sch ON sdh.template_id = uddft_sch.template_id
	INNER JOIN user_defined_deal_fields uddf_sch ON uddf_sch.udf_template_id = uddft_sch.udf_template_id 
		AND sdh.source_deal_header_id = uddf_sch.source_deal_header_id
	INNER JOIN user_defined_deal_fields_template uddft_to ON uddft_sch.template_id = uddft_to.template_id
	AND uddft_to.field_name = @_sdv_to_deal
	INNER JOIN  user_defined_deal_fields uddf_to ON uddf_to.udf_template_id = uddft_to.udf_template_id 
		AND uddf_sch.source_deal_header_id = uddf_to.source_deal_header_id
) s1
PIVOT(MAX(udf_value) FOR Field_label IN ([Scheduled ID], [Path Detail ID])) AS a	  

CREATE TABLE #deal_detail(
	source_deal_header_id	INT
	, path_code				VARCHAR(50)
	, path_id				INT
	, receipt_location		VARCHAR(100)
	, delivery_location		VARCHAR(100)
    , delivery_location_id	INT
	, receipt_volume		NUMERIC(38,20)
	, delivery_volume		NUMERIC(38,20)
	, term_start			DATETIME
	, term_end				DATETIME
	, deal_volume_uom_id	INT
	, phy_deal_id			INT
    , path_detail_id		INT
    , contract_id			INT
    , from_location			VARCHAR(150)
    , to_location			VARCHAR(150)
    , groupPath				CHAR
    , template_name			VARCHAR(150)
    ,to_deal int
)

SET @_sql = ''
INSERT INTO #deal_detail (
	source_deal_header_id	
	, path_code				
	, path_id				
	, receipt_location		
	, delivery_location
    , delivery_location_id		
	, receipt_volume		
	, delivery_volume		
	, term_start			
	, term_end				
	, deal_volume_uom_id	
	, phy_deal_id
    , path_detail_id
    , contract_id
    , from_location
    , to_location
    , groupPath
    , template_name
    , to_deal 
	)
SELECT tsd.source_deal_header_id
	, dp.path_code
	, dp.path_id 
	, CASE WHEN sdd.leg = 1 THEN sm1.Location_Name ELSE NULL END receipt_location
	, CASE WHEN sdd.leg = 2 THEN sm1.Location_Name ELSE NULL END delivery_location
    ,CASE WHEN sdd.leg = 2 THEN sm1.source_minor_location_id ELSE NULL END delivery_location_id
	, CASE WHEN sdd.leg = 1 THEN sdd.deal_volume ELSE NULL END receipt_volume
	, CASE WHEN sdd.leg = 2 THEN sdd.deal_volume ELSE NULL END delivery_volume
	, sdd.term_start
	, sdd.term_end
	, sdd.deal_volume_uom_id
	, tsd.phy_deal_id
	, tsd.[Path Detail ID]
	, tsd.contract_id
	, sml_from.Location_Name
    , sml_to.Location_Name
    , dp.groupPath
    , sdht.template_name
    , tsd.to_deal
FROM  #total_scheduled_deals tsd 
	INNER JOIN source_deal_detail sdd ON sdd.source_deal_header_id = tsd.source_deal_header_id
	INNER JOIN source_deal_header_template sdht ON sdht.template_id = tsd.template_id
	INNER JOIN deal_schedule ds ON ds.deal_schedule_id = tsd.[Scheduled ID]	
	INNER JOIN delivery_path dp ON dp.path_id = ds.path_id
	LEFT JOIN source_minor_location sm1 ON sm1.source_minor_location_id = sdd.location_id
	LEFT JOIN source_minor_location sml_from ON sml_from.source_minor_location_id = dp.from_location
	LEFT JOIN source_minor_location sml_to ON sml_to.source_minor_location_id = dp.to_location
WHERE 1 = 1 '' +
CASE WHEN @_flow_date_from IS NOT NULL THEN '' AND sdd.term_start >= '''''' + CAST(@_flow_date_from AS VARCHAR) + '''''''' ELSE '''' END
+ CASE WHEN @_flow_date_to IS NOT NULL THEN '' AND sdd.term_end <= '''''' + CAST(@_flow_date_to AS VARCHAR) + '''''''' ELSE '''' END

EXEC(@_sql)

SELECT 
		dd.phy_deal_id [from_source_deal_header_id],
		dbo.FNADateFormat(dd.term_start) [flow_date_from],
		dbo.FNADateFormat(dd.term_end) [flow_date_to],
		dd.source_deal_header_id  [source_deal_header_id]
		,  MAX(path_code) [path]
		, MAX(receipt_location) [receipt_location]	
		, MAX(delivery_location)[delivery_location]
        , MAX(delivery_location_id)[delivery_location_id]
		, SUM(receipt_volume) [receipt_volume]
		, SUM(delivery_volume) [delivery_volume] 
		, MAX(su.uom_name) [uom]
		, MAX(b.sub_id) sub_id	--physical deal sub_id
		, MAX(b.stra_id) stra_id
		, MAX(b.book_id) book_id
		, MAX(b.book_deal_type_map_id) sub_book_id
		, MAX(sdh.counterparty_id) counterparty_id
		, MAX(sc.counterparty_name) [counterparty]
		, MAX(cg.contract_id) contract_id
		, MAX(cg.contract_name) [contract]
		, MAX(dd.from_location) [from_location]
		, MAX(dd.to_location) [to_location]
		, MAX(dd.groupPath) [group_path]
		, MAX(dd.template_name) template_name
		, MAX(dd.to_deal) to_deal
		--[__batch_report__]		
FROM  #deal_detail dd
	INNER JOIN source_deal_header sdh ON sdh.source_deal_header_id = dd.phy_deal_id
	INNER JOIN #books b ON b.source_system_book_id1 = sdh.source_system_book_id1
		AND b.source_system_book_id2 = sdh.source_system_book_id2
		AND b.source_system_book_id3 = sdh.source_system_book_id3
		AND b.source_system_book_id4 = sdh.source_system_book_id4
	LEFT JOIN source_uom su ON su.source_uom_id = dd.deal_volume_uom_id
	LEFT JOIN source_counterparty sc ON sc.source_counterparty_id = sdh.counterparty_id
	LEFT JOIN contract_group cg ON cg.contract_id = dd.contract_id
	GROUP BY dd.term_start, dd.term_end, dd.source_deal_header_id, dd.phy_deal_id, dd.path_detail_id
	ORDER BY dd.phy_deal_id, dd.term_start, dd.path_detail_id
	
	' AS [tsql], @report_id_data_source_dest AS report_id
	END 
	

	IF OBJECT_ID('tempdb..#data_source_column', 'U') IS NOT NULL
		DROP TABLE #data_source_column	
	CREATE TABLE #data_source_column(column_id INT)	

	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Scheduled Deal Detail View'
	            AND dsc.name =  'book_id'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Book ID'
			   , reqd_param = 1, widget_id = 5, datatype_id = 4, param_data_source = NULL, param_default_value = NULL, append_filter = 0, tooltip = NULL, column_template = 2, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Scheduled Deal Detail View'
			AND dsc.name =  'book_id'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'book_id' AS [name], 'Book ID' AS ALIAS, 1 AS reqd_param, 5 AS widget_id, 4 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 0 AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Scheduled Deal Detail View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	

	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Scheduled Deal Detail View'
	            AND dsc.name =  'delivery_location'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Delivery Location'
			   , reqd_param = 0, widget_id = 7, datatype_id = 5, param_data_source = '10102500', param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Scheduled Deal Detail View'
			AND dsc.name =  'delivery_location'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'delivery_location' AS [name], 'Delivery Location' AS ALIAS, 0 AS reqd_param, 7 AS widget_id, 5 AS datatype_id, '10102500' AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Scheduled Deal Detail View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	

	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Scheduled Deal Detail View'
	            AND dsc.name =  'delivery_volume'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Delivery Volume'
			   , reqd_param = 0, widget_id = 1, datatype_id = 3, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 2, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Scheduled Deal Detail View'
			AND dsc.name =  'delivery_volume'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'delivery_volume' AS [name], 'Delivery Volume' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 3 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Scheduled Deal Detail View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	

	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Scheduled Deal Detail View'
	            AND dsc.name =  'flow_date_from'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Flow Date From'
			   , reqd_param = 1, widget_id = 6, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 0, tooltip = NULL, column_template = 0, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Scheduled Deal Detail View'
			AND dsc.name =  'flow_date_from'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'flow_date_from' AS [name], 'Flow Date From' AS ALIAS, 1 AS reqd_param, 6 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 0 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Scheduled Deal Detail View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	

	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Scheduled Deal Detail View'
	            AND dsc.name =  'flow_date_to'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Flow Date To'
			   , reqd_param = 1, widget_id = 6, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 0, tooltip = NULL, column_template = 0, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Scheduled Deal Detail View'
			AND dsc.name =  'flow_date_to'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'flow_date_to' AS [name], 'Flow Date To' AS ALIAS, 1 AS reqd_param, 6 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 0 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Scheduled Deal Detail View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	

	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Scheduled Deal Detail View'
	            AND dsc.name =  'path'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Path'
			   , reqd_param = 0, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Scheduled Deal Detail View'
			AND dsc.name =  'path'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'path' AS [name], 'Path' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Scheduled Deal Detail View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	

	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Scheduled Deal Detail View'
	            AND dsc.name =  'receipt_location'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Receipt Location'
			   , reqd_param = 0, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Scheduled Deal Detail View'
			AND dsc.name =  'receipt_location'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'receipt_location' AS [name], 'Receipt Location' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Scheduled Deal Detail View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	

	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Scheduled Deal Detail View'
	            AND dsc.name =  'receipt_volume'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Receipt Volume'
			   , reqd_param = 0, widget_id = 1, datatype_id = 3, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 2, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Scheduled Deal Detail View'
			AND dsc.name =  'receipt_volume'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'receipt_volume' AS [name], 'Receipt Volume' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 3 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Scheduled Deal Detail View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	

	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Scheduled Deal Detail View'
	            AND dsc.name =  'stra_id'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Strategy ID'
			   , reqd_param = 1, widget_id = 4, datatype_id = 4, param_data_source = NULL, param_default_value = NULL, append_filter = 0, tooltip = NULL, column_template = 2, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Scheduled Deal Detail View'
			AND dsc.name =  'stra_id'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'stra_id' AS [name], 'Strategy ID' AS ALIAS, 1 AS reqd_param, 4 AS widget_id, 4 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 0 AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Scheduled Deal Detail View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	

	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Scheduled Deal Detail View'
	            AND dsc.name =  'sub_id'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Subsidiary ID'
			   , reqd_param = 1, widget_id = 3, datatype_id = 4, param_data_source = NULL, param_default_value = NULL, append_filter = 0, tooltip = NULL, column_template = 2, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Scheduled Deal Detail View'
			AND dsc.name =  'sub_id'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'sub_id' AS [name], 'Subsidiary ID' AS ALIAS, 1 AS reqd_param, 3 AS widget_id, 4 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 0 AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Scheduled Deal Detail View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	

	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Scheduled Deal Detail View'
	            AND dsc.name =  'uom'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'UOM'
			   , reqd_param = 0, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Scheduled Deal Detail View'
			AND dsc.name =  'uom'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'uom' AS [name], 'UOM' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Scheduled Deal Detail View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	

	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Scheduled Deal Detail View'
	            AND dsc.name =  'from_source_deal_header_id'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Deal ID'
			   , reqd_param = 0, widget_id = 1, datatype_id = 4, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Scheduled Deal Detail View'
			AND dsc.name =  'from_source_deal_header_id'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'from_source_deal_header_id' AS [name], 'Deal ID' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 4 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Scheduled Deal Detail View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	

	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Scheduled Deal Detail View'
	            AND dsc.name =  'source_deal_header_id'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Scheduled ID'
			   , reqd_param = 0, widget_id = 1, datatype_id = 4, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Scheduled Deal Detail View'
			AND dsc.name =  'source_deal_header_id'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'source_deal_header_id' AS [name], 'Scheduled ID' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 4 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Scheduled Deal Detail View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	

	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Scheduled Deal Detail View'
	            AND dsc.name =  'sub_book_id'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Sub Book ID'
			   , reqd_param = 1, widget_id = 8, datatype_id = 4, param_data_source = NULL, param_default_value = NULL, append_filter = 0, tooltip = NULL, column_template = 2, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Scheduled Deal Detail View'
			AND dsc.name =  'sub_book_id'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'sub_book_id' AS [name], 'Sub Book ID' AS ALIAS, 1 AS reqd_param, 8 AS widget_id, 4 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 0 AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Scheduled Deal Detail View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	

	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Scheduled Deal Detail View'
	            AND dsc.name =  'contract'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Contract'
			   , reqd_param = 0, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Scheduled Deal Detail View'
			AND dsc.name =  'contract'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'contract' AS [name], 'Contract' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Scheduled Deal Detail View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	

	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Scheduled Deal Detail View'
	            AND dsc.name =  'contract_id'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Contract ID'
			   , reqd_param = 0, widget_id = 7, datatype_id = 4, param_data_source = '10211299', param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 2, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Scheduled Deal Detail View'
			AND dsc.name =  'contract_id'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'contract_id' AS [name], 'Contract ID' AS ALIAS, 0 AS reqd_param, 7 AS widget_id, 4 AS datatype_id, '10211299' AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Scheduled Deal Detail View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	

	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Scheduled Deal Detail View'
	            AND dsc.name =  'counterparty'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Counterparty'
			   , reqd_param = 0, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Scheduled Deal Detail View'
			AND dsc.name =  'counterparty'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'counterparty' AS [name], 'Counterparty' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Scheduled Deal Detail View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	

	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Scheduled Deal Detail View'
	            AND dsc.name =  'counterparty_id'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Counterparty ID'
			   , reqd_param = 0, widget_id = 7, datatype_id = 4, param_data_source = '10191000', param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 2, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Scheduled Deal Detail View'
			AND dsc.name =  'counterparty_id'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'counterparty_id' AS [name], 'Counterparty ID' AS ALIAS, 0 AS reqd_param, 7 AS widget_id, 4 AS datatype_id, '10191000' AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Scheduled Deal Detail View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	

	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Scheduled Deal Detail View'
	            AND dsc.name =  'from_location'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'from_location'
			   , reqd_param = 0, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 2, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Scheduled Deal Detail View'
			AND dsc.name =  'from_location'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'from_location' AS [name], 'from_location' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Scheduled Deal Detail View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	

	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Scheduled Deal Detail View'
	            AND dsc.name =  'group_path'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'group_path'
			   , reqd_param = 0, widget_id = 1, datatype_id = 1, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Scheduled Deal Detail View'
			AND dsc.name =  'group_path'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'group_path' AS [name], 'group_path' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 1 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Scheduled Deal Detail View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	

	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Scheduled Deal Detail View'
	            AND dsc.name =  'to_location'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'to_location'
			   , reqd_param = 0, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 2, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Scheduled Deal Detail View'
			AND dsc.name =  'to_location'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'to_location' AS [name], 'to_location' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Scheduled Deal Detail View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	

	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Scheduled Deal Detail View'
	            AND dsc.name =  'template_name'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'template_name'
			   , reqd_param = 0, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Scheduled Deal Detail View'
			AND dsc.name =  'template_name'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'template_name' AS [name], 'template_name' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Scheduled Deal Detail View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	

	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Scheduled Deal Detail View'
	            AND dsc.name =  'delivery_location_id'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'delivery_location_id'
			   , reqd_param = 0, widget_id = 1, datatype_id = 4, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 2, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Scheduled Deal Detail View'
			AND dsc.name =  'delivery_location_id'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'delivery_location_id' AS [name], 'delivery_location_id' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 4 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Scheduled Deal Detail View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	

	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Scheduled Deal Detail View'
	            AND dsc.name =  'to_deal'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'To Deal'
			   , reqd_param = 0, widget_id = 1, datatype_id = 4, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 2, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Scheduled Deal Detail View'
			AND dsc.name =  'to_deal'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'to_deal' AS [name], 'To Deal' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 4 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Scheduled Deal Detail View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	

	DELETE dsc
	FROM data_source_column dsc 
	INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		AND ds.[name] = 'Scheduled Deal Detail View'
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
	