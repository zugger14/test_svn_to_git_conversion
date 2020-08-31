BEGIN TRANSACTION
GO
ALTER TABLE dbo.portfolio_mapping_commodity
	DROP CONSTRAINT FK__portfolio__portf__17D09CF4
GO
COMMIT
BEGIN TRANSACTION
GO
ALTER TABLE dbo.portfolio_mapping_commodity WITH NOCHECK ADD CONSTRAINT
	FK__portfolio__portf__17D09CF4 FOREIGN KEY
	(
	portfolio_mapping_source_id
	) REFERENCES dbo.portfolio_mapping_source
	(
	portfolio_mapping_source_id
	) ON UPDATE  NO ACTION 
	 ON DELETE  CASCADE 
	
GO
COMMIT