/* TRMTracker Section*/

--Insert into setup_menu
IF NOT EXISTS (SELECT 1 FROM setup_menu AS sm WHERE sm.function_id = 20014000 AND sm.product_category = 10000000)
BEGIN
    INSERT INTO setup_menu (function_id, display_name, hide_show, parent_menu_id, product_category, menu_order, menu_type)
    VALUES (20014000, 'Administration', 1, 10000000, 10000000, 0, 1)
    PRINT 'Setup Menu 20014000 inserted.'
END
ELSE
BEGIN
    PRINT 'Setup Menu 20014000 already EXISTS.'
END

--Insert into setup_menu
IF NOT EXISTS (SELECT 1 FROM setup_menu AS sm WHERE sm.function_id = 20014100 AND sm.product_category = 10000000)
BEGIN
    INSERT INTO setup_menu (function_id, display_name, hide_show, parent_menu_id, product_category, menu_order, menu_type)
    VALUES (20014100, 'Front Office', 1, 10000000, 10000000, 0, 1)
    PRINT 'Setup Menu 20014100 inserted.'
END
ELSE
BEGIN
    PRINT 'Setup Menu 20014100 already EXISTS.'
END

--Insert into setup_menu
IF NOT EXISTS (SELECT 1 FROM setup_menu AS sm WHERE sm.function_id = 20014200 AND sm.product_category = 10000000)
BEGIN
    INSERT INTO setup_menu (function_id, display_name, hide_show, parent_menu_id, product_category, menu_order, menu_type)
    VALUES (20014200, 'Middle Office', 1, 10000000, 10000000, 0, 1)
    PRINT 'Setup Menu 20014200 inserted.'
END
ELSE
BEGIN
    PRINT 'Setup Menu 20014200 already EXISTS.'
END
            
--Insert into setup_menu
IF NOT EXISTS (SELECT 1 FROM setup_menu AS sm WHERE sm.function_id = 20014300 AND sm.product_category = 10000000)
BEGIN
    INSERT INTO setup_menu (function_id, display_name, hide_show, parent_menu_id, product_category, menu_order, menu_type)
    VALUES (20014300, 'Back Office', 1, 10000000, 10000000, 0, 1)
    PRINT 'Setup Menu 20014300 inserted.'
END
ELSE
BEGIN
    PRINT 'Setup Menu 20014300 already EXISTS.'
END
            
/* FASTracker Section */

--Insert into setup_menu
IF NOT EXISTS (SELECT 1 FROM setup_menu AS sm WHERE sm.function_id = 20014000 AND sm.product_category = 13000000)
BEGIN
    INSERT INTO setup_menu (function_id, display_name, hide_show, parent_menu_id, product_category, menu_order, menu_type)
    VALUES (20014000, 'Administration', 1, 13000000, 13000000, 0, 1)
    PRINT 'Setup Menu 20014000 inserted.'
END
ELSE
BEGIN
    PRINT 'Setup Menu 20014000 already EXISTS.'
END
    
--Insert into setup_menu
IF NOT EXISTS (SELECT 1 FROM setup_menu AS sm WHERE sm.function_id = 20014400 AND sm.product_category = 13000000)
BEGIN
    INSERT INTO setup_menu (function_id, display_name, hide_show, parent_menu_id, product_category, menu_order, menu_type)
    VALUES (20014400, 'Transaction Processing', 1, 13000000, 13000000, 0, 1)
    PRINT 'Setup Menu 20014400 inserted.'
END
ELSE
BEGIN
    PRINT 'Setup Menu 20014400 already EXISTS.'
END

--Insert into setup_menu
IF NOT EXISTS (SELECT 1 FROM setup_menu AS sm WHERE sm.function_id = 20014500 AND sm.product_category = 13000000)
BEGIN
    INSERT INTO setup_menu (function_id, display_name, hide_show, parent_menu_id, product_category, menu_order, menu_type)
    VALUES (20014500, 'Effectiveness Testing & Reporting', 1, 13000000, 13000000, 0, 1)
    PRINT 'Setup Menu 20014500 inserted.'
END
ELSE
BEGIN
    PRINT 'Setup Menu 20014500 already EXISTS.'
END

--Insert into setup_menu
IF NOT EXISTS (SELECT 1 FROM setup_menu AS sm WHERE sm.function_id = 20014600 AND sm.product_category = 13000000)
BEGIN
    INSERT INTO setup_menu (function_id, display_name, hide_show, parent_menu_id, product_category, menu_order, menu_type)
    VALUES (20014600, 'Journal Entry and Disclosure', 1, 13000000, 13000000, 0, 1)
    PRINT 'Setup Menu 20014600 inserted.'
END
ELSE
BEGIN
    PRINT 'Setup Menu 20014600 already EXISTS.'
END
                 
/* RECTracker Section */

--Insert into setup_menu
IF NOT EXISTS (SELECT 1 FROM setup_menu AS sm WHERE sm.function_id = 20014000 AND sm.product_category = 14000000)
BEGIN
    INSERT INTO setup_menu (function_id, display_name, hide_show, parent_menu_id, product_category, menu_order, menu_type)
    VALUES (20014000, 'Administration', 1, 14000000, 14000000, 0, 1)
    PRINT 'Setup Menu 20014000 inserted.'
END
ELSE
BEGIN
    PRINT 'Setup Menu 20014000 already EXISTS.'
END

--Insert into setup_menu
IF NOT EXISTS (SELECT 1 FROM setup_menu AS sm WHERE sm.function_id = 20014700 AND sm.product_category = 14000000)
BEGIN
    INSERT INTO setup_menu (function_id, display_name, hide_show, parent_menu_id, product_category, menu_order, menu_type)
    VALUES (20014700, 'Environmental Inventory', 1, 14000000, 14000000, 0, 1)
    PRINT 'Setup Menu 20014700 inserted.'
END
ELSE
BEGIN
    PRINT 'Setup Menu 20014700 already EXISTS.'
END

--Insert into setup_menu
IF NOT EXISTS (SELECT 1 FROM setup_menu AS sm WHERE sm.function_id = 20014200 AND sm.product_category = 14000000)
BEGIN
    INSERT INTO setup_menu (function_id, display_name, hide_show, parent_menu_id, product_category, menu_order, menu_type)
    VALUES (20014200, 'Middle Office', 1, 14000000, 14000000, 0, 1)
    PRINT 'Setup Menu 20014200 inserted.'
END
ELSE
BEGIN
    PRINT 'Setup Menu 20014200 already EXISTS.'
END

--Insert into setup_menu
IF NOT EXISTS (SELECT 1 FROM setup_menu AS sm WHERE sm.function_id = 20014300 AND sm.product_category = 14000000)
BEGIN
    INSERT INTO setup_menu (function_id, display_name, hide_show, parent_menu_id, product_category, menu_order, menu_type)
    VALUES (20014300, 'Back Office', 1, 14000000, 14000000, 0, 1)
    PRINT 'Setup Menu 20014300 inserted.'
END
ELSE
BEGIN
    PRINT 'Setup Menu 20014300 already EXISTS.'
END

/* SettlementTracker Section */

--Insert into setup_menu
IF NOT EXISTS (SELECT 1 FROM setup_menu AS sm WHERE sm.function_id = 20014000 AND sm.product_category = 15000000)
BEGIN
    INSERT INTO setup_menu (function_id, display_name, hide_show, parent_menu_id, product_category, menu_order, menu_type)
    VALUES (20014000, 'Administration', 1, 15000000, 15000000, 0, 1)
    PRINT 'Setup Menu 20014000 inserted.'
END
ELSE
BEGIN
    PRINT 'Setup Menu 20014000 already EXISTS.'
END

--Insert into setup_menu
IF NOT EXISTS (SELECT 1 FROM setup_menu AS sm WHERE sm.function_id = 20014800 AND sm.product_category = 15000000)
BEGIN
    INSERT INTO setup_menu (function_id, display_name, hide_show, parent_menu_id, product_category, menu_order, menu_type)
    VALUES (20014800, 'Contract Administration', 1, 15000000, 15000000, 0, 1)
    PRINT 'Setup Menu 20014800 inserted.'
END
ELSE
BEGIN
    PRINT 'Setup Menu 20014800 already EXISTS.'
END

--Insert into setup_menu
IF NOT EXISTS (SELECT 1 FROM setup_menu AS sm WHERE sm.function_id = 20014900 AND sm.product_category = 15000000)
BEGIN
    INSERT INTO setup_menu (function_id, display_name, hide_show, parent_menu_id, product_category, menu_order, menu_type)
    VALUES (20014900, 'Settlement', 1, 15000000, 15000000, 0, 1)
    PRINT 'Setup Menu 20014900 inserted.'
END
ELSE
BEGIN
    PRINT 'Setup Menu 20014900 already EXISTS.'
END

--Insert into setup_menu
IF NOT EXISTS (SELECT 1 FROM setup_menu AS sm WHERE sm.function_id = 20015000 AND sm.product_category = 15000000)
BEGIN
    INSERT INTO setup_menu (function_id, display_name, hide_show, parent_menu_id, product_category, menu_order, menu_type)
    VALUES (20015000, 'Accounting', 1, 15000000, 15000000, 0, 1)
    PRINT 'Setup Menu 20015000 inserted.'
END
ELSE
BEGIN
    PRINT 'Setup Menu 20015000 already EXISTS.'
END