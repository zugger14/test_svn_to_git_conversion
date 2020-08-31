IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10237010)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10237010, 'Maintain Manual Journal Entries IU', 'Maintain Manual Journal Entries IU', 10237000, NULL)
 	PRINT ' Inserted 10237010 - Maintain Manual Journal Entries IU.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10237010 - Maintain Manual Journal Entries IU already EXISTS.'
END