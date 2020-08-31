IF NOT EXISTS (
		SELECT 1
		FROM INFORMATION_SCHEMA.COLUMNS
		WHERE TABLE_NAME = 'import_web_service'
			AND COLUMN_NAME = 'certificate_path'
		) 
BEGIN
   ALTER TABLE import_web_service ADD certificate_path NVARCHAR(1000)    
END

-- Added for EPEX Web service: password validity is 90 days and updating password needs to be handled by calling their API method.
IF NOT EXISTS (
		SELECT 1
		FROM INFORMATION_SCHEMA.COLUMNS
		WHERE TABLE_NAME = 'import_web_service'
			AND COLUMN_NAME = 'password_updated_date'
		) 
BEGIN
   ALTER TABLE import_web_service ADD password_updated_date DATETIME   
END
