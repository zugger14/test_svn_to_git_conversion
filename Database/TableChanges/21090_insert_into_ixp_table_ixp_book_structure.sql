DECLARE @ixp_table_id INT

IF NOT EXISTS(SELECT 1 FROM ixp_tables WHERE ixp_tables_name = 'ixp_book_structure')
BEGIN
	INSERT INTO ixp_tables (ixp_tables_name, ixp_tables_description, import_export_flag)
	VALUES ('ixp_book_structure', 'Book Structure Import', 'i')
END

SELECT @ixp_table_id = ixp_tables_id
FROM ixp_tables
WHERE ixp_tables_name = 'ixp_book_structure'

IF NOT EXISTS(SELECT 1 FROM ixp_columns WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'Subsidiary')
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major)
	VALUES (@ixp_table_id, 'Subsidiary', 'VARCHAR(600)', 0)
END

IF NOT EXISTS(SELECT 1 FROM ixp_columns WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'Strategy')
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major)
	VALUES (@ixp_table_id, 'Strategy', 'VARCHAR(600)', 0)
END

IF NOT EXISTS(SELECT 1 FROM ixp_columns WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'Book')
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major)
	VALUES (@ixp_table_id, 'Book', 'VARCHAR(600)', 0)
END

IF NOT EXISTS(SELECT 1 FROM ixp_columns WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'Sub Book')
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major)
	VALUES (@ixp_table_id, 'Sub Book', 'VARCHAR(600)', 0)
END

IF NOT EXISTS(SELECT 1 FROM ixp_columns WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'Currency')
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major)
	VALUES (@ixp_table_id, 'Currency', 'VARCHAR(600)', 0)
END