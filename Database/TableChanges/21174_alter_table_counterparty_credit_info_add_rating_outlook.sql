IF COL_LENGTH('counterparty_credit_info', 'rating_outlook') IS NULL
BEGIN
    ALTER TABLE counterparty_credit_info ADD rating_outlook INT NULL
END
ELSE
	PRINT('Column rating_outlook already exists.')
GO