
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10132313)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id)
	VALUES (10132313, 'Unlock', 'Unlock', 10132300)
 	PRINT ' Inserted 10106400 - Unlock.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10132313 - Unlock.'
END