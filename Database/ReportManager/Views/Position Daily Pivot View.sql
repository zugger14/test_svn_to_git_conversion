BEGIN TRY
		BEGIN TRAN
	

	DECLARE @report_id_data_source_dest INT 
	
	SELECT @report_id_data_source_dest = report_id
	FROM report r
	WHERE r.[name] = NULL

	IF EXISTS (SELECT 1 
	           FROM data_source 
	           WHERE [name] = 'Position Daily Pivot View'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
			
	BEGIN
		UPDATE data_source
		SET alias = 'PDPV', description = ''
		, [tsql] = CAST('' AS VARCHAR(MAX)) + 'IF OBJECT_ID(N''tempdb..#books'') IS NOT NULL
	DROP TABLE #books
IF OBJECT_ID(N''tempdb..#term_date'') IS NOT NULL
	DROP TABLE #term_date


DECLARE @_as_of_date VARCHAR(25) = ''''
DECLARE @_uom_id VARCHAR(25) = ''74''
select @_uom_id = source_uom_id from source_uom where uom_name = ''MT''

SELECT @_as_of_date = ma.as_of_date
FROM module_asofdate ma
WHERE ma.module_type = 15500

IF OBJECT_ID(N''tempdb..#books'') IS NOT NULL
	DROP TABLE #books

CREATE TABLE #books (fas_book_id INT, source_system_book_id1 INT ,source_system_book_id2 INT,source_system_book_id3 INT,source_system_book_id4 INT)   
 
INSERT INTO #books
SELECT DISTINCT 
	   book.entity_id,
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
	
select 
distinct isnull(spcd.block_define_id,300501) block_define_id,s.term_start,s.term_end 
INTO #temp_report_hourly_position_breakdown
from report_hourly_position_breakdown s  (nolock)  
INNER JOIN #books bk ON bk.fas_book_id=s.fas_book_id 
	AND bk.source_system_book_id1=s.source_system_book_id1 AND bk.source_system_book_id2=s.source_system_book_id2 
	AND bk.source_system_book_id3=s.source_system_book_id3 AND bk.source_system_book_id4=s.source_system_book_id4 
INNER JOIN [deal_status_group] dsg ON dsg.status_value_id = s.deal_status_id  
left JOIN source_price_curve_def spcd with (nolock) 
ON spcd.source_curve_def_id=s.curve_id 

CREATE TABLE #term_date( block_define_id int ,term_date date,term_start date,term_end date,
	hr1 tinyint,hr2 tinyint,hr3 tinyint,hr4 tinyint,hr5 tinyint,hr6 tinyint,hr7 tinyint,hr8 tinyint
	,hr9 tinyint,hr10 tinyint,hr11 tinyint,hr12 tinyint,hr13 tinyint,hr14 tinyint,hr15 tinyint,hr16 tinyint
	,hr17 tinyint,hr18 tinyint,hr19 tinyint,hr20 tinyint,hr21 tinyint,hr22 tinyint,hr23 tinyint,hr24 tinyint,add_dst_hour int
)
insert into #term_date(block_define_id  ,term_date,term_start,term_end,
hr1 ,hr2 ,hr3 ,hr4 ,hr5 ,hr6 ,hr7 ,hr8 ,hr9 ,hr10 ,hr11 ,hr12 ,hr13 ,hr14 ,hr15 ,hr16 
,hr17 ,hr18 ,hr19 ,hr20 ,hr21 ,hr22 ,hr23 ,hr24 ,add_dst_hour
)
select distinct a.block_define_id  ,hb.term_date,a.term_start ,a.term_end,
	hb.hr1 ,hb.hr2 ,hb.hr3 ,hb.hr4 ,hb.hr5 ,hb.hr6 ,hb.hr7 ,hb.hr8 
	,hb.hr9 ,hb.hr10 ,hb.hr11 ,hb.hr12 ,hb.hr13 ,hb.hr14 ,hb.hr15 ,hb.hr16 
	,hb.hr17 ,hb.hr18 ,hb.hr19 ,hb.hr20 ,hb.hr21 ,hb.hr22 ,hb.hr23 ,hb.hr24 ,hb.add_dst_hour
from #temp_report_hourly_position_breakdown a
		outer apply	(select h.* from hour_block_term h with (nolock) where block_define_id=a.block_define_id and h.block_type=12000 
		and term_date between a.term_start  and a.term_end
) hb
----- hourly position deal start
IF OBJECT_ID(N''tempdb..#temp_hourly_position_deal'') IS NOT NULL
	DROP TABLE #temp_hourly_position_deal
	
select s.curve_id,s.location_id,s.term_start,0 period,s.deal_date,s.deal_volume_uom_id,s.physical_financial_flag,s.hr1,s.hr2,s.hr3,s.hr4,s.hr5,s.hr6,s.hr7,s.hr8,s.hr9,s.hr10,s.hr11,s.hr12,s.hr13,s.hr14,s.hr15,s.hr16,s.hr17,s.hr18,s.hr19,s.hr20,s.hr21,s.hr22,s.hr23,s.hr24,s.hr25,s.source_deal_header_id,s.commodity_id,s.counterparty_id,s.fas_book_id,s.source_system_book_id1,s.source_system_book_id2
	,s.source_system_book_id3,s.source_system_book_id4,s.expiration_date,''n'' AS is_fixedvolume,deal_status_id,sdd.deal_volume_frequency,sdd.term_end 
INTO #temp_hourly_position_deal
 from report_hourly_position_deal s  (nolock)  INNER JOIN #books bk ON bk.fas_book_id=s.fas_book_id AND bk.source_system_book_id1=s.source_system_book_id1
AND bk.source_system_book_id2=s.source_system_book_id2 AND bk.source_system_book_id3=s.source_system_book_id3
AND bk.source_system_book_id4=s.source_system_book_id4 
INNER JOIN [deal_status_group] dsg ON  dsg.status_value_id = s.deal_status_id 
left join source_price_curve_def spcd on spcd.source_curve_def_id=s.curve_id
--------------
left JOIN source_deal_detail sdd 
		ON s.term_start BETWEEN sdd.term_start AND sdd.term_end
		AND sdd.source_deal_detail_id = s.source_deal_detail_id  
--------------		  
WHERE 1=1
--AND s.deal_date<=@_as_of_date  
AND s.expiration_date > @_as_of_date AND s.term_start > @_as_of_date
----- hourly position deal end
----- hourly position profile start
IF OBJECT_ID(N''tempdb..#temp_hourly_position_profile'') IS NOT NULL
	DROP TABLE #temp_hourly_position_profile

select s.curve_id,s.location_id,s.term_start,0 Period,s.deal_date,s.deal_volume_uom_id,s.physical_financial_flag,s.hr1,s.hr2,s.hr3,s.hr4,s.hr5,s.hr6,s.hr7,s.hr8,s.hr9,s.hr10,s.hr11,s.hr12,s.hr13,s.hr14,s.hr15,s.hr16,s.hr17,s.hr18,s.hr19,s.hr20,s.hr21,s.hr22,s.hr23,s.hr24,s.hr25,s.source_deal_header_id,s.commodity_id,s.counterparty_id,s.fas_book_id,s.source_system_book_id1,s.source_system_book_id2,s.source_system_book_id3,s.source_system_book_id4 
,s.expiration_date,''n'' AS is_fixedvolume,deal_status_id,sdd.deal_volume_frequency,sdd.term_end 
INTO #temp_hourly_position_profile
from report_hourly_position_profile s  (nolock)  
INNER JOIN #books bk ON bk.fas_book_id=s.fas_book_id 
AND bk.source_system_book_id1=s.source_system_book_id1	
AND bk.source_system_book_id2=s.source_system_book_id2	AND bk.source_system_book_id3=s.source_system_book_id3
AND bk.source_system_book_id4=s.source_system_book_id4 
INNER JOIN [deal_status_group] dsg ON  dsg.status_value_id = s.deal_status_id 
left join source_price_curve_def spcd on spcd.source_curve_def_id=s.curve_id
-------------
left JOIN source_deal_detail sdd 
		ON s.term_start BETWEEN sdd.term_start AND sdd.term_end
		AND sdd.source_deal_detail_id = s.source_deal_detail_id  
----------------
WHERE  1=1
--AND s.deal_date<=@_as_of_date  
AND s.expiration_date > @_as_of_date AND s.term_start > @_as_of_date
---- hourly position profile end

IF OBJECT_ID(N''tempdb..#temp_hourly_position_breakdown'') IS NOT NULL
	DROP TABLE #temp_hourly_position_breakdown
----- hourly position breakdown start

select s.curve_id,ISNULL(s.location_id,-1) location_id,hb.term_date term_start,0 period,s.deal_date,s.deal_volume_uom_id,s.physical_financial_flag
,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr1,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=1 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))/cast(nullif(isnull(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) as numeric(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,@_as_of_date)) AS VARCHAR)+''-''+CAST(MONTH(DATEADD(m,1,@_as_of_date)) AS VARCHAR)+''-01'' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  AS Hr1
,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr2,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=2 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))/cast(nullif(isnull(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) as numeric(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,@_as_of_date)) AS VARCHAR)+''-''+CAST(MONTH(DATEADD(m,1,@_as_of_date)) AS VARCHAR)+''-01'' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  AS Hr2
,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr3,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=3 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))/cast(nullif(isnull(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) as numeric(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,@_as_of_date)) AS VARCHAR)+''-''+CAST(MONTH(DATEADD(m,1,@_as_of_date)) AS VARCHAR)+''-01'' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  AS Hr3
,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr4,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=4 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))/cast(nullif(isnull(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) as numeric(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,@_as_of_date)) AS VARCHAR)+''-''+CAST(MONTH(DATEADD(m,1,@_as_of_date)) AS VARCHAR)+''-01'' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  AS Hr4
,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr5,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=5 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))/cast(nullif(isnull(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) as numeric(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,@_as_of_date)) AS VARCHAR)+''-''+CAST(MONTH(DATEADD(m,1,@_as_of_date)) AS VARCHAR)+''-01'' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  AS Hr5
,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr6,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=6 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))/cast(nullif(isnull(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) as numeric(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,@_as_of_date)) AS VARCHAR)+''-''+CAST(MONTH(DATEADD(m,1,@_as_of_date)) AS VARCHAR)+''-01'' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  AS Hr6
,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr7,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=7 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))/cast(nullif(isnull(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) as numeric(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,@_as_of_date)) AS VARCHAR)+''-''+CAST(MONTH(DATEADD(m,1,@_as_of_date)) AS VARCHAR)+''-01'' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  AS Hr7
,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr8,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=8 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))/cast(nullif(isnull(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) as numeric(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,@_as_of_date)) AS VARCHAR)+''-''+CAST(MONTH(DATEADD(m,1,@_as_of_date)) AS VARCHAR)+''-01'' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  AS Hr8
,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr9,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=9 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))/cast(nullif(isnull(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) as numeric(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,@_as_of_date)) AS VARCHAR)+''-''+CAST(MONTH(DATEADD(m,1,@_as_of_date)) AS VARCHAR)+''-01'' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  AS Hr9
,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr10,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=10 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))/cast(nullif(isnull(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) as numeric(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,@_as_of_date)) AS VARCHAR)+''-''+CAST(MONTH(DATEADD(m,1,@_as_of_date)) AS VARCHAR)+''-01'' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  AS Hr10
,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr11,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=11 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))/cast(nullif(isnull(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) as numeric(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,@_as_of_date)) AS VARCHAR)+''-''+CAST(MONTH(DATEADD(m,1,@_as_of_date)) AS VARCHAR)+''-01'' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  AS Hr11
,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr12,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=12 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))/cast(nullif(isnull(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) as numeric(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,@_as_of_date)) AS VARCHAR)+''-''+CAST(MONTH(DATEADD(m,1,@_as_of_date)) AS VARCHAR)+''-01'' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  AS Hr12
,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr13,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=13 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))/cast(nullif(isnull(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) as numeric(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,@_as_of_date)) AS VARCHAR)+''-''+CAST(MONTH(DATEADD(m,1,@_as_of_date)) AS VARCHAR)+''-01'' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  AS Hr13
,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr14,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=14 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))/cast(nullif(isnull(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) as numeric(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,@_as_of_date)) AS VARCHAR)+''-''+CAST(MONTH(DATEADD(m,1,@_as_of_date)) AS VARCHAR)+''-01'' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  AS Hr14
,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr15,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=15 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))/cast(nullif(isnull(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) as numeric(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,@_as_of_date)) AS VARCHAR)+''-''+CAST(MONTH(DATEADD(m,1,@_as_of_date)) AS VARCHAR)+''-01'' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  AS Hr15
,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr16,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=16 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))/cast(nullif(isnull(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) as numeric(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,@_as_of_date)) AS VARCHAR)+''-''+CAST(MONTH(DATEADD(m,1,@_as_of_date)) AS VARCHAR)+''-01'' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  AS Hr16
,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr17,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=17 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))/cast(nullif(isnull(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) as numeric(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,@_as_of_date)) AS VARCHAR)+''-''+CAST(MONTH(DATEADD(m,1,@_as_of_date)) AS VARCHAR)+''-01'' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  AS Hr17
,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr18,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=18 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))/cast(nullif(isnull(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) as numeric(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,@_as_of_date)) AS VARCHAR)+''-''+CAST(MONTH(DATEADD(m,1,@_as_of_date)) AS VARCHAR)+''-01'' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  AS Hr18
,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr19,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=19 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))/cast(nullif(isnull(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) as numeric(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,@_as_of_date)) AS VARCHAR)+''-''+CAST(MONTH(DATEADD(m,1,@_as_of_date)) AS VARCHAR)+''-01'' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  AS Hr19
,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr20,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=20 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))/cast(nullif(isnull(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) as numeric(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,@_as_of_date)) AS VARCHAR)+''-''+CAST(MONTH(DATEADD(m,1,@_as_of_date)) AS VARCHAR)+''-01'' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  AS Hr20
,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr21,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=21 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))/cast(nullif(isnull(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) as numeric(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,@_as_of_date)) AS VARCHAR)+''-''+CAST(MONTH(DATEADD(m,1,@_as_of_date)) AS VARCHAR)+''-01'' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  AS Hr21
,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr22,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=22 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))/cast(nullif(isnull(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) as numeric(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,@_as_of_date)) AS VARCHAR)+''-''+CAST(MONTH(DATEADD(m,1,@_as_of_date)) AS VARCHAR)+''-01'' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  AS Hr22
,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr23,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=23 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))/cast(nullif(isnull(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) as numeric(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,@_as_of_date)) AS VARCHAR)+''-''+CAST(MONTH(DATEADD(m,1,@_as_of_date)) AS VARCHAR)+''-01'' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  AS Hr23
,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr24,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=24 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))/cast(nullif(isnull(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) as numeric(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,@_as_of_date)) AS VARCHAR)+''-''+CAST(MONTH(DATEADD(m,1,@_as_of_date)) AS VARCHAR)+''-01'' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  AS Hr24
,(cast(cast(s.calc_volume as numeric(22,10))* cast(CASE WHEN isnull(hb.add_dst_hour,0)<=0 THEN 0 ELSE 1 END as numeric(1,0)) as numeric(22,10))) /cast(nullif(isnull(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) as numeric(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,@_as_of_date)) AS VARCHAR)+''-''+CAST(MONTH(DATEADD(m,1,@_as_of_date)) AS VARCHAR)+''-01'' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END) AS Hr25 
,s.source_deal_header_id,s.commodity_id,s.counterparty_id,s.fas_book_id,s.source_system_book_id1,s.source_system_book_id2,s.source_system_book_id3,s.source_system_book_id4,CASE WHEN s.formula IN(''dbo.FNACurveH'',''dbo.FNACurveD'') THEN ISNULL(hg.exp_date,hb.term_date) WHEN ISNULL(spcd.hourly_volume_allocation,17601) IN(17603,17604) THEN ISNULL(hg.exp_date,s.expiration_date) ELSE s.expiration_date END expiration_date,''y'' AS is_fixedvolume ,deal_status_id, ''m'' [deal_volume_frequency],s.term_end [term_end] --[deal_volume_frequency] for finalcial deals are always monthly  
INTO #temp_hourly_position_breakdown		 
from report_hourly_position_breakdown s  (nolock)  
INNER JOIN #books bk ON bk.fas_book_id=s.fas_book_id
	AND bk.source_system_book_id1=s.source_system_book_id1 
	AND bk.source_system_book_id2=s.source_system_book_id2
	AND bk.source_system_book_id3=s.source_system_book_id3 
	AND bk.source_system_book_id4=s.source_system_book_id4
INNER JOIN [deal_status_group] dsg ON  dsg.status_value_id = s.deal_status_id 
left JOIN source_price_curve_def spcd with (nolock) ON spcd.source_curve_def_id=s.curve_id 
LEFT JOIN source_price_curve_def spcd_proxy (nolock) On spcd_proxy.source_curve_def_id=spcd.settlement_curve_id
outer apply (select sum(volume_mult) term_no_hrs from hour_block_term hbt where isnull(spcd.hourly_volume_allocation,17601) <17603 and hbt.block_define_id=COALESCE(spcd.block_define_id,300501)	and  hbt.block_type=COALESCE(spcd.block_type,12000) and hbt.term_date between s.term_start  and s.term_END ) term_hrs
outer apply ( select sum(volume_mult) term_no_hrs from hour_block_term hbt inner join (select distinct exp_date from holiday_group h where  h.hol_group_value_id=ISNULL(spcd.exp_calendar_id,spcd_proxy.exp_calendar_id) and h.exp_date between s.term_start  and s.term_END ) ex on ex.exp_date=hbt.term_date
where  isnull(spcd.hourly_volume_allocation,17601) IN(17603,17604) and hbt.block_define_id=COALESCE(spcd.block_define_id,300501)	and  hbt.block_type=COALESCE(spcd.block_type,12000) and hbt.term_date between s.term_start  and s.term_END) term_hrs_exp
left join #term_date hb on hb.block_define_id=isnull(spcd.block_define_id,300501) and hb.term_start = s.term_start
and hb.term_end=s.term_end 
outer apply  (select MAX(exp_date) exp_date from holiday_group h where h.hol_date=hb.term_date AND 
h.hol_group_value_id=ISNULL(spcd.exp_calendar_id,spcd_proxy.exp_calendar_id) and h.hol_date between s.term_start  and s.term_END AND COALESCE(spcd_proxy.ratio_option,spcd.ratio_option,-1) <> 18800 ) hg   
outer apply  (select MIN(exp_date) hol_date ,MAX(exp_date) hol_date_to  from holiday_group h where 1=1 AND h.hol_group_value_id=ISNULL(spcd.exp_calendar_id,spcd_proxy.exp_calendar_id) and h.hol_date between s.term_start  and s.term_END AND s.formula NOT IN(''REBD'')) hg1   
outer apply  (select count(exp_date) total_days,SUM(CASE WHEN h.exp_date>@_as_of_date THEN 1 else 0 END) remain_days from holiday_group h where h.hol_group_value_id=ISNULL(spcd.exp_calendar_id,spcd_proxy.exp_calendar_id) 
AND h.exp_date BETWEEN hg1.hol_date AND ISNULL(hg1.hol_date_to,dbo.FNALastDayInDate(hg1.hol_date))
AND ISNULL(spcd_proxy.ratio_option,spcd.ratio_option) = 18800 AND s.formula NOT IN(''REBD'')) remain_month  
where ((ISNULL(spcd_proxy.ratio_option,spcd.ratio_option) = 18800 AND ISNULL(hg1.hol_date_to,''9999-01-01'')>@_as_of_date) OR COALESCE(spcd_proxy.ratio_option,spcd.ratio_option,-1) <> 18800)
AND ((isnull(spcd.hourly_volume_allocation,17601) IN(17603,17604) and  hg.exp_date is not null) or (isnull(spcd.hourly_volume_allocation,17601)<17603 ))		           
--AND s.deal_date<=@_as_of_date

-- hourly position breakdown end
create index indxterm_dat on #term_date(block_define_id, term_start,term_end)



IF OBJECT_ID(N''tempdb..#financial_deal_detail_id'') IS NOT NULL
	DROP TABLE #financial_deal_detail_id

select b.source_deal_header_id,b.curve_id,p.source_deal_detail_id,p.term_start,p.term_end 
into #financial_deal_detail_id
from (
	SELECT source_deal_header_id,curve_id,min(term_start) term_start,max(term_start) term_end FROM #temp_hourly_position_breakdown	group by source_deal_header_id,curve_id
	) b 
cross apply 
(select  source_deal_detail_id,min(fin_term_start) term_start,max(fin_term_end) term_end  from deal_position_break_down 
	where source_deal_header_id=b.source_deal_header_id and curve_id=b.curve_id and fin_term_start between  term_start and term_end 
	group by source_deal_detail_id
) p 



IF OBJECT_ID(N''tempdb..#temp_position_table'') IS NOT NULL
	DROP TABLE #temp_position_table
	
SELECT * INTO #temp_position_table FROM 
(
	SELECT sdd.source_deal_detail_id,vw.* FROM #temp_hourly_position_deal vw
	left join source_deal_detail sdd on sdd.source_deal_header_id=vw.source_deal_header_id  
	and vw.term_start between sdd.term_start and sdd.term_end and vw.curve_id=  sdd.curve_id
	and vw.location_id= vw.location_id 

	union ALL
	SELECT sdd.source_deal_detail_id,vw.* FROM #temp_hourly_position_profile vw
	left join source_deal_detail sdd on sdd.source_deal_header_id=vw.source_deal_header_id  
	and vw.term_start between sdd.term_start and sdd.term_end and vw.curve_id=  sdd.curve_id
	and vw.location_id= vw.location_id

	union ALL
	SELECT b.source_deal_detail_id,a.* FROM #temp_hourly_position_breakdown a left join #financial_deal_detail_id b on 
	 b.source_deal_header_id=a.source_deal_header_id and b.curve_id=a.curve_id and a.term_start between b.term_start and b.term_end 
) pos -- where source_deal_header_id=1832

IF OBJECT_ID(N''tempdb..#temp_hourly_position'') IS NOT NULL
	DROP TABLE #temp_hourly_position

SELECT DISTINCT CAST(@_as_of_date AS DATETIME) as_of_date, sub.entity_id sub_id, vw.source_deal_detail_id,
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
      spcd.curve_name+ case when spcd.curve_name  in(''BFOE Platts'',''ICE Gasoil Swap'') then ''(''+ DATENAME(mm,GETDATE())+ '' ''+DATENAME(yyyy,GETDATE()) +'')'' else '''' end [curve_name],
       spcd_proxy.curve_name proxy_index,
       sdv2.code region,
           sdv1.code grid,
          sdv.code country,
	   sdv3.code province,
       mjr.location_name location_group,mjr.source_major_location_ID,
       com.commodity_name commodity,
	   com1.commodity_name header_commodity,
       sdv_deal_staus.code deal_status,
       sc.counterparty_name counterparty_name,
       sc.counterparty_name parent_counterparty,
       CONVERT(VARCHAR(7), vw.term_start, 120) term_year_month,
       vw.term_start term_start,
       sb1.source_book_name book_identifier1,
       sb2.source_book_name book_identifier2,
       sb3.source_book_name book_identifier3,
       sb4.source_book_name book_identifier4,
       ssbm.logical_name AS book_identifier_logical_name,
       (vw.Hr1 + vw.Hr2 + vw.Hr3 + vw.Hr4 + vw.Hr5 + vw.Hr6 + vw.Hr7 +
        vw.Hr8 + vw.Hr9 + vw.Hr10 + vw.Hr11 + vw.Hr12 + vw.Hr13 +
        vw.Hr14 + vw.Hr15 + vw.Hr16 + vw.Hr17 + vw.Hr18 + vw.Hr19 + 
        vw.Hr20 + vw.Hr21 + vw.Hr22 + vw.Hr23 + vw.Hr24) *  coalesce(vuc.conversion_factor, 1) volume, 
		 --(vw.Hr1 + vw.Hr2 + vw.Hr3 + vw.Hr4 + vw.Hr5 + vw.Hr6 + vw.Hr7 +
   --     vw.Hr8 + vw.Hr9 + vw.Hr10 + vw.Hr11 + vw.Hr12 + vw.Hr13 +
   --     vw.Hr14 + vw.Hr15 + vw.Hr16 + vw.Hr17 + vw.Hr18 + vw.Hr19 + 
   --     vw.Hr20 + vw.Hr21 + vw.Hr22 + vw.Hr23 + vw.Hr24) v,  coalesce(uom.conversion_factor, vuc.conversion_factor, 1) f,
       su_uom.uom_name [uom],
       su_pos_uom.uom_name [position_uom],
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
		vw.term_start term_end,
		sc.source_counterparty_id counterparty_id,
		sml.source_minor_location_id location_id,  
		su_uom_proxy_curve.uom_name proxy_index_position_uom,
		spcd.source_curve_def_id [curve_id],
		ssbm.book_deal_type_map_id [sub_book_id] ,coalesce(vuc.to_source_uom_id,spcd.display_uom_id,spcd.uom_id) uom_id,
		su_convert_uom.uom_name [convert_uom]
		,case when spcd.curve_name in(''BFOE Platts'',''ICE Gasoil Swap'') then vw.expiration_date else vw.term_start end display_term
                                           ,case when spcd.Granularity=980 then vw.expiration_date else vw.term_start end CFD_term_start,
		 ISNULL(spcd_proxy.curve_name, spcd.curve_name) + case when spcd.Granularity=980 then ''(''+ DATENAME(mm,vw.term_start)+ '' ''+DATENAME(yyyy,vw.term_start) +'')'' else '''' end [CFD_curve_name]
		,sdv2.code [location_group2]
		,sdv1.code [location_group4]
		,sdv.code [location_group1]
		,sdv3.code [location_group3]
		--[__batch_report__]       
--select sdd.source_deal_detail_id, coalesce(uom.to_uom_id,vuc.to_source_uom_id,spcd.display_uom_id,spcd.uom_id),coalesce(uom.conversion_factor, vuc.conversion_factor, 1)
FROM #temp_position_table vw
INNER JOIN source_price_curve_def spcd ON spcd.source_curve_def_id = vw.curve_id 
--left join dbo.deal_uom_conversion_factor uom on vw.source_deal_detail_id=uom.source_deal_detail_id and uom.from_uom_id=isnull(spcd.display_uom_id,spcd.uom_id) and (@_uom_id = ''NULL'' OR uom.to_uom_id=@_uom_id)
left join rec_volume_unit_conversion vuc ON	vuc.from_source_uom_id = isnull(spcd.display_uom_id,spcd.uom_id)  AND vuc.to_source_uom_id = @_uom_id
LEFT JOIN source_minor_location sml ON sml.source_minor_location_id = vw.location_id
LEFT JOIN  source_price_curve_def spcd_proxy ON spcd_proxy.source_curve_def_id=spcd.proxy_curve_id
LEFT JOIN  source_price_curve_def spcd_proxy_curve3 ON spcd_proxy_curve3.source_curve_def_id=spcd.proxy_curve_id3
LEFT JOIN  source_price_curve_def spcd_monthly_index ON spcd_monthly_index.source_curve_def_id=spcd.monthly_index
LEFT JOIN  source_price_curve_def spcd_proxy_curve_def ON spcd_proxy_curve_def.source_curve_def_id=spcd.proxy_source_curve_def_id
LEFT JOIN source_system_description sssd ON sssd.source_system_id = spcd_monthly_index.source_system_id
LEFT JOIN source_system_description sssd2 ON sssd.source_system_id = spcd_proxy_curve3.source_system_id
LEFT JOIN static_data_value sdv1 ON sdv1.value_id=sml.grid_value_id
LEFT JOIN static_data_value sdv ON sdv.value_id=sml.country
LEFT JOIN static_data_value sdv2 ON sdv2.value_id=sml.region
LEFT JOIN static_data_value sdv3 ON sdv3.value_id=sml.province
LEFT JOIN source_major_location mjr ON sml.source_major_location_ID=mjr.source_major_location_ID
LEFT JOIN source_uom AS su_pos_uom ON su_pos_uom.source_uom_id = ISNULL(spcd.display_uom_id,spcd.uom_id)

LEFT JOIN source_uom AS su_convert_uom ON su_convert_uom.source_uom_id = coalesce(vuc.to_source_uom_id,spcd.display_uom_id,spcd.uom_id)

LEFT JOIN source_uom su_uom on su_uom.source_uom_id= coalesce(vuc.to_source_uom_id,spcd.uom_id)
LEFT JOIN source_uom su_uom_proxy3 on su_uom_proxy3.source_uom_id= ISNULL(spcd_proxy_curve3.display_uom_id,spcd_proxy_curve3.uom_id)--spcd_proxy_curve3.display_uom_id
LEFT JOIN source_uom su_uom_proxy2 on su_uom_proxy2.source_uom_id= ISNULL(spcd_monthly_index.display_uom_id,spcd_monthly_index.uom_id)
LEFT JOIN source_uom su_uom_proxy_curve_def on su_uom_proxy_curve_def.source_uom_id= ISNULL(spcd_proxy_curve_def.display_uom_id,spcd_proxy_curve_def.uom_id)--spcd_proxy_curve_def.display_uom_id
LEFT JOIN source_uom su_uom_proxy_curve on su_uom_proxy_curve.source_uom_id= ISNULL(spcd_proxy.display_uom_id,spcd_proxy.uom_id)
LEFT JOIN source_counterparty sc ON sc.source_counterparty_id = vw.counterparty_id 
LEFT JOIN source_counterparty psc  ON psc.source_counterparty_id=sc.parent_counterparty_id
LEFT JOIN source_commodity com ON com.source_commodity_id=spcd.commodity_id 
LEFT JOIN portfolio_hierarchy book ON book.entity_id = vw.fas_book_id 
LEFT JOIN portfolio_hierarchy stra ON stra.entity_id = book.parent_entity_id 
LEFT JOIN portfolio_hierarchy sub ON sub.entity_id = stra.parent_entity_id
LEFT JOIN source_deal_header sdh ON sdh.source_deal_header_id = vw.source_deal_header_id
LEFT JOIN static_data_value sdv_deal_staus ON sdv_deal_staus.value_id = vw.deal_status_id
LEFT JOIN source_commodity com1 ON com1.source_commodity_id = sdh.commodity_id 
LEFT JOIN source_system_book_map ssbm ON ssbm.source_system_book_id1 = vw.source_system_book_id1
	AND ssbm.source_system_book_id2 = vw.source_system_book_id2
	AND ssbm.source_system_book_id3 = vw.source_system_book_id3
	AND ssbm.source_system_book_id4 = vw.source_system_book_id4
LEFT JOIN source_book sb1 ON sb1.source_book_id = vw.source_system_book_id1
LEFT JOIN source_book sb2 ON sb2.source_book_id = vw.source_system_book_id2
LEFT JOIN source_book sb3 ON sb3.source_book_id = vw.source_system_book_id3
LEFT JOIN source_book sb4 ON sb4.source_book_id = vw.source_system_book_id4
LEFT JOIN static_data_value sdv_block ON sdv_block.value_id  = sdh.block_define_id
WHERE vw.expiration_date > @_as_of_date AND vw.term_start > @_as_of_date', report_id = @report_id_data_source_dest 
		WHERE [name] = 'Position Daily Pivot View'
			AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1)
	END	
	

	IF NOT EXISTS (SELECT 1 
	           FROM data_source 
	           WHERE [name] = 'Position Daily Pivot View'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		INSERT INTO data_source([type_id], [name], [alias], [description], [tsql], report_id)
		SELECT TOP 1 1 AS [type_id], 'Position Daily Pivot View' AS [name], 'PDPV' AS ALIAS, '' AS [description],'IF OBJECT_ID(N''tempdb..#books'') IS NOT NULL
	DROP TABLE #books
IF OBJECT_ID(N''tempdb..#term_date'') IS NOT NULL
	DROP TABLE #term_date


DECLARE @_as_of_date VARCHAR(25) = ''''
DECLARE @_uom_id VARCHAR(25) = ''74''
select @_uom_id = source_uom_id from source_uom where uom_name = ''MT''

SELECT @_as_of_date = ma.as_of_date
FROM module_asofdate ma
WHERE ma.module_type = 15500

IF OBJECT_ID(N''tempdb..#books'') IS NOT NULL
	DROP TABLE #books

CREATE TABLE #books (fas_book_id INT, source_system_book_id1 INT ,source_system_book_id2 INT,source_system_book_id3 INT,source_system_book_id4 INT)   
 
INSERT INTO #books
SELECT DISTINCT 
	   book.entity_id,
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
	
select 
distinct isnull(spcd.block_define_id,300501) block_define_id,s.term_start,s.term_end 
INTO #temp_report_hourly_position_breakdown
from report_hourly_position_breakdown s  (nolock)  
INNER JOIN #books bk ON bk.fas_book_id=s.fas_book_id 
	AND bk.source_system_book_id1=s.source_system_book_id1 AND bk.source_system_book_id2=s.source_system_book_id2 
	AND bk.source_system_book_id3=s.source_system_book_id3 AND bk.source_system_book_id4=s.source_system_book_id4 
INNER JOIN [deal_status_group] dsg ON dsg.status_value_id = s.deal_status_id  
left JOIN source_price_curve_def spcd with (nolock) 
ON spcd.source_curve_def_id=s.curve_id 

CREATE TABLE #term_date( block_define_id int ,term_date date,term_start date,term_end date,
	hr1 tinyint,hr2 tinyint,hr3 tinyint,hr4 tinyint,hr5 tinyint,hr6 tinyint,hr7 tinyint,hr8 tinyint
	,hr9 tinyint,hr10 tinyint,hr11 tinyint,hr12 tinyint,hr13 tinyint,hr14 tinyint,hr15 tinyint,hr16 tinyint
	,hr17 tinyint,hr18 tinyint,hr19 tinyint,hr20 tinyint,hr21 tinyint,hr22 tinyint,hr23 tinyint,hr24 tinyint,add_dst_hour int
)
insert into #term_date(block_define_id  ,term_date,term_start,term_end,
hr1 ,hr2 ,hr3 ,hr4 ,hr5 ,hr6 ,hr7 ,hr8 ,hr9 ,hr10 ,hr11 ,hr12 ,hr13 ,hr14 ,hr15 ,hr16 
,hr17 ,hr18 ,hr19 ,hr20 ,hr21 ,hr22 ,hr23 ,hr24 ,add_dst_hour
)
select distinct a.block_define_id  ,hb.term_date,a.term_start ,a.term_end,
	hb.hr1 ,hb.hr2 ,hb.hr3 ,hb.hr4 ,hb.hr5 ,hb.hr6 ,hb.hr7 ,hb.hr8 
	,hb.hr9 ,hb.hr10 ,hb.hr11 ,hb.hr12 ,hb.hr13 ,hb.hr14 ,hb.hr15 ,hb.hr16 
	,hb.hr17 ,hb.hr18 ,hb.hr19 ,hb.hr20 ,hb.hr21 ,hb.hr22 ,hb.hr23 ,hb.hr24 ,hb.add_dst_hour
from #temp_report_hourly_position_breakdown a
		outer apply	(select h.* from hour_block_term h with (nolock) where block_define_id=a.block_define_id and h.block_type=12000 
		and term_date between a.term_start  and a.term_end
) hb
----- hourly position deal start
IF OBJECT_ID(N''tempdb..#temp_hourly_position_deal'') IS NOT NULL
	DROP TABLE #temp_hourly_position_deal
	
select s.curve_id,s.location_id,s.term_start,0 period,s.deal_date,s.deal_volume_uom_id,s.physical_financial_flag,s.hr1,s.hr2,s.hr3,s.hr4,s.hr5,s.hr6,s.hr7,s.hr8,s.hr9,s.hr10,s.hr11,s.hr12,s.hr13,s.hr14,s.hr15,s.hr16,s.hr17,s.hr18,s.hr19,s.hr20,s.hr21,s.hr22,s.hr23,s.hr24,s.hr25,s.source_deal_header_id,s.commodity_id,s.counterparty_id,s.fas_book_id,s.source_system_book_id1,s.source_system_book_id2
	,s.source_system_book_id3,s.source_system_book_id4,s.expiration_date,''n'' AS is_fixedvolume,deal_status_id,sdd.deal_volume_frequency,sdd.term_end 
INTO #temp_hourly_position_deal
 from report_hourly_position_deal s  (nolock)  INNER JOIN #books bk ON bk.fas_book_id=s.fas_book_id AND bk.source_system_book_id1=s.source_system_book_id1
AND bk.source_system_book_id2=s.source_system_book_id2 AND bk.source_system_book_id3=s.source_system_book_id3
AND bk.source_system_book_id4=s.source_system_book_id4 
INNER JOIN [deal_status_group] dsg ON  dsg.status_value_id = s.deal_status_id 
left join source_price_curve_def spcd on spcd.source_curve_def_id=s.curve_id
--------------
left JOIN source_deal_detail sdd 
		ON s.term_start BETWEEN sdd.term_start AND sdd.term_end
		AND sdd.source_deal_detail_id = s.source_deal_detail_id  
--------------		  
WHERE 1=1
--AND s.deal_date<=@_as_of_date  
AND s.expiration_date > @_as_of_date AND s.term_start > @_as_of_date
----- hourly position deal end
----- hourly position profile start
IF OBJECT_ID(N''tempdb..#temp_hourly_position_profile'') IS NOT NULL
	DROP TABLE #temp_hourly_position_profile

select s.curve_id,s.location_id,s.term_start,0 Period,s.deal_date,s.deal_volume_uom_id,s.physical_financial_flag,s.hr1,s.hr2,s.hr3,s.hr4,s.hr5,s.hr6,s.hr7,s.hr8,s.hr9,s.hr10,s.hr11,s.hr12,s.hr13,s.hr14,s.hr15,s.hr16,s.hr17,s.hr18,s.hr19,s.hr20,s.hr21,s.hr22,s.hr23,s.hr24,s.hr25,s.source_deal_header_id,s.commodity_id,s.counterparty_id,s.fas_book_id,s.source_system_book_id1,s.source_system_book_id2,s.source_system_book_id3,s.source_system_book_id4 
,s.expiration_date,''n'' AS is_fixedvolume,deal_status_id,sdd.deal_volume_frequency,sdd.term_end 
INTO #temp_hourly_position_profile
from report_hourly_position_profile s  (nolock)  
INNER JOIN #books bk ON bk.fas_book_id=s.fas_book_id 
AND bk.source_system_book_id1=s.source_system_book_id1	
AND bk.source_system_book_id2=s.source_system_book_id2	AND bk.source_system_book_id3=s.source_system_book_id3
AND bk.source_system_book_id4=s.source_system_book_id4 
INNER JOIN [deal_status_group] dsg ON  dsg.status_value_id = s.deal_status_id 
left join source_price_curve_def spcd on spcd.source_curve_def_id=s.curve_id
-------------
left JOIN source_deal_detail sdd 
		ON s.term_start BETWEEN sdd.term_start AND sdd.term_end
		AND sdd.source_deal_detail_id = s.source_deal_detail_id  
----------------
WHERE  1=1
--AND s.deal_date<=@_as_of_date  
AND s.expiration_date > @_as_of_date AND s.term_start > @_as_of_date
---- hourly position profile end

IF OBJECT_ID(N''tempdb..#temp_hourly_position_breakdown'') IS NOT NULL
	DROP TABLE #temp_hourly_position_breakdown
----- hourly position breakdown start

select s.curve_id,ISNULL(s.location_id,-1) location_id,hb.term_date term_start,0 period,s.deal_date,s.deal_volume_uom_id,s.physical_financial_flag
,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr1,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=1 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))/cast(nullif(isnull(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) as numeric(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,@_as_of_date)) AS VARCHAR)+''-''+CAST(MONTH(DATEADD(m,1,@_as_of_date)) AS VARCHAR)+''-01'' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  AS Hr1
,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr2,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=2 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))/cast(nullif(isnull(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) as numeric(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,@_as_of_date)) AS VARCHAR)+''-''+CAST(MONTH(DATEADD(m,1,@_as_of_date)) AS VARCHAR)+''-01'' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  AS Hr2
,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr3,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=3 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))/cast(nullif(isnull(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) as numeric(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,@_as_of_date)) AS VARCHAR)+''-''+CAST(MONTH(DATEADD(m,1,@_as_of_date)) AS VARCHAR)+''-01'' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  AS Hr3
,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr4,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=4 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))/cast(nullif(isnull(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) as numeric(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,@_as_of_date)) AS VARCHAR)+''-''+CAST(MONTH(DATEADD(m,1,@_as_of_date)) AS VARCHAR)+''-01'' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  AS Hr4
,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr5,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=5 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))/cast(nullif(isnull(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) as numeric(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,@_as_of_date)) AS VARCHAR)+''-''+CAST(MONTH(DATEADD(m,1,@_as_of_date)) AS VARCHAR)+''-01'' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  AS Hr5
,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr6,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=6 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))/cast(nullif(isnull(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) as numeric(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,@_as_of_date)) AS VARCHAR)+''-''+CAST(MONTH(DATEADD(m,1,@_as_of_date)) AS VARCHAR)+''-01'' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  AS Hr6
,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr7,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=7 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))/cast(nullif(isnull(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) as numeric(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,@_as_of_date)) AS VARCHAR)+''-''+CAST(MONTH(DATEADD(m,1,@_as_of_date)) AS VARCHAR)+''-01'' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  AS Hr7
,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr8,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=8 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))/cast(nullif(isnull(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) as numeric(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,@_as_of_date)) AS VARCHAR)+''-''+CAST(MONTH(DATEADD(m,1,@_as_of_date)) AS VARCHAR)+''-01'' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  AS Hr8
,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr9,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=9 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))/cast(nullif(isnull(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) as numeric(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,@_as_of_date)) AS VARCHAR)+''-''+CAST(MONTH(DATEADD(m,1,@_as_of_date)) AS VARCHAR)+''-01'' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  AS Hr9
,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr10,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=10 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))/cast(nullif(isnull(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) as numeric(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,@_as_of_date)) AS VARCHAR)+''-''+CAST(MONTH(DATEADD(m,1,@_as_of_date)) AS VARCHAR)+''-01'' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  AS Hr10
,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr11,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=11 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))/cast(nullif(isnull(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) as numeric(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,@_as_of_date)) AS VARCHAR)+''-''+CAST(MONTH(DATEADD(m,1,@_as_of_date)) AS VARCHAR)+''-01'' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  AS Hr11
,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr12,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=12 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))/cast(nullif(isnull(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) as numeric(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,@_as_of_date)) AS VARCHAR)+''-''+CAST(MONTH(DATEADD(m,1,@_as_of_date)) AS VARCHAR)+''-01'' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  AS Hr12
,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr13,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=13 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))/cast(nullif(isnull(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) as numeric(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,@_as_of_date)) AS VARCHAR)+''-''+CAST(MONTH(DATEADD(m,1,@_as_of_date)) AS VARCHAR)+''-01'' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  AS Hr13
,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr14,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=14 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))/cast(nullif(isnull(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) as numeric(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,@_as_of_date)) AS VARCHAR)+''-''+CAST(MONTH(DATEADD(m,1,@_as_of_date)) AS VARCHAR)+''-01'' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  AS Hr14
,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr15,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=15 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))/cast(nullif(isnull(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) as numeric(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,@_as_of_date)) AS VARCHAR)+''-''+CAST(MONTH(DATEADD(m,1,@_as_of_date)) AS VARCHAR)+''-01'' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  AS Hr15
,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr16,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=16 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))/cast(nullif(isnull(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) as numeric(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,@_as_of_date)) AS VARCHAR)+''-''+CAST(MONTH(DATEADD(m,1,@_as_of_date)) AS VARCHAR)+''-01'' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  AS Hr16
,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr17,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=17 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))/cast(nullif(isnull(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) as numeric(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,@_as_of_date)) AS VARCHAR)+''-''+CAST(MONTH(DATEADD(m,1,@_as_of_date)) AS VARCHAR)+''-01'' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  AS Hr17
,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr18,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=18 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))/cast(nullif(isnull(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) as numeric(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,@_as_of_date)) AS VARCHAR)+''-''+CAST(MONTH(DATEADD(m,1,@_as_of_date)) AS VARCHAR)+''-01'' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  AS Hr18
,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr19,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=19 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))/cast(nullif(isnull(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) as numeric(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,@_as_of_date)) AS VARCHAR)+''-''+CAST(MONTH(DATEADD(m,1,@_as_of_date)) AS VARCHAR)+''-01'' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  AS Hr19
,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr20,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=20 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))/cast(nullif(isnull(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) as numeric(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,@_as_of_date)) AS VARCHAR)+''-''+CAST(MONTH(DATEADD(m,1,@_as_of_date)) AS VARCHAR)+''-01'' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  AS Hr20
,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr21,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=21 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))/cast(nullif(isnull(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) as numeric(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,@_as_of_date)) AS VARCHAR)+''-''+CAST(MONTH(DATEADD(m,1,@_as_of_date)) AS VARCHAR)+''-01'' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  AS Hr21
,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr22,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=22 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))/cast(nullif(isnull(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) as numeric(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,@_as_of_date)) AS VARCHAR)+''-''+CAST(MONTH(DATEADD(m,1,@_as_of_date)) AS VARCHAR)+''-01'' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  AS Hr22
,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr23,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=23 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))/cast(nullif(isnull(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) as numeric(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,@_as_of_date)) AS VARCHAR)+''-''+CAST(MONTH(DATEADD(m,1,@_as_of_date)) AS VARCHAR)+''-01'' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  AS Hr23
,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr24,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=24 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))/cast(nullif(isnull(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) as numeric(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,@_as_of_date)) AS VARCHAR)+''-''+CAST(MONTH(DATEADD(m,1,@_as_of_date)) AS VARCHAR)+''-01'' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  AS Hr24
,(cast(cast(s.calc_volume as numeric(22,10))* cast(CASE WHEN isnull(hb.add_dst_hour,0)<=0 THEN 0 ELSE 1 END as numeric(1,0)) as numeric(22,10))) /cast(nullif(isnull(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) as numeric(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,@_as_of_date)) AS VARCHAR)+''-''+CAST(MONTH(DATEADD(m,1,@_as_of_date)) AS VARCHAR)+''-01'' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END) AS Hr25 
,s.source_deal_header_id,s.commodity_id,s.counterparty_id,s.fas_book_id,s.source_system_book_id1,s.source_system_book_id2,s.source_system_book_id3,s.source_system_book_id4,CASE WHEN s.formula IN(''dbo.FNACurveH'',''dbo.FNACurveD'') THEN ISNULL(hg.exp_date,hb.term_date) WHEN ISNULL(spcd.hourly_volume_allocation,17601) IN(17603,17604) THEN ISNULL(hg.exp_date,s.expiration_date) ELSE s.expiration_date END expiration_date,''y'' AS is_fixedvolume ,deal_status_id, ''m'' [deal_volume_frequency],s.term_end [term_end] --[deal_volume_frequency] for finalcial deals are always monthly  
INTO #temp_hourly_position_breakdown		 
from report_hourly_position_breakdown s  (nolock)  
INNER JOIN #books bk ON bk.fas_book_id=s.fas_book_id
	AND bk.source_system_book_id1=s.source_system_book_id1 
	AND bk.source_system_book_id2=s.source_system_book_id2
	AND bk.source_system_book_id3=s.source_system_book_id3 
	AND bk.source_system_book_id4=s.source_system_book_id4
INNER JOIN [deal_status_group] dsg ON  dsg.status_value_id = s.deal_status_id 
left JOIN source_price_curve_def spcd with (nolock) ON spcd.source_curve_def_id=s.curve_id 
LEFT JOIN source_price_curve_def spcd_proxy (nolock) On spcd_proxy.source_curve_def_id=spcd.settlement_curve_id
outer apply (select sum(volume_mult) term_no_hrs from hour_block_term hbt where isnull(spcd.hourly_volume_allocation,17601) <17603 and hbt.block_define_id=COALESCE(spcd.block_define_id,300501)	and  hbt.block_type=COALESCE(spcd.block_type,12000) and hbt.term_date between s.term_start  and s.term_END ) term_hrs
outer apply ( select sum(volume_mult) term_no_hrs from hour_block_term hbt inner join (select distinct exp_date from holiday_group h where  h.hol_group_value_id=ISNULL(spcd.exp_calendar_id,spcd_proxy.exp_calendar_id) and h.exp_date between s.term_start  and s.term_END ) ex on ex.exp_date=hbt.term_date
where  isnull(spcd.hourly_volume_allocation,17601) IN(17603,17604) and hbt.block_define_id=COALESCE(spcd.block_define_id,300501)	and  hbt.block_type=COALESCE(spcd.block_type,12000) and hbt.term_date between s.term_start  and s.term_END) term_hrs_exp
left join #term_date hb on hb.block_define_id=isnull(spcd.block_define_id,300501) and hb.term_start = s.term_start
and hb.term_end=s.term_end 
outer apply  (select MAX(exp_date) exp_date from holiday_group h where h.hol_date=hb.term_date AND 
h.hol_group_value_id=ISNULL(spcd.exp_calendar_id,spcd_proxy.exp_calendar_id) and h.hol_date between s.term_start  and s.term_END AND COALESCE(spcd_proxy.ratio_option,spcd.ratio_option,-1) <> 18800 ) hg   
outer apply  (select MIN(exp_date) hol_date ,MAX(exp_date) hol_date_to  from holiday_group h where 1=1 AND h.hol_group_value_id=ISNULL(spcd.exp_calendar_id,spcd_proxy.exp_calendar_id) and h.hol_date between s.term_start  and s.term_END AND s.formula NOT IN(''REBD'')) hg1   
outer apply  (select count(exp_date) total_days,SUM(CASE WHEN h.exp_date>@_as_of_date THEN 1 else 0 END) remain_days from holiday_group h where h.hol_group_value_id=ISNULL(spcd.exp_calendar_id,spcd_proxy.exp_calendar_id) 
AND h.exp_date BETWEEN hg1.hol_date AND ISNULL(hg1.hol_date_to,dbo.FNALastDayInDate(hg1.hol_date))
AND ISNULL(spcd_proxy.ratio_option,spcd.ratio_option) = 18800 AND s.formula NOT IN(''REBD'')) remain_month  
where ((ISNULL(spcd_proxy.ratio_option,spcd.ratio_option) = 18800 AND ISNULL(hg1.hol_date_to,''9999-01-01'')>@_as_of_date) OR COALESCE(spcd_proxy.ratio_option,spcd.ratio_option,-1) <> 18800)
AND ((isnull(spcd.hourly_volume_allocation,17601) IN(17603,17604) and  hg.exp_date is not null) or (isnull(spcd.hourly_volume_allocation,17601)<17603 ))		           
--AND s.deal_date<=@_as_of_date

-- hourly position breakdown end
create index indxterm_dat on #term_date(block_define_id, term_start,term_end)



IF OBJECT_ID(N''tempdb..#financial_deal_detail_id'') IS NOT NULL
	DROP TABLE #financial_deal_detail_id

select b.source_deal_header_id,b.curve_id,p.source_deal_detail_id,p.term_start,p.term_end 
into #financial_deal_detail_id
from (
	SELECT source_deal_header_id,curve_id,min(term_start) term_start,max(term_start) term_end FROM #temp_hourly_position_breakdown	group by source_deal_header_id,curve_id
	) b 
cross apply 
(select  source_deal_detail_id,min(fin_term_start) term_start,max(fin_term_end) term_end  from deal_position_break_down 
	where source_deal_header_id=b.source_deal_header_id and curve_id=b.curve_id and fin_term_start between  term_start and term_end 
	group by source_deal_detail_id
) p 



IF OBJECT_ID(N''tempdb..#temp_position_table'') IS NOT NULL
	DROP TABLE #temp_position_table
	
SELECT * INTO #temp_position_table FROM 
(
	SELECT sdd.source_deal_detail_id,vw.* FROM #temp_hourly_position_deal vw
	left join source_deal_detail sdd on sdd.source_deal_header_id=vw.source_deal_header_id  
	and vw.term_start between sdd.term_start and sdd.term_end and vw.curve_id=  sdd.curve_id
	and vw.location_id= vw.location_id 

	union ALL
	SELECT sdd.source_deal_detail_id,vw.* FROM #temp_hourly_position_profile vw
	left join source_deal_detail sdd on sdd.source_deal_header_id=vw.source_deal_header_id  
	and vw.term_start between sdd.term_start and sdd.term_end and vw.curve_id=  sdd.curve_id
	and vw.location_id= vw.location_id

	union ALL
	SELECT b.source_deal_detail_id,a.* FROM #temp_hourly_position_breakdown a left join #financial_deal_detail_id b on 
	 b.source_deal_header_id=a.source_deal_header_id and b.curve_id=a.curve_id and a.term_start between b.term_start and b.term_end 
) pos -- where source_deal_header_id=1832

IF OBJECT_ID(N''tempdb..#temp_hourly_position'') IS NOT NULL
	DROP TABLE #temp_hourly_position

SELECT DISTINCT CAST(@_as_of_date AS DATETIME) as_of_date, sub.entity_id sub_id, vw.source_deal_detail_id,
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
      spcd.curve_name+ case when spcd.curve_name  in(''BFOE Platts'',''ICE Gasoil Swap'') then ''(''+ DATENAME(mm,GETDATE())+ '' ''+DATENAME(yyyy,GETDATE()) +'')'' else '''' end [curve_name],
       spcd_proxy.curve_name proxy_index,
       sdv2.code region,
           sdv1.code grid,
          sdv.code country,
	   sdv3.code province,
       mjr.location_name location_group,mjr.source_major_location_ID,
       com.commodity_name commodity,
	   com1.commodity_name header_commodity,
       sdv_deal_staus.code deal_status,
       sc.counterparty_name counterparty_name,
       sc.counterparty_name parent_counterparty,
       CONVERT(VARCHAR(7), vw.term_start, 120) term_year_month,
       vw.term_start term_start,
       sb1.source_book_name book_identifier1,
       sb2.source_book_name book_identifier2,
       sb3.source_book_name book_identifier3,
       sb4.source_book_name book_identifier4,
       ssbm.logical_name AS book_identifier_logical_name,
       (vw.Hr1 + vw.Hr2 + vw.Hr3 + vw.Hr4 + vw.Hr5 + vw.Hr6 + vw.Hr7 +
        vw.Hr8 + vw.Hr9 + vw.Hr10 + vw.Hr11 + vw.Hr12 + vw.Hr13 +
        vw.Hr14 + vw.Hr15 + vw.Hr16 + vw.Hr17 + vw.Hr18 + vw.Hr19 + 
        vw.Hr20 + vw.Hr21 + vw.Hr22 + vw.Hr23 + vw.Hr24) *  coalesce(vuc.conversion_factor, 1) volume, 
		 --(vw.Hr1 + vw.Hr2 + vw.Hr3 + vw.Hr4 + vw.Hr5 + vw.Hr6 + vw.Hr7 +
   --     vw.Hr8 + vw.Hr9 + vw.Hr10 + vw.Hr11 + vw.Hr12 + vw.Hr13 +
   --     vw.Hr14 + vw.Hr15 + vw.Hr16 + vw.Hr17 + vw.Hr18 + vw.Hr19 + 
   --     vw.Hr20 + vw.Hr21 + vw.Hr22 + vw.Hr23 + vw.Hr24) v,  coalesce(uom.conversion_factor, vuc.conversion_factor, 1) f,
       su_uom.uom_name [uom],
       su_pos_uom.uom_name [position_uom],
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
		vw.term_start term_end,
		sc.source_counterparty_id counterparty_id,
		sml.source_minor_location_id location_id,  
		su_uom_proxy_curve.uom_name proxy_index_position_uom,
		spcd.source_curve_def_id [curve_id],
		ssbm.book_deal_type_map_id [sub_book_id] ,coalesce(vuc.to_source_uom_id,spcd.display_uom_id,spcd.uom_id) uom_id,
		su_convert_uom.uom_name [convert_uom]
		,case when spcd.curve_name in(''BFOE Platts'',''ICE Gasoil Swap'') then vw.expiration_date else vw.term_start end display_term
                                           ,case when spcd.Granularity=980 then vw.expiration_date else vw.term_start end CFD_term_start,
		 ISNULL(spcd_proxy.curve_name, spcd.curve_name) + case when spcd.Granularity=980 then ''(''+ DATENAME(mm,vw.term_start)+ '' ''+DATENAME(yyyy,vw.term_start) +'')'' else '''' end [CFD_curve_name]
		,sdv2.code [location_group2]
		,sdv1.code [location_group4]
		,sdv.code [location_group1]
		,sdv3.code [location_group3]
		--[__batch_report__]       
--select sdd.source_deal_detail_id, coalesce(uom.to_uom_id,vuc.to_source_uom_id,spcd.display_uom_id,spcd.uom_id),coalesce(uom.conversion_factor, vuc.conversion_factor, 1)
FROM #temp_position_table vw
INNER JOIN source_price_curve_def spcd ON spcd.source_curve_def_id = vw.curve_id 
--left join dbo.deal_uom_conversion_factor uom on vw.source_deal_detail_id=uom.source_deal_detail_id and uom.from_uom_id=isnull(spcd.display_uom_id,spcd.uom_id) and (@_uom_id = ''NULL'' OR uom.to_uom_id=@_uom_id)
left join rec_volume_unit_conversion vuc ON	vuc.from_source_uom_id = isnull(spcd.display_uom_id,spcd.uom_id)  AND vuc.to_source_uom_id = @_uom_id
LEFT JOIN source_minor_location sml ON sml.source_minor_location_id = vw.location_id
LEFT JOIN  source_price_curve_def spcd_proxy ON spcd_proxy.source_curve_def_id=spcd.proxy_curve_id
LEFT JOIN  source_price_curve_def spcd_proxy_curve3 ON spcd_proxy_curve3.source_curve_def_id=spcd.proxy_curve_id3
LEFT JOIN  source_price_curve_def spcd_monthly_index ON spcd_monthly_index.source_curve_def_id=spcd.monthly_index
LEFT JOIN  source_price_curve_def spcd_proxy_curve_def ON spcd_proxy_curve_def.source_curve_def_id=spcd.proxy_source_curve_def_id
LEFT JOIN source_system_description sssd ON sssd.source_system_id = spcd_monthly_index.source_system_id
LEFT JOIN source_system_description sssd2 ON sssd.source_system_id = spcd_proxy_curve3.source_system_id
LEFT JOIN static_data_value sdv1 ON sdv1.value_id=sml.grid_value_id
LEFT JOIN static_data_value sdv ON sdv.value_id=sml.country
LEFT JOIN static_data_value sdv2 ON sdv2.value_id=sml.region
LEFT JOIN static_data_value sdv3 ON sdv3.value_id=sml.province
LEFT JOIN source_major_location mjr ON sml.source_major_location_ID=mjr.source_major_location_ID
LEFT JOIN source_uom AS su_pos_uom ON su_pos_uom.source_uom_id = ISNULL(spcd.display_uom_id,spcd.uom_id)

LEFT JOIN source_uom AS su_convert_uom ON su_convert_uom.source_uom_id = coalesce(vuc.to_source_uom_id,spcd.display_uom_id,spcd.uom_id)

LEFT JOIN source_uom su_uom on su_uom.source_uom_id= coalesce(vuc.to_source_uom_id,spcd.uom_id)
LEFT JOIN source_uom su_uom_proxy3 on su_uom_proxy3.source_uom_id= ISNULL(spcd_proxy_curve3.display_uom_id,spcd_proxy_curve3.uom_id)--spcd_proxy_curve3.display_uom_id
LEFT JOIN source_uom su_uom_proxy2 on su_uom_proxy2.source_uom_id= ISNULL(spcd_monthly_index.display_uom_id,spcd_monthly_index.uom_id)
LEFT JOIN source_uom su_uom_proxy_curve_def on su_uom_proxy_curve_def.source_uom_id= ISNULL(spcd_proxy_curve_def.display_uom_id,spcd_proxy_curve_def.uom_id)--spcd_proxy_curve_def.display_uom_id
LEFT JOIN source_uom su_uom_proxy_curve on su_uom_proxy_curve.source_uom_id= ISNULL(spcd_proxy.display_uom_id,spcd_proxy.uom_id)
LEFT JOIN source_counterparty sc ON sc.source_counterparty_id = vw.counterparty_id 
LEFT JOIN source_counterparty psc  ON psc.source_counterparty_id=sc.parent_counterparty_id
LEFT JOIN source_commodity com ON com.source_commodity_id=spcd.commodity_id 
LEFT JOIN portfolio_hierarchy book ON book.entity_id = vw.fas_book_id 
LEFT JOIN portfolio_hierarchy stra ON stra.entity_id = book.parent_entity_id 
LEFT JOIN portfolio_hierarchy sub ON sub.entity_id = stra.parent_entity_id
LEFT JOIN source_deal_header sdh ON sdh.source_deal_header_id = vw.source_deal_header_id
LEFT JOIN static_data_value sdv_deal_staus ON sdv_deal_staus.value_id = vw.deal_status_id
LEFT JOIN source_commodity com1 ON com1.source_commodity_id = sdh.commodity_id 
LEFT JOIN source_system_book_map ssbm ON ssbm.source_system_book_id1 = vw.source_system_book_id1
	AND ssbm.source_system_book_id2 = vw.source_system_book_id2
	AND ssbm.source_system_book_id3 = vw.source_system_book_id3
	AND ssbm.source_system_book_id4 = vw.source_system_book_id4
LEFT JOIN source_book sb1 ON sb1.source_book_id = vw.source_system_book_id1
LEFT JOIN source_book sb2 ON sb2.source_book_id = vw.source_system_book_id2
LEFT JOIN source_book sb3 ON sb3.source_book_id = vw.source_system_book_id3
LEFT JOIN source_book sb4 ON sb4.source_book_id = vw.source_system_book_id4
LEFT JOIN static_data_value sdv_block ON sdv_block.value_id  = sdh.block_define_id
WHERE vw.expiration_date > @_as_of_date AND vw.term_start > @_as_of_date' AS [tsql], @report_id_data_source_dest AS report_id
	END 
	

	IF OBJECT_ID('tempdb..#data_source_column', 'U') IS NOT NULL
		DROP TABLE #data_source_column	
	CREATE TABLE #data_source_column(column_id INT)	

	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position Daily Pivot View'
	            AND dsc.name =  'as_of_date'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'As of Date'
			   , reqd_param = 0, widget_id = 6, datatype_id = 2, param_data_source = NULL, param_default_value = NULL, append_filter = 0, tooltip = NULL, column_template = 4, key_column = 1
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position Daily Pivot View'
			AND dsc.name =  'as_of_date'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'as_of_date' AS [name], 'As of Date' AS ALIAS, 0 AS reqd_param, 6 AS widget_id, 2 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 0 AS append_filter, NULL  AS tooltip,4 AS column_template, 1 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Position Daily Pivot View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	

	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position Daily Pivot View'
	            AND dsc.name =  'book'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Book'
			   , reqd_param = 0, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position Daily Pivot View'
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
		INNER JOIN data_source ds ON ds.[name] = 'Position Daily Pivot View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	

	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position Daily Pivot View'
	            AND dsc.name =  'book_id'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Book ID'
			   , reqd_param = 1, widget_id = 5, datatype_id = 4, param_data_source = NULL, param_default_value = NULL, append_filter = 0, tooltip = NULL, column_template = 2, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position Daily Pivot View'
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
		INNER JOIN data_source ds ON ds.[name] = 'Position Daily Pivot View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	

	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position Daily Pivot View'
	            AND dsc.name =  'book_identifier_logical_name'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Sub Book'
			   , reqd_param = 0, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position Daily Pivot View'
			AND dsc.name =  'book_identifier_logical_name'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'book_identifier_logical_name' AS [name], 'Sub Book' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Position Daily Pivot View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	

	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position Daily Pivot View'
	            AND dsc.name =  'book_identifier1'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Book ID1'
			   , reqd_param = 0, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position Daily Pivot View'
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
		INNER JOIN data_source ds ON ds.[name] = 'Position Daily Pivot View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	

	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position Daily Pivot View'
	            AND dsc.name =  'book_identifier2'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Book ID2'
			   , reqd_param = 0, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position Daily Pivot View'
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
		INNER JOIN data_source ds ON ds.[name] = 'Position Daily Pivot View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	

	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position Daily Pivot View'
	            AND dsc.name =  'book_identifier3'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Book ID3'
			   , reqd_param = 0, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position Daily Pivot View'
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
		INNER JOIN data_source ds ON ds.[name] = 'Position Daily Pivot View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	

	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position Daily Pivot View'
	            AND dsc.name =  'book_identifier4'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Book ID4'
			   , reqd_param = 0, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position Daily Pivot View'
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
		INNER JOIN data_source ds ON ds.[name] = 'Position Daily Pivot View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	

	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position Daily Pivot View'
	            AND dsc.name =  'commodity'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Commodity'
			   , reqd_param = 0, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position Daily Pivot View'
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
		INNER JOIN data_source ds ON ds.[name] = 'Position Daily Pivot View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	

	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position Daily Pivot View'
	            AND dsc.name =  'country'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Country'
			   , reqd_param = 0, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position Daily Pivot View'
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
		INNER JOIN data_source ds ON ds.[name] = 'Position Daily Pivot View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	

	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position Daily Pivot View'
	            AND dsc.name =  'deal_date'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Deal Date'
			   , reqd_param = 0, widget_id = 6, datatype_id = 2, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 4, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position Daily Pivot View'
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
		INNER JOIN data_source ds ON ds.[name] = 'Position Daily Pivot View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	

	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position Daily Pivot View'
	            AND dsc.name =  'deal_id'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Reference ID'
			   , reqd_param = 0, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position Daily Pivot View'
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
		INNER JOIN data_source ds ON ds.[name] = 'Position Daily Pivot View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	

	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position Daily Pivot View'
	            AND dsc.name =  'deal_status'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Deal Status'
			   , reqd_param = 0, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position Daily Pivot View'
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
		INNER JOIN data_source ds ON ds.[name] = 'Position Daily Pivot View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	

	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position Daily Pivot View'
	            AND dsc.name =  'grid'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Grid'
			   , reqd_param = 0, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position Daily Pivot View'
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
		INNER JOIN data_source ds ON ds.[name] = 'Position Daily Pivot View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	

	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position Daily Pivot View'
	            AND dsc.name =  'location'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Location'
			   , reqd_param = 0, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position Daily Pivot View'
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
		INNER JOIN data_source ds ON ds.[name] = 'Position Daily Pivot View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	

	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position Daily Pivot View'
	            AND dsc.name =  'location_group'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Location Group'
			   , reqd_param = 0, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position Daily Pivot View'
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
		INNER JOIN data_source ds ON ds.[name] = 'Position Daily Pivot View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	

	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position Daily Pivot View'
	            AND dsc.name =  'parent_counterparty'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Parent Counterparty'
			   , reqd_param = 0, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position Daily Pivot View'
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
		INNER JOIN data_source ds ON ds.[name] = 'Position Daily Pivot View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	

	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position Daily Pivot View'
	            AND dsc.name =  'physical_financial_flag'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Physical Financial'
			   , reqd_param = 0, widget_id = 2, datatype_id = 5, param_data_source = '[''Physical'',''Physical''],[''Financial'',''Financial'']', param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position Daily Pivot View'
			AND dsc.name =  'physical_financial_flag'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'physical_financial_flag' AS [name], 'Physical Financial' AS ALIAS, 0 AS reqd_param, 2 AS widget_id, 5 AS datatype_id, '[''Physical'',''Physical''],[''Financial'',''Financial'']' AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Position Daily Pivot View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	

	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position Daily Pivot View'
	            AND dsc.name =  'proxy_index'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Proxy Index'
			   , reqd_param = 0, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position Daily Pivot View'
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
		INNER JOIN data_source ds ON ds.[name] = 'Position Daily Pivot View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	

	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position Daily Pivot View'
	            AND dsc.name =  'region'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Region'
			   , reqd_param = 0, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position Daily Pivot View'
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
		INNER JOIN data_source ds ON ds.[name] = 'Position Daily Pivot View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	

	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position Daily Pivot View'
	            AND dsc.name =  'source_deal_header_id'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Deal ID'
			   , reqd_param = 0, widget_id = 1, datatype_id = 4, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 2, key_column = 1
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position Daily Pivot View'
			AND dsc.name =  'source_deal_header_id'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'source_deal_header_id' AS [name], 'Deal ID' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 4 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,2 AS column_template, 1 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Position Daily Pivot View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	

	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position Daily Pivot View'
	            AND dsc.name =  'stra_id'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Strategy ID'
			   , reqd_param = 1, widget_id = 4, datatype_id = 4, param_data_source = NULL, param_default_value = NULL, append_filter = 0, tooltip = NULL, column_template = 2, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position Daily Pivot View'
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
		INNER JOIN data_source ds ON ds.[name] = 'Position Daily Pivot View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	

	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position Daily Pivot View'
	            AND dsc.name =  'strategy'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Strategy'
			   , reqd_param = 0, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position Daily Pivot View'
			AND dsc.name =  'strategy'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'strategy' AS [name], 'Strategy' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Position Daily Pivot View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	

	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position Daily Pivot View'
	            AND dsc.name =  'sub'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Subsidiary'
			   , reqd_param = 0, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position Daily Pivot View'
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
		INNER JOIN data_source ds ON ds.[name] = 'Position Daily Pivot View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	

	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position Daily Pivot View'
	            AND dsc.name =  'sub_id'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Subsidiary ID'
			   , reqd_param = 1, widget_id = 3, datatype_id = 4, param_data_source = NULL, param_default_value = NULL, append_filter = 0, tooltip = NULL, column_template = 2, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position Daily Pivot View'
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
		INNER JOIN data_source ds ON ds.[name] = 'Position Daily Pivot View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	

	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position Daily Pivot View'
	            AND dsc.name =  'term_start'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Term Start'
			   , reqd_param = 0, widget_id = 6, datatype_id = 2, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 4, key_column = 1
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position Daily Pivot View'
			AND dsc.name =  'term_start'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'term_start' AS [name], 'Term Start' AS ALIAS, 0 AS reqd_param, 6 AS widget_id, 2 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,4 AS column_template, 1 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Position Daily Pivot View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	

	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position Daily Pivot View'
	            AND dsc.name =  'term_year_month'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Term Year Month'
			   , reqd_param = 0, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position Daily Pivot View'
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
		INNER JOIN data_source ds ON ds.[name] = 'Position Daily Pivot View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	

	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position Daily Pivot View'
	            AND dsc.name =  'uom'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'UOM'
			   , reqd_param = 0, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position Daily Pivot View'
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
		INNER JOIN data_source ds ON ds.[name] = 'Position Daily Pivot View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	

	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position Daily Pivot View'
	            AND dsc.name =  'volume'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Volume'
			   , reqd_param = 0, widget_id = 1, datatype_id = 3, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 2, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position Daily Pivot View'
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
		INNER JOIN data_source ds ON ds.[name] = 'Position Daily Pivot View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	

	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position Daily Pivot View'
	            AND dsc.name =  'block_definition'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Block Definition'
			   , reqd_param = 0, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position Daily Pivot View'
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
		INNER JOIN data_source ds ON ds.[name] = 'Position Daily Pivot View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	

	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position Daily Pivot View'
	            AND dsc.name =  'deal_volume_frequency'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Volume Frequency'
			   , reqd_param = 0, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position Daily Pivot View'
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
		INNER JOIN data_source ds ON ds.[name] = 'Position Daily Pivot View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	

	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position Daily Pivot View'
	            AND dsc.name =  'proxy_curve2'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Proxy Curve2'
			   , reqd_param = 0, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position Daily Pivot View'
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
		INNER JOIN data_source ds ON ds.[name] = 'Position Daily Pivot View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	

	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position Daily Pivot View'
	            AND dsc.name =  'proxy_curve3'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Proxy Curve3'
			   , reqd_param = 0, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position Daily Pivot View'
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
		INNER JOIN data_source ds ON ds.[name] = 'Position Daily Pivot View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	

	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position Daily Pivot View'
	            AND dsc.name =  'proxy_curve'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Proxy Curve'
			   , reqd_param = 0, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position Daily Pivot View'
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
		INNER JOIN data_source ds ON ds.[name] = 'Position Daily Pivot View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	

	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position Daily Pivot View'
	            AND dsc.name =  'proxy_curve_position_uom'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Proxy Curve Position UOM'
			   , reqd_param = 0, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position Daily Pivot View'
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
		INNER JOIN data_source ds ON ds.[name] = 'Position Daily Pivot View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	

	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position Daily Pivot View'
	            AND dsc.name =  'proxy2_position_uom'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Proxy2 Position UOM'
			   , reqd_param = 0, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position Daily Pivot View'
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
		INNER JOIN data_source ds ON ds.[name] = 'Position Daily Pivot View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	

	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position Daily Pivot View'
	            AND dsc.name =  'proxy3_position_uom'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Proxy3 Position UOM'
			   , reqd_param = 0, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position Daily Pivot View'
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
		INNER JOIN data_source ds ON ds.[name] = 'Position Daily Pivot View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	

	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position Daily Pivot View'
	            AND dsc.name =  'term_year'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Term Year'
			   , reqd_param = 0, widget_id = 1, datatype_id = 4, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 2, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position Daily Pivot View'
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
		INNER JOIN data_source ds ON ds.[name] = 'Position Daily Pivot View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	

	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position Daily Pivot View'
	            AND dsc.name =  'counterparty_id'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Counterparty ID'
			   , reqd_param = 0, widget_id = 7, datatype_id = 4, param_data_source = '10191000', param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 2, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position Daily Pivot View'
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
		INNER JOIN data_source ds ON ds.[name] = 'Position Daily Pivot View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	

	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position Daily Pivot View'
	            AND dsc.name =  'location_id'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Location ID'
			   , reqd_param = 0, widget_id = 7, datatype_id = 4, param_data_source = '10102500', param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 2, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position Daily Pivot View'
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
		INNER JOIN data_source ds ON ds.[name] = 'Position Daily Pivot View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	

	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position Daily Pivot View'
	            AND dsc.name =  'proxy_index_position_uom'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Proxy Index Position UOM'
			   , reqd_param = 0, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position Daily Pivot View'
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
		INNER JOIN data_source ds ON ds.[name] = 'Position Daily Pivot View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	

	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position Daily Pivot View'
	            AND dsc.name =  'term_end'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Term End'
			   , reqd_param = 0, widget_id = 6, datatype_id = 2, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 4, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position Daily Pivot View'
			AND dsc.name =  'term_end'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'term_end' AS [name], 'Term End' AS ALIAS, 0 AS reqd_param, 6 AS widget_id, 2 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,4 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Position Daily Pivot View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	

	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position Daily Pivot View'
	            AND dsc.name =  'curve_name'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Index'
			   , reqd_param = 0, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position Daily Pivot View'
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
		INNER JOIN data_source ds ON ds.[name] = 'Position Daily Pivot View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	

	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position Daily Pivot View'
	            AND dsc.name =  'curve_id'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Curve ID'
			   , reqd_param = 0, widget_id = 7, datatype_id = 4, param_data_source = '10102600', param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 2, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position Daily Pivot View'
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
		INNER JOIN data_source ds ON ds.[name] = 'Position Daily Pivot View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	

	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position Daily Pivot View'
	            AND dsc.name =  'position_uom'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Position UOM'
			   , reqd_param = 0, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position Daily Pivot View'
			AND dsc.name =  'position_uom'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'position_uom' AS [name], 'Position UOM' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Position Daily Pivot View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	

	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position Daily Pivot View'
	            AND dsc.name =  'counterparty_name'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Counterparty'
			   , reqd_param = 0, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position Daily Pivot View'
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
		INNER JOIN data_source ds ON ds.[name] = 'Position Daily Pivot View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	

	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position Daily Pivot View'
	            AND dsc.name =  'sub_book_id'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Sub Book ID'
			   , reqd_param = 1, widget_id = 8, datatype_id = 4, param_data_source = NULL, param_default_value = NULL, append_filter = 0, tooltip = NULL, column_template = 2, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position Daily Pivot View'
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
		INNER JOIN data_source ds ON ds.[name] = 'Position Daily Pivot View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	

	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position Daily Pivot View'
	            AND dsc.name =  'CFD_curve_name'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'CFD_curve_name'
			   , reqd_param = 0, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position Daily Pivot View'
			AND dsc.name =  'CFD_curve_name'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'CFD_curve_name' AS [name], 'CFD_curve_name' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Position Daily Pivot View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	

	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position Daily Pivot View'
	            AND dsc.name =  'CFD_term_start'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'CFD_term_start'
			   , reqd_param = 0, widget_id = 6, datatype_id = 2, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 4, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position Daily Pivot View'
			AND dsc.name =  'CFD_term_start'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'CFD_term_start' AS [name], 'CFD_term_start' AS ALIAS, 0 AS reqd_param, 6 AS widget_id, 2 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,4 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Position Daily Pivot View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	

	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position Daily Pivot View'
	            AND dsc.name =  'convert_uom'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'convert_uom'
			   , reqd_param = 0, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position Daily Pivot View'
			AND dsc.name =  'convert_uom'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'convert_uom' AS [name], 'convert_uom' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Position Daily Pivot View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	

	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position Daily Pivot View'
	            AND dsc.name =  'display_term'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'display_term'
			   , reqd_param = 0, widget_id = 6, datatype_id = 2, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 4, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position Daily Pivot View'
			AND dsc.name =  'display_term'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'display_term' AS [name], 'display_term' AS ALIAS, 0 AS reqd_param, 6 AS widget_id, 2 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,4 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Position Daily Pivot View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	

	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position Daily Pivot View'
	            AND dsc.name =  'header_commodity'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'header_commodity'
			   , reqd_param = 0, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position Daily Pivot View'
			AND dsc.name =  'header_commodity'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'header_commodity' AS [name], 'header_commodity' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Position Daily Pivot View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	

	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position Daily Pivot View'
	            AND dsc.name =  'location_group1'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'location_group1'
			   , reqd_param = 0, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position Daily Pivot View'
			AND dsc.name =  'location_group1'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'location_group1' AS [name], 'location_group1' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Position Daily Pivot View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	

	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position Daily Pivot View'
	            AND dsc.name =  'location_group2'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'location_group2'
			   , reqd_param = 0, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position Daily Pivot View'
			AND dsc.name =  'location_group2'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'location_group2' AS [name], 'location_group2' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Position Daily Pivot View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	

	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position Daily Pivot View'
	            AND dsc.name =  'location_group3'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'location_group3'
			   , reqd_param = 0, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position Daily Pivot View'
			AND dsc.name =  'location_group3'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'location_group3' AS [name], 'location_group3' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Position Daily Pivot View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	

	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position Daily Pivot View'
	            AND dsc.name =  'location_group4'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'location_group4'
			   , reqd_param = 0, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position Daily Pivot View'
			AND dsc.name =  'location_group4'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'location_group4' AS [name], 'location_group4' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Position Daily Pivot View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	

	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position Daily Pivot View'
	            AND dsc.name =  'province'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'province'
			   , reqd_param = 0, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position Daily Pivot View'
			AND dsc.name =  'province'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'province' AS [name], 'province' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Position Daily Pivot View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	

	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position Daily Pivot View'
	            AND dsc.name =  'source_deal_detail_id'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'source_deal_detail_id'
			   , reqd_param = 0, widget_id = 1, datatype_id = 4, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 2, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position Daily Pivot View'
			AND dsc.name =  'source_deal_detail_id'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'source_deal_detail_id' AS [name], 'source_deal_detail_id' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 4 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Position Daily Pivot View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	

	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position Daily Pivot View'
	            AND dsc.name =  'uom_id'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'uom_id'
			   , reqd_param = 0, widget_id = 1, datatype_id = 4, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 2, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position Daily Pivot View'
			AND dsc.name =  'uom_id'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'uom_id' AS [name], 'uom_id' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 4 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Position Daily Pivot View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	

	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position Daily Pivot View'
	            AND dsc.name =  'source_major_location_ID'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Location Group ID'
			   , reqd_param = 0, widget_id = 2, datatype_id = 4, param_data_source = 'SELECT source_major_location_ID [value], location_name [label] FROM source_major_location', param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 2, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position Daily Pivot View'
			AND dsc.name =  'source_major_location_ID'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'source_major_location_ID' AS [name], 'Location Group ID' AS ALIAS, 0 AS reqd_param, 2 AS widget_id, 4 AS datatype_id, 'SELECT source_major_location_ID [value], location_name [label] FROM source_major_location' AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Position Daily Pivot View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	

	DELETE dsc
	FROM data_source_column dsc 
	INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		AND ds.[name] = 'Position Daily Pivot View'
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
	