IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 12121500)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call, file_path)
	VALUES (12121500, 'Lifecycle of Transactions', 'Lifecycle of Transactions', 10202200, '', '')
 	PRINT ' Inserted 12121500 - 12121500.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 12121500 - 12121500 already EXISTS.'
END