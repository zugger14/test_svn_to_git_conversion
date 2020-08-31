/*
   Wednesday, December 10, 20085:39:06 PM
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
select Has_Perms_By_Name(N'dbo.static_data_type', 'Object', 'ALTER') as ALT_Per, Has_Perms_By_Name(N'dbo.static_data_type', 'Object', 'VIEW DEFINITION') as View_def_Per, Has_Perms_By_Name(N'dbo.static_data_type', 'Object', 'CONTROL') as Contr_Per BEGIN TRANSACTION
GO
ALTER TABLE dbo.source_price_curve_def ADD
	granularity int NULL
GO
ALTER TABLE dbo.source_price_curve_def ADD CONSTRAINT
	FK_source_price_curve_def_source_price_curve_def1 FOREIGN KEY
	(
	source_curve_def_id
	) REFERENCES dbo.source_price_curve_def
	(
	source_curve_def_id
	) ON UPDATE  NO ACTION 
	 ON DELETE  NO ACTION 
	
GO
ALTER TABLE dbo.source_price_curve_def ADD CONSTRAINT
	FK_source_price_curve_def_static_data_type FOREIGN KEY
	(
	granularity
	) REFERENCES dbo.static_data_value
	(
	value_id
	) ON UPDATE  NO ACTION 
	 ON DELETE  NO ACTION 
	

	
GO
COMMIT
select Has_Perms_By_Name(N'dbo.source_price_curve_def', 'Object', 'ALTER') as ALT_Per, Has_Perms_By_Name(N'dbo.source_price_curve_def', 'Object', 'VIEW DEFINITION') as View_def_Per, Has_Perms_By_Name(N'dbo.source_price_curve_def', 'Object', 'CONTROL') as Contr_Per 