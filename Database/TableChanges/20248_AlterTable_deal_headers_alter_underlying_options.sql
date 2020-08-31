IF COL_LENGTH('source_deal_header', 'underlying_options') IS NOT NULL
BEGIN
    ALTER TABLE source_deal_header ALTER COLUMN underlying_options INT
END
GO

IF COL_LENGTH('source_deal_header_template', 'underlying_options') IS NOT NULL
BEGIN
    ALTER TABLE source_deal_header_template ALTER COLUMN underlying_options CHAR(1)
END
GO

IF COL_LENGTH('delete_source_deal_header', 'underlying_options') IS NOT NULL
BEGIN
    ALTER TABLE delete_source_deal_header ALTER COLUMN underlying_options CHAR(1)
END
GO

IF COL_LENGTH('source_deal_header_audit', 'underlying_options') IS NOT NULL
BEGIN
    ALTER TABLE source_deal_header_audit ALTER COLUMN underlying_options CHAR(1)
END
GO