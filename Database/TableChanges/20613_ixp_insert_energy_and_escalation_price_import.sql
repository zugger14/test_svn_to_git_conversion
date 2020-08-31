IF NOT EXISTS (SELECT 1 FROM ixp_tables it WHERE it.ixp_tables_name = 'ixp_source_energy_escalation_price') 
BEGIN 
	INSERT INTO ixp_tables (ixp_tables_name, ixp_tables_description, import_export_flag) 
	SELECT 'ixp_source_energy_escalation_price', 'Import energy price and escalation price', 'i' 
END

--TABLE: ixp_power_outage 
     
DECLARE @temp_ixp_tables_id INT

SET @temp_ixp_tables_id = (SELECT it.ixp_tables_id FROM ixp_tables it WHERE it.ixp_tables_name = 'ixp_source_energy_escalation_price')
     
--COLUMN:[source_curve_def_id]
IF NOT EXISTS(SELECT 1 FROM ixp_columns WHERE ixp_columns_name = 'source_curve_def_id' AND ixp_table_id = @temp_ixp_tables_id)
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major)
	VALUES (@temp_ixp_tables_id, 'source_curve_def_id', 'VARCHAR(600)', 0)
END
ELSE
BEGIN
    PRINT 'COLUMN:source_curve_def_id ALREADY EXISTS.'
END

--TABLE: ixp_power_outage 
     
--COLUMN:[as_of_date]
IF NOT EXISTS(SELECT 1 FROM ixp_columns WHERE ixp_columns_name = 'as_of_date' AND ixp_table_id = @temp_ixp_tables_id)
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major)
	VALUES (@temp_ixp_tables_id, 'as_of_date', 'VARCHAR(600)', 0)
END
ELSE
BEGIN
    PRINT 'COLUMN:as_of_date ALREADY EXISTS.'
END
     
--COLUMN:[curve_value]
IF NOT EXISTS(SELECT 1 FROM ixp_columns WHERE ixp_columns_name = 'curve_value' AND ixp_table_id = @temp_ixp_tables_id)
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major)
	VALUES (@temp_ixp_tables_id, 'curve_value', 'VARCHAR(600)', 0)
END
ELSE
BEGIN
    PRINT 'COLUMN:curve_value ALREADY EXISTS.'
END
 