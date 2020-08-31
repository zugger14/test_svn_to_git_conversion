if object_id('vwDealTimezoneContract') is not null
drop view dbo.vwDealTimezoneContract
go

create view [dbo].[vwDealTimezoneContract]  WITH schemabinding
as
	select COUNT_BIG(*) cnt,sdh.source_deal_header_id,isnull(sdd.curve_id,-1) curve_id,isnull(sdd.location_id,-1) location_id 
	--,isnull(cg.contract_id,-1) contract_id 
	,max(tz.dst_group_value_id) dst_group_value_id
	from dbo.source_deal_header sdh	
	cross apply
	( 
		select distinct location_id,curve_id from dbo.source_deal_detail where source_deal_header_id=sdh.source_deal_header_id
	 union all
		select distinct null location_id,curve_id from dbo.deal_position_break_down where source_deal_header_id=sdh.source_deal_header_id
	) sdd 	
	left join dbo.source_minor_location sml (nolock) on sml.source_minor_location_id=sdd.location_id
	left join dbo.source_price_curve_def spcd (nolock) on spcd.source_curve_def_id=sdd.curve_id
	left join dbo.contract_group cg (nolock) on cg.contract_id=sdh.contract_id
	cross join 
	(
		select var_value default_timezone_id from dbo.adiha_default_codes_values (nolock) WHERE instance_no = 1 AND default_code_id = 36 AND seq_no = 1
	) df  
	inner join dbo.time_zones tz (nolock) on tz.timezone_id = coalesce(cg.time_zone,sdh.timezone_id,sml.time_zone,spcd.time_zone,df.default_timezone_id)
	group by sdh.source_deal_header_id,sdd.curve_id,sdd.location_id
--,cg.contract_id



GO


