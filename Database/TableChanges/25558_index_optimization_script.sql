DROP INDEX IF EXISTS [indx_delta_report_hourly_position_id] ON [dbo].[delta_report_hourly_position]
DROP INDEX IF EXISTS [IX_source_deal_header_1] ON [dbo].[source_deal_header]
DROP INDEX IF EXISTS [IX_source_deal_header] ON [dbo].[source_deal_header]
DROP INDEX IF EXISTS [indx_delta_report_hourly_position_as_of_date] ON [dbo].[delta_report_hourly_position]
DROP INDEX IF EXISTS [indx_source_price_curve_def_commodity] ON [dbo].[source_price_curve_def]
DROP INDEX IF EXISTS [indx_delta_report_hourly_position_delta_type] ON [dbo].[delta_report_hourly_position]
DROP INDEX IF EXISTS [indx_mv90_data31] ON [dbo].[mv90_data]
DROP INDEX IF EXISTS [indx_mv90_data21] ON [dbo].[mv90_data]
DROP INDEX IF EXISTS [IX_PT_user_defined_deal_detail_fields_audit_source_deal_detail_id_header_audit_id] ON [dbo].[user_defined_deal_detail_fields_audit]
DROP INDEX IF EXISTS [indx_delta_report_hourly_position_breakdown] ON [dbo].[delta_report_hourly_position_breakdown]
DROP INDEX IF EXISTS [IX_PT_source_price_curve_source_curve_def_id111] ON [dbo].[source_price_curve]
DROP INDEX IF EXISTS [indx_report_hourly_position_breakdown_deal_date] ON [dbo].[report_hourly_position_breakdown]
DROP INDEX IF EXISTS [indx_report_hourly_position_breakdown_commodity_id] ON [dbo].[report_hourly_position_breakdown]
DROP INDEX IF EXISTS [indx_report_hourly_position_breakdown_counterparty_id] ON [dbo].[report_hourly_position_breakdown]
DROP INDEX IF EXISTS [IX_PT_calc_formula_value_calc_id] ON [dbo].[calc_formula_value]
DROP INDEX IF EXISTS [indx_report_hourly_position_breakdown_fas_book_id] ON [dbo].[report_hourly_position_breakdown]
DROP INDEX IF EXISTS [IX_PT_calc_formula_value_calc_id_is_final_result] ON [dbo].[calc_formula_value]
DROP INDEX IF EXISTS [indx_report_hourly_position_breakdown_source_system_book_id] ON [dbo].[report_hourly_position_breakdown]
DROP INDEX IF EXISTS [IX_PT_calc_formula_value_invoice_line_item_id] ON [dbo].[calc_formula_value]
DROP INDEX IF EXISTS [indx_report_hourly_position_breakdown_volume_uom_id] ON [dbo].[report_hourly_position_breakdown]
DROP INDEX IF EXISTS [IX_PT_calc_formula_value_invoice_line_item_id_calc_id_is_final_result] ON [dbo].[calc_formula_value]
DROP INDEX IF EXISTS [IX_PT_calc_formula_value_invoice_line_item_id_calc_id_is_final_result_prod_date_deal_id] ON [dbo].[calc_formula_value]
DROP INDEX IF EXISTS [IX_PT_calc_formula_value_invoice_line_item_id_prod_date_calc_id] ON [dbo].[calc_formula_value]
DROP INDEX IF EXISTS [indx_source_minor_location_proxy_profile_id] ON [dbo].[source_minor_location]
DROP INDEX IF EXISTS [IX_PT_calc_formula_value_invoice_line_item_id_prod_date_contract_id_counterparty_id] ON [dbo].[calc_formula_value]
DROP INDEX IF EXISTS [IX_PT_calc_formula_value_invoice_line_item_id_seq_number] ON [dbo].[calc_formula_value]
DROP INDEX IF EXISTS [IX_PT_calc_formula_value_invoice_line_item_id_prod_date] ON [dbo].[calc_formula_value]
DROP INDEX IF EXISTS [IX_PT_message_board_source] ON [dbo].[message_board]
DROP INDEX IF EXISTS [IX_PT_calc_formula_value_invoice_line_item_id_seq_number_calc_id] ON [dbo].[calc_formula_value]
DROP INDEX IF EXISTS [IX_PT_calc_formula_value_invoice_line_item_id_seq_number_formula_id] ON [dbo].[calc_formula_value]
DROP INDEX IF EXISTS [IX_PT_calc_formula_value_is_final_result] ON [dbo].[calc_formula_value]
DROP INDEX IF EXISTS [indx_source_price_curve_def_udf_block_group_id] ON [dbo].[source_price_curve_def]
DROP INDEX IF EXISTS [indx_source_price_curve_def001] ON [dbo].[source_price_curve_def]
DROP INDEX IF EXISTS [indx_source_price_curve_def002] ON [dbo].[source_price_curve_def]
DROP INDEX IF EXISTS [indx_source_price_curve_def003] ON [dbo].[source_price_curve_def]
DROP INDEX IF EXISTS [IX_PT_source_deal_detail_audit_header_audit_id] ON [dbo].[source_deal_detail_audit]
DROP INDEX IF EXISTS [IX_PT_SDHA11] ON [dbo].[source_deal_header_audit]
DROP INDEX IF EXISTS [IX_PT_source_deal_header_audit_update_ts] ON [dbo].[source_deal_header_audit]
DROP INDEX IF EXISTS [IX_PT_source_deal_header_audit_user_action_update_ts] ON [dbo].[source_deal_header_audit]
DROP INDEX IF EXISTS [IX_PT_source_deal_pnl_Leg_pnl_as_of_date_pnl_source_value_id_term_start] ON [dbo].[source_deal_pnl]
DROP INDEX IF EXISTS [IX_application_functional_users_role_id] ON [dbo].[application_functional_users]
DROP INDEX IF EXISTS [IX_PT_user_defined_deal_fields_audit_header_audit_id] ON [dbo].[user_defined_deal_fields_audit]
DROP INDEX IF EXISTS [IX_PT_user_defined_deal_fields_audit_source_deal_header_id_udf_audit_id] ON [dbo].[user_defined_deal_fields_audit]
DROP INDEX IF EXISTS [IX_PT_user_defined_deal_detail_fields_audit_header_audit_id] ON [dbo].[user_defined_deal_detail_fields_audit]
DROP INDEX IF EXISTS [IX_source_traders_1] ON [dbo].[source_traders]
DROP INDEX IF EXISTS [indx_source_deal_detail_volume_frequency] ON [dbo].[source_deal_detail]
DROP INDEX IF EXISTS [IX_calc_invoice_volume_recorder] ON [dbo].[calc_invoice_volume_recorder]
DROP INDEX IF EXISTS [IX_calc_invoice_volume_recorder_estimates] ON [dbo].[calc_invoice_volume_recorder_estimates]
DROP INDEX IF EXISTS [IX_PT_calc_formula_value_seq_number_formula_id] ON [dbo].[calc_formula_value]
DROP INDEX IF EXISTS [IX_PT_sdda1] ON [dbo].[source_deal_detail_audit]
DROP INDEX  IF EXISTS [idx_deal_detail_hour_term_date_profile_id] ON [dbo].[deal_detail_hour]
DROP INDEX  IF EXISTS [IX_ssis_mtm_formate2_error_log] ON [dbo].[ssis_mtm_formate2_error_log]
DROP INDEX  IF EXISTS [IX_PT_user_defined_deal_detail_fields_audit_header_audit_id] ON [dbo].[user_defined_deal_detail_fields_audit]
DROP INDEX  IF EXISTS [IX_PT_user_defined_deal_detail_fields_audit_source_deal_detail_id_header_audit_id] ON [dbo].[user_defined_deal_detail_fields_audit]
DROP INDEX  IF EXISTS [IX_ssis_mtm_formate1_error_log] ON [dbo].[ssis_mtm_formate1_error_log]
DROP INDEX  IF EXISTS [indx_source_deal_header_tm4] ON [dbo].[source_deal_header]
DROP INDEX  IF EXISTS [indx_entire_term_end_tm] ON [dbo].[source_deal_header]
DROP INDEX  IF EXISTS [indx_source_deal_header_tm3] ON [dbo].[source_deal_header]
DROP INDEX  IF EXISTS [indx_source_deal_header_tm2] ON [dbo].[source_deal_header]
DROP INDEX  IF EXISTS [IX_source_deal_header_profile_granularity] ON [dbo].[source_deal_header]
DROP INDEX  IF EXISTS [IX_source_deal_header_holiday_calendar] ON [dbo].[source_deal_header]
DROP INDEX  IF EXISTS [IX_source_deal_header_confirmation_type] ON [dbo].[source_deal_header]
DROP INDEX  IF EXISTS [IX_PT_source_deal_header_deal_id] ON [dbo].[source_deal_header]
DROP INDEX  IF EXISTS [IX_fas_books] ON [dbo].[fas_books]
DROP INDEX  IF EXISTS [indx_user_defined_deal_fields_tm] ON [dbo].[user_defined_deal_fields]
DROP INDEX  IF EXISTS [IX_PT_application_functional_users_role_user_flag] ON [dbo].[application_functional_users]
DROP INDEX  IF EXISTS [source_deal_pnl_2] ON [dbo].[source_deal_pnl]
DROP INDEX  IF EXISTS [IX_source_deal_pnl_pnl_source_value_id] ON [dbo].[source_deal_pnl]
DROP INDEX  IF EXISTS [indx_source_deal_pnl_tm1] ON [dbo].[source_deal_pnl]
DROP INDEX  IF EXISTS [indx_source_deal_pnl_tm] ON [dbo].[source_deal_pnl]
DROP INDEX  IF EXISTS [IX_PT_source_deal_pnl_Leg_pnl_as_of_date_pnl_source_value_id_term_start] ON [dbo].[source_deal_pnl]
DROP INDEX  IF EXISTS [IX_PT_source_system_data_import_status_status_id] ON [dbo].[source_system_data_import_status]
DROP INDEX  IF EXISTS [idx_source_system_data_import_status_detail_pro_sou] ON [dbo].[source_system_data_import_status_detail]
DROP INDEX  IF EXISTS [IX_PT_source_deal_header_audit_user_action_update_ts] ON [dbo].[source_deal_header_audit]
DROP INDEX  IF EXISTS [IX_PT_source_deal_header_audit_update_ts] ON [dbo].[source_deal_header_audit]
DROP INDEX  IF EXISTS [idx_source_deal_header_audit_deal_header_id] ON [dbo].[source_deal_header_audit]
DROP INDEX  IF EXISTS [IX_PT_SDHA11] ON [dbo].[source_deal_header_audit]
DROP INDEX  IF EXISTS [IX_PT_user_defined_deal_fields_audit_source_deal_header_id] ON [dbo].[user_defined_deal_fields_audit]
DROP INDEX  IF EXISTS [IX_PT_user_defined_deal_fields_audit_header_audit_id] ON [dbo].[user_defined_deal_fields_audit]
DROP INDEX  IF EXISTS [IX_PT_user_defined_deal_fields_audit_source_deal_header_id_udf_audit_id] ON [dbo].[user_defined_deal_fields_audit]
DROP INDEX  IF EXISTS [IX_PT_user_defined_deal_fields_audit_source_deal_header_id_header_audit_id] ON [dbo].[user_defined_deal_fields_audit]
DROP INDEX  IF EXISTS [IX_source_price_curve_Assessment_curve_type_value_id] ON [dbo].[source_price_curve]
DROP INDEX  IF EXISTS [IX_source_price_curve_curve_source_value_id] ON [dbo].[source_price_curve]
DROP INDEX  IF EXISTS [indx_source_deal_detail_curve] ON [dbo].[source_deal_detail]
DROP INDEX  IF EXISTS [IX_source_deal_detail_Update_ts] ON [dbo].[source_deal_detail]
DROP INDEX  IF EXISTS [IX_PT_source_deal_detail_physical_financial_flag] ON [dbo].[source_deal_detail]
DROP INDEX  IF EXISTS [indx_source_deal_detail_volume_frequency] ON [dbo].[source_deal_detail]
DROP INDEX  IF EXISTS [IX_source_deal_detail_strike_granularity] ON [dbo].[source_deal_detail]
DROP INDEX  IF EXISTS [IX_fas_strategy_1] ON [dbo].[fas_strategy]
DROP INDEX  IF EXISTS [IX_source_book_1] ON [dbo].[source_book]
DROP INDEX  IF EXISTS [indx_report_hourly_position_breakdown_counterparty_id] ON [dbo].[report_hourly_position_breakdown]
DROP INDEX  IF EXISTS [indx_report_hourly_position_breakdown_commodity_id] ON [dbo].[report_hourly_position_breakdown]
DROP INDEX  IF EXISTS [indx_report_hourly_position_breakdown_source_system_book_id] ON [dbo].[report_hourly_position_breakdown]
DROP INDEX  IF EXISTS [indx_report_hourly_position_breakdown_fas_book_id] ON [dbo].[report_hourly_position_breakdown]
DROP INDEX  IF EXISTS [indx_report_hourly_position_breakdown_deal_date] ON [dbo].[report_hourly_position_breakdown]
DROP INDEX  IF EXISTS [indx_report_hourly_position_breakdown_volume_uom_id] ON [dbo].[report_hourly_position_breakdown]
DROP INDEX  IF EXISTS [IX_PT_credit_exposure_detail_netting_counterparty_id] ON [dbo].[credit_exposure_detail]
DROP INDEX  IF EXISTS [IX_PT_credit_exposure_detail_Source_Deal_Header_ID_netting_counterparty_id] ON [dbo].[credit_exposure_detail]
DROP INDEX  IF EXISTS [IX_PT_credit_exposure_detail_as_of_date] ON [dbo].[credit_exposure_detail]
DROP INDEX  IF EXISTS [indx_source_book_name_tm] ON [dbo].[source_book]
DROP INDEX  IF EXISTS [IX_PT_source_deal_detail_audit_source_deal_detail_id] ON [dbo].[source_deal_detail_audit]
DROP INDEX  IF EXISTS [IX_PT_source_deal_detail_audit_header_audit_id] ON [dbo].[source_deal_detail_audit]
DROP INDEX  IF EXISTS [IX_PT_source_deal_detail_audit_source_deal_detail_id_header_audit_id] ON [dbo].[source_deal_detail_audit]
DROP INDEX  IF EXISTS [IX_deal_id_curve] ON [dbo].[source_deal_detail]
DROP INDEX  IF EXISTS [IX_curve_leg] ON [dbo].[source_deal_detail]
DROP INDEX  IF EXISTS [IX_source_system_book_map] ON [dbo].[source_system_book_map]
DROP INDEX  IF EXISTS [UQ_index_source_book_mapping] ON [dbo].[source_system_book_map]
DROP INDEX  IF EXISTS [indx_delta_report_hourly_position_breakdown] ON [dbo].[delta_report_hourly_position_breakdown]
DROP INDEX  IF EXISTS [indx_delta_report_hourly_position_id] ON [dbo].[delta_report_hourly_position]
DROP INDEX  IF EXISTS [IX_PT_message_board_job_name] ON [dbo].[message_board]
DROP INDEX  IF EXISTS [IX_PT_message_board_source] ON [dbo].[message_board]
DROP INDEX  IF EXISTS [IX_PT_report_hourly_position_deal_term_start_expiration_date] ON [dbo].[report_hourly_position_deal]
DROP INDEX  IF EXISTS [indx_counterparty_name_tm] ON [dbo].[source_counterparty]
DROP INDEX  IF EXISTS [IX_source_counterparty_1] ON [dbo].[source_counterparty]
DROP INDEX  IF EXISTS [IX_PT_source_counterparty_int_ext_flag2] ON [dbo].[source_counterparty]
DROP INDEX  IF EXISTS [IX_ssis_position_formate1_error_log] ON [dbo].[ssis_position_formate1_error_log]
DROP INDEX  IF EXISTS [IX_ssis_position_formate2_error_log] ON [dbo].[ssis_position_formate2_error_log]
DROP INDEX  IF EXISTS [IX_PT_source_counterparty_netting_parent_counterparty_id] ON [dbo].[source_counterparty]
DROP INDEX  IF EXISTS [IX_PT_application_functional_users_login_id_role_user_flag] ON [dbo].[application_functional_users]
DROP INDEX  IF EXISTS [IX_source_deal_header_2] ON [dbo].[source_deal_header]
DROP INDEX  IF EXISTS [IX_PT_source_deal_pnl_source_deal_header_id_term_start_pnl_as_of_date] ON [dbo].[source_deal_pnl]
DROP INDEX  IF EXISTS [IX_application_functions_func_ref_id] ON [dbo].[application_functions]
DROP INDEX  IF EXISTS [IX_PT_contract_group_source_system_id] ON [dbo].[contract_group]
DROP INDEX  IF EXISTS [IX_application_functional_users_entity_id] ON [dbo].[application_functional_users]
DROP INDEX  IF EXISTS [IX_user_defined_deal_fields] ON [dbo].[user_defined_deal_fields]
DROP INDEX  IF EXISTS [IX_source_traders_1] ON [dbo].[source_traders]
DROP INDEX  IF EXISTS [index_source_book_mapping] ON [dbo].[source_system_book_map]
DROP INDEX  IF EXISTS [IX_fas_strategy] ON [dbo].[fas_strategy]
DROP INDEX  IF EXISTS [indx_report_hourly_position_profile_deal_id] ON [dbo].[report_hourly_position_profile]
DROP INDEX  IF EXISTS [unique_indx_report_hourly_position_breakdown] ON [dbo].[report_hourly_position_breakdown]
DROP INDEX  IF EXISTS [IX_application_functional_users_function_id] ON [dbo].[application_functional_users]
DROP INDEX  IF EXISTS [IX_application_functional_users_role_id] ON [dbo].[application_functional_users]
DROP INDEX  IF EXISTS [indx_fas_link_detail_dicing_tm] ON [dbo].[fas_link_detail_dicing]
DROP INDEX  IF EXISTS [IX_PT_source_deal_pnl_pnl_as_of_date] ON [dbo].[source_deal_pnl]
DROP INDEX  IF EXISTS [IX_message_board] ON [dbo].[message_board]
DROP INDEX  IF EXISTS [source_deal_pnl_2_1] ON [dbo].[source_deal_pnl]
DROP INDEX  IF EXISTS [IX_PT_hour_block_term_term_date] ON [dbo].[hour_block_term]
DROP INDEX  IF EXISTS [IX_PT_source_deal_pnl_detail_pnl_as_of_date_pnl_source_value_id] ON [dbo].[source_deal_pnl_detail]
DROP INDEX  IF EXISTS [IX_PT_application_functional_users_role_user_flag_function_id] ON [dbo].[application_functional_users]
DROP INDEX  IF EXISTS [indx_confirm_status_tm] ON [dbo].[confirm_status]
DROP INDEX  IF EXISTS [IX_PT_source_counterparty_int_ext_flag] ON [dbo].[source_counterparty]
DROP INDEX  IF EXISTS [IX_source_deal_header] ON [dbo].[source_deal_header]
DROP INDEX  IF EXISTS [IX_PT_source_deal_detail_term_start] ON [dbo].[source_deal_detail]
DROP INDEX  IF EXISTS [IX_source_deal_header_1] ON [dbo].[source_deal_header]
DROP INDEX  IF EXISTS [IX_user_defined_deal_fields_1] ON [dbo].[user_defined_deal_fields]
DROP INDEX  IF EXISTS [IX_source_currency_1] ON [dbo].[source_currency]
DROP INDEX  IF EXISTS [indx_report_hourly_position_deal_deal_id] ON [dbo].[report_hourly_position_deal]
DROP INDEX  IF EXISTS [IX_source_uom_1] ON [dbo].[source_uom]
DROP INDEX  IF EXISTS [indx_source_deal_detail_tm] ON [dbo].[source_deal_detail]
DROP INDEX  IF EXISTS [IX_source_minor_location_meter] ON [dbo].[source_minor_location_meter]
DROP INDEX  IF EXISTS [IX_PT_hour_block_term_term_date1] ON [dbo].[hour_block_term]
DROP INDEX  IF EXISTS [IX_PT_source_deal_pnl_detail_source_deal_header_id_term_start_term_end_Leg_pnl_as_of_date_pnl_source_value_id] ON [dbo].[source_deal_pnl_detail]
DROP INDEX  IF EXISTS [IX_rec_volume_unit_conversion] ON [dbo].[rec_volume_unit_conversion]
DROP INDEX  IF EXISTS [IX_PT_source_price_curve_as_of_date_curve_source_value_id_Assessment_curve_type_value_id] ON [dbo].[source_price_curve]
DROP INDEX  IF EXISTS [IX_PT_calc_formula_value_invoice_line_item_id_seq_number_formula_id] ON [dbo].[calc_formula_value]
DROP INDEX  IF EXISTS [IX_PT_formula_editor_sql_formula_id] ON [dbo].[formula_editor_sql]
DROP INDEX  IF EXISTS [IX_formula_editor_static_value_id] ON [dbo].[formula_editor]
DROP INDEX  IF EXISTS [indx_source_deal_detail_location] ON [dbo].[source_deal_detail]
DROP INDEX  IF EXISTS [IX_PT_source_price_curve_source_curve_def_id111] ON [dbo].[source_price_curve]
DROP INDEX  IF EXISTS [IX_source_system_book_map_1] ON [dbo].[source_system_book_map]
DROP INDEX  IF EXISTS [IX_PT_message_board_process_id] ON [dbo].[message_board]
DROP INDEX  IF EXISTS [IX_fas_subsidiaries] ON [dbo].[fas_subsidiaries]
DROP INDEX  IF EXISTS [IX_portfolio_hierarchy] ON [dbo].[portfolio_hierarchy]
DROP INDEX  IF EXISTS [IX_PT_source_deal_header_close_reference_id] ON [dbo].[source_deal_header]
DROP INDEX  IF EXISTS [indx_source_deal_header_tm1] ON [dbo].[source_deal_header]
DROP INDEX  IF EXISTS [unq_cur_indx_index_fees_breakdown_settlement] ON [dbo].[index_fees_breakdown_settlement]
DROP INDEX  IF EXISTS [indx_mv90_data31] ON [dbo].[mv90_data]
DROP INDEX  IF EXISTS [indx_hour_block_term_11] ON [dbo].[hour_block_term]
DROP INDEX  IF EXISTS [unq_cur_indx_source_deal_settlement] ON [dbo].[source_deal_settlement]
DROP INDEX  IF EXISTS [uci_deal_position_break_down] ON [dbo].[deal_position_break_down]
DROP INDEX  IF EXISTS [IX_PT_mtm_test_run_log_process_id_code] ON [dbo].[mtm_test_run_log]
DROP INDEX  IF EXISTS [IX_PT_message_board_job_name1] ON [dbo].[message_board]
DROP INDEX  IF EXISTS [indx_mv90_data11] ON [dbo].[mv90_data]
DROP INDEX  IF EXISTS [indx_mv90_data_hour1] ON [dbo].[mv90_data_hour]
DROP INDEX  IF EXISTS [IX_PT_source_deal_detail_curve_id] ON [dbo].[source_deal_detail]
DROP INDEX  IF EXISTS [IX_PT_source_price_curve_source_curve_def_id_curve_source_value_id] ON [dbo].[source_price_curve]
DROP INDEX  IF EXISTS [IX_PT_source_price_curve_maturity_date] ON [dbo].[source_price_curve]
DROP INDEX  IF EXISTS [IX_PT_source_price_curve_as_of_date_curve_source_value_id] ON [dbo].[source_price_curve]
DROP INDEX  IF EXISTS [IX_source_deal_header_template] ON [dbo].[source_deal_header_template]
DROP INDEX  IF EXISTS [IDX_holiday_group] ON [dbo].[holiday_group]
DROP INDEX IF EXISTS [IX_PT_source_deal_header_deal_id] ON [dbo].[source_deal_header]

DROP INDEX  IF EXISTS [indx_calcprocess_aoci_release_tm] ON [dbo].[calcprocess_aoci_release]
DROP INDEX  IF EXISTS [indx_calcprocess_deals_tm] ON [dbo].[calcprocess_deals]
DROP INDEX  IF EXISTS [indx_calcprocess_deals_expired_tm] ON [dbo].[calcprocess_deals_expired]
IF EXISTS(SELECT 1 FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS where CONSTRAINT_TYPE='UNIQUE' and table_name='contract_charge_type_detail' and CONSTRAINT_NAME = 'IX_contract_charge_type_detail_template')
BEGIN
	ALTER TABLE 
	/**
		INDEX
		IX_contract_charge_type_detail_template : Drop IX_contract_charge_type_detail_template
	*/
	contract_charge_type_detail DROP CONSTRAINT IX_contract_charge_type_detail_template;
END
Drop INDEX IF EXISTS [IX_contract_charge_type_detail_template] ON [contract_charge_type_detail]

Drop INDEX IF EXISTS [idx_deal_voided_in_external_source_deal_header_id] ON [deal_voided_in_external]
Drop INDEX IF EXISTS [indx_fas_eff_ass_test_results_tm] ON [fas_eff_ass_test_results]	
Drop INDEX IF EXISTS [indx_fas_eff_ass_test_results_tm1] ON [fas_eff_ass_test_results]	
Drop INDEX IF EXISTS [indx_fas_eff_ass_test_results_tm2] ON [fas_eff_ass_test_results]	
Drop INDEX IF EXISTS [indx_fas_eff_ass_test_results_tm3] ON [fas_eff_ass_test_results]	
Drop INDEX IF EXISTS [indx_fas_eff_ass_test_results1_tm] ON [fas_eff_ass_test_results]	
Drop INDEX IF EXISTS [indx_fas_link_detail_tm] ON [fas_link_detail]	
Drop INDEX IF EXISTS [IX_PT_hour_block_term_term_date] ON [hour_block_term]

IF EXISTS(SELECT 1 from INFORMATION_SCHEMA.TABLE_CONSTRAINTS where CONSTRAINT_TYPE='UNIQUE' and table_name='rec_volume_unit_conversion' and CONSTRAINT_NAME = 'IX_rec_volume_unit_conversion_1')
BEGIN
	ALTER TABLE
	/**
		INDEX
		IX_rec_volume_unit_conversion_1 : Drop IX_rec_volume_unit_conversion_1
	*/
	rec_volume_unit_conversion DROP CONSTRAINT IX_rec_volume_unit_conversion_1;
END
Drop INDEX IF EXISTS [IX_rec_volume_unit_conversion_1] ON [rec_volume_unit_conversion]

Drop INDEX IF EXISTS [indx_report_measurement_values_tm] ON [report_measurement_values]
Drop INDEX IF EXISTS [indx_report_measurement_values_expired_tm] ON [report_measurement_values_expired]
Drop INDEX IF EXISTS [IX_PT_source_counterparty_int_ext_flag] ON [source_counterparty]
Drop INDEX IF EXISTS [IX_PT_source_counterparty_int_ext_flag1] ON [source_counterparty]
Drop INDEX IF EXISTS [IX_PT_source_counterparty_int_ext_flag2] ON [source_counterparty]
Drop INDEX IF EXISTS [IX_PT_source_deal_delta_value_run_date] ON [source_deal_delta_value]
Drop INDEX IF EXISTS [IX_source_deal_pnl_pnl_source_value_id] ON [source_deal_pnl]
Drop INDEX IF EXISTS [source_deal_pnl_arch1_2_1] ON [source_deal_pnl_arch1]
Drop INDEX IF EXISTS [source_deal_pnl_arch_2_1] ON [source_deal_pnl_arch2]
Drop INDEX IF EXISTS [IX_PT_source_price_simulation_delta_run_date_source_curve_def_id_as_of_date_curve_source_value_id_maturity_date] ON [source_price_simulation_delta]
Drop INDEX IF EXISTS [indx_user_defined_deal_fields_tm] ON [user_defined_deal_fields]
Drop INDEX IF EXISTS [IX_PT_user_defined_deal_fields_audit_source_deal_header_id] ON [user_defined_deal_fields_audit]
Drop INDEX IF EXISTS  [IX_source_deal_pnl_pnl_source_value_id] ON [source_deal_pnl]
Drop INDEX IF EXISTS  [indx_user_defined_deal_fields_tm] ON [user_defined_deal_fields]

--IF EXISTS(SELECT 1 FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS where CONSTRAINT_TYPE='UNIQUE' and table_name='source_deal_header' and CONSTRAINT_NAME = 'IX_source_deal_header_unique')
--BEGIN
--	ALTER TABLE
--	/**
--		INDEX
--		IX_source_deal_header_unique : Drop IX_source_deal_header_unique
--	*/
--	source_deal_header DROP CONSTRAINT IX_source_deal_header_unique;
--END
--Drop INDEX IF EXISTS [IX_source_deal_header_unique] ON [source_deal_header]
----add unique constraint source_system_id, deal_id 

--IF NOT EXISTS  (SELECT 1 FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS where CONSTRAINT_TYPE='UNIQUE' and table_name='source_deal_header' and CONSTRAINT_NAME = 'IX_source_deal_header_unique')
--BEGIN
--	ALTER TABLE 
--	/**
--		INDEX
--		UC_logical_name : Add UC_logical_name
--	*/
--	source_deal_header ADD CONSTRAINT IX_source_deal_header_unique UNIQUE(source_system_id,deal_id);

--END


Drop INDEX IF EXISTS  [indx_source_deal_header_tm1] ON [source_deal_header]
Drop INDEX IF EXISTS  [IX_source_deal_header_profile_granularity] ON [source_deal_header]
Drop INDEX IF EXISTS  [IX_source_deal_header_1] ON [source_deal_header]
Drop INDEX IF EXISTS  [IX_source_deal_header] ON [source_deal_header]
Drop INDEX IF EXISTS  [IX_PT_source_deal_header_deal_id] ON [source_deal_header] 
Drop INDEX IF EXISTS  [IX_source_deal_header_holiday_calendar] ON [source_deal_header] 
Drop INDEX IF EXISTS  [indx_entire_term_end_tm] ON [source_deal_header] 
Drop INDEX IF EXISTS  [indx_source_deal_header_tm2] ON [source_deal_header] 
Drop INDEX IF EXISTS  [indx_source_deal_header_tm3] ON [source_deal_header] 
Drop INDEX IF EXISTS  [indx_source_deal_header_tm4] ON [source_deal_header] 
Drop INDEX IF EXISTS  [IX_source_deal_header_confirmation_type] ON [source_deal_header] 
Drop INDEX IF EXISTS  [IX_PT_calc_formula_value_invoice_line_item_id_prod_date] ON [calc_formula_value]
Drop INDEX IF EXISTS  [IX_PT_calc_formula_value_invoice_line_item_id_prod_date_calc_id]  ON [calc_formula_value]
Drop INDEX IF EXISTS  [IX_PT_calc_formula_value_invoice_line_item_id_prod_date_contract_id_counterparty_id]  ON [calc_formula_value]
Drop INDEX IF EXISTS  [IX_PT_calc_formula_value_invoice_line_item_id_seq_number]  ON [calc_formula_value]
Drop INDEX IF EXISTS  [IX_PT_calc_formula_value_invoice_line_item_id_seq_number_calc_id] ON [calc_formula_value]
Drop INDEX IF EXISTS  [IX_PT_calc_formula_value_invoice_line_item_id_seq_number_calc_id_formula_id] ON [calc_formula_value]
Drop INDEX IF EXISTS  [IX_calc_formula_value_invoice_line_item_id]  ON [calc_formula_value]
Drop INDEX IF EXISTS  [IX_PT_calc_formula_value_is_final_result] ON [source_deal_detail]
Drop INDEX IF EXISTS  [IX_PT_calc_formula_value_calc_id]  ON [source_deal_detail]
Drop INDEX IF EXISTS  [IX_PT_calc_formula_value_calc_id_is_final_result] ON [source_deal_detail]
Drop INDEX IF EXISTS  [IX_PT_calc_formula_value_invoice_line_item_id]   ON [source_deal_detail]
Drop INDEX IF EXISTS  [indx_source_deal_detail_tm]  ON [source_deal_detail]
Drop INDEX IF EXISTS  [IX_deal_id_curve]  ON [source_deal_detail]
Drop INDEX IF EXISTS  [IX_PT_source_deal_detail_curve_id]  ON [source_deal_detail]
Drop INDEX IF EXISTS  [IX_source_deal_detail_Update_ts]  ON [source_deal_detail]
Drop INDEX IF EXISTS  [indx_source_deal_detail_location] ON [source_deal_detail]
Drop INDEX IF EXISTS  [IX_PT_source_deal_detail_physical_financial_flag] ON [source_deal_detail]
Drop INDEX IF EXISTS  [IX_curve_leg] ON [source_deal_detail]
Drop INDEX IF EXISTS  [IX_source_deal_detail_strike_granularity] ON [source_deal_detail]
Drop INDEX IF EXISTS  [indx_source_deal_detail_curve] ON [source_deal_detail]
Drop INDEX IF EXISTS  [indx_source_deal_detail_volume_frequency] ON [source_deal_detail]

--IF EXISTS(SELECT 1 FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS where CONSTRAINT_TYPE='UNIQUE' and table_name='source_counterparty' and CONSTRAINT_NAME = 'IX_source_counterparty')
--BEGIN
--	ALTER TABLE 
--	/**
--		INDEX
--		IX_source_counterparty : Drop IX_source_counterparty
--	*/
--	source_counterparty DROP CONSTRAINT IX_source_counterparty;
--END
--Drop INDEX IF EXISTS [IX_source_counterparty] ON [source_counterparty]

--IF NOT EXISTS  (SELECT 1 FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS where CONSTRAINT_TYPE='UNIQUE' and table_name='source_counterparty' and CONSTRAINT_NAME = 'IX_source_counterparty')
--BEGIN
--	ALTER TABLE 
--	/**
--		INDEX
--		UC_logical_name : Add UC_logical_name
--	*/
--	source_counterparty ADD CONSTRAINT IX_source_counterparty UNIQUE(source_system_id, counterparty_id);

--END

Drop INDEX IF EXISTS [IX_source_counterparty_1]  ON [source_counterparty]
Drop INDEX IF EXISTS [IX_PT_source_counterparty_netting_parent_counterparty_id] ON [source_counterparty]
Drop INDEX IF EXISTS [indx_counterparty_name_tm]  ON [source_counterparty]
Drop INDEX IF EXISTS [IX_PT_source_counterparty_int_ext_flag1] ON [source_counterparty]
Drop INDEX IF EXISTS [IX_PT_source_counterparty_int_ext_flag2]  ON [source_counterparty]
Drop INDEX IF EXISTS [IX_PT_source_deal_pnl_source_deal_header_id_term_start_pnl_as_of_date]  ON [source_deal_pnl]
Drop INDEX IF EXISTS [source_deal_pnl_2] ON [source_deal_pnl]
Drop INDEX IF EXISTS [IX_PT_source_deal_pnl_Leg_pnl_as_of_date_pnl_source_value_id_term_start] ON [source_deal_pnl]
Drop INDEX IF EXISTS [indx_source_deal_pnl_tm] ON [source_deal_pnl]
Drop INDEX IF EXISTS [indx_source_deal_pnl_tm1] ON [source_deal_pnl]
Drop INDEX IF EXISTS [IX_source_deal_pnl_pnl_source_value_id]ON [source_deal_pnl] 
Drop INDEX IF EXISTS [IX_PT_source_price_curve_maturity_date]ON [source_price_curve]
--IF EXISTS(SELECT 1 FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS where CONSTRAINT_TYPE='UNIQUE' and table_name='source_price_curve' and CONSTRAINT_NAME = 'IX_unique_source_curve_def_id_index')
--BEGIN
--	ALTER TABLE  
--	/**
--		INDEX
--		IX_unique_source_curve_def_id_index : Drop IX_unique_source_curve_def_id_index
--	*/
--	source_price_curve
--	DROP CONSTRAINT IX_unique_source_curve_def_id_index;
--END
--Drop INDEX IF EXISTS [IX_unique_source_curve_def_id_index] ON [source_price_curve]
--IF NOT EXISTS(SELECT 1 FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS where CONSTRAINT_TYPE='UNIQUE' and table_name='source_system_book_map' and CONSTRAINT_NAME = 'IX_unique_source_curve_def_id_index')
--BEGIN
--	ALTER TABLE 
--	/**
--		INDEX
--		UC_logical_name : Add UC_logical_name
--	*/
--	source_price_curve ADD CONSTRAINT IX_unique_source_curve_def_id_index UNIQUE(as_of_date, source_curve_def_id, maturity_date, is_dst, curve_source_value_id, Assessment_curve_type_value_id);
--END
---as_of_date, source_curve_def_id, maturity_date, is_dst, curve_source_value_id, Assessment_curve_type_value_id

Drop INDEX IF EXISTS [IX_PT_source_price_curve_source_curve_def_id111] ON [source_price_curve]
Drop INDEX IF EXISTS [IX_source_price_curve_Assessment_curve_type_value_id] ON [source_price_curve]
Drop INDEX IF EXISTS [IX_source_price_curve_curve_source_value_id] ON [source_price_curve]
Drop INDEX IF EXISTS [IX_PT_application_functional_users_role_user_flag_function_id] ON [application_functional_users]
Drop INDEX IF EXISTS [IX_application_functional_users_role_id] ON [application_functional_users]
Drop INDEX IF EXISTS [IX_application_functional_users_entity_id] ON [application_functional_users]
Drop INDEX IF EXISTS [indx_report_hourly_position_breakdown_deal_date] ON [report_hourly_position_breakdown]
Drop INDEX IF EXISTS [indx_report_hourly_position_breakdown_commodity_id] ON [report_hourly_position_breakdown]
Drop INDEX IF EXISTS [indx_report_hourly_position_breakdown_counterparty_id] ON [report_hourly_position_breakdown]
Drop INDEX IF EXISTS [indx_report_hourly_position_breakdown_fas_book_id] ON [report_hourly_position_breakdown]
Drop INDEX IF EXISTS [indx_report_hourly_position_breakdown_source_system_book_id] ON [report_hourly_position_breakdown]
Drop INDEX IF EXISTS [indx_report_hourly_position_breakdown_volume_uom_id] ON [report_hourly_position_breakdown]
--IF EXISTS(SELECT 1 FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS where CONSTRAINT_TYPE='UNIQUE' and table_name='source_system_book_map' and CONSTRAINT_NAME = 'UC_logical_name')
--BEGIN
--	ALTER TABLE 
--	/**
--		INDEX
--		UC_logical_name : Drop UC_logical_name
--	*/
--	source_system_book_map DROP CONSTRAINT UC_logical_name;
--	---logical_name
--END
--Drop INDEX IF EXISTS [UC_logical_name] ON [source_system_book_map]
--
--IF NOT EXISTS(SELECT 1 FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS where CONSTRAINT_TYPE='UNIQUE' and table_name='source_system_book_map' and CONSTRAINT_NAME = 'UC_logical_name')
--BEGIN
--	ALTER TABLE 
--	/**
--		INDEX
--		UC_logical_name : Add UC_logical_name
--	*/
--	source_system_book_map ADD CONSTRAINT UC_logical_name UNIQUE(logical_name);
--END
Drop INDEX IF EXISTS [UQ_index_source_book_mapping] ON [source_system_book_map]
Drop INDEX IF EXISTS [IX_source_system_book_map] ON [source_system_book_map]
Drop INDEX IF EXISTS [indx_source_price_curve_def_commodity] ON [source_system_book_map]
Drop INDEX IF EXISTS [indx_source_price_curve_def_udf_block_group_id] ON [source_price_curve_def]
Drop INDEX IF EXISTS [IX_PT_sdda1] ON [source_deal_detail_audit]
Drop INDEX IF EXISTS [IX_PT_source_deal_detail_audit_header_audit_id] ON [source_deal_detail_audit]

IF NOT EXISTS (SELECT NAME FROM sys.indexes WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[adiha_grid_columns_definition]') AND NAME = N'indx_adiha_grid_columns_definition')
BEGIN
	CREATE INDEX  indx_adiha_grid_columns_definition ON adiha_grid_columns_definition ([grid_id], [field_type])
END

IF NOT EXISTS (SELECT NAME FROM sys.indexes WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[credit_exposure_detail]') AND NAME = N'indx_credit_exposure_detail')
BEGIN
	CREATE INDEX  indx_credit_exposure_detail ON credit_exposure_detail ([as_of_date], [curve_source_value_id], [Source_Counterparty_ID]) INCLUDE ([internal_counterparty_id], [contract_id])
END

IF NOT EXISTS (SELECT NAME FROM sys.indexes WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[deal_position_break_down]') AND NAME = N'indx_deal_position_break_down')
BEGIN
	CREATE INDEX  indx_deal_position_break_down ON [deal_position_break_down] ([source_deal_header_id]) INCLUDE ([curve_id])
END
IF NOT EXISTS (SELECT NAME FROM sys.indexes WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[deal_price_type]') AND NAME = N'indx_deal_price_type')
BEGIN
	CREATE INDEX  indx_deal_price_type ON [deal_price_type] ([source_deal_detail_id]) INCLUDE ([deal_price_type_id], [price_type_id])
END
IF NOT EXISTS (SELECT NAME FROM sys.indexes WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[email_notes]') AND NAME = N'indx_email_notes')
BEGIN
	CREATE INDEX  indx_email_notes ON [email_notes] ([mailitem_id])
END
IF NOT EXISTS (SELECT NAME FROM sys.indexes WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[holiday_group]') AND NAME = N'indx_holiday_group')
BEGIN
	CREATE INDEX  indx_holiday_group ON [holiday_group] ([hol_group_value_id], [hol_date])
END
IF NOT EXISTS (SELECT NAME FROM sys.indexes WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[message_board]') AND NAME = N'indx_message_board')
BEGIN
	CREATE INDEX  indx_message_board ON [message_board] ([process_id],[source])
END
IF NOT EXISTS (SELECT NAME FROM sys.indexes WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[report_hourly_position_deal]') AND NAME = N'indx_report_hourly_position_deal')
BEGIN
	CREATE INDEX  indx_report_hourly_position_deal ON [report_hourly_position_deal] ([source_deal_header_id]) INCLUDE ([curve_id], [location_id], [term_start], [deal_date], [commodity_id], [counterparty_id], [fas_book_id], [source_system_book_id1], [source_system_book_id2], [source_system_book_id3], [source_system_book_id4], [deal_volume_uom_id], [physical_financial_flag], [hr1], [hr2], [hr3], [hr4], [hr5], [hr6], [hr7], [hr8], [hr9], [hr10], [hr11], [hr12], [hr13], [hr14], [hr15], [hr16], [hr17], [hr18], [hr19], [hr20], [hr21], [hr22], [hr23], [hr24], [hr25], [expiration_date])
END
IF NOT EXISTS (SELECT NAME FROM sys.indexes WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[report_hourly_position_profile]') AND NAME = N'indx_report_hourly_position_profile_1')
BEGIN
	CREATE INDEX indx_report_hourly_position_profile_1 ON [report_hourly_position_profile] ([source_deal_header_id],[deal_date]) INCLUDE ([curve_id], [location_id], [term_start], [commodity_id], [counterparty_id], [fas_book_id], [source_system_book_id1], [source_system_book_id2], [source_system_book_id3], [source_system_book_id4], [deal_volume_uom_id], [physical_financial_flag], [hr1], [hr2], [hr3], [hr4], [hr5], [hr6], [hr7], [hr8], [hr9], [hr10], [hr11], [hr12], [hr13], [hr14], [hr15], [hr16], [hr17], [hr18], [hr19], [hr20], [hr21], [hr22], [hr23], [hr24], [hr25], [expiration_date], [deal_status_id])
END
IF NOT EXISTS (SELECT NAME FROM sys.indexes WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[report_param]') AND NAME = N'indx_report_param')
BEGIN
	CREATE INDEX  indx_report_param ON  [report_param] ([dataset_paramset_id],[operator]) INCLUDE ([column_id], [initial_value])
END
IF NOT EXISTS (SELECT NAME FROM sys.indexes WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[source_deal_detail]') AND NAME = N'indx_source_deal_detail')
BEGIN
	CREATE INDEX  indx_source_deal_detail ON  [source_deal_detail] ([source_deal_group_id])
END
IF NOT EXISTS (SELECT NAME FROM sys.indexes WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[source_deal_header_audit]') AND NAME = N'indx_source_deal_header_audit')
BEGIN
	CREATE INDEX  indx_source_deal_header_audit ON  [source_deal_header_audit] ([source_deal_header_id]) INCLUDE ([audit_id])
END
IF NOT EXISTS (SELECT NAME FROM sys.indexes WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[source_deal_settlement]') AND NAME = N'indx_source_deal_settlement')
BEGIN
	CREATE INDEX  indx_source_deal_settlement ON  [source_deal_settlement] ([source_deal_header_id], [leg]) INCLUDE ([as_of_date], [settlement_date], [term_start], [term_end], [set_type])
END
IF NOT EXISTS (SELECT NAME FROM sys.indexes WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[source_system_data_import_status_detail]') AND NAME = N'indx_source_system_data_import_status_detail')
BEGIN
	CREATE INDEX  indx_source_system_data_import_status_detail ON  [source_system_data_import_status_detail] ([process_id], [source]) INCLUDE ([type])
END
IF NOT EXISTS (SELECT NAME FROM sys.indexes WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[source_system_data_import_status_detail]') AND NAME = N'indx_source_system_data_import_status_detail_1')
BEGIN
	CREATE INDEX  indx_source_system_data_import_status_detail_1 ON [source_system_data_import_status_detail] ([process_id], [source]) INCLUDE ([type], [description], [type_error], [import_file_name])
END
IF NOT EXISTS (SELECT NAME FROM sys.indexes WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[user_application_log]') AND NAME = N'indx_user_application_log')
BEGIN
	CREATE INDEX  indx_user_application_log ON  [user_application_log] ([user_login_id], [product_category]) INCLUDE ([function_id], [function_name], [log_date], [file_path])
END
IF NOT EXISTS (SELECT NAME FROM sys.indexes WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[workflow_activities]') AND NAME = N'indx_workflow_activities')
BEGIN
	CREATE INDEX  indx_workflow_activities ON  [workflow_activities] ([event_message_id], [control_status]) INCLUDE ([workflow_activity_id], [create_ts])
END