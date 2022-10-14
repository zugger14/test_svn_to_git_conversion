IF OBJECT_ID(N'export_web_service', N'U') IS NOT NULL AND COL_LENGTH('export_web_service', 'token_updated_date') IS NULL
BEGIN
    ALTER TABLE 
	/**
		Columns
		token_updated_date : Last updated date and time of token
	*/
		export_web_service ADD token_updated_date DATETIME
END
GO


IF OBJECT_ID(N'export_web_service', N'U') IS NOT NULL AND COL_LENGTH('export_web_service', 'auth_key') IS NULL
BEGIN
    ALTER TABLE 
	/**
		Columns
		auth_key : Authentication Key 
	*/
		export_web_service ADD auth_key VARCHAR(100)
END
GO
