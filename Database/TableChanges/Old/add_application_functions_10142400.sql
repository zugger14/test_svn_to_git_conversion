IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10142400)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10142400, 'Derivative Position Report', 'Derivative Position Report', 10140000, 'windowDerivativePositionReport')
 	PRINT ' Inserted 10142400 - Derivative Position Report.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10142400 - Derivative Position Report already EXISTS.'
END