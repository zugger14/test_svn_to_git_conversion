IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10162312)
BEGIN
 	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10162312, 'Insert Source Book Mapping', 'Insert Source Book Mapping', 10162310, NULL)
 	PRINT ' Inserted 10162312 - Insert Source Book Mapping.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10162312 - Insert Source Book Mapping already EXISTS.'
END