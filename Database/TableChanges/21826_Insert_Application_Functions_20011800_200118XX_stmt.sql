--Insert into application_functions
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 20011800)
BEGIN
    INSERT INTO application_functions (function_id, function_name, function_desc, func_ref_id, document_path, file_path, book_required, function_parameter)
    VALUES (20011800, 'Run Accrual', 'Run Accrual', NULL, NULL, '_settlement_billing/stmt_checkout/stmt.checkout.php', 0, 20011800)
    PRINT ' Inserted 20011800 - .'
END
ELSE
BEGIN
    PRINT 'Application FunctionID 20011800 -  already EXISTS.'
END

--Insert into setup_menu
IF NOT EXISTS (SELECT 1 FROM setup_menu AS sm WHERE sm.function_id = 20011800 AND sm.product_category = 10000000)
BEGIN
    INSERT INTO setup_menu (function_id, display_name, parent_menu_id, hide_show, menu_type, menu_order, product_category)
    VALUES (20011800, 'Run Accrual', 10220000, 1, 0, 0, 10000000)
    PRINT ' Setup Menu 20011800 inserted.'
END
ELSE
BEGIN
    PRINT 'Setup Menu 20011800 already EXISTS.'
END            


--Insert into application_functions
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 20011801)
BEGIN
    INSERT INTO application_functions (function_id, function_name, function_desc, func_ref_id, document_path, file_path, book_required)
    VALUES (20011801, 'Run Settlement', 'Run Settlement', 20011800, NULL, NULL, 0)
    PRINT ' Inserted 20011801 - .'
END
ELSE
BEGIN
    PRINT 'Application FunctionID 20011801 -  already EXISTS.'
END      


--Insert into application_functions
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 20011802)
BEGIN
    INSERT INTO application_functions (function_id, function_name, function_desc, func_ref_id, document_path, file_path, book_required)
    VALUES (20011802, 'Post GL', 'Post GL', 20011800, NULL, NULL, 0)
    PRINT ' Inserted 20011802 - .'
END
ELSE
BEGIN
    PRINT 'Application FunctionID 20011802 -  already EXISTS.'
END           


--Insert into application_functions
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 20011803)
BEGIN
    INSERT INTO application_functions (function_id, function_name, function_desc, func_ref_id, document_path, file_path, book_required)
    VALUES (20011803, 'Revert GL', 'Revert GL', 20011800, NULL, NULL, 0)
    PRINT ' Inserted 20011803 - .'
END
ELSE
BEGIN
    PRINT 'Application FunctionID 20011803 -  already EXISTS.'
END         


--Insert into application_functions
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 20011804)
BEGIN
    INSERT INTO application_functions (function_id, function_name, function_desc, func_ref_id, document_path, file_path, book_required)
    VALUES (20011804, 'Accrual GL', 'Accrual GL', 20011800, NULL, NULL, 0)
    PRINT ' Inserted 20011804 - .'
END
ELSE
BEGIN
    PRINT 'Application FunctionID 20011804 -  already EXISTS.'
END      


--Insert into application_functions
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 20011805)
BEGIN
    INSERT INTO application_functions (function_id, function_name, function_desc, func_ref_id, document_path, file_path, book_required)
    VALUES (20011805, 'Accrual Extract', 'Accrual Extract', 20011800, NULL, NULL, 0)
    PRINT ' Inserted 20011805 - .'
END
ELSE
BEGIN
    PRINT 'Application FunctionID 20011805 -  already EXISTS.'
END        

--Insert into application_functions
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 20011806)
BEGIN
    INSERT INTO application_functions (function_id, function_name, function_desc, func_ref_id, document_path, file_path, book_required)
    VALUES (20011806, 'Submitted Accrual', 'Submitted Accrual', 20011800, NULL, NULL, 0)
    PRINT ' Inserted 20011806 - .'
END
ELSE
BEGIN
    PRINT 'Application FunctionID 20011806 -  already EXISTS.'
END        