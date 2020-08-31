IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10235600)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10235600, 'Run Accounting Disclosure Report', 'Run Accounting Disclosure Report', 10230000, 'windowRunDisclosureReport')
 	PRINT ' Inserted 10235600 - Run Accounting Disclosure Report.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10235600 - Run Accounting Disclosure Report already EXISTS.'
END

UPDATE application_functions SET function_name = 'Accounting Disclosure Report', function_desc = 'Accounting Disclosure Report' WHERE function_id = 10235600
UPDATE my_report SET my_report_name = 'Accounting Disclosure Report' ,tooltip= 'Accounting Disclosure Report' WHERE application_function_id = 10235600