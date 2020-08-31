IF COL_LENGTH('deal_type_pricing_maping', 'enable_efp') IS NULL
BEGIN
    ALTER TABLE deal_type_pricing_maping ADD enable_efp BIT DEFAULT 0
END
GO

IF COL_LENGTH('deal_type_pricing_maping', 'enable_trigger') IS NULL
BEGIN
    ALTER TABLE deal_type_pricing_maping ADD enable_trigger BIT DEFAULT 0
END
GO