/*
   Friday, January 09, 20091:19:46 PM
   User: farrms_admin
   Server: SMAHARJAN\INSTANCE1
   Database: TRM_Master
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
ALTER TABLE dbo.source_price_curve
	DROP CONSTRAINT FK_source_price_curve_static_data_value2
GO
COMMIT
select Has_Perms_By_Name(N'dbo.static_data_value', 'Object', 'ALTER') as ALT_Per, Has_Perms_By_Name(N'dbo.static_data_value', 'Object', 'VIEW DEFINITION') as View_def_Per, Has_Perms_By_Name(N'dbo.static_data_value', 'Object', 'CONTROL') as Contr_Per BEGIN TRANSACTION
GO
ALTER TABLE dbo.source_price_curve
	DROP COLUMN volume_granularity
GO
COMMIT
select Has_Perms_By_Name(N'dbo.source_price_curve', 'Object', 'ALTER') as ALT_Per, Has_Perms_By_Name(N'dbo.source_price_curve', 'Object', 'VIEW DEFINITION') as View_def_Per, Has_Perms_By_Name(N'dbo.source_price_curve', 'Object', 'CONTROL') as Contr_Per 