  BEGIN TRY
		BEGIN TRAN
	
	declare @new_ds_alias varchar(10) = 'VTPP'
	/** IF DATA SOURCE ALIAS ALREADY EXISTS ON DESTINATION, RAISE ERROR **/
	if exists(select top 1 1 from data_source where alias = 'VTPP' and name <> 'VTPPosition')
	begin
		select top 1 @new_ds_alias = 'VTPP' + cast(s.n as varchar(5))
		from seq s
		left join data_source ds on ds.alias = 'VTPP' + cast(s.n as varchar(5))
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
	           WHERE [name] = 'VTPPosition'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	AND NOT EXISTS (SELECT 1 FROM map_function_category WHERE [function_name] = 'VTPPosition' AND '106501' = '106501') 
	BEGIN
		INSERT INTO data_source([type_id], [name], [alias], [description], [tsql], report_id, system_defined,category)
		SELECT TOP 1 1 AS [type_id], 'VTPPosition' AS [name], @new_ds_alias AS ALIAS, 'VTP Position' AS [description],null AS [tsql], @report_id_data_source_dest AS report_id,'0' AS [system_defined]
			,'106501' AS [category]
	END

	UPDATE data_source
	SET alias = @new_ds_alias, description = 'VTP Position'
	, [tsql] = CAST('' AS VARCHAR(MAX)) + 'DECLARE @_calc_process_table VARCHAR(500)
DECLARE @_st VARCHAR(MAX)
DECLARE @_source_deal_header_id VARCHAR(1000)

DECLARE @_subbook_id INT=NULL
IF OBJECT_ID(''tempdb..#buy_sell_deal_collection'') IS NOT NULL
    DROP TABLE #buy_sell_deal_collection

SET @_calc_process_table = nullif(isnull(@_calc_process_table, nullif(''@calc_process_table'', replace(''@_calc_process_table'', ''@_'', ''@''))), ''null'')

--VTP Position

IF NULLIF(@_calc_process_table,''1900'') is null  -- debug mode only
BEGIN
	SET @_source_deal_header_id = ''9881''
	DECLARE @_user_login_id VARCHAR(50), @_process_id VARCHAR(100)

	SET @_user_login_id = dbo.FNADBUser()

	IF @_process_id IS NULL
		SET @_process_id=REPLACE(NEWID(), ''-'', ''_'')

	SET @_calc_process_table = dbo.FNAProcessTableName(''calc_process_table'', @_user_login_id, @_process_id)

	SET @_st = ''
			CREATE TABLE ''+@_calc_process_table+''(
				rowid INT IDENTITY(1,1),
				counterparty_id INT,
				contract_id INT,
				curve_id INT,
				prod_date DATETIME,
				as_of_date DATETIME,
				volume FLOAT,
				onPeakVolume FLOAT,
				source_deal_detail_id INT,
				formula_id INT,
				invoice_Line_item_id INT,			
				invoice_line_item_seq_id INT,
				price FLOAT,			
				granularity INT,
				volume_uom_id INT,
				generator_id INT,
				[Hour] INT,
				commodity_id INT,
				meter_id INT,
				curve_source_value_id INT,
				[mins] INT,
				source_deal_header_id INT,
				term_start DATETIME,
				term_end DATETIME)	''

		EXEC spa_print @_st
		EXEC(@_st)	

		SET @_st = '' 
		INSERT INTO ''+@_calc_process_table+''(counterparty_id, contract_id, curve_id, prod_date, as_of_date
											, volume, onPeakVolume, source_deal_detail_id, formula_id
											, invoice_Line_item_id, invoice_line_item_seq_id, price, granularity, volume_uom_id
											, generator_id, [Hour], commodity_id, meter_id
											, curve_source_value_id, [mins], source_deal_header_id, term_start, term_end
											)
		SELECT 	sdh.counterparty_id, sdh.contract_id, sdd.curve_id, cast(t.term_start as date), sdh.deal_date		
			,  CASE WHEN sdd.buy_sell_flag = ''''s'''' THEN -1 ELSE 1 END * sdd.deal_volume, NULL onPeakVolume, sdd.source_deal_detail_id,
			sdd.position_formula_id, NULL invoice_Line_item_id, NULL invoice_line_item_seq_id, NULL price, sdht.hourly_position_breakdown granularity, NULL volume_uom_id,
			NULL generator_id, CASE WHEN sdht.hourly_position_breakdown IN ( 982, 987) THEN DATEPART(hh, t.term_start)+1 ELSE NULL END [hour],
			sdh.commodity_id, NULL meter_id, 4500 curve_source_value_id,  
			CASE WHEN sdht.hourly_position_breakdown IN (987) THEN DATEPART(MINUTE, t.term_start) ELSE 0 END [mins], sdh.source_deal_header_id, sdd.term_start, sdd.term_end
		FROM  source_deal_header sdh 
		INNER JOIN dbo.FNASplit('''''' + @_source_deal_header_id + '''''', '''','''') i ON i.item = sdh.source_deal_header_id
		INNER JOIN source_deal_header_template sdht ON sdht.template_id = sdh.template_id
		INNER JOIN source_deal_detail sdd ON sdd.source_deal_header_id = sdh.source_deal_header_id
		CROSS APPLY [dbo].[FNATermBreakdown] (CASE sdht.hourly_position_breakdown WHEN 982 THEN ''''h'''' WHEN 980 THEN ''''m'''' 
		WHEN 987 THEN ''''f'''' WHEN 993 THEN ''''a'''' ELSE ''''d'''' END, sdd.term_start, CASE sdht.hourly_position_breakdown WHEN 982 THEN DATEADD(hh, 23, sdd.term_end) ELSE sdd.term_end END ) t
		''
		EXEC spa_print @_st
		EXEC(@_st)
END

--EXEC(''select * from '' + @_calc_process_table)

 
IF OBJECT_ID(''tempdb..#location_id'') IS NOT NULL 
	DROP TABLE #location_id 

CREATE TABLE #location_id (location_id INT, location_name VARCHAR(1000) COLLATE DATABASE_DEFAULT, granularity INT, source_deal_header_id INT)

SET @_st = ''INSERT INTO #location_id (location_id, location_name, granularity, source_deal_header_id)
			SELECT DISTINCT sdd.location_id, sml.location_name , s.granularity, s.source_deal_header_id
			FROM ''+ @_calc_process_table +'' s 
			INNER JOIN source_deal_detail sdd on sdd.source_deal_detail_id = s.source_deal_detail_id
			INNER JOIN source_minor_location sml ON sml.source_minor_location_id = sdd.location_id
			''
EXEC spa_print @_st
EXEC(@_st)

SELECT sml.location_id
	, sdh.source_deal_header_id source_deal_header_id
	, NULL buy_deal_id
	, sml.location_name
	, sdd.term_start
	, sdd.term_end
	, sdd.leg
	, buy_sell_flag   
	, granularity
	, MAX(sdd.deal_volume) deal_volume
	INTO #buy_sell_deal_collection  
FROM source_deal_header sdh
INNER JOIN source_deal_detail sdd ON sdd.source_deal_header_id = sdh.source_deal_header_id 
INNER JOIN #location_id sml on sml.location_id = sdd.location_id 
WHERE sdh.source_deal_header_id NOT IN (SELECT source_deal_header_id FROM #location_id)
GROUP BY sdd.term_start, sdh.source_deal_header_id, sml.location_id
	, sml.location_name
	, sdd.term_start
	, sdd.term_end
	, sdd.leg
	, buy_sell_flag   
	, granularity
	, sdd.source_deal_detail_id
 
-- select * from #buy_sell_deal_collection 

-- select * from source_deal_detail where source_deal_header_id IN (9880
--,9878)
-- return 

IF OBJECT_ID(''tempdb..#position'') IS NOT NULL
    DROP TABLE #position

SELECT t1.location_id,rhpd.term_start
--,  rhpd.hr1
--,  rhpd.curve_id , sdd01.curve_id
	 , SUM(rhpd.hr1) hr1 
	, SUM(rhpd.hr2) hr2 
	, SUM(rhpd.hr3) hr3 
	, SUM(rhpd.hr4) hr4 
	, SUM(rhpd.hr5) hr5 
	, SUM(rhpd.hr6) hr6 
	, SUM(rhpd.hr7) hr7 
	, SUM(rhpd.hr8) hr8 
	, SUM(rhpd.hr9 ) hr9 
	, SUM(rhpd.hr10) hr10
	, SUM(rhpd.hr11) hr11
	, SUM(rhpd.hr12) hr12
	, SUM(rhpd.hr13) hr13
	, SUM(rhpd.hr14) hr14
	, SUM(rhpd.hr15) hr15
	, SUM(rhpd.hr16) hr16
	, SUM(rhpd.hr17) hr17
	, SUM(rhpd.hr18) hr18
	, SUM(rhpd.hr19) hr19
	, SUM(rhpd.hr20) hr20
	, SUM(rhpd.hr21) hr21
	, SUM(rhpd.hr22) hr22
	, SUM(rhpd.hr23) hr23
	, SUM(rhpd.hr24) hr24
INTO #position
FROM #buy_sell_deal_collection t1  
INNER JOIN source_deal_detail sdd01 ON sdd01.source_deal_header_id = t1.source_deal_header_id
INNER JOIN report_hourly_position_deal rhpd on rhpd.source_deal_header_id = t1.source_deal_header_id
	AND rhpd.location_id = t1.location_id 
	--AND rhpd.term_start = t1.term_start 
	AND rhpd.term_start BETWEEN sdd01.term_start AND sdd01.term_end
GROUP BY t1.location_id,rhpd.term_start
 
--select * from #position
--select * from report_hourly_position_deal where  source_deal_header_id IN (9880,9878)
--return 

IF OBJECT_ID(''tempdb..#position_unpvt'') IS NOT NULL
    DROP TABLE #position_unpvt

SELECT unpvt.location_id,unpvt.term_start,unpvt.[hour],unpvt.[value]
INTO #position_unpvt
FROM
	(
	SELECT location_id,term_start,hr1 [1],hr2 [2],hr3 [3],hr4 [4],hr5 [5],hr6 [6]
	,hr7 [7],hr8 [8],hr9 [9],hr10 [10],hr11 [11],hr12 [12],hr13 [13],hr14 [14]
	,hr15 [15],hr16 [16],hr17 [17],hr18 [18],hr19 [19],hr20 [20],hr21 [21],hr22 [22],hr23 [23],hr24 [24]	
	FROM #position 
	) P
	UNPIVOT (value for hour IN ([1],[2],[3],[4],[5],[6],[7],[8],[9],[10],[11],[12],[13]
		,[14],[15],[16],[17],[18],[19],[20],[21],[22],[23],[24])
	) as unpvt;


SET @_st = ''
			UPDATE sdd 
			SET sdd.deal_volume = pos.[value]  
			--select *
			FROM ''+ @_calc_process_table +'' s
			INNER JOIN source_deal_detail sdd on sdd.source_deal_detail_id=s.source_deal_detail_id
			INNER JOIN (SELECT location_id
						, term_start
						, MAX([value]) value
						FROM #position_unpvt 
						GROUP BY location_id, term_start
					) pos on pos.location_id= sdd.location_id and pos.term_start = s.prod_date  ''
EXEC spa_print @_st
EXEC(@_st)

--select * from source_deal_detail where source_deal_header_id =7429 
SET @_st=''
	SELECT 
		   s.source_deal_header_id,
		   s.source_deal_detail_id,
		   s.counterparty_id,
		   s.contract_id,
		   s.prod_date,
		   s.[hour],
		   s.[mins],
		ABS(pos.[value]) [value],
		''''''+ @_calc_process_table + '''''' calc_process_table
	--[__batch_report__]
	 from ''+ @_calc_process_table +'' s
		inner join source_deal_detail sdd on sdd.source_deal_detail_id=s.source_deal_detail_id
		inner join #position_unpvt pos on pos.location_id= sdd.location_id and pos.term_start=s.prod_date and pos.[hour]=s.[hour]
	--order by 5,6
''
EXEC spa_print @_st
EXEC(@_st)
--*/', report_id = @report_id_data_source_dest,
	system_defined = '0'
	,category = '106501' 
	WHERE [name] = 'VTPPosition'
		AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1)
		
	
	IF OBJECT_ID('tempdb..#data_source_column', 'U') IS NOT NULL
		DROP TABLE #data_source_column	
	CREATE TABLE #data_source_column(column_id INT)	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'VTPPosition'
	            AND dsc.name =  'calc_process_table'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Calc Process Table'
			   , reqd_param = NULL, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 0, key_column = 0, required_filter = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'VTPPosition'
			AND dsc.name =  'calc_process_table'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'calc_process_table' AS [name], 'Calc Process Table' AS ALIAS, NULL AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, 0 AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'VTPPosition'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'VTPPosition'
	            AND dsc.name =  'contract_id'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Contract ID'
			   , reqd_param = NULL, widget_id = 1, datatype_id = 4, param_data_source = NULL, param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 2, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'VTPPosition'
			AND dsc.name =  'contract_id'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'contract_id' AS [name], 'Contract ID' AS ALIAS, NULL AS reqd_param, 1 AS widget_id, 4 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'VTPPosition'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'VTPPosition'
	            AND dsc.name =  'counterparty_id'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Counterparty ID'
			   , reqd_param = NULL, widget_id = 1, datatype_id = 4, param_data_source = NULL, param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 2, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'VTPPosition'
			AND dsc.name =  'counterparty_id'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'counterparty_id' AS [name], 'Counterparty ID' AS ALIAS, NULL AS reqd_param, 1 AS widget_id, 4 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'VTPPosition'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'VTPPosition'
	            AND dsc.name =  'hour'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Hour'
			   , reqd_param = NULL, widget_id = 1, datatype_id = 4, param_data_source = NULL, param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 2, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'VTPPosition'
			AND dsc.name =  'hour'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'hour' AS [name], 'Hour' AS ALIAS, NULL AS reqd_param, 1 AS widget_id, 4 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'VTPPosition'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'VTPPosition'
	            AND dsc.name =  'mins'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Mins'
			   , reqd_param = NULL, widget_id = 1, datatype_id = 4, param_data_source = NULL, param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 2, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'VTPPosition'
			AND dsc.name =  'mins'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'mins' AS [name], 'Mins' AS ALIAS, NULL AS reqd_param, 1 AS widget_id, 4 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'VTPPosition'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'VTPPosition'
	            AND dsc.name =  'prod_date'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Prod Date'
			   , reqd_param = NULL, widget_id = 6, datatype_id = 2, param_data_source = NULL, param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 4, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'VTPPosition'
			AND dsc.name =  'prod_date'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'prod_date' AS [name], 'Prod Date' AS ALIAS, NULL AS reqd_param, 6 AS widget_id, 2 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,4 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'VTPPosition'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'VTPPosition'
	            AND dsc.name =  'source_deal_detail_id'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Source Deal Detail Id'
			   , reqd_param = NULL, widget_id = 1, datatype_id = 4, param_data_source = NULL, param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 2, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'VTPPosition'
			AND dsc.name =  'source_deal_detail_id'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'source_deal_detail_id' AS [name], 'Source Deal Detail Id' AS ALIAS, NULL AS reqd_param, 1 AS widget_id, 4 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'VTPPosition'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'VTPPosition'
	            AND dsc.name =  'source_deal_header_id'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Deal ID'
			   , reqd_param = NULL, widget_id = 1, datatype_id = 4, param_data_source = NULL, param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 2, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'VTPPosition'
			AND dsc.name =  'source_deal_header_id'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'source_deal_header_id' AS [name], 'Deal ID' AS ALIAS, NULL AS reqd_param, 1 AS widget_id, 4 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'VTPPosition'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'VTPPosition'
	            AND dsc.name =  'value'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Value'
			   , reqd_param = NULL, widget_id = 1, datatype_id = 3, param_data_source = NULL, param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 2, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'VTPPosition'
			AND dsc.name =  'value'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'value' AS [name], 'Value' AS ALIAS, NULL AS reqd_param, 1 AS widget_id, 3 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'VTPPosition'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	DELETE dsc
	FROM data_source_column dsc 
	INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		AND ds.[name] = 'VTPPosition'
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
	 