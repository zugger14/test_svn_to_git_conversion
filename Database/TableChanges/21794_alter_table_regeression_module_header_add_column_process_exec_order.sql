IF COL_LENGTH('regression_module_header', 'process_exec_order') IS NULL
BEGIN
	ALTER TABLE regression_module_header ADD process_exec_order INT DEFAULT NULL
	PRINT 'Column added' 
END
