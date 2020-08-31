IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 13151000)
BEGIN
 	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (13151000, 'Run Calc Dynamic Limit', 'Run Calc Dynamic Limit', 13150000, NULL)
 	PRINT ' Inserted 13151000 - Run Calc Dynamic Limit.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 13151000 - Run Calc Dynamic Limit already EXISTS.'
END
