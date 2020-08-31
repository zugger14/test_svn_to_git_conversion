TRUNCATE TABLE setup_menu

INSERT INTO setup_menu (
	function_id
	,display_name
	,parent_menu_id
	,product_category
	,default_parameter
	,window_name
	,hide_show
	,menu_type
	,menu_order
)

/***********************************TRMTracker Menus***************************************/

 SELECT	10000000	, 'TRMTracker',	NULL	,	10000000	,	NULL	, 	NULL		,1,	1,	1

 UNION ALL 
 SELECT	10100000	, 'Setup ',	10000000	,	10000000	,	NULL	, 	NULL		,1,	1,	2

 UNION ALL 
 SELECT	10101099	, 'Setup Static Data',	10100000	,	10000000	,	NULL	, 	NULL		,1,	1,	3

 UNION ALL 
 SELECT	10101000	, 'Maintain Static Data',	10101099	,	10000000	,	NULL	, 'windowMaintainStaticData',1,	0,	4

 UNION ALL 
 SELECT	10101100	, 'Maintain Definition',	10101099	,	10000000	,	NULL	, 'windowMaintainDefination',1,	0,	5

 UNION ALL 
 SELECT	10101200	, 'Setup Book Structure',	10101099	,	10000000	,	NULL	, 'windowSetupHedgingStrategies',1,	0,	6

 UNION ALL 
 SELECT	10102600	, 'Setup Price Curves',	10101099	,	10000000	,	NULL	, 'windowSetupPriceCurves',1,	0,	7

 UNION ALL 
 SELECT	10102500	, 'Setup Location',	10101099	,	10000000	,	NULL	, 'windowSetupLocation',1,	0,	8

 UNION ALL 
 SELECT	10102800	, 'Setup Profile',	10101099	,	10000000	,	NULL	, 'windowSetupProfile',1,	0,	9

 UNION ALL 
 SELECT	10101300	, 'Map GL Codes',	10100000	,	10000000	,	NULL	, 'windowMapGLCodes',1,	0,	10

 UNION ALL 
 SELECT	10101499	, 'Setup Deal Templates',	10100000	,	10000000	,	NULL	, NULL,1,	1,	11

 UNION ALL 
 SELECT	10101400	, 'Maintain Deal Template',	10101499	,	10000000	,	NULL	, 'windowMaintainDealTemplate',1,	0,	12

 UNION ALL 
 SELECT	10104200	, 'Maintain Field Template',	10101499	,	10000000	,	NULL	, 'windowSetupFieldTemplate',1,	0,	13

 UNION ALL 
 SELECT	10104100	, 'Maintain UDF Template',	10101499	,	10000000	,	NULL	, 'windowSetupUDFTemplate',1,	0,	14

 UNION ALL 
 SELECT	10103900	, 'Setup Deal Status and Confirmation Rule',	10101499	,	10000000	,	NULL	, 'windowSetupDealStatusConfirmationRule',1,	0,	15

 UNION ALL 
 SELECT	10104000	, 'Define Deal Status Privilege',	10101499	,	10000000	,	NULL	, 'windowDefineDealStatusPrivilege',1,	0,	16

 UNION ALL 
 SELECT	10103500	, 'Maintain Hedge Deferral Rules',	10101499	,	10000000	,	NULL	, 'windowSetupHedgingRelationshipsTypesWithReturn',1,	0,	17

 UNION ALL 
 SELECT	10101500	, 'Maintain Netting Asset/Liab Groups',	10100000	,	10000000	,	NULL	, 'windowMaintainNettingGroups',1,	0,	18

 UNION ALL 
 SELECT	10101600	, 'View Scheduled Job',	10100000	,	10000000	,	NULL	, 'windowSchedulejob',1,	0,	19

 UNION ALL 
 SELECT	10103000	, 'Define Meter IDs',	10100000	,	10000000	,	NULL	, 'windowDefineMeterID',1,	0,	20

 UNION ALL 
 SELECT	10103800	, 'Maintain Source Generator',	10100000	,	10000000	,	NULL	, 'windowMaintainSourceGenerator',1,	0,	21

 UNION ALL 
 SELECT	10103399	, 'Setup Contract Components ',	10100000	,	10000000	,	NULL	, NULL,1,	1,	22

 UNION ALL 
 SELECT	10103300	, 'Maintain Contract Components Gl Codes',	10103399	,	10000000	,	NULL	, 'windowDefineInvoiceGLCode',1,	0,	23

 UNION ALL 
 SELECT	10103400	, 'Setup Default GL Code for Contract Components',	10103399	,	10000000	,	NULL	, 'windowSetupDefaultGLCode',1,	0,	24

 UNION ALL 
 SELECT	10104300	, 'Setup Contract Component Mapping',	10103399	,	10000000	,	NULL	, 'windowSetupContractComponentMapping',1,	0,	25

 UNION ALL 
 SELECT	10104400	, 'Setup Contract Price',	10103399	,	10000000	,	NULL	, 'windowSetupContractPrice',1,	0,	26

 UNION ALL 
 SELECT	10101900	, 'Setup Logical Trade Lock',	10100000	,	10000000	,	NULL	, 'windowSetupDealLock',1,	0,	27

 UNION ALL 
 SELECT	10102000	, 'Setup Tenor Bucket',	10100000	,	10000000	,	NULL	, 'windowSetupTenorBucketData',1,	0,	28

 UNION ALL 
 SELECT	10102900	, 'Manage Documents',	10100000	,	10000000	,	NULL	, 'windowManageDocumentsMain',1,	0,	29

 UNION ALL 
 SELECT	10102300	, 'Setup Emissions Source/Sink Type',	10100000	,	10000000	,	NULL	, 'windowSetupEMSStrategies',1,	0,	30

 UNION ALL 
 SELECT	10102200	, 'Setup As of Date',	10100000	,	10000000	,	NULL	, 'windowSetupAsOfDate',1,	0,	31

 UNION ALL 
 SELECT	10102400	, 'Formula Builder',	10100000	,	10000000	,	NULL	, 'windowFormulaBuilder',1,	0,	32

 UNION ALL 
 SELECT	13170000	, 'Mapping Setup',	10100000	,	10000000	,	NULL	, NULL,1,	1,	33

 UNION ALL 
 SELECT	10103100	, 'Term Mapping ',	13170000	,	10000000	,	NULL	, 'windowSetupTrayportTermMappingStaging',1,	0,	34

 UNION ALL 
 SELECT	10103200	, 'Pratos Mapping',	13170000	,	10000000	,	NULL	, 'windowPratosMapping',1,	0,	35

 UNION ALL 
 SELECT	13171000	, 'ST Forecast Mapping',	13170000	,	10000000	,	NULL	, 'windowSTForecastMapping',1,	0,	36

 UNION ALL 
 SELECT	13102000	, 'Generic Mapping',	13170000	,	10000000	,	NULL	, 'windowGenericMapping',1,	0,	37

 UNION ALL 
 SELECT	10102799	, 'Manage Data',	10100000	,	10000000	,	NULL	, NULL,1,	1,	38

 UNION ALL 
 SELECT	10102700	, 'Archive Data',	10102799	,	10000000	,	NULL	, 'windowSetupArchiveData',1,	0,	39

 UNION ALL 
 SELECT	10103600	, 'Remove Data',	10102799	,	10000000	,	NULL	, 'windowRemoveData',1,	0,	40

 UNION ALL 
 SELECT	10104600	, 'Maintain Settlement Netting Group',	10100000	,	10000000	,	NULL	, 'windowMaintainNettingGrp',1,	0,	41

 UNION ALL 
 SELECT	10110000	, 'Users and Roles',	10000000	,	10000000	,	NULL	, NULL,1,	1,	42

 UNION ALL 
 SELECT	10111000	, 'Maintain Users',	10110000	,	10000000	,	NULL	, 'windowMaintainUsers',1,	0,	43

 UNION ALL 
 SELECT	10111100	, 'Maintain Roles',	10110000	,	10000000	,	NULL	, 'windowMaintainRoles',1,	0,	44

 UNION ALL 
 SELECT	10111200	, 'Maintain Work Flow Menu',	10110000	,	10000000	,	NULL	, 'windowCustomizedMenu',1,	0,	45

 UNION ALL 
 SELECT	10111300	, 'Run Privilege Report',	10110000	,	10000000	,	NULL	, 'windowRunPrivilege',1,	0,	46

 UNION ALL 
 SELECT	10111400	, 'Run System Access Log Report',	10110000	,	10000000	,	NULL	, 'windowRunSystemAccessLog',1,	0,	47

 UNION ALL 
 SELECT	10111500	, 'Maintain Report',	10110000	,	10000000	,	NULL	, 'windowMaintainReport',1,	0,	48

 UNION ALL 
 SELECT	10120000	, 'Compliance Management',	10000000	,	10000000	,	NULL	, NULL,1,	1,	49

 UNION ALL 
 SELECT	10121300	, 'Maintain Compliance Standards',	10120000	,	10000000	,	NULL	, 'MaintainComplianceStandards',1,	0,	50

 UNION ALL 
 SELECT	10121000	, 'Maintain Compliance Groups',	10120000	,	10000000	,	NULL	, 'maintainComplianceProcess',1,	0,	51

 UNION ALL 
 SELECT	10121400	, 'Activity Process Map',	10120000	,	10000000	,	NULL	, 'windowActivityProcessMap',1,	0,	52

 UNION ALL 
 SELECT	10121500	, 'Change Owners',	10120000	,	10000000	,	NULL	, 'MaintainChangeOwners',1,	0,	53

 UNION ALL 
 SELECT	10121200	, 'Perform Compliance Activities',	10120000	,	10000000	,	NULL	, 'PerformComplianceActivities',1,	0,	54

 UNION ALL 
 SELECT	10121100	, 'Approve Compliance Activities',	10120000	,	10000000	,	NULL	, 'ApproveComplianceActivities',1,	0,	55

 UNION ALL 
 SELECT	10122300	, 'Reports',	10120000	,	10000000	,	NULL	, NULL,1,	1,	56

 UNION ALL 
 SELECT	10121600	, 'View Compliance Activities',	10122300	,	10000000	,	NULL	, 'ViewComplianceActivities',1,	0,	57

 UNION ALL 
 SELECT	10121700	, 'View Status On Compliance Activities',	10122300	,	10000000	,	NULL	, 'ReportComplianceActivities',1,	0,	58

 UNION ALL 
 SELECT	10122200	, 'View Compliance Calendar',	10122300	,	10000000	,	NULL	, 'windowComplianceCalendar',1,	0,	59

 UNION ALL 
 SELECT	10121800	, 'Run Compliance Activity Audit Report',	10122300	,	10000000	,	NULL	, 'RunComplianceAuditReport',1,	0,	60

 UNION ALL 
 SELECT	10121900	, 'Run Compliance Trend Report',	10122300	,	10000000	,	NULL	, 'RunComplianceTrendReport',1,	0,	61

 UNION ALL 
 SELECT	10122000	, 'Run Compliance Graph Report',	10122300	,	10000000	,	NULL	, 'dashReportPie',1,	0,	62

 UNION ALL 
 SELECT	10122100	, 'Run Compliance Status Graph Report',	10122300	,	10000000	,	NULL	, 'dashReportBar',1,	0,	63

 UNION ALL 
 SELECT	10122400	, 'Run Compliance Due Date Violation Report',	10122300	,	10000000	,	NULL	, 'RunComplianceDateVoilationReport',1,	0,	64

 UNION ALL 
 SELECT	10111600	, 'Maintain Alerts',	10120000	,	10000000	,	NULL	, 'windowMaintainAlerts',1,	0,	65

 UNION ALL 
 SELECT	10130000	, 'Deal Capture',	10000000	,	10000000	,	NULL	, NULL,1,	1,	66

 UNION ALL 
 SELECT	10131000	, 'Maintain Transactions',	10130000	,	10000000	,	NULL	, 'windowMaintainDeals',1,	0,	67

 UNION ALL 
 SELECT	10131300	, 'Import Data',	10130000	,	10000000	,	NULL	, 'windowImportDataDeal',1,	0,	68

 UNION ALL 
 SELECT	10131500	, 'Import EPA Allowance Data',	10130000	,	10000000	,	NULL	, 'windowEPAAllowanceData',1,	0,	69

 UNION ALL 
 SELECT	10131600	, 'Transfer Book Position',	10130000	,	10000000	,	NULL	, 'windowTransferBookPosition',1,	0,	70

 UNION ALL 
 SELECT	10140000	, 'Position Reporting',	10000000	,	10000000	,	NULL	, NULL,1,	1,	71

 UNION ALL 
 SELECT	10141000	, 'Run Index Position Report',	10140000	,	10000000	,	NULL	, 'windowRunPositionReport',1,	0,	72

 UNION ALL 
 SELECT	10141700	, 'Run Trader Position Report',	10140000	,	10000000	,	NULL	, 'windowRunTraderPositionReport',1,	0,	73

 UNION ALL 
 SELECT	10141100	, 'Run Options Report',	10140000	,	10000000	,	NULL	, 'windowRunOptionsReport',1,	0,	74

 UNION ALL 
 SELECT	10141200	, 'Run Options Greeks Report',	10140000	,	10000000	,	NULL	, 'windowRunOptionsGreeksReport',1,	0,	75

 UNION ALL 
 SELECT	10141300	, 'Run Hourly Position Report',	10140000	,	10000000	,	NULL	, 'windowRunHourlyProductionReport',1,	0,	76

 UNION ALL 
 SELECT	10141900	, 'Run Load Forecast Report',	10140000	,	10000000	,	NULL	, 'windowRunLoadForecastReport',1,	0,	77

 UNION ALL 
 SELECT	10142100	, 'Run FX Exposure Report',	10140000	,	10000000	,	NULL	, 'windowRunFXExposureReport',1,	0,	78

 UNION ALL 
 SELECT	10142200	, 'Run Explain Report',	10140000	,	10000000	,	NULL	, 'windowRunPositionExplainReport',1,	0,	79

 UNION ALL 
 SELECT	10142300	, 'Run Power Bidding Nomination Report',	10140000	,	10000000	,	NULL	, 'windowPowerBiddingNominationReport',1,	0,	80

 UNION ALL 
 SELECT	10150000	, 'Price Curve Management',	10000000	,	10000000	,	NULL	, NULL,1,	1,	81

 UNION ALL 
 SELECT	10151000	, 'View Prices',	10150000	,	10000000	,	NULL	, 'windowViewPrices',1,	0,	82

 UNION ALL 
 SELECT	10151100	, 'Import Price',	10150000	,	10000000	,	NULL	, 'windowImportDataPrice',1,	0,	83

 UNION ALL 
 SELECT	10160000	, 'Scheduling And Delivery',	10000000	,	10000000	,	NULL	, NULL,1,	1,	84

 UNION ALL 
 SELECT	10161000	, 'Maintain Loss Factor',	10160000	,	10000000	,	NULL	, 'windowMaintainLossFactor',1,	0,	85

 UNION ALL 
 SELECT	10161100	, 'Setup Delivery Path',	10160000	,	10000000	,	NULL	, 'windowSetupDeliveryPath',1,	0,	86

 UNION ALL 
 SELECT	10162000	, 'Maintain Transportation Rate Schedule',	10160000	,	10000000	,	NULL	, 'windowMaintainTransRate',1,	0,	87

 UNION ALL 
 SELECT	10161200	, 'Run Gas Position Report',	10160000	,	10000000	,	NULL	, 'windowPositionGas',1,	0,	88

 UNION ALL 
 SELECT	10161300	, 'View Delivery Transactions',	10160000	,	10000000	,	NULL	, 'windowScheduleAndDelivery',1,	0,	89

 UNION ALL 
 SELECT	10161400	, 'Run Gas Storage Position Report',	10160000	,	10000000	,	NULL	, 'windowRunStoragePositionReport',1,	0,	90

 UNION ALL 
 SELECT	10161800	, 'Maintain Power Outage',	10160000	,	10000000	,	NULL	, 'windowMaintainPowerOutage',1,	0,	91

 UNION ALL 
 SELECT	10162600	, 'Pipeline Imbalance Report',	10160000	,	10000000	,	NULL	, 'windowImbalance',1,	0,	92

 UNION ALL 
 SELECT	10162100	, 'Run WACOG Report',	10160000	,	10000000	,	NULL	, 'windowWACOG',1,	0,	93

 UNION ALL 
 SELECT	10162200	, 'Run PNL Report',	10160000	,	10000000	,	NULL	, 'windowPNLReport',1,	0,	94

 UNION ALL 
 SELECT	10162300	, 'Storage Assets',	10160000	,	10000000	,	NULL	, 'windowVirtualGas',1,	0,	95

 UNION ALL 
 SELECT	10162500	, 'Run Inventory Calc',	10160000	,	10000000	,	NULL	, 'windowRunInventoryCalc',1,	0,	96

 UNION ALL 
 SELECT	10162400	, 'Run Roll Forward Inventory Report',	10160000	,	10000000	,	NULL	, 'windowRunRollForwardInventoryReport',1,	0,	97

 UNION ALL 
 SELECT	10170000	, 'Deal Verification And Confirmation',	10000000	,	10000000	,	NULL	, NULL,1,	1,	98

 UNION ALL 
 SELECT	10171000	, 'Confirm Transactions',	10170000	,	10000000	,	NULL	, 'windowConfirmModule',1,	0,	99

 UNION ALL 
 SELECT	10171400	, 'Update Deal Status and Confirmation',	10170000	,	10000000	,	NULL	, 'windowUpdateConfirmModule',1,	0,	100

 UNION ALL 
 SELECT	10171500	, 'Update Deal Status',	10170000	,	10000000	,	NULL	, 'windowUpdateModule',1,	0,	101

 UNION ALL 
 SELECT	10171100	, 'Transaction Audit Log Report',	10170000	,	10000000	,	NULL	, 'windowTransactionAuditLog',1,	0,	102

 UNION ALL 
 SELECT	10171200	, 'Lock/Unlock Deal',	10170000	,	10000000	,	NULL	, 'windowLockUnlockDeal',1,	0,	103

 UNION ALL 
 SELECT	10171300	, 'Run Unconfirmed Exception Report',	10170000	,	10000000	,	NULL	, 'windowUnconfirmedExeptionReport',1,	0,	104

 UNION ALL 
 SELECT	10180000	, 'Valuation And Risk Analysis',	10000000	,	10000000	,	NULL	, NULL,1,	1,	105

 UNION ALL 
 SELECT	10181099	, 'Run MTM',	10180000	,	10000000	,	NULL	, NULL,1,	1,	106

 UNION ALL 
 SELECT	10181000	, 'Run MTM Process',	10181099	,	10000000	,	NULL	, 'windowRunMtmCalc',1,	0,	107

 UNION ALL 
 SELECT	10181100	, 'Run MTM Report',	10181099	,	10000000	,	NULL	, 'windowMTMReport',1,	0,	108

 UNION ALL 
 SELECT	10182200	, 'Run Counterparty MTM report',	10181099	,	10000000	,	NULL	, 'windowCounterpartyMTMReport',1,	0,	109

 UNION ALL 
 SELECT	10183000	, 'Maintain Risk Factor Models',	10180000	,	10000000	,	NULL	, 'windowMaintainMonteCarloModels',1,	0,	110

 UNION ALL 
 SELECT	10183100	, 'Run Monte Carlo Simulation',	10180000	,	10000000	,	NULL	, 'windowRunMonteCarloSimulation',1,	0,	111

 UNION ALL 
 SELECT	10181299	, 'Run At Risk',	10180000	,	10000000	,	NULL	, NULL,1,	1,	112

 UNION ALL 
 SELECT	10181200	, 'Maintain At Risk Measurement Criteria',	10181299	,	10000000	,	NULL	, 'VaRMeasurementCriteriaDetail',1,	0,	113

 UNION ALL 
 SELECT	10181500	, 'Run At Risk calculation',	10181299	,	10000000	,	NULL	, 'VaRMeasurementCriteriaDetailReport',1,	0,	114

 UNION ALL 
 SELECT	10181600	, 'Run At Risk Report',	10181299	,	10000000	,	NULL	, 'windowVaRreport',1,	0,	115

 UNION ALL 
 SELECT	10181399	, 'Run Limits',	10180000	,	10000000	,	NULL	, NULL,1,	1,	116

 UNION ALL 
 SELECT	10181300	, 'Maintain Limits',	10181399	,	10000000	,	NULL	, 'LimitTrackingScreen',1,	0,	117

 UNION ALL 
 SELECT	10181700	, 'Run Limits Report',	10181399	,	10000000	,	NULL	, 'windowLimitsReport',1,	0,	118

 UNION ALL 
 SELECT	10181499	, 'Run Volatility Calculations',	10180000	,	10000000	,	NULL	, NULL,1,	1,	119

 UNION ALL 
 SELECT	10181400	, 'Calculate Volatility, Correlation and Expected Return',	10181499	,	10000000	,	NULL	, 'CalculateVolatilityCorrelation',1,	0,	120

 UNION ALL 
 SELECT	10182000	, 'View Volatility, Correlation and Expected Return',	10181499	,	10000000	,	NULL	, 'windowViewVolCorReport',1,	0,	121

 UNION ALL 
 SELECT	10181800	, 'Run Implied Volatility Calculation',	10181499	,	10000000	,	NULL	, 'windowCalImpVolatility',1,	0,	122

 UNION ALL 
 SELECT	10181900	, 'Run Implied Volatility Report',	10181499	,	10000000	,	NULL	, 'windowReportImpVol',1,	0,	123

 UNION ALL 
 SELECT	10182300	, 'Financial Model',	10180000	,	10000000	,	NULL	, 'windowCashflowEarningsModel',1,	0,	124

 UNION ALL 
 SELECT	10182600	, 'Calculate Financial Forecast',	10180000	,	10000000	,	NULL	, 'windowCalculateFinancialForecast',1,	0,	125

 UNION ALL 
 SELECT	10182400	, 'Financial Forecast Report',	10180000	,	10000000	,	NULL	, 'windowRunCashflowEarningsReport',1,	0,	126

 UNION ALL 
 SELECT	10182900	, 'Run Hedge Cashflow Deferral Report',	10180000	,	10000000	,	NULL	, 'windowRunHedgeCashflowDeferral',1,	0,	127

 UNION ALL 
 SELECT	10183499	, 'Run What-If',	10180000	,	10000000	,	NULL	, NULL,1,	1,	128

 UNION ALL 
 SELECT	10183200	, 'Maintain Portfolio Group',	10183499	,	10000000	,	NULL	, 'windowMaintainPortfolioGroup',1,	0,	129

 UNION ALL 
 SELECT	10183300	, 'Maintain What-If Scenario',	10183499	,	10000000	,	NULL	, 'windowMaintainWhatIfScenario',1,	0,	130

 UNION ALL 
 SELECT	10183400	, 'Maintain What-If Criteria',	10183499	,	10000000	,	NULL	, 'windowMaintainWhatIfCriteria',1,	0,	131

 UNION ALL 
 SELECT	10183500	, 'Run What-If Analysis Report',	10183499	,	10000000	,	NULL	, 'windowRunWhatIfAnalysisReport',1,	0,	132

 UNION ALL 
 SELECT	10190000	, 'Credit Risk And Analysis',	10000000	,	10000000	,	NULL	, NULL,1,	1,	133

 UNION ALL 
 SELECT	10191000	, 'Maintain Counterparty',	10190000	,	10000000	,	NULL	, 'windowMaintainDefinationArg',1,	0,	134

 UNION ALL 
 SELECT	10192000	, 'Maintain Counterparty Limit',	10190000	,	10000000	,	NULL	, 'windowMaintainCounterpartyLimit',1,	0,	135

 UNION ALL 
 SELECT	10191100	, 'Import Credit Data',	10190000	,	10000000	,	NULL	, 'windowImportDataCredit',1,	0,	136

 UNION ALL 
 SELECT	10191200	, 'Export Credit Data Report',	10190000	,	10000000	,	NULL	, 'windowExportCreditData',1,	0,	137

 UNION ALL 
 SELECT	10191300	, 'Run Credit Exposure Report',	10190000	,	10000000	,	NULL	, 'windowRunCreditExposureReport',1,	0,	138

 UNION ALL 
 SELECT	10191400	, 'Run Fixed/MTM Exposure Report',	10190000	,	10000000	,	NULL	, 'windowRunFixdMtmExposureReport',1,	0,	139

 UNION ALL 
 SELECT	10191500	, 'Run Exposure Concentration Report',	10190000	,	10000000	,	NULL	, 'windowRunConcExposureReport',1,	0,	140

 UNION ALL 
 SELECT	10191600	, 'Run Credit Reserve Report',	10190000	,	10000000	,	NULL	, 'windowCrRunReserveReport',1,	0,	141

 UNION ALL 
 SELECT	10191700	, 'Run Aged A/R Report',	10190000	,	10000000	,	NULL	, 'windowAgedARReport',1,	0,	142

 UNION ALL 
 SELECT	10191800	, 'Calculate Credit Exposure',	10190000	,	10000000	,	NULL	, 'windowCalculateCreditExposure',1,	0,	143

 UNION ALL 
 SELECT	10191900	, 'Run Counterparty Credit Availability Report',	10190000	,	10000000	,	NULL	, 'windowCounterpartyCreditAvailability',1,	0,	144

 UNION ALL 
 SELECT	10200000	, 'Reporting',	10000000	,	10000000	,	NULL	, NULL,1,	1,	145

 UNION ALL 
 SELECT	10201000	, 'Report Writer',	10200000	,	10000000	,	NULL	, 'windowreportwriter',1,	0,	146

 UNION ALL 
 SELECT	10201300	, 'Maintain EoD Log Status',	10200000	,	10000000	,	NULL	, 'windowMaintainEoDLogStatus',1,	0,	147

 UNION ALL 
 SELECT	10201400	, 'Run Import Audit Report',	10200000	,	10000000	,	NULL	, 'windowRunFilesImportAuditReportPrice',1,	0,	148

 UNION ALL 
 SELECT	10201500	, 'Run Static Data Audit Report',	10200000	,	10000000	,	NULL	, 'windowRunStaticDataAuditReport',1,	0,	149

 UNION ALL 
 SELECT	10201600	, 'Report Manager',	10200000	,	10000000	,	NULL	, 'windowReportManager',1,	0,	150

 UNION ALL 
 SELECT	10201100	, 'Run Report Group',	10200000	,	10000000	,	NULL	, 'WindowRunReportGroup',1,	0,	151

 UNION ALL 
 SELECT	10201200	, 'Report Group Manager',	10200000	,	10000000	,	NULL	, 'WindowReportGroupManager',1,	0,	152

 UNION ALL 
 SELECT	10210000	, 'Contract Administration',	10000000	,	10000000	,	NULL	, NULL,1,	1,	153

 UNION ALL 
 SELECT	10211000	, 'Maintain Contract',	10210000	,	10000000	,	NULL	, 'windowMaintainContract',1,	0,	154

 UNION ALL 
 SELECT	10162700	, 'Maintain Transportation Contract',	10210000	,	10000000	,	NULL	, 'windowTransportationContract',1,	0,	155

 UNION ALL 
 SELECT	10211010	, 'Maintain Settlement Rules',	10210000	,	10000000	,	NULL	, 'windowMaintainContractGroup',1,	0,	156

 UNION ALL 
 SELECT	10211100	, 'Contract Component Templates',	10210000	,	10000000	,	NULL	, 'windowContractChargeType',1,	0,	157

 UNION ALL 
 SELECT	10220000	, 'Settlement And Billing',	10000000	,	10000000	,	NULL	, NULL,1,	1,	158

 UNION ALL 
 SELECT	10221099	, 'Run Settlement Calc',	10220000	,	10000000	,	NULL	, NULL,1,	1,	159

 UNION ALL 
 SELECT	10221000	, 'Run Contract Settlement',	10221099	,	10000000	,	NULL	, 'windowMaintainInvoice',1,	0,	160

 UNION ALL 
 SELECT	10222300	, 'Run Deal Settlement',	10221099	,	10000000	,	NULL	, 'windowRunSettlement',1,	0,	161

 UNION ALL 
 SELECT	10221100	, 'Run Inventory Calc',	10221099	,	10000000	,	NULL	, 'windowRunInventoryCalc',1,	0,	162

 UNION ALL 
 SELECT	10221300	, 'Settlement Calculation History',	10221099	,	10000000	,	NULL	, 'windowMaintainInvoiceHistory',1,	0,	163

 UNION ALL 
 SELECT	10221999	, 'Run Settlement Report',	10220000	,	10000000	,	NULL	, NULL,1,	1,	164

 UNION ALL 
 SELECT	10221900	, 'Run Settlement Report',	10221999	,	10000000	,	NULL	, 'windowSettlementReport',1,	0,	165

 UNION ALL 
 SELECT	10221200	, 'Run Contract Settlement Report',	10221999	,	10000000	,	NULL	, 'windowBrokerFeeReport',1,	0,	166

 UNION ALL 
 SELECT	10221800	, 'Run Settlement Production Report',	10221999	,	10000000	,	NULL	, 'windowSettlementProductionReport',1,	0,	167

 UNION ALL 
 SELECT	10222400	, 'Run Meter Data Report',	10220000	,	10000000	,	NULL	, 'windowMeterDataReport',1,	0,	168

 UNION ALL 
 SELECT	10221400	, 'Post JE Report',	10220000	,	10000000	,	NULL	, 'windowPostJEReport',1,	0,	169

 UNION ALL 
 SELECT	10221600	, 'Settlement Adjustments',	10220000	,	10000000	,	NULL	, 'windowSettlementAdjustments',1,	0,	170

 UNION ALL 
 SELECT	10221700	, 'Market Variance Report',	10220000	,	10000000	,	NULL	, 'windowMarketVarienceReport',1,	0,	171

 UNION ALL 
 SELECT	10222000	, 'SAP Settlement Export',	10220000	,	10000000	,	NULL	, 'windowSAPSettlementExport',1,	0,	172

 UNION ALL 
 SELECT	10230000	, 'Accounting Inventory',	10000000	,	10000000	,	NULL	, NULL,1,	1,	173

 UNION ALL 
 SELECT	10231000	, 'Maintain Inventory GL Account',	10230000	,	10000000	,	NULL	, 'windowMaintainInventoryGLAccount',1,	0,	174

 UNION ALL 
 SELECT	10231100	, 'Run Inventory Journal Entry Report',	10230000	,	10000000	,	NULL	, 'windowRunInventoryAccountReport',1,	0,	175

 UNION ALL 
 SELECT	10231200	, 'Run Weighted Averag Inventory Cost Report',	10230000	,	10000000	,	NULL	, 'windowRunWghtInventoryCostReport',1,	0,	176

 UNION ALL 
 SELECT	10162400	, 'Run Roll Forward Inventory Report',	10230000	,	10000000	,	NULL	, 'windowRunRollForwardInventoryReport',1,	0,	177

 UNION ALL 
 SELECT	10237000	, 'Maintain Manual Journal Entries',	10230000	,	10000000	,	NULL	, 'windowMaintainManualJournalEntries',1,	0,	178

 UNION ALL 
 SELECT	10237100	, 'Maintain Inventory Cost Override',	10230000	,	10000000	,	NULL	, 'windowInventoryCostOverride',1,	0,	179

 UNION ALL 
 SELECT	10237200	, 'Run Inventory Calc',	10230000	,	10000000	,	NULL	, 'windowRunInventoryCalc',1,	0,	180

 UNION ALL 
 SELECT	10230098	, 'Accounting derivative Accounting Srategy',	10000000	,	10000000	,	NULL	, NULL,1,	1,	181

 UNION ALL 
 SELECT	10231900	, 'Setup Hedging Relationship Types',	10230098	,	10000000	,	NULL	, 'windowSetupHedgingRelationshipsTypes',1,	0,	182

 UNION ALL 
 SELECT	10232000	, 'Run Hedging Relationship Types Report',	10230098	,	10000000	,	NULL	, 'windowRunSetupHedgingRelationshipsTypesReport',1,	0,	183

 UNION ALL 
 SELECT	10101500	, 'Maintain Netting Asset/Liab Groups',	10230098	,	10000000	,	NULL	, 'windowMaintainNettingGroups',1,	0,	184

 UNION ALL 
 SELECT	10230096	, 'Accounting derivative Hedge Effeciveness Test',	10000000	,	10000000	,	NULL	, NULL,1,	1,	185

 UNION ALL 
 SELECT	10232300	, 'Run Assessment',	10230096	,	10000000	,	NULL	, 'windowRunAssessment',1,	0,	186

 UNION ALL 
 SELECT	10232400	, 'View Assessment Results',	10230096	,	10000000	,	NULL	, 'windowViewAssessmentResults',1,	0,	187

 UNION ALL 
 SELECT	10237300	, 'View/Update Cum PNL Series',	10230096	,	10000000	,	NULL	, 'windowViewUpdateCumPNLSeries',1,	0,	188

 UNION ALL 
 SELECT	10232500	, 'Run Assessment Trend Graph',	10230096	,	10000000	,	NULL	, 'windowRunAssessmentTrendGraph',1,	0,	189

 UNION ALL 
 SELECT	10232600	, 'Run What-If Effectiveness Analysis',	10230096	,	10000000	,	NULL	, 'windowRunWhatIfEffectivenessAnalysis',1,	0,	190

 UNION ALL 
 SELECT	10230097	, 'Accounting derivative Deal Capture',	10000000	,	10000000	,	NULL	, NULL,1,	1,	191

 UNION ALL 
 SELECT	10232700	, 'Import Data',	10230097	,	10000000	,	NULL	, 'windowImportData',1,	0,	192

 UNION ALL 
 SELECT	10232800	, 'Run Import Audit Report',	10230097	,	10000000	,	NULL	, 'windowRunFilesImportAuditReport',1,	0,	193

 UNION ALL 
 SELECT	10232900	, 'Maintain Missing Static Data',	10230097	,	10000000	,	NULL	, 'windowMaintainMissingStaticData',1,	0,	194

 UNION ALL 
 SELECT	10233000	, 'Delete Voided Deal',	10230097	,	10000000	,	NULL	, 'windowVoidDealImports',1,	0,	195

 UNION ALL 
 SELECT	10103000	, 'Define Meter IDs',	10230097	,	10000000	,	NULL	, 'windowDefineMeterID',1,	0,	196

 UNION ALL 
 SELECT	10230095	, 'Accounting derivative Transaction Processing',	10000000	,	10000000	,	NULL	, NULL,1,	1,	197

 UNION ALL 
 SELECT	10233700	, 'Designation of a Hedge',	10230095	,	10000000	,	NULL	, 'windowDesignationofaHedgeFromMenu',1,	0,	198

 UNION ALL 
 SELECT	10233800	, 'De-Designation of a Hedge by FIFO/LIFO',	10230095	,	10000000	,	NULL	, 'windowDedesignateFifolifo',1,	0,	199

 UNION ALL 
 SELECT	10233900	, 'Run Hedging Relationship Report',	10230095	,	10000000	,	NULL	, 'windowRunHedgeRelationshipReport',1,	0,	200

 UNION ALL 
 SELECT	10234000	, 'Reclassify Hedge De-Designation',	10230095	,	10000000	,	NULL	, 'windowReclassifyDedesignationValues',1,	0,	201

 UNION ALL 
 SELECT	10234100	, 'Amortize Deferred AOCI',	10230095	,	10000000	,	NULL	, 'windowAmortizeLockedAOCI',1,	0,	202

 UNION ALL 
 SELECT	10234200	, 'Life Cycle of Hedges',	10230095	,	10000000	,	NULL	, 'windowLifecyclesOfHedges',1,	0,	203

 UNION ALL 
 SELECT	10234300	, 'Automation of Forecasted Transaction',	10230095	,	10000000	,	NULL	, 'windowAutomationofForecastedTransaction',1,	0,	204

 UNION ALL 
 SELECT	10234400	, 'Automate Matching of Hedges',	10230095	,	10000000	,	NULL	, 'windowAutomationMathingHedge',1,	0,	205

 UNION ALL 
 SELECT	10234500	, 'View Outstanding Automation Results',	10230095	,	10000000	,	NULL	, 'windowViewOutstandingAutomationResults',1,	0,	206

 UNION ALL 
 SELECT	10234600	, 'First Day Gain/Loss Treatment',	10230095	,	10000000	,	NULL	, 'windowFirstDayGainLoss',1,	0,	207

 UNION ALL 
 SELECT	10234700	, 'Maintain Transactions Tagging',	10230095	,	10000000	,	NULL	, 'windowMaintainTransactionsTagging',1,	0,	208

 UNION ALL 
 SELECT	10234800	, 'Bifurcation Of Embedded Derivatives',	10230095	,	10000000	,	NULL	, 'windowBifurcationEmbeddedDerivatives',1,	0,	209

 UNION ALL 
 SELECT	10230094	, 'Accounting derivative Ongoing Assessment',	10000000	,	10000000	,	NULL	, NULL,1,	1,	210

 UNION ALL 
 SELECT	10233200	, 'Run What-If Measurement Analysis',	10230094	,	10000000	,	NULL	, 'windowRunwhatifmeasurementana',1,	0,	211

 UNION ALL 
 SELECT	10181000	, 'Run MTM',	10230094	,	10000000	,	NULL	, 'windowRunMtmCalc',1,	0,	212

 UNION ALL 
 SELECT	10233300	, 'Copy Prior MTM Value',	10230094	,	10000000	,	NULL	, 'windowPriorMTM',1,	0,	213

 UNION ALL 
 SELECT	10233400	, 'Run Measurement',	10230094	,	10000000	,	NULL	, 'windowRunMeasurement',1,	0,	214

 UNION ALL 
 SELECT	10233500	, 'Run Calc Embedded Derivative',	10230094	,	10000000	,	NULL	, 'windowCalcEmbedded',1,	0,	215

 UNION ALL 
 SELECT	10233600	, 'Close Accounting Period',	10230094	,	10000000	,	NULL	, 'windowCloseMeasurement',1,	0,	216

 UNION ALL 
 SELECT	10230093	, 'Accounting derivative Reporting',	10000000	,	10000000	,	NULL	, NULL,1,	1,	217

 UNION ALL 
 SELECT	10234900	, 'Run Measurement Report',	10230093	,	10000000	,	NULL	, 'windowRunMeasurementReport',1,	0,	218

 UNION ALL 
 SELECT	10235000	, 'Run Measurement Trend Graph',	10230093	,	10000000	,	NULL	, 'windowRunMeasurementTrendGraph',1,	0,	219

 UNION ALL 
 SELECT	10235100	, 'Run Period Change Values Report',	10230093	,	10000000	,	NULL	, 'windowPeriodChangeValueReport',1,	0,	220

 UNION ALL 
 SELECT	10235200	, 'Run AOCI Report',	10230093	,	10000000	,	NULL	, 'windowAOCIReport',1,	0,	221

 UNION ALL 
 SELECT	13160000	, 'Run Hedging Relationship Audit Report',	10230093	,	10000000	,	NULL	, 'windowHedgingRelationshipReport',1,	0,	222

 UNION ALL 
 SELECT	10235300	, 'Run De-Designation Values Report',	10230093	,	10000000	,	NULL	, 'windowDedesignateReport',1,	0,	223

 UNION ALL 
 SELECT	10235400	, 'Run Journal Entry Report',	10230093	,	10000000	,	NULL	, 'windowRunJournalEntryReport',1,	0,	224

 UNION ALL 
 SELECT	10235500	, 'Run Netted Journal Entry Report',	10230093	,	10000000	,	NULL	, 'windowRunNettedJournalEntryReport',1,	0,	225

 UNION ALL 
 SELECT	10234900	, 'Run Hedge Cashflow Deferral Report',	10230093	,	10000000	,	NULL	, 'windowRunHedgeCashflowDeferral',1,	0,	226

 UNION ALL 
 SELECT	10230092	, 'Run Disclosure Report',	10230093	,	10000000	,	NULL	, NULL,1,	1,	227

 UNION ALL 
 SELECT	10235600	, 'Run Accounting Disclosure Report',	10230092	,	10000000	,	NULL	, 'windowRunDisclosureReport',1,	0,	228

 UNION ALL 
 SELECT	10235700	, 'Run Fair Value Disclosure Report',	10230092	,	10000000	,	NULL	, 'windowRunnetAssetsReport',1,	0,	229

 UNION ALL 
 SELECT	10235800	, 'Run Assessment Report',	10230093	,	10000000	,	NULL	, 'windowRunAssessmentReport',1,	0,	230

 UNION ALL 
 SELECT	10235900	, 'Run Transaction Report',	10230093	,	10000000	,	NULL	, 'windowRunDealReport',1,	0,	231

 UNION ALL 
 SELECT	10236000	, 'Run Tagging Export',	10230093	,	10000000	,	NULL	, 'windowTaggingExport',1,	0,	232

 UNION ALL 
 SELECT	10230091	, 'Run Exception Report',	10230093	,	10000000	,	NULL	, NULL,1,	1,	233

 UNION ALL 
 SELECT	10236100	, 'Run Missing Assessment Values Report',	10230091	,	10000000	,	NULL	, 'windowRunMissingAssessmentValuesReport',1,	0,	234

 UNION ALL 
 SELECT	10236200	, 'Run Failed Assessment Values Report',	10230091	,	10000000	,	NULL	, 'windowRunFailAssessmentValuesReport',1,	0,	235

 UNION ALL 
 SELECT	10236300	, 'Run Unapproved Hedging Relationship Exception Report',	10230091	,	10000000	,	NULL	, 'windowRunUnapprovedHedgingRelationshipExceptionReport',1,	0,	236

 UNION ALL 
 SELECT	10236400	, 'Run Available Hedge Capacity Exception Report',	10230091	,	10000000	,	NULL	, 'windowRunAvailableHedgeCapacityExceptionReport',1,	0,	237

 UNION ALL 
 SELECT	10236500	, 'Run Not Mapped Transaction Report',	10230091	,	10000000	,	NULL	, 'windowRunNotMappedDealReport',1,	0,	238

 UNION ALL 
 SELECT	10236600	, 'Run Tagging Audit Report',	10230091	,	10000000	,	NULL	, 'windowRunTaggingAuditReport',1,	0,	239

 UNION ALL 
 SELECT	10236700	, 'Run Hedge and Item Position Matching Report',	10230091	,	10000000	,	NULL	, 'windowHedgeItemMatchExceptRpt',1,	0,	240

 UNION ALL 
 SELECT	10201000	, 'Report Writer',	10230093	,	10000000	,	NULL	, 'windowreportwriter',1,	0,	241

 UNION ALL 
 SELECT	10230099	, 'Accounting Accural',	10000000	,	10000000	,	NULL	, NULL,1,	1,	242

 UNION ALL 
 SELECT	10231500	, 'Curve Value Report',	10230099	,	10000000	,	NULL	, 'windowCurveValueReport',1,	0,	243

 UNION ALL 
 SELECT	10231600	, 'Run Revenue Report',	10230099	,	10000000	,	NULL	, 'windowRevenueReport',1,	0,	244

 UNION ALL 
 SELECT	10231700	, 'Run Accrual Journal Entry Report',	10230099	,	10000000	,	NULL	, 'windowRunInventoryJournalEntryReport',1,	0,	245

 UNION ALL 
 SELECT	10231800	, 'Run EQR Report',	10230099	,	10000000	,	NULL	, 'windowRunEQRReport',1,	0,	246

 UNION ALL 
 SELECT	10240000	, 'Treasury',	10000000	,	10000000	,	NULL	, NULL,1,	1,	247

 UNION ALL 
 SELECT	10241000	, 'Reconcile Cash Entries for Derivatives',	10240000	,	10000000	,	NULL	, 'windowReconcileCashEntriesDerivatives',1,	0,	248

 UNION ALL 
 SELECT	10241100	, 'Apply Cash',	10240000	,	10000000	,	NULL	, 'windowApplyCash',1,	0,	249

/**********************************FASTracker Menus*********************************************************************/

 UNION ALL 
SELECT	13000000	, 'FASTracker',	NULL	,	13000000	,	NULL	, 	NULL		,1,	1,	1				

 UNION ALL 
SELECT	10100000	, 'Setup ',	10000000	,	13000000	,	NULL	, 	NULL		,1,	1,	2				

 UNION ALL 
SELECT	10101099	, 'Setup Static Data',	10100000	,	13000000	,	NULL	, 	NULL		,1,	1,	3				

 UNION ALL 
SELECT	10101000	, 'Maintain Static Data',	10101099	,	13000000	,	NULL	, 'windowMaintainStaticData',1,	0,	4				

 UNION ALL 
SELECT	10101100	, 'Maintain Definition',	10101099	,	13000000	,	NULL	, 'windowMaintainDefination',1,	0,	5				

 UNION ALL 
SELECT	10101200	, 'Setup Book Structure',	10101099	,	13000000	,	NULL	, 'windowSetupHedgingStrategies',1,	0,	6				

 UNION ALL 
SELECT	10102600	, 'Setup Price Curves',	10101099	,	13000000	,	NULL	, 'windowSetupPriceCurves',1,	0,	7				

 UNION ALL 
SELECT	10102500	, 'Setup Location',	10101099	,	13000000	,	NULL	, 'windowSetupLocation',1,	0,	8				

 UNION ALL 
SELECT	10102800	, 'Setup Profile',	10101099	,	13000000	,	NULL	, 'windowSetupProfile',1,	0,	9				

 UNION ALL 
SELECT	10101300	, 'Map GL Codes',	10100000	,	13000000	,	NULL	, 'windowMapGLCodes',1,	0,	10				

 UNION ALL 
SELECT	10101499	, 'Setup Deal Templates',	10100000	,	13000000	,	NULL	, NULL,1,	1,	11				

 UNION ALL 
SELECT	10101400	, 'Maintain Deal Template',	10101499	,	13000000	,	NULL	, 'windowMaintainDealTemplate',1,	0,	12				

 UNION ALL 
SELECT	10104200	, 'Maintain Field Template',	10101499	,	13000000	,	NULL	, 'windowSetupFieldTemplate',1,	0,	13				

 UNION ALL 
SELECT	10104100	, 'Maintain UDF Template',	10101499	,	13000000	,	NULL	, 'windowSetupUDFTemplate',1,	0,	14				

 UNION ALL 
SELECT	10103900	, 'Setup Deal Status and Confirmation Rule',	10101499	,	13000000	,	NULL	, 'windowSetupDealStatusConfirmationRule',1,	0,	15				

 UNION ALL 
SELECT	10104000	, 'Define Deal Status Privilege',	10101499	,	13000000	,	NULL	, 'windowDefineDealStatusPrivilege',1,	0,	16				

 UNION ALL 
SELECT	10103500	, 'Maintain Hedge Deferral Rules',	10101499	,	13000000	,	NULL	, 'windowSetupHedgingRelationshipsTypesWithReturn',1,	0,	17				

 UNION ALL 
SELECT	10101500	, 'Maintain Netting Asset/Liab Groups',	10100000	,	13000000	,	NULL	, 'windowMaintainNettingGroups',1,	0,	18				

 UNION ALL 
SELECT	10101600	, 'View Scheduled Job',	10100000	,	13000000	,	NULL	, 'windowSchedulejob',1,	0,	19				

 UNION ALL 
SELECT	10103000	, 'Define Meter IDs',	10100000	,	13000000	,	NULL	, 'windowDefineMeterID',1,	0,	20				

 UNION ALL 
SELECT	10103800	, 'Maintain Source Generator',	10100000	,	13000000	,	NULL	, 'windowMaintainSourceGenerator',1,	0,	21				

 UNION ALL 
SELECT	10103399	, 'Setup Contract Components ',	10100000	,	13000000	,	NULL	, NULL,1,	1,	22				

 UNION ALL 
SELECT	10103300	, 'Maintain Contract Components Gl Codes',	10103399	,	13000000	,	NULL	, 'windowDefineInvoiceGLCode',1,	0,	23				

 UNION ALL 
SELECT	10103400	, 'Setup Default GL Code for Contract Components',	10103399	,	13000000	,	NULL	, 'windowSetupDefaultGLCode',1,	0,	24				

 UNION ALL 
SELECT	10104300	, 'Setup Contract Component Mapping',	10103399	,	13000000	,	NULL	, 'windowSetupContractComponentMapping',1,	0,	25				

 UNION ALL 
SELECT	10104400	, 'Setup Contract Price',	10103399	,	13000000	,	NULL	, 'windowSetupContractPrice',1,	0,	26				

 UNION ALL 
SELECT	10101900	, 'Setup Logical Trade Lock',	10100000	,	13000000	,	NULL	, 'windowSetupDealLock',1,	0,	27				

 UNION ALL 
SELECT	10102000	, 'Setup Tenor Bucket',	10100000	,	13000000	,	NULL	, 'windowSetupTenorBucketData',1,	0,	28				

 UNION ALL 
SELECT	10102900	, 'Manage Documents',	10100000	,	13000000	,	NULL	, 'windowManageDocumentsMain',1,	0,	29				

 UNION ALL 
SELECT	10102300	, 'Setup Emissions Source/Sink Type',	10100000	,	13000000	,	NULL	, 'windowSetupEMSStrategies',1,	0,	30				

 UNION ALL 
SELECT	10102200	, 'Setup As of Date',	10100000	,	13000000	,	NULL	, 'windowSetupAsOfDate',1,	0,	31				

 UNION ALL 
SELECT	10102400	, 'Formula Builder',	10100000	,	13000000	,	NULL	, 'windowFormulaBuilder',1,	0,	32				

 UNION ALL 
SELECT	13170000	, 'Mapping Setup',	10100000	,	13000000	,	NULL	, NULL,1,	1,	33				

 UNION ALL 
SELECT	10103100	, 'Term Mapping ',	13170000	,	13000000	,	NULL	, 'windowSetupTrayportTermMappingStaging',1,	0,	34				

 UNION ALL 
SELECT	10103200	, 'Pratos Mapping',	13170000	,	13000000	,	NULL	, 'windowPratosMapping',1,	0,	35				

 UNION ALL 
SELECT	13171000	, 'ST Forecast Mapping',	13170000	,	13000000	,	NULL	, 'windowSTForecastMapping',1,	0,	36				

 UNION ALL 
SELECT	10102799	, 'Manage Data',	10100000	,	13000000	,	NULL	, NULL,1,	1,	37				

 UNION ALL 
SELECT	10102700	, 'Archive Data',	10102799	,	13000000	,	NULL	, 'windowSetupArchiveData',1,	0,	38				

 UNION ALL 
SELECT	10103600	, 'Remove Data',	10102799	,	13000000	,	NULL	, 'windowRemoveData',1,	0,	39				

 UNION ALL 
SELECT	10110000	, 'Users and Roles',	10000000	,	13000000	,	NULL	, NULL,1,	1,	40				

 UNION ALL 
SELECT	10111000	, 'Maintain Users',	10110000	,	13000000	,	NULL	, 'windowMaintainUsers',1,	0,	41				

 UNION ALL 
SELECT	10111100	, 'Maintain Roles',	10110000	,	13000000	,	NULL	, 'windowMaintainRoles',1,	0,	42				

 UNION ALL 
SELECT	10111200	, 'Maintain Work Flow Menu',	10110000	,	13000000	,	NULL	, 'windowCustomizedMenu',1,	0,	43				

 UNION ALL 
SELECT	10111300	, 'Run Privilege Report',	10110000	,	13000000	,	NULL	, 'windowRunPrivilege',1,	0,	44				

 UNION ALL 
SELECT	10111400	, 'Run System Access Log Report',	10110000	,	13000000	,	NULL	, 'windowRunSystemAccessLog',1,	0,	45				

 UNION ALL 
SELECT	10111500	, 'Maintain Report',	10110000	,	13000000	,	NULL	, 'windowMaintainReport',1,	0,	46				

 UNION ALL 
SELECT	10111600	, 'Maintain Alerts',	10110001	,	13000000	,	NULL	, 'windowMaintainAlerts',1,	0,	47				

 UNION ALL 
SELECT	10120000	, 'Compliance Management',	10000000	,	13000000	,	NULL	, NULL,1,	1,	48				

 UNION ALL 
SELECT	10121300	, 'Maintain Compliance Standards',	10120000	,	13000000	,	NULL	, 'MaintainComplianceStandards',1,	0,	49				

 UNION ALL 
SELECT	10121000	, 'Maintain Compliance Groups',	10120000	,	13000000	,	NULL	, 'maintainComplianceProcess',1,	0,	50				

 UNION ALL 
SELECT	10121400	, 'Activity Process Map',	10120000	,	13000000	,	NULL	, 'windowActivityProcessMap',1,	0,	51				

 UNION ALL 
SELECT	10121500	, 'Change Owners',	10120000	,	13000000	,	NULL	, 'MaintainChangeOwners',1,	0,	52				

 UNION ALL 
SELECT	10121200	, 'Perform Compliance Activities',	10120000	,	13000000	,	NULL	, 'PerformComplianceActivities',1,	0,	53				

 UNION ALL 
SELECT	10121100	, 'Approve Compliance Activities',	10120000	,	13000000	,	NULL	, 'ApproveComplianceActivities',1,	0,	54				

 UNION ALL 
SELECT	10122300	, 'Reports',	10120000	,	13000000	,	NULL	, NULL,1,	1,	55				

 UNION ALL 
SELECT	10121600	, 'View Compliance Activities',	10122300	,	13000000	,	NULL	, 'ViewComplianceActivities',1,	0,	56				

 UNION ALL 
SELECT	10121700	, 'View Status On Compliance Activities',	10122300	,	13000000	,	NULL	, 'ReportComplianceActivities',1,	0,	57				

 UNION ALL 
SELECT	10122200	, 'View Compliance Calendar',	10122300	,	13000000	,	NULL	, 'windowComplianceCalendar',1,	0,	58				

 UNION ALL 
SELECT	10121800	, 'Run Compliance Activity Audit Report',	10122300	,	13000000	,	NULL	, 'RunComplianceAuditReport',1,	0,	59				

 UNION ALL 
SELECT	10121900	, 'Run Compliance Trend Report',	10122300	,	13000000	,	NULL	, 'RunComplianceTrendReport',1,	0,	60				

 UNION ALL 
SELECT	10122000	, 'Run Compliance Graph Report',	10122300	,	13000000	,	NULL	, 'dashReportPie',1,	0,	61				

 UNION ALL 
SELECT	10122100	, 'Run Compliance Status Graph Report',	10122300	,	13000000	,	NULL	, 'dashReportBar',1,	0,	62				

 UNION ALL 
SELECT	10122400	, 'Run Compliance Due Date Violation Report',	10122300	,	13000000	,	NULL	, 'RunComplianceDateVoilationReport',1,	0,	63				

 UNION ALL 
SELECT	10131099	, 'Deal Capture and Tagging',	13000000	,	13000000	,	NULL	, NULL,1,	1,	64				

 UNION ALL 
SELECT	10131000	, 'Maintain Transactions',	10131099	,	13000000	,	NULL	, 'windowMaintainDeals',1,	0,	65				

 UNION ALL 
SELECT	10234700	, 'Maintain Transactions Tagging',	10131099	,	13000000	,	NULL	, 'windowMaintainTransactionsTagging',1,	0,	66				

 UNION ALL 
SELECT	10236500	, 'Run Not Mapped Transaction Report',	10131099	,	13000000	,	NULL	, 'windowRunNotMappedDealReport',1,	0,	67				

 UNION ALL 
SELECT	10236000	, 'Run Tagging Report',	10131099	,	13000000	,	NULL	, 'windowTaggingExport',1,	0,	68				

 UNION ALL 
SELECT	10236600	, 'Run Tagging Audit Report',	10131099	,	13000000	,	NULL	, 'windowRunTaggingAuditReport',1,	0,	69				

 UNION ALL 
SELECT	10234800	, 'Bifurcation Of Embedded Derivatives',	10131099	,	13000000	,	NULL	, 'windowBifurcationEmbeddedDerivatives',1,	0,	70				

 UNION ALL 
SELECT	10131399	, 'ETRM Interfaces',	13000000	,	13000000	,	NULL	, NULL,1,	1,	71				

 UNION ALL 
SELECT	10131300	, 'Import Data',	10131399	,	13000000	,	NULL	, 'windowImportDataDeal',1,	0,	72				

 UNION ALL 
SELECT	10232800	, 'Run Import Audit Report',	10131399	,	13000000	,	NULL	, 'windowRunFilesImportAuditReport',1,	0,	73				

 UNION ALL 
SELECT	10232900	, 'Maintain Missing Static Data',	10131399	,	13000000	,	NULL	, 'windowMaintainMissingStaticData',1,	0,	74				

 UNION ALL 
SELECT	10233000	, 'Delete Voided Deal',	10131399	,	13000000	,	NULL	, 'windowVoidDealImports',1,	0,	75				

 UNION ALL 
SELECT	10231996	, 'Hedge Management',	13000000	,	13000000	,	NULL	, NULL,1,	1,	76				

 UNION ALL 
SELECT	10231997	, 'Hedging Strategies',	10231996	,	13000000	,	NULL	, NULL,1,	1,	77				

 UNION ALL 
SELECT	10231900	, 'Setup Hedging Relationship Types',	10231997	,	13000000	,	NULL	, 'windowSetupHedgingRelationshipsTypes',1,	0,	78				

 UNION ALL 
SELECT	10232000	, 'Run Hedging Relationship Types Report',	10231997	,	13000000	,	NULL	, 'windowRunSetupHedgingRelationshipsTypesReport',1,	0,	79				

 UNION ALL 
SELECT	10233797	, 'Hedge Designation',	10231996	,	13000000	,	NULL	, NULL,1,	1,	80				

 UNION ALL 
SELECT	10233700	, 'Designation of a Hedge',	10233797	,	13000000	,	NULL	, 'windowDesignationofaHedgeFromMenu',1,	0,	81				

 UNION ALL 
SELECT	10233800	, 'De-Designation of a Hedge by FIFO/LIFO',	10233797	,	13000000	,	NULL	, 'windowDedesignateFifolifo',1,	0,	82				

 UNION ALL 
SELECT	10234300	, 'Automation of Forecasted Transaction',	10233797	,	13000000	,	NULL	, 'windowAutomationofForecastedTransaction',1,	0,	83				

 UNION ALL 
SELECT	10234400	, 'Automate Matching of Hedges',	10233797	,	13000000	,	NULL	, 'windowAutomationMathingHedge',1,	0,	84				

 UNION ALL 
SELECT	10234500	, 'View Outstanding Automation Results',	10233797	,	13000000	,	NULL	, 'windowViewOutstandingAutomationResults',1,	0,	85				

 UNION ALL 
SELECT	10234200	, 'Life Cycle of Hedges',	10233797	,	13000000	,	NULL	, 'windowLifecyclesOfHedges',1,	0,	86				

 UNION ALL 
SELECT	10234100	, 'Amortize Deferred AOCI',	10233797	,	13000000	,	NULL	, 'windowAmortizeLockedAOCI',1,	0,	87				

 UNION ALL 
SELECT	10233897	, 'Hedge De-Designation',	10231996	,	13000000	,	NULL	, NULL,1,	1,	88				

 UNION ALL 
SELECT	10233800	, 'De-Designation of a Hedge by FIFO/LIFO',	10233897	,	13000000	,	NULL	, 'windowDedesignateFifolifo',1,	0,	89				

 UNION ALL 
SELECT	10230000	, 'Reclassify Hedge De-Designation',	10233897	,	13000000	,	NULL	, 'windowReclassifyDedesignationValues',1,	0,	90				

 UNION ALL 
SELECT	10233896	, 'Hedge Designation / De-Designation Based on Dynamic Limit',	10231996	,	13000000	,	NULL	, NULL,1,	1,	91				

 UNION ALL 
SELECT	10151099	, 'Hedge Effectiveness Testing',	13000000	,	13000000	,	NULL	, NULL,1,	1,	92				

 UNION ALL 
SELECT	10151000	, 'View Prices',	10151099	,	13000000	,	NULL	, 'windowViewPrices',1,	0,	93				

 UNION ALL 
SELECT	10232300	, 'Run Assessment',	10151099	,	13000000	,	NULL	, 'windowRunAssessment',1,	0,	94				

 UNION ALL 
SELECT	10232400	, 'View Assessment Results',	10151099	,	13000000	,	NULL	, 'windowViewAssessmentResults',1,	0,	95				

 UNION ALL 
SELECT	10237300	, 'View/Update Cum PNL Series',	10151099	,	13000000	,	NULL	, 'windowViewUpdateCumPNLSeries',1,	0,	96				

 UNION ALL 
SELECT	10232500	, 'Run Assessment Trend Graph',	10151099	,	13000000	,	NULL	, 'windowRunAssessmentTrendGraph',1,	0,	97				

 UNION ALL 
SELECT	10232600	, 'Run What-If Effectiveness Analysis',	10151099	,	13000000	,	NULL	, 'windowRunWhatIfEffectivenessAnalysis',1,	0,	98				

 UNION ALL 
SELECT	10233499	, 'Hedge Ineffectiveness Measurement',	13000000	,	13000000	,	NULL	, NULL,1,	0,	99				

 UNION ALL 
SELECT	10233400	, 'Run Measurement',	10233499	,	13000000	,	NULL	, 'windowRunMeasurement',1,	0,	100				

 UNION ALL 
SELECT	10181000	, 'Calc MTM',	10233499	,	13000000	,	NULL	, 'windowRunMtmCalc',1,	0,	101				

 UNION ALL 
SELECT	10181100	, 'Run MTM Report',	10233499	,	13000000	,	NULL	, 'windowMTMReport',1,	0,	102				

 UNION ALL 
SELECT	10233200	, 'Run What-If Measurement Analysis',	10233499	,	13000000	,	NULL	, 'windowRunwhatifmeasurementana',1,	0,	103				

 UNION ALL 
SELECT	10233300	, 'Run MTM Copy Prior MTM Value',	10233499	,	13000000	,	NULL	, 'windowPriorMTM',1,	0,	104				

 UNION ALL 
SELECT	10234610	, 'First Day Gain/Loss Treatment',	10233499	,	13000000	,	NULL	, 'windowFirstDayGainLossIU',1,	0,	105				

 UNION ALL 
SELECT	10233500	, 'Calc Embedded Derivative',	10233499	,	13000000	,	NULL	, 'windowCalcEmbedded',1,	0,	106				

 UNION ALL 
SELECT	13121295	, 'Reporting',	13000000	,	13000000	,	NULL	, NULL,1,	1,	107				

 UNION ALL 
SELECT	13121299	, 'Effectiveness Reporting',	13121295	,	13000000	,	NULL	, NULL,1,	1,	108				

 UNION ALL 
SELECT	13121200	, 'Run Hedge Ineffectiveness Report',	13121299	,	13000000	,	NULL	, 'windowRunHedgeIneffectivenessReport',1,	0,	109				

 UNION ALL 
SELECT	10234900	, 'Run Measurement Report',	13121299	,	13000000	,	NULL	, 'windowRunMeasurementReport',1,	0,	110				

 UNION ALL 
SELECT	10235000	, 'Run Measurement Trend Graph',	13121299	,	13000000	,	NULL	, 'windowRunMeasurementTrendGraph',1,	0,	111				

 UNION ALL 
SELECT	10235200	, 'Run AOCI Report',	13121299	,	13000000	,	NULL	, 'windowAOCIReport',1,	0,	112				

 UNION ALL 
SELECT	10235800	, 'Run Assessment Report',	13121299	,	13000000	,	NULL	, 'windowRunAssessmentReport',1,	0,	113				

 UNION ALL 
SELECT	10235300	, 'Run De-Designation Values Report',	13121299	,	13000000	,	NULL	, 'windowDedesignateReport',1,	0,	114				

 UNION ALL 
SELECT	13121298	, 'Position Reporting',	13121295	,	13000000	,	NULL	, NULL,1,	1,	115				

 UNION ALL 
SELECT	10235900	, 'Run Transaction Report',	13121298	,	13000000	,	NULL	, 'windowRunDealReport',1,	0,	116				

 UNION ALL 
SELECT	10141000	, 'Run Position Report',	13121298	,	13000000	,	NULL	, 'windowRunPositionReport',1,	0,	117				

 UNION ALL 
SELECT	10236400	, 'Run Available Hedge Capacity Exception Report',	13121298	,	13000000	,	NULL	, 'windowRunAvailableHedgeCapacityExceptionReport',1,	0,	118				

 UNION ALL 
SELECT	13121297	, 'Audit Reporting',	13121295	,	13000000	,	NULL	, NULL,1,	1,	119				

 UNION ALL 
SELECT	13121296	, 'Exception Reporting',	13121295	,	13000000	,	NULL	, NULL,1,	1,	120				

 UNION ALL 
SELECT	10236100	, 'Run Missing Assessment Values Report',	13121296	,	13000000	,	NULL	, 'windowRunMissingAssessmentValuesReport',1,	0,	121				

 UNION ALL 
SELECT	10236200	, 'Run Failed Assessment Values Report',	13121296	,	13000000	,	NULL	, 'windowRunFailAssessmentValuesReport',1,	0,	122				

 UNION ALL 
SELECT	10236300	, 'Run Unapproved Hedging Relationship Exception Report',	13121296	,	13000000	,	NULL	, 'windowRunUnapprovedHedgingRelationshipExceptionReport',1,	0,	123				

 UNION ALL 
SELECT	10201000	, 'Report Writer',	13121295	,	13000000	,	NULL	, 'windowreportwriter',1,	1,	124				

 UNION ALL 
SELECT	10235499	, 'Accounting',	13000000	,	13000000	,	NULL	, NULL,1,	1,	125				

 UNION ALL 
SELECT	10235400	, 'Run Journal Entry Report',	10235499	,	13000000	,	NULL	, 'windowRunJournalEntryReport',1,	0,	126				

 UNION ALL 
SELECT	10237000	, 'Maintain Manual Journal Entries',	10235499	,	13000000	,	NULL	, 'windowMaintainManualJournalEntries',1,	0,	127				

 UNION ALL 
SELECT	10235500	, 'Run Netted Journal Entry Report',	10235499	,	13000000	,	NULL	, 'windowRunNettedJournalEntryReport',1,	0,	128				

 UNION ALL 
SELECT	10241000	, 'Reconcile Cash Entries for Derivatives',	10235499	,	13000000	,	NULL	, 'windowReconcileCashEntriesDerivatives',1,	0,	129				

 UNION ALL 
SELECT	10233600	, 'Close Accounting Period',	10235499	,	13000000	,	NULL	, 'windowCloseMeasurement',1,	0,	130				

 UNION ALL 
SELECT	10235699	, 'Disclosures',	13000000	,	13000000	,	NULL	, NULL,1,	1,	131				

 UNION ALL 
SELECT	10235600	, 'Run Accounting Disclosure Report',	10235699	,	13000000	,	NULL	, 'windowRunDisclosureReport',1,	0,	132				

 UNION ALL 
SELECT	10235700	, 'Run Fair Value Disclosure Report',	10235699	,	13000000	,	NULL	, 'windowRunnetAssetsReport',1,	0,	133				

 UNION ALL 
SELECT	10235100	, 'Run Period Change Values Report',	10235699	,	13000000	,	NULL	, 'windowPeriodChangeValueReport',1,	0,	134				
																			


/**********************************Settlement Tracker Menus*********************************************************************/

 UNION ALL 
SELECT	15000000	, 'Settlement Tracker',	NULL	,	15000000	,	NULL	, 	NULL		,1,	1,	0				

 UNION ALL 
SELECT	10100000	, 'Setup',	15000000	,	15000000	,	NULL	, 	NULL		,1,	1,	1				

 UNION ALL 
SELECT	10101099	, 'Setup Static Data',	10100000	,	15000000	,	NULL	, 	NULL		,1,	1,	2				

 UNION ALL 
SELECT	10101000	, 'Maintain Static Data',	10101099	,	15000000	,	NULL	, 'windowMaintainStaticData',1,	0,	3				

 UNION ALL 
SELECT	10101100	, 'Maintain Definition',	10101099	,	15000000	,	NULL	, 'windowMaintainDefination',1,	0,	4				

 UNION ALL 
SELECT	10101200	, 'Setup Book Structure',	10101099	,	15000000	,	NULL	, 'windowSetupHedgingStrategies',1,	0,	5				

 UNION ALL 
SELECT	10102600	, 'Setup Price Curves',	10101099	,	15000000	,	NULL	, 'windowSetupPriceCurves',1,	0,	6				

 UNION ALL 
SELECT	10102500	, 'Setup Location',	10101099	,	15000000	,	NULL	, 'windowSetupLocation',1,	0,	7				

 UNION ALL 
SELECT	10102800	, 'Setup Profile',	10101099	,	15000000	,	NULL	, 'windowSetupProfile',1,	0,	8				

 UNION ALL 
SELECT	10101300	, 'Map GL Codes',	10100000	,	15000000	,	NULL	, 'windowMapGLCodes',1,	0,	9				

 UNION ALL 
SELECT	10101499	, 'Setup Deal Templates',	10100000	,	15000000	,	NULL	, NULL,1,	1,	10				

 UNION ALL 
SELECT	10101400	, 'Maintain Deal Template',	10101499	,	15000000	,	NULL	, 'windowMaintainDealTemplate',1,	0,	11				

 UNION ALL 
SELECT	10104200	, 'Maintain Field Template',	10101499	,	15000000	,	NULL	, 'windowSetupFieldTemplate',1,	0,	12				

 UNION ALL 
SELECT	10104100	, 'Maintain UDF Template',	10101499	,	15000000	,	NULL	, 'windowSetupUDFTemplate',1,	0,	13				

 UNION ALL 
SELECT	10103900	, 'Setup Deal Status and Confirmation Rule',	10101499	,	15000000	,	NULL	, 'windowSetupDealStatusConfirmationRule',1,	0,	14				

 UNION ALL 
SELECT	10103500	, 'Maintain Hedge Deferral Rules',	10101499	,	15000000	,	NULL	, 'windowSetupHedgingRelationshipsTypesWithReturn',1,	0,	15				

 UNION ALL 
SELECT	10101500	, 'Maintain Netting Asset/Liab Groups',	10100000	,	15000000	,	NULL	, 'windowMaintainNettingGroups',1,	0,	16				

 UNION ALL 
SELECT	10101600	, 'View Scheduled Job',	10100000	,	15000000	,	NULL	, 'windowSchedulejob',1,	0,	17				

 UNION ALL 
SELECT	10103000	, 'Define Meter IDs',	10100000	,	15000000	,	NULL	, 'windowDefineMeterID',1,	0,	18				

 UNION ALL 
SELECT	10103800	, 'Maintain Source Generator',	10100000	,	15000000	,	NULL	, 'windowMaintainSourceGenerator',1,	0,	19				

 UNION ALL 
SELECT	10103399	, 'Setup Contract Components ',	10100000	,	15000000	,	NULL	, NULL,1,	1,	20				

 UNION ALL 
SELECT	10103300	, 'Maintain Contract Components Gl Codes',	10103399	,	15000000	,	NULL	, 'windowDefineInvoiceGLCode',1,	0,	21				

 UNION ALL 
SELECT	10103400	, 'Setup Default GL Code for Contract Components',	10103399	,	15000000	,	NULL	, 'windowSetupDefaultGLCode',1,	0,	22				

 UNION ALL 
SELECT	10101900	, 'Setup Logical Trade Lock',	10100000	,	15000000	,	NULL	, 'windowSetupDealLock',1,	0,	23				

 UNION ALL 
SELECT	10102000	, 'Setup Tenor Bucket',	10100000	,	15000000	,	NULL	, 'windowSetupTenorBucketData',1,	0,	24				

 UNION ALL 
SELECT	10102900	, 'Manage Documents',	10100000	,	15000000	,	NULL	, 'windowManageDocumentsMain',1,	0,	25				

 UNION ALL 
SELECT	10102300	, 'Setup Emissions Source/Sink Type',	10100000	,	15000000	,	NULL	, 'windowSetupEMSStrategies',1,	0,	26				

 UNION ALL 
SELECT	10102200	, 'Setup As of Date',	10100000	,	15000000	,	NULL	, 'windowSetupAsOfDate',1,	0,	27				

 UNION ALL 
SELECT	10102400	, 'Formula Builder',	10100000	,	15000000	,	NULL	, 'windowFormulaBuilder',1,	0,	28				

 UNION ALL 
SELECT	13170000	, 'Mapping Setup',	10100000	,	15000000	,	NULL	, NULL,1,	1,	29				

 UNION ALL 
SELECT	10103100	, 'Term Mapping ',	13170000	,	15000000	,	NULL	, 'windowSetupTrayportTermMappingStaging',1,	0,	30				

 UNION ALL 
SELECT	10103200	, 'Pratos Mapping',	13170000	,	15000000	,	NULL	, 'windowPratosMapping',1,	0,	31				

 UNION ALL 
SELECT	13171000	, 'ST Forecast Mapping',	13170000	,	15000000	,	NULL	, 'windowSTForecastMapping',1,	0,	32				

 UNION ALL 
SELECT	10102799	, 'Manage Data',	10100000	,	15000000	,	NULL	, NULL,1,	1,	33				

 UNION ALL 
SELECT	10102700	, 'Archive Data',	10102799	,	15000000	,	NULL	, 'windowSetupArchiveData',1,	0,	34				

 UNION ALL 
SELECT	10103600	, 'Remove Data',	10102799	,	15000000	,	NULL	, 'windowRemoveData',1,	0,	35				

 UNION ALL 
SELECT	10104000	, 'Define Deal Status Privilege',	10100000	,	15000000	,	NULL	, 'windowDefineDealStatusPrivilege',1,	0,	36				

 UNION ALL 
SELECT	10104300	, 'Setup Contract Component Mapping',	10100000	,	15000000	,	NULL	, 'windowSetupContractComponentMapping',1,	0,	37				

 UNION ALL 
SELECT	10104400	, 'Setup Contract Price',	10100000	,	15000000	,	NULL	, 'windowSetupContractPrice',1,	0,	38				

 UNION ALL 
SELECT	10110000	, 'Users and Roles',	15000000	,	15000000	,	NULL	, NULL,1,	1,	39				

 UNION ALL 
SELECT	10111000	, 'Maintain Users',	10110000	,	15000000	,	NULL	, 'windowMaintainUsers',1,	0,	40				

 UNION ALL 
SELECT	10111100	, 'Maintain Roles',	10110000	,	15000000	,	NULL	, 'windowMaintainRoles',1,	0,	41				

 UNION ALL 
SELECT	10111200	, 'Maintain Workflow Menu',	10110000	,	15000000	,	NULL	, 'windowCustomizedMenu',1,	0,	42				

 UNION ALL 
SELECT	10111300	, 'Run Privilege Report',	10110000	,	15000000	,	NULL	, 'windowRunPrivilege',1,	0,	43				

 UNION ALL 
SELECT	10111400	, 'Run System Access Log Report',	10110000	,	15000000	,	NULL	, 'windowRunSystemAccessLog',1,	0,	44				

 UNION ALL 
SELECT	10120000	, 'Compliance Management',	15000000	,	15000000	,	NULL	, NULL,1,	1,	45				

 UNION ALL 
SELECT	10121300	, 'Maintain Compliance Standards',	10120000	,	15000000	,	NULL	, 'MaintainComplianceStandards',1,	0,	46				

 UNION ALL 
SELECT	10121000	, 'Maintain Compliance Groups',	10120000	,	15000000	,	NULL	, 'maintainComplianceProcess',1,	0,	47				

 UNION ALL 
SELECT	10121400	, 'Activity Process Map',	10120000	,	15000000	,	NULL	, 'windowActivityProcessMap',1,	0,	48				

 UNION ALL 
SELECT	10121500	, 'Change Owners',	10120000	,	15000000	,	NULL	, 'MaintainChangeOwners',1,	0,	49				

 UNION ALL 
SELECT	10121200	, 'Perform Compliance Activities',	10120000	,	15000000	,	NULL	, 'PerformComplianceActivities',1,	0,	50				

 UNION ALL 
SELECT	10121100	, 'Approve Compliance Activities',	10120000	,	15000000	,	NULL	, 'ApproveComplianceActivities',1,	0,	51				

 UNION ALL 
SELECT	10122300	, 'Reports',	10120000	,	15000000	,	NULL	, NULL,1,	1,	52				

 UNION ALL 
SELECT	10121600	, 'View Compliance Activities',	10122300	,	15000000	,	NULL	, 'ViewComplianceActivities',1,	0,	53				

 UNION ALL 
SELECT	10121700	, 'View Status On Compliance Activities',	10122300	,	15000000	,	NULL	, 'ReportComplianceActivities',1,	0,	54				

 UNION ALL 
SELECT	10122200	, 'View Compliance Calendar',	10122300	,	15000000	,	NULL	, 'windowComplianceCalendar',1,	0,	55				

 UNION ALL 
SELECT	10121800	, 'Run Compliance Activity Audit Report',	10122300	,	15000000	,	NULL	, 'RunComplianceAuditReport',1,	0,	56				

 UNION ALL 
SELECT	10121900	, 'Run Compliance Trend Report',	10122300	,	15000000	,	NULL	, 'RunComplianceTrendReport',1,	0,	57				

 UNION ALL 
SELECT	10122000	, 'Run Compliance Graph Report',	10122300	,	15000000	,	NULL	, 'dashReportPie',1,	0,	58				

 UNION ALL 
SELECT	10122100	, 'Run Compliance Status Graph Report',	10122300	,	15000000	,	NULL	, 'dashReportBar',1,	0,	59				

 UNION ALL 
SELECT	10122400	, 'Run Compliance Due Date Violation Report',	10122300	,	15000000	,	NULL	, 'RunComplianceDateVoilationReport',1,	0,	60				

 UNION ALL 
SELECT	15130199	, 'Define Billing Determinants',	15000000	,	15000000	,	NULL	, NULL,1,	1,	61				

 UNION ALL 
SELECT	15130100	, 'Setup Contract Component',	15130199	,	15000000	,	NULL	, 'windowMaintainStaticDataContractComponent',1,	0,	62				

 UNION ALL 
SELECT	10103800	, 'Setup Generators',	15130199	,	15000000	,	NULL	, 'windowMaintainSourceGenerator',1,	0,	63				

 UNION ALL 
SELECT	10103000	, 'Define Meter IDs',	15130199	,	15000000	,	NULL	, 'windowDefineMeterID',1,	0,	64				

 UNION ALL 
SELECT	10102600	, 'Setup Price Curves',	15130199	,	15000000	,	NULL	, 'windowSetupPriceCurves',1,	0,	65				

 UNION ALL 
SELECT	10211199	, 'Setup Contract Template',	15000000	,	15000000	,	NULL	, NULL,1,	1,	66				

 UNION ALL 
SELECT	10211100	, 'Maintain Contract Component Template',	10211199	,	15000000	,	NULL	, 'windowContractChargeType',1,	0,	67				

 UNION ALL 
SELECT	10191099	, 'Setup Contracts ',	15000000	,	15000000	,	NULL	, NULL,1,	1,	68				

 UNION ALL 
SELECT	10191000	, 'Setup Counterparty',	10191099	,	15000000	,	NULL	, 'windowMaintainDefinationArg',1,	0,	69				

 UNION ALL 
SELECT	10211000	, 'Maintain Contract',	10191099	,	15000000	,	NULL	, 'windowMaintainContractGroup',1,	0,	70				

 UNION ALL 
SELECT	10131000	, 'Maintain Deals',	10191099	,	15000000	,	NULL	, 'windowMaintainDeals',1,	0,	71				

 UNION ALL 
SELECT	10141399	, 'Manage Billing Determinants',	15000000	,	15000000	,	NULL	, NULL,1,	1,	72				

 UNION ALL 
SELECT	10141300	, 'View Position',	10141399	,	15000000	,	NULL	, 'windowRunHourlyProductionReport',1,	0,	73				

 UNION ALL 
SELECT	10131300	, 'Import Meter Data',	10141399	,	15000000	,	NULL	, 'windowImportDataDeal',1,	0,	74				

 UNION ALL 
SELECT	10222400	, 'Run Meter Data Report',	10141399	,	15000000	,	NULL	, 'windowMeterDataReport',1,	0,	75				

 UNION ALL 
SELECT	10131300	, 'Price Curves Import',	10141399	,	15000000	,	NULL	, 'windowImportDataDeal',1,	0,	76				

 UNION ALL 
SELECT	10151000	, 'View Prices',	10141399	,	15000000	,	NULL	, 'windowViewPrices',1,	0,	77				

 UNION ALL 
SELECT	10222399	, 'Run Settlement Process',	15000000	,	15000000	,	NULL	, NULL,1,	1,	78				

 UNION ALL 
SELECT	10222300	, 'Run Deal Settlement',	10222399	,	15000000	,	NULL	, 'windowRunSettlement',1,	0,	79				

 UNION ALL 
SELECT	10221000	, 'Run Contract Settlement',	10222399	,	15000000	,	NULL	, 'windowMaintainInvoice',1,	0,	80				

 UNION ALL 
SELECT	10221300	, 'Settlement Calculation History',	10222399	,	15000000	,	NULL	, 'windowMaintainInvoiceHistory',1,	0,	81				

 UNION ALL 
SELECT	10181000	, 'Run MTM Process',	10222399	,	15000000	,	NULL	, 'windowRunMtmCalc',1,	0,	82				

 UNION ALL 
SELECT	10221600	, 'Compare Prior Settlement for Adjustments',	10222399	,	15000000	,	NULL	, 'windowSettlementAdjustments',1,	0,	83				

 UNION ALL 
SELECT	10222000	, 'Export Settlement Data',	10222399	,	15000000	,	NULL	, 'windowSAPSettlementExport',1,	0,	84				

 UNION ALL 
SELECT	10221999	, 'Settlement Reporting',	15000000	,	15000000	,	NULL	, NULL,1,	1,	85				

 UNION ALL 
SELECT	10221900	, 'Run Settlement Report',	10221999	,	15000000	,	NULL	, 'windowSettlementReport',1,	0,	86				

 UNION ALL 
SELECT	10221200	, 'Run Contract Settlement Report',	10221999	,	15000000	,	NULL	, 'windowBrokerFeeReport',1,	0,	87				

 UNION ALL 
SELECT	10181100	, 'Run Forward Report',	10221999	,	15000000	,	NULL	, 'windowMTMReport',1,	0,	88				

 UNION ALL 
SELECT	10221800	, 'Run Settlement Production Report',	10221999	,	15000000	,	NULL	, 'windowSettlementProductionReport',1,	0,	89				

 UNION ALL 
SELECT	10221700	, 'Market Variance Report',	10221999	,	15000000	,	NULL	, 'windowMarketVarienceReport',1,	0,	90				

 UNION ALL 
SELECT	10201000	, 'Report Writer',	10221999	,	15000000	,	NULL	, 'windowreportwriter',1,	0,	91				

 UNION ALL 
SELECT	10201100	, 'Run Dashboard Report',	10221999	,	15000000	,	NULL	, 'WindowRunDashReport',1,	0,	92				

 UNION ALL 
SELECT	10201200	, 'Dashboard Report Template',	10221999	,	15000000	,	NULL	, 'WindowDashReportTemplate',1,	0,	93				

 UNION ALL 
SELECT	10201300	, 'Maintain EoD Log Status',	10221999	,	15000000	,	NULL	, 'windowMaintainEoDLogStatus',1,	0,	94				

 UNION ALL 
SELECT	10201400	, 'Run Import Audit Report',	10221999	,	15000000	,	NULL	, 'windowRunFilesImportAuditReportPrice',1,	0,	95				

 UNION ALL 
SELECT	10101399	, 'Setup Accounts',	15000000	,	15000000	,	NULL	, NULL,1,	1,	96				

 UNION ALL 
SELECT	10101300	, 'Map GL Codes',	10101399	,	15000000	,	NULL	, 'windowMapGLCodes',1,	0,	97				

 UNION ALL 
SELECT	15190100	, 'Maintain Contract Components GL Codes Def',	10101399	,	15000000	,	NULL	, 'windowMaintainStaticDataContractComponentGLCode',1,	0,	98				

 UNION ALL 
SELECT	10103300	, 'Maintain Contract Components GL Codes',	10101399	,	15000000	,	NULL	, 'windowDefineInvoiceGLCode',1,	0,	99				

 UNION ALL 
SELECT	10103400	, 'Setup Default GL Code for Contract Components',	10101399	,	15000000	,	NULL	, 'windowSetupDefaultGLCode',1,	0,	100				

 UNION ALL 
SELECT	10231099	, 'Prepare and Submit GL Entries',	15000000	,	15000000	,	NULL	, NULL,1,	1,	101				

 UNION ALL 
SELECT	10231000	, 'Add Manual Entries',	10231099	,	15000000	,	NULL	, 'windowMaintainManualJournalEntries',1,	0,	102				

 UNION ALL 
SELECT	10231700	, 'Run Accrual Journal Entry Report',	10231099	,	15000000	,	NULL	, 'windowRunInventoryJournalEntryReport',1,	0,	103				

 UNION ALL 
SELECT	10221400	, 'Post JE Report',	10231099	,	15000000	,	NULL	, 'windowPostJEReport',1,	0,	104				

 UNION ALL 
SELECT	10233600	, 'Close Month End',	10231099	,	15000000	,	NULL	, 'windowCloseMeasurement',1,	0,	105				

 UNION ALL 
SELECT	10240000	, 'Treasury',	15000000	,	15000000	,	NULL	, NULL,1,	1,	106				

 UNION ALL 
SELECT	10241000	, 'Reconcile Cash Entries for Derivatives',	10240000	,	15000000	,	NULL	, 'windowReconcileCashEntriesDerivatives',1,	0,	107				

 UNION ALL 
SELECT	10241100	, 'Apply Cash',	10240000	,	15000000	,	NULL	, 'windowApplyCash',1,	0,	108				
		
		
/**********************************Emission Tracker Menus*********************************************************************/
		
 UNION ALL 
SELECT	12000000	,'Emission Tracker',	NULL	,	12000000	,	NULL	, 	NULL		,1,	1,	0

 UNION ALL 
SELECT	10100000, 'Setup',	12000000,	12000000,	NULL, 	NULL	,1,	1,	1

 UNION ALL 
SELECT	10101099, 'Setup Static Data',	10100000,	12000000,	NULL, 	NULL	,1,	1,	2

 UNION ALL 
SELECT	10101000, 'Maintain Static Data',	10101099,	12000000,	NULL, 'windowMaintainStaticData',1,	0,	3

 UNION ALL 
SELECT	10101100, 'Maintain Definition',	10101099,	12000000,	NULL, 'windowMaintainDefination',1,	0,	4

 UNION ALL 
SELECT	10101200, 'Setup Book Structure',	10101099,	12000000,	NULL, 'windowSetupHedgingStrategies',1,	0,	5

 UNION ALL 
SELECT	10102600, 'Setup Price Curves',	10101099,	12000000,	NULL, 'windowSetupPriceCurves',1,	0,	6

 UNION ALL 
SELECT	10102500, 'Setup Location',	10101099,	12000000,	NULL, 'windowSetupLocation',1,	0,	7

 UNION ALL 
SELECT	10102800, 'Setup Profile',	10101099,	12000000,	NULL, 'windowSetupProfile',1,	0,	8

 UNION ALL 
SELECT	10101300, 'Map GL Codes',	10100000,	12000000,	NULL, 'windowMapGLCodes',1,	0,	9

 UNION ALL 
SELECT	10101499, 'Setup Deal Templates',	10100000,	12000000,	NULL, NULL,1,	1,	10

 UNION ALL 
SELECT	10101400, 'Maintain Deal Template',	10101499,	12000000,	NULL, 'windowMaintainDealTemplate',1,	0,	11

 UNION ALL 
SELECT	10104200, 'Maintain Field Template',	10101499,	12000000,	NULL, 'windowSetupFieldTemplate',1,	0,	12

 UNION ALL 
SELECT	10104100, 'Maintain UDF Template',	10101499,	12000000,	NULL, 'windowSetupUDFTemplate',1,	0,	13

 UNION ALL 
SELECT	10103900, 'Setup Deal Status and Confirmation Rule',	10101499,	12000000,	NULL, 'windowSetupDealStatusConfirmationRule',1,	0,	14

 UNION ALL 
SELECT	10103500, 'Maintain Hedge Deferral Rules',	10101499,	12000000,	NULL, 'windowSetupHedgingRelationshipsTypesWithReturn',1,	0,	15

 UNION ALL 
SELECT	10101500, 'Maintain Netting Asset/Liab Groups',	10100000,	12000000,	NULL, 'windowMaintainNettingGroups',1,	0,	16

 UNION ALL 
SELECT	10101600, 'View Scheduled Job',	10100000,	12000000,	NULL, 'windowSchedulejob',1,	0,	17

 UNION ALL 
SELECT	10103000, 'Define Meter IDs',	10100000,	12000000,	NULL, 'windowDefineMeterID',1,	0,	18

 UNION ALL 
SELECT	10103700, 'Location Price Index',	10100000,	12000000,	NULL, 'windowLocationPriceIndex',1,	0,	19

 UNION ALL 
SELECT	10103800, 'Maintain Source Generator',	10100000,	12000000,	NULL, 'windowMaintainSourceGenerator',1,	0,	20

 UNION ALL 
SELECT	10103399, 'Setup Contract Components',	10100000,	12000000,	NULL, NULL,1,	1,	21

 UNION ALL 
SELECT	10103300, 'Maintain Contract Components Gl Codes',	10103399,	12000000,	NULL, 'windowDefineInvoiceGLCode',1,	0,	22

 UNION ALL 
SELECT	10103400, 'Setup Default GL Code for Contract Components',	10103399,	12000000,	NULL, 'windowSetupDefaultGLCode',1,	0,	23

 UNION ALL 
SELECT	10101900, 'Setup Logical Trade Lock',	10100000,	12000000,	NULL, 'windowSetupDealLock',1,	0,	24

 UNION ALL 
SELECT	10102000, 'Setup Tenor Bucket',	10100000,	12000000,	NULL, 'windowSetupTenorBucketData',1,	0,	25

 UNION ALL 
SELECT	10102900, 'Manage Documents',	10100000,	12000000,	NULL, 'windowManageDocumentsMain',1,	0,	26

 UNION ALL 
SELECT	10102300, 'Setup Emissions Source/Sink Type',	10100000,	12000000,	NULL, 'windowSetupEMSStrategies',1,	0,	27

 UNION ALL 
SELECT	10102100, 'Maintain Wellhead',	10100000,	12000000,	NULL, 'windowMaintainWellhead',1,	0,	28

 UNION ALL 
SELECT	10102200, 'Setup As of Date',	10100000,	12000000,	NULL, 'windowSetupAsOfDate',1,	0,	29

 UNION ALL 
SELECT	10102400, 'Formula Builder',	10100000,	12000000,	NULL, 'windowFormulaBuilder',1,	0,	30

 UNION ALL 
SELECT	13170000, 'Mapping Setup',	10100000,	12000000,	NULL, NULL,1,	1,	31

 UNION ALL 
SELECT	10103100, 'Term Mapping',	13170000,	12000000,	NULL, 'windowSetupTrayportTermMappingStaging',1,	0,	32

 UNION ALL 
SELECT	10103200, 'Pratos Mapping',	13170000,	12000000,	NULL, 'windowPratosMapping',1,	0,	33

 UNION ALL 
SELECT	13171000, 'ST Forecast Mapping',	13170000,	12000000,	NULL, 'windowSTForecastMapping',1,	0,	34

 UNION ALL 
SELECT 10102799, 'Manage Data', 10100000, 12000000, NULL, NULL, 1, 1, 35

 UNION ALL 
SELECT 10102700, 'Archive Data', 10102799, 12000000, NULL, 'windowSetupArchiveData', 1, 0, 36

 UNION ALL 
SELECT 10103600, 'Remove Data',10102799, 12000000, NULL, 'windowRemoveData', 1, 0, 37

 UNION ALL 
SELECT	10110000, 'Users and Roles',	12000000,	12000000,	NULL, NULL,1,	1,	37

 UNION ALL 
SELECT	10111000, 'Maintain Users',	10110000,	12000000,	NULL, 'windowMaintainUsers',1,	0,	38

 UNION ALL 
SELECT	10111100, 'Maintain Roles',	10110000,	12000000,	NULL, 'windowMaintainRoles',1,	0,	39

 UNION ALL 
SELECT	10111200, 'Maintain Work Flow Menu',	10110000,	12000000,	NULL, 'windowCustomizedMenu',1,	0,	40

 UNION ALL 
SELECT	10111300, 'Run Privilege Report',	10110000,	12000000,	NULL, 'windowRunPrivilege',1,	0,	41

 UNION ALL 
SELECT	10111400, 'Run System Access Log Report',	10110000,	12000000,	NULL, 'windowRunSystemAccessLog',1,	0,	42

 UNION ALL 
SELECT	10111500, 'Maintain Report',	10110000,	12000000,	NULL, 'windowMaintainReport',1,	0,	43

 UNION ALL 
SELECT	10120000, 'Compliance Management',	12000000,	12000000,	NULL, NULL, 1,	1,	44

 UNION ALL 
SELECT	10121300, 'Maintain Compliance Standards',	10120000,	12000000,	NULL, 'MaintainComplianceStandards',1,	0,	45

 UNION ALL 
SELECT	10121000, 'Maintain Compliance Groups',	10120000,	12000000,	NULL, 'maintainComplianceProcess',1,	0,	46

 UNION ALL 
SELECT	10121400, 'Activity Process Map',	10120000,	12000000,	NULL, 'windowActivityProcessMap',1,	0,	47

 UNION ALL 
SELECT	10121500, 'Change Owners',	10120000,	12000000,	NULL, 'MaintainChangeOwners',1,	0,	48

 UNION ALL 
SELECT	10121200, 'Perform Compliance Activities',	10120000,	12000000,	NULL, 'PerformComplianceActivities',1,	0,	49

 UNION ALL 
SELECT	10121100, 'Approve Compliance Activities',	10120000,	12000000,	NULL, 'ApproveComplianceActivities',1,	0,	50

 UNION ALL 
SELECT	10122300, 'Reports',	10120000,	12000000,	NULL, NULL,1,	1,	51

 UNION ALL 
SELECT	10121600, 'View Compliance Activities',	10122300,	12000000,	NULL, 'ViewComplianceActivities',1,	0,	52

 UNION ALL 
SELECT	10121700, 'View Status On Compliance Activities',	10122300,	12000000,	NULL, 'ReportComplianceActivities',1,	0,	53

 UNION ALL 
SELECT	10122200, 'View Compliance Calendar',	10122300,	12000000,	NULL, 'windowComplianceCalendar',1,	0,	54

 UNION ALL 
SELECT	10121800, 'Run Compliance Activity Audit Report',	10122300,	12000000,	NULL, 'RunComplianceAuditReport',1,	0,	55

 UNION ALL 
SELECT	10121900, 'Run Compliance Trend Report',	10122300,	12000000,	NULL, 'RunComplianceTrendReport',1,	0,	56

 UNION ALL 
SELECT	10122000, 'Run Compliance Graph Report',	10122300,	12000000,	NULL, 'dashReportPie',1,	0,	57

 UNION ALL 
SELECT	10122100, 'Run Compliance Status Graph Report',	10122300,	12000000,	NULL, 'dashReportBar',1,	0,	58

 UNION ALL 
SELECT	10122400, 'Run Compliance Due Date Violation Report',	10122300,	12000000,	NULL, 'RunComplianceDateVoilationReport',1,	0,	59

 UNION ALL 
SELECT	12100000, 'Models and Activity',	12000000,	12000000,	NULL, NULL,1,	1,	60

 UNION ALL 
SELECT	12101100, 'Maintain Input Characteristics',	12100000,	12000000,	NULL, 'windowEMSMaintainCharater',1,	0,	61

 UNION ALL 
SELECT	12101200, 'Maintain Multiple Source/Sink Unit Map',	12100000,	12000000,	NULL, 'windowMultipleSourceUnitMap',1,	0,	62

 UNION ALL 
SELECT	12101300, 'Maintain Input/Output',	12100000,	12000000,	NULL, 'windowDefineEmissionInputOutput',1,	0,	63

 UNION ALL 
SELECT	12101140, 'Define Emissions Source Model',	12100000,	12000000,	NULL, 'windowDefineEmissionSourceModel',1,	0,	64

 UNION ALL 
SELECT	12101150, 'Maintain Emissions Source/Sinks',	12100000,	12000000,	NULL, 'windowMaintainEmsGenerators',1,	0,	65

 UNION ALL 
SELECT	12101160, 'Maintain Emissions Source/Sinks Detail',	12100000,	12000000,	NULL, 'windowMaintainEmsGeneratorsDetail',1,	0,	66

 UNION ALL 
SELECT	12101170, 'Maintain Renewable Sources',	12100000,	12000000,	NULL, 'windowMaintainRenewableGenerators',1,	0,	67

 UNION ALL 
SELECT	12101180, 'Setup User Defined Source/Sink Group',	12100000,	12000000,	NULL, 'windowSetupSourceSinkGroup',1,	0,	68

 UNION ALL 
SELECT	12101190, 'Maintain Decaying Factor',	12100000,	12000000,	NULL, 'windowMaintainDecaying',1,	0,	69

 UNION ALL 
SELECT	12102000, 'Maintain Emission Input/Output Data',	12100000,	12000000,	NULL, 'windowMaintainEmsInput',1,	0,	70

 UNION ALL 
SELECT	12102100, 'Input Activity Data',	12100000,	12000000,	NULL, 'windowInputActivityData',1,	0,	71

 UNION ALL 
SELECT	12102200, 'Setup Wizard',	12100000,	12000000,	NULL, 'windowWizardWelcomeScreen',1,	0,	72

 UNION ALL 
SELECT	12102399, 'Reports',	12100000,	12000000,	NULL, NULL,1,	1,	73

 UNION ALL 
SELECT	12102300, 'Run Source/Sink Info Report',	12102399,	12000000,	NULL, 'windowSourceSinkInfoReport',1,	0,	74

 UNION ALL 
SELECT	12102400, 'Run Exceptions Report',	12102399,	12000000,	NULL, 'windowRunExceptionsReport',1,	0,	75

 UNION ALL 
SELECT	12102500, 'Emissions Source Model Report',	12102399,	12000000,	NULL, 'windowEmissionsSourceModelReport',1,	0,	76

 UNION ALL 
SELECT	12102699, 'Emissions Vendor Setup Wizard',	12100000,	12000000,	NULL, NULL,1,	1,	77

 UNION ALL 
SELECT	12102600, 'Maintain Company Type',	12102699,	12000000,	NULL, 'windowDefineMainCompType',1,	0,	78

 UNION ALL 
SELECT	12102700, 'Maintain Source/Sink category',	12102699,	12000000,	NULL, 'windowMaintainSourceSinkCatFrame',1,	0,	79

 UNION ALL 
SELECT	12103000, 'Maintain Company Type Template',	12102699,	12000000,	NULL, 'windowDefineMainCompTypeTemp',1,	0,	80

 UNION ALL 
SELECT	12102800, 'Company Type Source Model',	12102699,	12000000,	NULL, 'windowCompanyTypeSourceModel1',1,	0,	81

 UNION ALL 
SELECT	12102900, 'Company Source Sink Template',	12102699,	12000000,	NULL, 'windowCompanySourceSinkTemplate',1,	0,	82

 UNION ALL 
SELECT	12103100, 'Maintain Limits',	12100000,	12000000,	NULL, 'windowMaintainLimits',1,	0,	83

 UNION ALL 
SELECT	12110000, 'Inventory and Reductions',	12000000,	12000000,	NULL, NULL,1,	1,	84

 UNION ALL 
SELECT	12111000, 'Run Emissions Inventory Calc',	12110000,	12000000,	NULL, 'windowRunEmissionInventory',1,	0,	85

 UNION ALL 
SELECT	12111100, 'Run What-if Emissions Inventory Calc',	12110000,	12000000,	NULL, 'windowRunWhatifEmissionInventory',1,	0,	86

 UNION ALL 
SELECT	12111200, 'Export Emissions Inventory/Reductions Data',	12110000,	12000000,	NULL, 'windowMaintainEmsInvReport',1,	0,	87

 UNION ALL 
SELECT	12112200, 'Run Emissions Limit Report',	12110000,	12000000,	NULL, 'windowMaintainEmsInputReport',1,	0,	88

 UNION ALL 
SELECT	12111300, 'Run Emissions Inventory Report',	12110000,	12000000,	NULL, 'windowRunEmissionsInventoryReport',1,	0,	89

 UNION ALL 
SELECT	12111400, 'Run Emissions Tracking Report',	12110000,	12000000,	NULL, 'windowRunGHGTrackingReport',1,	0,	90

 UNION ALL 
SELECT	12111500, 'Benchmark Emissions Input & Output Data',	12110000,	12000000,	NULL, 'windowRunEMSAnalyticalReport',1,	0,	91

 UNION ALL 
SELECT	12111600, 'Control Chart',	12110000,	12000000,	NULL, 'windowControlChart',1,	0,	92

 UNION ALL 
SELECT	12111700, 'Run Emissions What-If Report',	12110000,	12000000,	NULL, 'windowRunEmissionsWhatIfReport',1,	0,	93

 UNION ALL 
SELECT	12112000, 'Publish Report',	12110000,	12000000,	NULL, 'windowPublishReport',1,	0,	94

 UNION ALL 
SELECT	12112100, 'Archive Data',	12110000,	12000000,	NULL, 'windowArchieveData',1,	0,	95

 UNION ALL 
SELECT	12120000, 'Allowance/Credit Assignment',	12000000,	12000000,	NULL, NULL,1,	1,	96

 UNION ALL 
SELECT	12121000, 'Maintain Emissions Profile/Credit requirements',	12120000,	12000000,	NULL, 'windowMaintainEmission',1,	0,	97

 UNION ALL 
SELECT	12121100, 'Maintain Target Emissions',	12120000,	12000000,	NULL, 'windowMaintainTargetEmission',1,	0,	98

 UNION ALL 
SELECT	12121200, 'Reconcile Certificates',	12120000,	12000000,	NULL, 'windowRecGis',1,	0,	99

 UNION ALL 
SELECT	12121300, 'Assign Transactions',	12120000,	12000000,	NULL, 'windowAssignRecDeals',1,	0,	100

 UNION ALL 
SELECT	12121400, 'Unassign Transactions',	12120000,	12000000,	NULL, 'windowUnAssignRecDeals',1,	0,	101

 UNION ALL 
SELECT	12121500, 'Lifecycle of Transactions',	12120000,	12000000,	NULL, 'windowLifecyclesOfRec',1,	0,	102

 UNION ALL 
SELECT	12130000, 'Inventory and Compliance Reporting',	12000000,	12000000,	NULL, NULL,1,	1,	103

 UNION ALL 
SELECT	12131000, 'Run Target Report',	12130000,	12000000,	NULL, 'windowRunTargetReport',1,	0,	104

 UNION ALL 
SELECT	12131100, 'Run Inventory Position Report',	12130000,	12000000,	NULL, 'windowRunRecActivity',1,	0,	105

 UNION ALL 
SELECT	12131200, 'Run Transactions Report',	12130000,	12000000,	NULL, 'windowRunTransactionsReport',1,	0,	106

 UNION ALL 
SELECT	12131300, 'Run Compliance Report',	12130000,	12000000,	NULL, 'windowRecComplianceReport',1,	0,	107

 UNION ALL 
SELECT	12131400, 'Run Exposure Report',	12130000,	12000000,	NULL, 'windowRecExposureReport',1,	0,	108

 UNION ALL 
SELECT	12131500, 'Run Market Value Report',	12130000,	12000000,	NULL, 'windowRunMarketValueReport',1,	0,	109

 UNION ALL 
SELECT	12131600, 'Allowance Transfer Form',	12130000,	12000000,	NULL, 'windowAllowanceTransfer',1,	0,	110

 UNION ALL 
SELECT	12131700, 'Run Allowance Reconciliation Report',	12130000,	12000000,	NULL, 'windowRunAllowanceReconciliationReport',1,	0,	111

 UNION ALL 
SELECT	12131800, 'Run REC Production Report',	12130000,	12000000,	NULL, 'windowRecProductionReport',1,	0,	112

 UNION ALL 
SELECT	12131900, 'Run Generator Report',	12130000,	12000000,	NULL, 'windowRecGeneratorReport',1,	0,	113

 UNION ALL 
SELECT	12132000, 'Run Generator Info Report',	12130000,	12000000,	NULL, 'windowGeneratorInfoReport',1,	0,	114

 UNION ALL 
SELECT	12132100, 'Run Gen/Credit Source Allocation Report',	12130000,	12000000,	NULL, 'windowRecGenAllocateReport',1,	0,	115

 UNION ALL 
SELECT	12132200, 'Purchase Power Renewable Report',	12130000,	12000000,	NULL, 'windowWindPurPowerReport',1,	0,	116

 UNION ALL 
SELECT	10130000, 'Deal Capture',	12000000,	12000000,	NULL, NULL,1,	1,	117

 UNION ALL 
SELECT	10131000, 'Maintain Transactions',	10130000,	12000000,	NULL, 'windowMaintainDeals',1,	0,	118

 UNION ALL 
SELECT	10131200, 'Maintain Environmental Transactions',	10130000,	12000000,	NULL, 'windowMaintainRecDeals',1,	0,	119

 UNION ALL 
SELECT	10131300, 'Import Data',	10130000,	12000000,	NULL, 'windowImportDataDeal',1,	0,	120

 UNION ALL 
SELECT	10131400, 'Rollover From Forward To Spot',	10130000,	12000000,	NULL, 'windowRolloverForwardSpot',1,	0,	121

 UNION ALL 
SELECT	10161700, 'Bid Offer Formulator',	10130000,	12000000,	NULL, 'windowBidOfferFormulator',1,	0,	122

 UNION ALL 
SELECT	10161000, 'Bid Offer Submission',	10130000,	12000000,	NULL, 'windowBidOfferReport',1,	0,	123

 UNION ALL 
SELECT	10131500, 'Import EPA Allowance Data',	10130000,	12000000,	NULL, 'windowEPAAllowanceData',1,	0,	124

 UNION ALL 
SELECT	10131600, 'Transfer Book Position',	10130000,	12000000,	NULL, 'windowTransferBookPosition',1,	0,	125

 UNION ALL 
SELECT	10140000, 'Position Reporting',	12000000,	12000000,	NULL, NULL,1,	1,	126

 UNION ALL 
SELECT	10141000, 'Run Index Position Report',	10140000,	12000000,	NULL, 'windowRunPositionReport',1,	0,	127

 UNION ALL 
SELECT	10141700, 'Run Trader Position Report',	10141000,	12000000,	NULL, 'windowRunTraderPositionReport',1,	0,	128

 UNION ALL 
SELECT	10141100, 'Run Options Report',	10140000,	12000000,	NULL, 'windowRunOptionsReport',1,	0,	129

 UNION ALL 
SELECT	10141200, 'Run Options Greeks Report',	10140000,	12000000,	NULL, 'windowRunOptionsGreeksReport',1,	0,	130

 UNION ALL 
SELECT	10141300, 'Run Hourly Position Report',	10140000,	12000000,	NULL, 'windowRunHourlyProductionReport',1,	0,	131

 UNION ALL 
SELECT	10141500, 'Run Units Availability Report',	10140000,	12000000,	NULL, 'windowRunUnitsAvailabilityReport',1,	0,	132

 UNION ALL 
SELECT	10142000, 'Run Power Position Report',	10140000,	12000000,	NULL, 'windowRunPowerPositionReport',1,	0,	133

 UNION ALL 
SELECT	10141900, 'Run Load Forecast Report',	10140000,	12000000,	NULL, 'windowRunLoadForecastReport',1,	0,	134

 UNION ALL 
SELECT	10142100, 'Run FX Exposure Report',	10140000,	12000000,	NULL, 'windowRunFXExposureReport',1,	0,	135

 UNION ALL 
SELECT	10142200, 'Run Explain Report',	10140000,	12000000,	NULL, 'windowRunPositionExplainReport',1,	0,	136

 UNION ALL 
SELECT	10150000, 'Price Curve Management',	12000000,	12000000,	NULL, NULL,1,	1,	137

 UNION ALL 
SELECT	10151000, 'View Prices',	10150000,	12000000,	NULL, 'windowViewPrices',1,	0,	138

 UNION ALL 
SELECT	10151100, 'Import Price',	10150000,	12000000,	NULL, 'windowImportDataPrice',1,	0,	139

 UNION ALL 
SELECT	10170000, 'Deal Verification And Confirmation',	12000000,	12000000,	NULL, NULL,1,	1,	140

 UNION ALL 
SELECT	10171000, 'Confirm Transactions',	10170000,	12000000,	NULL, 'windowConfirmModule',1,	0,	141

 UNION ALL 
SELECT	10171400, 'Update Deal Status and Confirmation',	10170000,	12000000,	NULL, 'windowUpdateConfirmModule',1,	0,	142

 UNION ALL 
SELECT	10171500, 'Update Deal Status',	10170000,	12000000,	NULL, 'windowUpdateModule',1,	0,	143

 UNION ALL 
SELECT	10171100, 'Transaction Audit Log Report',	10170000,	12000000,	NULL, 'windowTransactionAuditLog',1,	0,	144

 UNION ALL 
SELECT	10171200, 'Lock/Unlock Deal',	10170000,	12000000,	NULL, 'windowLockUnlockDeal',1,	0,	145

 UNION ALL 
SELECT	10171300, 'Run Unconfirmed Exception Report',	10170000,	12000000,	NULL, 'windowUnconfirmedExeptionReport',1,	0,	146

 UNION ALL 
SELECT	10180000, 'Valuation And Risk Analysis',	12000000,	12000000,	NULL, NULL,1,	1,	147

 UNION ALL 
SELECT	10181099, 'Run MTM',	10180000,	12000000,	NULL, NULL,1,	1,	148

 UNION ALL 
SELECT	10181000, 'Run MTM Process',	10181099,	12000000,	NULL, 'windowRunMtmCalc',1,	0,	149

 UNION ALL 
SELECT	10181100, 'Run MTM Report',	10181099,	12000000,	NULL, 'windowMTMReport',1,	0,	150

 UNION ALL 
SELECT	10182200, 'Run Counterparty MTM report',	10181099,	12000000,	NULL, 'windowCounterpartyMTMReport',1,	0,	151

 UNION ALL 
SELECT	10183000, 'Maintain Monte Carlo Models',	10180000,	12000000,	NULL, 'windowMaintainMonteCarloModels',1,	0,	152

 UNION ALL 
SELECT	10183100, 'Run Monte Carlo Simulation',	10180000,	12000000,	NULL, 'windowRunMonteCarloSimulation',1,	0,	153

 UNION ALL 
SELECT	10181299, 'Run At Risk',	10180000,	12000000,	NULL, NULL,1,	1,	154

 UNION ALL 
SELECT	10181200, 'Maintain At Risk Measurement Criteria',	10181299,	12000000,	NULL, 'VaRMeasurementCriteriaDetail',1,	0,	155

 UNION ALL 
SELECT	10181500, 'Run At Risk calculation',	10181299,	12000000,	NULL, 'VaRMeasurementCriteriaDetailReport',1,	0,	156

 UNION ALL 
SELECT	10181600, 'Run At Risk Report',	10181299,	12000000,	NULL, 'windowVaRreport',1,	0,	157

 UNION ALL 
SELECT	10181399, 'Run Limits',	10180000,	12000000,	NULL, NULL,1,	1,	158

 UNION ALL 
SELECT	10181300, 'Maintain Limits',	10181399,	12000000,	NULL, 'LimitTrackingScreen',1,	0,	159

 UNION ALL 
SELECT	10181700, 'Run Limits Report',	10181399,	12000000,	NULL, 'windowLimitsReport',1,	0,	160

 UNION ALL 
SELECT	10181499, 'Run Volatility Calculations',	10180000,	12000000,	NULL, NULL,1,	1,	161

 UNION ALL 
SELECT	10181400, 'Calculate Volatility, Correlation and Expected Return',	10181499,	12000000,	NULL, 'CalculateVolatilityCorrelation',1,	0,	162

 UNION ALL 
SELECT	10182000, 'View Volatility, Correlation and Expected Return',	10181499,	12000000,	NULL, 'windowViewVolCorReport',1,	0,	163

 UNION ALL 
SELECT	10181800, 'Run Implied Volatility Calculation',	10181499,	12000000,	NULL, 'windowCalImpVolatility',1,	0,	164

 UNION ALL 
SELECT	10181900, 'Run Implied Volatility Report',	10181499,	12000000,	NULL, 'windowReportImpVol',1,	0,	165

 UNION ALL 
SELECT	10182300, 'Financial Forecast Model',	10180000,	12000000,	NULL, 'windowCashflowEarningsModel',1,	0,	166

 UNION ALL 
SELECT	10182600, 'Calculate Financial Forecast',	10180000,	12000000,	NULL, 'windowCalculateFinancialForecast',1,	0,	167

 UNION ALL 
SELECT	10182400, 'Financial Forecast Report',	10180000,	12000000,	NULL, 'windowRunCashflowEarningsReport',1,	0,	168

 UNION ALL 
SELECT	10182500, 'Maintain What-If Scenario',	10180000,	12000000,	NULL, 'windowWhatIfScenario',1,	0,	169

 UNION ALL 
SELECT	10182700, 'Run What-If Scenario Report',	10180000,	12000000,	NULL, 'windowWhatIfScenarioReport',1,	0,	170

 UNION ALL 
SELECT	10182900, 'Run Hedge Cashflow Deferral Report',	10180000,	12000000,	NULL, 'windowRunHedgeCashflowDeferral',1,	0,	171

 UNION ALL 
SELECT	10183499, 'Run What-If',	10180000,	12000000,	NULL, NULL,1,	1,	172

 UNION ALL 
SELECT	10183200, 'Maintain Portfolio Group',	10183499,	12000000,	NULL, 'windowMaintainPortfolioGroup',1,	0,	173

 UNION ALL 
SELECT	10183300, 'Maintain What-If Scenario',	10183499,	12000000,	NULL, 'windowMaintainWhatIfScenario',1,	0,	174

 UNION ALL 
SELECT	10183400, 'Maintain What-If Criteria',	10183499,	12000000,	NULL, 'windowMaintainWhatIfCriteria',1,	0,	175

 UNION ALL 
SELECT	10183500, 'Run What-If Scenario',	10183499,	12000000,	NULL, 'windowRunWhatIfScenario',1,	0,	176

 UNION ALL 
SELECT	10190000, 'Credit Risk And Analysis',	12000000,	12000000,	NULL, NULL,1,	1,	177

 UNION ALL 
SELECT	10191000, 'Maintain Counterparty',	10190000,	12000000,	NULL, 'windowMaintainDefinationArg',1,	0,	178

 UNION ALL 
SELECT	10192000, 'Maintain Counterparty Limit',	10190000,	12000000,	NULL, 'windowMaintainCounterpartyLimit',1,	0,	179

 UNION ALL 
SELECT	10191100, 'Import Credit Data',	10190000,	12000000,	NULL, 'windowImportDataCredit',1,	0,	180

 UNION ALL 
SELECT	10191200, 'Export Credit Data Report',	10190000,	12000000,	NULL, 'windowExportCreditData',1,	0,	181

 UNION ALL 
SELECT	10191300, 'Run Credit Exposure Report',	10190000,	12000000,	NULL, 'windowRunCreditExposureReport',1,	0,	182

 UNION ALL 
SELECT	10191400, 'Run Fixed/MTM Exposure Report',	10190000,	12000000,	NULL, 'windowRunFixdMtmExposureReport',1,	0,	183

 UNION ALL 
SELECT	10191500, 'Run Exposure Concentration Report',	10190000,	12000000,	NULL, 'windowRunConcExposureReport',1,	0,	184

 UNION ALL 
SELECT	10191600, 'Run Credit Reserve Report',	10190000,	12000000,	NULL, 'windowCrRunReserveReport',1,	0,	185

 UNION ALL 
SELECT	10191700, 'Run Aged A/R Report',	10190000,	12000000,	NULL, 'windowAgedARReport',1,	0,	186

 UNION ALL 
SELECT	10191800, 'Calculate Credit Exposure',	10190000,	12000000,	NULL, 'windowCalculateCreditExposure',1,	0,	187

 UNION ALL 
SELECT	10191900, 'Run Counterparty Credit Availability Report',	10190000,	12000000,	NULL, 'windowCounterpartyCreditAvailability',1,	0,	188

 UNION ALL 
SELECT	10200000, 'Reporting',	12000000,	12000000,	NULL, NULL,1,	1,	189

 UNION ALL 
SELECT	10201000, 'Report Writer',	10200000,	12000000,	NULL, 'windowreportwriter',1,	0,	190

 UNION ALL 
SELECT	10201100, 'Run Dashboard Report',	10200000,	12000000,	NULL, 'WindowRunDashReport',1,	0,	191

 UNION ALL 
SELECT	10201200, 'Run Dashboard Report Template',	10200000,	12000000,	NULL, 'WindowDashReportTemplate',1,	0,	192

 UNION ALL 
SELECT	10201300, 'Maintain EoD Log Status',	10200000,	12000000,	NULL, 'windowMaintainEoDLogStatus',1,	0,	193

 UNION ALL 
SELECT	10201400, 'Run Import Audit Report',	10200000,	12000000,	NULL, 'windowRunFilesImportAuditReportPrice',1,	0,	194

 UNION ALL 
SELECT	10201500, 'Run Static Data Audit Report',	10200000,	12000000,	NULL, 'windowRunStaticDataAuditReport',1,	0,	195

 UNION ALL 
SELECT	10201600, 'Report Manager',	10200000,	12000000,	NULL, 'windowReportManager',1,	0,	196

 UNION ALL 
SELECT	10201100, 'Run Report Group',	10200000,	12000000,	NULL, 'WindowRunReportGroup',1,	0,	197

 UNION ALL 
SELECT	10201200, 'Report Group Manager',	10200000,	12000000,	NULL, 'WindowReportGroupManager',1,	0,	198

 UNION ALL 
SELECT	10210000, 'Contract Administration',	12000000,	12000000,	NULL, NULL,1,	1,	199

 UNION ALL 
SELECT	10211000, 'Maintain Contract',	10210000,	12000000,	NULL, 'windowMaintainContractGroup',1,	0,	200

 UNION ALL 
SELECT	10211100, 'Contract Component Templates',	10210000,	12000000,	NULL, 'windowContractChargeType',1,	0,	201

 UNION ALL 
SELECT	10220000, 'Settlement And Billing',	12000000,	12000000,	NULL, NULL,1,	1,	202

 UNION ALL 
SELECT	10221099, 'Run Settlement Calc',	10220000,	12000000,	NULL, NULL,1,	1,	203

 UNION ALL 
SELECT	10221000, 'Run Contract Settlement',	10221099,	12000000,	NULL, 'windowMaintainInvoice',1,	0,	204

 UNION ALL 
SELECT	10222300, 'Run Deal Settlement',	10221099,	12000000,	NULL, 'windowRunSettlement',1,	0,	205

 UNION ALL 
SELECT	10221100, 'Run Inventory Calc',	10221099,	12000000,	NULL, 'windowRunInventoryCalc',1,	0,	206

 UNION ALL 
SELECT	10221300, 'Settlement Calculation History',	10221099,	12000000,	NULL, 'windowMaintainInvoiceHistory',1,	0,	207

 UNION ALL 
SELECT	10221999, 'Run Settlement Report',	10221900,	12000000,	NULL, NULL,1,	1,	208

 UNION ALL 
SELECT	10221900, 'Run Settlement Report',	10221999,	12000000,	NULL, 'windowSettlementReport',1,	0,	209

 UNION ALL 
SELECT	10221200, 'Run Contract Settlement Report',	10221999,	12000000,	NULL, 'windowBrokerFeeReport',1,	0,	210

 UNION ALL 
SELECT	10221800, 'Run Settlement Production Report',	10221999,	12000000,	NULL, 'windowSettlementProductionReport',1,	0,	211

 UNION ALL 
SELECT	10222400, 'Run Meter Data Report',	10220000,	12000000,	NULL, 'windowMeterDataReport',1,	0,	212

 UNION ALL 
SELECT	10221400, 'Post JE Report',	10220000,	12000000,	NULL, 'windowPostJEReport',1,	0,	213

 UNION ALL 
SELECT	10221600, 'Settlement Adjustments',	10220000,	12000000,	NULL, 'windowSettlementAdjustments',1,	0,	214

 UNION ALL 
SELECT	10221700, 'Market Variance Report',	10220000,	12000000,	NULL, 'windowMarketVarienceReport',1,	0,	215

 UNION ALL 
SELECT	10222000, 'SAP Settlement Export',	10220000,	12000000,	NULL, 'windowSAPSettlementExport',1,	0,	216

 UNION ALL 
SELECT	10230000, 'Accounting Inventory',	12000000,	12000000,	NULL, NULL,1,	1,	217

 UNION ALL 
SELECT	10231000, 'Maintain Inventory GL Account',	10230000,	12000000,	NULL, 'windowMaintainInventoryGLAccount',1,	0,	218

 UNION ALL 
SELECT	10231100, 'Run Inventory Journal Entry Report',	10230000,	12000000,	NULL, 'windowRunInventoryAccountReport',1,	0,	219

 UNION ALL 
SELECT	10231200, 'Run Weighted Averag Inventory Cost Report',	10230000,	12000000,	NULL, 'windowRunWghtInventoryCostReport',1,	0,	220

 UNION ALL 
SELECT	10162400, 'Run Roll Forward Inventory Report',	10230000,	12000000,	NULL, 'windowRunRollForwardInventoryReport',1,	0,	221

 UNION ALL 
SELECT	10237000, 'Maintain Manual Journal Entries',	10230000,	12000000,	NULL, 'windowMaintainManualJournalEntries',1,	0,	222

 UNION ALL 
SELECT	10237100, 'Maintain Inventory Cost Override',	10230000,	12000000,	NULL, 'windowInventoryCostOverride',1,	0,	223

 UNION ALL 
SELECT	10237200, 'Run Inventory Calc',	10230000,	12000000,	NULL, 'windowRunInventoryCalc',1,	0,	224

 UNION ALL 
SELECT	10230098, 'Accounting derivative Accounting Srategy',	12000000,	12000000,	NULL, NULL,1,	1,	225

 UNION ALL 
SELECT	10231900, 'Setup Hedging Relationship Types',	10230098,	12000000,	NULL, 'windowSetupHedgingRelationshipsTypes',1,	0,	226

 UNION ALL 
SELECT	10232000, 'Run Hedging Relationship Types Report',	10230098,	12000000,	NULL, 'windowRunSetupHedgingRelationshipsTypesReport',1,	0,	227

 UNION ALL 
SELECT	10101500, 'Maintain Netting Asset/Liab Groups',	10230098,	12000000,	NULL, 'windowMaintainNettingGroups',1,	0,	228

 UNION ALL 
SELECT	10230096, 'Accounting derivative Hedge Effeciveness Test',	12000000,	12000000,	NULL, NULL,1,	1,	229

 UNION ALL 
SELECT	10232300, 'Run Assessment',	10230096,	12000000,	NULL, 'windowRunAssessment',1,	0,	230

 UNION ALL 
SELECT	10232400, 'View Assessment Results',	10230096,	12000000,	NULL, 'windowViewAssessmentResults',1,	0,	231

 UNION ALL 
SELECT	10237300, 'View/Update Cum PNL Series',	10230096,	12000000,	NULL, 'windowViewUpdateCumPNLSeries',1,	0,	232

 UNION ALL 
SELECT	10232500, 'Run Assessment Trend Graph',	10230096,	12000000,	NULL, 'windowRunAssessmentTrendGraph',1,	0,	233

 UNION ALL 
SELECT	10232600, 'Run What-If Effectiveness Analysis',	10230096,	12000000,	NULL, 'windowRunWhatIfEffectivenessAnalysis',1,	0,	234

 UNION ALL 
SELECT	10230097, 'Accounting derivative Deal Capture',	12000000,	12000000,	NULL, NULL,1,	1,	235

 UNION ALL 
SELECT	10232700, 'Import Data',	10230097,	12000000,	NULL, 'windowImportData',1,	0,	236

 UNION ALL 
SELECT	10232800, 'Run Import Audit Report',	10230097,	12000000,	NULL, 'windowRunFilesImportAuditReport',1,	0,	237

 UNION ALL 
SELECT	10232900, 'Maintain Missing Static Data',	10230097,	12000000,	NULL, 'windowMaintainMissingStaticData',1,	0,	238

 UNION ALL 
SELECT	10233000, 'Delete Voided Deal',	10230097,	12000000,	NULL, 'windowVoidDealImports',1,	0,	239

 UNION ALL 
SELECT	10103000, 'Define Meter IDs',	10230097,	12000000,	NULL, 'windowDefineMeterID',1,	0,	240

 UNION ALL 
SELECT	10230095, 'Accounting derivative Transaction Processing',	12000000,	12000000,	NULL, NULL,1,	1,	241

 UNION ALL 
SELECT	10233700, 'Designation of a Hedge',	10230095,	12000000,	NULL, 'windowDesignationofaHedgeFromMenu',1,	0,	242

 UNION ALL 
SELECT	10233800, 'De-Designation of a Hedge by FIFO/LIFO',	10230095,	12000000,	NULL, 'windowDedesignateFifolifo',1,	0,	243

 UNION ALL 
SELECT	10233900, 'Run Hedging Relationship Report',	10230095,	12000000,	NULL, 'windowRunHedgeRelationshipReport',1,	0,	244

 UNION ALL 
SELECT	10234000, 'Reclassify Hedge De-Designation',	10230095,	12000000,	NULL, 'windowReclassifyDedesignationValues',1,	0,	245

 UNION ALL 
SELECT	10234100, 'Amortize Deferred AOCI',	10230095,	12000000,	NULL, 'windowAmortizeLockedAOCI',1,	0,	246

 UNION ALL 
SELECT	10234200, 'Life Cycle of Hedges',	10230095,	12000000,	NULL, 'windowLifecyclesOfHedges',1,	0,	247

 UNION ALL 
SELECT	10234300, 'Automation of Forecasted Transaction',	10230095,	12000000,	NULL, 'windowAutomationofForecastedTransaction',1,	0,	248

 UNION ALL 
SELECT	10234400, 'Automate Matching of Hedges',	10230095,	12000000,	NULL, 'windowAutomationMathingHedge',1,	0,	249

 UNION ALL 
SELECT	10234500, 'View Outstanding Automation Results',	10230095,	12000000,	NULL, 'windowViewOutstandingAutomationResults',1,	0,	250

 UNION ALL 
SELECT	10234600, 'First Day Gain/Loss Treatment',	10230095,	12000000,	NULL, 'windowFirstDayGainLoss',1,	0,	251

 UNION ALL 
SELECT	10234700, 'Maintain Transactions Tagging',	10230095,	12000000,	NULL, 'windowMaintainTransactionsTagging',1,	0,	252

 UNION ALL 
SELECT	10234800, 'Bifurcation Of Embedded Derivatives',	10230095,	12000000,	NULL, 'windowBifurcationEmbeddedDerivatives',1,	0,	253

 UNION ALL 
SELECT	10230094, 'Accounting derivative Ongoing Assessment',	12000000,	12000000,	NULL, NULL,1,	1,	254

 UNION ALL 
SELECT	10233200, 'Run What-If Measurement Analysis',	10230094,	12000000,	NULL, 'windowRunwhatifmeasurementana',1,	0,	255

 UNION ALL 
SELECT	10181000, 'Run MTM',	10230094,	12000000,	NULL, 'windowRunMtmCalc',1,	0,	256

 UNION ALL 
SELECT	10233300, 'Copy Prior MTM Value',	10230094,	12000000,	NULL, 'windowPriorMTM',1,	0,	257

 UNION ALL 
SELECT	10233400, 'Run Measurement',	10230094,	12000000,	NULL, 'windowRunMeasurement',1,	0,	258

 UNION ALL 
SELECT	10233500, 'Run Calc Embedded Derivative',	10230094,	12000000,	NULL, 'windowCalcEmbedded',1,	0,	259

 UNION ALL 
SELECT	10233600, 'Close Accounting Period',	10230094,	12000000,	NULL, 'windowCloseMeasurement',1,	0,	260

 UNION ALL 
SELECT	10230093, 'Accounting derivative Reporting',	12000000,	12000000,	NULL, NULL,1,	1,	261

 UNION ALL 
SELECT	10234900, 'Run Measurement Report',	10230093,	12000000,	NULL, 'windowRunMeasurementReport',1,	0,	262

 UNION ALL 
SELECT	10235000, 'Run Measurement Trend Graph',	10230093,	12000000,	NULL, 'windowRunMeasurementTrendGraph',1,	0,	263

 UNION ALL 
SELECT	10235100, 'Run Period Change Values Report',	10230093,	12000000,	NULL, 'windowPeriodChangeValueReport',1,	0,	264

 UNION ALL 
SELECT	10235200, 'Run AOCI Report',	10230093,	12000000,	NULL, 'windowAOCIReport',1,	0,	265

 UNION ALL 
SELECT	13160000, 'Run Hedging Relationship Audit Report',	10230093,	12000000,	NULL, 'windowHedgingRelationshipReport',1,	0,	266

 UNION ALL 
SELECT	10235300, 'Run De-Designation Values Report',	10230093,	12000000,	NULL, 'windowDedesignateReport',1,	0,	267

 UNION ALL 
SELECT	10235400, 'Run Journal Entry Report',	10230093,	12000000,	NULL, 'windowRunJournalEntryReport',1,	0,	268

 UNION ALL 
SELECT	10235500, 'Run Netted Journal Entry Report',	10230093,	12000000,	NULL, 'windowRunNettedJournalEntryReport',1,	0,	269

 UNION ALL 
SELECT	10234900, 'Run Hedge Cashflow Deferral Report',	10230093,	12000000,	NULL, 'windowRunHedgeCashflowDeferral',1,	0,	270

 UNION ALL 
SELECT	10230092, 'Run Disclosure Report',	10230093,	12000000,	NULL, NULL,1,	1,	271

 UNION ALL 
SELECT	10235600, 'Run Accounting Disclosure Report',	10230092,	12000000,	NULL, 'windowRunDisclosureReport',1,	0,	272

 UNION ALL 
SELECT	10235700, 'Run Fair Value Disclosure Report',	10230092,	12000000,	NULL, 'windowRunnetAssetsReport',1,	0,	273

 UNION ALL 
SELECT	10235800, 'Run Assessment Report',	10230093,	12000000,	NULL, 'windowRunAssessmentReport',1,	0,	274

 UNION ALL 
SELECT	10235900, 'Run Transaction Report',	10230093,	12000000,	NULL, 'windowRunDealReport',1,	0,	275

 UNION ALL 
SELECT	10236000, 'Run Tagging Export',	10230093,	12000000,	NULL, 'windowTaggingExport',1,	0,	276

 UNION ALL 
SELECT	10230091, 'Run Exception Report',	10230093,	12000000,	NULL, NULL,1,	1,	277

 UNION ALL 
SELECT	10236100, 'Run Missing Assessment Values Report',	10230091,	12000000,	NULL, 'windowRunMissingAssessmentValuesReport',1,	0,	278

 UNION ALL 
SELECT	10236200, 'Run Failed Assessment Values Report',	10230091,	12000000,	NULL, 'windowRunFailAssessmentValuesReport',1,	0,	279

 UNION ALL 
SELECT	10236300, 'Run Unapproved Hedging Relationship Exception Report',	10230091,	12000000,	NULL, 'windowRunUnapprovedHedgingRelationshipExceptionReport',1,	0,	280

 UNION ALL 
SELECT	10236400, 'Run Available Hedge Capacity Exception Report',	10230091,	12000000,	NULL, 'windowRunAvailableHedgeCapacityExceptionReport',1,	0,	281

 UNION ALL 
SELECT	10236500, 'Run Not Mapped Transaction Report',	10230091,	12000000,	NULL, 'windowRunNotMappedDealReport',1,	0,	282

 UNION ALL 
SELECT	10236600, 'Run Tagging Audit Report',	10230091,	12000000,	NULL, 'windowRunTaggingAuditReport',1,	0,	283

 UNION ALL 
SELECT	10236700, 'Run Hedge and Item Position Matching Report',	10230091,	12000000,	NULL, 'windowHedgeItemMatchExceptRpt',1,	0,	284

 UNION ALL 
SELECT	10201000, 'Report Writer',	10230093,	12000000,	NULL, 'windowreportwriter',1,	0,	285

 UNION ALL 
SELECT	10230099, 'Accounting Accural',	12000000,	12000000,	NULL, NULL,1,	1,	286

 UNION ALL 
SELECT	10231500, 'Curve Value Report',	10230099,	12000000,	NULL, 'windowCurveValueReport',1,	0,	287

 UNION ALL 
SELECT	10231600, 'Run Revenue Report',	10230099,	12000000,	NULL, 'windowRevenueReport',1,	0,	288

 UNION ALL 
SELECT	10231700, 'Run Accrual Journal Entry Report',	10230099,	12000000,	NULL, 'windowRunInventoryJournalEntryReport',1,	0,	289

 UNION ALL 
SELECT	10231800, 'Run EQR Report',	10230099,	12000000,	NULL, 'windowRunEQRReport',1,	0,	290

 UNION ALL 
SELECT	10240000, 'Treasury',	12000000,	12000000,	NULL, NULL,1,	1,	291

 UNION ALL 
SELECT	10241000, 'Reconcile Cash Entries for Derivatives',	10240000,	12000000,	NULL, 'windowReconcileCashEntriesDerivatives',1,	0,	292

 UNION ALL 
SELECT	10241100, 'Apply Cash',	10240000,	12000000,	NULL, 'windowApplyCash',1,	0,	293																			


/**********************************RECTracker Menus*********************************************************************/


 UNION ALL 
SELECT	14000000	, 'RECTracker',	NULL	,	14000000	,	NULL	, 	NULL		,1,	1,	1

 UNION ALL 
SELECT	10100000	, 'Setup ',	14000000	,	14000000	,	NULL	, 	NULL		,1,	1,	2

 UNION ALL 
SELECT	10101099	, 'Setup Static Data',	10100000	,	14000000	,	NULL	, 	NULL		,1,	1,	3

 UNION ALL 
SELECT	10101000	, 'Maintain Static Data',	10101099	,	14000000	,	NULL	, 'windowMaintainStaticData',1,	0,	4

 UNION ALL 
SELECT	10101100	, 'Maintain Definition',	10101099	,	14000000	,	NULL	, 'windowMaintainDefination',1,	0,	5

 UNION ALL 
SELECT	10101200	, 'Setup Book Structure',	10101099	,	14000000	,	NULL	, 'windowSetupHedgingStrategies',1,	0,	6

 UNION ALL 
SELECT	10102600	, 'Setup Price Curves',	10101099	,	14000000	,	NULL	, 'windowSetupPriceCurves',1,	0,	7

 UNION ALL 
SELECT	10102500	, 'Setup Location',	10101099	,	14000000	,	NULL	, 'windowSetupLocation',1,	0,	8

 UNION ALL 
SELECT	10102800	, 'Setup Profile',	10101099	,	14000000	,	NULL	, 'windowSetupProfile',1,	0,	9

 UNION ALL 
SELECT	10101300	, 'Map GL Codes',	10100000	,	14000000	,	NULL	, 'windowMapGLCodes',1,	0,	10

 UNION ALL 
SELECT	10101499	, 'Setup Deal Templates',	10100000	,	14000000	,	NULL	, NULL,1,	1,	11

 UNION ALL 
SELECT	10101400	, 'Maintain Deal Template',	10101499	,	14000000	,	NULL	, 'windowMaintainDealTemplate',1,	0,	12

 UNION ALL 
SELECT	10104200	, 'Maintain Field Template',	10101499	,	14000000	,	NULL	, 'windowSetupFieldTemplate',1,	0,	13

 UNION ALL 
SELECT	10104100	, 'Maintain UDF Template',	10101499	,	14000000	,	NULL	, 'windowSetupUDFTemplate',1,	0,	14

 UNION ALL 
SELECT	10103900	, 'Setup Deal Status and Confirmation Rule',	10101499	,	14000000	,	NULL	, 'windowSetupDealStatusConfirmationRule',1,	0,	15

 UNION ALL 
SELECT	10104000	, 'Define Deal Status Privilege',	10101499	,	14000000	,	NULL	, 'windowDefineDealStatusPrivilege',1,	0,	16

 UNION ALL 
SELECT	10103500	, 'Maintain Hedge Deferral Rules',	10101499	,	14000000	,	NULL	, 'windowSetupHedgingRelationshipsTypesWithReturn',1,	0,	17

 UNION ALL 
SELECT	10101500	, 'Maintain Netting Asset/Liab Groups',	10100000	,	14000000	,	NULL	, 'windowMaintainNettingGroups',1,	0,	18

 UNION ALL 
SELECT	10101600	, 'View Scheduled Job',	10100000	,	14000000	,	NULL	, 'windowSchedulejob',1,	0,	19

 UNION ALL 
SELECT	10103000	, 'Define Meter IDs',	10100000	,	14000000	,	NULL	, 'windowDefineMeterID',1,	0,	20

 UNION ALL 
SELECT	10103800	, 'Maintain Source Generator',	10100000	,	14000000	,	NULL	, 'windowMaintainSourceGenerator',1,	0,	21

 UNION ALL 
SELECT	10103399	, 'Setup Contract Components ',	10100000	,	14000000	,	NULL	, NULL,1,	1,	22

 UNION ALL 
SELECT	10103300	, 'Maintain Contract Components Gl Codes',	10103399	,	14000000	,	NULL	, 'windowDefineInvoiceGLCode',1,	0,	23

 UNION ALL 
SELECT	10103400	, 'Setup Default GL Code for Contract Components',	10103399	,	14000000	,	NULL	, 'windowSetupDefaultGLCode',1,	0,	24

 UNION ALL 
SELECT	10104300	, 'Setup Contract Component Mapping',	10103399	,	14000000	,	NULL	, 'windowSetupContractComponentMapping',1,	0,	25

 UNION ALL 
SELECT	10104400	, 'Setup Contract Price',	10103399	,	14000000	,	NULL	, 'windowSetupContractPrice',1,	0,	26

 UNION ALL 
SELECT	10101900	, 'Setup Logical Trade Lock',	10100000	,	14000000	,	NULL	, 'windowSetupDealLock',1,	0,	27

 UNION ALL 
SELECT	10102000	, 'Setup Tenor Bucket',	10100000	,	14000000	,	NULL	, 'windowSetupTenorBucketData',1,	0,	28

 UNION ALL 
SELECT	10102900	, 'Manage Documents',	10100000	,	14000000	,	NULL	, 'windowManageDocumentsMain',1,	0,	29

 UNION ALL 
SELECT	10102300	, 'Setup Emissions Source/Sink Type',	10100000	,	14000000	,	NULL	, 'windowSetupEMSStrategies',1,	0,	30

 UNION ALL 
SELECT	10102200	, 'Setup As of Date',	10100000	,	14000000	,	NULL	, 'windowSetupAsOfDate',1,	0,	31

 UNION ALL 
SELECT	10102400	, 'Formula Builder',	10100000	,	14000000	,	NULL	, 'windowFormulaBuilder',1,	0,	32

 UNION ALL 
SELECT	13170000	, 'Mapping Setup',	10100000	,	14000000	,	NULL	, NULL,1,	1,	33

 UNION ALL 
SELECT	10103100	, 'Term Mapping ',	13170000	,	14000000	,	NULL	, 'windowSetupTrayportTermMappingStaging',1,	0,	34

 UNION ALL 
SELECT	10103200	, 'Pratos Mapping',	13170000	,	14000000	,	NULL	, 'windowPratosMapping',1,	0,	35

 UNION ALL 
SELECT	13171000	, 'ST Forecast Mapping',	13170000	,	14000000	,	NULL	, 'windowSTForecastMapping',1,	0,	36

 UNION ALL 
SELECT	10102799	, 'Manage Data',	10100000	,	14000000	,	NULL	, NULL,1,	1,	37

 UNION ALL 
SELECT	10102700	, 'Archive Data',	10102799	,	14000000	,	NULL	, 'windowSetupArchiveData',1,	0,	38

 UNION ALL 
SELECT	10103600	, 'Remove Data',	10102799	,	14000000	,	NULL	, 'windowRemoveData',1,	0,	39

 UNION ALL 
SELECT	10110000	, 'Users and Roles',	14000000	,	14000000	,	NULL	, NULL,1,	1,	40

 UNION ALL 
SELECT	10111000	, 'Maintain Users',	10110000	,	14000000	,	NULL	, 'windowMaintainUsers',1,	0,	41

 UNION ALL 
SELECT	10111100	, 'Maintain Roles',	10110000	,	14000000	,	NULL	, 'windowMaintainRoles',1,	0,	42

 UNION ALL 
SELECT	10111200	, 'Maintain Work Flow Menu',	10110000	,	14000000	,	NULL	, 'windowCustomizedMenu',1,	0,	43

 UNION ALL 
SELECT	10111300	, 'Run Privilege Report',	10110000	,	14000000	,	NULL	, 'windowRunPrivilege',1,	0,	44

 UNION ALL 
SELECT	10111400	, 'Run System Access Log Report',	10110000	,	14000000	,	NULL	, 'windowRunSystemAccessLog',1,	0,	45

 UNION ALL 
SELECT	10111500	, 'Maintain Report',	10110000	,	14000000	,	NULL	, 'windowMaintainReport',1,	0,	46

 UNION ALL 
SELECT	10120000	, 'Compliance Management',	14000000	,	14000000	,	NULL	, NULL,1,	1,	47

 UNION ALL 
SELECT	10121300	, 'Maintain Compliance Standards',	10120000	,	14000000	,	NULL	, 'MaintainComplianceStandards',1,	0,	48

 UNION ALL 
SELECT	10121000	, 'Maintain Compliance Groups',	10120000	,	14000000	,	NULL	, 'maintainComplianceProcess',1,	0,	49

 UNION ALL 
SELECT	10121400	, 'Activity Process Map',	10120000	,	14000000	,	NULL	, 'windowActivityProcessMap',1,	0,	50

 UNION ALL 
SELECT	10121500	, 'Change Owners',	10120000	,	14000000	,	NULL	, 'MaintainChangeOwners',1,	0,	51

 UNION ALL 
SELECT	10121200	, 'Perform Compliance Activities',	10120000	,	14000000	,	NULL	, 'PerformComplianceActivities',1,	0,	52

 UNION ALL 
SELECT	10121100	, 'Approve Compliance Activities',	10120000	,	14000000	,	NULL	, 'ApproveComplianceActivities',1,	0,	53

 UNION ALL 
SELECT	10122300	, 'Reports',	10120000	,	14000000	,	NULL	, NULL,1,	1,	54

 UNION ALL 
SELECT	10121600	, 'View Compliance Activities',	10122300	,	14000000	,	NULL	, 'ViewComplianceActivities',1,	0,	55

 UNION ALL 
SELECT	10121700	, 'View Status On Compliance Activities',	10122300	,	14000000	,	NULL	, 'ReportComplianceActivities',1,	0,	56

 UNION ALL 
SELECT	10122200	, 'View Compliance Calendar',	10122300	,	14000000	,	NULL	, 'windowComplianceCalendar',1,	0,	57

 UNION ALL 
SELECT	10121800	, 'Run Compliance Activity Audit Report',	10122300	,	14000000	,	NULL	, 'RunComplianceAuditReport',1,	0,	58

 UNION ALL 
SELECT	10121900	, 'Run Compliance Trend Report',	10122300	,	14000000	,	NULL	, 'RunComplianceTrendReport',1,	0,	59

 UNION ALL 
SELECT	10122000	, 'Run Compliance Graph Report',	10122300	,	14000000	,	NULL	, 'dashReportPie',1,	0,	60

 UNION ALL 
SELECT	10122100	, 'Run Compliance Status Graph Report',	10122300	,	14000000	,	NULL	, 'dashReportBar',1,	0,	61

 UNION ALL 
SELECT	10122400	, 'Run Compliance Due Date Violation Report',	10122300	,	14000000	,	NULL	, 'RunComplianceDateVoilationReport',1,	0,	62

 UNION ALL 
SELECT	12100000	, 'Renewable Sources',	14000000	,	14000000	,	NULL	, NULL,1,	1,	63

 UNION ALL 
SELECT	12101100	, 'Maintain Input Characteristics',	12100000	,	14000000	,	NULL	, 'windowEMSMaintainCharater',1,	0,	64

 UNION ALL 
SELECT	12101200	, 'Maintain Multiple Source/Sink Unit Map',	12100000	,	14000000	,	NULL	, 'windowMultipleSourceUnitMap',1,	0,	65

 UNION ALL 
SELECT	12101300	, 'Maintain Input/Output',	12100000	,	14000000	,	NULL	, 'windowDefineEmissionInputOutput',1,	0,	66

 UNION ALL 
SELECT	12101140	, 'Define Emissions Source Model',	12100000	,	14000000	,	NULL	, 'windowDefineEmissionSourceModel',1,	0,	67

 UNION ALL 
SELECT	12101150	, 'Maintain Emissions Source/Sinks',	12100000	,	14000000	,	NULL	, 'windowMaintainEmsGenerators',1,	0,	68

 UNION ALL 
SELECT	12101160	, 'Maintain Emissions Source/Sinks Detail',	12100000	,	14000000	,	NULL	, 'windowMaintainEmsGeneratorsDetail',1,	0,	69

 UNION ALL 
SELECT	12101170	, 'Maintain Renewable Sources',	12100000	,	14000000	,	NULL	, 'windowMaintainRenewableGenerators',1,	0,	70

 UNION ALL 
SELECT	12101180	, 'Setup User Defined Source/Sink Group',	12100000	,	14000000	,	NULL	, 'windowSetupSourceSinkGroup',1,	0,	71

 UNION ALL 
SELECT	12101190	, 'Maintain Decaying Factor ',	12100000	,	14000000	,	NULL	, 'windowMaintainDecaying',1,	0,	72

 UNION ALL 
SELECT	12102000	, 'Maintain Emission Input/Output Data',	12100000	,	14000000	,	NULL	, 'windowMaintainEmsInput',1,	0,	73

 UNION ALL 
SELECT	12102100	, 'Input Activity Data',	12100000	,	14000000	,	NULL	, 'windowInputActivityData',1,	0,	74

 UNION ALL 
SELECT	12102200	, 'Setup Wizard',	12100000	,	14000000	,	NULL	, 'windowWizardWelcomeScreen',1,	0,	75

 UNION ALL 
SELECT	12102399	, 'Reports',	12100000	,	14000000	,	NULL	, NULL,1,	1,	76

 UNION ALL 
SELECT	12102300	, 'Run Source/Sink Info Report',	12102399	,	14000000	,	NULL	, 'windowSourceSinkInfoReport',1,	0,	77

 UNION ALL 
SELECT	12102400	, 'Run Exceptions Report',	12102399	,	14000000	,	NULL	, 'windowRunExceptionsReport',1,	0,	78

 UNION ALL 
SELECT	12102500	, 'Emissions Source Model Report',	12102399	,	14000000	,	NULL	, 'windowEmissionsSourceModelReport',1,	0,	79

 UNION ALL 
SELECT	12102699	, 'Emissions Vendor Setup Wizard',	12100000	,	14000000	,	NULL	, NULL,1,	1,	80

 UNION ALL 
SELECT	12102600	, 'Maintain Company Type',	12102699	,	14000000	,	NULL	, 'windowDefineMainCompType',1,	0,	81

 UNION ALL 
SELECT	12102700	, 'Maintain Source/Sink category',	12102699	,	14000000	,	NULL	, 'windowMaintainSourceSinkCatFrame',1,	0,	82

 UNION ALL 
SELECT	12103000	, 'Maintain Company Type Template',	12102699	,	14000000	,	NULL	, 'windowDefineMainCompTypeTemp',1,	0,	83

 UNION ALL 
SELECT	12102800	, 'Company Type Source Model',	12102699	,	14000000	,	NULL	, 'windowCompanyTypeSourceModel1',1,	0,	84

 UNION ALL 
SELECT	12102900	, 'Company Source Sink Template',	12102699	,	14000000	,	NULL	, 'windowCompanySourceSinkTemplate',1,	0,	85

 UNION ALL 
SELECT	12103100	, 'Maintain Emission Limits',	12100000	,	14000000	,	NULL	, 'windowMaintainLimits',1,	0,	86

 UNION ALL 
SELECT	12120000	, 'Allowance/Credit Assignment',	14000000	,	14000000	,	NULL	, NULL,1,	1,	87

 UNION ALL 
SELECT	12121000	, 'Maintain Emissions Profile/Credit requirements',	12120000	,	14000000	,	NULL	, 'windowMaintainEmission',1,	0,	88

 UNION ALL 
SELECT	12121100	, 'Maintain Target Emissions',	12120000	,	14000000	,	NULL	, 'windowMaintainTargetEmission',1,	0,	89

 UNION ALL 
SELECT	12121200	, 'Reconcile Certificates',	12120000	,	14000000	,	NULL	, 'windowRecGis',1,	0,	90

 UNION ALL 
SELECT	12121300	, 'Assign Transactions',	12120000	,	14000000	,	NULL	, 'windowAssignRecDeals',1,	0,	91

 UNION ALL 
SELECT	12121400	, 'Unassign Transactions',	12120000	,	14000000	,	NULL	, 'windowUnAssignRecDeals',1,	0,	92

 UNION ALL 
SELECT	12121500	, 'Lifecycle of Transactions',	12120000	,	14000000	,	NULL	, 'windowLifecyclesOfRec',1,	0,	93

 UNION ALL 
SELECT	12130000	, 'Inventory and Compliance Reporting',	14000000	,	14000000	,	NULL	, NULL,1,	1,	94

 UNION ALL 
SELECT	12131000	, 'Run Target Report',	12130000	,	14000000	,	NULL	, 'windowRunTargetReport',1,	0,	95

 UNION ALL 
SELECT	12131100	, 'Run Inventory Position Report',	12130000	,	14000000	,	NULL	, 'windowRunRecActivity',1,	0,	96

 UNION ALL 
SELECT	12131200	, 'Run Transactions Report',	12130000	,	14000000	,	NULL	, 'windowRunTransactionsReport',1,	0,	97

 UNION ALL 
SELECT	12131300	, 'Run Compliance Report',	12130000	,	14000000	,	NULL	, 'windowRecComplianceReport',1,	0,	98

 UNION ALL 
SELECT	12131400	, 'Run Exposure Report',	12130000	,	14000000	,	NULL	, 'windowRecExposureReport',1,	0,	99

 UNION ALL 
SELECT	12131500	, 'Run Market Value Report',	12130000	,	14000000	,	NULL	, 'windowRunMarketValueReport',1,	0,	100

 UNION ALL 
SELECT	12131600	, 'Allowance Transfer Form',	12130000	,	14000000	,	NULL	, 'windowAllowanceTransfer',1,	0,	101

 UNION ALL 
SELECT	12131700	, 'Run Allowance Reconciliation Report',	12130000	,	14000000	,	NULL	, 'windowRunAllowanceReconciliationReport',1,	0,	102

 UNION ALL 
SELECT	12131800	, 'Run REC Production Report',	12130000	,	14000000	,	NULL	, 'windowRecProductionReport',1,	0,	103

 UNION ALL 
SELECT	12131900	, 'Run Generator Report',	12130000	,	14000000	,	NULL	, 'windowRecGeneratorReport',1,	0,	104

 UNION ALL 
SELECT	12132000	, 'Run Generator Info Report',	12130000	,	14000000	,	NULL	, 'windowGeneratorInfoReport',1,	0,	105

 UNION ALL 
SELECT	12132100	, 'Run Gen/Credit Source Allocation Report',	12130000	,	14000000	,	NULL	, 'windowRecGenAllocateReport',1,	0,	106

 UNION ALL 
SELECT	12132200	, 'Purchase Power Renewable Report',	12130000	,	14000000	,	NULL	, 'windowWindPurPowerReport',1,	0,	107

 UNION ALL 
SELECT	10130000	, 'Deal Capture',	14000000	,	14000000	,	NULL	, NULL,1,	1,	108

 UNION ALL 
SELECT	10131000	, 'Maintain Transactions',	10130000	,	14000000	,	NULL	, 'windowMaintainDeals',1,	0,	109

 UNION ALL 
SELECT	10131300	, 'Import Data',	10130000	,	14000000	,	NULL	, 'windowImportDataDeal',1,	0,	110

 UNION ALL 
SELECT	10131500	, 'Import EPA Allowance Data',	10130000	,	14000000	,	NULL	, 'windowEPAAllowanceData',1,	0,	111

 UNION ALL 
SELECT	10131600	, 'Transfer Book Position',	10130000	,	14000000	,	NULL	, 'windowTransferBookPosition',1,	0,	112

 UNION ALL 
SELECT	10140000	, 'Position Reporting',	14000000	,	14000000	,	NULL	, NULL,1,	1,	113

 UNION ALL 
SELECT	10141000	, 'Run Index Position Report',	10140000	,	14000000	,	NULL	, 'windowRunPositionReport',1,	0,	114

 UNION ALL 
SELECT	10141700	, 'Run Trader Position Report',	10140000	,	14000000	,	NULL	, 'windowRunTraderPositionReport',1,	0,	115

 UNION ALL 
SELECT	10141100	, 'Run Options Report',	10140000	,	14000000	,	NULL	, 'windowRunOptionsReport',1,	0,	116

 UNION ALL 
SELECT	10141200	, 'Run Options Greeks Report',	10140000	,	14000000	,	NULL	, 'windowRunOptionsGreeksReport',1,	0,	117

 UNION ALL 
SELECT	10141300	, 'Run Hourly Position Report',	10140000	,	14000000	,	NULL	, 'windowRunHourlyProductionReport',1,	0,	118

 UNION ALL 
SELECT	10141900	, 'Run Load Forecast Report',	10140000	,	14000000	,	NULL	, 'windowRunLoadForecastReport',1,	0,	119

 UNION ALL 
SELECT	10142100	, 'Run FX Exposure Report',	10140000	,	14000000	,	NULL	, 'windowRunFXExposureReport',1,	0,	120

 UNION ALL 
SELECT	10142200	, 'Run Explain Report',	10140000	,	14000000	,	NULL	, 'windowRunPositionExplainReport',1,	0,	121

 UNION ALL 
SELECT	10142300	, 'Run Power Bidding Nomination Report',	10140000	,	14000000	,	NULL	, 'windowPowerBiddingNominationReport',1,	0,	122

 UNION ALL 
SELECT	10150000	, 'Price Curve Management',	14000000	,	14000000	,	NULL	, NULL,1,	1,	123

 UNION ALL 
SELECT	10151000	, 'View Prices',	10150000	,	14000000	,	NULL	, 'windowViewPrices',1,	0,	124

 UNION ALL 
SELECT	10151100	, 'Import Price',	10150000	,	14000000	,	NULL	, 'windowImportDataPrice',1,	0,	125

 UNION ALL 
SELECT	10170000	, 'Deal Verification And Confirmation',	14000000	,	14000000	,	NULL	, NULL,1,	1,	126

 UNION ALL 
SELECT	10171000	, 'Confirm Transactions',	10170000	,	14000000	,	NULL	, 'windowConfirmModule',1,	0,	127

 UNION ALL 
SELECT	10171400	, 'Update Deal Status and Confirmation',	10170000	,	14000000	,	NULL	, 'windowUpdateConfirmModule',1,	0,	128

 UNION ALL 
SELECT	10171500	, 'Update Deal Status',	10170000	,	14000000	,	NULL	, 'windowUpdateModule',1,	0,	129

 UNION ALL 
SELECT	10171100	, 'Transaction Audit Log Report',	10170000	,	14000000	,	NULL	, 'windowTransactionAuditLog',1,	0,	130

 UNION ALL 
SELECT	10171200	, 'Lock/Unlock Deal',	10170000	,	14000000	,	NULL	, 'windowLockUnlockDeal',1,	0,	131

 UNION ALL 
SELECT	10171300	, 'Run Unconfirmed Exception Report',	10170000	,	14000000	,	NULL	, 'windowUnconfirmedExeptionReport',1,	0,	132

 UNION ALL 
SELECT	10180000	, 'Valuation And Risk Analysis',	14000000	,	14000000	,	NULL	, NULL,1,	1,	133

 UNION ALL 
SELECT	10181099	, 'Run MTM',	10180000	,	14000000	,	NULL	, NULL,1,	1,	134

 UNION ALL 
SELECT	10181000	, 'Run MTM Process',	10181099	,	14000000	,	NULL	, 'windowRunMtmCalc',1,	0,	135

 UNION ALL 
SELECT	10181100	, 'Run MTM Report',	10181099	,	14000000	,	NULL	, 'windowMTMReport',1,	0,	136

 UNION ALL 
SELECT	10182200	, 'Run Counterparty MTM report',	10181099	,	14000000	,	NULL	, 'windowCounterpartyMTMReport',1,	0,	137

 UNION ALL 
SELECT	10183000	, 'Maintain Monte Carlo Models',	10180000	,	14000000	,	NULL	, 'windowMaintainMonteCarloModels',1,	0,	138

 UNION ALL 
SELECT	10183100	, 'Run Monte Carlo Simulation',	10180000	,	14000000	,	NULL	, 'windowRunMonteCarloSimulation',1,	0,	139

 UNION ALL 
SELECT	10181299	, 'Run At Risk',	10180000	,	14000000	,	NULL	, NULL,1,	1,	140

 UNION ALL 
SELECT	10181200	, 'Maintain At Risk Measurement Criteria',	10181299	,	14000000	,	NULL	, 'VaRMeasurementCriteriaDetail',1,	0,	141

 UNION ALL 
SELECT	10181500	, 'Run At Risk calculation',	10181299	,	14000000	,	NULL	, 'VaRMeasurementCriteriaDetailReport',1,	0,	142

 UNION ALL 
SELECT	10181600	, 'Run At Risk Report',	10181299	,	14000000	,	NULL	, 'windowVaRreport',1,	0,	143

 UNION ALL 
SELECT	10181399	, 'Run Limits',	10180000	,	14000000	,	NULL	, NULL,1,	1,	144

 UNION ALL 
SELECT	10181300	, 'Maintain Limits',	10181399	,	14000000	,	NULL	, 'LimitTrackingScreen',1,	0,	145

 UNION ALL 
SELECT	10181700	, 'Run Limits Report',	10181399	,	14000000	,	NULL	, 'windowLimitsReport',1,	0,	146

 UNION ALL 
SELECT	10181499	, 'Run Volatility Calculations',	10180000	,	14000000	,	NULL	, NULL,1,	1,	147

 UNION ALL 
SELECT	10181400	, 'Calculate Volatility, Correlation and Expected Return',	10181499	,	14000000	,	NULL	, 'CalculateVolatilityCorrelation',1,	0,	148

 UNION ALL 
SELECT	10182000	, 'View Volatility, Correlation and Expected Return',	10181499	,	14000000	,	NULL	, 'windowViewVolCorReport',1,	0,	149

 UNION ALL 
SELECT	10181800	, 'Run Implied Volatility Calculation',	10181499	,	14000000	,	NULL	, 'windowCalImpVolatility',1,	0,	150

 UNION ALL 
SELECT	10181900	, 'Run Implied Volatility Report',	10181499	,	14000000	,	NULL	, 'windowReportImpVol',1,	0,	151

 UNION ALL 
SELECT	10182300	, 'Financial Forecast Model',	10180000	,	14000000	,	NULL	, 'windowCashflowEarningsModel',1,	0,	152

 UNION ALL 
SELECT	10182600	, 'Calculate Financial Forecast',	10180000	,	14000000	,	NULL	, 'windowCalculateFinancialForecast',1,	0,	153

 UNION ALL 
SELECT	10182400	, 'Financial Forecast Report',	10180000	,	14000000	,	NULL	, 'windowRunCashflowEarningsReport',1,	0,	154

 UNION ALL 
SELECT	10182900	, 'Run Hedge Cashflow Deferral Report',	10180000	,	14000000	,	NULL	, 'windowRunHedgeCashflowDeferral',1,	0,	155

 UNION ALL 
SELECT	10183499	, 'Run What-If',	10180000	,	14000000	,	NULL	, NULL,1,	1,	156

 UNION ALL 
SELECT	10183200	, 'Maintain Portfolio Group',	10183499	,	14000000	,	NULL	, 'windowMaintainPortfolioGroup',1,	0,	157

 UNION ALL 
SELECT	10183300	, 'Maintain What-If Scenario',	10183499	,	14000000	,	NULL	, 'windowMaintainWhatIfScenario',1,	0,	158

 UNION ALL 
SELECT	10183400	, 'Maintain What-If Criteria',	10183499	,	14000000	,	NULL	, 'windowMaintainWhatIfCriteria',1,	0,	159

 UNION ALL 
SELECT	10183500	, 'Run What-If Analysis Report',	10183499	,	14000000	,	NULL	, 'windowRunWhatIfAnalysisReport',1,	0,	160

 UNION ALL 
SELECT	10190000	, 'Credit Risk And Analysis',	14000000	,	14000000	,	NULL	, NULL,1,	1,	161

 UNION ALL 
SELECT	10191000	, 'Maintain Counterparty',	10190000	,	14000000	,	NULL	, 'windowMaintainDefinationArg',1,	0,	162

 UNION ALL 
SELECT	10192000	, 'Maintain Counterparty Limit',	10190000	,	14000000	,	NULL	, 'windowMaintainCounterpartyLimit',1,	0,	163

 UNION ALL 
SELECT	10191100	, 'Import Credit Data',	10190000	,	14000000	,	NULL	, 'windowImportDataCredit',1,	0,	164

 UNION ALL 
SELECT	10191200	, 'Export Credit Data Report',	10190000	,	14000000	,	NULL	, 'windowExportCreditData',1,	0,	165

 UNION ALL 
SELECT	10191300	, 'Run Credit Exposure Report',	10190000	,	14000000	,	NULL	, 'windowRunCreditExposureReport',1,	0,	166

 UNION ALL 
SELECT	10191400	, 'Run Fixed/MTM Exposure Report',	10190000	,	14000000	,	NULL	, 'windowRunFixdMtmExposureReport',1,	0,	167

 UNION ALL 
SELECT	10191500	, 'Run Exposure Concentration Report',	10190000	,	14000000	,	NULL	, 'windowRunConcExposureReport',1,	0,	168

 UNION ALL 
SELECT	10191600	, 'Run Credit Reserve Report',	10190000	,	14000000	,	NULL	, 'windowCrRunReserveReport',1,	0,	169

 UNION ALL 
SELECT	10191700	, 'Run Aged A/R Report',	10190000	,	14000000	,	NULL	, 'windowAgedARReport',1,	0,	170

 UNION ALL 
SELECT	10191800	, 'Calculate Credit Exposure',	10190000	,	14000000	,	NULL	, 'windowCalculateCreditExposure',1,	0,	171

 UNION ALL 
SELECT	10191900	, 'Run Counterparty Credit Availability Report',	10190000	,	14000000	,	NULL	, 'windowCounterpartyCreditAvailability',1,	0,	172

 UNION ALL 
SELECT	10200000	, 'Reporting',	14000000	,	14000000	,	NULL	, NULL,1,	1,	173

 UNION ALL 
SELECT	10201000	, 'Report Writer',	10200000	,	14000000	,	NULL	, 'windowreportwriter',1,	0,	174

 UNION ALL 
SELECT	10201300	, 'Maintain EoD Log Status',	10200000	,	14000000	,	NULL	, 'windowMaintainEoDLogStatus',1,	0,	175

 UNION ALL 
SELECT	10201400	, 'Run Import Audit Report',	10200000	,	14000000	,	NULL	, 'windowRunFilesImportAuditReportPrice',1,	0,	176

 UNION ALL 
SELECT	10201500	, 'Run Static Data Audit Report',	10200000	,	14000000	,	NULL	, 'windowRunStaticDataAuditReport',1,	0,	177

 UNION ALL 
SELECT	10201600	, 'Report Manager',	10200000	,	14000000	,	NULL	, 'windowReportManager',1,	0,	178

 UNION ALL 
SELECT	10201100	, 'Run Report Group',	10200000	,	14000000	,	NULL	, 'WindowRunReportGroup',1,	0,	179

 UNION ALL 
SELECT	10201200	, 'Report Group Manager',	10200000	,	14000000	,	NULL	, 'WindowReportGroupManager',1,	0,	180

 UNION ALL 
SELECT	10210000	, 'Contract Administration',	14000000	,	14000000	,	NULL	, NULL,1,	1,	181

 UNION ALL 
SELECT	10211000	, 'Maintain Contract',	10210000	,	14000000	,	NULL	, 'windowMaintainContractGroup',1,	0,	182

 UNION ALL 
SELECT	10211100	, 'Contract Component Templates',	10210000	,	14000000	,	NULL	, 'windowContractChargeType',1,	0,	183

 UNION ALL 
SELECT	10220000	, 'Settlement And Billing',	14000000	,	14000000	,	NULL	, NULL,1,	1,	184

 UNION ALL 
SELECT	10221099	, 'Run Settlement Calc',	10220000	,	14000000	,	NULL	, NULL,1,	1,	185

 UNION ALL 
SELECT	10221000	, 'Run Contract Settlement',	10221099	,	14000000	,	NULL	, 'windowMaintainInvoice',1,	0,	186

 UNION ALL 
SELECT	10222300	, 'Run Deal Settlement',	10221099	,	14000000	,	NULL	, 'windowRunSettlement',1,	0,	187

 UNION ALL 
SELECT	10221100	, 'Run Inventory Calc',	10221099	,	14000000	,	NULL	, 'windowRunInventoryCalc',1,	0,	188

 UNION ALL 
SELECT	10221300	, 'Settlement Calculation History',	10221099	,	14000000	,	NULL	, 'windowMaintainInvoiceHistory',1,	0,	189

 UNION ALL 
SELECT	10221999	, 'Run Settlement Report',	10221900	,	14000000	,	NULL	, NULL,1,	1,	190

 UNION ALL 
SELECT	10221900	, 'Run Settlement Report',	10221999	,	14000000	,	NULL	, 'windowSettlementReport',1,	0,	191

 UNION ALL 
SELECT	10221200	, 'Run Contract Settlement Report',	10221999	,	14000000	,	NULL	, 'windowBrokerFeeReport',1,	0,	192

 UNION ALL 
SELECT	10221800	, 'Run Settlement Production Report',	10221999	,	14000000	,	NULL	, 'windowSettlementProductionReport',1,	0,	193

 UNION ALL 
SELECT	10222400	, 'Run Meter Data Report',	10220000	,	14000000	,	NULL	, 'windowMeterDataReport',1,	0,	194

 UNION ALL 
SELECT	10221400	, 'Post JE Report',	10220000	,	14000000	,	NULL	, 'windowPostJEReport',1,	0,	195

 UNION ALL 
SELECT	10221600	, 'Settlement Adjustments',	10220000	,	14000000	,	NULL	, 'windowSettlementAdjustments',1,	0,	196

 UNION ALL 
SELECT	10221700	, 'Market Variance Report',	10220000	,	14000000	,	NULL	, 'windowMarketVarienceReport',1,	0,	197

 UNION ALL 
SELECT	10222000	, 'SAP Settlement Export',	10220000	,	14000000	,	NULL	, 'windowSAPSettlementExport',1,	0,	198

 UNION ALL 
SELECT	10230000	, 'Accounting Inventory',	14000000	,	14000000	,	NULL	, NULL,1,	1,	199

 UNION ALL 
SELECT	10231000	, 'Maintain Inventory GL Account',	10230000	,	14000000	,	NULL	, 'windowMaintainInventoryGLAccount',1,	0,	200

 UNION ALL 
SELECT	10231100	, 'Run Inventory Journal Entry Report',	10230000	,	14000000	,	NULL	, 'windowRunInventoryAccountReport',1,	0,	201

 UNION ALL 
SELECT	10231200	, 'Run Weighted Averag Inventory Cost Report',	10230000	,	14000000	,	NULL	, 'windowRunWghtInventoryCostReport',1,	0,	202

 UNION ALL 
SELECT	10162400	, 'Run Roll Forward Inventory Report',	10230000	,	14000000	,	NULL	, 'windowRunRollForwardInventoryReport',1,	0,	203

 UNION ALL 
SELECT	10237000	, 'Maintain Manual Journal Entries',	10230000	,	14000000	,	NULL	, 'windowMaintainManualJournalEntries',1,	0,	204

 UNION ALL 
SELECT	10237100	, 'Maintain Inventory Cost Override',	10230000	,	14000000	,	NULL	, 'windowInventoryCostOverride',1,	0,	205

 UNION ALL 
SELECT	10237200	, 'Run Inventory Calc',	10230000	,	14000000	,	NULL	, 'windowRunInventoryCalc',1,	0,	206

 UNION ALL 
SELECT	10230098	, 'Accounting derivative Accounting Srategy',	14000000	,	14000000	,	NULL	, NULL,1,	1,	207

 UNION ALL 
SELECT	10231900	, 'Setup Hedging Relationship Types',	10230098	,	14000000	,	NULL	, 'windowSetupHedgingRelationshipsTypes',1,	0,	208

 UNION ALL 
SELECT	10232000	, 'Run Hedging Relationship Types Report',	10230098	,	14000000	,	NULL	, 'windowRunSetupHedgingRelationshipsTypesReport',1,	0,	209

 UNION ALL 
SELECT	10101500	, 'Maintain Netting Asset/Liab Groups',	10230098	,	14000000	,	NULL	, 'windowMaintainNettingGroups',1,	0,	210

 UNION ALL 
SELECT	10230096	, 'Accounting derivative Hedge Effeciveness Test',	14000000	,	14000000	,	NULL	, NULL,1,	1,	211

 UNION ALL 
SELECT	10232300	, 'Run Assessment',	10230096	,	14000000	,	NULL	, 'windowRunAssessment',1,	0,	212

 UNION ALL 
SELECT	10232400	, 'View Assessment Results',	10230096	,	14000000	,	NULL	, 'windowViewAssessmentResults',1,	0,	213

 UNION ALL 
SELECT	10237300	, 'View/Update Cum PNL Series',	10230096	,	14000000	,	NULL	, 'windowViewUpdateCumPNLSeries',1,	0,	214

 UNION ALL 
SELECT	10232500	, 'Run Assessment Trend Graph',	10230096	,	14000000	,	NULL	, 'windowRunAssessmentTrendGraph',1,	0,	215

 UNION ALL 
SELECT	10232600	, 'Run What-If Effectiveness Analysis',	10230096	,	14000000	,	NULL	, 'windowRunWhatIfEffectivenessAnalysis',1,	0,	216

 UNION ALL 
SELECT	10230097	, 'Accounting derivative Deal Capture',	14000000	,	14000000	,	NULL	, NULL,1,	1,	217

 UNION ALL 
SELECT	10232700	, 'Import Data',	10230097	,	14000000	,	NULL	, 'windowImportData',1,	0,	218

 UNION ALL 
SELECT	10232800	, 'Run Import Audit Report',	10230097	,	14000000	,	NULL	, 'windowRunFilesImportAuditReport',1,	0,	219

 UNION ALL 
SELECT	10232900	, 'Maintain Missing Static Data',	10230097	,	14000000	,	NULL	, 'windowMaintainMissingStaticData',1,	0,	220

 UNION ALL 
SELECT	10233000	, 'Delete Voided Deal',	10230097	,	14000000	,	NULL	, 'windowVoidDealImports',1,	0,	221

 UNION ALL 
SELECT	10103000	, 'Define Meter IDs',	10230097	,	14000000	,	NULL	, 'windowDefineMeterID',1,	0,	222

 UNION ALL 
SELECT	10230095	, 'Accounting derivative Transaction Processing',	14000000	,	14000000	,	NULL	, NULL,1,	1,	223

 UNION ALL 
SELECT	10233700	, 'Designation of a Hedge',	10230095	,	14000000	,	NULL	, 'windowDesignationofaHedgeFromMenu',1,	0,	224

 UNION ALL 
SELECT	10233800	, 'De-Designation of a Hedge by FIFO/LIFO',	10230095	,	14000000	,	NULL	, 'windowDedesignateFifolifo',1,	0,	225

 UNION ALL 
SELECT	10233900	, 'Run Hedging Relationship Report',	10230095	,	14000000	,	NULL	, 'windowRunHedgeRelationshipReport',1,	0,	226

 UNION ALL 
SELECT	10234000	, 'Reclassify Hedge De-Designation',	10230095	,	14000000	,	NULL	, 'windowReclassifyDedesignationValues',1,	0,	227

 UNION ALL 
SELECT	10234100	, 'Amortize Deferred AOCI',	10230095	,	14000000	,	NULL	, 'windowAmortizeLockedAOCI',1,	0,	228

 UNION ALL 
SELECT	10234200	, 'Life Cycle of Hedges',	10230095	,	14000000	,	NULL	, 'windowLifecyclesOfHedges',1,	0,	229

 UNION ALL 
SELECT	10234300	, 'Automation of Forecasted Transaction',	10230095	,	14000000	,	NULL	, 'windowAutomationofForecastedTransaction',1,	0,	230

 UNION ALL 
SELECT	10234400	, 'Automate Matching of Hedges',	10230095	,	14000000	,	NULL	, 'windowAutomationMathingHedge',1,	0,	231

 UNION ALL 
SELECT	10234500	, 'View Outstanding Automation Results',	10230095	,	14000000	,	NULL	, 'windowViewOutstandingAutomationResults',1,	0,	232

 UNION ALL 
SELECT	10234600	, 'First Day Gain/Loss Treatment',	10230095	,	14000000	,	NULL	, 'windowFirstDayGainLoss',1,	0,	233

 UNION ALL 
SELECT	10234700	, 'Maintain Transactions Tagging',	10230095	,	14000000	,	NULL	, 'windowMaintainTransactionsTagging',1,	0,	234

 UNION ALL 
SELECT	10234800	, 'Bifurcation Of Embedded Derivatives',	10230095	,	14000000	,	NULL	, 'windowBifurcationEmbeddedDerivatives',1,	0,	235

 UNION ALL 
SELECT	10230094	, 'Accounting derivative Ongoing Assessment',	14000000	,	14000000	,	NULL	, NULL,1,	1,	236

 UNION ALL 
SELECT	10233200	, 'Run What-If Measurement Analysis',	10230094	,	14000000	,	NULL	, 'windowRunwhatifmeasurementana',1,	0,	237

 UNION ALL 
SELECT	10181000	, 'Run MTM',	10230094	,	14000000	,	NULL	, 'windowRunMtmCalc',1,	0,	238

 UNION ALL 
SELECT	10233300	, 'Copy Prior MTM Value',	10230094	,	14000000	,	NULL	, 'windowPriorMTM',1,	0,	239

 UNION ALL 
SELECT	10233400	, 'Run Measurement',	10230094	,	14000000	,	NULL	, 'windowRunMeasurement',1,	0,	240

 UNION ALL 
SELECT	10233500	, 'Run Calc Embedded Derivative',	10230094	,	14000000	,	NULL	, 'windowCalcEmbedded',1,	0,	241

 UNION ALL 
SELECT	10233600	, 'Close Accounting Period',	10230094	,	14000000	,	NULL	, 'windowCloseMeasurement',1,	0,	242

 UNION ALL 
SELECT	10230093	, 'Accounting derivative Reporting',	14000000	,	14000000	,	NULL	, NULL,1,	1,	243

 UNION ALL 
SELECT	10234900	, 'Run Measurement Report',	10230093	,	14000000	,	NULL	, 'windowRunMeasurementReport',1,	0,	244

 UNION ALL 
SELECT	10235000	, 'Run Measurement Trend Graph',	10230093	,	14000000	,	NULL	, 'windowRunMeasurementTrendGraph',1,	0,	245

 UNION ALL 
SELECT	10235100	, 'Run Period Change Values Report',	10230093	,	14000000	,	NULL	, 'windowPeriodChangeValueReport',1,	0,	246

 UNION ALL 
SELECT	10235200	, 'Run AOCI Report',	10230093	,	14000000	,	NULL	, 'windowAOCIReport',1,	0,	247

 UNION ALL 
SELECT	13160000	, 'Run Hedging Relationship Audit Report',	10230093	,	14000000	,	NULL	, 'windowHedgingRelationshipReport',1,	0,	248

 UNION ALL 
SELECT	10235300	, 'Run De-Designation Values Report',	10230093	,	14000000	,	NULL	, 'windowDedesignateReport',1,	0,	249

 UNION ALL 
SELECT	10235400	, 'Run Journal Entry Report',	10230093	,	14000000	,	NULL	, 'windowRunJournalEntryReport',1,	0,	250

 UNION ALL 
SELECT	10235500	, 'Run Netted Journal Entry Report',	10230093	,	14000000	,	NULL	, 'windowRunNettedJournalEntryReport',1,	0,	251

 UNION ALL 
SELECT	10234900	, 'Run Hedge Cashflow Deferral Report',	10230093	,	14000000	,	NULL	, 'windowRunHedgeCashflowDeferral',1,	0,	252

 UNION ALL 
SELECT	10230092	, 'Run Disclosure Report',	10230093	,	14000000	,	NULL	, NULL,1,	1,	253

 UNION ALL 
SELECT	10235600	, 'Run Accounting Disclosure Report',	10230092	,	14000000	,	NULL	, 'windowRunDisclosureReport',1,	0,	254

 UNION ALL 
SELECT	10235700	, 'Run Fair Value Disclosure Report',	10230092	,	14000000	,	NULL	, 'windowRunnetAssetsReport',1,	0,	255

 UNION ALL 
SELECT	10235800	, 'Run Assessment Report',	10230093	,	14000000	,	NULL	, 'windowRunAssessmentReport',1,	0,	256

 UNION ALL 
SELECT	10235900	, 'Run Transaction Report',	10230093	,	14000000	,	NULL	, 'windowRunDealReport',1,	0,	257

 UNION ALL 
SELECT	10236000	, 'Run Tagging Export',	10230093	,	14000000	,	NULL	, 'windowTaggingExport',1,	0,	258

 UNION ALL 
SELECT	10230091	, 'Run Exception Report',	10230093	,	14000000	,	NULL	, NULL,1,	1,	259

 UNION ALL 
SELECT	10236100	, 'Run Missing Assessment Values Report',	10230091	,	14000000	,	NULL	, 'windowRunMissingAssessmentValuesReport',1,	0,	260

 UNION ALL 
SELECT	10236200	, 'Run Failed Assessment Values Report',	10230091	,	14000000	,	NULL	, 'windowRunFailAssessmentValuesReport',1,	0,	261

 UNION ALL 
SELECT	10236300	, 'Run Unapproved Hedging Relationship Exception Report',	10230091	,	14000000	,	NULL	, 'windowRunUnapprovedHedgingRelationshipExceptionReport',1,	0,	262

 UNION ALL 
SELECT	10236400	, 'Run Available Hedge Capacity Exception Report',	10230091	,	14000000	,	NULL	, 'windowRunAvailableHedgeCapacityExceptionReport',1,	0,	263

 UNION ALL 
SELECT	10236500	, 'Run Not Mapped Transaction Report',	10230091	,	14000000	,	NULL	, 'windowRunNotMappedDealReport',1,	0,	264

 UNION ALL 
SELECT	10236600	, 'Run Tagging Audit Report',	10230091	,	14000000	,	NULL	, 'windowRunTaggingAuditReport',1,	0,	265

 UNION ALL 
SELECT	10236700	, 'Run Hedge and Item Position Matching Report',	10230091	,	14000000	,	NULL	, 'windowHedgeItemMatchExceptRpt',1,	0,	266

 UNION ALL 
SELECT	10201000	, 'Report Writer',	10230093	,	14000000	,	NULL	, 'windowreportwriter',1,	0,	267

 UNION ALL 
SELECT	10230099	, 'Accounting Accural',	14000000	,	14000000	,	NULL	, NULL,1,	1,	268

 UNION ALL 
SELECT	10231500	, 'Curve Value Report',	10230099	,	14000000	,	NULL	, 'windowCurveValueReport',1,	0,	269

 UNION ALL 
SELECT	10231600	, 'Run Revenue Report',	10230099	,	14000000	,	NULL	, 'windowRevenueReport',1,	0,	270

 UNION ALL 
SELECT	10231700	, 'Run Accrual Journal Entry Report',	10230099	,	14000000	,	NULL	, 'windowRunInventoryJournalEntryReport',1,	0,	271

 UNION ALL 
SELECT	10231800	, 'Run EQR Report',	10230099	,	14000000	,	NULL	, 'windowRunEQRReport',1,	0,	272

 UNION ALL 
SELECT	10240000	, 'Treasury',	14000000	,	14000000	,	NULL	, NULL,1,	1,	273

 UNION ALL 
SELECT	10241000	, 'Reconcile Cash Entries for Derivatives',	10240000	,	14000000	,	NULL	, 'windowReconcileCashEntriesDerivatives',1,	0,	274

 UNION ALL 
SELECT	10241100	, 'Apply Cash',	10240000	,	14000000	,	NULL	, 'windowApplyCash',1,	0,	275


--SELECT * FROM setup_menu