

IF OBJECT_ID(N'dbo.spa_calculate_forward_position', N'P') IS NOT NULL
DROP PROCEDURE [dbo].[spa_calculate_forward_position]
GO 
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


 /**
	Calculate forward position of deal in portfolio

	Parameters : 
	@as_of_date : As Of Date is to mark fordward period
	@source_deal_header_ids : Source Deal Header Ids for filter to process

  */

CREATE PROCEDURE [dbo].[spa_calculate_forward_position]
	@as_of_date VARCHAR(25),
	@source_deal_header_ids VARCHAR(1000) = NULL
AS


--declare @as_of_date varchar(25) = '2012-04-30'

DECLARE @sub                     VARCHAR(1000) = NULL,
        @str                     VARCHAR(1000) = NULL,
        @book                    VARCHAR(1000) = null ,--'211,217' ,--'162', --'162,164,166,206'
      --  @source_deal_header_ids  VARCHAR(1000) = '126334',
        @deal_ids                VARCHAR(1000) = NULL,
        @curve_source_id INT=4500
           
       
   -- position------------------    
IF object_id('tempdb..#temp_deals_pos') is not null
drop table #temp_deals_pos
IF object_id('tempdb..#deal_header') is not null
drop table #deal_header
IF object_id('tempdb..#deal_detail') is not null
drop table #deal_detail
IF object_id('tempdb..#book') is not null
drop table #book
--IF object_id('tempdb..#process_deals') is not null
--drop table #process_deals
IF object_id('tempdb..#report_hourly_position_breakdown') is not null
drop table #report_hourly_position_breakdown
IF object_id('tempdb..#udt') is not null
drop table #udt
IF object_id('tempdb..#delta_report_hourly_position_breakdown') is not null
drop table #delta_report_hourly_position_breakdown
IF object_id('tempdb..#report_hourly_position_breakdown_detail') is not null
drop table #report_hourly_position_breakdown_detail

IF object_id('tempdb..#mv90_dst') is not null
drop table #mv90_dst



DECLARE @user_login_id VARCHAR(50)
DECLARE  @position_detail VARCHAR(150)
DECLARE @process_id VARCHAR(150)

--declare @select_fix varchar(max)

--SET @str_batch_table = ''
SET @user_login_id = dbo.FNADBUser() 

--Start tracking time for Elapse time
--DECLARE @begin_time DATETIME
--SET @begin_time = GETDATE()

SET @process_id = REPLACE(newid(),'-','_')

DECLARE @baseload_block_type       VARCHAR(10)
DECLARE @baseload_block_define_id  VARCHAR(10)--,@orginal_summary_option CHAR(1)
--DECLARE @explain_position          VARCHAR(200)
DECLARE @st1                       VARCHAR(MAX),
        @st2                       VARCHAR(MAX)
	
select	source_commodity_id, [year], case when (source_commodity_id=-1) then DATEADD(DAY, -1, [date]) else [date] end [date],
		case when (source_commodity_id=-1) then 21 else [hour] end [hour]
		, [date] [fin_date],[hour] [fin_hour]
into #mv90_dst
from mv90_dst dst
--cross join  (
--select 0 dst union all select 1 dst
--)  dst_hr
cross join source_commodity 	
where insert_delete='i'


set  @position_detail = dbo.FNAProcessTableName('explain_position_detail', @user_login_id, @process_id)
	
CREATE TABLE #temp_deals_pos (source_deal_id INT,process_status bit,product_id int)
--CREATE TABLE #process_deals (source_deal_id INT,product_id int )

create table #book (book_id int,book_deal_type_map_id int,source_system_book_id1 int,source_system_book_id2 int,source_system_book_id3 int,source_system_book_id4 int,func_cur_id INT)		
	
SET @st1='insert into #book (book_id,book_deal_type_map_id ,source_system_book_id1 ,source_system_book_id2 ,source_system_book_id3 ,source_system_book_id4,func_cur_id )		
	select book.entity_id, book_deal_type_map_id ,source_system_book_id1 ,source_system_book_id2 ,source_system_book_id3 ,source_system_book_id4 ,fs.func_cur_value_id
	from source_system_book_map sbm            
		INNER JOIN  portfolio_hierarchy book (NOLOCK) ON book.entity_id=sbm.fas_book_id
		INNER JOIN  Portfolio_hierarchy stra (NOLOCK) ON book.parent_entity_id = stra.entity_id 
		INNER JOIN  Portfolio_hierarchy sb (NOLOCK) ON stra.parent_entity_id = sb.entity_id 
		left join fas_subsidiaries fs on sb.entity_id=fs.fas_subsidiary_id
	WHERE 1=1  '
		+CASE WHEN  @sub IS NULL THEN '' ELSE ' and sb.entity_id in ('+@sub+')' END
		+CASE WHEN  @str IS NULL THEN '' ELSE ' and stra.entity_id in ('+@str+')' END
		+CASE WHEN  @book IS NULL THEN '' ELSE ' and book.entity_id in ('+@book+')' END		
		
exec(@st1)
	
SET @st1='
	INSERT INTO #temp_deals_pos (source_deal_id,process_status,product_id)
		SELECT dh.source_deal_header_id,0,isnull(dh.product_id,4101) product_id FROM source_deal_header dh
		INNER JOIN #book sbm ON dh.source_system_book_id1 = sbm.source_system_book_id1 AND 
		   dh.source_system_book_id2 = sbm.source_system_book_id2 AND dh.source_system_book_id3 = sbm.source_system_book_id3 AND 
		   dh.source_system_book_id4 = sbm.source_system_book_id4  AND dh.deal_date<='''+convert(varchar(10),@as_of_date,120) +''''
	+CASE WHEN  @source_deal_header_ids IS NULL THEN '' ELSE ' and dh.source_deal_header_id in ('+@source_deal_header_ids+')' END
	+CASE WHEN  @deal_ids IS NULL THEN '' ELSE ' and dh.deal_id in ('''+REPLACE(@deal_ids,',',''',''') +''')' END

exec spa_print @st1
EXEC(@st1)

SET @baseload_block_type = '12000'	-- Internal Static Data
SELECT @baseload_block_define_id = CAST(value_id AS VARCHAR(10)) FROM   static_data_value WHERE  [TYPE_ID] = 10018 AND code LIKE 'Base Load' -- External Static Data

IF @baseload_block_define_id IS NULL
    SET @baseload_block_define_id = 'NULL'

CREATE TABLE #deal_header(book_id int, source_deal_header_id INT , create_ts datetime, deal_id varchar(150) COLLATE DATABASE_DEFAULT, source_system_book_id1 int, source_system_book_id2 int, source_system_book_id3 int,source_system_book_id4 int
	,book_deal_type_map_id int,broker_id int ,profile_id int ,deal_type_id int ,trader_id int ,contract_id int ,
	product_id int ,template_id int ,deal_status_id int ,counterparty_id int 
)

CREATE TABLE #deal_detail(source_deal_detail_id int, source_deal_header_id INT , term_start date, term_end date,curve_id INT , location_id int, fixed_price float, leg int
,index_id int,pvparty_id int,uom_id int,physical_financial_flag varchar(1) COLLATE DATABASE_DEFAULT,buy_sell_Flag varchar(1) COLLATE DATABASE_DEFAULT,Category_id int
,create_ts datetime,deal_volume numeric(38,20), fixed_cost float,contract_expiration_date datetime,commodity_id int
 )

INSERT INTO #deal_header(book_id, source_deal_header_id  ,create_ts ,deal_id,source_system_book_id1,source_system_book_id2,source_system_book_id3
,source_system_book_id4	,book_deal_type_map_id ,broker_id  ,profile_id  ,deal_type_id  ,trader_id  ,contract_id  ,
	product_id  ,template_id  ,deal_status_id  ,counterparty_id   
 )
SELECT ssbm.fas_book_id, s.source_deal_header_id,s.create_ts,deal_id,s.source_system_book_id1,s.source_system_book_id2,s.source_system_book_id3,s.source_system_book_id4 
	,ssbm.book_deal_type_map_id ,s.broker_id  ,s.internal_desk_id profile_id  ,s.source_deal_type_id deal_type_id  ,s.trader_id  ,s.contract_id  ,
	s.product_id  ,s.template_id  ,s.deal_status deal_status_id  ,s.counterparty_id   
 FROM source_deal_header s INNER JOIN #temp_deals_pos t ON s.source_deal_header_id=t.source_deal_id
	left join source_system_book_map ssbm on s.source_system_book_id1 =ssbm.source_system_book_id1  and
	s.source_system_book_id2=ssbm.source_system_book_id2 and s.source_system_book_id3=ssbm.source_system_book_id3 
	and s.source_system_book_id4=ssbm.source_system_book_id4

set @st1='
INSERT INTO #deal_detail( source_deal_detail_id,source_deal_header_id  ,term_start ,term_end ,curve_id  ,location_id ,fixed_price ,leg 
	,index_id,pvparty_id,uom_id,physical_financial_flag,buy_sell_Flag,Category_id
	,create_ts,deal_volume,fixed_cost ,contract_expiration_date,commodity_id )
SELECT s.source_deal_detail_id,s.source_deal_header_id,s.term_start,s.term_end,s.curve_id,ISNULL(s.location_id,-1) location_id,s.fixed_price,s.leg 
	,spcd.source_curve_def_id index_id,s.pv_party pvparty_id,ISNULL(spcd.display_uom_id,spcd.uom_id) uom_id
	,s.physical_financial_flag,s.buy_sell_flag,s.Category Category_id
	 ,s.create_ts,s.deal_volume,s.fixed_cost ,s.contract_expiration_date,spcd.commodity_id commodity_id 
FROM source_deal_detail s INNER JOIN #temp_deals_pos t ON s.source_deal_header_id=t.source_deal_id 
INNER JOIN source_price_curve_def spcd ON spcd.source_curve_def_id=s.curve_id 
left JOIN  source_price_curve_def spcd1 ON  spcd1.source_curve_def_id=spcd.proxy_curve_id
'

exec spa_print @st1
EXEC(@st1)



CREATE INDEX indx_deal_detail_aaa ON #deal_detail( source_deal_header_id,curve_id,location_id,term_start ,term_end)
CREATE INDEX indx_deal_header_aaa ON #deal_header( source_deal_header_id)

SET @st2='create table '+@position_detail+' (
	as_of_date DATETIME, source_deal_header_id int, [curve_id] int,[term_start] date, Hr tinyint
	,deal_volume_uom_id int,formula_breakdown bit,
	[book_id] int,[counterparty_id] int,
	position	numeric(26,10),maturity_hr datetime,maturity_mnth date,maturity_qtr date,maturity_semi date,maturity_yr date,
	commodity_id int,dst tinyint,source_system_book_id1 INT,source_system_book_id2 INT,source_system_book_id3 INT,source_system_book_id4 INT, location_id INT
	)'


EXEC spa_print @st2
exec(@st2)

exec('if exists(select 1 from sys.indexes where [name]=''idx_tmp_position_detail_'+@process_id+''')
	drop INDEX idx_tmp_position_detail_'+@process_id+' ON '+@position_detail )

select 	rowid=identity(int,1,1),u.source_deal_header_id,u.[curve_id],u.[term_start] ,u.expiration_date,u.deal_volume_uom_id
		,sdh.book_id
		,u.formula,u.term_end,sum(u.calc_volume) calc_volume,u.counterparty_id,u.commodity_id
		, u.source_system_book_id1,u.source_system_book_id2,u.source_system_book_id3,u.source_system_book_id4
into #report_hourly_position_breakdown
from report_hourly_position_breakdown u  (nolock)
	INNER JOIN [deal_status_group] dsg ON dsg.status_value_id = u.deal_status_id  -- AND u.deal_date<=@as_of_date
	inner JOIN #deal_header sdh  ON u.source_deal_header_id=sdh.source_deal_header_id -- and ISNULL(sdh.product_id,4101)<>4100 
	LEFT JOIN  #deal_detail sdd  ON u.source_deal_header_id=sdd.source_deal_header_id AND sdd.curve_id=u.[curve_id] 
			AND u.[term_start] BETWEEN sdd.term_start AND sdd.term_end
GROUP BY 
		u.source_deal_header_id,u.[curve_id],u.[term_start] ,u.expiration_date,u.deal_volume_uom_id
		,sdh.book_id,u.formula,u.term_end,u.counterparty_id,u.commodity_id,
		u.source_system_book_id1,u.source_system_book_id2,u.source_system_book_id3,u.source_system_book_id4

select s.rowid,cast(hb.term_date as DATE) term_start
	,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr1,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=1 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))/cast(nullif(isnull(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) as numeric(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,@as_of_date)) AS VARCHAR)+'-'+CAST(MONTH(DATEADD(m,1,@as_of_date)) AS VARCHAR)+'-01' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  AS Hr1
	,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr2,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=2 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))/cast(nullif(isnull(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) as numeric(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,@as_of_date)) AS VARCHAR)+'-'+CAST(MONTH(DATEADD(m,1,@as_of_date)) AS VARCHAR)+'-01' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  AS Hr2
	,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr3,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=3 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))/cast(nullif(isnull(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) as numeric(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,@as_of_date)) AS VARCHAR)+'-'+CAST(MONTH(DATEADD(m,1,@as_of_date)) AS VARCHAR)+'-01' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  AS Hr3
	,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr4,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=4 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))/cast(nullif(isnull(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) as numeric(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,@as_of_date)) AS VARCHAR)+'-'+CAST(MONTH(DATEADD(m,1,@as_of_date)) AS VARCHAR)+'-01' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  AS Hr4
	,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr5,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=5 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))/cast(nullif(isnull(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) as numeric(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,@as_of_date)) AS VARCHAR)+'-'+CAST(MONTH(DATEADD(m,1,@as_of_date)) AS VARCHAR)+'-01' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  AS Hr5
	,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr6,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=6 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))/cast(nullif(isnull(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) as numeric(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,@as_of_date)) AS VARCHAR)+'-'+CAST(MONTH(DATEADD(m,1,@as_of_date)) AS VARCHAR)+'-01' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  AS Hr6
	,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr7,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=7 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))/cast(nullif(isnull(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) as numeric(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,@as_of_date)) AS VARCHAR)+'-'+CAST(MONTH(DATEADD(m,1,@as_of_date)) AS VARCHAR)+'-01' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  AS Hr7
	,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr8,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=8 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))/cast(nullif(isnull(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) as numeric(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,@as_of_date)) AS VARCHAR)+'-'+CAST(MONTH(DATEADD(m,1,@as_of_date)) AS VARCHAR)+'-01' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  AS Hr8
	,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr9,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=9 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))/cast(nullif(isnull(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) as numeric(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,@as_of_date)) AS VARCHAR)+'-'+CAST(MONTH(DATEADD(m,1,@as_of_date)) AS VARCHAR)+'-01' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  AS Hr9
	,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr10,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=10 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))/cast(nullif(isnull(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) as numeric(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,@as_of_date)) AS VARCHAR)+'-'+CAST(MONTH(DATEADD(m,1,@as_of_date)) AS VARCHAR)+'-01' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  AS Hr10
	,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr11,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=11 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))/cast(nullif(isnull(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) as numeric(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,@as_of_date)) AS VARCHAR)+'-'+CAST(MONTH(DATEADD(m,1,@as_of_date)) AS VARCHAR)+'-01' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  AS Hr11
	,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr12,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=12 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))/cast(nullif(isnull(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) as numeric(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,@as_of_date)) AS VARCHAR)+'-'+CAST(MONTH(DATEADD(m,1,@as_of_date)) AS VARCHAR)+'-01' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  AS Hr12
	,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr13,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=13 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))/cast(nullif(isnull(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) as numeric(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,@as_of_date)) AS VARCHAR)+'-'+CAST(MONTH(DATEADD(m,1,@as_of_date)) AS VARCHAR)+'-01' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  AS Hr13
	,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr14,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=14 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))/cast(nullif(isnull(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) as numeric(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,@as_of_date)) AS VARCHAR)+'-'+CAST(MONTH(DATEADD(m,1,@as_of_date)) AS VARCHAR)+'-01' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  AS Hr14
	,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr15,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=15 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))/cast(nullif(isnull(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) as numeric(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,@as_of_date)) AS VARCHAR)+'-'+CAST(MONTH(DATEADD(m,1,@as_of_date)) AS VARCHAR)+'-01' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  AS Hr15
	,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr16,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=16 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))/cast(nullif(isnull(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) as numeric(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,@as_of_date)) AS VARCHAR)+'-'+CAST(MONTH(DATEADD(m,1,@as_of_date)) AS VARCHAR)+'-01' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  AS Hr16
	,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr17,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=17 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))/cast(nullif(isnull(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) as numeric(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,@as_of_date)) AS VARCHAR)+'-'+CAST(MONTH(DATEADD(m,1,@as_of_date)) AS VARCHAR)+'-01' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  AS Hr17
	,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr18,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=18 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))/cast(nullif(isnull(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) as numeric(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,@as_of_date)) AS VARCHAR)+'-'+CAST(MONTH(DATEADD(m,1,@as_of_date)) AS VARCHAR)+'-01' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  AS Hr18
	,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr19,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=19 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))/cast(nullif(isnull(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) as numeric(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,@as_of_date)) AS VARCHAR)+'-'+CAST(MONTH(DATEADD(m,1,@as_of_date)) AS VARCHAR)+'-01' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  AS Hr19
	,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr20,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=20 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))/cast(nullif(isnull(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) as numeric(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,@as_of_date)) AS VARCHAR)+'-'+CAST(MONTH(DATEADD(m,1,@as_of_date)) AS VARCHAR)+'-01' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  AS Hr20
	,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr21,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=21 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))/cast(nullif(isnull(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) as numeric(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,@as_of_date)) AS VARCHAR)+'-'+CAST(MONTH(DATEADD(m,1,@as_of_date)) AS VARCHAR)+'-01' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  AS Hr21
	,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr22,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=22 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))/cast(nullif(isnull(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) as numeric(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,@as_of_date)) AS VARCHAR)+'-'+CAST(MONTH(DATEADD(m,1,@as_of_date)) AS VARCHAR)+'-01' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  AS Hr22
	,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr23,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=23 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))/cast(nullif(isnull(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) as numeric(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,@as_of_date)) AS VARCHAR)+'-'+CAST(MONTH(DATEADD(m,1,@as_of_date)) AS VARCHAR)+'-01' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  AS Hr23
	,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr24,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=24 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))/cast(nullif(isnull(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) as numeric(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,@as_of_date)) AS VARCHAR)+'-'+CAST(MONTH(DATEADD(m,1,@as_of_date)) AS VARCHAR)+'-01' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  AS Hr24
	,(cast(cast(s.calc_volume as numeric(22,10))* cast(CASE WHEN isnull(hb.add_dst_hour,0)=0 THEN 0 ELSE 1 END as numeric(1,0)) as numeric(22,10))) /cast(nullif(isnull(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) as numeric(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,@as_of_date)) AS VARCHAR)+'-'+CAST(MONTH(DATEADD(m,1,@as_of_date)) AS VARCHAR)+'-01' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END) AS Hr25 
	,CASE WHEN s.formula IN('dbo.FNACurveH','dbo.FNACurveD') THEN ISNULL(hg.exp_date,hb.term_date) 
		WHEN ISNULL(spcd.hourly_volume_allocation,17601) IN(17603,17604) THEN ISNULL(hg.exp_date,s.expiration_date)
		 ELSE s.expiration_date END expiration_date
into #report_hourly_position_breakdown_detail
from #report_hourly_position_breakdown s  (nolock) 
	left JOIN source_price_curve_def spcd with (nolock) ON spcd.source_curve_def_id=s.curve_id  
	LEFT JOIN source_price_curve_def spcd1 (nolock) On spcd1.source_curve_def_id=spcd.settlement_curve_id
	outer apply 
	(
		select sum(volume_mult) term_no_hrs from hour_block_term hbt where isnull(spcd.hourly_volume_allocation,17601) <17603 and hbt.block_define_id=COALESCE(spcd.block_define_id,'292037')	
		and  hbt.block_type=COALESCE(spcd.block_type,12000) and hbt.term_date between s.term_start  and s.term_END 
	) term_hrs
	outer apply 
	( 
		select sum(volume_mult) term_no_hrs from hour_block_term hbt inner join 
		(
			select distinct exp_date from holiday_group h where  h.hol_group_value_id=ISNULL(spcd.exp_calendar_id,spcd1.exp_calendar_id) and h.exp_date between s.term_start  and s.term_END 
		) ex on ex.exp_date=hbt.term_date
		where  isnull(spcd.hourly_volume_allocation,17601) IN(17603,17604) and hbt.block_define_id=COALESCE(spcd.block_define_id,292037)	
		and  hbt.block_type=COALESCE(spcd.block_type,12000) and hbt.term_date between s.term_start  and s.term_END
	) term_hrs_exp
	LEFT JOIN hour_block_term hb (nolock) on hb.block_define_id=COALESCE(spcd.block_define_id,292037)
		and  hb.block_type=COALESCE(spcd.block_type,12000) and hb.term_date between s.term_start  and s.term_end  
	 outer apply 
	  (
	  	select MAX(exp_date) exp_date from holiday_group h where h.hol_date=hb.term_date AND 
	  h.hol_group_value_id=ISNULL(spcd.exp_calendar_id,spcd1.exp_calendar_id) and h.hol_date between s.term_start  and s.term_END 
	  AND COALESCE(spcd1.ratio_option,spcd.ratio_option,-1) <> 18800 
	  ) hg   
	 outer apply 
	 (
	 	select MIN(exp_date) hol_date ,MAX(exp_date) hol_date_to  from holiday_group h where h.hol_group_value_id=ISNULL(spcd.exp_calendar_id,spcd1.exp_calendar_id) and h.hol_date between s.term_start  and s.term_END AND s.formula NOT IN('REBD')
	 ) hg1   
	 outer APPLY
	 (
	 	select count(exp_date) total_days,SUM(CASE WHEN h.exp_date>@as_of_date THEN 1 else 0 END) remain_days from holiday_group h where h.hol_group_value_id=ISNULL(spcd.exp_calendar_id,spcd1.exp_calendar_id) 
				AND h.exp_date BETWEEN hg1.hol_date AND ISNULL(hg1.hol_date_to,dbo.FNALastDayInDate(hg1.hol_date))
				AND ISNULL(spcd1.ratio_option,spcd.ratio_option) = 18800 AND s.formula NOT IN('REBD')
	 ) remain_month  
	WHERE 
	((ISNULL(spcd1.ratio_option,spcd.ratio_option) = 18800 AND ISNULL(hg1.hol_date_to,'9999-01-01')>@as_of_date ) OR COALESCE(spcd1.ratio_option,spcd.ratio_option,-1) <> 18800)
     AND (
     	(isnull(spcd.hourly_volume_allocation,17601) IN(17603,17604) and  hg.exp_date is not null) 
     	or (isnull(spcd.hourly_volume_allocation,17601)<17603 )
		)	 
	  and CASE WHEN s.formula IN('dbo.FNACurveH','dbo.FNACurveD') THEN ISNULL(hg.exp_date,hb.term_date) 
		WHEN ISNULL(spcd.hourly_volume_allocation,17601) IN(17603,17604) THEN ISNULL(hg.exp_date,s.expiration_date)
		 ELSE s.expiration_date END>@as_of_date
		 	   and   hb.term_date>@as_of_date
		
		
	   
		
	declare @hr_columns varchar(max),@fin_columns varchar(max),@phy_columns varchar(max)

	set @fin_columns='h.source_deal_header_id,h.counterparty_id,h.[curve_id],h.expiration_date,h.deal_volume_uom_id,h.book_id,e.[term_start],h.commodity_id,h.source_system_book_id1,h.source_system_book_id2,h.source_system_book_id3,h.source_system_book_id4, null'

	set @phy_columns='e.source_deal_header_id,sdh.counterparty_id,e.[curve_id],e.expiration_date,e.deal_volume_uom_id,sdh.book_id,e.[term_start],sdd.commodity_id,e.source_system_book_id1,e.source_system_book_id2,e.source_system_book_id3,e.source_system_book_id4, e.location_id '

	set @hr_columns=',e.hr1,e.hr2,e.hr3,e.hr4,e.hr5,e.hr6,e.hr7,e.hr8,e.hr9,e.hr10,e.hr11,e.hr12,e.hr13,e.hr14,e.hr15,e.hr16,e.hr17,e.hr18,e.hr19,e.hr20,e.hr21 ,e.hr22 ,e.hr23,e.hr24,e.hr25,e.hr25 dst_hr'

	SET @st1='
	INSERT INTO ' +@position_detail+'(as_of_date, source_deal_header_id,counterparty_id,[curve_id] ,[term_start] , Hr,deal_volume_uom_id ,formula_breakdown,[book_id],Position,maturity_hr,maturity_mnth,maturity_qtr,maturity_semi,maturity_yr,commodity_id,dst,source_system_book_id1,source_system_book_id2,source_system_book_id3,source_system_book_id4, location_id)	
	Select ''' + @as_of_date + ''' as_of_date, NULL,u.counterparty_id,u.[curve_id]
	,u.term_start
	,case when cast(substring(hr,3,2) AS INT) =25 then case when u.formula_breakdown=0 then dst.[hour] else dst.fin_hour end
	else 	
		cast(substring(u.hr,3,2) AS INT) 
	end Hr
	,u.deal_volume_uom_id,u.formula_breakdown,u.[book_id]
	,sum(case when u.expiration_date>'''+CONVERT(VARCHAR(10),@as_of_date,120) + ''' AND u.[term_start]>'''+CONVERT(VARCHAR(10),@as_of_date,120) +''' 
			then u.Volume else 0 end- case when dst.[hour]=cast(substring(u.hr,3,2) AS INT) then isnull(u.dst_hr,0) else 0 end ) Volume
	, DATEADD(hour,	case when cast(substring(hr,3,2) AS INT) =25 then dst.[hour] else cast(substring(u.hr,3,2) AS INT) end -1
	,u.[term_start]) [Maturity_hr]
	,cast(convert(varchar(8),u.[term_start],120)+''01'' as date) [Maturity_mnth]
	,cast(convert(varchar(5),u.[term_start],120)+ cast(case datepart(q, u.term_start) when 1 then 1 when 2 then 4 when 3 then 7 when 4 then 10 end as varchar)+''-01'' as date) [Maturity_qtr] 
	,cast(convert(varchar(5),u.[term_start],120)+ cast(case when month(u.term_start) < 7 then 1 else 7 end as varchar)+''-01'' as date) [Maturity_semi] 
	,cast(convert(varchar(5),u.[term_start],120)+ ''01-01'' as date) [Maturity_yr],u.commodity_id
	,case when cast(substring(u.hr,3,2) AS INT)=25 then 1 else 0 end
	,u.source_system_book_id1,u.source_system_book_id2,u.source_system_book_id3,u.source_system_book_id4, u.location_id 	'
	set @st2='	FROM 
	(
		select '+ @phy_columns +'
			,sum(e.hr1) hr1,sum(e.hr2) hr2 ,sum(e.hr3) hr3 ,sum(e.hr4) hr4 ,sum(e.hr5) hr5 ,sum(e.hr6) hr6 ,sum(e.hr7) hr7 ,sum(e.hr8) hr8
			,sum(e.hr9) hr9 ,sum(e.hr10) hr10 ,sum(e.hr11) hr11 ,sum(e.hr12) hr12 ,sum(e.hr13) hr13 ,sum(e.hr14) hr14 ,sum(e.hr15) hr15 ,sum(e.hr16) hr16
			,sum(e.hr17) hr17 ,sum(e.hr18) hr18 ,sum(e.hr19) hr19 ,sum(e.hr20) hr20 ,sum(e.hr21 ) hr21 ,sum(e.hr22 ) hr22 ,sum(e.hr23) hr23 ,sum(e.hr24) hr24,sum(e.hr25) hr25,sum(e.hr25) dst_hr
			,0 formula_breakdown
		FROM [dbo].[report_hourly_position_profile] e
		inner JOIN #deal_header sdh  ON e.source_deal_header_id=sdh.source_deal_header_id 
		INNER JOIN [deal_status_group] dsg ON dsg.status_value_id = sdh.deal_status_id 
			and e.expiration_date>'''+CONVERT(VARCHAR(10),@as_of_date,120) +''' AND e.[term_start]>'''+CONVERT(VARCHAR(10),@as_of_date,120) +'''
		LEFT JOIN  #deal_detail sdd  ON e.[term_start] BETWEEN sdd.term_start AND sdd.term_end 
			and e.source_deal_detail_id=sdd.source_deal_detail_id
		group by '+@phy_columns+',cast(convert(varchar(10),sdh.create_ts,120) as date)
	UNION ALL
		select '+ @phy_columns +'
			,sum(e.hr1) hr1,sum(e.hr2) hr2 ,sum(e.hr3) hr3 ,sum(e.hr4) hr4 ,sum(e.hr5) hr5 ,sum(e.hr6) hr6 ,sum(e.hr7) hr7 ,sum(e.hr8) hr8
				,sum(e.hr9) hr9 ,sum(e.hr10) hr10 ,sum(e.hr11) hr11 ,sum(e.hr12) hr12 ,sum(e.hr13) hr13 ,sum(e.hr14) hr14 ,sum(e.hr15) hr15 ,sum(e.hr16) hr16
				,sum(e.hr17) hr17 ,sum(e.hr18) hr18 ,sum(e.hr19) hr19 ,sum(e.hr20) hr20 ,sum(e.hr21 ) hr21 ,sum(e.hr22 ) hr22 ,sum(e.hr23) hr23 ,sum(e.hr24) hr24,sum(e.hr25) hr25,sum(e.hr25) dst_hr
			,0 formula_breakdown
		FROM [dbo].[report_hourly_position_deal] e inner join #temp_deals_pos t on e.[source_deal_header_id]=t.source_deal_id 
			and e.expiration_date>'''+CONVERT(VARCHAR(10),@as_of_date,120) +''' AND e.[term_start]>'''+CONVERT(VARCHAR(10),@as_of_date,120) +'''
		inner JOIN #deal_header sdh  ON e.source_deal_header_id=sdh.source_deal_header_id -- and ISNULL(sdh.product_id,4101)<>4100 
		INNER JOIN [deal_status_group] dsg ON dsg.status_value_id = sdh.deal_status_id 
		LEFT JOIN  #deal_detail sdd  ON e.[term_start] BETWEEN sdd.term_start AND sdd.term_end 
			and e.source_deal_detail_id=sdd.source_deal_detail_id
		group by '+@phy_columns+',cast(convert(varchar(10),sdh.create_ts,120) as date)
	union all
		select '+ @fin_columns+@hr_columns +',1 formula_breakdown FROM #report_hourly_position_breakdown_detail e
			left join #report_hourly_position_breakdown h on h.rowid=e.rowid
	) p
		UNPIVOT
			(Volume for Hr IN (hr1,hr2,hr3,hr4,hr5,hr6,hr7,hr8,hr9,hr10,hr11,hr12,hr13,hr14,hr15,hr16,hr17,hr18,hr19,hr20,hr21,hr22,hr23,hr24,hr25)
	)AS u 
		left join source_price_curve_def spcd on u.curve_id=spcd.source_curve_def_id
	left join #mv90_dst dst on dst.source_commodity_id = u.commodity_id 
		and u.term_start=case when u.formula_breakdown=0 then dst.date else dst.fin_date end
		 where Volume<>0 and (case when cast(substring(hr,3,2) AS INT) =25 then case when u.formula_breakdown=0 then dst.[hour] else dst.fin_hour end
				else cast(substring(u.hr,3,2) AS INT) 	end) is not null AND 
				DATEADD(hour, case when cast(substring(hr,3,2) AS INT) =25 then dst.[hour] else cast(substring(u.hr,3,2) AS INT) end -1, u.[term_start]) < ''' + CAST(dbo.FNALastDayInDate(DATEADD(m,1,@as_of_date)) + ' 23:59:59:997' AS VARCHAR) + '''
	group by	
		u.[curve_id],u.[term_start] ,u.expiration_date,cast(substring(hr,3,2) AS INT),dst.[hour],dst.[fin_hour]
		,u.deal_volume_uom_id,u.formula_breakdown,u.[book_id],u.[counterparty_id],u.commodity_id
		,u.source_system_book_id1,u.source_system_book_id2,u.source_system_book_id3,u.source_system_book_id4 , u.location_id
'
EXEC spa_print @st1	
EXEC spa_print @st2 


exec(@st1+ @st2 )	

set @st1='create index indx_111_'+@process_id +' on '+@position_detail+'(curve_id,term_start,hr)'
exec(@st1)

set @st1='create index indx_222_'+@process_id +' on '+@position_detail+'(maturity_yr,maturity_semi,maturity_qtr,maturity_mnth,maturity_hr)'
exec(@st1)

 
 DECLARE @next_month_start DATETIME = CAST(CONVERT(CHAR(7), DATEADD(m,1,@as_of_date), 126) + '-01' AS DATETIME),
	     @next_month_end DATETIME = [dbo].FNALastDayInDate( DATEADD(m,1,@as_of_date) )
  
 
--truncate table open_position
EXEC(' DELETE FROM open_position WHERE 
as_of_date = ''' + @as_of_date + '''')
--term_start BETWEEN '''+ @next_month_start +''' AND ''' + @next_month_end + '''  ')


EXEC('INSERT INTO open_position(as_of_date, source_deal_header_id,[curve_id] ,[term_start] , Hr,deal_volume_uom_id ,formula_breakdown,[book_id],counterparty_id,Position,maturity_hr,maturity_mnth,maturity_qtr,maturity_semi,maturity_yr,commodity_id,dst,source_system_book_id1,source_system_book_id2,
		source_system_book_id3,source_system_book_id4, location_id)
		
		SELECT as_of_date, source_deal_header_id,[curve_id] ,[term_start] , Hr,deal_volume_uom_id ,formula_breakdown,[book_id],counterparty_id, 
		Position,maturity_hr,maturity_mnth,maturity_qtr,maturity_semi,maturity_yr,commodity_id,dst,source_system_book_id1,source_system_book_id2,source_system_book_id3, source_system_book_id4	, location_id
		FROM ' + @position_detail  )

