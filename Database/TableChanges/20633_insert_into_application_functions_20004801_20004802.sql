--Insert into application_functions
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 20004801)
BEGIN
	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, file_path, function_parameter, module_type, book_required)
	VALUES (20004801, 'Add/Save', 'Add/Save', 20004800, '', NULL, NULL, 0)
	PRINT ' Inserted 20004801 - Add/Save.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 20004801 - Add/Save already EXISTS.'
END

--Insert into application_functions
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 20004802)
BEGIN
	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, file_path, function_parameter, module_type, book_required)
	VALUES (20004802, 'Delete', 'Delete', 20004800, '', NULL, NULL, 0)
	PRINT ' Inserted 20004802 - Delete.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 20004802 - Delete already EXISTS.'
END

                    