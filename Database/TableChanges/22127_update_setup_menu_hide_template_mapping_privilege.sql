-- Hide 'Template Mapping Privilege' menu from Main Menu.
UPDATE setup_menu
SET hide_show = 0
WHERE function_id = 20008100

GO