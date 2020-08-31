--BEGIN TRAN
print('--==============================Start application_functions=============================')
--TODO: check existance
IF OBJECT_ID('tempdb..#application_functions') IS NOT NULL
	DROP TABLE #application_functions

CREATE TABLE #application_functions(
	[function_id] [int] NOT NULL,
	[function_name] [varchar](200) NULL,
	[function_desc] [varchar](200) NULL,
	[func_ref_id] [int] NULL,
	[document_path] [varchar](1000) NULL,
	[function_call] [varchar](200) NULL,
	[function_parameter] [varchar](500) NULL,
	[file_path] [varchar](2000) NULL,
	[book_required] [bit] DEFAULT ((0)) NOT NULL,
)

INSERT INTO #application_functions ([function_id],[function_name],[function_desc],[func_ref_id],[document_path],[function_call],[function_parameter],[file_path],[book_required])VALUES(10101000,'Setup Static Data','Setup Static Data',NULL,'#5 Setup Static Data',NULL,NULL,'_setup/maintain_static_data/maintain.static.data.php',0)
INSERT INTO #application_functions ([function_id],[function_name],[function_desc],[func_ref_id],[document_path],[function_call],[function_parameter],[file_path],[book_required])VALUES(10101122,'Counterparty Credit Info','Counterparty Credit Info',NULL,NULL,NULL,NULL,'_credit_risks_analysis/counterparty_credit_info/counterparty.credit.info.php',0)
INSERT INTO #application_functions ([function_id],[function_name],[function_desc],[func_ref_id],[document_path],[function_call],[function_parameter],[file_path],[book_required])VALUES(10101161,'Deal Confirmation Rule','Deal Confirmation Rule',10101115,NULL,NULL,NULL,'_setup/confirmation_rule/confirmation_rule.php',0)
INSERT INTO #application_functions ([function_id],[function_name],[function_desc],[func_ref_id],[document_path],[function_call],[function_parameter],[file_path],[book_required])VALUES(10101182,'Setup UOM Conversion','Setup UOM Conversion',NULL,'#10 Setup UOM Conversion',NULL,NULL,'_setup/define_uom_conversion/define.uom.conversion.php',0)
INSERT INTO #application_functions ([function_id],[function_name],[function_desc],[func_ref_id],[document_path],[function_call],[function_parameter],[file_path],[book_required])VALUES(10101200,'Setup Book Structure','Setup Book Structure',NULL,'#6 Setup Book Structure',NULL,NULL,'_setup/setup_book_structure/setup.hedging.strat.php',1)
INSERT INTO #application_functions ([function_id],[function_name],[function_desc],[func_ref_id],[document_path],[function_call],[function_parameter],[file_path],[book_required])VALUES(10101300,'Setup GL Codes','Setup GL Codes',NULL,'#12 Setup GL Codes',NULL,NULL,'_setup/map_gl_codes/map.gl.codes.php',0)
INSERT INTO #application_functions ([function_id],[function_name],[function_desc],[func_ref_id],[document_path],[function_call],[function_parameter],[file_path],[book_required])VALUES(10101400,'Maintain Deal Template','Maintain Deal Template',NULL,'#13 Maintain Deal Template',NULL,NULL,'_setup/maintain_deal_template/maintain.deal.template.php',0)
INSERT INTO #application_functions ([function_id],[function_name],[function_desc],[func_ref_id],[document_path],[function_call],[function_parameter],[file_path],[book_required])VALUES(10101500,'Maintain Netting Asset/Liab Groups','Maintain Netting Asset/Liab Groups',NULL,NULL,NULL,NULL,'_setup/maintain_netting_groups/maintain.netting.groups.php',0)
INSERT INTO #application_functions ([function_id],[function_name],[function_desc],[func_ref_id],[document_path],[function_call],[function_parameter],[file_path],[book_required])VALUES(10101600,'View Scheduled Job','View Scheduled Job',NULL,'#16 View Scheduled Job',NULL,NULL,'_setup/schedule_job/schedule.job.php',0)
INSERT INTO #application_functions ([function_id],[function_name],[function_desc],[func_ref_id],[document_path],[function_call],[function_parameter],[file_path],[book_required])VALUES(10101900,'Setup Logical Trade Lock','Setup Logical Trade Lock',NULL,NULL,NULL,NULL,'_setup/setup_logical_trade_lock/setup.logical.trade.lock.php',0)
INSERT INTO #application_functions ([function_id],[function_name],[function_desc],[func_ref_id],[document_path],[function_call],[function_parameter],[file_path],[book_required])VALUES(10102400,'Formula Builder','Formula Builder',NULL,'#22 Formula Builder',NULL,NULL,'_setup/formula_builder/formula.builder.php',0)
INSERT INTO #application_functions ([function_id],[function_name],[function_desc],[func_ref_id],[document_path],[function_call],[function_parameter],[file_path],[book_required])VALUES(10102500,'Setup Location','Setup Location',NULL,'#8 Setup Location',NULL,NULL,'_setup/setup_location/setup.location.php',0)
INSERT INTO #application_functions ([function_id],[function_name],[function_desc],[func_ref_id],[document_path],[function_call],[function_parameter],[file_path],[book_required])VALUES(10102600,'Setup Price Curve','Setup Price Curve',NULL,'#7 Setup Price Curve',NULL,NULL,'_setup/setup_price_curves/setup.price.curves.php',0)
INSERT INTO #application_functions ([function_id],[function_name],[function_desc],[func_ref_id],[document_path],[function_call],[function_parameter],[file_path],[book_required])VALUES(10102800,'Setup Profile','Setup Profile',NULL,NULL,NULL,NULL,'_setup/setup_profile/setup.profile.php',0)
INSERT INTO #application_functions ([function_id],[function_name],[function_desc],[func_ref_id],[document_path],[function_call],[function_parameter],[file_path],[book_required])VALUES(10102900,'Manage Document','Manage Document',NULL,'#21 Manage Document',NULL,NULL,'_setup/manage_documents/manage.documents.php',0)
INSERT INTO #application_functions ([function_id],[function_name],[function_desc],[func_ref_id],[document_path],[function_call],[function_parameter],[file_path],[book_required])VALUES(10103000,'Setup Meter','Setup Meter',NULL,'#17 Setup Meter',NULL,NULL,'_setup/define_meter_id/define.meter.id.php',0)
INSERT INTO #application_functions ([function_id],[function_name],[function_desc],[func_ref_id],[document_path],[function_call],[function_parameter],[file_path],[book_required])VALUES(10103300,'Setup GL Groups','Setup GL Groups',NULL,'#18 Setup GL Groups',NULL,NULL,'_setup/define_invoice_glcode/define.invoice.glcode.php',0)
INSERT INTO #application_functions ([function_id],[function_name],[function_desc],[func_ref_id],[document_path],[function_call],[function_parameter],[file_path],[book_required])VALUES(10103400,'Setup Default GL Code for Contract Components','Setup Default GL Code for Contract Components',NULL,'#19 Setup Default GL Code for Contract Components',NULL,NULL,'_setup/setup_default_glcode/setup.default.glcode.php',0)
INSERT INTO #application_functions ([function_id],[function_name],[function_desc],[func_ref_id],[document_path],[function_call],[function_parameter],[file_path],[book_required])VALUES(10104100,'Maintain UDF Template','Maintain UDF Template',NULL,'#15 Maintain UDF Template','windowSetupUDFTemplate',NULL,'_setup/maintain_udf_template/maintain.udf.template.php',0)
INSERT INTO #application_functions ([function_id],[function_name],[function_desc],[func_ref_id],[document_path],[function_call],[function_parameter],[file_path],[book_required])VALUES(10104200,'Maintain Field Template','Maintain Field Template',NULL,'#14 Maintain Field Template','windowSetupFieldTemplate',NULL,'_setup/maintain_field_template/maintain_field_template.php',0)
INSERT INTO #application_functions ([function_id],[function_name],[function_desc],[func_ref_id],[document_path],[function_call],[function_parameter],[file_path],[book_required])VALUES(10104300,'Setup Contract Component Mapping','Setup Contract Component Mapping',NULL,'#20 Setup Contract Component Mapping',NULL,NULL,'_setup/setup_contract_component_mapping/setup.contract.component.mapping.php',0)
INSERT INTO #application_functions ([function_id],[function_name],[function_desc],[func_ref_id],[document_path],[function_call],[function_parameter],[file_path],[book_required])VALUES(10104600,'Setup Settlement Netting Group','Setup Settlement Netting Group',10100000,NULL,NULL,NULL,'_setup/maintain_settlement_netting_grp/maintain.settlement.netting.grp.php',0)
INSERT INTO #application_functions ([function_id],[function_name],[function_desc],[func_ref_id],[document_path],[function_call],[function_parameter],[file_path],[book_required])VALUES(10104800,'Import/Export','Data Import/Export',NULL,'#24 Data Import/Export',NULL,NULL,'_setup/data_import_export/data.import.export.manager.php',0)
INSERT INTO #application_functions ([function_id],[function_name],[function_desc],[func_ref_id],[document_path],[function_call],[function_parameter],[file_path],[book_required])VALUES(10104900,'Compose Email','Compose Email',NULL,'#25 Compose Email',NULL,NULL,'_setup/compose_email/compose.email.php',0)
INSERT INTO #application_functions ([function_id],[function_name],[function_desc],[func_ref_id],[document_path],[function_call],[function_parameter],[file_path],[book_required])VALUES(10105800,'Setup Counterparty','Setup Counterparty',NULL,'#9 Setup Counterparty',NULL,NULL,'_setup/setup_counterparty/setup.counterparty.php',0)
INSERT INTO #application_functions ([function_id],[function_name],[function_desc],[func_ref_id],[document_path],[function_call],[function_parameter],[file_path],[book_required])VALUES(10106300,'Data Import/Export New UI','Data Import/Export New UI',NULL,NULL,NULL,NULL,'_setup/data_import_export/data.import.export.php',0)
INSERT INTO #application_functions ([function_id],[function_name],[function_desc],[func_ref_id],[document_path],[function_call],[function_parameter],[file_path],[book_required])VALUES(10106400,'Template Field Mapping','Template Field Mapping',NULL,NULL,NULL,NULL,'_setup/template_field_mapping/template.field.mapping.php',0)
INSERT INTO #application_functions ([function_id],[function_name],[function_desc],[func_ref_id],[document_path],[function_call],[function_parameter],[file_path],[book_required])VALUES(10106600,'Rules Workflow','Rules Workflow',NULL,NULL,NULL,NULL,'_compliance_management/setup_rule_workflow/setup.rule.workflow.php',0)
INSERT INTO #application_functions ([function_id],[function_name],[function_desc],[func_ref_id],[document_path],[function_call],[function_parameter],[file_path],[book_required])VALUES(10106700,'Manage Approval','Manage Approval',NULL,NULL,NULL,NULL,'_compliance_management/setup_rule_workflow/workflow.approval.php',0)
INSERT INTO #application_functions ([function_id],[function_name],[function_desc],[func_ref_id],[document_path],[function_call],[function_parameter],[file_path],[book_required])VALUES(10111000,'Setup User','Setup User',NULL,'#28 Setup User',NULL,NULL,'_users_roles/maintain_users/maintain.users.php',0)
INSERT INTO #application_functions ([function_id],[function_name],[function_desc],[func_ref_id],[document_path],[function_call],[function_parameter],[file_path],[book_required])VALUES(10111100,'Setup Role','Setup Role',NULL,'#29 Setup Role',NULL,NULL,'_users_roles/maintain_roles/maintain.roles.php',0)
INSERT INTO #application_functions ([function_id],[function_name],[function_desc],[func_ref_id],[document_path],[function_call],[function_parameter],[file_path],[book_required])VALUES(10111200,'Customize Menu','Setup Workflow',NULL,'#30 Setup Workflow',NULL,NULL,'_users_roles/maintain_menu_item/maintain.menu.item.php',0)
INSERT INTO #application_functions ([function_id],[function_name],[function_desc],[func_ref_id],[document_path],[function_call],[function_parameter],[file_path],[book_required])VALUES(10111300,'Privilege Report','Privilege Report',10202200,NULL,NULL,NULL,NULL,0)
INSERT INTO #application_functions ([function_id],[function_name],[function_desc],[func_ref_id],[document_path],[function_call],[function_parameter],[file_path],[book_required])VALUES(10111400,'System Access Log Report','System Access Log Report',10202200,NULL,NULL,NULL,NULL,0)
INSERT INTO #application_functions ([function_id],[function_name],[function_desc],[func_ref_id],[document_path],[function_call],[function_parameter],[file_path],[book_required])VALUES(10122500,'Setup Alerts','Setup Alerts',NULL,'#26 Maintain Alerts',NULL,NULL,'_compliance_management/setup_alerts/setup.alerts.php',0)
INSERT INTO #application_functions ([function_id],[function_name],[function_desc],[func_ref_id],[document_path],[function_call],[function_parameter],[file_path],[book_required])VALUES(10122600,'Setup Simple Alert','Setup Simple Alert',NULL,NULL,NULL,NULL,'_compliance_management/setup_alerts/setup.alerts.simple.php',0)
INSERT INTO #application_functions ([function_id],[function_name],[function_desc],[func_ref_id],[document_path],[function_call],[function_parameter],[file_path],[book_required])VALUES(10131000,'Create and View Deals','Create and View Deals',NULL,'#31 Create and View Deals',NULL,NULL,'_deal_capture/maintain_deals/maintain.deals.new.php',1)
INSERT INTO #application_functions ([function_id],[function_name],[function_desc],[func_ref_id],[document_path],[function_call],[function_parameter],[file_path],[book_required])VALUES(10131300,'Import All Data','Import All Data',NULL,NULL,NULL,NULL,'_accounting/derivative/deal_capture/import_data/import.data.php?call_from=d',0)
INSERT INTO #application_functions ([function_id],[function_name],[function_desc],[func_ref_id],[document_path],[function_call],[function_parameter],[file_path],[book_required])VALUES(10141400,'Transcations Report','Transcations Report',10202200,NULL,NULL,NULL,NULL,0)
INSERT INTO #application_functions ([function_id],[function_name],[function_desc],[func_ref_id],[document_path],[function_call],[function_parameter],[file_path],[book_required])VALUES(10151000,'View Prices','View Prices',NULL,'#32 View Prices',NULL,NULL,'_price_curve_management/view_prices/view.prices.php',0)
INSERT INTO #application_functions ([function_id],[function_name],[function_desc],[func_ref_id],[document_path],[function_call],[function_parameter],[file_path],[book_required])VALUES(10171100,'Transaction Audit Log Report','Transaction Audit Log Report',10202200,NULL,NULL,NULL,NULL,1)
INSERT INTO #application_functions ([function_id],[function_name],[function_desc],[func_ref_id],[document_path],[function_call],[function_parameter],[file_path],[book_required])VALUES(10181000,'Run MTM Process','Run MTM Process',NULL,NULL,NULL,NULL,'_valuation_risk_analysis/run_mtm_process/run.mtm.process.php',1)
INSERT INTO #application_functions ([function_id],[function_name],[function_desc],[func_ref_id],[document_path],[function_call],[function_parameter],[file_path],[book_required])VALUES(10181200,'Run At Risk Measurement','Run At Risk Measurement',NULL,NULL,NULL,NULL,'_valuation_risk_analysis/run_at_risk/run.risk.measurement.php',1)
INSERT INTO #application_functions ([function_id],[function_name],[function_desc],[func_ref_id],[document_path],[function_call],[function_parameter],[file_path],[book_required])VALUES(10181300,'Maintain Limits','Maintain Limits',NULL,NULL,NULL,NULL,'_valuation_risk_analysis/run_limits/maintain.limits.php',1)
INSERT INTO #application_functions ([function_id],[function_name],[function_desc],[func_ref_id],[document_path],[function_call],[function_parameter],[file_path],[book_required])VALUES(10181400,'Calculate Volatility, Correlation and Expected Return','Calculate Volatility, Correlation and Expected Return',NULL,NULL,NULL,NULL,'_valuation_risk_analysis/calculate_volatility_correlation/calculate.volatility.correlation.php',0)
INSERT INTO #application_functions ([function_id],[function_name],[function_desc],[func_ref_id],[document_path],[function_call],[function_parameter],[file_path],[book_required])VALUES(10181800,'Run Implied Volatility Calculation','Run Implied Volatility Calculation',10180000,NULL,NULL,NULL,'_valuation_risk_analysis/run_implied_volatility_calculation/run.implied.volatility.calculation.php',0)
INSERT INTO #application_functions ([function_id],[function_name],[function_desc],[func_ref_id],[document_path],[function_call],[function_parameter],[file_path],[book_required])VALUES(10182500,'Maintain What-If scenario','Maintain What-If scenario',NULL,NULL,NULL,NULL,'_valuation_risk_analysis/maintain_what_if_scenario/maintain.scenario.php',0)
INSERT INTO #application_functions ([function_id],[function_name],[function_desc],[func_ref_id],[document_path],[function_call],[function_parameter],[file_path],[book_required])VALUES(10183000,'Maintain Monte Carlo Models','Maintain Monte Carlo Models',NULL,NULL,NULL,NULL,'_valuation_risk_analysis/maintain_risk_factor_models/maintain.risk.factor.models.php',0)
INSERT INTO #application_functions ([function_id],[function_name],[function_desc],[func_ref_id],[document_path],[function_call],[function_parameter],[file_path],[book_required])VALUES(10183100,'Run Monte Carlo Simulation','Run Monte Carlo Simulation',NULL,NULL,NULL,NULL,'_valuation_risk_analysis/run_montecarlo_simulation/run.montecarlo.simulation.php',1)
INSERT INTO #application_functions ([function_id],[function_name],[function_desc],[func_ref_id],[document_path],[function_call],[function_parameter],[file_path],[book_required])VALUES(10183200,'Setup Portfolio Group','Setup Portfolio Group',10180000,NULL,NULL,NULL,'_valuation_risk_analysis/maintain_portfolio_group/maintain.portfolio.group.php',1)
INSERT INTO #application_functions ([function_id],[function_name],[function_desc],[func_ref_id],[document_path],[function_call],[function_parameter],[file_path],[book_required])VALUES(10183400,'Setup What if Criteria','Setup What if Criteria',NULL,NULL,NULL,NULL,'_valuation_risk_analysis/maintain_whatif_criteria/maintain.whatif.criteria.php',1)
INSERT INTO #application_functions ([function_id],[function_name],[function_desc],[func_ref_id],[document_path],[function_call],[function_parameter],[file_path],[book_required])VALUES(10184000,'Run MTM Simulation','Run MTM Simulation',10180000,NULL,NULL,NULL,'_valuation_risk_analysis/run_mtm_process/run.mtm.simulation.php',1)
INSERT INTO #application_functions ([function_id],[function_name],[function_desc],[func_ref_id],[document_path],[function_call],[function_parameter],[file_path],[book_required])VALUES(10191800,'Calculate Credit Exposure','Calculate Credit Exposure',NULL,NULL,NULL,NULL,'_credit_risks_analysis/_credit/calculate.credit.exposure.php',0)
INSERT INTO #application_functions ([function_id],[function_name],[function_desc],[func_ref_id],[document_path],[function_call],[function_parameter],[file_path],[book_required])VALUES(10192200,'Calculate Credit Value Adjustment','Calculate Credit Value Adjustment',NULL,NULL,NULL,NULL,'_credit_risks_analysis/calculate_credit_value_adjustment/calculate.credit.value.adjustment.php',0)
INSERT INTO #application_functions ([function_id],[function_name],[function_desc],[func_ref_id],[document_path],[function_call],[function_parameter],[file_path],[book_required])VALUES(10201500,'Static Data Audit Report','Static Data Audit Report',10202200,NULL,NULL,NULL,NULL,0)
INSERT INTO #application_functions ([function_id],[function_name],[function_desc],[func_ref_id],[document_path],[function_call],[function_parameter],[file_path],[book_required])VALUES(10201600,'Report Manager','Report Manager',NULL,'#44 Report Manager','windowReportManager',NULL,'_reporting/report_manager/report.manager.php',0)
INSERT INTO #application_functions ([function_id],[function_name],[function_desc],[func_ref_id],[document_path],[function_call],[function_parameter],[file_path],[book_required])VALUES(10201700,'Run Report Group','Run Report Group',10200000,NULL,NULL,NULL,NULL,0)
INSERT INTO #application_functions ([function_id],[function_name],[function_desc],[func_ref_id],[document_path],[function_call],[function_parameter],[file_path],[book_required])VALUES(10201800,'Report Group Manager','Report Group Manager',NULL,NULL,'windowReportGroupManager',NULL,'_reporting/report_group/report.group.manager.php',0)
INSERT INTO #application_functions ([function_id],[function_name],[function_desc],[func_ref_id],[document_path],[function_call],[function_parameter],[file_path],[book_required])VALUES(10201900,'Data Import/Export Audit Report','Data Import/Export Audit Report',10202200,NULL,NULL,NULL,NULL,0)
INSERT INTO #application_functions ([function_id],[function_name],[function_desc],[func_ref_id],[document_path],[function_call],[function_parameter],[file_path],[book_required])VALUES(10202000,'User Activity Log Report','User Activity Log Report',10202200,NULL,NULL,NULL,NULL,0)
INSERT INTO #application_functions ([function_id],[function_name],[function_desc],[func_ref_id],[document_path],[function_call],[function_parameter],[file_path],[book_required])VALUES(10202100,'Message Board Log Report','Message Board Log Report',10202200,NULL,NULL,NULL,NULL,0)
INSERT INTO #application_functions ([function_id],[function_name],[function_desc],[func_ref_id],[document_path],[function_call],[function_parameter],[file_path],[book_required])VALUES(10202200,'View Report','View Report',NULL,'#45 View Report',NULL,NULL,'_reporting/view_report/view.report.php',0)
INSERT INTO #application_functions ([function_id],[function_name],[function_desc],[func_ref_id],[document_path],[function_call],[function_parameter],[file_path],[book_required])VALUES(10202201,'Export GL Entries','SAP Settlement Export',NULL,NULL,NULL,NULL,'_settlement_billing/sap_export/sap_export.php',0)
INSERT INTO #application_functions ([function_id],[function_name],[function_desc],[func_ref_id],[document_path],[function_call],[function_parameter],[file_path],[book_required])VALUES(10202500,'Report Manager DHX','Report Manager DHX',NULL,NULL,NULL,NULL,'_reporting/report_manager_dhx/report.manager.dhx.php',0)
INSERT INTO #application_functions ([function_id],[function_name],[function_desc],[func_ref_id],[document_path],[function_call],[function_parameter],[file_path],[book_required])VALUES(10202600,'Excel Addin Report Manager','Excel Addin Report Manager',10200000,NULL,NULL,NULL,'_reporting/report_manager_excel/report.manager.excel.php',0)
INSERT INTO #application_functions ([function_id],[function_name],[function_desc],[func_ref_id],[document_path],[function_call],[function_parameter],[file_path],[book_required])VALUES(10211100,'Setup Contract Component Template','Setup Contract Component Template',NULL,'#51 Setup Contract Component Template',NULL,NULL,'_contract_administration/contract_charge_type/contract.charge.type.php',0)
INSERT INTO #application_functions ([function_id],[function_name],[function_desc],[func_ref_id],[document_path],[function_call],[function_parameter],[file_path],[book_required])VALUES(10211200,'Setup Standard Contract','Setup Standard Contract',NULL,'#48 Setup Standard Contract',NULL,NULL,'_contract_administration/maintain_contract_group/maintain.contract.php',0)
INSERT INTO #application_functions ([function_id],[function_name],[function_desc],[func_ref_id],[document_path],[function_call],[function_parameter],[file_path],[book_required])VALUES(10211213,'Setup Custom Report Template','Setup Custom Report Template',NULL,'#11 Setup Custom Report Template',NULL,NULL,'_setup/custom_report_template/custom.report.template.php',0)
INSERT INTO #application_functions ([function_id],[function_name],[function_desc],[func_ref_id],[document_path],[function_call],[function_parameter],[file_path],[book_required])VALUES(10211300,'Setup Non-Standard Contract','Setup Non-Standard Contract',NULL,'#49 Setup Non-Standard Contract',NULL,NULL,'_contract_administration/maintain_contract_group/maintain.contract.nonstandard.php',0)
INSERT INTO #application_functions ([function_id],[function_name],[function_desc],[func_ref_id],[document_path],[function_call],[function_parameter],[file_path],[book_required])VALUES(10221000,'Process Invoice','Process Invoice',NULL,'#52 Process Invoice',NULL,NULL,'_settlement_billing/maintain_invoice/run.contract.settlement.php',0)
INSERT INTO #application_functions ([function_id],[function_name],[function_desc],[func_ref_id],[document_path],[function_call],[function_parameter],[file_path],[book_required])VALUES(10221200,'Contract Settlement Report','Contract Settlement Report',10202200,NULL,NULL,NULL,NULL,0)
INSERT INTO #application_functions ([function_id],[function_name],[function_desc],[func_ref_id],[document_path],[function_call],[function_parameter],[file_path],[book_required])VALUES(10221300,'View Invoice','View Invoice',NULL,'#55 View Invoice',NULL,NULL,'_settlement_billing/maintain_invoice/maintain.invoice.php',0)
INSERT INTO #application_functions ([function_id],[function_name],[function_desc],[func_ref_id],[document_path],[function_call],[function_parameter],[file_path],[book_required])VALUES(10222300,'Run Deal Settlement','Run Deal Settlement',NULL,'#53 Run Deal Settlement',NULL,NULL,'_settlement_billing/run_settlement/run.settlement.php',1)
INSERT INTO #application_functions ([function_id],[function_name],[function_desc],[func_ref_id],[document_path],[function_call],[function_parameter],[file_path],[book_required])VALUES(10222400,'Meter Data Report','Meter Data Report',10202200,NULL,NULL,NULL,NULL,0)
INSERT INTO #application_functions ([function_id],[function_name],[function_desc],[func_ref_id],[document_path],[function_call],[function_parameter],[file_path],[book_required])VALUES(10231000,'Setup Inventory GL Account','Setup Inventory GL Account',NULL,NULL,NULL,NULL,'_accounting/inventory/maintain.inventory.gl.account/maintain.inventory.gl.account.php',0)
INSERT INTO #application_functions ([function_id],[function_name],[function_desc],[func_ref_id],[document_path],[function_call],[function_parameter],[file_path],[book_required])VALUES(10232800,'Import Audit Report','Import Audit Report',10202200,NULL,NULL,NULL,NULL,0)
INSERT INTO #application_functions ([function_id],[function_name],[function_desc],[func_ref_id],[document_path],[function_call],[function_parameter],[file_path],[book_required])VALUES(10234700,'Maintain Deal Transfer','Maintain Deal Transfer',NULL,NULL,NULL,NULL,'_accounting/derivative/transaction_processing/maintain_deal_transfer/maintain.deal.transfer.php',0)
INSERT INTO #application_functions ([function_id],[function_name],[function_desc],[func_ref_id],[document_path],[function_call],[function_parameter],[file_path],[book_required])VALUES(10237500,'Close Accounting Period','Close Accounting Period',10230000,NULL,NULL,NULL,'_accounting/derivative/ongoing_assessment/close_msmt_books/close.accounting.period.php',0)
INSERT INTO #application_functions ([function_id],[function_name],[function_desc],[func_ref_id],[document_path],[function_call],[function_parameter],[file_path],[book_required])VALUES(10241100,'Apply Cash','Apply Cash',10220000,NULL,NULL,NULL,'_settlement_billing/apply_cash/apply.cash.php',0)
INSERT INTO #application_functions ([function_id],[function_name],[function_desc],[func_ref_id],[document_path],[function_call],[function_parameter],[file_path],[book_required])VALUES(12101700,'Setup Renewable Sources','Setup Renewable Sources',12100000,NULL,NULL,NULL,'_models_and_activity/setup_renewable_source/setup.renewable.source.php',1)
INSERT INTO #application_functions ([function_id],[function_name],[function_desc],[func_ref_id],[document_path],[function_call],[function_parameter],[file_path],[book_required])VALUES(12101712,'Setup Source Group','Setup Source Group',NULL,NULL,NULL,NULL,NULL,0)
INSERT INTO #application_functions ([function_id],[function_name],[function_desc],[func_ref_id],[document_path],[function_call],[function_parameter],[file_path],[book_required])VALUES(12101720,'Assignment','Assignment Form',NULL,NULL,NULL,NULL,NULL,0)
INSERT INTO #application_functions ([function_id],[function_name],[function_desc],[func_ref_id],[document_path],[function_call],[function_parameter],[file_path],[book_required])VALUES(12103200,'Setup REC Assignment Priority','Setup REC Assignment Priority',NULL,NULL,NULL,NULL,'_compliance_management/setup_rec_assignment_priority/setup.rec.assignment.priority.php',0)
INSERT INTO #application_functions ([function_id],[function_name],[function_desc],[func_ref_id],[document_path],[function_call],[function_parameter],[file_path],[book_required])VALUES(12121500,'Lifecycle of Transactions','Lifecycle of Transactions',10202200,NULL,NULL,NULL,NULL,0)
INSERT INTO #application_functions ([function_id],[function_name],[function_desc],[func_ref_id],[document_path],[function_call],[function_parameter],[file_path],[book_required])VALUES(12121600,'Assigned Hypothetical RECs','Assigned Hypothetical RECs',NULL,NULL,NULL,NULL,'_allowance_credit_assignment/assign.hypothetic.recs.php',1)
INSERT INTO #application_functions ([function_id],[function_name],[function_desc],[func_ref_id],[document_path],[function_call],[function_parameter],[file_path],[book_required])VALUES(12131000,'Run Target Report','Run Target Report',10202200,NULL,NULL,NULL,NULL,0)
INSERT INTO #application_functions ([function_id],[function_name],[function_desc],[func_ref_id],[document_path],[function_call],[function_parameter],[file_path],[book_required])VALUES(13102000,'Generic Mapping','Generic Mapping',NULL,'#23 Generic Mapping',NULL,NULL,'_setup/common_mapping/common_mapping.php',0)
INSERT INTO #application_functions ([function_id],[function_name],[function_desc],[func_ref_id],[document_path],[function_call],[function_parameter],[file_path],[book_required])VALUES(14100100,'Compliance Jurisdiction','Compliance Jurisdiction',NULL,NULL,NULL,NULL,'_setup/compliance_jurisdiction/compliance.jurisdiction.php',0)
INSERT INTO #application_functions ([function_id],[function_name],[function_desc],[func_ref_id],[document_path],[function_call],[function_parameter],[file_path],[book_required])VALUES(14121400,'Assign/Unassign Transaction','Assign/Unassign Transaction',NULL,NULL,NULL,NULL,'_allowance_credit_assignment/assign.unassign.transaction.php',0)
INSERT INTO #application_functions ([function_id],[function_name],[function_desc],[func_ref_id],[document_path],[function_call],[function_parameter],[file_path],[book_required])VALUES(14121500,'Unassign Transaction','Unassign Transaction',NULL,NULL,NULL,NULL,'_allowance_credit_assignment/unassign.transaction.php',0)
INSERT INTO #application_functions ([function_id],[function_name],[function_desc],[func_ref_id],[document_path],[function_call],[function_parameter],[file_path],[book_required])VALUES(20001800,'View/Edit Meter Data','View/Edit Meter Data',NULL,NULL,NULL,NULL,'_settlement_billing/update_meter_data/update.meter.data.php',0)
INSERT INTO #application_functions ([function_id],[function_name],[function_desc],[func_ref_id],[document_path],[function_call],[function_parameter],[file_path],[book_required])VALUES(20004000,'Accrual Journal Entry Report','Accrual Journal Entry Report',NULL,NULL,NULL,NULL,NULL,0)
INSERT INTO #application_functions ([function_id],[function_name],[function_desc],[func_ref_id],[document_path],[function_call],[function_parameter],[file_path],[book_required])VALUES(20004100,'Curve Value Report','Curve Value Report',10202200,NULL,NULL,NULL,NULL,0)
INSERT INTO #application_functions ([function_id],[function_name],[function_desc],[func_ref_id],[document_path],[function_call],[function_parameter],[file_path],[book_required])VALUES(20004200,'Purchase Power Renewable Report','Purchase Power Renewable Report',NULL,NULL,NULL,NULL,NULL,0)
INSERT INTO #application_functions ([function_id],[function_name],[function_desc],[func_ref_id],[document_path],[function_call],[function_parameter],[file_path],[book_required])VALUES(20004300,'Revenue Report','Revenue Report',NULL,NULL,NULL,NULL,NULL,0)
INSERT INTO #application_functions ([function_id],[function_name],[function_desc],[func_ref_id],[document_path],[function_call],[function_parameter],[file_path],[book_required])VALUES(20004700,'Deal Match','Deal Match',NULL,NULL,NULL,NULL,'_deal_capture/deal_match/deal.match.php',0)
INSERT INTO #application_functions ([function_id],[function_name],[function_desc],[func_ref_id],[document_path],[function_call],[function_parameter],[file_path],[book_required])VALUES(20004800,'Compliance Group','Compliance Group',NULL,NULL,NULL,NULL,'_setup/compliance_group/compliance.group.php',0)
INSERT INTO #application_functions ([function_id],[function_name],[function_desc],[func_ref_id],[document_path],[function_call],[function_parameter],[file_path],[book_required])VALUES(20007900,'Buy Sell Match','Buy Sell Match',NULL,NULL,NULL,NULL,'_deal_capture/buy_sell/buysell.match.php',0)

UPDATE dbo.application_functions
SET [function_id] = src.[function_id] 
	, [function_name] = src.[function_name]
	, [function_desc] = src.[function_desc] 
	, [func_ref_id] = src.[func_ref_id] 
	, [document_path] = src.[document_path] 
	, [function_call] = src.[function_call] 
	, [function_parameter] = src.[function_parameter]
	, [file_path] = src.[file_path]
	, [book_required] = src.[book_required]
FROM #application_functions src
INNER JOIN application_functions dst ON src.function_id = dst.function_id;

INSERT INTO application_functions (
	 [function_id],
	 [function_name],
	 [function_desc],
     [func_ref_id] ,
	 [document_path], 
	 [function_call],
	 [function_parameter],
	 [file_path],
	 [book_required])
SELECT src.[function_id],
	 src.[function_name],
	 src.[function_desc],
     src.[func_ref_id] ,
	 src.[document_path], 
	 src.[function_call],
	 src.[function_parameter],
	 src.[file_path],
	 src.[book_required]
FROM #application_functions src
LEFT JOIN application_functions dst ON src.function_id = dst.function_id
WHERE dst.[function_id] IS NULL;
print('--==============================End application_functions=============================')
print('--==============================START setup_menu=============================')
   if object_id('tempdb..#setup_menu') is null       CREATE TABLE #setup_menu    (    [setup_menu_id] int ,[function_id] int ,[window_name] varchar(1000) COLLATE DATABASE_DEFAULT,[display_name] varchar(200) COLLATE DATABASE_DEFAULT,[default_parameter] varchar(5000) COLLATE DATABASE_DEFAULT,[hide_show] bit ,[parent_menu_id] int ,[product_category] int ,[menu_order] int ,[menu_type] bit ,new_recid int,old_recid int    )    ELSE    TRUNCATE TABLE #setup_menu;
INSERT INTO #setup_menu(    [setup_menu_id],[function_id],[window_name],[display_name],[default_parameter],[hide_show],[parent_menu_id],[product_category],[menu_order],[menu_type],old_recid    )    VALUES    
(1930,12101720,'windowAssignmentForm','Assignment Form',NULL,0,12101700,14000000,50,0,1930),
(1931,12101712,'windowSetupSourceGroup','Setup Source Group',NULL,0,12101700,14000000,50,0,1931),
(1941,14000000,NULL,'RECTracker',NULL,1,NULL,14000000,1,1,1941),
(1942,10100000,NULL,'Setup',NULL,1,14000000,14000000,1,1,1942),
(1943,10122500,'windowSetupAlerts','Setup Alert',NULL,1,10106699,14000000,48,0,1943),
(1944,10106600,'windowRulesWorkflow','Setup Rule Workflow',NULL,1,10106699,14000000,52,0,1944),
(1945,10106700,'windowManageApproval','Manage Approval',NULL,1,10106699,14000000,53,0,1945),
(1946,10106699,'NULL','Alert and Workflow',NULL,1,10100000,14000000,1,1,1946),
(1947,10106300,'windowDataImportNewUI','Data Import/Export',NULL,1,10106399,14000000,112,0,1947),
(1948,10131300,'windowImportDataDeal','Import Data',NULL,0,10106399,14000000,51,0,1948),
(1949,10104800,'windowDataImportExport','Data Import/Export',NULL,0,10100000,14000000,41,0,1949),
(1950,10106399,'NULL','Data Import',NULL,1,10100000,14000000,1,1,1950),
(1951,10102900,'windowManageDocumentsMain','Manage Document',NULL,1,10100000,14000000,27,0,1951),
(1952,10101099,'NULL','Reference Data',NULL,1,10100000,14000000,1,1,1952),
(1953,10101000,'windowMaintainStaticData','Setup Static Data',NULL,1,10101099,14000000,2,0,1953),
(1954,10101200,'windowSetupHedgingStrategies','Setup Book Structure',NULL,1,10101099,14000000,3,0,1954),
(1955,10102600,'windowSetupPriceCurves','Setup Price Curve',NULL,1,10101099,14000000,4,0,1955),
(1956,10102500,'windowSetupLocation','Setup Location',NULL,1,10101099,14000000,5,0,1956),
(1957,10103000,'windowDefineMeterID','Setup Meter',NULL,1,10101099,14000000,20,0,1957),
(1958,10102400,'windowFormulaBuilder','Formula Builder',NULL,1,10104099,14000000,29,0,1958),
(1959,13102000,'windowGenericMapping','Generic Mapping',NULL,1,10106499,14000000,34,0,1959),
(1960,10101400,'windowMaintainDealTemplate','Setup Deal Template',NULL,1,10104099,14000000,12,0,1960),
(1961,10104200,'windowSetupFieldTemplate','Setup Deal Field Template',NULL,1,10104099,14000000,13,0,1961),
(1962,10101182,'WindowDefineUOMConversion','Setup UOM Conversion',NULL,1,10101099,14000000,8,0,1962),
(1963,10105800,'windowSetupCounterparty','Setup Counterparty',NULL,1,10101099,14000000,7,0,1963),
(1964,10211213,'windowReportTemplateSetup','Setup Custom Report Template',NULL,1,10104099,14000000,9,0,1964),
(1965,10104100,'windowSetupUDFTemplate','Setup UDF Template',NULL,1,10104099,14000000,14,0,1965),
(1966,10102800,'windowSetupProfile','Setup Profile',NULL,1,10101099,14000000,6,0,1966),
(1967,10106400,'windowTemplateFieldMapping','Template Field Mapping',NULL,1,10106499,14000000,16,0,1967),
(1968,10101900,'windowSetupDealLock','Setup Logical Trade Lock',NULL,0,10100000,14000000,3,1,1968),
(1969,10101161,'windowDealConfirmationRule','Setup Confirmation Rule',NULL,1,10104099,14000000,16,0,1969),
(1970,10106499,'NULL','Mapping Setup',NULL,1,10100000,14000000,1,1,1970),
(1971,10104099,'NULL','Template',NULL,1,10100000,14000000,1,1,1971),
(1972,10200000,NULL,'Reporting',NULL,1,14000000,14000000,1,1,1972),
(1973,10201600,'windowReportManager','Report Manager - Old',NULL,0,10200000,14000000,125,0,1973),
(1974,10202200,'windowViewReport','View Report',NULL,1,10200000,14000000,133,0,1974),
(1975,10202500,'windowReportManagerDHX','Report Manager',NULL,1,10200000,14000000,43,0,1975),
(1976,10201800,'WindowReportGroupManager','Report Group Manager',NULL,0,10200000,14000000,0,0,1976),
(1977,10201700,'WindowRunReportGroup','Run Report Group',NULL,0,10200000,14000000,0,0,1977),
(1978,10110000,NULL,'User and Role',NULL,1,10000000,14000000,42,1,1978),
(1979,10111000,'windowMaintainUsers','Setup User',NULL,1,10110000,14000000,40,0,1979),
(1980,10111100,'windowMaintainRoles','Setup Role',NULL,1,10110000,14000000,41,0,1980),
(1981,10111200,'windowCustomizedMenu','Customize Menu',NULL,1,10110000,14000000,42,0,1981),
(1982,14100000,NULL,'Compliance Menu',NULL,1,14000000,14000000,1,1,1982),
(1983,12100000,NULL,'Renewable Source',NULL,1,14000000,14000000,1,1,1983),
(1984,12101700,'windowSetupRenewableSource','Setup Renewable Source',NULL,1,12100000,14000000,2,0,1984),
(1985,12130000,NULL,'Inventory Management',NULL,1,14000000,14000000,1,1,1985),
(1986,10131000,'windowMaintainDeals','Create REC Deal',NULL,1,12130000,14000000,50,0,1986),
(1987,10234700,'windowMaintainDealTransfer','Maintain REC Deal Transfer',NULL,0,12130000,14000000,54,0,1987),
(1988,10150000,NULL,'Price Curve Management',NULL,1,14000000,14000000,1,1,1988),
(1989,10151000,'windowViewPrices','View REC Price',NULL,1,10150000,14000000,62,0,1989),
(1990,15190000,'NULL','Accounting Setup',NULL,1,14000000,14000000,1,1,1990),
(1991,10103300,'windowDefineInvoiceGLCode','Setup GL Group',NULL,1,15190000,14000000,22,0,1991),
(1992,10103400,'windowSetupDefaultGLCode','Setup Default GL Group',NULL,1,15190000,14000000,23,0,1992),
(1993,10101500,'windowMaintainNettingGroups','Setup Netting Group',NULL,1,15190000,14000000,222,0,1993),
(1994,10231000,'windowSetupInventoryGLAccount','Setup Inventory GL Account',NULL,0,15190000,14000000,40,0,1994),
(1995,10104300,'windowSetupContractComponentMapping','Setup Contract Component Mapping',NULL,1,10210000,14000000,24,0,1995),
(1996,10210000,'NULL','Contract Administration',NULL,1,14000000,14000000,153,1,1996),
(1997,10211200,'windowMaintainContractGroup','Setup Standard Contract',NULL,0,10210000,14000000,135,0,1997),
(1998,10211100,'windowContractChargeType','Setup Contract Component Template',NULL,1,10210000,14000000,138,0,1998),
(1999,10211300,'windowNonStandardContract','Setup Contract',NULL,1,10210000,14000000,136,0,1999),
(2000,10220000,'NULL','Settlement And Billing',NULL,1,14000000,14000000,158,1,2000),
(2001,10221000,'windowMaintainInvoice','Process Invoice',NULL,1,10220000,14000000,140,0,2001),
(2002,10222300,'windowRunSettlement','Run Deal Settlement',NULL,1,10220000,14000000,141,0,2002),
(2003,10221300,'windowMaintainInvoiceHistory','View Invoice',NULL,1,10220000,14000000,143,0,2003),
(2004,10241100,'windowApplyCash','Apply Cash',NULL,1,10220000,14000000,111,0,2004),
(2005,10104600,'windowMaintainNettingGrp','Setup Settlement Netting Group',NULL,1,10220000,14000000,17,0,2005),
(2155,12121600,NULL,'Finalize Committed RECs',NULL,1,12130000,14000000,1,1,2155),
(2156,10141400,NULL,'Transcations Report',NULL,0,10202200,14000000,3,0,2156),
(2157,12121500,NULL,'Lifecycle of Transactions',NULL,0,10202200,14000000,4,0,2157),
(2158,12131000,NULL,'Run Target Report',NULL,0,10202200,14000000,5,0,2158),
(2159,12103200,'windowSetupRECAssignmentPriority','Setup REC Assignment Priority',NULL,1,14100000,14000000,1,0,2159),
(2160,14100100,NULL,'Compliance Jurisdiction',NULL,1,14100000,14000000,3,0,2160),
(2161,10104900,NULL,'Compose Email',NULL,1,10104099,14000000,0,0,2161),
(2162,10101600,NULL,'View Scheduled Job',NULL,1,10100000,14000000,0,0,2162),
(2163,10101300,NULL,'Setup GL Code',NULL,1,15190000,14000000,0,0,2163),
(2164,13240000,NULL,'Derivative Accounting',NULL,1,14000000,14000000,0,1,2164),
(2165,10235499,NULL,'Accounting',NULL,1,13240000,14000000,0,1,2165),
(2166,10237500,NULL,'Close Accounting Period',NULL,1,10235499,14000000,0,0,2166),
(2167,10202201,NULL,'Export GL Entry',NULL,0,10220000,14000000,0,0,2167),
(2168,10111400,NULL,'System Access Log Report',NULL,0,10202200,14000000,0,0,2168),
(2169,10111300,NULL,'Privilege Report',NULL,0,10202200,14000000,0,0,2169),
(2170,10201900,NULL,'Data Import/Export Audit Report',NULL,0,10202200,14000000,0,0,2170),
(2171,10202000,NULL,'User Activity Log Report',NULL,0,10202200,14000000,0,0,2171),
(2172,10202100,NULL,'Message Board Log Report',NULL,0,10202200,14000000,0,0,2172),
(2173,20004300,NULL,'Revenue Report',NULL,0,10202200,14000000,0,0,2173),
(2174,14121400,'windowAssignUnassignTransaction','Assign Transaction',NULL,1,12130000,14000000,1,1,2174),
(2175,20004000,NULL,'Accrual Journal Entry Report',NULL,0,10202200,14000000,0,0,2175),
(2176,20004100,NULL,'Curve Value Report',NULL,0,10202200,14000000,0,0,2176),
(2177,20004800,NULL,'Compliance Group',NULL,1,14100000,14000000,0,0,2177),
(2178,20004200,NULL,'Purchase Power Renewable Report',NULL,0,10202200,14000000,0,0,2178),
(2179,14121500,NULL,'Unassign Transaction',NULL,1,12130000,14000000,0,0,2179),
(2180,10202600,NULL,'Excel Addin Report Manager',NULL,1,10200000,14000000,0,0,2180),
(2181,10122600,NULL,'Setup Simple Alert',NULL,1,10106699,14000000,0,0,2181),
(2182,10222400,NULL,'Meter Data Report',NULL,0,10202200,14000000,7,0,2182),
(2183,10221200,NULL,'Contract Settlement Report',NULL,0,10202200,14000000,6,0,2183),
(2184,10232800,NULL,'Run Import Audit Report',NULL,1,10230097,14000000,215,0,2184),
(2185,10201500,NULL,'Static Data Audit Report',NULL,0,10202200,14000000,11,0,2185),
(2186,10171100,NULL,'Transaction Audit Log Report',NULL,0,10202200,14000000,10,0,2186),
(2187,20001800,NULL,'View/Edit Meter Data',NULL,1,10220000,14000000,0,0,2187),
(2188,20004700,NULL,'Deal Match        ',NULL,1,12130000,14000000,0,0,2188),
(2189,10180000,NULL,'Valuation And Risk Analysis',NULL,1,14000000,14000000,133,1,2189),
(2190,10181299,NULL,'Run At Risk',NULL,0,10180000,14000000,140,1,2190),
(2191,10183499,NULL,'Run What-If',NULL,0,10180000,14000000,25,1,2191),
(2192,10181399,NULL,'Run Limits',NULL,0,10180000,14000000,100,1,2192),
(2193,10181499,NULL,'Run Volatility Calculations',NULL,0,10180000,14000000,133,1,2193),
(2194,10181599,NULL,'Simulation',NULL,0,10180000,14000000,1,1,2194),
(2195,10181099,NULL,'Setup',NULL,1,10180000,14000000,1,1,2195),
(2196,10181199,NULL,'Run Analytical Process',NULL,1,10180000,14000000,1,1,2196),
(2197,10190000,NULL,'Credit Risk And Analysis',NULL,1,14000000,14000000,133,1,2197),
(2198,10191800,NULL,'Calculate Credit Risk Exposure',NULL,1,10190000,14000000,112,0,2198),
(2199,10101122,NULL,'Counterparty Credit Information',NULL,1,10190000,14000000,117,0,2199),
(2200,10192200,NULL,'Calculate Credit Value Adjustment',NULL,1,10190000,14000000,114,0,2200),
(2201,10182200,NULL,'Run Counterparty MTM report',NULL,0,10181099,14000000,87,0,2201),
(2202,10181100,NULL,'Run MTM Report',NULL,0,10181099,14000000,86,0,2202),
(2203,10181300,NULL,'Setup Limit',NULL,1,10181099,14000000,100,0,2203),
(2204,10183200,NULL,'Setup Portfolio Group',NULL,1,10181099,14000000,118,0,2204),
(2205,10183000,NULL,'Setup Risk Factor Model',NULL,1,10181099,14000000,117,0,2205),
(2206,10182500,NULL,'Setup What If Scenario',NULL,1,10181099,14000000,200,0,2206),
(2207,10181400,NULL,'Calculate Volatility, Correlation and Expected Return',NULL,1,10181199,14000000,133,1,2207),
(2208,10181200,NULL,'Run At Risk Measurement',NULL,1,10181199,14000000,8,0,2208),
(2209,10181800,NULL,'Run Implied Volatility Calculation',NULL,1,10181199,14000000,134,1,2209),
(2210,10183100,NULL,'Run Monte Carlo Simulation',NULL,1,10181199,14000000,133,0,2210),
(2211,10181000,NULL,'Run MTM Process',NULL,1,10181199,14000000,133,0,2211),
(2212,10184000,NULL,'Run MTM Simulation',NULL,1,10181199,14000000,134,1,2212),
(2213,10183400,NULL,'Run What If Analysis',NULL,1,10181199,14000000,27,0,2213),
(2214,20007900,NULL,'Buy Sell Match',NULL,1,12130000,14000000,0,0,2214),
(NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,null);   delete #setup_menu where setup_menu_id is null;   update #setup_menu set function_id='FARRMS1_ '+cast(setup_menu_id as varchar(30))  where isnull(function_id,'')='' ;   update #setup_menu set product_category='FARRMS2_ '+cast(setup_menu_id as varchar(30))  where isnull(product_category,'')='' ;     
UPDATE dbo.setup_menu 
SET [window_name]=src.[window_name],[display_name]=src.[display_name],[default_parameter]=src.[default_parameter],[hide_show]=src.[hide_show],[parent_menu_id]=src.[parent_menu_id],[menu_order]=src.[menu_order],[menu_type]=src.[menu_type]       
--OUTPUT 'u','setup_menu',inserted.setup_menu_id,inserted.function_id,inserted.product_category,NULL INTO #old_new_id(tran_type,table_name,new_id,unique_key1,unique_key2,unique_key3)   
FROM #setup_menu src INNER JOIN setup_menu dst  ON src.function_id=dst.function_id AND src.product_category=dst.product_category;
insert into setup_menu    ([function_id],[window_name],[display_name],[default_parameter],[hide_show],[parent_menu_id],[product_category],[menu_order],[menu_type]    )     
--OUTPUT 'i','setup_menu',inserted.setup_menu_id,inserted.function_id,inserted.product_category,NULL INTO #old_new_id(tran_type,table_name,new_id,unique_key1,unique_key2,unique_key3)       
SELECT     src.[function_id],src.[window_name],src.[display_name],src.[default_parameter],src.[hide_show],src.[parent_menu_id],src.[product_category],src.[menu_order],src.[menu_type]    
FROM #setup_menu src LEFT JOIN setup_menu dst  ON src.function_id=dst.function_id AND src.product_category=dst.product_category    WHERE dst.[setup_menu_id] IS NULL;
--UPDATE #setup_menu SET new_recid =dst.new_id     FROM #setup_menu src INNER JOIN #old_new_id dst  ON src.function_id=dst.unique_key1 AND src.product_category=dst.unique_key2 AND dst.table_name='setup_menu'    ;
print('--==============================END setup_menu=============================')
--rollback