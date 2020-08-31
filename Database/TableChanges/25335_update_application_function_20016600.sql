--Update application_functions
UPDATE application_functions
SET function_name = 'Setup Energy Conversion',
    function_desc = 'Setup Energy Conversion',
    func_ref_id = NULL,
    file_path = '_setup/setup_conversion_factor/setup_conversion_factor.php',
    book_required = 0
    WHERE [function_id] = 20016600
PRINT 'Updated .'

--Update setup_menu
UPDATE setup_menu
SET display_name = 'Setup Energy Conversion',
    parent_menu_id = 10101099,
    menu_type = 0,
    hide_show = 1
    WHERE [function_id] = 20016600
    AND [product_category]= 10000000
PRINT 'Updated Setup Menu.'            