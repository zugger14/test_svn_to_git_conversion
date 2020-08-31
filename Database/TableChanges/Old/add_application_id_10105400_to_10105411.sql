IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10105400)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10105400, 'Function Category', 'Function Category', 10100000, 'windowFunctionCategory')
 	PRINT ' Inserted 10105400 - Function Category.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10105400 - Function Category already EXISTS.'
END
GO

IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10105410)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10105410, 'Function Category IU', 'Function Category IU', 10105400, 'windowFunctionCategoryIU')
 	PRINT ' Inserted 10105410 - Function Category IU.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10105410 - Function Category IU already EXISTS.'
END
GO

IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10105411)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10105411, 'Delete Function Category', 'Delete Function Category', 10105400, NULL)
 	PRINT ' Inserted 10105411 - Delete Function Category.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10105411 - Delete Function Category already EXISTS.'
END
