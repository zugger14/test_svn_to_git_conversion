IF NOT EXISTS (SELECT 'x' FROM INFORMATION_SCHEMA.columns WHERE table_name = 'source_deal_detail' AND column_name = 'fixed_cost')
	ALTER TABLE [dbo].[source_deal_detail] ADD [fixed_cost] FLOAT 