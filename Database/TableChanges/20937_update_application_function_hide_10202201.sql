--Export GL Entries
UPDATE setup_menu
SET
	hide_show = 0
WHERE function_id = 10202201 
	  AND product_category = 10000000	