--Insert into application_functions
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 20011401)
BEGIN
    INSERT INTO application_functions (function_id, function_name, function_desc, func_ref_id, document_path, file_path, book_required)
    VALUES (20011401, 'Add/Save', 'Add/Save', 20011400, NULL, NULL, 0)
    PRINT ' Inserted 20011401 - .'
END
ELSE
BEGIN
    PRINT 'Application FunctionID 20011401 -  already EXISTS.'
END