IF NOT EXISTS (
	SELECT 1 FROM sys.columns c
	INNER JOIN sys.tables t ON t.[object_id] = c.[object_id]
	WHERE t.name = 'forecast_profile'
		AND c.name = 'profile_name'
)
ALTER TABLE forecast_profile ADD profile_name VARCHAR(50)