IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10101060)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call, document_path)
	VALUES (10101060, 'Quality', 'Quality', 10101000, '', '')
 	PRINT ' Inserted 10101060 - Quality.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10101060 - already EXISTS.'
END

--10101060


