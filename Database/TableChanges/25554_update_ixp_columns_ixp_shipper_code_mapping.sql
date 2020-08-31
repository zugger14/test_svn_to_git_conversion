UPDATE ic SET is_required = 1 
FROM ixp_columns ic
INNER JOIN ixp_tables it
	ON ic.ixp_table_id = it.ixp_tables_id
WHERE it.ixp_tables_name = 'ixp_shipper_code_mapping'
	AND ixp_columns_name IN ('shipper_code', 'is_default', 'is_active', 'external_id')
