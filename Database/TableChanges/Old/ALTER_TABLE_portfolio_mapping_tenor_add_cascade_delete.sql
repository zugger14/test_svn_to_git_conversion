BEGIN TRANSACTION
GO
ALTER TABLE dbo.portfolio_mapping_tenor
	DROP CONSTRAINT FK__portfolio__portf__2AE37168
GO
COMMIT
BEGIN TRANSACTION
GO
ALTER TABLE dbo.portfolio_mapping_tenor WITH NOCHECK ADD CONSTRAINT
	FK__portfolio__portf__2AE37168 FOREIGN KEY
	(
	portfolio_mapping_source_id
	) REFERENCES dbo.portfolio_mapping_source
	(
	portfolio_mapping_source_id
	) ON UPDATE  NO ACTION 
	 ON DELETE  CASCADE 
	
GO
COMMIT