--Insert into application_functions
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10141900)
BEGIN
    INSERT INTO application_functions (function_id, function_name, function_desc, func_ref_id, document_path, file_path, book_required)
    VALUES (10141900, 'Load Forecast Report', 'Load Forecast Report', NULL, NULL, NULL, 0)
    PRINT ' Inserted 10141900 - .'
END
ELSE
BEGIN
    PRINT 'Application FunctionID 10141900 -  already EXISTS.'
END

--Insert into setup_menu
IF NOT EXISTS (SELECT 1 FROM setup_menu AS sm WHERE sm.function_id = 10141900 AND sm.product_category = 13000000)
BEGIN
    INSERT INTO setup_menu (function_id, display_name, parent_menu_id, hide_show, menu_type, menu_order, product_category)
    VALUES (10141900, 'Load Forecast Report', 10202200, 0, NULL, 21, 13000000)
    PRINT ' Setup Menu 10141900 inserted.'
END
ELSE
BEGIN
    PRINT 'Setup Menu 10141900 already EXISTS.'
END  