--Insert into application_functions
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 20012211)
BEGIN
    INSERT INTO application_functions (function_id, function_name, function_desc, func_ref_id, document_path, file_path, book_required)
    VALUES (20012211, 'Finalize All', 'Finalize All', 20012200, NULL, NULL, 0)
    PRINT ' Inserted 20012211 - .'
END
ELSE
BEGIN
    PRINT 'Application FunctionID 20012211 -  already EXISTS.'
END