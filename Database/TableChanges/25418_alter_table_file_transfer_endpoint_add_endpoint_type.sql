IF OBJECT_ID(N'file_transfer_endpoint', N'U') IS NOT NULL AND COL_LENGTH('file_transfer_endpoint', 'endpoint_type') IS NULL
BEGIN
    ALTER TABLE 
	/**
		Columns
		endpoint_type : Endpoint type to identify endpoint will be used for Import or Export, represent as drop down, null => Both, 1=> Import, 2=> Export
	*/
		file_transfer_endpoint ADD endpoint_type int
END
GO



