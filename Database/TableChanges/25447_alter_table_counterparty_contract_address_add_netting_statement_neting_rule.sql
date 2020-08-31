/* Added new column in table counterparty_contract_address:
	netting_statement, neting_rule
*/

IF COL_LENGTH('counterparty_contract_address', 'netting_statement') IS NULL
BEGIN
	ALTER TABLE counterparty_contract_address ADD netting_statement NCHAR(1)
END

IF COL_LENGTH('counterparty_contract_address', 'neting_rule') IS NULL
BEGIN
	ALTER TABLE counterparty_contract_address ADD neting_rule NCHAR(1)
END





