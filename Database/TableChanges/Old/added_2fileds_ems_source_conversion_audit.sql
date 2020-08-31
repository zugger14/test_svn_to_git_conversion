IF COL_LENGTH('ems_source_conversion_audit', 'create_user') IS NULL
BEGIN
    ALTER TABLE ems_source_conversion_audit ADD [create_user] VARCHAR(50) DEFAULT dbo.FNADBUser()
END

IF COL_LENGTH('ems_source_conversion_audit', '[create_ts]') IS NULL
BEGIN
    ALTER TABLE ems_source_conversion_audit ADD [create_ts] DATETIME DEFAULT GETDATE()
END