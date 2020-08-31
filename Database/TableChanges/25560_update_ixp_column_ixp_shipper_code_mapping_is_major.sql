DECLARE @ixp_table_id INT
SELECT @ixp_table_id = ISNULL(ixp_tables_id, IDENT_CURRENT('ixp_tables')) 
FROM ixp_tables 
WHERE ixp_tables_name = 'ixp_shipper_code_mapping'

UPDATE ic SET is_major = 0 
FROM ixp_columns ic
WHERE ixp_table_id = @ixp_table_id

UPDATE ic SET is_major = 1 
FROM ixp_columns ic
WHERE ixp_table_id = @ixp_table_id
	AND ixp_columns_name in ('location', 'effective_date', 'shipper_code1', 'shipper_code')
