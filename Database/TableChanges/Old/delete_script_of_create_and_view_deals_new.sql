--Function ID 10132000 was made for Create and Deal View New menu which is not required now, hence deleted from every where it exists.

--Delete from application_functional_users
DELETE FROM application_functional_users
WHERE function_id = 10132000

--Delete from favourites_menu
DELETE FROM favourites_menu
WHERE function_id = 10132000

--Delete from application_functions
DELETE FROM application_functions
WHERE function_id = 10132000

--Delete from setup_menu
DELETE FROM setup_menu
WHERE function_id = 10132000