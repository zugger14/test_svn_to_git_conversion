IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10131027)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10131027, 'Undo Deal Delete', 'Undo Deal Delete', 10131000, 'windowUndoDealDelete')
 	PRINT ' Inserted 10131027 - Undo Deal Delete.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10131027 - Undo Deal Delete already EXISTS.'
END
