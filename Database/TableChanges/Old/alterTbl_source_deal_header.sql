
IF NOT EXISTS(SELECT 'X' FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'source_deal_header' AND COLUMN_NAME = 'unit_fixed_flag')
BEGIN
	ALTER TABLE source_deal_header ADD unit_fixed_flag CHAR(1) 
END

IF NOT EXISTS(SELECT 'X' FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'source_deal_header' AND COLUMN_NAME = 'broker_unit_fees')
BEGIN
	ALTER TABLE source_deal_header ADD broker_unit_fees FLOAT 
END

IF NOT EXISTS(SELECT 'X' FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'source_deal_header' AND COLUMN_NAME = 'broker_fixed_cost')
BEGIN
	ALTER TABLE source_deal_header ADD broker_fixed_cost FLOAT 
END

IF NOT EXISTS(SELECT 'X' FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'source_deal_header' AND COLUMN_NAME = 'broker_currency_id')
BEGIN
	ALTER TABLE source_deal_header ADD broker_currency_id INT 
END


IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_source_deal_header_source_currency]') AND parent_object_id = OBJECT_ID(N'[dbo].[source_deal_header]'))
ALTER TABLE [dbo].[source_deal_header] DROP CONSTRAINT [FK_source_deal_header_source_currency]
GO

ALTER TABLE [dbo].[source_deal_header]  WITH NOCHECK ADD  CONSTRAINT [FK_source_deal_header_source_currency] FOREIGN KEY([broker_currency_id])
REFERENCES [dbo].[source_currency] ([source_currency_id])
GO
ALTER TABLE [dbo].[source_deal_header] CHECK CONSTRAINT [FK_source_deal_header_source_currency]
GO