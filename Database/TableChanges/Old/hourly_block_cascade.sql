BEGIN TRANSACTION
GO

ALTER TABLE dbo.hourly_block
        DROP CONSTRAINT FK_hourly_block_static_data_value
GO
ALTER TABLE dbo.hourly_block ADD CONSTRAINT
        FK_hourly_block_static_data_value FOREIGN KEY
        (
        block_value_id
        ) REFERENCES [dbo].[static_data_value] ([value_id]) ON UPDATE  NO ACTION 
         ON DELETE CASCADE 
        
GO
COMMIT
GO
