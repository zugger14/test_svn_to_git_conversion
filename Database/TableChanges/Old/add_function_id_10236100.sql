IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10236100)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10236100, 'Missing Assessment Values Report', 'Missing Assessment Values Report', 10230000, 'windowRunMissingAssessmentValuesReport')
 	PRINT ' Inserted 10236100 - Missing Assessment Values Report.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10236100 - Missing Assessment Values Report already EXISTS.'
END
