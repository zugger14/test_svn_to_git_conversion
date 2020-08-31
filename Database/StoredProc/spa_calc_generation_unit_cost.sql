
if object_id('spa_calc_generation_unit_cost') is not null
	drop proc dbo.spa_calc_generation_unit_cost 

GO

CREATE PROCEDURE [dbo].[spa_calc_generation_unit_cost] 
	@flag varchar(1)='b'  -- l=long term; s=short term
	,@as_of_date datetime =null
	,@term_start datetime =null
	,@term_end datetime = null
	,@hourly_no_days int=7
	,@group_tou_id int=null
	,@process_id varchar(250)  =null
	,@location_ids varchar(1000) = null --'69693,69688'89996,92011,
	,@call_from_eod INT = 0

AS

SET NOCOUNT ON

/*

----   select * from source_minor_location where location_name  like '%br3%'
declare
	@flag varchar(1)='s'  -- l=long term; s=short term
	,@as_of_date datetime ='2017-06-01'
	,@term_start datetime ='2017-06-01' --'2016-10-06'
	,@term_end datetime = '2017-06-02'
	,@hourly_no_days int=1
	,@group_tou_id int=null
	,@process_id varchar(250)  =null
	,@location_ids varchar(1000) =1588 --1587 --1588 --2624 -- 1587 --2624 --'69693,69688'89996,92011
	,@call_from_eod INT = 0

--select @flag='l', @as_of_date='2017-02-01', @term_start='', @term_end='2017-04-30', @hourly_no_days='', @location_ids=''

-- select @flag='s', @as_of_date='2016-09-30', @term_start='2016-10-01', @term_end='2016-10-04'
--, @hourly_no_days=3, @location_ids=null
--	-- select * from source_deal_header where deal_id in ('Peaker','Cogen')

 -- */

IF OBJECT_ID(N'tempdb..#gen_characterstics') IS NOT NULL DROP TABLE #gen_characterstics
IF OBJECT_ID(N'tempdb..#books') IS NOT NULL DROP TABLE #books
IF OBJECT_ID(N'tempdb..#tmp_hr') IS NOT NULL DROP TABLE #tmp_hr
IF OBJECT_ID(N'tempdb..#tmp_gen_data') IS NOT NULL DROP TABLE #tmp_gen_data
IF OBJECT_ID(N'tempdb..#gen_hourly_data') IS NOT NULL DROP TABLE #gen_hourly_data
IF OBJECT_ID(N'tempdb..#tou_hour_value') IS NOT NULL DROP TABLE #tou_hour_value
IF OBJECT_ID(N'tempdb..#dispatch_cost') IS NOT NULL DROP TABLE #dispatch_cost
IF OBJECT_ID(N'tempdb..#dispatch_cost_mix') IS NOT NULL DROP TABLE #dispatch_cost_mix
IF OBJECT_ID(N'tempdb..#operational_min_max') IS NOT NULL DROP TABLE #operational_min_max
IF OBJECT_ID(N'tempdb..#temp_long_term_cost') IS NOT NULL DROP TABLE #temp_long_term_cost
IF OBJECT_ID(N'tempdb..#volume_post_dataset2') IS NOT NULL DROP TABLE #volume_post_dataset2
IF OBJECT_ID(N'tempdb..#volume_post_dataset_leg1') IS NOT NULL DROP TABLE #volume_post_dataset_leg1
IF OBJECT_ID(N'tempdb..#volume_post_dataset_term_hourly') IS NOT NULL DROP TABLE #volume_post_dataset_term_hourly
IF OBJECT_ID(N'tempdb..#volume_post_dataset_leg1b') IS NOT NULL DROP TABLE #volume_post_dataset_leg1b
IF OBJECT_ID(N'tempdb..#temp_long_term_cost1') IS NOT NULL DROP TABLE #temp_long_term_cost1
IF OBJECT_ID(N'tempdb..#dataset_volume_update') IS NOT NULL DROP TABLE #dataset_volume_update
IF OBJECT_ID(N'tempdb..#volume_post_dataset1') IS NOT NULL DROP TABLE #volume_post_dataset1
IF OBJECT_ID(N'tempdb..#volume_post_dataset') IS NOT NULL DROP TABLE #volume_post_dataset
IF OBJECT_ID(N'tempdb..#inserted_deal_detail') IS NOT NULL DROP TABLE #inserted_deal_detail
IF OBJECT_ID(N'tempdb..#dispatch_cost_mix_incr') IS NOT NULL DROP TABLE #dispatch_cost_mix_incr
IF OBJECT_ID(N'tempdb..#gen_hourly_data11') IS NOT NULL DROP TABLE #gen_hourly_data11
IF OBJECT_ID(N'tempdb..#process_generation_unit_cost') IS NOT NULL DROP TABLE #process_generation_unit_cost
IF OBJECT_ID(N'tempdb..#dispatch_cost_incr') IS NOT NULL DROP TABLE #dispatch_cost_incr
--IF OBJECT_ID(N'tempdb..#dispatch_cost_mix_incr1') IS NOT NULL DROP TABLE #dispatch_cost_mix_incr1
IF OBJECT_ID(N'tempdb..#check_existance') IS NOT NULL DROP TABLE #check_existance
IF OBJECT_ID(N'tempdb..#dispatch_cost_mix_incr') IS NOT NULL DROP TABLE #dispatch_cost_mix_incr
IF OBJECT_ID(N'tempdb..#data_eff_date') IS NOT NULL DROP TABLE #data_eff_date
IF OBJECT_ID(N'tempdb..#gen_hourly_data11111') IS NOT NULL DROP TABLE #gen_hourly_data11111
IF OBJECT_ID(N'tempdb..#short_term_calculated_data') IS NOT NULL DROP TABLE #short_term_calculated_data


declare @st varchar(max) ,@column_list varchar(max),@column_list_sel VARCHAR(MAX)
declare @term_start_hr datetime,@term_end_hr datetime,@db_user varchar(30)

declare @owner_id int
select  @owner_id=source_counterparty_id from dbo.source_counterparty where counterparty_id  ='ATCO Power Canada Ltd.'

declare @create_ts varchar(30),@coal_fuel_id int ,@gas_fuel_id int
--set @tou_id =309302

set @db_user=dbo.FNADBUser()
set @create_ts=getdate()

if @process_id is null 
	set @process_id=REPLACE(newid(),'-','_')

select	@coal_fuel_id =value_id from static_data_value where type_id =10023 and code ='Coal'
select	@gas_fuel_id =value_id from static_data_value where type_id =10023 and code ='Gas'

--Term derive logic is handle in wrapper, so there will not be null in term_start and term_end in both short and long

if @flag ='s'  -- l=long term
begin
	--set @as_of_date=@term_start
	set @group_tou_id=null
	--set @as_of_date=isnull(nullif(@as_of_date,''),@term_start)
	set @term_start_hr =isnull(nullif(@term_start,''),@as_of_date+1)
	
end
else
begin
	
	set @term_start=isnull(@term_start,@as_of_date+1)
	--set @term_start=isnull(nullif(@term_start,''),@as_of_date+1)
	set @group_tou_id=isnull(@group_tou_id,309302)
	set @term_start_hr =@term_start
end

SELECT @term_end_hr =dateadd(hour,-1, @term_end+1)

--select @term_start_hr,@term_end_hr
--return

--Handling ToU for retrieving generator data

select distinct tou,week_day,hr-1 hr,on_off
into #tou_hour_value --- select * from #tou_hour_value
from (
	select hb.block_value_id tou,week_day,
		hb.Hr1 [1],hb.Hr2 [2],hb.Hr3 [3],hb.Hr4 [4],hb.Hr5 [5],hb.Hr6 [6],hb.Hr7 [7],hb.Hr8 [8]
		,hb.Hr9 [9],hb.Hr10 [10],hb.Hr11 [11],hb.Hr12 [12],hb.Hr13 [13]
		,hb.Hr14 [14],hb.Hr15 [15],hb.Hr16 [16],hb.Hr17 [17],hb.Hr18 [18],hb.Hr19 [19],hb.Hr20 [20],hb.Hr21 [21],hb.Hr22 [22],hb.Hr23 [23],hb.Hr24 [24]
	from hourly_block hb 
	inner join block_type_group grp ON  grp.block_type_group_id=@group_tou_id
		and grp.hourly_block_id=hb.block_value_id
) p
UNPIVOT
(
	on_off for hr IN
	( 
		[1],[2],[3],[4],[5],[6],[7],[8],[9],[10],[11],[12],[13],[14],[15],[16],[17],[18],[19],[20],[21],[22],[23],[24] 
	)

) AS unpvt
where on_off=1

select order_id=identity(int,1,1), term_start term_hr,0 is_dst,datepart(hour,term_start) hr,cast(convert(varchar(10),term_start,120) as datetime) term,cast(null as int) tou,datepart(weekday,term_start) week_day into #tmp_hr
 from [dbo].[FNATermBreakdown]('h',@term_start_hr ,@term_end_hr)


-- For now dst is not handled
--INSERT INTO #tmp_hr(term_hr,is_dst,hr,term)
--SELECT 
--	CAST(CONVERT(VARCHAR(10),[date],120)+' '+CAST([hour]-1 AS VARCHAR)+':00' AS DATETIME),1,[hour]-1 hr,[date]
--FROM mv90_dst
--WHERE 	[date] BETWEEN @term_start_hr AND @term_end_hr
--	AND insert_delete = 'i'

update #tmp_hr set tou=tou.tou
from #tmp_hr th inner join #tou_hour_value tou on th.week_day=tou.week_day
		and th.hr=tou.hr


--select * from #tou_hour_value order by 2,3
-- select  * from #tmp_hr
--return


create table #gen_characterstics
(
	location_id INT 
	,fuel_value_id int
	,generator_config_value_id int
	,min_capacity numeric(12,2) 
	,max_capacity numeric(12,2)
	,heat_rate float	
	,coefficient_a	 numeric(20,6) 
	,coefficient_b	 numeric(20,6)
	,coefficient_c	 numeric(20,6)
	,fuel_curve_id int
	,is_default bit
)

begin try

--Take first all the generator characterstics
set @st='
	insert into  #gen_characterstics 
	 (
		 min_capacity,max_capacity,heat_rate,location_id,
		  coefficient_a, coefficient_b, coefficient_c ,fuel_curve_id,fuel_value_id,generator_config_value_id,is_default
	 ) 
	SELECT 
		isnull(charc.unit_min,1),charc.unit_max,charc.heat_rate,sml.source_minor_location_id
		,charc.coeff_a ,charc.coeff_b,charc.coeff_c,charc.fuel_curve_id
		,isnull(charc.fuel_value_id,-1),isnull(charc.generator_config_value_id,-1)
		,isnull(charc.is_default,1) is_default
	FROM dbo.source_minor_location sml inner join dbo.source_major_location smjl 
		on smjl.source_major_location_ID=sml.source_major_location_ID and smjl.location_name=''Generator''
		cross apply
		( 
			select  generator_config_value_id,fuel_value_id,max(isnull(effective_date,''1990-01-01'')) effective_date
			from  [dbo].[generator_characterstics] 
				where  location_id=sml.source_minor_location_id 
					and isnull(effective_date,''1990-01-01'')<='''+convert(varchar(10),@as_of_date,120)+'''
				--	and isnull(is_default,1)=1
				group by generator_config_value_id,fuel_value_id
		) eff
		cross apply
		( 
			select  fuel_value_id,fuel_curve_id,coeff_a ,coeff_b,coeff_c ,heat_rate ,unit_min ,unit_max 
			,isnull(generator_config_value_id,-1) generator_config_value_id,is_default
			from  [dbo].[generator_characterstics] 
				where  location_id=sml.source_minor_location_id 
					and isnull(generator_config_value_id,-1)=isnull(eff.generator_config_value_id,-1) and fuel_value_id=eff.fuel_value_id
					and isnull(effective_date,''1990-01-01'')=eff.effective_date
					--and isnull(is_default,1)=1
		) charc
	WHERE  1=1 '
	+case when isnull(@location_ids,'')='' then '' else ' and sml.source_minor_location_id in ('+@location_ids+' )  ' end

--print @st
exec(@st)


--select * from  #gen_characterstics 
--return

-- take valid(effective date) generator data for all generater characterstics
select
	td.location_id,td.generator_config_value_id,eff.data_type_value_id,eff.effective_date
	, gen_data.tou ,gen_data.data_value,gen_data.hour_from,gen_data.hour_to,9 week_day ,th.term
into #tmp_gen_data    --   select * from #tmp_gen_data where data_type_value_id=44501 and location_id=1601
from #gen_characterstics td
cross join 
(
	select distinct convert(varchar(10),term_hr,120) term from #tmp_hr
) th
outer apply
(
	select	data_type_value_id,isnull(generator_config_value_id,-1) generator_config_value_id,max(effective_date) effective_date 
	from  [dbo].[generator_data] 
	where 
		location_id=td.location_id 
		and isnull(generator_config_value_id,-1)=td.generator_config_value_id
		and  effective_date <=th.term
		and   th.term<isnull(effective_end_date,th.term)+1
		and isnull(period_type,'b') =case when period_type is null then 'b' else case when @flag='s' then 'ST' else 'LT' end end
		--and tou is not null
	group by data_type_value_id,generator_config_value_id
) eff
outer apply
( 
	select data_type_value_id,generator_config_value_id, tou,data_value,hour_from,hour_to from  [dbo].[generator_data] 
	where location_id=td.location_id and data_type_value_id=eff.data_type_value_id 
		and isnull(generator_config_value_id,-1)=eff.generator_config_value_id
		and effective_date=eff.effective_date 
		and isnull(period_type,'b') =case when period_type is null then 'b' else case when @flag='s' then 'ST' else 'LT' end end
		--and tou is not null
) gen_data

-- select * from #tmp_gen_data where data_type_value_id=44500 and location_id=1587 order by 4
--create index indx_tmp_gen_data1 on #tmp_gen_data (location_id,generator_config_value_id,term)

--create index indx_tmp_gen_data2 on #tmp_gen_data (effective_date)



--------------------------------------------------------------
---now generate hourly generator data



select 
	td.location_id,
	td.fuel_value_id,
	td.generator_config_value_id,
	th.term_hr,
	td.min_capacity  ,
	td.max_capacity,
	td.coefficient_a, td.coefficient_b, td.coefficient_c,
	td.is_default,td.heat_rate,
	td.coefficient_a+ td.coefficient_b+ td.coefficient_c   fuel_per_unit,
	th.tou ,td.fuel_curve_id
	,th.term,th.hr
	,cast(case when po.[type_name]='o' and [status]<>'c' then 1 else 0 end as bit) outage
into #gen_hourly_data11111 -- drop table select * from #gen_hourly_data11111 where location_id=1601
-- select th.term
from #gen_characterstics td
		cross join #tmp_hr th
		--(select * from #tmp_hr where term_hr='2017-12-31 00:00:00.000') th
		outer apply
		( 
			select top(1) [type_name],[status],case when [type_name]='o' then 1  when [type_name]='d' then 2  when [type_name]='s' then 3 else 9 end ord from dbo.power_outage 
			where source_generator_id=td.location_id and 
				th.term_hr between isnull(actual_start,planned_start) and isnull(actual_end,planned_end)  
				order by case when [type_name]='o' then 1  when [type_name]='d' then 2  when [type_name]='s' then 3 else 9 end
				--	and isnull([type_name],'a')='o'
		) po
where 
	--po.[type_name] is null and 
	isnull(td.max_capacity,0)>0
	and td.generator_config_value_id<>-309394


select
		td.location_id ,td.generator_config_value_id,eff.data_type_value_id,td.term,eff.effective_date			
into #data_eff_date
from 
	( 
		select distinct location_id ,generator_config_value_id,term from #gen_hourly_data11111 --where term= '2017-12-01 00:00:00.000' and location_id=1601 
		 
	) td
	outer apply
	(
	select data_type_value_id,max(effective_date) effective_date from  #tmp_gen_data
			where 
				location_id=td.location_id and generator_config_value_id=td.generator_config_value_id
				--and th.hr between isnull(hour_from-1,0) and isnull(hour_to-1,23) and tou is null
				and effective_date<=td.term	
			group by data_type_value_id
	) eff

-- select distinct * from #data_eff_date where location_id=1601 and data_type_value_id=44501

select 
	td.location_id,
	coalesce(gen_data.fuel_type,gen_data_tou.fuel_type,td.fuel_value_id,-1) fuel_value_id,
	td.generator_config_value_id,
	td.term_hr,
	td.min_capacity  ,
	--td.max_capacity actual_calc_max_capacity,
	--td.min_capacity actual_calc_min_capacity ,
	td.max_capacity,
	gen_data.contractual_unit_min,
	coalesce(gen_data.om1,gen_data_tou.om1,0) om1,
	coalesce(gen_data.om2,gen_data_tou.om2,0) om2,
	coalesce(gen_data.om3,gen_data_tou.om3,0) om3,
	coalesce(gen_data.om4,gen_data_tou.om4,0) om4,
	coalesce(gen_data.online_indicator,gen_data_tou.online_indicator,0) online_indicator,
	coalesce(gen_data.must_run_indicator,gen_data_tou.must_run_indicator,0) must_run_indicator,
	coalesce(gen_data.operating_limit_constraints,gen_data_tou.operating_limit_constraints,0) operating_limit_constraints,
	coalesce(gen_data.seasonal_variations,gen_data_tou.seasonal_variations,0) seasonal_variations,
	coalesce(gen_data.fuel_gas_intensity,gen_data_tou.fuel_gas_intensity,0) fuel_gas_intensity,
	coalesce(gen_data.OBA_target,gen_data_tou.OBA_target,0) OBA_target,
	coalesce(gen_data.carbon_cost,gen_data_tou.carbon_cost,0) carbon_cost,
	coalesce(gen_data.fuel_coal_intensity,gen_data_tou.fuel_coal_intensity,0) fuel_coal_intensity,
	td.coefficient_a, td.coefficient_b, td.coefficient_c,
	td.is_default,td.heat_rate,
	td.fuel_per_unit,
	td.tou ,td.fuel_curve_id,
	cast(0.0 as numeric(20,6)) fuel_price,
	cast(0.0 as numeric(20,6)) derate_unit
	,td.outage
into #gen_hourly_data -- select * from #gen_hourly_data where convert(varchar(10),term_hr,120)='2017-05-03' and location_id=1587
from #gen_hourly_data11111 td
outer apply
(


	select
		max(case when tgd.data_type_value_id=44500 then  tgd.data_value else null end) contractual_unit_min,
		max(case when tgd.data_type_value_id=44501 then  tgd.data_value else null end) om1,
		max(case when tgd.data_type_value_id=44502 then  tgd.data_value else null end) om2,
		max(case when tgd.data_type_value_id=44503 then  tgd.data_value else null end) om3,
		max(case when tgd.data_type_value_id=44504 then  tgd.data_value else null end) om4,
		max(case when tgd.data_type_value_id=44505 then  tgd.data_value else null end) online_indicator,
		max(case when tgd.data_type_value_id=44506 then  tgd.data_value else null end) must_run_indicator,
		max(case when tgd.data_type_value_id=44507 then  tgd.data_value else null end) operating_limit_constraints,
		max(case when tgd.data_type_value_id=44508 then  tgd.data_value else null end) seasonal_variations,
		max(case when tgd.data_type_value_id=44509 then  tgd.data_value else null end) fuel_type,
		max(case when tgd.data_type_value_id=44510 then  tgd.data_value else null end) fuel_gas_intensity,
		max(case when tgd.data_type_value_id=44511 then  tgd.data_value else null end) OBA_target,
		max(case when tgd.data_type_value_id=44512 then  tgd.data_value else null end) carbon_cost,
		max(case when tgd.data_type_value_id=44513 then  tgd.data_value else null end) fuel_coal_intensity
	from #data_eff_date eff_dt
	inner join  #tmp_gen_data tgd on tgd.effective_date=eff_dt.effective_date and tgd.data_type_value_id=eff_dt.data_type_value_id
		and eff_dt.term=td.term and
			eff_dt.location_id=tgd.location_id and eff_dt.generator_config_value_id=tgd.generator_config_value_id
			and td.hr between isnull(hour_from-1,0) and isnull(hour_to-1,23) and tou is null
			and eff_dt.location_id=td.location_id and td.generator_config_value_id=eff_dt.generator_config_value_id

) gen_data
outer apply
(
	select
		a.tou,
		max(case when a.data_type_value_id=44500  then  a.data_value else 0 end) contractual_unit_min,
		max(case when a.data_type_value_id=44501  then  a.data_value else 0 end) om1,
		max(case when a.data_type_value_id=44502  then  a.data_value else 0 end) om2,
		max(case when a.data_type_value_id=44503  then  a.data_value else 0 end) om3,
		max(case when a.data_type_value_id=44504  then  a.data_value else 0 end) om4,
		max(case when a.data_type_value_id=44505  then  a.data_value else 1 end) online_indicator,
		max(case when a.data_type_value_id=44506  then  a.data_value else 0 end) must_run_indicator,
		max(case when a.data_type_value_id=44507  then  a.data_value else 0 end) operating_limit_constraints,
		max(case when a.data_type_value_id=44508  then  a.data_value else 0 end) seasonal_variations,
		max(case when a.data_type_value_id=44509  then  a.data_value else null end) fuel_type,
		max(case when a.data_type_value_id=44510 then  a.data_value else null end) fuel_gas_intensity,
		max(case when a.data_type_value_id=44511 then  a.data_value else null end) OBA_target,
		max(case when a.data_type_value_id=44512 then  a.data_value else null end) carbon_cost,
		max(case when a.data_type_value_id=44513 then  a.data_value else null end) fuel_coal_intensity
	from #tmp_gen_data a inner join #tou_hour_value b
		on a.location_id=td.location_id and a.generator_config_value_id=td.generator_config_value_id
				and a.tou=b.tou and datepart(weekday,td.hr)=b.week_day and datepart(hour,td.hr)=b.hr-1
	group by a.tou	
) gen_data_tou
where coalesce(gen_data.online_indicator,gen_data_tou.online_indicator,1)=1	


--select * from #gen_hourly_data_pre
--select * from #gen_hourly_data


if @flag='l'
	delete #gen_hourly_data from #gen_hourly_data a inner join dbo.process_generation_unit_cost b
	on a.location_id=b.location_id and a.term_hr=b.term_hr and b.long_short='ST'
	--	and  a.generator_config_value_id =b.generator_config_value_id
			--	and a.fuel_value_id =b.fuel_value_id
				and a.is_default=1 and b.is_default=1

--select * from source_price_curve where source_curve_def_id=6925

-- Take fuel price of curve map with fuel in generator characterstics and derate unit
update #gen_hourly_data set fuel_price=p_hourly.curve_value
	,derate_unit=derate.derate_unit
--  select distinct td.fuel_curve_id,max_aod.as_of_date,ghd.term_hr,max_aod.maturity_date ,derate.derate_unit, p_hourly.curve_value

--select ghd.*

--,
--derate.*
from #gen_hourly_data ghd
	left join #gen_characterstics td on ghd.location_id=td.location_id 
			and  ghd.generator_config_value_id =td.generator_config_value_id
			and ghd.fuel_value_id =td.fuel_value_id
	outer apply
	(
		select top(1) as_of_date,s.maturity_date  from source_price_curve_def d inner join source_price_curve s 
			on d.source_curve_def_id=s.source_curve_def_id and d.source_curve_def_id=td.fuel_curve_id
				and s.maturity_date =case d.Granularity 
										when 980 then convert(varchar(8),ghd.term_hr,120)+'01'
										when 981 then  convert(varchar(10),ghd.term_hr,120)
										else ghd.term_hr end
			 order by as_of_date desc
	)	max_aod
	outer apply
	(
		select spc.curve_value from source_price_curve_def spcd inner join source_price_curve spc 
			on spcd.source_curve_def_id=spc.source_curve_def_id and spc.source_curve_def_id=td.fuel_curve_id
				and spc.as_of_date=max_aod.as_of_date 
				and spc.maturity_date =case spcd.Granularity 
										when 980 then convert(varchar(8),ghd.term_hr,120)+'01'
										when 981 then  convert(varchar(10),ghd.term_hr,120)
										else ghd.term_hr end
				and spc.is_dst=0
	) p_hourly
	outer apply
	(
		select 
			----round(
			
			--sum(cast(isnull(derate_mw,0) as numeric(20,10))) a,((sum(cast(isnull(derate_percent,0) as numeric(20,10)))/100.00)*ghd.max_capacity) b
			
			----,0) derate_unit 
			
			round(
				sum(cast(isnull(derate_mw,0) as numeric(20,10))) +((sum(cast(isnull(derate_percent,0) as numeric(20,10)))/100.00)*ghd.max_capacity)
			,0) derate_unit 
			
		from  
			power_outage
		where 
			source_generator_id=ghd.location_id and ghd.term_hr between isnull(actual_start,planned_start) and isnull(actual_end,planned_end) and [type_name] in ('d','s')
	) derate
--where ghd.term_hr='2017-03-10 02:00:000'	
-------------------------------------------------------------------------------------------------------------------------------------------


-- update as  new default dataset from operational_management_config
--------------------------------------------------------------------------
if @flag='s'
begin

	update #gen_hourly_data
		set  is_default=null

		-- select --charc.*,
		--eff.effective_date,ghd.*
	from  #gen_hourly_data ghd 
		 cross apply
		( 
			select  max(isnull(effective_date,'1990-01-01')) effective_date
   			from  [dbo].[operation_unit_configuration] 
				where  location_id=ghd.location_id and isnull(generator_config_value_id,-1)=ghd.generator_config_value_id
					and isnull(effective_date,'1990-01-01')<=ghd.term_hr 
						and   ghd.term_hr<isnull(effective_end_date,ghd.term_hr)+1
						and isnull(period_type,case when @flag='s' then 'ST'  else 'LT' end)=case when @flag='s' then 'ST'  else 'LT' end
					and  isnull(tou,-1)=isnull(ghd.tou,-1)
						
		) eff
		cross apply
		( 
			select top(1) hour_from ,hour_to,unit_from,unit_to,fuel_value_id 
   			from  [dbo].[operation_unit_configuration]
				where  location_id=ghd.location_id and isnull(generator_config_value_id,-1)=ghd.generator_config_value_id
					and isnull(effective_date,'1990-01-01')=eff.effective_date
						and isnull(period_type,case when @flag='s' then 'ST'  else 'LT' end)=case when @flag='s' then 'ST'  else 'LT' end			
					and  isnull(tou,-1)=isnull(ghd.tou,-1)
		) charc
	where eff.effective_date is not null and charc.fuel_value_id is null
		and unit_from is null and unit_to is null -- as the logic is conflic (scotford and joffre) and this condition is applied only for joffre
			and datepart(hour,ghd.term_hr)+1 between isnull(charc.hour_from,1) and isnull(charc.hour_to,24)

	if @@rowcount>0
	begin
		--return
		--select * from #gen_hourly_data
		--making default=0 to previuosly default=1 only newly updated default=1(null) hour only.
		update pre set  is_default=0 
		from #gen_hourly_data pre inner join
			#gen_hourly_data post on pre.location_id=post.location_id
			and pre.fuel_value_id=post.fuel_value_id --and pre.generator_config_value_id=post.generator_config_value_id
			and pre.term_hr=post.term_hr and pre.is_default=1 and post.is_default is null 

		--update #gen_hourly_data set is_default=0 where is_default is not null
		update  #gen_hourly_data set  is_default=1 from  #gen_hourly_data  where is_default is null
	end
end
--select * from #gen_hourly_data where is_default=1
------------------------------------------------------------------------------------------------------------------------------

--Save generater data/characterstics in hourly granularity

delete dbo.process_generation_unit_cost
from dbo.process_generation_unit_cost a
	inner join
	(
		select distinct location_id from #gen_characterstics
	) loc on a.location_id=loc.location_id
	and a.term_hr between @term_start_hr and  @term_end_hr
where --as_of_date=@as_of_date and 
	long_short=case when @flag='s' then long_short else 'LT' end

-- insert characterstic dataset
insert into dbo.process_generation_unit_cost
	(
		as_of_date,
		long_short,
		location_id ,
		generator_config_value_id,
		fuel_value_id ,
		tou,
		term_hr,
		min_capacity ,
		max_capacity,
		contractual_unit_min ,
		om1,
		om2,
		om3,
		om4,
		online_indicator,
		must_run_indicator,
		operating_limit_constraints,
		seasonal_variations,
		fuel_price,
		derate_unit,coefficient_a, coefficient_b, coefficient_c,is_default,is_mix,heat_rate,fuel_curve_id
		,outage,fuel_gas_intensity,OBA_target,carbon_cost,fuel_coal_intensity
	) 
select		   
	@as_of_date,
	case when @flag='s' then 'ST' else 'LT' end long_short,
	location_id ,
	generator_config_value_id,
	fuel_value_id ,
	tou,
	term_hr,
	--case when @flag='s' then 1 else min_capacity end min_capacity ,
	 min_capacity ,
	max_capacity,
	contractual_unit_min ,
	om1,
	om2,
	om3,
	om4,
	online_indicator,
	must_run_indicator=case when (min_capacity -contractual_unit_min)<0 or contractual_unit_min=0 then 0
else (min_capacity -contractual_unit_min) end ,
	operating_limit_constraints,
	seasonal_variations,
	fuel_price,
	isnull(derate_unit,0),isnull(coefficient_a,0), isnull(coefficient_b,0),isnull(coefficient_c,0)
	,isnull(is_default,1),0,heat_rate,fuel_curve_id
	,outage,fuel_gas_intensity,OBA_target,carbon_cost,fuel_coal_intensity
-- select *
from #gen_hourly_data --where is_default=case when @flag='s' then is_default else 1 end


-- insert mix dataset
insert into dbo.process_generation_unit_cost
	(
		as_of_date,
		long_short,
		location_id ,
		generator_config_value_id,
		fuel_value_id ,
		tou,
		term_hr,
		min_capacity ,
		max_capacity,
		contractual_unit_min ,
		om1,
		om2,
		om3,
		om4,
		online_indicator,
		must_run_indicator,
		operating_limit_constraints,
		seasonal_variations,
		fuel_price,
		derate_unit,coefficient_a, coefficient_b, coefficient_c,is_default,is_mix,heat_rate,fuel_curve_id
		,outage,fuel_gas_intensity,OBA_target,carbon_cost,fuel_coal_intensity
	)
select
	@as_of_date,
	case when @flag='s' then 'ST' else 'LT' end long_short,
	ghd.location_id ,
	ghd.generator_config_value_id,
	ghd.fuel_value_id,
	ghd.tou,
	ghd.term_hr,
	--case when @flag='s' then 1 else ghd.min_capacity end min_capacity ,
	ghd.min_capacity ,
	ghd.max_capacity,
	contractual_unit_min ,
	om1,
	om2,
	om3,
	om4,
	online_indicator,
	must_run_indicator=case when (min_capacity -contractual_unit_min)<0 or contractual_unit_min=0 then 0 else (min_capacity -contractual_unit_min) end ,
	operating_limit_constraints,
	seasonal_variations,
	fuel_price,
	isnull(derate_unit,0),isnull(coefficient_a,0), isnull(coefficient_b,0),isnull(coefficient_c,0),null is_default,1,heat_rate,fuel_curve_id
	,ghd.outage,fuel_gas_intensity,OBA_target,carbon_cost,fuel_coal_intensity
--   select ghd.generator_config_value_id,eff.effective_date, * 
from 
	 #gen_hourly_data ghd 
	 cross apply
	( 
		select  max(isnull(effective_date,'1990-01-01')) effective_date
   		from  [dbo].[operation_unit_configuration] 
			where  location_id=ghd.location_id --and isnull(generator_config_value_id,-1)=ghd.generator_config_value_id
				and isnull(effective_date,'1990-01-01')<=ghd.term_hr
				and  ghd.term_hr<isnull(effective_end_date,ghd.term_hr)+1
				and isnull(period_type,case when @flag='s' then 'ST'  else 'LT' end)=case when @flag='s' then 'ST'  else 'LT' end
				and  isnull(tou,-1)=isnull(ghd.tou,-1)
					
	) eff
	
	cross apply
	( 
		select  top(1) hour_from ,hour_to,unit_from,unit_to,fuel_value_id ,generator_config_value_id
   		from  [dbo].[operation_unit_configuration]
			where  location_id=ghd.location_id --and isnull(generator_config_value_id,-1)=ghd.generator_config_value_id
				and isnull(effective_date,'1990-01-01')=eff.effective_date
				and isnull(period_type,case when @flag='s' then 'ST'  else 'LT' end)=case when @flag='s' then 'ST'  else 'LT' end
				and  isnull(tou,-1)=isnull(ghd.tou,-1)
	) charc
where 
	eff.effective_date is not null and ghd.is_default=1   --and term_hr='2016-10-01'
	and ((charc.generator_config_value_id is not null and ghd.generator_config_value_id<>isnull(charc.generator_config_value_id,-1)
							and ghd.fuel_value_id=isnull(charc.fuel_value_id,-1)
		)	
			or ( charc.generator_config_value_id is null and ghd.fuel_value_id<>isnull(charc.fuel_value_id,-1))
		)


--  select * from dbo.process_short_term_generation_unit_cost where term_hr='2017-04-29 00:00.000' and location_id=1587	and unit_value<=12


--/*  ---View Query

select distinct location_id,generator_config_value_id,fuel_value_id,term_hr into #gen_hourly_data11 from #gen_hourly_data 

create index indx_gen_hourly_data11 on #gen_hourly_data11 (location_id,generator_config_value_id,fuel_value_id,term_hr) 


select 
	td.rec_id,td.as_of_date,td.long_short,td.location_id,td.generator_config_value_id,td.fuel_value_id
	,td.tou,td.term_hr,td.min_capacity,td.max_capacity
	,coalesce(nullif(td.contractual_unit_min,0),td.min_capacity,1) contractual_unit_min
	,td.om1,td.om2,td.om3
	,td.om4,td.online_indicator,td.must_run_indicator,td.operating_limit_constraints,td.seasonal_variations
	,td.fuel_price,td.derate_unit,td.coefficient_a,td.coefficient_b,td.coefficient_c,td.fuel_curve_id
	,td.heat_rate
	,isnull(td.is_default,1) is_default,td.is_mix,
	unt.min_unit ,case when  unt.max_unit>0 then unt.max_unit else 0 end max_unit
	, case when  unt.max_unit>0 then unt.max_unit else 0 end+1 max_unit1
	, case when  unt.max_unit_actual>0 then unt.max_unit_actual else 0 end max_unit_actual
	, eff.effective_date
	, td.outage
	, td.fuel_gas_intensity fuel_intensity 
	--,case when td.fuel_value_id = @gas_fuel_id then  td.fuel_gas_intensity else td.fuel_coal_intensity end fuel_intensity 
	,td.OBA_target,td.carbon_cost
	--,overlap_fuel_value_id=cast(null as int)
	--,overlap_fuel_curve_id=cast(null as int)
into #process_generation_unit_cost   ---     select * from process_generation_unit_cost where term_hr='2016-12-31 00:00:00.000' and location_id=1587 is_default=1 order by unit_value
--   select td.* 
from #gen_hourly_data11 ghd
	inner join dbo.process_generation_unit_cost td on 
		td.location_id=ghd.location_id
		and td.is_mix=0
		and td.generator_config_value_id=ghd.generator_config_value_id
		and td.fuel_value_id=ghd.fuel_value_id
		and	td.term_hr=ghd.term_hr
		and td.long_short=case when @flag='s' then 'ST' else 'LT' end
	--	and td.as_of_date=@as_of_date --and td.term_hr='2016-10-01 00:00:00.000'
	
outer apply
( 
	select  max(isnull(effective_date,'1990-01-01')) effective_date from  [dbo].[operation_unit_configuration] 
		where  location_id=td.location_id --and isnull(generator_config_value_id,-1)=td.generator_config_value_id
			and isnull(effective_date,'1990-01-01')<=td.term_hr 
			and    td.term_hr<isnull(effective_end_date,td.term_hr)+1
		--	and isnull(period_type,case when @flag='s' then 'ST' else 'LT' end)=case when @flag='s' then 'ST' else 'LT' end 
			and ((generator_config_value_id is not null and td.generator_config_value_id<>isnull(generator_config_value_id,-1)
					and td.fuel_value_id=isnull(fuel_value_id,-1)
			)	
				or ( generator_config_value_id is null and td.fuel_value_id<>isnull(fuel_value_id,-1))
			)
			and datepart(hour,td.term_hr)+1 between isnull(hour_from,1) and isnull(hour_to,24) 
				--and td1.unit_value between isnull(unit_from,0) and isnull(unit_to,999999)	
			and	td.is_default=1
) eff
left join #gen_characterstics gc on  gc.location_id=ghd.location_id
	and gc.generator_config_value_id=ghd.generator_config_value_id and gc.is_default=1
outer apply
(
	select 1 min_unit
		--coalesce(nullif(td.contractual_unit_min,0),td.min_capacity,1) min_unit
	--case when td.is_default=1 then 1 else case when td.min_capacity<coalesce(nullif(td.contractual_unit_min,0),td.min_capacity,1) then coalesce(nullif(td.contractual_unit_min,0),td.min_capacity,1) else td.min_capacity end end min_unit
	--case when td.long_short='ST' then td.min_capacity else  case when td.is_default=1 then coalesce(nullif(td.contractual_unit_min,0),td.min_capacity,1) else td.min_capacity end end min_unit
		-- ,case when  td.long_short='ST' then td.max_capacity else td.max_capacity-  isnull(td.operating_limit_constraints,0)- isnull(round(td.derate_unit,0),0)- isnull(td.seasonal_variations,0) end max_unit
		,td.max_capacity-  isnull(td.operating_limit_constraints,0)- 
			case when gc.fuel_value_id=td.fuel_value_id then isnull(round(td.derate_unit,0),0) else 0 end - isnull(td.seasonal_variations,0)  max_unit_actual
		,td.max_capacity max_unit
) unt
	 

--create index index_#process_generation_unit_cost_1 on #process_generation_unit_cost (location_id ,generator_config_value_id,fuel_value_id,term_hr)
create index index_#process_generation_unit_cost_2 on #process_generation_unit_cost (max_unit1)
create index index_#process_generation_unit_cost_200 on #process_generation_unit_cost
				 (location_id ,generator_config_value_id,fuel_value_id,term_hr,is_default)
create index index_#process_generation_unit_cost_200a on #process_generation_unit_cost (is_default)
--drop table #dispatch_cost
--return

declare @geneter_joffre_id int
select @geneter_joffre_id=source_minor_location_id
from source_minor_location where location_id='JOF1'

select 
	td.rec_id,
	mw.n unit_value,
	(mw.n*mw.n*td.coefficient_a)+(mw.n*td.coefficient_b)+td.coefficient_c fuel,
	((mw.n*mw.n*td.coefficient_a)+(mw.n*td.coefficient_b)+td.coefficient_c) *td.fuel_price fuel_amount,
	mw.n*td.om1 om1,
	mw.n*td.om2 om2,
	case when td.location_id=@geneter_joffre_id and mw.n>=210 then (mw.n-209)*td.om3 else 0 end om3,
	mw.n*td.om4 om4
	,mw.n-1 unit_value1
	,td.max_unit_actual
	,td.outage,td.fuel_intensity,td.OBA_target,td.carbon_cost
	,td.om3 om3a
into #dispatch_cost   ---     select * from #dispatch_cost where location_id=2626 and term_hr='2016-10-01 00:00:00.000' and is_default=1 order by unit_value
--   select td.* 
from #process_generation_unit_cost td 
inner join dbo.seq mw on mw.n < td.max_unit1 and mw.n>0


--create index index_dispatch_cost_1 on #dispatch_cost (rec_id,unit_value)
--create index index_dispatch_cost_100 on #dispatch_cost (rec_id,unit_value1)

-- update characterstic dataset for incremental cost
--update a set
 
select a.rec_id ,a.unit_value,
	--inc_cost1=(a.fuel_amount+a.om1+a.om2+a.om3+a.om4+((((a.fuel*a.fuel_intensity)/a.unit_value)-a.OBA_target)*a.carbon_cost))
	--		-isnull((b.fuel_amount+b.om1+b.om2+b.om3+b.om4+((((b.fuel*b.fuel_intensity)/a.unit_value)-b.OBA_target)*b.carbon_cost)),0)

	inc_cost1=(a.fuel_amount+a.om1+a.om2+a.om4)
			-isnull(b.fuel_amount+b.om1+b.om2+b.om4,0)
			+((((a.fuel*a.fuel_intensity)/a.unit_value)-a.OBA_target)*a.carbon_cost)+(a.om3/isnull(nullif(a.unit_value-209,0),1))

	--,inc_cost=(a.fuel_amount+a.om1+a.om2+a.om3+a.om4)-isnull(b.fuel_amount+b.om1+b.om2+b.om3+b.om4,0)

	,inc_cost=(a.fuel_amount+a.om1+a.om2+a.om4)-isnull(b.fuel_amount+b.om1+b.om2+b.om4,0)
	,inc_fuel=a.fuel-isnull(b.fuel,0)
	,inc_fuel_amount=a.fuel_amount-isnull(b.fuel_amount,0)
	
	--,total_cost=(a.fuel_amount+a.om1+a.om2+a.om3+a.om4)+((((a.fuel*a.fuel_intensity)/a.unit_value)-a.OBA_target)*a.carbon_cost)
	,total_cost=(a.fuel_amount+a.om1+a.om2+a.om4)
	
	--,avg_cost=(a.fuel_amount+a.om1+a.om2+a.om3+a.om4+((((a.fuel*a.fuel_intensity)/a.unit_value)-a.OBA_target)*a.carbon_cost))/a.unit_value
	,avg_cost=((a.fuel_amount+a.om1+a.om2+a.om4)/a.unit_value) + ((((a.fuel*a.fuel_intensity)/a.unit_value)-a.OBA_target)*a.carbon_cost)+(a.om3/isnull(nullif(a.unit_value-209,0),1))

	,emissions=a.fuel*a.fuel_intensity
	,emissions_intensity=(a.fuel*a.fuel_intensity)/a.unit_value
	,reduced_baseline=((a.fuel*a.fuel_intensity)/a.unit_value)-a.OBA_target
	,carbon_cost=(((a.fuel*a.fuel_intensity)/a.unit_value)-a.OBA_target)*a.carbon_cost
	,inc_carbon_cost=((((a.fuel*a.fuel_intensity)/a.unit_value)-a.OBA_target)*a.carbon_cost)-isnull((((b.fuel*b.fuel_intensity)/b.unit_value)-b.OBA_target)*b.carbon_cost,0)
into #dispatch_cost_incr --  select * from #dispatch_cost_incr where unit_value=1
from #dispatch_cost a
	left join  #dispatch_cost b on b.rec_id=a.rec_id 
		and b.unit_value=a.unit_value1


--where 		b.rec_id is null
	-- select * from #dispatch_cost_incr
--create index index_dispatch_cost_incr_1 on #dispatch_cost_incr (rec_id,unit_value)
--create index index_process_generation_unit_cost_1333 on #process_generation_unit_cost (location_id,effective_date)

select 
	td.long_short,
	td.location_id,
	td.generator_config_value_id,
	td.fuel_value_id,
	td.term_hr ,
	--isnull(ovr_wr.min_unit, isnull(nullif(pg.contractual_unit_min,0),1) ) min_unit
	isnull(ovr_wr.min_unit, isnull(nullif(td.contractual_unit_min,0),1) ) min_unit 
	, isnull(ovr_wr.max_unit,td.max_unit) max_unit ,
	td1.unit_value,
	--isnull(ovr_wr1.fuel,td1.fuel) fuel,
--	isnull(ovr_wr1.fuel_amount,td1.fuel_amount) fuel_amount,
	isnull(ovr_wr2.inc_fuel,td2.inc_fuel) inc_fuel
	,isnull(ovr_wr2.inc_fuel_amount,td2.inc_fuel_amount) inc_fuel_amount,
	isnull(ovr_wr1.om1,td1.om1) om1,
	isnull(ovr_wr1.om2,td1.om2) om2,
	isnull(ovr_wr1.om3,td1.om3) om3,
	isnull(ovr_wr1.om4,td1.om4) om4,
	isnull(ovr_wr1.om3a,td1.om3a) om3a,
--	isnull(ovr_wr2.total_cost,td2.total_cost) total_cost,
	--isnull(ovr_wr2.avg_cost,td2.avg_cost) avg_cost ,
	isnull(ovr_wr2.inc_cost,td2.inc_cost) inc_cost,
	isnull(ovr_wr2.inc_cost1,td2.inc_cost1) inc_cost1,
	isnull(ovr_wr2.inc_carbon_cost,td2.inc_carbon_cost) inc_carbon_cost,

	isnull(ovr_wr1.om1,td1.om1) inc_om1,
	isnull(ovr_wr1.om2,td1.om2) inc_om2,
	isnull(ovr_wr1.om3,td1.om3) inc_om3,
	isnull(ovr_wr1.om4,td1.om4) inc_om4,
	isnull(ovr_wr1.fuel_intensity,td1.fuel_intensity) fuel_intensity,
	isnull(ovr_wr1.OBA_target,td1.OBA_target) OBA_target,
	isnull(ovr_wr1.carbon_cost,td1.carbon_cost) gen_carbon_cost,

	isnull(ovr_wr.must_run_indicator,td.must_run_indicator) must_run_indicator,
	isnull(ovr_wr.operating_limit_constraints,td.operating_limit_constraints) operating_limit_constraints,
	isnull(ovr_wr.seasonal_variations,td.seasonal_variations) seasonal_variations,
	isnull(ovr_wr.fuel_price,td.fuel_price) fuel_price,
	isnull(ovr_wr.derate_unit,td.derate_unit) derate_unit
	,isnull(ovr_wr.coefficient_a,td.coefficient_a) coefficient_a
	,isnull(ovr_wr.coefficient_b,td.coefficient_b) coefficient_b
	,isnull(ovr_wr.coefficient_c,td.coefficient_c) coefficient_c
	,isnull(ovr_wr.fuel_curve_id,td.fuel_curve_id) fuel_curve_id
	,1 is_mix
	,isnull(ovr_wr.heat_rate,td.heat_rate) heat_rate
	,null is_default
	,td.tou
	,nullif(ovr_wr.fuel_value_id,-1) overlap_fuel_value_id
	,nullif(ovr_wr.fuel_curve_id,-1) overlap_fuel_curve_id
	,nullif(ovr_wr.generator_config_value_id,-1) overlap_generator_config_value_id
	,isnull(nullif(td.contractual_unit_min,0),1) contractual_unit_min
	,td1.rec_id
	,td.max_unit_actual
	,td.outage
	,isnull(ovr_wr2.emissions,td2.emissions) emissions
	,isnull(ovr_wr2.emissions_intensity,td2.emissions_intensity) emissions_intensity
	,isnull(ovr_wr2.reduced_baseline,td2.reduced_baseline) reduced_baseline
	,isnull(ovr_wr2.carbon_cost,td2.carbon_cost) carbon_cost

	--,rowid = identity(int,1,1)
 into #dispatch_cost_mix --  select * from #dispatch_cost_mix where  convert(varchar(10),term_hr='2016-12-22 22:00:00.000' order by unit_value
-- select charc.generator_config_value_id ,charc.fuel_value_id ,td.*, charc.* ,ovr_wr.*   --,  charc.* 
-- select  eff.effective_date --,ovr_wr.* ,td.*
from  #process_generation_unit_cost td 
inner join  #dispatch_cost td1   on  td.rec_id=td1.rec_id 	and td.is_default=1
left join #dispatch_cost_incr td2 on  td1.rec_id=td2.rec_id and td1.unit_value=td2.unit_value
outer apply
( 
	select top(1) hour_from ,hour_to,unit_from,unit_to,isnull(fuel_value_id,-1) fuel_value_id
		,isnull(generator_config_value_id ,-1) generator_config_value_id
	from  [dbo].[operation_unit_configuration]
		where  location_id=td.location_id --and isnull(generator_config_value_id,-1)=td.generator_config_value_id
			and isnull(effective_date,'1990-01-01')=td.effective_date
			--and isnull(period_type,case when @flag='s' then 'ST' else 'LT' end)=case when @flag='s' then 'ST' else 'LT' end  
			and ((generator_config_value_id is not null and td.generator_config_value_id<>isnull(generator_config_value_id,-1)
					and td.fuel_value_id=isnull(fuel_value_id,-1)
			)	
				or ( generator_config_value_id is null and td.fuel_value_id<>isnull(fuel_value_id,-1))
			)
			and datepart(hour,td.term_hr)+1 between isnull(hour_from,1) and isnull(hour_to,24) 
				and td1.unit_value between isnull(unit_from,0) and isnull(unit_to,999999)
) charc
left join #process_generation_unit_cost ovr_wr on ovr_wr.location_id=td.location_id 
	and ovr_wr.generator_config_value_id=charc.generator_config_value_id 
	and ovr_wr.fuel_value_id=charc.fuel_value_id and  ovr_wr.term_hr=td.term_hr and ovr_wr.is_default=0
	--and ovr_wr.min_unit+ovr_wr.unit_value-1=td.unit_value 
left join #dispatch_cost ovr_wr1   on  ovr_wr.rec_id=ovr_wr1.rec_id
	and td1.unit_value= ovr_wr.min_unit+ovr_wr1.unit_value-1 
left join #dispatch_cost_incr ovr_wr2 on  ovr_wr1.rec_id=ovr_wr2.rec_id and ovr_wr1.unit_value=ovr_wr2.unit_value
where --td.is_default=1 and
	 isnull(ovr_wr.generator_config_value_id,-1)<>-309394
-- order by  td.location_id,td.fuel_value_id,td.generator_config_value_id,td.term_hr ,td.unit_value

--create index index_dispatch_cost_mixt_1 on #dispatch_cost_mix (location_id ,generator_config_value_id,fuel_value_id,unit_value)
--create index index_dispatch_cost_mixt_3a on #dispatch_cost_mix (location_id ,generator_config_value_id,fuel_value_id)

--create index index_dispatch_cost_mix_2 on #dispatch_cost_mix (rec_id,unit_value)
--create index indx_a2 on #dispatch_cost_mix ( location_id,term_hr)

select distinct location_id, term_hr into #check_existance from #dispatch_cost_mix where  overlap_fuel_value_id is not null
		
--create index indx_a3 on #check_existance ( location_id,term_hr)


delete m
	from #dispatch_cost_mix m 
	inner join #gen_characterstics d
	on m.location_id=d.location_id 
		and d.generator_config_value_id=-309394
		and m.fuel_value_id=d.fuel_value_id
		and m.unit_value between d.min_capacity and d.max_capacity
	left join #check_existance check_existance	
		on m.location_id=check_existance.location_id and m.term_hr=check_existance.term_hr
	where 	check_existance.location_id is null


-- select * from #dispatch_cost_mix where  term_hr='2016-12-31 00:00:00.000' order by unit_value
 
--return
--  select * 	from #dispatch_cost where term_hr='2016-10-03 00:00:00.000' and is_default<>1
-- select * 	from #dispatch_cost_mix where term_hr='2016-10-01' order by unit_value
----select * 	from #volume_post_dataset where term_hr='2016-10-01'


--select * 	from #dispatch_cost_mix where term_hr='2016-10-01 08:00:00' order by unit_value
--select * 	from #dispatch_cost_mix where term_hr='2016-10-01 10:00:00' order by unit_value


select  rec_id,unit_value,
	total_cost=sum(inc_cost) over (PARTITION BY  rec_id order by unit_value)
	--total_cost=sum(inc_cost1) over (PARTITION BY  rec_id order by unit_value)
	--+((((sum(inc_fuel)  over (PARTITION BY rec_id order by unit_value)*a.fuel_intensity)/a.unit_value)-a.OBA_target)*a.gen_carbon_cost)
	--,avg_cost=sum(inc_cost) over(PARTITION BY location_id,generator_config_value_id,fuel_value_id,term_hr order by rowid)/unit_value
	,fuel_amount=sum(inc_fuel_amount)  over (PARTITION BY  rec_id order by unit_value)
	,fuel=sum(inc_fuel)  over (PARTITION BY rec_id order by unit_value)
	,carbon_cost=((((sum(inc_fuel)  over (PARTITION BY rec_id order by unit_value)*a.fuel_intensity)/a.unit_value)-a.OBA_target)*a.gen_carbon_cost)
	,emissions=sum(inc_fuel)  over (PARTITION BY rec_id order by unit_value)*a.fuel_intensity
	,emissions_intensity=(sum(inc_fuel)  over (PARTITION BY rec_id order by unit_value)*a.fuel_intensity)/a.unit_value
	,reduced_baseline=((sum(inc_fuel)  over (PARTITION BY rec_id order by unit_value)*a.fuel_intensity)/a.unit_value)-a.OBA_target
-- select b.*,a.*
into #dispatch_cost_mix_incr
from #dispatch_cost_mix a


--select a.rec_id ,a.unit_value,
--	inc_cost=a.total_cost-isnull(b.total_cost,0)
--into #dispatch_cost_mix_incr1 --  select * from #dispatch_cost_incr where unit_value=1
--from #dispatch_cost_mix_incr a
--	left join  #dispatch_cost_mix_incr b on b.rec_id=a.rec_id 
--		and b.unit_value=a.unit_value-1


--return

--select * from dbo.process_short_term_generation_unit_cost where term_hr='2017-04-29 00:00.000' 
--and location_id=1587	and unit_value<=12
--order by fuel_value_id, unit_value

--outer apply
--(
--	select sum(inc_fuel)  over (PARTITION BY rec_id order by unit_value) fuel
--) fuel 



--inc_cost=(a.fuel_amount+a.om1+a.om2+a.om3+a.om4+((((a.fuel*a.fuel_intensity)/a.unit_value)-a.OBA_target)*a.carbon_cost))
--			-isnull((b.fuel_amount+b.om1+b.om2+b.om3+b.om4+((((b.fuel*b.fuel_intensity)/a.unit_value)-b.OBA_target)*b.carbon_cost)),0)
--	,inc_fuel=a.fuel-isnull(b.fuel,0)
--	,inc_fuel_amount=a.fuel_amount-isnull(b.fuel_amount,0)
--	,total_cost=(a.fuel_amount+a.om1+a.om2+a.om3+a.om4)+((((a.fuel*a.fuel_intensity)/a.unit_value)-a.OBA_target)*a.carbon_cost)
--	,avg_cost=(a.fuel_amount+a.om1+a.om2+a.om3+a.om4+((((a.fuel*a.fuel_intensity)/a.unit_value)-a.OBA_target)*a.carbon_cost))/a.unit_value
--	,emissions=a.fuel*a.fuel_intensity
--	,emissions_intensity=(a.fuel*a.fuel_intensity)/a.unit_value
--	,reduced_baseline=((a.fuel*a.fuel_intensity)/a.unit_value)-a.OBA_target
--	,carbon_cost=(((a.fuel*a.fuel_intensity)/a.unit_value)-a.OBA_target)*a.carbon_cost
--	,inc_carbon_cost=((((a.fuel*a.fuel_intensity)/a.unit_value)-a.OBA_target)*a.carbon_cost)-isnull((((b.fuel*b.fuel_intensity)/b.unit_value)-b.OBA_target)*b.carbon_cost,0)





--  select * from #dispatch_cost_mix_incr a
--select * from #dispatch_cost_mix a order by term_hr,unit_value
--select * from #dispatch_cost_mix a where rec_id=8497 and unit_value=1

--create index index_tmp_data_2 on #dispatch_cost_mix_incr (rec_id,unit_value)

----update mix dataset for incremental cost
--update #dispatch_cost_mix set 
--	total_cost=b.total_cost
--	,avg_cost=b.total_cost/a.unit_value
--	,fuel_amount=b.fuel_amount
--	,fuel=b.fuel
---- select b.*,a.*
--from #dispatch_cost_mix a
--inner join #dispatch_cost_mix_incr b on a.rec_id=b.rec_id and a.unit_value=b.unit_value



----update mix dataset for incremental cost
--update #dispatch_cost_mix set 
--	inc_cost=0 where unit_value=1
	

-- select * from #dispatch_cost_mix where  term_hr='2017-05-19 00:00:00.000' and location_id=1587 and is_mix=1


/*

select * from dbo.process_generation_unit_cost where as_of_date=@as_of_date and long_short=case when @flag='s' then 'ST' else 'LT' end
select * from #dispatch_cost


--*/



--create index index_dispatch_cost_3a on #process_generation_unit_cost (location_id ,generator_config_value_id,fuel_value_id,is_default)


delete #process_generation_unit_cost
	from #process_generation_unit_cost d inner join #dispatch_cost_mix m  
	on m.location_id=d.location_id 
		and m.generator_config_value_id=d.generator_config_value_id
		and m.fuel_value_id=d.fuel_value_id
	where d.is_default=1
			

--select * from #dispatch_cost where unit_value<contractual_unit_min
--select contractual_unit_min* from #dispatch_cost_mix where unit_value<contractual_unit_min
--return


--delete #dispatch_cost where unit_value<contractual_unit_min
--delete #dispatch_cost_mix where unit_value<contractual_unit_min

update #process_generation_unit_cost set min_unit=contractual_unit_min where isnull(contractual_unit_min,0)>min_unit
update #dispatch_cost_mix set min_unit=contractual_unit_min where isnull(contractual_unit_min,0)>min_unit


--create table #volume_post_dataset
--(
--	location_id int,generator_config_value_id int,fuel_value_id int,fuel_curve_id int
--	 ,tou int,term_hr datetime,min_unit int , max_unit int
--	,volume int,min_total_cost numeric(20,6),max_total_cost numeric(20,6),fuel numeric(20,6),fuel_price numeric(20,6)
--	,coefficient_a numeric(20,6) , coefficient_b numeric(20,6), coefficient_c numeric(20,6),contractual_unit_min numeric(20,6)
--	,data_source char(1) COLLATE DATABASE_DEFAULT -- m=mixed, d=default
--)

	--insert into #volume_post_dataset
	--	(
	--		location_id ,generator_config_value_id ,fuel_value_id ,fuel_curve_id ,tou ,term_hr 
	--		 ,min_unit, max_unit,volume,min_total_cost,max_total_cost,fuel,fuel_price
	--		,coefficient_a,coefficient_b,coefficient_c,contractual_unit_min,data_source
	--	)
	
select 
	l.location_id
	,isnull(l.overlap_generator_config_value_id,l.generator_config_value_id) generator_config_value_id
	,isnull(l.overlap_fuel_value_id,l.fuel_value_id) fuel_value_id
	,max(isnull(l.overlap_fuel_curve_id,l.fuel_curve_id)) fuel_curve_id
	,max(l.tou) tou,l.term_hr,max(l.min_unit) min_unit , max(l.max_unit) max_unit
	,volume=count(1)
	,case when max(l.min_unit)=1 then 0 else min(t.total_cost) end  min_total_cost
	,max(t.total_cost) max_total_cost
	,cast(0.0 as numeric(28,4)) fuel
	,max(l.fuel_price) fuel_price
	,max(l.coefficient_a) coefficient_a
	,max(l.coefficient_b) coefficient_b
	,max(l.coefficient_c) coefficient_c
	,max(l.contractual_unit_min) contractual_unit_min,
	case when max(l.overlap_generator_config_value_id) is null then 'd' else 'm' end data_source
	,0 dst
	, case when max(l.min_unit)=1 then 0 else  MIN(t.carbon_cost) end min_carbon_cost
	, MIN(t.carbon_cost) max_carbon_cost
	,max(l.om3) om3
	,max(l.om3a) om3a
into #volume_post_dataset
from #dispatch_cost_mix l left join #dispatch_cost_mix_incr t on l.rec_id=t.rec_id and l.unit_value=t.unit_value
where l.unit_value>=l.contractual_unit_min
	and l.unit_value<=l.max_unit_actual and l.outage=0
group by
	l.location_id,isnull(l.overlap_generator_config_value_id,l.generator_config_value_id)
	,isnull(l.overlap_fuel_value_id,l.fuel_value_id),l.term_hr
	
union all

select 
	max(t.location_id) location_id
	,max(t.generator_config_value_id) generator_config_value_id
	,max(t.fuel_value_id) fuel_value_id
	,max(t.fuel_curve_id) fuel_curve_id
	,max(t.tou) tou ,max(t.term_hr) term_hr ,max(t.min_unit) min_unit , max(t.max_unit) max_unit
	,volume=count(1)
	,case when max(t.min_unit)=1 then 0 else min(t1.total_cost) end  min_total_cost
	,max(t1.total_cost) max_total_cost
	,cast(0.0 as numeric(28,4)) fuel
	,max(t.fuel_price) fuel_price
	,max(t.coefficient_a) coefficient_a
	,max(t.coefficient_b) coefficient_b
	,max(t.coefficient_c) coefficient_c
	,max(t.contractual_unit_min) contractual_unit_min,'d' data_source
	,0 dst
	, case when max(t.min_unit)=1 then 0 else MIN(t1.carbon_cost) end  min_carbon_cost
	, MIN(t1.carbon_cost)   max_carbon_cost
	,max(t.om3) om3
	,max(l.om3a) om3a
from  #dispatch_cost l inner join #process_generation_unit_cost t on l.rec_id=t.rec_id
	left join #dispatch_cost_incr t1 on l.rec_id=t1.rec_id and l.unit_value=t1.unit_value 
where t.is_default=1 and l.unit_value>=t.contractual_unit_min
	and l.unit_value<=l.max_unit_actual and l.outage=0
group by
	t.rec_id



-- select * from #volume_post_dataset order by term_hr,fuel_value_id



--update 
--	a
--set data_source=b.data_source
--from ##volume_post_dataset a 
--cross apply
--	(
--		select max(data_source) data_source from #volume_post_dataset 
--		where a.location_id=location_id   
--	) b	


update -- deduct 1 in default volume
	a
set volume=a.volume-
-- select a.*,	
case 
	--when a.generator_config_value_id<>no_def.generator_config_value_id and td.is_default<>1
	--	and a.fuel_value_id=no_def.fuel_value_id then 1 --scotford
	when	a.generator_config_value_id<>no_def.generator_config_value_id --and td.is_default=1
		and a.fuel_value_id=no_def.fuel_value_id and data_source='m' and td.is_default=1 then 1 --scotford
		when a.generator_config_value_id<>no_def.generator_config_value_id and td.is_default=1
			and a.fuel_value_id=no_def.fuel_value_id and data_source='d'
			and a.contractual_unit_min>1 then 1 --joffre
		when no_def.generator_config_value_id is null and td.is_default=1 and a.contractual_unit_min>1 then 1 --valley view
		when a.generator_config_value_id=isnull(no_def.generator_config_value_id,-1) and td.is_default=1
			and a.fuel_value_id<>isnull(no_def.fuel_value_id,-1) 
			and a.contractual_unit_min>1 then 1 ---br3
	else 0 end
	
-- select 
--a.generator_config_value_id,no_def.generator_config_value_id , td.is_default
--		, a.fuel_value_id,no_def.fuel_value_id
--,
--a.contractual_unit_min,data_source

--select  a.generator_config_value_id,no_def.generator_config_value_id , td.is_default
		--, a.fuel_value_id,no_def.fuel_value_id
		
from #volume_post_dataset a 
	inner join #gen_characterstics td on a.location_id=td.location_id 
				and  a.generator_config_value_id =td.generator_config_value_id
				and a.fuel_value_id =td.fuel_value_id --and td.is_default=1
outer apply
	(
		select top(1) * from #gen_characterstics 
		where a.location_id=location_id   
			and (
					(
						a.fuel_value_id <>fuel_value_id and a.generator_config_value_id =generator_config_value_id --case for normal unit where fuel is different and generator unit is same
					) 
					or 
					(
						a.fuel_value_id=fuel_value_id and a.generator_config_value_id <>generator_config_value_id --case for multi turbant 2t,3t where fuel is same
					) 
				 )		
	) no_def	

	



--------------------------------------------------------
--- DST Handling
---------------------------------------------------------
-- For now dst is not handled
/*
	delete #volume_post_dataset from #volume_post_dataset s
	inner join mv90_dst dst on s.term_hr=dateadd(hour,dst.[hour]-1,dst.[date])
		and dst.insert_delete='d'

	delete #tmp_hr from #tmp_hr s
	inner join mv90_dst dst on s.term_hr=dateadd(hour,dst.[hour]-1,dst.[date])
		and dst.insert_delete='d'


	INSERT INTO #tmp_hr(term_hr,is_dst,hr,term)
	SELECT 
		CAST(CONVERT(VARCHAR(10),[date],120)+' '+CAST([hour]-1 AS VARCHAR)+':00' AS DATETIME),1,[hour]-1 hr,[date]
	from #tmp_hr s
	inner join mv90_dst dst on s.term_hr=dateadd(hour,dst.[hour]-1,dst.[date])
		and dst.insert_delete='i'


	insert into #volume_post_dataset ( 
		location_id
		,generator_config_value_id
		,fuel_value_id
		,fuel_curve_id
		,tou
		,term_hr
		,min_unit 
		,max_unit
		,volume
		,min_total_cost
		,max_total_cost
		,fuel
		,fuel_price
		,coefficient_a
		,coefficient_b
		,coefficient_c
		, contractual_unit_min
		,[data_source]
		,dst
	)		
	select 
		location_id
		,generator_config_value_id
		,fuel_value_id
		,fuel_curve_id
		,tou
		,term_hr
		,min_unit 
		,max_unit
		,volume
		,min_total_cost
		,max_total_cost
		,fuel
		,fuel_price
		,coefficient_a
		,coefficient_b
		,coefficient_c
		, contractual_unit_min
		,[data_source]
		,1 dst
	from #volume_post_dataset  s
	inner join mv90_dst dst on s.term_hr=dateadd(hour,dst.[hour]-1,dst.[date])
		and dst.insert_delete='i'

*/
------------------------------------------------------------


--Inserting term into source_deal_detail/source_deal_detail_hour for update volume 

if OBJECT_ID('tempdb..#volume_post_dataset_term_hourly') is not null --deal_detail_hour level term -- assume hourly
	drop table #volume_post_dataset_term_hourly

select location_id,tou,term_hr,dst
	,convert(varchar(10),term_hr,120) term 
	,right('0'+cast(datepart(hour,term_hr)+1 as varchar),2)+':00' hr
	,sum(volume) volume, (max(max_total_cost)-min(min_total_cost))/sum(volume)+isnull(max(om3a),0) price
	, MIN(max_carbon_cost)-MIN(min_carbon_cost) carbon_cost
into #volume_post_dataset_term_hourly  -- select * from #volume_post_dataset_term_hourly order by term,hr
from #volume_post_dataset
group by location_id, term_hr,tou,dst
--order by 3,2
--  select * from #volume_post_dataset order by term_hr

--  select * from #volume_post_dataset where term_hr='2016-10-03 00:00:00.000'

if OBJECT_ID('tempdb..#volume_post_dataset_term_deal') is not null --deal_detail level term -- assume monthly
	drop table #volume_post_dataset_term_deal

select location_id
	,convert(varchar(7),term,120)+'-01' term 
	,sum(volume) volume, max(price) price
into #volume_post_dataset_term_deal  -- select * from #volume_post_dataset_term_deal order by term,hr
from #volume_post_dataset_term_hourly
group by location_id, convert(varchar(7),term,120)


-------------------Insert terms in deal detail--------------------------------------------------------

CREATE TABLE #inserted_deal_detail (
	source_deal_header_id	INT, 
	source_deal_detail_id	INT,
	leg						INT,
	term_start datetime,
	term_end datetime,
	location_id int,
	curve_id int
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
	  -- , [total_volume]
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
	   , [lock_deal_detail],detail_commodity_id,position_uom,source_deal_group_id)
OUTPUT INSERTED.source_deal_header_id, INSERTED.source_deal_detail_id ,INSERTED.leg,inserted.term_start
	,inserted.term_end,inserted.location_id,inserted.curve_id
INTO #inserted_deal_detail
select sdd_cpy.[source_deal_header_id]
	   , gen_term.term
	   , dateadd(month,1,gen_term.term)-1 term_end
	   , sdd_cpy.[Leg]
	   , sdd_cpy.[contract_expiration_date]
	   , sdd_cpy.[fixed_float_leg]
	   , sdd_cpy.[buy_sell_flag]
	   , sdd_cpy.[curve_id]
	   , sdd_cpy.[fixed_price]
	   , sdd_cpy.[fixed_price_currency_id]
	   , sdd_cpy.[option_strike_price]
	   ,0 [deal_volume]
	   , sdd_cpy.[deal_volume_frequency]
	   , sdd_cpy.[deal_volume_uom_id]
	   , sdd_cpy.[block_description]
	   , sdd_cpy.[deal_detail_description]
	   , sdd_cpy.[formula_id]
	   ,0 [volume_left]
	   , sdd_cpy.[settlement_volume]
	   , sdd_cpy.[settlement_uom]
	   , sdd_cpy.[create_user]
	   , getdate() [create_ts]
	   , sdd_cpy.[update_user]
	   , getdate() [update_ts]
	   , sdd_cpy.[price_adder]
	   , sdd_cpy.[price_multiplier]
	   , sdd_cpy.[settlement_date]
	   , sdd_cpy.[day_count_id]
	   , sdd_cpy.[location_id]
	   , sdd_cpy.[meter_id]
	   , sdd_cpy.[physical_financial_flag]
	   , sdd_cpy.[Booked]
	   , sdd_cpy.[process_deal_status]
	   , sdd_cpy.[fixed_cost]
	   , sdd_cpy.[multiplier]
	   , sdd_cpy.[adder_currency_id]
	   , sdd_cpy.[fixed_cost_currency_id]
	   , sdd_cpy.[formula_currency_id]
	   , sdd_cpy.[price_adder2]
	   , sdd_cpy.[price_adder_currency2]
	   , sdd_cpy.[volume_multiplier2]
	  -- , sdd_cpy.[total_volume]
	   , sdd_cpy.[pay_opposite]
	   , sdd_cpy.[capacity]
	   , sdd_cpy.[settlement_currency]
	   , sdd_cpy.[standard_yearly_volume]
	   , sdd_cpy.[formula_curve_id]
	   , sdd_cpy.[price_uom_id]
	   , sdd_cpy.[category]
	   , sdd_cpy.[profile_code]
	   , sdd_cpy.[pv_party]
	   , sdd_cpy.[status]
	   , sdd_cpy.[lock_deal_detail]	
	   ,sdd_cpy.detail_commodity_id,sdd_cpy.position_uom,sdd_cpy.source_deal_group_id
--  select sdd.* 
from #volume_post_dataset_term_deal gen_term 
left join dbo.source_deal_detail sdd on gen_term.location_id=sdd.location_id
	and gen_term.term=sdd.term_start and sdd.leg=1
outer apply
( 
	select distinct location_id,curve_id,leg from dbo.source_deal_detail 
		where  location_id=gen_term.location_id and sdd.source_deal_detail_id is null
) cpy_leg 
outer apply
( 
 select top(1) * from dbo.source_deal_detail  where  location_id=cpy_leg.location_id  
	and curve_id=cpy_leg.curve_id and leg=cpy_leg.leg and sdd.source_deal_detail_id is null
) sdd_cpy	
where sdd.source_deal_detail_id is null

--delete dbo.source_deal_detail_hour where source_deal_detail_id in (
--33287,
--33228,
--33967
--)

--select * from #volume_post_dataset_term_hourly

--while 1=1
begin

	if @flag='s'
		delete  sddh
		from  dbo.source_deal_detail sdd 
		inner join source_deal_detail_hour sddh
			on sddh.source_deal_detail_id=sdd.source_deal_detail_id
				and sddh.term_date between @term_start_hr and @term_end_hr
		 --and sdd.source_deal_detail_id=99212
		 inner join
		(
			select distinct location_id from  #gen_characterstics 
		) flt on flt.location_id=sdd.location_id
	else
	begin

		select distinct b.location_id,convert(varchar(10),b.term_hr,120) dt,right('0'+cast(datepart(hour,b.term_hr)+1 as varchar),2)+':00' hr	
		into #short_term_calculated_data
		from 
			(
				select distinct location_id from  #gen_characterstics 
			) flt
			inner join dbo.process_generation_unit_cost b
				on flt.location_id=b.location_id 
		where b.is_default=1 and b.long_short='ST'

		delete sddh
		from  dbo.source_deal_detail sdd 
		inner join source_deal_detail_hour sddh
			on sddh.source_deal_detail_id=sdd.source_deal_detail_id
				and sddh.term_date between @term_start_hr and @term_end_hr
		 --and sdd.source_deal_detail_id=99212
		 inner join
		(
			select distinct location_id from  #gen_characterstics 
		) flt on flt.location_id=sdd.location_id
		left join #short_term_calculated_data b
			on flt.location_id=b.location_id and
			sddh.hr=b.hr and sddh.term_date=b.dt
			--	and  a.generator_config_value_id =b.generator_config_value_id
					--	and a.fuel_value_id =b.fuel_value_id

		where b.location_id is null
	end
--	checkpoint
	--if @@rowcount<100000
	--	BREAK
end	

insert into dbo.source_deal_detail_hour
(
	source_deal_detail_id,
	term_date,
	hr,
	is_dst,
	volume,
	price,
	formula_id,
	granularity
)
select sdd.source_deal_detail_id,
	gen_term.term,
	gen_term.hr,
	gen_term.dst is_dst,
	0 volume, --gen_term.volume,
	0 price, --gen_term.price,
	null formula_id,
	982 granularity
from #volume_post_dataset_term_hourly gen_term 
inner join dbo.source_deal_detail sdd on gen_term.location_id=sdd.location_id
	and gen_term.term between sdd.term_start and sdd.term_end --and sdd.leg=1
left join source_deal_detail_hour sddh on sddh.source_deal_detail_id=sdd.source_deal_detail_id
	and sddh.term_date=gen_term.term and sddh.hr=gen_term.hr
--	and sddh.is_dst=gen_term.dst
where sddh.source_deal_detail_id is null


insert into dbo.source_deal_detail_hour
(
	source_deal_detail_id,
	term_date,
	hr,
	is_dst,
	volume,
	price,
	formula_id,
	granularity
)
select sdd.source_deal_detail_id,
	hr.term,
	right('0'+cast(hr.hr+1 as varchar),2)+':00' hr,
	hr.is_dst,
	0 volume, --gen_term.volume,
	0 price, --gen_term.price,
	null formula_id,
	982 granularity
--  select cast(left(sddh.hr,2) as int)-1 a,sddh.source_deal_detail_id,sddh.hr,hr.hr
from  dbo.source_deal_detail sdd 
inner join
(
	select distinct location_id from  #gen_characterstics 
) flt on flt.location_id=sdd.location_id
--inner join dbo.power_outage po
--	on po.source_generator_id= sdd.location_id and isnull(po.[type_name],'a')='o'
inner join #tmp_hr hr on hr.term_hr between sdd.term_start and dateadd(hour,-1,sdd.term_end+1)
--and hr.term_hr='2016-12-22 02:00:000'
left join source_deal_detail_hour sddh on sddh.source_deal_detail_id=sdd.source_deal_detail_id
	and sddh.term_date=hr.term and cast(left(sddh.hr,2) as int)-1=hr.hr
--	and sddh.is_dst=hr.is_dst
where 	sddh.source_deal_detail_id is null
--and sdd.source_deal_detail_id=97651 and hr.term='2016-12-22' 

 --and sdd.source_deal_detail_id=99212

--select * from #tmp_hr
--and sdd.source_deal_detail_id=97651 and hr.term='2016-12-22' 

--select * from source_deal_detail_hour where source_deal_detail_id=97651 and term_date='2016-12-22'
--	and hr='02:00'
	
update source_deal_header set entire_term_end=sdd.term_end
from source_deal_header sdh
cross apply
(
	select max(term_end) term_end from dbo.source_deal_detail d
	 inner join
		(
			select distinct location_id from  #gen_characterstics 
		) flt on flt.location_id=d.location_id
	where d.source_deal_header_id=sdh.source_deal_header_id
) sdd
where sdd.term_end is not null  

-----------------------------------------------------------------------------------------------------


------------------process updating deal leg=1 volume update
--  select * from #volume_post_dataset_term_hourly

update source_deal_detail_hour
	set volume=case when isnull(gen_term.volume,0)>0 then isnull(gen_term.volume,0) else 0 end
		,price=case when isnull(gen_term.volume,0)>0 then isnull(gen_term.price,0) + ISNULL(gen_term.carbon_cost, 0) else 0 end 
from dbo.source_deal_detail sdd 
inner join source_deal_detail_hour sddh on sddh.source_deal_detail_id=sdd.source_deal_detail_id
inner join
(
	select distinct location_id,term from  #volume_post_dataset_term_hourly
) flt on flt.location_id=sdd.location_id and flt.term=sddh.term_date and sdd.leg=1
inner join #volume_post_dataset_term_hourly gen_term on gen_term.location_id=sdd.location_id
	and gen_term.term between sdd.term_start and sdd.term_end	
 	and  sddh.hr=gen_term.hr and gen_term.term=sddh.term_date
	--and sddh.is_dst=gen_term.dst
-- select * from #volume_post_dataset	order by term_hr
	
update #volume_post_dataset set fuel=power(volume,2)*coefficient_a+(volume*coefficient_b)+coefficient_c

--select power(volume,2)*coefficient_a+(volume*coefficient_b)+coefficient_c fuel
--,volume,coefficient_a,coefficient_b,coefficient_c,*  from #volume_post_dataset

select location_id,generator_config_value_id,fuel_value_id
	,fuel_curve_id,tou,term_hr,max_unit,min_unit,dst
	,max(fuel) fuel,max(fuel_price) fuel_price
into #volume_post_dataset1 --     select * from   #volume_post_dataset1  order by term_hr
from #volume_post_dataset
group by location_id,generator_config_value_id,fuel_value_id
	,tou,term_hr,fuel_curve_id,max_unit,min_unit,dst

	
if OBJECT_ID('tempdb..#volume_post_dataset3') is not null
drop table #volume_post_dataset3

select 
	fuel_curve_id 
	, location_id
	, convert(varchar(10),term_hr,120) term
	, right('0'+cast(datepart(hour,term_hr)+1 as varchar),2)+':00' hr,dst
	,sum(fuel) volume , max(fuel_price)  price
into #volume_post_dataset3 --  select * from #volume_post_dataset3 order by term,hr
from #volume_post_dataset1  
group by
	fuel_curve_id , location_id, term_hr,dst

update source_deal_detail_hour set volume=case when isnull(tmp.volume,0)>0 then isnull(tmp.volume,0) else 0 end
	,price=case when isnull(tmp.volume,0)>0 then isnull(tmp.price,0) else 0 end
--   select sddh.hr,sdd.location_id,sdd.curve_id,sddh.term_date,sddh.hr,tmp.volume,tmp.price
from source_deal_detail_hour sddh inner join source_deal_detail sdd on sddh.source_deal_detail_id=sdd.source_deal_detail_id
	and sdd.leg<>1 --and sdd.location_id=1587
inner join
(
	select distinct fuel_curve_id,location_id,term from #volume_post_dataset3 
		
) flt on flt.location_id=sdd.location_id and flt.fuel_curve_id=sdd.curve_id
	and flt.term=sddh.term_date
inner join #volume_post_dataset3 tmp
	on tmp.fuel_curve_id =sdd.curve_id
		and tmp.location_id=sdd.location_id
		and tmp.term=sddh.term_date
		and tmp.hr=sddh.hr
--		and sddh.is_dst=tmp.dst
--where tmp.price is not null

update source_deal_detail
	set deal_volume=gen_term.volume
		,fixed_price=gen_term.price/gen_term.volume
		,multiplier=per.owner_per
--select deal_volume,fixed_price
from dbo.source_deal_detail sdd inner join 
(select distinct location_id from #gen_characterstics) loc on sdd.location_id=loc.location_id
cross apply
(
	select sum(volume*price) price, sum(volume) volume from  source_deal_detail_hour 
	where source_deal_detail_id=sdd.source_deal_detail_id
) gen_term
outer apply
(
	select top(1) owner_per/100 owner_per from dbo.generator_ownership_allocation
	where location_id=loc.location_id and owner_id=@owner_id
	order by effective_date desc
) per
where  gen_term.volume<>0

------------------------------------------------------------------------


--- process saving long term data	

if @flag='s'
begin
	delete dbo.process_short_term_generation_unit_cost
	from dbo.process_short_term_generation_unit_cost a
	inner join
	(
		select distinct location_id from  #gen_characterstics 
	) loc
	 on a.location_id=loc.location_id 
	-- and a.term_hr=ghd.term_hr
	and a.term_hr between @term_start_hr and @term_end_hr
	
	--delete dbo.process_short_term_generation_unit_cost
	--from dbo.process_short_term_generation_unit_cost a
	--inner join #dispatch_cost_mix ghd on a.location_id=ghd.location_id  and a.term_hr=ghd.term_hr
	
	
	--set @db_user=dbo.FNADBUser()
	set @create_ts=getdate()

	--select * from #dispatch_cost 
	update  #dispatch_cost_incr set inc_cost=0 where unit_value=1
	update  #dispatch_cost_mix set inc_cost=0 where unit_value=1
	update  #dispatch_cost_mix set inc_cost1=0 where unit_value=1
	update  #dispatch_cost_mix set inc_carbon_cost=0 where unit_value=1
	update #dispatch_cost_mix set inc_cost1=0 where unit_value=1
	update #dispatch_cost_mix_incr set carbon_cost=0 where unit_value=1

	insert into dbo.process_short_term_generation_unit_cost
	(
		location_id,generator_config_value_id,fuel_value_id,term_hr ,min_unit , max_unit
		 ,unit_value,fuel,fuel_amount,coefficient_a,coefficient_b,coefficient_c,om1 ,om2,om3,om4 
		,total_cost,avg_cost,inc_cost,must_run_indicator,operating_limit_constraints,seasonal_variations 
		,fuel_price,derate_unit,is_mix,is_default,heat_rate,fuel_curve_id
		,overlap_fuel_value_id,overlap_fuel_curve_id,overlap_generator_config_value_id,create_ts,create_user,max_unit_actual
		,emissions,emissions_intensity,reduced_baseline,carbon_cost
	)
	select 
		l.location_id,l.generator_config_value_id,l.fuel_value_id,l.term_hr ,l.min_unit, l.max_unit 
		,t.unit_value,t.fuel,t.fuel_amount,
		l.coefficient_a,l.coefficient_b,l.coefficient_c,t.om1 ,t.om2,t.om3,t.om4 ,t1.total_cost,t1.avg_cost,t1.inc_cost1
		,l.must_run_indicator,l.operating_limit_constraints,l.seasonal_variations ,l.fuel_price,l.derate_unit
		,l.is_mix,l.is_default,l.heat_rate,l.fuel_curve_id
		,null overlap_fuel_value_id, null overlap_fuel_curve_id, null overlap_generator_config_value_id
		,@create_ts,@db_user,t.max_unit_actual
		,t1.emissions,t1.emissions_intensity,t1.reduced_baseline,t1.carbon_cost
	from  #dispatch_cost t inner join #process_generation_unit_cost l on l.rec_id=t.rec_id
	left join  #dispatch_cost_incr t1 on t.rec_id=t1.rec_id and t.unit_value=t1.unit_value 

	--print 'llllllllllllllll2'

	insert into dbo.process_short_term_generation_unit_cost
	(
		location_id,generator_config_value_id,fuel_value_id,term_hr ,min_unit , max_unit
		 ,unit_value,fuel,fuel_amount,coefficient_a,coefficient_b,coefficient_c,om1 ,om2,om3,om4 
		,total_cost,avg_cost,inc_cost,must_run_indicator,operating_limit_constraints,seasonal_variations 
		,fuel_price,derate_unit,is_mix,is_default,heat_rate,fuel_curve_id
		,overlap_fuel_value_id,overlap_fuel_curve_id,overlap_generator_config_value_id,create_ts,create_user,max_unit_actual
		,emissions,emissions_intensity,reduced_baseline,carbon_cost
	)
	select 
		l.location_id,l.generator_config_value_id,l.fuel_value_id,l.term_hr ,l.min_unit , l.max_unit ,l.unit_value,t.fuel,t.fuel_amount,
		l.coefficient_a,l.coefficient_b,l.coefficient_c,l.om1 ,l.om2 ,l.om3 ,l.om4 ,t.total_cost
		,(t.total_cost/l.unit_value)+ t.carbon_cost+(l.om3/isnull(nullif(l.unit_value-209,0),1))  avg_cost
		,l.inc_cost+t.carbon_cost+(l.om3/isnull(nullif(l.unit_value-209,0),1)) inc_cost --   l.inc_cost1+l.inc_carbon_cost
		,l.must_run_indicator,l.operating_limit_constraints,l.seasonal_variations ,l.fuel_price,l.derate_unit,l.is_mix
		,l.is_default,l.heat_rate,l.fuel_curve_id,l.overlap_fuel_value_id,l.overlap_fuel_curve_id,l.overlap_generator_config_value_id
		,@create_ts,@db_user,l.max_unit_actual
		,t.emissions,t.emissions_intensity,t.reduced_baseline,t.carbon_cost
	 from #dispatch_cost_mix l
	left join  #dispatch_cost_mix_incr t on t.rec_id=l.rec_id and t.unit_value=l.unit_value
--	left join #dispatch_cost_mix_incr1 t1 on t.rec_id=t1.rec_id and t.unit_value=t1.unit_value
	--where term_hr='2017-05-19 00:00.000'
	--order by l.unit_value

end
else if @flag='l'
begin	
	
	delete dbo.process_long_term_generation_unit_cost --where as_of_date=@as_of_date
	from dbo.process_long_term_generation_unit_cost a
	inner join #volume_post_dataset ghd on a.location_id=ghd.location_id  and a.term=convert(varchar(7),ghd.term_hr,120)+'-01'

	insert into  dbo.process_long_term_generation_unit_cost
	(
		as_of_date ,location_id ,generator_config_value_id ,fuel_value_id ,tou,term ,volume ,price
	)
	select @as_of_date ,
		--  select
		 location_id ,null ,null ,tou
		 ,convert(varchar(7),term,120)+'-01' term,sum(volume) volume ,sum(volume*price)/sum(volume)
	from #volume_post_dataset_term_hourly
	group by location_id,tou
	--group by location_id ,generator_config_value_id ,fuel_value_id ,tou
	,convert(varchar(7),term,120)

end


--select * from process_long_term_generation_unit_cost
	--IF @call_from_eod =  0
	--EXEC spa_ErrorHandler 0
	--	, 'spa_process_power_dashboard'
	--	, 'spa_process_power_dashboard'
	--	, 'Success' 
	--	, 'Calculation completed successfully.'
	--	, ''
end try
begin catch

	declare @desc varchar(max)
	select @desc=isnull(error_message(),'')
	IF @call_from_eod =  0
	EXEC spa_ErrorHandler -1
			, 'spa_calc_generation_unit_cost'
			, 'spa_calc_generation_unit_cost'
			, 'Success' 
			, @desc
			, ''
	
end catch
