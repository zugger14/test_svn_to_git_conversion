IF NOT EXISTS (SELECT 1 FROM ixp_tables WHERE ixp_tables_name ='ixp_energy_conversion_data_import_template')
BEGIN
	INSERT INTO ixp_tables (ixp_tables_name, ixp_tables_description, import_export_flag)
	VALUES ('ixp_energy_conversion_data_import_template', 'Energy Conversion Data', 'i')
END
ELSE
    BEGIN
        PRINT '"Energy Conversion Data" already Exists'
    END

--insert into ixp_columns
DECLARE @ixp_tables_id INT
SELECT @ixp_tables_id = ixp_tables_id
FROM ixp_tables
WHERE ixp_tables_name = 'ixp_energy_conversion_data_import_template'

IF NOT EXISTS (SELECT 1 FROM ixp_columns WHERE ixp_table_id = @ixp_tables_id AND ixp_columns_name = 'conversion_name')
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major,seq,is_required)
	VALUES (@ixp_tables_id, 'conversion_name', 'NVARCHAR(600)', 1, 10, 1)
END

IF NOT EXISTS (SELECT 1 FROM ixp_columns WHERE ixp_table_id = @ixp_tables_id AND ixp_columns_name = 'from_uom')
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major,seq,is_required)
	VALUES (@ixp_tables_id, 'from_uom', 'NVARCHAR(600)', 1, 20, 1)
END

IF NOT EXISTS (SELECT 1 FROM ixp_columns WHERE ixp_table_id = @ixp_tables_id AND ixp_columns_name = 'to_uom')
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major,seq,is_required)
	VALUES (@ixp_tables_id, 'to_uom', 'NVARCHAR(600)', 1, 30, 1)
END

IF NOT EXISTS (SELECT 1 FROM ixp_columns WHERE ixp_table_id = @ixp_tables_id AND ixp_columns_name = 'effective_date')
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major,seq,is_required)
	VALUES (@ixp_tables_id, 'effective_date', 'NVARCHAR(600)', 1, 40, 1)
END

IF NOT EXISTS (SELECT 1 FROM ixp_columns WHERE ixp_table_id = @ixp_tables_id AND ixp_columns_name = 'factor')
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major,seq,is_required)
	VALUES (@ixp_tables_id, 'factor', 'NVARCHAR(600)', 0, 50, 1)
END

IF NOT EXISTS (SELECT 1 FROM ixp_columns WHERE ixp_table_id = @ixp_tables_id AND ixp_columns_name = 'actual')
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major,seq,is_required)
	VALUES (@ixp_tables_id, 'actual', 'NVARCHAR(600)', 0, 60, 1)
END