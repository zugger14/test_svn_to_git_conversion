/*
   Monday, March 23, 20099:41:25 AM
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
ALTER TABLE dbo.source_minor_location ADD
	region int NULL,
	is_pool char(1)NULL,
	term_pricing_index int NULL
GO
COMMIT
select Has_Perms_By_Name(N'dbo.source_minor_location', 'Object', 'ALTER') as ALT_Per, Has_Perms_By_Name(N'dbo.source_minor_location', 'Object', 'VIEW DEFINITION') as View_def_Per, Has_Perms_By_Name(N'dbo.source_minor_location', 'Object', 'CONTROL') as Contr_Per 