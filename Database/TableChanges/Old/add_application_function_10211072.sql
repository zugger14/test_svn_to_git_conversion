IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10211072)
BEGIN
 	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10211072, 'RelativeCurveD', 'RelativeCurveD', 10211017, 'windowRelativeCurveD')
 	PRINT ' Inserted 10211072 - RelativeCurveD.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10211072 - RelativeCurveD already EXISTS.'
END
