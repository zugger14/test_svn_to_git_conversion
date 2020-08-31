IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10235700)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10235700, 'Run Fair Value Disclosure Report', 'Run Fair Value Disclosure Report', 10230000, 'windowRunnetAssetsReport')
 	PRINT ' Inserted 10235700 - Run Fair Value Disclosure Report.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10235700 - Run Fair Value Disclosure Report already EXISTS.'
END

UPDATE application_functions SET function_name = 'Fair Value Disclosure Report', function_desc = 'Fair Value Disclosure Report' WHERE function_id = 10235700
UPDATE my_report SET my_report_name = 'Fair Value Disclosure Report' ,tooltip= 'Fair Value Disclosure Report' WHERE my_report.application_function_id = 10235700
