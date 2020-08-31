IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10183200)
BEGIN
 	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10183200, 'Maintain Portfolio Groups', 'Maintain Portfolio Groups', 10180000, 'windowRunMaintainPortFolioGroups')
 	PRINT ' Inserted 10183200 - Maintain Portfolio Groups.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10183200 - Maintain Portfolio Groups already EXISTS.'
END


