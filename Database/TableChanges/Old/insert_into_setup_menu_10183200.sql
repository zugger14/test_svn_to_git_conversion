IF NOT EXISTS(SELECT 1 FROM setup_menu WHERE function_id = 10183200 AND product_category = 10000000) 
BEGIN
	INSERT INTO setup_menu (function_id, window_name, display_name, hide_show, parent_menu_id, product_category, menu_order)
	VALUES (10183200, 'MaintainPortfolioGroup', 'Setup Portfolio Group', 1, 10180000, 10000000, 118)	
END
ELSE
BEGIN
	UPDATE setup_menu
		set display_name = 'Setup Portfolio Group'
		WHERE function_id = 10183200 AND product_category = 10000000
	PRINT 'Menu 10183200 - Setup Portfolio Group already exists.'
END