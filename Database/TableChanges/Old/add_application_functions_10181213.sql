IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10181213)
BEGIN
 	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10181213, 'Run', 'Run - Run At Risk Measurement', 10181200, '')
 	PRINT ' Inserted 10181213 - Run - Run At Risk Measurement.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10181213 - Run - Run At Risk Measurement already EXISTS.'
END