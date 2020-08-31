IF COL_LENGTH('master_view_counterparty_contacts', 'address1') IS NOT NULL
BEGIN
	ALTER TABLE 
	/**
		Columns
		address1: Address
	*/
		master_view_counterparty_contacts ALTER COLUMN address1 NVARCHAR(1000)
END
GO

IF COL_LENGTH('master_view_counterparty_contacts', 'address2') IS NOT NULL
BEGIN
	ALTER TABLE 
	/**
		Columns
		address2:  Address
	*/
		master_view_counterparty_contacts ALTER COLUMN address2 NVARCHAR(1000)
END
GO
