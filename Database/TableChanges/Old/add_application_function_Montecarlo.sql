IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10183210)
BEGIN
 	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10183210, 'Insert PortFolio Groups', 'Insert PortFolio Groups', 10183200, 'windowRunInsertPortFolioGroups')
 	PRINT ' Inserted 10183210 - Insert PortFolio Groups.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10183210 - Insert PortFolio Groups already EXISTS.'
END
