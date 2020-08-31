IF NOT EXISTS(SELECT 1 FROM application_functions where function_id = 10221345) 
BEGIN
	INSERT INTO application_functions (function_id, function_name, function_desc, func_ref_id, function_call, document_path, file_path, book_required) 
	SELECT 10221345, 'Invoice Dispute', 'Invoice Dispute', 10221300, NULL, NULL, NULL, 0
END
ELSE 
BEGIN
	PRINT 'Application FunctionId 10221345 already EXISTS.'
END

---------------------------------------------------------------------------------------

IF NOT EXISTS(SELECT 1 FROM application_functions where function_id = 10221346) 
BEGIN
	INSERT INTO application_functions (function_id, function_name, function_desc, func_ref_id, function_call, document_path, file_path, book_required) 
	SELECT 10221346, 'Add/Save', 'Add/Save', 10221345, NULL, NULL, NULL, 0
END
ELSE 
BEGIN
	PRINT 'Application FunctionId 10221346 already EXISTS.'
END

----------------------------------------------------------------------------------------

IF NOT EXISTS(SELECT 1 FROM application_functions where function_id = 10221347) 
BEGIN
	INSERT INTO application_functions (function_id, function_name, function_desc, func_ref_id, function_call, document_path, file_path, book_required) 
	SELECT 10221347, 'Delete', 'Delete', 10221345, NULL, NULL, NULL, 0
END
ELSE 
BEGIN
	PRINT 'Application FunctionId 10221347 already EXISTS.'
END