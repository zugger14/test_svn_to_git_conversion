--Deleting Assign Transaction as Assign/Unassign Transaction is renamed to Assign Transaction
DELETE FROM application_functional_users  WHERE function_id = 14121410
EXEC spa_application_ui_template 'd' ,14121410 
DELETE FROM favourites_menu WHERE function_id = 14121410
DELETE FROM menu_item WHERE function_id = 14121410
DELETE FROM wizard_page WHERE function_id = 14121410
DELETE FROM application_functions  WHERE function_id = 14121410
DELETE FROM setup_menu  WHERE function_id = 14121410

--Deleting Unassign Transaction as it is being created in application function ID 14121500
DELETE FROM application_functional_users WHERE function_id = 14121411EXEC spa_application_ui_template 'd' ,14121411  
DELETE FROM favourites_menu WHERE function_id = 14121411
DELETE FROM menu_item WHERE function_id = 14121411
DELETE FROM wizard_page WHERE function_id = 14121411
DELETE FROM application_functions  WHERE function_id = 14121411
DELETE FROM setup_menu  WHERE function_id = 14121411
