IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10221316)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10221316, 'Maintain Invoice Detail', 'Maintain Invoice Detail', 10221312, NULL)
 	PRINT ' Inserted 10221316 - Maintain Invoice Detail.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10221316 - Maintain Invoice Detail already EXISTS.'
END