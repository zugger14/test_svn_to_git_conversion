IF COL_LENGTH('source_price_curve_def', 'location_id') IS NULL
BEGIN
    ALTER TABLE source_price_curve_def ADD location_id INT
	Print 'Column added.'
END

-- add fk constraint
IF NOT EXISTS (SELECT 1 
			FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS 
			WHERE CONSTRAINT_TYPE = 'Foreign KEY' 
			AND TABLE_NAME = 'source_price_curve_def' 
			AND TABLE_SCHEMA ='dbo'
			AND CONSTRAINT_NAME = 'FK_source_price_curve_def_location_id')
BEGIN   
	ALTER TABLE [dbo].[source_price_curve_def]  WITH CHECK 
	ADD  CONSTRAINT [FK_source_price_curve_def_location_id] 
	FOREIGN KEY([location_id])
	REFERENCES [dbo].[source_minor_location] ([source_minor_location_id]) 

	ALTER TABLE [dbo].[source_price_curve_def] 
	CHECK CONSTRAINT [FK_source_price_curve_def_location_id]
END
GO 