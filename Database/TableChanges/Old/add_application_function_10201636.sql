IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10201636)
BEGIN
 	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10201636, 'Report Dataset IU Ok', 'Report Dataset Ok', 10201615, NULL)
 	PRINT ' Inserted 10201636 - Report Dataset IU Ok.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10201636 - Report Dataset IU Ok already EXISTS.'
END
