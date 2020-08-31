
IF NOT EXISTS (SELECT 1 FROM sys.columns c INNER JOIN sys.tables t ON t.[object_id] = c.[object_id]	WHERE t.name = 'source_deal_detail'
		AND c.name = 'formula_curve_id')
	ALTER TABLE source_deal_detail ADD formula_curve_id INT
GO

