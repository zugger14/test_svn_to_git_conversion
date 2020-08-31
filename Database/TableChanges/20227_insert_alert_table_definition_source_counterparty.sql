IF NOT EXISTS (SELECT 1 FROM alert_table_definition atd WHERE atd.physical_table_name = 'source_counterparty') 
BEGIN 
	INSERT INTO alert_table_definition (physical_table_name, logical_table_name)    
	SELECT 'source_counterparty'  , 'Counterparty' 
END

DECLARE @alert_table_definition_id INT

SELECT @alert_table_definition_id = alert_table_definition_id
FROM alert_table_definition
WHERE physical_table_name = 'source_counterparty'

IF NOT EXISTS (SELECT 1 FROM alert_columns_definition WHERE alert_table_id = @alert_table_definition_id AND column_name = 'source_counterparty_id')
BEGIN
	INSERT INTO alert_columns_definition(alert_table_id, column_name, is_primary, column_alias)
	SELECT @alert_table_definition_id, 'source_counterparty_id', 'y', 'Source Counterparty ID'
END

IF NOT EXISTS (SELECT 1 FROM alert_columns_definition WHERE alert_table_id = @alert_table_definition_id AND column_name = 'counterparty_id')
BEGIN
	INSERT INTO alert_columns_definition(alert_table_id, column_name, is_primary, column_alias)
	SELECT @alert_table_definition_id, 'counterparty_id', 'n', 'Counterparty ID'
END

IF NOT EXISTS (SELECT 1 FROM alert_columns_definition WHERE alert_table_id = @alert_table_definition_id AND column_name = 'counterparty_name')
BEGIN
	INSERT INTO alert_columns_definition(alert_table_id, column_name, is_primary, column_alias)
	SELECT @alert_table_definition_id, 'counterparty_name', 'n', 'Counterparty Name'
END

IF NOT EXISTS (SELECT 1 FROM alert_columns_definition WHERE alert_table_id = @alert_table_definition_id AND column_name = 'counterparty_desc')
BEGIN
	INSERT INTO alert_columns_definition(alert_table_id, column_name, is_primary, column_alias)
	SELECT @alert_table_definition_id, 'counterparty_desc', 'n', 'Counterparty Desc'
END

IF NOT EXISTS (SELECT 1 FROM alert_columns_definition WHERE alert_table_id = @alert_table_definition_id AND column_name = 'int_ext_flag')
BEGIN
	INSERT INTO alert_columns_definition(alert_table_id, column_name, is_primary, column_alias)
	SELECT @alert_table_definition_id, 'int_ext_flag', 'n', 'Internal External Flag'
END

IF NOT EXISTS (SELECT 1 FROM alert_columns_definition WHERE alert_table_id = @alert_table_definition_id AND column_name = 'is_active')
BEGIN
	INSERT INTO alert_columns_definition(alert_table_id, column_name, is_primary, column_alias)
	SELECT @alert_table_definition_id, 'is_active', 'n', 'Is Active'
END

IF NOT EXISTS (SELECT 1 FROM alert_columns_definition WHERE alert_table_id = @alert_table_definition_id AND column_name = 'type_of_entity')
BEGIN
	INSERT INTO alert_columns_definition(alert_table_id, column_name, is_primary, column_alias)
	SELECT @alert_table_definition_id, 'type_of_entity', 'n', 'Entity Type'
END

IF NOT EXISTS (SELECT 1 FROM alert_columns_definition WHERE alert_table_id = @alert_table_definition_id AND column_name = 'delivery_method')
BEGIN
	INSERT INTO alert_columns_definition(alert_table_id, column_name, is_primary, column_alias)
	SELECT @alert_table_definition_id, 'delivery_method', 'n', 'Delivery Method'
END

IF NOT EXISTS (SELECT 1 FROM alert_columns_definition WHERE alert_table_id = @alert_table_definition_id AND column_name = 'address')
BEGIN
	INSERT INTO alert_columns_definition(alert_table_id, column_name, is_primary, column_alias)
	SELECT @alert_table_definition_id, 'address', 'n', 'Address'
END

IF NOT EXISTS (SELECT 1 FROM alert_columns_definition WHERE alert_table_id = @alert_table_definition_id AND column_name = 'country')
BEGIN
	INSERT INTO alert_columns_definition(alert_table_id, column_name, is_primary, column_alias)
	SELECT @alert_table_definition_id, 'country', 'n', 'Country'
END

IF NOT EXISTS (SELECT 1 FROM alert_columns_definition WHERE alert_table_id = @alert_table_definition_id AND column_name = 'region')
BEGIN
	INSERT INTO alert_columns_definition(alert_table_id, column_name, is_primary, column_alias)
	SELECT @alert_table_definition_id, 'region', 'n', 'Region'
END