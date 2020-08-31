IF NOT EXISTS (SELECT 1 FROM application_functions WHERE function_id = 10132300)
BEGIN
	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, requires_at, document_path, function_call, function_parameter, module_type, process_map_id, file_path, book_required)
	VALUES (10132300, 'Setup CNG Deals', 'Setup CNG Deals', 10130000, NULL, '', 'windowSetupCNGDeals', NULL, NULL, NULL, '_deal_capture/setup_cng_deals/setup.cng.deals.php', 1)
END