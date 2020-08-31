BEGIN TRANSACTION
GO
ALTER TABLE dbo.portfolio_mapping_trader
	DROP CONSTRAINT FK__portfolio__portf__261EBC4B
GO
COMMIT
BEGIN TRANSACTION
GO
ALTER TABLE dbo.portfolio_mapping_trader WITH NOCHECK ADD CONSTRAINT
	FK__portfolio__portf__261EBC4B FOREIGN KEY
	(
	portfolio_mapping_source_id
	) REFERENCES dbo.portfolio_mapping_source
	(
	portfolio_mapping_source_id
	) ON UPDATE  NO ACTION 
	 ON DELETE  CASCADE 
	
GO
COMMIT