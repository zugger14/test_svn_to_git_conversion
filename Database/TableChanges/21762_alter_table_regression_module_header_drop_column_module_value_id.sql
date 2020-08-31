IF COL_LENGTH('regression_module_header', 'module_value_id') IS NOT NULL
BEGIN
	ALTER TABLE regression_module_header DROP COLUMN module_value_id
END