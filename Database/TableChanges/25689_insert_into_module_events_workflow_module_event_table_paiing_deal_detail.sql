IF EXISTS(SELECT 1 FROM alert_table_definition WHERE alert_table_definition_id = @alert_table_id)
BEGIN
	UPDATE alert_table_definition 
	SET primary_column = 'source_deal_detail_id', 
		physical_table_name = 'WF_Deals',
		data_source_id = '5015',
		is_action_view = 'y'
	WHERE alert_table_definition_id = @alert_table_id
END

IF NOT EXISTS(SELECT 1 FROM workflow_module_rule_table_mapping WHERE module_id = 20637 and rule_table_id = @alert_table_id)
BEGIN
	INSERT INTO workflow_module_rule_table_mapping(module_id, rule_table_id, is_active)
	SELECT 20637, @alert_table_id, 1
END

IF NOT EXISTS(SELECT 1 FROM workflow_module_event_mapping WHERE module_id = 20637 and event_id = 20509)
BEGIN
	INSERT INTO workflow_module_event_mapping(module_id, event_id, is_active)
	SELECT 20637, 20509, 1
END

IF EXISTS(SELECT 1 FROM module_events WHERE workflow_name = 'Deal Transfer Adjust')
BEGIN
	UPDATE module_events 
	SET modules_id = 20637,
	rule_table_id = @alert_table_id
	WHERE workflow_name IN ('Deal Transfer Adjust')
END

IF EXISTS(SELECT 1 FROM module_events WHERE workflow_name = 'Net Physical Position check in Opt-Power Book')
BEGIN
	UPDATE module_events 
	SET modules_id = 20637,
	rule_table_id = @alert_table_id
	WHERE workflow_name IN ('Net Physical Position check in Opt-Power Book')
END


IF EXISTS(SELECT 1 FROM module_events WHERE workflow_name = 'Limit Violation TEC1')
BEGIN
	UPDATE module_events 
	SET modules_id = 20637,
	rule_table_id = @alert_table_id
	WHERE workflow_name IN ('Limit Violation TEC1')
END

IF EXISTS(SELECT 1 FROM module_events WHERE workflow_name = 'Limit Violation TEC2')
BEGIN
	UPDATE module_events 
	SET modules_id = 20637,
	rule_table_id = @alert_table_id
	WHERE workflow_name IN ('Limit Violation TEC2')
END