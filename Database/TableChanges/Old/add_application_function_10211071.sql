IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10211071)
BEGIN
 	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10211071, 'CurveM', 'CurveM', 10211017, 'windowMPrice')
 	PRINT ' Inserted 10211071 - CurveM.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10211071 - CurveM already EXISTS.'
END
