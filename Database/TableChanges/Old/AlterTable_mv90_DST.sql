IF EXISTS(
SELECT 1 FROM sys.columns c
	INNER JOIN sys.tables t ON t.[object_id] = c.[object_id]
	WHERE t.name = 'mv90_DST'
		AND c.name = 'hour'
)
	ALTER TABLE mv90_DST ALTER COLUMN hour tinyint

