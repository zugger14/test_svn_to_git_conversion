IF COL_LENGTH('source_counterparty', 'contact_email') IS NOT NULL
BEGIN
    ALTER TABLE source_counterparty ALTER COLUMN contact_email VARCHAR(8000)
END
GO