BEGIN TRANSACTION
GO

ALTER TABLE dbo.holiday_block
        DROP CONSTRAINT FK_holiday_block_static_data_value
GO
ALTER TABLE dbo.holiday_block ADD CONSTRAINT
        FK_holiday_block_static_data_value FOREIGN KEY
        (
        block_value_id
        ) REFERENCES [dbo].[static_data_value] ([value_id]) ON UPDATE  NO ACTION 
         ON DELETE CASCADE 
        
GO
COMMIT
GO
