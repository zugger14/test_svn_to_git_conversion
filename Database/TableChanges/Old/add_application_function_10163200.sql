IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10163200)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10163200, 'Dashboard Manager', 'Dashboard Manager', 10160000, 'windowDashboardManager')
 	PRINT ' Inserted 10163200 - Dashboard Manager.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10163200 - Dashboard Manager already EXISTS.'
END
