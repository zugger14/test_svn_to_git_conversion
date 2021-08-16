BEGIN TRY
		BEGIN TRAN

		DECLARE @report_id_dest INT 
	

		--RETAIN APPLICATION FILTER DETAILS START (PART1)
		DROP TABLE IF EXISTS #paramset_map
		CREATE TABLE #paramset_map (
			deleted_paramset_id INT NULL, 
			paramset_hash VARCHAR(36) COLLATE DATABASE_DEFAULT NULL, 
			inserted_paramset_id INT NULL

		)

		--store mapping information for filter detail column ids and data source column id for sql datasource
		DROP TABLE IF EXISTS #sql_source_filter_detail_column_mapping
		CREATE TABLE #sql_source_filter_detail_column_mapping (
			paramset_hash VARCHAR(36),
			column_id INT,
			column_name VARCHAR(1000),
			application_ui_filter_details_id INT NULL
		)

		IF EXISTS (SELECT 1 FROM dbo.report WHERE report_hash='24E8DBB4_9596_427E_B92E_69D29F906BF1')
		BEGIN
			DECLARE @report_id_to_delete INT
			SELECT @report_id_to_delete = report_id FROM report WHERE report_hash = '24E8DBB4_9596_427E_B92E_69D29F906BF1'

			INSERT INTO #paramset_map(deleted_paramset_id, paramset_hash)
			SELECT rp.report_paramset_id, rp.paramset_hash
			FROM report_paramset rp
			INNER JOIN report_page pg ON pg.report_page_id = rp.page_id
			WHERE pg.report_id = @report_id_to_delete

			INSERT INTO #sql_source_filter_detail_column_mapping(paramset_hash, column_id, column_name, application_ui_filter_details_id)
			SELECT DISTINCT rpm.paramset_hash, aufd.report_column_id, dsc.name, aufd.application_ui_filter_details_id
			FROM application_ui_filter_details aufd
			INNER JOIN application_ui_filter auf
				ON auf.application_ui_filter_id = aufd.application_ui_filter_id
			INNER JOIN report_paramset rpm
				ON rpm.report_paramset_id = auf.report_id
			INNER JOIN report_page pg ON pg.report_page_id = rpm.page_id
			INNER JOIN data_source_column dsc
				ON dsc.data_source_column_id = aufd.report_column_id
			INNER JOIN data_source ds
				ON ds.data_source_id = source_id
			WHERE pg.report_id = @report_id_to_delete
				AND ds.type_id = 2

			EXEC spa_rfx_report @flag='d', @report_id=@report_id_to_delete, @retain_privilege=1, @process_id=NULL

		
		END
		--RETAIN APPLICATION FILTER DETAILS END (PART1)
		

		declare @report_copy_name varchar(200)
		
		set @report_copy_name = isnull(@report_copy_name, 'Copy of ' + 'EOD- Physical Future Fulfillment')
		

		INSERT INTO report ([name], [owner], is_system, is_excel, is_mobile, report_hash, [description], category_id)
		SELECT TOP 1 'EOD- Physical Future Fulfillment' [name], 'dev_admin' [owner], 0 is_system, 0 is_excel, 0 is_mobile, '24E8DBB4_9596_427E_B92E_69D29F906BF1' report_hash, '' [description], CAST(sdv_cat.value_id AS VARCHAR(10)) category_id
		FROM sys.objects o
		LEFT JOIN static_data_value sdv_cat ON sdv_cat.code = 'Processes' AND sdv_cat.type_id = 10008 
		SET @report_id_dest = SCOPE_IDENTITY()
		
		
BEGIN TRY
		BEGIN TRAN
	

	declare @new_ds_alias varchar(10) = 'EODPFF'
	/** IF DATA SOURCE ALIAS ALREADY EXISTS ON DESTINATION, RAISE ERROR **/
	if exists(select top 1 1 from data_source where alias = 'EODPFF' and name <> 'EOD- Physical Future Fulfillment Sql')
	begin
		select top 1 @new_ds_alias = 'EODPFF' + cast(s.n as varchar(5))
		from seq s
		left join data_source ds on ds.alias = 'EODPFF' + cast(s.n as varchar(5))
		where ds.data_source_id is null
			and s.n < 10

		--RAISERROR ('Datasource alias already exists on system.', 16, 1);
	end

	DECLARE @report_id_data_source_dest INT 
	
	SELECT @report_id_data_source_dest = report_id
	FROM report r
	WHERE r.[name] = 'EOD- Physical Future Fulfillment'

	IF NOT EXISTS (SELECT 1 
	           FROM data_source 
	           WHERE [name] = 'EOD- Physical Future Fulfillment Sql'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	AND NOT EXISTS (SELECT 1 FROM map_function_category WHERE [function_name] = 'EOD- Physical Future Fulfillment Sql' AND '106500' = '106501') 
	BEGIN
		INSERT INTO data_source([type_id], [name], [alias], [description], [tsql], report_id, system_defined,category)
		SELECT TOP 1 2 AS [type_id], 'EOD- Physical Future Fulfillment Sql' AS [name], @new_ds_alias AS ALIAS, NULL AS [description],null AS [tsql], @report_id_data_source_dest AS report_id,NULL AS [system_defined]
			,'106500' AS [category]
	END

	UPDATE data_source
	SET alias = @new_ds_alias, description = NULL
	, [tsql] = CAST('' AS VARCHAR(MAX)) + 'DECLARE @_sql NVARCHAR(MAX) = ''''
 , @_deal_count INT
 , @_counterparty_id NVARCHAR(MAX)

 , @_deal_type NVARCHAR(MAX)

 , @_physical_financial_flag NVARCHAR(2)

 , @_commodity_id NVARCHAR(MAX)

 , @_as_of_date DATE = ''@as_of_date''
 --, @_as_of_date DATE = ''2019-12-30''

 , @_process_id NVARCHAR(50) = ''@process_id''
 
IF ''@counterparty_id'' <> ''NULL''
 SET @_counterparty_id = ''@counterparty_id''

IF ''@deal_type'' <> ''NULL''
 SET @_deal_type = ''@deal_type''

IF ''@physical_financial_flag'' <> ''NULL''
 SET @_physical_financial_flag = ''@physical_financial_flag''

IF ''@commodity_id'' <> ''NULL''
 SET @_commodity_id = ''@commodity_id''

--SELECT source_counterparty_id , counterparty_id + '' - '' + counterparty_name AS counterparty_id FROM source_counterparty WHERE counterparty_id IN (''EEX'',''ICE'')
--SELECT @_counterparty_id = ''7734,7729''
--SELECT source_commodity_id from source_commodity where commodity_id in (''Gas'')
--SELECT @_commodity_id = ''-1''
--SELECT  source_deal_type_id from source_deal_type where deal_type_id in (''future'')
--SELECT @_deal_type = ''1172''
--SELECT @_physical_financial_flag = ''p''
--select * from static_data_value where value_id = 980

SET @_counterparty_id = REPLACE(@_counterparty_id,''!'','','')
SET @_commodity_id = REPLACE(@_commodity_id,''!'','','')

IF OBJECT_ID(''tempdb..#tmp_deals'') IS NOT NULL 
	DROP TABLE #tmp_deals 

CREATE TABLE #tmp_deals (
	[source_deal_header_id]		INT,
	[source_deal_detail_id]		INT,
	[term_start]				DATE,
	[term_end]					DATE,
	[curve_value]				FLOAT,
	[fixed_price]				FLOAT,
)

-- Calculation for price_adder : Difference between market price (curve value) and deal price (fixed price)
SET @_sql = ''
INSERT INTO #tmp_deals(
	[source_deal_header_id],	
	[source_deal_detail_id],	
	[term_start],			
	[term_end],				
	[curve_value],			
	[fixed_price]			
)
SELECT 
	sdh.source_deal_header_id
	,sdd.source_deal_detail_id
	,sdd.term_start
	,sdd.term_end
	,spc.curve_value
	,sdd.fixed_price
FROM source_deal_header sdh 
INNER JOIN source_deal_detail sdd ON sdd.source_deal_header_id = sdh.source_deal_header_id
INNER JOIN source_price_curve_def spcd ON spcd.source_curve_def_id = sdd.curve_id
OUTER APPLY(
	SELECT TOP 1
		h1.exp_date
	FROM holiday_group h1 WHERE 
	h1.hol_group_value_id = spcd.exp_calendar_id
	AND h1.hol_date = sdd.term_start AND h1.hol_date_to = sdd.term_end
		AND h1.exp_date = '''''' + CONVERT(NVARCHAR(20),@_as_of_date,120) + '''''' 
) holiday_group
OUTER APPLY (
	SELECT TOP 1
		s1.curve_value
	FROM source_price_curve s1 
	WHERE s1.source_curve_def_id = sdd.curve_id
	AND s1.as_of_date = holiday_group.exp_date
	AND s1.maturity_date = sdd.term_start
) spc
WHERE 1 = 1 
AND spcd.granularity = 980
AND holiday_group.exp_date IS NOT NULL
AND spc.curve_value IS NOT NULL
AND spcd.curve_id NOT IN (''''GAS.GPH.EEX.S.Fut'''',''''GAS.TTF.EEX.S.Fut'''',''''GAS.NCH.EEX.S.Fut'''')
''
IF NULLIF(@_counterparty_id,'''') IS NOT NULL
	SET @_sql += '' AND sdh.counterparty_id IN ('' + @_counterparty_id + '')''
IF NULLIF(@_deal_type,'''') IS NOT NULL
	SET @_sql += '' AND sdh.source_deal_type_id IN ('' + @_deal_type + '')''
IF NULLIF(@_physical_financial_flag,'''') IS NOT NULL
	SET @_sql += '' AND sdh.physical_financial_flag = '''''' + @_physical_financial_flag + ''''''''
IF NULLIF(@_counterparty_id,'''') IS NOT NULL
	SET @_sql += '' AND spcd.commodity_id IN ('' + @_commodity_id + '')''


SET @_sql += ''
	UPDATE sdd SET sdd.price_adder = t1.curve_value - t1.fixed_price
	FROM #tmp_deals t1
	INNER JOIN source_deal_detail sdd ON sdd.source_deal_detail_id = t1.source_deal_detail_id
		AND sdd.term_start = t1.term_start
		AND sdd.term_end = t1.term_end
''
EXEC(@_sql)

SELECT @_deal_count = COUNT(source_deal_header_id) FROM #tmp_deals

IF OBJECT_ID(''tempdb..#tmp_result'') IS NOT NULL 
	DROP TABLE #tmp_result 

CREATE TABLE #tmp_result (
	[errorcode]			NVARCHAR(200) COLLATE DATABASE_DEFAULT ,
	[module]			NVARCHAR(200) COLLATE DATABASE_DEFAULT ,
	[area]				NVARCHAR(200) COLLATE DATABASE_DEFAULT ,
	[status]			NVARCHAR(200) COLLATE DATABASE_DEFAULT ,
	[message]			NVARCHAR(1000) COLLATE DATABASE_DEFAULT ,
	[recommendation]	NVARCHAR(200) COLLATE DATABASE_DEFAULT 
)

INSERT INTO #tmp_result (errorcode, module, area, [status], [message], recommendation) 
SELECT ''Success'' ErrorCode, ''Deal'' Module, ''physical future fulfillment'' Area, ''Success'' [Status]
				, ''Physical Future Fulfillment successfully completed for As of Date '' + CONVERT(NVARCHAR(20),@_as_of_date,120) + '' for '' + CAST(ISNULL(@_deal_count,0) AS NVARCHAR(10)) + '' Deal(s).'' [Message], '''' Recommendation
				
SELECT @_as_of_date as_of_date,
     @_counterparty_id counterparty_id,    
     @_deal_type deal_type,    
     @_physical_financial_flag physical_financial_flag,    
     @_commodity_id commodity_id,
     @_process_id process_id,
     [ErrorCode],
	[Module],
	[Area],
	[Status],
	[Message],
	[Recommendation]

--[__batch_report__]

FROM #tmp_result', report_id = @report_id_data_source_dest,
	system_defined = NULL
	,category = '106500' 
	WHERE [name] = 'EOD- Physical Future Fulfillment Sql'
		AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1)
		
	

	IF OBJECT_ID('tempdb..#data_source_column', 'U') IS NOT NULL
		DROP TABLE #data_source_column	
	CREATE TABLE #data_source_column(column_id INT)	

	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'EOD- Physical Future Fulfillment Sql'
	            AND dsc.name =  'Area'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Area'
			   , reqd_param = NULL, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 0, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'EOD- Physical Future Fulfillment Sql'
			AND dsc.name =  'Area'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'Area' AS [name], 'Area' AS ALIAS, NULL AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'EOD- Physical Future Fulfillment Sql'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	

	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'EOD- Physical Future Fulfillment Sql'
	            AND dsc.name =  'as_of_date'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'As of Date'
			   , reqd_param = NULL, widget_id = 6, datatype_id = 2, param_data_source = NULL, param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 4, key_column = 0, required_filter = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'EOD- Physical Future Fulfillment Sql'
			AND dsc.name =  'as_of_date'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'as_of_date' AS [name], 'As of Date' AS ALIAS, NULL AS reqd_param, 6 AS widget_id, 2 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,4 AS column_template, 0 AS key_column, 0 AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'EOD- Physical Future Fulfillment Sql'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	

	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'EOD- Physical Future Fulfillment Sql'
	            AND dsc.name =  'commodity_id'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Commodity'
			   , reqd_param = NULL, widget_id = 9, datatype_id = 5, param_data_source = 'SELECT source_commodity_id, commodity_id FROM source_commodity ORDER BY commodity_id', param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 0, key_column = 0, required_filter = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'EOD- Physical Future Fulfillment Sql'
			AND dsc.name =  'commodity_id'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'commodity_id' AS [name], 'Commodity' AS ALIAS, NULL AS reqd_param, 9 AS widget_id, 5 AS datatype_id, 'SELECT source_commodity_id, commodity_id FROM source_commodity ORDER BY commodity_id' AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, 0 AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'EOD- Physical Future Fulfillment Sql'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	

	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'EOD- Physical Future Fulfillment Sql'
	            AND dsc.name =  'counterparty_id'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Counterparty'
			   , reqd_param = NULL, widget_id = 9, datatype_id = 5, param_data_source = 'SELECT source_counterparty_id , counterparty_id ' + CHAR(10) + ' FROM source_counterparty WHERE counterparty_id IN (''EEX'',''ICE'')', param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 0, key_column = 0, required_filter = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'EOD- Physical Future Fulfillment Sql'
			AND dsc.name =  'counterparty_id'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'counterparty_id' AS [name], 'Counterparty' AS ALIAS, NULL AS reqd_param, 9 AS widget_id, 5 AS datatype_id, 'SELECT source_counterparty_id , counterparty_id ' + CHAR(10) + ' FROM source_counterparty WHERE counterparty_id IN (''EEX'',''ICE'')' AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, 0 AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'EOD- Physical Future Fulfillment Sql'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	

	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'EOD- Physical Future Fulfillment Sql'
	            AND dsc.name =  'deal_type'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Deal Type'
			   , reqd_param = NULL, widget_id = 9, datatype_id = 5, param_data_source = 'SELECT source_deal_type_id, deal_type_id FROM source_deal_type ORDER BY deal_type_id', param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 0, key_column = 0, required_filter = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'EOD- Physical Future Fulfillment Sql'
			AND dsc.name =  'deal_type'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'deal_type' AS [name], 'Deal Type' AS ALIAS, NULL AS reqd_param, 9 AS widget_id, 5 AS datatype_id, 'SELECT source_deal_type_id, deal_type_id FROM source_deal_type ORDER BY deal_type_id' AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, 0 AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'EOD- Physical Future Fulfillment Sql'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	

	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'EOD- Physical Future Fulfillment Sql'
	            AND dsc.name =  'ErrorCode'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Errorcode'
			   , reqd_param = NULL, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 0, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'EOD- Physical Future Fulfillment Sql'
			AND dsc.name =  'ErrorCode'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'ErrorCode' AS [name], 'Errorcode' AS ALIAS, NULL AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'EOD- Physical Future Fulfillment Sql'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	

	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'EOD- Physical Future Fulfillment Sql'
	            AND dsc.name =  'Message'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Message'
			   , reqd_param = NULL, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 0, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'EOD- Physical Future Fulfillment Sql'
			AND dsc.name =  'Message'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'Message' AS [name], 'Message' AS ALIAS, NULL AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'EOD- Physical Future Fulfillment Sql'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	

	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'EOD- Physical Future Fulfillment Sql'
	            AND dsc.name =  'Module'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Module'
			   , reqd_param = NULL, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 0, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'EOD- Physical Future Fulfillment Sql'
			AND dsc.name =  'Module'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'Module' AS [name], 'Module' AS ALIAS, NULL AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'EOD- Physical Future Fulfillment Sql'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	

	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'EOD- Physical Future Fulfillment Sql'
	            AND dsc.name =  'physical_financial_flag'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Physical Financial'
			   , reqd_param = NULL, widget_id = 2, datatype_id = 5, param_data_source = 'SELECT ''p'' val, ''Physical'' lab UNION ALL SELECT ''f'' val, ''Financial'' lab', param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 0, key_column = 0, required_filter = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'EOD- Physical Future Fulfillment Sql'
			AND dsc.name =  'physical_financial_flag'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'physical_financial_flag' AS [name], 'Physical Financial' AS ALIAS, NULL AS reqd_param, 2 AS widget_id, 5 AS datatype_id, 'SELECT ''p'' val, ''Physical'' lab UNION ALL SELECT ''f'' val, ''Financial'' lab' AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, 0 AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'EOD- Physical Future Fulfillment Sql'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	

	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'EOD- Physical Future Fulfillment Sql'
	            AND dsc.name =  'process_id'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Process Id'
			   , reqd_param = NULL, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 0, key_column = 0, required_filter = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'EOD- Physical Future Fulfillment Sql'
			AND dsc.name =  'process_id'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'process_id' AS [name], 'Process Id' AS ALIAS, NULL AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, 0 AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'EOD- Physical Future Fulfillment Sql'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	

	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'EOD- Physical Future Fulfillment Sql'
	            AND dsc.name =  'Recommendation'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Recommendation'
			   , reqd_param = NULL, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 0, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'EOD- Physical Future Fulfillment Sql'
			AND dsc.name =  'Recommendation'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'Recommendation' AS [name], 'Recommendation' AS ALIAS, NULL AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'EOD- Physical Future Fulfillment Sql'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	

	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'EOD- Physical Future Fulfillment Sql'
	            AND dsc.name =  'Status'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Status'
			   , reqd_param = NULL, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 0, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'EOD- Physical Future Fulfillment Sql'
			AND dsc.name =  'Status'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'Status' AS [name], 'Status' AS ALIAS, NULL AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'EOD- Physical Future Fulfillment Sql'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	

	DELETE dsc
	FROM data_source_column dsc 
	INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		AND ds.[name] = 'EOD- Physical Future Fulfillment Sql'
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
	

		INSERT INTO report_dataset (source_id, report_id, [alias], root_dataset_id, is_free_from, relationship_sql)
		SELECT TOP 1 ds.data_source_id AS source_id, @report_id_dest AS report_id, 'EODPFF' [alias], rd_root.report_dataset_id AS root_dataset_id,0 AS is_free_from, 'NULL' AS relationship_sql
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'EOD- Physical Future Fulfillment Sql'
			AND ISNULL(ds.report_id, @report_id_dest) = @report_id_dest
		LEFT JOIN report_dataset rd_root ON rd_root.[alias] = NULL
			AND rd_root.report_id = @report_id_dest		
		

	INSERT INTO report_page(report_id, [name], report_hash, width, height)
	SELECT @report_id_dest AS report_id, 'EOD- Physical Future Fulfillment' [name], '24E8DBB4_9596_427E_B92E_69D29F906BF1' report_hash, 11.5 width,5.5 height
	

		INSERT INTO report_paramset(page_id, [name], paramset_hash, report_status_id, export_report_name, export_location, output_file_format, delimiter, xml_format, report_header, compress_file, category_id)
		SELECT TOP 1 rpage.report_page_id, 'EOD- Physical Future Fulfillment', '6317D410_E4F6_4F24_BBCD_EA13FB96F9FF', 1,'','','.xlsx',',', 
		-100000,'n','n',0	
		FROM sys.objects o
		INNER JOIN report_page rpage 
			on rpage.[name] = 'EOD- Physical Future Fulfillment'
		INNER JOIN report r 
		ON r.report_id = rpage.report_id
			AND r.[name] = 'EOD- Physical Future Fulfillment'
	

		INSERT INTO report_dataset_paramset(paramset_id, root_dataset_id, where_part, advance_mode)
		SELECT TOP 1 rp.report_paramset_id AS paramset_id, rd.report_dataset_id AS root_dataset_id, NULL AS where_part, 0
		FROM sys.objects o
		INNER JOIN report_paramset rp 
			ON rp.[name] = 'EOD- Physical Future Fulfillment'
		INNER JOIN report_page rpage 
			ON rpage.report_page_id = rp.page_id
			AND rpage.[name] = 'EOD- Physical Future Fulfillment'
		INNER JOIN report r 
			ON r.report_id = rpage.report_id
			AND r.[name] = 'EOD- Physical Future Fulfillment'
		INNER JOIN report_dataset rd 
			ON rd.report_id = @report_id_dest
			AND rd.[alias] = 'EODPFF'
	

		INSERT INTO report_param(dataset_paramset_id, dataset_id, column_id, operator,
					initial_value, initial_value2, optional, hidden, logical_operator, param_order, param_depth, label)
		SELECT TOP 1 rdp.report_dataset_paramset_id AS dataset_paramset_id, rd.report_dataset_id AS dataset_id , dsc.data_source_column_id AS column_id, 1 AS operator, '' AS initial_value, '' AS initial_value2, 0 AS optional, 0 AS hidden,1 AS logical_operator, 0 AS param_order, 0 AS param_depth, NULL AS label
		FROM sys.objects o
		INNER JOIN report_paramset rp 
			ON rp.[name] = 'EOD- Physical Future Fulfillment'
		INNER JOIN report_page rpage 
			ON rpage.report_page_id = rp.page_id
			AND rpage.[name] = 'EOD- Physical Future Fulfillment'
		INNER JOIN report r ON r.report_id = rpage.report_id
			AND r.[name] = 'EOD- Physical Future Fulfillment'
		INNER JOIN report_dataset rd_root 
			ON rd_root.report_id = @report_id_dest 
			AND rd_root.[alias] = 'EODPFF'
		INNER JOIN report_dataset_paramset rdp 
			ON rdp.paramset_id = rp.report_paramset_id
			AND rdp.root_dataset_id = rd_root.report_dataset_id
		INNER JOIN report_dataset rd 
			ON rd.report_id = r.report_id
			AND rd.[alias] = 'EODPFF'
		INNER JOIN data_source ds 
			ON ISNULL(NULLIF(ds.report_id, 0), r.report_id) = r.report_id	
			AND ds.[name] = 'EOD- Physical Future Fulfillment Sql' 
		INNER JOIN data_source_column dsc 
			ON dsc.source_id = ds.data_source_id
			AND dsc.[name] = 'as_of_date'	
	

		INSERT INTO report_param(dataset_paramset_id, dataset_id, column_id, operator,
					initial_value, initial_value2, optional, hidden, logical_operator, param_order, param_depth, label)
		SELECT TOP 1 rdp.report_dataset_paramset_id AS dataset_paramset_id, rd.report_dataset_id AS dataset_id , dsc.data_source_column_id AS column_id, 1 AS operator, '' AS initial_value, '' AS initial_value2, 1 AS optional, 0 AS hidden,1 AS logical_operator, 5 AS param_order, 0 AS param_depth, NULL AS label
		FROM sys.objects o
		INNER JOIN report_paramset rp 
			ON rp.[name] = 'EOD- Physical Future Fulfillment'
		INNER JOIN report_page rpage 
			ON rpage.report_page_id = rp.page_id
			AND rpage.[name] = 'EOD- Physical Future Fulfillment'
		INNER JOIN report r ON r.report_id = rpage.report_id
			AND r.[name] = 'EOD- Physical Future Fulfillment'
		INNER JOIN report_dataset rd_root 
			ON rd_root.report_id = @report_id_dest 
			AND rd_root.[alias] = 'EODPFF'
		INNER JOIN report_dataset_paramset rdp 
			ON rdp.paramset_id = rp.report_paramset_id
			AND rdp.root_dataset_id = rd_root.report_dataset_id
		INNER JOIN report_dataset rd 
			ON rd.report_id = r.report_id
			AND rd.[alias] = 'EODPFF'
		INNER JOIN data_source ds 
			ON ISNULL(NULLIF(ds.report_id, 0), r.report_id) = r.report_id	
			AND ds.[name] = 'EOD- Physical Future Fulfillment Sql' 
		INNER JOIN data_source_column dsc 
			ON dsc.source_id = ds.data_source_id
			AND dsc.[name] = 'process_id'	
	

		INSERT INTO report_param(dataset_paramset_id, dataset_id, column_id, operator,
					initial_value, initial_value2, optional, hidden, logical_operator, param_order, param_depth, label)
		SELECT TOP 1 rdp.report_dataset_paramset_id AS dataset_paramset_id, rd.report_dataset_id AS dataset_id , dsc.data_source_column_id AS column_id, 9 AS operator, '-1' AS initial_value, '' AS initial_value2, 0 AS optional, 1 AS hidden,1 AS logical_operator, 4 AS param_order, 0 AS param_depth, NULL AS label
		FROM sys.objects o
		INNER JOIN report_paramset rp 
			ON rp.[name] = 'EOD- Physical Future Fulfillment'
		INNER JOIN report_page rpage 
			ON rpage.report_page_id = rp.page_id
			AND rpage.[name] = 'EOD- Physical Future Fulfillment'
		INNER JOIN report r ON r.report_id = rpage.report_id
			AND r.[name] = 'EOD- Physical Future Fulfillment'
		INNER JOIN report_dataset rd_root 
			ON rd_root.report_id = @report_id_dest 
			AND rd_root.[alias] = 'EODPFF'
		INNER JOIN report_dataset_paramset rdp 
			ON rdp.paramset_id = rp.report_paramset_id
			AND rdp.root_dataset_id = rd_root.report_dataset_id
		INNER JOIN report_dataset rd 
			ON rd.report_id = r.report_id
			AND rd.[alias] = 'EODPFF'
		INNER JOIN data_source ds 
			ON ISNULL(NULLIF(ds.report_id, 0), r.report_id) = r.report_id	
			AND ds.[name] = 'EOD- Physical Future Fulfillment Sql' 
		INNER JOIN data_source_column dsc 
			ON dsc.source_id = ds.data_source_id
			AND dsc.[name] = 'commodity_id'	
	

		INSERT INTO report_param(dataset_paramset_id, dataset_id, column_id, operator,
					initial_value, initial_value2, optional, hidden, logical_operator, param_order, param_depth, label)
		SELECT TOP 1 rdp.report_dataset_paramset_id AS dataset_paramset_id, rd.report_dataset_id AS dataset_id , dsc.data_source_column_id AS column_id, 9 AS operator, '7734,7729' AS initial_value, '' AS initial_value2, 0 AS optional, 1 AS hidden,0 AS logical_operator, 1 AS param_order, 0 AS param_depth, NULL AS label
		FROM sys.objects o
		INNER JOIN report_paramset rp 
			ON rp.[name] = 'EOD- Physical Future Fulfillment'
		INNER JOIN report_page rpage 
			ON rpage.report_page_id = rp.page_id
			AND rpage.[name] = 'EOD- Physical Future Fulfillment'
		INNER JOIN report r ON r.report_id = rpage.report_id
			AND r.[name] = 'EOD- Physical Future Fulfillment'
		INNER JOIN report_dataset rd_root 
			ON rd_root.report_id = @report_id_dest 
			AND rd_root.[alias] = 'EODPFF'
		INNER JOIN report_dataset_paramset rdp 
			ON rdp.paramset_id = rp.report_paramset_id
			AND rdp.root_dataset_id = rd_root.report_dataset_id
		INNER JOIN report_dataset rd 
			ON rd.report_id = r.report_id
			AND rd.[alias] = 'EODPFF'
		INNER JOIN data_source ds 
			ON ISNULL(NULLIF(ds.report_id, 0), r.report_id) = r.report_id	
			AND ds.[name] = 'EOD- Physical Future Fulfillment Sql' 
		INNER JOIN data_source_column dsc 
			ON dsc.source_id = ds.data_source_id
			AND dsc.[name] = 'counterparty_id'	
	

		INSERT INTO report_param(dataset_paramset_id, dataset_id, column_id, operator,
					initial_value, initial_value2, optional, hidden, logical_operator, param_order, param_depth, label)
		SELECT TOP 1 rdp.report_dataset_paramset_id AS dataset_paramset_id, rd.report_dataset_id AS dataset_id , dsc.data_source_column_id AS column_id, 9 AS operator, '1172' AS initial_value, '' AS initial_value2, 0 AS optional, 1 AS hidden,1 AS logical_operator, 2 AS param_order, 0 AS param_depth, NULL AS label
		FROM sys.objects o
		INNER JOIN report_paramset rp 
			ON rp.[name] = 'EOD- Physical Future Fulfillment'
		INNER JOIN report_page rpage 
			ON rpage.report_page_id = rp.page_id
			AND rpage.[name] = 'EOD- Physical Future Fulfillment'
		INNER JOIN report r ON r.report_id = rpage.report_id
			AND r.[name] = 'EOD- Physical Future Fulfillment'
		INNER JOIN report_dataset rd_root 
			ON rd_root.report_id = @report_id_dest 
			AND rd_root.[alias] = 'EODPFF'
		INNER JOIN report_dataset_paramset rdp 
			ON rdp.paramset_id = rp.report_paramset_id
			AND rdp.root_dataset_id = rd_root.report_dataset_id
		INNER JOIN report_dataset rd 
			ON rd.report_id = r.report_id
			AND rd.[alias] = 'EODPFF'
		INNER JOIN data_source ds 
			ON ISNULL(NULLIF(ds.report_id, 0), r.report_id) = r.report_id	
			AND ds.[name] = 'EOD- Physical Future Fulfillment Sql' 
		INNER JOIN data_source_column dsc 
			ON dsc.source_id = ds.data_source_id
			AND dsc.[name] = 'deal_type'	
	

		INSERT INTO report_param(dataset_paramset_id, dataset_id, column_id, operator,
					initial_value, initial_value2, optional, hidden, logical_operator, param_order, param_depth, label)
		SELECT TOP 1 rdp.report_dataset_paramset_id AS dataset_paramset_id, rd.report_dataset_id AS dataset_id , dsc.data_source_column_id AS column_id, 9 AS operator, 'p' AS initial_value, '' AS initial_value2, 0 AS optional, 1 AS hidden,1 AS logical_operator, 3 AS param_order, 0 AS param_depth, NULL AS label
		FROM sys.objects o
		INNER JOIN report_paramset rp 
			ON rp.[name] = 'EOD- Physical Future Fulfillment'
		INNER JOIN report_page rpage 
			ON rpage.report_page_id = rp.page_id
			AND rpage.[name] = 'EOD- Physical Future Fulfillment'
		INNER JOIN report r ON r.report_id = rpage.report_id
			AND r.[name] = 'EOD- Physical Future Fulfillment'
		INNER JOIN report_dataset rd_root 
			ON rd_root.report_id = @report_id_dest 
			AND rd_root.[alias] = 'EODPFF'
		INNER JOIN report_dataset_paramset rdp 
			ON rdp.paramset_id = rp.report_paramset_id
			AND rdp.root_dataset_id = rd_root.report_dataset_id
		INNER JOIN report_dataset rd 
			ON rd.report_id = r.report_id
			AND rd.[alias] = 'EODPFF'
		INNER JOIN data_source ds 
			ON ISNULL(NULLIF(ds.report_id, 0), r.report_id) = r.report_id	
			AND ds.[name] = 'EOD- Physical Future Fulfillment Sql' 
		INNER JOIN data_source_column dsc 
			ON dsc.source_id = ds.data_source_id
			AND dsc.[name] = 'physical_financial_flag'	
	

		INSERT INTO report_page_tablix(page_id,root_dataset_id, [name], width, height, [top], [left], group_mode, border_style, page_break, type_id, cross_summary, no_header, export_table_name, is_global)
		SELECT TOP 1 rpage.report_page_id AS page_id, rd.report_dataset_id AS root_dataset_id, 'EOD_ Physical Future Fulfillment_tablix' [name], '4.533333333333333' width, '2.7733333333333334' height, '0' [top], '0' [left],2 AS group_mode,1 AS border_style,0 AS page_break,1 AS type_id,1 AS cross_summary,2 AS no_header,'' export_table_name, 0 AS is_global
		FROM sys.objects o
		INNER JOIN report_page rpage 
		ON rpage.[name] = 'EOD- Physical Future Fulfillment'
		INNER JOIN report r 
			ON r.report_id = rpage.report_id
			AND r.[name] = 'EOD- Physical Future Fulfillment'
		INNER JOIN report_dataset rd 
			ON rd.report_id = r.report_id 
			AND rd.[alias] = 'EODPFF' 
	

		INSERT INTO report_tablix_column(tablix_id, dataset_id, column_id, placement, column_order, aggregation
					, functions, [alias], sortable, rounding, thousand_seperation, font
					, font_size, font_style, text_align, text_color, background, default_sort_order
					, default_sort_direction, custom_field, render_as, column_template, negative_mark, currency, date_format, cross_summary_aggregation, mark_for_total, sql_aggregation, subtotal)
		SELECT TOP 1 rpt.report_page_tablix_id tablix_id, rd.report_dataset_id dataset_id, dsc.data_source_column_id column_id,1 placement, 0 column_order,NULL aggregation, NULL functions, 'Errorcode' [alias], 1 sortable, NULL rounding, NULL thousand_seperation, 'Tahoma' font, '8' font_size, '0,0,0' font_style, 'Left' text_align, '#000000' text_color, '#ffffff' background, NULL default_sort_order, NULL sort_direction, 0 custom_field, 0 render_as,-1 column_template,NULL negative_mark,NULL currency,NULL date_format,-1 cross_summary_aggregation,NULL mark_for_total,NULL sql_aggregation,NULL subtotal
			
		FROM sys.objects o
		INNER JOIN report_page_tablix rpt 
			ON rpt.[name] = 'EOD_ Physical Future Fulfillment_tablix'
		INNER JOIN report_page rpage 
			ON rpage.report_page_id = rpt.page_id 
			AND rpage.[name] = 'EOD- Physical Future Fulfillment'
		INNER JOIN report r 
			ON r.report_id = rpage.report_id
			AND r.[name] = 'EOD- Physical Future Fulfillment'
		INNER JOIN report_dataset rd 
			ON rd.report_id = r.report_id AND rd.[alias] = 'EODPFF' 	
		INNER JOIN data_source ds 
			ON ISNULL(NULLIF(ds.report_id, 0), r.report_id) = r.report_id	AND ds.[name] = 'EOD- Physical Future Fulfillment Sql' 	
		INNER JOIN data_source_column dsc 
			ON dsc.source_id = ds.data_source_id AND dsc.[name] = 'ErrorCode' 

		INSERT INTO report_tablix_column(tablix_id, dataset_id, column_id, placement, column_order, aggregation
					, functions, [alias], sortable, rounding, thousand_seperation, font
					, font_size, font_style, text_align, text_color, background, default_sort_order
					, default_sort_direction, custom_field, render_as, column_template, negative_mark, currency, date_format, cross_summary_aggregation, mark_for_total, sql_aggregation, subtotal)
		SELECT TOP 1 rpt.report_page_tablix_id tablix_id, rd.report_dataset_id dataset_id, dsc.data_source_column_id column_id,1 placement, 1 column_order,NULL aggregation, NULL functions, 'Module' [alias], 1 sortable, NULL rounding, NULL thousand_seperation, 'Tahoma' font, '8' font_size, '0,0,0' font_style, 'Left' text_align, '#000000' text_color, '#ffffff' background, NULL default_sort_order, NULL sort_direction, 0 custom_field, 0 render_as,-1 column_template,NULL negative_mark,NULL currency,NULL date_format,-1 cross_summary_aggregation,NULL mark_for_total,NULL sql_aggregation,NULL subtotal
			
		FROM sys.objects o
		INNER JOIN report_page_tablix rpt 
			ON rpt.[name] = 'EOD_ Physical Future Fulfillment_tablix'
		INNER JOIN report_page rpage 
			ON rpage.report_page_id = rpt.page_id 
			AND rpage.[name] = 'EOD- Physical Future Fulfillment'
		INNER JOIN report r 
			ON r.report_id = rpage.report_id
			AND r.[name] = 'EOD- Physical Future Fulfillment'
		INNER JOIN report_dataset rd 
			ON rd.report_id = r.report_id AND rd.[alias] = 'EODPFF' 	
		INNER JOIN data_source ds 
			ON ISNULL(NULLIF(ds.report_id, 0), r.report_id) = r.report_id	AND ds.[name] = 'EOD- Physical Future Fulfillment Sql' 	
		INNER JOIN data_source_column dsc 
			ON dsc.source_id = ds.data_source_id AND dsc.[name] = 'Module' 

		INSERT INTO report_tablix_column(tablix_id, dataset_id, column_id, placement, column_order, aggregation
					, functions, [alias], sortable, rounding, thousand_seperation, font
					, font_size, font_style, text_align, text_color, background, default_sort_order
					, default_sort_direction, custom_field, render_as, column_template, negative_mark, currency, date_format, cross_summary_aggregation, mark_for_total, sql_aggregation, subtotal)
		SELECT TOP 1 rpt.report_page_tablix_id tablix_id, rd.report_dataset_id dataset_id, dsc.data_source_column_id column_id,1 placement, 2 column_order,NULL aggregation, NULL functions, 'Area' [alias], 1 sortable, NULL rounding, NULL thousand_seperation, 'Tahoma' font, '8' font_size, '0,0,0' font_style, 'Left' text_align, '#000000' text_color, '#ffffff' background, NULL default_sort_order, NULL sort_direction, 0 custom_field, 0 render_as,-1 column_template,NULL negative_mark,NULL currency,NULL date_format,-1 cross_summary_aggregation,NULL mark_for_total,NULL sql_aggregation,NULL subtotal
			
		FROM sys.objects o
		INNER JOIN report_page_tablix rpt 
			ON rpt.[name] = 'EOD_ Physical Future Fulfillment_tablix'
		INNER JOIN report_page rpage 
			ON rpage.report_page_id = rpt.page_id 
			AND rpage.[name] = 'EOD- Physical Future Fulfillment'
		INNER JOIN report r 
			ON r.report_id = rpage.report_id
			AND r.[name] = 'EOD- Physical Future Fulfillment'
		INNER JOIN report_dataset rd 
			ON rd.report_id = r.report_id AND rd.[alias] = 'EODPFF' 	
		INNER JOIN data_source ds 
			ON ISNULL(NULLIF(ds.report_id, 0), r.report_id) = r.report_id	AND ds.[name] = 'EOD- Physical Future Fulfillment Sql' 	
		INNER JOIN data_source_column dsc 
			ON dsc.source_id = ds.data_source_id AND dsc.[name] = 'Area' 

		INSERT INTO report_tablix_column(tablix_id, dataset_id, column_id, placement, column_order, aggregation
					, functions, [alias], sortable, rounding, thousand_seperation, font
					, font_size, font_style, text_align, text_color, background, default_sort_order
					, default_sort_direction, custom_field, render_as, column_template, negative_mark, currency, date_format, cross_summary_aggregation, mark_for_total, sql_aggregation, subtotal)
		SELECT TOP 1 rpt.report_page_tablix_id tablix_id, rd.report_dataset_id dataset_id, dsc.data_source_column_id column_id,1 placement, 4 column_order,NULL aggregation, NULL functions, 'Message' [alias], 1 sortable, NULL rounding, NULL thousand_seperation, 'Tahoma' font, '8' font_size, '0,0,0' font_style, 'Left' text_align, '#000000' text_color, '#ffffff' background, NULL default_sort_order, NULL sort_direction, 0 custom_field, 0 render_as,-1 column_template,NULL negative_mark,NULL currency,NULL date_format,-1 cross_summary_aggregation,NULL mark_for_total,NULL sql_aggregation,NULL subtotal
			
		FROM sys.objects o
		INNER JOIN report_page_tablix rpt 
			ON rpt.[name] = 'EOD_ Physical Future Fulfillment_tablix'
		INNER JOIN report_page rpage 
			ON rpage.report_page_id = rpt.page_id 
			AND rpage.[name] = 'EOD- Physical Future Fulfillment'
		INNER JOIN report r 
			ON r.report_id = rpage.report_id
			AND r.[name] = 'EOD- Physical Future Fulfillment'
		INNER JOIN report_dataset rd 
			ON rd.report_id = r.report_id AND rd.[alias] = 'EODPFF' 	
		INNER JOIN data_source ds 
			ON ISNULL(NULLIF(ds.report_id, 0), r.report_id) = r.report_id	AND ds.[name] = 'EOD- Physical Future Fulfillment Sql' 	
		INNER JOIN data_source_column dsc 
			ON dsc.source_id = ds.data_source_id AND dsc.[name] = 'Message' 

		INSERT INTO report_tablix_column(tablix_id, dataset_id, column_id, placement, column_order, aggregation
					, functions, [alias], sortable, rounding, thousand_seperation, font
					, font_size, font_style, text_align, text_color, background, default_sort_order
					, default_sort_direction, custom_field, render_as, column_template, negative_mark, currency, date_format, cross_summary_aggregation, mark_for_total, sql_aggregation, subtotal)
		SELECT TOP 1 rpt.report_page_tablix_id tablix_id, rd.report_dataset_id dataset_id, dsc.data_source_column_id column_id,1 placement, 3 column_order,NULL aggregation, NULL functions, 'Status' [alias], 1 sortable, NULL rounding, NULL thousand_seperation, 'Tahoma' font, '8' font_size, '0,0,0' font_style, 'Left' text_align, '#000000' text_color, '#ffffff' background, NULL default_sort_order, NULL sort_direction, 0 custom_field, 0 render_as,-1 column_template,NULL negative_mark,NULL currency,NULL date_format,-1 cross_summary_aggregation,NULL mark_for_total,NULL sql_aggregation,NULL subtotal
			
		FROM sys.objects o
		INNER JOIN report_page_tablix rpt 
			ON rpt.[name] = 'EOD_ Physical Future Fulfillment_tablix'
		INNER JOIN report_page rpage 
			ON rpage.report_page_id = rpt.page_id 
			AND rpage.[name] = 'EOD- Physical Future Fulfillment'
		INNER JOIN report r 
			ON r.report_id = rpage.report_id
			AND r.[name] = 'EOD- Physical Future Fulfillment'
		INNER JOIN report_dataset rd 
			ON rd.report_id = r.report_id AND rd.[alias] = 'EODPFF' 	
		INNER JOIN data_source ds 
			ON ISNULL(NULLIF(ds.report_id, 0), r.report_id) = r.report_id	AND ds.[name] = 'EOD- Physical Future Fulfillment Sql' 	
		INNER JOIN data_source_column dsc 
			ON dsc.source_id = ds.data_source_id AND dsc.[name] = 'Status' 

		INSERT INTO report_tablix_column(tablix_id, dataset_id, column_id, placement, column_order, aggregation
					, functions, [alias], sortable, rounding, thousand_seperation, font
					, font_size, font_style, text_align, text_color, background, default_sort_order
					, default_sort_direction, custom_field, render_as, column_template, negative_mark, currency, date_format, cross_summary_aggregation, mark_for_total, sql_aggregation, subtotal)
		SELECT TOP 1 rpt.report_page_tablix_id tablix_id, rd.report_dataset_id dataset_id, dsc.data_source_column_id column_id,1 placement, 5 column_order,NULL aggregation, NULL functions, 'Recommendation' [alias], 1 sortable, NULL rounding, NULL thousand_seperation, 'Tahoma' font, '8' font_size, '0,0,0' font_style, 'Left' text_align, '#000000' text_color, '#ffffff' background, NULL default_sort_order, NULL sort_direction, 0 custom_field, 0 render_as,-1 column_template,NULL negative_mark,NULL currency,NULL date_format,-1 cross_summary_aggregation,NULL mark_for_total,NULL sql_aggregation,NULL subtotal
			
		FROM sys.objects o
		INNER JOIN report_page_tablix rpt 
			ON rpt.[name] = 'EOD_ Physical Future Fulfillment_tablix'
		INNER JOIN report_page rpage 
			ON rpage.report_page_id = rpt.page_id 
			AND rpage.[name] = 'EOD- Physical Future Fulfillment'
		INNER JOIN report r 
			ON r.report_id = rpage.report_id
			AND r.[name] = 'EOD- Physical Future Fulfillment'
		INNER JOIN report_dataset rd 
			ON rd.report_id = r.report_id AND rd.[alias] = 'EODPFF' 	
		INNER JOIN data_source ds 
			ON ISNULL(NULLIF(ds.report_id, 0), r.report_id) = r.report_id	AND ds.[name] = 'EOD- Physical Future Fulfillment Sql' 	
		INNER JOIN data_source_column dsc 
			ON dsc.source_id = ds.data_source_id AND dsc.[name] = 'Recommendation' 
 INSERT INTO report_tablix_header(tablix_id, column_id, font, font_size, font_style, text_align, text_color, background, report_tablix_column_id)
	  SELECT TOP 1 
			rpt.report_page_tablix_id tablix_id, dsc.data_source_column_id column_id,
			'Tahoma' font,
			'8' font_size,
			'1,0,0' font_style,
			'Left' text_align,
			'#ffffff' text_color,
			'#458bc1' background,
			rtc.report_tablix_column_id			 		       
		FROM   sys.objects o
		INNER JOIN report_page_tablix rpt 
			ON  rpt.[name] = 'EOD_ Physical Future Fulfillment_tablix'
		INNER JOIN report_page rpage 
			ON  rpage.report_page_id = rpt.page_id 
		AND rpage.[name] = 'EOD- Physical Future Fulfillment'
		INNER JOIN report r 
			ON  r.report_id = rpage.report_id 
			AND r.[name] = 'EOD- Physical Future Fulfillment'
		INNER JOIN data_source ds 
			ON ISNULL(NULLIF(ds.report_id, 0), r.report_id) = r.report_id	AND ds.[name] = 'EOD- Physical Future Fulfillment Sql' 	
		INNER JOIN data_source_column dsc 
			ON dsc.source_id = ds.data_source_id AND dsc.[name] = 'Area' 
		INNER JOIN report_tablix_column rtc 
			on rtc.tablix_id = rpt.report_page_tablix_id
			--AND rtc.column_id = dsc.data_source_column_id  --This did not handle custom column, got duplicate custom columns during export
			AND rtc.alias = 'Area' --Added to handle custom column. Assumption: alias is unique and NOT NULL
	
 INSERT INTO report_tablix_header(tablix_id, column_id, font, font_size, font_style, text_align, text_color, background, report_tablix_column_id)
	  SELECT TOP 1 
			rpt.report_page_tablix_id tablix_id, dsc.data_source_column_id column_id,
			'Tahoma' font,
			'8' font_size,
			'1,0,0' font_style,
			'Left' text_align,
			'#ffffff' text_color,
			'#458bc1' background,
			rtc.report_tablix_column_id			 		       
		FROM   sys.objects o
		INNER JOIN report_page_tablix rpt 
			ON  rpt.[name] = 'EOD_ Physical Future Fulfillment_tablix'
		INNER JOIN report_page rpage 
			ON  rpage.report_page_id = rpt.page_id 
		AND rpage.[name] = 'EOD- Physical Future Fulfillment'
		INNER JOIN report r 
			ON  r.report_id = rpage.report_id 
			AND r.[name] = 'EOD- Physical Future Fulfillment'
		INNER JOIN data_source ds 
			ON ISNULL(NULLIF(ds.report_id, 0), r.report_id) = r.report_id	AND ds.[name] = 'EOD- Physical Future Fulfillment Sql' 	
		INNER JOIN data_source_column dsc 
			ON dsc.source_id = ds.data_source_id AND dsc.[name] = 'ErrorCode' 
		INNER JOIN report_tablix_column rtc 
			on rtc.tablix_id = rpt.report_page_tablix_id
			--AND rtc.column_id = dsc.data_source_column_id  --This did not handle custom column, got duplicate custom columns during export
			AND rtc.alias = 'Errorcode' --Added to handle custom column. Assumption: alias is unique and NOT NULL
	
 INSERT INTO report_tablix_header(tablix_id, column_id, font, font_size, font_style, text_align, text_color, background, report_tablix_column_id)
	  SELECT TOP 1 
			rpt.report_page_tablix_id tablix_id, dsc.data_source_column_id column_id,
			'Tahoma' font,
			'8' font_size,
			'1,0,0' font_style,
			'Left' text_align,
			'#ffffff' text_color,
			'#458bc1' background,
			rtc.report_tablix_column_id			 		       
		FROM   sys.objects o
		INNER JOIN report_page_tablix rpt 
			ON  rpt.[name] = 'EOD_ Physical Future Fulfillment_tablix'
		INNER JOIN report_page rpage 
			ON  rpage.report_page_id = rpt.page_id 
		AND rpage.[name] = 'EOD- Physical Future Fulfillment'
		INNER JOIN report r 
			ON  r.report_id = rpage.report_id 
			AND r.[name] = 'EOD- Physical Future Fulfillment'
		INNER JOIN data_source ds 
			ON ISNULL(NULLIF(ds.report_id, 0), r.report_id) = r.report_id	AND ds.[name] = 'EOD- Physical Future Fulfillment Sql' 	
		INNER JOIN data_source_column dsc 
			ON dsc.source_id = ds.data_source_id AND dsc.[name] = 'Message' 
		INNER JOIN report_tablix_column rtc 
			on rtc.tablix_id = rpt.report_page_tablix_id
			--AND rtc.column_id = dsc.data_source_column_id  --This did not handle custom column, got duplicate custom columns during export
			AND rtc.alias = 'Message' --Added to handle custom column. Assumption: alias is unique and NOT NULL
	
 INSERT INTO report_tablix_header(tablix_id, column_id, font, font_size, font_style, text_align, text_color, background, report_tablix_column_id)
	  SELECT TOP 1 
			rpt.report_page_tablix_id tablix_id, dsc.data_source_column_id column_id,
			'Tahoma' font,
			'8' font_size,
			'1,0,0' font_style,
			'Left' text_align,
			'#ffffff' text_color,
			'#458bc1' background,
			rtc.report_tablix_column_id			 		       
		FROM   sys.objects o
		INNER JOIN report_page_tablix rpt 
			ON  rpt.[name] = 'EOD_ Physical Future Fulfillment_tablix'
		INNER JOIN report_page rpage 
			ON  rpage.report_page_id = rpt.page_id 
		AND rpage.[name] = 'EOD- Physical Future Fulfillment'
		INNER JOIN report r 
			ON  r.report_id = rpage.report_id 
			AND r.[name] = 'EOD- Physical Future Fulfillment'
		INNER JOIN data_source ds 
			ON ISNULL(NULLIF(ds.report_id, 0), r.report_id) = r.report_id	AND ds.[name] = 'EOD- Physical Future Fulfillment Sql' 	
		INNER JOIN data_source_column dsc 
			ON dsc.source_id = ds.data_source_id AND dsc.[name] = 'Module' 
		INNER JOIN report_tablix_column rtc 
			on rtc.tablix_id = rpt.report_page_tablix_id
			--AND rtc.column_id = dsc.data_source_column_id  --This did not handle custom column, got duplicate custom columns during export
			AND rtc.alias = 'Module' --Added to handle custom column. Assumption: alias is unique and NOT NULL
	
 INSERT INTO report_tablix_header(tablix_id, column_id, font, font_size, font_style, text_align, text_color, background, report_tablix_column_id)
	  SELECT TOP 1 
			rpt.report_page_tablix_id tablix_id, dsc.data_source_column_id column_id,
			'Tahoma' font,
			'8' font_size,
			'1,0,0' font_style,
			'Left' text_align,
			'#ffffff' text_color,
			'#458bc1' background,
			rtc.report_tablix_column_id			 		       
		FROM   sys.objects o
		INNER JOIN report_page_tablix rpt 
			ON  rpt.[name] = 'EOD_ Physical Future Fulfillment_tablix'
		INNER JOIN report_page rpage 
			ON  rpage.report_page_id = rpt.page_id 
		AND rpage.[name] = 'EOD- Physical Future Fulfillment'
		INNER JOIN report r 
			ON  r.report_id = rpage.report_id 
			AND r.[name] = 'EOD- Physical Future Fulfillment'
		INNER JOIN data_source ds 
			ON ISNULL(NULLIF(ds.report_id, 0), r.report_id) = r.report_id	AND ds.[name] = 'EOD- Physical Future Fulfillment Sql' 	
		INNER JOIN data_source_column dsc 
			ON dsc.source_id = ds.data_source_id AND dsc.[name] = 'Recommendation' 
		INNER JOIN report_tablix_column rtc 
			on rtc.tablix_id = rpt.report_page_tablix_id
			--AND rtc.column_id = dsc.data_source_column_id  --This did not handle custom column, got duplicate custom columns during export
			AND rtc.alias = 'Recommendation' --Added to handle custom column. Assumption: alias is unique and NOT NULL
	
 INSERT INTO report_tablix_header(tablix_id, column_id, font, font_size, font_style, text_align, text_color, background, report_tablix_column_id)
	  SELECT TOP 1 
			rpt.report_page_tablix_id tablix_id, dsc.data_source_column_id column_id,
			'Tahoma' font,
			'8' font_size,
			'1,0,0' font_style,
			'Left' text_align,
			'#ffffff' text_color,
			'#458bc1' background,
			rtc.report_tablix_column_id			 		       
		FROM   sys.objects o
		INNER JOIN report_page_tablix rpt 
			ON  rpt.[name] = 'EOD_ Physical Future Fulfillment_tablix'
		INNER JOIN report_page rpage 
			ON  rpage.report_page_id = rpt.page_id 
		AND rpage.[name] = 'EOD- Physical Future Fulfillment'
		INNER JOIN report r 
			ON  r.report_id = rpage.report_id 
			AND r.[name] = 'EOD- Physical Future Fulfillment'
		INNER JOIN data_source ds 
			ON ISNULL(NULLIF(ds.report_id, 0), r.report_id) = r.report_id	AND ds.[name] = 'EOD- Physical Future Fulfillment Sql' 	
		INNER JOIN data_source_column dsc 
			ON dsc.source_id = ds.data_source_id AND dsc.[name] = 'Status' 
		INNER JOIN report_tablix_column rtc 
			on rtc.tablix_id = rpt.report_page_tablix_id
			--AND rtc.column_id = dsc.data_source_column_id  --This did not handle custom column, got duplicate custom columns during export
			AND rtc.alias = 'Status' --Added to handle custom column. Assumption: alias is unique and NOT NULL
	

		--RETAIN APPLICATION FILTER DETAILS START (PART2)
		UPDATE pm
		SET inserted_paramset_id = rp.report_paramset_id
		FROM #paramset_map pm
		INNER JOIN report_paramset rp
			ON rp.paramset_hash = pm.paramset_hash
		
		UPDATE f set f.report_id = pm.inserted_paramset_id
		FROM application_ui_filter f
		INNER JOIN #paramset_map pm 
			ON pm.deleted_paramset_id = ISNULL(f.report_id, -1)
		WHERE f.application_function_id IS NULL
	
		--delete filter details only for view datasource columns
		DELETE fd
		FROM application_ui_filter_details fd
		INNER JOIN application_ui_filter f 
			ON f.application_ui_filter_id = fd.application_ui_filter_id
		INNER JOIN #paramset_map pm 
			ON pm.inserted_paramset_id = ISNULL(f.report_id, -1)
		LEFT JOIN #sql_source_filter_detail_column_mapping map
			ON map.column_id = ABS(fd.report_column_id)
		WHERE ABS(fd.report_column_id) NOT IN (
			SELECT DISTINCT rp.column_id
			FROM report_param rp
			INNER JOIN report_dataset_paramset rdp 
				ON rdp.report_dataset_paramset_id = rp.dataset_paramset_id
			INNER JOIN report_paramset rpm 
				ON rpm.report_paramset_id = rdp.paramset_id
			WHERE rpm.report_paramset_id = f.report_id
		)
		AND map.column_id IS NULL

		
		--store data to update and delete application filter details row for sql datasource only
		DROP TABLE IF EXISTS #filter_details_to_update_sql_datasource

		SELECT fd.application_ui_filter_details_id, fd.report_column_id, dsc.data_source_column_id, fd.field_value
		INTO #filter_details_to_update_sql_datasource
		FROM application_ui_filter_details fd
		INNER JOIN application_ui_filter f 
			ON f.application_ui_filter_id = fd.application_ui_filter_id
		INNER JOIN report_paramset rp 
			ON rp.report_paramset_id = f.report_id
		INNER JOIN #sql_source_filter_detail_column_mapping map 
			ON map.paramset_hash = rp.paramset_hash
			AND map.column_id = ABS(fd.report_column_id) --used ABS for browser columns label row.
		INNER JOIN report_dataset_paramset rdp 
			ON rdp.paramset_id = rp.report_paramset_id
		INNER JOIN report_param rpr
			ON rpr.dataset_paramset_id = rdp.report_dataset_paramset_id
		INNER JOIN report_dataset rd 
			ON rd.report_dataset_id = rdp.root_dataset_id
		INNER JOIN data_source ds 
			ON ds.data_source_id = rd.source_id
		INNER JOIN data_source_column dsc 
			ON dsc.source_id = ds.data_source_id
		WHERE dsc.name = map.column_name
			AND rpr.column_id = dsc.data_source_column_id

		DROP TABLE IF EXISTS #filter_details_to_delete_sql_datasource

		SELECT fdmap.application_ui_filter_details_id
		INTO #filter_details_to_delete_sql_datasource
		FROM #sql_source_filter_detail_column_mapping fdmap
		EXCEPT
		SELECT fdup.application_ui_filter_details_id
		FROM #filter_details_to_update_sql_datasource fdup
		
		--update filters for sql datasource columns
		UPDATE fd
			SET fd.report_column_id = IIF(fd.report_column_id < 0, -1, 1) * fdup.data_source_column_id		
		FROM application_ui_filter_details fd
		INNER JOIN #filter_details_to_update_sql_datasource fdup
			ON fdup.application_ui_filter_details_id = fd.application_ui_filter_details_id

		--delete unmatched columns from filter detail for sql data source
		DELETE fd
		FROM application_ui_filter_details fd
		INNER JOIN #filter_details_to_delete_sql_datasource fddel
			ON fddel.application_ui_filter_details_id = fd.application_ui_filter_details_id

		--RETAIN APPLICATION FILTER DETAILS END (PART2)
	
COMMIT 

END TRY
BEGIN CATCH
	IF @@TRANCOUNT > 0
		ROLLBACK TRAN;
		
	DECLARE @error_message VARCHAR(MAX) = ERROR_MESSAGE()
	RAISERROR(@error_message,16,1)
END CATCH
