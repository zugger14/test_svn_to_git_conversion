IF COL_LENGTH('deal_price_deemed', 'include_weekends') IS NULL
BEGIN
    ALTER TABLE deal_price_deemed ADD include_weekends CHAR(1)
END
GO

IF COL_LENGTH('deal_price_deemed', 'rounding') IS NULL
BEGIN
    ALTER TABLE deal_price_deemed ADD rounding INT
END
GO
