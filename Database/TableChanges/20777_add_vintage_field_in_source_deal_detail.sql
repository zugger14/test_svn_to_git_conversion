IF NOT EXISTS (SELECT 1 FROM maintain_field_deal WHERE field_id = 152 AND farrms_field_id = 'vintage') 
BEGIN
	INSERT INTO [dbo].[maintain_field_deal]([field_id], [farrms_field_id], [default_label], [field_type], [data_type], [default_validation], [header_detail], [system_required], [sql_string], [field_size], [is_disable], [window_function_id], [is_hidden], [default_value], [insert_required], [data_flag], [update_required])
	SELECT 152, N'vintage', N'Vintage', N'd', N'varchar', NULL, N'd', NULL, N'SELECT n id, n vintage FROM seq WHERE n BETWEEN 2000 AND 2050', NULL, NULL, NULL, N'n', NULL, N'y', N'i', N'y'

	UPDATE maintain_field_deal 
	SET sql_string = 'SELECT n id, n vintage FROM seq WHERE n BETWEEN 2000 AND 2050',
		system_required = 'n',
		data_type = 'int',
		field_size = 230
	WHERE farrms_field_id = 'vintage'
END
ELSE 
BEGIN
	UPDATE maintain_field_deal 
	SET sql_string = 'SELECT n id, n vintage FROM seq WHERE n BETWEEN 2000 AND 2050',
		system_required = 'n',
		data_type = 'int',
		field_size = 230
	WHERE farrms_field_id = 'vintage'
END

IF NOT EXISTS(SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'source_deal_detail_template' AND COLUMN_NAME = 'vintage') 
BEGIN
	ALTER TABLE source_deal_detail_template ADD vintage VARCHAR(10)
END

IF NOT EXISTS(SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'source_deal_detail_audit' AND COLUMN_NAME = 'vintage') 
BEGIN
	ALTER TABLE source_deal_detail_audit ADD vintage VARCHAR(10)
END

IF NOT EXISTS(SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'source_deal_detail' AND COLUMN_NAME = 'vintage') 
BEGIN
	ALTER TABLE source_deal_detail ADD vintage VARCHAR(10)
END

IF NOT EXISTS(SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'delete_source_deal_detail' AND COLUMN_NAME = 'vintage') 
BEGIN
	ALTER TABLE delete_source_deal_detail ADD vintage VARCHAR(10)
END