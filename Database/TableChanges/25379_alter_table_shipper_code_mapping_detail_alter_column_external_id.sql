IF COL_LENGTH('shipper_code_mapping_detail', 'external_id') IS NOT NULL
BEGIN
	ALTER TABLE 
	/**
		Columns
		external_id: External ID
	*/
		shipper_code_mapping_detail ALTER COLUMN external_id VARCHAR(100)
END
GO
