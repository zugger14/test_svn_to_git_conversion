IF EXISTS (SELECT 1 FROM sys.indexes i INNER JOIN sys.objects AS o ON o.[object_id] = i.[object_id] WHERE o.name = 'source_minor_location_meter' AND i.name = 'IX_source_minor_location_meter')
BEGIN
	DROP INDEX [IX_source_minor_location_meter] ON [dbo].[source_minor_location_meter]	
END	

IF NOT EXISTS (SELECT 1 FROM sys.indexes i INNER JOIN sys.objects AS o ON o.[object_id] = i.[object_id] WHERE o.name = 'source_minor_location_meter' AND i.name = 'IX_source_minor_location_meter')
BEGIN
	CREATE UNIQUE NONCLUSTERED INDEX [IX_source_minor_location_meter]  ON dbo.[source_minor_location_meter](meter_id)	
END