BEGIN TRANSACTION
GO

ALTER TABLE dbo.holiday_group
        DROP CONSTRAINT FK_holiday_group_static_data_value
GO
ALTER TABLE dbo.holiday_group ADD CONSTRAINT
        FK_holiday_group_static_data_value FOREIGN KEY
        (
        hol_group_value_id
        ) REFERENCES [dbo].[static_data_value] ([value_id]) ON UPDATE  NO ACTION 
         ON DELETE CASCADE 
        
GO
COMMIT
GO

