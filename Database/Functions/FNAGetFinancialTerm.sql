IF OBJECT_ID('[dbo].[FNAGetFinancialTerm]','tf') IS NOT NULL 
DROP FUNCTION [dbo].FNAGetFinancialTerm 
GO 

 /**
	Get the financial term details

	Parameters :
	@deal_detail_id : Deal Detail Id
	@ticket_detail_id : Ticket Detail Id

	Returns Table with details
 */

CREATE FUNCTION [dbo].[FNAGetFinancialTerm] 
(
	@deal_detail_id int,@ticket_detail_id int=null
)
returns @tt table(
	pricing_index int
	,term_start datetime
	,term_end datetime
	,multiplier float
	,price_multiplier float
	,adder float
	,volume float
	,uom int
)
AS
BEGIN



/*

--select * from position_break_down_rule
--select * from deal_position_break_down
--select * from deal_detail_formula_udf
--select * from deal_price_type
--select * from deal_price_deemed
--select * from deal_price_std_event 
--select * from deal_price_custom_event
--select * from static_data_value where type_id=106600   --pricing_period

--select *
--from source_deal_detail sdd 
--	where sdd.source_deal_header_id=10291

--	106604	d
--106602	d
--select dpd.*
--from source_deal_detail sdd 
--	inner join deal_price_type dpt on sdd.source_deal_detail_id=dpt.source_deal_detail_id
--	--and sdd.source_deal_header_id=6597
--		--and dpt.source_deal_detail_id=214174  -- @deal_detail_id --
--	inner join deal_price_deemed dpd on dpt.deal_price_type_id= dpd.deal_price_type_id
--		--and dpd.pricing_index=7185
		
--select * from [dbo].[pricing_period_setup] 103601

--select * from  source_deal_detail  where source_deal_header_id=22624 
--select * from deal_position_break_down
--select * from hour_block_term


--*/

--declare @deal_detail_id int=5892,@ticket_detail_id int=null
--drop table #TempTable

declare @time_zone_id int
declare @event_date datetime
declare @deal_date datetime

if @ticket_detail_id is not null
	select @event_date=movement_date_time from ticket_detail where ticket_detail_id= @ticket_detail_id


select @deal_date=max(sdh.deal_date) from dbo.source_deal_header sdh inner join dbo.source_deal_detail sdd on sdh.source_deal_header_id=sdd.source_deal_header_id where sdd.source_deal_detail_id=@deal_detail_id

SELECT @time_zone_id=var_value   --26
  FROM dbo.adiha_default_codes_values(nolock)
  WHERE instance_no = 1 AND default_code_id = 36 AND seq_no = 1


Declare @TempTable TABLE(      
	pricing_index int
	,fin_term_start datetime
	,fin_term_end datetime
	,multiplier float
	,price_multiplier float
	,adder float
	,volume float
	,uom  int
	,min_exp_date datetime
	,max_exp_date datetime
	,exp_calendar_id int
	,holiday_calendar_id int
	,pricing_period int
	,include_weekends varchar(1)
	,expiration_calendar bit
	,weekend_first_day int
	,weekend_second_day int
	,event_date date
	,include_event_date  varchar(1)
	,skip_date date
	,skip_granularity int,skip_days int,quotes_after int,BOLMO_pricing char(1)
	,hourly_volume_allocation int
	,fin_term_min date,fin_term_max date
)      
 
 /* 
create table #TempTable (      
	pricing_index int
	,fin_term_start datetime
	,fin_term_end datetime
	,multiplier float
	,price_multiplier float
	,adder float
	,volume float
	,uom  int
	,min_exp_date datetime
	,max_exp_date datetime
	,exp_calendar_id int
	,holiday_calendar_id int
	,pricing_period int
	,include_weekends varchar(1)
	,expiration_calendar bit
	,weekend_first_day int
	,weekend_second_day int
	,event_date date
	,include_event_date  varchar(1)
	,skip_date date
	,skip_granularity int,skip_days int,quotes_after int,BOLMO_pricing char(1),hourly_volume_allocation int
	,fin_term_min date,fin_term_max date
)      

-- select * from #TempTable
--*/


/*


17603	17600	Allocation by Expiration Calendar	Allocation by Expiration Calendar
17606	17600	Cumulative Month Expiration	Cumulative Month Expiration
17602	17600	Daily Allocation	Daily Allocation
17601	17600	Monthly Average Allocations	Monthly Average Allocations
17605	17600	Physical Allocation	Physical Allocation
17604	17600	TOU Allocation with Expiration Calendar	TOU Allocation with Expiration Calendar
17600	17600	TOU Allocations	TOU Allocations



*/
insert into @TempTable (
	pricing_index
	,fin_term_start
	,fin_term_end
	,multiplier
	,price_multiplier
	,adder
	,volume
	,uom
	,min_exp_date
	,max_exp_date
	,exp_calendar_id
	,holiday_calendar_id 
	,pricing_period
	,include_weekends
	,expiration_calendar 
	,weekend_first_day 
	,weekend_second_day 
	,event_date,include_event_date
	,skip_date 
	,skip_granularity,skip_days,quotes_after,BOLMO_pricing,hourly_volume_allocation,fin_term_min,fin_term_max
)

select term.pricing_index
	,isnull(term.fin_term_start,sdd.term_start) fin_term_start
	,isnull(term.fin_term_end,sdd.term_end) fin_term_end
	,coalesce(term.multiplier,cast(term.volume as float)/sdd.deal_volume,1) multiplier
	,coalesce(term.price_multiplier,1) price_multiplier
	,term.adder
	,term.volume
	,term.uom
	,isnull(exp_max.min_exp_date,sdd.term_start) min_exp_date
	,isnull(exp_max.max_exp_date,sdd.term_end) max_exp_date	
	,spcd.exp_calendar_id
	,spcd.holiday_calendar_id
	,term.pricing_period
	,isnull(term.include_weekends,'n') include_weekends
	,term.expiration_calendar 
	,isnull(tz.weekend_first_day,7) weekend_first_day
	,isnull(tz.weekend_second_day,1) weekend_second_day
	,term.event_date,term.include_event_date
	,term.skip_date
	,skip_granularity,skip_days,quotes_after,term.BOLMO_pricing
	,spcd.hourly_volume_allocation  
	,min(isnull(term.fin_term_start,sdd.term_start)) over(partition by pricing_index) fin_term_min
	,max(isnull(term.fin_term_end,sdd.term_end)) over(partition by pricing_index) fin_term_max
from source_deal_detail sdd 
	inner join deal_price_type dpt on sdd.source_deal_detail_id=dpt.source_deal_detail_id
		and dpt.source_deal_detail_id=@deal_detail_id --141519  -- 
		and dpt.price_type_id not in (103607,103604,103600)
	outer apply
	(
		select dateadd(mm, r.pricing_term, sdd.term_start) fin_term_start
			,CASE WHEN isnull(dpd.BOLMO_pricing,'n')='y' THEN  sdd.term_end ELSE dateadd(mm, r.pricing_term+1, sdd.term_start)-1 END  fin_term_end
			,r.multiplier,dpd.volume,dpd.multiplier price_multiplier,dpd.adder,dpd.uom
			,dpd.pricing_period,dpd.include_weekends,pps.expiration_calendar 
			,dpd.pricing_index,null event_date,'y' include_event_date,null skip_date
			,null skip_granularity,null skip_days,null quotes_after,dpd.BOLMO_pricing
		from  deal_price_deemed dpd
			inner join [dbo].[pricing_period_setup] pps on pps.pricing_period_value_id=dpd.pricing_period
				and dpd.deal_price_type_id=dpt.deal_price_type_id
			inner join [dbo].position_break_down_rule r on r.strip_from=pps.average_period
				and r.lag=pps.skip_period 
				AND r.strip_to=pps.delivery_period
				AND month(sdd.term_start) = r.phy_month	
				and pps.period_type='m'
		union all
		select dpd.pricing_start fin_term_start
			,CASE WHEN isnull(dpd.BOLMO_pricing,'n')='y' THEN  sdd.term_end ELSE isnull(dpd.pricing_end,dpd.pricing_start) END  fin_term_end
			,1 multiplier,dpd.volume,dpd.multiplier price_multiplier,dpd.adder,dpd.uom
			,dpd.pricing_period,isnull(dpd.include_weekends,'n') include_weekends,pps.expiration_calendar 
			,dpd.pricing_index,null event_date,'y' include_event_date,null skip_date
			,null skip_granularity,null skip_days,null quotes_after,dpd.BOLMO_pricing
		from  deal_price_deemed dpd
			inner join [dbo].[pricing_period_setup] pps on pps.pricing_period_value_id=dpd.pricing_period
				and dpd.deal_price_type_id=dpt.deal_price_type_id
				and pps.period_type='d'
		union all
		select isnull(dpd.pricing_start,sdd.term_start) fin_term_start
			,CASE WHEN isnull(dpd.BOLMO_pricing,'n')='y' THEN  sdd.term_end ELSE isnull(dpd.pricing_end,sdd.term_end) END fin_term_end
			,1 multiplier,dpd.volume,dpd.multiplier price_multiplier,dpd.adder,dpd.uom
			,dpd.pricing_period,isnull(dpd.include_weekends,'n') include_weekends,0 expiration_calendar 
			,dpd.pricing_index,null event_date,'y' include_event_date,null skip_date
			,null skip_granularity,null skip_days,null quotes_after,dpd.BOLMO_pricing
		from  deal_price_deemed dpd 
			--left join source_price_curve_def spcd on spcd.source_curve_def_id=dpd.pricing_index
			--left join source_price_curve_def spcd1 on spcd1.source_curve_def_id=spcd.settlement_curve_id 
		where dpd.pricing_period is null and nullif(dpd.pricing_dates,'') is null AND dpd.deal_price_type_id=dpt.deal_price_type_id

		union all
		select dt.item fin_term_start
			,CASE WHEN isnull(dpd.BOLMO_pricing,'n')='y' THEN  sdd.term_end ELSE dt.item END fin_term_end
			,1 multiplier,dpd.volume,dpd.multiplier price_multiplier,dpd.adder,dpd.uom
			,dpd.pricing_period,isnull(dpd.include_weekends,'n') include_weekends,null expiration_calendar 
			,dpd.pricing_index,null event_date,'y' include_event_date,null skip_date
			,null skip_granularity,null skip_days,null quotes_after,dpd.BOLMO_pricing
		from  deal_price_deemed dpd
			cross apply dbo.FNASplit(dpd.pricing_dates,';') dt
		where nullif(dpd.pricing_dates,'') is not null  AND dpd.deal_price_type_id=dpt.deal_price_type_id
		union all
		select 
			--case when dpce.include_holidays='y' then
			--dbo.FNAGetBusinessDayN('p',dpce.event_date,spcd1.holiday_calendar_id,isnull(dpce.quotes_before,0)-case when isnull(dpce.include_event_date,'n')='n' then 0 else 1 end)
			--else
			dbo.FNAGetBusinessDayN('p',isnull(@event_date,dpce.event_date),spcd1.holiday_calendar_id,isnull(dpce.quotes_before,0)-case when isnull(dpce.include_event_date,'n')='n' then 0 else 1 end) fin_term_start,
			CASE WHEN isnull(dpce.BOLMO_pricing,'n')='y' THEN  sdd.term_end ELSE case when dpce.skip_granularity in (990,980) then
				case when dpce.include_holidays='y' then
					dbo.FNAGetBusinessDayN('n',dbo.FNAGetSkippedDate(isnull(@event_date,dpce.event_date),dpce.skip_granularity,isnull(dpce.skip_days,0)),spcd1.holiday_calendar_id,isnull(dpce.quotes_after,0))
				else
					dbo.FNAGetBusinessDayN('n',dateadd(day,-1,dbo.FNAGetSkippedDate(isnull(@event_date,dpce.event_date),dpce.skip_granularity,isnull(dpce.skip_days,0))),spcd1.holiday_calendar_id,isnull(dpce.quotes_after,0)+1) 
				end 		
			else
				case when dpce.include_holidays='y' then
					dbo.FNAGetBusinessDayN('n',isnull(@event_date,dpce.event_date),spcd1.holiday_calendar_id,isnull(dpce.skip_days,0)+isnull(dpce.quotes_after,0)-case when isnull(dpce.include_event_date,'n')='n' then 0 else 1 end)
				else
					dbo.FNAGetBusinessDayN('n',isnull(@event_date,dpce.event_date)-1,spcd1.holiday_calendar_id,isnull(dpce.skip_days,0)+isnull(dpce.quotes_after,0)-case when isnull(dpce.include_event_date,'n')='n' then 0 else 1 end+1) end 
			end END fin_term_end
			,1 multiplier,dpce.volume,dpce.multiplier price_multiplier,dpce.adder,dpce.uom
			,null pricing_period,isnull(dpce.include_holidays,'n') include_weekends,0 expiration_calendar 
			,dpce.pricing_index,isnull(@event_date,dpce.event_date) event_date,isnull(dpce.include_event_date,'n') include_event_date
			,case when dpce.skip_granularity in (990,980) then
				dateadd(day,-1,dbo.FNAGetSkippedDate(isnull(@event_date,dpce.event_date),dpce.skip_granularity,isnull(dpce.skip_days,0)))
			else
				dbo.FNAGetBusinessDayN('n',dpce.event_date,spcd1.holiday_calendar_id,isnull(dpce.skip_days,0)-case when isnull(dpce.include_event_date,'n')='n' then 0 else 1 end) 
			end skip_date
			,dpce.skip_granularity,isnull(dpce.skip_days,0) skip_days
			,isnull(dpce.quotes_after,0) quotes_after,dpce.BOLMO_pricing
		from  deal_price_custom_event dpce
			left join source_price_curve_def spcd1 on spcd1.source_curve_def_id=dpce.pricing_index
		where dpce.deal_price_type_id=dpt.deal_price_type_id
		union all
		select 
			dbo.FNAGetBusinessDayN('p',isnull(@event_date,dpse.event_date),spcd2.holiday_calendar_id,cast(isnull(gmv.clm4_value,0) as int)-case when isnull(gmv.clm6_value,0)=0 then 0 else 1 end) fin_term_start,
			CASE WHEN isnull(dpse.BOLMO_pricing,'n')='y' THEN  sdd.term_end ELSE case when cast(gmv.clm8_value as int) in (990,980) then
				case when isnull(gmv.clm7_value,0)=1 then
					dbo.FNAGetBusinessDayN('n',dbo.FNAGetSkippedDate(isnull(@event_date,dpse.event_date),gmv.clm8_value,isnull(gmv.clm3_value,1)),spcd2.holiday_calendar_id,cast(isnull(gmv.clm5_value,0) as int))
				else 
					dbo.FNAGetBusinessDayN('n',dateadd(day,-1,dbo.FNAGetSkippedDate(isnull(@event_date,dpse.event_date),gmv.clm8_value,isnull(gmv.clm3_value,1))),spcd2.holiday_calendar_id,cast(isnull(gmv.clm5_value,0) as int)+1)
				end 
			else
				case when isnull(gmv.clm7_value,0)=1 then
					dbo.FNAGetBusinessDayN('n',isnull(@event_date,dpse.event_date),spcd2.holiday_calendar_id,cast(isnull(gmv.clm3_value,0) as int) +cast(isnull(gmv.clm5_value,0) as int)-case when isnull(gmv.clm6_value,0)=0 then 0 else 1 end)
				else 
					dbo.FNAGetBusinessDayN('n',isnull(@event_date,dpse.event_date)-1,spcd2.holiday_calendar_id,cast(isnull(gmv.clm3_value,0) as int) +cast(isnull(gmv.clm5_value,0) as int)-case when isnull(gmv.clm6_value,0)=0 then 0 else 1 end+1)
				end 
			end END fin_term_end
			,1 multiplier,dpse.volume,dpse.multiplier price_multiplier,dpse.adder,dpse.uom,null pricing_period
			,case when isnull(gmv.clm7_value,0)=0 then 'n' else 'y' end include_weekends
			,0 expiration_calendar ,dpse.pricing_index,isnull(@event_date,dpse.event_date) event_date
			,case when isnull(gmv.clm6_value,0)=0 then 'n' else 'y' end include_event_date
			,case when cast(gmv.clm8_value as int) in (990,980) then
				dateadd(day,-1,dbo.FNAGetSkippedDate(isnull(@event_date,dpse.event_date),gmv.clm8_value,isnull(gmv.clm3_value,1)) )
			else
				dbo.FNAGetBusinessDayN('n',isnull(@event_date,dpse.event_date),spcd2.holiday_calendar_id,cast(isnull(gmv.clm3_value,0) as int) -case when isnull(gmv.clm6_value,0)=0 then 0 else 1 end)
			end  skip_date
			,cast(gmv.clm8_value as int) skip_granularity,isnull(gmv.clm3_value,1) skip_days
			,cast(isnull(gmv.clm5_value,0) as int) quotes_after,dpse.BOLMO_pricing
		from  deal_price_std_event dpse
			inner join generic_mapping_values gmv on gmv.generic_mapping_values_id=dpse.event_type
			inner join generic_mapping_header gmh on gmh.mapping_table_id=gmv.mapping_table_id
				and gmh.mapping_name='Event Pricing Method'
			left join source_price_curve_def spcd2 on spcd2.source_curve_def_id=dpse.pricing_index
		where dpse.deal_price_type_id=dpt.deal_price_type_id
	) term
	left join source_price_curve_def spcd on spcd.source_curve_def_id=term.pricing_index
	left join time_zones tz on tz.TIMEZONE_ID=isnull(spcd.time_zone,@time_zone_id)	 -- 26 ---  
	outer apply
	(
		select min(exp_date) min_exp_date, max(exp_date) max_exp_date from holiday_group h
		where h.hol_group_value_id=spcd.exp_calendar_id
			and term.fin_term_start>= h.hol_date
			AND term.fin_term_end<=isnull(nullif(h.hol_date_to,'1900-01-01'),h.hol_date)
			and term.expiration_calendar =1
	) exp_max

--select *	
--	from #TempTable tt
--return
insert into @tt (
	pricing_index,term_start,term_end,multiplier,price_multiplier,adder ,volume ,uom
)
select
	a.pricing_index
	,a.term_start
	,a.term_end
	,a.multiplier*
	case when a.hourly_volume_allocation=17601 then -- 17601:	Monthly Average Allocations	Monthly Average Allocations
		(1.0000/(a.no_months*max(a.month_sno) over(partition by pricing_index,a.fin_term_start)))
	else
		(1.0000/(max(sno) over(partition by pricing_index)))
	end  multiplier
	,a.price_multiplier
	,a.adder
	,a.volume
	,a.uom
from (
	select tt.pricing_index
		,tt.fin_term_start
		,tt.fin_term_end
		,tt.multiplier
		,tt.price_multiplier
		,tt.adder
		,tt.volume
		,tt.uom
		,coalesce(h_grp.term_date,d.term_date,tt.fin_term_start) term_start
		,coalesce(h_grp.term_date,d.term_date,tt.fin_term_end) term_end
		,sno=ROW_NUMBER() over(partition by tt.pricing_index  order by isnull(h_grp.term_date,d.term_date))
		,month_sno=ROW_NUMBER() over(partition by tt.pricing_index,tt.fin_term_start  order by isnull(h_grp.term_date,d.term_date))
		,tt.event_date,tt.include_event_date
		,datediff(month,tt.fin_term_min,tt.fin_term_max)+1 no_months
		,tt.hourly_volume_allocation
/*

select tt.exp_calendar_id
				, tt.fin_term_start
				, tt.fin_term_end
				, tt.expiration_calendar
				,* from #TempTable tt
select *	
--*/
	from @TempTable tt
		outer apply
		(
			select exp_date term_date from holiday_group h
			where h.hol_group_value_id=tt.exp_calendar_id
				and tt.fin_term_start>= h.hol_date
				AND tt.fin_term_end<=isnull(nullif(h.hol_date_to,'1900-01-01'),h.hol_date)
				and tt.expiration_calendar =1
			union -- adding weekends and holiday
			select  t.term_date from seq s 
				outer apply
				(
					select tt.min_exp_date+(s.n-1) term_date
				) t	
				left join holiday_group hg on hg.hol_group_value_id=tt.holiday_calendar_id
					and hg.hol_date=t.term_date
			where t.term_date <=tt.max_exp_date
				and tt.expiration_calendar =1 and tt.include_weekends='y' 
				and (
					datepart(dw,t.term_date)=tt.weekend_first_day
					or datepart(dw,t.term_date)=tt.weekend_second_day
					or hg.hol_date is not null
				)
		) h_grp
		outer apply
		(
			select  tt.fin_term_start+(s1.n-1) term_date 
			from seq s1
				left join holiday_group h_day on h_day.hol_group_value_id=tt.holiday_calendar_id
					and h_day.hol_date=tt.fin_term_start+(s1.n-1)
			where
				--tt.fin_term_start+(s1.n-1)<>tt.skip_date and
				 not (
					 tt.fin_term_start+(s1.n-1)>isnull(tt.event_date, tt.fin_term_start) and tt.fin_term_start+(s1.n-1) <=isnull(tt.skip_date,tt.fin_term_start)
				 )
				and tt.expiration_calendar =0 
				and  tt.fin_term_start+(s1.n-1) <=tt.fin_term_end
				and
				((
					--isnull(tt.include_weekends,'y')='n' and
					not (
						datepart(dw,tt.fin_term_start+(s1.n-1))=tt.weekend_first_day
						or datepart(dw,tt.fin_term_start+(s1.n-1))=tt.weekend_second_day
						or h_day.hol_date is not null
					)
				) or tt.include_weekends='y')
		) d
	where ((isnull(tt.BOLMO_pricing,'n')='y' and coalesce(h_grp.term_date,d.term_date,tt.fin_term_start)>=@deal_date) or isnull(tt.BOLMO_pricing,'n')='n')
		and (tt.include_event_date='y' or  ( tt.include_event_date='n'  and coalesce(h_grp.term_date,d.term_date,tt.fin_term_start)<> tt.event_date))
	) a
	--where 
	--	(a.include_event_date='y' or  ( a.include_event_date='n'  and a.term_start<> a.event_date))

	RETURN 

END 