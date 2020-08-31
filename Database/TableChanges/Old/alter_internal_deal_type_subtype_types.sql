/*
   Wednesday, January 14, 20094:27:05 PM
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
ALTER TABLE dbo.internal_deal_type_subtype_types ADD CONSTRAINT
	PK_internal_deal_type_subtype_types PRIMARY KEY CLUSTERED 
	(
	internal_deal_type_subtype_id
	) WITH( STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]

GO
COMMIT
select Has_Perms_By_Name(N'dbo.internal_deal_type_subtype_types', 'Object', 'ALTER') as ALT_Per, Has_Perms_By_Name(N'dbo.internal_deal_type_subtype_types', 'Object', 'VIEW DEFINITION') as View_def_Per, Has_Perms_By_Name(N'dbo.internal_deal_type_subtype_types', 'Object', 'CONTROL') as Contr_Per 