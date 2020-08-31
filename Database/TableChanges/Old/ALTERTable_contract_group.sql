IF NOT EXISTS (
	SELECT 1 FROM sys.columns c
	INNER JOIN sys.tables t ON t.[object_id] = c.[object_id]
	WHERE t.name = 'contract_group'
		AND c.name = 'billing_from_hour'
)
	ALTER TABLE contract_group ADD billing_from_hour INT
GO

IF NOT EXISTS (
	SELECT 1 FROM sys.columns c
	INNER JOIN sys.tables t ON t.[object_id] = c.[object_id]
	WHERE t.name = 'contract_group'
		AND c.name = 'billing_to_hour'
)
	ALTER TABLE contract_group ADD billing_to_hour INT


IF NOT EXISTS (
	SELECT 1 FROM sys.columns c
	INNER JOIN sys.tables t ON t.[object_id] = c.[object_id]
	WHERE t.name = 'contract_group'
		AND c.name = 'block_type'
)
	ALTER TABLE contract_group ADD block_type INT
GO

IF NOT EXISTS (
	SELECT 1 FROM sys.columns c
	INNER JOIN sys.tables t ON t.[object_id] = c.[object_id]
	WHERE t.name = 'calc_formula_value'
		AND c.name = 'volume'
)
	ALTER TABLE calc_formula_value ADD volume FLOAT
GO

IF NOT EXISTS (
	SELECT 1 FROM sys.columns c
	INNER JOIN sys.tables t ON t.[object_id] = c.[object_id]
	WHERE t.name = 'calc_formula_value'
		AND c.name = 'formula_str_eval'
)
	ALTER TABLE calc_formula_value ADD formula_str_eval VARCHAR(2000)

GO

IF NOT EXISTS (
	SELECT 1 FROM sys.columns c
	INNER JOIN sys.tables t ON t.[object_id] = c.[object_id]
	WHERE t.name = 'contract_group_detail'
		AND c.name = 'time_bucket_formula_id'
)
	ALTER TABLE contract_group_detail ADD time_bucket_formula_id INT
GO