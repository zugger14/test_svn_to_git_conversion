--Update application_functions
UPDATE application_functions
SET function_name = 'Maintain Deal Template - Old',
    function_desc = 'Maintain Deal Template - Old',
    func_ref_id = NULL,
    file_path = '_setup/maintain_deal_template/maintain.deal.template.php',
    book_required = 0
    WHERE [function_id] = 10101400
PRINT 'Updated .'

--Update setup_menu
UPDATE setup_menu
SET display_name = 'Setup Deal Template - Old',
    parent_menu_id = 10104099,
    menu_type = 0,
    hide_show = 1
    WHERE [function_id] = 10101400
    AND [product_category]= 10000000
PRINT 'Updated Setup Menu.'