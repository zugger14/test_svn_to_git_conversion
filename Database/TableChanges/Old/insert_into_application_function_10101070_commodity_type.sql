IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10101070)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10101070, 'Commodity Type', 'Commodity Type', 10101000, '')
 	PRINT ' Inserted 10101070 - Commodity Type.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10101070 - Commodity Type already EXISTS.'
END

IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10101071)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10101071, 'Commodity Type IU', 'Commodity Type IU', 10101070, '')
 	PRINT ' Inserted 10101071 - Commodity Type IU.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10101071 - Commodity Type IU already EXISTS.'
END

IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10101072)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10101072, 'Commodity Type Delete', 'Commodity Type Delete', 10101070, '')
 	PRINT ' Inserted 10101072 - Commodity Type Delete.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10101072 - Commodity Type Delete already EXISTS.'
END
