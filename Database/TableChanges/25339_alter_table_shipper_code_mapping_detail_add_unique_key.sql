IF NOT EXISTS(SELECT 1  
FROM sys.objects  
WHERE type = 'UQ' AND OBJECT_NAME(parent_object_id) = N'shipper_code_mapping_detail' and name = 'UC_shipper_code_mapping_detail' )

BEGIN
    ALTER TABLE shipper_code_mapping_detail
	/**
	  Add unique constraint.
	*/
    ADD CONSTRAINT UC_shipper_code_mapping_detail UNIQUE(shipper_code_id,effective_date)
END

GO
IF COL_LENGTH('shipper_code_mapping_detail', 'is_default') IS NOT NULL
BEGIN
	 /**
	  Alter column is_default
	*/
	 ALTER TABLE shipper_code_mapping_detail ALTER COLUMN is_default NCHAR(1)
END
GO


