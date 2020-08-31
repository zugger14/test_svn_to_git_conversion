DELETE FROM setup_menu
WHERE product_category = 15000000

INSERT INTO setup_menu (function_id, window_name, display_name, hide_show, parent_menu_id, product_category, menu_order, menu_type)
VALUES (15000000, NULL, 'Settlement Tracker', 1, NULL, 15000000, 0, 1)

INSERT INTO setup_menu (function_id, window_name, display_name, hide_show, parent_menu_id, product_category, menu_order, menu_type)
VALUES (10100000, NULL, 'Setup', 1, 15000000, 15000000, 1, 1)
INSERT INTO setup_menu (function_id, window_name, display_name, hide_show, parent_menu_id, product_category, menu_order, menu_type)
VALUES (10101099, NULL, 'Reference Data', 1, 10100000, 15000000, 2, 1)
INSERT INTO setup_menu (function_id, window_name, display_name, hide_show, parent_menu_id, product_category, menu_order, menu_type)
VALUES (10101000, 'windowMaintainStaticData', 'Setup Static Data', 1, 10101099, 15000000, 3, 0)
INSERT INTO setup_menu (function_id, window_name, display_name, hide_show, parent_menu_id, product_category, menu_order, menu_type)
  VALUES (10101100, 'windowMaintainDefination', 'Maintain Definition', 0, 10101099, 15000000, 4, 0)
INSERT INTO setup_menu (function_id, window_name, display_name, hide_show, parent_menu_id, product_category, menu_order, menu_type)
  VALUES (10101200, 'windowSetupHedgingStrategies', 'Setup Book Structure', 1, 10101099, 15000000, 5, 0)
INSERT INTO setup_menu (function_id, window_name, display_name, hide_show, parent_menu_id, product_category, menu_order, menu_type)
  VALUES (10102500, 'windowSetupLocation', 'Setup Location', 1, 10101099, 15000000, 7, 0)
INSERT INTO setup_menu (function_id, window_name, display_name, hide_show, parent_menu_id, product_category, menu_order, menu_type)
  VALUES (10102800, 'windowSetupProfile', 'Setup Profile', 0, 10101099, 15000000, 8, 0)
INSERT INTO setup_menu (function_id, window_name, display_name, hide_show, parent_menu_id, product_category, menu_order, menu_type)
  VALUES (10101499, NULL, 'Setup Deal Templates', 0, 10100000, 15000000, 10, 1)
INSERT INTO setup_menu (function_id, window_name, display_name, hide_show, parent_menu_id, product_category, menu_order, menu_type)
  VALUES (10101400, 'windowMaintainDealTemplate', 'Maintain Deal Template', 1, 10100000, 15000000, 11, 0)
INSERT INTO setup_menu (function_id, window_name, display_name, hide_show, parent_menu_id, product_category, menu_order, menu_type)
  VALUES (10104200, 'windowSetupFieldTemplate', 'Maintain Field Template', 1, 10100000, 15000000, 12, 0)
INSERT INTO setup_menu (function_id, window_name, display_name, hide_show, parent_menu_id, product_category, menu_order, menu_type)
  VALUES (10104100, 'windowSetupUDFTemplate', 'Maintain UDF Template', 1, 10100000, 15000000, 13, 0)
INSERT INTO setup_menu (function_id, window_name, display_name, hide_show, parent_menu_id, product_category, menu_order, menu_type)
  VALUES (10103900, 'windowSetupDealStatusConfirmationRule', 'Setup Deal Status and Confirmation Rule', 0, 10101499, 15000000, 14, 0)
INSERT INTO setup_menu (function_id, window_name, display_name, hide_show, parent_menu_id, product_category, menu_order, menu_type)
  VALUES (10103500, 'windowSetupHedgingRelationshipsTypesWithReturn', 'Maintain Hedge Deferral Rules', 0, 10101499, 15000000, 15, 0)
INSERT INTO setup_menu (function_id, window_name, display_name, hide_show, parent_menu_id, product_category, menu_order, menu_type)
  VALUES (10101500, 'windowMaintainNettingGroups', 'Setup Netting Group', 0, 10100000, 15000000, 17, 0)
INSERT INTO setup_menu (function_id, window_name, display_name, hide_show, parent_menu_id, product_category, menu_order, menu_type)
  VALUES (10101600, 'windowSchedulejob', 'View Scheduled Job', 1, 10100000, 15000000, 16, 0)
INSERT INTO setup_menu (function_id, window_name, display_name, hide_show, parent_menu_id, product_category, menu_order, menu_type)
  VALUES (10103800, 'windowMaintainSourceGenerator', 'Maintain Source Generator', 0, 10100000, 15000000, 19, 0)
INSERT INTO setup_menu (function_id, window_name, display_name, hide_show, parent_menu_id, product_category, menu_order, menu_type)
  VALUES (10103399, NULL, 'Setup Contract Components ', 0, 10100000, 15000000, 20, 1)
INSERT INTO setup_menu (function_id, window_name, display_name, hide_show, parent_menu_id, product_category, menu_order, menu_type)
  VALUES (10101900, 'windowSetupDealLock', 'Setup Logical Trade Lock', 0, 10100000, 15000000, 23, 0)
INSERT INTO setup_menu (function_id, window_name, display_name, hide_show, parent_menu_id, product_category, menu_order, menu_type)
  VALUES (10102000, 'windowSetupTenorBucketData', 'Setup Tenor Bucket', 0, 10100000, 15000000, 24, 0)
INSERT INTO setup_menu (function_id, window_name, display_name, hide_show, parent_menu_id, product_category, menu_order, menu_type)
  VALUES (10102900, 'windowManageDocuments', 'Manage Document', 1, 10100000, 15000000, 20, 0)
INSERT INTO setup_menu (function_id, window_name, display_name, hide_show, parent_menu_id, product_category, menu_order, menu_type)
  VALUES (10102300, 'windowSetupEMSStrategies', 'Setup Emissions Source/Sink Type', 0, 10100000, 15000000, 26, 0)
INSERT INTO setup_menu (function_id, window_name, display_name, hide_show, parent_menu_id, product_category, menu_order, menu_type)
  VALUES (10102200, 'windowSetupAsOfDate', 'Setup As of Date', 0, 10100000, 15000000, 27, 0)
INSERT INTO setup_menu (function_id, window_name, display_name, hide_show, parent_menu_id, product_category, menu_order, menu_type)
  VALUES (10102400, 'windowFormulaBuilder', 'Formula Builder', 1, 10100000, 15000000, 24, 0)
INSERT INTO setup_menu (function_id, window_name, display_name, hide_show, parent_menu_id, product_category, menu_order, menu_type)
  VALUES (13170000, NULL, 'Mapping Setup', 0, 10100000, 15000000, 29, 1)
INSERT INTO setup_menu (function_id, window_name, display_name, hide_show, parent_menu_id, product_category, menu_order, menu_type)
  VALUES (10103100, 'windowSetupTrayportTermMappingStaging', 'Term Mapping ', 0, 13170000, 15000000, 30, 0)
INSERT INTO setup_menu (function_id, window_name, display_name, hide_show, parent_menu_id, product_category, menu_order, menu_type)
  VALUES (10103200, 'windowPratosMapping', 'Pratos Mapping', 0, 13170000, 15000000, 31, 0)
INSERT INTO setup_menu (function_id, window_name, display_name, hide_show, parent_menu_id, product_category, menu_order, menu_type)
  VALUES (13171000, 'windowSTForecastMapping', 'ST Forecast Mapping', 0, 13170000, 15000000, 32, 0)
INSERT INTO setup_menu (function_id, window_name, display_name, hide_show, parent_menu_id, product_category, menu_order, menu_type)
  VALUES (10102799, NULL, 'Manage Data', 0, 10100000, 15000000, 33, 1)
INSERT INTO setup_menu (function_id, window_name, display_name, hide_show, parent_menu_id, product_category, menu_order, menu_type)
  VALUES (10102700, 'windowSetupArchiveData', 'Archive Data', 0, 10102799, 15000000, 34, 0)
INSERT INTO setup_menu (function_id, window_name, display_name, hide_show, parent_menu_id, product_category, menu_order, menu_type)
  VALUES (10103600, 'windowRemoveData', 'Remove Data', 0, 10102799, 15000000, 35, 0)
INSERT INTO setup_menu (function_id, window_name, display_name, hide_show, parent_menu_id, product_category, menu_order, menu_type)
  VALUES (10104000, 'windowDefineDealStatusPrivilege', 'Define Deal Status Privilege', 0, 10100000, 15000000, 36, 0)
INSERT INTO setup_menu (function_id, window_name, display_name, hide_show, parent_menu_id, product_category, menu_order, menu_type)
  VALUES (10104300, 'windowSetupContractComponentMapping', 'Setup Contract Component Mapping', 1, 10100000, 15000000, 18, 0)
INSERT INTO setup_menu (function_id, window_name, display_name, hide_show, parent_menu_id, product_category, menu_order, menu_type)
  VALUES (10104400, 'windowSetupContractPrice', 'Setup Contract Price', 0, 10100000, 15000000, 38, 0)
INSERT INTO setup_menu (function_id, window_name, display_name, hide_show, parent_menu_id, product_category, menu_order, menu_type)
  VALUES (10110000, NULL, 'Users and Roles', 1, 15000000, 15000000, 39, 1)
INSERT INTO setup_menu (function_id, window_name, display_name, hide_show, parent_menu_id, product_category, menu_order, menu_type)
  VALUES (10111000, 'windowMaintainUsers', 'Setup User', 1, 10110000, 15000000, 40, 0)
INSERT INTO setup_menu (function_id, window_name, display_name, hide_show, parent_menu_id, product_category, menu_order, menu_type)
  VALUES (10111100, 'windowMaintainRoles', 'Setup Roles', 1, 10110000, 15000000, 41, 0)
INSERT INTO setup_menu (function_id, window_name, display_name, hide_show, parent_menu_id, product_category, menu_order, menu_type)
  VALUES (10111200, 'windowCustomizedMenu', 'Setup Workflow', 1, 10110000, 15000000, 42, 0)
INSERT INTO setup_menu (function_id, window_name, display_name, hide_show, parent_menu_id, product_category, menu_order, menu_type)
  VALUES (10111300, 'windowRunPrivilege', 'Run Privilege Report', 0, 10110000, 15000000, 43, 0)
INSERT INTO setup_menu (function_id, window_name, display_name, hide_show, parent_menu_id, product_category, menu_order, menu_type)
  VALUES (10111400, 'windowRunSystemAccessLog', 'Run System Access Log Report', 0, 10110000, 15000000, 44, 0)
INSERT INTO setup_menu (function_id, window_name, display_name, hide_show, parent_menu_id, product_category, menu_order, menu_type)
  VALUES (10120000, NULL, 'Compliance Management', 1, 15000000, 15000000, 45, 1)
INSERT INTO setup_menu (function_id, window_name, display_name, hide_show, parent_menu_id, product_category, menu_order, menu_type)
  VALUES (10121300, 'MaintainComplianceStandards', 'Maintain Compliance Standards', 0, 10120000, 15000000, 46, 0)
INSERT INTO setup_menu (function_id, window_name, display_name, hide_show, parent_menu_id, product_category, menu_order, menu_type)
  VALUES (10121000, 'maintainComplianceProcess', 'Maintain Compliance Groups', 0, 10120000, 15000000, 47, 0)
INSERT INTO setup_menu (function_id, window_name, display_name, hide_show, parent_menu_id, product_category, menu_order, menu_type)
  VALUES (10121400, 'windowActivityProcessMap', 'Activity Process Map', 0, 10120000, 15000000, 48, 0)
INSERT INTO setup_menu (function_id, window_name, display_name, hide_show, parent_menu_id, product_category, menu_order, menu_type)
  VALUES (10121500, 'MaintainChangeOwners', 'Change Owners', 0, 10120000, 15000000, 49, 0)
INSERT INTO setup_menu (function_id, window_name, display_name, hide_show, parent_menu_id, product_category, menu_order, menu_type)
  VALUES (10121200, 'PerformComplianceActivities', 'Perform Compliance Activities', 0, 10120000, 15000000, 50, 0)
INSERT INTO setup_menu (function_id, window_name, display_name, hide_show, parent_menu_id, product_category, menu_order, menu_type)
  VALUES (10121100, 'ApproveComplianceActivities', 'Approve Compliance Activities', 0, 10120000, 15000000, 51, 0)
INSERT INTO setup_menu (function_id, window_name, display_name, hide_show, parent_menu_id, product_category, menu_order, menu_type)
  VALUES (10122300, NULL, 'Reports', 0, 10120000, 15000000, 52, 1)
INSERT INTO setup_menu (function_id, window_name, display_name, hide_show, parent_menu_id, product_category, menu_order, menu_type)
  VALUES (10121600, 'ViewComplianceActivities', 'View Compliance Activities', 0, 10122300, 15000000, 53, 0)
INSERT INTO setup_menu (function_id, window_name, display_name, hide_show, parent_menu_id, product_category, menu_order, menu_type)
  VALUES (10121700, 'ReportComplianceActivities', 'View Status On Compliance Activities', 0, 10122300, 15000000, 54, 0)
INSERT INTO setup_menu (function_id, window_name, display_name, hide_show, parent_menu_id, product_category, menu_order, menu_type)
  VALUES (10122200, 'windowComplianceCalendar', 'View Compliance Calendar', 0, 10122300, 15000000, 55, 0)
INSERT INTO setup_menu (function_id, window_name, display_name, hide_show, parent_menu_id, product_category, menu_order, menu_type)
  VALUES (10121800, 'RunComplianceAuditReport', 'Run Compliance Activity Audit Report', 0, 10122300, 15000000, 56, 0)
INSERT INTO setup_menu (function_id, window_name, display_name, hide_show, parent_menu_id, product_category, menu_order, menu_type)
  VALUES (10121900, 'RunComplianceTrendReport', 'Run Compliance Trend Report', 0, 10122300, 15000000, 57, 0)
INSERT INTO setup_menu (function_id, window_name, display_name, hide_show, parent_menu_id, product_category, menu_order, menu_type)
  VALUES (10122000, 'dashReportPie', 'Run Compliance Graph Report', 0, 10122300, 15000000, 58, 0)
INSERT INTO setup_menu (function_id, window_name, display_name, hide_show, parent_menu_id, product_category, menu_order, menu_type)
  VALUES (10122100, 'dashReportBar', 'Run Compliance Status Graph Report', 0, 10122300, 15000000, 59, 0)
INSERT INTO setup_menu (function_id, window_name, display_name, hide_show, parent_menu_id, product_category, menu_order, menu_type)
  VALUES (10122400, 'RunComplianceDateVoilationReport', 'Run Compliance Due Date Violation Report', 0, 10122300, 15000000, 60, 0)
INSERT INTO setup_menu (function_id, window_name, display_name, hide_show, parent_menu_id, product_category, menu_order, menu_type)
  VALUES (15130199, NULL, 'Define Billing Determinants', 1, 15000000, 15000000, 61, 1)
INSERT INTO setup_menu (function_id, window_name, display_name, hide_show, parent_menu_id, product_category, menu_order, menu_type)
  VALUES (15130100, 'windowMaintainStaticDataContractComponent', 'Setup Contract Component', 0, 15130199, 15000000, 62, 0)
INSERT INTO setup_menu (function_id, window_name, display_name, hide_show, parent_menu_id, product_category, menu_order, menu_type)
  VALUES (10103800, 'windowMaintainSourceGenerator', 'Setup Generators', 0, 15130199, 15000000, 63, 0)
INSERT INTO setup_menu (function_id, window_name, display_name, hide_show, parent_menu_id, product_category, menu_order, menu_type)
  VALUES (10103000, 'windowDefineMeterID', 'Setup Meter', 1, 15130199, 15000000, 64, 0)
INSERT INTO setup_menu (function_id, window_name, display_name, hide_show, parent_menu_id, product_category, menu_order, menu_type)
  VALUES (10102600, 'windowSetupPriceCurves', 'Setup Price Curve', 1, 15130199, 15000000, 65, 0)
INSERT INTO setup_menu (function_id, window_name, display_name, hide_show, parent_menu_id, product_category, menu_order, menu_type)
  VALUES (15140000, NULL, 'Setup Contract Template', 1, 15000000, 15000000, 66, 1)
INSERT INTO setup_menu (function_id, window_name, display_name, hide_show, parent_menu_id, product_category, menu_order, menu_type)
  VALUES (10191099, NULL, 'Setup Contracts ', 1, 15000000, 15000000, 68, 1)
INSERT INTO setup_menu (function_id, window_name, display_name, hide_show, parent_menu_id, product_category, menu_order, menu_type)
  VALUES (10105800, 'windowSetupCounterparty', 'Setup Counterparty', 1, 10191099, 15000000, 69, 0)
INSERT INTO setup_menu (function_id, window_name, display_name, hide_show, parent_menu_id, product_category, menu_order, menu_type)
  VALUES (10211200, 'windowMaintainContract', 'Setup Standard Contract', 1, 10191099, 15000000, 71, 0)
INSERT INTO setup_menu (function_id, window_name, display_name, hide_show, parent_menu_id, product_category, menu_order, menu_type)
  VALUES (10131000, 'windowMaintainDeals', 'Setup Deals', 0, 10191099, 15000000, 70, 0)
INSERT INTO setup_menu (function_id, window_name, display_name, hide_show, parent_menu_id, product_category, menu_order, menu_type)
  VALUES (10141399, NULL, 'Manage Billing Determinants', 1, 15000000, 15000000, 72, 1)
INSERT INTO setup_menu (function_id, window_name, display_name, hide_show, parent_menu_id, product_category, menu_order, menu_type)
  VALUES (10141300, 'windowRunHourlyProductionReport', 'View Position', 0, 10141399, 15000000, 73, 0)
INSERT INTO setup_menu (function_id, window_name, display_name, hide_show, parent_menu_id, product_category, menu_order, menu_type)
  VALUES (10131300, 'windowImportDataDeal', 'Import Meter Data', 0, 10141399, 15000000, 74, 0)
INSERT INTO setup_menu (function_id, window_name, display_name, hide_show, parent_menu_id, product_category, menu_order, menu_type)
  VALUES (10222400, 'windowMeterDataReport', 'Run Meter Data Report', 0, 10141399, 15000000, 75, 0)
INSERT INTO setup_menu (function_id, window_name, display_name, hide_show, parent_menu_id, product_category, menu_order, menu_type)
  VALUES (10131300, 'windowImportDataDeal', 'Price Curves Import', 0, 10141399, 15000000, 76, 0)
INSERT INTO setup_menu (function_id, window_name, display_name, hide_show, parent_menu_id, product_category, menu_order, menu_type)
  VALUES (10151000, 'windowViewPrices', 'View Prices', 1, 10141399, 15000000, 77, 0)
INSERT INTO setup_menu (function_id, window_name, display_name, hide_show, parent_menu_id, product_category, menu_order, menu_type)
  VALUES (10222399, NULL, 'Run Settlement Process', 1, 15000000, 15000000, 78, 1)
INSERT INTO setup_menu (function_id, window_name, display_name, hide_show, parent_menu_id, product_category, menu_order, menu_type)
  VALUES (10222300, 'windowRunSettlement', 'Run Deal Settlement', 1, 10222399, 15000000, 79, 0)
INSERT INTO setup_menu (function_id, window_name, display_name, hide_show, parent_menu_id, product_category, menu_order, menu_type)
  VALUES (10221000, 'windowMaintainInvoice', 'Process Invoice', 1, 10222399, 15000000, 80, 0)
INSERT INTO setup_menu (function_id, window_name, display_name, hide_show, parent_menu_id, product_category, menu_order, menu_type)
  VALUES (10221300, 'windowMaintainInvoiceHistory', 'View Invoice', 1, 10222399, 15000000, 81, 0)
INSERT INTO setup_menu (function_id, window_name, display_name, hide_show, parent_menu_id, product_category, menu_order, menu_type)
  VALUES (10181000, 'windowRunMtmCalc', 'Run MTM Process', 0, 10222399, 15000000, 82, 0)
INSERT INTO setup_menu (function_id, window_name, display_name, hide_show, parent_menu_id, product_category, menu_order, menu_type)
  VALUES (10221600, 'windowSettlementAdjustments', 'Compare Prior Settlement for Adjustments', 0, 10222399, 15000000, 83, 0)
INSERT INTO setup_menu (function_id, window_name, display_name, hide_show, parent_menu_id, product_category, menu_order, menu_type)
  VALUES (10221999, NULL, 'Reporting', 1, 15000000, 15000000, 85, 1)
INSERT INTO setup_menu (function_id, window_name, display_name, hide_show, parent_menu_id, product_category, menu_order, menu_type)
  VALUES (10221900, 'windowSettlementReport', 'Run Settlement Report', 0, 10221999, 15000000, 86, 0)
INSERT INTO setup_menu (function_id, window_name, display_name, hide_show, parent_menu_id, product_category, menu_order, menu_type)
  VALUES (10221200, 'windowBrokerFeeReport', 'Run Contract Settlement Report', 0, 10221999, 15000000, 87, 0)
INSERT INTO setup_menu (function_id, window_name, display_name, hide_show, parent_menu_id, product_category, menu_order, menu_type)
  VALUES (10181100, 'windowMTMReport', 'Run Forward Report', 0, 10221999, 15000000, 88, 0)
INSERT INTO setup_menu (function_id, window_name, display_name, hide_show, parent_menu_id, product_category, menu_order, menu_type)
  VALUES (10221800, 'windowSettlementProductionReport', 'Run Settlement Production Report', 0, 10221999, 15000000, 89, 0)
INSERT INTO setup_menu (function_id, window_name, display_name, hide_show, parent_menu_id, product_category, menu_order, menu_type)
  VALUES (10221700, 'windowMarketVarienceReport', 'Market Variance Report', 0, 10221999, 15000000, 90, 0)
INSERT INTO setup_menu (function_id, window_name, display_name, hide_show, parent_menu_id, product_category, menu_order, menu_type)
  VALUES (10201000, 'windowreportwriter', 'Report Writer', 0, 10221999, 15000000, 91, 0)
INSERT INTO setup_menu (function_id, window_name, display_name, hide_show, parent_menu_id, product_category, menu_order, menu_type)
  VALUES (10201100, 'WindowRunDashReport', 'Run Dashboard Report', 0, 10221999, 15000000, 92, 0)
INSERT INTO setup_menu (function_id, window_name, display_name, hide_show, parent_menu_id, product_category, menu_order, menu_type)
  VALUES (10201200, 'WindowDashReportTemplate', 'Dashboard Report Template', 0, 10221999, 15000000, 93, 0)
INSERT INTO setup_menu (function_id, window_name, display_name, hide_show, parent_menu_id, product_category, menu_order, menu_type)
  VALUES (10201300, 'windowMaintainEoDLogStatus', 'Maintain EoD Log Status', 0, 10221999, 15000000, 94, 0)
INSERT INTO setup_menu (function_id, window_name, display_name, hide_show, parent_menu_id, product_category, menu_order, menu_type)
  VALUES (10201400, 'windowRunFilesImportAuditReportPrice', 'Run Import Audit Report', 0, 10221999, 15000000, 95, 0)
INSERT INTO setup_menu (function_id, window_name, display_name, hide_show, parent_menu_id, product_category, menu_order, menu_type)
  VALUES (10101399, NULL, 'Setup Accounts', 1, 15000000, 15000000, 96, 1)
INSERT INTO setup_menu (function_id, window_name, display_name, hide_show, parent_menu_id, product_category, menu_order, menu_type)
  VALUES (10101300, 'windowMapGLCodes', 'Setup GL Code', 1, 10101399, 15000000, 97, 0)
INSERT INTO setup_menu (function_id, window_name, display_name, hide_show, parent_menu_id, product_category, menu_order, menu_type)
  VALUES (15190100, 'windowMaintainStaticDataContractComponentGLCode', 'Maintain Contract Components GL Codes Def', 0, 10101399, 15000000, 98, 0)
INSERT INTO setup_menu (function_id, window_name, display_name, hide_show, parent_menu_id, product_category, menu_order, menu_type)
  VALUES (10103300, 'windowDefineInvoiceGLCode', 'Setup GL Group', 1, 10101399, 15000000, 99, 0)
INSERT INTO setup_menu (function_id, window_name, display_name, hide_show, parent_menu_id, product_category, menu_order, menu_type)
  VALUES (10103400, 'windowSetupDefaultGLCode', 'Setup Default GL Group', 1, 10101399, 15000000, 100, 0)
INSERT INTO setup_menu (function_id, window_name, display_name, hide_show, parent_menu_id, product_category, menu_order, menu_type)
  VALUES (10231099, NULL, 'Prepare and Submit GL Entries', 1, 15000000, 15000000, 101, 1)
INSERT INTO setup_menu (function_id, window_name, display_name, hide_show, parent_menu_id, product_category, menu_order, menu_type)
  VALUES (10231000, 'windowMaintainManualJournalEntries', 'Add Manual Entries', 0, 10231099, 15000000, 102, 0)
INSERT INTO setup_menu (function_id, window_name, display_name, hide_show, parent_menu_id, product_category, menu_order, menu_type)
  VALUES (10231700, 'windowRunInventoryJournalEntryReport', 'Run Accrual Journal Entry Report', 0, 10231099, 15000000, 103, 0)
INSERT INTO setup_menu (function_id, window_name, display_name, hide_show, parent_menu_id, product_category, menu_order, menu_type)
  VALUES (10221400, 'windowPostJEReport', 'Post JE Report', 0, 10231099, 15000000, 104, 0)
INSERT INTO setup_menu (function_id, window_name, display_name, hide_show, parent_menu_id, product_category, menu_order, menu_type)
  VALUES (10233600, 'windowCloseMeasurement', 'Close Settlement Accounting Period', 1, 10101399, 15000000, 105, 0)
INSERT INTO setup_menu (function_id, window_name, display_name, hide_show, parent_menu_id, product_category, menu_order, menu_type)
  VALUES (10240000, NULL, 'Treasury', 0, 15000000, 15000000, 106, 1)
INSERT INTO setup_menu (function_id, window_name, display_name, hide_show, parent_menu_id, product_category, menu_order, menu_type)
  VALUES (10241000, 'windowReconcileCashEntriesDerivatives', 'Reconcile Cash Entries for Derivatives', 0, 10240000, 15000000, 107, 0)
INSERT INTO setup_menu (function_id, window_name, display_name, hide_show, parent_menu_id, product_category, menu_order, menu_type)
  VALUES (10241100, 'windowApplyCash', 'Apply Cash', 0, 10240000, 15000000, 108, 0)
INSERT INTO setup_menu (function_id, window_name, display_name, hide_show, parent_menu_id, product_category, menu_order, menu_type)
  VALUES (10106300, 'windowDataImportExport', 'Data Import/Export', 1, 10100000, 15000000, 22, 0)
INSERT INTO setup_menu (function_id, window_name, display_name, hide_show, parent_menu_id, product_category, menu_order, menu_type)
  VALUES (10201900, 'windowDataImportExportAuditReport', 'Run Data Import/Export Audit Report', 0, 10221999, 15000000, 16, 0)
INSERT INTO setup_menu (function_id, window_name, display_name, hide_show, parent_menu_id, product_category, menu_order, menu_type)
  VALUES (10122500, 'windowSetupAlerts', 'Setup Alerts', 1, 10120000, 15000000, 49, 0)
INSERT INTO setup_menu (function_id, window_name, display_name, hide_show, parent_menu_id, product_category, menu_order, menu_type)
  VALUES (10101182, 'WindowDefineUOMConversion', 'Setup UOM Conversion', 1, 10100000, 15000000, 8, 0)
INSERT INTO setup_menu (function_id, window_name, display_name, hide_show, parent_menu_id, product_category, menu_order, menu_type)
  VALUES (10211300, 'windowNonStandardContract', 'Setup Non-Standard Contract', 1, 10191099, 15000000, 136, 0)
INSERT INTO setup_menu (function_id, window_name, display_name, hide_show, parent_menu_id, product_category, menu_order, menu_type)
  VALUES (10202200, 'windowViewReport', 'View Report', 1, 10221999, 15000000, 155, 0)
INSERT INTO setup_menu (function_id, window_name, display_name, hide_show, parent_menu_id, product_category, menu_order, menu_type)
  VALUES (10201600, 'windowReportManager', 'Report Manager', 1, 10221999, 15000000, 156, 0)
INSERT INTO setup_menu (function_id, window_name, display_name, hide_show, parent_menu_id, product_category, menu_order, menu_type)
  VALUES (10211100, 'windowContractChargeType', 'Setup Contract Component Template', 1, 15140000, 15000000, 66, 0)
INSERT INTO setup_menu (function_id, window_name, display_name, hide_show, parent_menu_id, product_category, menu_order, menu_type)
  VALUES (10106100, 'windowSetupTimeSeries', 'Setup Time Series', 1, 10100000, 15000000, 19, 0)
INSERT INTO setup_menu (function_id, window_name, display_name, hide_show, parent_menu_id, product_category, menu_order, menu_type)
  VALUES (10211213, 'windowReportTemplateSetup', 'Setup Custom Report Template', 1, 10100000, 15000000, 23, 0)
INSERT INTO setup_menu (function_id, window_name, display_name, hide_show, parent_menu_id, product_category, menu_order, menu_type)
  VALUES (13102000, 'windowGenericMapping', 'Generic Mapping', 1, 10100000, 15000000, 21, 0)
INSERT INTO setup_menu (function_id, window_name, display_name, hide_show, parent_menu_id, product_category, menu_order, menu_type)
  VALUES (10104900, 'windowEmailSetup', 'Compose Email', 1, 10100000, 15000000, 25, 0)
INSERT INTO setup_menu (function_id, window_name, display_name, hide_show, parent_menu_id, product_category, menu_order, menu_type)
  VALUES (10202201, 'windowSAPSettlementExport', 'SAP Settlement Export', 1, 10231099, 15000000, 84, 0)
INSERT INTO setup_menu (function_id, window_name, display_name, hide_show, parent_menu_id, product_category, menu_order, menu_type)
  VALUES (10131000, 'windowMaintainDeals', 'Create and View Deals', 1, 10191099, 15000000, 70, 0)
INSERT INTO setup_menu (function_id, window_name, display_name, hide_show, parent_menu_id, product_category, menu_order, menu_type)
  VALUES (10106700, 'windowManageApproval', 'Manage Approval', 1, 10120000, 15000000, 53, 0)
INSERT INTO setup_menu (function_id, window_name, display_name, hide_show, parent_menu_id, product_category, menu_order, menu_type)
  VALUES (10106600, 'windowRulesWorkflow', 'Setup Rule Workflow', 1, 10120000, 15000000, 52, 0)
INSERT INTO setup_menu (function_id, window_name, display_name, hide_show, parent_menu_id, product_category, menu_order, menu_type)
  VALUES (10104600, 'windowMaintainNettingGrp', 'Setup Settlement Netting Group', 1, 10100000, 15000000, 17, 0)


UPDATE setup_menu
SET parent_menu_id = 10221999,
    hide_show = 0
WHERE function_id = 10201200
AND product_category = 15000000

IF NOT EXISTS (SELECT
    *
  FROM setup_menu
  WHERE function_id = 10104099
  AND product_category = 15000000)
BEGIN
  INSERT INTO setup_menu (function_id, display_name, hide_show, parent_menu_id, product_category, menu_type, menu_order)
    VALUES (10104099, 'Template', 1, 10100000, 15000000, 1, 1)
END

UPDATE setup_menu
SET parent_menu_id = 10104099
WHERE function_id IN (10104900, 10101400, 10104200, 10104100, 10211213, 10102400)
AND product_category = 15000000

UPDATE setup_menu
SET display_name = 'Setup Deal Field Template'
WHERE display_name = 'Maintain Deal Template'
UPDATE setup_menu
SET display_name = 'Setup Field Template'
WHERE display_name = 'Maintain Field Template'
UPDATE setup_menu
SET display_name = 'Setup UDF Template'
WHERE display_name = 'Maintain UDF Template'

IF NOT EXISTS (SELECT
    *
  FROM setup_menu
  WHERE function_id = 10106699
  AND product_category = 15000000)
BEGIN
  INSERT INTO setup_menu (function_id, display_name, hide_show, parent_menu_id, product_category, menu_type, menu_order)
    VALUES (10106699, 'Alert and Workflow', 1, 15000000, 15000000, 1, 1)
END

UPDATE setup_menu
SET parent_menu_id = 10106699
WHERE function_id IN (10122500, 10106600, 10106700)
AND product_category = 15000000

UPDATE setup_menu
SET parent_menu_id = 15130199
WHERE function_id = 10106100
AND product_category = 15000000

UPDATE setup_menu
SET parent_menu_id = 15140000
WHERE function_id IN (10211100, 10104300, 10104600)
AND product_category = 15000000

UPDATE setup_menu
SET parent_menu_id = 10191099
WHERE function_id IN (10105800, 10211200, 10211300, 10132000)
AND product_category = 15000000

IF NOT EXISTS (SELECT
    1
  FROM setup_menu
  WHERE function_id = 10211400
  AND product_category = 15000000)
BEGIN
  INSERT INTO setup_menu (function_id, display_name, hide_show, parent_menu_id, product_category, menu_type, menu_order)
    VALUES (10211400, 'Setup Transportation Contract', 1, 10191099, 15000000, 0, 1)
END

UPDATE setup_menu
SET parent_menu_id = 10222399,
    hide_show = 1
WHERE function_id IN (10222300, 10221000, 10221300, 10241100)
AND product_category = 15000000

UPDATE setup_menu
SET display_name = 'Export GL Entry'
WHERE display_name = 'SAP Settlement Export'

IF NOT EXISTS (SELECT
    *
  FROM setup_menu
  WHERE function_id = 10231000
  AND product_category = 15000000
  AND hide_show = 1)
BEGIN
  INSERT INTO setup_menu (function_id, display_name, hide_show, parent_menu_id, product_category, menu_type, menu_order)
    VALUES (10231000, 'Setup Inventory GL Account', 1, 10101399, 15000000, 0, 1)
END

IF NOT EXISTS (SELECT
    *
  FROM setup_menu
  WHERE function_id = 10202299
  AND product_category = 15000000
  AND hide_show = 1)
BEGIN
  INSERT INTO setup_menu (function_id, display_name, hide_show, parent_menu_id, product_category, menu_type, menu_order)
    VALUES (10202299, 'Disclosure', 1, 15000000, 15000000, 1, 1)
END

UPDATE setup_menu
SET parent_menu_id = 10202299,
    menu_order = 1
WHERE function_id IN (10202201, 10233600)
AND product_category = 15000000

UPDATE setup_menu
SET display_name = 'Setup Alert'
WHERE display_name = 'Setup Alerts'

UPDATE setup_menu
SET display_name = 'Setup Role'
WHERE display_name = 'Setup Roles'

UPDATE setup_menu
SET display_name = 'Create and View Deal'
WHERE display_name = 'Create and View Deals'

UPDATE setup_menu
SET display_name = 'View Price'
WHERE display_name = 'View Prices'

IF NOT EXISTS (SELECT
    1
  FROM setup_menu
  WHERE function_id = 10201800
  AND product_category = 15000000)
BEGIN
  INSERT INTO setup_menu (function_id, display_name, hide_show, parent_menu_id, product_category, menu_order, menu_type)
    VALUES (10201800, 'Report Group Manager', 1, 10221999, 15000000, 0, 0)
END

UPDATE setup_menu
SET display_name = 'Report Manager - Old'
WHERE function_id = 10201600
AND product_category = 15000000

IF NOT EXISTS (SELECT
    *
  FROM setup_menu
  WHERE function_id = 10202500
  AND product_category = 15000000)
BEGIN
  INSERT INTO setup_menu (function_id, display_name, hide_show, parent_menu_id, product_category, menu_order, menu_type)
    VALUES (10202500, 'Report Manager', 1, 10221999, 15000000, 0, 0)
END

UPDATE setup_menu
SET parent_menu_id = 10101099
WHERE function_id = 10101182
AND product_category = 15000000