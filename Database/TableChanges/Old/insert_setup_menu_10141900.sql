--Insert into setup_menu
IF NOT EXISTS (SELECT 1 FROM setup_menu AS sm WHERE sm.function_id = 10141900 AND sm.product_category = 10000000)
BEGIN
	INSERT INTO setup_menu(function_id, display_name, parent_menu_id, hide_show, menu_type, menu_order, product_category)
	VALUES (10141900, 'Load Forecast Report', 10202200, 0, 0, 0, 10000000)
	PRINT ' Setup Menu 10141900 inserted.'
END
ELSE
BEGIN
	PRINT 'Setup Menu 10141900 already EXISTS.'
END
    
           
