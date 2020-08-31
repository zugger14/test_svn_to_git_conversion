IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10235200)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10235200, 'AOCI Report', 'AOCI Report', 10230000, 'windowAOCIReport')
 	PRINT ' Inserted 10235200 - AOCI Report.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10235200 - AOCI Report already EXISTS.'
END