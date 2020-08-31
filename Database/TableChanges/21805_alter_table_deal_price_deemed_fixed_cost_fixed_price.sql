IF COL_LENGTH(N'deal_price_deemed', N'fixed_cost') IS NOT NULL
	ALTER TABLE deal_price_deemed ALTER COLUMN fixed_cost NUMERIC(38, 4)

IF COL_LENGTH(N'deal_price_deemed', N'fixed_price') IS NOT NULL
	ALTER TABLE deal_price_deemed ALTER COLUMN fixed_price NUMERIC(38, 4)