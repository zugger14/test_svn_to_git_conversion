IF EXISTS(SELECT 1 FROM setup_menu WHERE function_id = 10103300 and product_category = 10000000 and display_name = 'Setup GL Group')
BEGIN
UPDATE
	setup_menu
	SET
	parent_menu_id = 15190000
	WHERE
	function_id = 10103300
	AND 
	display_name = 'Setup GL Group'
	AND
	product_category = 10000000
END