--SET Sequence
DECLARE @ixp_table_id VARCHAR(200)

SELECT @ixp_table_id = ixp_tables_id 
FROM ixp_tables 
WHERE ixp_tables_name = 'ixp_storage_constraints_template'

UPDATE ic 
SET seq = 10 
FROM ixp_columns ic 
WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'logical_name'

UPDATE ic 
SET seq = 20 
FROM ixp_columns ic 
WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'constraint_type'

UPDATE ic 
SET seq = 30 
FROM ixp_columns ic 
WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'value'

UPDATE ic 
SET seq = 40 
FROM ixp_columns ic 
WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'uom'

UPDATE ic 
SET seq = 50 
FROM ixp_columns ic 
WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'effective_date'

UPDATE ic 
SET seq = 60 
FROM ixp_columns ic 
WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'frequency'
	 
-- SET Required  

UPDATE ixp_columns 
SET is_required = 1 
WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name IN ('logical_name','constraint_type','value','uom','effective_date')

--SET  Unique

UPDATE ixp_columns 
SET is_major = 1 
WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'logical_name'

--SET datatype

UPDATE ixp_columns 
SET datatype = '[datetime]' 
WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'effective_date'
