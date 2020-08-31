
IF NOT EXISTS (SELECT 1 FROM sys.columns c INNER JOIN sys.tables t ON t.[object_id] = c.[object_id]	WHERE t.name = 'calc_formula_value_estimates'
		AND c.name = 'commodity_id')
	ALTER TABLE calc_formula_value_estimates ADD commodity_id INT
GO

IF NOT EXISTS (SELECT 1 FROM sys.columns c INNER JOIN sys.tables t ON t.[object_id] = c.[object_id]	WHERE t.name = 'calc_formula_value_estimates'
		AND c.name = 'granularity')
	ALTER TABLE calc_formula_value_estimates ADD granularity INT
GO
IF NOT EXISTS (SELECT 1 FROM sys.columns c INNER JOIN sys.tables t ON t.[object_id] = c.[object_id]	WHERE t.name = 'calc_formula_value_estimates'
		AND c.name = 'is_final_result')
	ALTER TABLE calc_formula_value_estimates ADD is_final_result CHAR(1)
GO


IF NOT EXISTS (SELECT 1 FROM sys.columns c INNER JOIN sys.tables t ON t.[object_id] = c.[object_id]	WHERE t.name = 'calc_formula_value'
		AND c.name = 'commodity_id')
	ALTER TABLE calc_formula_value ADD commodity_id INT
GO

IF NOT EXISTS (SELECT 1 FROM sys.columns c INNER JOIN sys.tables t ON t.[object_id] = c.[object_id]	WHERE t.name = 'calc_formula_value'
		AND c.name = 'granularity')
	ALTER TABLE calc_formula_value ADD granularity INT
GO
IF NOT EXISTS (SELECT 1 FROM sys.columns c INNER JOIN sys.tables t ON t.[object_id] = c.[object_id]	WHERE t.name = 'calc_formula_value'
		AND c.name = 'is_final_result')
	ALTER TABLE calc_formula_value ADD is_final_result CHAR(1)
GO




--SELECT * FROM static_data_value WHERE TYPE_ID=800 ORDER BY value_id
UPDATE dbo.static_data_value SET code='IF Condition' WHERE value_id=816

GO


ALTER TABLE calc_formula_value ALTER COLUMN formula_id INT NULL
