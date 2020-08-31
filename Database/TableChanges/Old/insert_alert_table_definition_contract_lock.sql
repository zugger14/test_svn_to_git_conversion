DECLARE @alert_table_id INT
SELECT @alert_table_id = alert_table_definition_id FROM alert_table_definition WHERE physical_table_name = 'contract_group'

IF NOT EXISTS (SELECT 1 FROM alert_columns_definition WHERE alert_table_id = @alert_table_id AND column_name = 'is_lock')
BEGIN
	INSERT INTO alert_columns_definition (alert_table_id, column_name, is_primary, column_alias)
	SELECT @alert_table_id, 'is_lock', 'n', 'Contract Lock'
END