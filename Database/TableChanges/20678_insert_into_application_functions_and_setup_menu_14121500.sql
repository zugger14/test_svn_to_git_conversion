--Insert into application_functions
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 14121500)
BEGIN
	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, file_path, function_parameter, module_type, book_required)
	VALUES (14121500, 'Unassign Transaction', 'Unassign Transaction', NULL, '_allowance_credit_assignment/unassign.transaction.php', NULL, NULL, 0)
	PRINT ' Inserted 14121500 - Unassign Transaction.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 14121500 - Unassign Transaction already EXISTS.'
END

--Insert into setup_menu
IF NOT EXISTS (SELECT 1 FROM setup_menu AS sm WHERE sm.function_id = 14121500 AND sm.product_category = 14000000)
BEGIN
	INSERT INTO setup_menu(function_id, display_name, parent_menu_id, hide_show, menu_type, menu_order, product_category)
	VALUES (14121500, 'Unassign Transaction', 12130000, 1, 0, 0, 14000000)
	PRINT ' Setup Menu 14121500 inserted.'
END
ELSE
BEGIN
	PRINT 'Setup Menu 14121500 already EXISTS.'
END
                    