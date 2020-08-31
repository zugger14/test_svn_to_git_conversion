--Insert into application_functions
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 20012200)
BEGIN
    INSERT INTO application_functions (function_id, function_name, function_desc, func_ref_id, document_path, file_path, book_required)
    VALUES (20012200, 'Settlement Invoice', 'Settlement Invoice', NULL, NULL, '_settlement_billing/stmt_checkout/stmt.invoice.php', 0)
    PRINT ' Inserted 20012200 - .'
END
ELSE
BEGIN
    PRINT 'Application FunctionID 20012200 -  already EXISTS.'
END

--Insert into setup_menu
IF NOT EXISTS (SELECT 1 FROM setup_menu AS sm WHERE sm.function_id = 20012200 AND sm.product_category = 10000000)
BEGIN
    INSERT INTO setup_menu (function_id, display_name, parent_menu_id, hide_show, menu_type, menu_order, product_category)
    VALUES (20012200, 'Settlement Invoice', 10220000, 1, 0, 0, 10000000)
    PRINT ' Setup Menu 20012200 inserted.'
END
ELSE
BEGIN
    PRINT 'Setup Menu 20012200 already EXISTS.'
END            

--Insert into application_functions
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 20012201)
BEGIN
    INSERT INTO application_functions (function_id, function_name, function_desc, func_ref_id, document_path, file_path, book_required)
    VALUES (20012201, 'Add/Save', 'Add/Save', 20012200, NULL, NULL, 0)
    PRINT ' Inserted 20012201 - .'
END
ELSE
BEGIN
    PRINT 'Application FunctionID 20012201 -  already EXISTS.'
END            


--Insert into application_functions
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 20012202)
BEGIN
    INSERT INTO application_functions (function_id, function_name, function_desc, func_ref_id, document_path, file_path, book_required)
    VALUES (20012202, 'Delete', 'Delete', 20012200, NULL, NULL, 0)
    PRINT ' Inserted 20012202 - .'
END
ELSE
BEGIN
    PRINT 'Application FunctionID 20012202 -  already EXISTS.'
END    

--Insert into application_functions
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 20012203)
BEGIN
    INSERT INTO application_functions (function_id, function_name, function_desc, func_ref_id, document_path, file_path, book_required)
    VALUES (20012203, 'Settlement Counterparty Invoice', 'Settlement Counterparty Invoice', 20012200, NULL, NULL, 0)
    PRINT ' Inserted 20012203 - .'
END
ELSE
BEGIN
    PRINT 'Application FunctionID 20012203 -  already EXISTS.'
END            