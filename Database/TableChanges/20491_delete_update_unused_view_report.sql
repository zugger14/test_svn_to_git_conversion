Create Table #multiple_param_hash (rnk int, name VARCHAR(500) COLLATE DATABASE_DEFAULT, report_hash VARCHAR(500) COLLATE DATABASE_DEFAULT, report_id int)

Insert into #multiple_param_hash
select a.* from (select ROW_NUMBER() over(partition by report_hash order by report_hash) rnk 
, name, report_hash, report_id
from report
) a
where rnk > 1
order by 1 desc,3 

Create Table #multiple_param_hash_reports
(report_id int)

Insert into #multiple_param_hash_reports
select r.report_id from #multiple_param_hash mph
LEFT JOIN report r on r.report_hash = mph.report_hash 

delete fd
from application_ui_filter_details fd
inner join application_ui_filter f on f.application_ui_filter_id = fd.application_ui_filter_id
where f.report_id in (select report_id from #multiple_param_hash_reports)

delete f
from application_ui_filter f
WHERE f.report_id in (select report_id from #multiple_param_hash_reports)

CREATE TABLE #report_paramset (dataset_id int)
INSERT INTO  #report_paramset
SELECT report_dataset_id from report_dataset rd where  rd.report_id in(select * from #multiple_param_hash_reports)

DELETE rp from report_param rp where rp.dataset_id IN (select * from #report_paramset)

DELETE FROM report_chart_column where dataset_id IN (select * from #report_paramset)

DELETE FROM report_tablix_column where dataset_id IN (select * from #report_paramset) or report_tablix_column.tablix_id in (select report_page_tablix_id from report_page_tablix where root_dataset_id in  (select * from #report_paramset))

DELETE FROM report_page_chart where root_dataset_id IN (select * from #report_paramset) 

DELETE FROM report_page_tablix where root_dataset_id IN (select * from #report_paramset) 

DELETE FROM report_dataset_paramset where root_dataset_id IN (select * from #report_paramset) 

DELETE FROM report_dataset_relationship where dataset_id  IN (select * from #report_paramset) 

DELETE FROM report_dataset where report_dataset_id IN (select * from #report_paramset) 

drop table #multiple_param_hash
drop table #multiple_param_hash_reports
drop table #report_paramset


IF OBJECT_ID('tempdb..#delete_Report') IS NOT NULL
	DROP TABLE #delete_Report
CREATE TABLE #delete_Report (Report_name VARCHAR(500) COLLATE DATABASE_DEFAULT)
INSERT INTO #delete_Report (Report_name)

Select ('Deal Reconciliation Report') UNION ALL
Select ('Deal Details Reports') UNION ALL
Select ('Deal Detail Report') UNION ALL
Select ('PNL Charge Type Report') UNION ALL
Select ('PNL Report') UNION ALL
Select ('Forecast Actual Report') UNION ALL
Select ('Price Curve Plot') UNION ALL
Select ('Time Series Report') UNION ALL
Select ('Cash Flow Report Old') UNION ALL
Select ('Meter Data Report') UNION ALL
--Select ('Counterparty Collateral Inventory Report') UNION ALL
Select ('Deal Settlement Detail Report') UNION ALL
Select ('Deal Extract Report') UNION ALL
Select ('Deal Audit Trail Detail Report') UNION ALL
Select ('MTM Fees Extract Report') UNION ALL
Select ('Deal Settlement Report') UNION ALL
Select ('Price Export Report') UNION ALL
Select ('EoD Trade Report') UNION ALL
Select ('Hourly Position Summary Report') UNION ALL
Select ('Daily Position Extract Report') UNION ALL
Select ('Monthly Position Extract Report') UNION ALL
Select ('Monthly Position Summary Report') UNION ALL
Select ('Power ToU Position Report') UNION ALL
Select ('Delta Position Report') UNION ALL
Select ('Position Change Report') UNION ALL
Select ('Delta Position Monthly Report') UNION ALL
Select ('MTM Extract Report') UNION ALL
Select ('MTM Report by Trader') UNION ALL
Select ('MTM Report by Book') UNION ALL
Select ('MTM Report by Counterparty') UNION ALL
Select ('MTM Report by Charges') UNION ALL
Select ('Deal Settlement Extract Report') UNION ALL
Select ('Deal Settlement Report by Book') UNION ALL
Select ('Deal Settlement Report by Counterparty') UNION ALL
Select ('Cash Flow Report') UNION ALL
Select ('Earning Report') UNION ALL
Select ('Realized Unrealized PNL Report') UNION ALL
Select ('Realized Unrealized Detail Report') UNION ALL
Select ('MTM Settlement Extract Report') UNION ALL
Select ('MTM Change Report') UNION ALL
Select ('Contract Settlement Report') UNION ALL
Select ('PNL Attribution Report') UNION ALL
Select ('Position Attribution Report') UNION ALL
--Select ('Counterparty Collateral Inventory Report') UNION ALL
Select ('Counterparty Detail Report') UNION ALL
Select ('Credit Reserve Report') UNION ALL
Select ('Credit Value Adjustment Report') UNION ALL
Select ('Cash Collateral Balance Report') UNION ALL
Select ('AR Aging Report') UNION ALL
Select ('PFE Report') UNION ALL
Select ('Default Recovery Rate Report') UNION ALL
Select ('Default Probability Report') UNION ALL
Select ('Counterparty Limit Report') UNION ALL
Select ('Options Greeks Report') UNION ALL
Select ('Eigen Values Report') UNION ALL
Select ('Eigen Vectors Report') UNION ALL
Select ('Expected Return Change Report') UNION ALL
Select ('Expected Return Report') UNION ALL
Select ('Implied Volatility Report') UNION ALL
Select ('Daily Position Summary Report') UNION ALL
Select ('Hourly Position Extract Report') UNION ALL 
Select ('Deal Report') UNION ALL
Select ('Buy Sell Position Report') UNION ALL
Select ('Detail MTM Report Mobile') UNION ALL
Select ('Counterparty Exposure Concentration') UNION ALL
Select ('Custom Report') UNION ALL
Select ('Cycle based Deal Summary Report') UNION ALL
Select ('Disclosure Counterparty Exposure Report by Rating') UNION ALL
Select ('Disclosure Counterparty Exposure Report by Tenor') UNION ALL
Select ('Disclosure Counterparty Exposure Reports') UNION ALL
Select ('EndUser report') UNION ALL
Select ('EOD Report') UNION ALL
Select ('Financial Position Pivot') UNION ALL
Select ('Flash Report Monthly') UNION ALL
Select ('Fuel Clause  Report') UNION ALL
Select ('Fuel Clause Batch Report') UNION ALL
Select ('Gas Buy by Seller by Facility Plant') UNION ALL
Select ('Gas Derivatives Positions') UNION ALL
Select ('Gas Financial Hedge Report') UNION ALL
Select ('Gas Physical Hedge Report') UNION ALL
Select ('Gas Purchase Transportation Reconciliation Report') UNION ALL
Select ('Gas Sell by Buyer by Counterparty Report') UNION ALL
Select ('Initial Statement for Gas') UNION ALL
Select ('Initial Statement for Power') UNION ALL
Select ('Invoice Purchase Sales Reports') UNION ALL
Select ('Liability Reserve Report') UNION ALL
Select ('LNG sales') UNION ALL
Select ('MTM Change Report By Commodity') UNION ALL
Select ('MTM Deal Summary Report') UNION ALL
Select ('MTM Forward Report') UNION ALL
Select ('MTM PeopleSoft Report') UNION ALL
Select ('MTM Report') UNION ALL
Select ('Netting Report') UNION ALL
Select ('New Forward Trade Report') UNION ALL
Select ('PNL and MTM Report by Strategy') UNION ALL
Select ('Power financial swap report') UNION ALL
Select ('Production Forecast Report') UNION ALL
Select ('Purchase and Sales MLGW') UNION ALL
Select ('Rules 570 Real Time Purchase Report') UNION ALL
Select ('Sales and Purchase Summary') UNION ALL
Select ('Scheduled Deal Detail Report') UNION ALL
Select ('Supplier Report') UNION ALL
Select ('Trading Tracker') UNION ALL
Select ('WACOG reports') UNION ALL
Select ('Yearly MTM by Book') UNION ALL
Select ('Yearly PnL Change Summary Report') UNION ALL
Select ('Zai net Comparison Report') UNION ALL
Select ('Deal Detail') UNION ALL
Select ('Option Greeks Report') UNION ALL
Select ('test data') UNION ALL
Select ('test') UNION ALL
Select ('Detail MTM Report') UNION ALL
Select ('Counterparty Exposure Concentration by Commodity') UNION ALL
Select ('Test Report HR') UNION ALL
Select ('Copy of Detail Position Report') UNION ALL
Select ('Detail Position Report') UNION ALL 
Select ('Copy of Deal Detail Report for Training') UNION ALL
Select ('Copy of Net') UNION ALL
Select ('Copy of PnL Attribution') UNION ALL
Select ('Copy of credit Exposure Summary') UNION ALL
Select ('Copy of Detail Position Report') UNION ALL
Select ('Power Price Curve Report1') UNION ALL
Select ('Price Curve Report1') UNION ALL
Select ('Price Curve Report1') UNION ALL
Select ('Deal Standard Report PNL 01') UNION ALL
Select ('Deal11') UNION ALL
Select ('Deal12') UNION ALL
Select ('Position Report with New View1') UNION ALL
Select ('Position Report with New View') UNION ALL
Select ('Position Report Crosstab New') UNION ALL
Select ('Position Report with New View') UNION ALL
Select ('Position Report by Book New') UNION ALL
Select ('Daily Position Report New') UNION ALL
Select ('New Standard MTM Report by Charges') UNION ALL

Select ('Approved and Active Counterparty List for Trader') UNION ALL
Select ('Approved Counterparty') UNION ALL
Select ('Asset and Liabilities Report by CPTY') UNION ALL
Select ('At Risk Change Summary Report') UNION ALL
Select ('Accrual JE Report') UNION ALL
Select ('Book Mapping Report unmapped') UNION ALL
Select ('Bridge_Mengen') UNION ALL
Select ('Broker Fees Report') UNION ALL
Select ('Credit Exposure Report Old') UNION ALL
Select ('Counterparty Credit Info Report') UNION ALL
Select ('Counterparty Volume Graph') UNION ALL
Select ('Capacity Usage') UNION ALL
Select ('Commodity Shift') UNION ALL
Select ('Counterparty Certificate') UNION ALL
Select ('Counterparty Payment Report') UNION ALL
Select ('Counterparty Product') UNION ALL
Select ('Credit Exposure Report by Contract') UNION ALL
Select ('Credit Exposure Report') UNION ALL
Select ('Credit Risk Report') UNION ALL
Select ('Credit Risk Tracker') UNION ALL
Select ('Customer Cash Receipt') UNION ALL
Select ('Combined Report') UNION ALL
Select ('Credit Exp Report') UNION ALL
Select ('Credit Exposure Dashboard') UNION ALL
Select ('Credit Migration Margin Report To Counterparty') UNION ALL
Select ('Cost Calc Detail Export') UNION ALL
Select ('Credit Migration Margin Report By Counterparty') UNION ALL
Select ('Cash Flow Report by Deal') UNION ALL
Select ('credit Exposure Summary') UNION ALL
Select ('Component VaR Report Term Wise') UNION ALL
Select ('Detailed Measurement Report MTM for Credit Prov') UNION ALL
Select ('Deal Detail View Report') UNION ALL
Select ('Detailed Measurement Report ContiPower VP') UNION ALL
Select ('Deal Price Report') UNION ALL
Select ('Deal Report_Updated_Konstantin') UNION ALL
Select ('Daily MTM Change Report') UNION ALL
Select ('Daily MTM Change Report') UNION ALL
Select ('Demand Supply Report') UNION ALL
Select ('Deal Level Report') UNION ALL
Select ('Daily Dashboard') UNION ALL
Select ('Deal Standard Report PNL 02') UNION ALL
Select ('Daily Forward Power Price Difference Report') UNION ALL
Select ('Daily Gas Position Change Report') UNION ALL
Select ('Daily Gas Price Difference Report') UNION ALL
Select ('Daily Power Position Change Report') UNION ALL
Select ('Deal Summary by Fees Report') UNION ALL
Select ('DST Position and Settlement') UNION ALL
Select ('Detailed Settlement Report_LB') UNION ALL
Select ('Daily Position Report') UNION ALL
Select ('Deal Volume Report') UNION ALL
Select ('Deal Audit Trail Summary Report') UNION ALL
Select ('Deal Settlement Report PNL') UNION ALL
Select ('Deal Test March') UNION ALL
Select ('Deal Detail Report for Training') UNION ALL
Select ('Deal Test Report') UNION ALL
Select ('Effectiveness Report') UNION ALL
Select ('Email Sent Status Report') UNION ALL
Select ('Energy Analysis Report') UNION ALL
Select ('Equity Position Report') UNION ALL
Select ('Equity Supply Position Report') UNION ALL
Select ('FX Ineffectiveness Report') UNION ALL
Select ('Failed Effectiveness Report') UNION ALL
Select ('FAS Journal Entry Report') UNION ALL
Select ('FAS Measurement Report') UNION ALL
Select ('FAS MTM Report') UNION ALL
Select ('FAS Netted Journal Entry Report') UNION ALL
Select ('FX Ineffectiveness Detail Report') UNION ALL
Select ('FX Ineffectiveness Summary Report') UNION ALL
Select ('Gas Price Curve Report') UNION ALL
Select ('Gas Accounting Report by Plant') UNION ALL
Select ('Gas Journal Entry Report by Account') UNION ALL
Select ('Gas Position Report by Book') UNION ALL
Select ('Gas Transport Checkout Report by facility contract') UNION ALL
Select ('Generation MTM Report') UNION ALL
Select ('Generation Position') UNION ALL
Select ('Gas Position Report  by Exposure Type') UNION ALL
Select ('Gas Position Report Questar') UNION ALL
Select ('Hedge Capacity Exception Report') UNION ALL
Select ('Hourly Position Detail Extract Report') UNION ALL
Select ('Hedge Position Report') UNION ALL
Select ('Hourly Position Report') UNION ALL
Select ('Intra Month Trade Compliance Report') UNION ALL
Select ('Inventory Value') UNION ALL
Select ('Level 3 Disclosure Report') UNION ALL
Select ('List of Products Report') UNION ALL
Select ('LT Cost Position Report') UNION ALL
Select ('MTM Summary Report MDV') UNION ALL
Select ('Market Risk Report') UNION ALL
Select ('Montlhy Position Report with Graph') UNION ALL
Select ('Market Risk Report Detail') UNION ALL
Select ('Market Curve') UNION ALL
Select ('Market Curve Report A') UNION ALL
Select ('Margin Statement for Credit Rating Migration') UNION ALL
Select ('Market Place Position Report') UNION ALL
Select ('Market Place Postion 15 Min Report') UNION ALL
Select ('MTM Accounting vs AOCI') UNION ALL
Select ('MTM Asset and Liabilities Report') UNION ALL
Select ('MTM Assets and Liabilities Report by Counterparty') UNION ALL
Select ('MTM Assets and Liabilities Report by Deal') UNION ALL
Select ('MTM by Charges') UNION ALL
Select ('MTM by Deal') UNION ALL
Select ('MTM by Trader') UNION ALL
Select ('MTM Detail Report') UNION ALL
Select ('MTM Detailed Extract') UNION ALL
Select ('MTM Pivot Report') UNION ALL
Select ('MTM Report by Deal') UNION ALL
Select ('MTM Report Demo') UNION ALL
Select ('MTM Roll Forward Report') UNION ALL
Select ('MTM Summary Report by Term') UNION ALL
Select ('Monthly Physical Position') UNION ALL
Select ('Monthly Position Report') UNION ALL
Select ('MMWEC Meter Data Report') UNION ALL
Select ('MMWEC Price Report') UNION ALL
Select ('MMWEC Fee Settement Report') UNION ALL
Select ('Multiple Scenario WhatIf MTM Report') UNION ALL
Select ('MTM by Counterparty') UNION ALL
Select ('MTM By Book') UNION ALL
Select ('Northpool Position Report') UNION ALL
Select ('Non EFET Detailed Settlement Report') UNION ALL
Select ('NFC PnL Sensitivities Report') UNION ALL
Select ('Nom Audit Report') UNION ALL
Select ('Net') UNION ALL
Select ('Oil Position') UNION ALL
Select ('Operations Cost Position Report') UNION ALL
Select ('Price Curve Report') UNION ALL
Select ('Position 15mins Report') UNION ALL
Select ('Position Report Mobile') UNION ALL
Select ('Payable Export') UNION ALL
Select ('Physical Position Pivot') UNION ALL
Select ('PNL Pivot Report') UNION ALL
Select ('PNL Report by Deal') UNION ALL
Select ('PNL Report Demo') UNION ALL
Select ('PnL Sensitivities Report') UNION ALL
Select ('Position Attribution') UNION ALL
Select ('Position Deal Level Report') UNION ALL
Select ('Position Hourly Report Tablix') UNION ALL
Select ('Position Report with Block Type') UNION ALL
Select ('Power Hourly Position Report by Book') UNION ALL
Select ('Price Curve Tablix') UNION ALL
Select ('Price Report') UNION ALL
Select ('Purchase Power Report') UNION ALL
Select ('PnL Attribution') UNION ALL
Select ('Price Curve System Report') UNION ALL
Select ('Position Extract Report') UNION ALL
Select ('Position Hourly Report') UNION ALL
Select ('Sales for Resale Power Reports') UNION ALL
Select ('Sales Vs Sourcing Dashboard') UNION ALL
Select ('Send Invoice Email Log Report') UNION ALL
Select ('Shut In Detail') UNION ALL
Select ('Sourcing Contracts') UNION ALL
Select ('Standard PNL Report') UNION ALL
Select ('Storage Position') UNION ALL
Select ('static data UDF') UNION ALL
Select ('Standard Forecast Actual Report') UNION ALL
Select ('Standard Price Curve Plot') UNION ALL
Select ('Standard Time Series Report') UNION ALL
Select ('Standrad Price Curve Plot') UNION ALL
Select ('ST Forecast Vs LT Forecast Report') UNION ALL
Select ('Standard Cash Flow Report Old') UNION ALL
Select ('Standard Meter Data Report') UNION ALL
Select ('Standard Counterparty Collateral Inventory Report') UNION ALL
Select ('Standard Deal Settlement Detail Report') UNION ALL
Select ('Standard Deal Settlement Report') UNION ALL
Select ('Standard Price Export Report') UNION ALL
Select ('Standard Counterparty Collateral Inventory Report') UNION ALL
Select ('SSIS Error Log Report') UNION ALL 
Select ('Trade Activity Daily Report') UNION ALL
Select ('True Up Report') UNION ALL
Select ('Transaction Export Report') UNION ALL
Select ('ToU Position Report') UNION ALL
Select ('Test Standard Cash Collateral Balance  Report') UNION ALL
Select ('Test Report RR') UNION ALL
Select ('Unit Availability Report') UNION ALL
Select ('Var Cost Master Report') UNION ALL
Select ('VaR Limit Report') UNION ALL
Select ('VaR Limit Report in MMs') UNION ALL
Select ('Weather Data Report') UNION ALL
Select ('Wellhead Setup and Volume Report') UNION ALL
Select ('Wellhead Volume Report') UNION ALL
Select ('WINDVISION Invoicing') UNION ALL
Select ('WINDVISION Result')UNION ALL
Select ('x_TEST_Volkhardt Aufstellung mtm_ALL')UNION ALL
Select ('Yearly Position Change by Commodity')UNION ALL
Select ('Large Report') UNION ALL
Select ('Questline Nomination Report') UNION ALL
Select ('Standard AR Aging Report') UNION ALL
Select ('12 Months Avg Price Change Report') UNION ALL
Select ('Run Purge Process') UNION ALL
Select ('Questline Nomination Report')  UNION ALL
SELECT ('test deal') UNION ALL
SELECT ('Report Name') UNION ALL
SELECT ('Report Paramset')UNION ALL 
SELECT('Report with large data test') UNION ALL
SELECT('Dataset Test')UNION ALL
SELECT('Dataset Enh Testing')UNION ALL
SELECT('What if Analysis Report Pivot') 

IF OBJECT_ID('tempdb..#delete_Report_confirm') IS NOT NULL
DROP TABLE #delete_Report_confirm
		CREATE TABLE #delete_Report_confirm  (report_id VARCHAR(500) COLLATE DATABASE_DEFAULT, name VARCHAR(500) COLLATE DATABASE_DEFAULT)
INSERT INTO #delete_Report_confirm 
		SELECT report_id, name from Report where name in (select Report_name from #delete_Report)

IF CURSOR_STATUS('local','Report_delete') > = -1
		BEGIN
			DEALLOCATE Report_delete
		END

		DECLARE Report_delete CURSOR LOCAL FOR
		
		SELECT report_id
		FROM   #delete_Report_confirm  
		DECLARE @report_id varchar(100)
		
		OPEN Report_delete 
		FETCH NEXT FROM Report_delete 
		INTO @report_id
		WHILE @@FETCH_STATUS = 0
		BEGIN			
			EXEC spa_rfx_report_dhx  @flag='d',@report_id = @report_id, @process_id=NULL		
		FETCH NEXT FROM Report_delete INTO @report_id
		END
		CLOSE Report_delete
		DEALLOCATE Report_delete

IF OBJECT_ID('tempdb..#save_View') IS NOT NULL
	DROP TABLE #save_View
CREATE TABLE #save_View (View_name VARCHAR(500) COLLATE DATABASE_DEFAULT)
INSERT INTO #save_View (View_name)


Select ('Price Curve View') UNION ALL
Select ('At Risk View') UNION ALL
Select ('Limit View') UNION ALL
Select ('Delta Monthly Position View') UNION ALL
Select ('Volatility View') UNION ALL
Select ('Correlation View') UNION ALL
Select ('Deal Audit Detail View') UNION ALL
Select ('UDF Crosstab view') UNION ALL
Select ('Deal Audit View') UNION ALL
Select ('Multiple Scenario Shift View') UNION ALL
Select ('Time Series View') UNION ALL
Select ('AR Aging View') UNION ALL
Select ('Position View') UNION ALL
Select ('Position Detail View') UNION ALL
Select ('Deal Detail View') UNION ALL
Select ('MTM Detail View') UNION ALL
Select ('Counterparty Limit View') UNION ALL
Select ('MTM Fees View') UNION ALL
Select ('Deal Settlement Detail View') UNION ALL
Select ('Credit Detail View') UNION ALL
Select ('Credit Exposure Summary View') UNION ALL
Select ('Settlement Mega View') UNION ALL
Select ('Contract Settlement View') UNION ALL
Select ('Static Data UDF View') UNION ALL
Select ('Actual Forecast View') UNION ALL
Select ('Settlement Lower Granularity View') UNION ALL
Select ('MTM Lower Granularity View') UNION ALL
Select ('Counterparty Collateral View') UNION ALL
Select ('Counterparty Detail View') UNION ALL
Select ('Whatif Analysis View') UNION ALL
Select ('Option Greeks Detail View') UNION ALL
Select ('Cash Collateral Balance View') UNION ALL
Select ('PNL Attribution View') UNION ALL
Select ('MTM Detailed Mega View') UNION ALL
Select ('Option Greeks Detail Value') UNION ALL
Select ('Expected Return View') UNION ALL
Select ('Implied Volatility View') UNION ALL
Select ('Simulated Prices View') UNION ALL
Select ('At Risk PFE View') UNION ALL
Select ('Cholesky Decomposition View') UNION ALL
Select ('Eigen Decomposition View') UNION ALL
Select ('Default Probability View') UNION ALL
Select ('Default Recovery Rate View') UNION ALL
Select ('CVA View') UNION ALL
Select ('Credit Reserve View') UNION ALL
Select ('MTM by Charge View') UNION ALL
Select ('MTM View') UNION ALL
Select ('Deal Settlement View') UNION ALL

Select ('Deal Header View') UNION ALL
Select ('Deal Detail View') UNION ALL
Select ('MTM_chart') UNION ALL
Select ('MTM_Chart') UNION ALL
Select ('Position_Tablix') UNION ALL
Select ('price_curve_chart') UNION ALL
Select ('MTM_chart') UNION ALL
Select ('MTM_Chart') UNION ALL
Select ('Actual_vs_Forward_Position_View') UNION ALL
Select ('sourcedealheader') UNION ALL
Select ('cs_ds') UNION ALL
Select ('vcvvvv') UNION ALL
Select ('SampleZeroTest') UNION ALL
Select ('dsrc_erp') UNION ALL
Select ('sample_multiple') UNION ALL
Select ('gauge_scale') UNION ALL
Select ('deal_header_link') UNION ALL
Select ('hyperlink test') UNION ALL
Select ('testing m') UNION ALL
Select ('inner join') UNION ALL
Select ('sql_mtm_view_all') UNION ALL
Select ('sql_mtm_view_book') UNION ALL
Select ('sql_cev_view') UNION ALL
Select ('combined view') UNION ALL
Select ('mtm view using between') UNION ALL
Select ('test  required') UNION ALL
Select ('MTM_Range') UNION ALL
Select ('source_deal_header') UNION ALL
Select ('sql view used') UNION ALL
Select ('deal detail view  sql') UNION ALL
Select ('combined view') UNION ALL
Select ('vcvvvv') UNION ALL
Select ('vcvvvv') UNION ALL
Select ('m_compo') UNION ALL
Select ('Column and line') UNION ALL
Select ('SQL-View') UNION ALL
Select ('Top 10 Credit Exposure View') UNION ALL
Select ('MTM View') UNION ALL
Select ('tt') UNION ALL
Select ('UDF View') UNION ALL
Select ('Position View Monthly') UNION ALL
Select ('Position View Daily') UNION ALL
Select ('Position View Hourly') UNION ALL
Select ('Delta Hourly Position') UNION ALL
Select ('Deal Settlement View') UNION ALL
Select ('Credit Reserve View') UNION ALL
Select ('What If View') UNION ALL
Select ('What If PFE') UNION ALL
Select ('User Roles Privileges View') UNION ALL
Select ('Static Data Export View') UNION ALL
Select ('Recovery Rate View') UNION ALL
Select ('Price Curve Change View') UNION ALL
Select ('Marginal Var View') UNION ALL
Select ('Expected Return View') UNION ALL
Select ('Default Probability View') UNION ALL
Select ('CVA Simulation View') UNION ALL
Select ('Counterparty Products View') UNION ALL
Select ('Counterparty Credit Info') UNION ALL
Select ('Counterparty Collateral View') UNION ALL
Select ('At Risk PFE View') UNION ALL
Select ('Counterparty Contract View') UNION ALL
Select ('Counterparty Information View') UNION ALL
Select ('Deal Audit Change Summary View') UNION ALL
Select ('Generic Mapping View') UNION ALL
Select ('Settlement Lower Granularity View') UNION ALL
Select ('MTM Fees View - Rename') UNION ALL
Select ('MTM Lower Granularity View') UNION ALL
Select ('Credit Exposure View O') UNION ALL
Select ('Contract Settlement Detail View') UNION ALL
Select ('Contract Settlement Summary View') UNION ALL 
Select ('[adiha_process].[dbo].[report_export_DH_exp_test]') UNION ALL
Select ('CVA View') UNION ALL
Select ('DST Shift Position View') UNION ALL
Select ('[adiha_process].[dbo].[batch_export_Source_Counterparty]') UNION ALL
Select ('DST Shift Settlement View') UNION ALL
Select ('Simulated Prices View') UNION ALL
Select ('Scheduled Deal Detail Report') UNION ALL
Select ('Commodity Shift View') UNION ALL
Select ('A/R Aging View') UNION ALL
Select ('Journal Entry View') UNION ALL
Select ('VaR Limit View') UNION ALL
Select ('Scheduled Deal Detail View') UNION ALL
Select ('Position View Hourly With Block Type') UNION ALL
Select ('Location View') UNION ALL
Select ('Imbalance View') UNION ALL
Select ('Price Curve Def View') UNION ALL
Select ('MTM View with Block Type') UNION ALL
Select ('Credit Exposure View') UNION ALL
Select ('Credit Value Adjustment View') UNION ALL
Select ('Credit Exposure View New') UNION ALL
Select ('Contract Detail Info View') UNION ALL
Select ('Counterparty Address View') UNION ALL
Select ('Delivery Path View') UNION ALL
Select ('Counterparty Payable View') UNION ALL
Select ('Position View Quaterly') UNION ALL
Select ('Capacity Use View') UNION ALL
Select ('Capacity Usage Deal View') UNION ALL
Select ('Price Curve View Demo') UNION ALL
Select ('Deal Detail View Demo') UNION ALL
Select ('Credit Exposure View Demo') UNION ALL
Select ('Credit Reserve View Demo') UNION ALL
Select ('MTM View Demo') UNION ALL
Select ('Position View Daily Demo') UNION ALL
Select ('Deal Settlement PNL View Demo') UNION ALL
Select ('Deal Header View Demo') UNION ALL
Select ('Deal Settlement Detail View') UNION ALL
Select ('Position View Monthly Delta_Demo') UNION ALL
Select ('Position view hourly with blocktype delta_Demo') UNION ALL
Select ('Deal Settlement Pivot View') UNION ALL
Select ('MTM Pivot View') UNION ALL
Select ('Position Daily Pivot View') UNION ALL
Select ('PCCV1') UNION ALL
Select ('Position View Hourly With Block Type Pivot') UNION ALL
Select ('Position Hourly View') UNION ALL
Select ('Position View New') UNION ALL
Select ('Position View 15min') UNION ALL
Select ('Purge Process') UNION ALL
Select ('Email Status View') UNION ALL
Select ('Counterparty Payment Info View') UNION ALL
Select ('Send Invoice Log View') UNION ALL
Select ('Accural JE View') UNION ALL
Select ('Optimizer position View1') UNION ALL
Select ('Position Hourly Detail View') UNION ALL
Select ('Position Monthly View') UNION ALL
Select ('MTM Detail Export View') UNION ALL
Select ('Credit Risk View') UNION ALL
Select ('PNL_Explain_View') UNION ALL
Select ('application_users') UNION ALL
Select ('Average Unit Availability') UNION ALL
Select ('Unit Avail View') UNION ALL
Select ('MTM Asset and Liability View') UNION ALL
Select ('Option Greeks Detail View') UNION ALL
Select ('DealDetailViewNew') UNION ALL
Select ('Deal Detail View New') UNION ALL
Select ('Deal Settlement PNL View') UNION ALL
Select ('generic mapping sql') UNION ALL
Select ('Whatif Analysis View') UNION ALL
Select ('Cholesky Decomposition') UNION ALL
Select ('Eigen Decomposition') UNION ALL
Select ('Cash Flow View') UNION ALL
Select ('MTM Assets and Liabilities Couterparty SQL') UNION ALL
Select ('MTM Assets and Liabilities Deal SQL') UNION ALL
Select ('MTM Assets and Liabilities Net SQL') UNION ALL
Select ('MTM Assets and Liabilities Couterparty SQL') UNION ALL
Select ('MTM Assets and Liabilities Deal SQL') UNION ALL
Select ('MTM Assets and Liabilities Net SQL') UNION ALL
Select ('Cash Balance View') UNION ALL
Select ('MTM Detail View (MDV)') UNION ALL
Select ('Implied Volatility View') UNION ALL
Select ('Level 3 Disclosure View') UNION ALL
Select ('pnl_explain_view_table') UNION ALL
Select ('Expected Return Difference View') UNION ALL
Select ('MTM_Chart') UNION ALL
Select ('Credit Rating Migration View') UNION ALL
Select ('[adiha_process].[dbo].[batch_export_systemaccesslogreport]') UNION ALL
Select ('[adiha_process].[dbo].[batch_export_test]') UNION ALL
Select ('Time Series Group View') UNION ALL
Select ('[adiha_process].[dbo].[batch_export_MyTest]') UNION ALL
Select ('[adiha_process].[dbo].[batch_export_system_access_log_report]') UNION ALL
Select ('[adiha_process].[dbo].[batch_export_test 1]') UNION ALL
Select ('[adiha_process].[dbo].[batch_export_system access log report]') UNION ALL
Select ('NorthPool Position View') UNION ALL
Select ('Non Cash Collateral View') UNION ALL
Select ('Wellhead Setup and Volume View') UNION ALL
Select ('Equity Position Export') UNION ALL
Select ('Credit Exp View') UNION ALL
Select ('Shutin View') UNION ALL
Select ('Storage View') UNION ALL
Select ('FX Ineffectiveness View') UNION ALL
Select ('detailed_measurement_view') UNION ALL
Select ('Default Recovery Rate View') UNION ALL
Select ('To Delete') UNION ALL
Select ('To delete') UNION ALL
Select ('Endur_deal_detail_view') UNION ALL
Select ('DDT') UNION ALL
Select ('Endur_deal_view') UNION ALL
Select ('Credit Exposure') UNION ALL
Select ('Credit Recivables or Payables') UNION ALL
Select ('Positive Neagative Summation') UNION ALL
Select ('TTF') UNION ALL
Select ('test') UNION ALL
Select ('Position Hourly View Excluding Sub Book') UNION ALL
Select ('Market Place Postion 15 Min') UNION ALL
Select ('Kid View') UNION ALL
Select ('Percentage Effectiveness View') UNION ALL
Select ('Failed Effectiveness View') UNION ALL
Select ('Address') UNION ALL
Select ('Attribute') UNION ALL
Select ('BankInfo') UNION ALL
Select ('Current Receivab or Payable') UNION ALL
Select ('Credit Exposure') UNION ALL
Select ('FAS Measurement View') UNION ALL
Select ('FAS MTM View') UNION ALL
Select ('MTM Accounting vs AOCI Ineffectiveness View') UNION ALL
Select ('FAS Netted Journal Entry View') UNION ALL
Select ('Hedge Capacity Exception View') UNION ALL
Select ('FAS Journal Entry View') UNION ALL
Select ('Combined Inventory View') UNION ALL
Select ('deal_confirm') UNION ALL
Select ('product_desc') UNION ALL
Select ('List of Products') UNION ALL
Select ('Counterparty Product') UNION ALL
Select ('Counterparty Certificate') UNION ALL
Select ('Approved Counterparty') UNION ALL
Select ('Contract Settlement View') UNION ALL
Select ('CVA View Simulation') UNION ALL
Select ('delta hourly positin') UNION ALL
Select ('delta_monthly_position') UNION ALL
Select ('Invoice View') UNION ALL
Select ('Position Monthly Dashboard') UNION ALL
Select ('Position_View_Monthly') UNION ALL
Select ('Trade Activity View') UNION ALL
Select ('MTM Change SQL') UNION ALL
Select ('MTM Change SQL') UNION ALL
Select ('generic mapping sql') UNION ALL
Select ('Non EFET Detailed Settlement View') UNION ALL
Select ('MTM Detail View') UNION ALL
Select ('aaaaaa') UNION ALL
Select ('MTM Fees View') UNION ALL
Select ('Merged Deal View') UNION ALL
Select ('dealRemark') UNION ALL
Select ('test') UNION ALL
Select ('Deal_Confirm_report_View') UNION ALL
Select ('Margin Analysis View') UNION ALL
Select ('MTM Assets and Liabilities Couterparty SQL') UNION ALL
Select ('MTM Assets and Liabilities Deal SQL') UNION ALL
Select ('MTM Assets and Liabilities Net SQL') UNION ALL
Select ('At Risk Change Summary SQL') UNION ALL
Select ('broker') UNION ALL
Select ('capacity_contract_view') UNION ALL
Select ('capacity_sql') UNION ALL
Select ('capacity_usage_report_view') UNION ALL
Select ('test3454') UNION ALL
Select ('Credit Exposure') UNION ALL
Select ('Credit Recivables or Payables') UNION ALL
Select ('Positive Neagative Summation') UNION ALL
Select ('Deal Audit Detail SQL View') UNION ALL
Select ('Energy_analysis2') UNION ALL
Select ('FX Ineffectiveness Detail Report') UNION ALL
Select ('FX Ineffectiveness Summary Report') UNION ALL
Select ('Custom Journal Entry Views') UNION ALL
Select ('Gas Transport') UNION ALL
Select ('Inventry_SQL') UNION ALL
Select ('MTM Assets and Liabilities Couterparty SQL') UNION ALL
Select ('MTM Assets and Liabilities Deal SQL') UNION ALL
Select ('MTM Assets and Liabilities Net SQL') UNION ALL
Select ('MTM Assets and Liabilities Couterparty SQL') UNION ALL
Select ('MTM Assets and Liabilities Deal SQL') UNION ALL
Select ('MTM Assets and Liabilities Net SQL') UNION ALL
Select ('MTM Assets and Liabilities Couterparty SQL') UNION ALL
Select ('MTM Assets and Liabilities Deal SQL') UNION ALL
Select ('MTM Assets and Liabilities Net SQL') UNION ALL
Select ('MTM Change SQL') UNION ALL
Select ('Trader Credit SQL Demo') UNION ALL
Select ('MTM Change SQL') UNION ALL
Select ('commodity shift filtered sql') UNION ALL
Select ('Nom Audit Report') UNION ALL
Select ('deal_group') UNION ALL
Select ('forecast sql Demo') UNION ALL
Select ('Deal Groups Demo') UNION ALL
Select ('forecast sql') UNION ALL
Select ('Deal Groups') UNION ALL
Select ('Questline Report SQL') UNION ALL
Select ('MTM_Chart') UNION ALL
Select ('SSIS_ERROR_LOG_SQL') UNION ALL
Select ('True Up View') UNION ALL
Select ('Unit Availability Report') UNION ALL
Select ('Wellhead Volume View') UNION ALL
Select ('Counterparty Detail View') UNION ALL
Select ('Deal Audit Detail View') UNION ALL
Select ('Credit Exposure Summary Whatif') UNION ALL
Select ('Hedge Strategy Report') UNION ALL
Select ('Hedge Statement Report') UNION ALL
Select ('Exp by Rating SQL') UNION ALL
Select ('Broker') UNION ALL
Select ('hedge report') UNION ALL
Select ('001test') UNION ALL
Select ('ABC') UNION ALL
Select ('Deal Group') UNION ALL
Select ('Deal Grouping') UNION ALL
Select ('Data Check') UNION ALL
Select ('Generation Position View') UNION ALL
Select ('Hourly Generation View') UNION ALL
Select ('Monthly Generation View') UNION ALL
Select ('Var Cost Master View') UNION ALL
Select ('MMWEC Meter Export') UNION ALL
Select ('Meter Data Report') UNION ALL
Select ('MMWEC Fee Settlement Report') UNION ALL
Select ('MMWEC Price Report') UNION ALL
Select ('actual_match') UNION ALL
Select ('Hedge Position View') UNION ALL
Select ('Component VaR View') UNION ALL
Select ('rs1') UNION ALL
Select ('er2') UNION ALL
Select ('Large Report') UNION ALL
Select ('Option Greeks Detail Value') UNION ALL
select ('UDF Crosstab view')UNION ALL
select ('MTM Detailed Mega View')


IF OBJECT_ID('tempdb..#delete_View') IS NOT NULL
DROP TABLE #delete_View
		CREATE TABLE #delete_View (source_data_id VARCHAR(500) COLLATE DATABASE_DEFAULT, name VARCHAR(500) COLLATE DATABASE_DEFAULT)
INSERT INTO #delete_View 
		SELECT data_source_id, name from data_source where name in (select View_name from #save_View)


IF CURSOR_STATUS('local','view_delete') > = -1
		BEGIN
			DEALLOCATE view_delete
		END

	DECLARE view_delete CURSOR LOCAL FOR
		
		SELECT source_data_id
		FROM   #delete_View 
		DECLARE @source_data_id varchar(100)
		
		OPEN view_delete 
		FETCH NEXT FROM view_delete 
		INTO @source_data_id
		WHILE @@FETCH_STATUS = 0
		BEGIN			
			EXEC spa_rfx_data_source 'd', NULL, NULL, NULL, NULL, NULL, @source_data_id
		
		FETCH NEXT FROM view_delete INTO @source_data_id
		END

		CLOSE view_delete
		DEALLOCATE view_delete




UPDATE report
SET Name  = REPLACE(Name, 'Standard ', '')
WHERE name in (
'Standard PNL Report',
'Standard Forecast Actual Report',
'Standard Price Curve Plot',
'Standard Time Series Report',
--'Standard Cash Flow Report Old',
--'Standard Meter Data Report',
--'Standard Counterparty Collateral Inventory Report',
--'Standard Deal Settlement Detail Report',
'Standard Deal Extract Report',
'Standard Deal Audit Trail Detail Report',
'Standard MTM Fees Extract Report',
--'Standard Deal Settlement Report',
--'Standard Price Export Report',
'Standard EoD Trade Report',
'Standard Hourly Position Summary Report',
'Standard Daily Position Extract Report',
'Standard Monthly Position Extract Report',
'Standard Monthly Position Summary Report',
'Standard Power ToU Position Report',
'Standard Delta Position Report',
'Standard Position Change Report',
'Standard Delta Position Monthly Report',
'Standard MTM Extract Report',
'Standard MTM Report by Trader',
'Standard MTM Report by Book',
'Standard MTM Report by Counterparty',
'Standard MTM Report by Charges',
'Standard Deal Settlement Extract Report',
'Standard Deal Settlement Report by Book',
'Standard Deal Settlement Report by Counterparty',
'Standard Cash Flow Report',
'Standard Earning Report',
'Standard Realized Unrealized PNL Report',
'Standard Realized Unrealized Detail Report',
'Standard MTM Settlement Extract Report',
'Standard MTM Change Report',
'Standard Contract Settlement Report',
'Standard PNL Attribution Report',
'Standard Position Attribution Report',
--'Standard Counterparty Collateral Inventory Report',
'Standard Counterparty Detail Report',
'Standard Credit Reserve Report',
'Standard Credit Value Adjustment Report',
'Standard Cash Collateral Balance Report',
'Standard AR Aging Report',
'Standard PFE Report',
'Standard Default Recovery Rate Report',
'Standard Default Probability Report',
'Standard Counterparty Limit Report',
'Standard Options Greeks Report',
'Standard Eigen Values Report',
'Standard Eigen Vectors Report',
'Standard Expected Return Change Report',
'Standard Expected Return Report',
'Standard Implied Volatility Report',
'Standard Daily Position Summary Report',
'Standard Hourly Position Extract Report', 
'aberce')

UPDATE report_paramset
SET Name  = REPLACE(Name, 'Standard ', '')
 WHERE name in (
'Standard PNL Report',
'Standard Forecast Actual Report',
'Standard Price Curve Plot',
'Standard Time Series Report',
--'Standard Cash Flow Report Old',
--'Standard Meter Data Report',
--'Standard Counterparty Collateral Inventory Report',
--'Standard Deal Settlement Detail Report',
'Standard Deal Extract Report',
'Standard Deal Audit Trail Detail Report',
'Standard MTM Fees Extract Report',
--'Standard Deal Settlement Report',
--'Standard Price Export Report',
'Standard EoD Trade Report',
'Standard Hourly Position Summary Report',
'Standard Daily Position Extract Report',
'Standard Monthly Position Extract Report',
'Standard Monthly Position Summary Report',
'Standard Power ToU Position Report',
'Standard Delta Position Report',
'Standard Position Change Report',
'Standard Delta Position Monthly Report',
'Standard MTM Extract Report',
'Standard MTM Report by Trader',
'Standard MTM Report by Book',
'Standard MTM Report by Counterparty',
'Standard MTM Report by Charges',
'Standard Deal Settlement Extract Report',
'Standard Deal Settlement Report by Book',
'Standard Deal Settlement Report by Counterparty',
'Standard Cash Flow Report',
'Standard Earning Report',
'Standard Realized Unrealized PNL Report',
'Standard Realized Unrealized Detail Report',
'Standard MTM Settlement Extract Report',
'Standard MTM Change Report',
'Standard Contract Settlement Report',
'Standard PNL Attribution Report',
'Standard Position Attribution Report',
--'Standard Counterparty Collateral Inventory Report',
'Standard Counterparty Detail Report',
'Standard Credit Reserve Report',
'Standard Credit Value Adjustment Report',
'Standard Cash Collateral Balance Report',
'Standard AR Aging Report',
'Standard PFE Report',
'Standard Default Recovery Rate Report',
'Standard Default Probability Report',
'Standard Counterparty Limit Report',
'Standard Options Greeks Report',
'Standard Eigen Values Report',
'Standard Eigen Vectors Report',
'Standard Expected Return Change Report',
'Standard Expected Return Report',
'Standard Implied Volatility Report',
'Standard Daily Position Summary Report',
'Standard Hourly Position Extract Report')

UPDATE data_source
SET Name  = REPLACE(Name, 'Standard ', '')
WHERE name IN (
'Standard Price Curve View',
'Standard At Risk View',
'Standard Limit View',
'Standard Delta Monthly Position View',
'Standard Volatility View',
'Standard Correlation View',
'Standard Deal Audit Detail View',
'Standard UDF Crosstab view',
'Standard Deal Audit View',
'Standard Multiple Scenario Shift View',
'Standard Time Series View',
'Standard AR Aging View',
'Standard Position View',
'Standard Position Detail View',
'Standard Deal Detail View',
'Standard MTM Detail View',
'Standard Counterparty Limit View',
'Standard MTM Fees View',
'Standard Deal Settlement Detail View',
'Standard Credit Detail View',
'Standard Credit Exposure Summary View',
'Standard Settlement Mega View',
'Standard Contract Settlement View',
'Standard Static Data UDF View',
'Standard Actual Forecast View',
'Standard Settlement Lower Granularity View',
'Standard MTM Lower Granularity View',
'Standard Counterparty Collateral View',
'Standard Counterparty Detail View',
'Standard Whatif Analysis View',
'Standard Option Greeks Detail View',
'Standard Cash Collateral Balance View',
'Standard PNL Attribution View',
'Standard MTM Detailed Mega View',
'Standard Option Greeks Detail Value',
'Standard Expected Return View',
'Standard Implied Volatility View',
'Standard Simulated Prices View',
'Standard At Risk PFE View',
'Standard Cholesky Decomposition View',
'Standard Eigen Decomposition View',
'Standard Default Probability View',
'Standard Default Recovery Rate View',
'Standard CVA View',
'Standard Credit Reserve View',
'Standard MTM by Charge View',
'Standard MTM View',
'Standard Deal Settlement View'
)

Update data_source 
set 
description = concat('Standard ',Name)
where name in 
('Price Curve View',
'Delta Monthly Position View',
'Deal Audit Detail View',
'UDF Crosstab view',
'Deal Audit View',
'Time Series View',
'AR Aging View',
'Contract Settlement View',
'Static Data UDF View',
'Actual Forecast View',
'Settlement Lower Granularity View',
'MTM Lower Granularity View',
'Counterparty Collateral View',
'Option Greeks Detail View',
'PNL Attribution View',
'Option Greeks Detail Value',
'At Risk PFE View',
'CVA View',
'GMaR View')

update report 
set description = concat('Standard ', Name) 
where name in (
'Credit Exposure By Counterparty',
'Credit Exposure Summary Report for Trader',
'Credit Exposure Summary Report',
'Credit Exposure To Counterparty',
'Parent Counterparty Credit Exposure Report',
'At Risk Backtesting',
'At Risk Report-Pivot',
'At Risk Report',
'Correlation Change Report',
'Correlation Report',
'Limit Report',
'Volatility Change Report',
'Volatility Report',
'What if Analysis Report-Pivot',
'Simulated Prices Report',
'Cholesky Decomposition Report',
'Marginal VaR Report',
'Hourly Position Summary Report',
'Delta Position Report',
'Deal Settlement Extract Report',
'Deal Settlement Report by Book',
'Deal Settlement Report by Counterparty',
'Cash Flow Report',
'PNL Attribution Report',
'Position Attribution Report',
'Credit Exposure Extract Report',
'Cash Collateral Balance Report',
'Counterparty Limit Report',
'GMaR Report',
'Assessment Results Plot Series',
'Assessment Results Plot Trends',
'Assessment Results Plot',
'Volatility Smile Chart',
'Hourly Position Extract Report',
'What If Analysis Report',
'What if Analysis Report Pivot',
'Position Change Report')