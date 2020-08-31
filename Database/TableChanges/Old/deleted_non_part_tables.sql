IF exists (select 1 from sys.objects o where o.name ='cached_curves_value_non_part' and o.type ='u')
DROP TABLE cached_curves_value_non_part
IF exists (select 1 from sys.objects o where o.name ='calc_formula_value_non_part' and o.type ='u')
DROP TABLE calc_formula_value_non_part
IF exists (select 1 from sys.objects o where o.name ='deal_detail_hour_non_part' and o.type ='u')
DROP TABLE deal_detail_hour_non_part
IF exists (select 1 from sys.objects o where o.name ='delta_report_hourly_position_breakdown_non_part' and o.type ='u')
DROP TABLE delta_report_hourly_position_breakdown_non_part
IF exists (select 1 from sys.objects o where o.name ='delta_report_hourly_position_non_part' and o.type ='u')
DROP TABLE delta_report_hourly_position_non_part
IF exists (select 1 from sys.objects o where o.name ='fx_exposure_non_part' and o.type ='u')
DROP TABLE fx_exposure_non_part
IF exists (select 1 from sys.objects o where o.name ='index_fees_breakdown_non_part' and o.type ='u')
DROP TABLE index_fees_breakdown_non_part
IF exists (select 1 from sys.objects o where o.name ='index_fees_breakdown_settlement_non_part' and o.type ='u')
DROP TABLE index_fees_breakdown_settlement_non_part
IF exists (select 1 from sys.objects o where o.name ='mv90_data_hour_non_part' and o.type ='u')
DROP TABLE mv90_data_hour_non_part
IF exists (select 1 from sys.objects o where o.name ='mv90_data_mins_non_part' and o.type ='u')
DROP TABLE mv90_data_mins_non_part
IF exists (select 1 from sys.objects o where o.name ='mv90_data_non_part' and o.type ='u')
DROP TABLE mv90_data_non_part
IF exists (select 1 from sys.objects o where o.name ='report_hourly_position_breakdown_non_part' and o.type ='u')
DROP TABLE report_hourly_position_breakdown_non_part
IF exists (select 1 from sys.objects o where o.name ='report_hourly_position_deal_non_part' and o.type ='u')
DROP TABLE report_hourly_position_deal_non_part
IF exists (select 1 from sys.objects o where o.name ='report_hourly_position_fixed_non_part' and o.type ='u')
DROP TABLE report_hourly_position_fixed_non_part
IF exists (select 1 from sys.objects o where o.name ='report_hourly_position_profile_non_part' and o.type ='u')
DROP TABLE report_hourly_position_profile_non_part
IF exists (select 1 from sys.objects o where o.name ='source_deal_pnl_detail_non_part' and o.type ='u')
DROP TABLE source_deal_pnl_detail_non_part
IF exists (select 1 from sys.objects o where o.name ='source_deal_pnl_non_part' and o.type ='u')
DROP TABLE source_deal_pnl_non_part
IF exists (select 1 from sys.objects o where o.name ='source_deal_settlement_non_part' and o.type ='u')
DROP TABLE source_deal_settlement_non_part
IF exists (select 1 from sys.objects o where o.name ='deal_detail_hour_non_part_org' and o.type ='u')
DROP TABLE deal_detail_hour_non_part_org
IF exists (select 1 from sys.objects o where o.name ='deal_position_break_down_non_part_org' and o.type ='u')
DROP TABLE deal_position_break_down_non_part_org
IF exists (select 1 from sys.objects o where o.name ='delta_report_hourly_position_non_part_org' and o.type ='u')
DROP TABLE delta_report_hourly_position_non_part_org
IF exists (select 1 from sys.objects o where o.name ='delta_report_hourly_position_profile_non_part_org' and o.type ='u')
DROP TABLE delta_report_hourly_position_profile_non_part_org
IF exists (select 1 from sys.objects o where o.name ='report_hourly_position_breakdown_non_part_org' and o.type ='u')
DROP TABLE report_hourly_position_breakdown_non_part_org
IF exists (select 1 from sys.objects o where o.name ='report_hourly_position_deal_non_part_org' and o.type ='u')
DROP TABLE report_hourly_position_deal_non_part_org
IF exists (select 1 from sys.objects o where o.name ='report_hourly_position_fixed_non_part_org' and o.type ='u')
DROP TABLE report_hourly_position_fixed_non_part_org
IF exists (select 1 from sys.objects o where o.name ='report_hourly_position_profile_non_part_org' and o.type ='u')
DROP TABLE report_hourly_position_profile_non_part_org