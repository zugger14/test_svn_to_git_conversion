IF OBJECT_ID(N'import_process_info', N'U') IS NOT NULL AND COL_LENGTH('import_process_info', 'create_user') IS NULL
BEGIN
    ALTER TABLE 
	/**
		Columns
		create_user : Created user.
	*/
		import_process_info ADD create_user NVARCHAR(200) DEFAULT dbo.FNADBUser()
END
GO

IF OBJECT_ID(N'import_process_info', N'U') IS NOT NULL AND COL_LENGTH('import_process_info', 'create_ts') IS NULL
BEGIN
    ALTER TABLE 
	/**
		Columns
		create_ts : Created date
	*/
		import_process_info ADD create_ts datetime DEFAULT GETDATE()
END
GO


TRUNCATE TABLE import_process_info
