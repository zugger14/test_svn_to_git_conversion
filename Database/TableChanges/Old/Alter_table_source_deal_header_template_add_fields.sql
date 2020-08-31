/*
   Tuesday, March 31, 200910:52:53 AM
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
ALTER TABLE dbo.source_deal_header_template ADD
	rollover_to_spot char(1) NULL,
	discounting_applies char(1) NULL
GO
COMMIT
select Has_Perms_By_Name(N'dbo.source_deal_header_template', 'Object', 'ALTER') as ALT_Per, Has_Perms_By_Name(N'dbo.source_deal_header_template', 'Object', 'VIEW DEFINITION') as View_def_Per, Has_Perms_By_Name(N'dbo.source_deal_header_template', 'Object', 'CONTROL') as Contr_Per 