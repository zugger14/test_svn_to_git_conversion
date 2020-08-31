--Update setup_menu
UPDATE setup_menu
SET display_name = 'Workflow',
    hide_show = 1,
    parent_menu_id = 10100000,
    menu_type = 1
    WHERE [function_id] = 10106699
    AND [product_category]= 10000000
PRINT 'Updated Setup Menu.'