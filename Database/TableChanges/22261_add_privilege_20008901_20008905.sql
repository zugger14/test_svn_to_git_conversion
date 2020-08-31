--Insert into application_functions
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 20008901)
BEGIN
    INSERT INTO application_functions (function_id, function_name, function_desc, func_ref_id, document_path, file_path, book_required)
    VALUES (20008901, 'Add/Save', 'Add/Save', 20008900, NULL, NULL, 0)
    PRINT ' Inserted 20008901 - .'
END
ELSE
BEGIN
    PRINT 'Application FunctionID 20008901 -  already EXISTS.'
END

--Insert into application_functions
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 20008902)
BEGIN
    INSERT INTO application_functions (function_id, function_name, function_desc, func_ref_id, document_path, file_path, book_required)
    VALUES (20008902, 'Delete', 'Delete', 20008900, NULL, NULL, 0)
    PRINT ' Inserted 20008902 - .'
END
ELSE
BEGIN
    PRINT 'Application FunctionID 20008902 -  already EXISTS.'
END        

--Insert into application_functions
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 20008903)
BEGIN
    INSERT INTO application_functions (function_id, function_name, function_desc, func_ref_id, document_path, file_path, book_required)
    VALUES (20008903, 'Charge Type', 'Charge Type', 20008900, NULL, NULL, 0)
    PRINT ' Inserted 20008903 - .'
END
ELSE
BEGIN
    PRINT 'Application FunctionID 20008903 -  already EXISTS.'
END            

--Insert into application_functions
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 20008904)
BEGIN
    INSERT INTO application_functions (function_id, function_name, function_desc, func_ref_id, document_path, file_path, book_required)
    VALUES (20008904, 'Add/Save', 'Add/Save', 20008903, NULL, NULL, 0)
    PRINT ' Inserted 20008904 - .'
END
ELSE
BEGIN
    PRINT 'Application FunctionID 20008904 -  already EXISTS.'
END            

--Insert into application_functions
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 20008905)
BEGIN
    INSERT INTO application_functions (function_id, function_name, function_desc, func_ref_id, document_path, file_path, book_required)
    VALUES (20008905, 'Delete', 'Delete', 20008903, NULL, NULL, 0)
    PRINT ' Inserted 20008905 - .'
END
ELSE
BEGIN
    PRINT 'Application FunctionID 20008905 -  already EXISTS.'
END            