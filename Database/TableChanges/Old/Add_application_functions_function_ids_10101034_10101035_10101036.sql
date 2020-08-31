IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10101034)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10101034, 'Block Type Group', 'Block Type Group', 10101000, 'windowBlockTypeGroup')
 	PRINT ' Inserted 10101034 - Block Type Group.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10101034 - Block Type Group already EXISTS.'
END

IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10101035)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10101035, 'Block Group Type Detail', 'Block Group Type Detail', 10101034, 'windowBlockTypeGroupIU')
 	PRINT ' Inserted 10101035 - Block Group Type Detail.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10101035 - Block Group Type Detail already EXISTS.'
END

IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10101036)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10101036, 'Block Type Group Delete', 'Block Type Group Delete', 10101034, NULL)
 	PRINT ' Inserted 10101036 - Block Type Group Delete.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10101036 - Block Type Group Delete already EXISTS.'
END
