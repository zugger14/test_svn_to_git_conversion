IF NOT EXISTS(SELECT 1 FROM application_functions where function_id = 10221330) 
BEGIN
	INSERT INTO application_functions (function_id, function_name, function_desc, func_ref_id, function_call, document_path, file_path, book_required) 
	SELECT 10221330, 'Manual Adjustment', 'Manual Adjustment', 10221300, NULL, NULL, NULL, 0
END
ELSE 
BEGIN
	PRINT 'Application FunctionId 10221330 already EXISTS.'
END

------------------------------------------------------------------------------------------------

IF NOT EXISTS(SELECT 1 FROM application_functions where function_id = 10221331) 
BEGIN
	INSERT INTO application_functions (function_id, function_name, function_desc, func_ref_id, function_call, document_path, file_path, book_required) 
	SELECT 10221331, 'Add/Save', 'Add/Save', 10221330, NULL, NULL, NULL, 0
END
ELSE 
BEGIN
	PRINT 'Application FunctionId 10221331 already EXISTS.'
END
-------------------------------------------------------------------------------------------------

IF NOT EXISTS(SELECT 1 FROM application_functions where function_id = 10221332) 
BEGIN
	INSERT INTO application_functions (function_id, function_name, function_desc, func_ref_id, function_call, document_path, file_path, book_required) 
	SELECT 10221332, 'Delete', 'Delete', 10221330, NULL, NULL, NULL, 0
END
ELSE 
BEGIN
	PRINT 'Application FunctionId 10221332 already EXISTS.'
END