IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10132312)
BEGIN 
	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, requires_at, document_path, function_call, function_parameter, module_type, process_map_id, file_path, book_required)
	VALUES (10132312, 'Setup CNG Cash Apply', 'Setup CNG Cash Apply', 10132300, NULL, NULL, 'windowSetupCashApply', NULL, NULL, NULL, '_deal_capture/setup_cng_deals/setup.cng.deals.cash.apply.php', 1)
END