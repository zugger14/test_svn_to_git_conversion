--Insert into application_functions
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10233722)
BEGIN
	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, file_path, function_parameter, module_type, book_required)
	VALUES (10233722, 'Deal Match Filter Set 1 in Designation of Hedge', 'Deal Match Filter Set 1 in Designation of Hedge', 10233700, '', NULL, NULL, 0)
	PRINT ' Inserted 10233722 - Deal Match Filter Set 1 in Designation of Hedge.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10233722 - Deal Match Filter Set 1 in Designation of Hedge already EXISTS.'
END

--Insert into application_functions
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10233723)
BEGIN
	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, file_path, function_parameter, module_type, book_required)
	VALUES (10233723, 'Deal Match Filter Set 2 in Designation of Hedge', 'Deal Match Filter Set 2 in Designation of Hedge', 10233700, '', NULL, NULL, 0)
	PRINT ' Inserted 10233723 - Deal Match Filter Set 2 in Designation of Hedge.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10233723 - Deal Match Filter Set 2 in Designation of Hedge already EXISTS.'
END
                                                                         