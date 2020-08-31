IF NOT EXISTS(SELECT 'X' FROM INFORMATION_SCHEMA.columns WHERE table_name LIKE 'deal_transfer_mapping' AND column_name LIKE 'transfer_pricing_option')
	ALTER TABLE [dbo].[deal_transfer_mapping] ADD transfer_pricing_option CHAR(1)
GO

IF NOT EXISTS(SELECT 'x' FROM information_schema.columns WHERE table_name LIKE 'deal_transfer_mapping' AND column_name LIKE 'formula_id')
	ALTER TABLE [dbo].[deal_transfer_mapping] ADD formula_id INT 
GO