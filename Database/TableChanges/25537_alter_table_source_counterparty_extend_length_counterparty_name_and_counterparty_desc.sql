if OBJECT_ID(N'dbo.VW_counterparty_certificate', N'V') is not null 
/**
DROP View due to schema binding column counterparty_name
*/
drop view dbo.VW_counterparty_certificate

IF COL_LENGTH('source_counterparty', 'counterparty_name') IS NOT NULL
BEGIN
	ALTER TABLE 
	/**
		Columns
		counterparty_name: Counterparty Name
	*/
		source_counterparty ALTER COLUMN counterparty_name NVARCHAR(1000)
END
GO


IF COL_LENGTH('source_counterparty', 'counterparty_desc') IS NOT NULL
BEGIN
	ALTER TABLE 
	/**
		Columns
		counterparty_desc: Counterparty Description
	*/
		source_counterparty ALTER COLUMN counterparty_desc NVARCHAR(1000)
END
GO