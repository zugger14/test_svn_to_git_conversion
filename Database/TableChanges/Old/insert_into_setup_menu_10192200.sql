/**
* insert menu 'Calculate Credit Value Adjustment' under module 'Credit Risk And Analysis'.
* 2013/03/27
* sligal
**/
IF NOT EXISTS(SELECT 1 FROM setup_menu WHERE function_id = 10192200)
BEGIN
    INSERT INTO setup_menu(function_id, window_name, display_name, default_parameter, hide_show, parent_menu_id, product_category, menu_order, menu_type)
    VALUES (10192200, 'windowCalcCreditValueAdjustment', 'Calculate Credit Value Adjustment', '', 1, 10190000, 10000000, '', 0)
    PRINT 'Calculate Credit Value Adjustment - 10192200 INSERTED.'
END
ELSE
BEGIN
    PRINT 'Function ID 10192200 already exists.'
END
GO

/**
* insert menu 'Run Credit Value Adjustment Report' under module 'Credit Risk And Analysis'.
* 2013/04/01
* sligal
**/
IF NOT EXISTS(SELECT 1 FROM setup_menu WHERE function_id = 10192300)
BEGIN
    INSERT INTO setup_menu(function_id, window_name, display_name, default_parameter, hide_show, parent_menu_id, product_category, menu_order, menu_type)
    VALUES (10192300, 'windowRunCreditValueAdjustmentReport', 'Run Credit Value Adjustment Report', '', 1, 10190000, 10000000, '', 0)
    PRINT 'Run Credit Value Adjustment Report - 10192300 INSERTED.'
END
ELSE
BEGIN
    PRINT 'Function ID 10192300 already exists.'
END
GO

