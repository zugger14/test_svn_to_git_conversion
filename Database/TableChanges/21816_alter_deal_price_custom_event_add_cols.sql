IF COL_LENGTH('deal_price_custom_event', 'rounding') IS NULL 
BEGIN
    ALTER TABLE deal_price_custom_event ADD rounding INT
END
GO
