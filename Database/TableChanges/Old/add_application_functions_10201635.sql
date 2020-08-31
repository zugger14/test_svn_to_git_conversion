IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10201635)
BEGIN
 	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10201635, 'Report Manager Writer Copy', 'Report Manager Writer Copy', 10201600, NULL)
 	PRINT ' Inserted 10201635 - Report Manager Writer Copy.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10201635 - Report Manager Writer Copy already EXISTS.'
END
