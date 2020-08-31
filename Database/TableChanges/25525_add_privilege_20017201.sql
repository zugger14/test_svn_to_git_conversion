--Insert into application_functions
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 20017201)
BEGIN
    INSERT INTO application_functions (function_id, function_name, function_desc, func_ref_id, document_path, file_path, book_required)
    VALUES (20017201, 'Add/Save', 'Add/Save', 20017200, NULL, NULL, 0)
    PRINT ' Inserted 20017201 - .'
END
ELSE
BEGIN
    PRINT 'Application FunctionID 20017201 -  already EXISTS.'
END