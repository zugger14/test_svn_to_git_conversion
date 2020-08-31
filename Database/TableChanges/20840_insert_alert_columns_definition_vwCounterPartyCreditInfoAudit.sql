DECLARE @alert_table_definition_id INT

SELECT @alert_table_definition_id = alert_table_definition_id
FROM alert_table_definition
WHERE physical_table_name = 'vwCounterPartyCreditInfoAudit'

IF NOT EXISTS (SELECT 1 FROM alert_columns_definition WHERE alert_table_id = @alert_table_definition_id AND column_name = 'risk_rating_compare')
BEGIN
	INSERT INTO alert_columns_definition(alert_table_id, column_name, is_primary, column_alias)
	SELECT @alert_table_definition_id, 'risk_rating_compare', 'n', 'Risk Rating Compare'
END

IF NOT EXISTS (SELECT 1 FROM alert_columns_definition WHERE alert_table_id = @alert_table_definition_id AND column_name = 'previous_risk_rating')
BEGIN
	INSERT INTO alert_columns_definition(alert_table_id, column_name, is_primary, column_alias)
	SELECT @alert_table_definition_id, 'previous_risk_rating', 'n', 'Previous Risk Rating'
END

 