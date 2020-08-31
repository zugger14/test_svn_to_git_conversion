--Insert into application_functions
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 20011211)
BEGIN
    INSERT INTO application_functions (function_id, function_name, function_desc, func_ref_id, document_path, file_path, book_required)
    VALUES (20011211, 'Apply Cash', 'Apply Cash', 20011200, NULL, NULL, 0)
    PRINT ' Inserted 20011211 - .'
END
ELSE
BEGIN
    PRINT 'Application FunctionID 20011211 -  already EXISTS.'
END            


--Insert into application_functions
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 20012204)
BEGIN
    INSERT INTO application_functions (function_id, function_name, function_desc, func_ref_id, document_path, file_path, book_required)
    VALUES (20012204, 'Workflow Status', 'Workflow Status', 20012200, NULL, NULL, 0)
    PRINT ' Inserted 20012204 - .'
END
ELSE
BEGIN
    PRINT 'Application FunctionID 20012204 -  already EXISTS.'
END  


--Insert into application_functions
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 20012205)
BEGIN
    INSERT INTO application_functions (function_id, function_name, function_desc, func_ref_id, document_path, file_path, book_required)
    VALUES (20012205, 'Finalize', 'Finalize', 20012200, NULL, NULL, 0)
    PRINT ' Inserted 20012205 - .'
END
ELSE
BEGIN
    PRINT 'Application FunctionID 20012205 -  already EXISTS.'
END          


--Insert into application_functions
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 20012206)
BEGIN
    INSERT INTO application_functions (function_id, function_name, function_desc, func_ref_id, document_path, file_path, book_required)
    VALUES (20012206, 'Void', 'Void', 20012200, NULL, NULL, 0)
    PRINT ' Inserted 20012206 - .'
END
ELSE
BEGIN
    PRINT 'Application FunctionID 20012206 -  already EXISTS.'
END 


--Insert into application_functions
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 20012207)
BEGIN
    INSERT INTO application_functions (function_id, function_name, function_desc, func_ref_id, document_path, file_path, book_required)
    VALUES (20012207, 'Export Invoice', 'Export Invoice', 20012200, NULL, NULL, 0)
    PRINT ' Inserted 20012207 - .'
END
ELSE
BEGIN
    PRINT 'Application FunctionID 20012207 -  already EXISTS.'
END        


--Update application_functions
UPDATE application_functions
SET function_name = 'Revert',
    function_desc = 'Revert',
    func_ref_id = 20011800,
    file_path = NULL,
    book_required = 0
    WHERE [function_id] = 20011803
PRINT 'Updated .'     