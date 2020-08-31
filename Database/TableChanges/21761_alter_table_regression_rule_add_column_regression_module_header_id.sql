IF COL_LENGTH('regression_rule', 'regression_module_header_id') IS NULL
BEGIN
	ALTER TABLE regression_rule ADD regression_module_header_id INT
END

