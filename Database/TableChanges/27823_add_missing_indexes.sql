IF NOT EXISTS(SELECT 1 FROM sys.indexes WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[calcprocess_storage_wacog]') AND name = N'IXNC_calcprocess_storage_wacog_term_storage_assets_id_commodity_id_98857')
	CREATE INDEX [IXNC_calcprocess_storage_wacog_term_storage_assets_id_commodity_id_98857] ON [dbo].[calcprocess_storage_wacog] ([term], [storage_assets_id], [commodity_id])
GO

IF NOT EXISTS(SELECT 1 FROM sys.indexes WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[holiday_group]') AND name = N'IXNC_holiday_group_hol_group_value_id_D4D2E')
	CREATE INDEX [IXNC_holiday_group_hol_group_value_id_D4D2E] ON [dbo].[holiday_group] ([hol_group_value_id]) INCLUDE ([hol_date])
GO

IF NOT EXISTS(SELECT 1 FROM sys.indexes WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[source_deal_pnl_detail]') AND name = N'IXNC_source_deal_pnl_detail_pnl_as_of_date_term_start_term_end_DA765')
	CREATE INDEX [IXNC_source_deal_pnl_detail_pnl_as_of_date_term_start_term_end_DA765] ON [dbo].[source_deal_pnl_detail] ([pnl_as_of_date],[term_start], [term_end]) INCLUDE ([source_deal_header_id], [Leg], [deal_volume], [contract_value])
GO
IF NOT EXISTS(SELECT 1 FROM sys.indexes WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[data_source]') AND name = N'IXNC_data_source_name_category_A9080')
	CREATE INDEX [IXNC_data_source_name_category_A9080] ON [dbo].[data_source] ([name], [category])
GO

IF NOT EXISTS(SELECT 1 FROM sys.indexes WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[source_deal_header]') AND name = N'IXNC_source_deal_header_entire_term_start_deal_id_0FB6E')
	CREATE INDEX [IXNC_source_deal_header_entire_term_start_deal_id_0FB6E] ON [dbo].[source_deal_header] ([entire_term_start],[deal_id]) INCLUDE ([source_deal_header_id], [template_id], [description4])
GO

IF NOT EXISTS(SELECT 1 FROM sys.indexes WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[date_details]') AND name = N'IXNC_date_details_is_weekday_A5DCD')
	CREATE INDEX [IXNC_date_details_is_weekday_A5DCD] ON [dbo].[date_details] ([is_weekday]) INCLUDE ([region_id], [sql_date_value])
GO

IF NOT EXISTS(SELECT 1 FROM sys.indexes WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[user_defined_deal_fields]') AND name = N'IXNC_user_defined_deal_fields_udf_template_id_6A1A5')
	CREATE INDEX [IXNC_user_defined_deal_fields_udf_template_id_6A1A5] ON [dbo].[user_defined_deal_fields] ([udf_template_id]) INCLUDE ([source_deal_header_id], [udf_value])
GO

IF NOT EXISTS(SELECT 1 FROM sys.indexes WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[maintain_udf_static_data_detail_values]') AND name = N'IXNC_maintain_udf_static_data_detail_values_primary_field_object_id_D535A')
	CREATE INDEX [IXNC_maintain_udf_static_data_detail_values_primary_field_object_id_D535A] ON [dbo].[maintain_udf_static_data_detail_values] ([primary_field_object_id]) INCLUDE ([application_field_id], [static_data_udf_values])
GO

IF NOT EXISTS(SELECT 1 FROM sys.indexes WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[hour_block_term]') AND name = N'IXNC_hour_block_term_block_define_id_block_type_D2893')
	CREATE INDEX [IXNC_hour_block_term_block_define_id_block_type_D2893] ON [dbo].[hour_block_term] ([block_define_id], [block_type]) INCLUDE ([term_date], [Hr1], [Hr2], [Hr3], [Hr4], [Hr5], [Hr6], [Hr7], [Hr8], [Hr9], [Hr10], [Hr11], [Hr12], [Hr13], [Hr14], [Hr15], [Hr16], [Hr17], [Hr18], [Hr19], [Hr20], [Hr21], [Hr22], [Hr23], [Hr24], [dst_group_value_id])
GO

IF NOT EXISTS(SELECT 1 FROM sys.indexes WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[maintain_field_template_detail]') AND name = N'IXNC_maintain_field_template_detail_field_group_id_udf_or_system_7D540')
	CREATE INDEX [IXNC_maintain_field_template_detail_field_group_id_udf_or_system_7D540] ON [dbo].[maintain_field_template_detail] ([field_group_id], [udf_or_system])
GO

IF NOT EXISTS(SELECT 1 FROM sys.indexes WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[application_functional_users]') AND name = N'IXNC_application_functional_users_function_id_login_id_F3AAD')
	CREATE INDEX [IXNC_application_functional_users_function_id_login_id_F3AAD] ON [dbo].[application_functional_users] ([function_id], [login_id])
GO

IF NOT EXISTS(SELECT 1 FROM sys.indexes WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[ixp_columns]') AND name = N'IXNC_ixp_columns_ixp_columns_name_91A38')
	CREATE INDEX [IXNC_ixp_columns_ixp_columns_name_91A38] ON [dbo].[ixp_columns] ([ixp_columns_name])
GO

IF NOT EXISTS(SELECT 1 FROM sys.indexes WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[index_fees_breakdown_settlement]') AND name = N'IXNC_index_fees_breakdown_settlement_field_id_81E39')
	CREATE INDEX [IXNC_index_fees_breakdown_settlement_field_id_81E39] ON [dbo].[index_fees_breakdown_settlement] ([field_id]) INCLUDE ([as_of_date], [source_deal_header_id], [term_start], [value])
GO
