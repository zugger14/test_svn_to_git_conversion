IF NOT EXISTS(SELECT 'X' FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'process_filters' AND COLUMN_NAME = 'module_type')
BEGIN
	ALter table process_filters ADD module_type CHAR(1)

END