--Insert into application_functions
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 20013702)
BEGIN
    INSERT INTO application_functions (function_id, function_name, function_desc, func_ref_id, document_path, file_path, book_required)
    VALUES (20013702, 'Delete', 'Delete', 20013700, NULL, NULL, 0)
    PRINT ' Inserted 20013702 - .'
END
ELSE
BEGIN
    PRINT 'Application FunctionID 20013702 -  already EXISTS.'
END            