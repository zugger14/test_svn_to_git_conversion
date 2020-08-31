--Insert into application_functions
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 20002301)
BEGIN
	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, file_path, function_parameter, module_type, book_required)
	VALUES (20002301, 'Add/Save', 'Add/Save', 20002300, '', NULL, NULL, 0)
	PRINT ' Inserted 20002301 - Add/Save.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 20002301 - Add/Save already EXISTS.'
END

             
--Update application_functions
UPDATE application_functions
	SET function_name = 'Add/Save',
		function_desc = 'Add/Save',
		func_ref_id = 20002300,
		file_path = '',
		function_parameter = NULL,
		module_type = NULL,
		book_required = 0
		WHERE [function_id] = 20002301
PRINT 'Updated Application Function.'

                    