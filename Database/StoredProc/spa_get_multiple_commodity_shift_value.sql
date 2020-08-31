
/************************************************************
 * Date: 2016-Mar-23
 * Owner : Shushil Bohara (@sbohara@pioneersolutionsglobal.com)
 * Desc: It returns shift value for multiple scenario 
 ***********************************************************
 */
if OBJECT_ID('spa_get_multiple_commodity_shift_value') is not null
drop proc spa_get_multiple_commodity_shift_value

go

Create proc dbo.spa_get_multiple_commodity_shift_value 
	@as_of_date DATETIME 
	, @sub_id VARCHAR(100)=NULL
	, @strategy_id VARCHAR(100)=NULL
	, @book_id VARCHAR(100)=NULl
	, @source_book_mapping_id VARCHAR (100)=NULL
	, @source_deal_header_id	 varchar(500)=null
	, @term_start DATETIME = null
	, @term_end DATETIME = NULL
	, @delta CHAR(1) = 'n'
	, @process_id VARCHAR(100) = NULL
 
 
 as

 /*
declare @as_of_date DATETIME  ='2014-08-04'
	, @sub_id VARCHAR(100)=NULL
	, @strategy_id VARCHAR(100)=NULL
	, @book_id VARCHAR(100)=NULl
	, @source_book_mapping_id VARCHAR (100)=NULL
	, @source_deal_header_id	 varchar(500)='43878'
	, @term_start DATETIME = null
	, @term_end DATETIME = NULL
	, @delta CHAR(1) = 'n'
	, @process_id VARCHAR(100) = NULL
 
drop table #book	
drop table 	#mv90_dst
drop table 	#deal_header
drop table #deal_detail
drop table #report_hourly_position_breakdown
drop table #report_hourly_position_breakdown_detail
drop table #source_deal_delta_value
drop table #curve_granularity
DROP TABLE #bok
DROP TABLE #total_val
DROP TABLE #tmp_commodity_shift
DROP TABLE #shift_val
DROP TABLE #tmp_final_shift
DROP TABLE #tmp_final_calc

--*/



	
DECLARE @mtm_job VARCHAR(100), @Monte_Carlo_Curve_Source INT, @MTMProcessTableName VARCHAR(200),
	@tbl_name VARCHAR(200), @st_sql NVARCHAR(MAX), @hedge_value VARCHAR(100),@mtm_process VARCHAR(100), 
	@mtm_as_of_date VARCHAR(100), @as_of_date_start DATETIME, @as_of_date_end DATETIME, @curve_date DATETIME,
	@module VARCHAR(100), @source VARCHAR(100), @errorcode VARCHAR(1), @desc VARCHAR(500), @url VARCHAR(500),
	@url_desc VARCHAR(500), @no_of_simulation INT, @call_to NCHAR(1), @DEALDeltaTableName VARCHAR(200) 
	,@tbl_name_pos varchar(250), @tbl_name_spc varchar(128)	  ,@user_id  varchar(128), @final_calc_val VARCHAR(100)
	

IF @process_id IS NULL
	SET @process_id = REPLACE(NEWID(), '-', '_')
		
IF @user_id IS NULL	
	SET @user_id = dbo.fnadbuser()	

SET @tbl_name = dbo.FNAProcessTableName('std_deals', @user_id, @process_id)
		
IF ISNULL(@tbl_name_pos,'')=''
	SET @tbl_name_pos = dbo.FNAProcessTableName('tbl_name_pos', @user_id, @process_id)
	
IF ISNULL(@final_calc_val,'')=''	
SELECT @final_calc_val = dbo.FNAProcessTableName('final_calc_val', @user_id, @process_id)	

IF OBJECT_ID(@tbl_name) IS NOT NULL EXEC ('DROP TABLE ' + @tbl_name)
IF OBJECT_ID(@tbl_name_pos) IS NOT NULL EXEC ('DROP TABLE ' + @tbl_name_pos)
	
select clm1_value curve_id,clm2_value granularity_id INTO  #curve_granularity from generic_mapping_values g 
	inner join generic_mapping_header h on g.mapping_table_id=h.mapping_table_id
	 and h.mapping_name= 'curve granularity' --and clm1_value='y'
 		
CREATE TABLE #book
(
	book_id                 INT,
	book_deal_type_map_id   INT,
	source_system_book_id1  INT,
	source_system_book_id2  INT,
	source_system_book_id3  INT,
	source_system_book_id4  INT,
	func_cur_id             INT
)
	
SET @st_sql='
	INSERT INTO #book (
		book_id,
		book_deal_type_map_id,
		source_system_book_id1,
		source_system_book_id2,
		source_system_book_id3,
		source_system_book_id4,
		func_cur_id 
		)		
	SELECT
		book.entity_id,
		book_deal_type_map_id,
		source_system_book_id1,
		source_system_book_id2,
		source_system_book_id3,
		source_system_book_id4,
		fs.func_cur_value_id
	FROM source_system_book_map sbm            
		INNER JOIN portfolio_hierarchy book (NOLOCK) ON book.entity_id = sbm.fas_book_id
		INNER JOIN Portfolio_hierarchy stra (NOLOCK) ON book.parent_entity_id = stra.entity_id 
		INNER JOIN Portfolio_hierarchy sb (NOLOCK) ON stra.parent_entity_id = sb.entity_id 
		LEFT JOIN fas_subsidiaries fs ON  sb.entity_id = fs.fas_subsidiary_id
	WHERE 1=1  '
	+CASE WHEN  @sub_id IS NULL THEN '' ELSE ' AND sb.entity_id IN (' + @sub_id + ')' END
	+CASE WHEN  @strategy_id IS NULL THEN '' ELSE ' AND stra.entity_id IN (' + @strategy_id + ')' END
	+CASE WHEN  @book_id IS NULL THEN '' ELSE ' AND book.entity_id IN (' + @book_id + ')' END
	+CASE WHEN  @source_book_mapping_id IS NULL THEN '' ELSE ' AND sbm.book_deal_type_map_id IN (' + @source_book_mapping_id + ')' END

					
exec spa_print @st_sql	
EXEC(@st_sql  )
		
--Collecting deal from Different Sources
SET @st_sql='
	SELECT 
		DISTINCT sdh.source_deal_header_id,
		''y''	real_deal
	into ' + @tbl_name + '
	FROM source_deal_header sdh 
	INNER JOIN #book sbm ON sdh.source_system_book_id1 = sbm.source_system_book_id1 
		AND sdh.source_system_book_id2 = sbm.source_system_book_id2 
		AND sdh.source_system_book_id3 = sbm.source_system_book_id3 
		AND sdh.source_system_book_id4 = sbm.source_system_book_id4 
		AND sdh.deal_date <= ''' + CONVERT(VARCHAR(10), @as_of_date, 120) + '''
		AND sdh.entire_term_end >= ''' + CONVERT(VARCHAR(10), @as_of_date, 120) + '''
		AND sdh.source_deal_header_id IN (' + @source_deal_header_id + ')'
				
	exec spa_print @st_sql
	EXEC(@st_sql)
	

	
SELECT source_commodity_id,
		[year],
		CASE WHEN (source_commodity_id = -1) THEN DATEADD(DAY, -1, [date])
			ELSE [date]
		END [date],
		CASE WHEN (source_commodity_id = -1) THEN 21
			ELSE [hour]
		END [hour],
		[date] [fin_date],
		[hour] [fin_hour]
		INTO #mv90_dst
FROM   mv90_dst dst
		CROSS JOIN source_commodity
WHERE  insert_delete = 'i'
	OPTION (MAXDOP 1000, MAXRECURSION 32767)
		
--new approach block start
DECLARE @baseload_block_type       VARCHAR(10)
DECLARE @baseload_block_define_id  VARCHAR(10)--,@orginal_summary_option CHAR(1)
DECLARE @position_detail  VARCHAR(150)
DECLARE @st1 VARCHAR(MAX), @st2 VARCHAR(MAX), @st3 VARCHAR(MAX),@st4 VARCHAR(MAX)
DECLARE @deal_level VARCHAR(1)
		
SET  @position_detail = dbo.FNAProcessTableName('explain_position_detail', @user_id, @process_id)
		
IF OBJECT_ID(@position_detail) IS NOT NULL EXEC ('DROP TABLE ' + @position_detail)		
		
SET @baseload_block_type = '12000'	-- Internal Static Data
SELECT @baseload_block_define_id = CAST(value_id AS VARCHAR(10)) FROM  static_data_value WHERE [TYPE_ID] = 10018 AND code LIKE 'Base Load' -- External Static Data

IF @baseload_block_define_id IS NULL
	SET @baseload_block_define_id = 'NULL'

CREATE TABLE #deal_header
(
	book_id                 INT,
	source_deal_header_id   INT,
	create_ts               DATETIME,
	deal_id                 VARCHAR(150) COLLATE DATABASE_DEFAULT,
	source_system_book_id1  INT,
	source_system_book_id2  INT,
	source_system_book_id3  INT,
	source_system_book_id4  INT,
	book_deal_type_map_id   INT,
	broker_id               INT,
	profile_id              INT,
	deal_type_id            INT,
	trader_id               INT,
	contract_id             INT,
	product_id              INT,
	template_id             INT,
	deal_status_id          INT,
	counterparty_id         INT,
	pricing         INT
)

CREATE TABLE #deal_detail
(
	source_deal_detail_id     INT,
	source_deal_header_id     INT,
	term_start                date,
	term_end                  date,
	curve_id                  INT,
	location_id               INT,
	fixed_price               FLOAT,
	leg                       INT,
	index_id                  INT,
	pvparty_id                INT,
	uom_id                    INT,
	physical_financial_flag   VARCHAR(1) COLLATE DATABASE_DEFAULT,
	buy_sell_Flag             VARCHAR(1) COLLATE DATABASE_DEFAULT,
	Category_id               INT,
	user_toublock_id          INT,
	toublock_id               INT,
	create_ts                 DATETIME,
	deal_volume               NUMERIC(38, 20),
	fixed_cost                FLOAT,
	contract_expiration_date  DATETIME,
	commodity_id              INT,
	price_multiplier          FLOAT,
	formula_curve_id          INT
)

SET @st_sql = '
INSERT INTO #deal_header
	(
	book_id,
	source_deal_header_id,
	create_ts,
	deal_id,
	source_system_book_id1,
	source_system_book_id2,
	source_system_book_id3,
	source_system_book_id4,
	book_deal_type_map_id,
	broker_id,
	profile_id,
	deal_type_id,
	trader_id,
	contract_id,
	product_id,
	template_id,
	deal_status_id,
	counterparty_id,
	pricing
	)
SELECT ssbm.fas_book_id,
		s.source_deal_header_id,
		s.create_ts,
		deal_id,
		s.source_system_book_id1,
		s.source_system_book_id2,
		s.source_system_book_id3,
		s.source_system_book_id4,
		ssbm.book_deal_type_map_id,
		s.broker_id,
		s.internal_desk_id profile_id,
		s.source_deal_type_id deal_type_id,
		s.trader_id,
		s.contract_id,
		s.product_id,
		s.template_id,
		s.deal_status deal_status_id,
		s.counterparty_id ,
		s.Pricing
FROM   source_deal_header s(NOLOCK)
		INNER JOIN ' + @tbl_name + ' t
			ON  s.source_deal_header_id = t.source_deal_header_id
		LEFT JOIN source_system_book_map ssbm
			ON  s.source_system_book_id1 = ssbm.source_system_book_id1
			AND s.source_system_book_id2 = ssbm.source_system_book_id2
			AND s.source_system_book_id3 = ssbm.source_system_book_id3
			AND s.source_system_book_id4 = ssbm.source_system_book_id4
'
exec spa_print @st_sql		
EXEC(@st_sql)

SET @st_sql = '
INSERT INTO #deal_detail
	(
	source_deal_detail_id,
	source_deal_header_id,
	term_start,
	term_end,
	curve_id,
	location_id,
	fixed_price,
	leg,
	index_id,
	pvparty_id,
	uom_id,
	physical_financial_flag,
	buy_sell_Flag,
	Category_id,
	user_toublock_id,
	toublock_id,
	create_ts,
	deal_volume,
	fixed_cost,
	contract_expiration_date,
	commodity_id,
	price_multiplier,
	formula_curve_id
	)
SELECT s.source_deal_detail_id,
		s.source_deal_header_id,
		s.term_start,
		s.term_end,
		s.curve_id,
		ISNULL(s.location_id, -1) location_id,
		s.fixed_price,
		s.leg,
		spcd.source_curve_def_id index_id,
		s.pv_party pvparty_id,
		ISNULL(spcd.display_uom_id, spcd.uom_id) uom_id,
		s.physical_financial_flag,
		s.buy_sell_flag,
		s.Category Category_id,
		ISNULL(spcd1.udf_block_group_id, spcd.udf_block_group_id) 
		user_toublock_id,
		ISNULL(spcd1.block_define_id, spcd.block_define_id) toublock_id,
		s.create_ts,
		s.deal_volume,
		s.fixed_cost,
		s.contract_expiration_date,
		spcd.commodity_id commodity_id,
		ISNULL(s.price_multiplier, 1) * ISNULL(dpbd.simple_for_multiplier, 1) 
		price_multiplier,
		s.formula_curve_id
FROM   source_deal_detail s(NOLOCK)
	INNER JOIN ' + @tbl_name + ' t
			ON  s.source_deal_header_id = t.source_deal_header_id
	'+case when @term_start is not null then ' and s.term_start>='''+convert(varchar(10),@term_start,120)+'''' else '' end
	+case when @term_end is not null then ' and s.term_end<='''+convert(varchar(10),@term_end,120) +'''' else '' end+'
	INNER JOIN source_price_curve_def spcd(NOLOCK)
		ON  spcd.source_curve_def_id = s.curve_id
	LEFT JOIN source_price_curve_def spcd1(NOLOCK)
		ON  spcd1.source_curve_def_id = spcd.proxy_curve_id
	OUTER APPLY(
		SELECT TOP(1) simple_for_multiplier
		FROM   deal_position_break_down
		WHERE  source_deal_detail_id = s.source_deal_detail_id
	) dpbd
'

exec spa_print @st_sql
EXEC(@st_sql)

CREATE  INDEX indx_deal_detail_aaa ON #deal_detail( source_deal_header_id,curve_id,location_id,term_start ,term_end)
CREATE INDEX indx_deal_header_aaa ON #deal_header( source_deal_header_id)
CREATE CLUSTERED INDEX indx_deal_detail_aaaxx ON #deal_detail( source_deal_detail_id)
		

SELECT rowid = IDENTITY(INT, 1, 1),
		u.[curve_id],
		u.[term_start],
		u.expiration_date,
		u.deal_volume_uom_id,
		sdh.book_id,
		MAX(ISNULL(spcd1.udf_block_group_id, spcd.udf_block_group_id)) 
		[user_toublock_id],
		MAX(ISNULL(spcd1.block_define_id, spcd.block_define_id)) [toublock_id],
		MAX(u.formula) formula,
		u.term_end,
		SUM(u.calc_volume) calc_volume,
		u.counterparty_id,
		u.commodity_id,
		u.physical_financial_flag,
		sdh.book_deal_type_map_id,
		CAST(CASE WHEN @deal_level = 'y' THEN sdh.[source_deal_header_id]
					ELSE NULL
			END AS INT
		) [source_deal_header_id]
		INTO #report_hourly_position_breakdown
FROM   report_hourly_position_breakdown u(NOLOCK)
		INNER JOIN [deal_status_group] dsg
			ON  dsg.status_value_id = u.deal_status_id -- AND u.deal_date<=@as_of_date
		INNER JOIN #deal_header sdh
			ON  u.source_deal_header_id = sdh.source_deal_header_id -- AND ISNULL(sdh.product_id,4101)<>4100 
		LEFT JOIN source_price_curve_def spcd(NOLOCK)
			ON  spcd.source_curve_def_id = u.curve_id
		LEFT JOIN source_price_curve_def spcd1(NOLOCK)
			ON  spcd1.source_curve_def_id = spcd.proxy_curve_id
GROUP BY
		u.[curve_id],
		u.[term_start],
		u.expiration_date,
		u.deal_volume_uom_id,
		sdh.book_id,
		u.term_end,
		u.counterparty_id,
		u.commodity_id,
		u.physical_financial_flag,
		sdh.book_deal_type_map_id,
		CAST(CASE WHEN @deal_level = 'y' THEN sdh.[source_deal_header_id]
					ELSE NULL
			END AS INT
		)
		OPTION (MAXDOP 1000, MAXRECURSION 32767)

SELECT s.rowid,CAST(hb.term_date AS DATE) term_start
	,(CAST(CAST(CAST(s.calc_volume AS NUMERIC(22,10))* CAST(ISNULL(hb.hr1,0) AS NUMERIC(1,0)) AS NUMERIC(22,10))*CAST(CASE WHEN ISNULL(hb.add_dst_hour,0)=1 THEN 2 ELSE 1 END AS NUMERIC(1,0)) AS NUMERIC(22,10)))/CAST(NULLIF(ISNULL(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) AS NUMERIC(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,@as_of_date)) AS VARCHAR)+'-'+CAST(MONTH(DATEADD(m,1,@as_of_date)) AS VARCHAR)+'-01' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  AS Hr1
	,(CAST(CAST(CAST(s.calc_volume AS NUMERIC(22,10))* CAST(ISNULL(hb.hr2,0) AS NUMERIC(1,0)) AS NUMERIC(22,10))*CAST(CASE WHEN ISNULL(hb.add_dst_hour,0)=2 THEN 2 ELSE 1 END AS NUMERIC(1,0)) AS NUMERIC(22,10)))/CAST(NULLIF(ISNULL(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) AS NUMERIC(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,@as_of_date)) AS VARCHAR)+'-'+CAST(MONTH(DATEADD(m,1,@as_of_date)) AS VARCHAR)+'-01' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  AS Hr2
	,(CAST(CAST(CAST(s.calc_volume AS NUMERIC(22,10))* CAST(ISNULL(hb.hr3,0) AS NUMERIC(1,0)) AS NUMERIC(22,10))*CAST(CASE WHEN ISNULL(hb.add_dst_hour,0)=3 THEN 2 ELSE 1 END AS NUMERIC(1,0)) AS NUMERIC(22,10)))/CAST(NULLIF(ISNULL(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) AS NUMERIC(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,@as_of_date)) AS VARCHAR)+'-'+CAST(MONTH(DATEADD(m,1,@as_of_date)) AS VARCHAR)+'-01' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  AS Hr3
	,(CAST(CAST(CAST(s.calc_volume AS NUMERIC(22,10))* CAST(ISNULL(hb.hr4,0) AS NUMERIC(1,0)) AS NUMERIC(22,10))*CAST(CASE WHEN ISNULL(hb.add_dst_hour,0)=4 THEN 2 ELSE 1 END AS NUMERIC(1,0)) AS NUMERIC(22,10)))/CAST(NULLIF(ISNULL(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) AS NUMERIC(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,@as_of_date)) AS VARCHAR)+'-'+CAST(MONTH(DATEADD(m,1,@as_of_date)) AS VARCHAR)+'-01' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  AS Hr4
	,(CAST(CAST(CAST(s.calc_volume AS NUMERIC(22,10))* CAST(ISNULL(hb.hr5,0) AS NUMERIC(1,0)) AS NUMERIC(22,10))*CAST(CASE WHEN ISNULL(hb.add_dst_hour,0)=5 THEN 2 ELSE 1 END AS NUMERIC(1,0)) AS NUMERIC(22,10)))/CAST(NULLIF(ISNULL(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) AS NUMERIC(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,@as_of_date)) AS VARCHAR)+'-'+CAST(MONTH(DATEADD(m,1,@as_of_date)) AS VARCHAR)+'-01' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  AS Hr5
	,(CAST(CAST(CAST(s.calc_volume AS NUMERIC(22,10))* CAST(ISNULL(hb.hr6,0) AS NUMERIC(1,0)) AS NUMERIC(22,10))*CAST(CASE WHEN ISNULL(hb.add_dst_hour,0)=6 THEN 2 ELSE 1 END AS NUMERIC(1,0)) AS NUMERIC(22,10)))/CAST(NULLIF(ISNULL(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) AS NUMERIC(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,@as_of_date)) AS VARCHAR)+'-'+CAST(MONTH(DATEADD(m,1,@as_of_date)) AS VARCHAR)+'-01' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  AS Hr6
	,(CAST(CAST(CAST(s.calc_volume AS NUMERIC(22,10))* CAST(ISNULL(hb.hr7,0) AS NUMERIC(1,0)) AS NUMERIC(22,10))*CAST(CASE WHEN ISNULL(hb.add_dst_hour,0)=7 THEN 2 ELSE 1 END AS NUMERIC(1,0)) AS NUMERIC(22,10)))/CAST(NULLIF(ISNULL(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) AS NUMERIC(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,@as_of_date)) AS VARCHAR)+'-'+CAST(MONTH(DATEADD(m,1,@as_of_date)) AS VARCHAR)+'-01' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  AS Hr7
	,(CAST(CAST(CAST(s.calc_volume AS NUMERIC(22,10))* CAST(ISNULL(hb.hr8,0) AS NUMERIC(1,0)) AS NUMERIC(22,10))*CAST(CASE WHEN ISNULL(hb.add_dst_hour,0)=8 THEN 2 ELSE 1 END AS NUMERIC(1,0)) AS NUMERIC(22,10)))/CAST(NULLIF(ISNULL(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) AS NUMERIC(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,@as_of_date)) AS VARCHAR)+'-'+CAST(MONTH(DATEADD(m,1,@as_of_date)) AS VARCHAR)+'-01' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  AS Hr8
	,(CAST(CAST(CAST(s.calc_volume AS NUMERIC(22,10))* CAST(ISNULL(hb.hr9,0) AS NUMERIC(1,0)) AS NUMERIC(22,10))*CAST(CASE WHEN ISNULL(hb.add_dst_hour,0)=9 THEN 2 ELSE 1 END AS NUMERIC(1,0)) AS NUMERIC(22,10)))/CAST(NULLIF(ISNULL(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) AS NUMERIC(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,@as_of_date)) AS VARCHAR)+'-'+CAST(MONTH(DATEADD(m,1,@as_of_date)) AS VARCHAR)+'-01' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  AS Hr9
	,(CAST(CAST(CAST(s.calc_volume AS NUMERIC(22,10))* CAST(ISNULL(hb.hr10,0) AS NUMERIC(1,0)) AS NUMERIC(22,10))*CAST(CASE WHEN ISNULL(hb.add_dst_hour,0)=10 THEN 2 ELSE 1 END AS NUMERIC(1,0)) AS NUMERIC(22,10)))/CAST(NULLIF(ISNULL(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) AS NUMERIC(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,@as_of_date)) AS VARCHAR)+'-'+CAST(MONTH(DATEADD(m,1,@as_of_date)) AS VARCHAR)+'-01' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  AS Hr10
	,(CAST(CAST(CAST(s.calc_volume AS NUMERIC(22,10))* CAST(ISNULL(hb.hr11,0) AS NUMERIC(1,0)) AS NUMERIC(22,10))*CAST(CASE WHEN ISNULL(hb.add_dst_hour,0)=11 THEN 2 ELSE 1 END AS NUMERIC(1,0)) AS NUMERIC(22,10)))/CAST(NULLIF(ISNULL(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) AS NUMERIC(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,@as_of_date)) AS VARCHAR)+'-'+CAST(MONTH(DATEADD(m,1,@as_of_date)) AS VARCHAR)+'-01' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  AS Hr11
	,(CAST(CAST(CAST(s.calc_volume AS NUMERIC(22,10))* CAST(ISNULL(hb.hr12,0) AS NUMERIC(1,0)) AS NUMERIC(22,10))*CAST(CASE WHEN ISNULL(hb.add_dst_hour,0)=12 THEN 2 ELSE 1 END AS NUMERIC(1,0)) AS NUMERIC(22,10)))/CAST(NULLIF(ISNULL(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) AS NUMERIC(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,@as_of_date)) AS VARCHAR)+'-'+CAST(MONTH(DATEADD(m,1,@as_of_date)) AS VARCHAR)+'-01' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  AS Hr12
	,(CAST(CAST(CAST(s.calc_volume AS NUMERIC(22,10))* CAST(ISNULL(hb.hr13,0) AS NUMERIC(1,0)) AS NUMERIC(22,10))*CAST(CASE WHEN ISNULL(hb.add_dst_hour,0)=13 THEN 2 ELSE 1 END AS NUMERIC(1,0)) AS NUMERIC(22,10)))/CAST(NULLIF(ISNULL(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) AS NUMERIC(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,@as_of_date)) AS VARCHAR)+'-'+CAST(MONTH(DATEADD(m,1,@as_of_date)) AS VARCHAR)+'-01' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  AS Hr13
	,(CAST(CAST(CAST(s.calc_volume AS NUMERIC(22,10))* CAST(ISNULL(hb.hr14,0) AS NUMERIC(1,0)) AS NUMERIC(22,10))*CAST(CASE WHEN ISNULL(hb.add_dst_hour,0)=14 THEN 2 ELSE 1 END AS NUMERIC(1,0)) AS NUMERIC(22,10)))/CAST(NULLIF(ISNULL(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) AS NUMERIC(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,@as_of_date)) AS VARCHAR)+'-'+CAST(MONTH(DATEADD(m,1,@as_of_date)) AS VARCHAR)+'-01' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  AS Hr14
	,(CAST(CAST(CAST(s.calc_volume AS NUMERIC(22,10))* CAST(ISNULL(hb.hr15,0) AS NUMERIC(1,0)) AS NUMERIC(22,10))*CAST(CASE WHEN ISNULL(hb.add_dst_hour,0)=15 THEN 2 ELSE 1 END AS NUMERIC(1,0)) AS NUMERIC(22,10)))/CAST(NULLIF(ISNULL(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) AS NUMERIC(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,@as_of_date)) AS VARCHAR)+'-'+CAST(MONTH(DATEADD(m,1,@as_of_date)) AS VARCHAR)+'-01' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  AS Hr15
	,(CAST(CAST(CAST(s.calc_volume AS NUMERIC(22,10))* CAST(ISNULL(hb.hr16,0) AS NUMERIC(1,0)) AS NUMERIC(22,10))*CAST(CASE WHEN ISNULL(hb.add_dst_hour,0)=16 THEN 2 ELSE 1 END AS NUMERIC(1,0)) AS NUMERIC(22,10)))/CAST(NULLIF(ISNULL(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) AS NUMERIC(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,@as_of_date)) AS VARCHAR)+'-'+CAST(MONTH(DATEADD(m,1,@as_of_date)) AS VARCHAR)+'-01' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  AS Hr16
	,(CAST(CAST(CAST(s.calc_volume AS NUMERIC(22,10))* CAST(ISNULL(hb.hr17,0) AS NUMERIC(1,0)) AS NUMERIC(22,10))*CAST(CASE WHEN ISNULL(hb.add_dst_hour,0)=17 THEN 2 ELSE 1 END AS NUMERIC(1,0)) AS NUMERIC(22,10)))/CAST(NULLIF(ISNULL(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) AS NUMERIC(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,@as_of_date)) AS VARCHAR)+'-'+CAST(MONTH(DATEADD(m,1,@as_of_date)) AS VARCHAR)+'-01' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  AS Hr17
	,(CAST(CAST(CAST(s.calc_volume AS NUMERIC(22,10))* CAST(ISNULL(hb.hr18,0) AS NUMERIC(1,0)) AS NUMERIC(22,10))*CAST(CASE WHEN ISNULL(hb.add_dst_hour,0)=18 THEN 2 ELSE 1 END AS NUMERIC(1,0)) AS NUMERIC(22,10)))/CAST(NULLIF(ISNULL(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) AS NUMERIC(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,@as_of_date)) AS VARCHAR)+'-'+CAST(MONTH(DATEADD(m,1,@as_of_date)) AS VARCHAR)+'-01' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  AS Hr18
	,(CAST(CAST(CAST(s.calc_volume AS NUMERIC(22,10))* CAST(ISNULL(hb.hr19,0) AS NUMERIC(1,0)) AS NUMERIC(22,10))*CAST(CASE WHEN ISNULL(hb.add_dst_hour,0)=19 THEN 2 ELSE 1 END AS NUMERIC(1,0)) AS NUMERIC(22,10)))/CAST(NULLIF(ISNULL(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) AS NUMERIC(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,@as_of_date)) AS VARCHAR)+'-'+CAST(MONTH(DATEADD(m,1,@as_of_date)) AS VARCHAR)+'-01' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  AS Hr19
	,(CAST(CAST(CAST(s.calc_volume AS NUMERIC(22,10))* CAST(ISNULL(hb.hr20,0) AS NUMERIC(1,0)) AS NUMERIC(22,10))*CAST(CASE WHEN ISNULL(hb.add_dst_hour,0)=20 THEN 2 ELSE 1 END AS NUMERIC(1,0)) AS NUMERIC(22,10)))/CAST(NULLIF(ISNULL(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) AS NUMERIC(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,@as_of_date)) AS VARCHAR)+'-'+CAST(MONTH(DATEADD(m,1,@as_of_date)) AS VARCHAR)+'-01' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  AS Hr20
	,(CAST(CAST(CAST(s.calc_volume AS NUMERIC(22,10))* CAST(ISNULL(hb.hr21,0) AS NUMERIC(1,0)) AS NUMERIC(22,10))*CAST(CASE WHEN ISNULL(hb.add_dst_hour,0)=21 THEN 2 ELSE 1 END AS NUMERIC(1,0)) AS NUMERIC(22,10)))/CAST(NULLIF(ISNULL(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) AS NUMERIC(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,@as_of_date)) AS VARCHAR)+'-'+CAST(MONTH(DATEADD(m,1,@as_of_date)) AS VARCHAR)+'-01' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  AS Hr21
	,(CAST(CAST(CAST(s.calc_volume AS NUMERIC(22,10))* CAST(ISNULL(hb.hr22,0) AS NUMERIC(1,0)) AS NUMERIC(22,10))*CAST(CASE WHEN ISNULL(hb.add_dst_hour,0)=22 THEN 2 ELSE 1 END AS NUMERIC(1,0)) AS NUMERIC(22,10)))/CAST(NULLIF(ISNULL(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) AS NUMERIC(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,@as_of_date)) AS VARCHAR)+'-'+CAST(MONTH(DATEADD(m,1,@as_of_date)) AS VARCHAR)+'-01' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  AS Hr22
	,(CAST(CAST(CAST(s.calc_volume AS NUMERIC(22,10))* CAST(ISNULL(hb.hr23,0) AS NUMERIC(1,0)) AS NUMERIC(22,10))*CAST(CASE WHEN ISNULL(hb.add_dst_hour,0)=23 THEN 2 ELSE 1 END AS NUMERIC(1,0)) AS NUMERIC(22,10)))/CAST(NULLIF(ISNULL(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) AS NUMERIC(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,@as_of_date)) AS VARCHAR)+'-'+CAST(MONTH(DATEADD(m,1,@as_of_date)) AS VARCHAR)+'-01' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  AS Hr23
	,(CAST(CAST(CAST(s.calc_volume AS NUMERIC(22,10))* CAST(ISNULL(hb.hr24,0) AS NUMERIC(1,0)) AS NUMERIC(22,10))*CAST(CASE WHEN ISNULL(hb.add_dst_hour,0)=24 THEN 2 ELSE 1 END AS NUMERIC(1,0)) AS NUMERIC(22,10)))/CAST(NULLIF(ISNULL(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) AS NUMERIC(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,@as_of_date)) AS VARCHAR)+'-'+CAST(MONTH(DATEADD(m,1,@as_of_date)) AS VARCHAR)+'-01' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  AS Hr24
	,(CAST(CAST(s.calc_volume AS NUMERIC(22,10))* CAST(CASE WHEN ISNULL(hb.add_dst_hour,0)=0 THEN 0 ELSE 1 END AS NUMERIC(1,0)) AS NUMERIC(22,10))) /CAST(NULLIF(ISNULL(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) AS NUMERIC(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,@as_of_date)) AS VARCHAR)+'-'+CAST(MONTH(DATEADD(m,1,@as_of_date)) AS VARCHAR)+'-01' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END) AS Hr25 
	,CASE WHEN s.formula IN('dbo.FNACurveH','dbo.FNACurveD') THEN ISNULL(hg.exp_date,hb.term_date) 
			WHEN ISNULL(spcd.hourly_volume_allocation,17601) IN(17603,17604) THEN ISNULL(hg.exp_date,s.expiration_date)
			ELSE s.expiration_date 
		END expiration_date
INTO #report_hourly_position_breakdown_detail
FROM #report_hourly_position_breakdown s  (NOLOCK) 
	LEFT JOIN source_price_curve_def spcd WITH (NOLOCK) ON spcd.source_curve_def_id=s.curve_id  
	LEFT JOIN source_price_curve_def spcd1 (NOLOCK) ON spcd1.source_curve_def_id=spcd.settlement_curve_id
	OUTER APPLY 
	(
		SELECT SUM(volume_mult) term_no_hrs FROM hour_block_term hbt WHERE ISNULL(spcd.hourly_volume_allocation,17601) <17603 AND hbt.block_define_id=COALESCE(spcd.block_define_id,@baseload_block_define_id)	
		AND  hbt.block_type = COALESCE(spcd.block_type,12000) AND hbt.term_date BETWEEN s.term_start  AND s.term_END 
	) term_hrs
	OUTER APPLY 
	( 
		SELECT SUM(volume_mult) term_no_hrs FROM hour_block_term hbt INNER JOIN 
		(
			SELECT DISTINCT exp_date FROM holiday_group h WHERE  h.hol_group_value_id = ISNULL(spcd.exp_calendar_id,spcd1.exp_calendar_id) AND h.exp_date BETWEEN s.term_start  AND s.term_END 
		) ex ON ex.exp_date = hbt.term_date
		WHERE  ISNULL(spcd.hourly_volume_allocation,17601) IN(17603,17604) AND hbt.block_define_id = COALESCE(spcd.block_define_id,@baseload_block_define_id)	
		AND  hbt.block_type = COALESCE(spcd.block_type,12000) AND hbt.term_date BETWEEN s.term_start  AND s.term_END
	) term_hrs_exp
	LEFT JOIN hour_block_term hb (NOLOCK) ON hb.block_define_id = COALESCE(spcd.block_define_id,@baseload_block_define_id)
		AND  hb.block_type=COALESCE(spcd.block_type,12000) AND hb.term_date BETWEEN s.term_start  AND s.term_end  
	OUTER APPLY 
	(
		SELECT MAX(exp_date) exp_date FROM holiday_group h WHERE h.hol_date = hb.term_date AND 
		h.hol_group_value_id = ISNULL(spcd.exp_calendar_id,spcd1.exp_calendar_id) AND h.hol_date BETWEEN s.term_start  AND s.term_END 
		AND COALESCE(spcd1.ratio_option,spcd.ratio_option,-1) <> 18800 
	) hg   
	OUTER APPLY 
	(
		SELECT MIN(exp_date) hol_date ,MAX(exp_date) hol_date_to  FROM holiday_group h WHERE h.hol_group_value_id = ISNULL(spcd.exp_calendar_id,spcd1.exp_calendar_id) AND h.hol_date BETWEEN s.term_start  AND s.term_END AND s.formula NOT IN('REBD')
	) hg1   
	OUTER APPLY
	(
		SELECT count(exp_date) total_days,SUM(CASE WHEN h.exp_date > @as_of_date THEN 1 ELSE 0 END) remain_days FROM holiday_group h WHERE h.hol_group_value_id = ISNULL(spcd.exp_calendar_id,spcd1.exp_calendar_id) 
			AND h.exp_date BETWEEN hg1.hol_date AND ISNULL(hg1.hol_date_to,dbo.FNALastDayInDate(hg1.hol_date))
			AND ISNULL(spcd1.ratio_option,spcd.ratio_option) = 18800 AND s.formula NOT IN('REBD')
	) remain_month  
	WHERE 
	((ISNULL(spcd1.ratio_option,spcd.ratio_option) = 18800 AND ISNULL(hg1.hol_date_to,'9999-01-01') > @as_of_date ) OR COALESCE(spcd1.ratio_option,spcd.ratio_option,-1) <> 18800)
		AND (
			(ISNULL(spcd.hourly_volume_allocation,17601) IN(17603,17604) AND  hg.exp_date IS NOT NULL) 
			OR (ISNULL(spcd.hourly_volume_allocation,17601) < 17603 )
		)	 
		AND CASE  WHEN s.formula IN('dbo.FNACurveH','dbo.FNACurveD') THEN ISNULL(hg.exp_date,hb.term_date) 
				WHEN ISNULL(spcd.hourly_volume_allocation,17601) IN(17603,17604) THEN ISNULL(hg.exp_date,s.expiration_date)
				ELSE s.expiration_date 
			END > @as_of_date
		AND   hb.term_date>@as_of_date
			OPTION (MAXDOP 1000, MAXRECURSION 32767)

DECLARE @hr_columns VARCHAR(MAX),@fin_columns VARCHAR(MAX),@phy_columns VARCHAR(MAX),@delta_hr_columns VARCHAR(MAX)

SET @fin_columns = 'h.counterparty_id,h.[curve_id],h.expiration_date,h.deal_volume_uom_id,h.book_id,e.[term_start],h.commodity_id,h.[physical_financial_flag],h.book_deal_type_map_id,h.[source_deal_header_id]' 

SET @phy_columns = 'sdd.source_deal_detail_id,sdh.counterparty_id,e.[curve_id],e.expiration_date,e.deal_volume_uom_id,sdh.book_id,e.[term_start],sdd.commodity_id,e.[physical_financial_flag],sdh.book_deal_type_map_id ,sdh.[source_deal_header_id]'

SET @hr_columns = ',e.hr1,e.hr2,e.hr3,e.hr4,e.hr5,e.hr6,e.hr7,e.hr8,e.hr9,e.hr10,e.hr11,e.hr12,e.hr13,e.hr14,e.hr15,e.hr16,e.hr17,e.hr18,e.hr19,e.hr20,e.hr21 ,e.hr22 ,e.hr23,e.hr24,e.hr25,e.hr25 dst_hr'

SET @st1 = '
	SELECT ROWID = IDENTITY(INT,1,1),u.source_deal_detail_id,u.counterparty_id,u.[curve_id],u.term_start,u.book_deal_type_map_id,[physical_financial_flag],u.deal_volume_uom_id,u.[book_id]
	,CASE WHEN CAST(SUBSTRING(hr,3,2) AS INT) =25 THEN CASE WHEN u.formula_breakdown=0 THEN dst.[hour] ELSE dst.fin_hour END
	ELSE 	
		CAST(SUBSTRING(u.hr,3,2) AS INT) 
	END Hr
	,SUM(CASE WHEN u.expiration_date > ''' + CONVERT(VARCHAR(10),@as_of_date,120) + ''' AND u.[term_start] > '''+CONVERT(VARCHAR(10),@as_of_date,120) + ''' 
			THEN u.Volume ELSE 0 END- CASE WHEN dst.[hour]=CAST(SUBSTRING(u.hr,3,2) AS INT) THEN ISNULL(u.dst_hr,0) ELSE 0 END ) Position
	, DATEADD(HOUR,	CASE WHEN CAST(SUBSTRING(hr,3,2) AS INT) = 25 THEN dst.[hour] ELSE CAST(SUBSTRING(u.hr,3,2) AS INT) END -1,u.[term_start]) [Maturity_hr]
	,CAST(CONVERT(VARCHAR(8),u.[term_start],120)+''01'' AS DATE) [Maturity_mnth]
	,CAST(CONVERT(VARCHAR(5),u.[term_start],120)+ CAST(CASE DATEPART(q, u.term_start) WHEN 1 THEN 1 WHEN 2 THEN 4 WHEN 3 THEN 7 WHEN 4 THEN 10 END as VARCHAR)+''-01'' AS DATE) [Maturity_qtr] 
	,CAST(CONVERT(VARCHAR(5),u.[term_start],120)+ CAST(CASE WHEN month(u.term_start) < 7 THEN 1 ELSE 7 END as VARCHAR)+''-01'' AS DATE) [Maturity_semi] 
	,CAST(CONVERT(VARCHAR(5),u.[term_start],120)+ ''01-01'' AS DATE) [Maturity_yr],MAX(u.formula_breakdown) formula_breakdown,u.commodity_id
	,CASE WHEN CAST(SUBSTRING(u.hr,3,2) AS INT)=25 THEN 1 ELSE 0 END dst,u.[source_deal_header_id]
	INTO ' + @position_detail
			
SET @st2 = '	FROM 
	(
		SELECT ' + @phy_columns + '
			,SUM(e.hr1) hr1,SUM(e.hr2) hr2 ,SUM(e.hr3) hr3 ,SUM(e.hr4) hr4 ,SUM(e.hr5) hr5 ,SUM(e.hr6) hr6 ,SUM(e.hr7) hr7 ,SUM(e.hr8) hr8
			,SUM(e.hr9) hr9 ,SUM(e.hr10) hr10 ,SUM(e.hr11) hr11 ,SUM(e.hr12) hr12 ,SUM(e.hr13) hr13 ,SUM(e.hr14) hr14 ,SUM(e.hr15) hr15 ,SUM(e.hr16) hr16
			,SUM(e.hr17) hr17 ,SUM(e.hr18) hr18 ,SUM(e.hr19) hr19 ,SUM(e.hr20) hr20 ,SUM(e.hr21 ) hr21 ,SUM(e.hr22 ) hr22 ,SUM(e.hr23) hr23 ,SUM(e.hr24) hr24,SUM(e.hr25) hr25,SUM(e.hr25) dst_hr
			,0 formula_breakdown
		FROM [dbo].[report_hourly_position_profile] e (NOLOCK) 
		INNER JOIN #deal_header sdh  ON e.source_deal_header_id=sdh.source_deal_header_id 
		INNER JOIN [deal_status_group] dsg ON dsg.status_value_id = sdh.deal_status_id 
			AND e.expiration_date > ''' + CONVERT(VARCHAR(10),@as_of_date,120) + ''' AND e.[term_start] > ''' + CONVERT(VARCHAR(10),@as_of_date,120) + '''
		inner JOIN  #deal_detail sdd  ON e.term_start BETWEEN sdd.term_start AND sdd.term_end 
		AND e.source_deal_detail_id=sdd.source_deal_detail_id
		GROUP BY ' + @phy_columns + ',CAST(CONVERT(VARCHAR(10),sdh.create_ts,120) AS DATE)
	UNION ALL
		SELECT '+ @phy_columns +'
			,SUM(e.hr1) hr1,SUM(e.hr2) hr2 ,SUM(e.hr3) hr3 ,SUM(e.hr4) hr4 ,SUM(e.hr5) hr5 ,SUM(e.hr6) hr6 ,SUM(e.hr7) hr7 ,SUM(e.hr8) hr8
				,SUM(e.hr9) hr9 ,SUM(e.hr10) hr10 ,SUM(e.hr11) hr11 ,SUM(e.hr12) hr12 ,SUM(e.hr13) hr13 ,SUM(e.hr14) hr14 ,SUM(e.hr15) hr15 ,SUM(e.hr16) hr16
				,SUM(e.hr17) hr17 ,SUM(e.hr18) hr18 ,SUM(e.hr19) hr19 ,SUM(e.hr20) hr20 ,SUM(e.hr21 ) hr21 ,SUM(e.hr22 ) hr22 ,SUM(e.hr23) hr23 ,SUM(e.hr24) hr24,SUM(e.hr25) hr25,SUM(e.hr25) dst_hr
			,0 formula_breakdown
		FROM [dbo].[report_hourly_position_deal] e (NOLOCK)  INNER JOIN ' + @tbl_name + ' t ON e.[source_deal_header_id]=t.source_deal_header_id 
			AND e.expiration_date > ''' + CONVERT(VARCHAR(10),@as_of_date,120) + ''' AND e.[term_start] > ''' + CONVERT(VARCHAR(10),@as_of_date,120) + '''
		INNER JOIN #deal_header sdh  ON e.source_deal_header_id=sdh.source_deal_header_id -- AND ISNULL(sdh.product_id,4101)<>4100 
		INNER JOIN [deal_status_group] dsg ON dsg.status_value_id = sdh.deal_status_id 
		inner JOIN  #deal_detail sdd  ON e.term_start BETWEEN sdd.term_start AND sdd.term_end 
		AND e.source_deal_detail_id=sdd.source_deal_detail_id
		GROUP BY '+@phy_columns+',CAST(CONVERT(VARCHAR(10),sdh.create_ts,120) AS DATE)
	UNION ALL
		SELECT '+ @phy_columns +'
			,SUM(e.hr1) hr1,SUM(e.hr2) hr2 ,SUM(e.hr3) hr3 ,SUM(e.hr4) hr4 ,SUM(e.hr5) hr5 ,SUM(e.hr6) hr6 ,SUM(e.hr7) hr7 ,SUM(e.hr8) hr8
				,SUM(e.hr9) hr9 ,SUM(e.hr10) hr10 ,SUM(e.hr11) hr11 ,SUM(e.hr12) hr12 ,SUM(e.hr13) hr13 ,SUM(e.hr14) hr14 ,SUM(e.hr15) hr15 ,SUM(e.hr16) hr16
				,SUM(e.hr17) hr17 ,SUM(e.hr18) hr18 ,SUM(e.hr19) hr19 ,SUM(e.hr20) hr20 ,SUM(e.hr21 ) hr21 ,SUM(e.hr22 ) hr22 ,SUM(e.hr23) hr23 ,SUM(e.hr24) hr24,SUM(e.hr25) hr25,SUM(e.hr25) dst_hr
			,1 formula_breakdown
		FROM [dbo].[report_hourly_position_financial] e (NOLOCK)  INNER JOIN ' + @tbl_name + ' t ON e.[source_deal_header_id]=t.source_deal_header_id 
			AND e.expiration_date > ''' + CONVERT(VARCHAR(10),@as_of_date,120) + ''' AND e.[term_start] > ''' + CONVERT(VARCHAR(10),@as_of_date,120) + '''
		INNER JOIN #deal_header sdh  ON e.source_deal_header_id=sdh.source_deal_header_id -- AND ISNULL(sdh.product_id,4101)<>4100 
		INNER JOIN [deal_status_group] dsg ON dsg.status_value_id = sdh.deal_status_id 
		inner JOIN  #deal_detail sdd  ON e.term_start BETWEEN sdd.term_start AND sdd.term_end 
		AND e.source_deal_detail_id=sdd.source_deal_detail_id
		GROUP BY '+@phy_columns+',CAST(CONVERT(VARCHAR(10),sdh.create_ts,120) AS DATE)	
	UNION ALL
		SELECT db.source_deal_detail_id,'+ @fin_columns + @hr_columns + ',1 formula_breakdown FROM #report_hourly_position_breakdown_detail e
		LEFT JOIN #report_hourly_position_breakdown h ON h.rowid=e.rowid
		cross APPLY (
				SELECT DISTINCT dpbd.source_deal_detail_id
				FROM deal_position_break_down dpbd
				inner join #deal_detail sdd on sdd.source_deal_detail_id = dpbd.source_deal_detail_id                                     
				WHERE dpbd.source_deal_header_id=h.source_deal_header_id
				AND dpbd.curve_id=h.curve_id AND ((e.term_start BETWEEN dpbd.fin_term_start AND dpbd.fin_term_end AND dpbd.formula = ''dbo.FNALagCurve'') 
					OR (e.term_start between sdd.term_start and sdd.term_end AND  isnull(dpbd.formula,'''') <> ''dbo.FNALagCurve''))
		) db
		'
			
SET @st3 = '
	) p
		UNPIVOT
			(Volume for Hr IN (hr1,hr2,hr3,hr4,hr5,hr6,hr7,hr8,hr9,hr10,hr11,hr12,hr13,hr14,hr15,hr16,hr17,hr18,hr19,hr20,hr21,hr22,hr23,hr24,hr25)
	)AS u 
	LEFT JOIN source_price_curve_def spcd ON u.curve_id = spcd.source_curve_def_id
	LEFT JOIN #mv90_dst dst ON dst.source_commodity_id = u.commodity_id 
		AND u.term_start=CASE WHEN u.formula_breakdown=0 THEN dst.date ELSE dst.fin_date END
	WHERE Volume <> 0 AND ( CASE WHEN CAST(SUBSTRING(hr,3,2) AS INT) = 25 THEN CASE WHEN u.formula_breakdown=0 THEN dst.[hour] ELSE dst.fin_hour END
									ELSE CAST(SUBSTRING(u.hr,3,2) AS INT) 	
							END) IS NOT NULL
	GROUP BY u.source_deal_detail_id,u.[curve_id],u.term_start,u.book_deal_type_map_id,[physical_financial_flag] ,u.deal_volume_uom_id,u.[book_id],u.counterparty_id
	,CASE WHEN CAST(SUBSTRING(hr,3,2) AS INT) = 25 THEN CASE WHEN u.formula_breakdown = 0 THEN dst.[hour] ELSE dst.fin_hour END
			ELSE CAST(SUBSTRING(u.hr,3,2) AS INT) 
		END , DATEADD(hour, CASE WHEN CAST(SUBSTRING(hr,3,2) AS INT) = 25 THEN dst.[hour] ELSE CAST(SUBSTRING(u.hr,3,2) AS INT) END -1,u.[term_start])
	,u.commodity_id,CASE WHEN CAST(SUBSTRING(u.hr,3,2) AS INT)=25 THEN 1 ELSE 0 END,u.[source_deal_header_id]'
			
			
EXEC spa_print @st1	
EXEC spa_print @st2 
EXEC spa_print @st3
EXEC(@st1+ @st2 + @st3 )		
			
SET @st1 = 'CREATE INDEX indx_222_' + @process_id + ' ON ' + @position_detail + '(curve_id)'
EXEC(@st1)
SET @st1 = 'CREATE INDEX ix_pt_indddd_111_' + @process_id + '  ON ' + @position_detail + ' ([curve_id]) INCLUDE ([source_deal_detail_id], [counterparty_id], [term_start], [physical_financial_flag], [deal_volume_uom_id], [book_id], [Position], [Maturity_hr], [Maturity_mnth], [Maturity_qtr], [Maturity_semi], [Maturity_yr], [formula_breakdown], [dst], [source_deal_header_id])'
EXEC(@st1)
	
SET @st2='
	select a.book_id,a.curve_id,a.source_deal_detail_id,a.counterparty_id,a.source_deal_header_id
		,max(a.deal_volume_uom_id) deal_volume_uom_id,
		CASE WHEN spcd.Granularity in( 982) then 
			case when g.granularity_id=993 then dateadd(hour,datepart(hour,a.maturity_hr),cast(a.maturity_yr as datetime) )
				when g.granularity_id=992 then dateadd(hour,datepart(hour,a.maturity_hr),cast(a.maturity_semi as datetime)) 
				when g.granularity_id=991 then dateadd(hour,datepart(hour,a.maturity_hr),cast(a.maturity_qtr as datetime)) 
				when g.granularity_id=980 then dateadd(hour,datepart(hour,a.maturity_hr),cast(a.maturity_mnth as datetime)) 
			else a.maturity_hr end else null end maturity_hr,
		CASE WHEN spcd.Granularity in(982, 981) then 
			case when g.granularity_id=993 then a.maturity_yr
				when g.granularity_id=992 then a.maturity_semi
				when g.granularity_id=991 then a.maturity_qtr 
				when g.granularity_id=980 then a.maturity_mnth
			else a.term_start end else a.maturity_mnth end term_start,
		CASE WHEN spcd.Granularity in( 982,981,980 ) then a.maturity_mnth else null end maturity_mnth,
		CASE WHEN spcd.Granularity in(982,981,980, 991) then a.maturity_qtr else null end maturity_qtr,
		CASE WHEN spcd.Granularity in( 982,981,980,991, 992) then a.maturity_semi else null end maturity_semi,
		CASE WHEN spcd.Granularity in( 982,981,980,991, 992,993) then a.maturity_yr else null end maturity_yr,
		CASE WHEN spcd.Granularity = 982 THEN case when g.granularity_id in (993,992,991,980) THEN 0 ELSE dst END ELSE 0 END dst,
		a.physical_financial_flag,formula_breakdown ,
			SUM(Position * CASE WHEN a.formula_breakdown = 1 THEN ISNULL(sdd.price_multiplier,1) ELSE 1 END
		* abs(isnull(case when sdd.leg=1 then isnull(sogd.delta,sdpd.delta) else isnull(sogd.delta2,sdpd.delta2) end,1))) Position
	INTO '+@tbl_name_pos+'
	from '+@position_detail+' a 
	inner join dbo.source_price_curve_Def spcd (NOLOCK)  on a.curve_id=spcd.source_curve_def_id
	inner join #deal_header  sdh on  a.source_deal_header_id=sdh.source_deal_header_id
	left join #deal_detail  sdd on  a.source_deal_header_id=sdd.source_deal_header_id and sdd.curve_id=a.curve_id
		and a.term_start between sdd.term_start and sdd.term_end  and a.formula_breakdown=0
	left join #curve_granularity g on g.curve_id=a.curve_id
	left join  source_option_greeks_detail sogd on sogd.as_of_date='''+convert(varchar(10),@as_of_date,120)+''' and sogd.source_deal_header_id=a.source_deal_header_id 
		and sdh.pricing in (1604,1605) and sogd.term_start=a.term_start
		and sogd.hr=a.hr and sogd.is_dst=0 and sogd.period=0 and sogd.pnl_source_value_id =4500
	left join  source_deal_pnl_detail_options sdpd on sdpd.as_of_date='''+convert(varchar(10),@as_of_date,120)+''' and sdpd.source_deal_header_id=a.source_deal_header_id 
		and sdh.pricing not in (1604,1605) and sdpd.term_start=a.term_start and sogd.pnl_source_value_id =4500
	group by
		a.book_id,a.curve_id,a.source_deal_detail_id,a.counterparty_id,a.physical_financial_flag,a.formula_breakdown,a.source_deal_header_id,
		CASE WHEN spcd.Granularity in( 982) then 
			case when g.granularity_id=993 then dateadd(hour,datepart(hour,a.maturity_hr),cast(a.maturity_yr as datetime) )
				when g.granularity_id=992 then dateadd(hour,datepart(hour,a.maturity_hr),cast(a.maturity_semi as datetime)) 
				when g.granularity_id=991 then dateadd(hour,datepart(hour,a.maturity_hr),cast(a.maturity_qtr as datetime)) 
				when g.granularity_id=980 then dateadd(hour,datepart(hour,a.maturity_hr),cast(a.maturity_mnth as datetime)) 
			else a.maturity_hr end else null end,
		CASE WHEN spcd.Granularity in(982, 981) then 
			case when g.granularity_id=993 then a.maturity_yr
				when g.granularity_id=992 then a.maturity_semi
				when g.granularity_id=991 then a.maturity_qtr 
				when g.granularity_id=980 then a.maturity_mnth
			else a.term_start end else a.maturity_mnth end,
		CASE WHEN spcd.Granularity in( 982,981,980) then maturity_mnth else null end ,
		CASE WHEN spcd.Granularity in(  982,981,980,991) then maturity_qtr else null end ,
		CASE WHEN spcd.Granularity in(  982,981,980,991, 992) then maturity_semi else null end ,
		CASE WHEN spcd.Granularity in( 982,981,980,991, 992,993) then maturity_yr else null end ,
		CASE WHEN spcd.Granularity = 982 THEN case when g.granularity_id in (993,992,991,980) THEN 0 ELSE dst END ELSE 0 END 
'
	
EXEC spa_print  @st2
exec(@st2 ) 

SELECT distinct book_id, func_cur_id INTO #bok FROM  #book
CREATE CLUSTERED INDEX ix_pt_bok ON #bok(book_id, func_cur_id)

SET @st1 = 'CREATE INDEX indx_333_' + @process_id + ' ON ' + @tbl_name_pos + '(curve_id)'
EXEC(@st1)
		
SET @st1 = 'CREATE INDEX indx_444_' + @process_id + ' ON ' + @tbl_name_pos + '(source_deal_detail_id)'
EXEC(@st1)
SET @st1 = 'CREATE INDEX indx_555_' + @process_id + ' ON ' + @tbl_name_pos + '(book_id)'
EXEC(@st1)
SET @st1 = 'CREATE INDEX indx_666_' + @process_id + ' ON ' + @tbl_name_pos + '(maturity_hr)'
EXEC(@st1)
SET @st1 = 'CREATE INDEX indx_777_' + @process_id + ' ON ' + @tbl_name_pos + '(term_start)'
EXEC(@st1)
SET @st1 = 'CREATE INDEX indx_888_' + @process_id + ' ON ' + @tbl_name_pos + '(maturity_mnth)'
EXEC(@st1)
SET @st1 = 'CREATE INDEX indx_999_' + @process_id + ' ON ' + @tbl_name_pos + '(maturity_qtr)'
EXEC(@st1)

SET @st1 = 'CREATE INDEX indx_11111_' + @process_id + ' ON ' + @tbl_name_pos + '(maturity_semi)'
EXEC(@st1)

SET @st1 = 'CREATE INDEX indx_22222_' + @process_id + ' ON ' + @tbl_name_pos + '(maturity_yr)'
EXEC(@st1)
		
SET @st1 = 'CREATE clustered INDEX IX_PT_spc1' + @process_id + ' ON ' + @tbl_name_spc + '(source_curve_def_id, curve_Source_value_id, maturity_date)'
EXEC(@st1)
		
CREATE TABLE #total_val(
	commodity_id INT,
	value FLOAT
	)



SET @st1 = '
insert into #total_val(commodity_id ,value )
	SELECT COALESCE(spcd.commodity_id,spcd2.commodity_id,spcd3.commodity_id,spcd4.commodity_id)  commodity_id
	,SUM(p.Position * COALESCE(spc.curve_value,spc2.curve_value,spc3.curve_value,spc4.curve_value)
		* ISNULL(sc_v.factor,1) * CASE WHEN p.formula_breakdown = 1 THEN ISNULL(sdd.price_multiplier,1) ELSE 1 END
		* CAST(ISNULL(conv_v.conversion_factor,1) AS NUMERIC(21,16)) 
		* COALESCE(fx_fnuc_v.curve_value,(1 / NULLIF(fx_fnuc_v1.curve_value,0)),1) / CAST(ISNULL(conv_price.conversion_factor,1) AS NUMERIC(21,16))
	) value
'

SET @st2 = '
	--select a.*
	from '+@tbl_name_pos+' p
	inner join  dbo.source_price_curve_Def spcd WITH(NOLOCK) on p.curve_id=spcd.source_curve_def_id
	LEFT JOIN dbo.source_price_curve_def spcd2 WITH(NOLOCK)  ON spcd.proxy_source_curve_def_id=spcd2.source_curve_def_id
	LEFT JOIN dbo.source_price_curve_def spcd3 (NOLOCK)  ON spcd.monthly_index=spcd3.source_curve_def_id
	LEFT JOIN dbo.source_price_curve_def spcd4 (NOLOCK)  ON spcd.proxy_curve_id3=spcd4.source_curve_def_id
	LEFT JOIN dbo.source_currency sc_v ON spcd.source_currency_id=sc_v.source_currency_id AND sc_v.currency_id_to IS NOT NULL
	LEFT JOIN source_price_curve [spc] WITH (NOLOCK)  ON spcd.source_curve_def_id=[spc].source_curve_def_id
		AND [spc].curve_Source_value_id=4500
		AND spc.as_of_date = '''+convert(varchar(10),@as_of_date,120)+'''
		AND [spc].maturity_date=
		CASE  spcd.Granularity WHEN 982 THEN p.maturity_hr WHEN 981 THEN p.term_start WHEN 980 THEN p.maturity_mnth
				WHEN 991 THEN p.maturity_qtr WHEN 992 THEN p.maturity_semi WHEN 993 THEN p.maturity_yr
		END AND p.dst=CASE WHEN spcd.Granularity = 982 THEN [spc].is_dst  ELSE p.dst END
		--AND spcd.settlement_curve_id IS NOT NULL
	LEFT JOIN source_price_curve [spc2] WITH(NOLOCK)  ON spcd2.source_curve_def_id=[spc2].source_curve_def_id
		AND [spc2].curve_Source_value_id=4500
		AND [spc2].maturity_date=
		CASE  spcd2.Granularity WHEN 982 THEN p.maturity_hr WHEN 981 THEN p.term_start WHEN 980 THEN p.maturity_mnth
			WHEN 991 THEN p.maturity_qtr WHEN 992 THEN p.maturity_semi WHEN 993 THEN p.maturity_yr
		END AND p.dst=CASE WHEN spcd2.Granularity = 982 THEN [spc2].is_dst  ELSE p.dst END
		AND spc2.as_of_date = '''+convert(varchar(10),@as_of_date,120)+'''
	LEFT JOIN source_price_curve [spc3] WITH (NOLOCK)  ON spcd3.source_curve_def_id=[spc3].source_curve_def_id
		AND [spc3].curve_Source_value_id=4500
		AND spc3.as_of_date = '''+convert(varchar(10),@as_of_date,120)+'''
		AND [spc3].maturity_date=
		CASE  spcd3.Granularity WHEN 982 THEN p.maturity_hr WHEN 981 THEN p.term_start WHEN 980 THEN p.maturity_mnth
				WHEN 991 THEN p.maturity_qtr WHEN 992 THEN p.maturity_semi WHEN 993 THEN p.maturity_yr
		END AND p.dst=CASE WHEN spcd3.Granularity = 982 THEN [spc3].is_dst  ELSE p.dst END
	LEFT JOIN source_price_curve [spc4] WITH(NOLOCK)  ON spcd4.source_curve_def_id=[spc4].source_curve_def_id
		AND [spc4].curve_Source_value_id=4500
		AND [spc4].maturity_date=
		CASE  spcd4.Granularity WHEN 982 THEN p.maturity_hr WHEN 981 THEN p.term_start WHEN 980 THEN p.maturity_mnth
			WHEN 991 THEN p.maturity_qtr WHEN 992 THEN p.maturity_semi WHEN 993 THEN p.maturity_yr
		END AND p.dst=CASE WHEN spcd4.Granularity = 982 THEN [spc4].is_dst  ELSE p.dst END
		AND spc4.as_of_date ='''+convert(varchar(10),@as_of_date,120)+'''
'
			
SET @st3 = '
		LEFT JOIN #bok b WITH(NOLOCK) ON p.book_id=b.book_id
		LEFT JOIN  dbo.source_price_curve_def fx_v WITH(NOLOCK)  ON fx_v.source_currency_id = ISNULL(sc_v.currency_id_to,spcd.source_currency_id) AND fx_v.source_currency_to_id=b.func_cur_id AND fx_v.Granularity=980
		LEFT JOIN source_price_curve fx_fnuc_v WITH(NOLOCK) 
				ON fx_v.source_curve_def_id=fx_fnuc_v.source_curve_def_id
				AND fx_fnuc_v.curve_Source_value_id = 4500	
				AND fx_fnuc_v.maturity_date= p.maturity_mnth AND COALESCE(spc.as_of_date,spc2.as_of_date,spc3.as_of_date,spc4.as_of_date)=fx_fnuc_v.as_of_date
		LEFT JOIN dbo.source_price_curve_def fx_v1 WITH(NOLOCK)  ON fx_v1.source_currency_id =b.func_cur_id AND fx_v1.source_currency_to_id= ISNULL(sc_v.currency_id_to,spcd.source_currency_id) AND fx_v1.Granularity=980
		LEFT JOIN source_price_curve fx_fnuc_v1 WITH(NOLOCK)  ON fx_v1.source_curve_def_id=fx_fnuc_v1.source_curve_def_id
			AND fx_fnuc_v1.curve_Source_value_id = 4500	
			AND fx_fnuc_v1.maturity_date=p.maturity_mnth AND COALESCE(spc.as_of_date,spc2.as_of_date,spc3.as_of_date,spc4.as_of_date)=fx_fnuc_v1.as_of_date
		LEFT JOIN dbo.rec_volume_unit_conversion conv_v WITH(NOLOCK) ON conv_v.from_source_uom_id=p.deal_volume_uom_id
			AND conv_v.to_source_uom_id=ISNULL(spcd.display_uom_id,spcd.uom_id)
		LEFT JOIN dbo.rec_volume_unit_conversion conv_price WITH(NOLOCK) ON conv_price.from_source_uom_id=spcd.uom_id
			AND conv_price.to_source_uom_id=ISNULL(spcd.display_uom_id,spcd.uom_id)	
		LEFT JOIN #deal_detail sdd WITH(nolock) ON sdd.source_deal_detail_id=p.source_deal_detail_id
		LEFT JOIN source_option_greeks_detail sogd WITH(nolock) ON p.source_deal_header_id = sogd.source_deal_header_id
			AND sogd.hr = ISNULL((1+DATEPART(hh,p.maturity_hr)), 1) 
			AND sogd.is_dst= CASE WHEN spcd.Granularity = 982 THEN p.dst ELSE sogd.is_dst END
			AND sogd.term_start = 
				CASE spcd.Granularity WHEN 982 THEN p.term_start WHEN 981 THEN p.term_start WHEN 980 THEN p.maturity_mnth
					WHEN 991 THEN p.maturity_qtr WHEN 992 THEN p.maturity_semi WHEN 993 THEN p.maturity_yr
				END
			AND sogd.as_of_date ='''+convert(varchar(10),@as_of_date,120)+'''
			AND sogd.pnl_source_value_id = 4500
		GROUP BY COALESCE(spcd.commodity_id,spcd2.commodity_id,spcd3.commodity_id,spcd4.commodity_id)
		'

exec spa_print @st1
exec spa_print @st2 
exec spa_print  @st3 
EXEC(@st1 + @st2 + @st3)

 --/*

DECLARE @commodity_shift_params_table VARCHAR(MAX)
SELECT @commodity_shift_params_table = dbo.FNAProcessTableName('commodity_shift_params', @user_id, @process_id)

CREATE TABLE #tmp_final_shift(
	commodity_one INT, 
	commodity_two INT, 
	shift_one FLOAT, 
	shift_two FLOAT
	)

EXEC ('INSERT INTO #tmp_final_shift SELECT * FROM '+ @commodity_shift_params_table)

--######## END COLLECTING SHIFT DETAILS #############--

		
CREATE TABLE #tmp_final_calc(
	commodity_one INT,
	commodity_two INT,
	shift_one FLOAT,
	shift_two FLOAT, 
	value_one FLOAT,
	value_two FLOAT, 
	calc_value_one FLOAT,
	calc_value_two FLOAT,
	fixed_value FLOAT,
	total_value FLOAT
)

IF @delta = 'y'
BEGIN
	INSERT INTO #tmp_final_calc
	SELECT tfs.commodity_one, tfs.commodity_two,
		tfs.shift_one,
		tfs.shift_two, 
		tv.value value_one,
		tv1.value value_two, 
		tv.value*(tfs.shift_one / 100) delta_one,
		tv1.value*(tfs.shift_two / 100) delta_two,
		tv2.value fixed_value,
		(ISNULL(tv.value*(tfs.shift_one / 100), 0) + ISNULL(tv1.value*(tfs.shift_two / 100), 0)) delta_total
	FROM #tmp_final_shift tfs
	LEFT JOIN #total_val tv ON tv.commodity_id = tfs.commodity_one
	LEFT JOIN #total_val tv1 ON tv1.commodity_id = tfs.commodity_two
	OUTER APPLY(SELECT value FROM #total_val WHERE commodity_id = -1) tv2
END
ELSE
BEGIN
	INSERT INTO #tmp_final_calc
	SELECT tfs.commodity_one, tfs.commodity_two,
		tfs.shift_one,
		tfs.shift_two, 
		tv.value value_one,
		tv1.value value_two, 
		tv.value*(1 + (tfs.shift_one) / 100) calc_value_one,
		tv1.value*(1 + (tfs.shift_two) / 100) calc_value_two,
		tv2.value fixed_value,
		--tv3.value other_value,
		ISNULL(tv.value*(1 + (tfs.shift_one / 100)), 0) + ISNULL(tv1.value*(1 + (tfs.shift_two / 100)), 0) + ISNULL(tv2.value, 0) + isnull(tv3.value,0) total_value
	FROM #tmp_final_shift tfs
	LEFT JOIN #total_val tv ON tv.commodity_id = tfs.commodity_one
	LEFT JOIN #total_val tv1 ON tv1.commodity_id = tfs.commodity_two
	OUTER APPLY(SELECT value FROM #total_val WHERE commodity_id = -1) tv2
	OUTER APPLY(
		SELECT value FROM #total_val WHERE	commodity_id <> -1 AND commodity_id <> tfs.commodity_one 
							AND commodity_id <> isnull(tfs.commodity_two,-99)
		) tv3

END
	
SET @st_sql='
	SELECT * INTO ' + @final_calc_val + ' FROM #tmp_final_calc'
	
exec spa_print @st_sql
EXEC(@st_sql)	
