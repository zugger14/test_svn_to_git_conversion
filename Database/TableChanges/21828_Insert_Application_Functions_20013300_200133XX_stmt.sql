--Insert into application_functions
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 20013300)
BEGIN
    INSERT INTO application_functions (function_id, function_name, function_desc, func_ref_id, document_path, file_path, book_required)
    VALUES (20013300, 'Netting Contract', 'Netting Contract', NULL, NULL, NULL, 0)
    PRINT ' Inserted 20013300 - .'
END
ELSE
BEGIN
    PRINT 'Application FunctionID 20013300 -  already EXISTS.'
END

--Insert into setup_menu
IF NOT EXISTS (SELECT 1 FROM setup_menu AS sm WHERE sm.function_id = 20013300 AND sm.product_category = 10000000)
BEGIN
    INSERT INTO setup_menu (function_id, display_name, parent_menu_id, hide_show, menu_type, menu_order, product_category)
    VALUES (20013300, 'Netting Contract', 10210000, 0, 0, 0, 10000000)
    PRINT ' Setup Menu 20013300 inserted.'
END
ELSE
BEGIN
    PRINT 'Setup Menu 20013300 already EXISTS.'
END            

--Insert into application_functions
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 20013301)
BEGIN
    INSERT INTO application_functions (function_id, function_name, function_desc, func_ref_id, document_path, file_path, book_required)
    VALUES (20013301, 'Add/Save', 'Add/Save', 20013300, NULL, NULL, 0)
    PRINT ' Inserted 20013301 - .'
END
ELSE
BEGIN
    PRINT 'Application FunctionID 20013301 -  already EXISTS.'
END            

--Insert into application_functions
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 20013302)
BEGIN
    INSERT INTO application_functions (function_id, function_name, function_desc, func_ref_id, document_path, file_path, book_required)
    VALUES (20013302, 'Delete', 'Delete', 20013300, NULL, NULL, 0)
    PRINT ' Inserted 20013302 - .'
END
ELSE
BEGIN
    PRINT 'Application FunctionID 20013302 -  already EXISTS.'
END            


 