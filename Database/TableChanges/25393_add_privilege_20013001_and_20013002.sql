--Insert into application_functions
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 20013001)
BEGIN
    INSERT INTO application_functions (function_id, function_name, function_desc, func_ref_id, document_path, file_path, book_required)
    VALUES (20013001, 'Add/Save', 'Add/Save', 20013000, NULL, NULL, 0)
    PRINT ' Inserted 20013001 - .'
END
ELSE
BEGIN
    PRINT 'Application FunctionID 20013001 -  already EXISTS.'
END

--Insert into application_functions
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 20013002)
BEGIN
    INSERT INTO application_functions (function_id, function_name, function_desc, func_ref_id, document_path, file_path, book_required)
    VALUES (20013002, 'Delete', 'Delete', 20013000, NULL, NULL, 0)
    PRINT ' Inserted 20013002 - .'
END
ELSE
BEGIN
    PRINT 'Application FunctionID 20013002 -  already EXISTS.'
END