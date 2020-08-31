IF COL_LENGTH('source_counterparty', 'payables') IS NULL
BEGIN
    ALTER TABLE source_counterparty ADD payables INT
END
GO
IF COL_LENGTH('source_counterparty', 'receivables') IS NULL
BEGIN
    ALTER TABLE source_counterparty ADD receivables INT
END
GO
IF COL_LENGTH('source_counterparty', 'confirmation') IS NULL
BEGIN
    ALTER TABLE source_counterparty ADD confirmation INT
END
GO

