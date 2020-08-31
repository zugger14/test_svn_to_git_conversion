IF COL_LENGTH('counterparty_credit_info', 'analyst') IS NULL
BEGIN
    ALTER TABLE counterparty_credit_info ADD analyst INT NULL
END
ELSE
	PRINT('Column analyst already exists.')
GO