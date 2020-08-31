
/****** Object:  StoredProcedure [dbo].[spa_copy_optimizer_deals]    Script Date: 12/23/2015 9:11:59 AM ******/
IF OBJECT_ID(N'[dbo].[spa_copy_optimizer_deals]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[spa_copy_optimizer_deals]
GO

/****** Object:  StoredProcedure [dbo].[spa_copy_optimizer_deals]    Script Date: 12/23/2015 9:11:59 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO
  
CREATE PROC [dbo].[spa_copy_optimizer_deals]
	@flow_date datetime,
	@flow_date_from datetime,
	@flow_date_to datetime,
	@enable_paging INT = 0, --'1' = enable, '0' = disable
	@page_size INT = NULL,
	@page_no INT = NULL,
	@batch_process_id VARCHAR(100) = NULL,
	@batch_report_param VARCHAR(1000) = NULL

As

 /* 
 
DECLARE @flow_date DATETIME='2016-03-06'
	,@flow_date_from datetime	='2016-03-07'
	,@flow_date_to datetime='2016-03-08'
	,@enable_paging INT = 0, --'1' = enable, '0' = disable
	@page_size INT = NULL,
	@page_no INT = NULL,
	@batch_process_id VARCHAR(100) = NULL,
	@batch_report_param VARCHAR(1000) = NULL



--*/

IF OBJECT_ID(N'tempdb..#tmp_nom_location') IS NOT NULL DROP TABLE #tmp_nom_location

IF OBJECT_ID('tempdb..#temp_sub_book1') IS NOT NULL DROP TABLE #temp_sub_book1
IF OBJECT_ID(N'tempdb..#tmp_header') IS NOT NULL DROP TABLE #tmp_header
IF OBJECT_ID(N'tempdb..#inserted_deal_detail') IS NOT NULL DROP TABLE #inserted_deal_detail
IF OBJECT_ID(N'tempdb..#tmp_deals') IS NOT NULL DROP TABLE #tmp_deals
IF OBJECT_ID(N'tempdb..#tmp_term') IS NOT NULL DROP TABLE #tmp_term
IF OBJECT_ID(N'tempdb..#tmp_error') IS NOT NULL DROP TABLE #tmp_error
IF OBJECT_ID(N'tempdb..#optimizer_header_inserted') IS NOT NULL DROP TABLE #optimizer_header_inserted

IF OBJECT_ID(N'tempdb..#tmp_deal_loc') IS NOT NULL DROP TABLE #tmp_deal_loc
IF OBJECT_ID(N'tempdb..#time_series_data') IS NOT NULL DROP TABLE #time_series_data
IF OBJECT_ID(N'tempdb..#split_router_result') IS NOT NULL DROP TABLE #split_router_result

IF OBJECT_ID(N'tempdb..#pos_val_loc') IS NOT NULL DROP TABLE #pos_val_loc

IF OBJECT_ID(N'tempdb..#nom_location_loss_factor') IS NOT NULL DROP TABLE #nom_location_loss_factor
--IF OBJECT_ID(N'tempdb..#location_routes_loss_factor') IS NOT NULL DROP TABLE #location_routes_loss_factor
 	 

set  @flow_date_to	=isnull(@flow_date_to,@flow_date_from)


select row_id=identity(int,1,1),a.term_start,a.term_end into #tmp_term from dbo.[FNATermBreakdown]('d',@flow_date_from,@flow_date_to )	a

Declare  @report_position			VARCHAR(250)
	, @user_name					VARCHAR(30)
	, @st1							VARCHAR(max)
	, @sdh_id						INT
	, @idoc							INT
	, @contract_detail				VARCHAR(250)
	, @scheduled_deals				VARCHAR(250)
	, @opt_deal_detail_pos			VARCHAR(250)
	
set @batch_process_id= ISNULL(@batch_process_id, REPLACE(NEWID(), '-', '_'))
set   @user_name=dbo.FNADBUser()

DECLARE  @sdv_from_deal	INT,@sdv_to_deal int ,@sql varchar(max)
		
SELECT @sdv_from_deal =
 value_id
FROM static_data_value
WHERE [TYPE_ID] = 5500 AND code = 'From Deal'

SELECT @sdv_to_deal = 
value_id
FROM static_data_value
WHERE [TYPE_ID] = 5500 AND code = 'To Deal'

	
select  CAST(clm2_value AS INT) sub_book into #temp_sub_book1 FROM generic_mapping_header gmh 
INNER JOIN generic_mapping_values gmv ON gmv.mapping_table_id = gmh.mapping_table_id
WHERE mapping_name IN('Flow Optimization Mapping') 
UNION ALL
select CAST(clm4_value AS INT) FROM generic_mapping_header gmh 
INNER JOIN generic_mapping_values gmv ON gmv.mapping_table_id = gmh.mapping_table_id
WHERE mapping_name IN('Storage Book Mapping') 
union all
select CAST(clm2_value AS INT) FROM generic_mapping_header gmh 
INNER JOIN generic_mapping_values gmv ON gmv.mapping_table_id = gmh.mapping_table_id
WHERE mapping_name = 'Nomination Mapping' 


SELECT distinct row_id=identity(int,1,1), sdh.source_deal_header_id 	 INTO #tmp_deals
FROM source_deal_header sdh 
INNER JOIN source_system_book_map ssbm ON ssbm.source_system_book_id1 = sdh.source_system_book_id1 
	AND ssbm.source_system_book_id2 = sdh.source_system_book_id2 
	AND ssbm.source_system_book_id3 = sdh.source_system_book_id3
	AND ssbm.source_system_book_id4 = sdh.source_system_book_id4
	AND sdh.entire_term_start=sdh.entire_term_end AND sdh.entire_term_start= @flow_date
INNER JOIN #temp_sub_book1 scsv ON scsv.sub_book = ssbm.book_deal_type_map_id



 ------------------------Start Validiation--------------------------------------------------------------------------------
 -------=========================================================================================================================

DECLARE @desc varchar(500),@err_type varchar(1)	,@url varchar(max), @module varchar(100)

declare @location_type int,@meter_type int
select @location_type=source_major_location_id from source_major_location where location_name='Gathering System'   --9
select @meter_type= value_id from static_data_value where code='Wellhead'   --9

 IF OBJECT_ID(N'tempdb..#terms') IS NOT NULL DROP TABLE #terms
 IF OBJECT_ID(N'tempdb..#time_series_data') IS NOT NULL DROP TABLE #time_series_data
 IF OBJECT_ID(N'tempdb..#deal_location') IS NOT NULL DROP TABLE #deal_location
 IF OBJECT_ID(N'tempdb..#missmatch_route') IS NOT NULL DROP TABLE #missmatch_route
		  


 ------------checking loss_factor
 /*
select sdd.from_loc_id ,sdd.to_loc_id 
into #deal_location from #tmp_deals td 
cross apply 
(
	select term_start,max(case when leg=1 then location_id else null end) from_loc_id,max(case when leg=2 then location_id else null end) to_loc_id
	from source_deal_detail where source_deal_header_id=td.source_deal_header_id and term_start=@flow_date
	group by term_start
) sdd

select t.term_start into #terms from  dbo.FNATermBreakdown('d',@flow_date_from,@flow_date_to) t
union all
select @flow_date term_start

select pls.path_id,max(pls.effective_date) effective_date
into #tmp_lf1_eff_date
from path_loss_shrinkage pls
where pls.effective_date <= @flow_date
group by pls.path_id

--extract value associated with latest effective date found for loss factor1
if OBJECT_ID('tempdb..#tmp_lf1') is not null 
drop table #tmp_lf1

select dp.path_id,dl.from_loc_id ,dl.to_loc_id,tm.term_start, ca_lf.shrinkage_curve_id,ca_lf.loss_factor
into #tmp_lf1
from   #deal_location dl cross join #terms tm
cross apply
(
	select top(1) * from delivery_path  where from_location=dl.from_loc_id and to_location=dl.to_loc_id
 
 ) dp

cross apply
(
	select pls.path_id,max(pls.effective_date) effective_date from path_loss_shrinkage pls
	where pls.effective_date <= tm.term_start
	group by pls.path_id 
 ) max_dt
cross apply (
	select p.loss_factor, p.shrinkage_curve_id from path_loss_shrinkage p where p.path_id = dp.path_id and p.effective_date = max_dt.effective_date
) ca_lf


 --extract value associated with latest effective date found for loss factor2(time series data)
if OBJECT_ID('tempdb..#tmp_lf2') is not null 
drop table #tmp_lf2

select tsd.time_series_definition_id,tm.term_start,sd.value loss_factor into #tmp_lf2 from dbo.time_series_definition tsd 
cross join #terms tm
cross apply (
	select  maturity, max(effective_date) effective_date  from   dbo.time_series_data where  time_series_definition_id=tsd.time_series_definition_id
	and  effective_date<=isnull(maturity,tm.term_start)  and isnull(maturity,tm.term_start) =tm.term_start
	group by   maturity 
) eff
inner join dbo.time_series_data sd on  sd.time_series_definition_id=tsd.time_series_definition_id and sd.effective_date=eff.effective_date
	and  isnull(sd.maturity,'1900-01-01')=isnull(eff.maturity,'1900-01-01')


--final store of loss factor information
if OBJECT_ID('tempdb..#tmp_loss_factor') is not null 
drop table #tmp_loss_factor

select l1.path_id,l1.term_start, l1.from_loc_id,l1.to_loc_id,l1.loss_factor loss_factor1, l2.loss_factor loss_factor2
	, coalesce(l1.loss_factor, l2.loss_factor) loss_factor
into #tmp_loss_factor
from #tmp_lf1 l1
left join #tmp_lf2 l2 on l2.time_series_definition_id = l1.shrinkage_curve_id  and l1.term_start=l2.term_start


IF OBJECT_ID(N'tempdb..#tmp_nom_location') IS NOT NULL
 DROP TABLE #tmp_nom_location

SELECT [rowid] = IDENTITY(INT, 1, 1), 
	tm.term_start, tu.from_loc_id from_location
	,max(dp.group_id) route_id
INTO #nom_location_loss_factor
FROM #deal_location tu
cross join #terms tm
CROSS APPLY (
	 SELECT TOP(1) * FROM  source_minor_location_nomination_group ng 
	 WHERE ng.source_minor_location_id = tu.from_loc_id and ng.effective_date<=tm.term_start 
	 and info_type='r'
	 order by  effective_date desc
) dp 
GROUP BY tm.term_start,tu.from_loc_id

 --assumation: there will be always only one primary route in volume split route group
 --   drop table #maintain_location_routes

SELECT  distinct  tlf.path_id,tlf.term_start,tlf.from_loc_id,tlf.to_loc_id 
	,coalesce(tlf.fuel_loss, r.fuel_loss,0) fuel_loss ,cast(0.0 as numeric(12,10)) source_fuel_loss
into #location_routes_loss_factor
FROM   #tmp_loss_factor tlf 
outer apply 
( 
	select  r.fuel_loss from dbo.maintain_location_routes r 
	inner join #nom_location_loss_factor p  on p.route_id = r.route_id 
	and p.from_location=tlf.from_loc_id and p.term_start=tlf.term_start
) nom  


update #location_routes_loss_factor set source_fuel_loss= b.fuel_loss  from #location_routes_loss_factor a
cross apply
(
  select fuel_loss from  #location_routes_loss_factor where term_start=@flow_date and path_id= a.path_id
)	b
where 	a.term_start between @flow_date_from  and @flow_date_to

*/

 ---------------------------------------------------------------------------



 --------checking meter volume
select rowid=identity(int,1,1),mdh.prod_date [Term],
sum(
	isnull(mdh.Hr1,0)+isnull(mdh.Hr2,0)+isnull(mdh.Hr3,0)+isnull(mdh.Hr4,0)+isnull(mdh.Hr5,0)+isnull(mdh.Hr6,0)+isnull(mdh.Hr7,0)+isnull(mdh.Hr8,0)+isnull(mdh.Hr9,0)+isnull(mdh.Hr10,0)+isnull(mdh.Hr11,0)+isnull(mdh.Hr12,0)
	+isnull(mdh.Hr13,0)+isnull(mdh.Hr14,0)+isnull(mdh.Hr15,0)+isnull(mdh.Hr16,0)+isnull(mdh.Hr17,0)+isnull(mdh.Hr18,0)+isnull(mdh.Hr19,0)+isnull(mdh.Hr20,0)+isnull(mdh.Hr21,0)+isnull(mdh.Hr22,0)+isnull(mdh.Hr23,0)+isnull(mdh.Hr24,0)
) volume,sml.source_minor_location_id location_id,max(smlm.meter_id) meter_id,cast(0.0 as numeric(28,10)) source_volume
into #tmp_deal_loc
from source_minor_location 	 sml inner join source_minor_location_meter smlm
	on sml.source_minor_location_id=smlm.source_minor_location_id and meter_type=@meter_type  --Wellhead
	and  sml.source_major_location_id=@location_type
inner join mv90_data mvd on mvd.meter_id=smlm.meter_id 	
inner join mv90_data_hour	mdh on mdh.meter_data_id= mvd.meter_data_id
	and mdh.prod_date between mvd.from_date and mvd.to_date
	and (mdh.prod_date between @flow_date_from  and @flow_date_to or mdh.prod_date=@flow_date)
LEFT JOIN dbo.nom_group_schedule_deal ngsd ON sml.source_minor_location_id=ngsd.location_id AND ngsd.term_start= mdh.prod_date
WHERE  ngsd.rowid IS NULL 
group by sml.source_minor_location_id, mdh.prod_date


update 	  #tmp_deal_loc set source_volume= b.volume  from #tmp_deal_loc a
cross apply
(
  select volume   from  #tmp_deal_loc where term=@flow_date and location_id= a.location_id
)	b
where 	a.term between @flow_date_from  and @flow_date_to

 ------------------------------------------------------------------------------



---------------------------checking split percentage-------------------
SELECT [rowid] = IDENTITY(INT, 1, 1), 
	tu.Term, tu.location_id from_location, SUM(tu.Volume) Volume,
	 MAX(tu.meter_id)  meter_from
	,max(dp.group_id) route_id, MAX(nom.group_id) group_id
INTO #tmp_nom_location
FROM #tmp_deal_loc tu
CROSS APPLY (
	SELECT TOP(1) * FROM  source_minor_location_nomination_group ng 
	WHERE ng.source_minor_location_id = tu.location_id	and ng.effective_date<=tu.term 
	and info_type='r'
	order by  effective_date desc
) dp 
OUTER APPLY (
	SELECT TOP(1) * FROM  source_minor_location_nomination_group ng 
	WHERE ng.source_minor_location_id = tu.location_id	and ng.effective_date<=tu.term 
	and info_type<>'r'
	order by  effective_date desc
) nom 
GROUP BY tu.Term,tu.location_id
HAVING SUM(tu.Volume) <> 0	;




select a.from_location,a.Term,a.route_id,b.Term term1,b.route_id route_id1  into #missmatch_route from #tmp_nom_location a 
outer apply
(
select top(1) * from #tmp_nom_location where from_location =a.from_location and term<>a.Term and route_id<>a.route_id

) b
where b.route_id is not null and a.Term=@flow_date




select rowid=identity(int,1,1), p.term,p.route_id,p.from_location from_location_id, ega.del_location_id,ega.split_percentage
	 ,cast(0.0 as numeric(12,10)) source_split_percentage
into #split_router_result
FROM #tmp_nom_location p 
inner join dbo.maintain_location_routes mlr on mlr.route_id = p.route_id
inner join dbo.equity_gas_allocation ega on ega.location_id =p.from_location 
		and ega.del_location_id= mlr.[delivery_location] and ega.term_start =p.term	


update #split_router_result set source_split_percentage=b.split_percentage from #split_router_result a
outer apply
(
	select split_percentage   from  #split_router_result 
	where term=@flow_date and route_id= a.route_id
		and from_location_id=from_location_id and del_location_id	=a.del_location_id
)	b
where 	a.term between @flow_date_from  and @flow_date_to

insert into  #split_router_result  (term,route_id,from_location_id,del_location_id,split_percentage , source_split_percentage )
select null term,b.route_id,b.from_location_id,b.del_location_id,0 split_percentage , b.source_split_percentage 
from ( select * from  #split_router_result where term=@flow_date )	b
	left join #split_router_result a	on 	 a.term=b.term and a.route_id= b.route_id
		and a.from_location_id=b.from_location_id and a.del_location_id	=b.del_location_id
		and a.term between @flow_date_from  and @flow_date_to
where 	a.route_id is null
 -------------------------------------------------------------------------
 
 
  ------- checking supply and demand position


select 
	sdd.term_start ,sdd.location_id	, sum(sdd.deal_volume * case sdd.buy_sell_flag when 's' then -1 else 1 end) [position]
	,cast(0.0 as numeric(28,10)) source_position
	into #pos_val_loc	  --  select * from #pos_val_loc where location_id in (  30426	,27357)
from 
(
	select distinct d.location_id from source_deal_detail d (nolock)
	inner join source_deal_header h on 	  h.source_deal_header_id =d.source_deal_header_id
	inner join source_deal_header_template t on t.template_id = h.template_id
		and t.template_name = 'Transportation NG' and d.term_start = @flow_date 
) loc --filter location
inner join source_deal_detail sdd (nolock) on sdd.location_id=loc.location_id
inner join source_deal_header sdh on  sdh.source_deal_header_id =sdd.source_deal_header_id
inner join source_deal_header_template sdht on sdht.template_id = sdh.template_id
left join optimizer_header oh on oh.transport_deal_id=sdd.source_deal_header_id
where ((sdd.term_start between @flow_date_from  and @flow_date_to) or sdd.term_start=@flow_date)
	and sdd.location_id is not null
	and  oh.transport_deal_id is null
	and sdht.template_name <> 'Transportation NG' -- exclude autonom/schedule deals ( include/check  only for physical supply/demand deals)
group by sdd.term_start ,sdd.location_id	


update #pos_val_loc set source_position= b.position  from #pos_val_loc a
cross apply
(
  select position from  #pos_val_loc where term_start=@flow_date and location_id= a.location_id
)	b
where 	a.term_start between @flow_date_from  and @flow_date_to

 ----------------------------------------------------



 ---delete source_date 
delete  #pos_val_loc  where term_start= @flow_date or (source_position=0 and position=0) 	 --delete  data of @flow_date as data of this date is already updated in soure_volume column.

delete #tmp_deal_loc where term=@flow_date or (source_volume=0 and volume=0) 	 --delete  data of @flow_date as data of this date is already updated in soure_volume column.

delete #split_router_result where term=@flow_date or (source_split_percentage=0 and split_percentage=0)  	 --delete  data of @flow_date as data of this date is already updated in soure_volume column.

--delete #location_routes_loss_factor where term_start=@flow_date or (source_fuel_loss=0 and fuel_loss=0)  	 --delete  data of @flow_date as data of this date is already updated in soure_volume column.

-- select * from #tmp_deal_loc
-- select * from  #split_router_result
--select * from #pos_val_loc
 


 --select * from #split_router_result
 --select * from #tmp_deal_loc
 --select * from #pos_val_loc -- where location_id in (27357,30426)
 --select * from #calc_status

--select * from source_minor_location where source_minor_location_id=1109
--select * from source_minor_location_nomination_group
--select * from equity_gas_allocation
--select * from maintain_location_routes	--where route_id=305913-- 1042

if OBJECT_ID('tempdb..#ok_deals') is not null drop table #ok_deals
if OBJECT_ID('tempdb..#no_rec_deal_detail_valid') is not null drop table #no_rec_deal_detail_valid
if OBJECT_ID('tempdb..#no_rec_deal_detail') is not null drop table #no_rec_deal_detail

CREATE TABLE #ok_deals
(
	source_deal_header_id int
)

--select * from dbo.source_deal_detail where source_deal_header_id=360023

--select sdd.source_deal_header_id,count(1) cnt  into #no_rec_deal_detail
--from dbo.source_deal_detail sdd 
--	inner join #tmp_deals td on td.source_deal_header_id=sdd.source_deal_header_id
--group by sdd.source_deal_header_id

----drop table #no_rec_deal_detail_valid
--select sdd.source_deal_header_id,tdl.term_start --,count(1) cnt  --into #no_rec_deal_detail_valid
--from  #pos_val_loc	tdl 
--	inner join dbo.source_deal_detail sdd 
--		on   tdl.location_id=sdd.location_id and sdd.term_start='2016-06-01'
--	inner join #tmp_deals td on td.source_deal_header_id=sdd.source_deal_header_id
--where tdl.source_position=tdl.position
--group by sdd.source_deal_header_id	--,tdl.term_start


--select * from #no_rec_deal_detail
--select * from #no_rec_deal_detail_valid

--insert into #ok_deals
--(
--	source_deal_header_id 
--)
--select distinct a1.source_deal_header_id
-- from  #no_rec_deal_detail	a1 
--inner join 	#no_rec_deal_detail_valid a2 on a1.source_deal_header_id=a2.source_deal_header_id and a1.cnt=a2.cnt



insert into #ok_deals
(
	source_deal_header_id 
)
select distinct sdd.source_deal_header_id
from  #tmp_deal_loc	tdl 
inner join dbo.source_deal_detail sdd 
	on tdl.location_id=sdd.location_id and sdd.term_start=@flow_date
inner join #tmp_deals td on td.source_deal_header_id=sdd.source_deal_header_id
where source_volume=volume


--insert into #ok_deals -------------
--(
--	source_deal_header_id 
--)
--select distinct sdd.source_deal_header_id
--from  #location_routes_loss_factor	tdl 
--inner join dbo.source_deal_detail sdd 
--	on tdl.from_location=sdd.location_id and sdd.term_start=@flow_date and sdd.Leg=1
--inner join #tmp_deals td on td.source_deal_header_id=sdd.source_deal_header_id
--where tdl.source_fuel_loss=tdl.fuel_loss

insert into #ok_deals
(
	source_deal_header_id 
)
select distinct sdd.source_deal_header_id
from  #split_router_result	tdl 
inner join dbo.source_deal_detail sdd 
	on tdl.from_location_id=sdd.location_id and sdd.term_start=@flow_date
inner join #tmp_deals td on td.source_deal_header_id=sdd.source_deal_header_id
where tdl.split_percentage<> tdl.source_split_percentage

if OBJECT_ID('tempdb..#calc_status') is not null drop table #calc_status

CREATE TABLE #calc_status
(
	process_id varchar(100) COLLATE DATABASE_DEFAULT,
	ErrorCode varchar(50) COLLATE DATABASE_DEFAULT,
	Module varchar(100) COLLATE DATABASE_DEFAULT,
	Source varchar(100) COLLATE DATABASE_DEFAULT,
	type varchar(100) COLLATE DATABASE_DEFAULT,
	[description] varchar(1000) COLLATE DATABASE_DEFAULT,
	[nextstep] varchar(250) COLLATE DATABASE_DEFAULT
)



insert into #calc_status 	
select @batch_process_id,'Error','Copy optimizer Deal','Copy Opt Deal','Data Error',
		'Route changed('+convert(varchar(10),@flow_date,120)+'->'+convert(varchar(10),tdl.term1,120)+'):' +sdv.[description] +'->' +sdv1.[description] +'.'
		,'Please check the deal.' 
from  #missmatch_route tdl 
left join static_data_value sdv on tdl.route_id=sdv.value_id
left join static_data_value sdv1 on tdl.route_id1=sdv1.value_id



insert into #calc_status 	
select @batch_process_id,'Error','Copy optimizer Deal','Copy Opt Deal','Data Error',
		'Supply/Demand position changed('+convert(varchar(10),@flow_date,120)+'->'+convert(varchar(10),tdl.term_start,120)+'):' +cast(round(tdl.source_position,0) as varchar) +'->' +cast(round(tdl.source_position,0) as varchar)
		+' for Location:'+sml.location_name +'Deal ID: '''+ dbo.FNAHyperLinkText(10131000, cast(sdd.source_deal_header_id as varchar), sdd.source_deal_header_id) 
		+'''.'
		,'Please check the deal.' 
from  #pos_val_loc	tdl 
	inner join dbo.source_deal_detail sdd 
		on tdl.location_id=sdd.location_id and tdl.Term_start=sdd.term_start
	inner join #tmp_deals td on td.source_deal_header_id=sdd.source_deal_header_id
	left join source_major_location sml on sml.source_major_location_id=tdl.location_id
where tdl.source_position<>tdl.position


-- insert into #calc_status 	
--select @batch_process_id,'Error','Copy optimizer Deal','Copy Opt Deal','Data Error',
--		'Route Fuel Loss changed('+convert(varchar(10),@flow_date,120)+'->'+convert(varchar(10),tdl.term_start,120)+'):' +cast(round(tdl.source_fuel_loss,0) as varchar) +'->' +cast(round(tdl.fuel_loss,0) as varchar)
--		+' for Route:'+tdl.route_name +'Deal ID: '''+ dbo.FNAHyperLinkText(10131000, cast(sdd.source_deal_header_id as varchar), sdd.source_deal_header_id) 
--		+'''.'
--		,'Please check the deal.' 
--from  #location_routes_loss_factor	tdl 
--	inner join dbo.source_deal_detail sdd 
--		on tdl.from_location=sdd.location_id and tdl.Term_start=sdd.term_start and sdd.Leg=1
--	inner join #tmp_deals td on td.source_deal_header_id=sdd.source_deal_header_id
--where tdl.source_fuel_loss<>tdl.fuel_loss


--insert into #calc_status 	
--select @batch_process_id,'Error','Copy optimizer Deal','Copy Opt Deal','Data Error',
--		'Supply/Demand position changed for Deal ID: '''+ dbo.FNAHyperLinkText(10131000, cast(a1.source_deal_header_id as varchar), a1.source_deal_header_id) 
--		+'''.'
--		,'Please check the deal.' 
--from  #no_rec_deal_detail	a1 
--	inner join 	#no_rec_deal_detail_valid a2 on a1.source_deal_header_id=a2.source_deal_header_id and a1.cnt<>a2.cnt


insert into #calc_status 	
select @batch_process_id,'Error','Copy optimizer Deal','Copy Opt Deal','Data Error',
		'Meter reading changed('+convert(varchar(10),@flow_date,120)+'->'+convert(varchar(10),tdl.term,120)+'):' +cast(round(tdl.source_volume,0) as varchar) +'->' +cast(round(tdl.volume,0) as varchar)
		+' for Meter:'+mi.[description]+'/Location:'+sml.location_name 
		+'''.'
		,'Please check meter reading.' 
 from  #tmp_deal_loc	tdl 
	--inner join dbo.source_deal_detail sdd 
	--	on tdl.location_id=sdd.location_id and tdl.Term=sdd.term_start
	--inner join #tmp_deals td on td.source_deal_header_id=sdd.source_deal_header_id
	inner join dbo.meter_id mi on mi.meter_id=tdl.meter_id 
	left join source_minor_location sml on sml.source_minor_location_id=tdl.location_id
where tdl.source_volume<>tdl.volume

insert into #calc_status 	
select @batch_process_id,'Error','Copy optimizer Deal','Copy Opt Deal','Data Error',
		'Router volume split percentage is found changed('+convert(varchar(10),@flow_date,120)+'->'+convert(varchar(10),tdl.term,120)+'):' +cast(round(tdl.source_split_percentage,4) as varchar) +'->' +cast(round(tdl.split_percentage,4) as varchar)
		+' for Router:'+mlr.route_name+'/Delivery Location:'+sml1.location_name	+'Deal ID: '''+ dbo.FNAHyperLinkText(10131000, cast(sdd.source_deal_header_id as varchar), sdd.source_deal_header_id) 
		+'''.'
		,'Please check router volume split percentage.' 
from  #split_router_result	tdl 
	inner join dbo.source_deal_detail sdd 
		on tdl.from_location_id=sdd.location_id and tdl.Term=sdd.term_start
	inner join #tmp_deals td on td.source_deal_header_id=sdd.source_deal_header_id
	left join dbo.source_major_location sml1 on sml1.source_major_location_id=tdl.del_location_id
	left join dbo.maintain_location_routes mlr on mlr.maintain_location_routes_id=tdl.route_id
where tdl.split_percentage<> tdl.source_split_percentage


DECLARE @error_count_s int
DECLARE @type_s char

insert into MTM_TEST_RUN_LOG(process_id,code,module,source,type,[description],nextsteps)  
select * from #calc_status --where process_id=@batch_process_id


If @@ROWCOUNT > 0 
	SET @type_s = 'e'
Else
	SET @type_s = 's'
		

--SET @desc = 'Assessment process completed for run date ' + @run_date 
SET @url = './dev/spa_html.php?__user_name__=' + @user_name + 
	'&spa=exec spa_get_mtm_test_run_log ''' +  @batch_process_id   + ''''


if @type_s='e'
begin

	SET @desc = '<a target="_blank" href="' + @url + '">' + 
			'Optimizer Deal Copy process completed from Term:' + dbo.FNADateFormat(@flow_date) +' into '+dbo.FNADateFormat(@flow_date_from) +' ~ '+ dbo.FNADateFormat(@flow_date_to) + 
			' (ERRORS found).</a>'

	EXEC spa_message_board 'i',
		@user_name,
		NULL,
		'Copy optimizer Deal',
		@desc ,null,null,'e'

	return
end
else
begin


	if exists(select top(1) 1 from #ok_deals )
	begin
		SET @desc = 
				'Optimizer Deal Copy process completed from Term:' + dbo.FNADateFormat(@flow_date) +' into '+dbo.FNADateFormat(@flow_date_from) +' ~ '+ dbo.FNADateFormat(@flow_date_to) + 	'.'
		EXEC spa_message_board 'i',
			@user_name,
			NULL,
			'Copy optimizer Deal',
			@desc ,null,null,'s'
	end
	else
	begin
		SET @desc = 
				'No records found to Copy Optimizer Deal from Term:' + dbo.FNADateFormat(@flow_date) +' into '+dbo.FNADateFormat(@flow_date_from) +' ~ '+ dbo.FNADateFormat(@flow_date_to) + 	'.'

		EXEC spa_message_board 'i',
			@user_name,
			NULL,
			'Copy optimizer Deal',
			@desc ,null,null,'e'
		return
	end

end


--return
--select * from #calc_status
----==========================================================================================================================
--------------------------------------end validation--------------------------------------------------------------------------

SELECT t.term_start	into #tmp_error
FROM source_deal_header sdh 
	INNER JOIN source_system_book_map ssbm ON ssbm.source_system_book_id1 = sdh.source_system_book_id1 
		AND ssbm.source_system_book_id2 = sdh.source_system_book_id2 
		AND ssbm.source_system_book_id3 = sdh.source_system_book_id3
		AND ssbm.source_system_book_id4 = sdh.source_system_book_id4
		AND sdh.entire_term_start=sdh.entire_term_end 
	INNER JOIN #temp_sub_book1 scsv ON scsv.sub_book = ssbm.book_deal_type_map_id
	inner join #tmp_term t on sdh.entire_term_start =t.term_start


--declare @batch_process_id varchar(250)
-- SET @batch_process_id = dbo.FNAGetNewID()

if @@ROWCOUNT>0
begin
	
  --purge existing data
	  --select @flow_date_from=min(term_start)) 
	  --,@flow_date_to=max(term_start)) from #tmp_error


	exec [dbo].[spa_run_purge_process]
		@date_from =@flow_date_from,
		@date_to =@flow_date_to,
		@purge_type ='b',
		@sub_book  = NULL,
		@batch_process_id  = @batch_process_id



	--select 'Error' [Status],'Optimizer results for the given dates['+dbo.fnadateformat(min(term_start)) +' : '+dbo.fnadateformat(max(term_start))+ '] already exist. Please purge it before copying again.' [Message]	
	-- from #tmp_error

	--return
end


SELECT [source_system_id]
	, cast([deal_id] as varchar(250)) [deal_id]
	, [deal_date]
	, [ext_deal_id]
	, [physical_financial_flag]
	, [structured_deal_id]
	, [counterparty_id]
	, [entire_term_start]
	, [entire_term_end]
	, [source_deal_type_id]
	, [deal_sub_type_type_id]
	, [option_flag]
	, [option_type]
	, [option_excercise_type]
	, [source_system_book_id1]
	, [source_system_book_id2]
	, [source_system_book_id3]
	, [source_system_book_id4]
	, [description1]
	, [description2]
	, [description3]
	, [deal_category_value_id]
	, [trader_id]
	, [internal_deal_type_value_id]
	, [internal_deal_subtype_value_id]
	, [template_id]
	, [header_buy_sell_flag]
	, [broker_id]
	, [generator_id]
	, [status_value_id]
	, [status_date]
	, [assignment_type_value_id]
	, [compliance_year]
	, [state_value_id]
	, [assigned_date]
	, [assigned_by]
	, [generation_source]
	, [aggregate_environment]
	, [aggregate_envrionment_comment]
	, [rec_price]
	, [rec_formula_id]
	, [rolling_avg]
	, [contract_id]
	, [create_user]
	, [create_ts]
	, [update_user]
	, [update_ts]
	, [legal_entity]
	, [internal_desk_id]
	, [product_id]
	, [internal_portfolio_id]
	, [commodity_id]
	, [reference]
	, [deal_locked]
	, [close_reference_id]
	, [block_type]
	, [block_define_id]
	, [granularity_id]
	, [Pricing]
	, [deal_reference_type_id]
	, [unit_fixed_flag]
	, [broker_unit_fees]
	, [broker_fixed_cost]
	, [broker_currency_id]
	, [deal_status]
	, [term_frequency]
	, [option_settlement_date]
	, [verified_by]
	, [verified_date]
	, [risk_sign_off_by]
	, [risk_sign_off_date]
	, [back_office_sign_off_by]
	, [back_office_sign_off_date]
	, [book_transfer_id]
	, [confirm_status_type]
	, [sub_book]
	, [deal_rules]
	, [confirm_rule]
	, [description4]
	, [timezone_id]
	, CAST(0 AS INT) source_deal_header_id,CAST(0 AS INT) org_source_deal_header_id
INTO #tmp_header
FROM [dbo].[source_deal_header] 
WHERE 1 = 2

INSERT INTO [dbo].[source_deal_header]
			([source_system_id]
			, [deal_id]
			, [deal_date]
			, [ext_deal_id]
			, [physical_financial_flag]
			, [structured_deal_id]
			, [counterparty_id]
			, [entire_term_start]
			, [entire_term_end]
			, [source_deal_type_id]
			, [deal_sub_type_type_id]
			, [option_flag]
			, [option_type]
			, [option_excercise_type]
			, [source_system_book_id1]
			, [source_system_book_id2]
			, [source_system_book_id3]
			, [source_system_book_id4]
			, [description1]
			, [description2]
			, [description3]
			, [deal_category_value_id]
			, [trader_id]
			, [internal_deal_type_value_id]
			, [internal_deal_subtype_value_id]
			, [template_id]
			, [header_buy_sell_flag]
			, [broker_id]
			, [generator_id]
			, [status_value_id]
			, [status_date]
			, [assignment_type_value_id]
			, [compliance_year]
			, [state_value_id]
			, [assigned_date]
			, [assigned_by]
			, [generation_source]
			, [aggregate_environment]
			, [aggregate_envrionment_comment]
			, [rec_price]
			, [rec_formula_id]
			, [rolling_avg]
			, [contract_id]
			, [create_user]
			, [create_ts]
			, [update_user]
			, [update_ts]
			, [legal_entity]
			, [internal_desk_id]
			, [product_id]
			, [internal_portfolio_id]
			, [commodity_id]
			, [reference]
			, [deal_locked]
			, [close_reference_id]
			, [block_type]
			, [block_define_id]
			, [granularity_id]
			, [Pricing]
			, [deal_reference_type_id]
			, [unit_fixed_flag]
			, [broker_unit_fees]
			, [broker_fixed_cost]
			, [broker_currency_id]
			, [deal_status]
			, [term_frequency]
			, [option_settlement_date]
			, [verified_by]
			, [verified_date]
			, [risk_sign_off_by]
			, [risk_sign_off_date]
			, [back_office_sign_off_by]
			, [back_office_sign_off_date]
			, [book_transfer_id]
			, [confirm_status_type]
			, [sub_book]
			, [deal_rules]
			, [confirm_rule]
			, [description4]
			, [timezone_id])

	output 
			inserted.[source_system_id]
			, inserted.[deal_id]
			, inserted.[deal_date]
			, inserted.[ext_deal_id]
			, inserted.[physical_financial_flag]
			, inserted.[structured_deal_id]
			, inserted.[counterparty_id]
			, inserted.[entire_term_start]
			, inserted.[entire_term_end]
			, inserted.[source_deal_type_id]
			, inserted.[deal_sub_type_type_id]
			, inserted.[option_flag]
			, inserted.[option_type]
			, inserted.[option_excercise_type]
			, inserted.[source_system_book_id1]
			, inserted.[source_system_book_id2]
			, inserted.[source_system_book_id3]
			, inserted.[source_system_book_id4]
			, inserted.[description1]
			, inserted.[description2]
			, inserted.[description3]
			, inserted.[deal_category_value_id]
			, inserted.[trader_id]
			, inserted.[internal_deal_type_value_id]
			, inserted.[internal_deal_subtype_value_id]
			, inserted.[template_id]
			, inserted.[header_buy_sell_flag]
			, inserted.[broker_id]
			, inserted.[generator_id]
			, inserted.[status_value_id]
			, inserted.[status_date]
			, inserted.[assignment_type_value_id]
			, inserted.[compliance_year]
			, inserted.[state_value_id]
			, inserted.[assigned_date]
			, inserted.[assigned_by]
			, inserted.[generation_source]
			, inserted.[aggregate_environment]
			, inserted.[aggregate_envrionment_comment]
			, inserted.[rec_price]
			, inserted.[rec_formula_id]
			, inserted.[rolling_avg]
			, inserted.[contract_id]
			, inserted.[create_user]
			, inserted.[create_ts]
			, inserted.[update_user]
			, inserted.[update_ts]
			, inserted.[legal_entity]
			, inserted.[internal_desk_id]
			, inserted.[product_id]
			, inserted.[internal_portfolio_id]
			, inserted.[commodity_id]
			, inserted.[reference]
			, inserted.[deal_locked]
			, inserted.[close_reference_id]
			, inserted.[block_type]
			, inserted.[block_define_id]
			, inserted.[granularity_id]
			, inserted.[Pricing]
			, inserted.[deal_reference_type_id]
			, inserted.[unit_fixed_flag]
			, inserted.[broker_unit_fees]
			, inserted.[broker_fixed_cost]
			, inserted.[broker_currency_id]
			, inserted.[deal_status]
			, inserted.[term_frequency]
			, inserted.[option_settlement_date]
			, inserted.[verified_by]
			, inserted.[verified_date]
			, inserted.[risk_sign_off_by]
			, inserted.[risk_sign_off_date]
			, inserted.[back_office_sign_off_by]
			, inserted.[back_office_sign_off_date]
			, inserted.[book_transfer_id]
			, inserted.[confirm_status_type]
			, inserted.[sub_book]
			, inserted.[deal_rules]
			, inserted.[confirm_rule]
			, inserted.[description4]
			, inserted.[timezone_id]
			, inserted.[source_deal_header_id]		
			,0	
	INTO #tmp_header
SELECT 
	h.[source_system_id]
			, h.deal_id+'____' + CAST(td.row_id AS VARCHAR)+'____'+ CAST(t.row_id AS VARCHAR)
			, h.deal_date
			, h.[ext_deal_id]
			, h.[physical_financial_flag]
			, h.[structured_deal_id]
			, h.[counterparty_id]
			, t.term_start
			, t.term_start
			, h.[source_deal_type_id]
			, h.[deal_sub_type_type_id]
			, h.[option_flag]
			, h.[option_type]
			, h.[option_excercise_type]
			, h.source_system_book_id1 
			, h.source_system_book_id2
			, h.source_system_book_id3
			, h.source_system_book_id4
			, h.[description1]
			, h.[description2]
			, h.[description3]
			, h.[deal_category_value_id]
			, h.[trader_id]
			, h.[internal_deal_type_value_id]
			, h.[internal_deal_subtype_value_id]
			, h.[template_id]
			, h.[header_buy_sell_flag]
			, h.[broker_id]
			, h.[generator_id]
			, h.[status_value_id]
			, h.[status_date]
			, h.[assignment_type_value_id]
			, h.[compliance_year]
			, h.[state_value_id]
			, h.[assigned_date]
			, h.[assigned_by]
			, h.[generation_source]
			, h.[aggregate_environment]
			, h.[aggregate_envrionment_comment]
			, h.[rec_price]
			, h.[rec_formula_id]
			, h.[rolling_avg]
			,h.[contract_id]
			, @user_name
			, getdate()
			,@user_name [update_user]
			, getdate()
			, h.[legal_entity]
			, h.[internal_desk_id]
			, h.[product_id]
			, h.[internal_portfolio_id]
			, h.[commodity_id]
			, h.[reference]
			, h.[deal_locked]
			, h.[close_reference_id]
			, h.[block_type]
			, h.[block_define_id]
			, h.[granularity_id]
			, h.[Pricing]
			, h.[deal_reference_type_id]
			, h.[unit_fixed_flag]
			, h.[broker_unit_fees]
			, h.[broker_fixed_cost]
			, h.[broker_currency_id]
			, h.[deal_status]
			, h.[term_frequency]
			, h.[option_settlement_date]
			, h.[verified_by]
			, h.[verified_date]
			, h.[risk_sign_off_by]
			, h.[risk_sign_off_date]
			, h.[back_office_sign_off_by]
			, h.[back_office_sign_off_date]
			, h.[book_transfer_id]
			, h.[confirm_status_type]
			,h.[sub_book]
			, h.[deal_rules]
			, h.[confirm_rule]
			, h.[source_deal_header_id] [description4]
			, h.[timezone_id]
from #tmp_deals td
--inner join #ok_deals ok on ok.[source_deal_header_id]=td.[source_deal_header_id]
INNER JOIN source_deal_header h ON h.source_deal_header_id = td.source_deal_header_id	 
cross join #tmp_term t
order by t.term_start,h.source_deal_header_id

update #tmp_header set org_source_deal_header_id = [description4]
--from  #tmp_deals td 
--inner join  source_deal_header h  ON h.source_deal_header_id = td.source_deal_header_id
--cross join #tmp_term t
--inner join select * from #tmp_header th  ON th.deal_id=h.deal_id+'____' + CAST(td.row_id AS VARCHAR)+'____'+ CAST(t.row_id AS VARCHAR)


CREATE TABLE #inserted_deal_detail (
	source_deal_header_id	INT, 
	source_deal_detail_id	INT,
	leg						INT, 
	org_source_deal_detail_id INT 
	,term_start datetime 
)


INSERT INTO [dbo].[source_deal_detail]
			([source_deal_header_id]
			, [term_start]
			, [term_end]
			, [Leg]
			, [contract_expiration_date]
			, [fixed_float_leg]
			, [buy_sell_flag]
			, [curve_id]
			, [fixed_price]
			, [fixed_price_currency_id]
			, [option_strike_price]
			, [deal_volume]
			, [deal_volume_frequency]
			, [deal_volume_uom_id]
			, [block_description]
			, [deal_detail_description]
			, [formula_id]
			, [volume_left]
			, [settlement_volume]
			, [settlement_uom]
			, [create_user]
			, [create_ts]
			, [update_user]
			, [update_ts]
			, [price_adder]
			, [price_multiplier]
			, [settlement_date]
			, [day_count_id]
			, [location_id]
			, [meter_id]
			, [physical_financial_flag]
			, [Booked]
			, [process_deal_status]
			, [fixed_cost]
			, [multiplier]
			, [adder_currency_id]
			, [fixed_cost_currency_id]
			, [formula_currency_id]
			, [price_adder2]
			, [price_adder_currency2]
			, [volume_multiplier2]
			, [pay_opposite]
			, [capacity]
			, [settlement_currency]
			, [standard_yearly_volume]
			, [formula_curve_id]
			, [price_uom_id]
			, [category]
			, [profile_code]
			, [pv_party]
			, [status]
			, [lock_deal_detail])
OUTPUT INSERTED.source_deal_header_id, INSERTED.source_deal_detail_id ,INSERTED.leg ,0 ,inserted.term_start
INTO #inserted_deal_detail
select th.[source_deal_header_id]
			, th.[entire_term_start]
			, th.[entire_term_start]
			, s.[Leg]
			, s.[contract_expiration_date]
			, s.[fixed_float_leg]
			, s.[buy_sell_flag]
			, s.[curve_id]
			, s.[fixed_price]
			, s.[fixed_price_currency_id]
			, s.[option_strike_price]
			,s.[deal_volume]
			, s.[deal_volume_frequency]
			, s.[deal_volume_uom_id]
			, s.[block_description]
			, s.[deal_detail_description]
			, s.[formula_id]
			,s.[volume_left]
			, s.[settlement_volume]
			, s.[settlement_uom]
			, @user_name [create_user]
			, getdate() [create_ts]
			, @user_name [update_user]
			, getdate() [update_ts]
			, s.[price_adder]
			, s.[price_multiplier]
			, s.[settlement_date]
			, s.[day_count_id]
			, s. [location_id]
			, s.[meter_id]
			, s.[physical_financial_flag]
			, s.[Booked]
			, s.[process_deal_status]
			, s.[fixed_cost]
			, s.[multiplier]
			, s.[adder_currency_id]
			, s.[fixed_cost_currency_id]
			, s.[formula_currency_id]
			, s.[price_adder2]
			, s.[price_adder_currency2]
			, s.[volume_multiplier2]
			, s.[pay_opposite]
			, s.[capacity]
			, s.[settlement_currency]
			, s.[standard_yearly_volume]
			, s.[formula_curve_id]
			, s.[price_uom_id]
			, s.[category]
			, s.[profile_code]
			, s.[pv_party]
			, s.[status]
			, s.[lock_deal_detail]	
from [dbo].[source_deal_detail] s 
inner join  #tmp_header th  ON th.org_source_deal_header_id=s.source_deal_header_id 


update #inserted_deal_detail set org_source_deal_detail_id = sdd.source_deal_detail_id
from  #tmp_header th 
inner join #inserted_deal_detail idd on th.source_deal_header_id=idd.source_deal_header_id
inner join source_deal_detail sdd on th.org_source_deal_header_id=sdd.source_deal_header_id
	  and sdd.leg=idd.leg


/**********************insert into *[user_defined_deal_fields]*****************************************************/

--print 'INSERT INTO [dbo].[user_defined_deal_fields]'
--print	getdate()

	
INSERT INTO [dbo].[user_defined_deal_fields]
		([source_deal_header_id]
		,[udf_template_id]
		,[udf_value]
		,[create_user]
		,[create_ts])
SELECT	th.source_deal_header_id 
		,u.[udf_template_id]
		, CASE uddft.field_id				
					when  @sdv_from_deal then  CAST(isnull(h1.source_deal_header_id,u.udf_value) AS VARCHAR)
					when  @sdv_to_deal then	CAST(h2.source_deal_header_id AS VARCHAR)
					ELSE u.udf_value
		END
		,@user_name
		,GETDATE()
from  #tmp_header th
inner JOIN [dbo].[user_defined_deal_fields_template] uddft ON uddft.template_id = th.template_id
inner join   [user_defined_deal_fields] u 	 on  u.source_deal_header_id=th.org_source_deal_header_id AND  uddft.udf_template_id = u.udf_template_id

 outer apply
( 
	select top(1) source_deal_header_id 
   	from  #tmp_header where cast(org_source_deal_header_id as varchar)=u.udf_value	and entire_term_start =th.entire_term_start
		 and  isnumeric(u.udf_value)=1 and	 uddft.field_id =@sdv_from_deal
) h1
  outer apply
( 
	select top(1) source_deal_header_id 
   	from  #tmp_header where cast(org_source_deal_header_id as varchar)=u.udf_value	and entire_term_start =th.entire_term_start
		 and  isnumeric(u.udf_value)=1 and	 uddft.field_id =@sdv_to_deal
) h2


INSERT INTO user_defined_deal_detail_fields
(
	-- udf_deal_id -- this column value is auto-generated
	source_deal_detail_id,
	udf_template_id,
	udf_value
)
select
 udf.source_deal_detail_id
, udf.udf_template_id
, udf.udf_value
from #tmp_term t
cross apply
(
	SELECT distinct idd.source_deal_detail_id
		, u.udf_template_id
	, u.udf_value
	from #inserted_deal_detail idd 
		inner join #tmp_header th on th.source_deal_header_id=idd.source_deal_header_id and th.entire_term_start=t.term_start 
		inner join  user_defined_deal_detail_fields u on u.source_deal_detail_id=idd.org_source_deal_detail_id
) udf


--optimizer


create table #optimizer_header_inserted ( optimizer_header_id_old int,optimizer_header_id_new int,term_start datetime,old_deal_id int,new_deal_id int)

--select * from optimizer_header
--select * from optimizer_detail

insert into dbo.optimizer_header(
	flow_date,transport_deal_id,package_id,SLN_id,receipt_location_id,delivery_location_id,rec_nom_volume,del_nom_volume,rec_nom_cycle1,del_nom_cycle1
	,rec_nom_cycle2,del_nom_cycle2,rec_nom_cycle3,del_nom_cycle3,rec_nom_cycle4,del_nom_cycle4,rec_nom_cycle5,del_nom_cycle5,sch_rec_volume,sch_del_volume
	,actual_rec_volume,actual_del_volume,create_user,create_ts,update_user,update_ts
)
output INSERTED.optimizer_header_id,inserted.flow_date,inserted.transport_deal_id into #optimizer_header_inserted(optimizer_header_id_new,term_start ,new_deal_id)
select 
	th.[entire_term_start],th.source_deal_header_id,h.package_id,h.SLN_id,h.receipt_location_id,h.delivery_location_id,h.rec_nom_volume,h.del_nom_volume,h.rec_nom_cycle1,h.del_nom_cycle1
	,h.rec_nom_cycle2,h.del_nom_cycle2,h.rec_nom_cycle3,h.del_nom_cycle3,h.rec_nom_cycle4,h.del_nom_cycle4,h.rec_nom_cycle5,h.del_nom_cycle5,h.sch_rec_volume,h.sch_del_volume
	,h.actual_rec_volume,h.actual_del_volume,dbo.fnadbuser(),getdate(),dbo.fnadbuser(),getdate()
from optimizer_header h inner join #tmp_header th on th.org_source_deal_header_id= h.transport_deal_id

 update #optimizer_header_inserted set optimizer_header_id_old =o.optimizer_header_id 
	 ,old_deal_id= o.transport_deal_id
 from dbo.optimizer_header o inner join  #tmp_header th on th.org_source_deal_header_id= o.transport_deal_id
	 inner join dbo.optimizer_header n on th.source_deal_header_id= n.transport_deal_id
	 inner join #optimizer_header_inserted i on i.optimizer_header_id_new=n.optimizer_header_id
 

insert into dbo.optimizer_detail(
	optimizer_header_id,flow_date,transport_deal_id,up_down_stream,source_deal_header_id,source_deal_detail_id
	,deal_volume,volume_used,sch_rec_volume,sch_del_volume,actual_rec_volume,actual_del_volume,create_user,create_ts,update_user,update_ts
)
select
	i.optimizer_header_id_new, i.[term_start] flow_date,i.new_deal_id,d.up_down_stream
	,idd.source_deal_header_id,idd.source_deal_detail_id 
	,d.deal_volume,d.volume_used,d.sch_rec_volume,d.sch_del_volume,d.actual_rec_volume,d.actual_del_volume,dbo.fnadbuser(),getdate(),dbo.fnadbuser(),getdate()
from dbo.optimizer_detail d inner join #optimizer_header_inserted i on d.optimizer_header_id=i.optimizer_header_id_old
	inner join #inserted_deal_detail idd  on  idd.org_source_deal_detail_id=d.source_deal_detail_id
		and i.term_start=idd.term_start

 --physical deal that not include in copied deal
insert into dbo.optimizer_detail(
	optimizer_header_id,flow_date,transport_deal_id,up_down_stream,source_deal_header_id,source_deal_detail_id
	,deal_volume,volume_used,sch_rec_volume,sch_del_volume,actual_rec_volume,actual_del_volume,create_user,create_ts,update_user,update_ts
)
select 
	i.optimizer_header_id_new, i.[term_start] flow_date,i.new_deal_id,d.up_down_stream
	,isnull(sdd_next.source_deal_header_id,d.source_deal_header_id) source_deal_header_id,sdd_next.source_deal_detail_id 
	,d.deal_volume,d.volume_used,d.sch_rec_volume,d.sch_del_volume,d.actual_rec_volume,d.actual_del_volume,dbo.fnadbuser(),getdate(),dbo.fnadbuser(),getdate()
from dbo.optimizer_detail d inner join #optimizer_header_inserted i on d.optimizer_header_id=i.optimizer_header_id_old
	left join #inserted_deal_detail idd  on  idd.org_source_deal_detail_id=d.source_deal_detail_id
		and i.term_start=idd.term_start
	left join  source_deal_detail sdd on sdd.source_deal_detail_id= d.source_deal_detail_id  --taking term_start 
	left join  source_deal_detail sdd_next on sdd_next.source_deal_header_id= d.source_deal_header_id 
		and sdd_next.leg= sdd.leg and sdd_next.location_id= sdd.location_id and sdd_next.term_start=i.term_start
where 
	idd.org_source_deal_detail_id is null
 

update h set deal_id = LEFT(h.deal_id,5)+CAST(h.source_deal_header_id AS VARCHAR)
from  #tmp_header td 
inner join  source_deal_header h  ON h.source_deal_header_id = td.source_deal_header_id


-- add audit
DECLARE @after_update_process_table VARCHAR(300), @job_name VARCHAR(200), @job_process_id VARCHAR(200) = dbo.FNAGETNEWID()
SET @after_update_process_table = dbo.FNAProcessTableName('after_insert_process_table', @user_name, @job_process_id)
			
EXEC spa_print @after_update_process_table
IF OBJECT_ID(@after_update_process_table) IS NOT NULL
BEGIN
	EXEC('DROP TABLE ' + @after_update_process_table)
END
				
EXEC ('CREATE TABLE ' + @after_update_process_table + '(source_deal_header_id INT)')

SET @sql = 'INSERT INTO ' + @after_update_process_table + '(source_deal_header_id) 
			SELECT source_deal_header_id from #tmp_header'
EXEC(@sql)
			
SET @sql = 'spa_deal_insert_update_jobs ''i'', ''' + @after_update_process_table + ''''
SET @job_name = 'spa_deal_insert_update_jobs_' + @job_process_id
 		
EXEC spa_run_sp_as_job @job_name, @sql, 'spa_deal_insert_update_jobs', @user_name	

--Update message board
SET @desc = 'Copy Nomination Process has been completed.'

--EXEC spa_message_board 'u',@user_name, NULL, 'Copy Nomination', @desc, '', '', 'c', @job_name, NULL, @batch_process_id	

/*

	--select * from [source_deal_header]
	--
	 DELETE user_defined_deal_detail_fields
	FROM user_defined_deal_detail_fields h INNER JOIN source_deal_detail d ON h.source_deal_detail_id=d.source_deal_detail_id
	 and d.[source_deal_header_id]>90077

DELETE user_defined_deal_fields
	FROM source_deal_header h INNER JOIN [user_defined_deal_fields] d ON h.source_deal_header_id=d.source_deal_header_id
	 and h.[source_deal_header_id]>90077



	 DELETE [source_deal_detail] WHERE [source_deal_header_id]>90077
	 DELETE [source_deal_header] WHERE [source_deal_header_id]>90077



SELECT sdh.description4 org_header_deal_id,sdh.entire_term_start ,sdh.source_deal_header_id
from #tmp_header sdh
order by 1,2



----old deals

SELECT sdh.description4 org_header_deal_id,sdh.entire_term_start ,sdh.source_deal_header_id,sdh.deal_id,frm_deal.from_deal_id ,coalesce(to_deal.to_deal_id,to_deal1.to_deal_id) to_deal_id
FROM   source_deal_header sdh  inner join #tmp_deals th on sdh.source_deal_header_id=th.source_deal_header_id  
outer apply
( 
	select  u.udf_value from_deal_id
   	from  [user_defined_deal_fields] u 
		inner JOIN [dbo].[user_defined_deal_fields_template] uddft1 ON  isnumeric(u.udf_value)=1 
			and	 u.source_deal_header_id=sdh.source_deal_header_id and uddft1.field_id ='293418' 
			AND uddft1.udf_template_id = u.udf_template_id 
) frm_deal
outer apply
( 
	select  u1.udf_value to_deal_id
   	from  [user_defined_deal_fields] u1 
		inner JOIN [dbo].[user_defined_deal_fields_template] uddft1 ON  isnumeric(u1.udf_value)=1 
			and	 u1.source_deal_header_id=sdh.source_deal_header_id and uddft1.field_id ='293419'  
			AND uddft1.udf_template_id = u1.udf_template_id 
) to_deal
outer apply
( 
	select  u2.source_deal_header_id  to_deal_id
   	from  [user_defined_deal_fields] u2 
		inner JOIN [dbo].[user_defined_deal_fields_template] uddft2 ON  isnumeric(u2.udf_value)=1 
			and	u2.udf_value=CAST(sdh.source_deal_header_id AS VARCHAR) and uddft2.field_id ='293419' 
			AND uddft2.udf_template_id = u2.udf_template_id 
) to_deal1 
where sdh.source_deal_header_id=256420
order by 1,2

----new deals
SELECT sdh.description4 org_header_deal_id,sdh.entire_term_start ,sdh.source_deal_header_id,sdh.deal_id,frm_deal.from_deal_id ,coalesce(to_deal.to_deal_id,to_deal1.to_deal_id) to_deal_id
FROM   source_deal_header sdh  inner join #tmp_header th on sdh.source_deal_header_id=th.source_deal_header_id  
outer apply
( 
	select  u.udf_value from_deal_id
   	from  [user_defined_deal_fields] u 
		inner JOIN [dbo].[user_defined_deal_fields_template] uddft1 ON  isnumeric(u.udf_value)=1 
			and	 u.source_deal_header_id=sdh.source_deal_header_id and uddft1.field_id ='293418' 
			AND uddft1.udf_template_id = u.udf_template_id 
) frm_deal
outer apply
( 
	select  u1.udf_value to_deal_id
   	from  [user_defined_deal_fields] u1 
		inner JOIN [dbo].[user_defined_deal_fields_template] uddft1 ON  isnumeric(u1.udf_value)=1 
			and	 u1.source_deal_header_id=sdh.source_deal_header_id and uddft1.field_id ='293419'  
			AND uddft1.udf_template_id = u1.udf_template_id 
) to_deal
outer apply
( 
	select  u2.source_deal_header_id  to_deal_id
   	from  [user_defined_deal_fields] u2 
		inner JOIN [dbo].[user_defined_deal_fields_template] uddft2 ON  isnumeric(u2.udf_value)=1 
			and	u2.udf_value=CAST(sdh.source_deal_header_id AS VARCHAR) and uddft2.field_id ='293419' 
			AND uddft2.udf_template_id = u2.udf_template_id 
) to_deal1 
where sdh.source_deal_header_id=257208
order by 1,2


*/


