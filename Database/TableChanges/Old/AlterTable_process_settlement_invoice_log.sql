IF COL_LENGTH('process_settlement_invoice_log', 'description') IS NOT NULL
BEGIN
    ALTER TABLE process_settlement_invoice_log ALTER COLUMN [DESCRIPTION] VARCHAR(8000)
END
GO