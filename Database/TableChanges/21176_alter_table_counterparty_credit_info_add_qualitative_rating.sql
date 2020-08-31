IF COL_LENGTH('counterparty_credit_info', 'qualitative_rating') IS NULL
BEGIN
    ALTER TABLE counterparty_credit_info ADD qualitative_rating INT NULL
END
ELSE
	PRINT('Column qualitative_rating already exists.')
GO