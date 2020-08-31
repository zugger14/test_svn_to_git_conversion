UPDATE s
SET s.parent_menu_id = 14000000
--SELECT *
FROM setup_menu s
WHERE s.function_id = 10110000
	AND s.product_category = 14000000