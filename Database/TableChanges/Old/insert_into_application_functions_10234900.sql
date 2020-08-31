IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10234900)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10234900, 'Measurement Report', 'Measurement Report', 10230000, 'windowMeasurementReport')
 	PRINT ' Inserted 10234900 - Measurement Report.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10234900 - Measurement Report already EXISTS.'
END