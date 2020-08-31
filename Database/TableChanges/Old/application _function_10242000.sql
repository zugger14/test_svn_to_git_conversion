IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10242000)
BEGIN
 	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10242000, 'View De-designation Criteria', 'View De-designation Criteria', 13140000, NULL)
 	PRINT ' Inserted 10242000 - View De-designation Criteria.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10242000 - View De-designation Criteria already EXISTS.'
END
