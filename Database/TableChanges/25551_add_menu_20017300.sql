--Insert into application_functions
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 20017300)
BEGIN
    INSERT INTO application_functions (function_id, function_name, function_desc, func_ref_id, document_path, file_path, book_required)
    VALUES (20017300, 'Setup File Transfer Endpoint', 'Setup File Transfer Endpoint', NULL, NULL, '_setup/setup_file_transfer_endpoint/setup_file_transfer_endpoint.php', 0)
    PRINT ' Inserted 20017300 - .'
END
ELSE
BEGIN
    PRINT 'Application FunctionID 20017300 -  already EXISTS.'
END

--Insert into setup_menu
IF NOT EXISTS (SELECT 1 FROM setup_menu AS sm WHERE sm.function_id = 20017300 AND sm.product_category = 10000000)
BEGIN
    INSERT INTO setup_menu (function_id, display_name, parent_menu_id, hide_show, menu_type, menu_order, product_category)
    VALUES (20017300, 'Setup File Transfer Endpoint', 20017100, 1, 0, 0, 10000000)
    PRINT ' Setup Menu 20017300 inserted.'
END
ELSE
BEGIN
    PRINT 'Setup Menu 20017300 already EXISTS.'
END