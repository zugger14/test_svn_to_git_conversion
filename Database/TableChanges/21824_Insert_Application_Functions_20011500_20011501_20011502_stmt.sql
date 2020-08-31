--Insert into application_functions
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 20011500)
BEGIN
    INSERT INTO application_functions (function_id, function_name, function_desc, func_ref_id, document_path, file_path, book_required)
    VALUES (20011500, 'Setup Account Code Mapping', 'Setup Account Code Mapping', NULL, NULL, '_settlement_billing/stmt_checkout/stmt.setup.account.code.mapping.php', 0)
    PRINT ' Inserted 20011500 - .'
END
ELSE
BEGIN
    PRINT 'Application FunctionID 20011500 -  already EXISTS.'
END

--Insert into setup_menu
IF NOT EXISTS (SELECT 1 FROM setup_menu AS sm WHERE sm.function_id = 20011500 AND sm.product_category = 10000000)
BEGIN
    INSERT INTO setup_menu (function_id, display_name, parent_menu_id, hide_show, menu_type, menu_order, product_category)
    VALUES (20011500, 'Setup Account Code Mapping', 15190000, 1, 0, 0, 10000000)
    PRINT ' Setup Menu 20011500 inserted.'
END
ELSE
BEGIN
    PRINT 'Setup Menu 20011500 already EXISTS.'
END                      


--Insert into application_functions
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 20011501)
BEGIN
    INSERT INTO application_functions (function_id, function_name, function_desc, func_ref_id, document_path, file_path, book_required)
    VALUES (20011501, 'Add/Save', 'Add/Save', 20011500, NULL, NULL, 0)
    PRINT ' Inserted 20011501 - .'
END
ELSE
BEGIN
    PRINT 'Application FunctionID 20011501 -  already EXISTS.'
END


--Insert into application_functions
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 20011502)
BEGIN
    INSERT INTO application_functions (function_id, function_name, function_desc, func_ref_id, document_path, file_path, book_required)
    VALUES (20011502, 'Delete', 'Delete', 20011500, NULL, NULL, 0)
    PRINT ' Inserted 20011502 - .'
END
ELSE
BEGIN
    PRINT 'Application FunctionID 20011502 -  already EXISTS.'
END
GO


UPDATE setup_menu
SET display_name = 'Setup GL Account Code Mapping',
	menu_order = 169
WHERE function_id = 20011500 --Setup Account Code Mapping
	AND product_category = 10000000

UPDATE setup_menu
SET display_name = 'Setup GL Account Code',
	menu_order = 167
WHERE function_id = 10101300  --Setup GL Code
	AND product_category = 10000000

UPDATE setup_menu
SET display_name = 'Setup GL Accounting Rule',
	menu_order = 168
WHERE function_id = 10103300 --Setup GL Group
	AND product_category = 10000000
GO