--Insert into application_functions
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 20013003)
BEGIN
    INSERT INTO application_functions (function_id, function_name, function_desc, func_ref_id, document_path, file_path, book_required)
    VALUES (20013003, 'Filter Term Mapping', 'Filter Term Mapping', 20013000, NULL, NULL, 0)
    PRINT ' Inserted 20013003 - Filter Term Mapping.'
END
ELSE
BEGIN
    PRINT 'Application FunctionID 20013003 - Filter Term Mapping already EXISTS.'
END