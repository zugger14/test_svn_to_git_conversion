IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10166700)
BEGIN
	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call, document_path, file_path, book_required)
	VALUES (10166700, 'Generation Reserve Planner', 'Generation Reserve Planner', '10160000', NULL, NULL, '_scheduling_delivery/generation_reserve_planner/generation.reserve.planner.php', 0 )
	PRINT 'INSERTED 10166500 - Generation Reserve Planner.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10166700 - Generation Reserve Planner already EXISTS.'
END