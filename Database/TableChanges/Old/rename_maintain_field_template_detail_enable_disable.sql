IF EXISTS(SELECT 'x' FROM sys.[columns] c INNER JOIN sys.tables t ON c.[object_id] = t.[object_id]
          WHERE t.[name] = 'maintain_field_template_detail' AND c.[name] = 'enable_disable')
exec sp_rename 'maintain_field_template_detail.enable_disable','is_disable','COLUMN'