IF EXISTS(SELECT 1 FROM application_functional_users WHERE function_id = 10182510 AND functional_users_id IN (20980, 19588, 20312))
	DELETE FROM application_functional_users WHERE function_id = 10182510 AND functional_users_id IN (20980, 19588, 20312)

IF EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10182510 AND func_ref_id =10182600)
	DELETE FROM application_functions WHERE function_id = 10182510 AND func_ref_id =10182600

IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10182610)
BEGIN
 	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10182610, 'Show Plot', 'Show Plot', 10182600, 'windowShowPlot')
 	PRINT ' Inserted 10182610 - Show Plot.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10182610 - Show Plot already EXISTS.'
END
