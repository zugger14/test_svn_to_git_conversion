IF COL_LENGTH('delete_source_deal_header', 'deal_id') IS NOT NULL
BEGIN
    ALTER TABLE delete_source_deal_header ALTER COLUMN deal_id VARCHAR(200)
END
GO