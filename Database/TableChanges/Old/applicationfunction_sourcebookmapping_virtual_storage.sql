IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10103100)
BEGIN
    INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
    VALUES (10103100, 'Insert Source Book Mapping', 'Insert Source Book Mapping', 10100000, 'windowInsertSourceBookMappingIU')
    PRINT '10103100 INSERTED.'
END
ELSE
BEGIN
    PRINT '10103100 ALREADY EXISTS.'
END