IF NOT EXISTS(SELECT 1 FROM setup_menu WHERE  function_id = 10132300)
BEGIN
    INSERT INTO setup_menu (function_id, window_name, display_name, default_parameter, hide_show, parent_menu_id, product_category, menu_order, menu_type)
    VALUES (10132300, 'windowMaintainCNGDeals', 'Setup CNG Deals', '', 1, 10130000, 10000000, 72, 0)
END