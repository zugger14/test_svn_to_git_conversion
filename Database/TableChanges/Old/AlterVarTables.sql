/***********************
ALter tables VaR
***************************/

Alter table var_results ADD currency_id INT
GO
ALTER TABLE [dbo].[var_results]  WITH CHECK ADD  CONSTRAINT [FK_var_results_source_currency] FOREIGN KEY([currency_id])
REFERENCES [dbo].[source_currency] ([source_currency_id])
GO
ALTER TABLE [dbo].[var_results] CHECK CONSTRAINT [FK_var_results_source_currency]
GO

Alter table marginal_var ADD MTM_value FLOAT



