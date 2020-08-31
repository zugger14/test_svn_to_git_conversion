--Update application_functions
UPDATE application_functions
SET function_name = 'Setup Shipper Code Mapping',
    function_desc = 'Setup Shipper Code Mapping',
    func_ref_id = NULL,
    file_path = '_setup/setup_shipper_code_mapping/setup_shipper_code_mapping.php',
    book_required = 0
    WHERE [function_id] = 20016500
PRINT 'Updated .'

--Update setup_menu
UPDATE setup_menu
SET display_name = 'Setup Shipper Code Mapping',
    parent_menu_id = 10101099,
    menu_type = 0,
    hide_show = 1
    WHERE [function_id] = 20016500
    AND [product_category]= 10000000
PRINT 'Updated Setup Menu.'            