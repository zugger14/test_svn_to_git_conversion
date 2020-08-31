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
		IF EXISTS (SELECT 1 FROM dbo.report WHERE report_hash='8CC7F1A1_58CB_48DD_A078_CFBB8678FDA5')
		BEGIN
			declare @report_id_to_delete int
			select @report_id_to_delete = report_id from report where report_hash = '8CC7F1A1_58CB_48DD_A078_CFBB8678FDA5'

			insert into #paramset_map(deleted_paramset_id, paramset_hash)
			select rp.report_paramset_id, rp.paramset_hash
			from report_paramset rp
			inner join report_page pg on pg.report_page_id = rp.page_id
			where pg.report_id = @report_id_to_delete

			EXEC spa_rfx_report @flag='d', @report_id=@report_id_to_delete, @retain_privilege=1, @process_id=NULL

		
		END
		--RETAIN APPLICATION FILTER DETAILS END (PART1)
		
		declare @report_copy_name varchar(200)
		
		set @report_copy_name = isnull(@report_copy_name, 'Copy of ' + 'RECs Obligation Volume Update')
		
		INSERT INTO report ([name], [owner], is_system, is_excel, is_mobile, report_hash, [description], category_id)
		SELECT TOP 1 'RECs Obligation Volume Update' [name], 'dev_admin' [owner], 0 is_system, 0 is_excel, 0 is_mobile, '8CC7F1A1_58CB_48DD_A078_CFBB8678FDA5' report_hash, '' [description], CAST(sdv_cat.value_id AS VARCHAR(10)) category_id
		FROM sys.objects o
		LEFT JOIN static_data_value sdv_cat ON sdv_cat.code = 'Processes' AND sdv_cat.type_id = 10008 
		SET @report_id_dest = SCOPE_IDENTITY()
		
		BEGIN TRY
		BEGIN TRAN
	
	declare @new_ds_alias varchar(10) = 'rovu1'
	/** IF DATA SOURCE ALIAS ALREADY EXISTS ON DESTINATION, RAISE ERROR **/
	if exists(select top 1 1 from data_source where alias = 'rovu1' and name <> 'RECs Obligation Volume Update')
	begin
		select top 1 @new_ds_alias = 'rovu1' + cast(s.n as varchar(5))
		from seq s
		left join data_source ds on ds.alias = 'rovu1' + cast(s.n as varchar(5))
		where ds.data_source_id is null
			and s.n < 10

		--RAISERROR ('Datasource alias already exists on system.', 16, 1);
	end

	DECLARE @report_id_data_source_dest INT 
	
	SELECT @report_id_data_source_dest = report_id
	FROM report r
	WHERE r.[name] = 'RECs Obligation Volume Update'
	IF NOT EXISTS (SELECT 1 
	           FROM data_source 
	           WHERE [name] = 'RECs Obligation Volume Update'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	AND NOT EXISTS (SELECT 1 FROM map_function_category WHERE [function_name] = 'RECs Obligation Volume Update' AND '106500' = '106501') 
	BEGIN
		INSERT INTO data_source([type_id], [name], [alias], [description], [tsql], report_id, system_defined,category)
		SELECT TOP 1 2 AS [type_id], 'RECs Obligation Volume Update' AS [name], @new_ds_alias AS ALIAS, NULL AS [description],null AS [tsql], @report_id_data_source_dest AS report_id,NULL AS [system_defined]
			,'106500' AS [category]
	END

	UPDATE data_source
	SET alias = @new_ds_alias, description = NULL
	, [tsql] = CAST('' AS VARCHAR(MAX)) + 'DECLARE @_as_of_date DATETIME = NULL
DECLARE @_jurisdiction VARCHAR(MAX) = NULL
DECLARE @_tier VARCHAR(MAX) = NULL
DECLARE @_sql VARCHAR(MAX) 
SET @_as_of_date = NULLIF(ISNULL(CAST(@_as_of_date AS VARCHAR(20)), NULLIF(''@as_of_date'', REPLACE(''@_as_of_date'', ''@_'', ''@''))), ''NULL'')
SET @_jurisdiction = NULLIF(ISNULL(@_jurisdiction, NULLIF(''@jurisdiction'', REPLACE(''@_jurisdiction'', ''@_'', ''@''))), ''NULL'')
SET @_tier = NULLIF(ISNULL(@_tier, NULLIF(''@tier'', REPLACE(''@_tier'', ''@_'', ''@''))), ''NULL'')
IF @_as_of_date IS NULL
    SET @_as_of_date = CAST(GETDATE() AS VARCHAR(20))
---get year break according to state_value_id
 IF OBJECT_ID(''tempdb..#temp_state_req_data_splitted_year'') is not null
	DROP TABLE #temp_state_req_data_splitted_year
; WITH  CTE AS
        (
        SELECT  state_value_id, MIN(from_year) from_year, MAX(to_year) to_year, MIN(from_year) AS yr
		FROM state_rec_requirement_data srrd
		GROUP BY state_value_id
        UNION ALL
        SELECT  state_value_id, from_year, to_year, yr + 1
        FROM CTE
        WHERE yr < to_year    
	)
SELECT  state_value_id, yr, from_year, to_year
INTO #temp_state_req_data_splitted_year
FROM CTE
--get data from state_rec_requirement_data and state_rec_requirement_data 
IF OBJECT_ID(''tempdb..#temp_state_req_data_splitted_target'') is not null
	DROP TABLE #temp_state_req_data_splitted_target
CREATE TABLE #temp_state_req_data_splitted_target(
		state_value_id INT,
		tier_type INT,
		min_from_yr DATE,
		max_to_yr DATE,
		yr INT,
		from_yr DATE,
		to_yr DATE,
		state_rec_requirement_data_id INT,
		min_target FLOAT
)
SET @_sql = ''INSERT INTO #temp_state_req_data_splitted_target(
					state_value_id,
					tier_type,
					min_from_yr,
					max_to_yr,
					yr,
					from_yr,
					to_yr,
					state_rec_requirement_data_id,
					min_target
			 ) 
			 SELECT tmp_srdsy.state_value_id
				  , srrde.tier_type
				  , CAST(tmp_srdsy.from_year AS VARCHAR(4)) + ''''-'''' + CAST(sp.calendar_from_month AS VARCHAR(2)) + ''''-1''''  min_from_yr
				  , EOMONTH(CAST(tmp_srdsy.to_year AS VARCHAR(4)) + ''''-'''' + CAST(sp.calendar_to_month AS VARCHAR(2)) + ''''-1'''') max_to_yr
				  , tmp_srdsy.yr
				  , CAST(CASE WHEN ISNULL(sp.current_next_year, ''''c'''') = ''''c'''' THEN tmp_srdsy.yr ELSE tmp_srdsy.yr - 1 END AS VARCHAR(4)) + ''''-'''' + CAST(sp.calendar_from_month AS VARCHAR(2)) + ''''-1'''' from_yr
				  , EOMONTH(CAST(CASE WHEN ISNULL(sp.current_next_year, ''''c'''') = ''''c''''  AND sp.calendar_from_month <> 1 THEN tmp_srdsy.yr + 1 ELSE tmp_srdsy.yr END AS VARCHAR(4)) + ''''-'''' + CAST(sp.calendar_to_month AS VARCHAR(2)) + ''''-1'''') to_yr
				  , srrd.state_rec_requirement_data_id
				  , srrde.min_target			 
			 FROM #temp_state_req_data_splitted_year tmp_srdsy
			 INNER JOIN state_properties sp
			 	ON  sp.state_value_id = tmp_srdsy.state_value_id
			 INNER JOIN state_rec_requirement_data srrd
			 	ON tmp_srdsy.state_value_id  = srrd.state_value_id
			 	AND CASE WHEN ISNULL(sp.current_next_year, ''''c'''') = ''''c'''' THEN tmp_srdsy.yr ELSE tmp_srdsy.yr END BETWEEN srrd.from_year and srrd.to_year
			 INNER JOIN state_rec_requirement_detail srrde
			 	ON srrde.state_value_id  = srrd.state_value_id
			 	AND srrde.state_rec_requirement_data_id  = srrd.state_rec_requirement_data_id
			 WHERE 1 = 1''
			 IF @_jurisdiction IS NOT NULL
				SET @_sql += '' AND tmp_srdsy.state_value_id IN ('' + @_jurisdiction + '')''				 
			 IF @_tier IS NOT NULL
				SET @_sql += '' AND srrde.tier_type IN ('' + @_tier + '')''
			 SET @_sql += '' ORDER BY tmp_srdsy.state_value_id''
EXEC (@_sql)
--get energy deals
IF OBJECT_ID(''tempdb..#temp_energy_deals_committed'') is not null
	DROP TABLE #temp_energy_deals_committed
CREATE TABLE #temp_energy_deals_committed (
			 state_value_id INT, 
			 tier_value_id  INT,
			 total_volume   FLOAT, 
			 term_start		DATETIME, 
			 term_end		DATETIME, 
			 from_yr		DATE,
			 to_yr			DATE,
			 target_volume  FLOAT,
			 min_target		FLOAT
)
SET @_sql = '' INSERT INTO #temp_energy_deals_committed(
					  state_value_id,
					  tier_value_id,
					  total_volume, 
					  term_start,	
					  term_end,	
					  from_yr,	
					  to_yr,		
					  target_volume,
					  min_target
			  )
			  SELECT tmp_srdst.state_value_id state_value_id , 
			  	     tmp_srdst.tier_type tier_value_id,
			  	     SUM(total_volume) total_volume, 
			  	     sdd.term_start, 
			  	     sdd.term_end, 
			  	     MIN(tmp_srdst.from_yr) from_yr,
			  	     MAX(tmp_srdst.to_yr) to_yr,
			  	     SUM(sdd.total_volume) * MAX(tmp_srdst.min_target) target_volume,
			  	     MAX(tmp_srdst.min_target) min_target	   
			  --INTO #temp_energy_deals_committed
			  FROM source_deal_detail  sdd
			  INNER JOIN source_deal_header sdh
			  	  ON sdd.source_deal_header_id = sdh.source_deal_header_id
			  INNER JOIN source_minor_location sml
			  	  ON sdd.location_id = sml.source_minor_location_id
			  INNER JOIN udt_compliance_zone_mapping udt_c
			  	  ON udt_c.zone = sml.location_id
			  INNER JOIN static_data_value sdv
			  	  ON sdv.code = udt_c.state_compliance
			  INNER JOIN #temp_state_req_data_splitted_target tmp_srdst
			  	  ON tmp_srdst.state_value_id = sdv.value_id
			  OUTER APPLY ( SELECT ssbm.book_deal_type_map_id
			  				FROM portfolio_hierarchy psub
			  				INNER JOIN portfolio_hierarchy pstr
			    			    ON pstr.parent_entity_id = psub.entity_id
			  				INNER JOIN portfolio_hierarchy pbook
			    			    ON pbook.parent_entity_id = pstr.entity_id
			  				INNER JOIN source_system_book_map ssbm
			    			    ON ssbm.fas_book_id = pbook.entity_id
			  				WHERE psub.entity_name = ''''Retail - Power''''
			    			    AND pstr.entity_name = ''''Load''''
			    			    AND ssbm.logical_name LIKE ''''%committed%''''
			    			    AND ssbm.logical_name NOT LIKE ''''%Uncommitted%''''
			  				    AND ssbm.book_deal_type_map_id = sdh.sub_book
			  ) sub_book
			  WHERE sdd.term_start BETWEEN tmp_srdst.from_yr AND tmp_srdst.to_yr
			  	  AND sub_book.book_deal_type_map_id IS NOT NULL
				  --AND sdh.deal_id NOT LIKE ''''%LOSS''''
			  ''
			  IF @_as_of_date IS NOT NULL
				  SET @_sql += '' AND sdd.term_start >='''''' + CAST(@_as_of_date AS VARCHAR(20)) + ''''''''
			  SET @_sql += '' GROUP BY sdd.term_start, sdd.term_end, tmp_srdst.state_value_id , tmp_srdst.tier_type ''
EXEC(@_sql)
IF OBJECT_ID(''tempdb..#temp_energy_deals_uncommitted'') is not null
	DROP TABLE #temp_energy_deals_uncommitted
CREATE TABLE #temp_energy_deals_uncommitted (
			 state_value_id INT, 
			 tier_value_id  INT,
			 total_volume   FLOAT, 
			 term_start		DATETIME, 
			 term_end		DATETIME, 
			 from_yr		DATE,
			 to_yr			DATE,
			 target_volume  FLOAT,
			 min_target		FLOAT
)
SET @_sql = '' INSERT INTO #temp_energy_deals_uncommitted(
					 state_value_id,
					 tier_value_id,
					 total_volume, 
					 term_start,
					 term_end,	
					 from_yr,		
					 to_yr,		
					 target_volume ,
					 min_target
			  )
			  SELECT tmp_srdst.state_value_id state_value_id , 
				     tmp_srdst.tier_type tier_value_id,
				     SUM(total_volume) total_volume, 
				     sdd.term_start, 
				     sdd.term_end, 
				     MIN(tmp_srdst.from_yr) from_yr,
				     MAX(tmp_srdst.to_yr) to_yr,
				     SUM(sdd.total_volume) * MAX(tmp_srdst.min_target) target_volume,
				     MAX(tmp_srdst.min_target) min_target	   			  
			  FROM source_deal_detail  sdd
			  INNER JOIN source_deal_header sdh
			  	ON sdd.source_deal_header_id = sdh.source_deal_header_id
			  INNER JOIN source_minor_location sml
			  	ON sdd.location_id = sml.source_minor_location_id
			  INNER JOIN udt_compliance_zone_mapping udt_c
			  	ON udt_c.zone = sml.location_id
			  INNER JOIN static_data_value sdv
			  	ON sdv.code = udt_c.state_compliance
			  INNER JOIN #temp_state_req_data_splitted_target tmp_srdst
			  	ON tmp_srdst.state_value_id = sdv.value_id
			  OUTER APPLY ( SELECT ssbm.book_deal_type_map_id
			  			  FROM portfolio_hierarchy psub
			  			  INNER JOIN portfolio_hierarchy pstr
			    				  ON pstr.parent_entity_id = psub.entity_id
			  			  INNER JOIN portfolio_hierarchy pbook
			    				  ON pbook.parent_entity_id = pstr.entity_id
			  			  INNER JOIN source_system_book_map ssbm
			    				  ON ssbm.fas_book_id = pbook.entity_id
			  			  WHERE psub.entity_name = ''''Retail - Power'''' 
			    				  AND pstr.entity_name = ''''Load''''
			    				  AND ssbm.logical_name LIKE ''''%Uncommitted%''''			  	  
			  				  AND ssbm.book_deal_type_map_id = sdh.sub_book
			  ) sub_book
			  WHERE sdd.term_start BETWEEN tmp_srdst.from_yr AND tmp_srdst.to_yr
			  	AND sub_book.book_deal_type_map_id IS NOT NULL
				--AND sdh.deal_id NOT LIKE ''''%LOSS''''
			 ''
			  IF @_as_of_date IS NOT NULL
				  SET @_sql += '' AND sdd.term_start >='''''' + CAST(@_as_of_date AS VARCHAR(20)) + ''''''''
			  SET @_sql += '' GROUP BY sdd.term_start, sdd.term_end, tmp_srdst.state_value_id , tmp_srdst.tier_type ''
EXEC(@_sql) 
--rec deals
--committed
UPDATE sdd 
SET contractual_volume = ted.target_volume/100
FROM source_deal_header sdh
INNER JOIN #temp_energy_deals_committed ted
	ON ted.state_value_id = sdh.state_value_id
	AND ted.tier_value_id = sdh.tier_value_id
INNER JOIN source_deal_detail sdd
	ON sdd.source_deal_header_id = sdh.source_deal_header_id
	AND sdd.term_start = ted.term_start
	AND sdd.term_end = ted.term_end
INNER JOIN source_system_book_map ssbm
	ON ssbm.book_deal_type_map_id = sdh.sub_book 	
WHERE sdh.deal_id NOT LIKE ''%Uncommitted%''
	AND ssbm.logical_name in (
		''IL RPS''
		,''MD RPS''
		,''MI RPS''
		,''NJ RPS''
		,''OH RPS''
		,''PA RPS''
	)
--uncommitted
UPDATE sdd 
SET contractual_volume = ted.target_volume/100
FROM source_deal_header sdh
INNER JOIN #temp_energy_deals_uncommitted ted
	ON ted.state_value_id = sdh.state_value_id
	AND ted.tier_value_id = sdh.tier_value_id
INNER JOIN source_deal_detail sdd
	ON sdd.source_deal_header_id = sdh.source_deal_header_id
	AND sdd.term_start = ted.term_start
	AND sdd.term_end = ted.term_end
INNER JOIN source_system_book_map ssbm
	ON ssbm.book_deal_type_map_id = sdh.sub_book 	
WHERE sdh.deal_id LIKE ''%Uncommitted%''
	AND ssbm.logical_name in (
		''IL RPS''
		,''MD RPS''
		,''MI RPS''
		,''NJ RPS''
		,''OH RPS''
		,''PA RPS''
	)
--Updated deal_volume with best available volume	
--Committed
UPDATE sdd 
SET deal_volume = COALESCE(sdd.actual_volume, sdd.schedule_volume, sdd.contractual_volume),
	volume_left = CASE WHEN volume_left IS NULL THEN 0 ELSE volume_left END
FROM source_deal_header sdh
INNER JOIN #temp_energy_deals_committed ted
	ON ted.state_value_id = sdh.state_value_id
	AND ted.tier_value_id = sdh.tier_value_id
INNER JOIN source_deal_detail sdd
	ON sdd.source_deal_header_id = sdh.source_deal_header_id
	AND sdd.term_start = ted.term_start
	AND sdd.term_end = ted.term_end
INNER JOIN source_deal_type sdt ON sdt.source_deal_type_id = sdh.source_deal_type_id
INNER JOIN source_system_book_map ssbm
	ON ssbm.book_deal_type_map_id = sdh.sub_book 	
WHERE ssbm.logical_name in (
		''IL RPS''
		,''MD RPS''
		,''MI RPS''
		,''NJ RPS''
		,''OH RPS''
		,''PA RPS''
	)
	AND sdh.is_environmental = ''y''

--UnCommitted
	UPDATE sdd 
SET deal_volume = COALESCE(sdd.actual_volume, sdd.schedule_volume, sdd.contractual_volume),
	volume_left = CASE WHEN volume_left IS NULL THEN 0 ELSE volume_left END
FROM source_deal_header sdh
INNER JOIN #temp_energy_deals_uncommitted ted
	ON ted.state_value_id = sdh.state_value_id
	AND ted.tier_value_id = sdh.tier_value_id
INNER JOIN source_deal_detail sdd
	ON sdd.source_deal_header_id = sdh.source_deal_header_id
	AND sdd.term_start = ted.term_start
	AND sdd.term_end = ted.term_end
INNER JOIN source_deal_type sdt ON sdt.source_deal_type_id = sdh.source_deal_type_id
INNER JOIN source_system_book_map ssbm
	ON ssbm.book_deal_type_map_id = sdh.sub_book 	
WHERE ssbm.logical_name in (
		''IL RPS''
		,''MD RPS''
		,''MI RPS''
		,''NJ RPS''
		,''OH RPS''
		,''PA RPS''
	)
	AND sdh.is_environmental = ''y''


IF OBJECT_ID(''tempdb..#tmp_result'') IS NOT NULL
	DROP TABLE #tmp_result
CREATE TABLE #tmp_result (
	ErrorCode VARCHAR(200) COLLATE DATABASE_DEFAULT ,
	Module VARCHAR(200) COLLATE DATABASE_DEFAULT ,
	Area VARCHAR(200) COLLATE DATABASE_DEFAULT ,
	Status VARCHAR(200) COLLATE DATABASE_DEFAULT ,
	Message VARCHAR(1000) COLLATE DATABASE_DEFAULT ,
	Recommendation VARCHAR(200) COLLATE DATABASE_DEFAULT 
)
INSERT INTO #tmp_result (ErrorCode, Module, Area, Status, Message, Recommendation)
EXEC spa_ErrorHandler 0, ''RECs Obligation Volume Update'', 
 				''RECs Obligation Volume Update'', ''Success'', 
 				''Changes have been saved successfully.'', ''''
SELECT @_as_of_date [as_of_date],
	   @_jurisdiction [Jurisdiction],
	   @_tier [Tier],
	   [ErrorCode],
	   [Module],
	   [Area],
	   [Status],
	   [Message],
	   [Recommendation]
--[__batch_report__] 
FROM #tmp_result
WHERE 1=1
', report_id = @report_id_data_source_dest,
	system_defined = NULL
	,category = '106500' 
	WHERE [name] = 'RECs Obligation Volume Update'
		AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1)
		
	
	IF OBJECT_ID('tempdb..#data_source_column', 'U') IS NOT NULL
		DROP TABLE #data_source_column	
	CREATE TABLE #data_source_column(column_id INT)	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'RECs Obligation Volume Update'
	            AND dsc.name =  'Area'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Area'
			   , reqd_param = NULL, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 0, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'RECs Obligation Volume Update'
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
		INNER JOIN data_source ds ON ds.[name] = 'RECs Obligation Volume Update'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'RECs Obligation Volume Update'
	            AND dsc.name =  'ErrorCode'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Errorcode'
			   , reqd_param = NULL, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 0, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'RECs Obligation Volume Update'
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
		INNER JOIN data_source ds ON ds.[name] = 'RECs Obligation Volume Update'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'RECs Obligation Volume Update'
	            AND dsc.name =  'Message'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Message'
			   , reqd_param = NULL, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 0, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'RECs Obligation Volume Update'
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
		INNER JOIN data_source ds ON ds.[name] = 'RECs Obligation Volume Update'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'RECs Obligation Volume Update'
	            AND dsc.name =  'Module'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Module'
			   , reqd_param = NULL, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 0, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'RECs Obligation Volume Update'
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
		INNER JOIN data_source ds ON ds.[name] = 'RECs Obligation Volume Update'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'RECs Obligation Volume Update'
	            AND dsc.name =  'Recommendation'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Recommendation'
			   , reqd_param = NULL, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 0, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'RECs Obligation Volume Update'
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
		INNER JOIN data_source ds ON ds.[name] = 'RECs Obligation Volume Update'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'RECs Obligation Volume Update'
	            AND dsc.name =  'Status'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Status'
			   , reqd_param = NULL, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 0, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'RECs Obligation Volume Update'
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
		INNER JOIN data_source ds ON ds.[name] = 'RECs Obligation Volume Update'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'RECs Obligation Volume Update'
	            AND dsc.name =  'Jurisdiction'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Jurisdiction'
			   , reqd_param = NULL, widget_id = 9, datatype_id = 5, param_data_source = 'SELECT DISTINCT sdv.value_id AS [id], sdv.code AS [code] ' + CHAR(10) + 'FROM static_data_value sdv' + CHAR(10) + 'INNER JOIN static_data_type sdt' + CHAR(10) + '' + CHAR(9) + 'ON sdv.type_id = sdt.type_id' + CHAR(10) + 'INNER JOIN state_properties_details spd' + CHAR(10) + '' + CHAR(9) + 'ON spd.state_value_id = sdv.value_id' + CHAR(10) + 'WHERE sdt.type_name = ''Compliance Jurisdictions''' + CHAR(10) + '' + CHAR(9) + 'AND sdv.code IN (''IL'', ''MD'', ''MI'', ''NJ'', ''OH'', ''PA'')', param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 0, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'RECs Obligation Volume Update'
			AND dsc.name =  'Jurisdiction'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'Jurisdiction' AS [name], 'Jurisdiction' AS ALIAS, NULL AS reqd_param, 9 AS widget_id, 5 AS datatype_id, 'SELECT DISTINCT sdv.value_id AS [id], sdv.code AS [code] ' + CHAR(10) + 'FROM static_data_value sdv' + CHAR(10) + 'INNER JOIN static_data_type sdt' + CHAR(10) + '' + CHAR(9) + 'ON sdv.type_id = sdt.type_id' + CHAR(10) + 'INNER JOIN state_properties_details spd' + CHAR(10) + '' + CHAR(9) + 'ON spd.state_value_id = sdv.value_id' + CHAR(10) + 'WHERE sdt.type_name = ''Compliance Jurisdictions''' + CHAR(10) + '' + CHAR(9) + 'AND sdv.code IN (''IL'', ''MD'', ''MI'', ''NJ'', ''OH'', ''PA'')' AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'RECs Obligation Volume Update'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'RECs Obligation Volume Update'
	            AND dsc.name =  'Tier'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Tier'
			   , reqd_param = NULL, widget_id = 9, datatype_id = 5, param_data_source = 'SELECT DISTINCT sdv.value_id AS [id], sdv.code AS [code] ' + CHAR(10) + 'FROM static_data_value sdv' + CHAR(10) + 'INNER JOIN static_data_type sdt' + CHAR(10) + '' + CHAR(9) + 'ON sdv.type_id = sdt.type_id' + CHAR(10) + 'INNER JOIN state_properties_details spd' + CHAR(10) + '' + CHAR(9) + 'ON spd.tier_id = sdv.value_id' + CHAR(10) + 'WHERE sdt.type_name = ''Tier''', param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 0, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'RECs Obligation Volume Update'
			AND dsc.name =  'Tier'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'Tier' AS [name], 'Tier' AS ALIAS, NULL AS reqd_param, 9 AS widget_id, 5 AS datatype_id, 'SELECT DISTINCT sdv.value_id AS [id], sdv.code AS [code] ' + CHAR(10) + 'FROM static_data_value sdv' + CHAR(10) + 'INNER JOIN static_data_type sdt' + CHAR(10) + '' + CHAR(9) + 'ON sdv.type_id = sdt.type_id' + CHAR(10) + 'INNER JOIN state_properties_details spd' + CHAR(10) + '' + CHAR(9) + 'ON spd.tier_id = sdv.value_id' + CHAR(10) + 'WHERE sdt.type_name = ''Tier''' AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'RECs Obligation Volume Update'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'RECs Obligation Volume Update'
	            AND dsc.name =  'as_of_date'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'As of Date'
			   , reqd_param = NULL, widget_id = 6, datatype_id = 2, param_data_source = NULL, param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 4, key_column = 0, required_filter = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'RECs Obligation Volume Update'
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
		INNER JOIN data_source ds ON ds.[name] = 'RECs Obligation Volume Update'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	DELETE dsc
	FROM data_source_column dsc 
	INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		AND ds.[name] = 'RECs Obligation Volume Update'
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
		SELECT TOP 1 ds.data_source_id AS source_id, @report_id_dest AS report_id, 'rovu1' [alias], rd_root.report_dataset_id AS root_dataset_id,0 AS is_free_from, 'NULL' AS relationship_sql
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'RECs Obligation Volume Update'
			AND ISNULL(ds.report_id, @report_id_dest) = @report_id_dest
		LEFT JOIN report_dataset rd_root ON rd_root.[alias] = NULL
			AND rd_root.report_id = @report_id_dest		
		
	INSERT INTO report_page(report_id, [name], report_hash, width, height)
	SELECT @report_id_dest AS report_id, 'RECs Obligation Volume Update' [name], '8CC7F1A1_58CB_48DD_A078_CFBB8678FDA5' report_hash, 11.5 width,5.5 height
	
		INSERT INTO report_paramset(page_id, [name], paramset_hash, report_status_id, export_report_name, export_location, output_file_format, delimiter, xml_format, report_header, compress_file)
		SELECT TOP 1 rpage.report_page_id, 'RECs Obligation Volume Update', '79B25E35_81D0_4992_815E_10E80FDCF26D', 3,'','','.xlsx',',', 
		-100000,'n','n'	
		FROM sys.objects o
		INNER JOIN report_page rpage 
			on rpage.[name] = 'RECs Obligation Volume Update'
		INNER JOIN report r 
		ON r.report_id = rpage.report_id
			AND r.[name] = 'RECs Obligation Volume Update'
	
		INSERT INTO report_dataset_paramset(paramset_id, root_dataset_id, where_part, advance_mode)
		SELECT TOP 1 rp.report_paramset_id AS paramset_id, rd.report_dataset_id AS root_dataset_id, '(  rovu1.[Jurisdiction] = ''@Jurisdiction'' 
AND rovu1.[Tier] = ''@Tier'')' AS where_part, 0
		FROM sys.objects o
		INNER JOIN report_paramset rp 
			ON rp.[name] = 'RECs Obligation Volume Update'
		INNER JOIN report_page rpage 
			ON rpage.report_page_id = rp.page_id
			AND rpage.[name] = 'RECs Obligation Volume Update'
		INNER JOIN report r 
			ON r.report_id = rpage.report_id
			AND r.[name] = 'RECs Obligation Volume Update'
		INNER JOIN report_dataset rd 
			ON rd.report_id = @report_id_dest
			AND rd.[alias] = 'rovu1'
	
		INSERT INTO report_param(dataset_paramset_id, dataset_id, column_id, operator,
					initial_value, initial_value2, optional, hidden, logical_operator, param_order, param_depth, label)
		SELECT TOP 1 rdp.report_dataset_paramset_id AS dataset_paramset_id, rd.report_dataset_id AS dataset_id , dsc.data_source_column_id AS column_id, 1 AS operator, '' AS initial_value, '' AS initial_value2, 1 AS optional, 0 AS hidden,0 AS logical_operator, 1 AS param_order, 0 AS param_depth, NULL AS label
		FROM sys.objects o
		INNER JOIN report_paramset rp 
			ON rp.[name] = 'RECs Obligation Volume Update'
		INNER JOIN report_page rpage 
			ON rpage.report_page_id = rp.page_id
			AND rpage.[name] = 'RECs Obligation Volume Update'
		INNER JOIN report r ON r.report_id = rpage.report_id
			AND r.[name] = 'RECs Obligation Volume Update'
		INNER JOIN report_dataset rd_root 
			ON rd_root.report_id = @report_id_dest 
			AND rd_root.[alias] = 'rovu1'
		INNER JOIN report_dataset_paramset rdp 
			ON rdp.paramset_id = rp.report_paramset_id
			AND rdp.root_dataset_id = rd_root.report_dataset_id
		INNER JOIN report_dataset rd 
			ON rd.report_id = r.report_id
			AND rd.[alias] = 'rovu1'
		INNER JOIN data_source ds 
			ON ISNULL(NULLIF(ds.report_id, 0), r.report_id) = r.report_id	
			AND ds.[name] = 'RECs Obligation Volume Update' 
		INNER JOIN data_source_column dsc 
			ON dsc.source_id = ds.data_source_id
			AND dsc.[name] = 'Jurisdiction'	
	
		INSERT INTO report_param(dataset_paramset_id, dataset_id, column_id, operator,
					initial_value, initial_value2, optional, hidden, logical_operator, param_order, param_depth, label)
		SELECT TOP 1 rdp.report_dataset_paramset_id AS dataset_paramset_id, rd.report_dataset_id AS dataset_id , dsc.data_source_column_id AS column_id, 1 AS operator, '' AS initial_value, '' AS initial_value2, 1 AS optional, 0 AS hidden,1 AS logical_operator, 2 AS param_order, 0 AS param_depth, NULL AS label
		FROM sys.objects o
		INNER JOIN report_paramset rp 
			ON rp.[name] = 'RECs Obligation Volume Update'
		INNER JOIN report_page rpage 
			ON rpage.report_page_id = rp.page_id
			AND rpage.[name] = 'RECs Obligation Volume Update'
		INNER JOIN report r ON r.report_id = rpage.report_id
			AND r.[name] = 'RECs Obligation Volume Update'
		INNER JOIN report_dataset rd_root 
			ON rd_root.report_id = @report_id_dest 
			AND rd_root.[alias] = 'rovu1'
		INNER JOIN report_dataset_paramset rdp 
			ON rdp.paramset_id = rp.report_paramset_id
			AND rdp.root_dataset_id = rd_root.report_dataset_id
		INNER JOIN report_dataset rd 
			ON rd.report_id = r.report_id
			AND rd.[alias] = 'rovu1'
		INNER JOIN data_source ds 
			ON ISNULL(NULLIF(ds.report_id, 0), r.report_id) = r.report_id	
			AND ds.[name] = 'RECs Obligation Volume Update' 
		INNER JOIN data_source_column dsc 
			ON dsc.source_id = ds.data_source_id
			AND dsc.[name] = 'Tier'	
	
		INSERT INTO report_param(dataset_paramset_id, dataset_id, column_id, operator,
					initial_value, initial_value2, optional, hidden, logical_operator, param_order, param_depth, label)
		SELECT TOP 1 rdp.report_dataset_paramset_id AS dataset_paramset_id, rd.report_dataset_id AS dataset_id , dsc.data_source_column_id AS column_id, 1 AS operator, '' AS initial_value, '' AS initial_value2, 1 AS optional, 0 AS hidden,1 AS logical_operator, 0 AS param_order, 0 AS param_depth, NULL AS label
		FROM sys.objects o
		INNER JOIN report_paramset rp 
			ON rp.[name] = 'RECs Obligation Volume Update'
		INNER JOIN report_page rpage 
			ON rpage.report_page_id = rp.page_id
			AND rpage.[name] = 'RECs Obligation Volume Update'
		INNER JOIN report r ON r.report_id = rpage.report_id
			AND r.[name] = 'RECs Obligation Volume Update'
		INNER JOIN report_dataset rd_root 
			ON rd_root.report_id = @report_id_dest 
			AND rd_root.[alias] = 'rovu1'
		INNER JOIN report_dataset_paramset rdp 
			ON rdp.paramset_id = rp.report_paramset_id
			AND rdp.root_dataset_id = rd_root.report_dataset_id
		INNER JOIN report_dataset rd 
			ON rd.report_id = r.report_id
			AND rd.[alias] = 'rovu1'
		INNER JOIN data_source ds 
			ON ISNULL(NULLIF(ds.report_id, 0), r.report_id) = r.report_id	
			AND ds.[name] = 'RECs Obligation Volume Update' 
		INNER JOIN data_source_column dsc 
			ON dsc.source_id = ds.data_source_id
			AND dsc.[name] = 'as_of_date'	
	
		INSERT INTO report_page_tablix(page_id,root_dataset_id, [name], width, height, [top], [left], group_mode, border_style, page_break, type_id, cross_summary, no_header, export_table_name, is_global)
		SELECT TOP 1 rpage.report_page_id AS page_id, rd.report_dataset_id AS root_dataset_id, 'RECs Obligation Volume Update_tablix' [name], '4' width, '2.6666666666666665' height, '0' [top], '0' [left],2 AS group_mode,1 AS border_style,0 AS page_break,1 AS type_id,1 AS cross_summary,2 AS no_header,'' export_table_name, 0 AS is_global
		FROM sys.objects o
		INNER JOIN report_page rpage 
		ON rpage.[name] = 'RECs Obligation Volume Update'
		INNER JOIN report r 
			ON r.report_id = rpage.report_id
			AND r.[name] = 'RECs Obligation Volume Update'
		INNER JOIN report_dataset rd 
			ON rd.report_id = r.report_id 
			AND rd.[alias] = 'rovu1' 
	
		INSERT INTO report_tablix_column(tablix_id, dataset_id, column_id, placement, column_order, aggregation
					, functions, [alias], sortable, rounding, thousand_seperation, font
					, font_size, font_style, text_align, text_color, background, default_sort_order
					, default_sort_direction, custom_field, render_as, column_template, negative_mark, currency, date_format, cross_summary_aggregation, mark_for_total, sql_aggregation, subtotal)
		SELECT TOP 1 rpt.report_page_tablix_id tablix_id, rd.report_dataset_id dataset_id, dsc.data_source_column_id column_id,1 placement, 0 column_order,NULL aggregation, NULL functions, 'As of Date' [alias], 1 sortable, NULL rounding, NULL thousand_seperation, 'Tahoma' font, '8' font_size, '0,0,0' font_style, 'Left' text_align, '#000000' text_color, '#ffffff' background, NULL default_sort_order, NULL sort_direction, 0 custom_field, 0 render_as,-1 column_template,NULL negative_mark,NULL currency,NULL date_format,-1 cross_summary_aggregation,NULL mark_for_total,NULL sql_aggregation,NULL subtotal
			
		FROM sys.objects o
		INNER JOIN report_page_tablix rpt 
			ON rpt.[name] = 'RECs Obligation Volume Update_tablix'
		INNER JOIN report_page rpage 
			ON rpage.report_page_id = rpt.page_id 
			AND rpage.[name] = 'RECs Obligation Volume Update'
		INNER JOIN report r 
			ON r.report_id = rpage.report_id
			AND r.[name] = 'RECs Obligation Volume Update'
		INNER JOIN report_dataset rd 
			ON rd.report_id = r.report_id AND rd.[alias] = 'rovu1' 	
		INNER JOIN data_source ds 
			ON ISNULL(NULLIF(ds.report_id, 0), r.report_id) = r.report_id	AND ds.[name] = 'RECs Obligation Volume Update' 	
		INNER JOIN data_source_column dsc 
			ON dsc.source_id = ds.data_source_id AND dsc.[name] = 'as_of_date' 
		INSERT INTO report_tablix_column(tablix_id, dataset_id, column_id, placement, column_order, aggregation
					, functions, [alias], sortable, rounding, thousand_seperation, font
					, font_size, font_style, text_align, text_color, background, default_sort_order
					, default_sort_direction, custom_field, render_as, column_template, negative_mark, currency, date_format, cross_summary_aggregation, mark_for_total, sql_aggregation, subtotal)
		SELECT TOP 1 rpt.report_page_tablix_id tablix_id, rd.report_dataset_id dataset_id, dsc.data_source_column_id column_id,1 placement, 1 column_order,NULL aggregation, NULL functions, 'Jurisdiction' [alias], 1 sortable, NULL rounding, NULL thousand_seperation, 'Tahoma' font, '8' font_size, '0,0,0' font_style, 'Left' text_align, '#000000' text_color, '#ffffff' background, NULL default_sort_order, NULL sort_direction, 0 custom_field, 0 render_as,-1 column_template,NULL negative_mark,NULL currency,NULL date_format,-1 cross_summary_aggregation,NULL mark_for_total,NULL sql_aggregation,NULL subtotal
			
		FROM sys.objects o
		INNER JOIN report_page_tablix rpt 
			ON rpt.[name] = 'RECs Obligation Volume Update_tablix'
		INNER JOIN report_page rpage 
			ON rpage.report_page_id = rpt.page_id 
			AND rpage.[name] = 'RECs Obligation Volume Update'
		INNER JOIN report r 
			ON r.report_id = rpage.report_id
			AND r.[name] = 'RECs Obligation Volume Update'
		INNER JOIN report_dataset rd 
			ON rd.report_id = r.report_id AND rd.[alias] = 'rovu1' 	
		INNER JOIN data_source ds 
			ON ISNULL(NULLIF(ds.report_id, 0), r.report_id) = r.report_id	AND ds.[name] = 'RECs Obligation Volume Update' 	
		INNER JOIN data_source_column dsc 
			ON dsc.source_id = ds.data_source_id AND dsc.[name] = 'Jurisdiction' 
		INSERT INTO report_tablix_column(tablix_id, dataset_id, column_id, placement, column_order, aggregation
					, functions, [alias], sortable, rounding, thousand_seperation, font
					, font_size, font_style, text_align, text_color, background, default_sort_order
					, default_sort_direction, custom_field, render_as, column_template, negative_mark, currency, date_format, cross_summary_aggregation, mark_for_total, sql_aggregation, subtotal)
		SELECT TOP 1 rpt.report_page_tablix_id tablix_id, rd.report_dataset_id dataset_id, dsc.data_source_column_id column_id,1 placement, 2 column_order,NULL aggregation, NULL functions, 'Tier' [alias], 1 sortable, NULL rounding, NULL thousand_seperation, 'Tahoma' font, '8' font_size, '0,0,0' font_style, 'Left' text_align, '#000000' text_color, '#ffffff' background, NULL default_sort_order, NULL sort_direction, 0 custom_field, 0 render_as,-1 column_template,NULL negative_mark,NULL currency,NULL date_format,-1 cross_summary_aggregation,NULL mark_for_total,NULL sql_aggregation,NULL subtotal
			
		FROM sys.objects o
		INNER JOIN report_page_tablix rpt 
			ON rpt.[name] = 'RECs Obligation Volume Update_tablix'
		INNER JOIN report_page rpage 
			ON rpage.report_page_id = rpt.page_id 
			AND rpage.[name] = 'RECs Obligation Volume Update'
		INNER JOIN report r 
			ON r.report_id = rpage.report_id
			AND r.[name] = 'RECs Obligation Volume Update'
		INNER JOIN report_dataset rd 
			ON rd.report_id = r.report_id AND rd.[alias] = 'rovu1' 	
		INNER JOIN data_source ds 
			ON ISNULL(NULLIF(ds.report_id, 0), r.report_id) = r.report_id	AND ds.[name] = 'RECs Obligation Volume Update' 	
		INNER JOIN data_source_column dsc 
			ON dsc.source_id = ds.data_source_id AND dsc.[name] = 'Tier' 
		INSERT INTO report_tablix_column(tablix_id, dataset_id, column_id, placement, column_order, aggregation
					, functions, [alias], sortable, rounding, thousand_seperation, font
					, font_size, font_style, text_align, text_color, background, default_sort_order
					, default_sort_direction, custom_field, render_as, column_template, negative_mark, currency, date_format, cross_summary_aggregation, mark_for_total, sql_aggregation, subtotal)
		SELECT TOP 1 rpt.report_page_tablix_id tablix_id, rd.report_dataset_id dataset_id, dsc.data_source_column_id column_id,1 placement, 3 column_order,NULL aggregation, NULL functions, 'Status' [alias], 1 sortable, NULL rounding, NULL thousand_seperation, 'Tahoma' font, '8' font_size, '0,0,0' font_style, 'Left' text_align, '#000000' text_color, '#ffffff' background, NULL default_sort_order, NULL sort_direction, 0 custom_field, 0 render_as,-1 column_template,NULL negative_mark,NULL currency,NULL date_format,-1 cross_summary_aggregation,NULL mark_for_total,NULL sql_aggregation,NULL subtotal
			
		FROM sys.objects o
		INNER JOIN report_page_tablix rpt 
			ON rpt.[name] = 'RECs Obligation Volume Update_tablix'
		INNER JOIN report_page rpage 
			ON rpage.report_page_id = rpt.page_id 
			AND rpage.[name] = 'RECs Obligation Volume Update'
		INNER JOIN report r 
			ON r.report_id = rpage.report_id
			AND r.[name] = 'RECs Obligation Volume Update'
		INNER JOIN report_dataset rd 
			ON rd.report_id = r.report_id AND rd.[alias] = 'rovu1' 	
		INNER JOIN data_source ds 
			ON ISNULL(NULLIF(ds.report_id, 0), r.report_id) = r.report_id	AND ds.[name] = 'RECs Obligation Volume Update' 	
		INNER JOIN data_source_column dsc 
			ON dsc.source_id = ds.data_source_id AND dsc.[name] = 'Status' 
		INSERT INTO report_tablix_column(tablix_id, dataset_id, column_id, placement, column_order, aggregation
					, functions, [alias], sortable, rounding, thousand_seperation, font
					, font_size, font_style, text_align, text_color, background, default_sort_order
					, default_sort_direction, custom_field, render_as, column_template, negative_mark, currency, date_format, cross_summary_aggregation, mark_for_total, sql_aggregation, subtotal)
		SELECT TOP 1 rpt.report_page_tablix_id tablix_id, rd.report_dataset_id dataset_id, dsc.data_source_column_id column_id,1 placement, 4 column_order,NULL aggregation, NULL functions, 'Errorcode' [alias], 1 sortable, NULL rounding, NULL thousand_seperation, 'Tahoma' font, '8' font_size, '0,0,0' font_style, 'Left' text_align, '#000000' text_color, '#ffffff' background, NULL default_sort_order, NULL sort_direction, 0 custom_field, 0 render_as,-1 column_template,NULL negative_mark,NULL currency,NULL date_format,-1 cross_summary_aggregation,NULL mark_for_total,NULL sql_aggregation,NULL subtotal
			
		FROM sys.objects o
		INNER JOIN report_page_tablix rpt 
			ON rpt.[name] = 'RECs Obligation Volume Update_tablix'
		INNER JOIN report_page rpage 
			ON rpage.report_page_id = rpt.page_id 
			AND rpage.[name] = 'RECs Obligation Volume Update'
		INNER JOIN report r 
			ON r.report_id = rpage.report_id
			AND r.[name] = 'RECs Obligation Volume Update'
		INNER JOIN report_dataset rd 
			ON rd.report_id = r.report_id AND rd.[alias] = 'rovu1' 	
		INNER JOIN data_source ds 
			ON ISNULL(NULLIF(ds.report_id, 0), r.report_id) = r.report_id	AND ds.[name] = 'RECs Obligation Volume Update' 	
		INNER JOIN data_source_column dsc 
			ON dsc.source_id = ds.data_source_id AND dsc.[name] = 'ErrorCode' 
		INSERT INTO report_tablix_column(tablix_id, dataset_id, column_id, placement, column_order, aggregation
					, functions, [alias], sortable, rounding, thousand_seperation, font
					, font_size, font_style, text_align, text_color, background, default_sort_order
					, default_sort_direction, custom_field, render_as, column_template, negative_mark, currency, date_format, cross_summary_aggregation, mark_for_total, sql_aggregation, subtotal)
		SELECT TOP 1 rpt.report_page_tablix_id tablix_id, rd.report_dataset_id dataset_id, dsc.data_source_column_id column_id,1 placement, 5 column_order,NULL aggregation, NULL functions, 'Message' [alias], 1 sortable, NULL rounding, NULL thousand_seperation, 'Tahoma' font, '8' font_size, '0,0,0' font_style, 'Left' text_align, '#000000' text_color, '#ffffff' background, NULL default_sort_order, NULL sort_direction, 0 custom_field, 0 render_as,-1 column_template,NULL negative_mark,NULL currency,NULL date_format,-1 cross_summary_aggregation,NULL mark_for_total,NULL sql_aggregation,NULL subtotal
			
		FROM sys.objects o
		INNER JOIN report_page_tablix rpt 
			ON rpt.[name] = 'RECs Obligation Volume Update_tablix'
		INNER JOIN report_page rpage 
			ON rpage.report_page_id = rpt.page_id 
			AND rpage.[name] = 'RECs Obligation Volume Update'
		INNER JOIN report r 
			ON r.report_id = rpage.report_id
			AND r.[name] = 'RECs Obligation Volume Update'
		INNER JOIN report_dataset rd 
			ON rd.report_id = r.report_id AND rd.[alias] = 'rovu1' 	
		INNER JOIN data_source ds 
			ON ISNULL(NULLIF(ds.report_id, 0), r.report_id) = r.report_id	AND ds.[name] = 'RECs Obligation Volume Update' 	
		INNER JOIN data_source_column dsc 
			ON dsc.source_id = ds.data_source_id AND dsc.[name] = 'Message' 
		INSERT INTO report_tablix_column(tablix_id, dataset_id, column_id, placement, column_order, aggregation
					, functions, [alias], sortable, rounding, thousand_seperation, font
					, font_size, font_style, text_align, text_color, background, default_sort_order
					, default_sort_direction, custom_field, render_as, column_template, negative_mark, currency, date_format, cross_summary_aggregation, mark_for_total, sql_aggregation, subtotal)
		SELECT TOP 1 rpt.report_page_tablix_id tablix_id, rd.report_dataset_id dataset_id, dsc.data_source_column_id column_id,1 placement, 6 column_order,NULL aggregation, NULL functions, 'Module' [alias], 1 sortable, NULL rounding, NULL thousand_seperation, 'Tahoma' font, '8' font_size, '0,0,0' font_style, 'Left' text_align, '#000000' text_color, '#ffffff' background, NULL default_sort_order, NULL sort_direction, 0 custom_field, 0 render_as,-1 column_template,NULL negative_mark,NULL currency,NULL date_format,-1 cross_summary_aggregation,NULL mark_for_total,NULL sql_aggregation,NULL subtotal
			
		FROM sys.objects o
		INNER JOIN report_page_tablix rpt 
			ON rpt.[name] = 'RECs Obligation Volume Update_tablix'
		INNER JOIN report_page rpage 
			ON rpage.report_page_id = rpt.page_id 
			AND rpage.[name] = 'RECs Obligation Volume Update'
		INNER JOIN report r 
			ON r.report_id = rpage.report_id
			AND r.[name] = 'RECs Obligation Volume Update'
		INNER JOIN report_dataset rd 
			ON rd.report_id = r.report_id AND rd.[alias] = 'rovu1' 	
		INNER JOIN data_source ds 
			ON ISNULL(NULLIF(ds.report_id, 0), r.report_id) = r.report_id	AND ds.[name] = 'RECs Obligation Volume Update' 	
		INNER JOIN data_source_column dsc 
			ON dsc.source_id = ds.data_source_id AND dsc.[name] = 'Module' 
		INSERT INTO report_tablix_column(tablix_id, dataset_id, column_id, placement, column_order, aggregation
					, functions, [alias], sortable, rounding, thousand_seperation, font
					, font_size, font_style, text_align, text_color, background, default_sort_order
					, default_sort_direction, custom_field, render_as, column_template, negative_mark, currency, date_format, cross_summary_aggregation, mark_for_total, sql_aggregation, subtotal)
		SELECT TOP 1 rpt.report_page_tablix_id tablix_id, rd.report_dataset_id dataset_id, dsc.data_source_column_id column_id,1 placement, 7 column_order,NULL aggregation, NULL functions, 'Area' [alias], 1 sortable, NULL rounding, NULL thousand_seperation, 'Tahoma' font, '8' font_size, '0,0,0' font_style, 'Left' text_align, '#000000' text_color, '#ffffff' background, NULL default_sort_order, NULL sort_direction, 0 custom_field, 0 render_as,-1 column_template,NULL negative_mark,NULL currency,NULL date_format,-1 cross_summary_aggregation,NULL mark_for_total,NULL sql_aggregation,NULL subtotal
			
		FROM sys.objects o
		INNER JOIN report_page_tablix rpt 
			ON rpt.[name] = 'RECs Obligation Volume Update_tablix'
		INNER JOIN report_page rpage 
			ON rpage.report_page_id = rpt.page_id 
			AND rpage.[name] = 'RECs Obligation Volume Update'
		INNER JOIN report r 
			ON r.report_id = rpage.report_id
			AND r.[name] = 'RECs Obligation Volume Update'
		INNER JOIN report_dataset rd 
			ON rd.report_id = r.report_id AND rd.[alias] = 'rovu1' 	
		INNER JOIN data_source ds 
			ON ISNULL(NULLIF(ds.report_id, 0), r.report_id) = r.report_id	AND ds.[name] = 'RECs Obligation Volume Update' 	
		INNER JOIN data_source_column dsc 
			ON dsc.source_id = ds.data_source_id AND dsc.[name] = 'Area' 
		INSERT INTO report_tablix_column(tablix_id, dataset_id, column_id, placement, column_order, aggregation
					, functions, [alias], sortable, rounding, thousand_seperation, font
					, font_size, font_style, text_align, text_color, background, default_sort_order
					, default_sort_direction, custom_field, render_as, column_template, negative_mark, currency, date_format, cross_summary_aggregation, mark_for_total, sql_aggregation, subtotal)
		SELECT TOP 1 rpt.report_page_tablix_id tablix_id, rd.report_dataset_id dataset_id, dsc.data_source_column_id column_id,1 placement, 8 column_order,NULL aggregation, NULL functions, 'Recommendation' [alias], 1 sortable, NULL rounding, NULL thousand_seperation, 'Tahoma' font, '8' font_size, '0,0,0' font_style, 'Left' text_align, '#000000' text_color, '#ffffff' background, NULL default_sort_order, NULL sort_direction, 0 custom_field, 0 render_as,-1 column_template,NULL negative_mark,NULL currency,NULL date_format,-1 cross_summary_aggregation,NULL mark_for_total,NULL sql_aggregation,NULL subtotal
			
		FROM sys.objects o
		INNER JOIN report_page_tablix rpt 
			ON rpt.[name] = 'RECs Obligation Volume Update_tablix'
		INNER JOIN report_page rpage 
			ON rpage.report_page_id = rpt.page_id 
			AND rpage.[name] = 'RECs Obligation Volume Update'
		INNER JOIN report r 
			ON r.report_id = rpage.report_id
			AND r.[name] = 'RECs Obligation Volume Update'
		INNER JOIN report_dataset rd 
			ON rd.report_id = r.report_id AND rd.[alias] = 'rovu1' 	
		INNER JOIN data_source ds 
			ON ISNULL(NULLIF(ds.report_id, 0), r.report_id) = r.report_id	AND ds.[name] = 'RECs Obligation Volume Update' 	
		INNER JOIN data_source_column dsc 
			ON dsc.source_id = ds.data_source_id AND dsc.[name] = 'Recommendation'  INSERT INTO report_tablix_header(tablix_id, column_id, font, font_size, font_style, text_align, text_color, background, report_tablix_column_id)
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
			ON  rpt.[name] = 'RECs Obligation Volume Update_tablix'
		INNER JOIN report_page rpage 
			ON  rpage.report_page_id = rpt.page_id 
		AND rpage.[name] = 'RECs Obligation Volume Update'
		INNER JOIN report r 
			ON  r.report_id = rpage.report_id 
			AND r.[name] = 'RECs Obligation Volume Update'
		INNER JOIN data_source ds 
			ON ISNULL(NULLIF(ds.report_id, 0), r.report_id) = r.report_id	AND ds.[name] = 'RECs Obligation Volume Update' 	
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
			ON  rpt.[name] = 'RECs Obligation Volume Update_tablix'
		INNER JOIN report_page rpage 
			ON  rpage.report_page_id = rpt.page_id 
		AND rpage.[name] = 'RECs Obligation Volume Update'
		INNER JOIN report r 
			ON  r.report_id = rpage.report_id 
			AND r.[name] = 'RECs Obligation Volume Update'
		INNER JOIN data_source ds 
			ON ISNULL(NULLIF(ds.report_id, 0), r.report_id) = r.report_id	AND ds.[name] = 'RECs Obligation Volume Update' 	
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
			ON  rpt.[name] = 'RECs Obligation Volume Update_tablix'
		INNER JOIN report_page rpage 
			ON  rpage.report_page_id = rpt.page_id 
		AND rpage.[name] = 'RECs Obligation Volume Update'
		INNER JOIN report r 
			ON  r.report_id = rpage.report_id 
			AND r.[name] = 'RECs Obligation Volume Update'
		INNER JOIN data_source ds 
			ON ISNULL(NULLIF(ds.report_id, 0), r.report_id) = r.report_id	AND ds.[name] = 'RECs Obligation Volume Update' 	
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
			ON  rpt.[name] = 'RECs Obligation Volume Update_tablix'
		INNER JOIN report_page rpage 
			ON  rpage.report_page_id = rpt.page_id 
		AND rpage.[name] = 'RECs Obligation Volume Update'
		INNER JOIN report r 
			ON  r.report_id = rpage.report_id 
			AND r.[name] = 'RECs Obligation Volume Update'
		INNER JOIN data_source ds 
			ON ISNULL(NULLIF(ds.report_id, 0), r.report_id) = r.report_id	AND ds.[name] = 'RECs Obligation Volume Update' 	
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
			ON  rpt.[name] = 'RECs Obligation Volume Update_tablix'
		INNER JOIN report_page rpage 
			ON  rpage.report_page_id = rpt.page_id 
		AND rpage.[name] = 'RECs Obligation Volume Update'
		INNER JOIN report r 
			ON  r.report_id = rpage.report_id 
			AND r.[name] = 'RECs Obligation Volume Update'
		INNER JOIN data_source ds 
			ON ISNULL(NULLIF(ds.report_id, 0), r.report_id) = r.report_id	AND ds.[name] = 'RECs Obligation Volume Update' 	
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
			ON  rpt.[name] = 'RECs Obligation Volume Update_tablix'
		INNER JOIN report_page rpage 
			ON  rpage.report_page_id = rpt.page_id 
		AND rpage.[name] = 'RECs Obligation Volume Update'
		INNER JOIN report r 
			ON  r.report_id = rpage.report_id 
			AND r.[name] = 'RECs Obligation Volume Update'
		INNER JOIN data_source ds 
			ON ISNULL(NULLIF(ds.report_id, 0), r.report_id) = r.report_id	AND ds.[name] = 'RECs Obligation Volume Update' 	
		INNER JOIN data_source_column dsc 
			ON dsc.source_id = ds.data_source_id AND dsc.[name] = 'Status' 
		INNER JOIN report_tablix_column rtc 
			on rtc.tablix_id = rpt.report_page_tablix_id
			--AND rtc.column_id = dsc.data_source_column_id  --This did not handle custom column, got duplicate custom columns during export
			AND rtc.alias = 'Status' --Added to handle custom column. Assumption: alias is unique and NOT NULL
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
			ON  rpt.[name] = 'RECs Obligation Volume Update_tablix'
		INNER JOIN report_page rpage 
			ON  rpage.report_page_id = rpt.page_id 
		AND rpage.[name] = 'RECs Obligation Volume Update'
		INNER JOIN report r 
			ON  r.report_id = rpage.report_id 
			AND r.[name] = 'RECs Obligation Volume Update'
		INNER JOIN data_source ds 
			ON ISNULL(NULLIF(ds.report_id, 0), r.report_id) = r.report_id	AND ds.[name] = 'RECs Obligation Volume Update' 	
		INNER JOIN data_source_column dsc 
			ON dsc.source_id = ds.data_source_id AND dsc.[name] = 'Jurisdiction' 
		INNER JOIN report_tablix_column rtc 
			on rtc.tablix_id = rpt.report_page_tablix_id
			--AND rtc.column_id = dsc.data_source_column_id  --This did not handle custom column, got duplicate custom columns during export
			AND rtc.alias = 'Jurisdiction' --Added to handle custom column. Assumption: alias is unique and NOT NULL
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
			ON  rpt.[name] = 'RECs Obligation Volume Update_tablix'
		INNER JOIN report_page rpage 
			ON  rpage.report_page_id = rpt.page_id 
		AND rpage.[name] = 'RECs Obligation Volume Update'
		INNER JOIN report r 
			ON  r.report_id = rpage.report_id 
			AND r.[name] = 'RECs Obligation Volume Update'
		INNER JOIN data_source ds 
			ON ISNULL(NULLIF(ds.report_id, 0), r.report_id) = r.report_id	AND ds.[name] = 'RECs Obligation Volume Update' 	
		INNER JOIN data_source_column dsc 
			ON dsc.source_id = ds.data_source_id AND dsc.[name] = 'Tier' 
		INNER JOIN report_tablix_column rtc 
			on rtc.tablix_id = rpt.report_page_tablix_id
			--AND rtc.column_id = dsc.data_source_column_id  --This did not handle custom column, got duplicate custom columns during export
			AND rtc.alias = 'Tier' --Added to handle custom column. Assumption: alias is unique and NOT NULL
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
			ON  rpt.[name] = 'RECs Obligation Volume Update_tablix'
		INNER JOIN report_page rpage 
			ON  rpage.report_page_id = rpt.page_id 
		AND rpage.[name] = 'RECs Obligation Volume Update'
		INNER JOIN report r 
			ON  r.report_id = rpage.report_id 
			AND r.[name] = 'RECs Obligation Volume Update'
		INNER JOIN data_source ds 
			ON ISNULL(NULLIF(ds.report_id, 0), r.report_id) = r.report_id	AND ds.[name] = 'RECs Obligation Volume Update' 	
		INNER JOIN data_source_column dsc 
			ON dsc.source_id = ds.data_source_id AND dsc.[name] = 'as_of_date' 
		INNER JOIN report_tablix_column rtc 
			on rtc.tablix_id = rpt.report_page_tablix_id
			--AND rtc.column_id = dsc.data_source_column_id  --This did not handle custom column, got duplicate custom columns during export
			AND rtc.alias = 'As of Date' --Added to handle custom column. Assumption: alias is unique and NOT NULL
	
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