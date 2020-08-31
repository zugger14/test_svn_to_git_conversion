DECLARE @rule_table_id INT

/*
 * Contract Module
 */ 
SELECT @rule_table_id = alert_table_definition_id FROM alert_table_definition WHERE physical_table_name = 'contract_group'
IF NOT EXISTS (SELECT 1 FROM workflow_module_rule_table_mapping WHERE module_id = 20603 AND rule_table_id = @rule_table_id)
BEGIN
	INSERT INTO workflow_module_rule_table_mapping (module_id, rule_table_id, is_active)
	SELECT 20603,@rule_table_id,1 
END

SELECT @rule_table_id = alert_table_definition_id FROM alert_table_definition WHERE physical_table_name = 'contract_group_audit_view'
IF NOT EXISTS (SELECT 1 FROM workflow_module_rule_table_mapping WHERE module_id = 20603 AND rule_table_id = @rule_table_id)
BEGIN
	INSERT INTO workflow_module_rule_table_mapping (module_id, rule_table_id, is_active)
	SELECT 20603,@rule_table_id,1
END

/*
 * Deal Module
 */ 
SELECT @rule_table_id = alert_table_definition_id FROM alert_table_definition WHERE physical_table_name = 'vwSourceDealHeader'
IF NOT EXISTS (SELECT 1 FROM workflow_module_rule_table_mapping WHERE module_id = 20601 AND rule_table_id = @rule_table_id)
BEGIN
	INSERT INTO workflow_module_rule_table_mapping (module_id, rule_table_id, is_active)
	SELECT 20601,@rule_table_id,1
END

SELECT @rule_table_id = alert_table_definition_id FROM alert_table_definition WHERE physical_table_name = 'source_deal_detail'
IF NOT EXISTS (SELECT 1 FROM workflow_module_rule_table_mapping WHERE module_id = 20601 AND rule_table_id = @rule_table_id)
BEGIN
	INSERT INTO workflow_module_rule_table_mapping (module_id, rule_table_id, is_active)
	SELECT 20601,@rule_table_id,1  
END

SELECT @rule_table_id = alert_table_definition_id FROM alert_table_definition WHERE physical_table_name = 'confirm_status'
IF NOT EXISTS (SELECT 1 FROM workflow_module_rule_table_mapping WHERE module_id = 20601 AND rule_table_id = @rule_table_id)
BEGIN
	INSERT INTO workflow_module_rule_table_mapping (module_id, rule_table_id, is_active)
	SELECT 20601,@rule_table_id,0  
END

SELECT @rule_table_id = alert_table_definition_id FROM alert_table_definition WHERE physical_table_name = 'confirm_status_recent'
IF NOT EXISTS (SELECT 1 FROM workflow_module_rule_table_mapping WHERE module_id = 20601 AND rule_table_id = @rule_table_id)
BEGIN
	INSERT INTO workflow_module_rule_table_mapping (module_id, rule_table_id, is_active)
	SELECT 20601,@rule_table_id,1  
END

SELECT @rule_table_id = alert_table_definition_id FROM alert_table_definition WHERE physical_table_name = 'deal_confirmation_rule'
IF NOT EXISTS (SELECT 1 FROM workflow_module_rule_table_mapping WHERE module_id = 20601 AND rule_table_id = @rule_table_id)
BEGIN
	INSERT INTO workflow_module_rule_table_mapping (module_id, rule_table_id, is_active)
	SELECT 20601,@rule_table_id,1  
END

SELECT @rule_table_id = alert_table_definition_id FROM alert_table_definition WHERE physical_table_name = 'source_deal_pnl'
IF NOT EXISTS (SELECT 1 FROM workflow_module_rule_table_mapping WHERE module_id = 20601 AND rule_table_id = @rule_table_id)
BEGIN
	INSERT INTO workflow_module_rule_table_mapping (module_id, rule_table_id, is_active)
	SELECT 20601,@rule_table_id,1  
END

SELECT @rule_table_id = alert_table_definition_id FROM alert_table_definition WHERE physical_table_name = 'vwDealContractValue'
IF NOT EXISTS (SELECT 1 FROM workflow_module_rule_table_mapping WHERE module_id = 20601 AND rule_table_id = @rule_table_id)
BEGIN
	INSERT INTO workflow_module_rule_table_mapping (module_id, rule_table_id, is_active)
	SELECT 20601,@rule_table_id,1  
END

SELECT @rule_table_id = alert_table_definition_id FROM alert_table_definition WHERE physical_table_name = 'source_deal_header_template'
IF NOT EXISTS (SELECT 1 FROM workflow_module_rule_table_mapping WHERE module_id = 20601 AND rule_table_id = @rule_table_id)
BEGIN
	INSERT INTO workflow_module_rule_table_mapping (module_id, rule_table_id, is_active)
	SELECT 20601,@rule_table_id,1  
END

/*
 * Invoice Module
 */
SELECT @rule_table_id = alert_table_definition_id FROM alert_table_definition WHERE physical_table_name = 'Calc_invoice_Volume_variance'
IF NOT EXISTS (SELECT 1 FROM workflow_module_rule_table_mapping WHERE module_id = 20605 AND rule_table_id = @rule_table_id)
BEGIN
	INSERT INTO workflow_module_rule_table_mapping (module_id, rule_table_id, is_active)
	SELECT 20605,@rule_table_id,1  
END

SELECT @rule_table_id = alert_table_definition_id FROM alert_table_definition WHERE physical_table_name = 'Calc_invoice_Volume_variance_audit_view'
IF NOT EXISTS (SELECT 1 FROM workflow_module_rule_table_mapping WHERE module_id = 20605 AND rule_table_id = @rule_table_id)
BEGIN
	INSERT INTO workflow_module_rule_table_mapping (module_id, rule_table_id, is_active)
	SELECT 20605,@rule_table_id,1  
END

/*
 * Scheduling Module
 */
SELECT @rule_table_id = alert_table_definition_id FROM alert_table_definition WHERE physical_table_name = 'vwScheduling'
IF NOT EXISTS (SELECT 1 FROM workflow_module_rule_table_mapping WHERE module_id = 20611 AND rule_table_id = @rule_table_id)
BEGIN
	INSERT INTO workflow_module_rule_table_mapping (module_id, rule_table_id, is_active)
	SELECT 20611,@rule_table_id,1  
END

/*
 * Counterparty Module
 */
SELECT @rule_table_id = alert_table_definition_id FROM alert_table_definition WHERE physical_table_name = 'source_counterparty'
IF NOT EXISTS (SELECT 1 FROM workflow_module_rule_table_mapping WHERE module_id = 20601 AND rule_table_id = @rule_table_id)
BEGIN
	INSERT INTO workflow_module_rule_table_mapping (module_id, rule_table_id, is_active)
	SELECT 20601,@rule_table_id,1  
END