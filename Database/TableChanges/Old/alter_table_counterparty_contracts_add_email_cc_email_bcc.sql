IF COL_LENGTH('counterparty_contacts', 'email_cc') IS NULL
BEGIN
    ALTER TABLE counterparty_contacts ADD email_cc VARCHAR(100)
END
ELSE
BEGIN
	ALTER TABLE counterparty_contacts ALTER COLUMN email_cc VARCHAR(100)
END
GO

IF COL_LENGTH('counterparty_contacts', 'email_bcc') IS NULL
BEGIN
    ALTER TABLE counterparty_contacts ADD email_bcc VARCHAR(100)
END
ELSE
BEGIN
	ALTER TABLE counterparty_contacts ALTER COLUMN email_bcc VARCHAR(100)
END
GO