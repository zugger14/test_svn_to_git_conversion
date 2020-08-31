IF NOT EXISTS(SELECT 1 FROM setup_menu WHERE function_id = 10161800 AND product_category = 10000000) 
BEGIN
	INSERT INTO setup_menu (function_id, window_name, display_name, hide_show, parent_menu_id, product_category, menu_order)
	VALUES (10161800, 'windowMaintainPowerOutage', 'Setup Plant Derate/Outage', 1, 10160000, 10000000, 16)	
END
ELSE
BEGIN
	UPDATE setup_menu
		set display_name = 'Setup Plant Derate/Outage'
		WHERE function_id = 10161800 AND product_category = 10000000
	PRINT 'Menu 10161800 - Setup Plant Derate/Outage already exists.'
END