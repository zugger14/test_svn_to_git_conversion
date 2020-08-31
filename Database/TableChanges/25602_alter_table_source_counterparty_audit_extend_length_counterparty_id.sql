IF COL_LENGTH('source_counterparty_audit', 'counterparty_id') IS NOT NULL
BEGIN
	ALTER TABLE 
	/**
		Columns
		counterparty_id: Counterparty ID
	*/
		source_counterparty_audit ALTER COLUMN counterparty_id NVARCHAR(1000)
END
GO