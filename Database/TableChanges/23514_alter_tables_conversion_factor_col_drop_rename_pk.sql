
IF COL_LENGTH('conversion_factor', 'conversion_factor_id') IS  NULL
BEGIN
	EXEC sp_rename
	/**
	  Renamed column id to conversion_factor_id
	*/
	'conversion_factor.id', 'conversion_factor_id', 'COLUMN';  
END
GO

IF EXISTS(SELECT 1  
FROM sys.objects  
WHERE type = 'UQ' AND OBJECT_NAME(parent_object_id) = N'conversion_factor' and name = 'UC_conversion_factor' )
BEGIN
	ALTER TABLE dbo.conversion_factor  
	/**
	  Delete the unique constraint.
	*/
	DROP CONSTRAINT UC_conversion_factor;  
END
GO  

IF COL_LENGTH('conversion_factor', 'effective_date') IS NOT NULL
BEGIN
   ALTER TABLE 
   /**
	 Drop column effective_date not used
	*/
   conversion_factor DROP COLUMN effective_date

END
GO

IF COL_LENGTH('conversion_factor', 'factor') IS NOT NULL
BEGIN
	 /**
	  Drop column factor
	*/
	 ALTER TABLE conversion_factor DROP COLUMN factor
END
GO
IF NOT EXISTS(SELECT 1  
FROM sys.objects  
WHERE type = 'UQ' AND OBJECT_NAME(parent_object_id) = N'conversion_factor' and name = 'UC_conversion_factor' )

BEGIN
    ALTER TABLE conversion_factor
	/**
	  Add unique constraint.
	*/
    ADD CONSTRAINT UC_conversion_factor UNIQUE(conversion_value_id,from_uom,to_uom)
END


