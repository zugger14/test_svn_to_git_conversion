--TABLE: ixp_power_outage 
IF NOT EXISTS (SELECT 1 FROM ixp_tables it WHERE it.ixp_tables_name = 'ixp_forecast_profile') 
BEGIN 
	INSERT INTO ixp_tables (ixp_tables_name, ixp_tables_description, import_export_flag) 
	SELECT 'ixp_forecast_profile', 'Forecast Profile Definition', 'i' 
END

DECLARE @temp_ixp_tables_id INT

SET @temp_ixp_tables_id = (SELECT it.ixp_tables_id FROM ixp_tables it WHERE it.ixp_tables_name = 'ixp_forecast_profile')
     
--COLUMN:[profile_id]
IF NOT EXISTS(SELECT 1 FROM ixp_columns WHERE ixp_columns_name = 'profile_id' AND ixp_table_id = @temp_ixp_tables_id)
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major)
	VALUES (@temp_ixp_tables_id, 'profile_id', 'VARCHAR(600)', 0)
END
ELSE
BEGIN
    PRINT 'COLUMN:profile_id ALREADY EXISTS.'
END

--COLUMN:[profile_code]
IF NOT EXISTS(SELECT 1 FROM ixp_columns WHERE ixp_columns_name = 'profile_code' AND ixp_table_id = @temp_ixp_tables_id)
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major)
	VALUES (@temp_ixp_tables_id, 'profile_code', 'VARCHAR(600)', 0)
END
ELSE
BEGIN
    PRINT 'COLUMN:profile_code ALREADY EXISTS.'
END

--COLUMN:[profile_type]
IF NOT EXISTS(SELECT 1 FROM ixp_columns WHERE ixp_columns_name = 'profile_type' AND ixp_table_id = @temp_ixp_tables_id)
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major)
	VALUES (@temp_ixp_tables_id, 'profile_type', 'VARCHAR(600)', 0)
END
ELSE
BEGIN
    PRINT 'COLUMN:profile_type ALREADY EXISTS.'
END

--COLUMN:[uom_id]
IF NOT EXISTS(SELECT 1 FROM ixp_columns WHERE ixp_columns_name = 'uom_id' AND ixp_table_id = @temp_ixp_tables_id)
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major)
	VALUES (@temp_ixp_tables_id, 'uom_id', 'VARCHAR(600)', 0)
END
ELSE
BEGIN
    PRINT 'COLUMN:uom_id ALREADY EXISTS.'
END

--COLUMN:[granularity]
IF NOT EXISTS(SELECT 1 FROM ixp_columns WHERE ixp_columns_name = 'granularity' AND ixp_table_id = @temp_ixp_tables_id)
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major)
	VALUES (@temp_ixp_tables_id, 'granularity', 'VARCHAR(600)', 0)
END
ELSE
BEGIN
    PRINT 'COLUMN:granularity ALREADY EXISTS.'
END

--COLUMN:[profile_name]
IF NOT EXISTS(SELECT 1 FROM ixp_columns WHERE ixp_columns_name = 'profile_name' AND ixp_table_id = @temp_ixp_tables_id)
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major)
	VALUES (@temp_ixp_tables_id, 'profile_name', 'VARCHAR(600)', 0)
END
ELSE
BEGIN
    PRINT 'COLUMN:profile_name ALREADY EXISTS.'
END