IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10101033)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10101033, 'REC Requirement Detail Delete', 'REC Requirement Detail Delete', 10101017, NULL)
 	PRINT ' Inserted 10101033 - REC Requirement Detail Delete.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10101033 - REC Requirement Detail Delete already EXISTS.'
END