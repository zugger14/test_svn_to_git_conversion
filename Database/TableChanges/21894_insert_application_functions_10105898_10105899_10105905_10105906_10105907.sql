--Insert into application_functions
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10105898)
BEGIN
    INSERT INTO application_functions (function_id, function_name, function_desc, func_ref_id, document_path, file_path, book_required)
    VALUES (10105898, 'Netting', 'Netting', 10105800, NULL, NULL, 0)
    PRINT ' Inserted 10105898 - .'
END
ELSE
BEGIN
    PRINT 'Application FunctionID 10105898 -  already EXISTS.'
END            

--Insert into application_functions
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10105899)
BEGIN
    INSERT INTO application_functions (function_id, function_name, function_desc, func_ref_id, document_path, file_path, book_required)
    VALUES (10105899, 'Add/Save', 'Add/Save', 10105898, NULL, NULL, 0)
    PRINT ' Inserted 10105899 - .'
END
ELSE
BEGIN
    PRINT 'Application FunctionID 10105899 -  already EXISTS.'
END            

--Insert into application_functions
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10105905)
BEGIN
    INSERT INTO application_functions (function_id, function_name, function_desc, func_ref_id, document_path, file_path, book_required)
    VALUES (10105905, 'Delete', 'Delete', 10105898, NULL, NULL, 0)
    PRINT ' Inserted 10105905 - .'
END
ELSE
BEGIN
    PRINT 'Application FunctionID 10105905 -  already EXISTS.'
END            

--Insert into application_functions
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10105906)
BEGIN
    INSERT INTO application_functions (function_id, function_name, function_desc, func_ref_id, document_path, file_path, book_required)
    VALUES (10105906, 'Contract Add/Save/Delete', 'Contract', 10105898, NULL, NULL, 0)
    PRINT ' Inserted 10105906 - .'
END
ELSE
BEGIN
	UPDATE application_functions 
		SET function_name = 'Contract Add/Save/Delete'
	WHERE function_id = 10105906

    PRINT 'Application FunctionID 10105906 -  already EXISTS.'
END            


--Insert into application_functions
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10105907)
BEGIN
    INSERT INTO application_functions (function_id, function_name, function_desc, func_ref_id, document_path, file_path, book_required)
    VALUES (10105907, 'View Netting', 'View Netting', 10105800, NULL, NULL, 0)
    PRINT ' Inserted 10105907 - .'
END
ELSE
BEGIN
	UPDATE application_functions 
		SET function_name = 'View Netting'
	WHERE function_id = 10105907

    PRINT 'Application FunctionID 10105907 -  already EXISTS.'
END            




