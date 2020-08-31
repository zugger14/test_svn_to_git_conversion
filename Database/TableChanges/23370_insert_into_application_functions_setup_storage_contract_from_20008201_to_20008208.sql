--Insert into application_functions
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 20008201)
BEGIN
    INSERT INTO application_functions (function_id, function_name, function_desc, func_ref_id, document_path, file_path, book_required)
    VALUES (20008201, 'Add/Save', 'Add/Save', 20008200, NULL, NULL, 0)
    PRINT ' Inserted 20008201 - .'
END
ELSE
BEGIN
    PRINT 'Application FunctionID 20008201 -  already EXISTS.'
END

--Insert into application_functions
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 20008202)
BEGIN
    INSERT INTO application_functions (function_id, function_name, function_desc, func_ref_id, document_path, file_path, book_required)
    VALUES (20008202, 'Delete', 'Delete', 20008200, NULL, NULL, 0)
    PRINT ' Inserted 20008202 - .'
END
ELSE
BEGIN
    PRINT 'Application FunctionID 20008202 -  already EXISTS.'
END     

--Insert into application_functions
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 20008203)
BEGIN
    INSERT INTO application_functions (function_id, function_name, function_desc, func_ref_id, document_path, file_path, book_required)
    VALUES (20008203, 'Maintain Privilege', 'Maintain Privilege', 20008200, NULL, NULL, 0)
    PRINT ' Inserted 20008203 - .'
END
ELSE
BEGIN
    PRINT 'Application FunctionID 20008203 -  already EXISTS.'
END            

--Insert into application_functions
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 20008204)
BEGIN
    INSERT INTO application_functions (function_id, function_name, function_desc, func_ref_id, document_path, file_path, book_required)
    VALUES (20008204, 'Charge Type', 'Charge Type', 20008200, NULL, NULL, 0)
    PRINT ' Inserted 20008204 - .'
END
ELSE
BEGIN
    PRINT 'Application FunctionID 20008204 -  already EXISTS.'
END            

--Insert into application_functions
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 20008205)
BEGIN
    INSERT INTO application_functions (function_id, function_name, function_desc, func_ref_id, document_path, file_path, book_required)
    VALUES (20008205, 'Add/Save', 'Add/Save', 20008204, NULL, NULL, 0)
    PRINT ' Inserted 20008205 - .'
END
ELSE
BEGIN
    PRINT 'Application FunctionID 20008205 -  already EXISTS.'
END            

--Insert into application_functions
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 20008206)
BEGIN
    INSERT INTO application_functions (function_id, function_name, function_desc, func_ref_id, document_path, file_path, book_required)
    VALUES (20008206, 'Delete', 'Delete', 20008204, NULL, NULL, 0)
    PRINT ' Inserted 20008206 - .'
END
ELSE
BEGIN
    PRINT 'Application FunctionID 20008206 -  already EXISTS.'
END            

--Insert into application_functions
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 20008207)
BEGIN
    INSERT INTO application_functions (function_id, function_name, function_desc, func_ref_id, document_path, file_path, book_required)
    VALUES (20008207, 'Map GL Code', 'Map GL Code', 20008204, NULL, NULL, 0)
    PRINT ' Inserted 20008207 - .'
END
ELSE
BEGIN
    PRINT 'Application FunctionID 20008207 -  already EXISTS.'
END            

--Insert into application_functions
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 20008208)
BEGIN
    INSERT INTO application_functions (function_id, function_name, function_desc, func_ref_id, document_path, file_path, book_required)
    VALUES (20008208, 'Formula Add/Save/Delete', 'Formula Add/Save/Delete', 20008204, NULL, NULL, 0)
    PRINT ' Inserted 20008208 - .'
END
ELSE
BEGIN
    PRINT 'Application FunctionID 20008208 -  already EXISTS.'
END            