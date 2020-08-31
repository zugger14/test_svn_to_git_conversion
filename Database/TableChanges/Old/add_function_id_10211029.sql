
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10211029)
BEGIN
 	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10211029, 'Contract Charge Type Copy', 'Contract Charge Type Copy', 10211000, NULL)
 	PRINT ' Inserted 10211028 - Contract Charge Type Copy.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10211029 -Contract Charge Type Copy.'
END
