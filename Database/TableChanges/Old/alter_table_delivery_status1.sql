/*
   Tuesday, January 20, 20095:25:07 PM
   User: farrms_admin
   Server: BAGRAWAL\INSTANCE1
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
BEGIN TRANSACTION
GO
CREATE TABLE dbo.Tmp_delivery_status
	(
	Id int NOT NULL IDENTITY (1, 1),
	deal_transport_id int NULL,
	delivery_status int NULL,
	status_timestamp datetime NULL,
	current_facility int NULL,
	estimated_delivery_date datetime NULL,
	estimated_delivery_time nchar(100) NULL,
	memo1 nchar(10) NULL,
	memo2 nchar(10) NULL
	)  ON [PRIMARY]
GO
SET IDENTITY_INSERT dbo.Tmp_delivery_status ON
GO
IF EXISTS(SELECT * FROM dbo.delivery_status)
	 EXEC('INSERT INTO dbo.Tmp_delivery_status (Id, deal_transport_id, delivery_status, status_timestamp, current_facility, estimated_delivery_date, estimated_delivery_time, memo1, memo2)
		SELECT Id, deal_transport_id, delivery_status, status_timestamp, current_facility, estimated_delivery_date, estimated_delivery_time, memo1, memo2 FROM dbo.delivery_status WITH (HOLDLOCK TABLOCKX)')
GO
SET IDENTITY_INSERT dbo.Tmp_delivery_status OFF
GO
ALTER TABLE dbo.delivery_status
	DROP CONSTRAINT FK_delivery_status_delivery_status
GO
DROP TABLE dbo.delivery_status
GO
EXECUTE sp_rename N'dbo.Tmp_delivery_status', N'delivery_status', 'OBJECT' 
GO
ALTER TABLE dbo.delivery_status ADD CONSTRAINT
	PK_delivery_status PRIMARY KEY CLUSTERED 
	(
	Id
	) WITH( STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]

GO
ALTER TABLE dbo.delivery_status ADD CONSTRAINT
	FK_delivery_status_delivery_status FOREIGN KEY
	(
	Id
	) REFERENCES dbo.delivery_status
	(
	Id
	) ON UPDATE  NO ACTION 
	 ON DELETE  NO ACTION 
	
GO
COMMIT
select Has_Perms_By_Name(N'dbo.delivery_status', 'Object', 'ALTER') as ALT_Per, Has_Perms_By_Name(N'dbo.delivery_status', 'Object', 'VIEW DEFINITION') as View_def_Per, Has_Perms_By_Name(N'dbo.delivery_status', 'Object', 'CONTROL') as Contr_Per 