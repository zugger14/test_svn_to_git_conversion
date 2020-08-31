-- 1 Insert into ixp_tables
IF NOT EXISTS (SELECT 1 FROM ixp_tables it WHERE it.ixp_tables_name = 'ixp_demand_volume_template')

 

BEGIN
    INSERT INTO ixp_tables (ixp_tables_name, ixp_tables_description, import_export_flag)
    SELECT 'ixp_demand_volume_template' , 'Demand Forecast Import', 'i'
END

 

-- 2 Insert into ixp_columns logical_name, constraint_type, value, uom, effective_date, frequency
DECLARE @ixp_tables_id INT
SELECT @ixp_tables_id = ixp_tables_id FROM ixp_tables WHERE ixp_tables_name = 'ixp_demand_volume_template'

 

IF NOT EXISTS(SELECT 1 FROM ixp_columns AS ic WHERE ic.ixp_table_id = @ixp_tables_id AND ic.ixp_columns_name LIKE 'term_start')
BEGIN
    INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major)
    VALUES
    (@ixp_tables_id,'term_start','VARCHAR(600)', 0 )
END
IF NOT EXISTS(SELECT 1 FROM ixp_columns AS ic WHERE ic.ixp_table_id = @ixp_tables_id AND ic.ixp_columns_name LIKE 'term_end')
BEGIN
    INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major)
    VALUES
    (@ixp_tables_id,'term_end','VARCHAR(600)', 0 )
END
IF NOT EXISTS(SELECT 1 FROM ixp_columns AS ic WHERE ic.ixp_table_id = @ixp_tables_id AND ic.ixp_columns_name LIKE 'location')
BEGIN
    INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major)
    VALUES
    (@ixp_tables_id,'location','VARCHAR(600)', 0 )
END
IF NOT EXISTS(SELECT 1 FROM ixp_columns AS ic WHERE ic.ixp_table_id = @ixp_tables_id AND ic.ixp_columns_name LIKE 'volume')
BEGIN
    INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major)
    VALUES
    (@ixp_tables_id,'volume','VARCHAR(600)', 0 )
END