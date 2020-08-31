IF COL_LENGTH('deal_price_deemed', 'fixed_cost') IS NULL
BEGIN
    ALTER TABLE deal_price_deemed ADD fixed_cost FLOAT
END
GO

IF COL_LENGTH('deal_price_deemed', 'fixed_cost_currency') IS NULL
BEGIN
    ALTER TABLE deal_price_deemed ADD fixed_cost_currency INT  REFERENCES source_currency (source_currency_id)
END
GO