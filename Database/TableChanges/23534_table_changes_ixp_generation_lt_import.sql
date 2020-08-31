IF NOT EXISTS (SELECT 1 FROM ixp_tables WHERE ixp_tables_name ='ixp_generation_lt_import')
BEGIN
	INSERT INTO ixp_tables (ixp_tables_name, ixp_tables_description, import_export_flag)
	VALUES ('ixp_generation_lt_import', 'Generation LT Import', 'i')
END
ELSE
    BEGIN
        PRINT 'Generation LT Import already Exists'
    END

--insert into ixp_columns
DECLARE @ixp_tables_id INT
SELECT @ixp_tables_id = ixp_tables_id
FROM ixp_tables
WHERE ixp_tables_name = 'ixp_generation_lt_import'

IF NOT EXISTS (SELECT 1 FROM ixp_columns WHERE ixp_table_id = @ixp_tables_id AND ixp_columns_name = 'upload_date')
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major,seq,is_required)
	VALUES (@ixp_tables_id, 'upload_date', 'NVARCHAR(600)', 1, 10, 1)
END

IF NOT EXISTS (SELECT 1 FROM ixp_columns WHERE ixp_table_id = @ixp_tables_id AND ixp_columns_name = 'deal_id')
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major,seq,is_required)
	VALUES (@ixp_tables_id, 'deal_id', 'NVARCHAR(600)', 1, 20, 1)
END

IF NOT EXISTS (SELECT 1 FROM ixp_columns WHERE ixp_table_id = @ixp_tables_id AND ixp_columns_name = 'term_start')
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major,seq,is_required)
	VALUES (@ixp_tables_id, 'term_start', 'NVARCHAR(600)', 1, 30, 1)
END

IF NOT EXISTS (SELECT 1 FROM ixp_columns WHERE ixp_table_id = @ixp_tables_id AND ixp_columns_name = 'term_end')
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major,seq,is_required)
	VALUES (@ixp_tables_id, 'term_end', 'NVARCHAR(600)', 1, 40, 1)
END

IF NOT EXISTS (SELECT 1 FROM ixp_columns WHERE ixp_table_id = @ixp_tables_id AND ixp_columns_name = 'volume')
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major,seq,is_required)
	VALUES (@ixp_tables_id, 'volume', 'NVARCHAR(600)', 0, 50, 1)
END

IF NOT EXISTS (SELECT 1 FROM ixp_columns WHERE ixp_table_id = @ixp_tables_id AND ixp_columns_name = 'price')
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major,seq,is_required)
	VALUES (@ixp_tables_id, 'price', 'NVARCHAR(600)', 0, 60, 0)
END

IF NOT EXISTS (SELECT 1 FROM ixp_columns WHERE ixp_table_id = @ixp_tables_id AND ixp_columns_name = 'mapping_name')
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major,seq,is_required)
	VALUES (@ixp_tables_id, 'mapping_name', 'NVARCHAR(600)', 0, 70, 0)
END

IF NOT EXISTS (SELECT 1 FROM ixp_columns WHERE ixp_table_id = @ixp_tables_id AND ixp_columns_name = 'product')
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major,seq,is_required)
	VALUES (@ixp_tables_id, 'product', 'NVARCHAR(600)', 0, 80, 0)
END

IF NOT EXISTS (SELECT 1 FROM ixp_columns WHERE ixp_table_id = @ixp_tables_id AND ixp_columns_name = 'index')
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major,seq,is_required)
	VALUES (@ixp_tables_id, 'index', 'NVARCHAR(600)', 0, 90, 0)
END

