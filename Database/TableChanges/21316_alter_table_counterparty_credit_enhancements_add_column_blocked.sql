IF COL_LENGTH('counterparty_credit_enhancements', 'blocked') IS NULL
BEGIN
    ALTER TABLE counterparty_credit_enhancements ADD blocked CHAR(1) NULL
END
ELSE
	PRINT('Column blocked already exists.')
GO