
IF NOT EXISTS (SELECT 1 FROM sys.columns c INNER JOIN sys.tables t ON t.[object_id] = c.[object_id]	WHERE t.name = 'sap_trm_mapping'
		AND c.name = 'map_type')
	ALTER TABLE sap_trm_mapping ADD map_type VARCHAR(100)

IF NOT EXISTS (SELECT 1 FROM sys.columns c INNER JOIN sys.tables t ON t.[object_id] = c.[object_id]	WHERE t.name = 'sap_trm_mapping'
		AND c.name = 'location_id')
	ALTER TABLE sap_trm_mapping ADD location_id INT

IF NOT EXISTS (SELECT 1 FROM sys.columns c INNER JOIN sys.tables t ON t.[object_id] = c.[object_id]	WHERE t.name = 'sap_trm_mapping'
		AND c.name = 'type_id')
	ALTER TABLE sap_trm_mapping ADD type_id INT

GO

