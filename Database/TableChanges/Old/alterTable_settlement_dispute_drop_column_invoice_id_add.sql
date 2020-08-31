/*
   Wednesday, July 29, 200910:07:15 AM
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
ALTER TABLE dbo.settlement_dispute
	DROP CONSTRAINT FK_settlement_dispute_save_invoice
GO
COMMIT
BEGIN TRANSACTION
GO
ALTER TABLE dbo.settlement_dispute
	DROP COLUMN invoice_id
GO

ALTER TABLE settlement_dispute add contract_id INT,counterparty_id INT ,prod_date DATETIME,as_of_date DATETIME

COMMIT
