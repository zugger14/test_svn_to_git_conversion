IF EXISTS(SELECT 'X' FROM INFORMATION_SCHEMA.REFERENTIAL_CONSTRAINTS    WHERE CONSTRAINT_NAME ='FK_recorder_properties_meter_id')
	ALTER TABLE recorder_properties DROP CONSTRAINT FK_recorder_properties_meter_id

IF EXISTS(SELECT 'X' FROM INFORMATION_SCHEMA.REFERENTIAL_CONSTRAINTS    WHERE CONSTRAINT_NAME ='FK_meter_id_allocation_meter_id')
	ALTER TABLE meter_id_allocation DROP CONSTRAINT FK_meter_id_allocation_meter_id

GO

ALTER TABLE [dbo].recorder_properties  WITH CHECK 
ADD CONSTRAINT [FK_recorder_properties_meter_id] FOREIGN KEY([meter_id])
REFERENCES [dbo].[meter_id] ([meter_id])
ON DELETE CASCADE
GO

ALTER TABLE [dbo].meter_id_allocation  WITH CHECK 
ADD CONSTRAINT [FK_meter_id_allocation_meter_id] FOREIGN KEY([meter_id])
REFERENCES [dbo].[meter_id] ([meter_id])
ON DELETE CASCADE
GO