
alter table curve_volatility add granularity int
GO
ALTER TABLE [dbo].[curve_volatility]  WITH CHECK ADD  CONSTRAINT [FK_curve_volatility_static_data_value2] FOREIGN KEY([granularity])
REFERENCES [dbo].[static_data_value] ([value_id])

