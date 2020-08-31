IF NOT EXISTS (SELECT 1 
			FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS 
			WHERE CONSTRAINT_TYPE = 'Foreign KEY' 
			AND TABLE_NAME = 'conversion_factor' 
			AND TABLE_SCHEMA ='dbo'
			AND CONSTRAINT_NAME = 'FK_conversion_factor_from_uom')
BEGIN   
	ALTER TABLE [dbo].[conversion_factor]  WITH CHECK 
	ADD  CONSTRAINT [FK_conversion_factor_from_uom] 
	FOREIGN KEY([from_uom])
	REFERENCES [dbo].[source_uom] ([source_uom_id]) 

	ALTER TABLE [dbo].[conversion_factor] 
	CHECK CONSTRAINT [FK_conversion_factor_from_uom]
END
GO

IF NOT EXISTS (SELECT 1 
			FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS 
			WHERE CONSTRAINT_TYPE = 'Foreign KEY' 
			AND TABLE_NAME = 'conversion_factor' 
			AND TABLE_SCHEMA ='dbo'
			AND CONSTRAINT_NAME = 'FK_conversion_factor_to_uom')
BEGIN   
	ALTER TABLE [dbo].[conversion_factor]  WITH CHECK 
	ADD  CONSTRAINT [FK_conversion_factor_to_uom] 
	FOREIGN KEY([to_uom])
	REFERENCES [dbo].[source_uom] ([source_uom_id]) 

	ALTER TABLE [dbo].[conversion_factor] 
	CHECK CONSTRAINT [FK_conversion_factor_to_uom]
END
GO




