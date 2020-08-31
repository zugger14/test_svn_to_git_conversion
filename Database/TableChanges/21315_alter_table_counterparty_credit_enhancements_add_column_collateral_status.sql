IF COL_LENGTH('counterparty_credit_enhancements', 'collateral_status') IS NULL
BEGIN
    ALTER TABLE counterparty_credit_enhancements ADD collateral_status INT NULL
END
ELSE
	PRINT('Column collateral_status already exists.')
GO