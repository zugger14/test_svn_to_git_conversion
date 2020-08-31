--Insert into application_functions
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 12101728)
BEGIN
    INSERT INTO application_functions (function_id, function_name, function_desc, func_ref_id, document_path, file_path, book_required)
    VALUES (12101728, 'Renewable Source Filter', 'Renewable Source Filter', 12101700, NULL, NULL, 0)
    PRINT ' Inserted 12101728 - .'
END
ELSE
BEGIN
    PRINT 'Application FunctionID 12101728 -  already EXISTS.'
END