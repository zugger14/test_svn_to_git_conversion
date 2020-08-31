IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 14121400)
BEGIN
	INSERT INTO application_functions (function_id, function_name, function_desc, func_ref_id, file_path, document_path)
	VALUES (14121400, 'Assign/Unassign Transaction', 'Assign/Unassign Transaction', NULL, '_allowance_credit_assignment/assign.unassign.transaction.php', '')
END

IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 14121410)
BEGIN
	INSERT INTO application_functions (function_id, function_name, function_desc, func_ref_id, file_path, document_path)
	VALUES (14121410, 'Assign Transaction', 'Assign Transaction', 14121400, '', '')
END

IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 14121411)
BEGIN
	INSERT INTO application_functions (function_id, function_name, function_desc, func_ref_id, file_path, document_path)
	VALUES (14121411, 'Unassign Transaction', 'Unassign Transaction', 14121400, '', '')
END

IF NOT EXISTS (SELECT 1 FROM setup_menu WHERE function_id = 14121400 AND product_category = 14000000)
BEGIN
	INSERT INTO setup_menu (function_id, window_name, display_name, hide_show, parent_menu_id, product_category, menu_order, menu_type)
	VALUES (14121400, 'windowAssignUnassignTransaction', 'Assign/Unassign Transaction', 1, 12130000, 14000000, 1, 1)
END