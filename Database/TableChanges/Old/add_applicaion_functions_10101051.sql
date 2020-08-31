IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10101051)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10101051, 'Container', 'Container', 10101000, 'windowMaintainStaticData')
 	PRINT ' Inserted 10101051 - Container.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10101051 - Container already EXISTS.'
END