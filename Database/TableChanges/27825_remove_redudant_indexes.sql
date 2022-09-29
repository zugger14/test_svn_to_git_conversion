IF EXISTS(SELECT 1 FROM sys.indexes WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[calcprocess_deals]') AND name = N'ix_calprocess_deals1')
	DROP INDEX [ix_calprocess_deals1] ON [dbo].[calcprocess_deals]
GO

IF EXISTS(SELECT 1 FROM sys.indexes WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[calcprocess_deals_expired]') AND name = N'ix_calcprocess_deals_expired1')
	DROP INDEX [ix_calcprocess_deals_expired1] ON [dbo].[calcprocess_deals_expired]
GO

IF EXISTS(SELECT 1 FROM sys.indexes WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[fas_dedesignated_link_detail]') AND name = N'indx_fas_dedesignated_link_detail_tm')
	DROP INDEX [indx_fas_dedesignated_link_detail_tm] ON [dbo].[fas_dedesignated_link_detail]
GO

IF EXISTS(SELECT 1 FROM sys.indexes WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[fas_eff_ass_test_results_process_detail]') AND name = N'indx_fas_eff_ass_test_results_process_detail_tm')
	DROP INDEX [indx_fas_eff_ass_test_results_process_detail_tm] ON [dbo].[fas_eff_ass_test_results_process_detail]
GO

IF EXISTS(SELECT 1 FROM sys.indexes WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[fas_eff_ass_test_results_process_header]') AND name = N'indx_fas_eff_ass_test_results_process_header_tm')
	DROP INDEX [indx_fas_eff_ass_test_results_process_header_tm] ON [dbo].[fas_eff_ass_test_results_process_header]
GO

IF EXISTS(SELECT 1 FROM sys.indexes WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[fas_eff_ass_test_results_profile]') AND name = N'indx_fas_eff_ass_test_results_profile_tm')
	DROP INDEX [indx_fas_eff_ass_test_results_profile_tm] ON [dbo].[fas_eff_ass_test_results_profile]
GO

IF EXISTS(SELECT 1 FROM sys.indexes WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[fas_eff_hedge_rel_type_whatif_detail]') AND name = N'indx_fas_eff_hedge_rel_type_whatif_detail_tm')
	DROP INDEX [indx_fas_eff_hedge_rel_type_whatif_detail_tm] ON [dbo].[fas_eff_hedge_rel_type_whatif_detail]
GO

IF EXISTS(SELECT 1 FROM sys.indexes WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[report_hourly_position_deal_main]') AND name = N'IXNC_report_hourly_position_deal_main_source_deal_header_id_term_start_expiration_date_B2606')
	DROP INDEX [IXNC_report_hourly_position_deal_main_source_deal_header_id_term_start_expiration_date_B2606] ON [dbo].[report_hourly_position_deal_main]
GO

IF EXISTS(SELECT 1 FROM sys.indexes WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[report_hourly_position_profile_blank]') AND name = N'indx_report_hourly_position_profile_blank_deal_id')
	DROP INDEX [indx_report_hourly_position_profile_blank_deal_id] ON [dbo].[report_hourly_position_profile_blank]
GO

IF EXISTS(SELECT 1 FROM sys.indexes WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[report_measurement_values]') AND name = N'ix_report_measurement_values1')
	DROP INDEX [ix_report_measurement_values1] ON [dbo].[report_measurement_values]
GO

IF EXISTS(SELECT 1 FROM sys.indexes WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[report_measurement_values_expired]') AND name = N'ix_report_measurement_values_expired1')
	DROP INDEX [ix_report_measurement_values_expired1] ON [dbo].[report_measurement_values_expired]
GO

IF EXISTS(SELECT 1 FROM sys.indexes WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[source_deal_pnl_arch1]') AND name = N'indx_source_deal_pnl_arch1_tm')
	DROP INDEX [indx_source_deal_pnl_arch1_tm] ON [dbo].[source_deal_pnl_arch1]
GO

IF EXISTS(SELECT 1 FROM sys.indexes WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[source_deal_pnl_arch2]') AND name = N'indx_source_deal_pnl_arch2_tm1')
	DROP INDEX [indx_source_deal_pnl_arch2_tm1] ON [dbo].[source_deal_pnl_arch2]
GO

IF EXISTS(SELECT 1 FROM sys.indexes WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[source_deal_pnl_settlement]') AND name = N'indx_source_deal_pnl_settlement_tm')
	DROP INDEX [indx_source_deal_pnl_settlement_tm] ON [dbo].[source_deal_pnl_settlement]
GO

IF EXISTS(SELECT 1 FROM sys.indexes WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[state_properties_duration]') AND name = N'IX_state_properties_duration_1')
	DROP INDEX [IX_state_properties_duration_1] ON [dbo].[state_properties_duration]
GO

