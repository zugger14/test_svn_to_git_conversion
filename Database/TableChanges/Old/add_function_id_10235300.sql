IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10235300)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10235300, 'Run De-Designation Values Report', 'Run De-Designation Values Report', 10230000, 'windowDedesignateReport')
 	PRINT ' Inserted 10235300 - Run De-Designation Values Report.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10235300 - Run De-Designation Values Report already EXISTS.'
END

UPDATE application_functions SET function_name = 'De-Designation Values Report', function_desc = 'De-Designation Values Report' WHERE function_id = 10235300