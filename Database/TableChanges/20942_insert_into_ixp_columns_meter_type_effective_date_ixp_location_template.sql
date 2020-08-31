DECLARE @ixp_table_id INT
SELECT @ixp_table_id = ixp_tables_id FROM ixp_tables WHERE ixp_tables_name = 'ixp_location_template'

IF NOT EXISTS (SELECT 1 FROM ixp_columns WHERE ixp_columns_name = 'meter_type' AND ixp_table_id = @ixp_table_id)
BEGIN
INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major)
SELECT @ixp_table_id, 'meter_type', 'VARCHAR(600)', 0
END

IF NOT EXISTS (SELECT 1 FROM ixp_columns WHERE ixp_columns_name = 'effective_date' AND ixp_table_id = @ixp_table_id)
BEGIN
INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major)
SELECT @ixp_table_id, 'effective_date', 'VARCHAR(600)', 0
END
