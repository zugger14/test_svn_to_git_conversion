IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10235800)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10235800, 'Run Assessment Report', 'Run Assessment Report', 10230000, 'windowRunAssessmentReport')
 	PRINT ' Inserted 10235800 - Run Assessment Report.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10235800 - Run Assessment Report already EXISTS.'
END
