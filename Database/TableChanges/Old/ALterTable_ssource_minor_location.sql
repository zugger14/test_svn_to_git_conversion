IF NOT EXISTS (
	SELECT 1 FROM sys.columns c
	INNER JOIN sys.tables t ON t.[object_id] = c.[object_id]
	WHERE t.name = 'source_minor_location'
		AND c.name = 'grid_value_id'
)
	ALTER TABLE source_minor_location ADD grid_value_id INT
GO

