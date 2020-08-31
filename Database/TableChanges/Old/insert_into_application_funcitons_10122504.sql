IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10122504)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10122504, 'Maintain Alerts Report', 'Maintain Alerts Report', 10122500, '')
 	PRINT ' Inserted 10122504 - Maintain Alerts Report.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10122504 - Maintain Alerts Report already EXISTS.'
END