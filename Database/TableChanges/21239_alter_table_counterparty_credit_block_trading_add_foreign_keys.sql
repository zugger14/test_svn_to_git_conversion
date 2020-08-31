IF NOT EXISTS (SELECT 1 
			FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS 
			WHERE CONSTRAINT_TYPE = 'Foreign KEY' 
			AND TABLE_NAME = 'counterparty_credit_block_trading' 
			AND TABLE_SCHEMA ='dbo'
			AND CONSTRAINT_NAME = 'FK_counterparty_credit_block_trading_counterparty_credit_info')
BEGIN    
	ALTER TABLE [dbo].[counterparty_credit_block_trading]  WITH CHECK 
	ADD  CONSTRAINT [FK_counterparty_credit_block_trading_counterparty_credit_info] 
	FOREIGN KEY([counterparty_credit_info_id])
	REFERENCES [dbo].[counterparty_credit_info] ([counterparty_credit_info_id])

	ALTER TABLE [dbo].[counterparty_credit_block_trading] 
	CHECK CONSTRAINT [FK_counterparty_credit_block_trading_counterparty_credit_info] 
END


IF NOT EXISTS (SELECT 1 
			FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS 
			WHERE CONSTRAINT_TYPE = 'Foreign KEY' 
			AND TABLE_NAME = 'counterparty_credit_block_trading' 
			AND TABLE_SCHEMA ='dbo'
			AND CONSTRAINT_NAME = 'FK_counterparty_credit_block_trading_source_commodity')
BEGIN   
	ALTER TABLE [dbo].[counterparty_credit_block_trading]  WITH CHECK 
	ADD  CONSTRAINT [FK_counterparty_credit_block_trading_source_commodity] 
	FOREIGN KEY([comodity_id])
	REFERENCES [dbo].[source_commodity] ([source_commodity_id]) 

	ALTER TABLE [dbo].[counterparty_credit_block_trading] 
	CHECK CONSTRAINT [FK_counterparty_credit_block_trading_source_commodity]
END


IF NOT EXISTS (SELECT 1 
			FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS 
			WHERE CONSTRAINT_TYPE = 'Foreign KEY' 
			AND TABLE_NAME = 'counterparty_credit_block_trading' 
			AND TABLE_SCHEMA ='dbo'
			AND CONSTRAINT_NAME = 'FK_counterparty_credit_block_trading_source_deal_type')
BEGIN   
	ALTER TABLE [dbo].[counterparty_credit_block_trading]  WITH CHECK 
	ADD  CONSTRAINT [FK_counterparty_credit_block_trading_source_deal_type] 
	FOREIGN KEY([deal_type_id])
	REFERENCES [dbo].[source_deal_type] ([source_deal_type_id])

	ALTER TABLE [dbo].[counterparty_credit_block_trading] 
	CHECK CONSTRAINT [FK_counterparty_credit_block_trading_source_deal_type]
END
