--Update application_functions
UPDATE application_functions
SET function_name = 'Setup Regression Testing',
    function_desc = 'Setup Regression Testing',
    func_ref_id = NULL,
    file_path = '_reporting/regression_testing/setup.regerssion.testing.php',
    book_required = 0
    WHERE [function_id] = 20009400
PRINT 'Updated .'

--Update setup_menu
UPDATE setup_menu
SET display_name = 'Setup Regression Testing',
    parent_menu_id = 20013800,
    menu_type = 0,
    hide_show = 1,
	menu_order = 1
    WHERE [function_id] = 20009400
    AND [product_category]= 10000000
PRINT 'Updated Setup Menu.'
