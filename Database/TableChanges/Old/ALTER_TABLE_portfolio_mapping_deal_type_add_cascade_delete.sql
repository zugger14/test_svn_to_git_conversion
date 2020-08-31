BEGIN TRANSACTION
GO
ALTER TABLE dbo.portfolio_mapping_deal_type
	DROP CONSTRAINT FK__portfolio__portf__215A072E
GO
COMMIT
BEGIN TRANSACTION
GO
ALTER TABLE dbo.portfolio_mapping_deal_type WITH NOCHECK ADD CONSTRAINT
	FK__portfolio__portf__215A072E FOREIGN KEY
	(
	portfolio_mapping_source_id
	) REFERENCES dbo.portfolio_mapping_source
	(
	portfolio_mapping_source_id
	) ON UPDATE  NO ACTION 
	 ON DELETE  CASCADE 
	
GO
COMMIT