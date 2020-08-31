IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10211093)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10211093, 'New Formula Editor', 'New Formula Editor', 10105600, 'windowNewFormulaEditor')
 	PRINT ' Inserted 10211093 - New Formula Editor.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10211093 - New Formula Editor already EXISTS.'
END

IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10105600)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10105600, 'New Formula Builder', 'New Formula Builder', 10100000, 'windowNewFormulaBuilder')
 	PRINT ' Inserted 10105600 - New Formula Builder.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10105600 - New Formula Builder already EXISTS.'
END

