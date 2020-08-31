IF COL_LENGTH('counterparty_contract_address', 'billing_start_month') IS NULL
BEGIN
    ALTER TABLE counterparty_contract_address ADD billing_start_month INT
END
GO