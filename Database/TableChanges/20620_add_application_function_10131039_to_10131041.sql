--Insert into application_functions
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10131039)
BEGIN
	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, file_path, function_parameter, module_type, book_required)
	VALUES (10131039, 'REC Certificate', 'REC Certificate', 10131000, '', NULL, NULL, 0)
	PRINT ' Inserted 10131039 - REC Certificate.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10131039 - REC Certificate already EXISTS.'
END

--Insert into application_functions
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10131040)
BEGIN
	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, file_path, function_parameter, module_type, book_required)
	VALUES (10131040, 'Add/Save', 'Add/Save', 10131039, '', NULL, NULL, 0)
	PRINT ' Inserted 10131040 - Add/Save.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10131040 - Add/Save already EXISTS.'
END

--Insert into application_functions
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10131041)
BEGIN
	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, file_path, function_parameter, module_type, book_required)
	VALUES (10131041, 'Delete', 'Delete', 10131039, '', NULL, NULL, 0)
	PRINT ' Inserted 10131041 - Delete.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10131041 - Delete already EXISTS.'
END

                                                         