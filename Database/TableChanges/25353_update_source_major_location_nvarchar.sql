IF EXISTS(SELECT 'X' FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS WHERE CONSTRAINT_NAME = 'unique_source_major_location_location_name')
BEGIN
	ALTER TABLE source_major_location
	DROP CONSTRAINT unique_source_major_location_location_name
END

IF EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'unique_source_major_location_location_name' AND object_id = OBJECT_ID(N'[dbo].[source_major_location]'))
BEGIN 
	DROP INDEX source_major_location.unique_source_major_location_location_name
END

IF COL_LENGTH('source_major_location', 'location_name') IS NOT NULL
BEGIN
	ALTER TABLE
	/**
        Columns
        location_name : Location Name
    */
	source_major_location ALTER COLUMN location_name NVARCHAR(100)
END

IF COL_LENGTH('source_major_location', 'location_description') IS NOT NULL
BEGIN
	ALTER TABLE
	/**
        Columns
        location_description : Location Description
    */
	source_major_location ALTER COLUMN location_description NVARCHAR(255)
END



IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'unique_source_major_location_location_name' AND object_id = OBJECT_ID(N'[dbo].[source_major_location]'))
	ALTER TABLE [dbo].[source_major_location] ADD CONSTRAINT [unique_source_major_location_location_name] UNIQUE NONCLUSTERED  (location_name) ON [PRIMARY]
GO

IF NOT EXISTS(SELECT 'X' FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS WHERE CONSTRAINT_NAME = 'unique_source_major_location_location_name')
BEGIN
	ALTER TABLE source_major_location
	ADD CONSTRAINT unique_source_major_location_location_name UNIQUE NONCLUSTERED (location_name)
END


