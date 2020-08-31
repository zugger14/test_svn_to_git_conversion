IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10241110)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10241110, 'Apply cash IU', 'Apply cash IU', 10241100, NULL)
 	PRINT ' Inserted 10241110 - Apply cash IU.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10241110 - Apply cash IU already EXISTS.'
END

IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10241111)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10241111, 'Apply Cash Delete', 'Apply Cash Delete', 10241100, NULL)
 	PRINT ' Inserted 10241111 - Apply Cash Delete.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10241111 - Apply Cash Delete already EXISTS.'
END

IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10241112)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10241112, 'Apply Cash Save', 'Apply Cash Save', 10241100, NULL)
 	PRINT ' Inserted 10241112 - Apply Cash Save.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10241112 - Apply Cash Save already EXISTS.'
END