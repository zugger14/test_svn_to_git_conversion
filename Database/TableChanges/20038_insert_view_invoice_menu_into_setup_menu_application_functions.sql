IF NOT EXISTS (SELECT 1 FROM application_functions WHERE function_id = 10221300)
BEGIN
	INSERT INTO application_functions(function_id, function_name, function_desc, document_path, file_path, book_required)
	VALUES (10221300, 'View Invoice', 'View Invoice', '#55 View Invoice', '_settlement_billing/maintain_invoice/maintain.invoice.php', 0)
END

IF NOT EXISTS (SELECT 1 FROM setup_menu WHERE function_id = 10221300 AND product_category = 10000000)
BEGIN
	INSERT INTO setup_menu(function_id, display_name, hide_show, parent_menu_id, product_category, menu_order, menu_type)
	VALUES (10221300, 'View Invoice', 1, 10220000, 10000000, 0, 0)
END