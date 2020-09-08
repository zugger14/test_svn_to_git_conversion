BEGIN TRY
		BEGIN TRAN
	
	declare @new_ds_alias varchar(10) = 'imb'
	/** IF DATA SOURCE ALIAS ALREADY EXISTS ON DESTINATION, RAISE ERROR **/
	if exists(select top 1 1 from data_source where alias = 'imb' and name <> 'Imbalance')
	begin
		select top 1 @new_ds_alias = 'imb' + cast(s.n as varchar(5))
		from seq s
		left join data_source ds on ds.alias = 'imb' + cast(s.n as varchar(5))
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
	           WHERE [name] = 'Imbalance'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	AND NOT EXISTS (SELECT 1 FROM map_function_category WHERE [function_name] = 'Imbalance' AND '106501' = '106501') 
	BEGIN
		INSERT INTO data_source([type_id], [name], [alias], [description], [tsql], report_id, system_defined,category)
		SELECT TOP 1 1 AS [type_id], 'Imbalance' AS [name], @new_ds_alias AS ALIAS, 'Imbalance' AS [description],null AS [tsql], @report_id_data_source_dest AS report_id,'0' AS [system_defined]
			,'106501' AS [category]
	END

	UPDATE data_source
	SET alias = @new_ds_alias, description = 'Imbalance'
	, [tsql] = CAST('' AS VARCHAR(MAX)) + 'DECLARE @_prod_date                DATETIME
 DECLARE @_source_deal_header_id    NVARCHAR(1000)
 DECLARE @_source_deal_detail_id    NVARCHAR(1000)
 DECLARE @_leg                    NVARCHAR(1000)
 DECLARE @_curve_id NVARCHAR(200) = ''POWER.DE.TENNET.QH.Imbalance''

 IF ''@prod_date''<>''NULL''
     SET @_prod_date = ''@prod_date'' 
IF ''@source_deal_header_id''<>''NULL''
     SET @_source_deal_header_id = ''@source_deal_header_id'' 
IF ''@source_deal_detail_id''<>''NULL''
     SET @_source_deal_detail_id = ''@source_deal_detail_id'' 
IF ''@leg''<>''NULL''
     SET @_leg = ''@leg'' 

IF OBJECT_ID(''tempdb..#temp_source_price_curve'') IS NOT NULL
	DROP TABLE #temp_source_price_curve

IF OBJECT_ID(''tempdb..#temp_mv90_dst'') IS NOT NULL
	DROP TABLE #temp_mv90_dst

SELECT * INTO #temp_source_price_curve
FROM (
	SELECT spc.source_curve_def_id [curve_id], CAST(spc.maturity_date AS DATE) maturity_date
	, DATEPART(MINUTE, spc.maturity_date) [minute]
	,CASE WHEN spc.is_dst = 0 THEN  ''Hr'' + CAST((DATEPART(HOUR, spc.maturity_date) + 1) AS VARCHAR(10))
	  ELSE ''Hr25'' END [hour] , MAX(spc.curve_value) curve_value
	 FROM source_price_curve_def spcd
	 INNER JOIN source_price_curve spc
		ON spc.source_curve_def_id = spcd.source_curve_def_id
	 WHERE spcd.curve_id = @_curve_id
	 AND YEAR(spc.maturity_date) = YEAR(@_prod_date)
	 AND MONTH(spc.maturity_date) = MONTH(@_prod_date)
	 GROUP BY spc.source_curve_def_id,spc.maturity_date,spc.is_dst,  DATEPART(MINUTE, spc.maturity_date)
) tbl
PIVOT
(
  AVG(curve_value)
  for [hour] in (Hr1,Hr2,Hr3,Hr4,Hr5,Hr6,Hr7,Hr8,Hr9,Hr10,Hr11,Hr12,Hr13,Hr14,Hr15,Hr16,Hr17,Hr18,Hr19,Hr20,Hr21,Hr22,Hr23,Hr24, Hr25)
) unpvt

SELECT * INTO #temp_mv90_dst
FROM (
	 SELECT [date]
	,''Hr'' + CAST(hour AS VARCHAR(10)) [hour]
	, 1 [value]
	 FROM mv90_dst 
	 WHERE [year] = YEAR(@_prod_date)
	 AND insert_delete = ''i''
	 AND dst_group_value_id = 102201
) tbl
PIVOT
(
  AVG([value])
  for [hour] in (Hr1,Hr2,Hr3,Hr4,Hr5,Hr6,Hr7,Hr8,Hr9,Hr10,Hr11,Hr12,Hr13,Hr14,Hr15,Hr16,Hr17,Hr18,Hr19,Hr20,Hr21,Hr22,Hr23,Hr24)
) unpvt


SELECT @_source_deal_header_id source_deal_header_id,
    @_leg leg,
     @_prod_date prod_date,
     0 [hour], 
     0 [mins],
     ISNULL(mdh.meter_volume,0) - ISNULL(pf.profile_volume,0) [value],
     NULL counterparty_id,
	 NULL contract_id,	 
	 sdd.source_deal_detail_id source_deal_detail_id
 --[__batch_report__]
 FROM source_deal_detail sdd
 INNER JOIN  mv90_data mv ON sdd.meter_id = mv.meter_id AND mv.from_date = sdd.term_start
 OUTER APPLY (
     SELECT    dbo.fnagetcontractmonth(prod_date) term_date,
               SUM((ISNULL(mdh.Hr1,0)  - IIF(md_dst.[date] IS NOT NULL AND ISNULL(md_dst.Hr1,0)  = 1, ISNULL(mdh.Hr25,0) , 0))  * ISNULL(tscp.Hr1, 0)
                 + (ISNULL(mdh.Hr2 ,0) - IIF(md_dst.[date] IS NOT NULL AND ISNULL(md_dst.Hr2 ,0) = 1, ISNULL(mdh.Hr25 ,0), 0)) * ISNULL(tscp.Hr2, 0)
                 + (ISNULL(mdh.Hr3 ,0) - IIF(md_dst.[date] IS NOT NULL AND ISNULL(md_dst.Hr3 ,0) = 1, ISNULL(mdh.Hr25 ,0), 0)) * ISNULL(tscp.Hr3, 0)
                 + (ISNULL(mdh.Hr4 ,0) - IIF(md_dst.[date] IS NOT NULL AND ISNULL(md_dst.Hr4 ,0) = 1, ISNULL(mdh.Hr25 ,0), 0)) * ISNULL(tscp.Hr4, 0)
                 + (ISNULL(mdh.Hr5 ,0) - IIF(md_dst.[date] IS NOT NULL AND ISNULL(md_dst.Hr5 ,0) = 1, ISNULL(mdh.Hr25 ,0), 0)) * ISNULL(tscp.Hr5, 0)
                 + (ISNULL(mdh.Hr6 ,0) - IIF(md_dst.[date] IS NOT NULL AND ISNULL(md_dst.Hr6 ,0) = 1, ISNULL(mdh.Hr25 ,0), 0)) * ISNULL(tscp.Hr6, 0)
                 + (ISNULL(mdh.Hr7 ,0) - IIF(md_dst.[date] IS NOT NULL AND ISNULL(md_dst.Hr7 ,0) = 1, ISNULL(mdh.Hr25 ,0), 0)) * ISNULL(tscp.Hr7, 0)
                 + (ISNULL(mdh.Hr8 ,0) - IIF(md_dst.[date] IS NOT NULL AND ISNULL(md_dst.Hr8 ,0) = 1, ISNULL(mdh.Hr25 ,0), 0)) * ISNULL(tscp.Hr8, 0)
                 + (ISNULL(mdh.Hr9 ,0) - IIF(md_dst.[date] IS NOT NULL AND ISNULL(md_dst.Hr9 ,0) = 1, ISNULL(mdh.Hr25 ,0), 0)) * ISNULL(tscp.Hr9, 0)
                 + (ISNULL(mdh.Hr10,0) - IIF(md_dst.[date] IS NOT NULL AND ISNULL(md_dst.Hr10,0) = 1, ISNULL(mdh.Hr25,0), 0)) * ISNULL(tscp.Hr10, 0)
                 + (ISNULL(mdh.Hr11,0) - IIF(md_dst.[date] IS NOT NULL AND ISNULL(md_dst.Hr11,0) = 1, ISNULL(mdh.Hr25,0), 0)) * ISNULL(tscp.Hr11, 0)
                 + (ISNULL(mdh.Hr12,0) - IIF(md_dst.[date] IS NOT NULL AND ISNULL(md_dst.Hr12,0) = 1, ISNULL(mdh.Hr25,0), 0)) * ISNULL(tscp.Hr12, 0)
                 + (ISNULL(mdh.Hr13,0) - IIF(md_dst.[date] IS NOT NULL AND ISNULL(md_dst.Hr13,0) = 1, ISNULL(mdh.Hr25,0), 0)) * ISNULL(tscp.Hr13, 0)
                 + (ISNULL(mdh.Hr14,0) - IIF(md_dst.[date] IS NOT NULL AND ISNULL(md_dst.Hr14,0) = 1, ISNULL(mdh.Hr25,0), 0)) * ISNULL(tscp.Hr14, 0)
                 + (ISNULL(mdh.Hr15,0) - IIF(md_dst.[date] IS NOT NULL AND ISNULL(md_dst.Hr15,0) = 1, ISNULL(mdh.Hr25,0), 0)) * ISNULL(tscp.Hr15, 0)
                 + (ISNULL(mdh.Hr16,0) - IIF(md_dst.[date] IS NOT NULL AND ISNULL(md_dst.Hr16,0) = 1, ISNULL(mdh.Hr25,0), 0)) * ISNULL(tscp.Hr16, 0)
                 + (ISNULL(mdh.Hr17,0) - IIF(md_dst.[date] IS NOT NULL AND ISNULL(md_dst.Hr17,0) = 1, ISNULL(mdh.Hr25,0), 0)) * ISNULL(tscp.Hr17, 0)
                 + (ISNULL(mdh.Hr18,0) - IIF(md_dst.[date] IS NOT NULL AND ISNULL(md_dst.Hr18,0) = 1, ISNULL(mdh.Hr25,0), 0)) * ISNULL(tscp.Hr18, 0)
                 + (ISNULL(mdh.Hr19,0) - IIF(md_dst.[date] IS NOT NULL AND ISNULL(md_dst.Hr19,0) = 1, ISNULL(mdh.Hr25,0), 0)) * ISNULL(tscp.Hr19, 0)
                 + (ISNULL(mdh.Hr20,0) - IIF(md_dst.[date] IS NOT NULL AND ISNULL(md_dst.Hr20,0) = 1, ISNULL(mdh.Hr25,0), 0)) * ISNULL(tscp.Hr20, 0)
                 + (ISNULL(mdh.Hr21,0) - IIF(md_dst.[date] IS NOT NULL AND ISNULL(md_dst.Hr21,0) = 1, ISNULL(mdh.Hr25,0), 0)) * ISNULL(tscp.Hr21, 0)
                 + (ISNULL(mdh.Hr22,0) - IIF(md_dst.[date] IS NOT NULL AND ISNULL(md_dst.Hr22,0) = 1, ISNULL(mdh.Hr25,0), 0)) * ISNULL(tscp.Hr22, 0)
                 + (ISNULL(mdh.Hr23,0) - IIF(md_dst.[date] IS NOT NULL AND ISNULL(md_dst.Hr23,0) = 1, ISNULL(mdh.Hr25,0), 0)) * ISNULL(tscp.Hr23, 0)
                 + (ISNULL(mdh.Hr24,0) - IIF(md_dst.[date] IS NOT NULL AND ISNULL(md_dst.Hr24,0) = 1, ISNULL(mdh.Hr25,0), 0)) * ISNULL(tscp.Hr24, 0)
                 + ISNULL(mdh.Hr25,0) * ISNULL(tscp.Hr25, 0)) [meter_volume]
     FROM mv90_data_hour mdh 
	 INNER JOIN #temp_source_price_curve tscp
		ON YEAR(tscp.maturity_date) = YEAR(sdd.term_start)
		AND MONTH(tscp.maturity_date) = MONTH(sdd.term_start)
		AND tscp.[minute] = ISNULL([period], tscp.[minute])
		AND mdh.prod_date = tscp.maturity_date
	LEFT JOIN #temp_mv90_dst md_dst
		ON CAST(md_dst.[date] AS DATE) = CAST(mdh.prod_date AS DATE)
	 WHERE mdh.meter_data_id = mv.meter_data_id 
	 AND YEAR(mdh.prod_date) = YEAR(sdd.term_start)
	 AND MONTH(mdh.prod_date) = MONTH(sdd.term_start)
     GROUP BY dbo.fnagetcontractmonth(prod_date)
 ) mdh
 OUTER APPLY (
     SELECT    dbo.fnagetcontractmonth(term_date) term_date,
                SUM((ISNULL(ddh.Hr1,0) - IIF(md_dst.[date] IS NOT NULL AND ISNULL(md_dst.Hr1,0)  = 1, ISNULL(ddh.Hr25,0) , 0)) * ISNULL(tscp.Hr1, 0)
                  + (ISNULL(ddh.Hr2 ,0) - IIF(md_dst.[date] IS NOT NULL AND ISNULL(md_dst.Hr2 ,0) = 1, ISNULL(ddh.Hr25 ,0), 0)) * ISNULL(tscp.Hr2, 0)
                  + (ISNULL(ddh.Hr3 ,0) - IIF(md_dst.[date] IS NOT NULL AND ISNULL(md_dst.Hr3 ,0) = 1, ISNULL(ddh.Hr25 ,0), 0)) * ISNULL(tscp.Hr3, 0)
                  + (ISNULL(ddh.Hr4 ,0) - IIF(md_dst.[date] IS NOT NULL AND ISNULL(md_dst.Hr4 ,0) = 1, ISNULL(ddh.Hr25 ,0), 0)) * ISNULL(tscp.Hr4, 0)
                  + (ISNULL(ddh.Hr5 ,0) - IIF(md_dst.[date] IS NOT NULL AND ISNULL(md_dst.Hr5 ,0) = 1, ISNULL(ddh.Hr25 ,0), 0)) * ISNULL(tscp.Hr5, 0)
                  + (ISNULL(ddh.Hr6 ,0) - IIF(md_dst.[date] IS NOT NULL AND ISNULL(md_dst.Hr6 ,0) = 1, ISNULL(ddh.Hr25 ,0), 0)) * ISNULL(tscp.Hr6, 0)
                  + (ISNULL(ddh.Hr7 ,0) - IIF(md_dst.[date] IS NOT NULL AND ISNULL(md_dst.Hr7 ,0) = 1, ISNULL(ddh.Hr25 ,0), 0)) * ISNULL(tscp.Hr7, 0)
                  + (ISNULL(ddh.Hr8 ,0) - IIF(md_dst.[date] IS NOT NULL AND ISNULL(md_dst.Hr8 ,0) = 1, ISNULL(ddh.Hr25 ,0), 0)) * ISNULL(tscp.Hr8, 0)
                  + (ISNULL(ddh.Hr9 ,0) - IIF(md_dst.[date] IS NOT NULL AND ISNULL(md_dst.Hr9 ,0) = 1, ISNULL(ddh.Hr25 ,0), 0)) * ISNULL(tscp.Hr9, 0)
                  + (ISNULL(ddh.Hr10,0) - IIF(md_dst.[date] IS NOT NULL AND ISNULL(md_dst.Hr10,0) = 1, ISNULL(ddh.Hr25,0), 0)) * ISNULL(tscp.Hr10, 0)
                  + (ISNULL(ddh.Hr11,0) - IIF(md_dst.[date] IS NOT NULL AND ISNULL(md_dst.Hr11,0) = 1, ISNULL(ddh.Hr25,0), 0)) * ISNULL(tscp.Hr11, 0)
                  + (ISNULL(ddh.Hr12,0) - IIF(md_dst.[date] IS NOT NULL AND ISNULL(md_dst.Hr12,0) = 1, ISNULL(ddh.Hr25,0), 0)) * ISNULL(tscp.Hr12, 0)
                  + (ISNULL(ddh.Hr13,0) - IIF(md_dst.[date] IS NOT NULL AND ISNULL(md_dst.Hr13,0) = 1, ISNULL(ddh.Hr25,0), 0)) * ISNULL(tscp.Hr13, 0)
                  + (ISNULL(ddh.Hr14,0) - IIF(md_dst.[date] IS NOT NULL AND ISNULL(md_dst.Hr14,0) = 1, ISNULL(ddh.Hr25,0), 0)) * ISNULL(tscp.Hr14, 0)
                  + (ISNULL(ddh.Hr15,0) - IIF(md_dst.[date] IS NOT NULL AND ISNULL(md_dst.Hr15,0) = 1, ISNULL(ddh.Hr25,0), 0)) * ISNULL(tscp.Hr15, 0)
                  + (ISNULL(ddh.Hr16,0) - IIF(md_dst.[date] IS NOT NULL AND ISNULL(md_dst.Hr16,0) = 1, ISNULL(ddh.Hr25,0), 0)) * ISNULL(tscp.Hr16, 0)
                  + (ISNULL(ddh.Hr17,0) - IIF(md_dst.[date] IS NOT NULL AND ISNULL(md_dst.Hr17,0) = 1, ISNULL(ddh.Hr25,0), 0)) * ISNULL(tscp.Hr17, 0)
                  + (ISNULL(ddh.Hr18,0) - IIF(md_dst.[date] IS NOT NULL AND ISNULL(md_dst.Hr18,0) = 1, ISNULL(ddh.Hr25,0), 0)) * ISNULL(tscp.Hr18, 0)
                  + (ISNULL(ddh.Hr19,0) - IIF(md_dst.[date] IS NOT NULL AND ISNULL(md_dst.Hr19,0) = 1, ISNULL(ddh.Hr25,0), 0)) * ISNULL(tscp.Hr19, 0)
                  + (ISNULL(ddh.Hr20,0) - IIF(md_dst.[date] IS NOT NULL AND ISNULL(md_dst.Hr20,0) = 1, ISNULL(ddh.Hr25,0), 0)) * ISNULL(tscp.Hr20, 0)
                  + (ISNULL(ddh.Hr21,0) - IIF(md_dst.[date] IS NOT NULL AND ISNULL(md_dst.Hr21,0) = 1, ISNULL(ddh.Hr25,0), 0)) * ISNULL(tscp.Hr21, 0)
                  + (ISNULL(ddh.Hr22,0) - IIF(md_dst.[date] IS NOT NULL AND ISNULL(md_dst.Hr22,0) = 1, ISNULL(ddh.Hr25,0), 0)) * ISNULL(tscp.Hr22, 0)
                  + (ISNULL(ddh.Hr23,0) - IIF(md_dst.[date] IS NOT NULL AND ISNULL(md_dst.Hr23,0) = 1, ISNULL(ddh.Hr25,0), 0)) * ISNULL(tscp.Hr23, 0)
                  + (ISNULL(ddh.Hr24,0) - IIF(md_dst.[date] IS NOT NULL AND ISNULL(md_dst.Hr24,0) = 1, ISNULL(ddh.Hr25,0), 0)) * ISNULL(tscp.Hr24, 0)
                  + ISNULL(ddh.Hr25,0) * ISNULL(tscp.Hr25, 0)) [profile_volume]
     FROM deal_detail_hour ddh 
	 INNER JOIN #temp_source_price_curve tscp
		ON YEAR(tscp.maturity_date) = YEAR(sdd.term_start)
		AND MONTH(tscp.maturity_date) = MONTH(sdd.term_start)
		AND tscp.[minute] = ISNULL([period],tscp.[minute])
		AND ddh.term_date = tscp.maturity_date
	LEFT JOIN #temp_mv90_dst md_dst
		ON CAST(md_dst.[date] AS DATE) = CAST(ddh.term_date AS DATE)
	 WHERE profile_Id = sdd.profile_id 
	 AND YEAR(ddh.term_date) = YEAR(sdd.term_start)
	 AND MONTH(ddh.term_date) = MONTH(sdd.term_start)
     GROUP BY dbo.fnagetcontractmonth(term_date)--, [period]
 ) pf
 WHERE sdd.source_deal_header_id = @_source_deal_header_id
 AND dbo.fnagetcontractmonth(sdd.term_start) = @_prod_date
 --AND sdd.source_deal_detail_id = @_source_deal_detail_id
', report_id = @report_id_data_source_dest,
	system_defined = '0'
	,category = '106501' 
	WHERE [name] = 'Imbalance'
		AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1)
		
	
	IF OBJECT_ID('tempdb..#data_source_column', 'U') IS NOT NULL
		DROP TABLE #data_source_column	
	CREATE TABLE #data_source_column(column_id INT)	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Imbalance'
	            AND dsc.name =  'hour'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Hour'
			   , reqd_param = NULL, widget_id = 1, datatype_id = 4, param_data_source = NULL, param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 2, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Imbalance'
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
		INNER JOIN data_source ds ON ds.[name] = 'Imbalance'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Imbalance'
	            AND dsc.name =  'leg'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Leg'
			   , reqd_param = NULL, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 2, key_column = 0, required_filter = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Imbalance'
			AND dsc.name =  'leg'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'leg' AS [name], 'Leg' AS ALIAS, NULL AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column, 0 AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Imbalance'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Imbalance'
	            AND dsc.name =  'mins'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Mins'
			   , reqd_param = NULL, widget_id = 1, datatype_id = 4, param_data_source = NULL, param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 2, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Imbalance'
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
		INNER JOIN data_source ds ON ds.[name] = 'Imbalance'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Imbalance'
	            AND dsc.name =  'prod_date'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Prod Date'
			   , reqd_param = NULL, widget_id = 6, datatype_id = 2, param_data_source = NULL, param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 4, key_column = 0, required_filter = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Imbalance'
			AND dsc.name =  'prod_date'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'prod_date' AS [name], 'Prod Date' AS ALIAS, NULL AS reqd_param, 6 AS widget_id, 2 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,4 AS column_template, 0 AS key_column, 0 AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Imbalance'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Imbalance'
	            AND dsc.name =  'value'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Value'
			   , reqd_param = NULL, widget_id = 1, datatype_id = 3, param_data_source = NULL, param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 2, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Imbalance'
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
		INNER JOIN data_source ds ON ds.[name] = 'Imbalance'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Imbalance'
	            AND dsc.name =  'source_deal_header_id'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Deal ID'
			   , reqd_param = NULL, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 0, key_column = 0, required_filter = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Imbalance'
			AND dsc.name =  'source_deal_header_id'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'source_deal_header_id' AS [name], 'Deal ID' AS ALIAS, NULL AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, 0 AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Imbalance'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Imbalance'
	            AND dsc.name =  'counterparty_id'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Counterparty ID'
			   , reqd_param = NULL, widget_id = 1, datatype_id = 4, param_data_source = NULL, param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 2, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Imbalance'
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
		INNER JOIN data_source ds ON ds.[name] = 'Imbalance'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Imbalance'
	            AND dsc.name =  'contract_id'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Contract ID'
			   , reqd_param = NULL, widget_id = 1, datatype_id = 4, param_data_source = NULL, param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 2, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Imbalance'
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
		INNER JOIN data_source ds ON ds.[name] = 'Imbalance'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Imbalance'
	            AND dsc.name =  'source_deal_detail_id'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Source Deal Detail Id'
			   , reqd_param = NULL, widget_id = 1, datatype_id = 4, param_data_source = NULL, param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 2, key_column = 0, required_filter = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Imbalance'
			AND dsc.name =  'source_deal_detail_id'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'source_deal_detail_id' AS [name], 'Source Deal Detail Id' AS ALIAS, NULL AS reqd_param, 1 AS widget_id, 4 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column, 0 AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Imbalance'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	DELETE dsc
	FROM data_source_column dsc 
	INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		AND ds.[name] = 'Imbalance'
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
	