
IF NOT EXISTS (SELECT 1 
			FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS 
			WHERE CONSTRAINT_TYPE = 'Foreign KEY' 
			AND TABLE_NAME = 'conversion_factor' 
			AND TABLE_SCHEMA ='dbo'
			AND CONSTRAINT_NAME = 'FK_conversion_factor_conversion_value_id')
BEGIN   
	ALTER TABLE [dbo].[conversion_factor]  WITH CHECK 
	ADD  CONSTRAINT [FK_conversion_factor_conversion_value_id] 
	FOREIGN KEY([conversion_value_id])
	REFERENCES [dbo].[static_data_value] ([value_id]) 

	ALTER TABLE [dbo].[conversion_factor] 
	CHECK CONSTRAINT [FK_conversion_factor_conversion_value_id]
END
GO

