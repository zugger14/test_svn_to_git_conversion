IF NOT EXISTS (SELECT 1 FROM setup_menu WHERE function_id = 10234200 AND product_category = 13000000)
BEGIN
  INSERT INTO setup_menu (function_id, display_name, hide_show, parent_menu_id, product_category, menu_order, menu_type)
    VALUES (10234200, 'Life Cycle of Hedges', 0, 10230095, 13000000, 1, 0)
END

 
IF NOT EXISTS (SELECT 1 FROM setup_menu WHERE function_id = 10202000 AND product_category = 13000000)
BEGIN
  INSERT INTO setup_menu (function_id, display_name, hide_show, parent_menu_id, product_category, menu_order, menu_type)
    VALUES (10202000, 'User Activity Log Report', 0, 10202200, 13000000, 1, 0)
END

 
IF NOT EXISTS (SELECT 1 FROM setup_menu WHERE function_id = 10202100 AND product_category = 13000000)
BEGIN
  INSERT INTO setup_menu (function_id, display_name, hide_show, parent_menu_id, product_category, menu_order, menu_type)
    VALUES (10202100, 'Message Board Log Report', 0, 10202200, 13000000, 1, 0)
END

 
IF NOT EXISTS (SELECT 1 FROM setup_menu WHERE function_id = 10111300 AND product_category = 13000000)
BEGIN
  INSERT INTO setup_menu (function_id, display_name, hide_show, parent_menu_id, product_category, menu_order, menu_type)
    VALUES (10111300, 'Privilege Report', 0, 10202200, 13000000, 1, 0)
END

 
IF NOT EXISTS (SELECT 1 FROM setup_menu WHERE function_id = 10111400 AND product_category = 13000000)
BEGIN
  INSERT INTO setup_menu (function_id, display_name, hide_show, parent_menu_id, product_category, menu_order, menu_type)
    VALUES (10111400, 'System Access Log Report', 0, 10202200, 13000000, 1, 0)
END

 
IF NOT EXISTS (SELECT 1 FROM setup_menu WHERE function_id = 10171100 AND product_category = 13000000)
BEGIN
  INSERT INTO setup_menu (function_id, display_name, hide_show, parent_menu_id, product_category, menu_order, menu_type)
    VALUES (10171100, 'Transaction Audit Log Report', 0, 10202200, 13000000, 1, 0)
END

 
IF NOT EXISTS (SELECT 1 FROM setup_menu WHERE function_id = 10201500 AND product_category = 13000000)
BEGIN
  INSERT INTO setup_menu (function_id, display_name, hide_show, parent_menu_id, product_category, menu_order, menu_type)
    VALUES (10201500, 'Static Data Audit Report', 0, 10202200, 13000000, 1, 0)
END

 
IF NOT EXISTS (SELECT 1 FROM setup_menu WHERE function_id = 10201900 AND product_category = 13000000)
BEGIN
  INSERT INTO setup_menu (function_id, display_name, hide_show, parent_menu_id, product_category, menu_order, menu_type)
    VALUES (10201900, 'Data Import/Export Audit Report', 0, 10202200, 13000000, 1, 0)
END

UPDATE setup_menu
SET parent_menu_id = 10202200
WHERE function_id = 10234200
	AND product_category = 13000000