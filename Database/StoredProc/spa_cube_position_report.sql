/****** Object:  StoredProcedure [dbo].[spa_cube_position_report]    Script Date: 06/01/2012 20:15:13 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_cube_position_report]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_cube_position_report]
GO

/****** Object:  StoredProcedure [dbo].[spa_cube_position_report]    Script Date: 06/01/2012 20:15:18 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE PROC [dbo].[spa_cube_position_report]
	@flag CHAR(1) = 's', -- 's' Summary in month level, 'd' Detail 
	@as_of_date VARCHAR(20),
	@process_table_name VARCHAR(100)=NULL,
	@source_deal_header_id VARCHAR(2000) = NULL
	
AS
SET NOCOUNT ON 
/*
DECLARE @flag CHAR(1),@as_of_date VARCHAR(20),@process_table_name VARCHAR(100),@source_deal_header_id VARCHAR(100)

SET @flag = 'd'
SET @as_of_date = '2012-05-24'
SET @process_table_name = 'adiha_process.dbo.cube_position_report'

--select * from source_price_curve_def where source_curve_def_id=92
--*/

DECLARE @user_login_id VARCHAR(50),@process_id VARCHAR(100),@sql VARCHAR(MAX),@sql1 VARCHAR(MAX),@sql2 VARCHAR(MAX),@sql3 VARCHAR(MAX), @sql4 VARCHAR(MAX)
DECLARE @hour INT


IF @as_of_date IS NULL
BEGIN
	SET @hour=DATEPART(hour,GETDATE())
	IF @hour>= 0 AND @hour<=19
		SET @as_of_date=CONVERT(VARCHAR(10),getdate()-1,120)
	ELSE
		SET @as_of_date=CONVERT(VARCHAR(10),getdate(),120)	
END	

	

	
IF OBJECT_ID(N'adiha_process.dbo.cube_position_report', N'U') IS NOT NULL
	DROP TABLE adiha_process.dbo.cube_position_report

IF OBJECT_ID(N'tempdb..#books', N'U') IS NOT NULL
	DROP TABLE #books

IF OBJECT_ID(N'tempdb..#udt', N'U') IS NOT NULL
	DROP TABLE #udt

IF OBJECT_ID(N'tempdb..#tmp_block', N'U') IS NOT NULL
	DROP TABLE #tmp_block
		
IF OBJECT_ID(N'tempdb..#tmp_block_udf', N'U') IS NOT NULL
	DROP TABLE #tmp_block_udf	
	
IF OBJECT_ID(N'adiha_process.dbo.cube_position_report_fin', N'U') IS NOT NULL
	DROP TABLE adiha_process.dbo.cube_position_report_fin
	
IF OBJECT_ID(N'adiha_process.dbo.cube_position_report_phy', N'U') IS NOT NULL
	DROP TABLE adiha_process.dbo.cube_position_report_phy

IF OBJECT_ID(N'adiha_process.dbo.cube_position_report_hourly', N'U') IS NOT NULL
	DROP TABLE adiha_process.dbo.cube_position_report_hourly

IF OBJECT_ID(N'adiha_process.dbo.temp_position', N'U') IS NOT NULL
	DROP TABLE adiha_process.dbo.temp_position
	
IF OBJECT_ID(N'adiha_process.dbo.unpvt', N'U') IS NOT NULL
	DROP TABLE adiha_process.dbo.unpvt

DECLARE @baseload_block_type varchar(30),@baseload_block_define_id varchar(30)

SET @baseload_block_type = '12000'	-- Internal Static Data
SELECT @baseload_block_define_id = CAST(value_id as VARCHAR(10)) FROM static_data_value WHERE [type_id] = 10018 AND code LIKE 'Base Load' -- External Static Data
IF @baseload_block_define_id IS NULL 
	SET @baseload_block_define_id = 'NULL'
	
CREATE TABLE #books (book_deal_type_map_id INT, fas_book_id INT, source_system_book_id1 INT ,source_system_book_id2 INT,source_system_book_id3 INT,source_system_book_id4 INT)    

INSERT INTO  #books   
	SELECT DISTINCT 
		ssbm.book_deal_type_map_id,
		book.entity_id,
		ssbm.source_system_book_id1,
		ssbm.source_system_book_id2,
		ssbm.source_system_book_id3,
		ssbm.source_system_book_id4 fas_book_id
	 FROM portfolio_hierarchy book (NOLOCK) 
		  INNER JOIN Portfolio_hierarchy stra (NOLOCK) ON book.parent_entity_id = stra.entity_id 
	      INNER JOIN source_system_book_map ssbm ON ssbm.fas_book_id = book.entity_id   
	WHERE (fas_deal_type_value_id IS NULL OR fas_deal_type_value_id BETWEEN 400 AND 401)   
		--	and book.entity_id=162 
			 --AND stra.parent_entity_id IN (148,149) 


--EXEC spa_print getdate()	
	
select hb.*
 into #tmp_block
from (
select isnull(spcd.block_define_id,@baseload_block_define_id) block_define_id,MIN(term_start) term_start, Max(term_end) term_end from report_hourly_position_breakdown s
left JOIN source_price_curve_def spcd with (nolock) ON spcd.source_curve_def_id=s.curve_id 
where  s.deal_date<=@as_of_date
group by isnull(spcd.block_define_id,@baseload_block_define_id)
) b
cross apply	
	( select block_define_id,term_date,Hr1,Hr2,Hr3,Hr4,Hr5,Hr6,Hr7,Hr8,Hr9,Hr10,Hr11,Hr12,
		Hr13,Hr14,Hr15,Hr16,Hr17,Hr18,Hr19,Hr20,Hr21,Hr22,Hr23,Hr24,volume_mult,add_dst_hour from hour_block_term h with (nolock) where term_date between b.term_start  and b.term_end -- and term_date>@as_of_date
		and  block_type=12000 and block_define_id=b.block_define_id	and volume_mult>0
		  
	) hb 
	

	
select hb.*
 into #tmp_block_udf
from (
select isnull(grp.hourly_block_id,@baseload_block_define_id) block_define_id, min(term_start) term_start, Max(term_end) term_end from report_hourly_position_breakdown s
inner JOIN source_price_curve_def spcd with (nolock) ON spcd.source_curve_def_id=s.curve_id and spcd.udf_block_group_id is not null
left join block_type_group grp ON spcd.udf_block_group_id=grp.block_type_group_id 
where  s.deal_date<=@as_of_date
group by isnull(grp.hourly_block_id,@baseload_block_define_id)
) b
cross apply	
	( select block_define_id,term_date,Hr1,Hr2,Hr3,Hr4,Hr5,Hr6,Hr7,Hr8,Hr9,Hr10,Hr11,Hr12,
		Hr13,Hr14,Hr15,Hr16,Hr17,Hr18,Hr19,Hr20,Hr21,Hr22,Hr23,Hr24,volume_mult,add_dst_hour from hour_block_term h with (nolock) where term_date between b.term_start  and b.term_end
		and  block_type=12000 and block_define_id=b.block_define_id	and volume_mult>0
		  
	) hb 

create index indx_aaaaaaaaaa on #tmp_block ( block_define_id,term_date)
create index indx_aaaaaaaaaa_udf on #tmp_block_udf ( block_define_id,term_date)


if OBJECT_ID('adiha_process.dbo.report_hourly_position_breakdown') is not null
	drop table adiha_process.dbo.report_hourly_position_breakdown

select 	rowid=identity(int,1,1),s.physical_financial_flag,s.[curve_id],s.[term_start] ,s.expiration_date,s.deal_volume_uom_id
	,bk.book_deal_type_map_id,s.[deal_status_id],s.[counterparty_id],s.formula,s.term_end
	,sum(s.calc_volume) calc_volume,bk.fas_book_id,sdh.template_id,sdh.trader_id,sdh.source_deal_type_id,sdh.broker_id
	,s.commodity_id, sdh.internal_desk_id AS profile_id,sdh.internal_portfolio_id product_id,sdh.contract_id,sdh.header_buy_sell_flag buy_sell_flag
into adiha_process.dbo.report_hourly_position_breakdown
from report_hourly_position_breakdown s  (nolock)
	inner JOIN source_deal_header sdh  ON s.source_deal_header_id=sdh.source_deal_header_id AND sdh.deal_date<=@as_of_date  
	INNER JOIN [deal_status_group] dsg ON dsg.status_value_id = s.deal_status_id  
	INNER JOIN #books bk ON bk.fas_book_id=s.fas_book_id 
				AND bk.source_system_book_id1=s.source_system_book_id1	
				AND bk.source_system_book_id2=s.source_system_book_id2 
				AND bk.source_system_book_id3=s.source_system_book_id3
				AND bk.source_system_book_id4=s.source_system_book_id4	
--WHERE sdh.source_deal_header_id=114156					
	GROUP BY s.[curve_id], s.commodity_id,s.[term_start],bk.book_deal_type_map_id, sdh.broker_id, sdh.internal_desk_id, sdh.source_deal_type_id
		, sdh.trader_id, sdh.contract_id, sdh.template_id, s.deal_status_id, s.counterparty_id,s.term_end
	,s.physical_financial_flag,s.expiration_date,s.deal_volume_uom_id,s.formula,sdh.internal_portfolio_id ,bk.fas_book_id,sdh.header_buy_sell_flag

create index indx_rowid_report_hourly_position_breakdown on adiha_process.dbo.report_hourly_position_breakdown(rowid)
create index indx_curve_report_hourly_position_breakdown on adiha_process.dbo.report_hourly_position_breakdown(curve_id,term_start,term_end)

SET @sql = 'SELECT 	s.curve_id,	s.term_start, ISNULL(spcd.display_uom_id,spcd.uom_id) deal_volume_uom_id,s.physical_financial_flag,s.commodity_id,	s.counterparty_id,s.fas_book_id,''n'' AS is_fixedvolume,
			deal_status_id,	bk.book_deal_type_map_id, sdh.internal_desk_id AS profile_id,sdh.internal_portfolio_id product_id	, sml.region
			, sml.grid_value_id grid, sml.country,sdd.category category_id	,MAX(sdh.header_buy_sell_flag) buy_sell_flag,s.expiration_date, sdd.pv_party  pv_party_id,sdh.broker_id, sdh.source_deal_type_id, sdh.trader_id,sdh.contract_id, sdh.template_id
			,cast(sum(s.hr1) as numeric(26,10)) hr1,cast(sum(s.hr2) as numeric(26,10)) hr2 ,cast(sum(s.hr3) as numeric(26,10)) hr3 ,cast(sum(s.hr4) as numeric(26,10)) hr4 ,cast(sum(s.hr5) as numeric(26,10)) hr5 ,cast(sum(s.hr6) as numeric(26,10)) hr6 ,cast(sum(s.hr7) as numeric(26,10)) hr7 ,cast(sum(s.hr8) as numeric(26,10)) hr8
			,cast(sum(s.hr9) as numeric(26,10)) hr9 ,cast(sum(s.hr10) as numeric(26,10)) hr10 ,cast(sum(s.hr11) as numeric(26,10)) hr11 ,cast(sum(s.hr12) as numeric(26,10)) hr12 ,cast(sum(s.hr13) as numeric(26,10)) hr13 ,cast(sum(s.hr14) as numeric(26,10)) hr14 ,cast(sum(s.hr15) as numeric(26,10)) hr15 ,cast(sum(s.hr16) as numeric(26,10)) hr16
			,cast(sum(s.hr17) as numeric(26,10)) hr17 ,cast(sum(s.hr18) as numeric(26,10)) hr18 ,cast(sum(s.hr19) as numeric(26,10)) hr19 ,cast(sum(s.hr20) as numeric(26,10)) hr20 ,cast(sum(s.hr21 ) as numeric(26,10)) hr21 ,cast(sum(s.hr22 ) as numeric(26,10)) hr22 ,cast(sum(s.hr23) as numeric(26,10)) hr23 ,cast(sum(s.hr24) as numeric(26,10)) hr24			
			,cast(sum(s.hr25) as numeric(26,10)) hr25,max(spcd.udf_block_group_id) udf_block_group_id,MAX(spcd.block_define_id) block_define_id
		INTO  adiha_process.dbo.temp_position
		FROM report_hourly_position_deal s  
			INNER JOIN [deal_status_group] dsg ON dsg.status_value_id = s.deal_status_id  -- and 1=0
			inner join source_deal_header sdh on sdh.source_deal_header_id =s.source_deal_header_id
			inner join source_deal_detail sdd on s.term_start BETWEEN sdd.term_start AND sdd.term_end 
					AND s.source_deal_detail_id=sdd.source_deal_detail_id
			INNER JOIN #books bk ON bk.fas_book_id=s.fas_book_id AND bk.source_system_book_id1=s.source_system_book_id1	
				AND bk.source_system_book_id2=s.source_system_book_id2 AND bk.source_system_book_id3=s.source_system_book_id3
				AND bk.source_system_book_id4=s.source_system_book_id4 and s.expiration_date>'''+@as_of_date+''' AND s.term_start>'''+@as_of_date+''' 	AND s.deal_date<='''+@as_of_date+'''				
			left join source_minor_location sml on s.location_id=sml.source_minor_location_id
			left JOIN source_price_curve_def spcd with (nolock) ON spcd.source_curve_def_id=s.curve_id
		--WHERE s.source_deal_header_id=114156	 
		GROUP BY s.[curve_id], s.commodity_id,s.[term_start],bk.book_deal_type_map_id, sdh.broker_id, sdh.internal_desk_id, sdh.source_deal_type_id
			, sdh.trader_id, sdh.contract_id,sdh.internal_portfolio_id, sdh.template_id, s.deal_status_id, s.counterparty_id
			,s.physical_financial_flag, sdd.pv_party, ISNULL(spcd.display_uom_id,spcd.uom_id),sml.region, sml.grid_value_id , sml.country
			,sdd.category, sdd.buy_sell_flag ,	s.expiration_date	,s.fas_book_id		
	UNION ALL 
		SELECT s.curve_id,	s.term_start, ISNULL(spcd.display_uom_id,spcd.uom_id) deal_volume_uom_id,s.physical_financial_flag,s.commodity_id,	s.counterparty_id,s.fas_book_id,''n'' AS is_fixedvolume,
			deal_status_id,	bk.book_deal_type_map_id, sdh.internal_desk_id AS profile_id,sdh.internal_portfolio_id product_id	, sml.region
			, sml.grid_value_id grid, sml.country,sdd.category category_id	,MAX(sdh.header_buy_sell_flag) buy_sell_flag,s.expiration_date, sdd.pv_party  pv_party_id,sdh.broker_id, sdh.source_deal_type_id, sdh.trader_id,sdh.contract_id, sdh.template_id
			,cast(sum(s.hr1) as numeric(26,10)) hr1,cast(sum(s.hr2) as numeric(26,10)) hr2 ,cast(sum(s.hr3) as numeric(26,10)) hr3 ,cast(sum(s.hr4) as numeric(26,10)) hr4 ,cast(sum(s.hr5) as numeric(26,10)) hr5 ,cast(sum(s.hr6) as numeric(26,10)) hr6 ,cast(sum(s.hr7) as numeric(26,10)) hr7 ,cast(sum(s.hr8) as numeric(26,10)) hr8
			,cast(sum(s.hr9) as numeric(26,10)) hr9 ,cast(sum(s.hr10) as numeric(26,10)) hr10 ,cast(sum(s.hr11) as numeric(26,10)) hr11 ,cast(sum(s.hr12) as numeric(26,10)) hr12 ,cast(sum(s.hr13) as numeric(26,10)) hr13 ,cast(sum(s.hr14) as numeric(26,10)) hr14 ,cast(sum(s.hr15) as numeric(26,10)) hr15 ,cast(sum(s.hr16) as numeric(26,10)) hr16
			,cast(sum(s.hr17) as numeric(26,10)) hr17 ,cast(sum(s.hr18) as numeric(26,10)) hr18 ,cast(sum(s.hr19) as numeric(26,10)) hr19 ,cast(sum(s.hr20) as numeric(26,10)) hr20 ,cast(sum(s.hr21 ) as numeric(26,10)) hr21 ,cast(sum(s.hr22 ) as numeric(26,10)) hr22 ,cast(sum(s.hr23) as numeric(26,10)) hr23 ,cast(sum(s.hr24) as numeric(26,10)) hr24			
			,cast(sum(s.hr25) as numeric(26,10)) hr25,max(spcd.udf_block_group_id) udf_block_group_id,MAX(spcd.block_define_id) block_define_id
	   FROM 
			report_hourly_position_profile s  
			INNER JOIN [deal_status_group] dsg ON dsg.status_value_id = s.deal_status_id   --and 1=0
			inner join source_deal_header sdh on sdh.source_deal_header_id =s.source_deal_header_id
			inner join source_deal_detail sdd on s.term_start BETWEEN sdd.term_start AND sdd.term_end 
				AND s.source_deal_detail_id=sdd.source_deal_detail_id
			INNER JOIN #books bk ON bk.fas_book_id=s.fas_book_id 
				AND bk.source_system_book_id1=s.source_system_book_id1	AND bk.source_system_book_id2=s.source_system_book_id2 
				AND bk.source_system_book_id3=s.source_system_book_id3 AND bk.source_system_book_id4=s.source_system_book_id4		
				and s.expiration_date>'''+@as_of_date+''' AND s.term_start>'''+@as_of_date+''' 	AND s.deal_date<='''+@as_of_date+'''				
			left join source_minor_location sml on s.location_id=sml.source_minor_location_id
			left JOIN source_price_curve_def spcd with (nolock) ON spcd.source_curve_def_id=s.curve_id
		--WHERE s.source_deal_header_id=114156	
		GROUP BY s.[curve_id], s.commodity_id,s.[term_start],bk.book_deal_type_map_id, sdh.broker_id, sdh.internal_desk_id, sdh.source_deal_type_id
			, sdh.trader_id, sdh.contract_id,sdh.internal_portfolio_id, sdh.template_id, s.deal_status_id, s.counterparty_id
			,s.physical_financial_flag, sdd.pv_party, ISNULL(spcd.display_uom_id,spcd.uom_id) ,sml.region, sml.grid_value_id , sml.country
			,sdd.category, sdd.buy_sell_flag,s.expiration_date,s.fas_book_id
	'		 

SET @sql1='UNION ALL 
		SELECT s.curve_id,	hb.term_date, ISNULL(spcd.display_uom_id,spcd.uom_id) deal_volume_uom_id,s.physical_financial_flag,s.commodity_id,	s.counterparty_id,s.fas_book_id,''y'' AS is_fixedvolume,
			s.deal_status_id,	s.book_deal_type_map_id,s.profile_id,s.product_id	,null region, null grid,null country, null category_id	, s.buy_sell_flag buy_sell_flag
			,CASE WHEN s.formula IN(''dbo.FNACurveH'',''dbo.FNACurveD'') THEN ISNULL(hg.exp_date,hb.term_date) WHEN ISNULL(spcd.hourly_volume_allocation,17601) IN(17603,17604) THEN ISNULL(hg.exp_date,s.expiration_date) ELSE s.expiration_date END expiration_date,null  pv_party_id,s.broker_id, s.source_deal_type_id, s.trader_id,s.contract_id, s.template_id 
			,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr1,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=1 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))/cast(nullif(isnull(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) as numeric(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,'''+@as_of_date+''')) AS VARCHAR)+''-''+CAST(MONTH(DATEADD(m,1,'''+@as_of_date+''')) AS VARCHAR)+''-01'' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  AS Hr1
			,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr2,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=2 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))/cast(nullif(isnull(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) as numeric(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,'''+@as_of_date+''')) AS VARCHAR)+''-''+CAST(MONTH(DATEADD(m,1,'''+@as_of_date+''')) AS VARCHAR)+''-01'' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  AS Hr2
			,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr3,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=3 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))/cast(nullif(isnull(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) as numeric(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,'''+@as_of_date+''')) AS VARCHAR)+''-''+CAST(MONTH(DATEADD(m,1,'''+@as_of_date+''')) AS VARCHAR)+''-01'' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  AS Hr3
			,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr4,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=4 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))/cast(nullif(isnull(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) as numeric(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,'''+@as_of_date+''')) AS VARCHAR)+''-''+CAST(MONTH(DATEADD(m,1,'''+@as_of_date+''')) AS VARCHAR)+''-01'' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  AS Hr4
			,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr5,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=5 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))/cast(nullif(isnull(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) as numeric(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,'''+@as_of_date+''')) AS VARCHAR)+''-''+CAST(MONTH(DATEADD(m,1,'''+@as_of_date+''')) AS VARCHAR)+''-01'' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  AS Hr5
			,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr6,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=6 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))/cast(nullif(isnull(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) as numeric(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,'''+@as_of_date+''')) AS VARCHAR)+''-''+CAST(MONTH(DATEADD(m,1,'''+@as_of_date+''')) AS VARCHAR)+''-01'' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  AS Hr6
			,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr7,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=7 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))/cast(nullif(isnull(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) as numeric(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,'''+@as_of_date+''')) AS VARCHAR)+''-''+CAST(MONTH(DATEADD(m,1,'''+@as_of_date+''')) AS VARCHAR)+''-01'' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  AS Hr7
			,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr8,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=8 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))/cast(nullif(isnull(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) as numeric(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,'''+@as_of_date+''')) AS VARCHAR)+''-''+CAST(MONTH(DATEADD(m,1,'''+@as_of_date+''')) AS VARCHAR)+''-01'' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  AS Hr8
			,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr9,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=9 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))/cast(nullif(isnull(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) as numeric(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,'''+@as_of_date+''')) AS VARCHAR)+''-''+CAST(MONTH(DATEADD(m,1,'''+@as_of_date+''')) AS VARCHAR)+''-01'' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  AS Hr9
			,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr10,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=10 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))/cast(nullif(isnull(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) as numeric(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,'''+@as_of_date+''')) AS VARCHAR)+''-''+CAST(MONTH(DATEADD(m,1,'''+@as_of_date+''')) AS VARCHAR)+''-01'' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  AS Hr10'
		
SET @sql2=',(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr11,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=11 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))/cast(nullif(isnull(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) as numeric(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,'''+@as_of_date+''')) AS VARCHAR)+''-''+CAST(MONTH(DATEADD(m,1,'''+@as_of_date+''')) AS VARCHAR)+''-01'' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  AS Hr11
			,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr12,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=12 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))/cast(nullif(isnull(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) as numeric(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,'''+@as_of_date+''')) AS VARCHAR)+''-''+CAST(MONTH(DATEADD(m,1,'''+@as_of_date+''')) AS VARCHAR)+''-01'' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  AS Hr12
			,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr13,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=13 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))/cast(nullif(isnull(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) as numeric(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,'''+@as_of_date+''')) AS VARCHAR)+''-''+CAST(MONTH(DATEADD(m,1,'''+@as_of_date+''')) AS VARCHAR)+''-01'' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  AS Hr13
			,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr14,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=14 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))/cast(nullif(isnull(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) as numeric(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,'''+@as_of_date+''')) AS VARCHAR)+''-''+CAST(MONTH(DATEADD(m,1,'''+@as_of_date+''')) AS VARCHAR)+''-01'' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  AS Hr14
			,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr15,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=15 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))/cast(nullif(isnull(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) as numeric(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,'''+@as_of_date+''')) AS VARCHAR)+''-''+CAST(MONTH(DATEADD(m,1,'''+@as_of_date+''')) AS VARCHAR)+''-01'' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  AS Hr15
			,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr16,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=16 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))/cast(nullif(isnull(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) as numeric(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,'''+@as_of_date+''')) AS VARCHAR)+''-''+CAST(MONTH(DATEADD(m,1,'''+@as_of_date+''')) AS VARCHAR)+''-01'' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  AS Hr16
			,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr17,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=17 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))/cast(nullif(isnull(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) as numeric(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,'''+@as_of_date+''')) AS VARCHAR)+''-''+CAST(MONTH(DATEADD(m,1,'''+@as_of_date+''')) AS VARCHAR)+''-01'' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  AS Hr17
			,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr18,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=18 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))/cast(nullif(isnull(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) as numeric(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,'''+@as_of_date+''')) AS VARCHAR)+''-''+CAST(MONTH(DATEADD(m,1,'''+@as_of_date+''')) AS VARCHAR)+''-01'' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  AS Hr18
			,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr19,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=19 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))/cast(nullif(isnull(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) as numeric(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,'''+@as_of_date+''')) AS VARCHAR)+''-''+CAST(MONTH(DATEADD(m,1,'''+@as_of_date+''')) AS VARCHAR)+''-01'' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  AS Hr19
			,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr20,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=20 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))/cast(nullif(isnull(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) as numeric(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,'''+@as_of_date+''')) AS VARCHAR)+''-''+CAST(MONTH(DATEADD(m,1,'''+@as_of_date+''')) AS VARCHAR)+''-01'' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  AS Hr20
			,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr21,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=21 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))/cast(nullif(isnull(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) as numeric(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,'''+@as_of_date+''')) AS VARCHAR)+''-''+CAST(MONTH(DATEADD(m,1,'''+@as_of_date+''')) AS VARCHAR)+''-01'' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  AS Hr21
			,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr22,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=22 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))/cast(nullif(isnull(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) as numeric(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,'''+@as_of_date+''')) AS VARCHAR)+''-''+CAST(MONTH(DATEADD(m,1,'''+@as_of_date+''')) AS VARCHAR)+''-01'' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  AS Hr22
			,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr23,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=23 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))/cast(nullif(isnull(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) as numeric(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,'''+@as_of_date+''')) AS VARCHAR)+''-''+CAST(MONTH(DATEADD(m,1,'''+@as_of_date+''')) AS VARCHAR)+''-01'' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  AS Hr23
			,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr24,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=24 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))/cast(nullif(isnull(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) as numeric(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,'''+@as_of_date+''')) AS VARCHAR)+''-''+CAST(MONTH(DATEADD(m,1,'''+@as_of_date+''')) AS VARCHAR)+''-01'' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  AS Hr24
			,(cast(cast(s.calc_volume as numeric(22,10))* cast(CASE WHEN isnull(hb.add_dst_hour,0)<=0 THEN 0 ELSE 1 END as numeric(1,0)) as numeric(22,10))) /cast(nullif(isnull(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) as numeric(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,'''+@as_of_date+''')) AS VARCHAR)+''-''+CAST(MONTH(DATEADD(m,1,'''+@as_of_date+''')) AS VARCHAR)+''-01'' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END) AS Hr25'

	--TODO: Fix usage of 292037 - Baseload (local: 291890), it is hardcoded even it is external static data
SET @sql3='	 ,spcd.udf_block_group_id,spcd.block_define_id block_define_id from 
			adiha_process.dbo.report_hourly_position_breakdown s  (nolock)
			left JOIN source_price_curve_def spcd with (nolock) ON spcd.source_curve_def_id=s.curve_id 
			LEFT JOIN source_price_curve_def spcd1 (nolock) On spcd1.source_curve_def_id=spcd.settlement_curve_id
			outer apply (select sum(volume_mult) term_no_hrs from #tmp_block hbt where isnull(spcd.hourly_volume_allocation,17601) <17603 and hbt.block_define_id=COALESCE(spcd.block_define_id,'+@baseload_block_define_id+')	 and hbt.term_date between s.term_start  and s.term_END ) term_hrs
			outer apply ( select sum(volume_mult) term_no_hrs from #tmp_block hbt inner join (select distinct exp_date from holiday_group h where  h.hol_group_value_id=ISNULL(spcd.exp_calendar_id,spcd1.exp_calendar_id) and h.exp_date between s.term_start  and s.term_END ) ex on ex.exp_date=hbt.term_date
				and  isnull(spcd.hourly_volume_allocation,17601) IN(17603,17604) and hbt.block_define_id=COALESCE(spcd.block_define_id,'+@baseload_block_define_id+')	) term_hrs_exp
			outer apply	( select * from #tmp_block h with (nolock) where block_define_id=COALESCE(spcd.block_define_id,'+@baseload_block_define_id+')	
				 and term_date between s.term_start  and s.term_end ) hb 
			 '	
	
SET @sql4='	 outer apply  (select MAX(exp_date) exp_date from holiday_group h where h.hol_date=hb.term_date AND 
			  h.hol_group_value_id=ISNULL(spcd.exp_calendar_id,spcd1.exp_calendar_id) and h.hol_date between s.term_start  and s.term_END AND COALESCE(spcd1.ratio_option,spcd.ratio_option,-1) <> 18800 ) hg   
			 outer apply  (select MIN(exp_date) hol_date ,MAX(exp_date) hol_date_to  from holiday_group h where 1=1 AND h.hol_group_value_id=ISNULL(spcd.exp_calendar_id,spcd1.exp_calendar_id) and h.hol_date between s.term_start  and s.term_END AND s.formula NOT IN(''REBD'')) hg1   
			 outer apply  (select count(exp_date) total_days,SUM(CASE WHEN h.exp_date>'''+@as_of_date+''' THEN 1 else 0 END) remain_days from holiday_group h where h.hol_group_value_id=ISNULL(spcd.exp_calendar_id,spcd1.exp_calendar_id) 
						AND h.exp_date BETWEEN hg1.hol_date AND ISNULL(hg1.hol_date_to,dbo.FNALastDayInDate(hg1.hol_date))
						AND ISNULL(spcd1.ratio_option,spcd.ratio_option) = 18800 AND s.formula NOT IN(''REBD'')) remain_month  
			WHERE	
		     ((ISNULL(spcd1.ratio_option,spcd.ratio_option) = 18800 AND ISNULL(hg1.hol_date_to,''9999-01-01'')>'''+@as_of_date+''') OR COALESCE(spcd1.ratio_option,spcd.ratio_option,-1) <> 18800)
		     AND ((isnull(spcd.hourly_volume_allocation,17601) IN(17603,17604) and  hg.exp_date is not null) or (isnull(spcd.hourly_volume_allocation,17601)<17603 ))		           
		  		   and CASE WHEN s.formula IN(''dbo.FNACurveH'',''dbo.FNACurveD'') THEN ISNULL(hg.exp_date,hb.term_date) WHEN ISNULL(spcd.hourly_volume_allocation,17601) IN(17603,17604) THEN ISNULL(hg.exp_date,s.expiration_date) ELSE s.expiration_date END>'''+@as_of_date+'''
	'


--EXEC spa_print getdate()


EXEC spa_print @sql
EXEC spa_print @sql1
EXEC spa_print @sql2
EXEC spa_print @sql3
EXEC spa_print @sql4
EXEC(@sql+@sql1+@sql2+@sql3+@sql4)



create index  indx_temp_position_11 on  adiha_process.dbo.temp_position(curve_id,term_start,expiration_date)
	include (hr1,hr2,hr3,hr4,hr5,hr6,hr7,hr8,hr9,hr10,hr11,hr12,hr13,hr14,hr15,hr16,hr17,hr18,hr19,hr20,hr21,hr22,hr23,hr24)

--EXEC spa_print getdate()	
EXEC spa_print 'create   adiha_process.dbo.unpv...'

select distinct upv.udf_block_group_id ,upv.block_id, upv.term_start,cast(substring(upv.hr,3,2) AS INT) Hr
into #udt
from (
select p.udf_block_group_id,p.block_id ,p.term_start ,
	hb.hr1,hb.hr2,hb.hr3,hb.hr4,hb.hr5,hb.hr6,hb.hr7,hb.hr8,hb.hr9,hb.hr10,hb.hr11,hb.hr12,hb.hr13,hb.hr14,hb.hr15,hb.hr16
	,hb.hr17,hb.hr18,hb.hr19,hb.hr20,hb.hr21,hb.hr22,hb.hr23,hb.hr24
 from (
		select distinct grp.id udf_block_group_id,a.udf_block_group_id block_id, a.term_start,hourly_block_id from adiha_process.dbo.temp_position a  
		inner join block_type_group grp ON a.udf_block_group_id=grp.block_type_group_id 
		and a.udf_block_group_id is not null
			
	) p
	inner join  hour_block_term hb  ON hb.block_define_id=p.hourly_block_id and isnull(hb.block_type,12000)=12000
			and p.term_start=hb.term_date
) s
	UNPIVOT
	(on_off for Hr IN (hr1,hr2,hr3,hr4,hr5,hr6,hr7,hr8,hr9,hr10,hr11,hr12,hr13,hr14,hr15,hr16,hr17,hr18,hr19,hr20,hr21,hr22,hr23,hr24)	
) upv	
where on_off=1

create index indx_udt_aaa on #udt (term_start ,hr,block_id )


select 	unpvt.[Index]
		, unpvt.book_deal_type_map_id
		, unpvt.broker_id
		, unpvt.profile_id
		, unpvt.source_deal_type_id
		, unpvt.trader_id
		, unpvt.contract_id
		, unpvt.product_id
		, unpvt.template_id
		, unpvt.deal_status			
		, unpvt.counterparty_id
		, unpvt.block_define_id block_defintion_id
		, t.udf_block_group_id udf_block_group_id
		, -1 location_id
		, unpvt.[physical/Financial]
		, unpvt.pv_party_id
		, unpvt.Volume [Position]
		, unpvt.uom_id
		, unpvt.region
		, unpvt.grid
		, unpvt.country 
		, unpvt.category_id
		,unpvt.buy_sell_flag
	, CASE WHEN unpvt.commodity_id=-1 AND is_fixedvolume ='n' and unpvt.hr > 18 THEN DATEADD(DAY, 1, unpvt.term_start) ELSE unpvt.term_start END [Term]
 ,case when unpvt.commodity_id=-1 AND is_fixedvolume ='n' then 
        CASE WHEN unpvt.hr<= 18 THEN unpvt.hr + 6
              WHEN unpvt.hr =25  THEN 3
              WHEN unpvt.hr >=19  THEN unpvt.hr -18
             else unpvt.hr
         END 
   else
		CASE WHEN unpvt.hr = 25 THEN 3 else	unpvt.hr 
	end
end  AS [Hour],
CASE WHEN unpvt.hr = 25 THEN 1 else 0 end DST
INTO  adiha_process.dbo.cube_position_report_hourly
 FROM ( 
	SELECT 
		s.curve_id [Index], s.commodity_id, s.term_start, s.book_deal_type_map_id, s.broker_id, s.profile_id, s.source_deal_type_id
		, s.trader_id, s.contract_id, s.product_id, s.template_id, s.deal_status_id deal_status, s.counterparty_id, s.pv_party_id, s.buy_sell_flag
		,s.physical_financial_flag [Physical/Financial], s.deal_volume_uom_id uom_id, s.region, s.grid , s.country 	, s.category_id,s.is_fixedvolume
		, udf_block_group_id,MAX(block_define_id) block_define_id,
		CAST(SUM( s.hr1) AS NUMERIC(38,20)) [1]	, CAST(SUM( s.hr2) AS NUMERIC(38,20)) [2]
		, CAST(SUM( s.hr3  - CASE WHEN not (s.commodity_id=-1 and is_fixedvolume='n') THEN ISNULL(s.hr25, 0) ELSE 0 END) AS NUMERIC(38,20)) [3]
		, CAST(SUM( s.hr4) AS NUMERIC(38,20)) [4]	, CAST(SUM( s.hr5) AS NUMERIC(38,20)) [5]
		, CAST(SUM( s.hr6 ) AS NUMERIC(38,20)) [6]	, CAST(SUM( s.hr7) AS NUMERIC(38,20)) [7]
		, CAST(SUM( s.hr8) AS NUMERIC(38,20)) [8]	, CAST(SUM( s.hr9) AS NUMERIC(38,20)) [9]
		, CAST(SUM( s.hr10) AS NUMERIC(38,20)) [10]	, CAST(SUM( s.hr11) AS NUMERIC(38,20)) [11]
		, CAST(SUM( s.hr12) AS NUMERIC(38,20)) [12]	, CAST(SUM( s.hr13) AS NUMERIC(38,20)) [13]
		, CAST(SUM( s.hr14) AS NUMERIC(38,20)) [14]	, CAST(SUM( s.hr15) AS NUMERIC(38,20)) [15]
		, CAST(SUM( s.hr16) AS NUMERIC(38,20)) [16]	, CAST(SUM( s.hr17) AS NUMERIC(38,20)) [17]	, CAST(SUM( s.hr18) AS NUMERIC(38,20)) [18]
		, CAST(SUM( s.hr19) AS NUMERIC(38,20)) [19]	, CAST(SUM( s.hr20) AS NUMERIC(38,20)) [20]
		, CAST(SUM( s.hr21  - CASE WHEN s.commodity_id = -1 and is_fixedvolume='n' THEN ISNULL(s.hr25, 0) ELSE 0 END) AS NUMERIC(38,20)) [21]
		, CAST(SUM( s.hr22) AS NUMERIC(38,20)) [22]	, CAST(SUM( s.hr23) AS NUMERIC(38,20)) [23]
		, CAST(SUM( s.hr24) AS NUMERIC(38,20)) [24]	, CAST(SUM(s.hr25) AS NUMERIC(38,20)) [25]
		--,SUM( s.hr21) v21, SUM( s.hr25) v22,SUM( s.hr21-s.hr25) v22a
	FROM adiha_process.dbo.temp_position s  where s.term_start > @as_of_date and s.expiration_date> @as_of_date--@as_of_date
	GROUP BY s.curve_id , s.commodity_id, s.term_start, s.book_deal_type_map_id, s.broker_id, s.profile_id, s.source_deal_type_id
		, s.trader_id, s.contract_id, s.product_id, s.template_id, s.deal_status_id, s.counterparty_id, s.pv_party_id, s.buy_sell_flag
		,s.physical_financial_flag, s.deal_volume_uom_id, s.region, s.grid , s.country 	, s.category_id	,s.is_fixedvolume, udf_block_group_id
) p
UNPIVOT
	(Volume FOR [Hr] IN
		([1], [2], [3], [4], [5], [6], [7], [8], [9], [10], [11], [12], [13], [14], [15], [16], [17], [18], [19], [20], [21], [22], [23], [24], [25])
	) AS unpvt
	left join #udt t on unpvt.udf_block_group_id =t.block_id and t.term_start= CASE WHEN unpvt.commodity_id=-1 AND unpvt.is_fixedvolume ='n' and unpvt.hr > 18 THEN DATEADD(DAY, 1, unpvt.term_start) ELSE unpvt.term_start END
	and t.hr=    case when unpvt.commodity_id=-1 AND unpvt.is_fixedvolume ='n' then 
				CASE WHEN unpvt.hr<= 18 THEN unpvt.hr + 6
					  WHEN unpvt.hr =25  THEN 3
					  WHEN unpvt.hr >=19  THEN unpvt.hr -18
					 else unpvt.hr
				 END 
		   else
				CASE WHEN unpvt.hr = 25 THEN 3 else	unpvt.hr 
			end
		end  
	WHERE  not (unpvt.hr=25 and unpvt.Volume=0 ) 
	

--EXEC spa_print getdate()

EXEC spa_print '[[[[[[[[[[[[[Start monthly position]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]'

	
SET @sql = 'SELECT 	s.source_deal_header_id,convert(varchar(7),s.term_start,120)+''-01'' Term,s.curve_id, max(ISNULL(spcd.display_uom_id,spcd.uom_id)) uom_id
			,s.physical_financial_flag [physical/Financial],max(s.commodity_id) commodity_id,	max(s.counterparty_id) counterparty_id,max(bk.fas_book_id) fas_book_id
			,max(bk.book_deal_type_map_id) book_deal_type_map_id , max(sdh.internal_desk_id) AS profile_id,max(sdh.internal_portfolio_id) product_id	
			, max(sml.region) region, max(sml.grid_value_id) grid, max(sml.country) country,sdd.category category_id,MAX(sdh.header_buy_sell_flag) buy_sell_flag, sdd.pv_party pv_party_id
			,max(s.deal_status_id) deal_status_id,max(sdh.broker_id) broker_id, max(sdh.source_deal_type_id) source_deal_type_id
			, max(sdh.trader_id) trader_id,max(sdh.contract_id) contract_id, max(sdh.template_id) template_id
			,cast(sum(isnull(tou.hr1,1) *s.hr1+isnull(tou.hr2,1) *s.hr2+isnull(tou.hr3,1) *s.hr3+isnull(tou.hr4,1) *s.hr4+isnull(tou.hr5,1) *s.hr5+isnull(tou.hr6,1) *s.hr6
				+isnull(tou.hr7,1) *s.hr7+isnull(tou.hr8,1) *s.hr8+isnull(tou.hr9,1) *s.hr9+isnull(tou.hr10,1) *s.hr10+isnull(tou.hr11,1) *s.hr11
				+isnull(tou.hr12,1) *s.hr12+isnull(tou.hr13,1) *s.hr13+isnull(tou.hr14,1) *s.hr14
				+isnull(tou.hr15,1) *s.hr15+isnull(tou.hr16,1) *s.hr16+isnull(tou.hr17,1) *s.hr17+isnull(tou.hr18,1) *s.hr18+isnull(tou.hr19,1) *s.hr19
				+isnull(tou.hr20,1) *s.hr20+isnull(tou.hr21,1) *s.hr21+isnull(tou.hr22,1) *s.hr22+isnull(tou.hr23,1) *s.hr23+isnull(tou.hr24,1) *s.hr24) as numeric(26,10)) Position
			,max(spcd.udf_block_group_id) block_defintion_id, s.location_id ,tou.id udf_block_group_id,max(spcd.block_define_id) block_define_id
		INTO  adiha_process.dbo.cube_position_report_phy
		FROM report_hourly_position_deal s  
			INNER JOIN [deal_status_group] dsg ON dsg.status_value_id = s.deal_status_id  -- and 1=0
			inner join source_deal_header sdh on sdh.source_deal_header_id =s.source_deal_header_id
			inner join source_deal_detail sdd on s.term_start BETWEEN sdd.term_start AND sdd.term_end 
				AND s.source_deal_detail_id=sdd.source_deal_detail_id
			INNER JOIN #books bk ON bk.fas_book_id=s.fas_book_id AND bk.source_system_book_id1=s.source_system_book_id1	
				AND bk.source_system_book_id2=s.source_system_book_id2 AND bk.source_system_book_id3=s.source_system_book_id3
				AND bk.source_system_book_id4=s.source_system_book_id4 and s.expiration_date>'''+@as_of_date+''' AND s.term_start>'''+@as_of_date+''' 	AND s.deal_date<='''+@as_of_date+'''				
			left join source_minor_location sml on s.location_id=sml.source_minor_location_id
			left JOIN source_price_curve_def spcd with (nolock) ON spcd.source_curve_def_id=s.curve_id 
			outer apply (select grp.id,term_date,block_define_id,hr1,hr2,hr3,hr4,hr5,hr6,hr7,hr8,hr9,hr10,hr11,hr12,hr13,hr14,hr15,hr16,hr17,hr18,hr19,hr20,hr21,hr22,hr23,hr24  
				from block_type_group grp inner join #tmp_block_udf t ON t.block_define_id=grp.hourly_block_id and t.term_date=s.term_start
					and  spcd.udf_block_group_id=grp.block_type_group_id
			) tou
		GROUP BY s.source_deal_header_id,convert(varchar(7),s.term_start,120)+''-01'',s.[curve_id], s.physical_financial_flag, sdd.pv_party,sdd.category,s.location_id ,tou.id
	UNION ALL 
		SELECT 	s.source_deal_header_id,convert(varchar(7),s.term_start,120)+''-01'' Term,s.curve_id, max(ISNULL(spcd.display_uom_id,spcd.uom_id)) uom_id
			,s.physical_financial_flag [physical/Financial],max(s.commodity_id) commodity_id,	max(s.counterparty_id) counterparty_id,max(bk.fas_book_id) fas_book_id
			,max(bk.book_deal_type_map_id) book_deal_type_map_id , max(sdh.internal_desk_id) AS profile_id,max(sdh.internal_portfolio_id) product_id	
			, max(sml.region) region, max(sml.grid_value_id) grid, max(sml.country) country,sdd.category category_id,MAX(sdh.header_buy_sell_flag) buy_sell_flag, sdd.pv_party pv_party_id
			,max(s.deal_status_id) deal_status_id,max(sdh.broker_id) broker_id, max(sdh.source_deal_type_id) source_deal_type_id
			, max(sdh.trader_id) trader_id,max(sdh.contract_id) contract_id, max(sdh.template_id) template_id
				,cast(sum(isnull(tou.hr1,1) *s.hr1+isnull(tou.hr2,1) *s.hr2+isnull(tou.hr3,1) *s.hr3+isnull(tou.hr4,1) *s.hr4+isnull(tou.hr5,1) *s.hr5+isnull(tou.hr6,1) *s.hr6
				+isnull(tou.hr7,1) *s.hr7+isnull(tou.hr8,1) *s.hr8+isnull(tou.hr9,1) *s.hr9+isnull(tou.hr10,1) *s.hr10+isnull(tou.hr11,1) *s.hr11
				+isnull(tou.hr12,1) *s.hr12+isnull(tou.hr13,1) *s.hr13+isnull(tou.hr14,1) *s.hr14
				+isnull(tou.hr15,1) *s.hr15+isnull(tou.hr16,1) *s.hr16+isnull(tou.hr17,1) *s.hr17+isnull(tou.hr18,1) *s.hr18+isnull(tou.hr19,1) *s.hr19
				+isnull(tou.hr20,1) *s.hr20+isnull(tou.hr21,1) *s.hr21+isnull(tou.hr22,1) *s.hr22+isnull(tou.hr23,1) *s.hr23+isnull(tou.hr24,1) *s.hr24) as numeric(26,10)) Position
				,max(spcd.udf_block_group_id) block_defintion_id,s.location_id ,tou.id udf_block_group_id,max(spcd.block_define_id) block_define_id
	   FROM report_hourly_position_profile s  
			INNER JOIN [deal_status_group] dsg ON dsg.status_value_id = s.deal_status_id   --and 1=0
			inner join source_deal_header sdh on sdh.source_deal_header_id =s.source_deal_header_id
			inner join source_deal_detail sdd on s.term_start BETWEEN sdd.term_start AND sdd.term_end 
				AND s.source_deal_detail_id=sdd.source_deal_detail_id
			INNER JOIN #books bk ON bk.fas_book_id=s.fas_book_id 
				AND bk.source_system_book_id1=s.source_system_book_id1	AND bk.source_system_book_id2=s.source_system_book_id2 
				AND bk.source_system_book_id3=s.source_system_book_id3 AND bk.source_system_book_id4=s.source_system_book_id4		
				and s.expiration_date>'''+@as_of_date+''' AND s.term_start>'''+@as_of_date+''' 	AND s.deal_date<='''+@as_of_date+'''				
			left join source_minor_location sml on s.location_id=sml.source_minor_location_id
			left JOIN source_price_curve_def spcd with (nolock) ON spcd.source_curve_def_id=s.curve_id
			outer apply (select grp.id, term_date,block_define_id,hr1,hr2,hr3,hr4,hr5,hr6,hr7,hr8,hr9,hr10,hr11,hr12,hr13,hr14,hr15,hr16,hr17,hr18,hr19,hr20,hr21,hr22,hr23,hr24  
				from block_type_group grp inner join #tmp_block_udf t ON t.block_define_id=grp.hourly_block_id and t.term_date=s.term_start
					and  spcd.udf_block_group_id=grp.block_type_group_id
			) tou
		GROUP BY s.source_deal_header_id,convert(varchar(7),s.term_start,120)+''-01'',s.[curve_id], s.physical_financial_flag, sdd.pv_party,sdd.category,s.location_id ,tou.id
	'		 

	--EXEC spa_print getdate()
	EXEC spa_print @sql


	EXEC(@sql)


SET @sql='SELECT s.source_deal_header_id,convert(varchar(7),hb.term_date,120)+''-01'' Term,s.curve_id,max(ISNULL(spcd.display_uom_id,spcd.uom_id)) uom_id,s.physical_financial_flag [physical/Financial],max(s.commodity_id) commodity_id
		,max(s.counterparty_id) counterparty_id,max(bk.fas_book_id) fas_book_id,max(bk.book_deal_type_map_id) book_deal_type_map_id,max(sdh.internal_desk_id) profile_id
		,max(sdh.internal_portfolio_id) product_id	,null region, null grid,null country, null category_id	, MAX(sdh.header_buy_sell_flag) buy_sell_flag,null  pv_party_id
		,max(s.deal_status_id) deal_status_id ,max(sdh.broker_id) broker_id,max(sdh.source_deal_type_id) source_deal_type_id, max(sdh.trader_id) trader_id
		,max(sdh.contract_id) contract_id, max(sdh.template_id) template_id
		,sum(
			cast(s.calc_volume as numeric(22,10))/cast(nullif(isnull(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) as numeric(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,'''+@as_of_date+''')) AS VARCHAR)+''-''+CAST(MONTH(DATEADD(m,1,'''+@as_of_date+''')) AS VARCHAR)+''-01'' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)
			*(isnull(tou.hr1,1)*hb.hr1+isnull(tou.hr2,1)*hb.hr2+isnull(tou.hr3,1)*hb.hr3*CASE WHEN isnull(hb.add_dst_hour,0)=3 THEN 2 ELSE 1 END+isnull(tou.hr4,1)*hb.hr4+isnull(tou.hr5,1)*hb.hr5+isnull(tou.hr6,1)*hb.hr6
			+isnull(tou.hr7,1)*hb.hr7+isnull(tou.hr8,1)*hb.hr8+isnull(tou.hr9,1)*hb.hr9+isnull(tou.hr10,1)*hb.hr10+isnull(tou.hr11,1)*hb.hr11+isnull(tou.hr12,1)*hb.hr12
			+isnull(tou.hr13,1)*hb.hr13+isnull(tou.hr14,1)*hb.hr14+isnull(tou.hr15,1)*hb.hr15+isnull(tou.hr16,1)*hb.hr16+isnull(tou.hr17,1)*hb.hr17+isnull(tou.hr18,1)*hb.hr18
			+isnull(tou.hr19,1)*hb.hr19+isnull(tou.hr20,1)*hb.hr20+isnull(tou.hr21,1)*hb.hr21+isnull(tou.hr22,1)*hb.hr22+isnull(tou.hr23,1)*hb.hr23+isnull(tou.hr24,1)*hb.hr24
			)) Position ,max(spcd.udf_block_group_id) block_defintion_id,-1 location_id,tou.id udf_block_group_id,max(spcd.block_define_id) block_define_id
	INTO  adiha_process.dbo.cube_position_report_fin
  '

	--TODO: Fix usage of 292037 - Baseload (local: 291890), it is hardcoded even it is external static data
	SET @sql3='	from report_hourly_position_breakdown s  (nolock)  INNER JOIN #books bk ON bk.fas_book_id=s.fas_book_id 
			 	AND bk.source_system_book_id1=s.source_system_book_id1 AND bk.source_system_book_id2=s.source_system_book_id2 
			 	AND bk.source_system_book_id3=s.source_system_book_id3 AND bk.source_system_book_id4=s.source_system_book_id4 AND s.deal_date<='''+@as_of_date+'''	
			 INNER JOIN [deal_status_group] dsg ON dsg.status_value_id = s.deal_status_id  
			left join source_deal_header sdh on sdh.source_deal_header_id=s.source_deal_header_id
			left JOIN source_price_curve_def spcd with (nolock) ON spcd.source_curve_def_id=s.curve_id 
			LEFT JOIN source_price_curve_def spcd1 (nolock) On spcd1.source_curve_def_id=spcd.settlement_curve_id
			outer apply (select sum(volume_mult) term_no_hrs from #tmp_block hbt where isnull(spcd.hourly_volume_allocation,17601) <17603
					 and hbt.block_define_id=COALESCE(spcd.block_define_id,'+@baseload_block_define_id+') 
					 and hbt.term_date between s.term_start  and s.term_END 
			) term_hrs
			outer apply ( select sum(volume_mult) term_no_hrs from #tmp_block hbt inner join 
				(
					select distinct exp_date from holiday_group h where  h.hol_group_value_id=ISNULL(spcd.exp_calendar_id,spcd1.exp_calendar_id) 
					and h.exp_date between s.term_start  and s.term_END 
				) ex on ex.exp_date=hbt.term_date
				where  isnull(spcd.hourly_volume_allocation,17601) IN(17603,17604) and hbt.block_define_id=COALESCE(spcd.block_define_id,'+@baseload_block_define_id+')	
			) term_hrs_exp
			outer apply	
			( select * from #tmp_block h with (nolock) where block_define_id=COALESCE(spcd.block_define_id,'+@baseload_block_define_id+')	
				 and term_date between s.term_start  and s.term_end and term_date>'''+@as_of_date+'''
			) hb '	
	
	SET @sql4='	 outer apply  
			(select MAX(exp_date) exp_date from holiday_group h where h.hol_date=hb.term_date AND h.hol_group_value_id=ISNULL(spcd.exp_calendar_id,spcd1.exp_calendar_id) 
				and h.hol_date between s.term_start  and s.term_END AND COALESCE(spcd1.ratio_option,spcd.ratio_option,-1) <> 18800
			 ) hg   
			 outer apply  
			 (	select MIN(exp_date) hol_date ,MAX(exp_date) hol_date_to  from holiday_group h 	where 1=1 AND h.hol_group_value_id=ISNULL(spcd.exp_calendar_id,spcd1.exp_calendar_id) 
					and h.hol_date between s.term_start  and s.term_END AND s.formula NOT IN(''REBD'')
			) hg1   
			 outer apply  
			 (
				select count(exp_date) total_days,SUM(CASE WHEN h.exp_date>'''+@as_of_date+''' THEN 1 else 0 END) remain_days 
					from holiday_group h where h.hol_group_value_id=ISNULL(spcd.exp_calendar_id,spcd1.exp_calendar_id) 
						AND h.exp_date BETWEEN hg1.hol_date AND ISNULL(hg1.hol_date_to,dbo.FNALastDayInDate(hg1.hol_date))
						AND ISNULL(spcd1.ratio_option,spcd.ratio_option) = 18800 AND s.formula NOT IN(''REBD'')
			) remain_month  
			outer apply (select grp.id, term_date,hr1,hr2,hr3,hr4,hr5,hr6,hr7,hr8,hr9,hr10,hr11,hr12,hr13,hr14,hr15,hr16,hr17,hr18,hr19,hr20,hr21,hr22,hr23,hr24  from block_type_group grp inner join #tmp_block_udf t  ON t.block_define_id=grp.hourly_block_id and t.term_date=hb.term_date
				and  spcd.udf_block_group_id=grp.block_type_group_id
			) tou
		     where  ((ISNULL(spcd1.ratio_option,spcd.ratio_option) = 18800 AND ISNULL(hg1.hol_date_to,''9999-01-01'')>'''+@as_of_date+''') OR COALESCE(spcd1.ratio_option,spcd.ratio_option,-1) <> 18800)
		     AND ((isnull(spcd.hourly_volume_allocation,17601) IN(17603,17604) and  hg.exp_date is not null) or (isnull(spcd.hourly_volume_allocation,17601)<17603 ))		           
		  	and CASE WHEN s.formula IN(''dbo.FNACurveH'',''dbo.FNACurveD'') THEN ISNULL(hg.exp_date,hb.term_date) WHEN ISNULL(spcd.hourly_volume_allocation,17601) IN(17603,17604) THEN ISNULL(hg.exp_date,s.expiration_date) ELSE s.expiration_date END>'''+@as_of_date+'''
		  	and hb.term_date>'''+@as_of_date+''' 
		GROUP BY s.source_deal_header_id,convert(varchar(7),hb.term_date,120)+''-01'',s.[curve_id], s.physical_financial_flag,tou.id
	'

--EXEC spa_print getdate()
EXEC spa_print @sql
EXEC spa_print @sql3
EXEC spa_print @sql4

EXEC(@sql+@sql3+@sql4)

--EXEC spa_print getdate()

--------------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------
