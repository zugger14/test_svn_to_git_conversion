--Insert into application_functions
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 20015100)
BEGIN
    INSERT INTO application_functions (function_id, function_name, function_desc, func_ref_id, document_path, file_path, book_required)
    VALUES (20015100, 'Exchange API Configuration', 'Exchange API Configuration', NULL, NULL, '_setup/exchange_api_configuration/exchange.api.configuration.php', 0)
    PRINT ' Inserted 20015100 - .'
END
ELSE
BEGIN
    PRINT 'Application FunctionID 20015100 -  already EXISTS.'
END

--Insert into setup_menu
IF NOT EXISTS (SELECT 1 FROM setup_menu AS sm WHERE sm.function_id = 20015100 AND sm.product_category = 10000000)
BEGIN
    INSERT INTO setup_menu (function_id, display_name, parent_menu_id, hide_show, menu_type, menu_order, product_category)
    VALUES (20015100, 'Exchange API Configuration', 10100000, 1, 0, 0, 10000000)
    PRINT ' Setup Menu 20015100 inserted.'
END
ELSE
BEGIN
    PRINT 'Setup Menu 20015100 already EXISTS.'
END            


--Insert into application_functions
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 20015101)
BEGIN
    INSERT INTO application_functions (function_id, function_name, function_desc, func_ref_id, document_path, file_path, book_required)
    VALUES (20015101, 'Add/Save', 'Add/Save', 20015100, NULL, NULL, 0)
    PRINT ' Inserted 20015101 - .'
END
ELSE
BEGIN
    PRINT 'Application FunctionID 20015101 -  already EXISTS.'
END            


--Insert into application_functions
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 20015102)
BEGIN
    INSERT INTO application_functions (function_id, function_name, function_desc, func_ref_id, document_path, file_path, book_required)
    VALUES (20015102, 'Delete', 'Delete', 20015100, NULL, NULL, 0)
    PRINT ' Inserted 20015102 - .'
END
ELSE
BEGIN
    PRINT 'Application FunctionID 20015102 -  already EXISTS.'
END            