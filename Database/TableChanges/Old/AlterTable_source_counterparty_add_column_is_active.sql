IF COL_LENGTH('source_counterparty', 'is_active') IS NULL
BEGIN
    ALTER TABLE source_counterparty ADD is_active CHAR(1)
END
GO
