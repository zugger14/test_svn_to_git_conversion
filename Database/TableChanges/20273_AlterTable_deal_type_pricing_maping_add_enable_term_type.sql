IF COL_LENGTH('deal_type_pricing_maping', 'enable_term_type') IS NULL
BEGIN
    ALTER TABLE deal_type_pricing_maping ADD enable_term_type BIT DEFAULT 0
END
GO