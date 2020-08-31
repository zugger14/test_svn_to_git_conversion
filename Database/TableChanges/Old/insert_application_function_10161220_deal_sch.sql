IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10161220)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10161220, 'Schedule And Delivery Post Deal Detail', 'Schedule And Delivery Post Deal Detail', 10161200, NULL)
 	PRINT ' Inserted 10161220 - Schedule And Delivery Post Deal Detail.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10161220 - Schedule And Delivery Post Deal Detail already EXISTS.'
END
