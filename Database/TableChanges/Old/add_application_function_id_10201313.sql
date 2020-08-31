IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10201313)
BEGIN
 	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10201313, 'Maintain EoD Log Status Run', 'Maintain EoD Log Status Run', 10200000, '')
 	PRINT ' Inserted 10201313 - Maintain EoD Log Status Run.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10201313 - Maintain EoD Log Status Run already EXISTS.'
END
