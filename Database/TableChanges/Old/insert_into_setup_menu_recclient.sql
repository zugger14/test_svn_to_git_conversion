IF NOT EXISTS (SELECT 1 FROM setup_menu WHERE function_id = 14000000 AND product_category = 14000000)
BEGIN
	INSERT INTO setup_menu (function_id, window_name, display_name, default_parameter, hide_show, parent_menu_id, product_category, menu_order, menu_type)
	VALUES (14000000, NULL, 'RECTracker', NULL, 1, NULL, 14000000, 1, 1)
END

--Setup Start
IF NOT EXISTS (SELECT 1 FROM setup_menu WHERE function_id = 10100000 AND product_category = 14000000)
BEGIN
	INSERT INTO setup_menu (function_id, window_name, display_name, default_parameter, hide_show, parent_menu_id, product_category, menu_order, menu_type)
	VALUES (10100000, NULL, 'Setup', NULL, 1, 14000000, 14000000, 1, 1)
END


IF NOT EXISTS(SELECT 1 FROM setup_menu WHERE function_id = 10122500 AND product_category = 14000000)
BEGIN
	INSERT INTO setup_menu (function_id, window_name, display_name, default_parameter, hide_show, parent_menu_id, product_category, menu_order, menu_type)
	VALUES (10122500, 'windowSetupAlerts', 'Setup Alert', NULL, 1, 10106699, 14000000, 48, 0)
END


IF NOT EXISTS(SELECT 1 FROM setup_menu WHERE function_id = 10106600 AND product_category = 14000000)
BEGIN
	INSERT INTO setup_menu (function_id, window_name, display_name, default_parameter, hide_show, parent_menu_id, product_category, menu_order, menu_type)
	VALUES (10106600, 'windowRulesWorkflow', 'Setup Rule Workflow', NULL, 1, 10106699, 14000000, 52, 0)
END


IF NOT EXISTS(SELECT 1 FROM setup_menu WHERE function_id = 10106700 AND product_category = 14000000)
BEGIN
	INSERT INTO setup_menu (function_id, window_name, display_name, default_parameter, hide_show, parent_menu_id, product_category, menu_order, menu_type)
	VALUES (10106700, 'windowManageApproval', 'Manage Approval', NULL, 1, 10106699, 14000000, 53, 0)
END


IF NOT EXISTS(SELECT 1 FROM setup_menu WHERE function_id = 10106699 AND product_category = 14000000)
BEGIN
	INSERT INTO setup_menu (function_id, window_name, display_name, default_parameter, hide_show, parent_menu_id, product_category, menu_order, menu_type)
	VALUES (10106699, 'NULL', 'Alert and Workflow', NULL, 1, 10100000, 14000000, 1, 1)
END


IF NOT EXISTS(SELECT 1 FROM setup_menu WHERE function_id = 10106300 AND product_category = 14000000)
BEGIN
	INSERT INTO setup_menu (function_id, window_name, display_name, default_parameter, hide_show, parent_menu_id, product_category, menu_order, menu_type)
	VALUES (10106300, 'windowDataImportNewUI', 'Data Import/Export', NULL, 1, 10106399, 14000000, 112, 0)
END


IF NOT EXISTS(SELECT 1 FROM setup_menu WHERE function_id = 10131300 AND product_category = 14000000)
BEGIN
	INSERT INTO setup_menu (function_id, window_name, display_name, default_parameter, hide_show, parent_menu_id, product_category, menu_order, menu_type)
	VALUES (10131300, 'windowImportDataDeal', 'Import Data', NULL, 1, 10106399, 14000000, 51, 0)
END


IF NOT EXISTS(SELECT 1 FROM setup_menu WHERE function_id = 10104800 AND product_category = 14000000)
BEGIN
	INSERT INTO setup_menu (function_id, window_name, display_name, default_parameter, hide_show, parent_menu_id, product_category, menu_order, menu_type)
	VALUES (10104800, 'windowDataImportExport', 'Data Import/Export', NULL, 0, 10100000, 14000000, 41, NULL)
END


IF NOT EXISTS(SELECT 1 FROM setup_menu WHERE function_id = 10106399 AND product_category = 14000000)
BEGIN
	INSERT INTO setup_menu (function_id, window_name, display_name, default_parameter, hide_show, parent_menu_id, product_category, menu_order, menu_type)
	VALUES (10106399, 'NULL', 'Data Import', NULL, 1, 10100000, 14000000, 1, 1)
END

IF NOT EXISTS(SELECT 1 FROM setup_menu WHERE function_id = 10102900 AND product_category = 14000000)
BEGIN
	INSERT INTO setup_menu (function_id, window_name, display_name, default_parameter, hide_show, parent_menu_id, product_category, menu_order, menu_type)
	VALUES (10102900, 'windowManageDocumentsMain', 'Manage Document', NULL, 1, 10100000, 14000000, 27, 0)
END


IF NOT EXISTS(SELECT 1 FROM setup_menu WHERE function_id = 10101099 AND product_category = 14000000)
BEGIN
	INSERT INTO setup_menu (function_id, window_name, display_name, default_parameter, hide_show, parent_menu_id, product_category, menu_order, menu_type)
	VALUES (10101099, 'NULL', 'Reference Data', NULL, 1, 10100000, 14000000, 1, 1)
END


IF NOT EXISTS(SELECT 1 FROM setup_menu WHERE function_id = 10101000 AND product_category = 14000000)
BEGIN
	INSERT INTO setup_menu (function_id, window_name, display_name, default_parameter, hide_show, parent_menu_id, product_category, menu_order, menu_type)
	VALUES (10101000, 'windowMaintainStaticData', 'Setup Static Data', NULL, 1, 10101099, 14000000, 2, 0)
END


IF NOT EXISTS(SELECT 1 FROM setup_menu WHERE function_id = 10101200 AND product_category = 14000000)
BEGIN
	INSERT INTO setup_menu (function_id, window_name, display_name, default_parameter, hide_show, parent_menu_id, product_category, menu_order, menu_type)
	VALUES (10101200, 'windowSetupHedgingStrategies', 'Setup Book Structure', NULL, 1, 10101099, 14000000, 3, 0)
END


IF NOT EXISTS(SELECT 1 FROM setup_menu WHERE function_id = 10102600 AND product_category = 14000000)
BEGIN
	INSERT INTO setup_menu (function_id, window_name, display_name, default_parameter, hide_show, parent_menu_id, product_category, menu_order, menu_type)
	VALUES (10102600, 'windowSetupPriceCurves', 'Setup Price Curve', NULL, 1, 10101099, 14000000, 4, 0)
END


IF NOT EXISTS(SELECT 1 FROM setup_menu WHERE function_id = 10102500 AND product_category = 14000000)
BEGIN
	INSERT INTO setup_menu (function_id, window_name, display_name, default_parameter, hide_show, parent_menu_id, product_category, menu_order, menu_type)
	VALUES (10102500, 'windowSetupLocation', 'Setup Location', NULL, 1, 10101099, 14000000, 5, 0)
END


IF NOT EXISTS(SELECT 1 FROM setup_menu WHERE function_id = 10103000 AND product_category = 14000000)
BEGIN
	INSERT INTO setup_menu (function_id, window_name, display_name, default_parameter, hide_show, parent_menu_id, product_category, menu_order, menu_type)
	VALUES (10103000, 'windowDefineMeterID', 'Setup Meter', NULL, 1, 10101099, 14000000, 20, 0)
END


IF NOT EXISTS(SELECT 1 FROM setup_menu WHERE function_id = 10102400 AND product_category = 14000000)
BEGIN
	INSERT INTO setup_menu (function_id, window_name, display_name, default_parameter, hide_show, parent_menu_id, product_category, menu_order, menu_type)
	VALUES (10102400, 'windowFormulaBuilder', 'Formula Builder', NULL, 1, 10104099, 14000000, 29, 0)
END


IF NOT EXISTS(SELECT 1 FROM setup_menu WHERE function_id = 13102000 AND product_category = 14000000)
BEGIN
	INSERT INTO setup_menu (function_id, window_name, display_name, default_parameter, hide_show, parent_menu_id, product_category, menu_order, menu_type)
	VALUES (13102000, 'windowGenericMapping', 'Generic Mapping', NULL, 1, 10106499, 14000000, 34, 0)
END


IF NOT EXISTS(SELECT 1 FROM setup_menu WHERE function_id = 10101400 AND product_category = 14000000)
BEGIN
	INSERT INTO setup_menu (function_id, window_name, display_name, default_parameter, hide_show, parent_menu_id, product_category, menu_order, menu_type)
	VALUES (10101400, 'windowMaintainDealTemplate', 'Setup Deal Template', NULL, 1, 10104099, 14000000, 12, 0)
END


IF NOT EXISTS(SELECT 1 FROM setup_menu WHERE function_id = 10104200 AND product_category = 14000000)
BEGIN
	INSERT INTO setup_menu (function_id, window_name, display_name, default_parameter, hide_show, parent_menu_id, product_category, menu_order, menu_type)
	VALUES (10104200, 'windowSetupFieldTemplate', 'Setup Deal Field Template', NULL, 1, 10104099, 14000000, 13, 0)
END


IF NOT EXISTS(SELECT 1 FROM setup_menu WHERE function_id = 10101182 AND product_category = 14000000)
BEGIN
	INSERT INTO setup_menu (function_id, window_name, display_name, default_parameter, hide_show, parent_menu_id, product_category, menu_order, menu_type)
	VALUES (10101182, 'WindowDefineUOMConversion', 'Setup UOM Conversion', NULL, 1, 10101099, 14000000, 8, 0)
END


IF NOT EXISTS(SELECT 1 FROM setup_menu WHERE function_id = 10105800 AND product_category = 14000000)
BEGIN
	INSERT INTO setup_menu (function_id, window_name, display_name, default_parameter, hide_show, parent_menu_id, product_category, menu_order, menu_type)
	VALUES (10105800, 'windowSetupCounterparty', 'Setup Counterparty', NULL, 1, 10101099, 14000000, 7, 0)
END


IF NOT EXISTS(SELECT 1 FROM setup_menu WHERE function_id = 10211213 AND product_category = 14000000)
BEGIN
	INSERT INTO setup_menu (function_id, window_name, display_name, default_parameter, hide_show, parent_menu_id, product_category, menu_order, menu_type)
	VALUES (10211213, 'windowReportTemplateSetup', 'Setup Custom Report Template', NULL, 1, 10104099, 14000000, 9, 0)
END


IF NOT EXISTS(SELECT 1 FROM setup_menu WHERE function_id = 10104100 AND product_category = 14000000)
BEGIN
	INSERT INTO setup_menu (function_id, window_name, display_name, default_parameter, hide_show, parent_menu_id, product_category, menu_order, menu_type)
	VALUES (10104100, 'windowSetupUDFTemplate', 'Setup UDF Template', NULL, 1, 10104099, 14000000, 14, NULL)
END


IF NOT EXISTS(SELECT 1 FROM setup_menu WHERE function_id = 10102800 AND product_category = 14000000)
BEGIN
	INSERT INTO setup_menu (function_id, window_name, display_name, default_parameter, hide_show, parent_menu_id, product_category, menu_order, menu_type)
	VALUES (10102800, 'windowSetupProfile', 'Setup Profile', NULL, 1, 10101099, 14000000, 6, 0)
END


IF NOT EXISTS(SELECT 1 FROM setup_menu WHERE function_id = 10106400 AND product_category = 14000000)
BEGIN
	INSERT INTO setup_menu (function_id, window_name, display_name, default_parameter, hide_show, parent_menu_id, product_category, menu_order, menu_type)
	VALUES (10106400, 'windowTemplateFieldMapping', 'Template Field Mapping', NULL, 1, 10106499, 14000000, 16, 0)
END


IF NOT EXISTS(SELECT 1 FROM setup_menu WHERE function_id = 10101900 AND product_category = 14000000)
BEGIN
	INSERT INTO setup_menu (function_id, window_name, display_name, default_parameter, hide_show, parent_menu_id, product_category, menu_order, menu_type)
	VALUES (10101900, 'windowSetupDealLock', 'Setup Logical Trade Lock', NULL, 1, 10100000, 14000000, 3, 1)
END


IF NOT EXISTS(SELECT 1 FROM setup_menu WHERE function_id = 10101161 AND product_category = 14000000)
BEGIN
	INSERT INTO setup_menu (function_id, window_name, display_name, default_parameter, hide_show, parent_menu_id, product_category, menu_order, menu_type)
	VALUES (10101161, 'windowDealConfirmationRule', 'Setup Confirmation Rule', NULL, 1, 10104099, 14000000, 16, 0)
END


IF NOT EXISTS(SELECT 1 FROM setup_menu WHERE function_id = 10106499 AND product_category = 14000000)
BEGIN
	INSERT INTO setup_menu (function_id, window_name, display_name, default_parameter, hide_show, parent_menu_id, product_category, menu_order, menu_type)
	VALUES (10106499, 'NULL', 'Mapping Setup', NULL, 1, 10100000, 14000000, 1, 1)
END


IF NOT EXISTS(SELECT 1 FROM setup_menu WHERE function_id = 10104099 AND product_category = 14000000)
BEGIN
	INSERT INTO setup_menu (function_id, window_name, display_name, default_parameter, hide_show, parent_menu_id, product_category, menu_order, menu_type)
	VALUES (10104099, 'NULL', 'Template', NULL, 1, 10100000, 14000000, 1, 1)
END

--Setup End

--Reporting Module Start
IF NOT EXISTS (SELECT 1 FROM setup_menu WHERE function_id = 10200000 AND product_category = 14000000)
BEGIN
	INSERT INTO setup_menu (function_id, window_name, display_name, default_parameter, hide_show, parent_menu_id, product_category, menu_order, menu_type)
	VALUES (10200000, NULL, 'Reporting', NULL, 1, 14000000, 14000000, 1, 1)
END

IF NOT EXISTS(SELECT 1 FROM setup_menu WHERE function_id = 10201600 AND product_category = 14000000)
BEGIN
	INSERT INTO setup_menu (function_id, window_name, display_name, default_parameter, hide_show, parent_menu_id, product_category, menu_order, menu_type)
	VALUES (10201600, 'windowReportManager', 'Report Manager - Old', NULL, 1, 10200000, 14000000, 125, 0)
END

IF NOT EXISTS(SELECT 1 FROM setup_menu WHERE function_id = 10202200 AND product_category = 14000000)
BEGIN
	INSERT INTO setup_menu (function_id, window_name, display_name, default_parameter, hide_show, parent_menu_id, product_category, menu_order, menu_type)
	VALUES (10202200, 'windowViewReport', 'View Report', NULL, 1, 10200000, 14000000, 133, 0)
END


IF NOT EXISTS(SELECT 1 FROM setup_menu WHERE function_id = 10202500 AND product_category = 14000000)
BEGIN
	INSERT INTO setup_menu (function_id, window_name, display_name, default_parameter, hide_show, parent_menu_id, product_category, menu_order, menu_type)
	VALUES (10202500, 'windowReportManagerDHX', 'Report Manager', NULL, 1, 10200000, 14000000, 43, 0)
END


IF NOT EXISTS(SELECT 1 FROM setup_menu WHERE function_id = 10201800 AND product_category = 14000000)
BEGIN
	INSERT INTO setup_menu (function_id, window_name, display_name, default_parameter, hide_show, parent_menu_id, product_category, menu_order, menu_type)
	VALUES (10201800, 'WindowReportGroupManager', 'Report Group Manager', NULL, 1, 10200000, 14000000, 0, 0)
END


IF NOT EXISTS(SELECT 1 FROM setup_menu WHERE function_id = 10201700 AND product_category = 14000000)
BEGIN
	INSERT INTO setup_menu (function_id, window_name, display_name, default_parameter, hide_show, parent_menu_id, product_category, menu_order, menu_type)
	VALUES (10201700, 'WindowRunReportGroup', 'Run Report Group', NULL, 0, 10200000, 14000000, 0, 0)
END

--Reporting Module END

--User and Role Start
IF NOT EXISTS(SELECT 1 FROM setup_menu WHERE function_id = 10110000 AND product_category = 14000000)
BEGIN
	INSERT INTO setup_menu (function_id, window_name, display_name, default_parameter, hide_show, parent_menu_id, product_category, menu_order, menu_type)
	VALUES (10110000, NULL, 'User and Role', NULL, 1, 10000000, 14000000, 42, 1)
END


IF NOT EXISTS(SELECT 1 FROM setup_menu WHERE function_id = 10111000 AND product_category = 14000000)
BEGIN
	INSERT INTO setup_menu (function_id, window_name, display_name, default_parameter, hide_show, parent_menu_id, product_category, menu_order, menu_type)
	VALUES (10111000, 'windowMaintainUsers', 'Setup User', NULL, 1, 10110000, 14000000, 40, 0)
END


IF NOT EXISTS(SELECT 1 FROM setup_menu WHERE function_id = 10111100 AND product_category = 14000000)
BEGIN
	INSERT INTO setup_menu (function_id, window_name, display_name, default_parameter, hide_show, parent_menu_id, product_category, menu_order, menu_type)
	VALUES (10111100, 'windowMaintainRoles', 'Setup Role', NULL, 1, 10110000, 14000000, 41, 0)
END


IF NOT EXISTS(SELECT 1 FROM setup_menu WHERE function_id = 10111200 AND product_category = 14000000)
BEGIN
	INSERT INTO setup_menu (function_id, window_name, display_name, default_parameter, hide_show, parent_menu_id, product_category, menu_order, menu_type)
	VALUES (10111200, 'windowCustomizedMenu', 'Setup Workflow', NULL, 1, 10110000, 14000000, 42, 0)
END
--User and Role End

--Compliance Menu Start
IF NOT EXISTS (SELECT 1 FROM setup_menu WHERE function_id = 14100000 AND product_category = 14000000)
BEGIN
	INSERT INTO setup_menu (function_id, window_name, display_name, default_parameter, hide_show, parent_menu_id, product_category, menu_order, menu_type)
	VALUES (14100000, NULL, 'Compliance Menu', NULL, 1, 14000000, 14000000, 1, 1)
END
--Compliance Menu End

--Renewable Source Start
IF NOT EXISTS (SELECT 1 FROM setup_menu WHERE function_id = 12100000 AND product_category = 14000000)
BEGIN
	INSERT INTO setup_menu (function_id, window_name, display_name, default_parameter, hide_show, parent_menu_id, product_category, menu_order, menu_type)
	VALUES (12100000, NULL, 'Renewable Source', NULL, 1, 14000000, 14000000, 1, 1)
END


IF NOT EXISTS(SELECT 1 FROM setup_menu WHERE function_id = 12101700 AND product_category = 14000000)
BEGIN
	INSERT INTO setup_menu (function_id, window_name, display_name, default_parameter, hide_show, parent_menu_id, product_category, menu_order, menu_type)
	VALUES (12101700, 'windowSetupRenewableSource', 'Setup Renewable Sources', NULL, 1, 12100000, 14000000, 2, 0)
END

--Renewable Source End

--Inventory Management Start
IF NOT EXISTS (SELECT 1 FROM setup_menu WHERE function_id = 12130000 AND product_category = 14000000)
BEGIN
	INSERT INTO setup_menu (function_id, window_name, display_name, default_parameter, hide_show, parent_menu_id, product_category, menu_order, menu_type)
	VALUES (12130000, NULL, 'Inventory Management', NULL, 1, 14000000, 14000000, 1, 1)
END

IF NOT EXISTS(SELECT 1 FROM setup_menu WHERE function_id = 10131000 AND product_category = 14000000)
BEGIN
	INSERT INTO setup_menu (function_id, window_name, display_name, default_parameter, hide_show, parent_menu_id, product_category, menu_order, menu_type)
	VALUES (10131000, 'windowMaintainDeals', 'Create REC Deals', NULL, 1, 12130000, 14000000, 50, 0)
END


IF NOT EXISTS(SELECT 1 FROM setup_menu WHERE function_id = 10234700 AND product_category = 14000000)
BEGIN
	INSERT INTO setup_menu (function_id, window_name, display_name, default_parameter, hide_show, parent_menu_id, product_category, menu_order, menu_type)
	VALUES (10234700, 'windowMaintainDealTransfer', 'Maintain REC Deal Transfer', NULL, 1, 12130000, 14000000, 54, 0)
END
--Inventory Management End

--Price Curve Management Start
IF NOT EXISTS (SELECT 1 FROM setup_menu WHERE function_id = 10150000 AND product_category = 14000000)
BEGIN
	INSERT INTO setup_menu (function_id, window_name, display_name, default_parameter, hide_show, parent_menu_id, product_category, menu_order, menu_type)
	VALUES (10150000, NULL, 'Price Curve Management', NULL, 1, 14000000, 14000000, 1, 1)
END

IF NOT EXISTS(SELECT 1 FROM setup_menu WHERE function_id = 10151000 AND product_category = 14000000)
BEGIN
	INSERT INTO setup_menu (function_id, window_name, display_name, default_parameter, hide_show, parent_menu_id, product_category, menu_order, menu_type)
	VALUES (10151000, 'windowViewPrices', 'View REC Price', NULL, 1, 10150000, 14000000, 62, 0)
END
--Price Curve Management End

--Accounting Setup Start
IF NOT EXISTS(SELECT 1 FROM setup_menu WHERE function_id = 15190000 AND product_category = 14000000)
BEGIN
	INSERT INTO setup_menu (function_id, window_name, display_name, default_parameter, hide_show, parent_menu_id, product_category, menu_order, menu_type)
	VALUES (15190000, 'NULL', 'Accounting Setup', NULL, 1, 14000000, 14000000, 1, 1)
END

IF NOT EXISTS(SELECT 1 FROM setup_menu WHERE function_id = 10103300 AND product_category = 14000000)
BEGIN
	INSERT INTO setup_menu (function_id, window_name, display_name, default_parameter, hide_show, parent_menu_id, product_category, menu_order, menu_type)
	VALUES (10103300, 'windowDefineInvoiceGLCode', 'Setup GL Group', NULL, 1, 15190000, 14000000, 22, 0)
END


IF NOT EXISTS(SELECT 1 FROM setup_menu WHERE function_id = 10103400 AND product_category = 14000000)
BEGIN
	INSERT INTO setup_menu (function_id, window_name, display_name, default_parameter, hide_show, parent_menu_id, product_category, menu_order, menu_type)
	VALUES (10103400, 'windowSetupDefaultGLCode', 'Setup Default GL Group', NULL, 1, 15190000, 14000000, 23, 0)
END


IF NOT EXISTS(SELECT 1 FROM setup_menu WHERE function_id = 10101500 AND product_category = 14000000)
BEGIN
	INSERT INTO setup_menu (function_id, window_name, display_name, default_parameter, hide_show, parent_menu_id, product_category, menu_order, menu_type)
	VALUES (10101500, 'windowMaintainNettingGroups', 'Setup Netting Group', NULL, 1, 15190000, 14000000, 222, 0)
END

IF NOT EXISTS(SELECT 1 FROM setup_menu WHERE function_id = 10231000 AND product_category = 14000000)
BEGIN
	INSERT INTO setup_menu (function_id, window_name, display_name, default_parameter, hide_show, parent_menu_id, product_category, menu_order, menu_type)
	VALUES (10231000, 'windowSetupInventoryGLAccount', 'Setup Inventory GL Account', NULL, 1, 15190000, 14000000, 40, 0)
END
--Accounting Setup Start

--Contract Administration Start

IF NOT EXISTS(SELECT 1 FROM setup_menu WHERE function_id = 10104300 AND product_category = 14000000)
BEGIN
	INSERT INTO setup_menu (function_id, window_name, display_name, default_parameter, hide_show, parent_menu_id, product_category, menu_order, menu_type)
	VALUES (10104300, 'windowSetupContractComponentMapping', 'Setup Contract Component Mapping', NULL, 1, 10210000, 14000000, 24, 0)
END


IF NOT EXISTS(SELECT 1 FROM setup_menu WHERE function_id = 10210000 AND product_category = 14000000)
BEGIN
	INSERT INTO setup_menu (function_id, window_name, display_name, default_parameter, hide_show, parent_menu_id, product_category, menu_order, menu_type)
	VALUES (10210000, 'NULL', 'Contract Administration', NULL, 1, 14000000, 14000000, 153, 1)
END


IF NOT EXISTS(SELECT 1 FROM setup_menu WHERE function_id = 10211200 AND product_category = 14000000)
BEGIN
	INSERT INTO setup_menu (function_id, window_name, display_name, default_parameter, hide_show, parent_menu_id, product_category, menu_order, menu_type)
	VALUES (10211200, 'windowMaintainContractGroup', 'Setup Standard Contract', NULL, 1, 10210000, 14000000, 135, 0)
END


IF NOT EXISTS(SELECT 1 FROM setup_menu WHERE function_id = 10211100 AND product_category = 14000000)
BEGIN
	INSERT INTO setup_menu (function_id, window_name, display_name, default_parameter, hide_show, parent_menu_id, product_category, menu_order, menu_type)
	VALUES (10211100, 'windowContractChargeType', 'Setup Contract Component Template', NULL, 1, 10210000, 14000000, 138, 0)
END


IF NOT EXISTS(SELECT 1 FROM setup_menu WHERE function_id = 10211300 AND product_category = 14000000)
BEGIN
	INSERT INTO setup_menu (function_id, window_name, display_name, default_parameter, hide_show, parent_menu_id, product_category, menu_order, menu_type)
	VALUES (10211300, 'windowNonStandardContract', 'Setup Non Standard Contract', NULL, 1, 10210000, 14000000, 136, 0)
END

--Contract Administration End

--Settlement And Billing Start
IF NOT EXISTS(SELECT 1 FROM setup_menu WHERE function_id = 10220000 AND product_category = 14000000)
BEGIN
	INSERT INTO setup_menu (function_id, window_name, display_name, default_parameter, hide_show, parent_menu_id, product_category, menu_order, menu_type)
	VALUES (10220000, 'NULL', 'Settlement And Billing', NULL, 1, 14000000, 14000000, 158, 1)
END


IF NOT EXISTS(SELECT 1 FROM setup_menu WHERE function_id = 10221000 AND product_category = 14000000)
BEGIN
	INSERT INTO setup_menu (function_id, window_name, display_name, default_parameter, hide_show, parent_menu_id, product_category, menu_order, menu_type)
	VALUES (10221000, 'windowMaintainInvoice', 'Process Invoice', NULL, 1, 10220000, 14000000, 140, 0)
END


IF NOT EXISTS(SELECT 1 FROM setup_menu WHERE function_id = 10222300 AND product_category = 14000000)
BEGIN
	INSERT INTO setup_menu (function_id, window_name, display_name, default_parameter, hide_show, parent_menu_id, product_category, menu_order, menu_type)
	VALUES (10222300, 'windowRunSettlement', 'Run Deal Settlement', NULL, 1, 10220000, 14000000, 141, 0)
END


IF NOT EXISTS(SELECT 1 FROM setup_menu WHERE function_id = 10221300 AND product_category = 14000000)
BEGIN
	INSERT INTO setup_menu (function_id, window_name, display_name, default_parameter, hide_show, parent_menu_id, product_category, menu_order, menu_type)
	VALUES (10221300, 'windowMaintainInvoiceHistory', 'View Invoice', NULL, 1, 10220000, 14000000, 143, 0)
END


IF NOT EXISTS(SELECT 1 FROM setup_menu WHERE function_id = 10241100 AND product_category = 14000000)
BEGIN
	INSERT INTO setup_menu (function_id, window_name, display_name, default_parameter, hide_show, parent_menu_id, product_category, menu_order, menu_type)
	VALUES (10241100, 'windowApplyCash', 'Apply Cash', NULL, 1, 10220000, 14000000, 111, 0)
END


IF NOT EXISTS(SELECT 1 FROM setup_menu WHERE function_id = 10104600 AND product_category = 14000000)
BEGIN
	INSERT INTO setup_menu (function_id, window_name, display_name, default_parameter, hide_show, parent_menu_id, product_category, menu_order, menu_type)
	VALUES (10104600, 'windowMaintainNettingGrp', 'Setup Settlement Netting Group', NULL, 1, 10220000, 14000000, 17, 0)
END
--Settlement And Billing End