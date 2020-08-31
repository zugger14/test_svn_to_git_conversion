IF NOT EXISTS (SELECT 1 FROM ixp_tables it WHERE it.ixp_tables_name = 'ixp_power_outage') 
BEGIN 
	INSERT INTO ixp_tables (ixp_tables_name, ixp_tables_description, import_export_flag) 
	SELECT 'ixp_power_outage', 'Power Outage', 'i' 
END

--TABLE: ixp_power_outage 
     
DECLARE @temp_ixp_tables_id INT

SET @temp_ixp_tables_id = (SELECT it.ixp_tables_id FROM ixp_tables it WHERE it.ixp_tables_name = 'ixp_power_outage')
     
--COLUMN:[source_generator_id]
IF NOT EXISTS(SELECT 1 FROM ixp_columns WHERE ixp_columns_name = 'source_generator_id' AND ixp_table_id = @temp_ixp_tables_id)
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major)
	VALUES (@temp_ixp_tables_id, 'source_generator_id', 'VARCHAR(600)', 0)
END
ELSE
BEGIN
    PRINT 'COLUMN:source_generator_id ALREADY EXISTS.'
END

--TABLE: ixp_power_outage 
     
--COLUMN:[planned_start]
IF NOT EXISTS(SELECT 1 FROM ixp_columns WHERE ixp_columns_name = 'planned_start' AND ixp_table_id = @temp_ixp_tables_id)
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major)
	VALUES (@temp_ixp_tables_id, 'planned_start', 'VARCHAR(600)', 0)
END
ELSE
BEGIN
    PRINT 'COLUMN:planned_start ALREADY EXISTS.'
END
     
--COLUMN:[planned_end]
IF NOT EXISTS(SELECT 1 FROM ixp_columns WHERE ixp_columns_name = 'planned_end' AND ixp_table_id = @temp_ixp_tables_id)
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major)
	VALUES (@temp_ixp_tables_id, 'planned_end', 'VARCHAR(600)', 0)
END
ELSE
BEGIN
    PRINT 'COLUMN:planned_end ALREADY EXISTS.'
END
     
--COLUMN:[actual_start]
IF NOT EXISTS(SELECT 1 FROM ixp_columns WHERE ixp_columns_name = 'actual_start' AND ixp_table_id = @temp_ixp_tables_id)
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major)
	VALUES (@temp_ixp_tables_id, 'actual_start', 'VARCHAR(600)', 0)
END
ELSE
BEGIN
    PRINT 'COLUMN:actual_start ALREADY EXISTS.'
END
     
--COLUMN:[actual_end]
IF NOT EXISTS(SELECT 1 FROM ixp_columns WHERE ixp_columns_name = 'actual_end' AND ixp_table_id = @temp_ixp_tables_id)
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major)
	VALUES (@temp_ixp_tables_id, 'actual_end', 'VARCHAR(600)', 0)
END
ELSE
BEGIN
    PRINT 'COLUMN:actual_end ALREADY EXISTS.'
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
     
--COLUMN:[status]
IF NOT EXISTS(SELECT 1 FROM ixp_columns WHERE ixp_columns_name = 'status' AND ixp_table_id = @temp_ixp_tables_id)
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major)
	VALUES (@temp_ixp_tables_id, 'status', 'VARCHAR(600)', 0)
END
ELSE
BEGIN
    PRINT 'COLUMN:status ALREADY EXISTS.'
END
     
--COLUMN:[request_type]
IF NOT EXISTS(SELECT 1 FROM ixp_columns WHERE ixp_columns_name = 'request_type' AND ixp_table_id = @temp_ixp_tables_id)
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major)
	VALUES (@temp_ixp_tables_id, 'request_type', 'VARCHAR(600)', 0)
END
ELSE
BEGIN
    PRINT 'COLUMN:request_type ALREADY EXISTS.'
END
     
--COLUMN:[outage]
IF NOT EXISTS(SELECT 1 FROM ixp_columns WHERE ixp_columns_name = 'outage' AND ixp_table_id = @temp_ixp_tables_id)
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major)
	VALUES (@temp_ixp_tables_id, 'outage', 'VARCHAR(600)', 0)
END
ELSE
BEGIN
    PRINT 'COLUMN:outage ALREADY EXISTS.'
END
     
--COLUMN:[derate_mw]
IF NOT EXISTS(SELECT 1 FROM ixp_columns WHERE ixp_columns_name = 'derate_mw' AND ixp_table_id = @temp_ixp_tables_id)
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major)
	VALUES (@temp_ixp_tables_id, 'derate_mw', 'VARCHAR(600)', 0)
END
ELSE
BEGIN
    PRINT 'COLUMN:derate_mw ALREADY EXISTS.'
END
     
--COLUMN:[derate_percent]
IF NOT EXISTS(SELECT 1 FROM ixp_columns WHERE ixp_columns_name = 'derate_percent' AND ixp_table_id = @temp_ixp_tables_id)
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major)
	VALUES (@temp_ixp_tables_id, 'derate_percent', 'VARCHAR(600)', 0)
END
ELSE
BEGIN
    PRINT 'COLUMN:derate_percent ALREADY EXISTS.'
END
     
--COLUMN:[type_name]
IF NOT EXISTS(SELECT 1 FROM ixp_columns WHERE ixp_columns_name = 'type_name' AND ixp_table_id = @temp_ixp_tables_id)
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major)
	VALUES (@temp_ixp_tables_id, 'type_name', 'VARCHAR(600)', 0)
END
ELSE
BEGIN
    PRINT 'COLUMN:type_name ALREADY EXISTS.'
END
     
--COLUMN:[comments]
IF NOT EXISTS(SELECT 1 FROM ixp_columns WHERE ixp_columns_name = 'comments' AND ixp_table_id = @temp_ixp_tables_id)
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major)
	VALUES (@temp_ixp_tables_id, 'comments', 'VARCHAR(600)', 0)
END
ELSE
BEGIN
    PRINT 'COLUMN:comments ALREADY EXISTS.'
END