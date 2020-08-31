IF NOT EXISTS(SELECT DISTINCT 'X' FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'deal_transfer_mapping' AND COLUMN_NAME IN ('template_id'))
	BEGIN 
		ALTER TABLE [dbo].[deal_transfer_mapping] ADD
		[template_id] [int] NULL
		PRINT 'Table deal_transfer_mapping ALTERED'
	END 
IF OBJECT_ID('FK_template_id','F') IS NOT NULL
BEGIN 
	ALTER TABLE [dbo].[deal_transfer_mapping] DROP CONSTRAINT [FK_template_id]
	
	ALTER TABLE [dbo].[deal_transfer_mapping] WITH NOCHECK ADD
		CONSTRAINT [FK_template_id] FOREIGN KEY ([template_id]) REFERENCES [dbo].[source_deal_header_template] ([template_id])
END 

PRINT 'TABLE deal_transfer_mapping ALTERED.'