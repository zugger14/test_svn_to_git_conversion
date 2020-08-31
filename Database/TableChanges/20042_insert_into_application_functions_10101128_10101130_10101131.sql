IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10101128)
BEGIN
	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, file_path, function_parameter, module_type, book_required)
	VALUES (10101128, 'Limit', 'Limit Tab', 10101122, '', NULL, NULL, 0)
	PRINT ' Inserted 10101128 - Limit.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10101128 - Limit already EXISTS.'
END
GO

IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10101130)
BEGIN
	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, file_path, function_parameter, module_type, book_required)
	VALUES (10101130, 'Add/Save', 'Add/Save', 10101128, '', NULL, NULL, 0)
	PRINT ' Inserted 10101130 - Add/Save.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10101130 - Add/Save already EXISTS.'
END
GO

IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10101131)
BEGIN
	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, file_path, function_parameter, module_type, book_required)
	VALUES (10101131, 'Delete', 'Delete Limit', 10101128, '', NULL, NULL, 0)
	PRINT ' Inserted 10101131 - Delete.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10101131 - Delete already EXISTS.'
END
GO