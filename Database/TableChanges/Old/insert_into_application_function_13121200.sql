IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 13121200)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (13121200, 'Run Hedge Ineffectiveness Report', 'Run Hedge Ineffectiveness Report', 10202200, 'windowRunHedgeIneffectivenessReport')
 	PRINT ' Inserted 13121200 - Run Hedge Ineffectiveness Report.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 13121200 - Run Hedge Ineffectiveness Report already EXISTS.'
END
