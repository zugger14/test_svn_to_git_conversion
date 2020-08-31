IF OBJECT_ID(N'shipper_code_mapping_detail', N'U') IS NOT NULL 
	AND COL_LENGTH('shipper_code_mapping_detail', 'location_id') IS NULL
BEGIN
	ALTER TABLE
	/**
		Columns
		location_id : Location ID
	*/
		shipper_code_mapping_detail ADD location_id INT
END
GO

IF OBJECT_ID(N'shipper_code_mapping_detail', N'U') IS NOT NULL 
	AND COL_LENGTH('shipper_code_mapping_detail', 'is_active') IS NULL
BEGIN
	ALTER TABLE 
	/**
		Columns
		is_active: Active/Inactive flag
	*/
		shipper_code_mapping_detail ADD is_active CHAR(1)
END
GO

IF OBJECT_ID(N'shipper_code_mapping_detail', N'U') IS NOT NULL 
	AND COL_LENGTH('shipper_code_mapping_detail', 'external_id') IS NULL
BEGIN
	ALTER TABLE 
	/**
		Columns
		external_id: External ID
	*/
		shipper_code_mapping_detail ADD external_id VARCHAR(1)
END
GO
