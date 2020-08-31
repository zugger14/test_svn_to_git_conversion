IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS WHERE CONSTRAINT_NAME='UC_counterparty_credit_block_trading')
BEGIN  
	ALTER TABLE dbo.counterparty_credit_block_trading
	ADD CONSTRAINT UC_counterparty_credit_block_trading UNIQUE (counterparty_id, internal_counterparty_id, [contract], comodity_id, deal_type_id, template_id) 
END