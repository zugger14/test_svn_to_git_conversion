/*
Vishwas Khanal
Dated : 09.April.2009
Compliance Integration to TRM
*/
IF NOT EXISTS (SELECT 'X' FROM INFORMATION_SCHEMA.COLUMNS WHERE table_name = 'process_requirements_revisions' and column_name = 'fas_book_id')
BEGIN
	ALTER TABLE [dbo].[process_requirements_revisions] ADD [fas_book_id] [int] NULL

	ALTER TABLE [dbo].[process_risk_controls]  WITH NOCHECK ADD  CONSTRAINT [FK_process_risk_controls_portfolio_hierarchy] FOREIGN KEY([fas_book_id])
	REFERENCES [dbo].[portfolio_hierarchy] ([entity_id])
END
GO

IF NOT EXISTS (SELECT 'X' FROM INFORMATION_SCHEMA.COLUMNS WHERE table_name = 'process_requirements_revisions' and column_name = 'perform_activity')
	ALTER TABLE [dbo].[process_requirements_revisions] ADD [perform_activity] [int] NULL
GO
