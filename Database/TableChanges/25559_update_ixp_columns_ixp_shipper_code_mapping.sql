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
	AND ixp_columns_name in ('effective_date', 'external_id')
	
UPDATE ic SET seq = 10
FROM ixp_columns ic
WHERE ixp_table_id = @ixp_table_id 
	AND ixp_columns_name = 'counterparty'

UPDATE ic SET seq = 20
FROM ixp_columns ic
WHERE ixp_table_id = @ixp_table_id 
	AND ixp_columns_name = 'location'

UPDATE ic SET seq = 30
FROM ixp_columns ic
WHERE ixp_table_id = @ixp_table_id 
	AND ixp_columns_name = 'effective_date'
