IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10122503)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10122503, 'Maintain Alerts Conditions Detail', 'Maintain Alerts Conditions Detail', 10122519, '')
 	PRINT ' Inserted 10122503 - Maintain Alerts Conditions Detail.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10122503 - Maintain Alerts Conditions Detail already EXISTS.'
END