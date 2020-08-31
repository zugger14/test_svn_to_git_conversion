
IF OBJECT_ID(N'hedge_deferral_values', N'U') IS NOT NULL AND COL_LENGTH('hedge_deferral_values', 'pnl_currency_id') IS NULL
BEGIN
	ALTER TABLE hedge_deferral_values ADD pnl_currency_id INT
END

IF OBJECT_ID(N'hedge_deferral_values', N'U') IS NOT NULL AND COL_LENGTH('hedge_deferral_values', 'deal_volume') IS NULL
BEGIN
	ALTER TABLE hedge_deferral_values ADD deal_volume FLOAT
END

IF OBJECT_ID(N'hedge_deferral_values', N'U') IS NOT NULL AND COL_LENGTH('hedge_deferral_values', 'market_value') IS NULL
BEGIN
	ALTER TABLE hedge_deferral_values ADD market_value FLOAT
END

IF OBJECT_ID(N'hedge_deferral_values', N'U') IS NOT NULL AND COL_LENGTH('hedge_deferral_values', 'contract_value') IS NULL
BEGIN
	ALTER TABLE hedge_deferral_values ADD contract_value FLOAT
END

IF OBJECT_ID(N'hedge_deferral_values', N'U') IS NOT NULL AND COL_LENGTH('hedge_deferral_values', 'dis_market_value') IS NULL
BEGIN
	ALTER TABLE hedge_deferral_values ADD dis_market_value FLOAT
END

IF OBJECT_ID(N'hedge_deferral_values', N'U') IS NOT NULL AND COL_LENGTH('hedge_deferral_values', 'dis_contract_value') IS NULL
BEGIN
	ALTER TABLE hedge_deferral_values ADD dis_contract_value FLOAT
END

IF OBJECT_ID(N'hedge_deferral_values', N'U') IS NOT NULL AND COL_LENGTH('hedge_deferral_values', 'market_value_pnl') IS NULL
BEGIN
	ALTER TABLE hedge_deferral_values ADD market_value_pnl FLOAT
END

IF OBJECT_ID(N'hedge_deferral_values', N'U') IS NOT NULL AND COL_LENGTH('hedge_deferral_values', 'contract_value_pnl') IS NULL
BEGIN
	ALTER TABLE hedge_deferral_values ADD contract_value_pnl FLOAT
END

IF OBJECT_ID(N'hedge_deferral_values', N'U') IS NOT NULL AND COL_LENGTH('hedge_deferral_values', 'dis_market_value_pnl') IS NULL
BEGIN
	ALTER TABLE hedge_deferral_values ADD dis_market_value_pnl FLOAT
END

IF OBJECT_ID(N'hedge_deferral_values', N'U') IS NOT NULL AND COL_LENGTH('hedge_deferral_values', 'dis_contract_value_pnl') IS NULL
BEGIN
	ALTER TABLE hedge_deferral_values ADD dis_contract_value_pnl FLOAT
END

