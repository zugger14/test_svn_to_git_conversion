DECLARE @ixp_tables_id INT, @ixp_columns_id INT
SELECT @ixp_tables_id = ixp_tables_id
FROM ixp_tables 
WHERE ixp_tables_name = 'ixp_source_counterparty_template'

UPDATE ic
	SET is_major = 1
FROM ixp_columns ic
WHERE ixp_table_id = @ixp_tables_id
AND ixp_columns_name = 'counterparty_id'


UPDATE ic
	SET is_major = 0
FROM ixp_columns ic
WHERE ixp_table_id = @ixp_tables_id
AND ixp_columns_name = 'counterparty_name'



