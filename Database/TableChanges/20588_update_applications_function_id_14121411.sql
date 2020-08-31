UPDATE application_functions 
SET func_ref_id = '',
	file_path = '_allowance_credit_assignment/unassign.transaction.php'
WHERE function_id = 14121411


IF NOT EXISTS (SELECT 1 FROM setup_menu WHERE function_id = 14121411 AND product_category = 14000000)
BEGIN
	INSERT INTO setup_menu (function_id, window_name, display_name, hide_show, parent_menu_id, product_category, menu_order, menu_type)
	VALUES (14121411, 'windowUnassignTransaction', 'Unassign Transaction', 1, 12130000, 14000000, 1, 1)
END
