IF NOT EXISTS(SELECT * FROM setup_menu WHERE function_id = 12103200 AND product_category = 14000000)
BEGIN
 	INSERT INTO setup_menu(function_id, display_name, parent_menu_id, window_name, product_category, menu_order, hide_show, menu_type)
	VALUES (12103200, 'Setup REC Assignment Priority', 14100000, 'windowSetupRECAssignmentPriority', 14000000, 1, 1, 0)
 	PRINT ' Inserted 12103200 - Setup REC Assignment Priority.'
END
ELSE
BEGIN
	UPDATE setup_menu
	SET
		display_name = 'Setup REC Assignment Priority',
		menu_type = 0
	WHERE function_id = 12103200
	PRINT 'setup_menu FunctionID 12103200 -Setup REC Assignment Priority already EXISTS.'
END
GO


       
     
