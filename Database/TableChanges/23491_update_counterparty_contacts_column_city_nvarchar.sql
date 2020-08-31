IF COL_LENGTH('counterparty_contacts', 'city') IS NOT NULL
BEGIN
    ALTER TABLE counterparty_contacts ALTER COLUMN city nvarchar(100)
END
GO
