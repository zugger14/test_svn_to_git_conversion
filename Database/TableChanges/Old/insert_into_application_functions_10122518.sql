IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10122518)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10122518, 'Maintain Alerts Table Relation', 'Maintain Alerts Table Relation', 10122500, '')
 	PRINT ' Inserted 10122518 - Maintain Alerts Table Relation.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10122518 - Maintain Alerts Table Relation already EXISTS.'
END