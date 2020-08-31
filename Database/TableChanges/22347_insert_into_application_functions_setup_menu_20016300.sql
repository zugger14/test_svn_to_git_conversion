--Insert into application_functions
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 20016300)
BEGIN
    INSERT INTO application_functions (function_id, function_name, function_desc, func_ref_id, document_path, file_path, book_required)
    VALUES (20016300, 'Transfer RECs', 'Transfer RECs to Webservices', NULL, NULL, '_deal_capture/buy_sell/transfer.recs.php', 0)
    PRINT ' Inserted 20016300 - .'
END
ELSE
BEGIN
    PRINT 'Application FunctionID 20016300 -  already EXISTS.'
END

--Insert into setup_menu
IF NOT EXISTS (SELECT 1 FROM setup_menu AS sm WHERE sm.function_id = 20016300 AND sm.product_category = 14000000)
BEGIN
    INSERT INTO setup_menu (function_id, display_name, parent_menu_id, hide_show, menu_type, menu_order, product_category)
    VALUES (20016300, 'Transfer RECs', 12130000, 1, 0, 0, 14000000)
    PRINT ' Setup Menu 20016300 inserted.'
END
ELSE
BEGIN
    PRINT 'Setup Menu 20016300 already EXISTS.'
END       

--Insert into setup_menu
IF NOT EXISTS (SELECT 1 FROM setup_menu AS sm WHERE sm.function_id = 20016300 AND sm.product_category = 10000000)
BEGIN
    INSERT INTO setup_menu (function_id, display_name, parent_menu_id, hide_show, menu_type, menu_order, product_category)
    VALUES (20016300, 'Transfer RECs', 12130000, 1, 0, 0, 10000000)
    PRINT ' Setup Menu 20016300 inserted.'
END
ELSE
BEGIN
    PRINT 'Setup Menu 20016300 already EXISTS.'
END             

--Insert into application_functions
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 20016301)
BEGIN
    INSERT INTO application_functions (function_id, function_name, function_desc, func_ref_id, document_path, file_path, book_required)
    VALUES (20016301, 'Transfer', 'Transfer Button to transfer RECs to webservice', 20016300, NULL, NULL, 0)
    PRINT ' Inserted 20016301 - .'
END
ELSE
BEGIN
    PRINT 'Application FunctionID 20016301 -  already EXISTS.'
END                    