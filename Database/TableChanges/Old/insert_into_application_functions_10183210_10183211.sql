IF NOT EXISTS (SELECT 1 FROM application_functions WHERE function_id = 10183210)
BEGIN
	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, requires_at, document_path, function_call, function_parameter, module_type, process_map_id, file_path, book_required)
	VALUES (10183210, 'Setup Portfolio Group IU', 'Setup Portfolio Group IU', 10183200, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 1)
END

IF NOT EXISTS (SELECT 1 FROM application_functions WHERE function_id = 10183211)
BEGIN
	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, requires_at, document_path, function_call, function_parameter, module_type, process_map_id, file_path, book_required)
	VALUES (10183211, 'Setup Portfolio Group Delete', 'Setup Portfolio Group Delete', 10183200, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 1)
END

UPDATE af 
SET function_name = 'Setup Portfolio Group', 
	function_desc = 'Setup Portfolio Group'
FROM application_functions af
WHERE af.function_id = 10183200