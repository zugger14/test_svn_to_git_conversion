BEGIN TRY
		BEGIN TRAN
	
	DECLARE @report_id_data_source_dest INT 
	
	SELECT @report_id_data_source_dest = report_id
	FROM report r
	WHERE r.[name] = NULL
	IF EXISTS (SELECT 1 
	           FROM data_source 
	           WHERE [name] = 'Position View Hourly With Block Type'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
			
	BEGIN
		UPDATE data_source
		SET alias = 'PVHWBT', description = ''
		, [tsql] = CAST('' AS VARCHAR(MAX)) + 'IF OBJECT_ID(N''tempdb..#books'') IS NOT NULL
	DROP TABLE #books
IF OBJECT_ID(N''tempdb..#term_date'') IS NOT NULL
	DROP TABLE #term_date

DECLARE @_block_type_group_id INT,@_sql VARCHAR(MAX)

IF ''@user_defined_block_id'' <> ''NULL'' 
	SET @_block_type_group_id = ''@user_defined_block_id''

DECLARE @_term_start_from datetime 
DECLARE @_term_start_to datetime 

IF ''@period_from'' <> ''NULL'' 
	SET @_term_start_from = dbo.FNAGetTermStartDate(''m'',''@as_of_date'',''@period_from'')

IF ''@period_to'' <> ''NULL'' 
SET @_term_start_to = dbo.FNAGetTermENDDate(''m'',''@as_of_date'',''@period_to'')

CREATE TABLE #books ( fas_book_id INT, source_system_book_id1 INT ,source_system_book_id2 INT,source_system_book_id3 INT,source_system_book_id4 INT)    
INSERT INTO #books
SELECT DISTINCT book.entity_id,
       ssbm.source_system_book_id1,
       ssbm.source_system_book_id2,
       ssbm.source_system_book_id3,
       ssbm.source_system_book_id4 fas_book_id
FROM   portfolio_hierarchy book(NOLOCK)
INNER JOIN Portfolio_hierarchy stra(NOLOCK)
	ON  book.parent_entity_id = stra.entity_id
INNER JOIN portfolio_hierarchy sub (NOLOCK)
	ON  stra.parent_entity_id = sub.entity_id
INNER JOIN source_system_book_map ssbm
	ON  ssbm.fas_book_id = book.entity_id
WHERE  (fas_deal_type_value_id IS NULL OR fas_deal_type_value_id BETWEEN 400 AND 401)
AND (''@sub_id'' = ''NULL'' OR sub.entity_id IN (@sub_id)) 
AND (''@stra_id'' = ''NULL'' OR stra.entity_id IN (@stra_id)) 
AND (''@book_id'' = ''NULL'' OR book.entity_id IN (@book_id))
AND (''@sub_book_id'' = ''NULL'' OR ssbm.book_deal_type_map_id IN (@sub_book_id))

IF OBJECT_ID(N''tempdb..#temp_report_hourly_position_breakdown'') IS NOT NULL
	DROP TABLE #temp_report_hourly_position_breakdown
	
SELECT 
DISTINCT ISNULL(spcd.block_define_id,300501) block_define_id,s.term_start,s.term_END 
INTO #temp_report_hourly_position_breakdown
FROM report_hourly_position_breakdown s  (nolock)  
INNER JOIN #books bk ON bk.fas_book_id=s.fas_book_id 
	AND bk.source_system_book_id1=s.source_system_book_id1 AND bk.source_system_book_id2=s.source_system_book_id2 
	AND bk.source_system_book_id3=s.source_system_book_id3 AND bk.source_system_book_id4=s.source_system_book_id4 
INNER JOIN [deal_status_group] dsg ON dsg.status_value_id = s.deal_status_id  
LEFT JOIN source_price_curve_def spcd with (nolock) 
ON spcd.source_curve_def_id=s.curve_id 

CREATE TABLE #term_date( block_define_id int ,term_date date,term_start date,term_END date,
	hr1 tinyint,hr2 tinyint,hr3 tinyint,hr4 tinyint,hr5 tinyint,hr6 tinyint,hr7 tinyint,hr8 tinyint
	,hr9 tinyint,hr10 tinyint,hr11 tinyint,hr12 tinyint,hr13 tinyint,hr14 tinyint,hr15 tinyint,hr16 tinyint
	,hr17 tinyint,hr18 tinyint,hr19 tinyint,hr20 tinyint,hr21 tinyint,hr22 tinyint,hr23 tinyint,hr24 tinyint,add_dst_hour int
)
INSERT INTO #term_date(block_define_id  ,term_date,term_start,term_END,
hr1 ,hr2 ,hr3 ,hr4 ,hr5 ,hr6 ,hr7 ,hr8 ,hr9 ,hr10 ,hr11 ,hr12 ,hr13 ,hr14 ,hr15 ,hr16 
,hr17 ,hr18 ,hr19 ,hr20 ,hr21 ,hr22 ,hr23 ,hr24 ,add_dst_hour
)
SELECT DISTINCT a.block_define_id  ,hb.term_date,a.term_start ,a.term_END,
	hb.hr1 ,hb.hr2 ,hb.hr3 ,hb.hr4 ,hb.hr5 ,hb.hr6 ,hb.hr7 ,hb.hr8 
	,hb.hr9 ,hb.hr10 ,hb.hr11 ,hb.hr12 ,hb.hr13 ,hb.hr14 ,hb.hr15 ,hb.hr16 
	,hb.hr17 ,hb.hr18 ,hb.hr19 ,hb.hr20 ,hb.hr21 ,hb.hr22 ,hb.hr23 ,hb.hr24 ,hb.add_dst_hour
FROM #temp_report_hourly_position_breakdown a
		outer apply	(SELECT h.* FROM hour_block_term h with (nolock) WHERE block_define_id=a.block_define_id and h.block_type=12000 
		and term_date between a.term_start and a.term_END 
) hb
----- hourly position deal start
IF OBJECT_ID(N''tempdb..#temp_hourly_position_deal'') IS NOT NULL
	DROP TABLE #temp_hourly_position_deal

CREATE TABLE #temp_hourly_position_deal(
curve_id INT ,location_id INT,term_start DATETIME,period INT,deal_date DATETIME,deal_volume_uom_id DATETIME,
physical_financial_flag varchar(2) COLLATE DATABASE_DEFAULT,hr1 FLOAT,hr2 FLOAT,hr3 FLOAT,hr4 FLOAT,hr5 FLOAT,hr6 FLOAT,hr7 FLOAT,hr8 FLOAT,
hr9 FLOAT,hr10 FLOAT,hr11 FLOAT,hr12 FLOAT,hr13 FLOAT,hr14 FLOAT,hr15 FLOAT,hr16 FLOAT,hr17 FLOAT,hr18 FLOAT,hr19 FLOAT,
hr20 FLOAT,hr21 FLOAT,hr22 FLOAT,hr23 FLOAT,hr24 FLOAT,hr25 FLOAT,source_deal_header_id INT,commodity_id INT,
counterparty_id INT,fas_book_id INT,source_system_book_id1 INT,source_system_book_id2 INT,source_system_book_id3 INT,
source_system_book_id4 INT,expiration_date DATETIME,is_fixedvolume VARCHAR(2) COLLATE DATABASE_DEFAULT,deal_status_id INT,deal_volume_frequency VARCHAR(2) COLLATE DATABASE_DEFAULT,term_end DATETIME)

SET @_sql =	
''INSERT INTO #temp_hourly_position_deal (curve_id,location_id,term_start,period,deal_date,deal_volume_uom_id,physical_financial_flag,hr1,hr2,hr3,hr4,hr5,hr6,hr7,hr8,hr9,hr10,hr11,hr12,hr13,hr14,hr15,hr16,hr17,hr18,hr19,hr20,hr21,hr22,hr23,hr24,hr25,source_deal_header_id,commodity_id,counterparty_id,fas_book_id,source_system_book_id1,source_system_book_id2,source_system_book_id3,source_system_book_id4,expiration_date,is_fixedvolume,deal_status_id,deal_volume_frequency,term_END)
SELECT s.curve_id,s.location_id,s.term_start,s.period,s.deal_date,s.deal_volume_uom_id,s.physical_financial_flag,s.hr1,s.hr2,s.hr3,s.hr4,s.hr5,s.hr6,s.hr7,s.hr8,s.hr9,s.hr10,s.hr11,s.hr12,s.hr13,s.hr14,s.hr15,s.hr16,s.hr17,s.hr18,s.hr19,s.hr20,s.hr21,s.hr22,s.hr23,s.hr24,s.hr25,s.source_deal_header_id,s.commodity_id,s.counterparty_id,s.fas_book_id,s.source_system_book_id1,s.source_system_book_id2
	,s.source_system_book_id3,s.source_system_book_id4,s.expiration_date,''''n'''' AS is_fixedvolume,deal_status_id,sdd.deal_volume_frequency,sdd.term_END 
FROM report_hourly_position_deal s  (nolock)  INNER JOIN #books bk ON bk.fas_book_id=s.fas_book_id AND bk.source_system_book_id1=s.source_system_book_id1	
AND bk.source_system_book_id2=s.source_system_book_id2 AND bk.source_system_book_id3=s.source_system_book_id3
AND bk.source_system_book_id4=s.source_system_book_id4 
INNER JOIN [deal_status_group] dsg ON  dsg.status_value_id = s.deal_status_id 
LEFT JOIN source_price_curve_def spcd ON spcd.source_curve_def_id=s.curve_id
LEFT JOIN source_deal_detail sdd 
	ON s.term_start BETWEEN sdd.term_start AND sdd.term_end
	AND sdd.source_deal_detail_id = s.source_deal_detail_id 
WHERE 1=1
AND s.deal_date<=''''@as_of_date''''  AND s.expiration_date > ''''@as_of_date'''' AND s.term_start > ''''@as_of_date'''' ''
+		
CASE 
	WHEN @_term_start_from IS NULL AND @_term_start_to IS NULL THEN ''''
	WHEN @_term_start_to IS NULL THEN '' AND s.term_start >= CAST('''''' + CAST(@_term_start_from AS VARCHAR(100)) + '''''' as DATETIME)''
	WHEN @_term_start_from IS NULL THEN '' AND s.term_start =< CAST('''''' +  CAST(@_term_start_to AS VARCHAR(100)) + ''''''as DATETIME)'' 
	ELSE '' AND s.term_start BETWEEN CAST('''''' + CAST(@_term_start_from AS VARCHAR(100)) + '''''' as DATETIME) AND CAST('''''' +  CAST(@_term_start_to AS VARCHAR(100)) + ''''''as DATETIME)''
END

PRINT(@_sql)
EXEC(@_sql)
----- hourly position deal END

----- hourly position profile start
IF OBJECT_ID(N''tempdb..#temp_hourly_position_profile'') IS NOT NULL
	DROP TABLE #temp_hourly_position_profile

CREATE TABLE #temp_hourly_position_profile(
curve_id INT ,location_id INT,term_start DATETIME,period INT,deal_date DATETIME,deal_volume_uom_id DATETIME,
physical_financial_flag varchar(2) COLLATE DATABASE_DEFAULT,hr1 FLOAT,hr2 FLOAT,hr3 FLOAT,hr4 FLOAT,hr5 FLOAT,hr6 FLOAT,hr7 FLOAT,hr8 FLOAT,
hr9 FLOAT,hr10 FLOAT,hr11 FLOAT,hr12 FLOAT,hr13 FLOAT,hr14 FLOAT,hr15 FLOAT,hr16 FLOAT,hr17 FLOAT,hr18 FLOAT,hr19 FLOAT,
hr20 FLOAT,hr21 FLOAT,hr22 FLOAT,hr23 FLOAT,hr24 FLOAT,hr25 FLOAT,source_deal_header_id INT,commodity_id INT,
counterparty_id INT,fas_book_id INT,source_system_book_id1 INT,source_system_book_id2 INT,source_system_book_id3 INT,
source_system_book_id4 INT,expiration_date DATETIME,is_fixedvolume VARCHAR(2) COLLATE DATABASE_DEFAULT,deal_status_id INT,deal_volume_frequency VARCHAR(2) COLLATE DATABASE_DEFAULT,term_end DATETIME)

SET @_sql = ''
			INSERT INTO #temp_hourly_position_profile (curve_id,location_id,term_start,period,deal_date,deal_volume_uom_id,physical_financial_flag,hr1,hr2,hr3,hr4,hr5,hr6,hr7,hr8,hr9,hr10,hr11,hr12,hr13,hr14,hr15,hr16,hr17,hr18,hr19,hr20,hr21,hr22,hr23,hr24,hr25,source_deal_header_id,commodity_id,counterparty_id,fas_book_id,source_system_book_id1,source_system_book_id2,source_system_book_id3,source_system_book_id4,expiration_date,is_fixedvolume,deal_status_id,deal_volume_frequency,term_END)
			SELECT s.curve_id,s.location_id,s.term_start,s.period,s.deal_date,s.deal_volume_uom_id,s.physical_financial_flag,s.hr1,s.hr2,s.hr3,s.hr4,s.hr5,s.hr6,s.hr7,s.hr8,s.hr9,s.hr10,s.hr11,s.hr12,s.hr13,s.hr14,s.hr15,s.hr16,s.hr17,s.hr18,s.hr19,s.hr20,s.hr21,s.hr22,s.hr23,s.hr24,s.hr25,s.source_deal_header_id,s.commodity_id,s.counterparty_id,s.fas_book_id,s.source_system_book_id1,s.source_system_book_id2,s.source_system_book_id3,s.source_system_book_id4 
			,s.expiration_date,''''n'''' AS is_fixedvolume,deal_status_id,sdd.deal_volume_frequency,sdd.term_END 
			FROM report_hourly_position_profile s  (nolock)  
			INNER JOIN #books bk ON bk.fas_book_id=s.fas_book_id 
			AND bk.source_system_book_id1=s.source_system_book_id1	
			AND bk.source_system_book_id2=s.source_system_book_id2	AND bk.source_system_book_id3=s.source_system_book_id3
			AND bk.source_system_book_id4=s.source_system_book_id4 
			INNER JOIN [deal_status_group] dsg ON  dsg.status_value_id = s.deal_status_id 
			LEFT JOIN source_price_curve_def spcd ON spcd.source_curve_def_id=s.curve_id
			LEFT JOIN source_deal_detail sdd 
				ON sdd.source_deal_header_id = s.source_deal_header_id  
				AND sdd.curve_id = s.curve_id and ISNULL(sdd.location_id,-1)=ISNULL(s.location_id,-1)
				AND s.term_start BETWEEN sdd.term_start AND sdd.term_END
			WHERE  1=1
			AND s.deal_date<=''''@as_of_date''''  AND s.expiration_date > ''''@as_of_date'''' AND s.term_start > ''''@as_of_date''''''
			+		
			CASE 
				WHEN @_term_start_from IS NULL AND @_term_start_to IS NULL THEN ''''
				WHEN @_term_start_to IS NULL THEN '' AND s.deal_date >= CAST('''''' + CAST(@_term_start_from AS VARCHAR(100)) + '''''' as DATETIME)''
				WHEN @_term_start_from IS NULL THEN '' AND s.deal_date =< CAST('''''' +  CAST(@_term_start_to AS VARCHAR(100)) + ''''''as DATETIME)'' 
				ELSE '' AND s.deal_date BETWEEN CAST('''''' + CAST(@_term_start_from AS VARCHAR(100)) + '''''' as DATETIME) AND CAST('''''' +  CAST(@_term_start_to AS VARCHAR(100)) + ''''''as DATETIME)''
			END

PRINT(@_sql) 
EXEC (@_sql)
---- hourly position profile END

IF OBJECT_ID(N''tempdb..#temp_hourly_position_breakdown'') IS NOT NULL
	DROP TABLE #temp_hourly_position_breakdown
----- hourly position breakdown start

CREATE TABLE #temp_hourly_position_breakdown(
curve_id INT ,location_id INT,term_start DATETIME,period INT,deal_date DATETIME,deal_volume_uom_id DATETIME,
physical_financial_flag varchar(2) COLLATE DATABASE_DEFAULT,hr1 FLOAT,hr2 FLOAT,hr3 FLOAT,hr4 FLOAT,hr5 FLOAT,hr6 FLOAT,hr7 FLOAT,hr8 FLOAT,
hr9 FLOAT,hr10 FLOAT,hr11 FLOAT,hr12 FLOAT,hr13 FLOAT,hr14 FLOAT,hr15 FLOAT,hr16 FLOAT,hr17 FLOAT,hr18 FLOAT,hr19 FLOAT,
hr20 FLOAT,hr21 FLOAT,hr22 FLOAT,hr23 FLOAT,hr24 FLOAT,hr25 FLOAT,source_deal_header_id INT,commodity_id INT,
counterparty_id INT,fas_book_id INT,source_system_book_id1 INT,source_system_book_id2 INT,source_system_book_id3 INT,
source_system_book_id4 INT,expiration_date DATETIME,is_fixedvolume VARCHAR(2) COLLATE DATABASE_DEFAULT,deal_status_id INT,deal_volume_frequency VARCHAR(2) COLLATE DATABASE_DEFAULT,term_end DATETIME)

SET @_sql = ''
INSERT INTO #temp_hourly_position_breakdown (curve_id,location_id,term_start,period,deal_date,deal_volume_uom_id,physical_financial_flag,hr1,hr2,hr3,hr4,hr5,hr6,hr7,hr8,hr9,hr10,hr11,hr12,hr13,hr14,hr15,hr16,hr17,hr18,hr19,hr20,hr21,hr22,hr23,hr24,hr25,source_deal_header_id,commodity_id,counterparty_id,fas_book_id,source_system_book_id1,source_system_book_id2,source_system_book_id3,source_system_book_id4,expiration_date,is_fixedvolume,deal_status_id,deal_volume_frequency,term_END)
SELECT s.curve_id,ISNULL(s.location_id,-1) location_id,hb.term_date term_start,0 period,s.deal_date,s.deal_volume_uom_id,s.physical_financial_flag
,(CAST(CAST(CAST(s.calc_volume AS NUMERIC(22,10))* CAST(ISNULL(hb.hr1,0) AS NUMERIC(1,0)) AS NUMERIC(22,10))*CAST(CASE WHEN ISNULL(hb.add_dst_hour,0)=1 THEN 2 ELSE 1 END AS NUMERIC(1,0)) AS NUMERIC(22,10)))/CAST(NULLIF(ISNULL(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) AS NUMERIC(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,''''@as_of_date'''')) AS VARCHAR)+''''-''''+CAST(MONTH(DATEADD(m,1,''''@as_of_date'''')) AS VARCHAR)+''''-01'''' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  AS Hr1
,(CAST(CAST(CAST(s.calc_volume AS NUMERIC(22,10))* CAST(ISNULL(hb.hr2,0) AS NUMERIC(1,0)) AS NUMERIC(22,10))*CAST(CASE WHEN ISNULL(hb.add_dst_hour,0)=2 THEN 2 ELSE 1 END AS NUMERIC(1,0)) AS NUMERIC(22,10)))/CAST(NULLIF(ISNULL(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) AS NUMERIC(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,''''@as_of_date'''')) AS VARCHAR)+''''-''''+CAST(MONTH(DATEADD(m,1,''''@as_of_date'''')) AS VARCHAR)+''''-01'''' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  AS Hr2
,(CAST(CAST(CAST(s.calc_volume AS NUMERIC(22,10))* CAST(ISNULL(hb.hr3,0) AS NUMERIC(1,0)) AS NUMERIC(22,10))*CAST(CASE WHEN ISNULL(hb.add_dst_hour,0)=3 THEN 2 ELSE 1 END AS NUMERIC(1,0)) AS NUMERIC(22,10)))/CAST(NULLIF(ISNULL(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) AS NUMERIC(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,''''@as_of_date'''')) AS VARCHAR)+''''-''''+CAST(MONTH(DATEADD(m,1,''''@as_of_date'''')) AS VARCHAR)+''''-01'''' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  AS Hr3
,(CAST(CAST(CAST(s.calc_volume AS NUMERIC(22,10))* CAST(ISNULL(hb.hr4,0) AS NUMERIC(1,0)) AS NUMERIC(22,10))*CAST(CASE WHEN ISNULL(hb.add_dst_hour,0)=4 THEN 2 ELSE 1 END AS NUMERIC(1,0)) AS NUMERIC(22,10)))/CAST(NULLIF(ISNULL(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) AS NUMERIC(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,''''@as_of_date'''')) AS VARCHAR)+''''-''''+CAST(MONTH(DATEADD(m,1,''''@as_of_date'''')) AS VARCHAR)+''''-01'''' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  AS Hr4
,(CAST(CAST(CAST(s.calc_volume AS NUMERIC(22,10))* CAST(ISNULL(hb.hr5,0) AS NUMERIC(1,0)) AS NUMERIC(22,10))*CAST(CASE WHEN ISNULL(hb.add_dst_hour,0)=5 THEN 2 ELSE 1 END AS NUMERIC(1,0)) AS NUMERIC(22,10)))/CAST(NULLIF(ISNULL(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) AS NUMERIC(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,''''@as_of_date'''')) AS VARCHAR)+''''-''''+CAST(MONTH(DATEADD(m,1,''''@as_of_date'''')) AS VARCHAR)+''''-01'''' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  AS Hr5
,(CAST(CAST(CAST(s.calc_volume AS NUMERIC(22,10))* CAST(ISNULL(hb.hr6,0) AS NUMERIC(1,0)) AS NUMERIC(22,10))*CAST(CASE WHEN ISNULL(hb.add_dst_hour,0)=6 THEN 2 ELSE 1 END AS NUMERIC(1,0)) AS NUMERIC(22,10)))/CAST(NULLIF(ISNULL(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) AS NUMERIC(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,''''@as_of_date'''')) AS VARCHAR)+''''-''''+CAST(MONTH(DATEADD(m,1,''''@as_of_date'''')) AS VARCHAR)+''''-01'''' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  AS Hr6
,(CAST(CAST(CAST(s.calc_volume AS NUMERIC(22,10))* CAST(ISNULL(hb.hr7,0) AS NUMERIC(1,0)) AS NUMERIC(22,10))*CAST(CASE WHEN ISNULL(hb.add_dst_hour,0)=7 THEN 2 ELSE 1 END AS NUMERIC(1,0)) AS NUMERIC(22,10)))/CAST(NULLIF(ISNULL(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) AS NUMERIC(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,''''@as_of_date'''')) AS VARCHAR)+''''-''''+CAST(MONTH(DATEADD(m,1,''''@as_of_date'''')) AS VARCHAR)+''''-01'''' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  AS Hr7
,(CAST(CAST(CAST(s.calc_volume AS NUMERIC(22,10))* CAST(ISNULL(hb.hr8,0) AS NUMERIC(1,0)) AS NUMERIC(22,10))*CAST(CASE WHEN ISNULL(hb.add_dst_hour,0)=8 THEN 2 ELSE 1 END AS NUMERIC(1,0)) AS NUMERIC(22,10)))/CAST(NULLIF(ISNULL(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) AS NUMERIC(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,''''@as_of_date'''')) AS VARCHAR)+''''-''''+CAST(MONTH(DATEADD(m,1,''''@as_of_date'''')) AS VARCHAR)+''''-01'''' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  AS Hr8
,(CAST(CAST(CAST(s.calc_volume AS NUMERIC(22,10))* CAST(ISNULL(hb.hr9,0) AS NUMERIC(1,0)) AS NUMERIC(22,10))*CAST(CASE WHEN ISNULL(hb.add_dst_hour,0)=9 THEN 2 ELSE 1 END AS NUMERIC(1,0)) AS NUMERIC(22,10)))/CAST(NULLIF(ISNULL(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) AS NUMERIC(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,''''@as_of_date'''')) AS VARCHAR)+''''-''''+CAST(MONTH(DATEADD(m,1,''''@as_of_date'''')) AS VARCHAR)+''''-01'''' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  AS Hr9
,(CAST(CAST(CAST(s.calc_volume AS NUMERIC(22,10))* CAST(ISNULL(hb.hr10,0) AS NUMERIC(1,0)) AS NUMERIC(22,10))*CAST(CASE WHEN ISNULL(hb.add_dst_hour,0)=10 THEN 2 ELSE 1 END AS NUMERIC(1,0)) AS NUMERIC(22,10)))/CAST(NULLIF(ISNULL(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) AS NUMERIC(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,''''@as_of_date'''')) AS VARCHAR)+''''-''''+CAST(MONTH(DATEADD(m,1,''''@as_of_date'''')) AS VARCHAR)+''''-01'''' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  AS Hr10
,(CAST(CAST(CAST(s.calc_volume AS NUMERIC(22,10))* CAST(ISNULL(hb.hr11,0) AS NUMERIC(1,0)) AS NUMERIC(22,10))*CAST(CASE WHEN ISNULL(hb.add_dst_hour,0)=11 THEN 2 ELSE 1 END AS NUMERIC(1,0)) AS NUMERIC(22,10)))/CAST(NULLIF(ISNULL(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) AS NUMERIC(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,''''@as_of_date'''')) AS VARCHAR)+''''-''''+CAST(MONTH(DATEADD(m,1,''''@as_of_date'''')) AS VARCHAR)+''''-01'''' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  AS Hr11
,(CAST(CAST(CAST(s.calc_volume AS NUMERIC(22,10))* CAST(ISNULL(hb.hr12,0) AS NUMERIC(1,0)) AS NUMERIC(22,10))*CAST(CASE WHEN ISNULL(hb.add_dst_hour,0)=12 THEN 2 ELSE 1 END AS NUMERIC(1,0)) AS NUMERIC(22,10)))/CAST(NULLIF(ISNULL(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) AS NUMERIC(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,''''@as_of_date'''')) AS VARCHAR)+''''-''''+CAST(MONTH(DATEADD(m,1,''''@as_of_date'''')) AS VARCHAR)+''''-01'''' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  AS Hr12
,(CAST(CAST(CAST(s.calc_volume AS NUMERIC(22,10))* CAST(ISNULL(hb.hr13,0) AS NUMERIC(1,0)) AS NUMERIC(22,10))*CAST(CASE WHEN ISNULL(hb.add_dst_hour,0)=13 THEN 2 ELSE 1 END AS NUMERIC(1,0)) AS NUMERIC(22,10)))/CAST(NULLIF(ISNULL(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) AS NUMERIC(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,''''@as_of_date'''')) AS VARCHAR)+''''-''''+CAST(MONTH(DATEADD(m,1,''''@as_of_date'''')) AS VARCHAR)+''''-01'''' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  AS Hr13
,(CAST(CAST(CAST(s.calc_volume AS NUMERIC(22,10))* CAST(ISNULL(hb.hr14,0) AS NUMERIC(1,0)) AS NUMERIC(22,10))*CAST(CASE WHEN ISNULL(hb.add_dst_hour,0)=14 THEN 2 ELSE 1 END AS NUMERIC(1,0)) AS NUMERIC(22,10)))/CAST(NULLIF(ISNULL(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) AS NUMERIC(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,''''@as_of_date'''')) AS VARCHAR)+''''-''''+CAST(MONTH(DATEADD(m,1,''''@as_of_date'''')) AS VARCHAR)+''''-01'''' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  AS Hr14
,(CAST(CAST(CAST(s.calc_volume AS NUMERIC(22,10))* CAST(ISNULL(hb.hr15,0) AS NUMERIC(1,0)) AS NUMERIC(22,10))*CAST(CASE WHEN ISNULL(hb.add_dst_hour,0)=15 THEN 2 ELSE 1 END AS NUMERIC(1,0)) AS NUMERIC(22,10)))/CAST(NULLIF(ISNULL(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) AS NUMERIC(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,''''@as_of_date'''')) AS VARCHAR)+''''-''''+CAST(MONTH(DATEADD(m,1,''''@as_of_date'''')) AS VARCHAR)+''''-01'''' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  AS Hr15
,(CAST(CAST(CAST(s.calc_volume AS NUMERIC(22,10))* CAST(ISNULL(hb.hr16,0) AS NUMERIC(1,0)) AS NUMERIC(22,10))*CAST(CASE WHEN ISNULL(hb.add_dst_hour,0)=16 THEN 2 ELSE 1 END AS NUMERIC(1,0)) AS NUMERIC(22,10)))/CAST(NULLIF(ISNULL(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) AS NUMERIC(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,''''@as_of_date'''')) AS VARCHAR)+''''-''''+CAST(MONTH(DATEADD(m,1,''''@as_of_date'''')) AS VARCHAR)+''''-01'''' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  AS Hr16
,(CAST(CAST(CAST(s.calc_volume AS NUMERIC(22,10))* CAST(ISNULL(hb.hr17,0) AS NUMERIC(1,0)) AS NUMERIC(22,10))*CAST(CASE WHEN ISNULL(hb.add_dst_hour,0)=17 THEN 2 ELSE 1 END AS NUMERIC(1,0)) AS NUMERIC(22,10)))/CAST(NULLIF(ISNULL(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) AS NUMERIC(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,''''@as_of_date'''')) AS VARCHAR)+''''-''''+CAST(MONTH(DATEADD(m,1,''''@as_of_date'''')) AS VARCHAR)+''''-01'''' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  AS Hr17
,(CAST(CAST(CAST(s.calc_volume AS NUMERIC(22,10))* CAST(ISNULL(hb.hr18,0) AS NUMERIC(1,0)) AS NUMERIC(22,10))*CAST(CASE WHEN ISNULL(hb.add_dst_hour,0)=18 THEN 2 ELSE 1 END AS NUMERIC(1,0)) AS NUMERIC(22,10)))/CAST(NULLIF(ISNULL(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) AS NUMERIC(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,''''@as_of_date'''')) AS VARCHAR)+''''-''''+CAST(MONTH(DATEADD(m,1,''''@as_of_date'''')) AS VARCHAR)+''''-01'''' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  AS Hr18
,(CAST(CAST(CAST(s.calc_volume AS NUMERIC(22,10))* CAST(ISNULL(hb.hr19,0) AS NUMERIC(1,0)) AS NUMERIC(22,10))*CAST(CASE WHEN ISNULL(hb.add_dst_hour,0)=19 THEN 2 ELSE 1 END AS NUMERIC(1,0)) AS NUMERIC(22,10)))/CAST(NULLIF(ISNULL(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) AS NUMERIC(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,''''@as_of_date'''')) AS VARCHAR)+''''-''''+CAST(MONTH(DATEADD(m,1,''''@as_of_date'''')) AS VARCHAR)+''''-01'''' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  AS Hr19
,(CAST(CAST(CAST(s.calc_volume AS NUMERIC(22,10))* CAST(ISNULL(hb.hr20,0) AS NUMERIC(1,0)) AS NUMERIC(22,10))*CAST(CASE WHEN ISNULL(hb.add_dst_hour,0)=20 THEN 2 ELSE 1 END AS NUMERIC(1,0)) AS NUMERIC(22,10)))/CAST(NULLIF(ISNULL(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) AS NUMERIC(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,''''@as_of_date'''')) AS VARCHAR)+''''-''''+CAST(MONTH(DATEADD(m,1,''''@as_of_date'''')) AS VARCHAR)+''''-01'''' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  AS Hr20
,(CAST(CAST(CAST(s.calc_volume AS NUMERIC(22,10))* CAST(ISNULL(hb.hr21,0) AS NUMERIC(1,0)) AS NUMERIC(22,10))*CAST(CASE WHEN ISNULL(hb.add_dst_hour,0)=21 THEN 2 ELSE 1 END AS NUMERIC(1,0)) AS NUMERIC(22,10)))/CAST(NULLIF(ISNULL(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) AS NUMERIC(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,''''@as_of_date'''')) AS VARCHAR)+''''-''''+CAST(MONTH(DATEADD(m,1,''''@as_of_date'''')) AS VARCHAR)+''''-01'''' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  AS Hr21
,(CAST(CAST(CAST(s.calc_volume AS NUMERIC(22,10))* CAST(ISNULL(hb.hr22,0) AS NUMERIC(1,0)) AS NUMERIC(22,10))*CAST(CASE WHEN ISNULL(hb.add_dst_hour,0)=22 THEN 2 ELSE 1 END AS NUMERIC(1,0)) AS NUMERIC(22,10)))/CAST(NULLIF(ISNULL(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) AS NUMERIC(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,''''@as_of_date'''')) AS VARCHAR)+''''-''''+CAST(MONTH(DATEADD(m,1,''''@as_of_date'''')) AS VARCHAR)+''''-01'''' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  AS Hr22
,(CAST(CAST(CAST(s.calc_volume AS NUMERIC(22,10))* CAST(ISNULL(hb.hr23,0) AS NUMERIC(1,0)) AS NUMERIC(22,10))*CAST(CASE WHEN ISNULL(hb.add_dst_hour,0)=23 THEN 2 ELSE 1 END AS NUMERIC(1,0)) AS NUMERIC(22,10)))/CAST(NULLIF(ISNULL(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) AS NUMERIC(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,''''@as_of_date'''')) AS VARCHAR)+''''-''''+CAST(MONTH(DATEADD(m,1,''''@as_of_date'''')) AS VARCHAR)+''''-01'''' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  AS Hr23
,(CAST(CAST(CAST(s.calc_volume AS NUMERIC(22,10))* CAST(ISNULL(hb.hr24,0) AS NUMERIC(1,0)) AS NUMERIC(22,10))*CAST(CASE WHEN ISNULL(hb.add_dst_hour,0)=24 THEN 2 ELSE 1 END AS NUMERIC(1,0)) AS NUMERIC(22,10)))/CAST(NULLIF(ISNULL(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) AS NUMERIC(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,''''@as_of_date'''')) AS VARCHAR)+''''-''''+CAST(MONTH(DATEADD(m,1,''''@as_of_date'''')) AS VARCHAR)+''''-01'''' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  AS Hr24
,(CAST(CAST(s.calc_volume AS NUMERIC(22,10))* CAST(CASE WHEN ISNULL(hb.add_dst_hour,0)<=0 THEN 0 ELSE 1 END AS NUMERIC(1,0)) AS NUMERIC(22,10))) /CAST(NULLIF(ISNULL(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) AS NUMERIC(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,''''@as_of_date'''')) AS VARCHAR)+''''-''''+CAST(MONTH(DATEADD(m,1,''''@as_of_date'''')) AS VARCHAR)+''''-01'''' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END) AS Hr25 
,s.source_deal_header_id,s.commodity_id,s.counterparty_id,s.fas_book_id,s.source_system_book_id1,s.source_system_book_id2,s.source_system_book_id3,s.source_system_book_id4,CASE WHEN s.formula IN(''''dbo.FNACurveH'''',''''dbo.FNACurveD'''') THEN ISNULL(hg.exp_date,hb.term_date) WHEN ISNULL(spcd.hourly_volume_allocation,17601) IN(17603,17604) THEN ISNULL(hg.exp_date,s.expiration_date) ELSE s.expiration_date END expiration_date,''''y'''' AS is_fixedvolume ,deal_status_id, ''''m'''' [deal_volume_frequency],s.term_END [term_END] --[deal_volume_frequency] for finalcial deals are always monthly  
FROM report_hourly_position_breakdown s  (nolock)  
INNER JOIN #books bk ON bk.fas_book_id=s.fas_book_id
	AND bk.source_system_book_id1=s.source_system_book_id1 
	AND bk.source_system_book_id2=s.source_system_book_id2
	AND bk.source_system_book_id3=s.source_system_book_id3 
	AND bk.source_system_book_id4=s.source_system_book_id4
INNER JOIN [deal_status_group] dsg ON  dsg.status_value_id = s.deal_status_id 
LEFT JOIN source_price_curve_def spcd with (nolock) ON spcd.source_curve_def_id=s.curve_id 
LEFT JOIN source_price_curve_def spcd_proxy (nolock) ON spcd_proxy.source_curve_def_id=spcd.settlement_curve_id
outer apply (SELECT sum(volume_mult) term_no_hrs FROM hour_block_term hbt WHERE ISNULL(spcd.hourly_volume_allocation,17601) <17603 and hbt.block_define_id=COALESCE(spcd.block_define_id,300501)	and  hbt.block_type=COALESCE(spcd.block_type,12000) and hbt.term_date between s.term_start  and s.term_END ) term_hrs
outer apply ( SELECT sum(volume_mult) term_no_hrs FROM hour_block_term hbt inner join (SELECT DISTINCT exp_date FROM holiday_group h WHERE  h.hol_group_value_id=ISNULL(spcd.exp_calENDar_id,spcd_proxy.exp_calENDar_id) and h.exp_date between s.term_start  and s.term_END ) ex ON ex.exp_date=hbt.term_date
WHERE  ISNULL(spcd.hourly_volume_allocation,17601) IN(17603,17604) and hbt.block_define_id=COALESCE(spcd.block_define_id,300501)	and  hbt.block_type=COALESCE(spcd.block_type,12000) and hbt.term_date between s.term_start  and s.term_END) term_hrs_exp
LEFT JOIN #term_date hb ON hb.block_define_id=ISNULL(spcd.block_define_id,300501) and hb.term_start = s.term_start
and hb.term_END=s.term_END 
outer apply  (SELECT MAX(exp_date) exp_date FROM holiday_group h WHERE h.hol_date=hb.term_date AND 
h.hol_group_value_id=ISNULL(spcd.exp_calENDar_id,spcd_proxy.exp_calENDar_id) and h.hol_date between s.term_start  and s.term_END AND COALESCE(spcd_proxy.ratio_option,spcd.ratio_option,-1) <> 18800 ) hg   
outer apply  (SELECT MIN(exp_date) hol_date ,MAX(exp_date) hol_date_to  FROM holiday_group h WHERE 1=1 AND h.hol_group_value_id=ISNULL(spcd.exp_calENDar_id,spcd_proxy.exp_calENDar_id) and h.hol_date between s.term_start  and s.term_END AND s.formula NOT IN(''''REBD'''')) hg1   
outer apply  (SELECT count(exp_date) total_days,SUM(CASE WHEN h.exp_date>''''@as_of_date'''' THEN 1 ELSE 0 END) remain_days FROM holiday_group h WHERE h.hol_group_value_id=ISNULL(spcd.exp_calENDar_id,spcd_proxy.exp_calENDar_id) 
AND h.exp_date BETWEEN hg1.hol_date AND ISNULL(hg1.hol_date_to,dbo.FNALastDayInDate(hg1.hol_date))
AND ISNULL(spcd_proxy.ratio_option,spcd.ratio_option) = 18800 AND s.formula NOT IN(''''REBD'''')) remain_month  
WHERE ((ISNULL(spcd_proxy.ratio_option,spcd.ratio_option) = 18800 AND ISNULL(hg1.hol_date_to,''''9999-01-01'''')>''''@as_of_date'''') OR COALESCE(spcd_proxy.ratio_option,spcd.ratio_option,-1) <> 18800)
AND ((ISNULL(spcd.hourly_volume_allocation,17601) IN(17603,17604) and  hg.exp_date is not null) or (ISNULL(spcd.hourly_volume_allocation,17601)<17603 ))		           
AND s.deal_date<=''''@as_of_date''''''
+		
CASE 
	WHEN @_term_start_from IS NULL AND @_term_start_to IS NULL THEN ''''
	WHEN @_term_start_to IS NULL THEN '' AND hb.term_date >= CAST('''''' + CAST(@_term_start_from AS VARCHAR(100)) + '''''' as DATETIME)''
	WHEN @_term_start_from IS NULL THEN '' AND hb.term_date =< CAST('''''' +  CAST(@_term_start_to AS VARCHAR(100)) + ''''''as DATETIME)'' 
	ELSE '' AND hb.term_date BETWEEN CAST('''''' + CAST(@_term_start_from AS VARCHAR(100)) + '''''' as DATETIME) AND CAST('''''' +  CAST(@_term_start_to AS VARCHAR(100)) + ''''''as DATETIME)''
END

PRINT(@_sql)
EXEC(@_sql)

-- hourly position breakdown END
create index indxterm_dat ON #term_date(block_define_id, term_start,term_END)

IF OBJECT_ID(N''tempdb..#temp_position_table'') IS NOT NULL
	DROP TABLE #temp_position_table
	
SELECT * INTO #temp_position_table FROM (
	SELECT * FROM #temp_hourly_position_deal 
	UNION ALL
	SELECT * FROM #temp_hourly_position_profile 
	UNION ALL
	SELECT * FROM #temp_hourly_position_breakdown		
) pos

IF OBJECT_ID(N''tempdb..#temp_hourly_position'') IS NOT NULL
	DROP TABLE #temp_hourly_position

CREATE INDEX ix_pt_tpt ON #temp_position_table(source_deal_header_id,term_start,location_id,curve_id,counterparty_id,expiration_date)
INCLUDE(source_system_book_id1,source_system_book_id2,source_system_book_id3,source_system_book_id4)

SELECT CAST(''@as_of_date'' AS DATETIME) as_of_date, sub.entity_id sub_id,
       stra.entity_id stra_id,
       book.entity_id book_id,
       sub.entity_name sub,
       stra.entity_name strategy,
       book.entity_name book,
       vw.source_deal_header_id,
       sdh.deal_id deal_id,
       (
           CASE 
                WHEN vw.physical_financial_flag = ''p'' THEN ''Physical''
                ELSE ''Financial''
           END
       ) physical_financial_flag,
       vw.deal_date deal_date,
       sml.Location_Name location,
       spcd.curve_name [index],
       spcd_proxy.curve_name proxy_index,
       sdv2.code region,
       sdv.code country,
       sdv1.code grid,
       mjr.location_name location_group,
       com.commodity_name commodity,
       sdv_deal_staus.code deal_status,
       sc.counterparty_name counterparty_name,
       sc.counterparty_name parent_counterparty,
       CONVERT(VARCHAR(7), vw.term_start, 120) term_year_month,
       vw.term_start term_start,
       sb1.source_book_name book_identifier1,
       sb2.source_book_name book_identifier2,
       sb3.source_book_name book_identifier3,
       sb4.source_book_name book_identifier4,
       ssbm.logical_name AS sub_book,
       hb.hr1*vw.Hr1 [01], hb.hr2*vw.Hr2 [02], hb.hr3*vw.Hr3 [03], hb.hr4*vw.Hr4 [04], hb.hr5*vw.Hr5 [05], hb.hr6*vw.Hr6 [06], hb.hr7*vw.Hr7[07] 
        , hb.hr8*vw.Hr8 [08], hb.hr9*vw.Hr9 [09], hb.hr10*vw.Hr10 [10] , hb.hr11*vw.Hr11 [11] , hb.hr12*vw.Hr12 [12], hb.hr13*vw.Hr13 [13]
        , hb.hr14*vw.Hr14 [14], hb.hr15*vw.Hr15 [15], hb.hr16*vw.Hr16 [16], hb.hr17*vw.Hr17 [17], hb.hr18*vw.Hr18 [18], hb.hr19*vw.Hr19 [19] 
        , hb.hr20*vw.Hr20 [20], hb.hr21*vw.Hr21 [21], hb.hr22*vw.Hr22 [22], hb.hr23*vw.Hr23 [23], hb.hr24*vw.Hr24 [24],vw.Hr25 [25], vw.Hr25 [dst_25],
              su_uom.uom_name [uom],
       su_pos_uom.uom_name [postion_uom],
       spcd_monthly_index.curve_name + CASE 
                           WHEN sssd.source_system_id = 2 THEN ''''
                           ELSE ''.'' + sssd.source_system_name
                      END AS [proxy_curve2],
		su_uom_proxy2.uom_name [proxy2_position_uom],
		spcd_proxy_curve3.curve_name + CASE 
                           WHEN sssd2.source_system_id = 2 THEN ''''
                           ELSE ''.'' + sssd2.source_system_name
                      END AS [proxy_curve3],
        su_uom_proxy3.uom_name [proxy3_position_uom], 
		sdv_block.code [block_definition],
		CASE WHEN vw.deal_volume_frequency = ''h'' THEN ''Hourly''
			WHEN vw.deal_volume_frequency = ''d'' THEN ''Daily''
			WHEN vw.deal_volume_frequency = ''m'' THEN ''Monthly''
			WHEN vw.deal_volume_frequency = ''t'' THEN ''Term''
			WHEN vw.deal_volume_frequency = ''a'' THEN  ''Annually''     
			WHEN vw.deal_volume_frequency = ''x'' THEN ''15 Minutes''      
			WHEN vw.deal_volume_frequency = ''y'' THEN  ''30 Minutes''     
		END  [deal_volume_frequency]   ,
		spcd_proxy_curve_def.curve_name [proxy_curve],
		su_uom_proxy_curve_def.uom_name [proxy_curve_position_uom],
		YEAR(vw.term_start) term_year,
		vw.term_start term_END,
		sc.source_counterparty_id counterparty_id,
		sml.source_minor_location_id location_id,  
		su_uom_proxy_curve.uom_name proxy_index_position_uom,
		spcd.source_curve_def_id [index_id],
		vw.period,
		ssbm.book_deal_type_map_id [sub_book_id] ,
		ISNULL(grp.block_name, spcd.curve_name) block_name,
        sdv_block_group.code [user_defined_block] ,
        sdv_block_group.value_id [user_defined_block_id] ,
com.source_commodity_id commodity_id
       INTO #temp_hourly_position
FROM
#temp_position_table vw
cross join (SELECT * FROM block_type_group WHERE block_type_group_id=ISNULL(@_block_type_group_id,block_type_group_id )) grp
LEFT JOIN source_minor_location sml ON sml.source_minor_location_id = vw.location_id
INNER JOIN source_price_curve_def spcd ON spcd.source_curve_def_id = vw.curve_id  
LEFT JOIN  source_price_curve_def spcd_proxy ON spcd_proxy.source_curve_def_id=spcd.proxy_curve_id
LEFT JOIN  source_price_curve_def spcd_proxy_curve3 ON spcd_proxy_curve3.source_curve_def_id=spcd.proxy_curve_id3
LEFT JOIN  source_price_curve_def spcd_monthly_index ON spcd_monthly_index.source_curve_def_id=spcd.monthly_index
LEFT JOIN  source_price_curve_def spcd_proxy_curve_def ON spcd_proxy_curve_def.source_curve_def_id=spcd.proxy_source_curve_def_id
--LEFT JOIN  block_type_group grp (nolock) ON spcd.udf_block_group_id = grp.block_type_group_id 
LEFT JOIN  hour_block_term hb (nolock)  ON hb.block_define_id=COALESCE(grp.hourly_block_id,300501) AND  hb.block_type=COALESCE(grp.block_type_id,12000) and vw.term_start=hb.term_date
LEFT JOIN source_system_description sssd ON sssd.source_system_id = spcd_monthly_index.source_system_id
LEFT JOIN source_system_description sssd2 ON sssd.source_system_id = spcd_proxy_curve3.source_system_id
LEFT JOIN static_data_value sdv1 ON sdv1.value_id=sml.grid_value_id
LEFT JOIN static_data_value sdv ON sdv.value_id=sml.country
LEFT JOIN static_data_value sdv2 ON sdv2.value_id=sml.region
LEFT JOIN source_major_location mjr ON sml.source_major_location_ID=mjr.source_major_location_ID
LEFT JOIN source_uom AS su_pos_uom ON su_pos_uom.source_uom_id = ISNULL(spcd.display_uom_id,spcd.uom_id)
LEFT JOIN source_uom su_uom ON su_uom.source_uom_id= spcd.uom_id
LEFT JOIN source_uom su_uom_proxy3 ON su_uom_proxy3.source_uom_id= ISNULL(spcd_proxy_curve3.display_uom_id,spcd_proxy_curve3.uom_id)--spcd_proxy_curve3.display_uom_id
LEFT JOIN source_uom su_uom_proxy2 ON su_uom_proxy2.source_uom_id= ISNULL(spcd_monthly_index.display_uom_id,spcd_monthly_index.uom_id)
LEFT JOIN source_uom su_uom_proxy_curve_def ON su_uom_proxy_curve_def.source_uom_id= ISNULL(spcd_proxy_curve_def.display_uom_id,spcd_proxy_curve_def.uom_id)--spcd_proxy_curve_def.display_uom_id
LEFT JOIN source_uom su_uom_proxy_curve ON su_uom_proxy_curve.source_uom_id= ISNULL(spcd_proxy.display_uom_id,spcd_proxy.uom_id)
LEFT JOIN source_counterparty sc ON sc.source_counterparty_id = vw.counterparty_id 
LEFT JOIN source_counterparty psc  ON psc.source_counterparty_id=sc.parent_counterparty_id
LEFT JOIN source_commodity com ON com.source_commodity_id=spcd.commodity_id 
LEFT JOIN portfolio_hierarchy book ON book.entity_id = vw.fas_book_id 
LEFT JOIN portfolio_hierarchy stra ON stra.entity_id = book.parent_entity_id 
LEFT JOIN portfolio_hierarchy sub ON sub.entity_id = stra.parent_entity_id
LEFT JOIN source_deal_header sdh ON sdh.source_deal_header_id = vw.source_deal_header_id
LEFT JOIN static_data_value sdv_deal_staus ON sdv_deal_staus.value_id = vw.deal_status_id
LEFT JOIN source_system_book_map ssbm ON ssbm.source_system_book_id1 = vw.source_system_book_id1
	AND ssbm.source_system_book_id2 = vw.source_system_book_id2
	AND ssbm.source_system_book_id3 = vw.source_system_book_id3
	AND ssbm.source_system_book_id4 = vw.source_system_book_id4
LEFT JOIN source_book sb1 ON sb1.source_book_id = vw.source_system_book_id1
LEFT JOIN source_book sb2 ON sb2.source_book_id = vw.source_system_book_id2
LEFT JOIN source_book sb3 ON sb3.source_book_id = vw.source_system_book_id3
LEFT JOIN source_book sb4 ON sb4.source_book_id = vw.source_system_book_id4
LEFT JOIN static_data_value sdv_block ON sdv_block.value_id  = sdh.block_define_id
LEFT JOIN static_data_value sdv_block_group ON sdv_block_group.value_id = grp.block_type_group_id
WHERE vw.expiration_date > ''@as_of_date'' AND vw.term_start > ''@as_of_date''

SELECT 
	as_of_date,
    sub_id,
    stra_id,
    book_id,
    sub,
    strategy [stra],
    book,
    source_deal_header_id,
    deal_id,
    physical_financial_flag,
    deal_date,
    location,
    [index] AS curve_name,
    proxy_index,
    region,
    country,
    grid,
    location_group,
    commodity,
    deal_status,
    counterparty_name,
    parent_counterparty,
    term_year_month,
    term_start,
    book_identifier1,
    book_identifier2,
    book_identifier3,
    book_identifier4,
    sub_book,
    uom,
    postion_uom,
    proxy_curve2,
    proxy2_position_uom,
    proxy_curve3,
    proxy3_position_uom,
    block_definition,
    deal_volume_frequency,
    proxy_curve,
    proxy_curve_position_uom,
    term_year,
    term_END,
    counterparty_id,
    location_id,
    proxy_index_position_uom,
    index_id AS [curve_id],
    unpvt.period,       
	CASE WHEN unpvt.Hours=25 THEN dst.[hour] 
		ELSE unpvt.Hours 
	END Hours,
	unpvt.Volume - CASE 
		WHEN dst.[hour] is not null and unpvt.hours=dst.[hour] 
		THEN ISNULL(unpvt.dst_25,0) 
		ELSE 0 
	END volume,
	CASE WHEN unpvt.hours=25 THEN 1 ELSE 0 END is_dst,
	sub_book_id,
	block_name,
	[user_defined_block] ,
	[user_defined_block_id],
	''@period_to'' period_to,
	''@period_from'' period_from,
commodity_id
--[__batch_report__] 
FROM
 #temp_hourly_position thp
UNPIVOT (Volume FOR Hours IN (thp.[01] , thp.[02] , thp.[03] , thp.[04] , thp.[05] , thp.[06] , thp.[07] 
           , thp.[08] , thp.[09] , thp.[10] , thp.[11] , thp.[12] , thp.[13] 
           , thp.[14] , thp.[15] , thp.[16] , thp.[17] , thp.[18] , thp.[19] 
           , thp.[20] , thp.[21] , thp.[22] , thp.[23] , thp.[24],thp.[25])) AS unpvt           
LEFT JOIN	mv90_dst dst ON dst.[date] = unpvt.term_start and insert_delete = ''i'' 
	WHERE unpvt.Hours<25 or (unpvt.Hours=25 and dst.[hour] is not null)', report_id = @report_id_data_source_dest 
		WHERE [name] = 'Position View Hourly With Block Type'
			AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1)
	END	
	
	IF NOT EXISTS (SELECT 1 
	           FROM data_source 
	           WHERE [name] = 'Position View Hourly With Block Type'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		INSERT INTO data_source([type_id], [name], [alias], [description], [tsql], report_id)
		SELECT TOP 1 1 AS [type_id], 'Position View Hourly With Block Type' AS [name], 'PVHWBT' AS ALIAS, '' AS [description],'IF OBJECT_ID(N''tempdb..#books'') IS NOT NULL
	DROP TABLE #books
IF OBJECT_ID(N''tempdb..#term_date'') IS NOT NULL
	DROP TABLE #term_date

DECLARE @_block_type_group_id INT,@_sql VARCHAR(MAX)

IF ''@user_defined_block_id'' <> ''NULL'' 
	SET @_block_type_group_id = ''@user_defined_block_id''

DECLARE @_term_start_from datetime 
DECLARE @_term_start_to datetime 

IF ''@period_from'' <> ''NULL'' 
	SET @_term_start_from = dbo.FNAGetTermStartDate(''m'',''@as_of_date'',''@period_from'')

IF ''@period_to'' <> ''NULL'' 
SET @_term_start_to = dbo.FNAGetTermENDDate(''m'',''@as_of_date'',''@period_to'')

CREATE TABLE #books ( fas_book_id INT, source_system_book_id1 INT ,source_system_book_id2 INT,source_system_book_id3 INT,source_system_book_id4 INT)    
INSERT INTO #books
SELECT DISTINCT book.entity_id,
       ssbm.source_system_book_id1,
       ssbm.source_system_book_id2,
       ssbm.source_system_book_id3,
       ssbm.source_system_book_id4 fas_book_id
FROM   portfolio_hierarchy book(NOLOCK)
INNER JOIN Portfolio_hierarchy stra(NOLOCK)
	ON  book.parent_entity_id = stra.entity_id
INNER JOIN portfolio_hierarchy sub (NOLOCK)
	ON  stra.parent_entity_id = sub.entity_id
INNER JOIN source_system_book_map ssbm
	ON  ssbm.fas_book_id = book.entity_id
WHERE  (fas_deal_type_value_id IS NULL OR fas_deal_type_value_id BETWEEN 400 AND 401)
AND (''@sub_id'' = ''NULL'' OR sub.entity_id IN (@sub_id)) 
AND (''@stra_id'' = ''NULL'' OR stra.entity_id IN (@stra_id)) 
AND (''@book_id'' = ''NULL'' OR book.entity_id IN (@book_id))
AND (''@sub_book_id'' = ''NULL'' OR ssbm.book_deal_type_map_id IN (@sub_book_id))

IF OBJECT_ID(N''tempdb..#temp_report_hourly_position_breakdown'') IS NOT NULL
	DROP TABLE #temp_report_hourly_position_breakdown
	
SELECT 
DISTINCT ISNULL(spcd.block_define_id,300501) block_define_id,s.term_start,s.term_END 
INTO #temp_report_hourly_position_breakdown
FROM report_hourly_position_breakdown s  (nolock)  
INNER JOIN #books bk ON bk.fas_book_id=s.fas_book_id 
	AND bk.source_system_book_id1=s.source_system_book_id1 AND bk.source_system_book_id2=s.source_system_book_id2 
	AND bk.source_system_book_id3=s.source_system_book_id3 AND bk.source_system_book_id4=s.source_system_book_id4 
INNER JOIN [deal_status_group] dsg ON dsg.status_value_id = s.deal_status_id  
LEFT JOIN source_price_curve_def spcd with (nolock) 
ON spcd.source_curve_def_id=s.curve_id 

CREATE TABLE #term_date( block_define_id int ,term_date date,term_start date,term_END date,
	hr1 tinyint,hr2 tinyint,hr3 tinyint,hr4 tinyint,hr5 tinyint,hr6 tinyint,hr7 tinyint,hr8 tinyint
	,hr9 tinyint,hr10 tinyint,hr11 tinyint,hr12 tinyint,hr13 tinyint,hr14 tinyint,hr15 tinyint,hr16 tinyint
	,hr17 tinyint,hr18 tinyint,hr19 tinyint,hr20 tinyint,hr21 tinyint,hr22 tinyint,hr23 tinyint,hr24 tinyint,add_dst_hour int
)
INSERT INTO #term_date(block_define_id  ,term_date,term_start,term_END,
hr1 ,hr2 ,hr3 ,hr4 ,hr5 ,hr6 ,hr7 ,hr8 ,hr9 ,hr10 ,hr11 ,hr12 ,hr13 ,hr14 ,hr15 ,hr16 
,hr17 ,hr18 ,hr19 ,hr20 ,hr21 ,hr22 ,hr23 ,hr24 ,add_dst_hour
)
SELECT DISTINCT a.block_define_id  ,hb.term_date,a.term_start ,a.term_END,
	hb.hr1 ,hb.hr2 ,hb.hr3 ,hb.hr4 ,hb.hr5 ,hb.hr6 ,hb.hr7 ,hb.hr8 
	,hb.hr9 ,hb.hr10 ,hb.hr11 ,hb.hr12 ,hb.hr13 ,hb.hr14 ,hb.hr15 ,hb.hr16 
	,hb.hr17 ,hb.hr18 ,hb.hr19 ,hb.hr20 ,hb.hr21 ,hb.hr22 ,hb.hr23 ,hb.hr24 ,hb.add_dst_hour
FROM #temp_report_hourly_position_breakdown a
		outer apply	(SELECT h.* FROM hour_block_term h with (nolock) WHERE block_define_id=a.block_define_id and h.block_type=12000 
		and term_date between a.term_start and a.term_END 
) hb
----- hourly position deal start
IF OBJECT_ID(N''tempdb..#temp_hourly_position_deal'') IS NOT NULL
	DROP TABLE #temp_hourly_position_deal

CREATE TABLE #temp_hourly_position_deal(
curve_id INT ,location_id INT,term_start DATETIME,period INT,deal_date DATETIME,deal_volume_uom_id DATETIME,
physical_financial_flag varchar(2) COLLATE DATABASE_DEFAULT,hr1 FLOAT,hr2 FLOAT,hr3 FLOAT,hr4 FLOAT,hr5 FLOAT,hr6 FLOAT,hr7 FLOAT,hr8 FLOAT,
hr9 FLOAT,hr10 FLOAT,hr11 FLOAT,hr12 FLOAT,hr13 FLOAT,hr14 FLOAT,hr15 FLOAT,hr16 FLOAT,hr17 FLOAT,hr18 FLOAT,hr19 FLOAT,
hr20 FLOAT,hr21 FLOAT,hr22 FLOAT,hr23 FLOAT,hr24 FLOAT,hr25 FLOAT,source_deal_header_id INT,commodity_id INT,
counterparty_id INT,fas_book_id INT,source_system_book_id1 INT,source_system_book_id2 INT,source_system_book_id3 INT,
source_system_book_id4 INT,expiration_date DATETIME,is_fixedvolume VARCHAR(2) COLLATE DATABASE_DEFAULT,deal_status_id INT,deal_volume_frequency VARCHAR(2) COLLATE DATABASE_DEFAULT,term_end DATETIME)

SET @_sql =	
''INSERT INTO #temp_hourly_position_deal (curve_id,location_id,term_start,period,deal_date,deal_volume_uom_id,physical_financial_flag,hr1,hr2,hr3,hr4,hr5,hr6,hr7,hr8,hr9,hr10,hr11,hr12,hr13,hr14,hr15,hr16,hr17,hr18,hr19,hr20,hr21,hr22,hr23,hr24,hr25,source_deal_header_id,commodity_id,counterparty_id,fas_book_id,source_system_book_id1,source_system_book_id2,source_system_book_id3,source_system_book_id4,expiration_date,is_fixedvolume,deal_status_id,deal_volume_frequency,term_END)
SELECT s.curve_id,s.location_id,s.term_start,s.period,s.deal_date,s.deal_volume_uom_id,s.physical_financial_flag,s.hr1,s.hr2,s.hr3,s.hr4,s.hr5,s.hr6,s.hr7,s.hr8,s.hr9,s.hr10,s.hr11,s.hr12,s.hr13,s.hr14,s.hr15,s.hr16,s.hr17,s.hr18,s.hr19,s.hr20,s.hr21,s.hr22,s.hr23,s.hr24,s.hr25,s.source_deal_header_id,s.commodity_id,s.counterparty_id,s.fas_book_id,s.source_system_book_id1,s.source_system_book_id2
	,s.source_system_book_id3,s.source_system_book_id4,s.expiration_date,''''n'''' AS is_fixedvolume,deal_status_id,sdd.deal_volume_frequency,sdd.term_END 
FROM report_hourly_position_deal s  (nolock)  INNER JOIN #books bk ON bk.fas_book_id=s.fas_book_id AND bk.source_system_book_id1=s.source_system_book_id1	
AND bk.source_system_book_id2=s.source_system_book_id2 AND bk.source_system_book_id3=s.source_system_book_id3
AND bk.source_system_book_id4=s.source_system_book_id4 
INNER JOIN [deal_status_group] dsg ON  dsg.status_value_id = s.deal_status_id 
LEFT JOIN source_price_curve_def spcd ON spcd.source_curve_def_id=s.curve_id
LEFT JOIN source_deal_detail sdd 
		ON s.term_start BETWEEN sdd.term_start AND sdd.term_end
	AND sdd.source_deal_detail_id = s.source_deal_detail_id 
WHERE 1=1
AND s.deal_date<=''''@as_of_date''''  AND s.expiration_date > ''''@as_of_date'''' AND s.term_start > ''''@as_of_date'''' ''
+		
CASE 
	WHEN @_term_start_from IS NULL AND @_term_start_to IS NULL THEN ''''
	WHEN @_term_start_to IS NULL THEN '' AND s.term_start >= CAST('''''' + CAST(@_term_start_from AS VARCHAR(100)) + '''''' as DATETIME)''
	WHEN @_term_start_from IS NULL THEN '' AND s.term_start =< CAST('''''' +  CAST(@_term_start_to AS VARCHAR(100)) + ''''''as DATETIME)'' 
	ELSE '' AND s.term_start BETWEEN CAST('''''' + CAST(@_term_start_from AS VARCHAR(100)) + '''''' as DATETIME) AND CAST('''''' +  CAST(@_term_start_to AS VARCHAR(100)) + ''''''as DATETIME)''
END

PRINT(@_sql)
EXEC(@_sql)
----- hourly position deal END

----- hourly position profile start
IF OBJECT_ID(N''tempdb..#temp_hourly_position_profile'') IS NOT NULL
	DROP TABLE #temp_hourly_position_profile

CREATE TABLE #temp_hourly_position_profile(
curve_id INT ,location_id INT,term_start DATETIME,period INT,deal_date DATETIME,deal_volume_uom_id DATETIME,
physical_financial_flag varchar(2) COLLATE DATABASE_DEFAULT,hr1 FLOAT,hr2 FLOAT,hr3 FLOAT,hr4 FLOAT,hr5 FLOAT,hr6 FLOAT,hr7 FLOAT,hr8 FLOAT,
hr9 FLOAT,hr10 FLOAT,hr11 FLOAT,hr12 FLOAT,hr13 FLOAT,hr14 FLOAT,hr15 FLOAT,hr16 FLOAT,hr17 FLOAT,hr18 FLOAT,hr19 FLOAT,
hr20 FLOAT,hr21 FLOAT,hr22 FLOAT,hr23 FLOAT,hr24 FLOAT,hr25 FLOAT,source_deal_header_id INT,commodity_id INT,
counterparty_id INT,fas_book_id INT,source_system_book_id1 INT,source_system_book_id2 INT,source_system_book_id3 INT,
source_system_book_id4 INT,expiration_date DATETIME,is_fixedvolume VARCHAR(2) COLLATE DATABASE_DEFAULT,deal_status_id INT,deal_volume_frequency VARCHAR(2) COLLATE DATABASE_DEFAULT,term_end DATETIME)

SET @_sql = ''
			INSERT INTO #temp_hourly_position_profile (curve_id,location_id,term_start,period,deal_date,deal_volume_uom_id,physical_financial_flag,hr1,hr2,hr3,hr4,hr5,hr6,hr7,hr8,hr9,hr10,hr11,hr12,hr13,hr14,hr15,hr16,hr17,hr18,hr19,hr20,hr21,hr22,hr23,hr24,hr25,source_deal_header_id,commodity_id,counterparty_id,fas_book_id,source_system_book_id1,source_system_book_id2,source_system_book_id3,source_system_book_id4,expiration_date,is_fixedvolume,deal_status_id,deal_volume_frequency,term_END)
			SELECT s.curve_id,s.location_id,s.term_start,s.period,s.deal_date,s.deal_volume_uom_id,s.physical_financial_flag,s.hr1,s.hr2,s.hr3,s.hr4,s.hr5,s.hr6,s.hr7,s.hr8,s.hr9,s.hr10,s.hr11,s.hr12,s.hr13,s.hr14,s.hr15,s.hr16,s.hr17,s.hr18,s.hr19,s.hr20,s.hr21,s.hr22,s.hr23,s.hr24,s.hr25,s.source_deal_header_id,s.commodity_id,s.counterparty_id,s.fas_book_id,s.source_system_book_id1,s.source_system_book_id2,s.source_system_book_id3,s.source_system_book_id4 
			,s.expiration_date,''''n'''' AS is_fixedvolume,deal_status_id,sdd.deal_volume_frequency,sdd.term_END 
			FROM report_hourly_position_profile s  (nolock)  
			INNER JOIN #books bk ON bk.fas_book_id=s.fas_book_id 
			AND bk.source_system_book_id1=s.source_system_book_id1	
			AND bk.source_system_book_id2=s.source_system_book_id2	AND bk.source_system_book_id3=s.source_system_book_id3
			AND bk.source_system_book_id4=s.source_system_book_id4 
			INNER JOIN [deal_status_group] dsg ON  dsg.status_value_id = s.deal_status_id 
			LEFT JOIN source_price_curve_def spcd ON spcd.source_curve_def_id=s.curve_id
			LEFT JOIN source_deal_detail sdd 
				ON s.term_start BETWEEN sdd.term_start AND sdd.term_end
	AND sdd.source_deal_detail_id = s.source_deal_detail_id 
			WHERE  1=1
			AND s.deal_date<=''''@as_of_date''''  AND s.expiration_date > ''''@as_of_date'''' AND s.term_start > ''''@as_of_date''''''
			+		
			CASE 
				WHEN @_term_start_from IS NULL AND @_term_start_to IS NULL THEN ''''
				WHEN @_term_start_to IS NULL THEN '' AND s.deal_date >= CAST('''''' + CAST(@_term_start_from AS VARCHAR(100)) + '''''' as DATETIME)''
				WHEN @_term_start_from IS NULL THEN '' AND s.deal_date =< CAST('''''' +  CAST(@_term_start_to AS VARCHAR(100)) + ''''''as DATETIME)'' 
				ELSE '' AND s.deal_date BETWEEN CAST('''''' + CAST(@_term_start_from AS VARCHAR(100)) + '''''' as DATETIME) AND CAST('''''' +  CAST(@_term_start_to AS VARCHAR(100)) + ''''''as DATETIME)''
			END

PRINT(@_sql) 
EXEC (@_sql)
---- hourly position profile END

IF OBJECT_ID(N''tempdb..#temp_hourly_position_breakdown'') IS NOT NULL
	DROP TABLE #temp_hourly_position_breakdown
----- hourly position breakdown start

CREATE TABLE #temp_hourly_position_breakdown(
curve_id INT ,location_id INT,term_start DATETIME,period INT,deal_date DATETIME,deal_volume_uom_id DATETIME,
physical_financial_flag varchar(2) COLLATE DATABASE_DEFAULT,hr1 FLOAT,hr2 FLOAT,hr3 FLOAT,hr4 FLOAT,hr5 FLOAT,hr6 FLOAT,hr7 FLOAT,hr8 FLOAT,
hr9 FLOAT,hr10 FLOAT,hr11 FLOAT,hr12 FLOAT,hr13 FLOAT,hr14 FLOAT,hr15 FLOAT,hr16 FLOAT,hr17 FLOAT,hr18 FLOAT,hr19 FLOAT,
hr20 FLOAT,hr21 FLOAT,hr22 FLOAT,hr23 FLOAT,hr24 FLOAT,hr25 FLOAT,source_deal_header_id INT,commodity_id INT,
counterparty_id INT,fas_book_id INT,source_system_book_id1 INT,source_system_book_id2 INT,source_system_book_id3 INT,
source_system_book_id4 INT,expiration_date DATETIME,is_fixedvolume VARCHAR(2) COLLATE DATABASE_DEFAULT,deal_status_id INT,deal_volume_frequency VARCHAR(2) COLLATE DATABASE_DEFAULT,term_end DATETIME)

SET @_sql = ''
INSERT INTO #temp_hourly_position_breakdown (curve_id,location_id,term_start,period,deal_date,deal_volume_uom_id,physical_financial_flag,hr1,hr2,hr3,hr4,hr5,hr6,hr7,hr8,hr9,hr10,hr11,hr12,hr13,hr14,hr15,hr16,hr17,hr18,hr19,hr20,hr21,hr22,hr23,hr24,hr25,source_deal_header_id,commodity_id,counterparty_id,fas_book_id,source_system_book_id1,source_system_book_id2,source_system_book_id3,source_system_book_id4,expiration_date,is_fixedvolume,deal_status_id,deal_volume_frequency,term_END)
SELECT s.curve_id,ISNULL(s.location_id,-1) location_id,hb.term_date term_start,0 period,s.deal_date,s.deal_volume_uom_id,s.physical_financial_flag
,(CAST(CAST(CAST(s.calc_volume AS NUMERIC(22,10))* CAST(ISNULL(hb.hr1,0) AS NUMERIC(1,0)) AS NUMERIC(22,10))*CAST(CASE WHEN ISNULL(hb.add_dst_hour,0)=1 THEN 2 ELSE 1 END AS NUMERIC(1,0)) AS NUMERIC(22,10)))/CAST(NULLIF(ISNULL(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) AS NUMERIC(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,''''@as_of_date'''')) AS VARCHAR)+''''-''''+CAST(MONTH(DATEADD(m,1,''''@as_of_date'''')) AS VARCHAR)+''''-01'''' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  AS Hr1
,(CAST(CAST(CAST(s.calc_volume AS NUMERIC(22,10))* CAST(ISNULL(hb.hr2,0) AS NUMERIC(1,0)) AS NUMERIC(22,10))*CAST(CASE WHEN ISNULL(hb.add_dst_hour,0)=2 THEN 2 ELSE 1 END AS NUMERIC(1,0)) AS NUMERIC(22,10)))/CAST(NULLIF(ISNULL(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) AS NUMERIC(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,''''@as_of_date'''')) AS VARCHAR)+''''-''''+CAST(MONTH(DATEADD(m,1,''''@as_of_date'''')) AS VARCHAR)+''''-01'''' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  AS Hr2
,(CAST(CAST(CAST(s.calc_volume AS NUMERIC(22,10))* CAST(ISNULL(hb.hr3,0) AS NUMERIC(1,0)) AS NUMERIC(22,10))*CAST(CASE WHEN ISNULL(hb.add_dst_hour,0)=3 THEN 2 ELSE 1 END AS NUMERIC(1,0)) AS NUMERIC(22,10)))/CAST(NULLIF(ISNULL(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) AS NUMERIC(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,''''@as_of_date'''')) AS VARCHAR)+''''-''''+CAST(MONTH(DATEADD(m,1,''''@as_of_date'''')) AS VARCHAR)+''''-01'''' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  AS Hr3
,(CAST(CAST(CAST(s.calc_volume AS NUMERIC(22,10))* CAST(ISNULL(hb.hr4,0) AS NUMERIC(1,0)) AS NUMERIC(22,10))*CAST(CASE WHEN ISNULL(hb.add_dst_hour,0)=4 THEN 2 ELSE 1 END AS NUMERIC(1,0)) AS NUMERIC(22,10)))/CAST(NULLIF(ISNULL(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) AS NUMERIC(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,''''@as_of_date'''')) AS VARCHAR)+''''-''''+CAST(MONTH(DATEADD(m,1,''''@as_of_date'''')) AS VARCHAR)+''''-01'''' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  AS Hr4
,(CAST(CAST(CAST(s.calc_volume AS NUMERIC(22,10))* CAST(ISNULL(hb.hr5,0) AS NUMERIC(1,0)) AS NUMERIC(22,10))*CAST(CASE WHEN ISNULL(hb.add_dst_hour,0)=5 THEN 2 ELSE 1 END AS NUMERIC(1,0)) AS NUMERIC(22,10)))/CAST(NULLIF(ISNULL(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) AS NUMERIC(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,''''@as_of_date'''')) AS VARCHAR)+''''-''''+CAST(MONTH(DATEADD(m,1,''''@as_of_date'''')) AS VARCHAR)+''''-01'''' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  AS Hr5
,(CAST(CAST(CAST(s.calc_volume AS NUMERIC(22,10))* CAST(ISNULL(hb.hr6,0) AS NUMERIC(1,0)) AS NUMERIC(22,10))*CAST(CASE WHEN ISNULL(hb.add_dst_hour,0)=6 THEN 2 ELSE 1 END AS NUMERIC(1,0)) AS NUMERIC(22,10)))/CAST(NULLIF(ISNULL(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) AS NUMERIC(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,''''@as_of_date'''')) AS VARCHAR)+''''-''''+CAST(MONTH(DATEADD(m,1,''''@as_of_date'''')) AS VARCHAR)+''''-01'''' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  AS Hr6
,(CAST(CAST(CAST(s.calc_volume AS NUMERIC(22,10))* CAST(ISNULL(hb.hr7,0) AS NUMERIC(1,0)) AS NUMERIC(22,10))*CAST(CASE WHEN ISNULL(hb.add_dst_hour,0)=7 THEN 2 ELSE 1 END AS NUMERIC(1,0)) AS NUMERIC(22,10)))/CAST(NULLIF(ISNULL(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) AS NUMERIC(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,''''@as_of_date'''')) AS VARCHAR)+''''-''''+CAST(MONTH(DATEADD(m,1,''''@as_of_date'''')) AS VARCHAR)+''''-01'''' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  AS Hr7
,(CAST(CAST(CAST(s.calc_volume AS NUMERIC(22,10))* CAST(ISNULL(hb.hr8,0) AS NUMERIC(1,0)) AS NUMERIC(22,10))*CAST(CASE WHEN ISNULL(hb.add_dst_hour,0)=8 THEN 2 ELSE 1 END AS NUMERIC(1,0)) AS NUMERIC(22,10)))/CAST(NULLIF(ISNULL(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) AS NUMERIC(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,''''@as_of_date'''')) AS VARCHAR)+''''-''''+CAST(MONTH(DATEADD(m,1,''''@as_of_date'''')) AS VARCHAR)+''''-01'''' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  AS Hr8
,(CAST(CAST(CAST(s.calc_volume AS NUMERIC(22,10))* CAST(ISNULL(hb.hr9,0) AS NUMERIC(1,0)) AS NUMERIC(22,10))*CAST(CASE WHEN ISNULL(hb.add_dst_hour,0)=9 THEN 2 ELSE 1 END AS NUMERIC(1,0)) AS NUMERIC(22,10)))/CAST(NULLIF(ISNULL(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) AS NUMERIC(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,''''@as_of_date'''')) AS VARCHAR)+''''-''''+CAST(MONTH(DATEADD(m,1,''''@as_of_date'''')) AS VARCHAR)+''''-01'''' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  AS Hr9
,(CAST(CAST(CAST(s.calc_volume AS NUMERIC(22,10))* CAST(ISNULL(hb.hr10,0) AS NUMERIC(1,0)) AS NUMERIC(22,10))*CAST(CASE WHEN ISNULL(hb.add_dst_hour,0)=10 THEN 2 ELSE 1 END AS NUMERIC(1,0)) AS NUMERIC(22,10)))/CAST(NULLIF(ISNULL(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) AS NUMERIC(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,''''@as_of_date'''')) AS VARCHAR)+''''-''''+CAST(MONTH(DATEADD(m,1,''''@as_of_date'''')) AS VARCHAR)+''''-01'''' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  AS Hr10
,(CAST(CAST(CAST(s.calc_volume AS NUMERIC(22,10))* CAST(ISNULL(hb.hr11,0) AS NUMERIC(1,0)) AS NUMERIC(22,10))*CAST(CASE WHEN ISNULL(hb.add_dst_hour,0)=11 THEN 2 ELSE 1 END AS NUMERIC(1,0)) AS NUMERIC(22,10)))/CAST(NULLIF(ISNULL(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) AS NUMERIC(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,''''@as_of_date'''')) AS VARCHAR)+''''-''''+CAST(MONTH(DATEADD(m,1,''''@as_of_date'''')) AS VARCHAR)+''''-01'''' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  AS Hr11
,(CAST(CAST(CAST(s.calc_volume AS NUMERIC(22,10))* CAST(ISNULL(hb.hr12,0) AS NUMERIC(1,0)) AS NUMERIC(22,10))*CAST(CASE WHEN ISNULL(hb.add_dst_hour,0)=12 THEN 2 ELSE 1 END AS NUMERIC(1,0)) AS NUMERIC(22,10)))/CAST(NULLIF(ISNULL(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) AS NUMERIC(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,''''@as_of_date'''')) AS VARCHAR)+''''-''''+CAST(MONTH(DATEADD(m,1,''''@as_of_date'''')) AS VARCHAR)+''''-01'''' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  AS Hr12
,(CAST(CAST(CAST(s.calc_volume AS NUMERIC(22,10))* CAST(ISNULL(hb.hr13,0) AS NUMERIC(1,0)) AS NUMERIC(22,10))*CAST(CASE WHEN ISNULL(hb.add_dst_hour,0)=13 THEN 2 ELSE 1 END AS NUMERIC(1,0)) AS NUMERIC(22,10)))/CAST(NULLIF(ISNULL(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) AS NUMERIC(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,''''@as_of_date'''')) AS VARCHAR)+''''-''''+CAST(MONTH(DATEADD(m,1,''''@as_of_date'''')) AS VARCHAR)+''''-01'''' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  AS Hr13
,(CAST(CAST(CAST(s.calc_volume AS NUMERIC(22,10))* CAST(ISNULL(hb.hr14,0) AS NUMERIC(1,0)) AS NUMERIC(22,10))*CAST(CASE WHEN ISNULL(hb.add_dst_hour,0)=14 THEN 2 ELSE 1 END AS NUMERIC(1,0)) AS NUMERIC(22,10)))/CAST(NULLIF(ISNULL(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) AS NUMERIC(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,''''@as_of_date'''')) AS VARCHAR)+''''-''''+CAST(MONTH(DATEADD(m,1,''''@as_of_date'''')) AS VARCHAR)+''''-01'''' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  AS Hr14
,(CAST(CAST(CAST(s.calc_volume AS NUMERIC(22,10))* CAST(ISNULL(hb.hr15,0) AS NUMERIC(1,0)) AS NUMERIC(22,10))*CAST(CASE WHEN ISNULL(hb.add_dst_hour,0)=15 THEN 2 ELSE 1 END AS NUMERIC(1,0)) AS NUMERIC(22,10)))/CAST(NULLIF(ISNULL(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) AS NUMERIC(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,''''@as_of_date'''')) AS VARCHAR)+''''-''''+CAST(MONTH(DATEADD(m,1,''''@as_of_date'''')) AS VARCHAR)+''''-01'''' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  AS Hr15
,(CAST(CAST(CAST(s.calc_volume AS NUMERIC(22,10))* CAST(ISNULL(hb.hr16,0) AS NUMERIC(1,0)) AS NUMERIC(22,10))*CAST(CASE WHEN ISNULL(hb.add_dst_hour,0)=16 THEN 2 ELSE 1 END AS NUMERIC(1,0)) AS NUMERIC(22,10)))/CAST(NULLIF(ISNULL(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) AS NUMERIC(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,''''@as_of_date'''')) AS VARCHAR)+''''-''''+CAST(MONTH(DATEADD(m,1,''''@as_of_date'''')) AS VARCHAR)+''''-01'''' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  AS Hr16
,(CAST(CAST(CAST(s.calc_volume AS NUMERIC(22,10))* CAST(ISNULL(hb.hr17,0) AS NUMERIC(1,0)) AS NUMERIC(22,10))*CAST(CASE WHEN ISNULL(hb.add_dst_hour,0)=17 THEN 2 ELSE 1 END AS NUMERIC(1,0)) AS NUMERIC(22,10)))/CAST(NULLIF(ISNULL(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) AS NUMERIC(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,''''@as_of_date'''')) AS VARCHAR)+''''-''''+CAST(MONTH(DATEADD(m,1,''''@as_of_date'''')) AS VARCHAR)+''''-01'''' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  AS Hr17
,(CAST(CAST(CAST(s.calc_volume AS NUMERIC(22,10))* CAST(ISNULL(hb.hr18,0) AS NUMERIC(1,0)) AS NUMERIC(22,10))*CAST(CASE WHEN ISNULL(hb.add_dst_hour,0)=18 THEN 2 ELSE 1 END AS NUMERIC(1,0)) AS NUMERIC(22,10)))/CAST(NULLIF(ISNULL(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) AS NUMERIC(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,''''@as_of_date'''')) AS VARCHAR)+''''-''''+CAST(MONTH(DATEADD(m,1,''''@as_of_date'''')) AS VARCHAR)+''''-01'''' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  AS Hr18
,(CAST(CAST(CAST(s.calc_volume AS NUMERIC(22,10))* CAST(ISNULL(hb.hr19,0) AS NUMERIC(1,0)) AS NUMERIC(22,10))*CAST(CASE WHEN ISNULL(hb.add_dst_hour,0)=19 THEN 2 ELSE 1 END AS NUMERIC(1,0)) AS NUMERIC(22,10)))/CAST(NULLIF(ISNULL(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) AS NUMERIC(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,''''@as_of_date'''')) AS VARCHAR)+''''-''''+CAST(MONTH(DATEADD(m,1,''''@as_of_date'''')) AS VARCHAR)+''''-01'''' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  AS Hr19
,(CAST(CAST(CAST(s.calc_volume AS NUMERIC(22,10))* CAST(ISNULL(hb.hr20,0) AS NUMERIC(1,0)) AS NUMERIC(22,10))*CAST(CASE WHEN ISNULL(hb.add_dst_hour,0)=20 THEN 2 ELSE 1 END AS NUMERIC(1,0)) AS NUMERIC(22,10)))/CAST(NULLIF(ISNULL(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) AS NUMERIC(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,''''@as_of_date'''')) AS VARCHAR)+''''-''''+CAST(MONTH(DATEADD(m,1,''''@as_of_date'''')) AS VARCHAR)+''''-01'''' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  AS Hr20
,(CAST(CAST(CAST(s.calc_volume AS NUMERIC(22,10))* CAST(ISNULL(hb.hr21,0) AS NUMERIC(1,0)) AS NUMERIC(22,10))*CAST(CASE WHEN ISNULL(hb.add_dst_hour,0)=21 THEN 2 ELSE 1 END AS NUMERIC(1,0)) AS NUMERIC(22,10)))/CAST(NULLIF(ISNULL(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) AS NUMERIC(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,''''@as_of_date'''')) AS VARCHAR)+''''-''''+CAST(MONTH(DATEADD(m,1,''''@as_of_date'''')) AS VARCHAR)+''''-01'''' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  AS Hr21
,(CAST(CAST(CAST(s.calc_volume AS NUMERIC(22,10))* CAST(ISNULL(hb.hr22,0) AS NUMERIC(1,0)) AS NUMERIC(22,10))*CAST(CASE WHEN ISNULL(hb.add_dst_hour,0)=22 THEN 2 ELSE 1 END AS NUMERIC(1,0)) AS NUMERIC(22,10)))/CAST(NULLIF(ISNULL(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) AS NUMERIC(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,''''@as_of_date'''')) AS VARCHAR)+''''-''''+CAST(MONTH(DATEADD(m,1,''''@as_of_date'''')) AS VARCHAR)+''''-01'''' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  AS Hr22
,(CAST(CAST(CAST(s.calc_volume AS NUMERIC(22,10))* CAST(ISNULL(hb.hr23,0) AS NUMERIC(1,0)) AS NUMERIC(22,10))*CAST(CASE WHEN ISNULL(hb.add_dst_hour,0)=23 THEN 2 ELSE 1 END AS NUMERIC(1,0)) AS NUMERIC(22,10)))/CAST(NULLIF(ISNULL(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) AS NUMERIC(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,''''@as_of_date'''')) AS VARCHAR)+''''-''''+CAST(MONTH(DATEADD(m,1,''''@as_of_date'''')) AS VARCHAR)+''''-01'''' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  AS Hr23
,(CAST(CAST(CAST(s.calc_volume AS NUMERIC(22,10))* CAST(ISNULL(hb.hr24,0) AS NUMERIC(1,0)) AS NUMERIC(22,10))*CAST(CASE WHEN ISNULL(hb.add_dst_hour,0)=24 THEN 2 ELSE 1 END AS NUMERIC(1,0)) AS NUMERIC(22,10)))/CAST(NULLIF(ISNULL(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) AS NUMERIC(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,''''@as_of_date'''')) AS VARCHAR)+''''-''''+CAST(MONTH(DATEADD(m,1,''''@as_of_date'''')) AS VARCHAR)+''''-01'''' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  AS Hr24
,(CAST(CAST(s.calc_volume AS NUMERIC(22,10))* CAST(CASE WHEN ISNULL(hb.add_dst_hour,0)<=0 THEN 0 ELSE 1 END AS NUMERIC(1,0)) AS NUMERIC(22,10))) /CAST(NULLIF(ISNULL(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) AS NUMERIC(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,''''@as_of_date'''')) AS VARCHAR)+''''-''''+CAST(MONTH(DATEADD(m,1,''''@as_of_date'''')) AS VARCHAR)+''''-01'''' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END) AS Hr25 
,s.source_deal_header_id,s.commodity_id,s.counterparty_id,s.fas_book_id,s.source_system_book_id1,s.source_system_book_id2,s.source_system_book_id3,s.source_system_book_id4,CASE WHEN s.formula IN(''''dbo.FNACurveH'''',''''dbo.FNACurveD'''') THEN ISNULL(hg.exp_date,hb.term_date) WHEN ISNULL(spcd.hourly_volume_allocation,17601) IN(17603,17604) THEN ISNULL(hg.exp_date,s.expiration_date) ELSE s.expiration_date END expiration_date,''''y'''' AS is_fixedvolume ,deal_status_id, ''''m'''' [deal_volume_frequency],s.term_END [term_END] --[deal_volume_frequency] for finalcial deals are always monthly  
FROM report_hourly_position_breakdown s  (nolock)  
INNER JOIN #books bk ON bk.fas_book_id=s.fas_book_id
	AND bk.source_system_book_id1=s.source_system_book_id1 
	AND bk.source_system_book_id2=s.source_system_book_id2
	AND bk.source_system_book_id3=s.source_system_book_id3 
	AND bk.source_system_book_id4=s.source_system_book_id4
INNER JOIN [deal_status_group] dsg ON  dsg.status_value_id = s.deal_status_id 
LEFT JOIN source_price_curve_def spcd with (nolock) ON spcd.source_curve_def_id=s.curve_id 
LEFT JOIN source_price_curve_def spcd_proxy (nolock) ON spcd_proxy.source_curve_def_id=spcd.settlement_curve_id
outer apply (SELECT sum(volume_mult) term_no_hrs FROM hour_block_term hbt WHERE ISNULL(spcd.hourly_volume_allocation,17601) <17603 and hbt.block_define_id=COALESCE(spcd.block_define_id,300501)	and  hbt.block_type=COALESCE(spcd.block_type,12000) and hbt.term_date between s.term_start  and s.term_END ) term_hrs
outer apply ( SELECT sum(volume_mult) term_no_hrs FROM hour_block_term hbt inner join (SELECT DISTINCT exp_date FROM holiday_group h WHERE  h.hol_group_value_id=ISNULL(spcd.exp_calENDar_id,spcd_proxy.exp_calENDar_id) and h.exp_date between s.term_start  and s.term_END ) ex ON ex.exp_date=hbt.term_date
WHERE  ISNULL(spcd.hourly_volume_allocation,17601) IN(17603,17604) and hbt.block_define_id=COALESCE(spcd.block_define_id,300501)	and  hbt.block_type=COALESCE(spcd.block_type,12000) and hbt.term_date between s.term_start  and s.term_END) term_hrs_exp
LEFT JOIN #term_date hb ON hb.block_define_id=ISNULL(spcd.block_define_id,300501) and hb.term_start = s.term_start
and hb.term_END=s.term_END 
outer apply  (SELECT MAX(exp_date) exp_date FROM holiday_group h WHERE h.hol_date=hb.term_date AND 
h.hol_group_value_id=ISNULL(spcd.exp_calENDar_id,spcd_proxy.exp_calENDar_id) and h.hol_date between s.term_start  and s.term_END AND COALESCE(spcd_proxy.ratio_option,spcd.ratio_option,-1) <> 18800 ) hg   
outer apply  (SELECT MIN(exp_date) hol_date ,MAX(exp_date) hol_date_to  FROM holiday_group h WHERE 1=1 AND h.hol_group_value_id=ISNULL(spcd.exp_calENDar_id,spcd_proxy.exp_calENDar_id) and h.hol_date between s.term_start  and s.term_END AND s.formula NOT IN(''''REBD'''')) hg1   
outer apply  (SELECT count(exp_date) total_days,SUM(CASE WHEN h.exp_date>''''@as_of_date'''' THEN 1 ELSE 0 END) remain_days FROM holiday_group h WHERE h.hol_group_value_id=ISNULL(spcd.exp_calENDar_id,spcd_proxy.exp_calENDar_id) 
AND h.exp_date BETWEEN hg1.hol_date AND ISNULL(hg1.hol_date_to,dbo.FNALastDayInDate(hg1.hol_date))
AND ISNULL(spcd_proxy.ratio_option,spcd.ratio_option) = 18800 AND s.formula NOT IN(''''REBD'''')) remain_month  
WHERE ((ISNULL(spcd_proxy.ratio_option,spcd.ratio_option) = 18800 AND ISNULL(hg1.hol_date_to,''''9999-01-01'''')>''''@as_of_date'''') OR COALESCE(spcd_proxy.ratio_option,spcd.ratio_option,-1) <> 18800)
AND ((ISNULL(spcd.hourly_volume_allocation,17601) IN(17603,17604) and  hg.exp_date is not null) or (ISNULL(spcd.hourly_volume_allocation,17601)<17603 ))		           
AND s.deal_date<=''''@as_of_date''''''
+		
CASE 
	WHEN @_term_start_from IS NULL AND @_term_start_to IS NULL THEN ''''
	WHEN @_term_start_to IS NULL THEN '' AND hb.term_date >= CAST('''''' + CAST(@_term_start_from AS VARCHAR(100)) + '''''' as DATETIME)''
	WHEN @_term_start_from IS NULL THEN '' AND hb.term_date =< CAST('''''' +  CAST(@_term_start_to AS VARCHAR(100)) + ''''''as DATETIME)'' 
	ELSE '' AND hb.term_date BETWEEN CAST('''''' + CAST(@_term_start_from AS VARCHAR(100)) + '''''' as DATETIME) AND CAST('''''' +  CAST(@_term_start_to AS VARCHAR(100)) + ''''''as DATETIME)''
END

PRINT(@_sql)
EXEC(@_sql)

-- hourly position breakdown END
create index indxterm_dat ON #term_date(block_define_id, term_start,term_END)

IF OBJECT_ID(N''tempdb..#temp_position_table'') IS NOT NULL
	DROP TABLE #temp_position_table
	
SELECT * INTO #temp_position_table FROM (
	SELECT * FROM #temp_hourly_position_deal 
	UNION ALL
	SELECT * FROM #temp_hourly_position_profile 
	UNION ALL
	SELECT * FROM #temp_hourly_position_breakdown		
) pos

IF OBJECT_ID(N''tempdb..#temp_hourly_position'') IS NOT NULL
	DROP TABLE #temp_hourly_position

CREATE INDEX ix_pt_tpt ON #temp_position_table(source_deal_header_id,term_start,location_id,curve_id,counterparty_id,expiration_date)
INCLUDE(source_system_book_id1,source_system_book_id2,source_system_book_id3,source_system_book_id4)

SELECT CAST(''@as_of_date'' AS DATETIME) as_of_date, sub.entity_id sub_id,
       stra.entity_id stra_id,
       book.entity_id book_id,
       sub.entity_name sub,
       stra.entity_name strategy,
       book.entity_name book,
       vw.source_deal_header_id,
       sdh.deal_id deal_id,
       (
           CASE 
                WHEN vw.physical_financial_flag = ''p'' THEN ''Physical''
                ELSE ''Financial''
           END
       ) physical_financial_flag,
       vw.deal_date deal_date,
       sml.Location_Name location,
       spcd.curve_name [index],
       spcd_proxy.curve_name proxy_index,
       sdv2.code region,
       sdv.code country,
       sdv1.code grid,
       mjr.location_name location_group,
       com.commodity_name commodity,
       sdv_deal_staus.code deal_status,
       sc.counterparty_name counterparty_name,
       sc.counterparty_name parent_counterparty,
       CONVERT(VARCHAR(7), vw.term_start, 120) term_year_month,
       vw.term_start term_start,
       sb1.source_book_name book_identifier1,
       sb2.source_book_name book_identifier2,
       sb3.source_book_name book_identifier3,
       sb4.source_book_name book_identifier4,
       ssbm.logical_name AS sub_book,
       hb.hr1*vw.Hr1 [01], hb.hr2*vw.Hr2 [02], hb.hr3*vw.Hr3 [03], hb.hr4*vw.Hr4 [04], hb.hr5*vw.Hr5 [05], hb.hr6*vw.Hr6 [06], hb.hr7*vw.Hr7[07] 
        , hb.hr8*vw.Hr8 [08], hb.hr9*vw.Hr9 [09], hb.hr10*vw.Hr10 [10] , hb.hr11*vw.Hr11 [11] , hb.hr12*vw.Hr12 [12], hb.hr13*vw.Hr13 [13]
        , hb.hr14*vw.Hr14 [14], hb.hr15*vw.Hr15 [15], hb.hr16*vw.Hr16 [16], hb.hr17*vw.Hr17 [17], hb.hr18*vw.Hr18 [18], hb.hr19*vw.Hr19 [19] 
        , hb.hr20*vw.Hr20 [20], hb.hr21*vw.Hr21 [21], hb.hr22*vw.Hr22 [22], hb.hr23*vw.Hr23 [23], hb.hr24*vw.Hr24 [24],vw.Hr25 [25], vw.Hr25 [dst_25],
              su_uom.uom_name [uom],
       su_pos_uom.uom_name [postion_uom],
       spcd_monthly_index.curve_name + CASE 
                           WHEN sssd.source_system_id = 2 THEN ''''
                           ELSE ''.'' + sssd.source_system_name
                      END AS [proxy_curve2],
		su_uom_proxy2.uom_name [proxy2_position_uom],
		spcd_proxy_curve3.curve_name + CASE 
                           WHEN sssd2.source_system_id = 2 THEN ''''
                           ELSE ''.'' + sssd2.source_system_name
                      END AS [proxy_curve3],
        su_uom_proxy3.uom_name [proxy3_position_uom], 
		sdv_block.code [block_definition],
		CASE WHEN vw.deal_volume_frequency = ''h'' THEN ''Hourly''
			WHEN vw.deal_volume_frequency = ''d'' THEN ''Daily''
			WHEN vw.deal_volume_frequency = ''m'' THEN ''Monthly''
			WHEN vw.deal_volume_frequency = ''t'' THEN ''Term''
			WHEN vw.deal_volume_frequency = ''a'' THEN  ''Annually''     
			WHEN vw.deal_volume_frequency = ''x'' THEN ''15 Minutes''      
			WHEN vw.deal_volume_frequency = ''y'' THEN  ''30 Minutes''     
		END  [deal_volume_frequency]   ,
		spcd_proxy_curve_def.curve_name [proxy_curve],
		su_uom_proxy_curve_def.uom_name [proxy_curve_position_uom],
		YEAR(vw.term_start) term_year,
		vw.term_start term_END,
		sc.source_counterparty_id counterparty_id,
		sml.source_minor_location_id location_id,  
		su_uom_proxy_curve.uom_name proxy_index_position_uom,
		spcd.source_curve_def_id [index_id],
		vw.period,
		ssbm.book_deal_type_map_id [sub_book_id] ,
		ISNULL(grp.block_name, spcd.curve_name) block_name,
        sdv_block_group.code [user_defined_block] ,
        sdv_block_group.value_id [user_defined_block_id] ,
com.source_commodity_id commodity_id
       INTO #temp_hourly_position
FROM
#temp_position_table vw
cross join (SELECT * FROM block_type_group WHERE block_type_group_id=ISNULL(@_block_type_group_id,block_type_group_id )) grp
LEFT JOIN source_minor_location sml ON sml.source_minor_location_id = vw.location_id
INNER JOIN source_price_curve_def spcd ON spcd.source_curve_def_id = vw.curve_id  
LEFT JOIN  source_price_curve_def spcd_proxy ON spcd_proxy.source_curve_def_id=spcd.proxy_curve_id
LEFT JOIN  source_price_curve_def spcd_proxy_curve3 ON spcd_proxy_curve3.source_curve_def_id=spcd.proxy_curve_id3
LEFT JOIN  source_price_curve_def spcd_monthly_index ON spcd_monthly_index.source_curve_def_id=spcd.monthly_index
LEFT JOIN  source_price_curve_def spcd_proxy_curve_def ON spcd_proxy_curve_def.source_curve_def_id=spcd.proxy_source_curve_def_id
--LEFT JOIN  block_type_group grp (nolock) ON spcd.udf_block_group_id = grp.block_type_group_id 
LEFT JOIN  hour_block_term hb (nolock)  ON hb.block_define_id=COALESCE(grp.hourly_block_id,300501) AND  hb.block_type=COALESCE(grp.block_type_id,12000) and vw.term_start=hb.term_date
LEFT JOIN source_system_description sssd ON sssd.source_system_id = spcd_monthly_index.source_system_id
LEFT JOIN source_system_description sssd2 ON sssd.source_system_id = spcd_proxy_curve3.source_system_id
LEFT JOIN static_data_value sdv1 ON sdv1.value_id=sml.grid_value_id
LEFT JOIN static_data_value sdv ON sdv.value_id=sml.country
LEFT JOIN static_data_value sdv2 ON sdv2.value_id=sml.region
LEFT JOIN source_major_location mjr ON sml.source_major_location_ID=mjr.source_major_location_ID
LEFT JOIN source_uom AS su_pos_uom ON su_pos_uom.source_uom_id = ISNULL(spcd.display_uom_id,spcd.uom_id)
LEFT JOIN source_uom su_uom ON su_uom.source_uom_id= spcd.uom_id
LEFT JOIN source_uom su_uom_proxy3 ON su_uom_proxy3.source_uom_id= ISNULL(spcd_proxy_curve3.display_uom_id,spcd_proxy_curve3.uom_id)--spcd_proxy_curve3.display_uom_id
LEFT JOIN source_uom su_uom_proxy2 ON su_uom_proxy2.source_uom_id= ISNULL(spcd_monthly_index.display_uom_id,spcd_monthly_index.uom_id)
LEFT JOIN source_uom su_uom_proxy_curve_def ON su_uom_proxy_curve_def.source_uom_id= ISNULL(spcd_proxy_curve_def.display_uom_id,spcd_proxy_curve_def.uom_id)--spcd_proxy_curve_def.display_uom_id
LEFT JOIN source_uom su_uom_proxy_curve ON su_uom_proxy_curve.source_uom_id= ISNULL(spcd_proxy.display_uom_id,spcd_proxy.uom_id)
LEFT JOIN source_counterparty sc ON sc.source_counterparty_id = vw.counterparty_id 
LEFT JOIN source_counterparty psc  ON psc.source_counterparty_id=sc.parent_counterparty_id
LEFT JOIN source_commodity com ON com.source_commodity_id=spcd.commodity_id 
LEFT JOIN portfolio_hierarchy book ON book.entity_id = vw.fas_book_id 
LEFT JOIN portfolio_hierarchy stra ON stra.entity_id = book.parent_entity_id 
LEFT JOIN portfolio_hierarchy sub ON sub.entity_id = stra.parent_entity_id
LEFT JOIN source_deal_header sdh ON sdh.source_deal_header_id = vw.source_deal_header_id
LEFT JOIN static_data_value sdv_deal_staus ON sdv_deal_staus.value_id = vw.deal_status_id
LEFT JOIN source_system_book_map ssbm ON ssbm.source_system_book_id1 = vw.source_system_book_id1
	AND ssbm.source_system_book_id2 = vw.source_system_book_id2
	AND ssbm.source_system_book_id3 = vw.source_system_book_id3
	AND ssbm.source_system_book_id4 = vw.source_system_book_id4
LEFT JOIN source_book sb1 ON sb1.source_book_id = vw.source_system_book_id1
LEFT JOIN source_book sb2 ON sb2.source_book_id = vw.source_system_book_id2
LEFT JOIN source_book sb3 ON sb3.source_book_id = vw.source_system_book_id3
LEFT JOIN source_book sb4 ON sb4.source_book_id = vw.source_system_book_id4
LEFT JOIN static_data_value sdv_block ON sdv_block.value_id  = sdh.block_define_id
LEFT JOIN static_data_value sdv_block_group ON sdv_block_group.value_id = grp.block_type_group_id
WHERE vw.expiration_date > ''@as_of_date'' AND vw.term_start > ''@as_of_date''

SELECT 
	as_of_date,
    sub_id,
    stra_id,
    book_id,
    sub,
    strategy [stra],
    book,
    source_deal_header_id,
    deal_id,
    physical_financial_flag,
    deal_date,
    location,
    [index] AS curve_name,
    proxy_index,
    region,
    country,
    grid,
    location_group,
    commodity,
    deal_status,
    counterparty_name,
    parent_counterparty,
    term_year_month,
    term_start,
    book_identifier1,
    book_identifier2,
    book_identifier3,
    book_identifier4,
    sub_book,
    uom,
    postion_uom,
    proxy_curve2,
    proxy2_position_uom,
    proxy_curve3,
    proxy3_position_uom,
    block_definition,
    deal_volume_frequency,
    proxy_curve,
    proxy_curve_position_uom,
    term_year,
    term_END,
    counterparty_id,
    location_id,
    proxy_index_position_uom,
    index_id AS [curve_id],
    unpvt.period,       
	CASE WHEN unpvt.Hours=25 THEN dst.[hour] 
		ELSE unpvt.Hours 
	END Hours,
	unpvt.Volume - CASE 
		WHEN dst.[hour] is not null and unpvt.hours=dst.[hour] 
		THEN ISNULL(unpvt.dst_25,0) 
		ELSE 0 
	END volume,
	CASE WHEN unpvt.hours=25 THEN 1 ELSE 0 END is_dst,
	sub_book_id,
	block_name,
	[user_defined_block] ,
	[user_defined_block_id],
	''@period_to'' period_to,
	''@period_from'' period_from,
commodity_id
--[__batch_report__] 
FROM
 #temp_hourly_position thp
UNPIVOT (Volume FOR Hours IN (thp.[01] , thp.[02] , thp.[03] , thp.[04] , thp.[05] , thp.[06] , thp.[07] 
           , thp.[08] , thp.[09] , thp.[10] , thp.[11] , thp.[12] , thp.[13] 
           , thp.[14] , thp.[15] , thp.[16] , thp.[17] , thp.[18] , thp.[19] 
           , thp.[20] , thp.[21] , thp.[22] , thp.[23] , thp.[24],thp.[25])) AS unpvt           
LEFT JOIN	mv90_dst dst ON dst.[date] = unpvt.term_start and insert_delete = ''i'' 
	WHERE unpvt.Hours<25 or (unpvt.Hours=25 and dst.[hour] is not null)' AS [tsql], @report_id_data_source_dest AS report_id
	END 
	
	IF OBJECT_ID('tempdb..#data_source_column', 'U') IS NOT NULL
		DROP TABLE #data_source_column	
	CREATE TABLE #data_source_column(column_id INT)	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position View Hourly With Block Type'
	            AND dsc.name =  'as_of_date'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'As of Date'
			   , reqd_param = 1, widget_id = 6, datatype_id = 2, param_data_source = NULL, param_default_value = NULL, append_filter = 0, tooltip = NULL, column_template = 4, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position View Hourly With Block Type'
			AND dsc.name =  'as_of_date'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'as_of_date' AS [name], 'As of Date' AS ALIAS, 1 AS reqd_param, 6 AS widget_id, 2 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 0 AS append_filter, NULL  AS tooltip,4 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Position View Hourly With Block Type'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position View Hourly With Block Type'
	            AND dsc.name =  'book'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Book'
			   , reqd_param = 0, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position View Hourly With Block Type'
			AND dsc.name =  'book'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'book' AS [name], 'Book' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Position View Hourly With Block Type'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position View Hourly With Block Type'
	            AND dsc.name =  'book_id'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Book ID'
			   , reqd_param = 1, widget_id = 5, datatype_id = 4, param_data_source = NULL, param_default_value = NULL, append_filter = 0, tooltip = NULL, column_template = 2, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position View Hourly With Block Type'
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
		INNER JOIN data_source ds ON ds.[name] = 'Position View Hourly With Block Type'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position View Hourly With Block Type'
	            AND dsc.name =  'book_identifier1'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Book ID1'
			   , reqd_param = 0, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position View Hourly With Block Type'
			AND dsc.name =  'book_identifier1'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'book_identifier1' AS [name], 'Book ID1' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Position View Hourly With Block Type'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position View Hourly With Block Type'
	            AND dsc.name =  'book_identifier2'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Book ID2'
			   , reqd_param = 0, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position View Hourly With Block Type'
			AND dsc.name =  'book_identifier2'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'book_identifier2' AS [name], 'Book ID2' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Position View Hourly With Block Type'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position View Hourly With Block Type'
	            AND dsc.name =  'book_identifier3'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Book ID3'
			   , reqd_param = 0, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position View Hourly With Block Type'
			AND dsc.name =  'book_identifier3'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'book_identifier3' AS [name], 'Book ID3' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Position View Hourly With Block Type'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position View Hourly With Block Type'
	            AND dsc.name =  'book_identifier4'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Book ID4'
			   , reqd_param = 0, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position View Hourly With Block Type'
			AND dsc.name =  'book_identifier4'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'book_identifier4' AS [name], 'Book ID4' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Position View Hourly With Block Type'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position View Hourly With Block Type'
	            AND dsc.name =  'commodity'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Commodity'
			   , reqd_param = 0, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position View Hourly With Block Type'
			AND dsc.name =  'commodity'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'commodity' AS [name], 'Commodity' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Position View Hourly With Block Type'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position View Hourly With Block Type'
	            AND dsc.name =  'country'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Country'
			   , reqd_param = 0, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position View Hourly With Block Type'
			AND dsc.name =  'country'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'country' AS [name], 'Country' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Position View Hourly With Block Type'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position View Hourly With Block Type'
	            AND dsc.name =  'deal_date'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Deal Date'
			   , reqd_param = 0, widget_id = 6, datatype_id = 2, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 4, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position View Hourly With Block Type'
			AND dsc.name =  'deal_date'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'deal_date' AS [name], 'Deal Date' AS ALIAS, 0 AS reqd_param, 6 AS widget_id, 2 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,4 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Position View Hourly With Block Type'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position View Hourly With Block Type'
	            AND dsc.name =  'deal_id'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Reference ID'
			   , reqd_param = 0, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position View Hourly With Block Type'
			AND dsc.name =  'deal_id'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'deal_id' AS [name], 'Reference ID' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Position View Hourly With Block Type'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position View Hourly With Block Type'
	            AND dsc.name =  'deal_status'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Deal Status'
			   , reqd_param = 0, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position View Hourly With Block Type'
			AND dsc.name =  'deal_status'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'deal_status' AS [name], 'Deal Status' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Position View Hourly With Block Type'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position View Hourly With Block Type'
	            AND dsc.name =  'grid'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Grid'
			   , reqd_param = 0, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position View Hourly With Block Type'
			AND dsc.name =  'grid'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'grid' AS [name], 'Grid' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Position View Hourly With Block Type'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position View Hourly With Block Type'
	            AND dsc.name =  'Hours'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Hour'
			   , reqd_param = 0, widget_id = 1, datatype_id = 4, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position View Hourly With Block Type'
			AND dsc.name =  'Hours'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'Hours' AS [name], 'Hour' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 4 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Position View Hourly With Block Type'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position View Hourly With Block Type'
	            AND dsc.name =  'location'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Location'
			   , reqd_param = 0, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position View Hourly With Block Type'
			AND dsc.name =  'location'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'location' AS [name], 'Location' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Position View Hourly With Block Type'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position View Hourly With Block Type'
	            AND dsc.name =  'location_group'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Location Group'
			   , reqd_param = 0, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position View Hourly With Block Type'
			AND dsc.name =  'location_group'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'location_group' AS [name], 'Location Group' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Position View Hourly With Block Type'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position View Hourly With Block Type'
	            AND dsc.name =  'parent_counterparty'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Parent Counterparty'
			   , reqd_param = 0, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position View Hourly With Block Type'
			AND dsc.name =  'parent_counterparty'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'parent_counterparty' AS [name], 'Parent Counterparty' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Position View Hourly With Block Type'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position View Hourly With Block Type'
	            AND dsc.name =  'physical_financial_flag'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Physical Financial'
			   , reqd_param = 0, widget_id = 2, datatype_id = 5, param_data_source = '[''Physical'',''Physical''] ,[''Financial'',''Financial'']', param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position View Hourly With Block Type'
			AND dsc.name =  'physical_financial_flag'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'physical_financial_flag' AS [name], 'Physical Financial' AS ALIAS, 0 AS reqd_param, 2 AS widget_id, 5 AS datatype_id, '[''Physical'',''Physical''] ,[''Financial'',''Financial'']' AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Position View Hourly With Block Type'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position View Hourly With Block Type'
	            AND dsc.name =  'proxy_index'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Proxy Index'
			   , reqd_param = 0, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position View Hourly With Block Type'
			AND dsc.name =  'proxy_index'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'proxy_index' AS [name], 'Proxy Index' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Position View Hourly With Block Type'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position View Hourly With Block Type'
	            AND dsc.name =  'region'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Region'
			   , reqd_param = 0, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position View Hourly With Block Type'
			AND dsc.name =  'region'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'region' AS [name], 'Region' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Position View Hourly With Block Type'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position View Hourly With Block Type'
	            AND dsc.name =  'source_deal_header_id'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Deal ID'
			   , reqd_param = 0, widget_id = 1, datatype_id = 4, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 2, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position View Hourly With Block Type'
			AND dsc.name =  'source_deal_header_id'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'source_deal_header_id' AS [name], 'Deal ID' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 4 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Position View Hourly With Block Type'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position View Hourly With Block Type'
	            AND dsc.name =  'stra_id'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Strategy ID'
			   , reqd_param = 1, widget_id = 4, datatype_id = 4, param_data_source = NULL, param_default_value = NULL, append_filter = 0, tooltip = NULL, column_template = 2, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position View Hourly With Block Type'
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
		INNER JOIN data_source ds ON ds.[name] = 'Position View Hourly With Block Type'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position View Hourly With Block Type'
	            AND dsc.name =  'sub'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Subsidiary'
			   , reqd_param = 0, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position View Hourly With Block Type'
			AND dsc.name =  'sub'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'sub' AS [name], 'Subsidiary' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Position View Hourly With Block Type'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position View Hourly With Block Type'
	            AND dsc.name =  'sub_id'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Subsidiary ID'
			   , reqd_param = 1, widget_id = 3, datatype_id = 4, param_data_source = NULL, param_default_value = NULL, append_filter = 0, tooltip = NULL, column_template = 2, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position View Hourly With Block Type'
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
		INNER JOIN data_source ds ON ds.[name] = 'Position View Hourly With Block Type'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position View Hourly With Block Type'
	            AND dsc.name =  'term_start'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Term Start'
			   , reqd_param = 0, widget_id = 6, datatype_id = 2, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 4, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position View Hourly With Block Type'
			AND dsc.name =  'term_start'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'term_start' AS [name], 'Term Start' AS ALIAS, 0 AS reqd_param, 6 AS widget_id, 2 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,4 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Position View Hourly With Block Type'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position View Hourly With Block Type'
	            AND dsc.name =  'term_year_month'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Term Year Month'
			   , reqd_param = 0, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position View Hourly With Block Type'
			AND dsc.name =  'term_year_month'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'term_year_month' AS [name], 'Term Year Month' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Position View Hourly With Block Type'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position View Hourly With Block Type'
	            AND dsc.name =  'uom'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'UOM'
			   , reqd_param = 0, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position View Hourly With Block Type'
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
		INNER JOIN data_source ds ON ds.[name] = 'Position View Hourly With Block Type'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position View Hourly With Block Type'
	            AND dsc.name =  'volume'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Volume'
			   , reqd_param = 0, widget_id = 1, datatype_id = 3, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 2, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position View Hourly With Block Type'
			AND dsc.name =  'volume'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'volume' AS [name], 'Volume' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 3 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Position View Hourly With Block Type'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position View Hourly With Block Type'
	            AND dsc.name =  'postion_uom'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Postion UOM'
			   , reqd_param = 0, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position View Hourly With Block Type'
			AND dsc.name =  'postion_uom'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'postion_uom' AS [name], 'Postion UOM' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Position View Hourly With Block Type'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position View Hourly With Block Type'
	            AND dsc.name =  'proxy_curve2'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Proxy Curve2'
			   , reqd_param = 0, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position View Hourly With Block Type'
			AND dsc.name =  'proxy_curve2'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'proxy_curve2' AS [name], 'Proxy Curve2' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Position View Hourly With Block Type'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position View Hourly With Block Type'
	            AND dsc.name =  'proxy_curve3'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Proxy Curve3'
			   , reqd_param = 0, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position View Hourly With Block Type'
			AND dsc.name =  'proxy_curve3'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'proxy_curve3' AS [name], 'Proxy Curve3' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Position View Hourly With Block Type'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position View Hourly With Block Type'
	            AND dsc.name =  'block_definition'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Block Definition'
			   , reqd_param = 0, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position View Hourly With Block Type'
			AND dsc.name =  'block_definition'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'block_definition' AS [name], 'Block Definition' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Position View Hourly With Block Type'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position View Hourly With Block Type'
	            AND dsc.name =  'deal_volume_frequency'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Volume Frequency'
			   , reqd_param = 0, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position View Hourly With Block Type'
			AND dsc.name =  'deal_volume_frequency'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'deal_volume_frequency' AS [name], 'Volume Frequency' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Position View Hourly With Block Type'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position View Hourly With Block Type'
	            AND dsc.name =  'proxy_curve'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Proxy Curve'
			   , reqd_param = 0, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position View Hourly With Block Type'
			AND dsc.name =  'proxy_curve'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'proxy_curve' AS [name], 'Proxy Curve' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Position View Hourly With Block Type'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position View Hourly With Block Type'
	            AND dsc.name =  'proxy_curve_position_uom'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Proxy Curve Position UOM'
			   , reqd_param = 0, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position View Hourly With Block Type'
			AND dsc.name =  'proxy_curve_position_uom'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'proxy_curve_position_uom' AS [name], 'Proxy Curve Position UOM' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Position View Hourly With Block Type'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position View Hourly With Block Type'
	            AND dsc.name =  'proxy2_position_uom'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Proxy2 Position UOM'
			   , reqd_param = 0, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position View Hourly With Block Type'
			AND dsc.name =  'proxy2_position_uom'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'proxy2_position_uom' AS [name], 'Proxy2 Position UOM' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Position View Hourly With Block Type'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position View Hourly With Block Type'
	            AND dsc.name =  'proxy3_position_uom'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Proxy3 Position UOM'
			   , reqd_param = 0, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position View Hourly With Block Type'
			AND dsc.name =  'proxy3_position_uom'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'proxy3_position_uom' AS [name], 'Proxy3 Position UOM' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Position View Hourly With Block Type'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position View Hourly With Block Type'
	            AND dsc.name =  'term_year'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Term Year'
			   , reqd_param = 0, widget_id = 1, datatype_id = 4, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 2, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position View Hourly With Block Type'
			AND dsc.name =  'term_year'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'term_year' AS [name], 'Term Year' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 4 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Position View Hourly With Block Type'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position View Hourly With Block Type'
	            AND dsc.name =  'counterparty_id'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Counterparty ID'
			   , reqd_param = 0, widget_id = 7, datatype_id = 4, param_data_source = '10191000', param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 2, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position View Hourly With Block Type'
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
		INNER JOIN data_source ds ON ds.[name] = 'Position View Hourly With Block Type'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position View Hourly With Block Type'
	            AND dsc.name =  'location_id'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Location ID'
			   , reqd_param = 0, widget_id = 7, datatype_id = 4, param_data_source = '10102500', param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 2, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position View Hourly With Block Type'
			AND dsc.name =  'location_id'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'location_id' AS [name], 'Location ID' AS ALIAS, 0 AS reqd_param, 7 AS widget_id, 4 AS datatype_id, '10102500' AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Position View Hourly With Block Type'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position View Hourly With Block Type'
	            AND dsc.name =  'proxy_index_position_uom'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Proxy Index Position UOM'
			   , reqd_param = 0, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position View Hourly With Block Type'
			AND dsc.name =  'proxy_index_position_uom'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'proxy_index_position_uom' AS [name], 'Proxy Index Position UOM' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Position View Hourly With Block Type'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position View Hourly With Block Type'
	            AND dsc.name =  'term_END'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Term End'
			   , reqd_param = 0, widget_id = 6, datatype_id = 2, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 4, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position View Hourly With Block Type'
			AND dsc.name =  'term_END'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'term_END' AS [name], 'Term End' AS ALIAS, 0 AS reqd_param, 6 AS widget_id, 2 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,4 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Position View Hourly With Block Type'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position View Hourly With Block Type'
	            AND dsc.name =  'counterparty_name'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Counterparty'
			   , reqd_param = 0, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position View Hourly With Block Type'
			AND dsc.name =  'counterparty_name'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'counterparty_name' AS [name], 'Counterparty' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Position View Hourly With Block Type'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position View Hourly With Block Type'
	            AND dsc.name =  'curve_id'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Curve ID'
			   , reqd_param = 0, widget_id = 7, datatype_id = 4, param_data_source = '10102600', param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 2, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position View Hourly With Block Type'
			AND dsc.name =  'curve_id'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'curve_id' AS [name], 'Curve ID' AS ALIAS, 0 AS reqd_param, 7 AS widget_id, 4 AS datatype_id, '10102600' AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Position View Hourly With Block Type'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position View Hourly With Block Type'
	            AND dsc.name =  'curve_name'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Index'
			   , reqd_param = 0, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position View Hourly With Block Type'
			AND dsc.name =  'curve_name'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'curve_name' AS [name], 'Index' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Position View Hourly With Block Type'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position View Hourly With Block Type'
	            AND dsc.name =  'is_dst'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'DST'
			   , reqd_param = 0, widget_id = 1, datatype_id = 4, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 2, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position View Hourly With Block Type'
			AND dsc.name =  'is_dst'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'is_dst' AS [name], 'DST' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 4 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Position View Hourly With Block Type'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position View Hourly With Block Type'
	            AND dsc.name =  'sub_book'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Sub Book'
			   , reqd_param = 0, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position View Hourly With Block Type'
			AND dsc.name =  'sub_book'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'sub_book' AS [name], 'Sub Book' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Position View Hourly With Block Type'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position View Hourly With Block Type'
	            AND dsc.name =  'stra'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Strategy'
			   , reqd_param = 0, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position View Hourly With Block Type'
			AND dsc.name =  'stra'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'stra' AS [name], 'Strategy' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Position View Hourly With Block Type'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position View Hourly With Block Type'
	            AND dsc.name =  'period'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Period'
			   , reqd_param = 0, widget_id = 1, datatype_id = 4, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 2, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position View Hourly With Block Type'
			AND dsc.name =  'period'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'period' AS [name], 'Period' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 4 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Position View Hourly With Block Type'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position View Hourly With Block Type'
	            AND dsc.name =  'sub_book_id'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Sub Book ID'
			   , reqd_param = 1, widget_id = 8, datatype_id = 4, param_data_source = NULL, param_default_value = NULL, append_filter = 0, tooltip = NULL, column_template = 2, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position View Hourly With Block Type'
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
		INNER JOIN data_source ds ON ds.[name] = 'Position View Hourly With Block Type'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position View Hourly With Block Type'
	            AND dsc.name =  'block_name'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Block Name'
			   , reqd_param = 0, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position View Hourly With Block Type'
			AND dsc.name =  'block_name'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'block_name' AS [name], 'Block Name' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Position View Hourly With Block Type'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position View Hourly With Block Type'
	            AND dsc.name =  'user_defined_block'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'User Defined Block'
			   , reqd_param = 0, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position View Hourly With Block Type'
			AND dsc.name =  'user_defined_block'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'user_defined_block' AS [name], 'User Defined Block' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Position View Hourly With Block Type'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position View Hourly With Block Type'
	            AND dsc.name =  'user_defined_block_id'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'User Defined Block ID'
			   , reqd_param = 1, widget_id = 2, datatype_id = 4, param_data_source = 'EXEC spa_StaticDataValues @flag = ''h'', @type_id = 15001', param_default_value = NULL, append_filter = 0, tooltip = NULL, column_template = 2, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position View Hourly With Block Type'
			AND dsc.name =  'user_defined_block_id'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'user_defined_block_id' AS [name], 'User Defined Block ID' AS ALIAS, 1 AS reqd_param, 2 AS widget_id, 4 AS datatype_id, 'EXEC spa_StaticDataValues @flag = ''h'', @type_id = 15001' AS param_data_source, NULL AS param_default_value, 0 AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Position View Hourly With Block Type'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position View Hourly With Block Type'
	            AND dsc.name =  'period_from'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Period From'
			   , reqd_param = 1, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 0, tooltip = NULL, column_template = 0, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position View Hourly With Block Type'
			AND dsc.name =  'period_from'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'period_from' AS [name], 'Period From' AS ALIAS, 1 AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 0 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Position View Hourly With Block Type'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position View Hourly With Block Type'
	            AND dsc.name =  'period_to'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Period To'
			   , reqd_param = 1, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 0, tooltip = NULL, column_template = 0, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position View Hourly With Block Type'
			AND dsc.name =  'period_to'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'period_to' AS [name], 'Period To' AS ALIAS, 1 AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 0 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Position View Hourly With Block Type'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position View Hourly With Block Type'
	            AND dsc.name =  'commodity_id'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Commodity ID'
			   , reqd_param = 0, widget_id = 2, datatype_id = 4, param_data_source = 'EXEC spa_source_commodity_maintain ''a''', param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 2, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position View Hourly With Block Type'
			AND dsc.name =  'commodity_id'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'commodity_id' AS [name], 'Commodity ID' AS ALIAS, 0 AS reqd_param, 2 AS widget_id, 4 AS datatype_id, 'EXEC spa_source_commodity_maintain ''a''' AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Position View Hourly With Block Type'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	DELETE dsc
	FROM data_source_column dsc 
	INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		AND ds.[name] = 'Position View Hourly With Block Type'
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
	