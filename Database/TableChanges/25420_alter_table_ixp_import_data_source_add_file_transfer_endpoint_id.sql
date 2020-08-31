IF OBJECT_ID(N'ixp_import_data_source', N'U') IS NOT NULL AND COL_LENGTH('ixp_import_data_source', 'file_transfer_endpoint_id') IS NULL
BEGIN
    ALTER TABLE 
	/**
		Columns
		file_transfer_endpoint_id : File transfer endpoint id
	*/
		ixp_import_data_source ADD file_transfer_endpoint_id INT
END
GO

