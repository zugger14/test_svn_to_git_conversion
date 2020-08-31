--Insert into application_functions
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 20011200)
BEGIN
    INSERT INTO application_functions (function_id, function_name, function_desc, func_ref_id, document_path, file_path, book_required, function_parameter)
    VALUES (20011200, 'Settlement Checkout', 'Settlement Checkout', NULL, NULL, '_settlement_billing/stmt_checkout/stmt.checkout.php', 0, 20011200)
    PRINT ' Inserted 20011200 - .'
END
ELSE
BEGIN
    PRINT 'Application FunctionID 20011200 -  already EXISTS.'
END

--Insert into setup_menu
IF NOT EXISTS (SELECT 1 FROM setup_menu AS sm WHERE sm.function_id = 20011200 AND sm.product_category = 10000000)
BEGIN
    INSERT INTO setup_menu (function_id, display_name, parent_menu_id, hide_show, menu_type, menu_order, product_category)
    VALUES (20011200, 'Settlement Checkout', 10220000, 1, 0, 0, 10000000)
    PRINT ' Setup Menu 20011200 inserted.'
END
ELSE
BEGIN
    PRINT 'Setup Menu 20011200 already EXISTS.'
END            


--Insert into application_functions
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 20011201)
BEGIN
    INSERT INTO application_functions (function_id, function_name, function_desc, func_ref_id, document_path, file_path, book_required)
    VALUES (20011201, 'Run Settlement', 'Run Settlement', 20011200, NULL, NULL, 0)
    PRINT ' Inserted 20011201 - .'
END
ELSE
BEGIN
    PRINT 'Application FunctionID 20011201 -  already EXISTS.'
END  


--Insert into application_functions
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 20011202)
BEGIN
    INSERT INTO application_functions (function_id, function_name, function_desc, func_ref_id, document_path, file_path, book_required)
    VALUES (20011202, 'Ready for Invoice', 'Ready for Invoice', 20011200, NULL, NULL, 0)
    PRINT ' Inserted 20011202 - .'
END
ELSE
BEGIN
    PRINT 'Application FunctionID 20011202 -  already EXISTS.'
END          


--Insert into application_functions
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 20011203)
BEGIN
    INSERT INTO application_functions (function_id, function_name, function_desc, func_ref_id, document_path, file_path, book_required)
    VALUES (20011203, 'Revert', 'Revert', 20011200, NULL, NULL, 0)
    PRINT ' Inserted 20011203 - .'
END
ELSE
BEGIN
    PRINT 'Application FunctionID 20011203 -  already EXISTS.'
END    


--Insert into application_functions
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 20011204)
BEGIN
    INSERT INTO application_functions (function_id, function_name, function_desc, func_ref_id, document_path, file_path, book_required)
    VALUES (20011204, 'Manual Adjustment', 'Manual Adjustment', 20011200, NULL, '_settlement_billing/stmt_checkout/stmt.manual.adjustment.php', 0)
    PRINT ' Inserted 20011204 - .'
END
ELSE
BEGIN
    PRINT 'Application FunctionID 20011204 -  already EXISTS.'
END     


--Insert into application_functions
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 20011205)
BEGIN
    INSERT INTO application_functions (function_id, function_name, function_desc, func_ref_id, document_path, file_path, book_required)
    VALUES (20011205, 'Run Adjustment', 'Run Adjustment', 20011200, NULL, NULL, 0)
    PRINT ' Inserted 20011205 - .'
END
ELSE
BEGIN
    PRINT 'Application FunctionID 20011205 -  already EXISTS.'
END         


--Insert into application_functions
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 20011207)
BEGIN
    INSERT INTO application_functions (function_id, function_name, function_desc, func_ref_id, document_path, file_path, book_required)
    VALUES (20011207, 'Prepare Invoice', 'Prepare Invoice', 20011200, NULL, NULL, 0)
    PRINT ' Inserted 20011207 - .'
END
ELSE
BEGIN
    PRINT 'Application FunctionID 20011207 -  already EXISTS.'
END   


--Insert into application_functions
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 20011208)
BEGIN
    INSERT INTO application_functions (function_id, function_name, function_desc, func_ref_id, document_path, file_path, book_required)
    VALUES (20011208, 'Post GL', 'Post GL', 20011200, NULL, NULL, 0)
    PRINT ' Inserted 20011208 - .'
END
ELSE
BEGIN
    PRINT 'Application FunctionID 20011208 -  already EXISTS.'
END        


--Insert into application_functions
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 20011209)
BEGIN
    INSERT INTO application_functions (function_id, function_name, function_desc, func_ref_id, document_path, file_path, book_required)
    VALUES (20011209, 'Final GL', 'Final GL', 20011200, NULL, NULL, 0)
    PRINT ' Inserted 20011209 - .'
END
ELSE
BEGIN
    PRINT 'Application FunctionID 20011209 -  already EXISTS.'
END            


--Insert into application_functions
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 20011210)
BEGIN
    INSERT INTO application_functions (function_id, function_name, function_desc, func_ref_id, document_path, file_path, book_required)
    VALUES (20011210, 'Final Extract', 'Final Extract', 20011200, NULL, NULL, 0)
    PRINT ' Inserted 20011210 - .'
END
ELSE
BEGIN
    PRINT 'Application FunctionID 20011210 -  already EXISTS.'
END            