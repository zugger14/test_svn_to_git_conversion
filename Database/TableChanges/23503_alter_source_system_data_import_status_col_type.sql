IF COL_LENGTH('source_system_data_import_status_detail', 'description') IS NOT NULL
BEGIN
    ALTER TABLE source_system_data_import_status_detail ALTER COLUMN [description] NVARCHAR(MAX)
END
GO


IF COL_LENGTH('source_system_data_import_status', 'description') IS NOT NULL
BEGIN
    ALTER TABLE source_system_data_import_status ALTER COLUMN [description] NVARCHAR(MAX)
END
GO
 
IF COL_LENGTH('source_system_data_import_status', 'recommendation') IS NOT NULL
BEGIN
    ALTER TABLE source_system_data_import_status ALTER COLUMN [recommendation] NVARCHAR(500)
END
GO
  
IF COL_LENGTH('source_system_data_import_status', 'source') IS NOT NULL
BEGIN
    ALTER TABLE source_system_data_import_status ALTER COLUMN [source] NVARCHAR(250)
END
GO