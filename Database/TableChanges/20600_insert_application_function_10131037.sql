--Insert into application_functions
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10131037)
BEGIN
	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, file_path, function_parameter, module_type, book_required)
	VALUES (10131037, 'Void Deal', 'Voided Deal', 10131000, '', NULL, NULL, 0)
	PRINT ' Inserted 10131037 - Void Deal.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10131037 - Void Deal already EXISTS.'
END

--Update application_functions
UPDATE application_functions
	SET function_name = 'Void Deal',
		function_desc = 'Voided Deal',
		func_ref_id = 10131000,
		file_path = '',
		function_parameter = NULL,
		module_type = NULL,
		book_required = 0
		WHERE [function_id] = 10131037
PRINT 'Updated Application Function.'