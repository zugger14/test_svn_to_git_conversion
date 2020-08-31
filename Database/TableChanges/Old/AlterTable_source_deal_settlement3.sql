
IF OBJECT_ID(N'source_deal_settlement', N'U') IS NOT NULL AND COL_LENGTH('source_deal_settlement', 'market_value') IS NULL
BEGIN
	ALTER TABLE source_deal_settlement ADD market_value FLOAT
END

IF OBJECT_ID(N'source_deal_settlement', N'U') IS NOT NULL AND COL_LENGTH('source_deal_settlement', 'contract_value') IS NULL
BEGIN
	ALTER TABLE source_deal_settlement ADD contract_value FLOAT
END

