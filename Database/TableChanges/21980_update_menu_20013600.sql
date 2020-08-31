--Update application_functions
UPDATE application_functions
SET function_name = 'Setup Regression Testing Module',
    function_desc = 'Setup Regression Testing Configuration',
    func_ref_id = NULL,
    file_path = '_setup/setup_regression_testing_configuration/setup.regression.testing.configuration.php',
    book_required = 0
    WHERE [function_id] = 20013600
PRINT 'Updated .'

--Update setup_menu
UPDATE setup_menu
SET display_name = 'Setup Regression Testing Module',
    parent_menu_id = 20013800,
    menu_type = 0,
    hide_show = 1
    WHERE [function_id] = 20013600
    AND [product_category]= 10000000
PRINT 'Updated Setup Menu.'