/*


select * from report_measurement_values where as_of_date = '2017-09-30'
select * from report_measurement_values_arch1 where as_of_date = '2017-09-30'
select * from report_measurement_values_arch2 where as_of_date = '2017-09-30'

select * from calcprocess_aoci_release where as_of_date = '2017-09-30'
select * from calcprocess_aoci_release_arch1 where as_of_date = '2017-09-30'
select * from calcprocess_aoci_release_arch2 where as_of_date = '2017-09-30'

select * from calcprocess_deals where as_of_date = '2017-09-30'
select * from calcprocess_deals_arch1 where as_of_date = '2017-09-30'
select * from calcprocess_deals_arch2 where as_of_date = '2017-09-30'

--select * from report_netted_gl_entry where as_of_date = '2017-09-30'
--select * from report_netted_gl_entry_arch1 where as_of_date = '2017-09-30'
--select * from report_netted_gl_entry_arch2 where as_of_date = '2017-09-30'

--select * from source_deal_pnl where pnl_as_of_date = '2017-09-30'
--select * from source_deal_pnl_arch1 where pnl_as_of_date = '2017-09-30'
--select * from source_deal_pnl_arch2 where pnl_as_of_date = '2017-09-30'


delete calcprocess_aoci_release_arch1 where as_of_date = '2017-09-30'
delete calcprocess_aoci_release_arch2 where as_of_date = '2017-09-30'

delete calcprocess_deals_arch1 where as_of_date = '2017-09-30'
delete calcprocess_deals_arch2 where as_of_date = '2017-09-30'


delete report_measurement_values_arch1 where as_of_date = '2017-09-30'
delete report_measurement_values_arch2 where as_of_date = '2017-09-30'

--delete report_netted_gl_entry_arch1 where as_of_date = '2017-09-30'
--delete report_netted_gl_entry_arch2 where as_of_date = '2017-09-30'

--delete source_deal_pnl_arch1 where pnl_as_of_date = '2017-09-30'
--delete source_deal_pnl_arch2 where pnl_as_of_date = '2017-09-30'

update  process_table_location set prefix_location_table=null

delete close_measurement_books where as_of_date='2017-09-01 00:00:00.000'


select *  from close_measurement_books
select *  from process_table_archive_policy

select * from process_table_location
select * from static_data_value where type_id=2150
*/



update  process_table_archive_policy set archieve_type_id=2150 where tbl_name in (
'calcprocess_aoci_release',
'calcprocess_deals',
'report_measurement_values',
'report_netted_gl_entry',
'source_deal_pnl'
)

update  process_table_archive_policy set archieve_type_id=2152 where tbl_name in (
'source_price_curve'
)

update  process_table_archive_policy set archieve_type_id=2157 where tbl_name in (
'deal_detail_hour'
)

update  process_table_archive_policy set archieve_type_id=2151 where tbl_name in (
'ems_calc_detail_value'
)

--select * from process_table_archive_policy
update  process_table_archive_policy set fieldlist='*' where fieldlist is null


