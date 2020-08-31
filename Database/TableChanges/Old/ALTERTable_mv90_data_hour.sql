IF NOT EXISTS (
	SELECT 1 FROM sys.columns c
	INNER JOIN sys.tables t ON t.[object_id] = c.[object_id]
	WHERE t.name = 'mv90_data_hour'
		AND c.name = 'Hr25'
)
	ALTER TABLE mv90_data_hour ADD Hr25 FLOAT
GO

