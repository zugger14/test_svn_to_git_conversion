IF NOT EXISTS (SELECT 1 FROM ixp_tables WHERE ixp_tables_name = 'ixp_storage_ratchet')
BEGIN
    INSERT INTO ixp_tables (ixp_tables_name, ixp_tables_description, import_export_flag)
    VALUES ('ixp_storage_ratchet', 'Storage Ratchet', 'i')
END

DECLARE @ixp_tables_id INT
SELECT @ixp_tables_id = ixp_tables_id
FROM ixp_tables
WHERE ixp_tables_name = 'ixp_storage_ratchet'
 
IF NOT EXISTS (SELECT 1 FROM ixp_columns WHERE ixp_table_id = @ixp_tables_id AND ixp_columns_name = 'general_assest_id')
BEGIN
    INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major)
    VALUES (@ixp_tables_id, 'general_assest_id', 'VARCHAR(600)', 0)
END

IF NOT EXISTS (SELECT 1 FROM ixp_columns WHERE ixp_table_id = @ixp_tables_id AND ixp_columns_name = 'term_from')
BEGIN
    INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major)
    VALUES (@ixp_tables_id, 'term_from', 'VARCHAR(600)', 0)
END

IF NOT EXISTS (SELECT 1 FROM ixp_columns WHERE ixp_table_id = @ixp_tables_id AND ixp_columns_name = 'term_to')
BEGIN
    INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major)
    VALUES (@ixp_tables_id, 'term_to', 'VARCHAR(600)', 0)
END

IF NOT EXISTS (SELECT 1 FROM ixp_columns WHERE ixp_table_id = @ixp_tables_id AND ixp_columns_name = 'inventory_level_from')
BEGIN
    INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major)
    VALUES (@ixp_tables_id, 'inventory_level_from', 'VARCHAR(600)', 0)
END

IF NOT EXISTS (SELECT 1 FROM ixp_columns WHERE ixp_table_id = @ixp_tables_id AND ixp_columns_name = 'inventory_level_to')
BEGIN
    INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major)
    VALUES (@ixp_tables_id, 'inventory_level_to', 'VARCHAR(600)', 0)
END

IF NOT EXISTS (SELECT 1 FROM ixp_columns WHERE ixp_table_id = @ixp_tables_id AND ixp_columns_name = 'gas_in_storage_perc_from')
BEGIN
    INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major)
    VALUES (@ixp_tables_id, 'gas_in_storage_perc_from', 'VARCHAR(600)', 0)
END

IF NOT EXISTS (SELECT 1 FROM ixp_columns WHERE ixp_table_id = @ixp_tables_id AND ixp_columns_name = 'gas_in_storage_perc_to')
BEGIN
    INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major)
    VALUES (@ixp_tables_id, 'gas_in_storage_perc_to', 'VARCHAR(600)', 0)
END

IF NOT EXISTS (SELECT 1 FROM ixp_columns WHERE ixp_table_id = @ixp_tables_id AND ixp_columns_name = 'type')
BEGIN
    INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major)
    VALUES (@ixp_tables_id, 'type', 'VARCHAR(600)', 0)
END

IF NOT EXISTS (SELECT 1 FROM ixp_columns WHERE ixp_table_id = @ixp_tables_id AND ixp_columns_name = 'perc_of_contracted_storage_space')
BEGIN
    INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major)
    VALUES (@ixp_tables_id, 'perc_of_contracted_storage_space', 'VARCHAR(600)', 0)
END

IF NOT EXISTS (SELECT 1 FROM ixp_columns WHERE ixp_table_id = @ixp_tables_id AND ixp_columns_name = 'fixed_value')
BEGIN
    INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major)
    VALUES (@ixp_tables_id, 'fixed_value', 'VARCHAR(600)', 0)
END
