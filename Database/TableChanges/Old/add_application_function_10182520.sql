IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10182520)
BEGIN
 	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10182520, 'Delet Manintain Whate-if scenario Deal', 'Delet Manintain Whate-if scenario Deal', 10182510, NULL)
 	PRINT ' Inserted 10182520 - Delet Manintain Whate-if scenario Deal.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10182520 - Delet Manintain Whate-if scenario Deal already EXISTS.'
END