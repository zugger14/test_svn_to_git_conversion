IF COL_LENGTH('regression_module_detail', 'process_exe_order') IS NULL
BEGIN
	ALTER TABLE regression_module_detail ADD process_exec_order INT
END


