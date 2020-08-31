IF NOT EXISTS (
		SELECT 1
		FROM ixp_tables it
		WHERE it.ixp_tables_name = 'ixp_ice_security_definition'
		)
BEGIN
	INSERT INTO ixp_tables (
		ixp_tables_name
		,ixp_tables_description
		,import_export_flag
		)
	SELECT 'ixp_ice_security_definition'
		,'ICE Security Definition'
		,'i'
END
ELSE PRINT 'table already present'
DECLARE @temp_ixp_tables_id INT
SET @temp_ixp_tables_id = (SELECT it.ixp_tables_id FROM ixp_tables it WHERE it.ixp_tables_name = 'ixp_ice_security_definition')
     
IF NOT EXISTS(SELECT 1 FROM ixp_columns WHERE ixp_columns_name = 'HubAlias' AND ixp_table_id = @temp_ixp_tables_id)
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major)
	VALUES (@temp_ixp_tables_id, 'HubAlias', 'VARCHAR(600)', 0)
END
ELSE
BEGIN
    PRINT 'COLUMN:HubAlias ALREADY EXISTS.'
END





--COLUMN:[source_deal_header_id]
IF NOT EXISTS(SELECT 1 FROM ixp_columns WHERE ixp_columns_name = 'product_id' AND ixp_table_id = @temp_ixp_tables_id)
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major)
	VALUES (@temp_ixp_tables_id, 'product_id', 'VARCHAR(600)', 0)
END
ELSE
BEGIN
    PRINT 'COLUMN:product_id ALREADY EXISTS.'
END

IF NOT EXISTS(SELECT 1 FROM ixp_columns WHERE ixp_columns_name = 'ExchangeName' AND ixp_table_id = @temp_ixp_tables_id)
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major)
	VALUES (@temp_ixp_tables_id, 'ExchangeName', 'VARCHAR(600)', 0)
END
ELSE
BEGIN
    PRINT 'COLUMN:ExchangeName ALREADY EXISTS.'
END

IF NOT EXISTS(SELECT 1 FROM ixp_columns WHERE ixp_columns_name = 'ProductName' AND ixp_table_id = @temp_ixp_tables_id)
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major)
	VALUES (@temp_ixp_tables_id, 'ProductName', 'VARCHAR(600)', 0)
END
ELSE
BEGIN
    PRINT 'COLUMN:ProductName ALREADY EXISTS.'
END

IF NOT EXISTS(SELECT 1 FROM ixp_columns WHERE ixp_columns_name = 'Granularity' AND ixp_table_id = @temp_ixp_tables_id)
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major)
	VALUES (@temp_ixp_tables_id, 'Granularity', 'VARCHAR(600)', 0)
END
ELSE
BEGIN
    PRINT 'COLUMN:Granularity ALREADY EXISTS.'
END

IF NOT EXISTS(SELECT 1 FROM ixp_columns WHERE ixp_columns_name = 'TickValue' AND ixp_table_id = @temp_ixp_tables_id)
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major)
	VALUES (@temp_ixp_tables_id, 'TickValue', 'VARCHAR(600)', 0)
END
ELSE
BEGIN
    PRINT 'COLUMN:TickValue ALREADY EXISTS.'
END
IF NOT EXISTS(SELECT 1 FROM ixp_columns WHERE ixp_columns_name = 'uom_id' AND ixp_table_id = @temp_ixp_tables_id)
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major)
	VALUES (@temp_ixp_tables_id, 'uom_id', 'VARCHAR(600)', 0)
END
ELSE
BEGIN
    PRINT 'COLUMN:uom_id ALREADY EXISTS.'
END

IF NOT EXISTS(SELECT 1 FROM ixp_columns WHERE ixp_columns_name = 'HubName' AND ixp_table_id = @temp_ixp_tables_id)
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major)
	VALUES (@temp_ixp_tables_id, 'HubName', 'VARCHAR(600)', 0)
END
ELSE
BEGIN
    PRINT 'COLUMN:HubName ALREADY EXISTS.'
END

IF NOT EXISTS(SELECT 1 FROM ixp_columns WHERE ixp_columns_name = 'Currency_id' AND ixp_table_id = @temp_ixp_tables_id)
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major)
	VALUES (@temp_ixp_tables_id, 'Currency_id', 'VARCHAR(600)', 0)
END
ELSE
BEGIN
    PRINT 'COLUMN:Currency_id ALREADY EXISTS.'
END

IF NOT EXISTS(SELECT 1 FROM ixp_columns WHERE ixp_columns_name = 'CFICode' AND ixp_table_id = @temp_ixp_tables_id)
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major)
	VALUES (@temp_ixp_tables_id, 'CFICode', 'VARCHAR(600)', 0)
END
ELSE
BEGIN
    PRINT 'COLUMN:CFICode ALREADY EXISTS.'
END

