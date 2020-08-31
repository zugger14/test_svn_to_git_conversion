BEGIN TRANSACTION
GO

ALTER TABLE dbo.commodity_quality
        DROP CONSTRAINT FK__commodity__sourc__1A409346
GO
ALTER TABLE dbo.commodity_quality ADD CONSTRAINT
        FK__commodity__sourc__1A409346 FOREIGN KEY
        (
        source_commodity_id
        ) REFERENCES [dbo].[source_commodity] ([source_commodity_id]) ON UPDATE  NO ACTION 
         ON DELETE CASCADE 
        
GO
COMMIT
GO

