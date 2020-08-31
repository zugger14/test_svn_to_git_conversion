IF NOT EXISTS (SELECT 1 FROM sys.[columns] AS c WHERE c.name = N'certificate_entity' 
	AND c.[object_id] = OBJECT_ID(N'export_web_service'))
BEGIN
	ALTER TABLE export_web_service ADD certificate_entity INT
END

UPDATE static_data_type SET internal =0 WHERE [type_id] = 10011

