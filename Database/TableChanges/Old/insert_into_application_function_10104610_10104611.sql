IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10104610)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10104610, 'Add/Save', 'Add/Save', 10104600, NULL)
 	PRINT ' Inserted 10104610 - Add/Save.'
END
ELSE
BEGIN
	UPDATE application_functions 
	 SET function_name = 'Add/Save',
		function_desc = 'Add/Save',
		func_ref_id = 10104600,
		function_call = NULL
		 WHERE [function_id] = 10104610
		PRINT 'Updated Application Function '
END

GO

IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10104611)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10104611, 'Delete', 'Delete', 10104600, NULL)
 	PRINT ' Inserted 10104611 - Delete.'
END
ELSE
BEGIN
	UPDATE application_functions 
	 SET function_name = 'Delete',
		function_desc = 'Delete',
		func_ref_id = 10104600,
		function_call = NULL
		 WHERE [function_id] = 10104611
		 
	PRINT 'Updated Application Function '
END