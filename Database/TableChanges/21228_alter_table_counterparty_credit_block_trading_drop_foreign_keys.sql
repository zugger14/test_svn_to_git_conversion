IF EXISTS ( SELECT 1 
			FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS 
			WHERE CONSTRAINT_TYPE = 'Foreign KEY' 
			AND TABLE_NAME = 'counterparty_credit_block_trading' 
			AND TABLE_SCHEMA ='dbo'
			AND CONSTRAINT_NAME = 'FK_counterparty_credit_block_trading_counterparty_credit_info' )
BEGIN
   ALTER TABLE dbo.counterparty_credit_block_trading DROP CONSTRAINT [FK_counterparty_credit_block_trading_counterparty_credit_info]
END


IF EXISTS ( SELECT 1 
			FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS 
			WHERE CONSTRAINT_TYPE = 'Foreign KEY' 
			AND TABLE_NAME = 'counterparty_credit_block_trading' 
			AND TABLE_SCHEMA ='dbo'
			AND CONSTRAINT_NAME = 'FK_counterparty_credit_block_trading_source_commodity' )
BEGIN
   ALTER TABLE dbo.counterparty_credit_block_trading DROP CONSTRAINT [FK_counterparty_credit_block_trading_source_commodity]
END


IF EXISTS ( SELECT 1 
			FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS 
			WHERE CONSTRAINT_TYPE = 'Foreign KEY' 
			AND TABLE_NAME = 'counterparty_credit_block_trading' 
			AND TABLE_SCHEMA ='dbo'
			AND CONSTRAINT_NAME = 'FK_counterparty_credit_block_trading_source_deal_type' )
BEGIN
   ALTER TABLE dbo.counterparty_credit_block_trading DROP CONSTRAINT [FK_counterparty_credit_block_trading_source_deal_type]
END
