IF NOT EXISTS (SELECT 1 FROM application_functions WHERE function_id = 10132000)
BEGIN
	INSERT INTO application_functions
	(
		function_id,
		function_name,
		function_desc,
		func_ref_id,
		requires_at,
		document_path,
		function_call,
		function_parameter,
		module_type,
		create_user,
		create_ts,
		update_user,
		update_ts,
		process_map_id,
		file_path,
		book_required
	)
	SELECT 
		10132000,
		'Create and View Deals New',
		'Create and View Deals New',
		func_ref_id,
		requires_at,
		document_path,
		function_call,
		function_parameter,
		module_type,
		create_user,
		create_ts,
		update_user,
		update_ts,
		process_map_id,
		'_deal_capture/maintain_deals/maintain.deals.new.php',
		book_required
	FROM application_functions af 
	WHERE af.function_id = 10131000
	
	INSERT INTO setup_menu (
		function_id,
		window_name,
		display_name,
		default_parameter,
		hide_show,
		parent_menu_id,
		product_category,
		menu_order,
		menu_type
	)
	SELECT 
		10132000,
		window_name,
		'Create and View Deals New',
		default_parameter,
		hide_show,
		parent_menu_id,
		product_category,
		menu_order,
		menu_type
	FROM setup_menu sm 
	WHERE sm.function_id = 10131000 AND sm.parent_menu_id = 10130000 AND sm.product_category = 10000000
END

