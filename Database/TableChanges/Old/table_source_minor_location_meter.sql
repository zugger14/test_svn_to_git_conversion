/*
   Monday, March 23, 200911:16:45 AM
   User: farrms_admin
   Server: PAWAN
   Database: TRMTracker2_1
   Application: 
*/

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
/*
BEGIN TRANSACTION
GO
ALTER TABLE dbo.source_minor_location_meter
	DROP CONSTRAINT FK_source_minor_location_meter_source_minor_location_meter
GO
COMMIT
*/
select Has_Perms_By_Name(N'dbo.source_minor_location', 'Object', 'ALTER') as ALT_Per, Has_Perms_By_Name(N'dbo.source_minor_location', 'Object', 'VIEW DEFINITION') as View_def_Per, Has_Perms_By_Name(N'dbo.source_minor_location', 'Object', 'CONTROL') as Contr_Per BEGIN TRANSACTION
GO
CREATE TABLE dbo.Tmp_source_minor_location_meter
	(
	meter_id int NOT NULL IDENTITY (1, 1),
	meter_name varchar(100) NULL,
	meter_description varchar(100) NULL,
	is_active char(1) NULL,
	source_minor_location_id int NULL
	)  ON [PRIMARY]
GO
SET IDENTITY_INSERT dbo.Tmp_source_minor_location_meter ON
GO
IF EXISTS(SELECT * FROM dbo.source_minor_location_meter)
	 EXEC('INSERT INTO dbo.Tmp_source_minor_location_meter (meter_id, meter_name, meter_description, is_active, source_minor_location_id)
		SELECT meter_id, meter_name, meter_description, is_active, source_minor_location_id FROM dbo.source_minor_location_meter WITH (HOLDLOCK TABLOCKX)')
GO
SET IDENTITY_INSERT dbo.Tmp_source_minor_location_meter OFF
GO
DROP TABLE dbo.source_minor_location_meter
GO
EXECUTE sp_rename N'dbo.Tmp_source_minor_location_meter', N'source_minor_location_meter', 'OBJECT' 
GO
ALTER TABLE dbo.source_minor_location_meter ADD CONSTRAINT
	PK_source_minor_location_meter PRIMARY KEY CLUSTERED 
	(
	meter_id
	) WITH( STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]

GO
ALTER TABLE dbo.source_minor_location_meter ADD CONSTRAINT
	FK_source_minor_location_meter_source_minor_location_meter FOREIGN KEY
	(
	source_minor_location_id
	) REFERENCES dbo.source_minor_location
	(
	source_minor_location_id
	) ON UPDATE  NO ACTION 
	 ON DELETE  NO ACTION 
	
GO
COMMIT
select Has_Perms_By_Name(N'dbo.source_minor_location_meter', 'Object', 'ALTER') as ALT_Per, Has_Perms_By_Name(N'dbo.source_minor_location_meter', 'Object', 'VIEW DEFINITION') as View_def_Per, Has_Perms_By_Name(N'dbo.source_minor_location_meter', 'Object', 'CONTROL') as Contr_Per 