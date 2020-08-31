--Insert into application_functions
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10163612)
BEGIN
    INSERT INTO application_functions (function_id, function_name, function_desc, func_ref_id, document_path, file_path, book_required)
    VALUES (10163612, 'Back to Back', 'Back to Back', 10163600, NULL, NULL, 0)
    PRINT ' Inserted 10163612 - .'
END
ELSE
BEGIN
    PRINT 'Application FunctionID 10163612 -  already EXISTS.'
END            