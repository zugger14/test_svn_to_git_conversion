--Insert into application_functions
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 20017302)
BEGIN
    INSERT INTO application_functions (function_id, function_name, function_desc, func_ref_id, document_path, file_path, book_required)
    VALUES (20017302, 'Delete', 'Delete', 20017300, NULL, NULL, 0)
    PRINT ' Inserted 20017302 - .'
END
ELSE
BEGIN
    PRINT 'Application FunctionID 20017302 -  already EXISTS.'
END