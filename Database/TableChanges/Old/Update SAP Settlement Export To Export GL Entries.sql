IF EXISTS(Select 1 FROM setup_menu where display_name = 'SAP Settlement Export'  AND function_id = 10202201 AND product_category = '10000000' AND window_name IS NOT NULL )
	BEGIN
		UPDATE setup_menu SET display_name = 'Export GL Entries'	WHERE 
		display_name = 'SAP Settlement Export'  AND function_id = 10202201 AND product_category = '10000000' AND window_name IS NOT NULL 
	END
ELSE 
	PRINT 'Name already changed.'