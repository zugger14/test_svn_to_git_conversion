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
ALTER TABLE dbo.location_loss_factor
	DROP CONSTRAINT FK_location_loss_factor_source_minor_location
GO
ALTER TABLE dbo.location_loss_factor
	DROP CONSTRAINT FK_location_loss_factor_source_minor_location1
GO
COMMIT
BEGIN TRANSACTION
GO
CREATE TABLE dbo.Tmp_location_loss_factor
	(
	location_loss_factor_id int NOT NULL IDENTITY (1, 1),
	effective_date datetime NULL,
	from_location_id int NOT NULL,
	to_location_id int NOT NULL,
	loss_factor float(53) NOT NULL
	)  ON [PRIMARY]
GO
SET IDENTITY_INSERT dbo.Tmp_location_loss_factor ON
GO
IF EXISTS(SELECT * FROM dbo.location_loss_factor)
	 EXEC('INSERT INTO dbo.Tmp_location_loss_factor (location_loss_factor_id, effective_date, from_location_id, to_location_id, loss_factor)
		SELECT location_loss_factor_id, effective_date, from_location_id, to_location_id, loss_factor FROM dbo.location_loss_factor WITH (HOLDLOCK TABLOCKX)')
GO
SET IDENTITY_INSERT dbo.Tmp_location_loss_factor OFF
GO
DROP TABLE dbo.location_loss_factor
GO
EXECUTE sp_rename N'dbo.Tmp_location_loss_factor', N'location_loss_factor', 'OBJECT' 
GO
ALTER TABLE dbo.location_loss_factor ADD CONSTRAINT
	PK_location_loss_factor PRIMARY KEY CLUSTERED 
	(
	location_loss_factor_id
	) WITH( STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]

GO
ALTER TABLE dbo.location_loss_factor ADD CONSTRAINT
	IX_location_loss_factor UNIQUE NONCLUSTERED 
	(
	effective_date,
	from_location_id,
	to_location_id
	) WITH( STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]

GO
ALTER TABLE dbo.location_loss_factor ADD CONSTRAINT
	FK_location_loss_factor_source_minor_location FOREIGN KEY
	(
	from_location_id
	) REFERENCES dbo.source_minor_location
	(
	source_minor_location_id
	) ON UPDATE  NO ACTION 
	 ON DELETE  NO ACTION 
	
GO
ALTER TABLE dbo.location_loss_factor ADD CONSTRAINT
	FK_location_loss_factor_source_minor_location1 FOREIGN KEY
	(
	to_location_id
	) REFERENCES dbo.source_minor_location
	(
	source_minor_location_id
	) ON UPDATE  NO ACTION 
	 ON DELETE  NO ACTION 
	
GO
COMMIT
