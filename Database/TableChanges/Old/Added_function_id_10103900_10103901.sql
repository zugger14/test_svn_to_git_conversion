IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10103900)
BEGIN
 	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10103900, 'Maintain Fields Templates', 'Maintain Fields Templates', 10100000, '')
 	PRINT ' Inserted 10103900 - Maintain Fields Templates.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10103900 - Maintain Fields Templates already EXISTS.'
END
/*
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10103901)
BEGIN
 	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10103901, 'Maintain Fields Templates Properties', 'Maintain Fields Templates Properties', 10103900, '')
 	PRINT ' Inserted 10103901 - Maintain Fields Templates Properties.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10103901 - Maintain Fields Templates Properties already EXISTS.'
END



UPDATE application_functions 
	 SET function_name = 'Maintain Fields Templates Properties',
		function_desc = 'Maintain Fields Templates Properties',
		func_ref_id = 10103900,
		function_call = 'windowSetupFieldTemplateProperties'
		 WHERE [function_id] = 10103901
PRINT 'Updated Application Function '
*/