IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10122517)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10122517, 'Maintain Alerts Action', 'Maintain Alerts Action', 10122500, '')
 	PRINT ' Inserted 10122517 - Maintain Alerts Action.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10122517 - Maintain Alerts Action already EXISTS.'
END