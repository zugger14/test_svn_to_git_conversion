IF COL_LENGTH('counterparty_credit_block_trading', 'counterparty_contract_address_id') IS NOT NULL
BEGIN
	ALTER TABLE counterparty_credit_block_trading 
	ALTER COLUMN counterparty_contract_address_id INT NOT NULL;
END

--select top 1 * from counterparty_credit_block_trading
--select top 1 * from counterparty_contract_address

