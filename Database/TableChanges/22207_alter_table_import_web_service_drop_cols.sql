IF EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'import_web_service' AND COLUMN_NAME = 'password' AND DATA_TYPE = 'varchar') 
BEGIN
   ALTER TABLE import_web_service DROP COLUMN [password]
   
   ALTER TABLE import_web_service ADD [password] VARBINARY(100)
END

IF EXISTS (
		SELECT 1
		FROM INFORMATION_SCHEMA.COLUMNS
		WHERE TABLE_NAME = 'import_web_service'
			AND COLUMN_NAME = 'client_name'
			AND DATA_TYPE = 'VARCHAR'
		) 
BEGIN
   ALTER TABLE import_web_service DROP COLUMN client_name
END

