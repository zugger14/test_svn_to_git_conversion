IF EXISTS(SELECT 1  
FROM sys.objects  
WHERE type = 'UQ' AND OBJECT_NAME(parent_object_id) = N'shipper_code_mapping' and name = 'UC_shipper_code_mapping' )
BEGIN
	ALTER TABLE dbo.shipper_code_mapping  
	/**
	  Delete the unique constraint.
	*/
	DROP CONSTRAINT UC_shipper_code_mapping;  
END
GO  

IF COL_LENGTH('shipper_code_mapping', 'effective_date') IS NOT NULL
BEGIN
   ALTER TABLE 
   /**
	 Drop column effective_date not used
	*/
   shipper_code_mapping DROP COLUMN effective_date

END
GO

IF COL_LENGTH('shipper_code_mapping', 'shipper_code') IS NOT NULL
BEGIN
	 /**
	  Drop column shipper_code
	*/
	 ALTER TABLE shipper_code_mapping DROP COLUMN shipper_code
END
GO

IF COL_LENGTH('shipper_code_mapping', 'is_default') IS NOT NULL
BEGIN
	 /**
	  Drop column is_default
	*/
	 ALTER TABLE shipper_code_mapping DROP COLUMN is_default
END
GO

IF NOT EXISTS(SELECT 1  
FROM sys.objects  
WHERE type = 'UQ' AND OBJECT_NAME(parent_object_id) = N'shipper_code_mapping' and name = 'UC_shipper_code_mapping' )

BEGIN
    ALTER TABLE shipper_code_mapping
	/**
	  Add unique constraint.
	*/
    ADD CONSTRAINT UC_shipper_code_mapping UNIQUE(counterparty_id,location_id)
END
GO


