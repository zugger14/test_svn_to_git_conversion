--update ixp table name for Deal Cost Import logic
if exists(select top 1 1 from ixp_tables t inner join ixp_columns c on c.ixp_table_id = t.ixp_tables_id where ixp_tables_name = 'ixp_deal_udf_import' and c.ixp_columns_name = 'currency')
begin
	update t set ixp_tables_name = 'ixp_deal_fees', ixp_tables_description = 'Deal Fees'
	from ixp_tables t 
	inner join ixp_columns c on c.ixp_table_id = t.ixp_tables_id 
	where ixp_tables_name = 'ixp_deal_udf_import' and c.ixp_columns_name = 'currency'
end

