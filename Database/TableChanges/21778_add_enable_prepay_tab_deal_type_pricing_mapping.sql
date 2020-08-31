IF COL_LENGTH('deal_type_pricing_maping', 'enable_prepay_tab') IS NULL
BEGIN
    ALTER TABLE deal_type_pricing_maping ADD enable_prepay_tab BIT DEFAULT 0
END
GO