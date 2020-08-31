IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10122519)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10122519, 'Maintain Alerts Conditions', 'Maintain Alerts Conditions', 10122500, '')
 	PRINT ' Inserted 10122519 - Maintain Alerts Conditions.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10122519 - Maintain Alerts Conditions already EXISTS.'
END