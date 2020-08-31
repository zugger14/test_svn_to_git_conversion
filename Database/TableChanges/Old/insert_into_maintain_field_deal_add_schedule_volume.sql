IF NOT EXISTS (SELECT 1 FROM maintain_field_deal WHERE field_id = 151 AND farrms_field_id = 'schedule_volume') 
BEGIN
	INSERT INTO [dbo].[maintain_field_deal]([field_id], [farrms_field_id], [default_label], [field_type], [data_type], [default_validation], [header_detail], [system_required], [sql_string], [field_size], [is_disable], [window_function_id], [is_hidden], [default_value], [insert_required], [data_flag], [update_required])
	SELECT 151, N'schedule_volume', N'Schedule Volume', N't', N'number', NULL, N'd', NULL, N'', NULL, NULL, NULL, N'n', NULL, N'y', N'i', N'y'
END