

if not exists(select 1 from sys.indexes where [name]='indx_deal_header_id')
begin
	create index indx_deal_header_id on  [dbo].[report_hourly_position_profile] (source_deal_header_id)
	create index indx_term on  [dbo].[report_hourly_position_profile] (term_start,expiration_date)
end