--Insert into application_functions
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 20009001)
BEGIN
    INSERT INTO application_functions (function_id, function_name, function_desc, func_ref_id, document_path, file_path, book_required)
    VALUES (20009001, 'Add/Save', 'Add/Save', 20009000, NULL, NULL, 0)
    PRINT ' Inserted 20009001 - .'
END
ELSE
BEGIN
    PRINT 'Application FunctionID 20009001 -  already EXISTS.'
END

--Insert into application_functions
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 20009002)
BEGIN
    INSERT INTO application_functions (function_id, function_name, function_desc, func_ref_id, document_path, file_path, book_required)
    VALUES (20009002, 'Delete', 'Delete', 20009000, NULL, NULL, 0)
    PRINT ' Inserted 20009002 - .'
END
ELSE
BEGIN
    PRINT 'Application FunctionID 20009002 -  already EXISTS.'
END

--Insert into application_functions
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 20009003)
BEGIN
    INSERT INTO application_functions (function_id, function_name, function_desc, func_ref_id, document_path, file_path, book_required)
    VALUES (20009003, 'Charge Type', 'Charge Type', 20009000, NULL, NULL, 0)
    PRINT ' Inserted 20009003 - .'
END
ELSE
BEGIN
    PRINT 'Application FunctionID 20009003 -  already EXISTS.'
END

--Insert into application_functions
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 20009004)
BEGIN
    INSERT INTO application_functions (function_id, function_name, function_desc, func_ref_id, document_path, file_path, book_required)
    VALUES (20009004, 'Add/Save', 'Add/Save', 20009003, NULL, NULL, 0)
    PRINT ' Inserted 20009004 - .'
END
ELSE
BEGIN
    PRINT 'Application FunctionID 20009004 -  already EXISTS.'
END

--Insert into application_functions
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 20009005)
BEGIN
    INSERT INTO application_functions (function_id, function_name, function_desc, func_ref_id, document_path, file_path, book_required)
    VALUES (20009005, 'Delete', 'Delete', 20009003, NULL, NULL, 0)
    PRINT ' Inserted 20009005 - .'
END
ELSE
BEGIN
    PRINT 'Application FunctionID 20009005 -  already EXISTS.'
END      