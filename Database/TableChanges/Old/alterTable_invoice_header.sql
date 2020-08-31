IF COL_LENGTH('invoice_header', 'contract_id') IS NULL
BEGIN
    ALTER TABLE invoice_header ADD contract_id INT
END
GO