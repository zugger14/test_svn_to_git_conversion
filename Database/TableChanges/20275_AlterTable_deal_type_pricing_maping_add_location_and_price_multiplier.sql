IF COL_LENGTH('deal_type_pricing_maping', 'location_id') IS NULL
BEGIN
    ALTER TABLE deal_type_pricing_maping ADD location_id BIT DEFAULT 0
END
GO

IF COL_LENGTH('deal_type_pricing_maping', 'price_multiplier') IS NULL
BEGIN
    ALTER TABLE deal_type_pricing_maping ADD price_multiplier BIT DEFAULT 0
END
GO