IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10171016)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10171016, 'Generate Confirm Confirm Transactions', 'Generate Confirm Confirm Transactions', 10171000, 'windowConfirmGenerate')
 	PRINT ' Inserted 10171016 - Generate Confirm Confirm Transactions.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10171016 - Generate Confirm Confirm Transactions already EXISTS.'
END