IF EXISTS (SELECT 1 FROM setup_menu WHERE product_category = 13000000 AND function_id = 10235400)
BEGIN
	UPDATE setup_menu
	SET
	display_name = 'Journal Entries Report',
	window_name = 'NULL',
	parent_menu_id = 10202200,
	menu_type = 0
	WHERE   function_id = 10235400  AND product_category = 13000000
END


IF EXISTS (SELECT 1 FROM setup_menu WHERE )
BEGIN
	UPDATE setup_menu
	SET
	display_name = 'Netted Journal Entry Report',
	window_name = 'NULL',
	parent_menu_id = 10202200,
	menu_type = 0
	where 
	product_category = 13000000 AND function_id = 10235500
END

IF EXISTS (SELECT 1 FROM application_functions WHERE function_id = 10235400)
BEGIN
	UPDATE application_functions 
	SET 
	function_name = 'Journal Entry Report',
	function_desc = 'Journal Entry Report' 
	WHERE function_id = 10235400
END

IF EXISTS (SELECT 1 FROM application_functions WHERE function_id = 10235500)
BEGIN
	UPDATE application_functions 
	SET 
	function_name = 'Netted Journal Entry Report',
	function_desc = 'Netted Journal Entry Report' 
	WHERE function_id = 10235400
END

if exists (Select 1 from setup_menu where function_id = 10232800 and parent_menu_id =13180000 and product_category = 13000000 )
Begin 
DELETE  from setup_menu 
WHERE
function_id = 10232800
AND 
parent_menu_id = 13180000
AND 
product_category = 13000000
END

