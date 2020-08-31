DECLARE @ixp_tables_id INT

SELECT @ixp_tables_id = ixp_tables_id
FROM ixp_tables																				
WHERE ixp_tables_name = 'ixp_source_price_curve_def_template'

IF NOT EXISTS (SELECT 1 FROM ixp_columns WHERE ixp_table_id = @ixp_tables_id AND ixp_columns_name = 'location_id')
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major, seq, is_required)
	VALUES (@ixp_tables_id, 'location_id', 'NVARCHAR(600)', 1, 115, 0)
END
