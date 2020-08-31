IF EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10106600)
BEGIN
	UPDATE application_functions
		SET file_path = '_compliance_management/setup_rule_workflow/setup.rule.workflow.php'
		WHERE function_id = 10106600
END