IF NOT EXISTS (SELECT 1 FROM setup_menu WHERE function_id = 12101720)
BEGIN
  INSERT INTO setup_menu (function_id, window_name, display_name, hide_show, parent_menu_id, product_category, menu_order, menu_type)
  VALUES (12101720, 'windowAssignmentForm', 'Assignment Form', 0, 12101700, 14000000, 50, 0)
END