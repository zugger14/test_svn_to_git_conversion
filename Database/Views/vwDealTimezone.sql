IF OBJECT_ID('dbo.vwDealTimezone') is not null
DROP VIEW dbo.vwDealTimezone
go

SET QUOTED_IDENTIFIER ON
GO
CREATE view [dbo].[vwDealTimezone]  WITH schemabinding
as
select sdh.source_deal_header_id,isnull(sdd.curve_id,-1) curve_id,isnull(sdd.formula_curve_id,-1) formula_curve_id,isnull(sdd.location_id,-1) location_id ,max(tz.dst_group_value_id) dst_group_value_id
from dbo.source_deal_header sdh	
cross apply (
select  isnull(curve_id,-1) curve_id,-1 formula_curve_id,isnull(location_id,-1) location_id from dbo.source_deal_detail 
	where source_deal_header_id=sdh.source_deal_header_id --and formula_curve_id is null 
union 
select  -1 curve_id,formula_curve_id,isnull(location_id,-1) location_id from dbo.source_deal_detail
	where source_deal_header_id=sdh.source_deal_header_id and formula_curve_id is not null 
 union 
  select  -1 curve_id,curve_id formula_curve_id,-1 location_id from dbo.deal_position_break_down where source_deal_header_id=sdh.source_deal_header_id

) sdd
left join dbo.source_minor_location sml (nolock) on sml.source_minor_location_id=sdd.location_id
left join dbo.source_price_curve_def spcd (nolock) on spcd.source_curve_def_id=sdd.curve_id
cross join 
(
	select var_value default_timezone_id from dbo.adiha_default_codes_values (nolock) WHERE instance_no = 1 AND default_code_id = 36 AND seq_no = 1
) df  
inner join dbo.time_zones tz (nolock) on tz.timezone_id = coalesce(sdh.timezone_id,sml.time_zone,spcd.time_zone,df.default_timezone_id)
group by sdh.source_deal_header_id,sdd.curve_id,sdd.location_id,sdd.formula_curve_id

