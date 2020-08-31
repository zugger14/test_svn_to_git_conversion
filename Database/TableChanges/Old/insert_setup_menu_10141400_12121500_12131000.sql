IF NOT EXISTS (
       SELECT 1
       FROM   setup_menu AS sm
       WHERE  sm.function_id = 10141400
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
    SELECT 10141400,
           NULL,
           'Transcations Report',
           0,
           10202200,
           14000000,
           3,
           0
END
ELSE
BEGIN
    PRINT 'Transcations Report- Menu already exist.'
	UPDATE setup_menu SET hide_show = 0 WHERE  function_id = 10141400
              AND product_category = 14000000  
END

IF NOT EXISTS (
       SELECT 1
       FROM   setup_menu AS sm
       WHERE  sm.function_id = 12121500
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
    SELECT 12121500,
           NULL,
           'Lifecycle of Transactions',
           0,
           10202200,
           14000000,
           4,
           0
END
ELSE
BEGIN
    PRINT 'Lifecycle of Transactions- Menu already exist.'
	UPDATE setup_menu SET hide_show = 0 WHERE  function_id = 12121500
            AND product_category = 14000000 
END

IF NOT EXISTS (
       SELECT 1
       FROM   setup_menu AS sm
       WHERE  sm.function_id = 12131000
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
    SELECT 12131000,
           NULL,
           'Run Target Report',
           0,
           10202200,
           14000000,
           5,
           0
END
ELSE
BEGIN
    PRINT 'Run Target Report- Menu already exist.'
	UPDATE setup_menu SET hide_show = 0 WHERE  function_id = 12131000
        AND product_category = 14000000 
END
