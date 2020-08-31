--Insert into application_functions
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10105904)
BEGIN
	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, file_path, function_parameter, module_type, book_required)
	VALUES (10105904, 'Contract Product', 'Contract Product', 10105800, '', NULL, NULL, 0)
	PRINT ' Inserted 10105904 - Contract Product.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10105904 - Contract Product already EXISTS.'
END

                    