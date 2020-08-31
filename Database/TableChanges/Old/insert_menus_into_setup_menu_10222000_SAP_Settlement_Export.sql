IF NOT EXISTS(SELECT * FROM setup_menu WHERE function_id = 10202201  AND product_category = 10000000)
BEGIN
    INSERT INTO setup_menu(function_id, window_name, display_name, default_parameter, hide_show, parent_menu_id, product_category, menu_order, menu_type)
    VALUES (10202201 , 'windowSAPSettlementExport', 'SAP Settlement Export', '', 1, 10220000 , 10000000, '', 0)
    PRINT 'SAP Settlement Export - 10202201 INSERTED.'
END
UPDATE setup_menu SET product_category = 10000000,display_name = 'SAP Settlement Export' WHERE function_id = 10202201
UPDATE application_functions SET file_path = '_settlement_billing/sap_export/sap_export.php',function_name = 'SAP Settlement Export',function_desc = 'SAP Settlement Export',function_call = 'windowSAPSettlementExport' WHERE function_id = 10202201
