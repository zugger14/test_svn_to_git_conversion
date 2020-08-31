IF EXISTS(SELECT 1 FROM counterparty_credit_block_trading WHERE counterparty_contract_address_id IS NULL)
BEGIN
	UPDATE ccbt set  ccbt.counterparty_contract_address_id = cca.counterparty_contract_address_id FROM counterparty_credit_block_trading ccbt INNER JOIN 
	counterparty_contract_address cca ON cca.contract_id = ccbt.contract AND cca.counterparty_id = ccbt.counterparty_id AND cca.internal_counterparty_id = ccbt.internal_counterparty_id WHERE  ccbt.counterparty_contract_address_id IS NULL
END

