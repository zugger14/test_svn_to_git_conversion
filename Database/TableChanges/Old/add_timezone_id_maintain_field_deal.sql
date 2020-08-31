IF NOT EXISTS (SELECT 1 FROM maintain_field_deal WHERE field_id = 134 AND farrms_field_id = 'timezone_id') 
BEGIN
	INSERT INTO [dbo].[maintain_field_deal]([field_id], [farrms_field_id], [default_label], [field_type], [data_type], [default_validation], [header_detail], [system_required], [sql_string], [field_size], [is_disable], [window_function_id], [is_hidden], [default_value], [insert_required], [data_flag], [update_required])
	SELECT 134, N'timezone_id', N'Timezone', N'd', N'int', NULL, N'h', NULL, N'exec spa_time_zone @flag=''s''', NULL, NULL, NULL, N'n', NULL, N'y', N'i', N'y'
END 