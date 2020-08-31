
if not exists(select 1 from sys.indexes where [name]='indx_source_price_curve_def_udf_block_group_id')
create index indx_source_price_curve_def_udf_block_group_id on dbo.source_price_curve_def (udf_block_group_id)