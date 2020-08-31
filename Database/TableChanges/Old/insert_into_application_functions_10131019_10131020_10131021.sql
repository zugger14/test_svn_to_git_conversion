IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10131019)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10131019, 'Update Deal Volume', 'Update Deal Volume', 10131018, NULL)
 	PRINT ' Inserted 10131019 - Update Deal Volume.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10131019 - Update Deal Volume already EXISTS.'
END

IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10131020)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10131020, 'Update Schedule Volume', 'Update Schedule Volume', 10131018, NULL)
 	PRINT ' Inserted 10131020 - Update Schedule Volume.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10131020 - Update Schedule Volume already EXISTS.'
END

IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10131021)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10131021, 'Update Actual Volume', 'Update Actual Volume', 10131018, NULL)
 	PRINT ' Inserted 10131021 - Update Actual Volume.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10131021 - Update Actual Volume already EXISTS.'
END
