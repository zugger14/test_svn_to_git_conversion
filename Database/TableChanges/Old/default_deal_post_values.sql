/*
   Wednesday, January 14, 20094:19:37 PM
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
CREATE TABLE dbo.default_deal_post_values
	(
	id int NOT NULL IDENTITY (1, 1),
	internal_deal_type_subtype_id int NULL,
	counterparty_id int NULL,
	trader_id int NULL,
	broker_id int NULL,
	deal_type_id int NULL,
	deal_sub_type_id int NULL
	)  ON [PRIMARY]
GO
ALTER TABLE dbo.default_deal_post_values ADD CONSTRAINT
	PK_default_deal_post_values PRIMARY KEY CLUSTERED 
	(
	id
	) WITH( STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]

GO
ALTER TABLE dbo.default_deal_post_values ADD CONSTRAINT
	FK_default_deal_post_values_default_deal_post_values FOREIGN KEY
	(
	id
	) REFERENCES dbo.default_deal_post_values
	(
	id
	) ON UPDATE  NO ACTION 
	 ON DELETE  NO ACTION 
	
GO
COMMIT
select Has_Perms_By_Name(N'dbo.default_deal_post_values', 'Object', 'ALTER') as ALT_Per, Has_Perms_By_Name(N'dbo.default_deal_post_values', 'Object', 'VIEW DEFINITION') as View_def_Per, Has_Perms_By_Name(N'dbo.default_deal_post_values', 'Object', 'CONTROL') as Contr_Per 