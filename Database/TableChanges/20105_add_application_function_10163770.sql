--Insert into application_functions
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10163770)
BEGIN
	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, file_path, function_parameter, module_type, book_required)
	VALUES (10163770, 'Save', 'Save', 10163700, '', NULL, NULL, 0)
	PRINT ' Inserted 10163770 - Save.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10163770 - Save already EXISTS.'
END

                    