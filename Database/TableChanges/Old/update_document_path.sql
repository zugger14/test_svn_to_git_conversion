/*
	script by:    Bikash Subba
	created date: 19th June 2009
	Object :      Update document path for newly inserted function_id to open help file

*/

--BEGIN TRAN 
--
--UPDATE  new
--SET     new.document_path = old.document_path
--FROM    dbo.application_functions new
--        INNER JOIN oldTRM.dbo.application_functions old ON old.function_call = new.function_call
--WHERE   old.document_path <> 'null' 
--
--COMMIT
update application_functions set document_path='Hedge_Accounting_Strategy/Administration/map_GL_codes.htm' where function_id=10101000 

update application_functions set document_path='Hedge_Accounting_Strategy/Administration/maintain_definition.htm' where function_id=10101100 

update application_functions set document_path='Hedge_Accounting_Strategy/Administration/maintain_definition.htm' where function_id=10101110 

update application_functions set document_path='Hedge_Accounting_Strategy/Administration/maintain_definition.htm' where function_id=10101111 

update application_functions set document_path='Hedge_Accounting_Strategy/Administration/maintain_definition.htm' where function_id=10101112 

update application_functions set document_path='Hedge_Accounting_Strategy/Administration/maintain_definition.htm' where function_id=10101113 

update application_functions set document_path='Hedge_Accounting_Strategy/Administration/maintain_definition.htm' where function_id=10101114 

update application_functions set document_path='Hedge_Accounting_Strategy/Administration/maintain_definition.htm' where function_id=10101115 

update application_functions set document_path='Hedge_Accounting_Strategy/Administration/maintain_definition.htm' where function_id=10101118 

update application_functions set document_path='Hedge_Accounting_Strategy/Administration/maintain_definition.htm' where function_id=10101129 

update application_functions set document_path='Hedge_Accounting_Strategy/Administration/maintain_definition.htm' where function_id=10101130 

update application_functions set document_path='Hedge_Accounting_Strategy/Administration/maintain_definition.htm' where function_id=10101135 

update application_functions set document_path='Hedge_Accounting_Strategy/Administration/maintain_definition.htm' where function_id=10101144 

update application_functions set document_path='Hedge_Accounting_Strategy/Administration/maintain_definition.htm' where function_id=10101145 

update application_functions set document_path='Hedge_Accounting_Strategy/Set_Up_Hedging_Strategies/Setup__Hedging_strategies.htm' where function_id=10101200 

update application_functions set document_path='Hedge_Accounting_Strategy/Administration/map_GL_codes.htm' where function_id=10101300 

update application_functions set document_path='Hedge_Accounting_Strategy/Administration/maintain_deal_template.htm' where function_id=10101400 

update application_functions set document_path='Hedge_Accounting_Strategy/Administration/maintain_netting_asset-liab_groups.htm' where function_id=10101500 

update application_functions set document_path='Hedge_Accounting_Strategy/Administration/maintain_users.htm' where function_id=10111000 

update application_functions set document_path='Hedge_Accounting_Strategy/Administration/maintain_users.htm' where function_id=10111010 

update application_functions set document_path='Hedge_Accounting_Strategy/Administration/maintain_roles.htm' where function_id=10111100 

update application_functions set document_path='Hedge_Accounting_Strategy/Administration/maintain_users.htm' where function_id=10111112 

update application_functions set document_path='Hedge_Accounting_Strategy/Administration/Maintain_Work_Flow_Menu.htm' where function_id=10111200 

update application_functions set document_path='Hedge_Accounting_Strategy/Administration/run_privilege_report.htm' where function_id=10111300 

update application_functions set document_path='Hedge_Accounting_Strategy/Administration/run_system_access_log_report.htm' where function_id=10111400 

update application_functions set document_path='_administrative_setup/approve_control_activities.htm' where function_id=10121100 

update application_functions set document_path='_administrative_setup/perform_control_activities.htm' where function_id=10121200 

update application_functions set document_path='_administrative_setup/view_processes.htm' where function_id=10121600 

update application_functions set document_path='_administrative_setup/report_status_on_control_activities.htm' where function_id=10121700 

update application_functions set document_path='Transaction_Processing/maintain_transaction/maintain_transaction.htm' where function_id=10131000 

update application_functions set document_path='Assessment_Of_Hedge_Effectiveness/View_Price/view_price.htm' where function_id=10151000 

update application_functions set document_path='_transaction.processing/Run_Confirm_Module.htm' where function_id=10171000 

update application_functions set document_path='Ongoing_Assessment&Measurement/Run_MTM/Run_MTM.htm' where function_id=10181000 

update application_functions set document_path='Reports/Run_MTM_Report/Run_MTM_Report.htm' where function_id=10181100 

update application_functions set document_path='_reports/Run_Wght_Avg_Inventory_Cost_Report.htm' where function_id=10231200 

update application_functions set document_path='_reports/rec_inventory_journal_entry.htm' where function_id=10231700 

update application_functions set document_path='Hedge_Accounting_Strategy/Setup_Hedging_Relationship_Types/Setup_Hedging_Relationship_Types.htm' where function_id=10231900 

update application_functions set document_path='Hedge_Accounting_Strategy/Run_Setup_Heging_Relationship_Types_Report/Run_Setup_hedging_Relationship_type_report.htm' where function_id=10232000 

update application_functions set document_path='Hedge_Accounting_Strategy/Manage_Documents/Manage_documents.htm' where function_id=10232200 

update application_functions set document_path='Assessment_Of_Hedge_Effectiveness/Run_Assessment/Run_Assessment.htm' where function_id=10232300 

update application_functions set document_path='Assessment_Of_Hedge_Effectiveness/View_Assessment_Results/View_Assessment_Result.htm' where function_id=10232400 

update application_functions set document_path='Assessment_Of_Hedge_Effectiveness/Run_What_If_Effectiveness_Analysis/Run_What-If_Effective_Analysis.htm' where function_id=10232600 

update application_functions set document_path='Deal_capture_or_risk_system/Import_Data/Import_data.htm' where function_id=10232700 

update application_functions set document_path='Ongoing_Assessment&Measurement/Run_what_If_Measurement_Analysis/Run_What_If_Measurement_Analysis.htm' where function_id=10233200 

update application_functions set document_path='Ongoing_Assessment&Measurement/Run_Measurement/Run_Measurement.htm' where function_id=10233400 

update application_functions set document_path='Ongoing_Assessment&Measurement/Close_Accounting_Period/Close_Accounting_Period.htm' where function_id=10233600 

update application_functions set document_path='Transaction_Processing/Designation_of_a_Hedge/Designation_of_a_Hedge.htm' where function_id=10233700 

update application_functions set document_path='Transaction_Processing/Designation_of_a_Hedge/Designation_of_a_Hedge.htm' where function_id=10233710 

update application_functions set document_path='Reports/Measurement_Report/Measurement_Report.htm' where function_id=10234900 

update application_functions set document_path='Reports/Run_Measurement_Trend_Graph/Run_Masurement_Trend_Graph.htm' where function_id=10235000 

update application_functions set document_path='Reports/Run_Period_Change_Values_Report/Run_Period_Change_Values_Report.htm' where function_id=10235100 

update application_functions set document_path='Reports/AOCI_Report/AOCI_Report.htm' where function_id=10235200 

update application_functions set document_path='Reports/Run_De-designation_Values_Report/Run_De-designation_Values_Report.htm' where function_id=10235300 

update application_functions set document_path='Reports/Run_Journal_Entry_Report/Run_Journal_Entry_Report.htm' where function_id=10235400 

update application_functions set document_path='Reports/Run_Netted_Journal_Entry_Report/Run_Netted_Journal_Entry_report.htm' where function_id=10235500 

update application_functions set document_path='Reports/Run_Disclosure_Report/Run_Accounting_Disclosure_Report.htm' where function_id=10235600 

update application_functions set document_path='Reports/Run_Disclosure_Report/Run_Net_Assets_Report.htm' where function_id=10235700 

update application_functions set document_path='Reports/Run_Assessment_Report/Run_Assessment_Report.htm' where function_id=10235800 

update application_functions set document_path='Reports/Run_Transaction_Report/Run_Transaction_Report.htm' where function_id=10235900 

update application_functions set document_path='Reports/Run_Exception_Report/Run_Missing_Assessment_Values_Report.htm' where function_id=10236100 

update application_functions set document_path='Reports/Run_Exception_Report/Run_Fail_Assessment_Values_Report.htm' where function_id=10236200 

update application_functions set document_path='Reports/Run_Exception_Report/Run_Unapproved_Hedge_Relationship_Exception_Report.htm' where function_id=10236300 

update application_functions set document_path='Reports/Run_Exception_Report/Run_Available_Hedge_Capacity_Exception_Report.htm' where function_id=10236400 

update application_functions set document_path='Reports/Run_Exception_Report/Run_Not_Mapped_Deal_Report.htm' where function_id=10236500 








