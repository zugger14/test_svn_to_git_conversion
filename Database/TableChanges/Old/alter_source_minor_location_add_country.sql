IF NOT EXISTS(SELECT 'x' FROM sys.tables t INNER JOIN sys.[columns] c ON t.[object_id] = c.[object_id]
              WHERE t.[name] = 'source_minor_location' AND c.[name] = 'country') 
ALTER TABLE dbo.source_minor_location ADD country INT 

GO
--
IF  EXISTS(SELECT 'x' FROM sys.tables t INNER JOIN sys.[columns] c ON t.[object_id] = c.[object_id]
              WHERE t.[name] = 'source_minor_location' AND c.[name] = 'country_id') 
ALTER TABLE dbo.source_minor_location DROP COLUMN country_id
