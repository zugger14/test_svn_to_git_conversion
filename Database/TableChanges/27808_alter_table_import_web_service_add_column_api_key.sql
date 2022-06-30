-- add new column api_key 
IF OBJECT_ID(N'import_web_service', N'U') IS NOT NULL AND COL_LENGTH('import_web_service', 'api_key') IS NULL
BEGIN
    ALTER TABLE 
	/**
		Columns
		api_key : X-api key 
	*/
		import_web_service ADD api_key NVARCHAR(200) 
END
GO

-- alter column length 
IF OBJECT_ID(N'import_web_service', N'U') IS NOT NULL AND COL_LENGTH('import_web_service', 'auth_token') IS NOT NULL
BEGIN
    ALTER TABLE import_web_service ALTER COLUMN auth_token VARCHAR(1000)
END
GO
