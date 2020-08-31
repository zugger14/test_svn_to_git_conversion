IF COL_LENGTH('counterparty_credit_info', 'analyst') IS NOT NULL
BEGIN
	ALTER TABLE counterparty_credit_info
	ALTER COLUMN analyst VARCHAR(200) NULL
	PRINT('Column analyst updated.')
END
ELSE
BEGIN
    ALTER TABLE counterparty_credit_info ADD analyst VARCHAR(200) NULL
    PRINT('Column analyst added.')
END
 