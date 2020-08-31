IF COL_LENGTH('deal_type_pricing_maping', 'commodity_id') IS NULL
BEGIN
    ALTER TABLE deal_type_pricing_maping ADD commodity_id INT REFERENCES source_commodity (source_commodity_id)
END
GO

IF COL_LENGTH('deal_type_pricing_maping', 'enable_cost_tab') IS NULL
BEGIN
    ALTER TABLE deal_type_pricing_maping ADD enable_cost_tab BIT DEFAULT 0
END
GO

IF COL_LENGTH('deal_type_pricing_maping', 'enable_tranches_tab') IS NULL
BEGIN
    ALTER TABLE deal_type_pricing_maping ADD enable_tranches_tab BIT DEFAULT 0
END
GO

IF COL_LENGTH('deal_type_pricing_maping', 'enable_exercise_tab') IS NULL
BEGIN
    ALTER TABLE deal_type_pricing_maping ADD enable_exercise_tab BIT DEFAULT 0
END
GO

IF COL_LENGTH('deal_type_pricing_maping', 'enable_udf_tab') IS NULL
BEGIN
    ALTER TABLE deal_type_pricing_maping ADD enable_udf_tab BIT DEFAULT 0
END
GO