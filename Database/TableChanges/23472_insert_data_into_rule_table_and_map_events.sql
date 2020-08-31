IF NOT EXISTS (SELECT 1 FROM workflow_module_event_mapping WHERE module_id = 20624 AND event_id = 20573)
BEGIN
	INSERT INTO workflow_module_event_mapping (module_id, event_id, is_active)
	SELECT 20624,20573,1 
END

IF NOT EXISTS (SELECT 1 FROM alert_table_definition atd WHERE atd.physical_table_name = 'WF_Incidentlog') 
BEGIN INSERT INTO alert_table_definition (physical_table_name, logical_table_name)    
	SELECT 'WF_Incidentlog'  , 'Incident Log' 
END


DECLARE @rule_table_id INT
SELECT @rule_table_id = alert_table_definition_id FROM alert_table_definition WHERE physical_table_name = 'WF_Incidentlog'
IF NOT EXISTS (SELECT 1 FROM workflow_module_rule_table_mapping WHERE module_id = 20608 AND rule_table_id = @rule_table_id)
BEGIN
	INSERT INTO workflow_module_rule_table_mapping (module_id, rule_table_id, is_active)
	SELECT 20624,@rule_table_id,1
END


IF NOT EXISTS (SELECT 1 FROM alert_columns_definition WHERE alert_table_id = @rule_table_id AND column_name = 'incident_log_id')
BEGIN
	INSERT INTO alert_columns_definition(alert_table_id, column_name, is_primary, column_alias)
	SELECT @rule_table_id, 'incident_log_id', 'y', 'Incident Log ID'
END

IF NOT EXISTS (SELECT 1 FROM alert_columns_definition WHERE alert_table_id = @rule_table_id AND column_name = 'incident_type')
BEGIN
	INSERT INTO alert_columns_definition(alert_table_id, column_name, is_primary, column_alias)
	SELECT @rule_table_id, 'incident_type', 'n', 'Incident Type'
END

IF NOT EXISTS (SELECT 1 FROM alert_columns_definition WHERE alert_table_id = @rule_table_id AND column_name = 'incident_status')
BEGIN
	INSERT INTO alert_columns_definition(alert_table_id, column_name, is_primary, column_alias)
	SELECT @rule_table_id, 'incident_status', 'n', 'Incident Status'
END

IF NOT EXISTS (SELECT 1 FROM alert_columns_definition WHERE alert_table_id = @rule_table_id AND column_name = 'application_notes_id')
BEGIN
	INSERT INTO alert_columns_definition(alert_table_id, column_name, is_primary, column_alias)
	SELECT @rule_table_id, 'application_notes_id', 'n', 'Application Notes ID'
END

IF NOT EXISTS (SELECT 1 FROM alert_columns_definition WHERE alert_table_id = @rule_table_id AND column_name = 'internal_counterparty')
BEGIN
	INSERT INTO alert_columns_definition(alert_table_id, column_name, is_primary, column_alias)
	SELECT @rule_table_id, 'internal_counterparty', 'n', 'Internal Counterparty'
END

IF NOT EXISTS (SELECT 1 FROM alert_columns_definition WHERE alert_table_id = @rule_table_id AND column_name = 'contract')
BEGIN
	INSERT INTO alert_columns_definition(alert_table_id, column_name, is_primary, column_alias)
	SELECT @rule_table_id, 'contract', 'n', 'Contract'
END

IF NOT EXISTS (SELECT 1 FROM alert_columns_definition WHERE alert_table_id = @rule_table_id AND column_name = 'application_notes_id_detail')
BEGIN
	INSERT INTO alert_columns_definition(alert_table_id, column_name, is_primary, column_alias)
	SELECT @rule_table_id, 'application_notes_id_detail', 'n', 'Application Notes ID Detail'
END

IF NOT EXISTS (SELECT 1 FROM alert_columns_definition WHERE alert_table_id = @rule_table_id AND column_name = 'object_id')
BEGIN
	INSERT INTO alert_columns_definition(alert_table_id, column_name, is_primary, column_alias)
	SELECT @rule_table_id, 'object_id', 'n', 'Object ID'
END

IF NOT EXISTS (SELECT 1 FROM alert_columns_definition WHERE alert_table_id = @rule_table_id AND column_name = 'category_id')
BEGIN
	INSERT INTO alert_columns_definition(alert_table_id, column_name, is_primary, column_alias)
	SELECT @rule_table_id, 'category_id', 'n', 'Category ID'
END

IF NOT EXISTS (SELECT 1 FROM alert_columns_definition WHERE alert_table_id = @rule_table_id AND column_name = 'counterparty_id')
BEGIN
	INSERT INTO alert_columns_definition(alert_table_id, column_name, is_primary, column_alias)
	SELECT @rule_table_id, 'counterparty_id', 'n', 'Counterparty ID'
END
