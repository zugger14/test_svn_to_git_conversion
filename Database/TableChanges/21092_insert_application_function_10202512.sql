--Insert into application_functions
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10202512)
BEGIN
	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, file_path, function_parameter, module_type, book_required)
	VALUES (10202512, 'Power BI Process', 'Power BI Process', 10202500, '', NULL, NULL, 0)
	PRINT ' Inserted 10202512 - Power BI Process.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10202512 - Power BI Process already EXISTS.'
END

                    