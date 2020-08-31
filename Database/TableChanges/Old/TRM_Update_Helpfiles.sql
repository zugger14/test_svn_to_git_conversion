------------------------------- Module Administration Start --------------------------------------------------------------
--Setup
update application_functions set document_path = 'Administration/Setup/configure_interface_timeout_parameter.htm' where function_id = 10101800
update application_functions set document_path = 'Administration/Setup/maintain_deal_template.htm' where function_id =10101400 
update application_functions set document_path = 'Administration/Setup/maintain_definition.htm' where function_id =10101100
update application_functions set document_path = 'Administration/Setup/maintain_netting_asset-liab_groups.htm' where function_id =10101500
update application_functions set document_path = 'Administration/Setup/Maintain_Source_Generator.htm' where function_id =10161500
update application_functions set document_path = 'Administration/Setup/maintain_static_data.htm' where function_id =10101000
update application_functions set document_path = 'Administration/Setup/map_GL_codes.htm' where function_id =10101300
update application_functions set document_path = 'Administration/Setup/Setup_Book_Structure.htm' where function_id =10101200
update application_functions set document_path = 'Administration/Setup/Define_Contract_Components_GL_Codes.htm' where function_id =10231300
update application_functions set document_path = 'Administration/Setup/Define_meter_id.htm' where function_id =10221500
update application_functions set document_path = 'Administration/Setup/Setup_Default_GL_Code_for_Contract_Components.htm' where function_id =10231400
update application_functions set document_path = 'Administration/Setup/setup_emission_source_sink_types.htm' where function_id =12101000

--Users and Roles
update application_functions set document_path = 'Administration/Users_and_Roles/maintain_roles.htm' where function_id =10111100
update application_functions set document_path = 'Administration/Users_and_Roles/maintain_users.htm' where function_id =10111000
update application_functions set document_path = 'Administration/Users_and_Roles/Maintain_Work_Flow.htm' where function_id =10111200
update application_functions set document_path = 'Administration/Users_and_Roles/run_privilege_report.htm' where function_id =10111300
update application_functions set document_path = 'Administration/Users_and_Roles/run_system_access_log_report.htm' where function_id =10111400

--Compliance Management
update application_functions set document_path = 'Administration/Compliance Management/approve_control_activities.htm' where function_id =10121100
update application_functions set document_path = 'Administration/Compliance Management/perform_control_activities.htm' where function_id =10121200
update application_functions set document_path = 'Administration/Compliance Management/Reports/report_status_on_control_activities.htm' where function_id =10121700


-- Child
update application_functions set document_path = 'Administration/Setup/maintain_static_data.htm' where function_id =10101010
update application_functions set document_path = 'Administration/Setup/maintain_definition.htm' where function_id =10101130
update application_functions set document_path = 'Administration/Setup/Setup_Book_Structure.htm' where function_id =10101210
update application_functions set document_path = 'Administration/Setup/Setup_Book_Structure.htm' where function_id =10101213
update application_functions set document_path = 'Administration/Setup/Setup_Book_Structure.htm' where function_id =10101215
update application_functions set document_path ='Administration/Setup/maintain_deal_template.htm' where function_id=10101410
update application_functions set document_path ='Administration/Setup/maintain_deal_template.htm' where function_id=10101414

update application_functions set document_path ='Administration/Setup/Define_meter_id.htm' where function_id=10221510
update application_functions set document_path ='Administration/Setup/Define_meter_id.htm' where function_id=10221512
update application_functions set document_path ='Administration/Setup/Define_meter_id.htm' where function_id=10221517
update application_functions set document_path ='Administration/Setup/Define_meter_id.htm' where function_id=10221513
update application_functions set document_path ='Administration/Setup/Define_Contract_Components_GL_Codes.htm' where function_id= 10231310
update application_functions set document_path ='Administration/Setup/Define_Contract_Components_GL_Codes.htm' where function_id= 10231312
update application_functions set document_path ='Administration/Setup/Setup_Default_GL_Code_for_Contract_Components.htm' where function_id=10231410
update application_functions set document_path ='Administration/Users_and_Roles/maintain_users.htm' WHERE function_id=10111010
update application_functions set document_path ='Administration/Users_and_Roles/maintain_users.htm' WHERE function_id=10111014
update application_functions set document_path ='Administration/Users_and_Roles/maintain_users.htm' WHERE function_id=10111110
update application_functions set document_path ='Administration/Users_and_Roles/maintain_users.htm' WHERE function_id=10111013
update application_functions set document_path ='Administration/Users_and_Roles/maintain_users.htm' WHERE function_id=10111112
update application_functions set document_path ='Administration/Users_and_Roles/maintain_users.htm' WHERE function_id=10111111
update application_functions set document_path ='Administration/Users_and_Roles/Maintain_Work_Flow.htm' where function_id=10111210
update application_functions set document_path ='Administration/Users_and_Roles/Maintain_Work_Flow.htm' where function_id=10111211
update application_functions set document_path = 'Administration/Setup/maintain_definition.htm' where function_id =10101131
update application_functions set document_path = 'Administration/Setup/maintain_definition.htm' where function_id =10101133
update application_functions set document_path ='Administration/Setup/maintain_deal_template.htm' where function_id=10101412
update application_functions set document_path = 'Administration/Setup/maintain_definition.htm' where function_id =10101143
update application_functions set document_path = 'Administration/Setup/maintain_definition.htm' where function_id =10101136
update application_functions set document_path = 'Administration/Setup/maintain_definition.htm' where function_id =10101137
update application_functions set document_path = 'Administration/Setup/maintain_definition.htm' where function_id =10101139
update application_functions set document_path = 'Administration/Setup/maintain_definition.htm' where function_id =10101142
update application_functions set document_path = 'Administration/Setup/maintain_netting_asset-liab_groups.htm' where function_id =10101510
update application_functions set document_path = 'Administration/Setup/maintain_netting_asset-liab_groups.htm' where function_id =10101512
update application_functions set document_path = 'Administration/Setup/maintain_netting_asset-liab_groups.htm' where function_id =10101514
update application_functions set document_path = 'Administration/Setup/Maintain_Source_Generator.htm' where function_id =10161510
update application_functions set document_path = 'Administration/Setup/setup_emission_source_sink_types.htm' where function_id =12101010
update application_functions set document_path = 'Administration/Setup/configure_interface_timeout_parameter.htm' where function_id=10101800
update application_functions set document_path = 'Administration/Setup/configure_interface_timeout_parameter.htm' where function_id=10101700
------------------------------- Module Administration End---------------------------------------------------------------------------------------------------



------------------------------- Module Back Office Start ----------------------------------------------------------------
--Accounting
--Accrual
update application_functions set document_path = 'Back Office/Accounting/Accrual/Run_Journal_Entry_Report.htm' where function_id =10235400
update application_functions set document_path = 'Back Office/Accounting/Accrual/run_EQR_report.html' where function_id =10231800
update application_functions set document_path = 'Back Office/Accounting/Accrual/run_revenue_report.html' where function_id =10231600
update application_functions set document_path = 'Back Office/Accounting/Accrual/curve_value_report.htm' where function_id =10231500

--Derivative/Deal Capture
update application_functions set document_path = 'Back Office/Accounting/Derivative/Deal Capture/Run Import Audit Report.htm' where function_id =10232800
--update application_functions set document_path = 'Back Office/Accounting/Derivative/Deal Capture/import_data.htm' where function_id =10131300

--Derivative/Accounting Strategy
update application_functions set document_path = 'Back Office/Accounting/Derivative/Accouting Strategy/Manage Documents.htm' where function_id =10232200
update application_functions set document_path = 'Back Office/Accounting/Derivative/Accouting Strategy/Run_Setup_hedging_Relationship_type_report.htm' where function_id =10233900
update application_functions set document_path = 'Back Office/Accounting/Derivative/Accouting Strategy/Setup_Hedging_Relationship_Types.htm' where function_id =10232000

--Derivative/Hedge Effectiveness Test
update application_functions set document_path = 'Back Office/Accounting/Derivative/Hedge Effectiveness Test/Run_Assessment.htm' where function_id =10232300
update application_functions set document_path = 'Back Office/Accounting/Derivative/Hedge Effectiveness Test/Run_Assessment_Trend_Graph.htm' where function_id =10232500
update application_functions set document_path = 'Back Office/Accounting/Derivative/Hedge Effectiveness Test/Run_What-If_Effective_Analysis.htm' where function_id =10232600
update application_functions set document_path = 'Back Office/Accounting/Derivative/Hedge Effectiveness Test/View_Assessment_Result.htm' where function_id =10232400

--Derivative/Ongoing Assessment
update application_functions set document_path = 'Back Office/Accounting/Derivative/Ongoing Assessment/Close_Accounting_Period.htm' where function_id =10233600
update application_functions set document_path = 'Back Office/Accounting/Derivative/Ongoing Assessment/Measurement_Report.htm' where function_id =10234900
--update application_functions set document_path = 'Back Office/Accounting/Derivative/Ongoing Assessment/Run_MTM.htm' where function_id =10181000
update application_functions set document_path = 'Back Office/Accounting/Derivative/Ongoing Assessment/Run_What_If_Measurement_Analysis.htm' where function_id =10233200

--Derivative/Reporting
update application_functions set document_path = 'Back Office/Accounting/Derivative/Reporting/AOCI_Report.htm' where function_id =10235200
update application_functions set document_path = 'Back Office/Accounting/Derivative/Reporting/Report Writer.htm' where function_id =10201000
update application_functions set document_path = 'Back Office/Accounting/Derivative/Reporting/Run_Assessment_Report.htm' where function_id =10235800
update application_functions set document_path = 'Back Office/Accounting/Derivative/Reporting/Run_De-designation_Values_Report.htm' where function_id =10235300
update application_functions set document_path = 'Back Office/Accounting/Derivative/Reporting/Run_Measurement.htm' where function_id =10233400
update application_functions set document_path = 'Back Office/Accounting/Derivative/Reporting/Run_Masurement_Trend_Graph.htm' where function_id =10235000
update application_functions set document_path = 'Back Office/Accounting/Derivative/Reporting/Run_Netted_Journal_Entry_report.htm' where function_id =10235500
update application_functions set document_path = 'Back Office/Accounting/Derivative/Reporting/Run_Period_Change_Values_Report.htm' where function_id =10235100

--Derivative/Reporting/Run Exception Report
update application_functions set document_path = 'Back Office/Accounting/Derivative/Reporting/Run Exception Report/Create_Hedge_Item_Matching_Report.htm' where function_id =10236700
update application_functions set document_path = 'Back Office/Accounting/Derivative/Reporting/Run Exception Report/Run_Available_Hedge_Capacity_Exception_Report.htm' where function_id =10236400
update application_functions set document_path = 'Back Office/Accounting/Derivative/Reporting/Run Exception Report/Run_Fail_Assessment_Values_Report.htm' where function_id =10236200
update application_functions set document_path = 'Back Office/Accounting/Derivative/Reporting/Run Exception Report/Run_Missing_Assessment_Values_Report.htm' where function_id =10236100
update application_functions set document_path = 'Back Office/Accounting/Derivative/Reporting/Run Exception Report/Run_Not_Mapped_Deal_Report.htm' where function_id =10236500
update application_functions set document_path = 'Back Office/Accounting/Derivative/Reporting/Run Exception Report/Run_Tagging_Audit_Report.htm' where function_id =10236600
update application_functions set document_path = 'Back Office/Accounting/Derivative/Reporting/Run Exception Report/Run_Unapproved_Hedge_Relationship_Exception_Report.htm' where function_id =10236300

--Derivative/Reporting/Run Disclosure Report
update application_functions set document_path = 'Back Office/Accounting/Derivative/Reporting/Run Disclosure Report/Run_Accounting_Disclosure_Report.htm' where function_id =10235600
update application_functions set document_path = 'Back Office/Accounting/Derivative/Reporting/Run Disclosure Report/Run_Fair_Value_Disclosure_Report.htm' where function_id =10235700



--Derivative/Tansaction Processing
update application_functions set document_path = 'Back Office/Accounting/Derivative/Tansaction Processing/Automate_Matching_of_Hedges.htm' where function_id =10234400
update application_functions set document_path = 'Back Office/Accounting/Derivative/Tansaction Processing/Automation_of_Forcasted_Transaction.htm' where function_id =10234300
update application_functions set document_path = 'Back Office/Accounting/Derivative/Tansaction Processing/Bifurcation_of_Embedded_Derivative.htm' where function_id =10234800
update application_functions set document_path = 'Back Office/Accounting/Derivative/Tansaction Processing/De-designation_of_a_Hedge_by FIFO_LIFO.htm' where function_id =10233800
update application_functions set document_path = 'Back Office/Accounting/Derivative/Tansaction Processing/Designation_of_a_Hedge.htm' where function_id =10233700
update application_functions set document_path = 'Back Office/Accounting/Derivative/Tansaction Processing/First_Day_Gain_Loss_Treatment-Derivative.htm' where function_id =10234600
update application_functions set document_path = 'Back Office/Accounting/Derivative/Tansaction Processing/hedge_relationship_report.htm' where function_id =10233900
update application_functions set document_path = 'Back Office/Accounting/Derivative/Tansaction Processing/Life_Cycle_of_Hedges.htm' where function_id =10234200
update application_functions set document_path = 'Back Office/Accounting/Derivative/Tansaction Processing/Maintain_Transactions_Tagging.htm' where function_id =10234700
update application_functions set document_path = 'Back Office/Accounting/Derivative/Tansaction Processing/reclassify_a_hedge_de-designation01.htm' where function_id =10234000
update application_functions set document_path = 'Back Office/Accounting/Derivative/Tansaction Processing/View_Outstanding_Automation_Results.htm' where function_id =10234500

update application_functions set document_path = 'Back Office/Accounting/Derivative/Tansaction Processing/Amortize_Locked_AOCI.htm' where function_id =10234100

--Inventory
update application_functions set document_path = 'Back Office/Accounting/Inventory/Maintain_inv_GL_Account.htm' where function_id =10231010
update application_functions set document_path = 'Back Office/Accounting/Inventory/rec_inventory_journal_entry.htm' where function_id =10231100
update application_functions set document_path = 'Back Office/Accounting/Inventory/Run_Wght_Avg_Inventory_Cost_Report.htm' where function_id =10231200
update application_functions set document_path = 'Back Office/Accounting/Inventory/Maintain Inventory GL Account.htm' where function_id =10231010
update application_functions set document_path = 'Back Office/Accounting/Inventory/Run Roll Forward Inventory Report.htm' where function_id =10236900
update application_functions set document_path = 'Back Office/Accounting/Inventory/Maintain Manual Journal Entries.htm' where function_id =10237000
update application_functions set document_path = 'Back Office/Accounting/Inventory/Maintain Inventory Cost Override.htm' where function_id =10237100
update application_functions set document_path = 'Back Office/Accounting/Inventory/Run Inventory Calc.htm' where function_id =10237200

--Contract Administration
update application_functions set document_path = 'Back Office/Contract Administration/Maintain Contract.htm' where function_id =10211000

--Settlement and Billing
update application_functions set document_path = 'Back Office/Settlement and Billing/Run Settlement Process.htm' where function_id =10221000
update application_functions set document_path = 'Back Office/Settlement and Billing/Run Settlement Report.htm' where function_id =10182100
update application_functions set document_path = 'Back Office/Settlement and Billing/Settlement Calculation History.htm' where function_id =10221300
update application_functions set document_path = 'Back Office/Settlement and Billing/Run_Settlement_Production_report.htm' where function_id =10221800
update application_functions set document_path = 'Back Office/Settlement and Billing/Settlement Adjustments.htm' where function_id=10221600

--Treasury
update application_functions set document_path = 'Back Office/Treasury/Reconcile_Cash_Entries_for_Derivatives.htm' where function_id =10241000


--Child
update application_functions set document_path = 'Back Office/Settlement and Billing/Run Settlement Process.htm' where function_id =10221312
update application_functions set document_path = 'Back Office/Contract Administration/Maintain Contract.htm' where function_id =10211010
update application_functions set document_path = 'Back Office/Settlement and Billing/Run Settlement Process.htm' where function_id =10221010
update application_functions set document_path = 'Back Office/Settlement and Billing/Run Settlement Process.htm' where function_id =10221011
update application_functions set document_path = 'Back Office/Settlement and Billing/Run Settlement Process.htm' where function_id =10221019
update application_functions set document_path = 'Back Office/Settlement and Billing/Run Settlement Process.htm' where function_id =10221013
update application_functions set document_path = 'Back Office/Settlement and Billing/Run Settlement Process.htm' where function_id =10221014
update application_functions set document_path = 'Back Office/Settlement and Billing/Run Settlement Process.htm' where function_id =10221018
update application_functions set document_path = 'Back Office/Accounting/Inventory/Run Inventory Calc.htm' where function_id =10221100
update application_functions set document_path = 'Back Office/Accounting/Derivative/Accouting Strategy/Manage Documents.htm' where function_id =10232210
update application_functions set document_path = 'Back Office/Accounting/Derivative/Accouting Strategy/Manage Documents.htm' where function_id =10232212
update application_functions set document_path = 'Back Office/Accounting/Derivative/Accouting Strategy/Setup_Hedging_Relationship_Types.htm' where function_id =10231910
update application_functions set document_path = 'Back Office/Accounting/Derivative/Tansaction Processing/Designation_of_a_Hedge.htm' where function_id =10233710
update application_functions set document_path = 'Back Office/Accounting/Derivative/Tansaction Processing/Designation_of_a_Hedge.htm' where function_id =10233711
update application_functions set document_path = 'Back Office/Accounting/Derivative/Tansaction Processing/Designation_of_a_Hedge.htm' where function_id =10233715
update application_functions set document_path = 'Back Office/Accounting/Derivative/Tansaction Processing/Designation_of_a_Hedge.htm' where function_id =10233713
update application_functions set document_path = 'Back Office/Accounting/Derivative/Hedge Effectiveness Test/Run_What-If_Effective_Analysis.htm' where function_id =10232610

------------------------------- Module Back Office End ------------------------------------------------------------------------------------



------------------------------- Module Enviromental Inventory Start -------------------------------------------------------------------------------------
--Environmental Inventory
--Allowance Credit Assignment

update application_functions set document_path = 'Environmental Inventory/Allowance Credit Assignment/Assign_transactions.htm' where function_id =12121300
update application_functions set document_path = 'Environmental Inventory/Allowance Credit Assignment/life_cycle_of_transaction.htm' where function_id =12121500
update application_functions set document_path = 'Environmental Inventory/Allowance Credit Assignment/Maintain_Emission_Profile_Credit_Requirement.htm' where function_id =12121000
update application_functions set document_path = 'Environmental Inventory/Allowance Credit Assignment/UnAssign_transactions.htm' where function_id =12121400
update application_functions set document_path = 'Environmental Inventory/Allowance Credit Assignment/Maintain_Target_Emissions.htm' where function_id =12121100

--Inventory and Compliance Reporting
update application_functions set document_path = 'Environmental Inventory/Inventory and Compliance Reporting/Run_Allowancet_Reconciliation_Report.htm' where function_id =12131700
update application_functions set document_path = 'Environmental Inventory/Inventory and Compliance Reporting/Run_Exposure_Report.htm' where function_id =12131400
update application_functions set document_path = 'Environmental Inventory/Inventory and Compliance Reporting/Run_Generator_Info_Report.htm' where function_id =12132000 
update application_functions set document_path = 'Environmental Inventory/Inventory and Compliance Reporting/Run_Market_Value_Report.htm' where function_id =12131500
update application_functions set document_path = 'Environmental Inventory/Inventory and Compliance Reporting/Run_Position_Report.htm' where function_id =12131100
update application_functions set document_path = 'Environmental Inventory/Inventory and Compliance Reporting/run_target_report.htm' where function_id =12131000
update application_functions set document_path = 'Environmental Inventory/Inventory and Compliance Reporting/Run_Transaction_Report.htm' where function_id =12131200
update application_functions set document_path = 'Environmental Inventory/Inventory and Compliance Reporting/Purchase_power-Renewable_report.htm' where function_id =12132200
update application_functions set document_path = 'Environmental Inventory/Inventory and Compliance Reporting/rec_ Production_Report.htm' where function_id =12131800
update application_functions set document_path = 'Environmental Inventory/Inventory and Compliance Reporting/rec_compliance_report.htm' where function_id =12131300
update application_functions set document_path = 'Environmental Inventory/Inventory and Compliance Reporting/rec_generator _allocation_report.htm' where function_id =12132100
update application_functions set document_path = 'Environmental Inventory/Inventory and Compliance Reporting/Run_Rec_ Generator_Report.htm' where function_id =12131900

--Models and Activity
update application_functions set document_path = 'Environmental Inventory/Models and Activity/Maintain_Detail_Emissions_Sources_Sinks.htm' where function_id =12101600
update application_functions set document_path = 'Environmental Inventory/Models and Activity/Maintain_Emissions_Sources_Sinks.htm' where function_id =12101500
update application_functions set document_path = 'Environmental Inventory/Models and Activity/Maintain_Renewable_Resource.htm' where function_id =12101700
update application_functions set document_path = 'Environmental Inventory/Models and Activity/emission_source_model_detail.htm' where function_id =12101400
update application_functions set document_path = 'Environmental Inventory/Models and Activity/input_characteristics.htm' where function_id =12101100
update application_functions set document_path = 'Environmental Inventory/Models and Activity/inputoutput_characteristics.htm' where function_id =12101313
update application_functions set document_path = 'Environmental Inventory/Models and Activity/Maintain_Decaying_Factor.htm' where function_id =12101900
update application_functions set document_path = 'Environmental Inventory/Models and Activity/Maintain_inputoutput.htm' where function_id =12101300
update application_functions set document_path = 'Environmental Inventory/Models and Activity/Setup_user_define_source_sink_group.htm' where function_id =12101800
update application_functions set document_path = 'Environmental Inventory/Models and Activity/maintain_emission_inp_out_data.htm' where function_id =12112100
update application_functions set document_path = 'Environmental Inventory/Models and Activity/maintain_emission_inp_out_data.htm' where function_id =12102000


--Inventory and Reductions
update application_functions set document_path = 'Environmental Inventory/Inventory and Reductions/Benchmark_Emissions_input_output_data.htm' where function_id =12111500
update application_functions set document_path = 'Environmental Inventory/Inventory and Reductions/control_chart.htm' where function_id =12111600
update application_functions set document_path = 'Environmental Inventory/Inventory and Reductions/exp_ems_inv_reduction_data.htm' where function_id =12111200
update application_functions set document_path = 'Environmental Inventory/Inventory and Reductions/Run_Emission_Inventory_Calc.htm' where function_id =12111000
update application_functions set document_path = 'Environmental Inventory/Inventory and Reductions/Run_Emissions_Tracking_report.htm' where function_id =12111400
update application_functions set document_path = 'Environmental Inventory/Inventory and Reductions/run_ems_inv_report.htm' where function_id =12111300
update application_functions set document_path = 'Environmental Inventory/Inventory and Reductions/Archive_Data.htm' where function_id =12112100

--Child
update application_functions set document_path = 'Environmental Inventory/Models and Activity/Maintain_Emissions_Sources_Sinks.htm' where function_id =12101510
update application_functions set document_path = 'Environmental Inventory/Models and Activity/Maintain_Renewable_Resource.htm' where function_id =12101710
update application_functions set document_path = 'Environmental Inventory/Models and Activity/Maintain_Emissions_Sources_Sinks.htm' where function_id =12101511
update application_functions set document_path = 'Environmental Inventory/Allowance Credit Assignment/reconcile_recs_with_gis.htm' where function_id =12121211
update application_functions set document_path = 'Environmental Inventory/Models and Activity/input_characteristics.htm' where function_id =12101110
update application_functions set document_path = 'Environmental Inventory/Models and Activity/Maintain_inputoutput.htm' where function_id =12101310
update application_functions set document_path = 'Environmental Inventory/Models and Activity/Maintain_inputoutput.htm' where function_id =12101312
update application_functions set document_path = 'Environmental Inventory/Models and Activity/Maintain_inputoutput.htm' where function_id =12101315
update application_functions set document_path = 'Environmental Inventory/Models and Activity/emission_source_model_detail.htm' where function_id =12101410
update application_functions set document_path = 'Environmental Inventory/Models and Activity/emission_source_model_detail.htm' where function_id =12101411
update application_functions set document_path = 'Environmental Inventory/Models and Activity/emission_source_model_detail.htm' where function_id =12101413
update application_functions set document_path = 'Environmental Inventory/Models and Activity/emission_source_model_detail.htm' where function_id =12101415
update application_functions set document_path = 'Environmental Inventory/Models and Activity/Maintain_Detail_Emissions_Sources_Sinks.htm' where function_id =12101610
update application_functions set document_path = 'Environmental Inventory/Models and Activity/Maintain_Emissions_Sources_Sinks.htm' where function_id =12101513
update application_functions set document_path = 'Environmental Inventory/Models and Activity/Maintain_Decaying_Factor.htm' where function_id =12101910
update application_functions set document_path = 'Environmental Inventory/Models and Activity/maintain_emission_inp_out_data.htm' where function_id =12102015
update application_functions set document_path = 'Environmental Inventory/Models and Activity/maintain_emission_inp_out_data.htm' where function_id =12102010
update application_functions set document_path = 'Environmental Inventory/Allowance Credit Assignment/Maintain_Emission_Profile_Credit_Requirement.htm' where function_id =12121010
update application_functions set document_path = 'Environmental Inventory/Allowance Credit Assignment/Maintain_Target_Emissions.htm' where function_id =12121110
update application_functions set document_path = 'Environmental Inventory/Allowance Credit Assignment/reconcile_recs_with_gis.htm' where function_id =12121200
update application_functions set document_path = 'Environmental Inventory/Models and Activity/Maintain_Detail_Emissions_Sources_Sinks.htm' where function_id =12101612
update application_functions set document_path = 'Environmental Inventory/Models and Activity/Setup_user_define_source_sink_group.htm' where function_id =12101810
------------------------------- Module Enviromental Inventory End ----------------------------------------------------------------------------------------------------

------------------------------- Module Front Office Start-------------------------------------------------------------------------------------
--Front Office--Deal Capture

update application_functions set document_path = 'Front Office/Deal Capture/import_data.htm' where function_id =10131300
update application_functions set document_path = 'Front Office/Deal Capture/Import_EPA_Allowance_Data.htm' where function_id =10232700
update application_functions set document_path = 'Front Office/Deal Capture/maintain_Environment_transaction.htm' where function_id =10131200
update application_functions set document_path = 'Front Office/Deal Capture/maintain_transaction_Blotter.htm' where function_id =10131100
update application_functions set document_path = 'Front Office/Deal Capture/Maintain_transactions.htm' where function_id =10131000

--Position Reporting
update application_functions set document_path = 'Front Office/Position Reporting/Run Options Greek Report.htm' where function_id =10141100
update application_functions set document_path = 'Front Office/Position Reporting/Run_Index_Position_Report.htm' where function_id =10141000
update application_functions set document_path = 'Front Office/Position Reporting/Run_Transactions_Report.htm' where function_id =10141400

--Price Curve Management
update application_functions set document_path = 'Front Office/Price Curve Management/view_price.htm' where function_id =10151000
update application_functions set document_path = 'Front Office/Price Curve Management/import_price.htm' where function_id =10151100

--Child Screen
update application_functions set document_path = 'Front Office/Deal Capture/Maintain_transactions.htm' where function_id =10131010
update application_functions set document_path = 'Front Office/Deal Capture/Maintain_transactions.htm' where function_id =10131011
update application_functions set document_path = 'Front Office/Deal Capture/Maintain_transactions.htm' where function_id =10131016
update application_functions set document_path = 'Front Office/Deal Capture/Maintain_transactions.htm' where function_id =10131017
update application_functions set document_path = 'Front Office/Price Curve Management/view_price.htm' where function_id =10151010
------------------------------- Module Front Office End--------------------------------------------------------------------------------------


------------------------------- Module Middle Office Start---------------------------------------------------------------
--Middle Office
--Credit Risks and Analysis

update application_functions set document_path = 'Middle Office/Credit Risks and Analysis/Calculate_Credit_Exposure.htm' where function_id =10191800
update application_functions set document_path = 'Middle Office/Credit Risks and Analysis/Maintain Counterparty.htm' where function_id =10191000
update application_functions set document_path = 'Middle Office/Credit Risks and Analysis/Run  Exposure Concentration Report.htm' where function_id =10191500
update application_functions set document_path = 'Middle Office/Credit Risks and Analysis/Run Credit Exposure Report.htm' where function_id =10191300
update application_functions set document_path = 'Middle Office/Credit Risks and Analysis/Run Credit Reserve Report.htm' where function_id =10191600
update application_functions set document_path = 'Middle Office/Credit Risks and Analysis/Run Fixed_MTM Exposure Report.htm' where function_id =10191400

--Deal Verification and Confirmation
update application_functions set document_path = 'Middle Office/Deal Verification and Confirmation/Confirm Transactions.htm' where function_id =10171000
update application_functions set document_path = 'Middle Office/Deal Verification and Confirmation/Lock_Unlock deals.htm' where function_id =10171200
update application_functions set document_path = 'Middle Office/Deal Verification and Confirmation/Run Unconfirmed Exception Report.htm' where function_id =10171300
update application_functions set document_path = 'Middle Office/Deal Verification and Confirmation/Transaction_Audit_Log_Report.htm' where function_id =10171100

--Reporting
update application_functions set document_path = 'Middle Office/Reporting/Dashboard Report Template.htm' where function_id =12111900
update application_functions set document_path = 'Middle Office/Reporting/Report Writer.htm' where function_id =10201000
update application_functions set document_path = 'Middle Office/Reporting/Run_DashBoard_Report.htm' where function_id=12111800

--Valuation and Risk Analysis
update application_functions set document_path = 'Middle Office/Valuation and Risk Analysis/Run MTM Process.htm' where function_id=10181000
update application_functions set document_path = 'Middle Office/Valuation and Risk Analysis/Run_MTM_Report.htm' where function_id=10181100
update application_functions set document_path = 'Middle Office/Valuation and Risk Analysis/View Volatility and Correlations Report.htm' where function_id=10182000

--Credit Risks and Analysis Child
update application_functions set document_path = 'Middle Office/Credit Risks and Analysis/Maintain Counterparty.htm' where function_id =10101115
update application_functions set document_path = 'Middle Office/Credit Risks and Analysis/Maintain Counterparty.htm' where function_id =10101122
update application_functions set document_path = 'Middle Office/Credit Risks and Analysis/Maintain Counterparty.htm' where function_id =10101116
update application_functions set document_path = 'Middle Office/Credit Risks and Analysis/Maintain Counterparty.htm' where function_id =10101118
update application_functions set document_path = 'Middle Office/Deal Verification and Confirmation/Confirm Transactions.htm' where function_id =10171010
update application_functions set document_path = 'Middle Office/Deal Verification and Confirmation/Confirm Transactions.htm' where function_id =10171011
update application_functions set document_path = 'Middle Office/Deal Verification and Confirmation/Confirm Transactions.htm' where function_id =10171016
update application_functions set document_path = 'Middle Office/Reporting/Dashboard Report Template.htm' where function_id =12111910
update application_functions set document_path = 'Middle Office/Reporting/Dashboard Report Template.htm' where function_id =12111912
update application_functions set document_path = 'Middle Office/Reporting/Report Writer.htm' where function_id =10201010
------------------------------- Module Middle Office End--------------------------------------------


------------------------------- Bookmark section start --------------------------------------------
--Maintain Staic Data
--Maitain Static Data Detail
update application_functions set document_path = 'Administration/Setup/maintain_static_data.htm' where function_id =10121412

update application_functions set document_path = 'Administration/Setup/maintain_static_data.htm' where function_id =10101023

update application_functions set document_path = 'Administration/Setup/maintain_static_data.htm' where function_id =10101030

update application_functions set document_path = 'Administration/Setup/maintain_static_data.htm' where function_id =10101012

update application_functions set document_path = 'Administration/Setup/maintain_static_data.htm' where function_id =10101013

update application_functions set document_path = 'Administration/Setup/maintain_static_data.htm' where function_id =10101015

update application_functions set document_path = 'Administration/Setup/maintain_static_data.htm' where function_id =10101017 

update application_functions set document_path = 'Administration/Setup/maintain_static_data.htm' where function_id =10101019

update application_functions set document_path = 'Administration/Setup/maintain_static_data.htm' where function_id =10101031

update application_functions set document_path = 'Administration/Setup/maintain_static_data.htm' where function_id =10101024  
 

--Holiday Calendar
update application_functions set document_path = 'Administration/Setup/maintain_static_data.htm' where function_id =10101021
--Eligibilty
update application_functions set document_path = 'Administration/Setup/maintain_static_data.htm' where function_id =12101614


--Maintain Definition
update application_functions set document_path = 'Administration/Setup/maintain_definition.htm' where function_id =10101110

update application_functions set document_path = 'Administration/Setup/maintain_definition.htm' where function_id =10101111


update application_functions set document_path = 'Administration/Setup/maintain_definition.htm' where function_id =10101112


update application_functions set document_path = 'Administration/Setup/maintain_definition.htm' where function_id =10101113


--update application_functions set document_path = 'Administration/Setup/maintain_definition.htm' where function_id =10101115


update application_functions set document_path = 'Administration/Setup/maintain_definition.htm' where function_id =10101129


update application_functions set document_path = 'Administration/Setup/maintain_definition.htm' where function_id =10101130

update application_functions set document_path = 'Administration/Setup/maintain_definition.htm' where function_id =10101135


update application_functions set document_path = 'Administration/Setup/maintain_definition.htm' where function_id =10101138


update application_functions set document_path = 'Administration/Setup/maintain_definition.htm' where function_id =10101144


update application_functions set document_path = 'Administration/Setup/maintain_definition.htm' where function_id =10101145


update application_functions set document_path = 'Administration/Setup/maintain_definition.htm' where function_id =10101151

------------------------------- Bookmark section End --------------------------------------------



------------------------------- Module Middle Office End---------------------------------------------------------------