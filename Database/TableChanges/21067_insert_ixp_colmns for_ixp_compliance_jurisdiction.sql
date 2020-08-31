DECLARE @ixp_tables_id INT

SELECT @ixp_tables_id = ixp_tables_id
FROM ixp_tables
WHERE ixp_tables_name = 'ixp_compliance_jurisdiction'

IF NOT EXISTS (SELECT 1 FROM ixp_columns WHERE ixp_table_id = @ixp_tables_id AND ixp_columns_name = 'program_scope')
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major)
	VALUES (@ixp_tables_id, 'program_scope', 'VARCHAR(100)', 0)
END
