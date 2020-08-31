IF NOT EXISTS (SELECT 1 FROM sys.[columns] AS c WHERE c.name = N'is_enable' AND c.[object_id] = OBJECT_ID(N'static_data_privilege'))
BEGIN
	ALTER TABLE static_data_privilege ADD is_enable INT NOT NULL DEFAULT 1
END
