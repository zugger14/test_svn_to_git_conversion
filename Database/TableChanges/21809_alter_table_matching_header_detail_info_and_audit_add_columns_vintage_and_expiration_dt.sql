IF COL_LENGTH('matching_header_detail_info', 'vintage_yr') IS NULL
BEGIN
ALTER TABLE dbo.matching_header_detail_info ADD vintage_yr int
END
GO

IF COL_LENGTH('matching_header_detail_info', 'expiration_dt') IS NULL
BEGIN
ALTER TABLE dbo.matching_header_detail_info ADD expiration_dt date
END
GO

IF COL_LENGTH('matching_header_detail_info_audit', 'vintage_yr') IS NULL
BEGIN
ALTER TABLE dbo.matching_header_detail_info_audit ADD vintage_yr int
END
GO

IF COL_LENGTH('matching_header_detail_info_audit', 'expiration_dt') IS NULL
BEGIN
ALTER TABLE dbo.matching_header_detail_info_audit ADD expiration_dt date
END
GO

