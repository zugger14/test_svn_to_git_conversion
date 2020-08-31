--Insert into application_functions
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10101025)
BEGIN
	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, file_path, function_parameter, module_type, book_required)
	VALUES (10101025, 'Certification Systems', 'Certification Systems', NULL, '', NULL, NULL, 0)
	PRINT ' Inserted 10101025 - Certification Systems.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10101025 - Certification Systems already EXISTS.'
END

                    