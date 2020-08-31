DECLARE @deal_ids VARCHAR(MAX)	   --Deal ids for position calculation..

select @deal_ids=isnull(@deal_ids+',','')+cast(source_deal_header_id as varchar)
from
(
	select distinct p.source_deal_header_id from report_hourly_position_deal p inner join source_price_curve_def c on p.curve_id=c.source_curve_def_id
	where p.commodity_id<>c.commodity_id
	union all
	select distinct p.source_deal_header_id from report_hourly_position_profile p inner join source_price_curve_def c on p.curve_id=c.source_curve_def_id
	where p.commodity_id<>c.commodity_id
) deals

Print '-----Recalc position for these deals:'
print @deal_ids
Print '=============================================================================='

EXEC spa_calc_deal_position_breakdown @deal_ids