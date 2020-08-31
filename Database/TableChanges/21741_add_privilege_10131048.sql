--Insert into application_functions
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10131048)
BEGIN
    INSERT INTO application_functions (function_id, function_name, function_desc, func_ref_id, document_path, file_path, book_required)
    VALUES (10131048, 'Deal Provisional Price', 'Provisional Price', 10131000, NULL, NULL, 0)
    PRINT ' Inserted 10131048 - .'
END
ELSE
BEGIN
    PRINT 'Application FunctionID 10131048 -  already EXISTS.'
END