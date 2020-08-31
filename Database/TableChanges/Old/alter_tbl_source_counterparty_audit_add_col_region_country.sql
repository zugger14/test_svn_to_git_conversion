IF COL_LENGTH('source_counterparty_audit', 'country') IS NULL
BEGIN
    ALTER TABLE source_counterparty_audit ADD [country] INT
END
GO

IF COL_LENGTH('source_counterparty_audit', 'region') IS NULL
BEGIN
    ALTER TABLE source_counterparty_audit ADD [region] INT
END
GO

IF COL_LENGTH('source_counterparty_audit', 'tax_id') IS NOT NULL
BEGIN
    ALTER TABLE source_counterparty_audit ALTER COLUMN [tax_id] VARCHAR(500)
END
GO