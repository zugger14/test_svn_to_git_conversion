IF NOT EXISTS (SELECT 1 FROM sys.[columns] AS c WHERE c.name = N'broker_relevant' AND c.[object_id] = OBJECT_ID(N'source_counterparty'))
BEGIN
	ALTER TABLE source_counterparty ADD broker_relevant CHAR(1) 
END