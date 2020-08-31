IF OBJECT_ID(N'ixp_import_data_source', N'U') IS NOT NULL AND COL_LENGTH('ixp_import_data_source', 'remote_directory') IS NULL
BEGIN
    ALTER TABLE 
	/**
		Columns
		file_transfer_endpoint_id : File transfer endpoint id
	*/
		ixp_import_data_source ADD remote_directory NVARCHAR(1024)
END
GO