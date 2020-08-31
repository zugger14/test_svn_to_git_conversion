IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10102514)
BEGIN
 	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10102514, 'View Location Detail', 'View Location Detail', 10102500, '')
 	PRINT ' Inserted 10102514 - View Location Detail.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10102514 - View Location Detail already EXISTS.'
END