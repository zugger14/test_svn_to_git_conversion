IF COL_LENGTH('incident_log', 'contract') IS NULL
BEGIN
	ALTER TABLE incident_log 
	ADD contract INT NULL
END
ELSE 
	PRINT('Column contract already exists')	
GO