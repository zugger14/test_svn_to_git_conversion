IF NOT EXISTS (
	SELECT 1 FROM sys.columns c
	INNER JOIN sys.tables t ON t.[object_id] = c.[object_id]
	WHERE t.name = 'source_price_curve_def'
		AND c.name = 'proxy_curve_id'
)
	ALTER TABLE source_price_curve_def ADD proxy_curve_id INT
GO

