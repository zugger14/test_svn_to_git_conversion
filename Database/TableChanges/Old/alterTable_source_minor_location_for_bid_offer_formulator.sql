/*
   Monday, July 27, 200910:47:59 AM
   User: farrms_admin
   Server: MSINGH\INSTANCE1
   Database: TRMTracker
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
ALTER TABLE dbo.source_minor_location ADD CONSTRAINT
	FK_source_minor_location_bid_offer_formulator_header FOREIGN KEY
	(
	bid_offer_formulator_id
	) REFERENCES dbo.bid_offer_formulator_header
	(
	bid_offer_id
	) ON UPDATE  NO ACTION 
	 ON DELETE  NO ACTION 
	
GO
COMMIT
