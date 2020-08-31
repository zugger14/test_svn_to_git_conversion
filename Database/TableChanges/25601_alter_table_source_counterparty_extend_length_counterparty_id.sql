
IF COL_LENGTH('source_counterparty', 'counterparty_id') IS NOT NULL
BEGIN
	ALTER TABLE 
	/**
		Columns
		counterparty_id: Counterparty ID
	*/
		source_counterparty ALTER COLUMN counterparty_id NVARCHAR(1000)
END
GO


