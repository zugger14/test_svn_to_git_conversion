UPDATE acd
SET is_primary = 'n' FROM alert_table_definition atd
INNER JOIN alert_columns_definition acd ON atd.alert_table_definition_id = acd.alert_columns_definition_id
WHERE atd.physical_table_name = 'vwScheduling' AND acd.column_name = 'match_group_id'

DELETE FROM alert_columns_definition WHERE column_name = 'mgs_match_group_shipment_id]'

UPDATE acd
SET column_name = 'mgs_match_group_shipment_id',
	is_primary = 'y' 
FROM alert_table_definition atd
INNER JOIN alert_columns_definition acd ON atd.alert_table_definition_id = acd.alert_table_id
WHERE atd.physical_table_name = 'vwScheduling' AND acd.column_alias = 'shipment ID'

DECLARE @new_alert_table_definition_id INT
SELECT @new_alert_table_definition_id = alert_table_definition_id FROM alert_table_definition WHERE logical_table_name = 'Scheduling'
IF NOT EXISTS (SELECT 1 FROM alert_columns_definition WHERE alert_table_id = @new_alert_table_definition_id AND column_name = 'mgs_match_group_shipment_id' AND is_primary = 'y')
BEGIN
	INSERT INTO alert_columns_definition(alert_table_id, column_name, is_primary, column_alias)
	SELECT @new_alert_table_definition_id, 'mgs_match_group_shipment_id', 'y', 'shipment ID'
END