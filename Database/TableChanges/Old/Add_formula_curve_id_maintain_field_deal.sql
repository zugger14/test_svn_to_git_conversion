IF NOT EXISTS (SELECT 1 FROM maintain_field_deal WHERE field_id = 127 AND farrms_field_id = 'formula_curve_id') 
BEGIN
	INSERT INTO [dbo].[maintain_field_deal]([field_id], [farrms_field_id], [default_label], [field_type], [data_type], [default_validation], [header_detail], [system_required], [sql_string], [field_size], [is_disable], [window_function_id], [is_hidden], [default_value], [insert_required], [data_flag], [update_required])
	SELECT 127, N'formula_curve_id', N'Formula Curve', NULL, N'int', NULL, N'd', NULL, NULL, NULL, NULL, NULL, N'y', NULL, N'n', N'i', N'n'
END 