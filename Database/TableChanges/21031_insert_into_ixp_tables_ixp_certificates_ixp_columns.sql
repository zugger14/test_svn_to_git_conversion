-- TABLE:[certificate ixp table]
IF NOT EXISTS (SELECT 1 FROM ixp_tables WHERE ixp_tables_name = 'ixp_certificate')
BEGIN
	INSERT INTO ixp_tables (ixp_tables_name, ixp_tables_description)
	VALUES('ixp_certificate', 'Certificte')
END 

DECLARE @temp_ixp_tables_id INT

SET @temp_ixp_tables_id = (SELECT it.ixp_tables_id FROM ixp_tables it WHERE it.ixp_tables_name = 'ixp_certificate')

--COLUMN:[production_installation_id]
IF NOT EXISTS(SELECT 1 FROM ixp_columns WHERE ixp_columns_name = 'production_installation_id' AND ixp_table_id = @temp_ixp_tables_id)
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major)
	VALUES (@temp_ixp_tables_id, 'production_installation_id', 'VARCHAR(600)', 0)
END
ELSE
BEGIN
    PRINT 'COLUMN:production_installation_id ALREADY EXISTS.'
END

--COLUMN:[certificate_start_id]
IF NOT EXISTS(SELECT 1 FROM ixp_columns WHERE ixp_columns_name = 'certificate_start_id' AND ixp_table_id = @temp_ixp_tables_id)
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major)
	VALUES (@temp_ixp_tables_id, 'certificate_start_id', 'VARCHAR(600)', 0)
END
ELSE
BEGIN
    PRINT 'COLUMN:certificate_start_id ALREADY EXISTS.'
END

--COLUMN:[certificate_end_id]
IF NOT EXISTS(SELECT 1 FROM ixp_columns WHERE ixp_columns_name = 'certificate_end_id' AND ixp_table_id = @temp_ixp_tables_id)
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major)
	VALUES (@temp_ixp_tables_id, 'certificate_end_id', 'VARCHAR(600)', 0)
END
ELSE
BEGIN
    PRINT 'COLUMN:certificate_end_id ALREADY EXISTS.'
END

--COLUMN:[quantity]
IF NOT EXISTS(SELECT 1 FROM ixp_columns WHERE ixp_columns_name = 'quantity' AND ixp_table_id = @temp_ixp_tables_id)
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major)
	VALUES (@temp_ixp_tables_id, 'quantity', 'VARCHAR(600)', 0)
END
ELSE
BEGIN
    PRINT 'COLUMN:quantity ALREADY EXISTS.'
END

--COLUMN:[energy]
IF NOT EXISTS(SELECT 1 FROM ixp_columns WHERE ixp_columns_name = 'energy' AND ixp_table_id = @temp_ixp_tables_id)
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major)
	VALUES (@temp_ixp_tables_id, 'energy', 'VARCHAR(600)', 0)
END
ELSE
BEGIN
    PRINT 'COLUMN:energy ALREADY EXISTS.'
END

--COLUMN:[production_start_date]
IF NOT EXISTS(SELECT 1 FROM ixp_columns WHERE ixp_columns_name = 'production_start_date' AND ixp_table_id = @temp_ixp_tables_id)
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major)
	VALUES (@temp_ixp_tables_id, 'production_start_date', 'VARCHAR(600)', 0)
END
ELSE
BEGIN
    PRINT 'COLUMN:production_start_date ALREADY EXISTS.'
END

--COLUMN:[production_end_date]
IF NOT EXISTS(SELECT 1 FROM ixp_columns WHERE ixp_columns_name = 'production_end_date' AND ixp_table_id = @temp_ixp_tables_id)
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major)
	VALUES (@temp_ixp_tables_id, 'production_end_date', 'VARCHAR(600)', 0)
END
ELSE
BEGIN
    PRINT 'COLUMN:production_end_date ALREADY EXISTS.'
END

--COLUMN:[expiry_date]
IF NOT EXISTS(SELECT 1 FROM ixp_columns WHERE ixp_columns_name = 'expiry_date' AND ixp_table_id = @temp_ixp_tables_id)
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major)
	VALUES (@temp_ixp_tables_id, 'expiry_date', 'VARCHAR(600)', 0)
END
ELSE
BEGIN
    PRINT 'COLUMN:expiry_date ALREADY EXISTS.'
END

--COLUMN:[issue_date]
IF NOT EXISTS(SELECT 1 FROM ixp_columns WHERE ixp_columns_name = 'issue_date' AND ixp_table_id = @temp_ixp_tables_id)
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major)
	VALUES (@temp_ixp_tables_id, 'issue_date', 'VARCHAR(600)', 0)
END
ELSE
BEGIN
    PRINT 'COLUMN:issue_date ALREADY EXISTS.'
END

--COLUMN:[tier]
IF NOT EXISTS(SELECT 1 FROM ixp_columns WHERE ixp_columns_name = 'tier' AND ixp_table_id = @temp_ixp_tables_id)
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major)
	VALUES (@temp_ixp_tables_id, 'tier', 'VARCHAR(600)', 0)
END
ELSE
BEGIN
    PRINT 'COLUMN:tier ALREADY EXISTS.'
END

--COLUMN:[juridiction]
IF NOT EXISTS(SELECT 1 FROM ixp_columns WHERE ixp_columns_name = 'juridiction' AND ixp_table_id = @temp_ixp_tables_id)
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major)
	VALUES (@temp_ixp_tables_id, 'juridiction', 'VARCHAR(600)', 0)
END
ELSE
BEGIN
    PRINT 'COLUMN:juridiction ALREADY EXISTS.'
END

--COLUMN:[state_value_id]
--IF NOT EXISTS(SELECT 1 FROM ixp_columns WHERE ixp_columns_name = 'state_value_id' AND ixp_table_id = @temp_ixp_tables_id)
--BEGIN
--	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major)
--	VALUES (@temp_ixp_tables_id, 'state_value_id', 'VARCHAR(600)', 0)
--END
--ELSE
--BEGIN
--    PRINT 'COLUMN:state_value_id ALREADY EXISTS.'
--END

--COLUMN:[certification_entity]
IF NOT EXISTS(SELECT 1 FROM ixp_columns WHERE ixp_columns_name = 'certification_entity' AND ixp_table_id = @temp_ixp_tables_id)
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major)
	VALUES (@temp_ixp_tables_id, 'certification_entity', 'VARCHAR(600)', 0)
END
ELSE
BEGIN
    PRINT 'COLUMN:certification_entity ALREADY EXISTS.'
END

--COLUMN:[year]
IF NOT EXISTS(SELECT 1 FROM ixp_columns WHERE ixp_columns_name = 'year' AND ixp_table_id = @temp_ixp_tables_id)
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major)
	VALUES (@temp_ixp_tables_id, 'year', 'VARCHAR(600)', 0)
END
ELSE
BEGIN
    PRINT 'COLUMN:year ALREADY EXISTS.'
END

--*/