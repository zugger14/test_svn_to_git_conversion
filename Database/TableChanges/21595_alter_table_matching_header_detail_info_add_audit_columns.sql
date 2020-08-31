IF COL_LENGTH('matching_header_detail_info', 'create_ts') IS NULL
BEGIN
ALTER TABLE dbo.matching_header_detail_info ADD create_ts DATETIME NULL DEFAULT GETDATE()
END
GO
IF COL_LENGTH('matching_header_detail_info', 'create_user') IS NULL
BEGIN
ALTER TABLE dbo.matching_header_detail_info ADD create_user VARCHAR(50) NULL DEFAULT dbo.FNADBUser()
END
GO
IF COL_LENGTH('matching_header_detail_info', 'update_ts') IS NULL
BEGIN
ALTER TABLE dbo.matching_header_detail_info ADD [update_ts] DATETIME NULL
END
GO
IF COL_LENGTH('matching_header_detail_info', 'update_user') IS NULL
BEGIN
ALTER TABLE dbo.matching_header_detail_info ADD [update_user] VARCHAR(50) NULL
END
GO