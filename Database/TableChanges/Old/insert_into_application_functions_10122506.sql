IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10122506)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10122506, 'Maintain Alerts Users', 'Maintain Alerts Users', 10122500, '')
 	PRINT ' Inserted 10122506 - Maintain Alerts Users.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10122506 - Maintain Alerts Users already EXISTS.'
END