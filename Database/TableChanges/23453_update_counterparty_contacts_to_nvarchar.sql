
IF COL_LENGTH('counterparty_contacts', 'title') IS NOT NULL
BEGIN
    ALTER TABLE counterparty_contacts ALTER COLUMN title NVARCHAR(200)
END
GO

IF COL_LENGTH('counterparty_contacts', 'name') IS NOT NULL
BEGIN
    ALTER TABLE counterparty_contacts ALTER COLUMN name NVARCHAR(200)
END
GO

IF COL_LENGTH('counterparty_contacts', 'id') IS NOT NULL
BEGIN
    ALTER TABLE counterparty_contacts ALTER COLUMN id NVARCHAR(200)
END
GO