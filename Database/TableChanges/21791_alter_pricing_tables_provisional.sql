IF COL_LENGTH(N'deal_price_std_event_provisional', N'pricing_month') IS NULL
BEGIN
	ALTER TABLE [dbo].[deal_price_std_event_provisional] ADD [pricing_month] DATE NULL
END

IF COL_LENGTH(N'deal_price_std_event_provisional', N'BOLMO_pricing') IS NULL
BEGIN
	ALTER TABLE [dbo].[deal_price_std_event_provisional] ADD [BOLMO_pricing] CHAR(1) COLLATE DATABASE_DEFAULT NULL
END

IF COL_LENGTH(N'deal_price_deemed_provisional', N'pricing_dates') IS NULL
BEGIN
	ALTER TABLE [dbo].[deal_price_deemed_provisional] ADD [pricing_dates] VARCHAR(MAX) COLLATE DATABASE_DEFAULT NULL
END

IF COL_LENGTH(N'deal_price_deemed_provisional', N'BOLMO_pricing') IS NULL
BEGIN
	ALTER TABLE [dbo].[deal_price_deemed_provisional] ADD [BOLMO_pricing] CHAR(1) COLLATE DATABASE_DEFAULT NULL
END

IF COL_LENGTH(N'deal_price_custom_event_provisional', N'pricing_month') IS NULL
BEGIN
	ALTER TABLE [dbo].[deal_price_custom_event_provisional] ADD [pricing_month] DATE NULL
END

IF COL_LENGTH(N'deal_price_custom_event_provisional', N'skip_granularity') IS NULL
BEGIN
	ALTER TABLE [dbo].[deal_price_custom_event_provisional] ADD [skip_granularity] INT NULL
END

IF COL_LENGTH(N'deal_price_custom_event_provisional', N'BOLMO_pricing') IS NULL
BEGIN
	ALTER TABLE [dbo].[deal_price_custom_event_provisional] ADD [BOLMO_pricing] CHAR(1) COLLATE DATABASE_DEFAULT NULL
END
GO