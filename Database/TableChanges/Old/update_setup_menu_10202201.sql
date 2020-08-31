IF EXISTS(SELECT 1 FROM setup_menu WHERE function_id = 10202201  AND product_category = 10000000)
BEGIN
	UPDATE 
	setup_menu
	SET parent_menu_id = 10220000
	WHERE
	function_id = 10202201 AND display_name = 'SAP Settlement Export' AND product_category = 10000000
END
ELSE PRINT 'Function id does not exists.'