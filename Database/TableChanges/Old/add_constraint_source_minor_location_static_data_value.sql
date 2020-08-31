if not exists(SELECT * FROM sys.objects  WHERE TYPE = 'f' AND NAME = 'FK_source_minor_location_static_data_value')
BEGIN 
	ALTER TABLE [dbo].[source_minor_location]  WITH CHECK ADD  CONSTRAINT [FK_source_minor_location_static_data_value] FOREIGN KEY([grid_value_id])
	REFERENCES [dbo].[static_data_value] ([value_id])
	

	ALTER TABLE [dbo].[source_minor_location] CHECK CONSTRAINT [FK_source_minor_location_static_data_value]
	

END 
