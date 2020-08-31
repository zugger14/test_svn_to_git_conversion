IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10103610)
BEGIN
 	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10103610, 'Delete Remove Report', 'Delete Remove Report', 10103600, NULL)
 	PRINT ' Inserted 10103610 - Delete Remove Report.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10103610 - Delete Remove Report already EXISTS.'
END
