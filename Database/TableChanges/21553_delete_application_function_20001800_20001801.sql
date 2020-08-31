--Deleting Unused application_function_id View/Edit Meter Data
DELETE FROM application_functional_users  WHERE function_id = 20001800
EXEC spa_application_ui_template 'd' ,20001800 
DELETE FROM favourites_menu WHERE function_id = 20001800
DELETE FROM menu_item WHERE function_id = 20001800
DELETE FROM wizard_page WHERE function_id = 20001800
DELETE FROM application_functions  WHERE function_id = 20001800
DELETE FROM setup_menu  WHERE function_id = 20001800

--Deleting Unused application_function_id View/Edit Meter Data
DELETE FROM application_functional_users  WHERE function_id = 20001801
EXEC spa_application_ui_template 'd' ,20001801 
DELETE FROM favourites_menu WHERE function_id = 20001801
DELETE FROM menu_item WHERE function_id = 20001801
DELETE FROM wizard_page WHERE function_id = 20001801
DELETE FROM application_functions  WHERE function_id = 20001801
DELETE FROM setup_menu  WHERE function_id = 20001801


