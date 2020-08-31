IF COL_LENGTH('source_counterparty_audit', 'counterparty_name') IS NOT NULL
BEGIN
	ALTER TABLE 
	/**
		Columns
		counterparty_name: Counterparty Name
	*/
		source_counterparty_audit ALTER COLUMN counterparty_name NVARCHAR(1000)
END
GO


IF COL_LENGTH('source_counterparty_audit', 'counterparty_desc') IS NOT NULL
BEGIN
	ALTER TABLE 
	/**
		Columns
		counterparty_desc: Counterparty Description
	*/
		source_counterparty_audit ALTER COLUMN counterparty_desc NVARCHAR(1000)
END
GO