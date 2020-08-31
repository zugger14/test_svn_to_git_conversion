IF NOT EXISTS(SELECT 'X' FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'status_rule_activity' AND COLUMN_NAME = 'workflow_function_id')
BEGIN
	ALTER TABLE status_rule_activity ADD  workflow_function_id INT
END

GO


