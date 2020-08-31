
IF COL_LENGTH('contract_group', 'payment_days') IS NULL
BEGIN
    ALTER TABLE contract_group ADD payment_days INT
END
GO


IF COL_LENGTH('contract_group', 'settlement_days') IS NULL
BEGIN
    ALTER TABLE contract_group ADD settlement_days INT
END
GO



