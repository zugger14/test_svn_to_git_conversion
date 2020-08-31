--Insert into application_functions
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10233724)
BEGIN
    INSERT INTO application_functions (function_id, function_name, function_desc, func_ref_id, document_path, file_path, book_required)
    VALUES (10233724, 'Deal Match/Refresh in Designation of Hedge', 'Deal Match/Refresh in Designation of Hedge', 10233700, NULL, NULL, 0)
    PRINT ' Inserted 10233724 - Deal Match/Refresh in Designation of Hedge.'
END
ELSE
BEGIN
    PRINT 'Application FunctionID 10233724 - Deal Match/Refresh in Designation of Hedge already EXISTS.'
END            
