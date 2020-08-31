IF EXISTS(SELECT 'x' FROM sys.[columns] c INNER JOIN sys.tables t ON t.[object_id] = c.[object_id]
          WHERE t.[name] = 'user_defined_deal_fields_template' AND c.[name] = 'template_id')
ALTER TABLE user_defined_deal_fields_template ALTER COLUMN template_id INT NULL 