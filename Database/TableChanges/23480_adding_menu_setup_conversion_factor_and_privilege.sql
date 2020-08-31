--Insert into application_functions
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 20016600)
BEGIN
    INSERT INTO application_functions (function_id, function_name, function_desc, func_ref_id, document_path, file_path, book_required)
    VALUES (20016600, 'Setup Conversion Factor', 'Setup Conversion Factor', NULL, NULL, '_setup/setup_counterparty/setup.counterparty.php', 0)
    PRINT ' Inserted 20016600 - .'
END
ELSE
BEGIN
    PRINT 'Application FunctionID 20016600 -  already EXISTS.'
END

--Insert into setup_menu
IF NOT EXISTS (SELECT 1 FROM setup_menu AS sm WHERE sm.function_id = 20016600 AND sm.product_category = 10000000)
BEGIN
    INSERT INTO setup_menu (function_id, display_name, parent_menu_id, hide_show, menu_type, menu_order, product_category)
    VALUES (20016600, 'Setup Conversion Factor', 10101099, 1, 0, 0, 10000000)
    PRINT ' Setup Menu 20016600 inserted.'
END
ELSE
BEGIN
    PRINT 'Setup Menu 20016600 already EXISTS.'
END   


--Update application_functions
UPDATE application_functions
SET function_name = 'Setup Conversion Factor',
    function_desc = 'Setup Conversion Factor',
    func_ref_id = NULL,
    file_path = '_setup/setup_conversion_factor/setup_conversion_factor.php',
    book_required = 0
    WHERE [function_id] = 20016600
PRINT 'Updated .'

--Update setup_menu
UPDATE setup_menu
SET display_name = 'Setup Conversion Factor',
    parent_menu_id = 10101099,
    menu_type = 0,
    hide_show = 1
    WHERE [function_id] = 20016600
    AND [product_category]= 10000000
PRINT 'Updated Setup Menu.'  

--Adding privilege
--Insert into application_functions
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 20016601)
BEGIN
    INSERT INTO application_functions (function_id, function_name, function_desc, func_ref_id, document_path, file_path, book_required)
    VALUES (20016601, 'Add/Save', 'Add/Save', 20016600, NULL, NULL, 0)
    PRINT ' Inserted 20016601 - .'
END
ELSE
BEGIN
    PRINT 'Application FunctionID 20016601 -  already EXISTS.'
END  

--Insert into application_functions
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 20016602)
BEGIN
    INSERT INTO application_functions (function_id, function_name, function_desc, func_ref_id, document_path, file_path, book_required)
    VALUES (20016602, 'Delete', 'Delete', 20016600, NULL, NULL, 0)
    PRINT ' Inserted 20016602 - .'
END
ELSE
BEGIN
    PRINT 'Application FunctionID 20016602 -  already EXISTS.'
END                      

 


               