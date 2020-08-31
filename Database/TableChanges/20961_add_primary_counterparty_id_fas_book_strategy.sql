IF NOT EXISTS(SELECT 'x' FROM information_schema.columns WHERE table_name LIKE 'fas_books' AND column_name LIKE 'primary_counterparty_id')
	ALTER TABLE [dbo].[fas_books] ADD primary_counterparty_id INT 
GO

IF NOT EXISTS(SELECT 'x' FROM information_schema.columns WHERE table_name LIKE 'fas_strategy' AND column_name LIKE 'primary_counterparty_id')
	ALTER TABLE [dbo].[fas_strategy] ADD primary_counterparty_id INT 
GO