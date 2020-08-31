IF NOT EXISTS (SELECT 1 FROM setup_menu WHERE function_id = 10111300 AND product_category = 13000000)
BEGIN 
	INSERT INTO setup_menu (function_id, display_name, hide_show, parent_menu_id, product_category, menu_order, menu_type)
	VALUES (10111300, 'Privilege Report',  0, 10202200, 13000000, 8, 0)
	PRINT 'Privilege Report 10111300 INSERTED for FASTracker.'
END
ELSE
BEGIN
	PRINT 'Privilege Report 10111300 for FASTracker already exists.'
END

IF NOT EXISTS (SELECT 1 FROM setup_menu WHERE function_id = 10111400 AND product_category = 13000000)
BEGIN 
	INSERT INTO setup_menu (function_id, display_name, hide_show, parent_menu_id, product_category, menu_order, menu_type)
	VALUES (10111400, 'System Access Log Report',  0, 10202200, 13000000, 9, 0)
	PRINT 'System Access Log Report 10111400 INSERTED for FASTracker.'
END
ELSE
BEGIN
	PRINT 'System Access Log Report 10111400 for FASTracker already exists.'
END
	
IF NOT EXISTS (SELECT 1 FROM setup_menu WHERE function_id = 10171100 AND product_category = 13000000)
BEGIN 
	INSERT INTO setup_menu (function_id, display_name, hide_show, parent_menu_id, product_category, menu_order, menu_type)
	VALUES (10171100, 'Transaction Audit Log Report',  0, 10202200, 13000000, 10, 0)
	PRINT 'Transaction Audit Log Report 10171100 INSERTED for FASTracker.'
END
ELSE
BEGIN
	PRINT 'Transaction Audit Log Report 10171100 for FASTracker already exists.'
END

IF NOT EXISTS (SELECT 1 FROM setup_menu WHERE function_id = 10201500 AND product_category = 13000000)
BEGIN 
	INSERT INTO setup_menu (function_id, display_name, hide_show, parent_menu_id, product_category, menu_order, menu_type)
	VALUES (10201500, 'Static Data Audit Report',  0, 10202200, 13000000, 11, 0)
	PRINT 'Static Data Audit Report 10201500 INSERTED for FASTracker.'
END
ELSE
BEGIN
	PRINT 'Static Data Audit Report 10201500 for FASTracker already exists.'
END

IF NOT EXISTS (SELECT 1 FROM setup_menu WHERE function_id = 10201900 AND product_category = 13000000)
BEGIN 
	INSERT INTO setup_menu (function_id, display_name, hide_show, parent_menu_id, product_category, menu_order, menu_type)
	VALUES (10201900, 'Data Import/Export Audit Report',  0, 10202200, 13000000, 12, 0)
	PRINT 'Data Import/Export Audit Report 10201900 INSERTED for FASTracker.'
END
ELSE
BEGIN
	PRINT 'Data Import/Export Audit Report 10201900 for FASTracker already exists.'
END	

IF NOT EXISTS (SELECT 1 FROM setup_menu WHERE function_id = 10202000 AND product_category = 13000000)
BEGIN 
	INSERT INTO setup_menu (function_id, display_name, hide_show, parent_menu_id, product_category, menu_order, menu_type)
	VALUES (10202000, 'User Activity Log Report',  0, 10202200, 13000000, 3, 0)
	PRINT 'User Activity Log Report 10202000 INSERTED for FASTracker.'
END
ELSE
BEGIN
	PRINT 'User Activity Log Report 10202000 for FASTracker already exists.'
END	

IF NOT EXISTS (SELECT 1 FROM setup_menu WHERE function_id = 10202100 AND product_category = 13000000)
BEGIN 
	INSERT INTO setup_menu (function_id, display_name, hide_show, parent_menu_id, product_category, menu_order, menu_type)
	VALUES (10202100, 'Message Board Log Report',  0, 10202200, 13000000, 4, 0)
	PRINT 'Message Board Log Report 10202100 INSERTED for FASTracker.'
END
ELSE
BEGIN
	PRINT 'Message Board Log Report 10202100 for FASTracker already exists.'
END	

IF NOT EXISTS (SELECT 1 FROM setup_menu WHERE function_id = 10234200 AND product_category = 13000000)
BEGIN 
	INSERT INTO setup_menu (function_id, display_name, hide_show, parent_menu_id, product_category, menu_order, menu_type)
	VALUES (10234200, 'Life Cycle of Hedges',  0, 10202200, 13000000, 5, 0)
	PRINT 'Life Cycle of Hedges 10234200 INSERTED for FASTracker.'
END
ELSE
BEGIN
	PRINT 'Life Cycle of Hedges 10234200 for FASTracker already exists.'
END	