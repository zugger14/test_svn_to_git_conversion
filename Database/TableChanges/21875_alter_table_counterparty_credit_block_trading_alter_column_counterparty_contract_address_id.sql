IF COL_LENGTH('counterparty_credit_block_trading', 'counterparty_contract_address_id') IS NULL
BEGIN
    ALTER TABLE counterparty_credit_block_trading ADD counterparty_contract_address_id INT NULL FOREIGN KEY REFERENCES counterparty_contract_address(counterparty_contract_address_id)
	PRINT 'Column counterparty_contract_address_id added on table counterparty_credit_block_trading.'
END
GO

