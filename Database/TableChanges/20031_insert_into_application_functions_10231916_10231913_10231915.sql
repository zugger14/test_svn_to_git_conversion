IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10231916)
BEGIN
	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, file_path, function_parameter, module_type, book_required)
	VALUES (10231916, 'Hedges/Items', 'Hedges/Items Tab', 10231900, '', NULL, NULL, 1)
	PRINT ' Inserted 10231916 - Hedges/Items.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10231916 - Hedges/Items already EXISTS.'
END

IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10231913)
BEGIN
	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, file_path, function_parameter, module_type, book_required)
	VALUES (10231913, 'Add/Save', 'Setup Hedge Item Add/Save', 10231916, '', NULL, NULL, 0)
	PRINT ' Inserted 10231913 - Add/Save.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10231913 - Add/Save already EXISTS.'
END

IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10231915)
BEGIN
	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, file_path, function_parameter, module_type, book_required)
	VALUES (10231915, 'Delete', 'Setup Hedge Item Delete', 10231916, '', NULL, NULL, 0)
	PRINT ' Inserted 10231915 - Delete.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10231915 - Delete already EXISTS.'
END