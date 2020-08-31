--Insert into application_functions
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 20001201)
BEGIN
    INSERT INTO application_functions (function_id, function_name, function_desc, func_ref_id, document_path, file_path, book_required)
    VALUES (20001201, 'Add/Save', 'Add/Save', 20001200, NULL, NULL, 0)
    PRINT ' Inserted 20001201 - Add/Save.'
END
ELSE
BEGIN
    PRINT 'Application FunctionID 20001201 -  already EXISTS.'
END

--Insert into application_functions
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 20001202)
BEGIN
    INSERT INTO application_functions (function_id, function_name, function_desc, func_ref_id, document_path, file_path, book_required)
    VALUES (20001202, 'Delete', 'Delete', 20001200, NULL, NULL, 0)
    PRINT ' Inserted 20001202 - Delete.'
END
ELSE
BEGIN
    PRINT 'Application FunctionID 20001202 Delete-  already EXISTS.'
END 

GO           