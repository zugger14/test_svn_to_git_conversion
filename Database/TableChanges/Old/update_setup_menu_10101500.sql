UPDATE setup_menu
SET
	display_name = 'Setup Netting Group'
WHERE  function_id = 10101500
       AND product_category = 10000000

UPDATE setup_menu 
SET parent_menu_id = 10100000,
menu_order = 16
WHERE display_name = 'Setup Netting Group' 
	AND product_category = 10000000
	AND function_id = 10101500

       
     
