--SELECT * FROM setup_menu sm WHERE sm.display_name LIKE 'deal capture%'

--SELECT * FROM setup_menu sm WHERE sm.parent_menu_id = 10131099 order by menu_order

UPDATE setup_menu
SET menu_order = 1
WHERE function_id = 10131000
AND parent_menu_id = 10131099
AND product_category = 13000000

UPDATE setup_menu
SET menu_order = 2
WHERE function_id = 10238000
AND parent_menu_id = 10131099
AND product_category = 13000000

UPDATE setup_menu
SET menu_order = 3
WHERE function_id = 10236500
AND parent_menu_id = 10131099
AND product_category = 13000000

UPDATE setup_menu
SET menu_order = 4
WHERE function_id = 10236000
AND parent_menu_id = 10131099
AND product_category = 13000000

UPDATE setup_menu
SET menu_order = 5
WHERE function_id = 10236600
AND parent_menu_id = 10131099
AND product_category = 13000000

UPDATE setup_menu
SET menu_order = 6
WHERE function_id = 10234800
AND parent_menu_id = 10131099
AND product_category = 13000000