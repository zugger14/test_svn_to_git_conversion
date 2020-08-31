IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10101032)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10101032, 'REC Requirement Detail IU', 'REC Requirement Detail IU', 10101017, NULL)
 	PRINT ' Inserted 10101032 - REC Requirement Detail IU.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10101032 - REC Requirement Detail IU already EXISTS.'
END