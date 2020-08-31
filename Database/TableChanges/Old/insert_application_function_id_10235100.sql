IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10235100)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10235100, 'Run Period Change Values Report', 'Run Period Change Values Report', 10230000, 'windowPeriodChangeValueReport')
 	PRINT ' Inserted 10235100 - Run Period Change Values Report.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10235100 - Run Period Change Values Report already EXISTS.'
END

UPDATE application_functions SET function_name = 'Period Change Values Report', function_desc = 'Period Change Values Report' WHERE function_id = 10235100
UPDATE my_report SET my_report_name = 'Period Change Values Report' ,tooltip= 'Period Change Values Report' WHERE my_report.application_function_id = 10235100
