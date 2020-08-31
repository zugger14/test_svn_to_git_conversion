IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10211022)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10211022, 'Contract Group Detail UI', 'Contract Group Detail UI', 10211200, 'windowContractGroupDetailUI')
 	PRINT ' Inserted 10211022 - Contract Group Detail UI.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10211022 - Contract Group Detail UI already EXISTS.'
END

IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10211023)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10211023, 'Contract GL Code', 'Contract GL Code', 10211000, 'windowContractGLCode')
 	PRINT ' Inserted 10211023 - Contract GL Code.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10211023 - Contract GL Code already EXISTS.'
END

