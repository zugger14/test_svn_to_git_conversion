IF NOT EXISTS (SELECT 1 FROM maintain_field_deal WHERE field_id = 150 AND farrms_field_id = 'cycle') 
BEGIN
	INSERT INTO [dbo].[maintain_field_deal]([field_id], [farrms_field_id], [default_label], [field_type], [data_type], [default_validation], [header_detail], [system_required], [sql_string], [field_size], [is_disable], [window_function_id], [is_hidden], [default_value], [insert_required], [data_flag], [update_required])
	SELECT 150, N'cycle', N'Cycle', N'd', N'int', NULL, N'd', NULL, N'SELECT value_id, code FROM static_data_value WHERE type_id = 41000', NULL, NULL, NULL, N'n', NULL, N'y', N'i', N'y'
END