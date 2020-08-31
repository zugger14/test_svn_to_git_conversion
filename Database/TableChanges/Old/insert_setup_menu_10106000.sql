IF NOT EXISTS(SELECT 1 FROM setup_menu WHERE function_id = 10106000 AND product_category = 10000000)
BEGIN
    INSERT INTO setup_menu (function_id, window_name, display_name, default_parameter, hide_show, parent_menu_id, product_category,
                           menu_order, menu_type)
    VALUES (10106000, 'windowNominationGroup', 'Assign Priority to Nomination Group', '', 1, 10160000, 10000000, 93, 0)
    PRINT 'Assign Priority to Nomination Group'
END
ELSE
BEGIN
    PRINT 'Function ID 10106000 already exists.'
END