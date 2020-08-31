/*************************
Alter table source_curve_def
*****************************/
 


Alter table source_price_curve_def
ADD spot_curve_id INT 

GO

ALTER TABLE [dbo].[source_price_curve_def]  WITH CHECK ADD  CONSTRAINT [FK_source_price_curve_def_static_data_value5] FOREIGN KEY(spot_curve_id)
REFERENCES [dbo].[source_price_curve_def] ([source_curve_def_id])
GO
