DECLARE @alert_table_definition_id INT

SELECT @alert_table_definition_id = alert_table_definition_id
FROM alert_table_definition
WHERE physical_table_name = 'vwSourceDealHeader'

IF NOT EXISTS (SELECT 1 FROM alert_columns_definition WHERE alert_table_id = @alert_table_definition_id AND column_name = 'subsidiary')
BEGIN
	INSERT INTO alert_columns_definition(alert_table_id, column_name, is_primary, column_alias)
	SELECT @alert_table_definition_id, 'subsidiary', 'n', 'Subsidiary'
END

IF NOT EXISTS (SELECT 1 FROM alert_columns_definition WHERE alert_table_id = @alert_table_definition_id AND column_name = 'strategy')
BEGIN
	INSERT INTO alert_columns_definition(alert_table_id, column_name, is_primary, column_alias)
	SELECT @alert_table_definition_id, 'strategy', 'n', 'Strategy'
END

IF NOT EXISTS (SELECT 1 FROM alert_columns_definition WHERE alert_table_id = @alert_table_definition_id AND column_name = 'book')
BEGIN
	INSERT INTO alert_columns_definition(alert_table_id, column_name, is_primary, column_alias)
	SELECT @alert_table_definition_id, 'book', 'n', 'Book'
END