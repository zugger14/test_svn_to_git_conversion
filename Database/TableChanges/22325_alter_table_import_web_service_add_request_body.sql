IF NOT EXISTS(SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'import_web_service' AND COLUMN_NAME = 'request_body')
BEGIN
	ALTER TABLE import_web_service ADD request_body VARCHAR(MAX)
END

IF NOT EXISTS(SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'import_web_service' AND COLUMN_NAME = 'request_params')
BEGIN
	ALTER TABLE import_web_service ADD request_params VARCHAR(MAX)
END

IF EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'import_web_service' AND COLUMN_NAME = 'password' AND DATA_TYPE = 'varchar') 
BEGIN
   ALTER TABLE import_web_service DROP COLUMN [password]
   
   ALTER TABLE import_web_service ADD [password] VARBINARY(100)
END
