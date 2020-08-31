--Insert into application_functions
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 20002201)
BEGIN
	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, file_path, function_parameter, module_type, book_required)
	VALUES (20002201, 'Add/Save', 'Add/Save', 20002200, '', NULL, NULL, 0)
	PRINT ' Inserted 20002201 - Add/Save.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 20002201 - Add/Save already EXISTS.'
END