IF OBJECT_ID(N'shipper_code_mapping_detail', N'U') IS NOT NULL AND COL_LENGTH('shipper_code_mapping_detail', 'shipper_code1_is_default') IS NOT NULL
BEGIN
    ALTER TABLE shipper_code_mapping_detail ALTER COLUMN shipper_code1_is_default CHAR(1)
END
GO