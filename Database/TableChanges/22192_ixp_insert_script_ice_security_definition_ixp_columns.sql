DECLARE @temp_ixp_tables_id INT
SET @temp_ixp_tables_id = (SELECT it.ixp_tables_id FROM ixp_tables it WHERE it.ixp_tables_name = 'ixp_ice_security_definition')

IF NOT EXISTS(SELECT 1 FROM ixp_columns WHERE ixp_columns_name = 'PriceUnit' AND ixp_table_id = @temp_ixp_tables_id)
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major)
	VALUES (@temp_ixp_tables_id, 'PriceUnit', 'VARCHAR(600)', 0)
END
ELSE
BEGIN
    PRINT 'COLUMN:PriceUnit ALREADY EXISTS.'
END

IF NOT EXISTS(SELECT 1 FROM ixp_columns WHERE ixp_columns_name = 'UnderlyingContractMultiplier' AND ixp_table_id = @temp_ixp_tables_id)
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major)
	VALUES (@temp_ixp_tables_id, 'UnderlyingContractMultiplier', 'VARCHAR(600)', 0)
END
ELSE
BEGIN
    PRINT 'COLUMN:UnderlyingContractMultiplier ALREADY EXISTS.'
END


IF NOT EXISTS(SELECT 1 FROM ixp_columns WHERE ixp_columns_name = 'LotSize' AND ixp_table_id = @temp_ixp_tables_id)
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major)
	VALUES (@temp_ixp_tables_id, 'LotSize', 'VARCHAR(600)', 0)
END
ELSE
BEGIN
    PRINT 'COLUMN:LotSize ALREADY EXISTS.'
END

IF NOT EXISTS(SELECT 1 FROM ixp_columns WHERE ixp_columns_name = 'PriceDenomination' AND ixp_table_id = @temp_ixp_tables_id)
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major)
	VALUES (@temp_ixp_tables_id, 'PriceDenomination', 'VARCHAR(600)', 0)
END
ELSE
BEGIN
    PRINT 'COLUMN:PriceDenomination ALREADY EXISTS.'
END

IF NOT EXISTS(SELECT 1 FROM ixp_columns WHERE ixp_columns_name = 'SecurityID' AND ixp_table_id = @temp_ixp_tables_id)
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major)
	VALUES (@temp_ixp_tables_id, 'SecurityID', 'VARCHAR(600)', 0)
END
ELSE
BEGIN
    PRINT 'COLUMN:SecurityID ALREADY EXISTS.'
END

IF NOT EXISTS(SELECT 1 FROM  ixp_columns c INNER JOIN ixp_tables t on t.ixp_tables_id = c.ixp_table_id WHERE ixp_columns_name = 'UnderlyingContractMultiplier'   AND ixp_tables_name = 'ixp_ice_security_definition')
BEGIN
	INSERT INTO ixp_columns(ixp_table_id,ixp_columns_name)
	SELECT ixp_tables_id,'UnderlyingContractMultiplier' FROM ixp_tables t WHERE ixp_tables_name = 'ixp_ice_security_definition'
END 
ELSE
BEGIN
    PRINT 'COLUMN:UnderlyingContractMultiplier ALREADY EXISTS.'
END