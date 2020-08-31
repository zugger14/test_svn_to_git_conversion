IF COL_LENGTH('deal_type_pricing_maping', 'formula_curve_id') IS NULL
BEGIN
    ALTER TABLE deal_type_pricing_maping ADD formula_curve_id BIT DEFAULT 0
END
GO