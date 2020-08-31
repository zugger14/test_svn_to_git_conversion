/*
   Tuesday, January 20, 20096:33:20 PM
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
COMMIT
select Has_Perms_By_Name(N'dbo.deal_transport_header', 'Object', 'ALTER') as ALT_Per, Has_Perms_By_Name(N'dbo.deal_transport_header', 'Object', 'VIEW DEFINITION') as View_def_Per, Has_Perms_By_Name(N'dbo.deal_transport_header', 'Object', 'CONTROL') as Contr_Per BEGIN TRANSACTION
GO
ALTER TABLE dbo.delivery_status
	DROP CONSTRAINT FK_delivery_status_delivery_status
GO
ALTER TABLE dbo.delivery_status ADD CONSTRAINT
	FK_delivery_status_delivery_status FOREIGN KEY
	(
	deal_transport_id
	) REFERENCES dbo.deal_transport_header
	(
	deal_transport_id
	) ON UPDATE  NO ACTION 
	 ON DELETE  NO ACTION 
	
GO
COMMIT
select Has_Perms_By_Name(N'dbo.delivery_status', 'Object', 'ALTER') as ALT_Per, Has_Perms_By_Name(N'dbo.delivery_status', 'Object', 'VIEW DEFINITION') as View_def_Per, Has_Perms_By_Name(N'dbo.delivery_status', 'Object', 'CONTROL') as Contr_Per 