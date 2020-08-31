/*
   Monday, January 05, 20097:21:38 PM
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
ALTER TABLE dbo.source_deal_header ADD
	close_reference_id int NULL
GO
ALTER TABLE dbo.source_deal_header ADD CONSTRAINT
	FK_source_deal_header_source_deal_header FOREIGN KEY
	(
	source_deal_header_id
	) REFERENCES dbo.source_deal_header
	(
	source_deal_header_id
	) ON UPDATE  NO ACTION 
	 ON DELETE  NO ACTION 
	
GO
ALTER TABLE dbo.source_deal_header ADD CONSTRAINT
	FK_source_deal_header_source_deal_header1 FOREIGN KEY
	(
	close_reference_id
	) REFERENCES dbo.source_deal_header
	(
	source_deal_header_id
	) ON UPDATE  NO ACTION 
	 ON DELETE  NO ACTION 
	
GO
COMMIT
select Has_Perms_By_Name(N'dbo.source_deal_header', 'Object', 'ALTER') as ALT_Per, Has_Perms_By_Name(N'dbo.source_deal_header', 'Object', 'VIEW DEFINITION') as View_def_Per, Has_Perms_By_Name(N'dbo.source_deal_header', 'Object', 'CONTROL') as Contr_Per 