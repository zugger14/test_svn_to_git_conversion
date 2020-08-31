
IF COL_LENGTH('counterparty_contract_address', 'amendment_date') IS NULL
BEGIN
ALTER TABLE counterparty_contract_address ADD amendment_date DATETIME
END
ELSE
BEGIN
	PRINT 'Column amendment_date EXISTS'
END

IF COL_LENGTH('counterparty_contract_address', 'amendment_description') IS NULL
BEGIN
ALTER TABLE counterparty_contract_address ADD amendment_description NVARCHAR(1000)
END
ELSE
BEGIN
	PRINT 'Column amendment_description EXISTS'
END

IF COL_LENGTH('counterparty_contract_address', 'external_counterparty_id') IS NULL
BEGIN
ALTER TABLE counterparty_contract_address ADD external_counterparty_id NVARCHAR(500)
END
ELSE
BEGIN
	PRINT 'Column external_counterparty_id EXISTS'
END

IF COL_LENGTH('counterparty_contract_address', 'description') IS NULL
BEGIN
ALTER TABLE counterparty_contract_address ADD description NVARCHAR(500)
END
ELSE
BEGIN
	PRINT 'Column description EXISTS'
END

