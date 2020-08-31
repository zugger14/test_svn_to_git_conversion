IF COL_LENGTH('deal_price_deemed', 'formula_currency') IS NULL
BEGIN
    ALTER TABLE deal_price_deemed ADD formula_currency INT REFERENCES source_currency (source_currency_id)
END
GO