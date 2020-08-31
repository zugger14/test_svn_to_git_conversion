IF COL_LENGTH('source_fee_volume', 'subsidiary') IS NULL
BEGIN
    ALTER TABLE source_fee_volume ADD subsidiary INT NULL
END

IF COL_LENGTH('source_fee_volume', 'deal_type') IS NULL
BEGIN
    ALTER TABLE source_fee_volume ADD deal_type INT NULL
END

IF COL_LENGTH('source_fee_volume', 'buy_sell') IS NULL
BEGIN
    ALTER TABLE source_fee_volume ADD buy_sell CHAR NULL
END

IF COL_LENGTH('source_fee_volume', 'index_market') IS NULL
BEGIN
    ALTER TABLE source_fee_volume ADD index_market INT NULL
END

IF COL_LENGTH('source_fee_volume', 'commodity') IS NULL
BEGIN
    ALTER TABLE source_fee_volume ADD commodity INT NULL
END

IF COL_LENGTH('source_fee_volume', 'location') IS NULL
BEGIN
    ALTER TABLE source_fee_volume ADD location INT NULL
END