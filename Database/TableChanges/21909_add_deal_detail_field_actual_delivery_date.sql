IF NOT EXISTS (SELECT 1 FROM maintain_field_deal WHERE farrms_field_id = 'actual_delivery_date' AND header_detail = 'd')
BEGIN
	INSERT INTO [dbo].[maintain_field_deal]([farrms_field_id], [default_label], [field_type], [data_type], [default_validation], [header_detail], [system_required], [sql_string], [field_size], [is_disable], [window_function_id], [is_hidden], [default_value], [insert_required], [data_flag], [update_required])
	SELECT N'actual_delivery_date', N'Actual Delivery Date', N'a', N'datetime', NULL, N'd', NULL, NULL, NULL, NULL, NULL, N'n', NULL, N'y', N'i', N'y'
END

IF COL_LENGTH(N'source_deal_detail_template', N'actual_delivery_date') IS NULL
BEGIN
	ALTER TABLE source_deal_detail_template ADD actual_delivery_date DATETIME
END

IF COL_LENGTH(N'source_deal_detail_audit', N'actual_delivery_date') IS NULL
BEGIN
	ALTER TABLE source_deal_detail_audit ADD actual_delivery_date DATETIME
END

IF COL_LENGTH(N'source_deal_detail', N'actual_delivery_date') IS NULL
BEGIN
	ALTER TABLE source_deal_detail ADD actual_delivery_date DATETIME
END

IF COL_LENGTH(N'delete_source_deal_detail', N'actual_delivery_date') IS NULL
BEGIN
	ALTER TABLE delete_source_deal_detail ADD actual_delivery_date DATETIME
END