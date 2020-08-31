BEGIN TRANSACTION
GO
ALTER TABLE dbo.portfolio_mapping_counterparty
	DROP CONSTRAINT FK__portfolio__portf__1C955211
GO
COMMIT
BEGIN TRANSACTION
GO
ALTER TABLE dbo.portfolio_mapping_counterparty WITH NOCHECK ADD CONSTRAINT
	FK__portfolio__portf__1C955211 FOREIGN KEY
	(
	portfolio_mapping_source_id
	) REFERENCES dbo.portfolio_mapping_source
	(
	portfolio_mapping_source_id
	) ON UPDATE  NO ACTION 
	 ON DELETE  CASCADE 
	
GO
COMMIT