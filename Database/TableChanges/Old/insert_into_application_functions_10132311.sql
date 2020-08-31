IF NOT EXISTS (SELECT 1 FROM application_functions WHERE function_id = 10132311)
BEGIN
	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, requires_at, document_path, function_call, function_parameter, module_type, process_map_id, file_path, book_required)
	VALUES (10132311, 'Setup CNG Deals Delete', 'Setup CNG Deals Delete', 10132300, NULL, '', NULL, NULL, NULL, NULL, NULL, 1)
END