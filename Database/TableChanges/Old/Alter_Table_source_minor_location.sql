/*
   Sunday, March 22, 200912:27:33 PM
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
BEGIN TRANSACTION
GO
COMMIT
select Has_Perms_By_Name(N'dbo.source_uom', 'Object', 'ALTER') as ALT_Per, Has_Perms_By_Name(N'dbo.source_uom', 'Object', 'VIEW DEFINITION') as View_def_Per, Has_Perms_By_Name(N'dbo.source_uom', 'Object', 'CONTROL') as Contr_Per BEGIN TRANSACTION
GO
COMMIT
select Has_Perms_By_Name(N'dbo.contract_group', 'Object', 'ALTER') as ALT_Per, Has_Perms_By_Name(N'dbo.contract_group', 'Object', 'VIEW DEFINITION') as View_def_Per, Has_Perms_By_Name(N'dbo.contract_group', 'Object', 'CONTROL') as Contr_Per BEGIN TRANSACTION
GO
ALTER TABLE dbo.source_minor_location ADD
	owner varchar(100)NULL,
	operator varchar(100) NULL,
	contract int NULL,
	volume float(53) NULL,
	uom int NULL
GO
ALTER TABLE dbo.source_minor_location ADD CONSTRAINT
	FK_source_minor_location_contract_group FOREIGN KEY
	(
	contract
	) REFERENCES dbo.contract_group
	(
	contract_id
	) ON UPDATE  NO ACTION 
	 ON DELETE  NO ACTION 
	
GO
ALTER TABLE dbo.source_minor_location ADD CONSTRAINT
	FK_source_minor_location_source_uom FOREIGN KEY
	(
	uom
	) REFERENCES dbo.source_uom
	(
	source_uom_id
	) ON UPDATE  NO ACTION 
	 ON DELETE  NO ACTION 
	
GO
COMMIT
select Has_Perms_By_Name(N'dbo.source_minor_location', 'Object', 'ALTER') as ALT_Per, Has_Perms_By_Name(N'dbo.source_minor_location', 'Object', 'VIEW DEFINITION') as View_def_Per, Has_Perms_By_Name(N'dbo.source_minor_location', 'Object', 'CONTROL') as Contr_Per 