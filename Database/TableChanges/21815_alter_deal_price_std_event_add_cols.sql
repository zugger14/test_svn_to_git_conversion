IF COL_LENGTH('deal_price_std_event', 'rounding') IS NULL
BEGIN
    ALTER TABLE deal_price_std_event ADD rounding INT
END
GO
