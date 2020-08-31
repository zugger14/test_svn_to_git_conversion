IF COL_LENGTH('deal_price_deemed', 'pricing_period') IS NULL
BEGIN
    ALTER TABLE deal_price_deemed ADD pricing_period INT
END
GO

IF COL_LENGTH('deal_price_deemed', 'fixed_price') IS NULL
BEGIN
    ALTER TABLE deal_price_deemed ADD fixed_price FLOAT
END
GO

IF COL_LENGTH('deal_price_deemed', 'pricing_uom') IS NULL
BEGIN
    ALTER TABLE deal_price_deemed ADD pricing_uom INT
END
GO

IF COL_LENGTH('deal_price_deemed', 'adder_currency') IS NULL
BEGIN
    ALTER TABLE deal_price_deemed ADD adder_currency INT
END
GO

IF COL_LENGTH('deal_price_deemed', 'formula_id') IS NULL
BEGIN
    ALTER TABLE deal_price_deemed ADD formula_id INT
END
GO

IF COL_LENGTH('deal_price_deemed', 'priority') IS NULL
BEGIN
    ALTER TABLE deal_price_deemed ADD [priority] INT
END
GO