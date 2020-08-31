--added extra condition to make it faile safe for multiple execution

IF EXISTS (SElECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'state_properties_duration' AND column_name = 'code_value')
	AND NOT EXISTS (SElECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'state_properties_duration' AND column_name = 'state_value_id')
BEGIN
	EXEC sp_RENAME 'state_properties_duration.code_value', 'state_value_id', 'COLUMN'
END