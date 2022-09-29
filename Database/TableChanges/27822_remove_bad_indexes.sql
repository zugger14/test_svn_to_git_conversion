 IF EXISTS(SELECT 1 FROM sys.indexes WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[source_deal_detail]') AND name = N'IXNC_source_deal_detail_source_deal_group_id_6AE01')
	DROP INDEX [IXNC_source_deal_detail_source_deal_group_id_6AE01] ON [dbo].[source_deal_detail]
GO

 IF EXISTS(SELECT 1 FROM sys.indexes WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[source_deal_header]') AND name = N'IXNC_source_deal_header_source_deal_type_id_56741')
	DROP INDEX [IXNC_source_deal_header_source_deal_type_id_56741] ON [dbo].[source_deal_header]
GO

 IF EXISTS(SELECT 1 FROM sys.indexes WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[source_deal_detail_audit]') AND name = N'IDX_source_deal_detail_audit')
	DROP INDEX [IDX_source_deal_detail_audit] ON [dbo].[source_deal_detail_audit]
GO

 IF EXISTS(SELECT 1 FROM sys.indexes WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[user_defined_deal_fields_audit]') AND name = N'IDX_user_defined_deal_fields_audit')
	DROP INDEX [IDX_user_defined_deal_fields_audit] ON [dbo].[user_defined_deal_fields_audit]
GO

 IF EXISTS(SELECT 1 FROM sys.indexes WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[user_defined_deal_detail_fields_audit]') AND name = N'IDX_user_defined_deal_detail_fields_audit')
	DROP INDEX [IDX_user_defined_deal_detail_fields_audit] ON [dbo].[user_defined_deal_detail_fields_audit]
GO

 IF EXISTS(SELECT 1 FROM sys.indexes WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[source_deal_header_audit]') AND name = N'IDX_source_deal_header_audit')
	DROP INDEX [IDX_source_deal_header_audit] ON [dbo].[source_deal_header_audit]
GO

 IF EXISTS(SELECT 1 FROM sys.indexes WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[deal_position_break_down]') AND name = N'IXNC_deal_position_break_down_source_deal_detail_id_BE67A')
	DROP INDEX [IXNC_deal_position_break_down_source_deal_detail_id_BE67A] ON [dbo].[deal_position_break_down]
GO

 IF EXISTS(SELECT 1 FROM sys.indexes WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[report_hourly_position_deal_main]') AND name = N'IXNC_report_hourly_position_deal_main_source_deal_header_id_term_start_expiration_date_B2606')
	DROP INDEX [IXNC_report_hourly_position_deal_main_source_deal_header_id_term_start_expiration_date_B2606] ON [dbo].[report_hourly_position_deal_main]
GO

 IF EXISTS(SELECT 1 FROM sys.indexes WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[report_hourly_position_deal_main]') AND name = N'IXNC_report_hourly_position_deal_main_expiration_date_161F8')
	DROP INDEX [IXNC_report_hourly_position_deal_main_expiration_date_161F8] ON [dbo].[report_hourly_position_deal_main]
GO

 IF EXISTS(SELECT 1 FROM sys.indexes WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[report_hourly_position_deal_main]') AND name = N'IXNC_report_hourly_position_deal_main_source_deal_header_id_7F8F7')
	DROP INDEX [IXNC_report_hourly_position_deal_main_source_deal_header_id_7F8F7] ON [dbo].[report_hourly_position_deal_main]
GO	
	
 IF EXISTS(SELECT 1 FROM sys.indexes WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[optimizer_detail]') AND name = N'IX_optimizer_detail_flow')
	DROP INDEX [IX_optimizer_detail_flow] ON [dbo].[optimizer_detail]
GO	
	
 IF EXISTS(SELECT 1 FROM sys.indexes WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[credit_exposure_detail]') AND name = N'IXNC_credit_exposure_detail_as_of_date_C68D1')
	DROP INDEX [IXNC_credit_exposure_detail_as_of_date_C68D1] ON [dbo].[credit_exposure_detail]
GO	
		
 IF EXISTS(SELECT 1 FROM sys.indexes WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[deal_detail_hour]') AND name = N'IXNC_deal_detail_hour_profile_id_2FC5B')
	DROP INDEX [IXNC_deal_detail_hour_profile_id_2FC5B] ON [dbo].[deal_detail_hour]
GO		
	
 IF EXISTS(SELECT 1 FROM sys.indexes WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[index_fees_breakdown]') AND name = N'IXNC_index_fees_breakdown_source_deal_header_id_term_start_term_end_as_of_date_DBACA')
	DROP INDEX [IXNC_index_fees_breakdown_source_deal_header_id_term_start_term_end_as_of_date_DBACA] ON [dbo].[index_fees_breakdown]
GO	
	
 IF EXISTS(SELECT 1 FROM sys.indexes WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[source_deal_pnl_detail]') AND name = N'IXNC_source_deal_pnl_detail_pnl_as_of_date_term_start_64A04')
	DROP INDEX [IXNC_source_deal_pnl_detail_pnl_as_of_date_term_start_64A04] ON [dbo].[source_deal_pnl_detail]
GO	
	
 IF EXISTS(SELECT 1 FROM sys.indexes WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[optimizer_detail_hour]') AND name = N'IX_optimizer_detail_hour_hr')
	DROP INDEX [IX_optimizer_detail_hour_hr] ON [dbo].[optimizer_detail_hour]
GO			
	
 IF EXISTS(SELECT 1 FROM sys.indexes WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[source_price_curve]') AND name = N'IXNC_source_price_curve_source_curve_def_id_curve_source_value_id_maturity_date_A2364')
	DROP INDEX [IXNC_source_price_curve_source_curve_def_id_curve_source_value_id_maturity_date_A2364] ON [dbo].[source_price_curve]
GO		
	
 IF EXISTS(SELECT 1 FROM sys.indexes WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[optimizer_detail_downstream_hour]') AND name = N'IX_optimizer_detail_downstream_hour_hr')
	DROP INDEX [IX_optimizer_detail_downstream_hour_hr] ON [dbo].[optimizer_detail_downstream_hour]
GO	
	
 IF EXISTS(SELECT 1 FROM sys.indexes WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[optimizer_detail_downstream_hour]') AND name = N'IXNC_source_deal_settlement_source_deal_header_id_term_start_term_end_as_of_date_3C6EB')
	DROP INDEX [IXNC_source_deal_settlement_source_deal_header_id_term_start_term_end_as_of_date_3C6EB] ON [dbo].[optimizer_detail_downstream_hour]
GO	
		
 IF EXISTS(SELECT 1 FROM sys.indexes WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[delete_source_deal_header]') AND name = N'IXNC_delete_source_deal_header_source_system_book_id1_source_system_book_id2_source_system_book_id3_source_system_book_id4_7E754')
	DROP INDEX [IXNC_delete_source_deal_header_source_system_book_id1_source_system_book_id2_source_system_book_id3_source_system_book_id4_7E754] ON [dbo].[delete_source_deal_header]
GO	
		
	
	
	
