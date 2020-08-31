/************************************************************
 * Code formatted by SoftTree SQL Assistant © v4.6.12
 * Time: 7/11/2013 10:41:34 AM
 ************************************************************/

IF NOT EXISTS(
       SELECT 1
       FROM   setup_menu
       WHERE  function_id = 13121200
              AND product_category = 10000000
   )
BEGIN
    INSERT INTO setup_menu
      (
        function_id,
        window_name,
        display_name,
        default_parameter,
        hide_show,
        parent_menu_id,
        product_category,
        menu_order,
        menu_type
      )
    VALUES
      (
        13121200,
        'windowRunHedgeIneffectivenessReport',
        'Run Hedge Ineffectiveness Report',
        '',
        1,
        10230093,
        10000000,
        '',
        0
      )
    PRINT 'Run Hedge Ineffectiveness Report - 13121200 INSERTED.'
END
ELSE
BEGIN
    PRINT 'Function ID 13121200 already exists.'
END

