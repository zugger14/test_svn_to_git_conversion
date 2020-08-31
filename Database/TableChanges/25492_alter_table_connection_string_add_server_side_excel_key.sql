IF OBJECT_ID(N'connection_string', N'U') IS NOT NULL AND COL_LENGTH('connection_string', 'server_side_excel_key') IS NULL
BEGIN
    ALTER TABLE 
	/**
		Columns
		server_side_excel_key : Encrypted license key by Spire
	*/
		connection_string ADD server_side_excel_key VARBINARY(4000)
END
GO