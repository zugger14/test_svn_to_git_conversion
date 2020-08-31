IF COL_LENGTH('deal_type_pricing_maping', 'block_define_id') IS NULL
BEGIN
    ALTER TABLE deal_type_pricing_maping ADD block_define_id BIT
END
GO

IF COL_LENGTH('deal_type_pricing_maping', 'settlement_currency') IS NULL
BEGIN
    ALTER TABLE deal_type_pricing_maping ADD settlement_currency BIT
END
GO

IF COL_LENGTH('deal_type_pricing_maping', 'settlement_date') IS NULL
BEGIN
    ALTER TABLE deal_type_pricing_maping ADD settlement_date BIT
END
GO

IF COL_LENGTH('deal_type_pricing_maping', 'fx_conversion_rate') IS NULL
BEGIN
    ALTER TABLE deal_type_pricing_maping ADD fx_conversion_rate BIT
END
GO

IF COL_LENGTH('deal_type_pricing_maping', 'cycle') IS NULL
BEGIN
    ALTER TABLE deal_type_pricing_maping ADD cycle BIT
END
GO

IF COL_LENGTH('deal_type_pricing_maping', 'upstream_counterparty') IS NULL
BEGIN
    ALTER TABLE deal_type_pricing_maping ADD upstream_counterparty BIT
END
GO

IF COL_LENGTH('deal_type_pricing_maping', 'upstream_contract') IS NULL
BEGIN
    ALTER TABLE deal_type_pricing_maping ADD upstream_contract BIT
END
GO

IF COL_LENGTH('deal_type_pricing_maping', 'enable_certificate') IS NULL
BEGIN
    ALTER TABLE deal_type_pricing_maping ADD enable_certificate BIT
END
GO