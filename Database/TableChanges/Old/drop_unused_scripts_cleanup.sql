IF EXISTS (SELECT 1 from INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = N'Actuals') Begin Drop Table Actuals END 
IF EXISTS (SELECT 1 from INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = N'books') Begin Drop Table books END
IF EXISTS (SELECT 1 from INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = N'c') Begin Drop Table c END
IF EXISTS (SELECT 1 from INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = N'calc_process_log') Begin Drop Table calc_process_log END
IF EXISTS (SELECT 1 from INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = N'calc_whatif_scenario') Begin Drop Table calc_whatif_scenario END
IF EXISTS (SELECT 1 from INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = N'commodity_hour_map') Begin Drop Table commodity_hour_map END
IF EXISTS (SELECT 1 from INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = N'company_type_value') Begin Drop Table company_type_value END
IF EXISTS (SELECT 1 from INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = N'compliance_year') Begin Drop Table compliance_year END
IF EXISTS (SELECT 1 from INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = N'data_source_type') Begin Drop Table data_source_type END
IF EXISTS (SELECT 1 from INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = N'deleted') Begin Drop Table deleted END
IF EXISTS (SELECT 1 from INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = N'edr_staging_monitor_hourly_data') Begin Drop Table edr_staging_monitor_hourly_data END
IF EXISTS (SELECT 1 from INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = N'expired_report_hourly_position_breakdown') Begin Drop Table expired_report_hourly_position_breakdown END
IF EXISTS (SELECT 1 from INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = N'expired_report_hourly_position_deal') Begin Drop Table expired_report_hourly_position_deal END
IF EXISTS (SELECT 1 from INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = N'expired_report_hourly_position_profile') Begin Drop Table expired_report_hourly_position_profile END
IF EXISTS (SELECT 1 from INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = N'fas_accrual_accounting_pnl') Begin Drop Table fas_accrual_accounting_pnl END
IF EXISTS (SELECT 1 from INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = N'fas_mtm_accounting_pnl') Begin Drop Table fas_mtm_accounting_pnl END
IF EXISTS (SELECT 1 from INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = N'fas_unlinked_deals') Begin Drop Table fas_unlinked_deals END
IF EXISTS (SELECT 1 from INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = N'formula_breakdown_benchmark') Begin Drop Table formula_breakdown_benchmark END
IF EXISTS (SELECT 1 from INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = N'formula_editor_bkp') Begin Drop Table formula_editor_bkp END
IF EXISTS (SELECT 1 from INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = N'formula_nested_bkp') Begin Drop Table formula_nested_bkp END
IF EXISTS (SELECT 1 from INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = N'forward_curve_mapping') Begin Drop Table forward_curve_mapping END
IF EXISTS (SELECT 1 from INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = N'gen_deals_transfer_status') Begin Drop Table gen_deals_transfer_status END
IF EXISTS (SELECT 1 from INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = N'gl_inventory_account_type') Begin Drop Table gl_inventory_account_type END
IF EXISTS (SELECT 1 from INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = N'grp_chck') Begin Drop Table grp_chck END
IF EXISTS (SELECT 1 from INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = N'hedge_deferral1') Begin Drop Table hedge_deferral1 END
IF EXISTS (SELECT 1 from INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = N'import_filter_deal') Begin Drop Table import_filter_deal END
IF EXISTS (SELECT 1 from INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = N'inserted') Begin Drop Table inserted END
IF EXISTS (SELECT 1 from INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = N'iptrace') Begin Drop Table iptrace END
IF EXISTS (SELECT 1 from INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = N'mv90_data_proxy_mins') Begin Drop Table mv90_data_proxy_mins END
IF EXISTS (SELECT 1 from INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = N'Numbers') Begin Drop Table Numbers END
IF EXISTS (SELECT 1 from INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = N'position_run_log') Begin Drop Table position_run_log END
IF EXISTS (SELECT 1 from INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = N'profile_hour_block') Begin Drop Table profile_hour_block END
IF EXISTS (SELECT 1 from INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = N'proxy_term') Begin Drop Table proxy_term END
IF EXISTS (SELECT 1 from INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = N'RDM_TEMP_SSIS') Begin Drop Table RDM_TEMP_SSIS END
IF EXISTS (SELECT 1 from INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = N'RDM_TEMP_SSIS_MTM') Begin Drop Table RDM_TEMP_SSIS_MTM END
IF EXISTS (SELECT 1 from INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = N'report_hourly_position_breakdown_benchmark') Begin Drop Table report_hourly_position_breakdown_benchmark END
IF EXISTS (SELECT 1 from INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = N'report_hourly_position_deal_benchmark') Begin Drop Table report_hourly_position_deal_benchmark END
IF EXISTS (SELECT 1 from INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = N'report_hourly_position_financial_benchmark') Begin Drop Table report_hourly_position_financial_benchmark END
IF EXISTS (SELECT 1 from INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = N'report_hourly_position_fixed_benchmark') Begin Drop Table report_hourly_position_fixed_benchmark END
IF EXISTS (SELECT 1 from INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = N'report_hourly_position_profile_benchmark') Begin Drop Table report_hourly_position_profile_benchmark END
IF EXISTS (SELECT 1 from INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = N'report_measurement_values_benchmark') Begin Drop Table report_measurement_values_benchmark END
IF EXISTS (SELECT 1 from INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = N'report_measurement_values_expired_benchmark') Begin Drop Table report_measurement_values_expired_benchmark END
IF EXISTS (SELECT 1 from INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = N'report_measurement_values_links') Begin Drop Table report_measurement_values_links END
IF EXISTS (SELECT 1 from INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = N'report_measurement_values_no_links') Begin Drop Table report_measurement_values_no_links END
IF EXISTS (SELECT 1 from INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = N'report_netted_gl_entry_benchmark') Begin Drop Table report_netted_gl_entry_benchmark END
IF EXISTS (SELECT 1 from INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = N'rpt_mtm_summary_by_deal_benchmark') Begin Drop Table rpt_mtm_summary_by_deal_benchmark END
IF EXISTS (SELECT 1 from INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = N'sap_trm_mapping') Begin Drop Table sap_trm_mapping END
IF EXISTS (SELECT 1 from INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = N'save_invoice_detail') Begin Drop Table save_invoice_detail END
IF EXISTS (SELECT 1 from INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = N'source_corr_curve') Begin Drop Table source_corr_curve END
IF EXISTS (SELECT 1 from INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = N'source_corr_curve_def') Begin Drop Table source_corr_curve_def END
IF EXISTS (SELECT 1 from INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = N'source_deal_audit') Begin Drop Table source_deal_audit END
IF EXISTS (SELECT 1 from INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = N'source_deal_broker') Begin Drop Table source_deal_broker END
IF EXISTS (SELECT 1 from INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = N'source_deal_OLD') Begin Drop Table source_deal_OLD END
IF EXISTS (SELECT 1 from INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = N'source_minor_location_meter1') Begin Drop Table source_minor_location_meter1 END
IF EXISTS (SELECT 1 from INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = N'SSIS_Configurations_BKP') Begin Drop Table SSIS_Configurations_BKP END
IF EXISTS (SELECT 1 from INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = N'ssis_position_formate2_archive') Begin Drop Table ssis_position_formate2_archive END
IF EXISTS (SELECT 1 from INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = N'tagging_endur') Begin Drop Table tagging_endur END
IF EXISTS (SELECT 1 from INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = N'temp1') Begin Drop Table temp1 END
IF EXISTS (SELECT 1 from INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = N'tmp_spc') Begin Drop Table tmp_spc END
IF EXISTS (SELECT 1 from INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = N'user_defined_deal_detail_fields_audit_old') Begin Drop Table user_defined_deal_detail_fields_audit_old END
IF EXISTS (SELECT 1 from INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = N'user_defined_deal_detail_fields_audit_org') Begin Drop Table user_defined_deal_detail_fields_audit_org END
IF EXISTS (SELECT 1 from INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = N'user_defined_deal_detail_fields_old') Begin Drop Table user_defined_deal_detail_fields_old END
IF EXISTS (SELECT 1 from INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = N'user_defined_deal_detail_fields_org') Begin Drop Table user_defined_deal_detail_fields_org END
--IF EXISTS (SELECT 1 from INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = N'workflow_activities_audit_summary') Begin Drop Table workflow_activities_audit_summary END

IF EXISTS(select 1 FROM sys.views where name =  'create_view_delta_report_hourly_position' ) BEGIN DROP VIEW create_view_delta_report_hourly_position END
IF EXISTS(select 1 FROM sys.views where name =  'create_view_report_hourly_position_breakdown' ) BEGIN DROP VIEW create_view_report_hourly_position_breakdown END
IF EXISTS(select 1 FROM sys.views where name =  'create_view_report_hourly_position_deal' ) BEGIN DROP VIEW create_view_report_hourly_position_deal END
IF EXISTS(select 1 FROM sys.views where name =  'create_view_report_hourly_position_profile' ) BEGIN DROP VIEW create_view_report_hourly_position_profile END
--IF EXISTS(select 1 FROM sys.views where name =  'Deal Settlement View' ) BEGIN DROP VIEW Deal Settlement View END
IF EXISTS(select 1 FROM sys.views where name =  'partition12C1_create_view_cached_curve' ) BEGIN DROP VIEW partition12C1_create_view_cached_curve END
IF EXISTS(select 1 FROM sys.views where name =  'partition12C1_create_view_source_price_curve' ) BEGIN DROP VIEW partition12C1_create_view_source_price_curve END
IF EXISTS(select 1 FROM sys.views where name =  'partition12C2_create_view_allocation_data' ) BEGIN DROP VIEW partition12C2_create_view_allocation_data END
IF EXISTS(select 1 FROM sys.views where name =  'partition12C3_create_view_position' ) BEGIN DROP VIEW partition12C3_create_view_position END
IF EXISTS(select 1 FROM sys.views where name =  'partition12C4_create_view_nomination' ) BEGIN DROP VIEW partition12C4_create_view_nomination END
IF EXISTS(select 1 FROM sys.views where name =  'partition12C5_create_view_settlement' ) BEGIN DROP VIEW partition12C5_create_view_settlement END
IF EXISTS(select 1 FROM sys.views where name =  'partition12C6_create_view_MTM' ) BEGIN DROP VIEW partition12C6_create_view_MTM END
IF EXISTS(select 1 FROM sys.views where name =  'partition12C7_create_view_fx_exposure' ) BEGIN DROP VIEW partition12C7_create_view_fx_exposure END
IF EXISTS(select 1 FROM sys.views where name =  'vw_delta_report_hourly_position_breakdown' ) BEGIN DROP VIEW vw_delta_report_hourly_position_breakdown END
IF EXISTS(select 1 FROM sys.views where name =  'vw_report_hourly_position_breakdown' ) BEGIN DROP VIEW vw_report_hourly_position_breakdown END
IF EXISTS(select 1 FROM sys.views where name =  'vwHourly_position_AllFilter_financial' ) BEGIN DROP VIEW vwHourly_position_AllFilter_financial END
IF EXISTS(select 1 FROM sys.views where name =  'vwHourly_position_monthly_AllFilter' ) BEGIN DROP VIEW vwHourly_position_monthly_AllFilter END
IF EXISTS(select 1 FROM sys.views where name =  'vwHourly_position_monthly_AllFilter_breakdown' ) BEGIN DROP VIEW vwHourly_position_monthly_AllFilter_breakdown END
IF EXISTS(select 1 FROM sys.views where name =  'vwHoursForDSTAppliedDate' ) BEGIN DROP VIEW vwHoursForDSTAppliedDate END

IF EXISTS(select 1 FROM sys.views where name =  'farrms_sysjobactivity' ) BEGIN DROP VIEW farrms_sysjobactivity END
IF EXISTS(select 1 FROM sys.views where name =  'lag_view' ) BEGIN DROP VIEW lag_view END
IF EXISTS(select 1 FROM sys.views where name =  'View_FTMeasurement' ) BEGIN DROP VIEW View_FTMeasurement END
IF EXISTS(select 1 FROM sys.views where name =  'vwDealDetail' ) BEGIN DROP VIEW vwDealDetail END
IF EXISTS(select 1 FROM sys.views where name =  'vwDetailedMeasurement' ) BEGIN DROP VIEW vwDetailedMeasurement END
IF EXISTS(select 1 FROM sys.views where name =  'vwEmbDealVolumeVariance' ) BEGIN DROP VIEW vwEmbDealVolumeVariance END
IF EXISTS(select 1 FROM sys.views where name =  'vwEmbDerMTM' ) BEGIN DROP VIEW vwEmbDerMTM END
IF EXISTS(select 1 FROM sys.views where name =  'vwSettledMTMValues' ) BEGIN DROP VIEW vwSettledMTMValues END

IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'BackupDB') Begin  Drop Procedure BackupDB  END
IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'deal_replicate') Begin  Drop Procedure deal_replicate  END
IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'deal_replicate_caller') Begin  Drop Procedure deal_replicate_caller  END
IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'fake_transaction_log') Begin  Drop Procedure fake_transaction_log  END
IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'FNAGetLogicalTerm') Begin  Drop Procedure FNAGetLogicalTerm  END
IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'FNAGetNextFirstDate_s') Begin  Drop Procedure FNAGetNextFirstDate_s  END
IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'FNANextInstanceCreationDatetmp') Begin  Drop Procedure FNANextInstanceCreationDatetmp  END
IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'gettemptablename') Begin  Drop Procedure gettemptablename  END
IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'Perfcounter') Begin  Drop Procedure Perfcounter  END
IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'schedule_detail_report') Begin  Drop Procedure schedule_detail_report  END
IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'spa_Adiha_process_table_drop') Begin  Drop Procedure spa_Adiha_process_table_drop  END
IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'spa_AppendToFile') Begin  Drop Procedure spa_AppendToFile  END
IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'spa_application_user') Begin  Drop Procedure spa_application_user  END
IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'spa_audit_trail') Begin  Drop Procedure spa_audit_trail  END
IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'spa_auto_matching_jobaaaa') Begin  Drop Procedure spa_auto_matching_jobaaaa  END
IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'spa_blotter_deal_hidden') Begin  Drop Procedure spa_blotter_deal_hidden  END
IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'spa_calc_auto_pre_post_test') Begin  Drop Procedure spa_calc_auto_pre_post_test  END
IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'spa_calc_embedded_deal') Begin  Drop Procedure spa_calc_embedded_deal  END
IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'spa_calc_explain_position_job') Begin  Drop Procedure spa_calc_explain_position_job  END
IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'spa_calc_financial_forecast') Begin  Drop Procedure spa_calc_financial_forecast  END
IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'spa_calc_gross_net') Begin  Drop Procedure spa_calc_gross_net  END
IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'spa_calc_invoice_detail') Begin  Drop Procedure spa_calc_invoice_detail  END
IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'spa_calc_invoice_t') Begin  Drop Procedure spa_calc_invoice_t  END
IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'spa_calc_price_change_value') Begin  Drop Procedure spa_calc_price_change_value  END
IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'spa_calc_rdb_variance') Begin  Drop Procedure spa_calc_rdb_variance  END
IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'spa_calc_shift_value') Begin  Drop Procedure spa_calc_shift_value  END
IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'spa_calc_value_report') Begin  Drop Procedure spa_calc_value_report  END
IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'spa_cancel_job') Begin  Drop Procedure spa_cancel_job  END
IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'spa_close_measurement_books_archieve') Begin  Drop Procedure spa_close_measurement_books_archieve  END
IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'spa_closing_month_msmt') Begin  Drop Procedure spa_closing_month_msmt  END
IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'spa_closing_month_msmt_job') Begin  Drop Procedure spa_closing_month_msmt_job  END
IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'spa_closing_Year') Begin  Drop Procedure spa_closing_Year  END
IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'spa_closing_year_job') Begin  Drop Procedure spa_closing_year_job  END
IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'spa_collect_price_curves_for_whatif_scenario') Begin  Drop Procedure spa_collect_price_curves_for_whatif_scenario  END
IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'spa_collect_std_deals_for_whatif_scenario') Begin  Drop Procedure spa_collect_std_deals_for_whatif_scenario  END
IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'spa_company_source_sink_type_temp') Begin  Drop Procedure spa_company_source_sink_type_temp  END
IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'spa_company_source_sink_type_temp_value') Begin  Drop Procedure spa_company_source_sink_type_temp_value  END
IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'spa_company_template_parameter_value') Begin  Drop Procedure spa_company_template_parameter_value  END
IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'spa_compliance_source_deal_header') Begin  Drop Procedure spa_compliance_source_deal_header  END
IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'spa_copy_missing_price') Begin  Drop Procedure spa_copy_missing_price  END
IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'spa_Create_AOCI_Report_process') Begin  Drop Procedure spa_Create_AOCI_Report_process  END
IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'spa_Create_Deal_Audit_Report_new') Begin  Drop Procedure spa_Create_Deal_Audit_Report_new  END
IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'spa_Create_Deal_Audit_Report_paging') Begin  Drop Procedure spa_Create_Deal_Audit_Report_paging  END
IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'spa_Create_Disclosure_Report_Final') Begin  Drop Procedure spa_Create_Disclosure_Report_Final  END
IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'spa_Create_Hedge_Rel_Audit_Report_paging') Begin  Drop Procedure spa_Create_Hedge_Rel_Audit_Report_paging  END
IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'spa_Create_Hedges_Measurement_Report_Backup061703') Begin  Drop Procedure spa_Create_Hedges_Measurement_Report_Backup061703  END
IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'spa_Create_Hedges_Measurement_Report_Final') Begin  Drop Procedure spa_Create_Hedges_Measurement_Report_Final  END
IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'spa_Create_Hedges_PNL_Deferral_Report_paging') Begin  Drop Procedure spa_Create_Hedges_PNL_Deferral_Report_paging  END
IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'spa_create_hourly_position_report_NEW') Begin  Drop Procedure spa_create_hourly_position_report_NEW  END
IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'spa_create_hourly_position_report_t') Begin  Drop Procedure spa_create_hourly_position_report_t  END
IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'spa_create_hourly_position_report1') Begin  Drop Procedure spa_create_hourly_position_report1  END
IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'spa_create_imbalance_report_paging') Begin  Drop Procedure spa_create_imbalance_report_paging  END
IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'spa_Create_Inventory_Journal_Entry_Report_New') Begin  Drop Procedure spa_Create_Inventory_Journal_Entry_Report_New  END
IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'spa_Create_MTM_Measurement_Report_Final') Begin  Drop Procedure spa_Create_MTM_Measurement_Report_Final  END
IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'spa_Create_MTM_Period_Report_old') Begin  Drop Procedure spa_Create_MTM_Period_Report_old  END
IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'spa_create_mtm_series_for_link') Begin  Drop Procedure spa_create_mtm_series_for_link  END
IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'spa_create_Partition_file_group') Begin  Drop Procedure spa_create_Partition_file_group  END
IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'spa_create_target_position_report_paging') Begin  Drop Procedure spa_create_target_position_report_paging  END
IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'spa_createHTMLReportOnSQLStmt') Begin  Drop Procedure spa_createHTMLReportOnSQLStmt  END
IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'spa_cube') Begin  Drop Procedure spa_cube  END
IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'spa_cube_notifications') Begin  Drop Procedure spa_cube_notifications  END
IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'spa_cube_process') Begin  Drop Procedure spa_cube_process  END
IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'spa_cube_process_as_job') Begin  Drop Procedure spa_cube_process_as_job  END
IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'spa_customer_detail') Begin  Drop Procedure spa_customer_detail  END
IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'spa_dashboard_deal') Begin  Drop Procedure spa_dashboard_deal  END
IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'spa_data_transfer_to_physical_tables') Begin  Drop Procedure spa_data_transfer_to_physical_tables  END
IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'spa_deal_comment_history') Begin  Drop Procedure spa_deal_comment_history  END
IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'spa_deal_exercise_detail') Begin  Drop Procedure spa_deal_exercise_detail  END
IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'spa_deal_rec_properties') Begin  Drop Procedure spa_deal_rec_properties  END
IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'spa_default_deal_post_values') Begin  Drop Procedure spa_default_deal_post_values  END
IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'spa_dice_vs_host') Begin  Drop Procedure spa_dice_vs_host  END
IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'spa_DoTransaction_tmp') Begin  Drop Procedure spa_DoTransaction_tmp  END
IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'spa_DoTransaction2') Begin  Drop Procedure spa_DoTransaction2  END
IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'spa_dynamic_slide') Begin  Drop Procedure spa_dynamic_slide  END
IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'spa_edr_file_import_prototype') Begin  Drop Procedure spa_edr_file_import_prototype  END
IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'spa_edr_file_map') Begin  Drop Procedure spa_edr_file_map  END
IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'spa_emissions_tracking_report') Begin  Drop Procedure spa_emissions_tracking_report  END
IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'spa_ems_demand_side_mgmt') Begin  Drop Procedure spa_ems_demand_side_mgmt  END
IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'spa_ems_exceptions_report_paging') Begin  Drop Procedure spa_ems_exceptions_report_paging  END
IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'spa_ems_listReportWriterElements') Begin  Drop Procedure spa_ems_listReportWriterElements  END
IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'spa_ems_pdf_report') Begin  Drop Procedure spa_ems_pdf_report  END
IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'spa_ems_source_model_program') Begin  Drop Procedure spa_ems_source_model_program  END
IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'spa_eod_calc_remnant_position_after_forecast_update') Begin  Drop Procedure spa_eod_calc_remnant_position_after_forecast_update  END
IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'spa_eod_functional_check') Begin  Drop Procedure spa_eod_functional_check  END
IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'spa_export_hedge_item_paging') Begin  Drop Procedure spa_export_hedge_item_paging  END
IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'spa_FindPercAvailableToLink') Begin  Drop Procedure spa_FindPercAvailableToLink  END
IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'spa_FindString') Begin  Drop Procedure spa_FindString  END
IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'spa_formula_editor_t') Begin  Drop Procedure spa_formula_editor_t  END
IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'spa_formula_nested_validator') Begin  Drop Procedure spa_formula_nested_validator  END
IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'spa_gen_invoice_variance_report_tmp') Begin  Drop Procedure spa_gen_invoice_variance_report_tmp  END
IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'spa_generate_exceptions') Begin  Drop Procedure spa_generate_exceptions  END
IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'spa_generate_position_breakdown_data_job_backup') Begin  Drop Procedure spa_generate_position_breakdown_data_job_backup  END
IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'spa_get_all_function_id_tmp') Begin  Drop Procedure spa_get_all_function_id_tmp  END
IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'spa_get_application_functions') Begin  Drop Procedure spa_get_application_functions  END
IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'spa_get_broker_values') Begin  Drop Procedure spa_get_broker_values  END
IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'spa_get_calc_history') Begin  Drop Procedure spa_get_calc_history  END
IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'spa_get_counterparty_bank_info') Begin  Drop Procedure spa_get_counterparty_bank_info  END
IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'spa_get_curve_value') Begin  Drop Procedure spa_get_curve_value  END
IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'spa_get_EIA_1605_forms_header_info') Begin  Drop Procedure spa_get_EIA_1605_forms_header_info  END
IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'spa_get_emissions_inventory_edr') Begin  Drop Procedure spa_get_emissions_inventory_edr  END
IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'spa_get_emissions_inventory_edr_paging') Begin  Drop Procedure spa_get_emissions_inventory_edr_paging  END
IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'spa_get_fas_id') Begin  Drop Procedure spa_get_fas_id  END
IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'spa_get_hourly_deal_data') Begin  Drop Procedure spa_get_hourly_deal_data  END
IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'spa_get_invoice_info_rdl') Begin  Drop Procedure spa_get_invoice_info_rdl  END
IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'spa_get_limit_report') Begin  Drop Procedure spa_get_limit_report  END
IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'spa_get_location_meter_n_loss_factor') Begin  Drop Procedure spa_get_location_meter_n_loss_factor  END
IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'spa_get_mitigate_activities') Begin  Drop Procedure spa_get_mitigate_activities  END
IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'spa_get_mult_pnl') Begin  Drop Procedure spa_get_mult_pnl  END
IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'spa_get_outstanding_control_activities') Begin  Drop Procedure spa_get_outstanding_control_activities  END
IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'spa_get_outstanding_control_activities_job_t') Begin  Drop Procedure spa_get_outstanding_control_activities_job_t  END
IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'spa_get_past_process_proofs') Begin  Drop Procedure spa_get_past_process_proofs  END
IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'spa_get_php_path') Begin  Drop Procedure spa_get_php_path  END
IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'spa_get_price_series_types') Begin  Drop Procedure spa_get_price_series_types  END
IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'spa_get_process_id') Begin  Drop Procedure spa_get_process_id  END
IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'spa_Get_Risk_Control_Activities_Reminder') Begin  Drop Procedure spa_Get_Risk_Control_Activities_Reminder  END
IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'spa_get_section_name') Begin  Drop Procedure spa_get_section_name  END
IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'spa_get_sub_ids_for_risk_control') Begin  Drop Procedure spa_get_sub_ids_for_risk_control  END
IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'spa_get_user_reports_to_report') Begin  Drop Procedure spa_get_user_reports_to_report  END
IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'spa_Get_Volume_UOM') Begin  Drop Procedure spa_Get_Volume_UOM  END
IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'spa_get_wizard_page') Begin  Drop Procedure spa_get_wizard_page  END
IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'spa_get_xfer_deal_info') Begin  Drop Procedure spa_get_xfer_deal_info  END
IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'spa_get_xml_from_sp') Begin  Drop Procedure spa_get_xml_from_sp  END
--IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'spa_GetAccessRights') Begin  Drop Procedure spa_GetAccessRights  END
IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'spa_getallaccessrights_tmp') Begin  Drop Procedure spa_getallaccessrights_tmp  END
IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'spa_getallentities') Begin  Drop Procedure spa_getallentities  END
--IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'spa_getallFunctions') Begin  Drop Procedure spa_getallFunctions  END
IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'spa_GetAllSourceSystemBookIds') Begin  Drop Procedure spa_GetAllSourceSystemBookIds  END
IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'spa_GetAllStaticDataType') Begin  Drop Procedure spa_GetAllStaticDataType  END
IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'spa_GetAllStaticDataValue') Begin  Drop Procedure spa_GetAllStaticDataValue  END
IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'spa_GetAllSubsidiaries') Begin  Drop Procedure spa_GetAllSubsidiaries  END
IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'spa_getCalendarData_tmp') Begin  Drop Procedure spa_getCalendarData_tmp  END
IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'spa_getCalendarDataTmp') Begin  Drop Procedure spa_getCalendarDataTmp  END
IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'spa_getcertificate_detail') Begin  Drop Procedure spa_getcertificate_detail  END
--IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'spa_getContractMonths') Begin  Drop Procedure spa_getContractMonths  END
--IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'spa_geteffectivehedgereltypes') Begin  Drop Procedure spa_geteffectivehedgereltypes  END
IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'spa_getFTPFileName') Begin  Drop Procedure spa_getFTPFileName  END
IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'spa_getinheritAssessValuefromtype') Begin  Drop Procedure spa_getinheritAssessValuefromtype  END
--IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'spa_getsourcedealdetail') Begin  Drop Procedure spa_getsourcedealdetail  END
IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'spa_handle_alert_sql') Begin  Drop Procedure spa_handle_alert_sql  END
--IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'spa_haveSecurityRights') Begin  Drop Procedure spa_haveSecurityRights  END
IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'spa_holiday_calendar') Begin  Drop Procedure spa_holiday_calendar  END
IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'spa_hourly_deal_data') Begin  Drop Procedure spa_hourly_deal_data  END
IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'spa_import_deal_hourly_data_delete_insert') Begin  Drop Procedure spa_import_deal_hourly_data_delete_insert  END
IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'spa_import_deal_hourly_data_update_insert') Begin  Drop Procedure spa_import_deal_hourly_data_update_insert  END
IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'spa_import_hourly_data_t') Begin  Drop Procedure spa_import_hourly_data_t  END
IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'spa_import_mv90_data_reprocess') Begin  Drop Procedure spa_import_mv90_data_reprocess  END
IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'spa_import_RecTracker_Data') Begin  Drop Procedure spa_import_RecTracker_Data  END
--IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'spa_Insert_Assessment_Results') Begin  Drop Procedure spa_Insert_Assessment_Results  END
IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'spa_insert_position_schedule_xml_deal_test') Begin  Drop Procedure spa_insert_position_schedule_xml_deal_test  END
--IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'spa_insert_rec_deals') Begin  Drop Procedure spa_insert_rec_deals  END
IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'spa_InsertDealXmlBlotter') Begin  Drop Procedure spa_InsertDealXmlBlotter  END
IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'spa_InsertDealXmlBlotter_t') Begin  Drop Procedure spa_InsertDealXmlBlotter_t  END
IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'spa_InsertDealXmlBlotterV2_test') Begin  Drop Procedure spa_InsertDealXmlBlotterV2_test  END
IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'spa_interface_Adaptor_2') Begin  Drop Procedure spa_interface_Adaptor_2  END
IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'spa_interpolate_curve') Begin  Drop Procedure spa_interpolate_curve  END
IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'spa_is_valid_user_t') Begin  Drop Procedure spa_is_valid_user_t  END
IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'spa_item_sales_report') Begin  Drop Procedure spa_item_sales_report  END
IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'spa_last_saturday') Begin  Drop Procedure spa_last_saturday  END
IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'spa_limit_Validation') Begin  Drop Procedure spa_limit_Validation  END
IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'spa_line_item_calculation') Begin  Drop Procedure spa_line_item_calculation  END
IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'spa_load_forecasted_report') Begin  Drop Procedure spa_load_forecasted_report  END
IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'spa_maintain_portfolio_groups') Begin  Drop Procedure spa_maintain_portfolio_groups  END
IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'spa_maintain_price_curve_bk') Begin  Drop Procedure spa_maintain_price_curve_bk  END
IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'spa_maintain_price_curve_graph') Begin  Drop Procedure spa_maintain_price_curve_graph  END
IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'spa_maintain_price_curve_t') Begin  Drop Procedure spa_maintain_price_curve_t  END
IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'spa_maintain_price_curve_tmp') Begin  Drop Procedure spa_maintain_price_curve_tmp  END
IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'spa_maintain_price_curve_tmp1') Begin  Drop Procedure spa_maintain_price_curve_tmp1  END
IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'spa_maintain_price_curve1') Begin  Drop Procedure spa_maintain_price_curve1  END
IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'spa_manage_document') Begin  Drop Procedure spa_manage_document  END
--IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'spa_manual_curve_movement') Begin  Drop Procedure spa_manual_curve_movement  END
--IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'spa_max_in_archive') Begin  Drop Procedure spa_max_in_archive  END
IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'spa_Measurement_Process') Begin  Drop Procedure spa_Measurement_Process  END
IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'spa_message_board_t') Begin  Drop Procedure spa_message_board_t  END
IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'spa_mobile_alert') Begin  Drop Procedure spa_mobile_alert  END
IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'spa_msmt_excp_assmt_values_offset') Begin  Drop Procedure spa_msmt_excp_assmt_values_offset  END
IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'spa_msmt_excp_conv_factor') Begin  Drop Procedure spa_msmt_excp_conv_factor  END
IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'spa_msmt_excp_disc_factor') Begin  Drop Procedure spa_msmt_excp_disc_factor  END
--IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'spa_mv90_data_hour') Begin  Drop Procedure spa_mv90_data_hour  END
IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'spa_mv90_data_hour_delete') Begin  Drop Procedure spa_mv90_data_hour_delete  END
--IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'spa_netting_group_gain_loss') Begin  Drop Procedure spa_netting_group_gain_loss  END
IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'spa_order_detail') Begin  Drop Procedure spa_order_detail  END
IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'spa_order_report') Begin  Drop Procedure spa_order_report  END
--IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'spa_portfolio_hierarchy_rootnode') Begin  Drop Procedure spa_portfolio_hierarchy_rootnode  END
--IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'spa_portfolio_hierarchy_sublevel') Begin  Drop Procedure spa_portfolio_hierarchy_sublevel  END
IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'spa_position_allocation_breakdown') Begin  Drop Procedure spa_position_allocation_breakdown  END
IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'spa_position_report_regular_format') Begin  Drop Procedure spa_position_report_regular_format  END
IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'spa_position_report_sch_n_delivery_new') Begin  Drop Procedure spa_position_report_sch_n_delivery_new  END
IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'spa_process_functions') Begin  Drop Procedure spa_process_functions  END
IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'spa_process_risk_control_std_dependency') Begin  Drop Procedure spa_process_risk_control_std_dependency  END
IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'spa_process_risk_controls_status_date') Begin  Drop Procedure spa_process_risk_controls_status_date  END
IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'spa_process_settlement_invoice_job') Begin  Drop Procedure spa_process_settlement_invoice_job  END
IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'spa_publish_activity_table') Begin  Drop Procedure spa_publish_activity_table  END
--IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'spa_purge_measurement_results') Begin  Drop Procedure spa_purge_measurement_results  END
IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'spa_rate_schedule') Begin  Drop Procedure spa_rate_schedule  END
IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'spa_read_process_risk_controls_date') Begin  Drop Procedure spa_read_process_risk_controls_date  END
IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'spa_REC_Target_Report_tmp') Begin  Drop Procedure spa_REC_Target_Report_tmp  END
--IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'spa_reconciled_pnl') Begin  Drop Procedure spa_reconciled_pnl  END
IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'spa_report_group_parameters_criteria') Begin  Drop Procedure spa_report_group_parameters_criteria  END
IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'spa_report_group_template') Begin  Drop Procedure spa_report_group_template  END
IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'spa_report_group_template_group') Begin  Drop Procedure spa_report_group_template_group  END
IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'spa_report_group_template_header') Begin  Drop Procedure spa_report_group_template_header  END
IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'spa_Reprice_Items') Begin  Drop Procedure spa_Reprice_Items  END
IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'spa_rfx_custom_reports') Begin  Drop Procedure spa_rfx_custom_reports  END
IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'spa_rfx_export_import_binary_file') Begin  Drop Procedure spa_rfx_export_import_binary_file  END
IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'spa_rfx_export_report_job_2') Begin  Drop Procedure spa_rfx_export_report_job_2  END
IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'spa_risk_process_function_map_detail') Begin  Drop Procedure spa_risk_process_function_map_detail  END
IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'spa_risks_criteria_detail') Begin  Drop Procedure spa_risks_criteria_detail  END
IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'spa_rollover_forward2spot') Begin  Drop Procedure spa_rollover_forward2spot  END
IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'spa_run_cascaded_matching') Begin  Drop Procedure spa_run_cascaded_matching  END
IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'spa_run_cashflow_earnings_report_paging') Begin  Drop Procedure spa_run_cashflow_earnings_report_paging  END
IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'spa_run_edr_import_as_job') Begin  Drop Procedure spa_run_edr_import_as_job  END
IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'spa_run_emissions_whatif_report_paging') Begin  Drop Procedure spa_run_emissions_whatif_report_paging  END
IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'spa_run_existing_job') Begin  Drop Procedure spa_run_existing_job  END
IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'spa_run_job') Begin  Drop Procedure spa_run_job  END
IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'spa_run_measurement_process') Begin  Drop Procedure spa_run_measurement_process  END
IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'spa_run_sql_report') Begin  Drop Procedure spa_run_sql_report  END
IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'spa_save_hourly_deal_volume') Begin  Drop Procedure spa_save_hourly_deal_volume  END
IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'spa_save_xml_grid_data_tmp') Begin  Drop Procedure spa_save_xml_grid_data_tmp  END
IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'spa_soap_pratos_t') Begin  Drop Procedure spa_soap_pratos_t  END
IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'spa_source_deal_detail_hour_1') Begin  Drop Procedure spa_source_deal_detail_hour_1  END
IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'spa_source_legal_entity') Begin  Drop Procedure spa_source_legal_entity  END
IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'spa_sourcedeal') Begin  Drop Procedure spa_sourcedeal  END
IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'spa_sourcedealtemp_detail_paging_test') Begin  Drop Procedure spa_sourcedealtemp_detail_paging_test  END
IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'spa_sourcedealtemp_paging') Begin  Drop Procedure spa_sourcedealtemp_paging  END
IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'spa_sourcedealtemp_tmp') Begin  Drop Procedure spa_sourcedealtemp_tmp  END
IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'spa_split_metervolume') Begin  Drop Procedure spa_split_metervolume  END
IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'spa_static_data_category') Begin  Drop Procedure spa_static_data_category  END
IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'spa_Temp_Rwest_Deal') Begin  Drop Procedure spa_Temp_Rwest_Deal  END
IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'spa_Temp_Rwest_Gas') Begin  Drop Procedure spa_Temp_Rwest_Gas  END
IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'spa_template_batch') Begin  Drop Procedure spa_template_batch  END
IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'spa_tenor_bucket_header') Begin  Drop Procedure spa_tenor_bucket_header  END
IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'spa_testpaging') Begin  Drop Procedure spa_testpaging  END
IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'spa_testpaging_paging') Begin  Drop Procedure spa_testpaging_paging  END
IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'spa_trader_ticket_template') Begin  Drop Procedure spa_trader_ticket_template  END
IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'spa_unassign_rec_deals') Begin  Drop Procedure spa_unassign_rec_deals  END
IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'spa_update_buy_sell_flag_paging') Begin  Drop Procedure spa_update_buy_sell_flag_paging  END
IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'spa_update_gis_certificate_no') Begin  Drop Procedure spa_update_gis_certificate_no  END
IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'spa_update_gis_certificate_no_monthly') Begin  Drop Procedure spa_update_gis_certificate_no_monthly  END
IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'spa_update_hourly_deal_data') Begin  Drop Procedure spa_update_hourly_deal_data  END
IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'spa_update_SPs') Begin  Drop Procedure spa_update_SPs  END
IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'spa_UpdateAutomaticProcess') Begin  Drop Procedure spa_UpdateAutomaticProcess  END
IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'spa_UpdateRECXml') Begin  Drop Procedure spa_UpdateRECXml  END
IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'spa_VaR_calculation') Begin  Drop Procedure spa_VaR_calculation  END
IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'spa_virtual_relationship_detail') Begin  Drop Procedure spa_virtual_relationship_detail  END
IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'spa_what_if_scenario') Begin  Drop Procedure spa_what_if_scenario  END
IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'spa_whatif_criteria_book') Begin  Drop Procedure spa_whatif_criteria_book  END
IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'spa_whatif_criteria_deal') Begin  Drop Procedure spa_whatif_criteria_deal  END
IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'spa_xml_2_table_clm') Begin  Drop Procedure spa_xml_2_table_clm  END
IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'sps_RDBExport_MTM') Begin  Drop Procedure sps_RDBExport_MTM  END
IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'sps_RDBExport_POS') Begin  Drop Procedure sps_RDBExport_POS  END
IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'test_spa_InsertDealXmlBlotterV2') Begin  Drop Procedure test_spa_InsertDealXmlBlotterV2  END
IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'test_spa_transfer_book_position') Begin  Drop Procedure test_spa_transfer_book_position  END
IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'test_spa_UpdateFromXml') Begin  Drop Procedure test_spa_UpdateFromXml  END



IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'spa_sourcedeal') Begin  Drop Procedure spa_sourcedeal  END
IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'FNAGetNextFirstDate_s') Begin  Drop Procedure FNAGetNextFirstDate_s  END
IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'FNANextInstanceCreationDatetmp') Begin  Drop Procedure FNANextInstanceCreationDatetmp  END
IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'Perfcounter') Begin  Drop Procedure Perfcounter  END
IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'sp_generate_inserts') Begin  Drop Procedure sp_generate_inserts  END
IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'spa_Adiha_process_table_drop') Begin  Drop Procedure spa_Adiha_process_table_drop  END
IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'spa_calc_invoice_t') Begin  Drop Procedure spa_calc_invoice_t  END
IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'spa_calculate_eigen_values') Begin  Drop Procedure spa_calculate_eigen_values  END
IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'spa_check_mitigated_dependent_activity_status') Begin  Drop Procedure spa_check_mitigated_dependent_activity_status  END
IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'spa_copy_missing_price') Begin  Drop Procedure spa_copy_missing_price  END
IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'spa_Create_Deal_Audit_Report_new') Begin  Drop Procedure spa_Create_Deal_Audit_Report_new  END
IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'spa_create_forecasted_transaction') Begin  Drop Procedure spa_create_forecasted_transaction  END
IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'spa_create_hourly_position_report_NEW') Begin  Drop Procedure spa_create_hourly_position_report_NEW  END
IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'spa_create_hourly_position_report_t') Begin  Drop Procedure spa_create_hourly_position_report_t  END
IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'spa_create_hourly_position_report1') Begin  Drop Procedure spa_create_hourly_position_report1  END
IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'spa_create_imbalance_report_paging') Begin  Drop Procedure spa_create_imbalance_report_paging  END
IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'spa_Create_Inventory_Journal_Entry_Report_New') Begin  Drop Procedure spa_Create_Inventory_Journal_Entry_Report_New  END
IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'spa_Create_MTM_Period_Report_old') Begin  Drop Procedure spa_Create_MTM_Period_Report_old  END
IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'spa_create_Partition_file_group') Begin  Drop Procedure spa_create_Partition_file_group  END
IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'spa_cube') Begin  Drop Procedure spa_cube  END
IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'spa_cube_process') Begin  Drop Procedure spa_cube_process  END
IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'spa_cube_process_as_job') Begin  Drop Procedure spa_cube_process_as_job  END
IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'spa_customer_detail') Begin  Drop Procedure spa_customer_detail  END
IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'spa_dashboardReportName') Begin  Drop Procedure spa_dashboardReportName  END
IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'spa_deal_comment_history') Begin  Drop Procedure spa_deal_comment_history  END
IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'spa_derive_curve_EOD') Begin  Drop Procedure spa_derive_curve_EOD  END
IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'spa_DoTransaction_tmp') Begin  Drop Procedure spa_DoTransaction_tmp  END
IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'spa_DoTransaction2') Begin  Drop Procedure spa_DoTransaction2  END
IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'spa_dump_data') Begin  Drop Procedure spa_dump_data  END
IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'spa_dynamic_slide') Begin  Drop Procedure spa_dynamic_slide  END
IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'spa_ems_archive_data_job') Begin  Drop Procedure spa_ems_archive_data_job  END
IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'spa_endur_import_check_violation') Begin  Drop Procedure spa_endur_import_check_violation  END
IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'spa_endur_import_update_staging_info') Begin  Drop Procedure spa_endur_import_update_staging_info  END
IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'spa_fk') Begin  Drop Procedure spa_fk  END
IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'spa_formula_editor_t') Begin  Drop Procedure spa_formula_editor_t  END
IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'spa_gen_invoice_variance_report_tmp') Begin  Drop Procedure spa_gen_invoice_variance_report_tmp  END
IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'spa_get_all_function_id_tmp') Begin  Drop Procedure spa_get_all_function_id_tmp  END
IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'spa_get_invoice_info_rdl') Begin  Drop Procedure spa_get_invoice_info_rdl  END
IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'spa_get_outstanding_control_activities_job_t') Begin  Drop Procedure spa_get_outstanding_control_activities_job_t  END
IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'spa_get_section_name') Begin  Drop Procedure spa_get_section_name  END
IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'spa_getallaccessrights_tmp') Begin  Drop Procedure spa_getallaccessrights_tmp  END
IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'spa_getCalendarData_tmp') Begin  Drop Procedure spa_getCalendarData_tmp  END
IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'spa_getCalendarDataTmp') Begin  Drop Procedure spa_getCalendarDataTmp  END
IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'spa_import_deal_hourly_data_delete_insert') Begin  Drop Procedure spa_import_deal_hourly_data_delete_insert  END
IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'spa_import_deal_hourly_data_update_insert') Begin  Drop Procedure spa_import_deal_hourly_data_update_insert  END
IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'spa_import_hourly_data_t') Begin  Drop Procedure spa_import_hourly_data_t  END
IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'spa_import_mv90_data_reprocess') Begin  Drop Procedure spa_import_mv90_data_reprocess  END
IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'spa_insert_position_schedule_xml_deal_test') Begin  Drop Procedure spa_insert_position_schedule_xml_deal_test  END
IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'spa_InsertDealXml2') Begin  Drop Procedure spa_InsertDealXml2  END
IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'spa_InsertDealXmlBlotter_t') Begin  Drop Procedure spa_InsertDealXmlBlotter_t  END
IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'spa_InsertDealXmlBlotterV2_test') Begin  Drop Procedure spa_InsertDealXmlBlotterV2_test  END
IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'spa_inventory_book_map') Begin  Drop Procedure spa_inventory_book_map  END
IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'spa_inventory_manual_entries') Begin  Drop Procedure spa_inventory_manual_entries  END
IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'spa_is_valid_user_t') Begin  Drop Procedure spa_is_valid_user_t  END
IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'spa_item_sales_report') Begin  Drop Procedure spa_item_sales_report  END
IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'spa_LADWP_source_price_curve_adapter') Begin  Drop Procedure spa_LADWP_source_price_curve_adapter  END
IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'spa_limit_Validation') Begin  Drop Procedure spa_limit_Validation  END
IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'spa_maintain_price_curve_t') Begin  Drop Procedure spa_maintain_price_curve_t  END
IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'spa_maintain_price_curve_tmp') Begin  Drop Procedure spa_maintain_price_curve_tmp  END
IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'spa_maintain_price_curve_tmp1') Begin  Drop Procedure spa_maintain_price_curve_tmp1  END
IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'spa_maintain_price_curve1') Begin  Drop Procedure spa_maintain_price_curve1  END
IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'spa_maintain_udf_detail_values') Begin  Drop Procedure spa_maintain_udf_detail_values  END
IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'spa_maintain_udf_header') Begin  Drop Procedure spa_maintain_udf_header  END
IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'spa_maintain_udf_header_detail') Begin  Drop Procedure spa_maintain_udf_header_detail  END
IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'spa_message_board_t') Begin  Drop Procedure spa_message_board_t  END
IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'spa_meter_id_channel') Begin  Drop Procedure spa_meter_id_channel  END
IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'spa_order_detail') Begin  Drop Procedure spa_order_detail  END
IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'spa_order_report') Begin  Drop Procedure spa_order_report  END
IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'spa_portfolio_mapping_book') Begin  Drop Procedure spa_portfolio_mapping_book  END
IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'spa_position_report_sch_n_delivery_new') Begin  Drop Procedure spa_position_report_sch_n_delivery_new  END
IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'spa_position_schedule') Begin  Drop Procedure spa_position_schedule  END
IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'spa_process_risk_controls_reminders') Begin  Drop Procedure spa_process_risk_controls_reminders  END
IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'spa_process_settlement_invoice_job') Begin  Drop Procedure spa_process_settlement_invoice_job  END
IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'spa_process_standard_main') Begin  Drop Procedure spa_process_standard_main  END
IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'spa_REC_Target_Report_tmp') Begin  Drop Procedure spa_REC_Target_Report_tmp  END
IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'spa_report_group_parameters_criteria') Begin  Drop Procedure spa_report_group_parameters_criteria  END
IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'spa_report_group_template_group') Begin  Drop Procedure spa_report_group_template_group  END
IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'spa_report_group_template_header') Begin  Drop Procedure spa_report_group_template_header  END
IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'spa_rfx_export_report_job_2') Begin  Drop Procedure spa_rfx_export_report_job_2  END
IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'spa_rollover_forward2spot') Begin  Drop Procedure spa_rollover_forward2spot  END
IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'spa_save_xml_grid_data_tmp') Begin  Drop Procedure spa_save_xml_grid_data_tmp  END
IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'spa_soap_pratos_t') Begin  Drop Procedure spa_soap_pratos_t  END
IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'spa_source_deal_detail') Begin  Drop Procedure spa_source_deal_detail  END
IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'spa_source_deal_detail_hour_1') Begin  Drop Procedure spa_source_deal_detail_hour_1  END
IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'spa_sourcedealtemp_detail_paging_test') Begin  Drop Procedure spa_sourcedealtemp_detail_paging_test  END
IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'spa_sourcedealtemp_tmp') Begin  Drop Procedure spa_sourcedealtemp_tmp  END
IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'spa_trigger_compliance_activities') Begin  Drop Procedure spa_trigger_compliance_activities  END
IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'spViewJobStatus') Begin  Drop Procedure spViewJobStatus  END
IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'test_spa_InsertDealXmlBlotterV2') Begin  Drop Procedure test_spa_InsertDealXmlBlotterV2  END
IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'test_spa_transfer_book_position') Begin  Drop Procedure test_spa_transfer_book_position  END
IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'test_spa_UpdateFromXml') Begin  Drop Procedure test_spa_UpdateFromXml  END
--IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'spa_recorder_generator_map') Begin  Drop Procedure spa_recorder_generator_map  END
--IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'spa_generate_debug_param_values') Begin  Drop Procedure spa_generate_debug_param_values  END

IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'spa_calculate_eigen_values') Begin  Drop Procedure spa_calculate_eigen_values  END
IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'spa_Create_MTM_Period_Report_mtest') Begin  Drop Procedure spa_Create_MTM_Period_Report_mtest  END

IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'spa_archive_data_job') Begin  Drop Procedure spa_archive_data_job  END
IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'spa_archive_meter_data') Begin  Drop Procedure spa_archive_meter_data  END
IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'spa_check_data_for_calc') Begin  Drop Procedure spa_check_data_for_calc  END
IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'spa_collect_deals') Begin  Drop Procedure spa_collect_deals  END
IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'spa_Create_Source_System_Report') Begin  Drop Procedure spa_Create_Source_System_Report  END
IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'spa_create_withdrawal_schedule') Begin  Drop Procedure spa_create_withdrawal_schedule  END
IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'spa_get_hourly_deal_data') Begin  Drop Procedure spa_get_hourly_deal_data  END
IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'spa_get_mitigate_activities') Begin  Drop Procedure spa_get_mitigate_activities  END
IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'spa_get_section_name') Begin  Drop Procedure spa_get_section_name  END
--IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'spa_get_source_table_names') Begin  Drop Procedure spa_get_source_table_names  END
IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'spa_get_xml_from_sp') Begin  Drop Procedure spa_get_xml_from_sp  END
IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'spa_import_mv90_data_reprocess') Begin  Drop Procedure spa_import_mv90_data_reprocess  END
IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'spa_interface_Adapter_email') Begin  Drop Procedure spa_interface_Adapter_email  END
IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'spa_interface_Adaptor_email') Begin  Drop Procedure spa_interface_Adaptor_email  END
IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'spa_maintain_udf_detail_values') Begin  Drop Procedure spa_maintain_udf_detail_values  END
IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'spa_maintain_udf_header') Begin  Drop Procedure spa_maintain_udf_header  END
IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'spa_maintain_udf_header_detail') Begin  Drop Procedure spa_maintain_udf_header_detail  END
IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'spa_manage_document') Begin  Drop Procedure spa_manage_document  END
IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'spa_meter_id_channel') Begin  Drop Procedure spa_meter_id_channel  END
IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'spa_portfolio_mapping_book') Begin  Drop Procedure spa_portfolio_mapping_book  END
IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'spa_position_schedule') Begin  Drop Procedure spa_position_schedule  END
IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'spa_rdb_position_report') Begin  Drop Procedure spa_rdb_position_report  END
IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'spa_term_map_detail') Begin  Drop Procedure spa_term_map_detail  END
IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'spa_trader_ticket_template') Begin  Drop Procedure spa_trader_ticket_template  END
IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'spa_trageted_syv_calc') Begin  Drop Procedure spa_trageted_syv_calc  END
IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'spa_update_hourly_deal_data') Begin  Drop Procedure spa_update_hourly_deal_data  END
IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'InsertScript_adiha_grid_definition_contract_group') Begin  Drop Procedure InsertScript_adiha_grid_definition_contract_group  END
IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'Insert_contract_group_file') Begin  Drop Procedure Insert_contract_group_file  END


IF EXISTS  ( SELECT  1 FROM sysobjects WHERE id = object_id( N'fn_Split' ) 
    AND xtype IN (N'FN', N'IF', N'TF')
) BEGIN
    DROP FUNCTION fn_Split END
IF EXISTS  ( SELECT  1 FROM sysobjects WHERE id = object_id( N'FNA_delta_report_hourly_position_breakdown' ) 
    AND xtype IN (N'FN', N'IF', N'TF')
) BEGIN
    DROP FUNCTION FNA_delta_report_hourly_position_breakdown END
IF EXISTS  ( SELECT  1 FROM sysobjects WHERE id = object_id( N'FNA_report_hourly_position_breakdown' ) 
    AND xtype IN (N'FN', N'IF', N'TF')
) BEGIN
    DROP FUNCTION FNA_report_hourly_position_breakdown END
IF EXISTS  ( SELECT  1 FROM sysobjects WHERE id = object_id( N'FNA_report_hourly_position_breakdown_diff_ratio' ) 
    AND xtype IN (N'FN', N'IF', N'TF')
) BEGIN
    DROP FUNCTION FNA_report_hourly_position_breakdown_diff_ratio END
IF EXISTS  ( SELECT  1 FROM sysobjects WHERE id = object_id( N'FNABonusSQL' ) 
    AND xtype IN (N'FN', N'IF', N'TF')
) BEGIN
    DROP FUNCTION FNABonusSQL END
IF EXISTS  ( SELECT  1 FROM sysobjects WHERE id = object_id( N'FNACertificateQtr' ) 
    AND xtype IN (N'FN', N'IF', N'TF')
) BEGIN
    DROP FUNCTION FNACertificateQtr END
IF EXISTS  ( SELECT  1 FROM sysobjects WHERE id = object_id( N'FNACertificateText' ) 
    AND xtype IN (N'FN', N'IF', N'TF')
) BEGIN
    DROP FUNCTION FNACertificateText END
IF EXISTS  ( SELECT  1 FROM sysobjects WHERE id = object_id( N'FNACertificateYear' ) 
    AND xtype IN (N'FN', N'IF', N'TF')
) BEGIN
    DROP FUNCTION FNACertificateYear END
IF EXISTS  ( SELECT  1 FROM sysobjects WHERE id = object_id( N'FNAConstantValue' ) 
    AND xtype IN (N'FN', N'IF', N'TF')
) BEGIN
    DROP FUNCTION FNAConstantValue END
IF EXISTS  ( SELECT  1 FROM sysobjects WHERE id = object_id( N'FNAContractMonthFormatTest' ) 
    AND xtype IN (N'FN', N'IF', N'TF')
) BEGIN
    DROP FUNCTION FNAContractMonthFormatTest END
IF EXISTS  ( SELECT  1 FROM sysobjects WHERE id = object_id( N'FNAConvertGranularity' ) 
    AND xtype IN (N'FN', N'IF', N'TF')
) BEGIN
    DROP FUNCTION FNAConvertGranularity END
IF EXISTS  ( SELECT  1 FROM sysobjects WHERE id = object_id( N'FNAConvertIntergerTo15minTime' ) 
    AND xtype IN (N'FN', N'IF', N'TF')
) BEGIN
    DROP FUNCTION FNAConvertIntergerTo15minTime END
IF EXISTS  ( SELECT  1 FROM sysobjects WHERE id = object_id( N'FNAConvertIntTo15MinTime' ) 
    AND xtype IN (N'FN', N'IF', N'TF')
) BEGIN
    DROP FUNCTION FNAConvertIntTo15MinTime END
IF EXISTS  ( SELECT  1 FROM sysobjects WHERE id = object_id( N'FNAConvertTerm' ) 
    AND xtype IN (N'FN', N'IF', N'TF')
) BEGIN
    DROP FUNCTION FNAConvertTerm END
IF EXISTS  ( SELECT  1 FROM sysobjects WHERE id = object_id( N'FNAConvSQL' ) 
    AND xtype IN (N'FN', N'IF', N'TF')
) BEGIN
    DROP FUNCTION FNAConvSQL END
IF EXISTS  ( SELECT  1 FROM sysobjects WHERE id = object_id( N'FNACovertTextToDate' ) 
    AND xtype IN (N'FN', N'IF', N'TF')
) BEGIN
    DROP FUNCTION FNACovertTextToDate END
IF EXISTS  ( SELECT  1 FROM sysobjects WHERE id = object_id( N'FNADateMin' ) 
    AND xtype IN (N'FN', N'IF', N'TF')
) BEGIN
    DROP FUNCTION FNADateMin END
IF EXISTS  ( SELECT  1 FROM sysobjects WHERE id = object_id( N'FNADBUserDefault' ) 
    AND xtype IN (N'FN', N'IF', N'TF')
) BEGIN
    DROP FUNCTION FNADBUserDefault END
IF EXISTS  ( SELECT  1 FROM sysobjects WHERE id = object_id( N'FNAEMS6MsBlockAverage' ) 
    AND xtype IN (N'FN', N'IF', N'TF')
) BEGIN
    DROP FUNCTION FNAEMS6MsBlockAverage END
IF EXISTS  ( SELECT  1 FROM sysobjects WHERE id = object_id( N'FNAExtractCurveID' ) 
    AND xtype IN (N'FN', N'IF', N'TF')
) BEGIN
    DROP FUNCTION FNAExtractCurveID END
IF EXISTS  ( SELECT  1 FROM sysobjects WHERE id = object_id( N'FNAFindCycle' ) 
    AND xtype IN (N'FN', N'IF', N'TF')
) BEGIN
    DROP FUNCTION FNAFindCycle END
IF EXISTS  ( SELECT  1 FROM sysobjects WHERE id = object_id( N'FNAFormulaRowFormat' ) 
    AND xtype IN (N'FN', N'IF', N'TF')
) BEGIN
    DROP FUNCTION FNAFormulaRowFormat END
IF EXISTS  ( SELECT  1 FROM sysobjects WHERE id = object_id( N'FNAGenerateCSVfromTable' ) 
    AND xtype IN (N'FN', N'IF', N'TF')
) BEGIN
    DROP FUNCTION FNAGenerateCSVfromTable END
IF EXISTS  ( SELECT  1 FROM sysobjects WHERE id = object_id( N'FNAGetFirstLastDayOfMonth' ) 
    AND xtype IN (N'FN', N'IF', N'TF')
) BEGIN
    DROP FUNCTION FNAGetFirstLastDayOfMonth END
IF EXISTS  ( SELECT  1 FROM sysobjects WHERE id = object_id( N'FNAGetInventoryWghtAvgCost' ) 
    AND xtype IN (N'FN', N'IF', N'TF')
) BEGIN
    DROP FUNCTION FNAGetInventoryWghtAvgCost END
IF EXISTS  ( SELECT  1 FROM sysobjects WHERE id = object_id( N'FNAGetMultipleArchiveTable' ) 
    AND xtype IN (N'FN', N'IF', N'TF')
) BEGIN
    DROP FUNCTION FNAGetMultipleArchiveTable END
IF EXISTS  ( SELECT  1 FROM sysobjects WHERE id = object_id( N'FNAGetNextFirstDate_t' ) 
    AND xtype IN (N'FN', N'IF', N'TF')
) BEGIN
    DROP FUNCTION FNAGetNextFirstDate_t END
IF EXISTS  ( SELECT  1 FROM sysobjects WHERE id = object_id( N'FNAGetSQLStandardCurveMaturityDateTime' ) 
    AND xtype IN (N'FN', N'IF', N'TF')
) BEGIN
    DROP FUNCTION FNAGetSQLStandardCurveMaturityDateTime END
IF EXISTS  ( SELECT  1 FROM sysobjects WHERE id = object_id( N'FNAGetTableFieldList' ) 
    AND xtype IN (N'FN', N'IF', N'TF')
) BEGIN
    DROP FUNCTION FNAGetTableFieldList END
IF EXISTS  ( SELECT  1 FROM sysobjects WHERE id = object_id( N'FNAHyperLinkText4' ) 
    AND xtype IN (N'FN', N'IF', N'TF')
) BEGIN
    DROP FUNCTION FNAHyperLinkText4 END
IF EXISTS  ( SELECT  1 FROM sysobjects WHERE id = object_id( N'FNAHyperLinkTextTRM3' ) 
    AND xtype IN (N'FN', N'IF', N'TF')
) BEGIN
    DROP FUNCTION FNAHyperLinkTextTRM3 END
IF EXISTS  ( SELECT  1 FROM sysobjects WHERE id = object_id( N'FNAIsValidClientDate' ) 
    AND xtype IN (N'FN', N'IF', N'TF')
) BEGIN
    DROP FUNCTION FNAIsValidClientDate END
IF EXISTS  ( SELECT  1 FROM sysobjects WHERE id = object_id( N'FNALong_String' ) 
    AND xtype IN (N'FN', N'IF', N'TF')
) BEGIN
    DROP FUNCTION FNALong_String END
IF EXISTS  ( SELECT  1 FROM sysobjects WHERE id = object_id( N'FNANextInstanceCalendarDate' ) 
    AND xtype IN (N'FN', N'IF', N'TF')
) BEGIN
    DROP FUNCTION FNANextInstanceCalendarDate END
IF EXISTS  ( SELECT  1 FROM sysobjects WHERE id = object_id( N'FNAOpenHTMLWindow' ) 
    AND xtype IN (N'FN', N'IF', N'TF')
) BEGIN
    DROP FUNCTION FNAOpenHTMLWindow END
IF EXISTS  ( SELECT  1 FROM sysobjects WHERE id = object_id( N'FNAPHSQL' ) 
    AND xtype IN (N'FN', N'IF', N'TF')
) BEGIN
    DROP FUNCTION FNAPHSQL END
IF EXISTS  ( SELECT  1 FROM sysobjects WHERE id = object_id( N'FNARDealFeesvolume' ) 
    AND xtype IN (N'FN', N'IF', N'TF')
) BEGIN
    DROP FUNCTION FNARDealFeesvolume END
IF EXISTS  ( SELECT  1 FROM sysobjects WHERE id = object_id( N'FNARECExpiration' ) 
    AND xtype IN (N'FN', N'IF', N'TF')
) BEGIN
    DROP FUNCTION FNARECExpiration END
IF EXISTS  ( SELECT  1 FROM sysobjects WHERE id = object_id( N'FNARECVolumeCH' ) 
    AND xtype IN (N'FN', N'IF', N'TF')
) BEGIN
    DROP FUNCTION FNARECVolumeCH END
IF EXISTS  ( SELECT  1 FROM sysobjects WHERE id = object_id( N'FNARelativeCurveDaily' ) 
    AND xtype IN (N'FN', N'IF', N'TF')
) BEGIN
    DROP FUNCTION FNARelativeCurveDaily END
IF EXISTS  ( SELECT  1 FROM sysobjects WHERE id = object_id( N'FNARFXSanitizeReportColumnName' ) 
    AND xtype IN (N'FN', N'IF', N'TF')
) BEGIN
    DROP FUNCTION FNARFXSanitizeReportColumnName END
IF EXISTS  ( SELECT  1 FROM sysobjects WHERE id = object_id( N'FNARollingDVol' ) 
    AND xtype IN (N'FN', N'IF', N'TF')
) BEGIN
    DROP FUNCTION FNARollingDVol END
IF EXISTS  ( SELECT  1 FROM sysobjects WHERE id = object_id( N'FNARRelativeCurveDaily' ) 
    AND xtype IN (N'FN', N'IF', N'TF')
) BEGIN
    DROP FUNCTION FNARRelativeCurveDaily END
IF EXISTS  ( SELECT  1 FROM sysobjects WHERE id = object_id( N'FNARRollingDVol' ) 
    AND xtype IN (N'FN', N'IF', N'TF')
) BEGIN
    DROP FUNCTION FNARRollingDVol END
IF EXISTS  ( SELECT  1 FROM sysobjects WHERE id = object_id( N'FNARwSum' ) 
    AND xtype IN (N'FN', N'IF', N'TF')
) BEGIN
    DROP FUNCTION FNARwSum END
IF EXISTS  ( SELECT  1 FROM sysobjects WHERE id = object_id( N'FNARYealyContractVolm' ) 
    AND xtype IN (N'FN', N'IF', N'TF')
) BEGIN
    DROP FUNCTION FNARYealyContractVolm END
IF EXISTS  ( SELECT  1 FROM sysobjects WHERE id = object_id( N'FNATestCFV' ) 
    AND xtype IN (N'FN', N'IF', N'TF')
) BEGIN
    DROP FUNCTION FNATestCFV END
IF EXISTS  ( SELECT  1 FROM sysobjects WHERE id = object_id( N'FNATestSettledRollForward' ) 
    AND xtype IN (N'FN', N'IF', N'TF')
) BEGIN
    DROP FUNCTION FNATestSettledRollForward END
IF EXISTS  ( SELECT  1 FROM sysobjects WHERE id = object_id( N'FNATFDistValue' ) 
    AND xtype IN (N'FN', N'IF', N'TF')
) BEGIN
    DROP FUNCTION FNATFDistValue END
IF EXISTS  ( SELECT  1 FROM sysobjects WHERE id = object_id( N'FNATrimDate' ) 
    AND xtype IN (N'FN', N'IF', N'TF')
) BEGIN
    DROP FUNCTION FNATrimDate END
IF EXISTS  ( SELECT  1 FROM sysobjects WHERE id = object_id( N'FNAUDFCharges' ) 
    AND xtype IN (N'FN', N'IF', N'TF')
) BEGIN
    DROP FUNCTION FNAUDFCharges END
IF EXISTS  ( SELECT  1 FROM sysobjects WHERE id = object_id( N'FNAVolumeCH' ) 
    AND xtype IN (N'FN', N'IF', N'TF')
) BEGIN
    DROP FUNCTION FNAVolumeCH END
IF EXISTS  ( SELECT  1 FROM sysobjects WHERE id = object_id( N'FNAYearCount' ) 
    AND xtype IN (N'FN', N'IF', N'TF')
) BEGIN
    DROP FUNCTION FNAYearCount END


IF EXISTS  ( SELECT  1 FROM sysobjects WHERE id = object_id( N'fn_Split' ) 
    AND xtype IN (N'FN', N'IF', N'TF')
) BEGIN
    DROP FUNCTION fn_Split END
IF EXISTS  ( SELECT  1 FROM sysobjects WHERE id = object_id( N'FNAConstantValue' ) 
    AND xtype IN (N'FN', N'IF', N'TF')
) BEGIN
    DROP FUNCTION FNAConstantValue END
IF EXISTS  ( SELECT  1 FROM sysobjects WHERE id = object_id( N'FNAConvertIntergerTo15minTime' ) 
    AND xtype IN (N'FN', N'IF', N'TF')
) BEGIN
    DROP FUNCTION FNAConvertIntergerTo15minTime END
IF EXISTS  ( SELECT  1 FROM sysobjects WHERE id = object_id( N'FNAConvertIntTo15MinTime' ) 
    AND xtype IN (N'FN', N'IF', N'TF')
) BEGIN
    DROP FUNCTION FNAConvertIntTo15MinTime END
IF EXISTS  ( SELECT  1 FROM sysobjects WHERE id = object_id( N'FNADealVol' ) 
    AND xtype IN (N'FN', N'IF', N'TF')
) BEGIN
    DROP FUNCTION FNADealVol END
IF EXISTS  ( SELECT  1 FROM sysobjects WHERE id = object_id( N'FNAFormulaRowFormat' ) 
    AND xtype IN (N'FN', N'IF', N'TF')
) BEGIN
    DROP FUNCTION FNAFormulaRowFormat END
IF EXISTS  ( SELECT  1 FROM sysobjects WHERE id = object_id( N'FNAFormulaTextContract' ) 
    AND xtype IN (N'FN', N'IF', N'TF')
) BEGIN
    DROP FUNCTION FNAFormulaTextContract END
IF EXISTS  ( SELECT  1 FROM sysobjects WHERE id = object_id( N'FNAFormulaTextEMS' ) 
    AND xtype IN (N'FN', N'IF', N'TF')
) BEGIN
    DROP FUNCTION FNAFormulaTextEMS END
IF EXISTS  ( SELECT  1 FROM sysobjects WHERE id = object_id( N'FNAGetNextFirstDate_t' ) 
    AND xtype IN (N'FN', N'IF', N'TF')
) BEGIN
    DROP FUNCTION FNAGetNextFirstDate_t END
IF EXISTS  ( SELECT  1 FROM sysobjects WHERE id = object_id( N'FNAGetSQL' ) 
    AND xtype IN (N'FN', N'IF', N'TF')
) BEGIN
    DROP FUNCTION FNAGetSQL END
IF EXISTS  ( SELECT  1 FROM sysobjects WHERE id = object_id( N'FNALong_String' ) 
    AND xtype IN (N'FN', N'IF', N'TF')
) BEGIN
    DROP FUNCTION FNALong_String END
IF EXISTS  ( SELECT  1 FROM sysobjects WHERE id = object_id( N'FNANextInstanceCalendarDate' ) 
    AND xtype IN (N'FN', N'IF', N'TF')
) BEGIN
    DROP FUNCTION FNANextInstanceCalendarDate END
IF EXISTS  ( SELECT  1 FROM sysobjects WHERE id = object_id( N'FNAParseFormula' ) 
    AND xtype IN (N'FN', N'IF', N'TF')
) BEGIN
    DROP FUNCTION FNAParseFormula END
IF EXISTS  ( SELECT  1 FROM sysobjects WHERE id = object_id( N'FNARCoIncidentPeak' ) 
    AND xtype IN (N'FN', N'IF', N'TF')
) BEGIN
    DROP FUNCTION FNARCoIncidentPeak END
IF EXISTS  ( SELECT  1 FROM sysobjects WHERE id = object_id( N'FNARDealFeesvolume' ) 
    AND xtype IN (N'FN', N'IF', N'TF')
) BEGIN
    DROP FUNCTION FNARDealFeesvolume END
IF EXISTS  ( SELECT  1 FROM sysobjects WHERE id = object_id( N'FNARDealFixedVolm' ) 
    AND xtype IN (N'FN', N'IF', N'TF')
) BEGIN
    DROP FUNCTION FNARDealFixedVolm END
IF EXISTS  ( SELECT  1 FROM sysobjects WHERE id = object_id( N'FNARDealVol' ) 
    AND xtype IN (N'FN', N'IF', N'TF')
) BEGIN
    DROP FUNCTION FNARDealVol END
IF EXISTS  ( SELECT  1 FROM sysobjects WHERE id = object_id( N'FNARDmdDateTime' ) 
    AND xtype IN (N'FN', N'IF', N'TF')
) BEGIN
    DROP FUNCTION FNARDmdDateTime END
IF EXISTS  ( SELECT  1 FROM sysobjects WHERE id = object_id( N'FNARECVolumeCH' ) 
    AND xtype IN (N'FN', N'IF', N'TF')
) BEGIN
    DROP FUNCTION FNARECVolumeCH END
IF EXISTS  ( SELECT  1 FROM sysobjects WHERE id = object_id( N'FNARelativeCurveDaily' ) 
    AND xtype IN (N'FN', N'IF', N'TF')
) BEGIN
    DROP FUNCTION FNARelativeCurveDaily END
IF EXISTS  ( SELECT  1 FROM sysobjects WHERE id = object_id( N'FNARExPostVolume' ) 
    AND xtype IN (N'FN', N'IF', N'TF')
) BEGIN
    DROP FUNCTION FNARExPostVolume END
IF EXISTS  ( SELECT  1 FROM sysobjects WHERE id = object_id( N'FNARHourlyDmd' ) 
    AND xtype IN (N'FN', N'IF', N'TF')
) BEGIN
    DROP FUNCTION FNARHourlyDmd END
IF EXISTS  ( SELECT  1 FROM sysobjects WHERE id = object_id( N'FNARollingDVol' ) 
    AND xtype IN (N'FN', N'IF', N'TF')
) BEGIN
    DROP FUNCTION FNARollingDVol END
IF EXISTS  ( SELECT  1 FROM sysobjects WHERE id = object_id( N'FNARPeakDmndMeter' ) 
    AND xtype IN (N'FN', N'IF', N'TF')
) BEGIN
    DROP FUNCTION FNARPeakDmndMeter END
IF EXISTS  ( SELECT  1 FROM sysobjects WHERE id = object_id( N'FNARRelativeCurveDaily' ) 
    AND xtype IN (N'FN', N'IF', N'TF')
) BEGIN
    DROP FUNCTION FNARRelativeCurveDaily END
IF EXISTS  ( SELECT  1 FROM sysobjects WHERE id = object_id( N'FNARRollingDVol' ) 
    AND xtype IN (N'FN', N'IF', N'TF')
) BEGIN
    DROP FUNCTION FNARRollingDVol END
IF EXISTS  ( SELECT  1 FROM sysobjects WHERE id = object_id( N'FNARYealyContractVolm' ) 
    AND xtype IN (N'FN', N'IF', N'TF')
) BEGIN
    DROP FUNCTION FNARYealyContractVolm END
IF EXISTS  ( SELECT  1 FROM sysobjects WHERE id = object_id( N'FNATrmHyperlink_tmp' ) 
    AND xtype IN (N'FN', N'IF', N'TF')
) BEGIN
    DROP FUNCTION FNATrmHyperlink_tmp END
IF EXISTS  ( SELECT  1 FROM sysobjects WHERE id = object_id( N'FNAWACOG' ) 
    AND xtype IN (N'FN', N'IF', N'TF')
) BEGIN
    DROP FUNCTION FNAWACOG END


IF EXISTS  ( SELECT  1 FROM sysobjects WHERE id = object_id( N'FNACoIncidentPeak' ) 
    AND xtype IN (N'FN', N'IF', N'TF')
) BEGIN
    DROP FUNCTION FNACoIncidentPeak END
IF EXISTS  ( SELECT  1 FROM sysobjects WHERE id = object_id( N'FNAFormulaTextContract' ) 
    AND xtype IN (N'FN', N'IF', N'TF')
) BEGIN
    DROP FUNCTION FNAFormulaTextContract END
IF EXISTS  ( SELECT  1 FROM sysobjects WHERE id = object_id( N'FNAFormulaTextEMS' ) 
    AND xtype IN (N'FN', N'IF', N'TF')
) BEGIN
    DROP FUNCTION FNAFormulaTextEMS END
IF EXISTS  ( SELECT  1 FROM sysobjects WHERE id = object_id( N'FNAHourlyDmd' ) 
    AND xtype IN (N'FN', N'IF', N'TF')
) BEGIN
    DROP FUNCTION FNAHourlyDmd END
IF EXISTS  ( SELECT  1 FROM sysobjects WHERE id = object_id( N'FNALaggingMonths' ) 
    AND xtype IN (N'FN', N'IF', N'TF')
) BEGIN
    DROP FUNCTION FNALaggingMonths END
IF EXISTS  ( SELECT  1 FROM sysobjects WHERE id = object_id( N'FNARCoIncidentPeak' ) 
    AND xtype IN (N'FN', N'IF', N'TF')
) BEGIN
    DROP FUNCTION FNARCoIncidentPeak END
IF EXISTS  ( SELECT  1 FROM sysobjects WHERE id = object_id( N'FNARDmdDateTime' ) 
    AND xtype IN (N'FN', N'IF', N'TF')
) BEGIN
    DROP FUNCTION FNARDmdDateTime END
IF EXISTS  ( SELECT  1 FROM sysobjects WHERE id = object_id( N'FNARECVolumeCH' ) 
    AND xtype IN (N'FN', N'IF', N'TF')
) BEGIN
    DROP FUNCTION FNARECVolumeCH END
IF EXISTS  ( SELECT  1 FROM sysobjects WHERE id = object_id( N'FNARExPostVolume' ) 
    AND xtype IN (N'FN', N'IF', N'TF')
) BEGIN
    DROP FUNCTION FNARExPostVolume END
IF EXISTS  ( SELECT  1 FROM sysobjects WHERE id = object_id( N'FNARHourlyDmd' ) 
    AND xtype IN (N'FN', N'IF', N'TF')
) BEGIN
    DROP FUNCTION FNARHourlyDmd END
IF EXISTS  ( SELECT  1 FROM sysobjects WHERE id = object_id( N'FNARPeakDmndMeter' ) 
    AND xtype IN (N'FN', N'IF', N'TF')
) BEGIN
    DROP FUNCTION FNARPeakDmndMeter END

IF EXISTS  ( SELECT  1 FROM sysobjects WHERE id = object_id( N'FNAConvertIntergerTo15minTime' ) 
    AND xtype IN (N'FN', N'IF', N'TF')
) BEGIN
    DROP FUNCTION FNAConvertIntergerTo15minTime END
IF EXISTS  ( SELECT  1 FROM sysobjects WHERE id = object_id( N'FNAConvertIntTo15MinTime' ) 
    AND xtype IN (N'FN', N'IF', N'TF')
) BEGIN
    DROP FUNCTION FNAConvertIntTo15MinTime END
IF EXISTS  ( SELECT  1 FROM sysobjects WHERE id = object_id( N'FNADealVol' ) 
    AND xtype IN (N'FN', N'IF', N'TF')
) BEGIN
    DROP FUNCTION FNADealVol END
IF EXISTS  ( SELECT  1 FROM sysobjects WHERE id = object_id( N'FNAFormulaRowFormat' ) 
    AND xtype IN (N'FN', N'IF', N'TF')
) BEGIN
    DROP FUNCTION FNAFormulaRowFormat END
IF EXISTS  ( SELECT  1 FROM sysobjects WHERE id = object_id( N'FNAFormulaTextContract' ) 
    AND xtype IN (N'FN', N'IF', N'TF')
) BEGIN
    DROP FUNCTION FNAFormulaTextContract END
IF EXISTS  ( SELECT  1 FROM sysobjects WHERE id = object_id( N'FNAFormulaTextEMS' ) 
    AND xtype IN (N'FN', N'IF', N'TF')
) BEGIN
    DROP FUNCTION FNAFormulaTextEMS END
IF EXISTS  ( SELECT  1 FROM sysobjects WHERE id = object_id( N'FNAGetNextFirstDate_t' ) 
    AND xtype IN (N'FN', N'IF', N'TF')
) BEGIN
    DROP FUNCTION FNAGetNextFirstDate_t END
IF EXISTS  ( SELECT  1 FROM sysobjects WHERE id = object_id( N'FNAGetSQL' ) 
    AND xtype IN (N'FN', N'IF', N'TF')
) BEGIN
    DROP FUNCTION FNAGetSQL END
IF EXISTS  ( SELECT  1 FROM sysobjects WHERE id = object_id( N'FNALong_String' ) 
    AND xtype IN (N'FN', N'IF', N'TF')
) BEGIN
    DROP FUNCTION FNALong_String END
IF EXISTS  ( SELECT  1 FROM sysobjects WHERE id = object_id( N'FNANextInstanceCalendarDate' ) 
    AND xtype IN (N'FN', N'IF', N'TF')
) BEGIN
    DROP FUNCTION FNANextInstanceCalendarDate END
IF EXISTS  ( SELECT  1 FROM sysobjects WHERE id = object_id( N'FNAParseFormula' ) 
    AND xtype IN (N'FN', N'IF', N'TF')
) BEGIN
    DROP FUNCTION FNAParseFormula END
IF EXISTS  ( SELECT  1 FROM sysobjects WHERE id = object_id( N'FNARDealFeesvolume' ) 
    AND xtype IN (N'FN', N'IF', N'TF')
) BEGIN
    DROP FUNCTION FNARDealFeesvolume END
IF EXISTS  ( SELECT  1 FROM sysobjects WHERE id = object_id( N'FNARDealFixedVolm' ) 
    AND xtype IN (N'FN', N'IF', N'TF')
) BEGIN
    DROP FUNCTION FNARDealFixedVolm END
IF EXISTS  ( SELECT  1 FROM sysobjects WHERE id = object_id( N'FNARDealVol' ) 
    AND xtype IN (N'FN', N'IF', N'TF')
) BEGIN
    DROP FUNCTION FNARDealVol END
IF EXISTS  ( SELECT  1 FROM sysobjects WHERE id = object_id( N'FNARelativeCurveDaily' ) 
    AND xtype IN (N'FN', N'IF', N'TF')
) BEGIN
    DROP FUNCTION FNARelativeCurveDaily END
IF EXISTS  ( SELECT  1 FROM sysobjects WHERE id = object_id( N'FNARollingDVol' ) 
    AND xtype IN (N'FN', N'IF', N'TF')
) BEGIN
    DROP FUNCTION FNARollingDVol END
IF EXISTS  ( SELECT  1 FROM sysobjects WHERE id = object_id( N'FNARPeakDmndMeter' ) 
    AND xtype IN (N'FN', N'IF', N'TF')
) BEGIN
    DROP FUNCTION FNARPeakDmndMeter END
IF EXISTS  ( SELECT  1 FROM sysobjects WHERE id = object_id( N'FNARRelativeCurveDaily' ) 
    AND xtype IN (N'FN', N'IF', N'TF')
) BEGIN
    DROP FUNCTION FNARRelativeCurveDaily END
IF EXISTS  ( SELECT  1 FROM sysobjects WHERE id = object_id( N'FNARRollingDVol' ) 
    AND xtype IN (N'FN', N'IF', N'TF')
) BEGIN
    DROP FUNCTION FNARRollingDVol END
IF EXISTS  ( SELECT  1 FROM sysobjects WHERE id = object_id( N'FNATrmHyperlink_tmp' ) 
    AND xtype IN (N'FN', N'IF', N'TF')
) BEGIN
    DROP FUNCTION FNATrmHyperlink_tmp END
IF EXISTS  ( SELECT  1 FROM sysobjects WHERE id = object_id( N'FNAWACOG' ) 
    AND xtype IN (N'FN', N'IF', N'TF')
) BEGIN
    DROP FUNCTION FNAWACOG END
IF EXISTS  ( SELECT  1 FROM sysobjects WHERE id = object_id( N'FNARelativeCurveDaily' ) 
    AND xtype IN (N'FN', N'IF', N'TF')
) BEGIN
    DROP FUNCTION FNARelativeCurveDaily END
IF EXISTS  ( SELECT  1 FROM sysobjects WHERE id = object_id( N'FNARwSum' ) 
    AND xtype IN (N'FN', N'IF', N'TF')
) BEGIN
    DROP FUNCTION FNARwSum END
IF EXISTS  ( SELECT  1 FROM sysobjects WHERE id = object_id( N'FNADebugSeperateParameter' ) 
    AND xtype IN (N'FN', N'IF', N'TF')
) BEGIN
    DROP FUNCTION FNADebugSeperateParameter END

IF EXISTS  ( SELECT  1 FROM sysobjects WHERE id = object_id( N'FNA24HrsAverage' ) 
    AND xtype IN (N'FN', N'IF', N'TF')
) BEGIN
    DROP FUNCTION FNA24HrsAverage END
IF EXISTS  ( SELECT  1 FROM sysobjects WHERE id = object_id( N'FNA3Hrs2Samples' ) 
    AND xtype IN (N'FN', N'IF', N'TF')
) BEGIN
    DROP FUNCTION FNA3Hrs2Samples END
IF EXISTS  ( SELECT  1 FROM sysobjects WHERE id = object_id( N'FNA6MsBlockAverage' ) 
    AND xtype IN (N'FN', N'IF', N'TF')
) BEGIN
    DROP FUNCTION FNA6MsBlockAverage END
IF EXISTS  ( SELECT  1 FROM sysobjects WHERE id = object_id( N'FNACounterpartyRegionID' ) 
    AND xtype IN (N'FN', N'IF', N'TF')
) BEGIN
    DROP FUNCTION FNACounterpartyRegionID END
IF EXISTS  ( SELECT  1 FROM sysobjects WHERE id = object_id( N'FNAEMS6MsBlockAverage' ) 
    AND xtype IN (N'FN', N'IF', N'TF')
) BEGIN
    DROP FUNCTION FNAEMS6MsBlockAverage END
IF EXISTS  ( SELECT  1 FROM sysobjects WHERE id = object_id( N'FNARwSum' ) 
    AND xtype IN (N'FN', N'IF', N'TF')
) BEGIN
    DROP FUNCTION FNARwSum END

IF EXISTS  ( SELECT  1 FROM sysobjects WHERE id = object_id( N'FNAMax' ) 
    AND xtype IN (N'FN', N'IF', N'TF')
) BEGIN
    DROP FUNCTION FNAMax END
    
IF EXISTS  ( SELECT  1 FROM sysobjects WHERE id = object_id( N'FNARCurve' ) 
    AND xtype IN (N'FN', N'IF', N'TF')
) BEGIN
    DROP FUNCTION FNARCurve END
    
IF EXISTS  ( SELECT  1 FROM sysobjects WHERE id = object_id( N'FNARollingSum' ) 
    AND xtype IN (N'FN', N'IF', N'TF')
) BEGIN
    DROP FUNCTION FNARollingSum END
    
IF EXISTS  ( SELECT  1 FROM sysobjects WHERE id = object_id( N'FNARow' ) 
    AND xtype IN (N'FN', N'IF', N'TF')
) BEGIN
    DROP FUNCTION FNARow END
    
IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'spa_calculate_eigen_values') Begin  Drop Procedure spa_calculate_eigen_values  END

IF EXISTS (SELECT  1 FROM sys.objects WHERE type = 'P' AND name = 'spa_Create_MTM_Period_Report_mtest') Begin  Drop Procedure spa_Create_MTM_Period_Report_mtest  END

IF EXISTS  ( SELECT  1 FROM sysobjects WHERE id = object_id( N'FNARCoIncidentPeak' ) 
    AND xtype IN (N'FN', N'IF', N'TF')
) BEGIN
    DROP FUNCTION FNARCoIncidentPeak END
    
IF EXISTS  ( SELECT  1 FROM sysobjects WHERE id = object_id( N'FNARDmdDateTime' ) 
    AND xtype IN (N'FN', N'IF', N'TF')
) BEGIN
    DROP FUNCTION FNARDmdDateTime END