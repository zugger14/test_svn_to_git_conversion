DECLARE @ixp_tables_id INT
SELECT @ixp_tables_id = ixp_tables_id
FROM ixp_tables																				
WHERE ixp_tables_name = 'ixp_compliance_jurisdiction'

IF NOT EXISTS (SELECT 1 FROM ixp_columns WHERE ixp_table_id = @ixp_tables_id AND ixp_columns_name = 'current_next_year')
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major, seq, is_required)
	VALUES (@ixp_tables_id, 'current_next_year', 'NVARCHAR(600)', 0, 80, 1)
END
