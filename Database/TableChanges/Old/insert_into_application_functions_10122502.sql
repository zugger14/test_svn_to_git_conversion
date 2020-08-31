IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10122502)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10122502, 'Maintain Alerts Conditions Delete', 'Maintain Alerts Conditions Delete', 10122519, '')
 	PRINT ' Inserted 10122502 - Maintain Alerts Conditions Delete.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10122502 - Maintain Alerts Conditions Delete already EXISTS.'
END