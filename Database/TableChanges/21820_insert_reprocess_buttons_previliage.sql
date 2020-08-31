--Insert into application_functions
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10106301)
BEGIN
    INSERT INTO application_functions (function_id, function_name, function_desc, func_ref_id, document_path, file_path, book_required)
    VALUES (10106301, 'Reprocess', 'Open import.data.interface window', 10106300, NULL, '_setup\import_data_interface\import.data.interface.php', 0)
    PRINT ' Inserted 10106301 - .'
END
ELSE
BEGIN
    PRINT 'Application FunctionID 10106301 -  already EXISTS.'
END            