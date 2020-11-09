BEGIN TRY
		BEGIN TRAN

		DECLARE @report_id_dest INT 
	
		--RETAIN APPLICATION FILTER DETAILS START (PART1)
		if object_id('tempdb..#paramset_map') is not null drop table #paramset_map
		create table #paramset_map (
			deleted_paramset_id int null, 
			paramset_hash varchar(36) COLLATE DATABASE_DEFAULT NULL, 
			inserted_paramset_id int null

		)
		IF EXISTS (SELECT 1 FROM dbo.report WHERE report_hash='A48E12D0_3792_4A72_95BC_9507138D83FA')
		BEGIN
			declare @report_id_to_delete int
			select @report_id_to_delete = report_id from report where report_hash = 'A48E12D0_3792_4A72_95BC_9507138D83FA'

			insert into #paramset_map(deleted_paramset_id, paramset_hash)
			select rp.report_paramset_id, rp.paramset_hash
			from report_paramset rp
			inner join report_page pg on pg.report_page_id = rp.page_id
			where pg.report_id = @report_id_to_delete

			EXEC spa_rfx_report @flag='d', @report_id=@report_id_to_delete, @retain_privilege=1, @process_id=NULL

		
		END
		--RETAIN APPLICATION FILTER DETAILS END (PART1)
		
		declare @report_copy_name varchar(200)
		
		set @report_copy_name = isnull(@report_copy_name, 'Copy of ' + 'book balancing')
		
		INSERT INTO report ([name], [owner], is_system, is_excel, is_mobile, report_hash, [description], category_id)
		SELECT TOP 1 'Book Balancing' [name], 'dev_admin' [owner], 0 is_system, 0 is_excel, 0 is_mobile, 'A48E12D0_3792_4A72_95BC_9507138D83FA' report_hash, '' [description], CAST(sdv_cat.value_id AS VARCHAR(10)) category_id
		FROM sys.objects o
		LEFT JOIN static_data_value sdv_cat ON sdv_cat.code = 'Processes' AND sdv_cat.type_id = 10008 
		SET @report_id_dest = SCOPE_IDENTITY()
		
		BEGIN TRY
		BEGIN TRAN
	
	declare @new_ds_alias varchar(10) = 'pf'
	/** IF DATA SOURCE ALIAS ALREADY EXISTS ON DESTINATION, RAISE ERROR **/
	if exists(select top 1 1 from data_source where alias = 'pf' and name <> 'position_formula')
	begin
		select top 1 @new_ds_alias = 'pf' + cast(s.n as varchar(5))
		from seq s
		left join data_source ds on ds.alias = 'pf' + cast(s.n as varchar(5))
		where ds.data_source_id is null
			and s.n < 10

		--RAISERROR ('Datasource alias already exists on system.', 16, 1);
	end

	DECLARE @report_id_data_source_dest INT 
	
	SELECT @report_id_data_source_dest = report_id
	FROM report r
	WHERE r.[name] = 'book balancing'
	IF NOT EXISTS (SELECT 1 
	           FROM data_source 
	           WHERE [name] = 'position_formula'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	AND NOT EXISTS (SELECT 1 FROM map_function_category WHERE [function_name] = 'position_formula' AND '106500' = '106501') 
	BEGIN
		INSERT INTO data_source([type_id], [name], [alias], [description], [tsql], report_id, system_defined,category)
		SELECT TOP 1 2 AS [type_id], 'position_formula' AS [name], @new_ds_alias AS ALIAS, NULL AS [description],null AS [tsql], @report_id_data_source_dest AS report_id,NULL AS [system_defined]
			,'106500' AS [category]
	END

	UPDATE data_source
	SET alias = @new_ds_alias, description = NULL
	, [tsql] = CAST('' AS VARCHAR(MAX)) + '--EXEC spa_drop_all_temp_table

DECLARE @_sql NVARCHAR(MAX)

DECLARE @_source_subbook_id VARCHAR(1000)

DECLARE @_destination_subbook_id VARCHAR(1000)  

DECLARE @_location_id VARCHAR(1000)

DECLARE @_term_start DATETIME

DECLARE @_term_end DATETIME

DECLARE @_distination_deal NVARCHAR(200)



IF ''@source_subbook_id'' <> ''NULL''

    SET @_source_subbook_id = ''@source_subbook_id''

IF ''@destination_subbook_id'' <> ''NULL''

    SET @_destination_subbook_id = ''@destination_subbook_id''

IF ''@location_id'' <> ''NULL''

    SET @_location_id = ''@location_id''

IF ''@term_start'' <> ''NULL''

    SET @_term_start = ''@term_start''

IF ''@term_end'' <> ''NULL''

    SET @_term_end = ''@term_end''

IF ''@distination_deal'' <> ''NULL''

    SET @_distination_deal = ''@distination_deal''



--SET @_term_start = ''2025-06-01''

--SET @_term_end = ''2025-06-30''

--SET @_source_subbook_id = 180

--SET @_destination_subbook_id = 181

--SET @_distination_deal = ''Destination GPLL''

--SET @_location_id = ''2852'' --GPLL





SELECT item location_id
INTO #temp_location
FROM SplitCommaSeperatedValues(@_location_id)

SELECT sdh.source_deal_header_id
	, MAX(sdd.buy_sell_flag) header_buy_sell_flag 
	, sdd.location_id location_id
	, MIN(sdd.term_start) term_start
	, MAX(sdd.term_end) term_end
INTO #temp_source
FROM source_deal_header sdh
INNER JOIN source_system_book_map ssbm 
	ON sdh.source_system_book_id1 = ssbm.source_system_book_id1 
	AND sdh.source_system_book_id2 = ssbm.source_system_book_id2  
	AND sdh.source_system_book_id3 = ssbm.source_system_book_id3  
	AND sdh.source_system_book_id4 = ssbm.source_system_book_id4	
INNER JOIN source_deal_header_template sdht
    ON sdht.template_id = sdh.template_id 
INNER JOIN source_deal_detail sdd
	ON sdh.source_deal_header_id = sdd.source_deal_header_id
INNER JOIN #temp_location tl
	ON tl.location_id = sdd.location_id
INNER JOIN SplitCommaSeperatedValues(@_source_subbook_id) sb
	ON sb.item = ssbm.book_deal_type_map_id
WHERE sdht.template_name <> ''Physical_Bal''
GROUP BY sdh.source_deal_header_id, sdd.location_id


DELETE FROM #temp_source 
WHERE @_term_start NOT BETWEEN term_start AND term_end

CREATE TABLE #temp_destination (
	source_deal_header_id INT
	, header_buy_sell_flag CHAR(1) COLLATE DATABASE_DEFAULT 
	, location_id INT
	, term_start DATETIME
	, term_end DATETIME
)


-- Inserts destination deals
INSERT INTO #temp_destination
SELECT sdh.source_deal_header_id
	, MAX(sdd.buy_sell_flag) header_buy_sell_flag 
	, MAX(sdd.location_id) location_id
	, MIN(sdd.term_start) term_start
	, MAX(sdd.term_end) term_end 
FROM source_deal_header sdh
INNER JOIN source_deal_detail sdd
	ON sdh.source_deal_header_id = sdd.source_deal_header_id
WHERE sdh.deal_id = @_distination_deal --''Destination GPLL''  -- 
GROUP BY sdh.source_deal_header_id

--Inserts offset deals
INSERT INTO #temp_destination 
SELECT  
	sdh.source_deal_header_id
	, MAX(sdd.buy_sell_flag) header_buy_sell_flag 
	, MAX(sdd.location_id) location_id
	, MIN(sdd.term_start) term_start
	, MAX(sdd.term_end) term_end 
FROM #temp_destination td
INNER JOIN source_deal_header sdh
	ON td.source_deal_header_id = sdh.close_reference_id
INNER JOIN source_deal_detail sdd
	ON sdh.source_deal_header_id = sdd.source_deal_header_id
GROUP BY sdh.source_deal_header_id



SELECT sub.term_start, s.location_id,
	SUM(ISNULL(sub.hr1, 0)) [01:00],
	SUM(ISNULL(sub.hr2, 0)) [02:00],
	SUM(ISNULL(sub.hr3, 0)) [03:00],
	SUM(ISNULL(sub.hr4, 0)) [04:00],
	SUM(ISNULL(sub.hr5, 0)) [05:00],
	SUM(ISNULL(sub.hr6, 0)) [06:00],
	SUM(ISNULL(sub.hr7, 0)) [07:00],
	SUM(ISNULL(sub.hr8, 0)) [08:00],
	SUM(ISNULL(sub.hr9, 0)) [09:00],
	SUM(ISNULL(sub.hr10, 0)) [10:00],
	SUM(ISNULL(sub.hr11, 0)) [11:00],
	SUM(ISNULL(sub.hr12, 0)) [12:00],
	SUM(ISNULL(sub.hr13, 0)) [13:00],
	SUM(ISNULL(sub.hr14, 0)) [14:00],
	SUM(ISNULL(sub.hr15, 0)) [15:00],
	SUM(ISNULL(sub.hr16, 0)) [16:00],
	SUM(ISNULL(sub.hr17, 0)) [17:00],
	SUM(ISNULL(sub.hr18, 0)) [18:00],
	SUM(ISNULL(sub.hr19, 0)) [19:00],
	SUM(ISNULL(sub.hr20, 0)) [20:00],
	SUM(ISNULL(sub.hr21, 0)) [21:00],
	SUM(ISNULL(sub.hr22, 0)) [22:00],
	SUM(ISNULL(sub.hr23, 0)) [23:00],
	SUM(ISNULL(sub.hr24, 0)) [24:00]
 INTO #temp_unpivot

FROM #temp_source s
INNER JOIN source_deal_detail sdd
	ON s.source_deal_header_id = sdd.source_deal_header_id
	 AND sdd.term_start BETWEEN @_term_start AND @_term_end
	AND s.location_id = sdd.location_id
CROSS APPLY(
		SELECT rhpd.source_deal_header_id, term_start, granularity
			, hr1, hr2, hr3, hr4, hr5, hr6, hr7
			, hr8, hr9, hr10, hr11, hr12, hr13
			, hr14, hr15, hr16, hr17, hr18, hr19
			, hr20, hr21, hr22, hr23, hr24
		FROM report_hourly_position_deal_main rhpd
		WHERE rhpd.term_start BETWEEN s.term_start AND s.term_end
			AND rhpd.term_start BETWEEN @_term_start AND @_term_end
			AND rhpd.source_deal_detail_id = sdd.source_deal_detail_id
		UNION ALL
		SELECT rhpp.source_deal_header_id, term_start, granularity
			, hr1, hr2, hr3, hr4, hr5, hr6, hr7
			, hr8, hr9, hr10, hr11, hr12, hr13
			, hr14, hr15, hr16, hr17, hr18, hr19
			, hr20, hr21, hr22, hr23, hr24
		FROM report_hourly_position_profile_main rhpp
		WHERE rhpp.term_start BETWEEN s.term_start AND s.term_end
			AND rhpp.term_start BETWEEN @_term_start AND @_term_end
			AND sdd.source_deal_detail_id = rhpp.source_deal_detail_id
) sub
GROUP BY sub.term_start,s.location_id

SELECT unpvt.location_id
	, unpvt.term_start term_date
	, unpvt.hr 
	, 0 is_dst
	, unpvt.volume
	, 982 granularity 
INTO #temp_hourly_data_pre
FROM (	SELECT * 
		FROM #temp_unpivot
) a
UNPIVOT
	(
		volume FOR hr IN (
			[01:00],[02:00],[03:00],[04:00],[05:00],[06:00],
			[07:00],[08:00],[09:00], [10:00],[11:00],[12:00],[13:00],				 
			[14:00],[15:00],[16:00],[17:00], [18:00], [19:00], [20:00],
			[21:00], [22:00],[23:00], [24:00]
		)
	) unpvt



SELECT sdd.source_deal_header_id,
	sdd.source_deal_detail_id,
	thd.term_date,
	thd.hr,
	thd.is_dst,
	thd.volume volume,
	thd.granularity 
INTO #temp_hourly_data
FROM #temp_hourly_data_pre thd
INNER JOIN #temp_destination td
	ON thd.location_id = td.location_id
	--- AND td.header_buy_sell_flag = IIF(thd.volume > 0, ''s'', ''b'')
	AND thd.term_date BETWEEN td.term_start AND td.term_end
INNER JOIN source_deal_detail sdd
	ON sdd.source_deal_header_id = td.source_deal_header_id
	AND thd.term_date BETWEEN sdd.term_start AND sdd.term_end
DROP TABLE IF EXISTS #deleted_dest_deal	
CREATE TABLE #deleted_dest_deal(source_deal_detail_id INT)
DELETE sddh 
OUTPUT DELETED.source_deal_detail_id
INTO #deleted_dest_deal(source_deal_detail_id)
FROM #temp_destination td
INNER JOIN source_deal_detail sdd
	ON td.source_deal_header_id = sdd.source_deal_header_id
INNER JOIN source_deal_detail_hour sddh
	ON sdd.source_deal_detail_id = sddh.source_deal_detail_id
WHERE sddh.term_date BETWEEN @_term_start AND @_term_end
INSERT INTO source_deal_detail_hour (
	source_deal_detail_id,
	term_date,
	hr,
	is_dst,
	volume,
	granularity
)
OUTPUT INSERTED.source_deal_detail_id
INTO #deleted_dest_deal(source_deal_detail_id)
SELECT 	source_deal_detail_id,
	term_date,
	hr,
	is_dst,
	volume,
	granularity
FROM #temp_hourly_data
DECLARE @_job_process_id VARCHAR(200), @_job_name VARCHAR(500)
DECLARE @_user_name NVARCHAR(200) = dbo.FNADBUser()
DECLARE @_after_insert_process_table NVARCHAR(500)
SET @_job_process_id = dbo.FNAGETNEWID()
SET @_after_insert_process_table = dbo.FNAProcessTableName(''report_position'', @_user_name, @_job_process_id)
IF OBJECT_ID(@_after_insert_process_table) IS NOT NULL
BEGIN
	EXEC(''DROP TABLE '' + @_after_insert_process_table)
END
EXEC (''CREATE TABLE '' + @_after_insert_process_table + ''( source_deal_header_id INT, source_deal_detail_id INT)'')
SET @_sql = ''INSERT INTO '' + @_after_insert_process_table + ''(source_deal_header_id, source_deal_detail_id) 
			SELECT DISTINCT sdh.source_deal_header_id, sdd.source_deal_detail_id 
			FROM #deleted_dest_deal d
			INNER JOIN source_deal_detail sdd ON sdd.source_deal_detail_id = d.source_deal_detail_id
			INNER JOIN source_deal_header sdh ON sdh.source_deal_header_id = sdd.source_deal_header_id
			''
EXEC (@_sql)
SET @_sql = '' spa_calc_deal_position_breakdown NULL,'''''' + @_job_process_id+ ''''''''
SET @_job_name = ''storage_st_jobs_'' + @_job_process_id
EXEC spa_run_sp_as_job @_job_name, @_sql, ''spa_calc_deal_position_breakdown'', @_user_name
SELECT @_source_subbook_id source_subbook_id,
	   @_destination_subbook_id destination_subbook_id,  
	   @_distination_deal distination_deal,
	   @_location_id location_id,
	   @_term_start term_start,
       @_term_end term_end
--[__batch_report__] 
FROM seq 
WHERE n = 1
', report_id = @report_id_data_source_dest,
	system_defined = NULL
	,category = '106500' 
	WHERE [name] = 'position_formula'
		AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1)
		
	
	IF OBJECT_ID('tempdb..#data_source_column', 'U') IS NOT NULL
		DROP TABLE #data_source_column	
	CREATE TABLE #data_source_column(column_id INT)	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'position_formula'
	            AND dsc.name =  'location_id'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Location ID'
			   , reqd_param = NULL, widget_id = 9, datatype_id = 5, param_data_source = 'EXEC spa_source_minor_location ''o''', param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 0, key_column = 0, required_filter = 1
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'position_formula'
			AND dsc.name =  'location_id'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'location_id' AS [name], 'Location ID' AS ALIAS, NULL AS reqd_param, 9 AS widget_id, 5 AS datatype_id, 'EXEC spa_source_minor_location ''o''' AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, 1 AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'position_formula'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'position_formula'
	            AND dsc.name =  'destination_subbook_id'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Destination Subbook Id'
			   , reqd_param = NULL, widget_id = 9, datatype_id = 5, param_data_source = 'SELECT sub_book_id, book_structure FROM [dbo].[FNAGetPipeSeparatedBookStructure](10131000)', param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 0, key_column = 0, required_filter = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'position_formula'
			AND dsc.name =  'destination_subbook_id'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'destination_subbook_id' AS [name], 'Destination Subbook Id' AS ALIAS, NULL AS reqd_param, 9 AS widget_id, 5 AS datatype_id, 'SELECT sub_book_id, book_structure FROM [dbo].[FNAGetPipeSeparatedBookStructure](10131000)' AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, 0 AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'position_formula'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'position_formula'
	            AND dsc.name =  'source_subbook_id'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Source Subbook Id'
			   , reqd_param = NULL, widget_id = 9, datatype_id = 5, param_data_source = 'SELECT sub_book_id, book_structure FROM [dbo].[FNAGetPipeSeparatedBookStructure](10131000)', param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 0, key_column = 0, required_filter = 1
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'position_formula'
			AND dsc.name =  'source_subbook_id'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'source_subbook_id' AS [name], 'Source Subbook Id' AS ALIAS, NULL AS reqd_param, 9 AS widget_id, 5 AS datatype_id, 'SELECT sub_book_id, book_structure FROM [dbo].[FNAGetPipeSeparatedBookStructure](10131000)' AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, 1 AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'position_formula'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'position_formula'
	            AND dsc.name =  'term_end'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Term End'
			   , reqd_param = NULL, widget_id = 6, datatype_id = 2, param_data_source = NULL, param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 4, key_column = 0, required_filter = 1
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'position_formula'
			AND dsc.name =  'term_end'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'term_end' AS [name], 'Term End' AS ALIAS, NULL AS reqd_param, 6 AS widget_id, 2 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,4 AS column_template, 0 AS key_column, 1 AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'position_formula'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'position_formula'
	            AND dsc.name =  'term_start'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Term Start'
			   , reqd_param = NULL, widget_id = 6, datatype_id = 2, param_data_source = NULL, param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 4, key_column = 0, required_filter = 1
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'position_formula'
			AND dsc.name =  'term_start'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'term_start' AS [name], 'Term Start' AS ALIAS, NULL AS reqd_param, 6 AS widget_id, 2 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,4 AS column_template, 0 AS key_column, 1 AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'position_formula'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'position_formula'
	            AND dsc.name =  'distination_deal'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Distination Deal'
			   , reqd_param = NULL, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 0, key_column = 0, required_filter = 1
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'position_formula'
			AND dsc.name =  'distination_deal'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'distination_deal' AS [name], 'Distination Deal' AS ALIAS, NULL AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, 1 AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'position_formula'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	DELETE dsc
	FROM data_source_column dsc 
	INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		AND ds.[name] = 'position_formula'
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
		SELECT TOP 1 ds.data_source_id AS source_id, @report_id_dest AS report_id, 'pf' [alias], rd_root.report_dataset_id AS root_dataset_id,0 AS is_free_from, 'NULL' AS relationship_sql
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'position_formula'
			AND ISNULL(ds.report_id, @report_id_dest) = @report_id_dest
		LEFT JOIN report_dataset rd_root ON rd_root.[alias] = NULL
			AND rd_root.report_id = @report_id_dest		
		
	INSERT INTO report_page(report_id, [name], report_hash, width, height)
	SELECT @report_id_dest AS report_id, 'Book Balancing' [name], 'A48E12D0_3792_4A72_95BC_9507138D83FA' report_hash, 11.5 width,5.5 height
	
		INSERT INTO report_paramset(page_id, [name], paramset_hash, report_status_id, export_report_name, export_location, output_file_format, delimiter, xml_format, report_header, compress_file, category_id)
		SELECT TOP 1 rpage.report_page_id, 'Position Formula', '8B01AA41_4F64_494D_A868_5A1864A8AB23', 1,'','','.xlsx',',', 
		-100000,'n','n',0	
		FROM sys.objects o
		INNER JOIN report_page rpage 
			on rpage.[name] = 'Book Balancing'
		INNER JOIN report r 
		ON r.report_id = rpage.report_id
			AND r.[name] = 'Book Balancing'
	
		INSERT INTO report_dataset_paramset(paramset_id, root_dataset_id, where_part, advance_mode)
		SELECT TOP 1 rp.report_paramset_id AS paramset_id, rd.report_dataset_id AS root_dataset_id, NULL AS where_part, 0
		FROM sys.objects o
		INNER JOIN report_paramset rp 
			ON rp.[name] = 'Position Formula'
		INNER JOIN report_page rpage 
			ON rpage.report_page_id = rp.page_id
			AND rpage.[name] = 'Book Balancing'
		INNER JOIN report r 
			ON r.report_id = rpage.report_id
			AND r.[name] = 'Book Balancing'
		INNER JOIN report_dataset rd 
			ON rd.report_id = @report_id_dest
			AND rd.[alias] = 'pf'
	
		INSERT INTO report_param(dataset_paramset_id, dataset_id, column_id, operator,
					initial_value, initial_value2, optional, hidden, logical_operator, param_order, param_depth, label)
		SELECT TOP 1 rdp.report_dataset_paramset_id AS dataset_paramset_id, rd.report_dataset_id AS dataset_id , dsc.data_source_column_id AS column_id, 1 AS operator, '' AS initial_value, '' AS initial_value2, 0 AS optional, 0 AS hidden,1 AS logical_operator, 3 AS param_order, 0 AS param_depth, NULL AS label
		FROM sys.objects o
		INNER JOIN report_paramset rp 
			ON rp.[name] = 'Position Formula'
		INNER JOIN report_page rpage 
			ON rpage.report_page_id = rp.page_id
			AND rpage.[name] = 'Book Balancing'
		INNER JOIN report r ON r.report_id = rpage.report_id
			AND r.[name] = 'Book Balancing'
		INNER JOIN report_dataset rd_root 
			ON rd_root.report_id = @report_id_dest 
			AND rd_root.[alias] = 'pf'
		INNER JOIN report_dataset_paramset rdp 
			ON rdp.paramset_id = rp.report_paramset_id
			AND rdp.root_dataset_id = rd_root.report_dataset_id
		INNER JOIN report_dataset rd 
			ON rd.report_id = r.report_id
			AND rd.[alias] = 'pf'
		INNER JOIN data_source ds 
			ON ISNULL(NULLIF(ds.report_id, 0), r.report_id) = r.report_id	
			AND ds.[name] = 'position_formula' 
		INNER JOIN data_source_column dsc 
			ON dsc.source_id = ds.data_source_id
			AND dsc.[name] = 'term_end'	
	
		INSERT INTO report_param(dataset_paramset_id, dataset_id, column_id, operator,
					initial_value, initial_value2, optional, hidden, logical_operator, param_order, param_depth, label)
		SELECT TOP 1 rdp.report_dataset_paramset_id AS dataset_paramset_id, rd.report_dataset_id AS dataset_id , dsc.data_source_column_id AS column_id, 1 AS operator, '' AS initial_value, '' AS initial_value2, 0 AS optional, 0 AS hidden,1 AS logical_operator, 2 AS param_order, 0 AS param_depth, NULL AS label
		FROM sys.objects o
		INNER JOIN report_paramset rp 
			ON rp.[name] = 'Position Formula'
		INNER JOIN report_page rpage 
			ON rpage.report_page_id = rp.page_id
			AND rpage.[name] = 'Book Balancing'
		INNER JOIN report r ON r.report_id = rpage.report_id
			AND r.[name] = 'Book Balancing'
		INNER JOIN report_dataset rd_root 
			ON rd_root.report_id = @report_id_dest 
			AND rd_root.[alias] = 'pf'
		INNER JOIN report_dataset_paramset rdp 
			ON rdp.paramset_id = rp.report_paramset_id
			AND rdp.root_dataset_id = rd_root.report_dataset_id
		INNER JOIN report_dataset rd 
			ON rd.report_id = r.report_id
			AND rd.[alias] = 'pf'
		INNER JOIN data_source ds 
			ON ISNULL(NULLIF(ds.report_id, 0), r.report_id) = r.report_id	
			AND ds.[name] = 'position_formula' 
		INNER JOIN data_source_column dsc 
			ON dsc.source_id = ds.data_source_id
			AND dsc.[name] = 'term_start'	
	
		INSERT INTO report_param(dataset_paramset_id, dataset_id, column_id, operator,
					initial_value, initial_value2, optional, hidden, logical_operator, param_order, param_depth, label)
		SELECT TOP 1 rdp.report_dataset_paramset_id AS dataset_paramset_id, rd.report_dataset_id AS dataset_id , dsc.data_source_column_id AS column_id, 1 AS operator, '' AS initial_value, '' AS initial_value2, 0 AS optional, 0 AS hidden,1 AS logical_operator, 5 AS param_order, 0 AS param_depth, 'Destination Ref ID' AS label
		FROM sys.objects o
		INNER JOIN report_paramset rp 
			ON rp.[name] = 'Position Formula'
		INNER JOIN report_page rpage 
			ON rpage.report_page_id = rp.page_id
			AND rpage.[name] = 'Book Balancing'
		INNER JOIN report r ON r.report_id = rpage.report_id
			AND r.[name] = 'Book Balancing'
		INNER JOIN report_dataset rd_root 
			ON rd_root.report_id = @report_id_dest 
			AND rd_root.[alias] = 'pf'
		INNER JOIN report_dataset_paramset rdp 
			ON rdp.paramset_id = rp.report_paramset_id
			AND rdp.root_dataset_id = rd_root.report_dataset_id
		INNER JOIN report_dataset rd 
			ON rd.report_id = r.report_id
			AND rd.[alias] = 'pf'
		INNER JOIN data_source ds 
			ON ISNULL(NULLIF(ds.report_id, 0), r.report_id) = r.report_id	
			AND ds.[name] = 'position_formula' 
		INNER JOIN data_source_column dsc 
			ON dsc.source_id = ds.data_source_id
			AND dsc.[name] = 'distination_deal'	
	
		INSERT INTO report_param(dataset_paramset_id, dataset_id, column_id, operator,
					initial_value, initial_value2, optional, hidden, logical_operator, param_order, param_depth, label)
		SELECT TOP 1 rdp.report_dataset_paramset_id AS dataset_paramset_id, rd.report_dataset_id AS dataset_id , dsc.data_source_column_id AS column_id, 9 AS operator, '' AS initial_value, '' AS initial_value2, 0 AS optional, 0 AS hidden,1 AS logical_operator, 4 AS param_order, 0 AS param_depth, 'Location' AS label
		FROM sys.objects o
		INNER JOIN report_paramset rp 
			ON rp.[name] = 'Position Formula'
		INNER JOIN report_page rpage 
			ON rpage.report_page_id = rp.page_id
			AND rpage.[name] = 'Book Balancing'
		INNER JOIN report r ON r.report_id = rpage.report_id
			AND r.[name] = 'Book Balancing'
		INNER JOIN report_dataset rd_root 
			ON rd_root.report_id = @report_id_dest 
			AND rd_root.[alias] = 'pf'
		INNER JOIN report_dataset_paramset rdp 
			ON rdp.paramset_id = rp.report_paramset_id
			AND rdp.root_dataset_id = rd_root.report_dataset_id
		INNER JOIN report_dataset rd 
			ON rd.report_id = r.report_id
			AND rd.[alias] = 'pf'
		INNER JOIN data_source ds 
			ON ISNULL(NULLIF(ds.report_id, 0), r.report_id) = r.report_id	
			AND ds.[name] = 'position_formula' 
		INNER JOIN data_source_column dsc 
			ON dsc.source_id = ds.data_source_id
			AND dsc.[name] = 'location_id'	
	
		INSERT INTO report_param(dataset_paramset_id, dataset_id, column_id, operator,
					initial_value, initial_value2, optional, hidden, logical_operator, param_order, param_depth, label)
		SELECT TOP 1 rdp.report_dataset_paramset_id AS dataset_paramset_id, rd.report_dataset_id AS dataset_id , dsc.data_source_column_id AS column_id, 9 AS operator, '' AS initial_value, '' AS initial_value2, 1 AS optional, 0 AS hidden,0 AS logical_operator, 1 AS param_order, 0 AS param_depth, 'Destination Subbook' AS label
		FROM sys.objects o
		INNER JOIN report_paramset rp 
			ON rp.[name] = 'Position Formula'
		INNER JOIN report_page rpage 
			ON rpage.report_page_id = rp.page_id
			AND rpage.[name] = 'Book Balancing'
		INNER JOIN report r ON r.report_id = rpage.report_id
			AND r.[name] = 'Book Balancing'
		INNER JOIN report_dataset rd_root 
			ON rd_root.report_id = @report_id_dest 
			AND rd_root.[alias] = 'pf'
		INNER JOIN report_dataset_paramset rdp 
			ON rdp.paramset_id = rp.report_paramset_id
			AND rdp.root_dataset_id = rd_root.report_dataset_id
		INNER JOIN report_dataset rd 
			ON rd.report_id = r.report_id
			AND rd.[alias] = 'pf'
		INNER JOIN data_source ds 
			ON ISNULL(NULLIF(ds.report_id, 0), r.report_id) = r.report_id	
			AND ds.[name] = 'position_formula' 
		INNER JOIN data_source_column dsc 
			ON dsc.source_id = ds.data_source_id
			AND dsc.[name] = 'destination_subbook_id'	
	
		INSERT INTO report_param(dataset_paramset_id, dataset_id, column_id, operator,
					initial_value, initial_value2, optional, hidden, logical_operator, param_order, param_depth, label)
		SELECT TOP 1 rdp.report_dataset_paramset_id AS dataset_paramset_id, rd.report_dataset_id AS dataset_id , dsc.data_source_column_id AS column_id, 9 AS operator, '' AS initial_value, '' AS initial_value2, 0 AS optional, 0 AS hidden,1 AS logical_operator, 0 AS param_order, 0 AS param_depth, 'Source Subbook' AS label
		FROM sys.objects o
		INNER JOIN report_paramset rp 
			ON rp.[name] = 'Position Formula'
		INNER JOIN report_page rpage 
			ON rpage.report_page_id = rp.page_id
			AND rpage.[name] = 'Book Balancing'
		INNER JOIN report r ON r.report_id = rpage.report_id
			AND r.[name] = 'Book Balancing'
		INNER JOIN report_dataset rd_root 
			ON rd_root.report_id = @report_id_dest 
			AND rd_root.[alias] = 'pf'
		INNER JOIN report_dataset_paramset rdp 
			ON rdp.paramset_id = rp.report_paramset_id
			AND rdp.root_dataset_id = rd_root.report_dataset_id
		INNER JOIN report_dataset rd 
			ON rd.report_id = r.report_id
			AND rd.[alias] = 'pf'
		INNER JOIN data_source ds 
			ON ISNULL(NULLIF(ds.report_id, 0), r.report_id) = r.report_id	
			AND ds.[name] = 'position_formula' 
		INNER JOIN data_source_column dsc 
			ON dsc.source_id = ds.data_source_id
			AND dsc.[name] = 'source_subbook_id'	
	
		INSERT INTO report_page_tablix(page_id,root_dataset_id, [name], width, height, [top], [left], group_mode, border_style, page_break, type_id, cross_summary, no_header, export_table_name, is_global)
		SELECT TOP 1 rpage.report_page_id AS page_id, rd.report_dataset_id AS root_dataset_id, 'position formula_tablix' [name], '4' width, '2.6666666666666665' height, '0' [top], '0' [left],2 AS group_mode,1 AS border_style,0 AS page_break,1 AS type_id,1 AS cross_summary,2 AS no_header,'' export_table_name, 0 AS is_global
		FROM sys.objects o
		INNER JOIN report_page rpage 
		ON rpage.[name] = 'Book Balancing'
		INNER JOIN report r 
			ON r.report_id = rpage.report_id
			AND r.[name] = 'Book Balancing'
		INNER JOIN report_dataset rd 
			ON rd.report_id = r.report_id 
			AND rd.[alias] = 'pf' 
	
		INSERT INTO report_tablix_column(tablix_id, dataset_id, column_id, placement, column_order, aggregation
					, functions, [alias], sortable, rounding, thousand_seperation, font
					, font_size, font_style, text_align, text_color, background, default_sort_order
					, default_sort_direction, custom_field, render_as, column_template, negative_mark, currency, date_format, cross_summary_aggregation, mark_for_total, sql_aggregation, subtotal)
		SELECT TOP 1 rpt.report_page_tablix_id tablix_id, rd.report_dataset_id dataset_id, dsc.data_source_column_id column_id,1 placement, 0 column_order,NULL aggregation, NULL functions, 'Source Subbook Id' [alias], 1 sortable, NULL rounding, NULL thousand_seperation, 'Tahoma' font, '8' font_size, '0,0,0' font_style, 'Left' text_align, '#000000' text_color, '#ffffff' background, NULL default_sort_order, NULL sort_direction, 0 custom_field, 0 render_as,-1 column_template,NULL negative_mark,NULL currency,NULL date_format,-1 cross_summary_aggregation,NULL mark_for_total,NULL sql_aggregation,NULL subtotal
			
		FROM sys.objects o
		INNER JOIN report_page_tablix rpt 
			ON rpt.[name] = 'position formula_tablix'
		INNER JOIN report_page rpage 
			ON rpage.report_page_id = rpt.page_id 
			AND rpage.[name] = 'Book Balancing'
		INNER JOIN report r 
			ON r.report_id = rpage.report_id
			AND r.[name] = 'Book Balancing'
		INNER JOIN report_dataset rd 
			ON rd.report_id = r.report_id AND rd.[alias] = 'pf' 	
		INNER JOIN data_source ds 
			ON ISNULL(NULLIF(ds.report_id, 0), r.report_id) = r.report_id	AND ds.[name] = 'position_formula' 	
		INNER JOIN data_source_column dsc 
			ON dsc.source_id = ds.data_source_id AND dsc.[name] = 'source_subbook_id' 
		INSERT INTO report_tablix_column(tablix_id, dataset_id, column_id, placement, column_order, aggregation
					, functions, [alias], sortable, rounding, thousand_seperation, font
					, font_size, font_style, text_align, text_color, background, default_sort_order
					, default_sort_direction, custom_field, render_as, column_template, negative_mark, currency, date_format, cross_summary_aggregation, mark_for_total, sql_aggregation, subtotal)
		SELECT TOP 1 rpt.report_page_tablix_id tablix_id, rd.report_dataset_id dataset_id, dsc.data_source_column_id column_id,1 placement, 1 column_order,NULL aggregation, NULL functions, 'Destination Subbook Id' [alias], 1 sortable, NULL rounding, NULL thousand_seperation, 'Tahoma' font, '8' font_size, '0,0,0' font_style, 'Left' text_align, '#000000' text_color, '#ffffff' background, NULL default_sort_order, NULL sort_direction, 0 custom_field, 0 render_as,-1 column_template,NULL negative_mark,NULL currency,NULL date_format,-1 cross_summary_aggregation,NULL mark_for_total,NULL sql_aggregation,NULL subtotal
			
		FROM sys.objects o
		INNER JOIN report_page_tablix rpt 
			ON rpt.[name] = 'position formula_tablix'
		INNER JOIN report_page rpage 
			ON rpage.report_page_id = rpt.page_id 
			AND rpage.[name] = 'Book Balancing'
		INNER JOIN report r 
			ON r.report_id = rpage.report_id
			AND r.[name] = 'Book Balancing'
		INNER JOIN report_dataset rd 
			ON rd.report_id = r.report_id AND rd.[alias] = 'pf' 	
		INNER JOIN data_source ds 
			ON ISNULL(NULLIF(ds.report_id, 0), r.report_id) = r.report_id	AND ds.[name] = 'position_formula' 	
		INNER JOIN data_source_column dsc 
			ON dsc.source_id = ds.data_source_id AND dsc.[name] = 'destination_subbook_id' 
		INSERT INTO report_tablix_column(tablix_id, dataset_id, column_id, placement, column_order, aggregation
					, functions, [alias], sortable, rounding, thousand_seperation, font
					, font_size, font_style, text_align, text_color, background, default_sort_order
					, default_sort_direction, custom_field, render_as, column_template, negative_mark, currency, date_format, cross_summary_aggregation, mark_for_total, sql_aggregation, subtotal)
		SELECT TOP 1 rpt.report_page_tablix_id tablix_id, rd.report_dataset_id dataset_id, dsc.data_source_column_id column_id,1 placement, 5 column_order,NULL aggregation, NULL functions, 'Location ID' [alias], 1 sortable, NULL rounding, NULL thousand_seperation, 'Tahoma' font, '8' font_size, '0,0,0' font_style, 'Left' text_align, '#000000' text_color, '#ffffff' background, NULL default_sort_order, NULL sort_direction, 0 custom_field, 0 render_as,-1 column_template,NULL negative_mark,NULL currency,NULL date_format,-1 cross_summary_aggregation,NULL mark_for_total,NULL sql_aggregation,NULL subtotal
			
		FROM sys.objects o
		INNER JOIN report_page_tablix rpt 
			ON rpt.[name] = 'position formula_tablix'
		INNER JOIN report_page rpage 
			ON rpage.report_page_id = rpt.page_id 
			AND rpage.[name] = 'Book Balancing'
		INNER JOIN report r 
			ON r.report_id = rpage.report_id
			AND r.[name] = 'Book Balancing'
		INNER JOIN report_dataset rd 
			ON rd.report_id = r.report_id AND rd.[alias] = 'pf' 	
		INNER JOIN data_source ds 
			ON ISNULL(NULLIF(ds.report_id, 0), r.report_id) = r.report_id	AND ds.[name] = 'position_formula' 	
		INNER JOIN data_source_column dsc 
			ON dsc.source_id = ds.data_source_id AND dsc.[name] = 'location_id' 
		INSERT INTO report_tablix_column(tablix_id, dataset_id, column_id, placement, column_order, aggregation
					, functions, [alias], sortable, rounding, thousand_seperation, font
					, font_size, font_style, text_align, text_color, background, default_sort_order
					, default_sort_direction, custom_field, render_as, column_template, negative_mark, currency, date_format, cross_summary_aggregation, mark_for_total, sql_aggregation, subtotal)
		SELECT TOP 1 rpt.report_page_tablix_id tablix_id, rd.report_dataset_id dataset_id, dsc.data_source_column_id column_id,1 placement, 3 column_order,NULL aggregation, NULL functions, 'Term Start' [alias], 1 sortable, NULL rounding, NULL thousand_seperation, 'Tahoma' font, '8' font_size, '0,0,0' font_style, 'Left' text_align, '#000000' text_color, '#ffffff' background, NULL default_sort_order, NULL sort_direction, 0 custom_field, 4 render_as,-1 column_template,NULL negative_mark,NULL currency,0 date_format,-1 cross_summary_aggregation,NULL mark_for_total,NULL sql_aggregation,NULL subtotal
			
		FROM sys.objects o
		INNER JOIN report_page_tablix rpt 
			ON rpt.[name] = 'position formula_tablix'
		INNER JOIN report_page rpage 
			ON rpage.report_page_id = rpt.page_id 
			AND rpage.[name] = 'Book Balancing'
		INNER JOIN report r 
			ON r.report_id = rpage.report_id
			AND r.[name] = 'Book Balancing'
		INNER JOIN report_dataset rd 
			ON rd.report_id = r.report_id AND rd.[alias] = 'pf' 	
		INNER JOIN data_source ds 
			ON ISNULL(NULLIF(ds.report_id, 0), r.report_id) = r.report_id	AND ds.[name] = 'position_formula' 	
		INNER JOIN data_source_column dsc 
			ON dsc.source_id = ds.data_source_id AND dsc.[name] = 'term_start' 
		INSERT INTO report_tablix_column(tablix_id, dataset_id, column_id, placement, column_order, aggregation
					, functions, [alias], sortable, rounding, thousand_seperation, font
					, font_size, font_style, text_align, text_color, background, default_sort_order
					, default_sort_direction, custom_field, render_as, column_template, negative_mark, currency, date_format, cross_summary_aggregation, mark_for_total, sql_aggregation, subtotal)
		SELECT TOP 1 rpt.report_page_tablix_id tablix_id, rd.report_dataset_id dataset_id, dsc.data_source_column_id column_id,1 placement, 4 column_order,NULL aggregation, NULL functions, 'Term End' [alias], 1 sortable, NULL rounding, NULL thousand_seperation, 'Tahoma' font, '8' font_size, '0,0,0' font_style, 'Left' text_align, '#000000' text_color, '#ffffff' background, NULL default_sort_order, NULL sort_direction, 0 custom_field, 4 render_as,-1 column_template,NULL negative_mark,NULL currency,0 date_format,-1 cross_summary_aggregation,NULL mark_for_total,NULL sql_aggregation,NULL subtotal
			
		FROM sys.objects o
		INNER JOIN report_page_tablix rpt 
			ON rpt.[name] = 'position formula_tablix'
		INNER JOIN report_page rpage 
			ON rpage.report_page_id = rpt.page_id 
			AND rpage.[name] = 'Book Balancing'
		INNER JOIN report r 
			ON r.report_id = rpage.report_id
			AND r.[name] = 'Book Balancing'
		INNER JOIN report_dataset rd 
			ON rd.report_id = r.report_id AND rd.[alias] = 'pf' 	
		INNER JOIN data_source ds 
			ON ISNULL(NULLIF(ds.report_id, 0), r.report_id) = r.report_id	AND ds.[name] = 'position_formula' 	
		INNER JOIN data_source_column dsc 
			ON dsc.source_id = ds.data_source_id AND dsc.[name] = 'term_end' 
		INSERT INTO report_tablix_column(tablix_id, dataset_id, column_id, placement, column_order, aggregation
					, functions, [alias], sortable, rounding, thousand_seperation, font
					, font_size, font_style, text_align, text_color, background, default_sort_order
					, default_sort_direction, custom_field, render_as, column_template, negative_mark, currency, date_format, cross_summary_aggregation, mark_for_total, sql_aggregation, subtotal)
		SELECT TOP 1 rpt.report_page_tablix_id tablix_id, rd.report_dataset_id dataset_id, dsc.data_source_column_id column_id,1 placement, 2 column_order,NULL aggregation, NULL functions, 'Distination Deal' [alias], 1 sortable, NULL rounding, NULL thousand_seperation, 'Tahoma' font, '8' font_size, '0,0,0' font_style, 'Left' text_align, '#000000' text_color, '#ffffff' background, NULL default_sort_order, NULL sort_direction, 0 custom_field, 0 render_as,-1 column_template,NULL negative_mark,NULL currency,NULL date_format,-1 cross_summary_aggregation,NULL mark_for_total,NULL sql_aggregation,NULL subtotal
			
		FROM sys.objects o
		INNER JOIN report_page_tablix rpt 
			ON rpt.[name] = 'position formula_tablix'
		INNER JOIN report_page rpage 
			ON rpage.report_page_id = rpt.page_id 
			AND rpage.[name] = 'Book Balancing'
		INNER JOIN report r 
			ON r.report_id = rpage.report_id
			AND r.[name] = 'Book Balancing'
		INNER JOIN report_dataset rd 
			ON rd.report_id = r.report_id AND rd.[alias] = 'pf' 	
		INNER JOIN data_source ds 
			ON ISNULL(NULLIF(ds.report_id, 0), r.report_id) = r.report_id	AND ds.[name] = 'position_formula' 	
		INNER JOIN data_source_column dsc 
			ON dsc.source_id = ds.data_source_id AND dsc.[name] = 'distination_deal'  INSERT INTO report_tablix_header(tablix_id, column_id, font, font_size, font_style, text_align, text_color, background, report_tablix_column_id)
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
			ON  rpt.[name] = 'position formula_tablix'
		INNER JOIN report_page rpage 
			ON  rpage.report_page_id = rpt.page_id 
		AND rpage.[name] = 'Book Balancing'
		INNER JOIN report r 
			ON  r.report_id = rpage.report_id 
			AND r.[name] = 'Book Balancing'
		INNER JOIN data_source ds 
			ON ISNULL(NULLIF(ds.report_id, 0), r.report_id) = r.report_id	AND ds.[name] = 'position_formula' 	
		INNER JOIN data_source_column dsc 
			ON dsc.source_id = ds.data_source_id AND dsc.[name] = 'location_id' 
		INNER JOIN report_tablix_column rtc 
			on rtc.tablix_id = rpt.report_page_tablix_id
			--AND rtc.column_id = dsc.data_source_column_id  --This did not handle custom column, got duplicate custom columns during export
			AND rtc.alias = 'Location ID' --Added to handle custom column. Assumption: alias is unique and NOT NULL
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
			ON  rpt.[name] = 'position formula_tablix'
		INNER JOIN report_page rpage 
			ON  rpage.report_page_id = rpt.page_id 
		AND rpage.[name] = 'Book Balancing'
		INNER JOIN report r 
			ON  r.report_id = rpage.report_id 
			AND r.[name] = 'Book Balancing'
		INNER JOIN data_source ds 
			ON ISNULL(NULLIF(ds.report_id, 0), r.report_id) = r.report_id	AND ds.[name] = 'position_formula' 	
		INNER JOIN data_source_column dsc 
			ON dsc.source_id = ds.data_source_id AND dsc.[name] = 'destination_subbook_id' 
		INNER JOIN report_tablix_column rtc 
			on rtc.tablix_id = rpt.report_page_tablix_id
			--AND rtc.column_id = dsc.data_source_column_id  --This did not handle custom column, got duplicate custom columns during export
			AND rtc.alias = 'Destination Subbook Id' --Added to handle custom column. Assumption: alias is unique and NOT NULL
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
			ON  rpt.[name] = 'position formula_tablix'
		INNER JOIN report_page rpage 
			ON  rpage.report_page_id = rpt.page_id 
		AND rpage.[name] = 'Book Balancing'
		INNER JOIN report r 
			ON  r.report_id = rpage.report_id 
			AND r.[name] = 'Book Balancing'
		INNER JOIN data_source ds 
			ON ISNULL(NULLIF(ds.report_id, 0), r.report_id) = r.report_id	AND ds.[name] = 'position_formula' 	
		INNER JOIN data_source_column dsc 
			ON dsc.source_id = ds.data_source_id AND dsc.[name] = 'source_subbook_id' 
		INNER JOIN report_tablix_column rtc 
			on rtc.tablix_id = rpt.report_page_tablix_id
			--AND rtc.column_id = dsc.data_source_column_id  --This did not handle custom column, got duplicate custom columns during export
			AND rtc.alias = 'Source Subbook Id' --Added to handle custom column. Assumption: alias is unique and NOT NULL
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
			ON  rpt.[name] = 'position formula_tablix'
		INNER JOIN report_page rpage 
			ON  rpage.report_page_id = rpt.page_id 
		AND rpage.[name] = 'Book Balancing'
		INNER JOIN report r 
			ON  r.report_id = rpage.report_id 
			AND r.[name] = 'Book Balancing'
		INNER JOIN data_source ds 
			ON ISNULL(NULLIF(ds.report_id, 0), r.report_id) = r.report_id	AND ds.[name] = 'position_formula' 	
		INNER JOIN data_source_column dsc 
			ON dsc.source_id = ds.data_source_id AND dsc.[name] = 'term_end' 
		INNER JOIN report_tablix_column rtc 
			on rtc.tablix_id = rpt.report_page_tablix_id
			--AND rtc.column_id = dsc.data_source_column_id  --This did not handle custom column, got duplicate custom columns during export
			AND rtc.alias = 'Term End' --Added to handle custom column. Assumption: alias is unique and NOT NULL
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
			ON  rpt.[name] = 'position formula_tablix'
		INNER JOIN report_page rpage 
			ON  rpage.report_page_id = rpt.page_id 
		AND rpage.[name] = 'Book Balancing'
		INNER JOIN report r 
			ON  r.report_id = rpage.report_id 
			AND r.[name] = 'Book Balancing'
		INNER JOIN data_source ds 
			ON ISNULL(NULLIF(ds.report_id, 0), r.report_id) = r.report_id	AND ds.[name] = 'position_formula' 	
		INNER JOIN data_source_column dsc 
			ON dsc.source_id = ds.data_source_id AND dsc.[name] = 'term_start' 
		INNER JOIN report_tablix_column rtc 
			on rtc.tablix_id = rpt.report_page_tablix_id
			--AND rtc.column_id = dsc.data_source_column_id  --This did not handle custom column, got duplicate custom columns during export
			AND rtc.alias = 'Term Start' --Added to handle custom column. Assumption: alias is unique and NOT NULL
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
			ON  rpt.[name] = 'position formula_tablix'
		INNER JOIN report_page rpage 
			ON  rpage.report_page_id = rpt.page_id 
		AND rpage.[name] = 'Book Balancing'
		INNER JOIN report r 
			ON  r.report_id = rpage.report_id 
			AND r.[name] = 'Book Balancing'
		INNER JOIN data_source ds 
			ON ISNULL(NULLIF(ds.report_id, 0), r.report_id) = r.report_id	AND ds.[name] = 'position_formula' 	
		INNER JOIN data_source_column dsc 
			ON dsc.source_id = ds.data_source_id AND dsc.[name] = 'distination_deal' 
		INNER JOIN report_tablix_column rtc 
			on rtc.tablix_id = rpt.report_page_tablix_id
			--AND rtc.column_id = dsc.data_source_column_id  --This did not handle custom column, got duplicate custom columns during export
			AND rtc.alias = 'Distination Deal' --Added to handle custom column. Assumption: alias is unique and NOT NULL
	
		--RETAIN APPLICATION FILTER DETAILS START (PART2)
		update pm
		set inserted_paramset_id = rp.report_paramset_id
		from #paramset_map pm
		inner join report_paramset rp on rp.paramset_hash = pm.paramset_hash
		
		update f set f.report_id = pm.inserted_paramset_id
		from application_ui_filter f
		inner join #paramset_map pm on pm.deleted_paramset_id = isnull(f.report_id, -1)
		where f.application_function_id is null
	
		delete fd
		--select *
		from application_ui_filter_details fd
		inner join application_ui_filter f on f.application_ui_filter_id = fd.application_ui_filter_id
		inner join #paramset_map pm on pm.inserted_paramset_id = isnull(f.report_id, -1)
		where abs(fd.report_column_id) not in (
			select distinct rp.column_id
			from report_param rp
			inner join report_dataset_paramset rdp on rdp.report_dataset_paramset_id = rp.dataset_paramset_id
			inner join report_paramset rpm on rpm.report_paramset_id = rdp.paramset_id
			where rpm.report_paramset_id = f.report_id
		)
		--RETAIN APPLICATION FILTER DETAILS END (PART2)
	COMMIT 

END TRY
BEGIN CATCH
	IF @@TRANCOUNT > 0
		ROLLBACK TRAN;
		
	DECLARE @error_message VARCHAR(MAX) = ERROR_MESSAGE()
	RAISERROR(@error_message,16,1)
END CATCH