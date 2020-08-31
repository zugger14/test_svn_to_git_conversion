
IF NOT EXISTS(SELECT 1 FROM sys.columns WHERE [name]='term_end' AND [object_id]=object_id('report_hourly_position_breakdown'))
begin

	ALTER TABLE report_hourly_position_breakdown ADD term_end datetime 
	ALTER TABLE deal_detail_hour DROP COLUMN location_id

	alter table source_minor_location add profile_id int,proxy_profile_id int
	create index indx_source_minor_location_profile_id on source_minor_location (profile_id)
	create index indx_source_minor_location_proxy_profile_id on source_minor_location (proxy_profile_id)

	create index indx_source_minor_location_proxy_profile_id on source_minor_location (proxy_profile_id)
	drop index indx_deal_detail_hour_location_id	on deal_detail_hour
	create index   indx_deal_detail_hour_profile_id   on deal_detail_hour (profile_id, term_start, term_date)
END