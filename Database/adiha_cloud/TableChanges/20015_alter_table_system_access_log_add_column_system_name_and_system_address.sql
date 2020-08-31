USE adiha_cloud

IF COL_LENGTH('system_access_log', 'system_name') IS NULL
BEGIN
    ALTER TABLE system_access_log ADD system_name NVARCHAR(100)
END
GO

IF COL_LENGTH('system_access_log', 'system_address') IS NULL
BEGIN
    ALTER TABLE system_access_log ADD system_address NVARCHAR(100)
END
GO