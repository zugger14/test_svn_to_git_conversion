IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10211200)
BEGIN
 	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10211200, 'Maintain Contract', 'Maintain Contract', 10210000, 'windowMaintainContract')
 	PRINT ' Inserted 10211200 - Maintain Contract.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10211200 - Maintain Contract already EXISTS.'
END
