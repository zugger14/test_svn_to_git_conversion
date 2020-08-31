--Insert into application_functions
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 20008301)
BEGIN
    INSERT INTO application_functions (function_id, function_name, function_desc, func_ref_id, document_path, file_path, book_required)
    VALUES (20008301, 'Add/Save', 'Add/Save', 20008300, NULL, NULL, 0)
    PRINT ' Inserted 20008301 - .'
END
ELSE
BEGIN
    PRINT 'Application FunctionID 20008301 -  already EXISTS.'
END            


--Insert into application_functions
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 20008302)
BEGIN
    INSERT INTO application_functions (function_id, function_name, function_desc, func_ref_id, document_path, file_path, book_required)
    VALUES (20008302, 'Delete', 'Delete', 20008300, NULL, NULL, 0)
    PRINT ' Inserted 20008302 - .'
END
ELSE
BEGIN
    PRINT 'Application FunctionID 20008302 -  already EXISTS.'
END            