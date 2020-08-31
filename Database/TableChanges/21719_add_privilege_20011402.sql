--Insert into application_functions
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 20011402)
BEGIN
    INSERT INTO application_functions (function_id, function_name, function_desc, func_ref_id, document_path, file_path, book_required)
    VALUES (20011402, 'Delete', 'Delete', 20011400, NULL, NULL, 0)
    PRINT ' Inserted 20011402 - .'
END
ELSE
BEGIN
    PRINT 'Application FunctionID 20011402 -  already EXISTS.'
END