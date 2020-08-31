--Insert into application_functions
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 20016500)
BEGIN
    INSERT INTO application_functions (function_id, function_name, function_desc, func_ref_id, document_path, file_path, book_required)
    VALUES (20016500, 'Setup Shipper Code Mapping', 'Setup Shipper Code Mapping', NULL, NULL, '_setup\setup_shipper_code_mapping\setup_shipper_code_mapping.php', 0)
    PRINT ' Inserted 20016500 - .'
END
ELSE
BEGIN
    PRINT 'Application FunctionID 20016500 -  already EXISTS.'
END

--Insert into setup_menu
IF NOT EXISTS (SELECT 1 FROM setup_menu AS sm WHERE sm.function_id = 20016500 AND sm.product_category = 10000000)
BEGIN
    INSERT INTO setup_menu (function_id, display_name, parent_menu_id, hide_show, menu_type, menu_order, product_category)
    VALUES (20016500, 'Setup Shipper Code Mapping', 10101099, 1, 0, 0, 10000000)
    PRINT ' Setup Menu 20016500 inserted.'
END
ELSE
BEGIN
    PRINT 'Setup Menu 20016500 already EXISTS.'
END            