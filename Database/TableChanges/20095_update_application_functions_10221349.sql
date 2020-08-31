IF NOT EXISTS(SELECT * FROM application_functions WHERE function_id = 10221349)
BEGIN
	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, file_path, function_parameter, module_type, book_required)
	VALUES (10221349, 'Post', 'Post SAP Export', 10202201, '', NULL, NULL, 0)
	PRINT ' Inserted 10221349 - Post.'
END
ELSE
BEGIN
	UPDATE application_functions
	SET func_ref_id = 10202201,
		function_name = 'Post'
	WHERE function_id = 10221349
	PRINT ' Updated 10221349 - Post.'
END