--ADD COLUMN is_primary
IF COL_LENGTH('counterparty_credit_enhancements', 'is_primary') IS NULL
BEGIN
    ALTER TABLE dbo.counterparty_credit_enhancements 
    ADD [is_primary]  BIT DEFAULT 0
END
ELSE
BEGIN
    PRINT ' Column ''is_primary'' Already Exists!'
END 
GO

