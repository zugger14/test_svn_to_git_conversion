IF COL_LENGTH('source_counterparty', 'region') IS NULL
BEGIN
    ALTER TABLE source_counterparty ADD region INT
END
GO