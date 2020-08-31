IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10131028)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10131028, 'Schedule Deal', 'Schedule Deal', 10131000, 'windowScheduleDeal')
 	PRINT ' Inserted 10131028 - Schedule Deal.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10131028 - Schedule Deal already EXISTS.'
END
