IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10231100)
BEGIN
 	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10231100, 'Accrual JE Report', 'Accrual JE Report', 10230000, NULL)
 	PRINT ' Inserted 10231100 - Accrual JE Report.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10231100 - Accrual JE Report.'
END
