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
ALTER TABLE dbo.counterparty_credit_info
	DROP CONSTRAINT FK_counterparty_credit_info_source_counterparty
GO
COMMIT
BEGIN TRANSACTION
GO
ALTER TABLE dbo.counterparty_credit_info ADD CONSTRAINT
	FK_counterparty_credit_info_source_counterparty FOREIGN KEY
	(
	Counterparty_id
	) REFERENCES dbo.source_counterparty
	(
	source_counterparty_id
	) ON UPDATE  NO ACTION 
	 ON DELETE  NO ACTION 
	
GO
COMMIT
