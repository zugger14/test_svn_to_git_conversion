DECLARE @temp_ixp_tables_id INT
SET @temp_ixp_tables_id = (SELECT it.ixp_tables_id FROM ixp_tables it WHERE it.ixp_tables_name = 'ixp_ice_security_definition')

IF NOT EXISTS(SELECT 1 FROM ixp_columns WHERE ixp_columns_name = 'Symbol' AND ixp_table_id = @temp_ixp_tables_id)
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major)
	VALUES (@temp_ixp_tables_id, 'Symbol', 'NVARCHAR(600)', 0)
END
ELSE
BEGIN
    PRINT 'COLUMN:Symbol ALREADY EXISTS.'
END

IF NOT EXISTS(SELECT 1 FROM ixp_columns WHERE ixp_columns_name = 'LegSymbol' AND ixp_table_id = @temp_ixp_tables_id)
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major)
	VALUES (@temp_ixp_tables_id, 'LegSymbol', 'NVARCHAR(600)', 0)
END
ELSE
BEGIN
    PRINT 'COLUMN:LegSymbol ALREADY EXISTS.'
END

IF NOT EXISTS(SELECT 1 FROM ixp_columns WHERE ixp_columns_name = 'SecurityDefinitionID' AND ixp_table_id = @temp_ixp_tables_id)
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major)
	VALUES (@temp_ixp_tables_id, 'SecurityDefinitionID', 'VARCHAR(100)', 0)
END
ELSE
BEGIN
    PRINT 'COLUMN:SecurityDefinitionID ALREADY EXISTS.'
END

IF NOT EXISTS(SELECT 1 FROM ixp_columns WHERE ixp_columns_name = 'UnitOfMeasure' AND ixp_table_id = @temp_ixp_tables_id)
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major)
	VALUES (@temp_ixp_tables_id, 'UnitOfMeasure', 'VARCHAR(100)', 0)
END
ELSE
BEGIN
    PRINT 'COLUMN:UnitOfMeasure ALREADY EXISTS.'
END

IF NOT EXISTS(SELECT 1 FROM ixp_columns WHERE ixp_columns_name = 'StripName' AND ixp_table_id = @temp_ixp_tables_id)
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major)
	VALUES (@temp_ixp_tables_id, 'StripName', 'VARCHAR(100)', 0)
END
ELSE
BEGIN
    PRINT 'COLUMN:StripName ALREADY EXISTS.'
END