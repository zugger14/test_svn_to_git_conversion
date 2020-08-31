/* To prevent any potential data loss issues, you should review this script in detail before running it outside the context of the database designer.*/
BEGIN TRANSACTION
SET QUOTED_IDENTIFIER ON
SET ARITHABORT ON
SET NUMERIC_ROUNDABORT OFF
SET CONCAT_NULL_YIELDS_NULL ON
SET ANSI_NULLS ON
SET ANSI_PADDING ON
SET ANSI_WARNINGS ON
COMMIT
BEGIN TRANSACTION
GO

IF NOT EXISTS (
	SELECT * FROM sys.indexes i 
	INNER JOIN sys.tables t ON t.[object_id] = i.[object_id]
	WHERE i.name LIKE 'PK_forecast_profile' AND t.name = 'forecast_profile'
)
ALTER TABLE dbo.forecast_profile ADD CONSTRAINT
	PK_forecast_profile PRIMARY KEY CLUSTERED 
	(
	profile_id
	) WITH( STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]



-- Update source_minor_location table to set all profiles which no longer exist to NULL
UPDATE sml
SET profile_id = NULL 
FROM 
source_minor_location sml
WHERE NOT EXISTS (
	SELECT * FROM forecast_profile fp
	WHERE fp.profile_id = sml.profile_id	
)


IF NOT EXISTS (
	SELECT * FROM sys.foreign_keys fk
	INNER JOIN sys.tables t ON t.[object_id] = fk.[parent_object_id]
	WHERE fk.name LIKE 'FK_source_minor_location_forecast_profile'
		AND t.name LIKE 'source_minor_location'
)
ALTER TABLE dbo.source_minor_location ADD CONSTRAINT
	FK_source_minor_location_forecast_profile FOREIGN KEY
	(
	profile_id
	) REFERENCES dbo.forecast_profile
	(
	profile_id
	) ON UPDATE  NO ACTION 
	 ON DELETE  NO ACTION 
	
GO
COMMIT
