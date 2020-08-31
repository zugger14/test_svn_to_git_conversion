IF NOT EXISTS (SELECT * FROM maintain_field_deal WHERE field_id = 209 AND farrms_field_id = 'match_type') 
BEGIN
	INSERT INTO [dbo].[maintain_field_deal]([field_id], [farrms_field_id], [default_label], [field_type], [data_type], [default_validation], [header_detail], [system_required], [sql_string], [field_size], [is_disable], [window_function_id], [is_hidden], [default_value], [insert_required], [data_flag], [update_required])
	SELECT 209, N'match_type', N'Match Type', N'd', N'varchar', NULL, N'h', NULL, N'SELECT ''m'' id, ''Vintage Month'' code UNION ALL SELECT ''y'', ''Vintage Year'' UNION ALL SELECT ''f'', ''FIFO''', NULL, NULL, NULL, N'n', NULL, N'y', N'i', N'y'
END

IF NOT EXISTS(SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'source_deal_header_template' AND COLUMN_NAME = 'match_type') 
BEGIN
	ALTER TABLE source_deal_header_template ADD match_type CHAR(1)
END

IF NOT EXISTS(SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'source_deal_header_audit' AND COLUMN_NAME = 'match_type') 
BEGIN
	ALTER TABLE source_deal_header_audit ADD match_type CHAR(1)
END

IF NOT EXISTS(SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'source_deal_header' AND COLUMN_NAME = 'match_type') 
BEGIN
	ALTER TABLE source_deal_header ADD match_type CHAR(1)
END

IF NOT EXISTS(SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'delete_source_deal_header' AND COLUMN_NAME = 'match_type') 
BEGIN
	ALTER TABLE delete_source_deal_header ADD match_type CHAR(1)
END
