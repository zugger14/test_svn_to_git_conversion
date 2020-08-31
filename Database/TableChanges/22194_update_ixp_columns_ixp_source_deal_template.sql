
UPDATE ic
SET  is_required = 0  
FROM ixp_tables it
INNER JOIN ixp_columns ic ON ic.ixp_table_id = it.ixp_tables_id
WHERE ixp_tables_name = 'ixp_source_deal_template' 
	AND ixp_columns_name in ('curve_id','deal_volume_frequency','deal_volume_uom_id') 