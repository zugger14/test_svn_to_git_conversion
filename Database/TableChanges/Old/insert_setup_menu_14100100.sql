IF NOT EXISTS (
       SELECT 1
       FROM   setup_menu AS sm
       WHERE  sm.function_id = 14100100
              AND sm.product_category = 14000000
   )
BEGIN
    INSERT INTO setup_menu
      (
        function_id,
        window_name,
        display_name,
        hide_show,
        parent_menu_id,
        product_category,
        menu_order,
        menu_type
      )
    SELECT 14100100,
           NULL,
           'Compliance Jurisdiction',
           1,
           14100000,
           14000000,
           3,
           0
END
ELSE
BEGIN
    PRINT 'Menu already exist.'
END