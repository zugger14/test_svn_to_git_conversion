IF NOT EXISTS (SELECT 1 FROM sys.[columns] AS c WHERE c.name = N'user_name' 
	AND c.[object_id] = OBJECT_ID(N'export_web_service'))
BEGIN
	ALTER TABLE export_web_service ADD [user_name] VARCHAR(50)
END

IF NOT EXISTS (SELECT 1 FROM sys.[columns] AS c WHERE c.name = N'request_param' 
	AND c.[object_id] = OBJECT_ID(N'export_web_service'))
BEGIN
	ALTER TABLE export_web_service ADD request_param VARCHAR(MAX)
END
