
IF OBJECT_ID('IX_invoice_header', 'UQ') IS NOT NULL 
ALTER TABLE  [dbo].[invoice_header] DROP CONSTRAINT IX_invoice_header
GO

IF  EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[invoice_header]') AND name = N'IX_invoice_header')
DROP INDEX [IX_invoice_header] ON [dbo].[invoice_header] WITH ( ONLINE = OFF )
GO
ALTER TABLE  [dbo].[invoice_header] ADD CONSTRAINT IX_invoice_header UNIQUE ([counterparty_id],[production_month],[contract_id])



