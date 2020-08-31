IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10122501)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10122501, 'Maintain Alerts Conditions IU', 'Maintain Alerts Conditions IU', 10122519, '')
 	PRINT ' Inserted 10122501 - Maintain Alerts Conditions IU.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10122501 - Maintain Alerts Conditions IU already EXISTS.'
END