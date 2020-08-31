
IF NOT EXISTS (SELECT 1 FROM sys.columns c INNER JOIN sys.tables t ON t.[object_id] = c.[object_id]	WHERE t.name = 'SOURCE_DEAL_PNL'
		AND c.name = 'dis_market_value')
	ALTER TABLE SOURCE_DEAL_PNL ADD dis_market_value float
GO


IF NOT EXISTS (SELECT 1 FROM sys.columns c INNER JOIN sys.tables t ON t.[object_id] = c.[object_id]	WHERE t.name = 'SOURCE_DEAL_PNL'
		AND c.name = 'dis_contract_value')
	ALTER TABLE SOURCE_DEAL_PNL ADD dis_contract_value float
GO


IF NOT EXISTS (SELECT 1 FROM sys.columns c INNER JOIN sys.tables t ON t.[object_id] = c.[object_id]	WHERE t.name = 'SOURCE_DEAL_PNL_DETAIL'
		AND c.name = 'market_value')
	ALTER TABLE SOURCE_DEAL_PNL_DETAIL ADD market_value float
GO


IF NOT EXISTS (SELECT 1 FROM sys.columns c INNER JOIN sys.tables t ON t.[object_id] = c.[object_id]	WHERE t.name = 'SOURCE_DEAL_PNL_DETAIL'
		AND c.name = 'contract_value')
	ALTER TABLE SOURCE_DEAL_PNL_DETAIL ADD contract_value float
GO

IF NOT EXISTS (SELECT 1 FROM sys.columns c INNER JOIN sys.tables t ON t.[object_id] = c.[object_id]	WHERE t.name = 'SOURCE_DEAL_PNL_DETAIL'
		AND c.name = 'dis_market_value')
	ALTER TABLE SOURCE_DEAL_PNL_DETAIL ADD dis_market_value float
GO


IF NOT EXISTS (SELECT 1 FROM sys.columns c INNER JOIN sys.tables t ON t.[object_id] = c.[object_id]	WHERE t.name = 'SOURCE_DEAL_PNL_DETAIL'
		AND c.name = 'dis_contract_value')
	ALTER TABLE SOURCE_DEAL_PNL_DETAIL ADD dis_contract_value float
GO


