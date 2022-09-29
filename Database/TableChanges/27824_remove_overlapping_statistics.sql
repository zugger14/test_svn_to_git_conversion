IF EXISTS(SELECT 1 FROM sys.stats WHERE OBJECT_ID = OBJECT_ID('[dbo].[user_defined_deal_fields_audit]') AND name='_WA_Sys_00000003_00527994')
  DROP STATISTICS [dbo].[user_defined_deal_fields_audit]._WA_Sys_00000003_00527994
 GO
IF EXISTS(SELECT 1 FROM sys.stats WHERE OBJECT_ID = OBJECT_ID('[dbo].[deal_detail_hour]') AND name='_WA_Sys_00000001_0052AB5E')
  DROP STATISTICS [dbo].[deal_detail_hour]._WA_Sys_00000001_0052AB5E
 GO
IF EXISTS(SELECT 1 FROM sys.stats WHERE OBJECT_ID = OBJECT_ID('[dbo].[deal_detail_hour]') AND name='_WA_Sys_00000002_0052AB5E')
  DROP STATISTICS [dbo].[deal_detail_hour]._WA_Sys_00000002_0052AB5E
 GO
IF EXISTS(SELECT 1 FROM sys.stats WHERE OBJECT_ID = OBJECT_ID('[dbo].[matching_header]') AND name='_WA_Sys_00000005_018AF136')
  DROP STATISTICS [dbo].[matching_header]._WA_Sys_00000005_018AF136
 GO
IF EXISTS(SELECT 1 FROM sys.stats WHERE OBJECT_ID = OBJECT_ID('[dbo].[my_report_group]') AND name='_WA_Sys_00000001_0242B36C')
  DROP STATISTICS [dbo].[my_report_group]._WA_Sys_00000001_0242B36C
 GO
IF EXISTS(SELECT 1 FROM sys.stats WHERE OBJECT_ID = OBJECT_ID('[dbo].[optimizer_detail_hour]') AND name='_WA_Sys_00000003_04A060BE')
  DROP STATISTICS [dbo].[optimizer_detail_hour]._WA_Sys_00000003_04A060BE
 GO
IF EXISTS(SELECT 1 FROM sys.stats WHERE OBJECT_ID = OBJECT_ID('[dbo].[invoice_header]') AND name='_WA_Sys_counterparty_id_04B60D13')
  DROP STATISTICS [dbo].[invoice_header]._WA_Sys_counterparty_id_04B60D13
 GO
IF EXISTS(SELECT 1 FROM sys.stats WHERE OBJECT_ID = OBJECT_ID('[dbo].[process_generation_unit_cost]') AND name='_WA_Sys_00000003_04ECA9BC')
  DROP STATISTICS [dbo].[process_generation_unit_cost]._WA_Sys_00000003_04ECA9BC
 GO
IF EXISTS(SELECT 1 FROM sys.stats WHERE OBJECT_ID = OBJECT_ID('[dbo].[source_system_description]') AND name='_WA_Sys_source_system_name_04F3A230')
  DROP STATISTICS [dbo].[source_system_description]._WA_Sys_source_system_name_04F3A230
 GO
IF EXISTS(SELECT 1 FROM sys.stats WHERE OBJECT_ID = OBJECT_ID('[dbo].[source_deal_detail_audit]') AND name='_WA_Sys_00000003_055D1CF7')
  DROP STATISTICS [dbo].[source_deal_detail_audit]._WA_Sys_00000003_055D1CF7
 GO
IF EXISTS(SELECT 1 FROM sys.stats WHERE OBJECT_ID = OBJECT_ID('[dbo].[deal_type_pricing_maping]') AND name='_WA_Sys_00000002_05D5E0FD')
  DROP STATISTICS [dbo].[deal_type_pricing_maping]._WA_Sys_00000002_05D5E0FD
 GO
IF EXISTS(SELECT 1 FROM sys.stats WHERE OBJECT_ID = OBJECT_ID('[dbo].[state_properties_pricing]') AND name='_WA_Sys_00000002_063DFB0F')
  DROP STATISTICS [dbo].[state_properties_pricing]._WA_Sys_00000002_063DFB0F
 GO
IF EXISTS(SELECT 1 FROM sys.stats WHERE OBJECT_ID = OBJECT_ID('[dbo].[user_defined_deal_detail_fields]') AND name='_WA_Sys_00000002_0690D08F')
  DROP STATISTICS [dbo].[user_defined_deal_detail_fields]._WA_Sys_00000002_0690D08F
 GO
IF EXISTS(SELECT 1 FROM sys.stats WHERE OBJECT_ID = OBJECT_ID('[dbo].[deal_rec_assignment_audit]') AND name='_WA_Sys_source_deal_header_id_0765FA87')
  DROP STATISTICS [dbo].[deal_rec_assignment_audit]._WA_Sys_source_deal_header_id_0765FA87
 GO
IF EXISTS(SELECT 1 FROM sys.stats WHERE OBJECT_ID = OBJECT_ID('[dbo].[fas_dedesignated_locked_aoci]') AND name='_WA_Sys_00000010_0838BE4B')
  DROP STATISTICS [dbo].[fas_dedesignated_locked_aoci]._WA_Sys_00000010_0838BE4B
 GO
IF EXISTS(SELECT 1 FROM sys.stats WHERE OBJECT_ID = OBJECT_ID('[dbo].[rec_generator_group]') AND name='_WA_Sys_generator_group_id_08B18680')
  DROP STATISTICS [dbo].[rec_generator_group]._WA_Sys_generator_group_id_08B18680
 GO
IF EXISTS(SELECT 1 FROM sys.stats WHERE OBJECT_ID = OBJECT_ID('[dbo].[rec_generator_group]') AND name='_WA_Sys_generator_group_id_08B18680')
  DROP STATISTICS [dbo].[rec_generator_group]._WA_Sys_generator_group_id_08B18680
 GO
IF EXISTS(SELECT 1 FROM sys.stats WHERE OBJECT_ID = OBJECT_ID('[dbo].[rec_generator_group]') AND name='_WA_Sys_generator_group_name_08B18680')
  DROP STATISTICS [dbo].[rec_generator_group]._WA_Sys_generator_group_name_08B18680
 GO
IF EXISTS(SELECT 1 FROM sys.stats WHERE OBJECT_ID = OBJECT_ID('[dbo].[source_deal_pnl_detail]') AND name='_WA_Sys_00000005_08E7F15F')
  DROP STATISTICS [dbo].[source_deal_pnl_detail]._WA_Sys_00000005_08E7F15F
 GO
IF EXISTS(SELECT 1 FROM sys.stats WHERE OBJECT_ID = OBJECT_ID('[dbo].[source_deal_pnl_arch2]') AND name='_WA_Sys_00000001_09BFE0F0')
  DROP STATISTICS [dbo].[source_deal_pnl_arch2]._WA_Sys_00000001_09BFE0F0
 GO
IF EXISTS(SELECT 1 FROM sys.stats WHERE OBJECT_ID = OBJECT_ID('[dbo].[source_deal_pnl_arch2]') AND name='_WA_Sys_0000000C_09BFE0F0')
  DROP STATISTICS [dbo].[source_deal_pnl_arch2]._WA_Sys_0000000C_09BFE0F0
 GO
IF EXISTS(SELECT 1 FROM sys.stats WHERE OBJECT_ID = OBJECT_ID('[dbo].[source_deal_pnl_arch2]') AND name='_WA_Sys_00000005_09BFE0F0')
  DROP STATISTICS [dbo].[source_deal_pnl_arch2]._WA_Sys_00000005_09BFE0F0
 GO
IF EXISTS(SELECT 1 FROM sys.stats WHERE OBJECT_ID = OBJECT_ID('[dbo].[source_deal_pnl_arch2]') AND name='_WA_Sys_00000001_09BFE0F0')
  DROP STATISTICS [dbo].[source_deal_pnl_arch2]._WA_Sys_00000001_09BFE0F0
 GO
IF EXISTS(SELECT 1 FROM sys.stats WHERE OBJECT_ID = OBJECT_ID('[dbo].[source_deal_settlement]') AND name='_WA_Sys_00000004_09DC1598')
  DROP STATISTICS [dbo].[source_deal_settlement]._WA_Sys_00000004_09DC1598
 GO
IF EXISTS(SELECT 1 FROM sys.stats WHERE OBJECT_ID = OBJECT_ID('[dbo].[source_system_data_import_status]') AND name='_WA_Sys_00000001_0A0BC65A')
  DROP STATISTICS [dbo].[source_system_data_import_status]._WA_Sys_00000001_0A0BC65A
 GO
IF EXISTS(SELECT 1 FROM sys.stats WHERE OBJECT_ID = OBJECT_ID('[dbo].[source_price_curve]') AND name='_WA_Sys_00000001_0AD039D1')
  DROP STATISTICS [dbo].[source_price_curve]._WA_Sys_00000001_0AD039D1
 GO
IF EXISTS(SELECT 1 FROM sys.stats WHERE OBJECT_ID = OBJECT_ID('[dbo].[source_price_curve]') AND name='_WA_Sys_00000001_0AD039D1')
  DROP STATISTICS [dbo].[source_price_curve]._WA_Sys_00000001_0AD039D1
 GO
IF EXISTS(SELECT 1 FROM sys.stats WHERE OBJECT_ID = OBJECT_ID('[dbo].[source_price_curve]') AND name='_WA_Sys_00000002_0AD039D1')
  DROP STATISTICS [dbo].[source_price_curve]._WA_Sys_00000002_0AD039D1
 GO
IF EXISTS(SELECT 1 FROM sys.stats WHERE OBJECT_ID = OBJECT_ID('[dbo].[pnl_component_price_detail]') AND name='_WA_Sys_00000002_0B1526C7')
  DROP STATISTICS [dbo].[pnl_component_price_detail]._WA_Sys_00000002_0B1526C7
 GO
IF EXISTS(SELECT 1 FROM sys.stats WHERE OBJECT_ID = OBJECT_ID('[dbo].[user_defined_deal_detail_fields_audit]') AND name='_WA_Sys_00000003_0B18BBE6')
  DROP STATISTICS [dbo].[user_defined_deal_detail_fields_audit]._WA_Sys_00000003_0B18BBE6
 GO
IF EXISTS(SELECT 1 FROM sys.stats WHERE OBJECT_ID = OBJECT_ID('[dbo].[deal_confirmation_status]') AND name='_WA_Sys_00000001_0B5BE064')
  DROP STATISTICS [dbo].[deal_confirmation_status]._WA_Sys_00000001_0B5BE064
 GO
IF EXISTS(SELECT 1 FROM sys.stats WHERE OBJECT_ID = OBJECT_ID('[dbo].[transportation_contract_capacity]') AND name='_WA_Sys_00000001_0BAC2215')
  DROP STATISTICS [dbo].[transportation_contract_capacity]._WA_Sys_00000001_0BAC2215
 GO
IF EXISTS(SELECT 1 FROM sys.stats WHERE OBJECT_ID = OBJECT_ID('[dbo].[deal_fields_mapping]') AND name='_WA_Sys_00000003_0D1AD6FB')
  DROP STATISTICS [dbo].[deal_fields_mapping]._WA_Sys_00000003_0D1AD6FB
 GO
IF EXISTS(SELECT 1 FROM sys.stats WHERE OBJECT_ID = OBJECT_ID('[dbo].[maintain_field_template_group]') AND name='_WA_Sys_00000002_0D3DCE1E')
  DROP STATISTICS [dbo].[maintain_field_template_group]._WA_Sys_00000002_0D3DCE1E
 GO
IF EXISTS(SELECT 1 FROM sys.stats WHERE OBJECT_ID = OBJECT_ID('[dbo].[maintain_field_template_group]') AND name='_WA_Sys_00000002_0D3DCE1E')
  DROP STATISTICS [dbo].[maintain_field_template_group]._WA_Sys_00000002_0D3DCE1E
 GO
IF EXISTS(SELECT 1 FROM sys.stats WHERE OBJECT_ID = OBJECT_ID('[dbo].[pratos_source_price_curve_map]') AND name='_WA_Sys_00000004_0DB20413')
  DROP STATISTICS [dbo].[pratos_source_price_curve_map]._WA_Sys_00000004_0DB20413
 GO
IF EXISTS(SELECT 1 FROM sys.stats WHERE OBJECT_ID = OBJECT_ID('[dbo].[alert_output_status]') AND name='_WA_Sys_00000001_0F7D7E50')
  DROP STATISTICS [dbo].[alert_output_status]._WA_Sys_00000001_0F7D7E50
 GO
IF EXISTS(SELECT 1 FROM sys.stats WHERE OBJECT_ID = OBJECT_ID('[dbo].[mtm_test_run_log]') AND name='_WA_Sys_mtm_test_run_log_id_0FEEBCE2')
  DROP STATISTICS [dbo].[mtm_test_run_log]._WA_Sys_mtm_test_run_log_id_0FEEBCE2
 GO
IF EXISTS(SELECT 1 FROM sys.stats WHERE OBJECT_ID = OBJECT_ID('[dbo].[alert_reports]') AND name='_WA_Sys_00000001_1071A289')
  DROP STATISTICS [dbo].[alert_reports]._WA_Sys_00000001_1071A289
 GO
IF EXISTS(SELECT 1 FROM sys.stats WHERE OBJECT_ID = OBJECT_ID('[dbo].[alert_reports]') AND name='_WA_Sys_00000002_1071A289')
  DROP STATISTICS [dbo].[alert_reports]._WA_Sys_00000002_1071A289
 GO
IF EXISTS(SELECT 1 FROM sys.stats WHERE OBJECT_ID = OBJECT_ID('[dbo].[alert_sql]') AND name='_WA_Sys_00000001_1165C6C2')
  DROP STATISTICS [dbo].[alert_sql]._WA_Sys_00000001_1165C6C2
 GO
IF EXISTS(SELECT 1 FROM sys.stats WHERE OBJECT_ID = OBJECT_ID('[dbo].[alert_sql]') AND name='_WA_Sys_00000009_1165C6C2')
  DROP STATISTICS [dbo].[alert_sql]._WA_Sys_00000009_1165C6C2
 GO
IF EXISTS(SELECT 1 FROM sys.stats WHERE OBJECT_ID = OBJECT_ID('[dbo].[fas_eff_ass_test_results_profile]') AND name='_WA_Sys_eff_test_result_id_1197D989')
  DROP STATISTICS [dbo].[fas_eff_ass_test_results_profile]._WA_Sys_eff_test_result_id_1197D989
 GO
IF EXISTS(SELECT 1 FROM sys.stats WHERE OBJECT_ID = OBJECT_ID('[dbo].[fas_eff_ass_test_results_profile]') AND name='_WA_Sys_eff_test_result_id_1197D989')
  DROP STATISTICS [dbo].[fas_eff_ass_test_results_profile]._WA_Sys_eff_test_result_id_1197D989
 GO
IF EXISTS(SELECT 1 FROM sys.stats WHERE OBJECT_ID = OBJECT_ID('[dbo].[alert_users]') AND name='_WA_Sys_00000001_1259EAFB')
  DROP STATISTICS [dbo].[alert_users]._WA_Sys_00000001_1259EAFB
 GO
IF EXISTS(SELECT 1 FROM sys.stats WHERE OBJECT_ID = OBJECT_ID('[dbo].[alert_users]') AND name='_WA_Sys_00000002_1259EAFB')
  DROP STATISTICS [dbo].[alert_users]._WA_Sys_00000002_1259EAFB
 GO
IF EXISTS(SELECT 1 FROM sys.stats WHERE OBJECT_ID = OBJECT_ID('[dbo].[report_paramset]') AND name='_WA_Sys_00000003_12CD5599')
  DROP STATISTICS [dbo].[report_paramset]._WA_Sys_00000003_12CD5599
 GO
IF EXISTS(SELECT 1 FROM sys.stats WHERE OBJECT_ID = OBJECT_ID('[dbo].[eod_process_status]') AND name='_WA_Sys_00000001_12F5DC1D')
  DROP STATISTICS [dbo].[eod_process_status]._WA_Sys_00000001_12F5DC1D
 GO
IF EXISTS(SELECT 1 FROM sys.stats WHERE OBJECT_ID = OBJECT_ID('[dbo].[alert_workflows]') AND name='_WA_Sys_00000001_134E0F34')
  DROP STATISTICS [dbo].[alert_workflows]._WA_Sys_00000001_134E0F34
 GO
IF EXISTS(SELECT 1 FROM sys.stats WHERE OBJECT_ID = OBJECT_ID('[dbo].[alert_workflows]') AND name='_WA_Sys_00000002_134E0F34')
  DROP STATISTICS [dbo].[alert_workflows]._WA_Sys_00000002_134E0F34
 GO
IF EXISTS(SELECT 1 FROM sys.stats WHERE OBJECT_ID = OBJECT_ID('[dbo].[counterparty_contract_address]') AND name='_WA_Sys_00000001_13AECD3E')
  DROP STATISTICS [dbo].[counterparty_contract_address]._WA_Sys_00000001_13AECD3E
 GO
IF EXISTS(SELECT 1 FROM sys.stats WHERE OBJECT_ID = OBJECT_ID('[dbo].[deal_default_value]') AND name='_WA_Sys_00000002_1518248D')
  DROP STATISTICS [dbo].[deal_default_value]._WA_Sys_00000002_1518248D
 GO
IF EXISTS(SELECT 1 FROM sys.stats WHERE OBJECT_ID = OBJECT_ID('[dbo].[deal_fields_mapping_curves]') AND name='_WA_Sys_00000002_15B01CFC')
  DROP STATISTICS [dbo].[deal_fields_mapping_curves]._WA_Sys_00000002_15B01CFC
 GO
IF EXISTS(SELECT 1 FROM sys.stats WHERE OBJECT_ID = OBJECT_ID('[dbo].[setup_menu]') AND name='_WA_Sys_00000001_17298D10')
  DROP STATISTICS [dbo].[setup_menu]._WA_Sys_00000001_17298D10
 GO
IF EXISTS(SELECT 1 FROM sys.stats WHERE OBJECT_ID = OBJECT_ID('[dbo].[mtm_cfar_simulation_whatif]') AND name='_WA_Sys_00000002_172A5867')
  DROP STATISTICS [dbo].[mtm_cfar_simulation_whatif]._WA_Sys_00000002_172A5867
 GO
IF EXISTS(SELECT 1 FROM sys.stats WHERE OBJECT_ID = OBJECT_ID('[dbo].[report_dataset_paramset]') AND name='_WA_Sys_00000001_17920AB6')
  DROP STATISTICS [dbo].[report_dataset_paramset]._WA_Sys_00000001_17920AB6
 GO
IF EXISTS(SELECT 1 FROM sys.stats WHERE OBJECT_ID = OBJECT_ID('[dbo].[mtm_ear_simulation_whatif]') AND name='_WA_Sys_00000002_181E7CA0')
  DROP STATISTICS [dbo].[mtm_ear_simulation_whatif]._WA_Sys_00000002_181E7CA0
 GO
IF EXISTS(SELECT 1 FROM sys.stats WHERE OBJECT_ID = OBJECT_ID('[dbo].[report_netted_gross_net]') AND name='_WA_Sys_netted_gross_net_id_19F8E0B7')
  DROP STATISTICS [dbo].[report_netted_gross_net]._WA_Sys_netted_gross_net_id_19F8E0B7
 GO
IF EXISTS(SELECT 1 FROM sys.stats WHERE OBJECT_ID = OBJECT_ID('[dbo].[mtm_var_simulation_whatif]') AND name='_WA_Sys_00000002_1A06C512')
  DROP STATISTICS [dbo].[mtm_var_simulation_whatif]._WA_Sys_00000002_1A06C512
 GO
IF EXISTS(SELECT 1 FROM sys.stats WHERE OBJECT_ID = OBJECT_ID('[dbo].[rec_assign_log]') AND name='_WA_Sys_rec_assign_log_id_1A0EBAA7')
  DROP STATISTICS [dbo].[rec_assign_log]._WA_Sys_rec_assign_log_id_1A0EBAA7
 GO
IF EXISTS(SELECT 1 FROM sys.stats WHERE OBJECT_ID = OBJECT_ID('[dbo].[mv90_data]') AND name='_WA_Sys_00000001_1A16444A')
  DROP STATISTICS [dbo].[mv90_data]._WA_Sys_00000001_1A16444A
 GO
IF EXISTS(SELECT 1 FROM sys.stats WHERE OBJECT_ID = OBJECT_ID('[dbo].[contract_group]') AND name='_WA_Sys_00000026_1A576E86')
  DROP STATISTICS [dbo].[contract_group]._WA_Sys_00000026_1A576E86
 GO
IF EXISTS(SELECT 1 FROM sys.stats WHERE OBJECT_ID = OBJECT_ID('[dbo].[risks_criteria_detail]') AND name='_WA_Sys_00000001_1B01DD90')
  DROP STATISTICS [dbo].[risks_criteria_detail]._WA_Sys_00000001_1B01DD90
 GO
IF EXISTS(SELECT 1 FROM sys.stats WHERE OBJECT_ID = OBJECT_ID('[dbo].[deal_fields_mapping_locations]') AND name='_WA_Sys_00000002_1B68F652')
  DROP STATISTICS [dbo].[deal_fields_mapping_locations]._WA_Sys_00000002_1B68F652
 GO
IF EXISTS(SELECT 1 FROM sys.stats WHERE OBJECT_ID = OBJECT_ID('[dbo].[mv90_data_hour]') AND name='_WA_Sys_00000001_1BFE8CBC')
  DROP STATISTICS [dbo].[mv90_data_hour]._WA_Sys_00000001_1BFE8CBC
 GO
IF EXISTS(SELECT 1 FROM sys.stats WHERE OBJECT_ID = OBJECT_ID('[dbo].[reclassify_aoci]') AND name='_WA_Sys_00000002_1C4AA3F0')
  DROP STATISTICS [dbo].[reclassify_aoci]._WA_Sys_00000002_1C4AA3F0
 GO
IF EXISTS(SELECT 1 FROM sys.stats WHERE OBJECT_ID = OBJECT_ID('[dbo].[nomination_group]') AND name='_WA_Sys_00000002_1C522D93')
  DROP STATISTICS [dbo].[nomination_group]._WA_Sys_00000002_1C522D93
 GO
IF EXISTS(SELECT 1 FROM sys.stats WHERE OBJECT_ID = OBJECT_ID('[dbo].[report_hourly_position_breakdown_main]') AND name='_WA_Sys_00000002_1D3EF5C4')
  DROP STATISTICS [dbo].[report_hourly_position_breakdown_main]._WA_Sys_00000002_1D3EF5C4
 GO
IF EXISTS(SELECT 1 FROM sys.stats WHERE OBJECT_ID = OBJECT_ID('[dbo].[mv90_DST]') AND name='_WA_Sys_year_1DE6719A')
  DROP STATISTICS [dbo].[mv90_DST]._WA_Sys_year_1DE6719A
 GO
IF EXISTS(SELECT 1 FROM sys.stats WHERE OBJECT_ID = OBJECT_ID('[dbo].[mv90_data_mins]') AND name='_WA_Sys_00000001_1DE6D52E')
  DROP STATISTICS [dbo].[mv90_data_mins]._WA_Sys_00000001_1DE6D52E
 GO
IF EXISTS(SELECT 1 FROM sys.stats WHERE OBJECT_ID = OBJECT_ID('[dbo].[rec_gen_eligibility]') AND name='_WA_Sys_00000005_1E1584A0')
  DROP STATISTICS [dbo].[rec_gen_eligibility]._WA_Sys_00000005_1E1584A0
 GO
IF EXISTS(SELECT 1 FROM sys.stats WHERE OBJECT_ID = OBJECT_ID('[dbo].[rec_gen_eligibility]') AND name='_WA_Sys_00000005_1E1584A0')
  DROP STATISTICS [dbo].[rec_gen_eligibility]._WA_Sys_00000005_1E1584A0
 GO
IF EXISTS(SELECT 1 FROM sys.stats WHERE OBJECT_ID = OBJECT_ID('[dbo].[gen_hedge_group_detail]') AND name='_WA_Sys_gen_hedge_group_id_20C377D2')
  DROP STATISTICS [dbo].[gen_hedge_group_detail]._WA_Sys_gen_hedge_group_id_20C377D2
 GO
IF EXISTS(SELECT 1 FROM sys.stats WHERE OBJECT_ID = OBJECT_ID('[dbo].[report_hourly_position_deal_main]') AND name='_WA_Sys_00000001_2203AAE1')
  DROP STATISTICS [dbo].[report_hourly_position_deal_main]._WA_Sys_00000001_2203AAE1
 GO
IF EXISTS(SELECT 1 FROM sys.stats WHERE OBJECT_ID = OBJECT_ID('[dbo].[report_hourly_position_deal_main]') AND name='_WA_Sys_00000020_2203AAE1')
  DROP STATISTICS [dbo].[report_hourly_position_deal_main]._WA_Sys_00000020_2203AAE1
 GO
IF EXISTS(SELECT 1 FROM sys.stats WHERE OBJECT_ID = OBJECT_ID('[dbo].[report_hourly_position_deal_main]') AND name='_WA_Sys_00000001_2203AAE1')
  DROP STATISTICS [dbo].[report_hourly_position_deal_main]._WA_Sys_00000001_2203AAE1
 GO
IF EXISTS(SELECT 1 FROM sys.stats WHERE OBJECT_ID = OBJECT_ID('[dbo].[deal_fields_mapping_contracts]') AND name='_WA_Sys_00000002_230A181A')
  DROP STATISTICS [dbo].[deal_fields_mapping_contracts]._WA_Sys_00000002_230A181A
 GO
IF EXISTS(SELECT 1 FROM sys.stats WHERE OBJECT_ID = OBJECT_ID('[dbo].[adjustment_default_gl_codes_detail]') AND name='_WA_Sys_00000001_23DF73DC')
  DROP STATISTICS [dbo].[adjustment_default_gl_codes_detail]._WA_Sys_00000001_23DF73DC
 GO
IF EXISTS(SELECT 1 FROM sys.stats WHERE OBJECT_ID = OBJECT_ID('[dbo].[source_uom]') AND name='_WA_Sys_source_system_id_24885067')
  DROP STATISTICS [dbo].[source_uom]._WA_Sys_source_system_id_24885067
 GO
IF EXISTS(SELECT 1 FROM sys.stats WHERE OBJECT_ID = OBJECT_ID('[dbo].[calc_formula_value]') AND name='_WA_Sys_00000001_2493D2BD')
  DROP STATISTICS [dbo].[calc_formula_value]._WA_Sys_00000001_2493D2BD
 GO
IF EXISTS(SELECT 1 FROM sys.stats WHERE OBJECT_ID = OBJECT_ID('[dbo].[optimizer_detail]') AND name='_WA_Sys_00000003_26A8CC30')
  DROP STATISTICS [dbo].[optimizer_detail]._WA_Sys_00000003_26A8CC30
 GO
IF EXISTS(SELECT 1 FROM sys.stats WHERE OBJECT_ID = OBJECT_ID('[dbo].[fas_eff_hedge_rel_type_detail]') AND name='_WA_Sys_eff_test_profile_id_272FB2E8')
  DROP STATISTICS [dbo].[fas_eff_hedge_rel_type_detail]._WA_Sys_eff_test_profile_id_272FB2E8
 GO
IF EXISTS(SELECT 1 FROM sys.stats WHERE OBJECT_ID = OBJECT_ID('[dbo].[credit_exposure_detail]') AND name='_WA_Sys_00000001_28BA02E9')
  DROP STATISTICS [dbo].[credit_exposure_detail]._WA_Sys_00000001_28BA02E9
 GO
IF EXISTS(SELECT 1 FROM sys.stats WHERE OBJECT_ID = OBJECT_ID('[dbo].[credit_exposure_detail]') AND name='_WA_Sys_00000001_28BA02E9')
  DROP STATISTICS [dbo].[credit_exposure_detail]._WA_Sys_00000001_28BA02E9
 GO
IF EXISTS(SELECT 1 FROM sys.stats WHERE OBJECT_ID = OBJECT_ID('[dbo].[deal_fields_mapping_formula_curves]') AND name='_WA_Sys_00000002_28C2F170')
  DROP STATISTICS [dbo].[deal_fields_mapping_formula_curves]._WA_Sys_00000002_28C2F170
 GO
IF EXISTS(SELECT 1 FROM sys.stats WHERE OBJECT_ID = OBJECT_ID('[dbo].[source_minor_location_nomination_group]') AND name='_WA_Sys_00000002_2A805159')
  DROP STATISTICS [dbo].[source_minor_location_nomination_group]._WA_Sys_00000002_2A805159
 GO
IF EXISTS(SELECT 1 FROM sys.stats WHERE OBJECT_ID = OBJECT_ID('[dbo].[default_holiday_calendar]') AND name='_WA_Sys_00000001_2DCDC69D')
  DROP STATISTICS [dbo].[default_holiday_calendar]._WA_Sys_00000001_2DCDC69D
 GO
IF EXISTS(SELECT 1 FROM sys.stats WHERE OBJECT_ID = OBJECT_ID('[dbo].[delivery_path]') AND name='_WA_Sys_00000001_2F11FABD')
  DROP STATISTICS [dbo].[delivery_path]._WA_Sys_00000001_2F11FABD
 GO
IF EXISTS(SELECT 1 FROM sys.stats WHERE OBJECT_ID = OBJECT_ID('[dbo].[calcprocess_deals]') AND name='_WA_Sys_00000004_333233C5')
  DROP STATISTICS [dbo].[calcprocess_deals]._WA_Sys_00000004_333233C5
 GO
IF EXISTS(SELECT 1 FROM sys.stats WHERE OBJECT_ID = OBJECT_ID('[dbo].[calcprocess_deals]') AND name='_WA_Sys_0000001C_333233C5')
  DROP STATISTICS [dbo].[calcprocess_deals]._WA_Sys_0000001C_333233C5
 GO
IF EXISTS(SELECT 1 FROM sys.stats WHERE OBJECT_ID = OBJECT_ID('[dbo].[calcprocess_deals]') AND name='_WA_Sys_0000001C_333233C5')
  DROP STATISTICS [dbo].[calcprocess_deals]._WA_Sys_0000001C_333233C5
 GO
IF EXISTS(SELECT 1 FROM sys.stats WHERE OBJECT_ID = OBJECT_ID('[dbo].[calcprocess_deals]') AND name='_WA_Sys_00000020_333233C5')
  DROP STATISTICS [dbo].[calcprocess_deals]._WA_Sys_00000020_333233C5
 GO
IF EXISTS(SELECT 1 FROM sys.stats WHERE OBJECT_ID = OBJECT_ID('[dbo].[report_measurement_values]') AND name='_WA_Sys_00000004_342657FE')
  DROP STATISTICS [dbo].[report_measurement_values]._WA_Sys_00000004_342657FE
 GO
IF EXISTS(SELECT 1 FROM sys.stats WHERE OBJECT_ID = OBJECT_ID('[dbo].[report_measurement_values]') AND name='_WA_Sys_00000003_342657FE')
  DROP STATISTICS [dbo].[report_measurement_values]._WA_Sys_00000003_342657FE
 GO
IF EXISTS(SELECT 1 FROM sys.stats WHERE OBJECT_ID = OBJECT_ID('[dbo].[report_measurement_values]') AND name='_WA_Sys_00000005_342657FE')
  DROP STATISTICS [dbo].[report_measurement_values]._WA_Sys_00000005_342657FE
 GO
IF EXISTS(SELECT 1 FROM sys.stats WHERE OBJECT_ID = OBJECT_ID('[dbo].[report_measurement_values]') AND name='_WA_Sys_00000005_342657FE')
  DROP STATISTICS [dbo].[report_measurement_values]._WA_Sys_00000005_342657FE
 GO
IF EXISTS(SELECT 1 FROM sys.stats WHERE OBJECT_ID = OBJECT_ID('[dbo].[report_measurement_values]') AND name='_WA_Sys_00000006_342657FE')
  DROP STATISTICS [dbo].[report_measurement_values]._WA_Sys_00000006_342657FE
 GO
IF EXISTS(SELECT 1 FROM sys.stats WHERE OBJECT_ID = OBJECT_ID('[dbo].[calcprocess_aoci_release]') AND name='_WA_Sys_00000005_351A7C37')
  DROP STATISTICS [dbo].[calcprocess_aoci_release]._WA_Sys_00000005_351A7C37
 GO
IF EXISTS(SELECT 1 FROM sys.stats WHERE OBJECT_ID = OBJECT_ID('[dbo].[calcprocess_aoci_release]') AND name='_WA_Sys_00000006_351A7C37')
  DROP STATISTICS [dbo].[calcprocess_aoci_release]._WA_Sys_00000006_351A7C37
 GO
IF EXISTS(SELECT 1 FROM sys.stats WHERE OBJECT_ID = OBJECT_ID('[dbo].[group_meter_mapping]') AND name='_WA_Sys_00000001_3575DCAA')
  DROP STATISTICS [dbo].[group_meter_mapping]._WA_Sys_00000001_3575DCAA
 GO
IF EXISTS(SELECT 1 FROM sys.stats WHERE OBJECT_ID = OBJECT_ID('[dbo].[calcprocess_deals_expired]') AND name='_WA_Sys_0000001C_36D47CFA')
  DROP STATISTICS [dbo].[calcprocess_deals_expired]._WA_Sys_0000001C_36D47CFA
 GO
IF EXISTS(SELECT 1 FROM sys.stats WHERE OBJECT_ID = OBJECT_ID('[dbo].[calcprocess_deals_expired]') AND name='_WA_Sys_0000001C_36D47CFA')
  DROP STATISTICS [dbo].[calcprocess_deals_expired]._WA_Sys_0000001C_36D47CFA
 GO
IF EXISTS(SELECT 1 FROM sys.stats WHERE OBJECT_ID = OBJECT_ID('[dbo].[calcprocess_deals_expired]') AND name='_WA_Sys_00000020_36D47CFA')
  DROP STATISTICS [dbo].[calcprocess_deals_expired]._WA_Sys_00000020_36D47CFA
 GO
IF EXISTS(SELECT 1 FROM sys.stats WHERE OBJECT_ID = OBJECT_ID('[dbo].[source_deal_pnl_arch1]') AND name='_WA_Sys_00000001_36FE9A2C')
  DROP STATISTICS [dbo].[source_deal_pnl_arch1]._WA_Sys_00000001_36FE9A2C
 GO
IF EXISTS(SELECT 1 FROM sys.stats WHERE OBJECT_ID = OBJECT_ID('[dbo].[source_deal_pnl_arch1]') AND name='_WA_Sys_0000000C_36FE9A2C')
  DROP STATISTICS [dbo].[source_deal_pnl_arch1]._WA_Sys_0000000C_36FE9A2C
 GO
IF EXISTS(SELECT 1 FROM sys.stats WHERE OBJECT_ID = OBJECT_ID('[dbo].[source_deal_pnl_arch1]') AND name='_WA_Sys_00000001_36FE9A2C')
  DROP STATISTICS [dbo].[source_deal_pnl_arch1]._WA_Sys_00000001_36FE9A2C
 GO
IF EXISTS(SELECT 1 FROM sys.stats WHERE OBJECT_ID = OBJECT_ID('[dbo].[source_deal_pnl_eff]') AND name='_WA_Sys_00000001_37F2BE65')
  DROP STATISTICS [dbo].[source_deal_pnl_eff]._WA_Sys_00000001_37F2BE65
 GO
IF EXISTS(SELECT 1 FROM sys.stats WHERE OBJECT_ID = OBJECT_ID('[dbo].[source_deal_pnl_eff]') AND name='_WA_Sys_00000001_37F2BE65')
  DROP STATISTICS [dbo].[source_deal_pnl_eff]._WA_Sys_00000001_37F2BE65
 GO
IF EXISTS(SELECT 1 FROM sys.stats WHERE OBJECT_ID = OBJECT_ID('[dbo].[calcprocess_deals_arch1]') AND name='_WA_Sys_00000005_38E6E29E')
  DROP STATISTICS [dbo].[calcprocess_deals_arch1]._WA_Sys_00000005_38E6E29E
 GO
IF EXISTS(SELECT 1 FROM sys.stats WHERE OBJECT_ID = OBJECT_ID('[dbo].[contract_component_mapping]') AND name='_WA_Sys_00000002_395225DD')
  DROP STATISTICS [dbo].[contract_component_mapping]._WA_Sys_00000002_395225DD
 GO
IF EXISTS(SELECT 1 FROM sys.stats WHERE OBJECT_ID = OBJECT_ID('[dbo].[internal_deal_type_subtype_types]') AND name='_WA_Sys_internal_deal_type_subtype_id_39B0B7DB')
  DROP STATISTICS [dbo].[internal_deal_type_subtype_types]._WA_Sys_internal_deal_type_subtype_id_39B0B7DB
 GO
IF EXISTS(SELECT 1 FROM sys.stats WHERE OBJECT_ID = OBJECT_ID('[dbo].[exclude_st_forecast_dates]') AND name='_WA_Sys_00000001_39C9892E')
  DROP STATISTICS [dbo].[exclude_st_forecast_dates]._WA_Sys_00000001_39C9892E
 GO
IF EXISTS(SELECT 1 FROM sys.stats WHERE OBJECT_ID = OBJECT_ID('[dbo].[calcprocess_deals_arch2]') AND name='_WA_Sys_00000005_39DB06D7')
  DROP STATISTICS [dbo].[calcprocess_deals_arch2]._WA_Sys_00000005_39DB06D7
 GO
IF EXISTS(SELECT 1 FROM sys.stats WHERE OBJECT_ID = OBJECT_ID('[dbo].[calcprocess_deals_arch2]') AND name='_WA_Sys_00000001_39DB06D7')
  DROP STATISTICS [dbo].[calcprocess_deals_arch2]._WA_Sys_00000001_39DB06D7
 GO
IF EXISTS(SELECT 1 FROM sys.stats WHERE OBJECT_ID = OBJECT_ID('[dbo].[calcprocess_deals_arch2]') AND name='_WA_Sys_00000009_39DB06D7')
  DROP STATISTICS [dbo].[calcprocess_deals_arch2]._WA_Sys_00000009_39DB06D7
 GO
IF EXISTS(SELECT 1 FROM sys.stats WHERE OBJECT_ID = OBJECT_ID('[dbo].[calcprocess_deals_arch2]') AND name='_WA_Sys_00000004_39DB06D7')
  DROP STATISTICS [dbo].[calcprocess_deals_arch2]._WA_Sys_00000004_39DB06D7
 GO
IF EXISTS(SELECT 1 FROM sys.stats WHERE OBJECT_ID = OBJECT_ID('[dbo].[source_deal_pfe_simulation]') AND name='_WA_Sys_00000001_39DE97C7')
  DROP STATISTICS [dbo].[source_deal_pfe_simulation]._WA_Sys_00000001_39DE97C7
 GO
IF EXISTS(SELECT 1 FROM sys.stats WHERE OBJECT_ID = OBJECT_ID('[dbo].[calcprocess_aoci_release_arch1]') AND name='_WA_Sys_00000001_3ACF2B10')
  DROP STATISTICS [dbo].[calcprocess_aoci_release_arch1]._WA_Sys_00000001_3ACF2B10
 GO
IF EXISTS(SELECT 1 FROM sys.stats WHERE OBJECT_ID = OBJECT_ID('[dbo].[fas_link_detail_dedesignation]') AND name='_WA_Sys_effective_date_3B0BC30C')
  DROP STATISTICS [dbo].[fas_link_detail_dedesignation]._WA_Sys_effective_date_3B0BC30C
 GO
IF EXISTS(SELECT 1 FROM sys.stats WHERE OBJECT_ID = OBJECT_ID('[dbo].[static_data_category]') AND name='_WA_Sys_category_id_3B81C179')
  DROP STATISTICS [dbo].[static_data_category]._WA_Sys_category_id_3B81C179
 GO
IF EXISTS(SELECT 1 FROM sys.stats WHERE OBJECT_ID = OBJECT_ID('[dbo].[calcprocess_aoci_release_arch2]') AND name='_WA_Sys_00000001_3BC34F49')
  DROP STATISTICS [dbo].[calcprocess_aoci_release_arch2]._WA_Sys_00000001_3BC34F49
 GO
IF EXISTS(SELECT 1 FROM sys.stats WHERE OBJECT_ID = OBJECT_ID('[dbo].[netting_group_detail_contract]') AND name='_WA_Sys_00000001_3DA0AAC3')
  DROP STATISTICS [dbo].[netting_group_detail_contract]._WA_Sys_00000001_3DA0AAC3
 GO
IF EXISTS(SELECT 1 FROM sys.stats WHERE OBJECT_ID = OBJECT_ID('[dbo].[source_deal_header]') AND name='_WA_Sys_source_deal_type_id_3DF28322')
  DROP STATISTICS [dbo].[source_deal_header]._WA_Sys_source_deal_type_id_3DF28322
 GO
IF EXISTS(SELECT 1 FROM sys.stats WHERE OBJECT_ID = OBJECT_ID('[dbo].[fas_dedesignated_link_detail]') AND name='_WA_Sys_hedge_or_item_3EDC53F0')
  DROP STATISTICS [dbo].[fas_dedesignated_link_detail]._WA_Sys_hedge_or_item_3EDC53F0
 GO
IF EXISTS(SELECT 1 FROM sys.stats WHERE OBJECT_ID = OBJECT_ID('[dbo].[mtm_var_simulation]') AND name='_WA_Sys_00000001_3FE0BE89')
  DROP STATISTICS [dbo].[mtm_var_simulation]._WA_Sys_00000001_3FE0BE89
 GO
IF EXISTS(SELECT 1 FROM sys.stats WHERE OBJECT_ID = OBJECT_ID('[dbo].[mtm_var_simulation]') AND name='_WA_Sys_00000002_3FE0BE89')
  DROP STATISTICS [dbo].[mtm_var_simulation]._WA_Sys_00000002_3FE0BE89
 GO
IF EXISTS(SELECT 1 FROM sys.stats WHERE OBJECT_ID = OBJECT_ID('[dbo].[counterparty_credit_migration]') AND name='_WA_Sys_00000004_421FD52E')
  DROP STATISTICS [dbo].[counterparty_credit_migration]._WA_Sys_00000004_421FD52E
 GO
IF EXISTS(SELECT 1 FROM sys.stats WHERE OBJECT_ID = OBJECT_ID('[dbo].[source_deal_header_template]') AND name='_WA_Sys_template_id_438F27D0')
  DROP STATISTICS [dbo].[source_deal_header_template]._WA_Sys_template_id_438F27D0
 GO
IF EXISTS(SELECT 1 FROM sys.stats WHERE OBJECT_ID = OBJECT_ID('[dbo].[first_day_gain_loss_decision]') AND name='_WA_Sys_00000001_43CE8565')
  DROP STATISTICS [dbo].[first_day_gain_loss_decision]._WA_Sys_00000001_43CE8565
 GO
IF EXISTS(SELECT 1 FROM sys.stats WHERE OBJECT_ID = OBJECT_ID('[dbo].[source_currency]') AND name='_WA_Sys_source_system_id_44801EAD')
  DROP STATISTICS [dbo].[source_currency]._WA_Sys_source_system_id_44801EAD
 GO
IF EXISTS(SELECT 1 FROM sys.stats WHERE OBJECT_ID = OBJECT_ID('[dbo].[event_trigger]') AND name='_WA_Sys_00000001_456EAF56')
  DROP STATISTICS [dbo].[event_trigger]._WA_Sys_00000001_456EAF56
 GO
IF EXISTS(SELECT 1 FROM sys.stats WHERE OBJECT_ID = OBJECT_ID('[dbo].[counterparty_credit_info]') AND name='_WA_Sys_00000002_469EA034')
  DROP STATISTICS [dbo].[counterparty_credit_info]._WA_Sys_00000002_469EA034
 GO
IF EXISTS(SELECT 1 FROM sys.stats WHERE OBJECT_ID = OBJECT_ID('[dbo].[gas_allocation_map_ebase]') AND name='_WA_Sys_00000001_483E985B')
  DROP STATISTICS [dbo].[gas_allocation_map_ebase]._WA_Sys_00000001_483E985B
 GO
IF EXISTS(SELECT 1 FROM sys.stats WHERE OBJECT_ID = OBJECT_ID('[dbo].[module_events]') AND name='_WA_Sys_00000001_493F403A')
  DROP STATISTICS [dbo].[module_events]._WA_Sys_00000001_493F403A
 GO
IF EXISTS(SELECT 1 FROM sys.stats WHERE OBJECT_ID = OBJECT_ID('[dbo].[application_security_role]') AND name='_WA_Sys_role_name_4AF9DA8A')
  DROP STATISTICS [dbo].[application_security_role]._WA_Sys_role_name_4AF9DA8A
 GO
IF EXISTS(SELECT 1 FROM sys.stats WHERE OBJECT_ID = OBJECT_ID('[dbo].[gis_reconcillation_log]') AND name='_WA_Sys_gis_reconcillation_log_id_4CD00FF5')
  DROP STATISTICS [dbo].[gis_reconcillation_log]._WA_Sys_gis_reconcillation_log_id_4CD00FF5
 GO
IF EXISTS(SELECT 1 FROM sys.stats WHERE OBJECT_ID = OBJECT_ID('[dbo].[source_deal_groups]') AND name='_WA_Sys_00000001_4EAA39E4')
  DROP STATISTICS [dbo].[source_deal_groups]._WA_Sys_00000001_4EAA39E4
 GO
IF EXISTS(SELECT 1 FROM sys.stats WHERE OBJECT_ID = OBJECT_ID('[dbo].[Trayport_Staging_Error]') AND name='_WA_Sys_00000001_4F09FACD')
  DROP STATISTICS [dbo].[Trayport_Staging_Error]._WA_Sys_00000001_4F09FACD
 GO
IF EXISTS(SELECT 1 FROM sys.stats WHERE OBJECT_ID = OBJECT_ID('[dbo].[deal_schedule]') AND name='_WA_Sys_00000001_5006106C')
  DROP STATISTICS [dbo].[deal_schedule]._WA_Sys_00000001_5006106C
 GO
IF EXISTS(SELECT 1 FROM sys.stats WHERE OBJECT_ID = OBJECT_ID('[dbo].[source_deal_detail]') AND name='_WA_Sys_0000003F_5013C72C')
  DROP STATISTICS [dbo].[source_deal_detail]._WA_Sys_0000003F_5013C72C
 GO
IF EXISTS(SELECT 1 FROM sys.stats WHERE OBJECT_ID = OBJECT_ID('[dbo].[admin_email_configuration]') AND name='_WA_Sys_00000008_50345C4A')
  DROP STATISTICS [dbo].[admin_email_configuration]._WA_Sys_00000008_50345C4A
 GO
IF EXISTS(SELECT 1 FROM sys.stats WHERE OBJECT_ID = OBJECT_ID('[dbo].[counterparty_credit_limits]') AND name='_WA_Sys_00000001_521AD815')
  DROP STATISTICS [dbo].[counterparty_credit_limits]._WA_Sys_00000001_521AD815
 GO
IF EXISTS(SELECT 1 FROM sys.stats WHERE OBJECT_ID = OBJECT_ID('[dbo].[invoice_cash_received]') AND name='_WA_Sys_00000001_53446E3B')
  DROP STATISTICS [dbo].[invoice_cash_received]._WA_Sys_00000001_53446E3B
 GO
IF EXISTS(SELECT 1 FROM sys.stats WHERE OBJECT_ID = OBJECT_ID('[dbo].[counterparty_contacts]') AND name='_WA_Sys_00000001_557FBDF7')
  DROP STATISTICS [dbo].[counterparty_contacts]._WA_Sys_00000001_557FBDF7
 GO
IF EXISTS(SELECT 1 FROM sys.stats WHERE OBJECT_ID = OBJECT_ID('[dbo].[time_series_definition]') AND name='_WA_Sys_00000001_5674AD87')
  DROP STATISTICS [dbo].[time_series_definition]._WA_Sys_00000001_5674AD87
 GO
IF EXISTS(SELECT 1 FROM sys.stats WHERE OBJECT_ID = OBJECT_ID('[dbo].[contract_charge_type]') AND name='_WA_Sys_00000002_570A1227')
  DROP STATISTICS [dbo].[contract_charge_type]._WA_Sys_00000002_570A1227
 GO
IF EXISTS(SELECT 1 FROM sys.stats WHERE OBJECT_ID = OBJECT_ID('[dbo].[source_brokers]') AND name='_WA_Sys_broker_id_5721EA88')
  DROP STATISTICS [dbo].[source_brokers]._WA_Sys_broker_id_5721EA88
 GO
IF EXISTS(SELECT 1 FROM sys.stats WHERE OBJECT_ID = OBJECT_ID('[dbo].[delete_source_deal_header]') AND name='_WA_Sys_00000011_57696B4D')
  DROP STATISTICS [dbo].[delete_source_deal_header]._WA_Sys_00000011_57696B4D
 GO
IF EXISTS(SELECT 1 FROM sys.stats WHERE OBJECT_ID = OBJECT_ID('[dbo].[deal_status_group]') AND name='_WA_Sys_00000001_57951F2D')
  DROP STATISTICS [dbo].[deal_status_group]._WA_Sys_00000001_57951F2D
 GO
IF EXISTS(SELECT 1 FROM sys.stats WHERE OBJECT_ID = OBJECT_ID('[dbo].[broker_fees]') AND name='_WA_Sys_00000009_57B8E1A7')
  DROP STATISTICS [dbo].[broker_fees]._WA_Sys_00000009_57B8E1A7
 GO
IF EXISTS(SELECT 1 FROM sys.stats WHERE OBJECT_ID = OBJECT_ID('[dbo].[deal_position_break_down]') AND name='_WA_Sys_00000003_5807BE74')
  DROP STATISTICS [dbo].[deal_position_break_down]._WA_Sys_00000003_5807BE74
 GO
IF EXISTS(SELECT 1 FROM sys.stats WHERE OBJECT_ID = OBJECT_ID('[dbo].[deal_transfer_mapping]') AND name='_WA_Sys_00000011_5889DCF3')
  DROP STATISTICS [dbo].[deal_transfer_mapping]._WA_Sys_00000011_5889DCF3
 GO
IF EXISTS(SELECT 1 FROM sys.stats WHERE OBJECT_ID = OBJECT_ID('[dbo].[contract_charge_type_detail]') AND name='_WA_Sys_00000002_58F25A99')
  DROP STATISTICS [dbo].[contract_charge_type_detail]._WA_Sys_00000002_58F25A99
 GO
IF EXISTS(SELECT 1 FROM sys.stats WHERE OBJECT_ID = OBJECT_ID('[dbo].[time_series_data]') AND name='_WA_Sys_00000001_59511A32')
  DROP STATISTICS [dbo].[time_series_data]._WA_Sys_00000001_59511A32
 GO
IF EXISTS(SELECT 1 FROM sys.stats WHERE OBJECT_ID = OBJECT_ID('[dbo].[state_properties]') AND name='_WA_Sys_code_value_5AB41AF8')
  DROP STATISTICS [dbo].[state_properties]._WA_Sys_code_value_5AB41AF8
 GO
IF EXISTS(SELECT 1 FROM sys.stats WHERE OBJECT_ID = OBJECT_ID('[dbo].[application_users]') AND name='_WA_Sys_00000021_5AFB3829')
  DROP STATISTICS [dbo].[application_users]._WA_Sys_00000021_5AFB3829
 GO
IF EXISTS(SELECT 1 FROM sys.stats WHERE OBJECT_ID = OBJECT_ID('[dbo].[Contract_report_template]') AND name='_WA_Sys_00000002_5CC2EB7D')
  DROP STATISTICS [dbo].[Contract_report_template]._WA_Sys_00000002_5CC2EB7D
 GO
IF EXISTS(SELECT 1 FROM sys.stats WHERE OBJECT_ID = OBJECT_ID('[dbo].[fas_eff_hedge_rel_type]') AND name='_WA_Sys_00000003_5E628010')
  DROP STATISTICS [dbo].[fas_eff_hedge_rel_type]._WA_Sys_00000003_5E628010
 GO
IF EXISTS(SELECT 1 FROM sys.stats WHERE OBJECT_ID = OBJECT_ID('[dbo].[hour_block_term]') AND name='_WA_Sys_00000001_5F54A5D8')
  DROP STATISTICS [dbo].[hour_block_term]._WA_Sys_00000001_5F54A5D8
 GO
IF EXISTS(SELECT 1 FROM sys.stats WHERE OBJECT_ID = OBJECT_ID('[dbo].[source_deal_cash_settlement]') AND name='_WA_Sys_00000002_6020AB50')
  DROP STATISTICS [dbo].[source_deal_cash_settlement]._WA_Sys_00000002_6020AB50
 GO
IF EXISTS(SELECT 1 FROM sys.stats WHERE OBJECT_ID = OBJECT_ID('[dbo].[process_map_table]') AND name='_WA_Sys_00000001_617428AF')
  DROP STATISTICS [dbo].[process_map_table]._WA_Sys_00000001_617428AF
 GO
IF EXISTS(SELECT 1 FROM sys.stats WHERE OBJECT_ID = OBJECT_ID('[dbo].[deal_reference_id_prefix]') AND name='_WA_Sys_00000001_6180DE1F')
  DROP STATISTICS [dbo].[deal_reference_id_prefix]._WA_Sys_00000001_6180DE1F
 GO
IF EXISTS(SELECT 1 FROM sys.stats WHERE OBJECT_ID = OBJECT_ID('[dbo].[deal_confirmation_rule]') AND name='_WA_Sys_00000002_621A6D3C')
  DROP STATISTICS [dbo].[deal_confirmation_rule]._WA_Sys_00000002_621A6D3C
 GO
IF EXISTS(SELECT 1 FROM sys.stats WHERE OBJECT_ID = OBJECT_ID('[dbo].[report]') AND name='_WA_Sys_00000002_631E4277')
  DROP STATISTICS [dbo].[report]._WA_Sys_00000002_631E4277
 GO
IF EXISTS(SELECT 1 FROM sys.stats WHERE OBJECT_ID = OBJECT_ID('[dbo].[source_internal_desk]') AND name='_WA_Sys_00000001_63C68575')
  DROP STATISTICS [dbo].[source_internal_desk]._WA_Sys_00000001_63C68575
 GO
IF EXISTS(SELECT 1 FROM sys.stats WHERE OBJECT_ID = OBJECT_ID('[dbo].[credit_exposure_calculation_log]') AND name='_WA_Sys_00000001_6488FEAA')
  DROP STATISTICS [dbo].[credit_exposure_calculation_log]._WA_Sys_00000001_6488FEAA
 GO
IF EXISTS(SELECT 1 FROM sys.stats WHERE OBJECT_ID = OBJECT_ID('[dbo].[source_product]') AND name='_WA_Sys_00000001_64BAA9AE')
  DROP STATISTICS [dbo].[source_product]._WA_Sys_00000001_64BAA9AE
 GO
IF EXISTS(SELECT 1 FROM sys.stats WHERE OBJECT_ID = OBJECT_ID('[dbo].[source_product]') AND name='_WA_Sys_00000003_64BAA9AE')
  DROP STATISTICS [dbo].[source_product]._WA_Sys_00000003_64BAA9AE
 GO
IF EXISTS(SELECT 1 FROM sys.stats WHERE OBJECT_ID = OBJECT_ID('[dbo].[source_product]') AND name='_WA_Sys_00000004_64BAA9AE')
  DROP STATISTICS [dbo].[source_product]._WA_Sys_00000004_64BAA9AE
 GO
IF EXISTS(SELECT 1 FROM sys.stats WHERE OBJECT_ID = OBJECT_ID('[dbo].[cached_curves]') AND name='_WA_Sys_00000001_652F116D')
  DROP STATISTICS [dbo].[cached_curves]._WA_Sys_00000001_652F116D
 GO
IF EXISTS(SELECT 1 FROM sys.stats WHERE OBJECT_ID = OBJECT_ID('[dbo].[source_internal_portfolio]') AND name='_WA_Sys_00000001_65AECDE7')
  DROP STATISTICS [dbo].[source_internal_portfolio]._WA_Sys_00000001_65AECDE7
 GO
IF EXISTS(SELECT 1 FROM sys.stats WHERE OBJECT_ID = OBJECT_ID('[dbo].[ems_source_input_limit]') AND name='_WA_Sys_00000001_67D34692')
  DROP STATISTICS [dbo].[ems_source_input_limit]._WA_Sys_00000001_67D34692
 GO
IF EXISTS(SELECT 1 FROM sys.stats WHERE OBJECT_ID = OBJECT_ID('[dbo].[forecast_model]') AND name='_WA_Sys_00000002_67FB6553')
  DROP STATISTICS [dbo].[forecast_model]._WA_Sys_00000002_67FB6553
 GO
IF EXISTS(SELECT 1 FROM sys.stats WHERE OBJECT_ID = OBJECT_ID('[dbo].[general_assest_info_virtual_storage]') AND name='_WA_Sys_00000002_68A07AF5')
  DROP STATISTICS [dbo].[general_assest_info_virtual_storage]._WA_Sys_00000002_68A07AF5
 GO
IF EXISTS(SELECT 1 FROM sys.stats WHERE OBJECT_ID = OBJECT_ID('[dbo].[expected_return]') AND name='_WA_Sys_00000001_68D55355')
  DROP STATISTICS [dbo].[expected_return]._WA_Sys_00000001_68D55355
 GO
IF EXISTS(SELECT 1 FROM sys.stats WHERE OBJECT_ID = OBJECT_ID('[dbo].[targeted_syv_mapping]') AND name='_WA_Sys_00000001_692A8ADA')
  DROP STATISTICS [dbo].[targeted_syv_mapping]._WA_Sys_00000001_692A8ADA
 GO
IF EXISTS(SELECT 1 FROM sys.stats WHERE OBJECT_ID = OBJECT_ID('[dbo].[embedded_deal]') AND name='_WA_Sys_00000001_699F2892')
  DROP STATISTICS [dbo].[embedded_deal]._WA_Sys_00000001_699F2892
 GO
IF EXISTS(SELECT 1 FROM sys.stats WHERE OBJECT_ID = OBJECT_ID('[dbo].[counterpartyt_netting_stmt_status]') AND name='_WA_Sys_00000001_6AACB7AB')
  DROP STATISTICS [dbo].[counterpartyt_netting_stmt_status]._WA_Sys_00000001_6AACB7AB
 GO
IF EXISTS(SELECT 1 FROM sys.stats WHERE OBJECT_ID = OBJECT_ID('[dbo].[user_defined_fields_template]') AND name='_WA_Sys_00000002_6B7F49A5')
  DROP STATISTICS [dbo].[user_defined_fields_template]._WA_Sys_00000002_6B7F49A5
 GO
IF EXISTS(SELECT 1 FROM sys.stats WHERE OBJECT_ID = OBJECT_ID('[dbo].[user_defined_fields_template]') AND name='_WA_Sys_0000000F_6B7F49A5')
  DROP STATISTICS [dbo].[user_defined_fields_template]._WA_Sys_0000000F_6B7F49A5
 GO
IF EXISTS(SELECT 1 FROM sys.stats WHERE OBJECT_ID = OBJECT_ID('[dbo].[inventory_reclassify_aoci]') AND name='_WA_Sys_00000002_6B9D4AF4')
  DROP STATISTICS [dbo].[inventory_reclassify_aoci]._WA_Sys_00000002_6B9D4AF4
 GO
IF EXISTS(SELECT 1 FROM sys.stats WHERE OBJECT_ID = OBJECT_ID('[dbo].[ipx_privileges]') AND name='_WA_Sys_00000001_6BAE2AE1')
  DROP STATISTICS [dbo].[ipx_privileges]._WA_Sys_00000001_6BAE2AE1
 GO
IF EXISTS(SELECT 1 FROM sys.stats WHERE OBJECT_ID = OBJECT_ID('[dbo].[source_commodity]') AND name='_WA_Sys_system_source_id_6BE40491')
  DROP STATISTICS [dbo].[source_commodity]._WA_Sys_system_source_id_6BE40491
 GO
IF EXISTS(SELECT 1 FROM sys.stats WHERE OBJECT_ID = OBJECT_ID('[dbo].[RDB_Mapping_Data]') AND name='_WA_Sys_00000001_6C3C01AF')
  DROP STATISTICS [dbo].[RDB_Mapping_Data]._WA_Sys_00000001_6C3C01AF
 GO
IF EXISTS(SELECT 1 FROM sys.stats WHERE OBJECT_ID = OBJECT_ID('[dbo].[inventory_accounting_log]') AND name='_WA_Sys_mtm_test_run_log_id_6C72D880')
  DROP STATISTICS [dbo].[inventory_accounting_log]._WA_Sys_mtm_test_run_log_id_6C72D880
 GO
IF EXISTS(SELECT 1 FROM sys.stats WHERE OBJECT_ID = OBJECT_ID('[dbo].[interrupt_data]') AND name='_WA_Sys_00000001_6CE444AD')
  DROP STATISTICS [dbo].[interrupt_data]._WA_Sys_00000001_6CE444AD
 GO
IF EXISTS(SELECT 1 FROM sys.stats WHERE OBJECT_ID = OBJECT_ID('[dbo].[location_price_index]') AND name='_WA_Sys_00000002_6D64FE48')
  DROP STATISTICS [dbo].[location_price_index]._WA_Sys_00000002_6D64FE48
 GO
IF EXISTS(SELECT 1 FROM sys.stats WHERE OBJECT_ID = OBJECT_ID('[dbo].[adiha_default_codes_values]') AND name='_WA_Sys_default_code_id_6E42E4FD')
  DROP STATISTICS [dbo].[adiha_default_codes_values]._WA_Sys_default_code_id_6E42E4FD
 GO
IF EXISTS(SELECT 1 FROM sys.stats WHERE OBJECT_ID = OBJECT_ID('[dbo].[adiha_default_codes_values]') AND name='_WA_Sys_var_value_6E42E4FD')
  DROP STATISTICS [dbo].[adiha_default_codes_values]._WA_Sys_var_value_6E42E4FD
 GO
IF EXISTS(SELECT 1 FROM sys.stats WHERE OBJECT_ID = OBJECT_ID('[dbo].[source_minor_location]') AND name='_WA_Sys_00000013_6ED77A17')
  DROP STATISTICS [dbo].[source_minor_location]._WA_Sys_00000013_6ED77A17
 GO
IF EXISTS(SELECT 1 FROM sys.stats WHERE OBJECT_ID = OBJECT_ID('[dbo].[process_risk_controls]') AND name='_WA_Sys_00000002_6FC24806')
  DROP STATISTICS [dbo].[process_risk_controls]._WA_Sys_00000002_6FC24806
 GO
IF EXISTS(SELECT 1 FROM sys.stats WHERE OBJECT_ID = OBJECT_ID('[dbo].[contract_group_detail]') AND name='_WA_Sys_00000003_6FC773D3')
  DROP STATISTICS [dbo].[contract_group_detail]._WA_Sys_00000003_6FC773D3
 GO
IF EXISTS(SELECT 1 FROM sys.stats WHERE OBJECT_ID = OBJECT_ID('[dbo].[user_defined_deal_fields_template_main]') AND name='_WA_Sys_00000002_706ABCCE')
  DROP STATISTICS [dbo].[user_defined_deal_fields_template_main]._WA_Sys_00000002_706ABCCE
 GO
IF EXISTS(SELECT 1 FROM sys.stats WHERE OBJECT_ID = OBJECT_ID('[dbo].[user_defined_deal_fields_template_main]') AND name='_WA_Sys_00000002_706ABCCE')
  DROP STATISTICS [dbo].[user_defined_deal_fields_template_main]._WA_Sys_00000002_706ABCCE
 GO
IF EXISTS(SELECT 1 FROM sys.stats WHERE OBJECT_ID = OBJECT_ID('[dbo].[fas_eff_hedge_rel_type_whatif_detail]') AND name='_WA_Sys_eff_test_profile_id_708B2022')
  DROP STATISTICS [dbo].[fas_eff_hedge_rel_type_whatif_detail]._WA_Sys_eff_test_profile_id_708B2022
 GO
IF EXISTS(SELECT 1 FROM sys.stats WHERE OBJECT_ID = OBJECT_ID('[dbo].[fas_eff_hedge_rel_type_whatif_detail]') AND name='_WA_Sys_eff_test_profile_id_708B2022')
  DROP STATISTICS [dbo].[fas_eff_hedge_rel_type_whatif_detail]._WA_Sys_eff_test_profile_id_708B2022
 GO
IF EXISTS(SELECT 1 FROM sys.stats WHERE OBJECT_ID = OBJECT_ID('[dbo].[pivot_report_view]') AND name='_WA_Sys_00000001_70A1C13A')
  DROP STATISTICS [dbo].[pivot_report_view]._WA_Sys_00000001_70A1C13A
 GO
IF EXISTS(SELECT 1 FROM sys.stats WHERE OBJECT_ID = OBJECT_ID('[dbo].[my_report]') AND name='_WA_Sys_00000001_7122490B')
  DROP STATISTICS [dbo].[my_report]._WA_Sys_00000001_7122490B
 GO
IF EXISTS(SELECT 1 FROM sys.stats WHERE OBJECT_ID = OBJECT_ID('[dbo].[source_deal_detail_template]') AND name='_WA_Sys_0000000B_7154BF66')
  DROP STATISTICS [dbo].[source_deal_detail_template]._WA_Sys_0000000B_7154BF66
 GO
IF EXISTS(SELECT 1 FROM sys.stats WHERE OBJECT_ID = OBJECT_ID('[dbo].[index_fees_breakdown]') AND name='_WA_Sys_00000003_715FDE28')
  DROP STATISTICS [dbo].[index_fees_breakdown]._WA_Sys_00000003_715FDE28
 GO
IF EXISTS(SELECT 1 FROM sys.stats WHERE OBJECT_ID = OBJECT_ID('[dbo].[generic_mapping_values]') AND name='_WA_Sys_00000001_75FCD818')
  DROP STATISTICS [dbo].[generic_mapping_values]._WA_Sys_00000001_75FCD818
 GO
IF EXISTS(SELECT 1 FROM sys.stats WHERE OBJECT_ID = OBJECT_ID('[dbo].[forecast_profile]') AND name='_WA_Sys_00000001_771720D0')
  DROP STATISTICS [dbo].[forecast_profile]._WA_Sys_00000001_771720D0
 GO
IF EXISTS(SELECT 1 FROM sys.stats WHERE OBJECT_ID = OBJECT_ID('[dbo].[forecast_profile]') AND name='_WA_Sys_00000002_771720D0')
  DROP STATISTICS [dbo].[forecast_profile]._WA_Sys_00000002_771720D0
 GO
IF EXISTS(SELECT 1 FROM sys.stats WHERE OBJECT_ID = OBJECT_ID('[dbo].[forecast_profile]') AND name='_WA_Sys_00000009_771720D0')
  DROP STATISTICS [dbo].[forecast_profile]._WA_Sys_00000009_771720D0
 GO
IF EXISTS(SELECT 1 FROM sys.stats WHERE OBJECT_ID = OBJECT_ID('[dbo].[user_defined_deal_fields]') AND name='_WA_Sys_00000002_7717BA5D')
  DROP STATISTICS [dbo].[user_defined_deal_fields]._WA_Sys_00000002_7717BA5D
 GO
IF EXISTS(SELECT 1 FROM sys.stats WHERE OBJECT_ID = OBJECT_ID('[dbo].[report_measurement_values_expired]') AND name='_WA_Sys_00000001_77E32648')
  DROP STATISTICS [dbo].[report_measurement_values_expired]._WA_Sys_00000001_77E32648
 GO
IF EXISTS(SELECT 1 FROM sys.stats WHERE OBJECT_ID = OBJECT_ID('[dbo].[report_measurement_values_expired]') AND name='_WA_Sys_00000045_77E32648')
  DROP STATISTICS [dbo].[report_measurement_values_expired]._WA_Sys_00000045_77E32648
 GO
IF EXISTS(SELECT 1 FROM sys.stats WHERE OBJECT_ID = OBJECT_ID('[dbo].[report_measurement_values_expired]') AND name='_WA_Sys_00000007_77E32648')
  DROP STATISTICS [dbo].[report_measurement_values_expired]._WA_Sys_00000007_77E32648
 GO
IF EXISTS(SELECT 1 FROM sys.stats WHERE OBJECT_ID = OBJECT_ID('[dbo].[report_measurement_values_expired]') AND name='_WA_Sys_00000004_77E32648')
  DROP STATISTICS [dbo].[report_measurement_values_expired]._WA_Sys_00000004_77E32648
 GO
IF EXISTS(SELECT 1 FROM sys.stats WHERE OBJECT_ID = OBJECT_ID('[dbo].[report_measurement_values_expired]') AND name='_WA_Sys_00000005_77E32648')
  DROP STATISTICS [dbo].[report_measurement_values_expired]._WA_Sys_00000005_77E32648
 GO
IF EXISTS(SELECT 1 FROM sys.stats WHERE OBJECT_ID = OBJECT_ID('[dbo].[report_measurement_values_expired]') AND name='_WA_Sys_00000005_77E32648')
  DROP STATISTICS [dbo].[report_measurement_values_expired]._WA_Sys_00000005_77E32648
 GO
IF EXISTS(SELECT 1 FROM sys.stats WHERE OBJECT_ID = OBJECT_ID('[dbo].[report_measurement_values_expired]') AND name='_WA_Sys_00000006_77E32648')
  DROP STATISTICS [dbo].[report_measurement_values_expired]._WA_Sys_00000006_77E32648
 GO
IF EXISTS(SELECT 1 FROM sys.stats WHERE OBJECT_ID = OBJECT_ID('[dbo].[source_deal_header_audit]') AND name='_WA_Sys_00000002_78F74612')
  DROP STATISTICS [dbo].[source_deal_header_audit]._WA_Sys_00000002_78F74612
 GO
IF EXISTS(SELECT 1 FROM sys.stats WHERE OBJECT_ID = OBJECT_ID('[dbo].[stage_source_deal_pnl]') AND name='_WA_Sys_0000000C_7A6003D4')
  DROP STATISTICS [dbo].[stage_source_deal_pnl]._WA_Sys_0000000C_7A6003D4
 GO
IF EXISTS(SELECT 1 FROM sys.stats WHERE OBJECT_ID = OBJECT_ID('[dbo].[volume_unit_conversion]') AND name='_WA_Sys_from_source_uom_id_7BB38562')
  DROP STATISTICS [dbo].[volume_unit_conversion]._WA_Sys_from_source_uom_id_7BB38562
 GO
IF EXISTS(SELECT 1 FROM sys.stats WHERE OBJECT_ID = OBJECT_ID('[dbo].[date_details]') AND name='_WA_Sys_00000001_7C9CEA3E')
  DROP STATISTICS [dbo].[date_details]._WA_Sys_00000001_7C9CEA3E
 GO
IF EXISTS(SELECT 1 FROM sys.stats WHERE OBJECT_ID = OBJECT_ID('[dbo].[optimizer_detail_downstream_hour]') AND name='_WA_Sys_00000003_7EE78768')
  DROP STATISTICS [dbo].[optimizer_detail_downstream_hour]._WA_Sys_00000003_7EE78768
 GO
IF EXISTS(SELECT 1 FROM sys.stats WHERE OBJECT_ID = OBJECT_ID('[dbo].[maintain_field_template_detail]') AND name='_WA_Sys_00000002_7EEFAEC7')
  DROP STATISTICS [dbo].[maintain_field_template_detail]._WA_Sys_00000002_7EEFAEC7
 GO
IF EXISTS(SELECT 1 FROM sys.stats WHERE OBJECT_ID = OBJECT_ID('[dbo].[maintain_field_template_detail]') AND name='_WA_Sys_00000002_7EEFAEC7')
  DROP STATISTICS [dbo].[maintain_field_template_detail]._WA_Sys_00000002_7EEFAEC7
 GO
IF EXISTS(SELECT 1 FROM sys.stats WHERE OBJECT_ID = OBJECT_ID('[dbo].[region]') AND name='_WA_Sys_00000002_7EF3A77A')
  DROP STATISTICS [dbo].[region]._WA_Sys_00000002_7EF3A77A
 GO
IF EXISTS(SELECT 1 FROM sys.stats WHERE OBJECT_ID = OBJECT_ID('[dbo].[calcprocess_credit_netting_one_usr5874_B152105A_463C_40CE_AE58_E2240392E515]') AND name='_WA_Sys_00000009_183A0419')
  DROP STATISTICS [dbo].[calcprocess_credit_netting_one_usr5874_B152105A_463C_40CE_AE58_E2240392E515]._WA_Sys_00000009_183A0419
 GO
IF EXISTS(SELECT 1 FROM sys.stats WHERE OBJECT_ID = OBJECT_ID('[dbo].[calcprocess_credit_netting_one_UAC0288_F4F19FC2_8786_42B4_A4F1_8921C0D57F3E]') AND name='_WA_Sys_00000009_1B77FA25')
  DROP STATISTICS [dbo].[calcprocess_credit_netting_one_UAC0288_F4F19FC2_8786_42B4_A4F1_8921C0D57F3E]._WA_Sys_00000009_1B77FA25
 GO
IF EXISTS(SELECT 1 FROM sys.stats WHERE OBJECT_ID = OBJECT_ID('[dbo].[calcprocess_credit_netting_one_he3008_74962665_7273_419E_8212_8E3A754B2939]') AND name='_WA_Sys_00000009_40F29A76')
  DROP STATISTICS [dbo].[calcprocess_credit_netting_one_he3008_74962665_7273_419E_8212_8E3A754B2939]._WA_Sys_00000009_40F29A76
 GO
IF EXISTS(SELECT 1 FROM sys.stats WHERE OBJECT_ID = OBJECT_ID('[dbo].[calcprocess_credit_netting_one_UAC0288_7B3FA234_F97C_439D_83D9_AF62F61A7FF8]') AND name='_WA_Sys_00000009_4EC58F93')
  DROP STATISTICS [dbo].[calcprocess_credit_netting_one_UAC0288_7B3FA234_F97C_439D_83D9_AF62F61A7FF8]._WA_Sys_00000009_4EC58F93
 GO
IF EXISTS(SELECT 1 FROM sys.stats WHERE OBJECT_ID = OBJECT_ID('[dbo].[calcprocess_credit_netting_one_UAC0288_111BBF57_73DA_4696_9B52_AAFFCE6C183B]') AND name='_WA_Sys_00000009_5D56D368')
  DROP STATISTICS [dbo].[calcprocess_credit_netting_one_UAC0288_111BBF57_73DA_4696_9B52_AAFFCE6C183B]._WA_Sys_00000009_5D56D368
 GO
IF EXISTS(SELECT 1 FROM sys.stats WHERE OBJECT_ID = OBJECT_ID('[dbo].[calcprocess_credit_netting_one_he3008_9669D5FF_0F90_4D99_A745_510075D587EF]') AND name='_WA_Sys_00000009_5F42176C')
  DROP STATISTICS [dbo].[calcprocess_credit_netting_one_he3008_9669D5FF_0F90_4D99_A745_510075D587EF]._WA_Sys_00000009_5F42176C
 GO
IF EXISTS(SELECT 1 FROM sys.stats WHERE OBJECT_ID = OBJECT_ID('[dbo].[calcprocess_credit_netting_one_he3008_64D5674D_441C_4D7D_8E3D_9E43F0340C53]') AND name='_WA_Sys_00000009_62355B28')
  DROP STATISTICS [dbo].[calcprocess_credit_netting_one_he3008_64D5674D_441C_4D7D_8E3D_9E43F0340C53]._WA_Sys_00000009_62355B28
 GO
IF EXISTS(SELECT 1 FROM sys.stats WHERE OBJECT_ID = OBJECT_ID('[dbo].[calcprocess_credit_netting_one_he3008_0AD79797_9823_4968_A659_46364794EF22]') AND name='_WA_Sys_00000009_6347B27A')
  DROP STATISTICS [dbo].[calcprocess_credit_netting_one_he3008_0AD79797_9823_4968_A659_46364794EF22]._WA_Sys_00000009_6347B27A
 GO
IF EXISTS(SELECT 1 FROM sys.stats WHERE OBJECT_ID = OBJECT_ID('[dbo].[calcprocess_credit_netting_one_UAC0288_15C8929A_AD4F_43BA_B4DA_97DE23C3E63D]') AND name='_WA_Sys_00000009_6B63FE7C')
  DROP STATISTICS [dbo].[calcprocess_credit_netting_one_UAC0288_15C8929A_AD4F_43BA_B4DA_97DE23C3E63D]._WA_Sys_00000009_6B63FE7C
 GO
IF EXISTS(SELECT 1 FROM sys.stats WHERE OBJECT_ID = OBJECT_ID('[dbo].[calcprocess_credit_netting_one_usr2902_545C4719_F9AB_4C85_A657_B7E759857B59]') AND name='_WA_Sys_00000009_74AF0842')
  DROP STATISTICS [dbo].[calcprocess_credit_netting_one_usr2902_545C4719_F9AB_4C85_A657_B7E759857B59]._WA_Sys_00000009_74AF0842
 GO
IF EXISTS(SELECT 1 FROM sys.stats WHERE OBJECT_ID = OBJECT_ID('[dbo].[calcprocess_credit_netting_one_usr5874_07E3774F_D921_4830_B3AC_1EEB75282ECA]') AND name='_WA_Sys_00000009_7E605F73')
  DROP STATISTICS [dbo].[calcprocess_credit_netting_one_usr5874_07E3774F_D921_4830_B3AC_1EEB75282ECA]._WA_Sys_00000009_7E605F73
 GO







































































































































































































































