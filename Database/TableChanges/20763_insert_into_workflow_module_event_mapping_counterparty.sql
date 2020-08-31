IF NOT EXISTS (SELECT 1 FROM workflow_module_event_mapping WHERE module_id = 20602 AND event_id = 20542)
BEGIN
	INSERT INTO workflow_module_event_mapping (module_id, event_id, is_active)
	SELECT 20602,	20542,	1
END

IF NOT EXISTS (SELECT 1 FROM workflow_module_event_mapping WHERE module_id = 20602 AND event_id = 20544)
BEGIN
	INSERT INTO workflow_module_event_mapping (module_id, event_id, is_active)
	SELECT 20602,	20544,	1
END

IF NOT EXISTS (SELECT 1 FROM workflow_module_event_mapping WHERE module_id = 20602 AND event_id = 20508)
BEGIN
	INSERT INTO workflow_module_event_mapping (module_id, event_id, is_active)
	SELECT 20602,	20508,	1
END

IF NOT EXISTS (SELECT 1 FROM workflow_module_rule_table_mapping  w
				INNER JOIN alert_table_definition atd ON atd.alert_table_definition_id = w.rule_table_id
				WHERE w.module_id = 20602 AND atd.logical_table_name = 'Counterparty')
BEGIN
	INSERT INTO workflow_module_rule_table_mapping (module_id, rule_table_id, is_active)
	SELECT  20602, atd.alert_table_definition_id, 1 FROM alert_table_definition atd 
	WHERE atd.logical_table_name = 'Counterparty'
END

IF NOT EXISTS (SELECT 1 FROM workflow_module_rule_table_mapping  w
				INNER JOIN alert_table_definition atd ON atd.alert_table_definition_id = w.rule_table_id
				WHERE w.module_id = 20602 AND atd.logical_table_name = 'Counterparty Credit Info')
BEGIN
	INSERT INTO workflow_module_rule_table_mapping (module_id, rule_table_id, is_active)
	SELECT  20602, atd.alert_table_definition_id, 1 FROM alert_table_definition atd 
	WHERE atd.logical_table_name = 'Counterparty Credit Info'
END