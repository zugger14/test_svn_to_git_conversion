/***************
	Alter table source_price_curve_def to add granularity column
**********************/
ALTER Table
	source_price_curve_def ADD Granularity INT
GO
ALTER TABLE [dbo].[source_price_curve_def]  WITH CHECK ADD  CONSTRAINT [FK_source_price_curve_def_static_data_value1] FOREIGN KEY([granularity])
REFERENCES [dbo].[static_data_value] ([value_id])
GO

