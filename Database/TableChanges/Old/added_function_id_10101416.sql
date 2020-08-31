IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10101416)
BEGIN
 	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10101416, 'Privilege Deal Template', 'Privilege Deal Template', 10101400, 'windowDealTemplatePrivilages')
 	PRINT ' Inserted 10101416 - Privilege Deal Template.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10101416 - Privilege Deal Template already EXISTS.'
END
