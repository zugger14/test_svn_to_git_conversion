--Insert into application_functions
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 20016501)
BEGIN
    INSERT INTO application_functions (function_id, function_name, function_desc, func_ref_id, document_path, file_path, book_required)
    VALUES (20016501, 'Add/Save', 'Add/Save', 20016500, NULL, NULL, 0)
    PRINT ' Inserted 20016501 - .'
END
ELSE
BEGIN
    PRINT 'Application FunctionID 20016501 -  already EXISTS.'
END  

--Insert into application_functions
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 20016502)
BEGIN
    INSERT INTO application_functions (function_id, function_name, function_desc, func_ref_id, document_path, file_path, book_required)
    VALUES (20016502, 'Delete', 'Delete', 20016500, NULL, NULL, 0)
    PRINT ' Inserted 20016502 - .'
END
ELSE
BEGIN
    PRINT 'Application FunctionID 20016502 -  already EXISTS.'
END                      