IF NOT EXISTS (SELECT 1 FROM sys.[columns] AS c WHERE c.name = N'counterparty_contact_notes' AND c.[object_id] = OBJECT_ID(N'source_counterparty'))
BEGIN
	ALTER TABLE source_counterparty ADD counterparty_contact_notes VARCHAR(200) 
END
