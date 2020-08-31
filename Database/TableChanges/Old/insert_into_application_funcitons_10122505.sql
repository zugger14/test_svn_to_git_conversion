IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10122505)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10122505, 'Maintain Alerts Workflow', 'Maintain Alerts Workflow', 10122500, '')
 	PRINT ' Inserted 10122505 - Maintain Alerts Workflow.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10122505 - Maintain Alerts Workflow already EXISTS.'
END