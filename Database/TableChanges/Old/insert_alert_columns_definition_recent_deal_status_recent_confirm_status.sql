DECLARE @alert_table_definition_id INT

SELECT @alert_table_definition_id = alert_table_definition_id
FROM alert_table_definition
WHERE physical_table_name = 'source_deal_header' OR physical_table_name = 'vwSourceDealHeader'

IF NOT EXISTS (SELECT 1 FROM alert_columns_definition WHERE alert_table_id = @alert_table_definition_id AND column_name = 'recent_deal_status')
BEGIN
	INSERT INTO alert_columns_definition(alert_table_id, column_name, is_primary, column_alias)
	SELECT @alert_table_definition_id, 'recent_deal_status', 'n', 'Recent Deal Status'
END

IF NOT EXISTS (SELECT 1 FROM alert_columns_definition WHERE alert_table_id = @alert_table_definition_id AND column_name = 'recent_confirm_status')
BEGIN
	INSERT INTO alert_columns_definition(alert_table_id, column_name, is_primary, column_alias)
	SELECT @alert_table_definition_id, 'recent_confirm_status', 'n', 'Recent Confirm Status'
END

UPDATE alert_table_definition
SET physical_table_name = 'vwSourceDealHeader'
WHERE physical_table_name = 'source_deal_header'