UPDATE ic 
SET is_major = 1
FROM ixp_columns ic
INNER JOIN ixp_tables it
	ON ic.ixp_table_id = it.ixp_tables_id
WHERE it.ixp_tables_name = 'ixp_shipper_code_deal_detail'
	AND ic.ixp_columns_name = 'leg'
