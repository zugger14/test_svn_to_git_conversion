
alter table source_price_curve_def add monthly_index int
GO
ALTER TABLE [dbo].[source_price_curve_def]  WITH CHECK ADD  CONSTRAINT [FK_source_price_curve_def_source_price_curve_def4] FOREIGN KEY([monthly_index])
REFERENCES [dbo].[source_price_curve_def] ([source_curve_def_id])

