IF NOT EXISTS (SELECT 1 FROM sys.[columns] AS c WHERE c.name = N'code_value' AND c.[object_id] = OBJECT_ID(N'state_properties_bonus'))
BEGIN
	ALTER TABLE state_properties_bonus ADD code_value INT 
END

IF NOT EXISTS (SELECT 1 FROM sys.[columns] AS c WHERE c.name = N'code_value' AND c.[object_id] = OBJECT_ID(N'state_properties_duration'))
BEGIN
	ALTER TABLE state_properties_duration ADD code_value INT
END

