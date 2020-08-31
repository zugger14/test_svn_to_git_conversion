IF COL_LENGTH('counterparty_contacts', 'address1') IS NOT NULL
BEGIN
	ALTER TABLE 
	/**
		Columns
		address1: Address1
	*/
		counterparty_contacts ALTER COLUMN address1 NVARCHAR(1000)
END
GO

IF COL_LENGTH('counterparty_contacts', 'address2') IS NOT NULL
BEGIN
	ALTER TABLE 
	/**
		Columns
		address1: Address2
	*/
		counterparty_contacts ALTER COLUMN address2 NVARCHAR(1000)
END
GO
