BEGIN TRANSACTION
GO

ALTER TABLE dbo.source_deal_detail_lagging
        DROP CONSTRAINT FK_source_deal_detail_lagging_source_deal_header
GO
ALTER TABLE dbo.source_deal_detail_lagging ADD CONSTRAINT
        FK_source_deal_detail_lagging_source_deal_header FOREIGN KEY
        (
        source_deal_header_id
        ) REFERENCES [dbo].[source_deal_header] ([source_deal_header_id]) ON UPDATE  NO ACTION 
         ON DELETE CASCADE 
        
GO
COMMIT
GO

