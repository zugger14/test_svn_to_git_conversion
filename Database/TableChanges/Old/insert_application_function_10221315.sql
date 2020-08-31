--Insert into application_functions
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10221315)
BEGIN
	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, file_path, function_parameter, module_type, book_required)
	VALUES (10221315, 'Finalize', 'invoice finalize privilege', 10221300, '', NULL, NULL, 0)
	PRINT ' Inserted 10221315 - Finalize.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10221315 - Finalize already EXISTS.'
END


