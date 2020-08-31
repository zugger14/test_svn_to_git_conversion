/*
   Thursday, January 15, 200912:50:45 PM
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
BEGIN TRANSACTION
GO
COMMIT
BEGIN TRANSACTION
GO
ALTER TABLE dbo.deal_exercise_detail ADD CONSTRAINT
	FK_deal_exercise_detail_source_deal_detail FOREIGN KEY
	(
	source_deal_detail_id
	) REFERENCES dbo.source_deal_detail
	(
	source_deal_detail_id
	) ON UPDATE  NO ACTION 
	 ON DELETE  NO ACTION 
	
GO
ALTER TABLE dbo.deal_exercise_detail ADD CONSTRAINT
	FK_deal_exercise_detail_source_deal_header FOREIGN KEY
	(
	exercise_deal_id
	) REFERENCES dbo.source_deal_header
	(
	source_deal_header_id
	) ON UPDATE  NO ACTION 
	 ON DELETE  NO ACTION 
	
GO
COMMIT
