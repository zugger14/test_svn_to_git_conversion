if not exists(select 1 from sys.indexes where [name]='IX_PT_report_hourly_position_deal_deal_date_main')
create index IX_PT_report_hourly_position_deal_deal_date_main on dbo.report_hourly_position_deal_main (deal_date)
if not exists(select 1 from sys.indexes where [name]='indx_report_hourly_position_breakdown_main_deal_date')
create index indx_report_hourly_position_breakdown_main_deal_date on report_hourly_position_breakdown_main (deal_date)
if not exists(select 1 from sys.indexes where [name]='indx_report_hourly_position_profile_main_deal_date')
create index indx_report_hourly_position_profile_main_deal_date on report_hourly_position_profile_main (deal_date)




if not exists(select 1 from sys.indexes where [name]='IX_PT_report_hourly_position_deal_term_start_expiration_date_main')
create index IX_PT_report_hourly_position_deal_term_start_expiration_date_main on dbo.report_hourly_position_deal_main (expiration_date)
if not exists(select 1 from sys.indexes where [name]='IX_PT_report_hourly_position_profile_term_start_expiration_date_main')
create index IX_PT_report_hourly_position_profile_term_start_expiration_date_main on dbo.report_hourly_position_profile_main (expiration_date)
if not exists(select 1 from sys.indexes where [name]='IX_PT_report_hourly_position_breakdown_term_start_expiration_date_main')
create index IX_PT_report_hourly_position_breakdown_term_start_expiration_date_main on dbo.report_hourly_position_breakdown_main (expiration_date)

if not exists(select 1 from sys.indexes where [name]='indx_report_hourly_position_deal_main_deal_detail_id')
create index indx_report_hourly_position_deal_main_deal_detail_id on report_hourly_position_deal_main (source_deal_detail_id)
if not exists(select 1 from sys.indexes where [name]='indx_report_hourly_position_profile_main_deal_detail_id')
create index indx_report_hourly_position_profile_main_deal_detail_id on report_hourly_position_profile_main (source_deal_detail_id)
if not exists(select 1 from sys.indexes where [name]='indx_report_hourly_position_breakdown_main_deal_detail_id')
create index indx_report_hourly_position_breakdown_main_deal_detail_id on report_hourly_position_breakdown_main (source_deal_detail_id)


--if not exists(select 1 from sys.indexes where [name]='indx_report_hourly_position_profile_main_deal_id')
--create index indx_report_hourly_position_profile_main_deal_id on report_hourly_position_profile_main (source_deal_header_id)



--if not exists(select 1 from sys.indexes where [name]='unique_indx_report_hourly_position_breakdown_main')
--create index unique_indx_report_hourly_position_breakdown_main on report_hourly_position_breakdown_main(source_deal_header_id)

--if not exists(select 1 from sys.indexes where [name]='indx_delta_report_hourly_position_id_main')
--create index indx_delta_report_hourly_position_id_main on delta_report_hourly_position_main(source_deal_header_id)

--if not exists(select 1 from sys.indexes where [name]='indx_delta_report_hourly_position_financial_main')
--create index indx_delta_report_hourly_position_financial_main on delta_report_hourly_position_financial_main(source_deal_header_id)

--if not exists(select 1 from sys.indexes where [name]='indx_delta_report_hourly_position_breakdown_main')
--create index indx_delta_report_hourly_position_breakdown_main on delta_report_hourly_position_breakdown_main ( source_deal_header_id)


if  COL_LENGTH('process_deal_position_breakdown', 'source_deal_detail_id') IS NULL
	alter table dbo.process_deal_position_breakdown  add source_deal_detail_id int



-- Unused indexes
if  exists(select 1 from sys.indexes where [name]='indx_delta_report_hourly_position_breakdown')
drop index indx_delta_report_hourly_position_breakdown on report_hourly_position_breakdown

if  exists(select 1 from sys.indexes where [name]='indx_report_hourly_position_breakdown_commodity_id')
drop index indx_report_hourly_position_breakdown_commodity_id on report_hourly_position_breakdown

if  exists(select 1 from sys.indexes where [name]='indx_report_hourly_position_breakdown_counterparty_id')
drop index indx_report_hourly_position_breakdown_counterparty_id on report_hourly_position_breakdown

if  exists(select 1 from sys.indexes where [name]='indx_report_hourly_position_breakdown_deal_date')
drop index indx_report_hourly_position_breakdown_deal_date on report_hourly_position_breakdown

if  exists(select 1 from sys.indexes where [name]='indx_report_hourly_position_breakdown_fas_book_id')
drop index indx_report_hourly_position_breakdown_fas_book_id on report_hourly_position_breakdown

if  exists(select 1 from sys.indexes where [name]='indx_report_hourly_position_breakdown_source_system_book_id')
drop index indx_report_hourly_position_breakdown_source_system_book_id on report_hourly_position_breakdown

if  exists(select 1 from sys.indexes where [name]='indx_report_hourly_position_breakdown_volume_uom_id')
drop index indx_report_hourly_position_breakdown_volume_uom_id on report_hourly_position_breakdown

if  exists(select 1 from sys.indexes where [name]='IX_PT_report_hourly_position_deal_term_start_expiration_date')
drop index IX_PT_report_hourly_position_deal_term_start_expiration_date on report_hourly_position_deal


    






--drop index cuindx_report_hourly_position_breakdown on report_hourly_position_breakdown
--drop index cuindx_delta_report_hourly_position on delta_report_hourly_position 
--drop  index cuindx_delta_report_hourly_position_financial on delta_report_hourly_position_financial 
--drop index cuindx_delta_report_hourly_position_breakdown on delta_report_hourly_position_breakdown 