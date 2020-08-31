IF COL_LENGTH('counterparty_contacts', 'address1') IS NOT NULL
BEGIN
    ALTER TABLE counterparty_contacts ALTER COLUMN address1 nvarchar(100)
END
GO


IF COL_LENGTH('counterparty_contacts', 'address2') IS NOT NULL
BEGIN
    ALTER TABLE counterparty_contacts ALTER COLUMN address2 nvarchar(100)
END
GO

