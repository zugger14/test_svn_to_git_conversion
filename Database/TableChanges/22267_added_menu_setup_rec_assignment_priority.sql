--Insert into setup_menu
IF NOT EXISTS (SELECT 1 FROM setup_menu AS sm WHERE sm.function_id = 12103200 AND sm.product_category = 10000000)
BEGIN
    INSERT INTO setup_menu (function_id, display_name, parent_menu_id, hide_show, menu_type, menu_order, product_category)
    VALUES (12103200, 'Setup REC Assignment Priority', 14100000, 1, 0, 0, 10000000)
    PRINT ' Setup Menu 12103200 inserted.'
END
ELSE
BEGIN
    PRINT 'Setup Menu 12103200 already EXISTS.'
END 

--Insert into application_functions
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 12103200)
BEGIN
    INSERT INTO application_functions (function_id, function_name, function_desc, func_ref_id, document_path, file_path, book_required)
    VALUES (12103200, 'Setup REC Assignment Priority', 'Setup REC Assignment Priority', NULL, NULL, NULL, 0)
    PRINT ' Inserted 12103200 - Setup REC Assignment Priority.'
END
ELSE
BEGIN
    PRINT 'Application FunctionID 12103200 - Setup REC Assignment Priority already EXISTS.'
END