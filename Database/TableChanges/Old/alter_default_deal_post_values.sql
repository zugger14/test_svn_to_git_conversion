/*
   Wednesday, January 14, 20094:29:03 PM
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
select Has_Perms_By_Name(N'dbo.internal_deal_type_subtype_types', 'Object', 'ALTER') as ALT_Per, Has_Perms_By_Name(N'dbo.internal_deal_type_subtype_types', 'Object', 'VIEW DEFINITION') as View_def_Per, Has_Perms_By_Name(N'dbo.internal_deal_type_subtype_types', 'Object', 'CONTROL') as Contr_Per BEGIN TRANSACTION
GO
ALTER TABLE dbo.default_deal_post_values
	DROP CONSTRAINT FK_default_deal_post_values_default_deal_post_values
GO
ALTER TABLE dbo.default_deal_post_values ADD CONSTRAINT
	FK_default_deal_post_values_default_deal_post_values FOREIGN KEY
	(
	internal_deal_type_subtype_id
	) REFERENCES dbo.internal_deal_type_subtype_types
	(
	internal_deal_type_subtype_id
	) ON UPDATE  NO ACTION 
	 ON DELETE  NO ACTION 
	
GO
COMMIT
select Has_Perms_By_Name(N'dbo.default_deal_post_values', 'Object', 'ALTER') as ALT_Per, Has_Perms_By_Name(N'dbo.default_deal_post_values', 'Object', 'VIEW DEFINITION') as View_def_Per, Has_Perms_By_Name(N'dbo.default_deal_post_values', 'Object', 'CONTROL') as Contr_Per 