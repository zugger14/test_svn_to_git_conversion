IF COL_LENGTH('incident_log', 'counterparty') IS NULL
BEGIN
	ALTER TABLE incident_log 
	ADD counterparty INT NULL
END
ELSE 
	PRINT('Column counterparty already exists')	
GO


IF COL_LENGTH('incident_log', 'internal_counterparty') IS NULL
BEGIN
	ALTER TABLE incident_log 
	ADD internal_counterparty INT NULL
END
ELSE 
	PRINT('Column internal_counterparty already exists')	
GO

 