IF NOT EXISTS (
		SELECT 1
		FROM INFORMATION_SCHEMA.COLUMNS
		WHERE TABLE_NAME = 'export_web_service'
			AND COLUMN_NAME = 'auth_url'
		) 
BEGIN
   ALTER TABLE export_web_service ADD auth_url VARCHAR(1000)    
END

IF NOT EXISTS (
		SELECT 1
		FROM INFORMATION_SCHEMA.COLUMNS
		WHERE TABLE_NAME = 'export_web_service'
			AND COLUMN_NAME = 'password'
		) 
BEGIN
   ALTER TABLE export_web_service ADD [password] VARBINARY(100)    
END 
