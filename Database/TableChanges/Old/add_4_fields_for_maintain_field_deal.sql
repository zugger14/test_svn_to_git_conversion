IF NOT EXISTS(SELECT 'X' FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'maintain_field_deal' AND COLUMN_NAME = 'sql_string')
BEGIN
	ALTER TABLE maintain_field_deal ADD sql_string varchar(5000) NULL
END
IF NOT EXISTS(SELECT 'X' FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'maintain_field_deal' AND COLUMN_NAME = 'field_size')
BEGIN
	ALTER TABLE maintain_field_deal ADD field_size int NULL
END
IF NOT EXISTS(SELECT 'X' FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'maintain_field_deal' AND COLUMN_NAME = 'is_disable')
BEGIN
	ALTER TABLE maintain_field_deal ADD is_disable  char(1) NULL
END
IF NOT EXISTS(SELECT 'X' FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'maintain_field_deal' AND COLUMN_NAME = 'window_function_id')
BEGIN
	ALTER TABLE maintain_field_deal ADD window_function_id varchar(50) NULL
END