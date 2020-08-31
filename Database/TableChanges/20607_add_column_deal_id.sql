IF COL_LENGTH('counterparty_credit_enhancements', 'deal_id') IS NULL
BEGIN
    ALTER TABLE counterparty_credit_enhancements ADD deal_id VARCHAR(50)
END
GO