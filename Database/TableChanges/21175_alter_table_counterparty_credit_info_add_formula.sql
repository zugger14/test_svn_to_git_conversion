IF COL_LENGTH('counterparty_credit_info', 'formula') IS NULL
BEGIN
    ALTER TABLE counterparty_credit_info ADD formula INT NULL
END
ELSE
	PRINT('Column formula already exists.')
GO