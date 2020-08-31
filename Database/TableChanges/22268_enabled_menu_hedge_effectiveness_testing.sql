--add or update setup menu
IF EXISTS (SELECT 1 FROM setup_menu WHERE function_id = 13200000 AND product_category = 10000000)
BEGIN
	UPDATE setup_menu 
	SET parent_menu_id = 13240000
	WHERE function_id = 13200000 AND product_category = 10000000 
END
ELSE
BEGIN
	INSERT INTO setup_menu (function_id, display_name, hide_show, parent_menu_id, product_category, menu_order, menu_type)
    VALUES (13200000, 'Hedge Effectivenesss Testing', 1, 13240000, 10000000, 0, 1)
END

-- Show Hedge Effectiveness Assessment menu
UPDATE setup_menu
SET hide_show = 1
WHERE parent_menu_id = 13200000 AND product_category = 10000000 AND display_name = 'Hedge Effectiveness Assessment'


--Insert into application_functions for View/Update Cum PNL Series
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10237300)
BEGIN
    INSERT INTO application_functions (function_id, function_name, function_desc, func_ref_id, document_path, file_path, book_required)
    VALUES (10237300, 'View/Update Cum PNL Series', 'View/Update Cum PNL Series', NULL, NULL, '_accounting/derivative/transaction_processing/des_of_a_hedge/view.link.php?mode=r&function_id=10237300', 0)
    PRINT ' Inserted 10237300 - .'
END
ELSE
BEGIN
    UPDATE application_functions
	SET file_path = '_accounting/derivative/transaction_processing/des_of_a_hedge/view.link.php?mode=r&function_id=10237300'
	WHERE function_id = 10237300
END

--Insert into setup_menu View/Update Cum PNL Series
IF NOT EXISTS (SELECT 1 FROM setup_menu AS sm WHERE sm.function_id = 10237300 AND sm.product_category = 10000000)
BEGIN
    INSERT INTO setup_menu (function_id, display_name, parent_menu_id, hide_show, menu_type, menu_order, product_category)
    VALUES (10237300, 'View/Update Cum PNL Series', 13200000, 1, 0, 0, 10000000)
    PRINT ' Setup Menu 10237300 inserted.'
END
ELSE
BEGIN
    PRINT 'Setup Menu 10237300 already EXISTS.'
END            