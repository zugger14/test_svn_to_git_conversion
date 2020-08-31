
IF COL_LENGTH('master_view_counterparty_contacts', 'counterparty_name') IS NOT NULL
BEGIN
	ALTER TABLE 
	/**
		Columns
		counterparty_name: Counterparty Name
	*/
		master_view_counterparty_contacts ALTER COLUMN counterparty_name NVARCHAR(1000)
END
GO
