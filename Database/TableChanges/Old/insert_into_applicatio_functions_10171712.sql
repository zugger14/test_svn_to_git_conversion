IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10171712)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10171712, 'Send Invoice Detail', 'Send Invoice Detail', 10171700, '')
 	PRINT ' Inserted 10171712 - Send Invoice Detail.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10171712 - Send Invoice Detail already EXISTS.'
END