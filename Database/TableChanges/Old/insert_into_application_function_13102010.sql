IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 13102010)
BEGIN
 	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (13102010, 'Generic Mapping IU', 'Generic Mapping IU', 13102000, NULL)
 	PRINT ' Inserted 13102010 - Generic Mapping IU.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 13102010 - Generic Mapping IU already EXISTS.'
END	
--UPDATE application_functions 
--	 SET function_name = 'Generic Mapping IU',
--		function_desc = 'Generic Mapping IU',
--		func_ref_id = 13102000,
--		function_call = NULL
--		 WHERE [function_id] = 13102010
--PRINT 'Updated Application Function '
