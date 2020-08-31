
IF NOT EXISTS(SELECT 'X' FROM information_schema.columns where table_name = 'source_option_greeks_detail' and column_name='is_dst')
alter table dbo.source_option_greeks_detail ADD is_dst INT

go

if exists(select 1 from sys.indexes where [name]='indx_clustered_source_option_greeks_detail')
	drop index indx_clustered_source_option_greeks_detail on dbo.source_option_greeks_detail

if exists(select 1 from sys.indexes where [name]='indx_uniq_clustered_source_option_greeks_detail')
	drop index indx_uniq_clustered_source_option_greeks_detail on dbo.source_option_greeks_detail

create unique CLUSTERED INDEX  indx_uniq_clustered_source_option_greeks_detail	ON dbo.source_option_greeks_detail
(as_of_date, source_deal_header_id, term_start, hr,is_dst, period, pnl_source_value_id)