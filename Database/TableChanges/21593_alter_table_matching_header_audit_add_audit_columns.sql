IF COL_LENGTH('matching_header_audit', 'update_user') IS NULL
BEGIN
ALTER TABLE dbo.matching_header_audit ADD [update_user] VARCHAR(50) NULL
END
GO
IF COL_LENGTH('matching_header_audit', 'update_ts') IS NULL
BEGIN
ALTER TABLE dbo.matching_header_audit ADD [update_ts] DATETIME NULL
END
GO
IF COL_LENGTH('matching_header_audit', 'match_status') IS NULL
BEGIN
ALTER TABLE dbo.matching_header_audit ADD [match_status] INT
END
GO
IF COL_LENGTH('matching_header_audit', 'action') IS NOT NULL
BEGIN
	ALTER TABLE matching_header_audit ALTER COLUMN action VARCHAR(50)
END