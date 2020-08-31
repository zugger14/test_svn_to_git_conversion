/* Environmental Inverntory */

--Insert into setup_menu
IF NOT EXISTS (SELECT 1 FROM setup_menu AS sm WHERE sm.function_id = 20014700 AND sm.product_category = 10000000)
BEGIN
    INSERT INTO setup_menu (function_id, display_name, hide_show, parent_menu_id, product_category, menu_order, menu_type, menu_image)
    VALUES (20014700, 'Environmental Inventory', 1, 10000000, 10000000, 0, 5, '<i class="fa fa-bars icon_design"></i>')
    PRINT 'Setup Menu 20014700 inserted.'
END
ELSE
BEGIN
    PRINT 'Setup Menu 20014700 already EXISTS.'
END

/* Compliance Setup */

--Insert into setup_menu
IF NOT EXISTS (SELECT 1 FROM setup_menu AS sm WHERE sm.function_id = 14100000 AND sm.product_category = 10000000)
BEGIN
    INSERT INTO setup_menu (function_id, display_name, hide_show, parent_menu_id, product_category, menu_order, menu_type)
    VALUES (14100000, 'Compliance Setup', 1, 20014700, 10000000, 0, 1)
    PRINT 'Setup Menu 14100000 inserted.'
END
ELSE
BEGIN
    PRINT 'Setup Menu 14100000 already EXISTS.'
END

/* Setup Eligibility Mapping Template */

--Insert into setup_menu
IF NOT EXISTS (SELECT 1 FROM setup_menu AS sm WHERE sm.function_id = 20010600 AND sm.product_category = 10000000)
BEGIN
    INSERT INTO setup_menu (function_id, display_name, parent_menu_id, hide_show, menu_type, menu_order, product_category)
    VALUES (20010600, 'Setup Eligibility Mapping Template', 14100000, 1, 0, 0, 10000000)
    PRINT ' Setup Menu 20010600 inserted.'
END
ELSE
BEGIN
    PRINT 'Setup Menu 20010600 already EXISTS.'
END

--Insert into application_functions
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 20010600)
BEGIN
    INSERT INTO application_functions (function_id, function_name, function_desc, func_ref_id, document_path, file_path, book_required)
    VALUES (20010600, 'Setup Eligibility Mapping Template', 'Setup Eligibility Mapping Template', NULL, NULL, '_compliance_management/setup_eligibility_mapping_template/setup.eligibility.mapping.template.php', 0)
    PRINT ' Inserted 12103200 - Setup REC Assignment Priority.'
END
ELSE
BEGIN
    PRINT 'Application FunctionID 20010600 - Setup Eligibility Mapping Template already EXISTS.'
END

/* Add/Save */

--Insert into application_functions
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 20010601)
BEGIN
    INSERT INTO application_functions (function_id, function_name, function_desc, func_ref_id, document_path, file_path, book_required)
    VALUES (20010601, 'Add/Save', 'Add/Save', 20010600, NULL, NULL, 0)
    PRINT ' Inserted 12103210 - Add/Save.'
END
ELSE
BEGIN
    PRINT 'Application FunctionID 20010601 - Add/Save already EXISTS.'
END  

/* Delete */          

--Insert into application_functions
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 12103211)
BEGIN
    INSERT INTO application_functions (function_id, function_name, function_desc, func_ref_id, document_path, file_path, book_required)
    VALUES (20010602, 'Delete', 'Delete', 20010600, NULL, NULL, 0)
    PRINT ' Inserted 20010602 - Delete.'
END
ELSE
BEGIN
    PRINT 'Application FunctionID 20010602 - Delete already EXISTS.'
END

/* Jurisdiction/Market */

--Insert into setup_menu
IF NOT EXISTS (SELECT 1 FROM setup_menu AS sm WHERE sm.function_id = 14100100 AND sm.product_category = 10000000)
BEGIN
    INSERT INTO setup_menu (function_id, display_name, parent_menu_id, hide_show, menu_type, menu_order, product_category)
    VALUES (14100100, 'Jurisdiction/Market', 14100000, 1, 0, 0, 10000000)
    PRINT ' Setup Menu 14100100 inserted.'
END
ELSE
BEGIN
    PRINT 'Setup Menu 14100100 already EXISTS.'
END

--Insert into application_functions
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 14100100)
BEGIN
    INSERT INTO application_functions (function_id, function_name, function_desc, func_ref_id, document_path, file_path, book_required)
    VALUES (14100100, 'Jurisdiction/Market', 'Compliance Jurisdiction', NULL, NULL, '_setup/compliance_jurisdiction/compliance.jurisdiction.php', 0)
    PRINT ' Inserted 14100100 - Jurisdiction/Market.'
END
ELSE
BEGIN
    PRINT 'Application FunctionID 14100100 - Jurisdiction/Market already EXISTS.'
END

/* Add/Save */

--Insert into application_functions
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 14100101)
BEGIN
    INSERT INTO application_functions (function_id, function_name, function_desc, func_ref_id, document_path, file_path, book_required)
    VALUES (14100101, 'Add/Save', 'Add/Save', 14100100, NULL, NULL, 0)
    PRINT ' Inserted 14100101 - Add/Save.'
END
ELSE
BEGIN
    PRINT 'Application FunctionID 14100101 - Add/Save already EXISTS.'
END 

/* Delete */

--Insert into application_functions
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 14100102)
BEGIN
    INSERT INTO application_functions (function_id, function_name, function_desc, func_ref_id, document_path, file_path, book_required)
    VALUES (14100102, 'Delete', 'Delete', 14100100, NULL, NULL, 0)
    PRINT ' Inserted 14100102 - Delete.'
END
ELSE
BEGIN
    PRINT 'Application FunctionID 14100102 - Delete already EXISTS.'
END

/* Inventory Management */

--Insert into setup_menu
IF NOT EXISTS (SELECT 1 FROM setup_menu AS sm WHERE sm.function_id = 12130000 AND sm.product_category = 10000000)
BEGIN
    INSERT INTO setup_menu (function_id, display_name, hide_show, parent_menu_id, product_category, menu_order, menu_type)
    VALUES (12130000, 'Inventory Management', 1, 20014700, 10000000, 0, 1)
    PRINT 'Setup Menu 12130000 inserted.'
END
ELSE
BEGIN
    PRINT 'Setup Menu 12130000 already EXISTS.'
END

--Insert into setup_menu
IF NOT EXISTS (SELECT 1 FROM setup_menu AS sm WHERE sm.function_id = 20007900 AND sm.product_category = 10000000)
BEGIN
    INSERT INTO setup_menu (function_id, display_name, parent_menu_id, hide_show, menu_type, menu_order, product_category)
    VALUES (20007900, 'Match Environmental Product', 12130000, 1, 0, 0, 10000000)
    PRINT ' Setup Menu 20007900 inserted.'
END
ELSE
BEGIN
    PRINT 'Setup Menu 20007900 already EXISTS.'
END

--Insert into application_functions
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 20007900)
BEGIN
    INSERT INTO application_functions (function_id, function_name, function_desc, func_ref_id, document_path, file_path, book_required)
    VALUES (20007900, 'Match Environmental Product', 'Match RECs', NULL, NULL, '_deal_capture/buy_sell/buysell.match.php', 0)
    PRINT ' Inserted 20007900 - Match Environmental Product.'
END
ELSE
BEGIN
    PRINT 'Application FunctionID 20007900 - Match Environmental Product already EXISTS.'
END