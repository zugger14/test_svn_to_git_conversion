DECLARE @alert_table_id INT

SELECT @alert_table_id = alert_table_definition_id
FROM alert_table_definition WHERE physical_table_name = 'source_deal_header'

IF NOT EXISTS (SELECT 1 FROM alert_columns_definition WHERE alert_table_id = @alert_table_id AND column_name = 'sample_control')
BEGIN
	INSERT INTO alert_columns_definition(alert_table_id, column_name, is_primary, column_alias)
	SELECT @alert_table_id, 'sample_control', 'n', 'Subject to Sample Control'
END