-- for eneco
IF NOT EXISTS(SELECT 1 FROM setup_menu WHERE function_id = 10201900 AND product_category = 15000000)
BEGIN
    INSERT INTO setup_menu(function_id, window_name, display_name, default_parameter, hide_show, parent_menu_id, product_category,
                           menu_order, menu_type)
    VALUES (10201900, 'windowDataImportExportAuditReport', 'Run Data Import/Export Audit Report', '', 1, 10221999, 15000000, 16, 0)
    PRINT 'Run Data Import/Export Audit Report - 10201900 INSERTED.'
END
ELSE
BEGIN
    PRINT 'Function ID 10201900 already exists.'
END

-- for others
IF NOT EXISTS(SELECT 1 FROM setup_menu WHERE function_id = 10201900 AND product_category = 10000000)
BEGIN
    INSERT INTO setup_menu(function_id, window_name, display_name, default_parameter, hide_show, parent_menu_id, product_category,
                           menu_order, menu_type)
    VALUES (10201900, 'windowDataImportExportAuditReport', 'Run Data Import/Export Audit Report', '', 1, 10200000, 10000000, 155, 0)
    PRINT 'Run Data Import/Export Audit Report - 10201900 INSERTED.'
END
ELSE
BEGIN
    PRINT 'Function ID 10201900 already exists.'
END

