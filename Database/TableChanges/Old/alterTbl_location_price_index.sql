/*
   Friday, May 22, 20095:48:12 PM
   User: farrms_admin
   Server: PIONEER-PC\instance1
   Database: TRMTracker
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
BEGIN TRANSACTION
GO
ALTER TABLE dbo.location_price_index
	DROP CONSTRAINT FK_location_price_index_static_data_value
GO
ALTER TABLE dbo.location_price_index
	DROP CONSTRAINT FK_location_price_index_static_data_value1
GO
COMMIT
BEGIN TRANSACTION
GO
ALTER TABLE dbo.location_price_index
	DROP CONSTRAINT FK_location_price_index_source_price_curve_def
GO
COMMIT
BEGIN TRANSACTION
GO
ALTER TABLE dbo.location_price_index
	DROP CONSTRAINT FK_location_price_index_source_minor_location
GO
COMMIT
BEGIN TRANSACTION
GO
CREATE TABLE dbo.Tmp_location_price_index
	(
	location_price_index_id int NOT NULL IDENTITY (1, 1),
	location_id int NOT NULL,
	product_type_id int NOT NULL,
	price_type_id int NOT NULL,
	curve_id int NOT NULL,
	create_user varchar(50) NULL,
	create_ts datetime NULL,
	update_user varchar(50) NULL,
	update_ts datetime NULL
	)  ON [PRIMARY]
GO
SET IDENTITY_INSERT dbo.Tmp_location_price_index ON
GO
IF EXISTS(SELECT * FROM dbo.location_price_index)
	 EXEC('INSERT INTO dbo.Tmp_location_price_index (location_price_index_id, location_id, product_type_id, price_type_id, curve_id, create_user, create_ts, update_user, update_ts)
		SELECT location_price_index_id, location_id, product_type_id, price_type_id, curve_id, create_user, create_ts, update_user, update_ts FROM dbo.location_price_index WITH (HOLDLOCK TABLOCKX)')
GO
SET IDENTITY_INSERT dbo.Tmp_location_price_index OFF
GO
DROP TABLE dbo.location_price_index
GO
EXECUTE sp_rename N'dbo.Tmp_location_price_index', N'location_price_index', 'OBJECT' 
GO
ALTER TABLE dbo.location_price_index ADD CONSTRAINT
	PK_location_price_index PRIMARY KEY CLUSTERED 
	(
	location_price_index_id
	) WITH( STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]

GO
ALTER TABLE dbo.location_price_index ADD CONSTRAINT
	FK_location_price_index_source_minor_location FOREIGN KEY
	(
	location_id
	) REFERENCES dbo.source_minor_location
	(
	source_minor_location_id
	) ON UPDATE  NO ACTION 
	 ON DELETE  NO ACTION 
	
GO
ALTER TABLE dbo.location_price_index ADD CONSTRAINT
	FK_location_price_index_source_price_curve_def FOREIGN KEY
	(
	curve_id
	) REFERENCES dbo.source_price_curve_def
	(
	source_curve_def_id
	) ON UPDATE  NO ACTION 
	 ON DELETE  NO ACTION 
	
GO
ALTER TABLE dbo.location_price_index ADD CONSTRAINT
	FK_location_price_index_static_data_value FOREIGN KEY
	(
	product_type_id
	) REFERENCES dbo.static_data_value
	(
	value_id
	) ON UPDATE  NO ACTION 
	 ON DELETE  NO ACTION 
	
GO
ALTER TABLE dbo.location_price_index ADD CONSTRAINT
	FK_location_price_index_static_data_value1 FOREIGN KEY
	(
	price_type_id
	) REFERENCES dbo.static_data_value
	(
	value_id
	) ON UPDATE  NO ACTION 
	 ON DELETE  NO ACTION 
	
GO
CREATE TRIGGER [dbo].[TRGUPD_location_price_index]
ON dbo.location_price_index
FOR UPDATE
AS
UPDATE location_price_index SET update_user =  dbo.FNADBUser(), update_ts = getdate()  where  location_price_index.location_price_index_id in (select location_price_index_id from deleted)
GO
CREATE TRIGGER [dbo].[TRGINS_location_price_index]
ON dbo.location_price_index
FOR INSERT
AS
UPDATE location_price_index SET create_user =  dbo.FNADBUser(), create_ts = getdate() where  location_price_index.location_price_index_id in (select location_price_index_id from inserted)
GO
COMMIT
