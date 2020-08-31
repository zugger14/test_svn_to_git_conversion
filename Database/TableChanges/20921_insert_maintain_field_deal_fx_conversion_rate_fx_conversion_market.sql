IF NOT EXISTS (SELECT 1 FROM maintain_field_deal WHERE field_id = 203 AND farrms_field_id = 'fx_conversion_rate') 
BEGIN
	INSERT INTO [dbo].[maintain_field_deal]([field_id], [farrms_field_id], [default_label], [field_type], [data_type], [default_validation], [header_detail], [system_required], [sql_string], [field_size], [is_disable], [window_function_id], [is_hidden], [default_value], [insert_required], [data_flag], [update_required])
	SELECT 203, N'fx_conversion_rate', N'FX Conversion Rate', N't', N'int', NULL, N'd', NULL, NULL, NULL, NULL, NULL, N'n', NULL, N'y', N'i', N'y'
END


IF NOT EXISTS (SELECT 1 FROM maintain_field_deal WHERE field_id = 204 AND farrms_field_id = 'fx_conversion_market') 
BEGIN
	INSERT INTO [dbo].[maintain_field_deal]([field_id], [farrms_field_id], [default_label], [field_type], [data_type], [default_validation], [header_detail], [system_required], [sql_string], [field_size], [is_disable], [window_function_id], [is_hidden], [default_value], [insert_required], [data_flag], [update_required])
	SELECT 204, N'fx_conversion_market', N'FX Conversion Market', N'd', N'int', NULL, N'h', NULL, N'EXEC spa_StaticDataValues @flag = ''h'', @type_id = 29700', 180, NULL, NULL, N'n', NULL, N'y', N'i', N'y'
END


