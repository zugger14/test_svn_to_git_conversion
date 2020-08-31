/*
   Wednesday, January 14, 20094:31:42 PM
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
CREATE TABLE dbo.Tmp_internal_deal_type_subtype_types
	(
	internal_deal_type_subtype_id int NOT NULL IDENTITY (1, 1),
	internal_deal_type_subtype_type varchar(50) NULL,
	type_subtype_flag char(1) NULL
	)  ON [PRIMARY]
GO
SET IDENTITY_INSERT dbo.Tmp_internal_deal_type_subtype_types ON
GO
IF EXISTS(SELECT * FROM dbo.internal_deal_type_subtype_types)
	 EXEC('INSERT INTO dbo.Tmp_internal_deal_type_subtype_types (internal_deal_type_subtype_id, internal_deal_type_subtype_type, type_subtype_flag)
		SELECT internal_deal_type_subtype_id, internal_deal_type_subtype_type, type_subtype_flag FROM dbo.internal_deal_type_subtype_types WITH (HOLDLOCK TABLOCKX)')
GO
SET IDENTITY_INSERT dbo.Tmp_internal_deal_type_subtype_types OFF
GO
ALTER TABLE dbo.default_deal_post_values
	DROP CONSTRAINT FK_default_deal_post_values_default_deal_post_values
GO
DROP TABLE dbo.internal_deal_type_subtype_types
GO
EXECUTE sp_rename N'dbo.Tmp_internal_deal_type_subtype_types', N'internal_deal_type_subtype_types', 'OBJECT' 
GO
ALTER TABLE dbo.internal_deal_type_subtype_types ADD CONSTRAINT
	PK_internal_deal_type_subtype_types PRIMARY KEY CLUSTERED 
	(
	internal_deal_type_subtype_id
	) WITH( STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]

GO
COMMIT
select Has_Perms_By_Name(N'dbo.internal_deal_type_subtype_types', 'Object', 'ALTER') as ALT_Per, Has_Perms_By_Name(N'dbo.internal_deal_type_subtype_types', 'Object', 'VIEW DEFINITION') as View_def_Per, Has_Perms_By_Name(N'dbo.internal_deal_type_subtype_types', 'Object', 'CONTROL') as Contr_Per BEGIN TRANSACTION
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