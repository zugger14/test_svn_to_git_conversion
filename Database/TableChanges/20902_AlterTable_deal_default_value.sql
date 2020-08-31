IF COL_LENGTH('deal_default_value', 'buy_sell_flag') IS NULL
BEGIN
    ALTER TABLE deal_default_value ADD buy_sell_flag CHAR(1)
END
GO

IF COL_LENGTH('deal_default_value', 'cycle') IS NULL
BEGIN
    ALTER TABLE deal_default_value ADD cycle INT
END
GO

IF COL_LENGTH('deal_default_value', 'upstream_counterparty') IS NULL
BEGIN
    ALTER TABLE deal_default_value ADD upstream_counterparty INT
END
GO

IF COL_LENGTH('deal_default_value', 'upstream_contract') IS NULL
BEGIN
    ALTER TABLE deal_default_value ADD upstream_contract INT
END
GO

IF COL_LENGTH('deal_default_value', 'fx_conversion_rate') IS NULL
BEGIN
    ALTER TABLE deal_default_value ADD fx_conversion_rate FLOAT
END
GO

IF COL_LENGTH('deal_default_value', 'settlement_currency') IS NULL
BEGIN
    ALTER TABLE deal_default_value ADD settlement_currency INT
END
GO

IF COL_LENGTH('deal_default_value', 'settlement_date') IS NULL
BEGIN
    ALTER TABLE deal_default_value ADD settlement_date DATETIME
END
GO

IF COL_LENGTH('deal_default_value', 'block_define_id') IS NULL
BEGIN
    ALTER TABLE deal_default_value ADD block_define_id INT
END
GO