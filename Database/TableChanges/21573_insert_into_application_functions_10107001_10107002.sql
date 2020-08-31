-- Insert into application_functions Add/Save
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10107001)
BEGIN
    INSERT INTO application_functions (function_id, function_name, function_desc, func_ref_id, document_path, file_path, book_required)
    VALUES (10107001, 'Add/Save', 'Add/Save', 10107000, NULL, NULL, 0)
    PRINT 'Inserted Application Function 10107001 - Add/Save.'
END
ELSE
BEGIN
    PRINT 'Application Function 10107001 - Add/Save. already exists.'
END         
   
-- Insert into application_functions Delete
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10107002)
BEGIN
    INSERT INTO application_functions (function_id, function_name, function_desc, func_ref_id, document_path, file_path, book_required)
    VALUES (10107002, 'Delete', 'Delete', 10107000, NULL, NULL, 0)
    PRINT 'Inserted Application Function 10107002 - Delete.'
END
ELSE
BEGIN
    PRINT 'Application Function 10107002 - Delete already exists.'
END