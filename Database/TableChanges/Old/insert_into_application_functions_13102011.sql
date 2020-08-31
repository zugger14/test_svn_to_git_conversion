IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 13102011)
BEGIN
 	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (13102011, 'Generic Mapping Delete', 'Generic Mapping Delete', 13102000, NULL)
 	PRINT ' Inserted 13102011 - Generic Mapping Delete.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 13102011 - Generic Mapping Delete already EXISTS.'
END	

--UPDATE application_functions 
--	 SET function_name = 'Generic Mapping Delete',
--		function_desc = 'Generic Mapping Delete',
--		func_ref_id = 13102000,
--		function_call = NULL
--		 WHERE [function_id] = 13102011
--PRINT 'Updated Application Function '
