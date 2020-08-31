IF NOT EXISTS(SELECT 'x' FROM sys.tables t inner join sys.columns c on t.object_id = c.object_id WHERE t.name = 'application_notes'
AND c.name = 'source_system_id')
ALTER TABLE application_notes ADD source_system_id INT



