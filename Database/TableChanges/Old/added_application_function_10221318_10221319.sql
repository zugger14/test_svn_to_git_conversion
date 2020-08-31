IF NOT EXISTS(SELECT 1 FROM application_functions where function_id = 10221319)
BEGIN
	INSERT INTO application_functions (function_id, function_name, function_desc, func_ref_id, function_call, document_path, file_path, book_required)
	SELECT 10221319, 'Update Invoice Status', 'Update Invoice Status', 10221300, NULL, NULL, NULL, 0 
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10221319 already EXIST.'
END

---------------------------------------------------------------------------------------------------

IF NOT EXISTS(SELECT 1 FROM application_functions where function_id = 10221318)
BEGIN
	INSERT INTO application_functions (function_id, function_name, function_desc, func_ref_id, function_call, document_path, file_path, book_required)
	SELECT 10221318, 'Split', 'Split', 10221300, NULL, NULL, NULL, 0 
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10221318 already EXIST.'
END

---------------------------------------------------------------------------------------------------------

