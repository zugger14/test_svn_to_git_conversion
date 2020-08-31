DECLARE @rule_table_id INT
SELECT @rule_table_id = alert_table_definition_id FROM alert_table_definition WHERE physical_table_name = 'vwCounterPartyCreditLimitsAudit'

IF NOT EXISTS (SELECT 1 FROM workflow_module_rule_table_mapping WHERE module_id = 20609 AND rule_table_id = @rule_table_id)
BEGIN
 INSERT INTO workflow_module_rule_table_mapping (module_id, rule_table_id, is_active)
 SELECT 20609,@rule_table_id,1
END
 