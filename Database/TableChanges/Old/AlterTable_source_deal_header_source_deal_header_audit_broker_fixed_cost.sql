IF COL_LENGTH('source_deal_header', 'broker_fixed_cost') IS NOT NULL
BEGIN
    ALTER TABLE source_deal_header ALTER COLUMN broker_fixed_cost NUMERIC(38,20)
END
GO

IF COL_LENGTH('source_deal_header_audit', 'broker_fixed_cost') IS NOT NULL
BEGIN
    ALTER TABLE source_deal_header_audit ALTER COLUMN broker_fixed_cost NUMERIC(38,20)
END
GO