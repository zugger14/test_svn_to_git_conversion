BEGIN TRY
		BEGIN TRAN
	
	declare @new_ds_alias varchar(10) = 'sdpmv'
	/** IF DATA SOURCE ALIAS ALREADY EXISTS ON DESTINATION, RAISE ERROR **/
	if exists(select top 1 1 from data_source where alias = 'sdpmv' and name <> 'Delta monthly position view')
	begin
		select top 1 @new_ds_alias = 'sdpmv' + cast(s.n as varchar(5))
		from seq s
		left join data_source ds on ds.alias = 'sdpmv' + cast(s.n as varchar(5))
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
	           WHERE [name] = 'Delta Monthly Position View'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	AND NOT EXISTS (SELECT 1 FROM map_function_category WHERE [function_name] = 'Delta Monthly Position View' AND '106500' = '106501') 
	BEGIN
		INSERT INTO data_source([type_id], [name], [alias], [description], [tsql], report_id, system_defined,category)
		SELECT TOP 1 1 AS [type_id], 'Delta Monthly Position View' AS [name], @new_ds_alias AS ALIAS, 'Standard Delta Monthly Position View' AS [description],null AS [tsql], @report_id_data_source_dest AS report_id,'1' AS [system_defined]
			,'106500' AS [category]
	END

	UPDATE data_source
	SET alias = @new_ds_alias, description = 'Standard Delta Monthly Position View'
	, [tsql] = CAST('' AS VARCHAR(MAX)) + 'DECLARE @_deal_status_group CHAR(1)

DECLARE @_final_sql VARCHAR(MAX)

DECLARE @_commodity_id VARCHAR(MAX)

DECLARE @_deal_type_id VARCHAR(MAX)



IF ''@deal_status_group'' <> ''NULL''

	SET @_deal_status_group = ''@deal_status_group''

IF ''@commodity_id'' <> ''NULL''

	SET @_commodity_id = ''@commodity_id''

IF ''@deal_type_id'' <> ''NULL''

	SET @_deal_type_id = ''@deal_type_id''



IF OBJECT_ID(N''tempdb..#books'') IS NOT NULL

	DROP TABLE #books

IF OBJECT_ID(N''tempdb..#term_date'') IS NOT NULL

	DROP TABLE #term_date



CREATE TABLE #books (

	fas_book_id INT

	,source_system_book_id1 INT

	,source_system_book_id2 INT

	,source_system_book_id3 INT

	,source_system_book_id4 INT

	)



INSERT INTO #books

SELECT DISTINCT book.entity_id

	,ssbm.source_system_book_id1

	,ssbm.source_system_book_id2

	,ssbm.source_system_book_id3

	,ssbm.source_system_book_id4 fas_book_id

FROM portfolio_hierarchy book(NOLOCK)

INNER JOIN Portfolio_hierarchy stra(NOLOCK) ON book.parent_entity_id = stra.entity_id

INNER JOIN portfolio_hierarchy sub(NOLOCK) ON stra.parent_entity_id = sub.entity_id

INNER JOIN source_system_book_map ssbm ON ssbm.fas_book_id = book.entity_id

WHERE (fas_deal_type_value_id IS NULL OR fas_deal_type_value_id BETWEEN 400 AND 401) 

	AND (''@sub_id'' = ''NULL'' OR sub.entity_id IN (@sub_id)) 

	AND (''@stra_id'' = ''NULL'' OR stra.entity_id IN (@stra_id)) 

	AND (''@book_id'' = ''NULL'' OR book.entity_id IN (@book_id)) 

	AND (''@sub_book_id'' = ''NULL'' OR ssbm.book_deal_type_map_id IN (@sub_book_id))



IF OBJECT_ID(N''tempdb..#temp_report_hourly_position_breakdown'') IS NOT NULL

	DROP TABLE #temp_report_hourly_position_breakdown

SELECT DISTINCT tz.dst_group_value_id

	,isnull(spcd.block_define_id, 300501) block_define_id

	,s.term_start

	,s.term_end

INTO #temp_report_hourly_position_breakdown

FROM report_hourly_position_breakdown s(NOLOCK)

INNER JOIN #books bk ON bk.fas_book_id = s.fas_book_id AND bk.source_system_book_id1 = s.source_system_book_id1 AND bk.source_system_book_id2 = s.source_system_book_id2 AND bk.source_system_book_id3 = s.source_system_book_id3 AND bk.source_system_book_id4 = s.source_system_book_id4

INNER JOIN [deal_status_group] dsg ON dsg.status_value_id = s.deal_status_id

LEFT JOIN source_price_curve_def spcd WITH (NOLOCK) ON spcd.source_curve_def_id = s.curve_id

OUTER APPLY (

	SELECT TOP 1 *

	FROM vwDealTimezone vw

	WHERE vw.source_deal_header_id = s.source_deal_header_id

) tz



CREATE TABLE #term_date (

	block_define_id INT

	,term_date DATE

	,term_start DATE

	,term_end DATE

	,hr1 TINYINT

	,hr2 TINYINT

	,hr3 TINYINT

	,hr4 TINYINT

	,hr5 TINYINT

	,hr6 TINYINT

	,hr7 TINYINT

	,hr8 TINYINT

	,hr9 TINYINT

	,hr10 TINYINT

	,hr11 TINYINT

	,hr12 TINYINT

	,hr13 TINYINT

	,hr14 TINYINT

	,hr15 TINYINT

	,hr16 TINYINT

	,hr17 TINYINT

	,hr18 TINYINT

	,hr19 TINYINT

	,hr20 TINYINT

	,hr21 TINYINT

	,hr22 TINYINT

	,hr23 TINYINT

	,hr24 TINYINT

	,add_dst_hour INT

	)



INSERT INTO #term_date (

	block_define_id

	,term_date

	,term_start

	,term_end

	,hr1

	,hr2

	,hr3

	,hr4

	,hr5

	,hr6

	,hr7

	,hr8

	,hr9

	,hr10

	,hr11

	,hr12

	,hr13

	,hr14

	,hr15

	,hr16

	,hr17

	,hr18

	,hr19

	,hr20

	,hr21

	,hr22

	,hr23

	,hr24

	,add_dst_hour

	)

SELECT DISTINCT a.block_define_id

	,hb.term_date

	,a.term_start

	,a.term_end

	,hb.hr1

	,hb.hr2

	,hb.hr3

	,hb.hr4

	,hb.hr5

	,hb.hr6

	,hb.hr7

	,hb.hr8

	,hb.hr9

	,hb.hr10

	,hb.hr11

	,hb.hr12

	,hb.hr13

	,hb.hr14

	,hb.hr15

	,hb.hr16

	,hb.hr17

	,hb.hr18

	,hb.hr19

	,hb.hr20

	,hb.hr21

	,hb.hr22

	,hb.hr23

	,hb.hr24

	,hb.add_dst_hour

FROM #temp_report_hourly_position_breakdown a

OUTER APPLY (

	SELECT h.*

	FROM hour_block_term h WITH (NOLOCK)

	WHERE block_define_id = a.block_define_id AND h.block_type = 12000 AND term_date BETWEEN a.term_start

			AND a.term_end --and term_date>@as_of_date

		AND h.dst_group_value_id = a.dst_group_value_id

	) hb



----- hourly position deal start

IF OBJECT_ID(N''tempdb..#temp_hourly_position_deal'') IS NOT NULL

	DROP TABLE #temp_hourly_position_deal

SELECT s.curve_id

	,s.location_id

	,s.term_start

	,0 period

	,s.deal_date

	,s.deal_volume_uom_id

	,s.physical_financial_flag

	,s.hr1 [01]

	,s.hr2 [02]

	,s.hr3 [03]

	,s.hr4 [04]

	,s.hr5 [05]

	,s.hr6 [06]

	,s.hr7 [07]

	,s.hr8 [08]

	,s.hr9 [09]

	,s.hr10 [10]

	,s.hr11 [11]

	,s.hr12 [12]

	,s.hr13 [13]

	,s.hr14 [14]

	,s.hr15 [15]

	,s.hr16 [16]

	,s.hr17 [17]

	,s.hr18 [18]

	,s.hr19 [19]

	,s.hr20 [20]

	,s.hr21 [21]

	,s.hr22 [22]

	,s.hr23 [23]

	,s.hr24 [24]

	,s.hr25 [25]

	,s.source_deal_header_id

	,s.commodity_id

	,s.counterparty_id

	,s.fas_book_id

	,s.source_system_book_id1

	,s.source_system_book_id2

	,s.source_system_book_id3

	,s.source_system_book_id4

	,s.expiration_date

	,''n'' AS is_fixedvolume

	,deal_status_id

INTO #temp_hourly_position_deal

FROM report_hourly_position_deal s(NOLOCK)

INNER JOIN #books bk ON bk.fas_book_id = s.fas_book_id AND bk.source_system_book_id1 = s.source_system_book_id1 AND bk.source_system_book_id2 = s.source_system_book_id2 AND bk.source_system_book_id3 = s.source_system_book_id3 AND bk.source_system_book_id4 = s.source_system_book_id4

LEFT JOIN source_price_curve_def spcd ON spcd.source_curve_def_id = s.curve_id

WHERE 1 = 1 AND s.deal_date < = ''@as_of_date'' AND s.expiration_date > ''@as_of_date'' AND s.term_start > ''@as_of_date''

----- hourly position deal end

----- hourly position profile start

IF OBJECT_ID(N''tempdb..#temp_hourly_position_profile'') IS NOT NULL

	DROP TABLE #temp_hourly_position_profile

SELECT s.curve_id

	,s.location_id

	,s.term_start

	,0 Period

	,s.deal_date

	,s.deal_volume_uom_id

	,s.physical_financial_flag

	,s.hr1 [01]

	,s.hr2 [02]

	,s.hr3 [03]

	,s.hr4 [04]

	,s.hr5 [05]

	,s.hr6 [06]

	,s.hr7 [07]

	,s.hr8 [08]

	,s.hr9 [09]

	,s.hr10 [10]

	,s.hr11 [11]

	,s.hr12 [12]

	,s.hr13 [13]

	,s.hr14 [14]

	,s.hr15 [15]

	,s.hr16 [16]

	,s.hr17 [17]

	,s.hr18 [18]

	,s.hr19 [19]

	,s.hr20 [20]

	,s.hr21 [21]

	,s.hr22 [22]

	,s.hr23 [23]

	,s.hr24 [24]

	,s.hr25 [25]

	,s.source_deal_header_id

	,s.commodity_id

	,s.counterparty_id

	,s.fas_book_id

	,s.source_system_book_id1

	,s.source_system_book_id2

	,s.source_system_book_id3

	,s.source_system_book_id4

	,s.expiration_date

	,''n'' AS is_fixedvolume

	,deal_status_id

INTO #temp_hourly_position_profile

FROM report_hourly_position_profile s(NOLOCK)

INNER JOIN #books bk ON bk.fas_book_id = s.fas_book_id AND bk.source_system_book_id1 = s.source_system_book_id1 AND bk.source_system_book_id2 = s.source_system_book_id2 AND bk.source_system_book_id3 = s.source_system_book_id3 AND bk.source_system_book_id4 = s.source_system_book_id4

LEFT JOIN source_price_curve_def spcd ON spcd.source_curve_def_id = s.curve_id

WHERE 1 = 1 AND s.deal_date < = ''@as_of_date'' AND s.expiration_date > ''@as_of_date'' AND s.term_start > ''@as_of_date''

---- hourly position profile end

IF OBJECT_ID(N''tempdb..#temp_hourly_position_breakdown'') IS NOT NULL

	DROP TABLE #temp_hourly_position_breakdown

----- hourly position breakdown start

SELECT s.curve_id

	,ISNULL(s.location_id, - 1) location_id

	,hb.term_date term_start

	,0 period

	,s.deal_date

	,s.deal_volume_uom_id

	,s.physical_financial_flag

	,(cast(cast(cast(s.calc_volume AS NUMERIC(22, 10)) * cast(isnull(hb.hr1, 0) AS NUMERIC(1, 0)) AS NUMERIC(22, 10)) * cast(CASE WHEN isnull(hb.add_dst_hour, 0) = 1 THEN 2 ELSE 1 END AS NUMERIC(1, 0)) AS NUMERIC(22, 10))) / cast(nullif(isnull(term_hrs.term_no_hrs, term_hrs_exp.term_no_hrs), 0) AS NUMERIC(8, 0)) * (CASE WHEN (hb.term_date) > = CAST(YEAR(DATEADD(m, 1, ''@as_of_date'')) AS VARCHAR) + ''-'' + CAST(MONTH(DATEADD(m, 1, ''@as_of_date'')) AS VARCHAR) + ''-01'' THEN ISNULL(remain_month.remain_days / CAST(remain_month.total_days AS FLOAT), 1) ELSE 1 END) [01]

	,(cast(cast(cast(s.calc_volume AS NUMERIC(22, 10)) * cast(isnull(hb.hr2, 0) AS NUMERIC(1, 0)) AS NUMERIC(22, 10)) * cast(CASE WHEN isnull(hb.add_dst_hour, 0) = 2 THEN 2 ELSE 1 END AS NUMERIC(1, 0)) AS NUMERIC(22, 10))) /

cast(nullif(isnull(term_hrs.term_no_hrs, term_hrs_exp.term_no_hrs), 0) AS NUMERIC(8, 0)) * (CASE WHEN (hb.term_date) > = CAST(YEAR(DATEADD(m, 1, ''@as_of_date'')) AS VARCHAR) + ''-'' + CAST(MONTH(DATEADD(m, 1, ''@as_of_date'')) AS VARCHAR) + ''-01'' THEN ISNULL(remain_month.remain_days / CAST(remain_month.total_days AS FLOAT), 1) ELSE 1 END) [02]

	,(cast(cast(cast(s.calc_volume AS NUMERIC(22, 10)) * cast(isnull(hb.hr3, 0) AS NUMERIC(1, 0)) AS NUMERIC(22, 10)) * cast(CASE WHEN isnull(hb.add_dst_hour, 0) = 3 THEN 2 ELSE 1 END AS NUMERIC(1, 0)) AS NUMERIC(22, 10))) /

cast(nullif(isnull(term_hrs.term_no_hrs, term_hrs_exp.term_no_hrs), 0) AS NUMERIC(8, 0)) * (CASE WHEN (hb.term_date) > = CAST(YEAR(DATEADD(m, 1, ''@as_of_date'')) AS VARCHAR) + ''-'' + CAST(MONTH(DATEADD(m, 1, ''@as_of_date'')) AS VARCHAR) + ''-01'' THEN ISNULL(remain_month.remain_days / CAST(remain_month.total_days AS FLOAT), 1) ELSE 1 END) [03]

	,(cast(cast(cast(s.calc_volume AS NUMERIC(22, 10)) * cast(isnull(hb.hr4, 0) AS NUMERIC(1, 0)) AS NUMERIC(22, 10)) * cast(CASE WHEN isnull(hb.add_dst_hour, 0) = 4 THEN 2 ELSE 1 END AS NUMERIC(1, 0)) AS NUMERIC(22, 10))) /

cast(nullif(isnull(term_hrs.term_no_hrs, term_hrs_exp.term_no_hrs), 0) AS NUMERIC(8, 0)) * (CASE WHEN (hb.term_date) > = CAST(YEAR(DATEADD(m, 1, ''@as_of_date'')) AS VARCHAR) + ''-'' + CAST(MONTH(DATEADD(m, 1, ''@as_of_date'')) AS VARCHAR) + ''-01'' THEN ISNULL(remain_month.remain_days / CAST(remain_month.total_days AS FLOAT), 1) ELSE 1 END) [04]

	,(cast(cast(cast(s.calc_volume AS NUMERIC(22, 10)) * cast(isnull(hb.hr5, 0) AS NUMERIC(1, 0)) AS NUMERIC(22, 10)) * cast(CASE WHEN isnull(hb.add_dst_hour, 0) = 5 THEN 2 ELSE 1 END AS NUMERIC(1, 0)) AS NUMERIC(22, 10))) /

cast(nullif(isnull(term_hrs.term_no_hrs, term_hrs_exp.term_no_hrs), 0) AS NUMERIC(8, 0)) * (CASE WHEN (hb.term_date) > = CAST(YEAR(DATEADD(m, 1, ''@as_of_date'')) AS VARCHAR) + ''-'' + CAST(MONTH(DATEADD(m, 1, ''@as_of_date'')) AS VARCHAR) + ''-01'' THEN ISNULL(remain_month.remain_days / CAST(remain_month.total_days AS FLOAT), 1) ELSE 1 END) [05]

	,(cast(cast(cast(s.calc_volume AS NUMERIC(22, 10)) * cast(isnull(hb.hr6, 0) AS NUMERIC(1, 0)) AS NUMERIC(22, 10)) * cast(CASE WHEN isnull(hb.add_dst_hour, 0) = 6 THEN 2 ELSE 1 END AS NUMERIC(1, 0)) AS NUMERIC(22, 10))) /

cast(nullif(isnull(term_hrs.term_no_hrs, term_hrs_exp.term_no_hrs), 0) AS NUMERIC(8, 0)) * (CASE WHEN (hb.term_date) > = CAST(YEAR(DATEADD(m, 1, ''@as_of_date'')) AS VARCHAR) + ''-'' + CAST(MONTH(DATEADD(m, 1, ''@as_of_date'')) AS VARCHAR) + ''-01'' THEN ISNULL(remain_month.remain_days / CAST(remain_month.total_days AS FLOAT), 1) ELSE 1 END) [06]

	,(cast(cast(cast(s.calc_volume AS NUMERIC(22, 10)) * cast(isnull(hb.hr7, 0) AS NUMERIC(1, 0)) AS NUMERIC(22, 10)) * cast(CASE WHEN isnull(hb.add_dst_hour, 0) = 7 THEN 2 ELSE 1 END AS NUMERIC(1, 0)) AS NUMERIC(22, 10))) /

cast(nullif(isnull(term_hrs.term_no_hrs, term_hrs_exp.term_no_hrs), 0) AS NUMERIC(8, 0)) * (CASE WHEN (hb.term_date) > = CAST(YEAR(DATEADD(m, 1, ''@as_of_date'')) AS VARCHAR) + ''-'' + CAST(MONTH(DATEADD(m, 1, ''@as_of_date'')) AS VARCHAR) + ''-01'' THEN ISNULL(remain_month.remain_days / CAST(remain_month.total_days AS FLOAT), 1) ELSE 1 END) [07]

	,(cast(cast(cast(s.calc_volume AS NUMERIC(22, 10)) * cast(isnull(hb.hr8, 0) AS NUMERIC(1, 0)) AS NUMERIC(22, 10)) * cast(CASE WHEN isnull(hb.add_dst_hour, 0) = 8 THEN 2 ELSE 1 END AS NUMERIC(1, 0)) AS NUMERIC(22, 10))) /

cast(nullif(isnull(term_hrs.term_no_hrs, term_hrs_exp.term_no_hrs), 0) AS NUMERIC(8, 0)) * (CASE WHEN (hb.term_date) > = CAST(YEAR(DATEADD(m, 1, ''@as_of_date'')) AS VARCHAR) + ''-'' + CAST(MONTH(DATEADD(m, 1, ''@as_of_date'')) AS VARCHAR) + ''-01'' THEN ISNULL(remain_month.remain_days / CAST(remain_month.total_days AS FLOAT), 1) ELSE 1 END) [08]

	,(cast(cast(cast(s.calc_volume AS NUMERIC(22, 10)) * cast(isnull(hb.hr9, 0) AS NUMERIC(1, 0)) AS NUMERIC(22, 10)) * cast(CASE WHEN isnull(hb.add_dst_hour, 0) = 9 THEN 2 ELSE 1 END AS NUMERIC(1, 0)) AS NUMERIC(22, 10))) /

cast(nullif(isnull(term_hrs.term_no_hrs, term_hrs_exp.term_no_hrs), 0) AS NUMERIC(8, 0)) * (CASE WHEN (hb.term_date) > = CAST(YEAR(DATEADD(m, 1, ''@as_of_date'')) AS VARCHAR) + ''-'' + CAST(MONTH(DATEADD(m, 1, ''@as_of_date'')) AS VARCHAR) + ''-01'' THEN ISNULL(remain_month.remain_days / CAST(remain_month.total_days AS FLOAT), 1) ELSE 1 END) [09]

	,(cast(cast(cast(s.calc_volume AS NUMERIC(22, 10)) * cast(isnull(hb.hr10, 0) AS NUMERIC(1, 0)) AS NUMERIC(22, 10)) * cast(CASE WHEN isnull(hb.add_dst_hour, 0) = 10 THEN 2 ELSE 1 END AS NUMERIC(1, 0)) AS NUMERIC(22, 10))) /

cast(nullif(isnull(term_hrs.term_no_hrs, term_hrs_exp.term_no_hrs), 0) AS NUMERIC(8, 0)) * (CASE WHEN (hb.term_date) > = CAST(YEAR(DATEADD(m, 1, ''@as_of_date'')) AS VARCHAR) + ''-'' + CAST(MONTH(DATEADD(m, 1, ''@as_of_date'')) AS VARCHAR) + ''-01'' THEN ISNULL(remain_month.remain_days / CAST(remain_month.total_days AS FLOAT), 1) ELSE 1 END) [10]

	,(cast(cast(cast(s.calc_volume AS NUMERIC(22, 10)) * cast(isnull(hb.hr11, 0) AS NUMERIC(1, 0)) AS NUMERIC(22, 10)) * cast(CASE WHEN isnull(hb.add_dst_hour, 0) = 11 THEN 2 ELSE 1 END AS NUMERIC(1, 0)) AS NUMERIC(22, 10))) /

cast(nullif(isnull(term_hrs.term_no_hrs, term_hrs_exp.term_no_hrs), 0) AS NUMERIC(8, 0)) * (CASE WHEN (hb.term_date) > = CAST(YEAR(DATEADD(m, 1, ''@as_of_date'')) AS VARCHAR) + ''-'' + CAST(MONTH(DATEADD(m, 1, ''@as_of_date'')) AS VARCHAR) + ''-01'' THEN ISNULL(remain_month.remain_days / CAST(remain_month.total_days AS FLOAT), 1) ELSE 1 END) [11]

	,(cast(cast(cast(s.calc_volume AS NUMERIC(22, 10)) * cast(isnull(hb.hr12, 0) AS NUMERIC(1, 0)) AS NUMERIC(22, 10)) * cast(CASE WHEN isnull(hb.add_dst_hour, 0) = 12 THEN 2 ELSE 1 END AS NUMERIC(1, 0)) AS NUMERIC(22, 10))) /

cast(nullif(isnull(term_hrs.term_no_hrs, term_hrs_exp.term_no_hrs), 0) AS NUMERIC(8, 0)) * (CASE WHEN (hb.term_date) > = CAST(YEAR(DATEADD(m, 1, ''@as_of_date'')) AS VARCHAR) + ''-'' + CAST(MONTH(DATEADD(m, 1, ''@as_of_date'')) AS VARCHAR) + ''-01'' THEN ISNULL(remain_month.remain_days / CAST(remain_month.total_days AS FLOAT), 1) ELSE 1 END) [12]

	,(cast(cast(cast(s.calc_volume AS NUMERIC(22, 10)) * cast(isnull(hb.hr13, 0) AS NUMERIC(1, 0)) AS NUMERIC(22, 10)) * cast(CASE WHEN isnull(hb.add_dst_hour, 0) = 13 THEN 2 ELSE 1 END AS NUMERIC(1, 0)) AS NUMERIC(22, 10))) /

cast(nullif(isnull(term_hrs.term_no_hrs, term_hrs_exp.term_no_hrs), 0) AS NUMERIC(8, 0)) * (CASE WHEN (hb.term_date) > = CAST(YEAR(DATEADD(m, 1, ''@as_of_date'')) AS VARCHAR) + ''-'' + CAST(MONTH(DATEADD(m, 1, ''@as_of_date'')) AS VARCHAR) + ''-01'' THEN ISNULL(remain_month.remain_days / CAST(remain_month.total_days AS FLOAT), 1) ELSE 1 END) [13]

	,(cast(cast(cast(s.calc_volume AS NUMERIC(22, 10)) * cast(isnull(hb.hr14, 0) AS NUMERIC(1, 0)) AS NUMERIC(22, 10)) * cast(CASE WHEN isnull(hb.add_dst_hour, 0) = 14 THEN 2 ELSE 1 END AS NUMERIC(1, 0)) AS NUMERIC(22, 10))) /

cast(nullif(isnull(term_hrs.term_no_hrs, term_hrs_exp.term_no_hrs), 0) AS NUMERIC(8, 0)) * (CASE WHEN (hb.term_date) > = CAST(YEAR(DATEADD(m, 1, ''@as_of_date'')) AS VARCHAR) + ''-'' + CAST(MONTH(DATEADD(m, 1, ''@as_of_date'')) AS VARCHAR) + ''-01'' THEN ISNULL(remain_month.remain_days / CAST(remain_month.total_days AS FLOAT), 1) ELSE 1 END) [14]

	,(cast(cast(cast(s.calc_volume AS NUMERIC(22, 10)) * cast(isnull(hb.hr15, 0) AS NUMERIC(1, 0)) AS NUMERIC(22, 10)) * cast(CASE WHEN isnull(hb.add_dst_hour, 0) = 15 THEN 2 ELSE 1 END AS NUMERIC(1, 0)) AS NUMERIC(22, 10))) /

cast(nullif(isnull(term_hrs.term_no_hrs, term_hrs_exp.term_no_hrs), 0) AS NUMERIC(8, 0)) * (CASE WHEN (hb.term_date) > = CAST(YEAR(DATEADD(m, 1, ''@as_of_date'')) AS VARCHAR) + ''-'' + CAST(MONTH(DATEADD(m, 1, ''@as_of_date'')) AS VARCHAR) + ''-01'' THEN ISNULL(remain_month.remain_days / CAST(remain_month.total_days AS FLOAT), 1) ELSE 1 END) [15]

	,(cast(cast(cast(s.calc_volume AS NUMERIC(22, 10)) * cast(isnull(hb.hr16, 0) AS NUMERIC(1, 0)) AS NUMERIC(22, 10)) * cast(CASE WHEN isnull(hb.add_dst_hour, 0) = 16 THEN 2 ELSE 1 END AS NUMERIC(1, 0)) AS NUMERIC(22, 10))) /

cast(nullif(isnull(term_hrs.term_no_hrs, term_hrs_exp.term_no_hrs), 0) AS NUMERIC(8, 0)) * (CASE WHEN (hb.term_date) > = CAST(YEAR(DATEADD(m, 1, ''@as_of_date'')) AS VARCHAR) + ''-'' + CAST(MONTH(DATEADD(m, 1, ''@as_of_date'')) AS VARCHAR) + ''-01'' THEN ISNULL(remain_month.remain_days / CAST(remain_month.total_days AS FLOAT), 1) ELSE 1 END) [16]

	,(cast(cast(cast(s.calc_volume AS NUMERIC(22, 10)) * cast(isnull(hb.hr17, 0) AS NUMERIC(1, 0)) AS NUMERIC(22, 10)) * cast(CASE WHEN isnull(hb.add_dst_hour, 0) = 17 THEN 2 ELSE 1 END AS NUMERIC(1, 0)) AS NUMERIC(22, 10))) /

cast(nullif(isnull(term_hrs.term_no_hrs, term_hrs_exp.term_no_hrs), 0) AS NUMERIC(8, 0)) * (CASE WHEN (hb.term_date) > = CAST(YEAR(DATEADD(m, 1, ''@as_of_date'')) AS VARCHAR) + ''-'' + CAST(MONTH(DATEADD(m, 1, ''@as_of_date'')) AS VARCHAR) + ''-01'' THEN ISNULL(remain_month.remain_days / CAST(remain_month.total_days AS FLOAT), 1) ELSE 1 END) [17]

	,(cast(cast(cast(s.calc_volume AS NUMERIC(22, 10)) * cast(isnull(hb.hr18, 0) AS NUMERIC(1, 0)) AS NUMERIC(22, 10)) * cast(CASE WHEN isnull(hb.add_dst_hour, 0) = 18 THEN 2 ELSE 1 END AS NUMERIC(1, 0)) AS NUMERIC(22, 10))) /

cast(nullif(isnull(term_hrs.term_no_hrs, term_hrs_exp.term_no_hrs), 0) AS NUMERIC(8, 0)) * (CASE WHEN (hb.term_date) > = CAST(YEAR(DATEADD(m, 1, ''@as_of_date'')) AS VARCHAR) + ''-'' + CAST(MONTH(DATEADD(m, 1, ''@as_of_date'')) AS VARCHAR) + ''-01'' THEN ISNULL(remain_month.remain_days / CAST(remain_month.total_days AS FLOAT), 1) ELSE 1 END) [18]

	,(cast(cast(cast(s.calc_volume AS NUMERIC(22, 10)) * cast(isnull(hb.hr19, 0) AS NUMERIC(1, 0)) AS NUMERIC(22, 10)) * cast(CASE WHEN isnull(hb.add_dst_hour, 0) = 19 THEN 2 ELSE 1 END AS NUMERIC(1, 0)) AS NUMERIC(22, 10))) /

cast(nullif(isnull(term_hrs.term_no_hrs, term_hrs_exp.term_no_hrs), 0) AS NUMERIC(8, 0)) * (CASE WHEN (hb.term_date) > = CAST(YEAR(DATEADD(m, 1, ''@as_of_date'')) AS VARCHAR) + ''-'' + CAST(MONTH(DATEADD(m, 1, ''@as_of_date'')) AS VARCHAR) + ''-01'' THEN ISNULL(remain_month.remain_days / CAST(remain_month.total_days AS FLOAT), 1) ELSE 1 END) [19]

	,(cast(cast(cast(s.calc_volume AS NUMERIC(22, 10)) * cast(isnull(hb.hr20, 0) AS NUMERIC(1, 0)) AS NUMERIC(22, 10)) * cast(CASE WHEN isnull(hb.add_dst_hour, 0) = 20 THEN 2 ELSE 1 END AS NUMERIC(1, 0)) AS NUMERIC(22, 10))) /

cast(nullif(isnull(term_hrs.term_no_hrs, term_hrs_exp.term_no_hrs), 0) AS NUMERIC(8, 0)) * (CASE WHEN (hb.term_date) > = CAST(YEAR(DATEADD(m, 1, ''@as_of_date'')) AS VARCHAR) + ''-'' + CAST(MONTH(DATEADD(m, 1, ''@as_of_date'')) AS VARCHAR) + ''-01'' THEN ISNULL(remain_month.remain_days / CAST(remain_month.total_days AS FLOAT), 1) ELSE 1 END) [20]

	,(cast(cast(cast(s.calc_volume AS NUMERIC(22, 10)) * cast(isnull(hb.hr21, 0) AS NUMERIC(1, 0)) AS NUMERIC(22, 10)) * cast(CASE WHEN isnull(hb.add_dst_hour, 0) = 21 THEN 2 ELSE 1 END AS NUMERIC(1, 0)) AS NUMERIC(22, 10))) /

cast(nullif(isnull(term_hrs.term_no_hrs, term_hrs_exp.term_no_hrs), 0) AS NUMERIC(8, 0)) * (CASE WHEN (hb.term_date) > = CAST(YEAR(DATEADD(m, 1, ''@as_of_date'')) AS VARCHAR) + ''-'' + CAST(MONTH(DATEADD(m, 1, ''@as_of_date'')) AS VARCHAR) + ''-01'' THEN ISNULL(remain_month.remain_days / CAST(remain_month.total_days AS FLOAT), 1) ELSE 1 END) [21]

	,(cast(cast(cast(s.calc_volume AS NUMERIC(22, 10)) * cast(isnull(hb.hr22, 0) AS NUMERIC(1, 0)) AS NUMERIC(22, 10)) * cast(CASE WHEN isnull(hb.add_dst_hour, 0) = 22 THEN 2 ELSE 1 END AS NUMERIC(1, 0)) AS NUMERIC(22, 10))) /

cast(nullif(isnull(term_hrs.term_no_hrs, term_hrs_exp.term_no_hrs), 0) AS NUMERIC(8, 0)) * (CASE WHEN (hb.term_date) > = CAST(YEAR(DATEADD(m, 1, ''@as_of_date'')) AS VARCHAR) + ''-'' + CAST(MONTH(DATEADD(m, 1, ''@as_of_date'')) AS VARCHAR) + ''-01'' THEN ISNULL(remain_month.remain_days / CAST(remain_month.total_days AS FLOAT), 1) ELSE 1 END) [22]

	,(cast(cast(cast(s.calc_volume AS NUMERIC(22, 10)) * cast(isnull(hb.hr23, 0) AS NUMERIC(1, 0)) AS NUMERIC(22, 10)) * cast(CASE WHEN isnull(hb.add_dst_hour, 0) = 23 THEN 2 ELSE 1 END AS NUMERIC(1, 0)) AS NUMERIC(22, 10))) /

cast(nullif(isnull(term_hrs.term_no_hrs, term_hrs_exp.term_no_hrs), 0) AS NUMERIC(8, 0)) * (CASE WHEN (hb.term_date) > = CAST(YEAR(DATEADD(m, 1, ''@as_of_date'')) AS VARCHAR) + ''-'' + CAST(MONTH(DATEADD(m, 1, ''@as_of_date'')) AS VARCHAR) + ''-01'' THEN ISNULL(remain_month.remain_days / CAST(remain_month.total_days AS FLOAT), 1) ELSE 1 END) [23]

	,(cast(cast(cast(s.calc_volume AS NUMERIC(22, 10)) * cast(isnull(hb.hr24, 0) AS NUMERIC(1, 0)) AS NUMERIC(22, 10)) * cast(CASE WHEN isnull(hb.add_dst_hour, 0) = 24 THEN 2 ELSE 1 END AS NUMERIC(1, 0)) AS NUMERIC(22, 10))) /

cast(nullif(isnull(term_hrs.term_no_hrs, term_hrs_exp.term_no_hrs), 0) AS NUMERIC(8, 0)) * (CASE WHEN (hb.term_date) > = CAST(YEAR(DATEADD(m, 1, ''@as_of_date'')) AS VARCHAR) + ''-'' + CAST(MONTH(DATEADD(m, 1, ''@as_of_date'')) AS VARCHAR) + ''-01'' THEN ISNULL(remain_month.remain_days / CAST(remain_month.total_days AS FLOAT), 1) ELSE 1 END) [24]

	,(cast(cast(s.calc_volume AS NUMERIC(22, 10)) * cast(CASE WHEN isnull(hb.add_dst_hour, 0) < = 0 THEN 0 ELSE 1 END AS NUMERIC(1, 0)) AS NUMERIC(22, 10))) /

cast(nullif(isnull(term_hrs.term_no_hrs, term_hrs_exp.term_no_hrs), 0) AS NUMERIC(8, 0)) * (CASE WHEN (hb.term_date) > = CAST(YEAR(DATEADD(m, 1, ''@as_of_date'')) AS VARCHAR) + ''-'' + CAST(MONTH(DATEADD(m, 1, ''@as_of_date'')) AS VARCHAR) + ''-01'' THEN ISNULL(remain_month.remain_days / CAST(remain_month.total_days AS FLOAT), 1) ELSE 1 END) [25]

	,

s.source_deal_header_id

	,s.commodity_id

	,s.counterparty_id

	,s.fas_book_id

	,s.source_system_book_id1

	,s.source_system_book_id2

	,s.source_system_book_id3

	,s.source_system_book_id4

	,CASE WHEN s.formula IN (

				''dbo.FNACurveH''

				,''dbo.FNACurveD''

				) THEN ISNULL(hg.exp_date, hb.term_date) WHEN ISNULL(spcd.hourly_volume_allocation, 17601) IN (

				17603

				,17604

				) THEN ISNULL(hg.exp_date, s.expiration_date) ELSE s.expiration_date END expiration_date

	,''y'' AS is_fixedvolume

	,deal_status_id

INTO #temp_hourly_position_breakdown

FROM report_hourly_position_breakdown s(NOLOCK)

INNER JOIN #books bk ON bk.fas_book_id = s.fas_book_id

	--AND s.source_deal_header_id IN (157950)	

	AND bk.source_system_book_id1 = s.source_system_book_id1 AND bk.source_system_book_id2 = s.source_system_book_id2 AND bk.source_system_book_id3 = s.source_system_book_id3 AND bk.source_system_book_id4 = s.source_system_book_id4

INNER JOIN [deal_status_group] dsg ON dsg.status_value_id = s.deal_status_id

LEFT JOIN source_price_curve_def spcd WITH (NOLOCK) ON spcd.source_curve_def_id = s.curve_id

LEFT JOIN source_price_curve_def spcd_proxy(NOLOCK) ON spcd_proxy.source_curve_def_id = spcd.settlement_curve_id

OUTER APPLY (

	SELECT TOP 1 *

	FROM vwDealTimezone vw

	WHERE vw.source_deal_header_id = s.source_deal_header_id

	) tz

OUTER APPLY (

	SELECT sum(volume_mult) term_no_hrs

	FROM hour_block_term hbt

	WHERE isnull(spcd.hourly_volume_allocation, 17601) < 17603 AND hbt.block_define_id = COALESCE(spcd.block_define_id, 300501) AND hbt.block_type = COALESCE(spcd.block_type, 12000) AND hbt.term_date BETWEEN s.term_start

			AND s.term_END AND hbt.dst_group_value_id = tz.dst_group_value_id

	)

term_hrs

OUTER APPLY (

	SELECT sum(volume_mult) term_no_hrs

	FROM hour_block_term hbt

	INNER JOIN (

		SELECT DISTINCT exp_date

		FROM holiday_group h

		WHERE h.hol_group_value_id = ISNULL(spcd.exp_calendar_id, spcd_proxy.exp_calendar_id) AND h.exp_date BETWEEN s.term_start

				AND s.term_END

		) ex ON ex.exp_date = hbt.term_date

	WHERE isnull(spcd.hourly_volume_allocation, 17601) IN (

			17603

			,17604

			) AND hbt.block_define_id = COALESCE(spcd.block_define_id, 300501) AND hbt.block_type = COALESCE(spcd.block_type, 12000) AND hbt.term_date BETWEEN s.term_start

			AND s.term_END AND hbt.dst_group_value_id = tz.dst_group_value_id

	) term_hrs_exp

LEFT JOIN #term_date hb ON hb.block_define_id = isnull(spcd.block_define_id, 300501) AND hb.term_start = s.term_start AND hb.term_end = s.term_end --and hb.term_date>''@as_of_date''

OUTER APPLY (

	SELECT MAX(exp_date) exp_date

	FROM holiday_group h

	WHERE h.hol_date = hb.term_date AND h.hol_group_value_id = ISNULL(spcd.exp_calendar_id, spcd_proxy.exp_calendar_id) AND h.hol_date BETWEEN s.term_start

			AND s.term_END AND COALESCE(spcd_proxy.ratio_option, spcd.ratio_option, - 1) < > 18800

	)

hg

OUTER APPLY (

	SELECT MIN(exp_date) hol_date

		,MAX(exp_date) hol_date_to

	FROM holiday_group h

	WHERE 1 = 1 AND h.hol_group_value_id = ISNULL(spcd.exp_calendar_id, spcd_proxy.exp_calendar_id) AND h.hol_date BETWEEN s.term_start

			AND s.term_END AND s.formula NOT IN (''REBD'')

	) hg1

OUTER APPLY (

	SELECT count(exp_date) total_days

		,SUM(CASE WHEN h.exp_date > ''@as_of_date'' THEN 1 ELSE 0 END) remain_days

	FROM holiday_group h

	WHERE h.hol_group_value_id = ISNULL(spcd.exp_calendar_id, spcd_proxy.exp_calendar_id) AND h.exp_date BETWEEN hg1.hol_date

			AND ISNULL(hg1.hol_date_to, dbo.FNALastDayInDate(hg1.hol_date)) AND ISNULL(spcd_proxy.ratio_option, spcd.ratio_option) = 18800 AND s.formula NOT IN (''REBD'')

	)

remain_month

WHERE ((ISNULL(spcd_proxy.ratio_option, spcd.ratio_option) = 18800 AND ISNULL(hg1.hol_date_to, ''9999-01-01'') > ''@as_of_date'') OR COALESCE(spcd_proxy.ratio_option, spcd.ratio_option, - 1) < > 18800) AND (

		(

			isnull(spcd.hourly_volume_allocation, 17601) IN (

				17603

				,17604

				) AND hg.exp_date IS NOT NULL

			) OR (isnull(spcd.hourly_volume_allocation, 17601) < 17603)

		)

	--AND s.source_deal_header_id IN (157950) 

	AND s.deal_date < = ''@as_of_date''

-- hourly position breakdown end

CREATE INDEX indxterm_dat ON #term_date (

	block_define_id

	,term_start

	,term_end

	)

IF OBJECT_ID(N''tempdb..#temp_position_table'') IS NOT NULL

	DROP TABLE #temp_position_table

SELECT *

INTO #temp_position_table

FROM (

	SELECT *

	FROM #temp_hourly_position_deal

	UNION ALL

	SELECT *

	FROM #temp_hourly_position_profile

	UNION ALL

	SELECT *

	FROM #temp_hourly_position_breakdown

	) pos

--SELECT * FROM  #temp_position_table

IF OBJECT_ID(N''tempdb..#temp_hourly_position'') IS NOT NULL

	DROP TABLE #temp_hourly_position

IF OBJECT_ID (''tempdb..#final_table'') IS NOT NULL

	DROP TABLE #final_table

SELECT CAST(''@as_of_date'' AS DATETIME) as_of_date

	,MAX(sub.entity_id) sub_id

	,MAX(stra.entity_id) stra_id

	,MAX(book.entity_id) book_id

	,MAX(sub.entity_name) sub

	,MAX(stra.entity_name) strategy

	,MAX(book.entity_name) book

	,ssbm.book_deal_type_map_id [sub_book_id]

	,vw.source_deal_header_id

	,MAX(sdh.deal_id) deal_id

	,(CASE WHEN vw.physical_financial_flag = ''p'' THEN ''Physical'' ELSE ''Financial'' END) physical_financial_flag

	,MAX(vw.deal_date) deal_date

	,ISNULL(sml.Location_Name, spcd.curve_name) location

	,spcd.curve_name [curve_name]

	,MAX(spcd_proxy.curve_name) proxy_index

	,MAX(sdv2.code) region

	,MAX(sdv.code) country

	,MAX(sdv1.code) grid

	,MAX(mjr.location_name) location_group

	,com.commodity_name commodity

	,com.commodity_id commodity_id

	,MAX(sc.counterparty_name) counterparty_name

	,MAX(sc.counterparty_name) parent_counterparty

	,MAX(CONVERT(VARCHAR(7), vw.term_start, 120)) term_year_month

	,MAX(vw.term_start) term_start

	,MAX(sb1.source_book_name) book_identifier1

	,MAX(sb2.source_book_name) book_identifier2

	,MAX(sb3.source_book_name) book_identifier3

	,MAX(sb4.source_book_name) book_identifier4

	,MAX(ssbm.logical_name) AS sub_book

	,SUM(vw.[01] + vw.[02] + vw.[03] + vw.[04] + vw.[05] + vw.[06] + vw.[07] + vw.[08] + vw.[09] + vw.[10] + vw.[11] + vw.[12] + vw.[13] + vw.[14] + vw.[15] + vw.[16] + vw.[17] + vw.[18] + vw.[19] + vw.[20] + vw.[21] + vw.[22] + vw.[23] + vw.[24]) [position]

	,SUM((vw.[01] + vw.[02] + vw.[03] + vw.[04] + vw.[05] + vw.[06] + vw.[07] + vw.[08] + vw.[09] + vw.[10] + vw.[11] + vw.[12] + vw.[13] + vw.[14] + vw.[15] + vw.[16] + vw.[17] + vw.[18] + vw.[19] + vw.[20] + vw.[21] + vw.[22] + vw.[23] + vw.[24]) * ISNULL((CASE WHEN ISNULL(sdd.leg, - 1) = 1 THEN ABS(DELTA) WHEN ISNULL(sdd.leg, - 1) = 2 THEN ABS(DELTA2) ELSE 1 END), 1) * CASE WHEN ISNULL(sdh.option_type, ''c'') = ''p'' THEN - 1 ELSE 1 END) [delta_position]

	,Max(sdd.total_volume) total_volume

	,Max((sdd.total_volume) * ISNULL((CASE WHEN ISNULL(sdd.leg, - 1) = 1 THEN ABS(DELTA) WHEN ISNULL(sdd.leg, - 1) = 2 THEN ABS(DELTA2) ELSE 1 END), 1) * CASE WHEN ISNULL(sdh.option_type, ''c'') = ''p'' THEN - 1 ELSE 1 END) [delta_pos]

	,MAX(su.uom_name) uom

	,MAX(CASE WHEN ISNULL(sdd.leg, - 1) = 1 THEN DELTA WHEN ISNULL(sdd.leg, - 1) = 2 THEN DELTA2 ELSE 0 END) [delta]

	,MAX(sdt.source_deal_type_id) [deal_type_id]

	,MAX(sdt.source_deal_type_name) [deal_type]

	,MAX(sdh.deal_status) [deal_status]

INTO #final_table

FROM #temp_position_table vw

LEFT JOIN source_minor_location sml ON sml.source_minor_location_id = vw.location_id

INNER JOIN source_price_curve_def spcd ON spcd.source_curve_def_id = vw.curve_id

LEFT JOIN source_price_curve_def spcd_proxy ON spcd_proxy.source_curve_def_id = spcd.proxy_curve_id

LEFT JOIN static_data_value sdv1 ON sdv1.value_id = sml.grid_value_id

LEFT JOIN static_data_value sdv ON sdv.value_id = sml.country

LEFT JOIN static_data_value sdv2 ON sdv2.value_id = sml.region

LEFT JOIN source_major_location mjr ON sml.source_major_location_ID = mjr.source_major_location_ID

LEFT JOIN source_uom AS su ON su.source_uom_id = ISNULL(spcd.display_uom_id, spcd.uom_id)

LEFT JOIN source_counterparty sc ON sc.source_counterparty_id = vw.counterparty_id

LEFT JOIN source_counterparty psc ON psc.source_counterparty_id = sc.parent_counterparty_id

LEFT JOIN source_commodity com ON com.source_commodity_id = spcd.commodity_id

LEFT JOIN portfolio_hierarchy book ON book.entity_id = vw.fas_book_id

LEFT JOIN portfolio_hierarchy stra ON stra.entity_id = book.parent_entity_id

LEFT JOIN portfolio_hierarchy sub ON sub.entity_id = stra.parent_entity_id

INNER JOIN source_deal_header sdh ON sdh.source_deal_header_id = vw.source_deal_header_id

INNER JOIN source_deal_detail sdd ON sdd.source_deal_header_id = vw.source_deal_header_id AND sdd.curve_id = vw.curve_id AND vw.term_start BETWEEN sdd.term_start

		AND sdd.term_end

--LEFT JOIN deal_status_group dsg ON dsg.status_value_id = vw.deal_status_id

LEFT JOIN source_system_book_map ssbm ON ssbm.source_system_book_id1 = vw.source_system_book_id1 AND ssbm.source_system_book_id2 = vw.source_system_book_id2 AND ssbm.source_system_book_id3 = vw.source_system_book_id3 AND ssbm.source_system_book_id4 = vw.source_system_book_id4

LEFT JOIN source_book sb1 ON sb1.source_book_id = vw.source_system_book_id1

LEFT JOIN source_book sb2 ON sb2.source_book_id = vw.source_system_book_id2

LEFT JOIN source_book sb3 ON sb3.source_book_id = vw.source_system_book_id3

LEFT JOIN source_book sb4 ON sb4.source_book_id = vw.source_system_book_id4

LEFT JOIN source_deal_type sdt ON sdt.source_deal_type_id = sdh.source_deal_type_id

OUTER APPLY (

	SELECT TOP (1) deal_volume

		,deal_volume2

		,delta

		,delta2

	FROM source_deal_pnl_detail_options

	WHERE as_of_date = ''@as_of_date'' AND source_deal_header_id = sdh.source_deal_header_id AND term_start = CASE WHEN ISNULL(sdh.internal_deal_subtype_value_id, 1) = 101 THEN term_start ELSE sdd.term_start END

	) sdpdo

WHERE vw.expiration_date > ''@as_of_date'' AND vw.term_start > ''@as_of_date''

--sdh.source_deal_header_id = 60

GROUP BY com.commodity_name

	,vw.physical_financial_flag

	,ISNULL(sml.Location_Name, spcd.curve_name)

	,spcd.curve_name

	,YEAR(vw.term_start)

	,MONTH(vw.term_start)

	,vw.source_deal_header_id

	,com.commodity_id

	,ssbm.book_deal_type_map_id

	--aggregate data in monthly level

SET @_final_sql = '' SELECT *, ''''''+ ISNULL(@_deal_status_group, '''') + '''''' [deal_status_group]

	--[__batch_report__]

	FROM #final_table sdh''

	+ CASE WHEN @_deal_status_group = ''o'' THEN

	'' INNER JOIN deal_status_group dsg ON dsg.status_value_id = sdh.deal_status ''

	WHEN @_deal_status_group = ''u'' THEN

	'' INNER JOIN (SELECT value_id FROM static_data_value WHERE type_id = 5600 EXCEPT SELECT status_value_id FROM deal_status_group) unofficial_status ON unofficial_status.value_id = sdh.deal_status ''

	ELSE

	''''

	END

	+ '' WHERE 1=1 ''

	+ CASE WHEN @_commodity_id IS NOT NULL THEN '' AND sdh.commodity_id IN ('''''' + @_commodity_id + '''''')'' ELSE '''' END

	+ CASE WHEN @_deal_type_id IS NOT NULL THEN '' AND sdh.deal_type_id IN ('' + @_deal_type_id + '')'' ELSE '''' END

--PRINT(@_final_sql)

EXEC(@_final_sql)', report_id = @report_id_data_source_dest,
	system_defined = '1'
	,category = '106500' 
	WHERE [name] = 'Delta Monthly Position View'
		AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1)
		
	
	IF OBJECT_ID('tempdb..#data_source_column', 'U') IS NOT NULL
		DROP TABLE #data_source_column	
	CREATE TABLE #data_source_column(column_id INT)	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Delta Monthly Position View'
	            AND dsc.name =  'as_of_date'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'As of Date'
			   , reqd_param = 1, widget_id = 6, datatype_id = 2, param_data_source = NULL, param_default_value = NULL, append_filter = 0, tooltip = NULL, column_template = 4, key_column = 1, required_filter = 1
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Delta Monthly Position View'
			AND dsc.name =  'as_of_date'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'as_of_date' AS [name], 'As of Date' AS ALIAS, 1 AS reqd_param, 6 AS widget_id, 2 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 0 AS append_filter, NULL  AS tooltip,4 AS column_template, 1 AS key_column, 1 AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Delta Monthly Position View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Delta Monthly Position View'
	            AND dsc.name =  'book'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Book'
			   , reqd_param = 0, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Delta Monthly Position View'
			AND dsc.name =  'book'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'book' AS [name], 'Book' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Delta Monthly Position View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Delta Monthly Position View'
	            AND dsc.name =  'book_id'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Book ID'
			   , reqd_param = 1, widget_id = 5, datatype_id = 4, param_data_source = NULL, param_default_value = NULL, append_filter = 0, tooltip = NULL, column_template = 2, key_column = 0, required_filter = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Delta Monthly Position View'
			AND dsc.name =  'book_id'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'book_id' AS [name], 'Book ID' AS ALIAS, 1 AS reqd_param, 5 AS widget_id, 4 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 0 AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column, 0 AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Delta Monthly Position View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Delta Monthly Position View'
	            AND dsc.name =  'book_identifier1'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Book ID1'
			   , reqd_param = 0, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Delta Monthly Position View'
			AND dsc.name =  'book_identifier1'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'book_identifier1' AS [name], 'Book ID1' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Delta Monthly Position View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Delta Monthly Position View'
	            AND dsc.name =  'book_identifier2'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Book ID2'
			   , reqd_param = 0, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Delta Monthly Position View'
			AND dsc.name =  'book_identifier2'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'book_identifier2' AS [name], 'Book ID2' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Delta Monthly Position View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Delta Monthly Position View'
	            AND dsc.name =  'book_identifier3'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Book ID3'
			   , reqd_param = 0, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Delta Monthly Position View'
			AND dsc.name =  'book_identifier3'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'book_identifier3' AS [name], 'Book ID3' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Delta Monthly Position View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Delta Monthly Position View'
	            AND dsc.name =  'book_identifier4'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Book ID4'
			   , reqd_param = 0, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Delta Monthly Position View'
			AND dsc.name =  'book_identifier4'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'book_identifier4' AS [name], 'Book ID4' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Delta Monthly Position View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Delta Monthly Position View'
	            AND dsc.name =  'commodity'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Commodity'
			   , reqd_param = 0, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Delta Monthly Position View'
			AND dsc.name =  'commodity'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'commodity' AS [name], 'Commodity' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Delta Monthly Position View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Delta Monthly Position View'
	            AND dsc.name =  'country'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Country'
			   , reqd_param = 0, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Delta Monthly Position View'
			AND dsc.name =  'country'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'country' AS [name], 'Country' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Delta Monthly Position View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Delta Monthly Position View'
	            AND dsc.name =  'deal_date'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Deal Date'
			   , reqd_param = 0, widget_id = 6, datatype_id = 2, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 4, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Delta Monthly Position View'
			AND dsc.name =  'deal_date'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'deal_date' AS [name], 'Deal Date' AS ALIAS, 0 AS reqd_param, 6 AS widget_id, 2 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,4 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Delta Monthly Position View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Delta Monthly Position View'
	            AND dsc.name =  'deal_id'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Deal Reference ID'
			   , reqd_param = 0, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Delta Monthly Position View'
			AND dsc.name =  'deal_id'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'deal_id' AS [name], 'Deal Reference ID' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Delta Monthly Position View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Delta Monthly Position View'
	            AND dsc.name =  'deal_status'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Deal Status'
			   , reqd_param = 0, widget_id = 1, datatype_id = 4, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 2, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Delta Monthly Position View'
			AND dsc.name =  'deal_status'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'deal_status' AS [name], 'Deal Status' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 4 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Delta Monthly Position View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Delta Monthly Position View'
	            AND dsc.name =  'delta'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Delta'
			   , reqd_param = 0, widget_id = 1, datatype_id = 3, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 2, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Delta Monthly Position View'
			AND dsc.name =  'delta'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'delta' AS [name], 'Delta' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 3 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Delta Monthly Position View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Delta Monthly Position View'
	            AND dsc.name =  'grid'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Grid'
			   , reqd_param = 0, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Delta Monthly Position View'
			AND dsc.name =  'grid'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'grid' AS [name], 'Grid' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Delta Monthly Position View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Delta Monthly Position View'
	            AND dsc.name =  'location'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Location'
			   , reqd_param = 0, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Delta Monthly Position View'
			AND dsc.name =  'location'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'location' AS [name], 'Location' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Delta Monthly Position View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Delta Monthly Position View'
	            AND dsc.name =  'location_group'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Location Group'
			   , reqd_param = 0, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Delta Monthly Position View'
			AND dsc.name =  'location_group'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'location_group' AS [name], 'Location Group' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Delta Monthly Position View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Delta Monthly Position View'
	            AND dsc.name =  'parent_counterparty'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Parent Counterparty'
			   , reqd_param = 0, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Delta Monthly Position View'
			AND dsc.name =  'parent_counterparty'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'parent_counterparty' AS [name], 'Parent Counterparty' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Delta Monthly Position View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Delta Monthly Position View'
	            AND dsc.name =  'physical_financial_flag'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Physical/Financial'
			   , reqd_param = 0, widget_id = 2, datatype_id = 5, param_data_source = 'SELECT ''Physical'' [ID],''Physical'' [name]' + CHAR(10) + 'UNION  ' + CHAR(10) + 'SELECT ' + CHAR(10) + '''Financial'',''Financial''', param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Delta Monthly Position View'
			AND dsc.name =  'physical_financial_flag'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'physical_financial_flag' AS [name], 'Physical/Financial' AS ALIAS, 0 AS reqd_param, 2 AS widget_id, 5 AS datatype_id, 'SELECT ''Physical'' [ID],''Physical'' [name]' + CHAR(10) + 'UNION  ' + CHAR(10) + 'SELECT ' + CHAR(10) + '''Financial'',''Financial''' AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Delta Monthly Position View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Delta Monthly Position View'
	            AND dsc.name =  'position'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Position'
			   , reqd_param = 0, widget_id = 1, datatype_id = 3, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 2, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Delta Monthly Position View'
			AND dsc.name =  'position'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'position' AS [name], 'Position' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 3 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Delta Monthly Position View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Delta Monthly Position View'
	            AND dsc.name =  'proxy_index'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Proxy Index'
			   , reqd_param = 0, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Delta Monthly Position View'
			AND dsc.name =  'proxy_index'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'proxy_index' AS [name], 'Proxy Index' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Delta Monthly Position View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Delta Monthly Position View'
	            AND dsc.name =  'region'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Region'
			   , reqd_param = 0, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Delta Monthly Position View'
			AND dsc.name =  'region'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'region' AS [name], 'Region' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Delta Monthly Position View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Delta Monthly Position View'
	            AND dsc.name =  'source_deal_header_id'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Deal ID'
			   , reqd_param = 0, widget_id = 1, datatype_id = 4, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 2, key_column = 1, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Delta Monthly Position View'
			AND dsc.name =  'source_deal_header_id'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'source_deal_header_id' AS [name], 'Deal ID' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 4 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,2 AS column_template, 1 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Delta Monthly Position View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Delta Monthly Position View'
	            AND dsc.name =  'stra_id'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Strategy ID'
			   , reqd_param = 1, widget_id = 4, datatype_id = 4, param_data_source = NULL, param_default_value = NULL, append_filter = 0, tooltip = NULL, column_template = 2, key_column = 0, required_filter = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Delta Monthly Position View'
			AND dsc.name =  'stra_id'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'stra_id' AS [name], 'Strategy ID' AS ALIAS, 1 AS reqd_param, 4 AS widget_id, 4 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 0 AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column, 0 AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Delta Monthly Position View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Delta Monthly Position View'
	            AND dsc.name =  'strategy'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Strategy'
			   , reqd_param = 0, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Delta Monthly Position View'
			AND dsc.name =  'strategy'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'strategy' AS [name], 'Strategy' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Delta Monthly Position View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Delta Monthly Position View'
	            AND dsc.name =  'sub'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Subsidiary'
			   , reqd_param = 0, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Delta Monthly Position View'
			AND dsc.name =  'sub'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'sub' AS [name], 'Subsidiary' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Delta Monthly Position View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Delta Monthly Position View'
	            AND dsc.name =  'sub_id'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Sub ID'
			   , reqd_param = 1, widget_id = 3, datatype_id = 4, param_data_source = NULL, param_default_value = NULL, append_filter = 0, tooltip = NULL, column_template = 2, key_column = 0, required_filter = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Delta Monthly Position View'
			AND dsc.name =  'sub_id'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'sub_id' AS [name], 'Sub ID' AS ALIAS, 1 AS reqd_param, 3 AS widget_id, 4 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 0 AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column, 0 AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Delta Monthly Position View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Delta Monthly Position View'
	            AND dsc.name =  'term_start'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Term Start'
			   , reqd_param = 0, widget_id = 6, datatype_id = 2, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 4, key_column = 1, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Delta Monthly Position View'
			AND dsc.name =  'term_start'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'term_start' AS [name], 'Term Start' AS ALIAS, 0 AS reqd_param, 6 AS widget_id, 2 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,4 AS column_template, 1 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Delta Monthly Position View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Delta Monthly Position View'
	            AND dsc.name =  'term_year_month'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Term Year Month'
			   , reqd_param = 0, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Delta Monthly Position View'
			AND dsc.name =  'term_year_month'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'term_year_month' AS [name], 'Term Year Month' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Delta Monthly Position View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Delta Monthly Position View'
	            AND dsc.name =  'uom'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'UOM'
			   , reqd_param = 0, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Delta Monthly Position View'
			AND dsc.name =  'uom'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'uom' AS [name], 'UOM' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Delta Monthly Position View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Delta Monthly Position View'
	            AND dsc.name =  'deal_type'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Deal Type'
			   , reqd_param = 0, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Delta Monthly Position View'
			AND dsc.name =  'deal_type'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'deal_type' AS [name], 'Deal Type' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Delta Monthly Position View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Delta Monthly Position View'
	            AND dsc.name =  'deal_type_id'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Deal Type ID'
			   , reqd_param = 0, widget_id = 9, datatype_id = 4, param_data_source = 'SELECT  source_deal_type_id,source_deal_type_name' + CHAR(10) + 'FROM       source_deal_type', param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0, required_filter = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Delta Monthly Position View'
			AND dsc.name =  'deal_type_id'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'deal_type_id' AS [name], 'Deal Type ID' AS ALIAS, 0 AS reqd_param, 9 AS widget_id, 4 AS datatype_id, 'SELECT  source_deal_type_id,source_deal_type_name' + CHAR(10) + 'FROM       source_deal_type' AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, 0 AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Delta Monthly Position View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Delta Monthly Position View'
	            AND dsc.name =  'delta_position'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Delta Position'
			   , reqd_param = 0, widget_id = 1, datatype_id = 3, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 2, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Delta Monthly Position View'
			AND dsc.name =  'delta_position'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'delta_position' AS [name], 'Delta Position' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 3 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Delta Monthly Position View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Delta Monthly Position View'
	            AND dsc.name =  'curve_name'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Index'
			   , reqd_param = 0, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Delta Monthly Position View'
			AND dsc.name =  'curve_name'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'curve_name' AS [name], 'Index' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Delta Monthly Position View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Delta Monthly Position View'
	            AND dsc.name =  'counterparty_name'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Counterparty'
			   , reqd_param = 0, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Delta Monthly Position View'
			AND dsc.name =  'counterparty_name'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'counterparty_name' AS [name], 'Counterparty' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Delta Monthly Position View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Delta Monthly Position View'
	            AND dsc.name =  'sub_book'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Sub Book'
			   , reqd_param = 0, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Delta Monthly Position View'
			AND dsc.name =  'sub_book'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'sub_book' AS [name], 'Sub Book' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Delta Monthly Position View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Delta Monthly Position View'
	            AND dsc.name =  'commodity_id'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Commodity Id'
			   , reqd_param = NULL, widget_id = 9, datatype_id = 5, param_data_source = 'select commodity_id [id], commodity_id [name]from source_commodity', param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 0, key_column = 0, required_filter = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Delta Monthly Position View'
			AND dsc.name =  'commodity_id'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'commodity_id' AS [name], 'Commodity Id' AS ALIAS, NULL AS reqd_param, 9 AS widget_id, 5 AS datatype_id, 'select commodity_id [id], commodity_id [name]from source_commodity' AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, 0 AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Delta Monthly Position View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Delta Monthly Position View'
	            AND dsc.name =  'sub_book_id'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Sub Book ID'
			   , reqd_param = NULL, widget_id = 8, datatype_id = 4, param_data_source = NULL, param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 2, key_column = 0, required_filter = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Delta Monthly Position View'
			AND dsc.name =  'sub_book_id'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'sub_book_id' AS [name], 'Sub Book ID' AS ALIAS, NULL AS reqd_param, 8 AS widget_id, 4 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column, 0 AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Delta Monthly Position View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Delta Monthly Position View'
	            AND dsc.name =  'delta_pos'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Delta Pos'
			   , reqd_param = NULL, widget_id = 1, datatype_id = 3, param_data_source = NULL, param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 2, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Delta Monthly Position View'
			AND dsc.name =  'delta_pos'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'delta_pos' AS [name], 'Delta Pos' AS ALIAS, NULL AS reqd_param, 1 AS widget_id, 3 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Delta Monthly Position View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Delta Monthly Position View'
	            AND dsc.name =  'total_volume'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Total Volume'
			   , reqd_param = NULL, widget_id = 1, datatype_id = 3, param_data_source = NULL, param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 2, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Delta Monthly Position View'
			AND dsc.name =  'total_volume'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'total_volume' AS [name], 'Total Volume' AS ALIAS, NULL AS reqd_param, 1 AS widget_id, 3 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Delta Monthly Position View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Delta Monthly Position View'
	            AND dsc.name =  'deal_status_group'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Deal Status Group'
			   , reqd_param = NULL, widget_id = 2, datatype_id = 5, param_data_source = 'SELECT ''a'', ''All'' UNION SELECT ''o'', ''Official'' UNION SELECT ''u'', ''Unofficial''', param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 0, key_column = 0, required_filter = 1
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Delta Monthly Position View'
			AND dsc.name =  'deal_status_group'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'deal_status_group' AS [name], 'Deal Status Group' AS ALIAS, NULL AS reqd_param, 2 AS widget_id, 5 AS datatype_id, 'SELECT ''a'', ''All'' UNION SELECT ''o'', ''Official'' UNION SELECT ''u'', ''Unofficial''' AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, 1 AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Delta Monthly Position View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	DELETE dsc
	FROM data_source_column dsc 
	INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		AND ds.[name] = 'Delta Monthly Position View'
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