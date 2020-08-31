-- Added generic_obj_id column for maintaining primary key for multiple table like deal, links, counterparty
IF NOT EXISTS (SELECT 1 FROM sys.[columns] AS c WHERE c.name = N'generic_obj_id' 
	AND c.[object_id] = OBJECT_ID(N'remote_service_response_log'))
BEGIN
	ALTER TABLE remote_service_response_log ADD generic_obj_id INT
END