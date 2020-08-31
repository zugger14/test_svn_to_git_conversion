-- source_minor_location

EXEC sp_fulltext_column      
@tabname =  'source_minor_location' , 
@colname =  'Location_Name' , 
@action =  'drop' 
GO

IF EXISTS(SELECT 'X' FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS WHERE CONSTRAINT_NAME = 'IX_source_minor_location')
BEGIN
	ALTER TABLE source_minor_location
	DROP CONSTRAINT IX_source_minor_location
END

IF COL_LENGTH('source_minor_location', 'Location_Name') IS NOT NULL
BEGIN
    ALTER TABLE source_minor_location ALTER COLUMN Location_Name nvarchar(100)
END
GO

IF NOT EXISTS(SELECT 'X' FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS WHERE CONSTRAINT_NAME = 'IX_source_minor_location')
BEGIN
	ALTER TABLE source_minor_location
	ADD CONSTRAINT IX_source_minor_location UNIQUE (term_pricing_index, Pricing_Index, Location_Name)
END

EXEC sp_fulltext_column       
@tabname =  'source_minor_location' , 
@colname =  'Location_Name' , 
@action =  'add' 
GO



EXEC sp_fulltext_column      
@tabname =  'source_minor_location' , 
@colname =  'Location_Description' , 
@action =  'drop' 
GO

IF COL_LENGTH('source_minor_location', 'Location_Description') IS NOT NULL
BEGIN
    ALTER TABLE source_minor_location ALTER COLUMN Location_Description nvarchar(500)
END
GO

EXEC sp_fulltext_column       
@tabname =  'source_minor_location' , 
@colname =  'Location_Description' , 
@action =  'add' 
GO


IF EXISTS(SELECT 'X' FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS WHERE CONSTRAINT_NAME = 'UX_source_minor_location')
BEGIN
	ALTER TABLE source_minor_location
	DROP CONSTRAINT UX_source_minor_location
END


Declare @error int = 0
BEGIN
BEGIN TRY
	EXEC sp_fulltext_column      
	@tabname =  'source_minor_location' , 
	@colname =  'location_id' , 
	@action =  'drop' 
END TRY
BEGIN CATCH
	SET @error = 1
END CATCH
END

IF COL_LENGTH('source_minor_location', 'location_id') IS NOT NULL
BEGIN
    ALTER TABLE source_minor_location ALTER COLUMN location_id nvarchar(500)
END
GO

EXEC sp_fulltext_column       
@tabname =  'source_minor_location' , 
@colname =  'location_id' , 
@action =  'add' 
GO

IF NOT EXISTS(SELECT 'X' FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS WHERE CONSTRAINT_NAME = 'UX_source_minor_location')
BEGIN
	ALTER TABLE source_minor_location
	ADD CONSTRAINT UX_source_minor_location UNIQUE (location_id)
END



