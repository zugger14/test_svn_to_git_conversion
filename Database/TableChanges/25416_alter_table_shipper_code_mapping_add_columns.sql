IF OBJECT_ID(N'shipper_code_mapping_detail', N'U') IS NOT NULL AND COL_LENGTH('shipper_code_mapping_detail', 'shipper_code1') IS NULL
BEGIN
    ALTER TABLE 
	/**
		Columns
		shipper_code1 : Shipper Code 1
	*/
	shipper_code_mapping_detail ADD shipper_code1 NVARCHAR(100)
END
GO

IF OBJECT_ID(N'shipper_code_mapping_detail', N'U') IS NOT NULL AND COL_LENGTH('shipper_code_mapping_detail', 'shipper_code1_is_default') IS NULL
BEGIN
    ALTER TABLE 
	/**
		Columns
		shipper_code1_is_default : Shipper Code 1 - Is Default
	*/
	shipper_code_mapping_detail ADD shipper_code1_is_default CHAR(1)
END
GO

IF OBJECT_ID(N'shipper_code_mapping_detail', N'U') IS NOT NULL AND COL_LENGTH('shipper_code_mapping_detail', 'internal_counterparty') IS NULL
BEGIN
    ALTER TABLE 
	/**
		Columns
		internal_counterparty : Internal Counterparty
	*/
	shipper_code_mapping_detail ADD internal_counterparty NVARCHAR(100)
END
GO



