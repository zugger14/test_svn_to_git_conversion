
IF NOT EXISTS(SELECT 1 FROM setup_menu WHERE function_id = 10131000 AND product_category = 13000000)  
BEGIN 
	INSERT INTO setup_menu(function_id, window_name, display_name, default_parameter, hide_show, parent_menu_id, product_category,menu_order, menu_type) 
	VALUES (10131000, 'windowMaintainDeals', 'Create and View Deal', NULL, 1 , 10130000, 13000000, 50,  0) 
END 
 ELSE 
BEGIN
	UPDATE setup_menu SET display_name = 'Create and View Deal', hide_show = 1, parent_menu_id = 10130000  WHERE function_id = 10131000 AND product_category = 13000000
END

IF NOT EXISTS(SELECT 1 FROM setup_menu WHERE function_id = 10202500 AND product_category = 13000000)  
BEGIN
 	INSERT INTO setup_menu(function_id, window_name, display_name, default_parameter, hide_show, parent_menu_id, product_category,menu_order, menu_type)
 	VALUES (10202500, NULL, 'Report Manager', NULL, 1 , 13121295, 13000000, 145,  1) 
END 
ELSE 
BEGIN
	UPDATE setup_menu SET display_name = 'Report Manager', hide_show = 1, parent_menu_id = 13121295  WHERE function_id = 10202500 AND product_category = 13000000
END
	
 
IF NOT EXISTS(SELECT 1 FROM setup_menu WHERE function_id = 10201600 AND product_category = 13000000)  
BEGIN 
	INSERT INTO setup_menu(function_id, window_name, display_name, default_parameter, hide_show, parent_menu_id, product_category,menu_order, menu_type)
	VALUES (10201600, 'windowReportManager', 'Report Manager - Old', NULL, 1 , 13121295, 13000000, 125,  0) 
END  
ELSE 
BEGIN
	UPDATE setup_menu SET display_name = 'Report Manager - Old', hide_show = 1, parent_menu_id = 13121295  WHERE function_id = 10201600 AND product_category = 13000000
END
	