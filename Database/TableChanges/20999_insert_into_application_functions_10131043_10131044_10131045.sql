--Insert into application_functions
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10131043)
BEGIN
	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, file_path, function_parameter, module_type, book_required)
	VALUES (10131043, 'REC Product', 'REC Product', 10131000, '', NULL, NULL, 0)
	PRINT ' Inserted 10131043 - REC Product.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10131043 - REC Product already EXISTS.'
END

--Insert into application_functions
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10131044)
BEGIN
	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, file_path, function_parameter, module_type, book_required)
	VALUES (10131044, 'Add/Save', 'Add/Save', 10131043, '', NULL, NULL, 0)
	PRINT ' Inserted 10131044 - Add/Save.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10131044 - Add/Save already EXISTS.'
END

--Insert into application_functions
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10131045)
BEGIN
	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, file_path, function_parameter, module_type, book_required)
	VALUES (10131045, 'Delete', 'Delete', 10131043, '', NULL, NULL, 0)
	PRINT ' Inserted 10131045 - Delete.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10131045 - Delete already EXISTS.'
END

                                        
                    
                    