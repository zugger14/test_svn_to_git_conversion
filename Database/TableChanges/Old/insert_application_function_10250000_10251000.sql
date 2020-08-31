IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10250000)
BEGIN
 	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10250000, 'Message Board', 'Message Board', 10000000, NULL)
 	PRINT ' Inserted 10250000 - Message Board.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10250000 - Message Board already EXISTS.'
END


IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10251000)
BEGIN
 	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10251000, 'Send Message', 'Send Message', 10250000, 'windowSendMessage')
 	PRINT ' Inserted 10251000 - Send Message.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10251000 - Send Message already EXISTS.'
END
