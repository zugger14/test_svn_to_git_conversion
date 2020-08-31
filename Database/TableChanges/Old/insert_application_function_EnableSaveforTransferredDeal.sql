IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10131214)
BEGIN
 	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10131214, 'Enable Save for Transferred Deals', 'Enable Save for Transferred Deals', 10131200, NULL)
 	PRINT ' Inserted 10131214 - Enable Save for Transferred Deals.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10131214 - Enable Save for Transferred Deals already EXISTS.'
END
