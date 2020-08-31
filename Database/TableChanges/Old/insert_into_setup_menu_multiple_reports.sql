
IF NOT EXISTS (SELECT * FROM setup_menu WHERE function_id = 10235400 AND product_category = 13000000)
BEGIN
	INSERT INTO setup_menu (
		function_id
		, display_name
		, hide_show
		, parent_menu_id
		, product_category
		, menu_order)
	SELECT 10235400, 'Journal Entry Report', 0, 10202200, 13000000, 10
END

IF NOT EXISTS (SELECT * FROM setup_menu WHERE function_id = 10233900 AND product_category = 13000000)
BEGIN
	INSERT INTO setup_menu (
		function_id
		, display_name
		, hide_show
		, parent_menu_id
		, product_category
		, menu_order)
	SELECT 10233900, 'Hedging Relationship Report', 0, 10202200, 13000000, 11
END

IF NOT EXISTS (SELECT * FROM setup_menu WHERE function_id = 10236500 AND product_category = 13000000)
BEGIN
	INSERT INTO setup_menu (
		function_id
		, display_name
		, hide_show
		, parent_menu_id
		, product_category
		, menu_order)
	SELECT 10236500, 'Not Mapped Transaction Report', 0, 10202200, 13000000, 12
END

IF NOT EXISTS (SELECT * FROM setup_menu WHERE function_id = 10235500 AND product_category = 13000000)
BEGIN
	INSERT INTO setup_menu (
		function_id
		, display_name
		, hide_show
		, parent_menu_id
		, product_category
		, menu_order)
	SELECT 10235500, 'Netted Journal Entry Report', 0, 10202200, 13000000, 13
END

IF NOT EXISTS (SELECT * FROM setup_menu WHERE function_id = 10236600 AND product_category = 13000000)
BEGIN
	INSERT INTO setup_menu (
		function_id
		, display_name
		, hide_show
		, parent_menu_id
		, product_category
		, menu_order)
	SELECT 10236600, 'Tagging Audit Report', 0, 10202200, 13000000, 14
END

IF NOT EXISTS (SELECT * FROM setup_menu WHERE function_id = 13121200 AND product_category = 13000000)
BEGIN
	INSERT INTO setup_menu (
		function_id
		, display_name
		, hide_show
		, parent_menu_id
		, product_category
		, menu_order)
	SELECT 13121200, 'Hedge Ineffectiveness Report', 0, 10202200, 13000000, 15
END

IF NOT EXISTS (SELECT * FROM setup_menu WHERE function_id = 10232800 AND product_category = 13000000)
BEGIN
	INSERT INTO setup_menu (
		function_id
		, display_name
		, hide_show
		, parent_menu_id
		, product_category
		, menu_order)
	SELECT 10232800, 'Import Audit Report', 0, 10202200, 13000000, 16
END