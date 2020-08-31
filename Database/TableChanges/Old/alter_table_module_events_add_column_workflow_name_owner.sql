IF NOT EXISTS(SELECT 'X' FROM INFORMATION_SCHEMA.COLUMNS 
              WHERE TABLE_NAME = 'module_events' AND COLUMN_NAME = 'workflow_name')
BEGIN
	ALTER TABLE module_events ADD workflow_name VARCHAR(100)
END

IF NOT EXISTS(SELECT 'X' FROM INFORMATION_SCHEMA.COLUMNS 
              WHERE TABLE_NAME = 'module_events' AND COLUMN_NAME = 'workflow_owner')
BEGIN
	ALTER TABLE module_events ADD workflow_owner VARCHAR(100)
END