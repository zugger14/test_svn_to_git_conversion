DECLARE @ixp_table_id INT
SELECT @ixp_table_id = ixp_tables_id FROM ixp_tables where ixp_tables_name = 'ixp_tier_mapping'



IF NOT EXISTS (SELECT 1 FROM ixp_columns WHERE ixp_table_id = @ixp_table_id and ixp_columns_name = 'effective_date')
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major,header_detail, seq, datatype)
	SELECT @ixp_table_id, 'effective_date', 'VARCHAR(600)', 1 ,NULL, 41, '[datetime]'
END

UPDATE ixp_columns 
SET is_required = 0
WHERE ixp_columns_name = 'banking_years'
AND ixp_table_id = @ixp_table_id

UPDATE ixp_columns 
SET is_major = 1
WHERE ixp_columns_name = 'price_index'
AND ixp_table_id = @ixp_table_id