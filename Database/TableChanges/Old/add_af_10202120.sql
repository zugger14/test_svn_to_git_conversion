
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10202120)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call, file_path)
	VALUES (10202120, 'NorthPool Position Report', 'NorthPool Position Report', 10202100, NULL, NULL)
 	PRINT ' Inserted 10202120 - Ticket.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10202120 - Ticket already EXISTS.'
END



