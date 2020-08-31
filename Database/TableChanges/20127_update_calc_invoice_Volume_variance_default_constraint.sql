ALTER TABLE [dbo].[Calc_invoice_Volume_variance]
DROP CONSTRAINT [DF_calc_invoice_volume_variance_invoice_status] 
GO

ALTER TABLE [dbo].[Calc_invoice_Volume_variance] ADD  CONSTRAINT
[DF_calc_invoice_volume_variance_invoice_status] DEFAULT (20701) FOR [invoice_status]
GO

