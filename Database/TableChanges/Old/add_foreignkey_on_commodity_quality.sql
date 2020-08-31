-- Deleting all the values form the [commodity_quality] if there quality value already deleted.
DELETE FROM [commodity_quality] WHERE  NOT EXISTS (SELECT * FROM   [static_data_value] WHERE  [commodity_quality].quality = [static_data_value].value_id)

-- Altering quality column from varchar to INT
ALTER TABLE [commodity_quality] ALTER COLUMN quality INT NOT NULL

IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_commodity_quality_quality]') AND parent_object_id = OBJECT_ID(N'[dbo].[commodity_quality]'))
BEGIN

	ALTER TABLE [dbo].[commodity_quality] WITH CHECK ADD CONSTRAINT [FK_commodity_quality_quality] 
	FOREIGN KEY([quality])
	REFERENCES [dbo].[static_data_value] ([value_id])

END