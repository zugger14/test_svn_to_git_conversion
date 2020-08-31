/*************************
Alter table fas_subsidiaries add curve_id
*****************************/
 


ALTER TABLE fas_subsidiaries ADD discount_curve_id int;
GO
ALTER TABLE fas_subsidiaries ADD risk_free_curve_id int;
GO

ALTER TABLE [dbo].fas_subsidiaries  WITH CHECK ADD  CONSTRAINT [FK_fas_subsidiaries_source_price_curve_def] FOREIGN KEY([discount_curve_id])
REFERENCES [dbo].source_price_curve_def ([source_curve_def_id])
GO
ALTER TABLE [dbo].fas_subsidiaries  WITH CHECK ADD  CONSTRAINT [FK_fas_subsidiaries_source_price_curve_def1] FOREIGN KEY([risk_free_curve_id])
REFERENCES [dbo].source_price_curve_def ([source_curve_def_id])
GO



