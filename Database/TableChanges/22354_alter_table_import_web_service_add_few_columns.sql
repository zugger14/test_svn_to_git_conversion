IF NOT EXISTS (
		SELECT 1
		FROM INFORMATION_SCHEMA.COLUMNS
		WHERE TABLE_NAME = 'import_web_service'
			AND COLUMN_NAME = 'auth_url'
		) 
BEGIN
   ALTER TABLE import_web_service ADD auth_url VARCHAR(1000)    
END

IF NOT EXISTS (
		SELECT 1
		FROM INFORMATION_SCHEMA.COLUMNS
		WHERE TABLE_NAME = 'import_web_service'
			AND COLUMN_NAME = 'client_id'
		) 
BEGIN
   ALTER TABLE import_web_service ADD client_id VARCHAR(1000)    
END

IF NOT EXISTS (
		SELECT 1
		FROM INFORMATION_SCHEMA.COLUMNS
		WHERE TABLE_NAME = 'import_web_service'
			AND COLUMN_NAME = 'client_secret'
		) 
BEGIN
   ALTER TABLE import_web_service ADD client_secret VARCHAR(1000)    
END