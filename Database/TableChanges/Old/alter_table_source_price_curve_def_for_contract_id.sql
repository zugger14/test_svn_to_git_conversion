IF COL_LENGTH('source_price_curve_def', 'contract_id') IS NULL
BEGIN
    ALTER TABLE source_price_curve_def ADD contract_id INT NULL
END
GO