IF COL_LENGTH('counterparty_credit_enhancements', 'contract_id') IS NULL
BEGIN
	ALTER TABLE counterparty_credit_enhancements ADD contract_id INT
END
GO

IF COL_LENGTH('counterparty_credit_enhancements', 'internal_counterparty_id') IS NOT NULL
BEGIN
	EXEC sp_rename 'counterparty_credit_enhancements.internal_counterparty_id', 'internal_counterparty', 'COLUMN'
END
GO

IF COL_LENGTH('counterparty_credit_enhancements', 'counterparty_id') IS NOT NULL
BEGIN
	ALTER TABLE counterparty_credit_enhancements
	DROP COLUMN counterparty_id
END