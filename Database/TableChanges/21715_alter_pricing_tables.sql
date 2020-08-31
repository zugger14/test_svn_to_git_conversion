IF COL_LENGTH(N'deal_price_std_event', N'pricing_month') IS NULL
BEGIN
	ALTER TABLE [dbo].[deal_price_std_event] ADD [pricing_month] DATE NULL
END

IF COL_LENGTH(N'deal_price_std_event', N'BOLMO_pricing') IS NULL
BEGIN
	ALTER TABLE [dbo].[deal_price_std_event] ADD [BOLMO_pricing] CHAR(1) COLLATE DATABASE_DEFAULT NULL
END

IF COL_LENGTH(N'deal_price_deemed', N'pricing_dates') IS NULL
BEGIN
	ALTER TABLE [dbo].[deal_price_deemed] ADD [pricing_dates] VARCHAR(MAX) COLLATE DATABASE_DEFAULT NULL
END

IF COL_LENGTH(N'deal_price_deemed', N'BOLMO_pricing') IS NULL
BEGIN
	ALTER TABLE [dbo].[deal_price_deemed] ADD [BOLMO_pricing] CHAR(1) COLLATE DATABASE_DEFAULT NULL
END

IF COL_LENGTH(N'deal_price_custom_event', N'pricing_month') IS NULL
BEGIN
	ALTER TABLE [dbo].[deal_price_custom_event] ADD [pricing_month] DATE NULL
END

IF COL_LENGTH(N'deal_price_custom_event', N'skip_granularity') IS NULL
BEGIN
	ALTER TABLE [dbo].[deal_price_custom_event] ADD [skip_granularity] INT NULL
END

IF COL_LENGTH(N'deal_price_custom_event', N'BOLMO_pricing') IS NULL
BEGIN
	ALTER TABLE [dbo].[deal_price_custom_event] ADD [BOLMO_pricing] CHAR(1) COLLATE DATABASE_DEFAULT NULL
END
GO