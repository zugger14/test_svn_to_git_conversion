IF COL_LENGTH('master_deal_view', 'source_deal_header_id') IS NOT NULL
BEGIN
	ALTER TABLE dbo.master_deal_view ALTER COLUMN source_deal_header_id VARCHAR(100)
END