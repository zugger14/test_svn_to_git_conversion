IF COL_LENGTH('source_deal_pnl_breakdown', 'deal_id') IS NOT NULL
BEGIN
	ALTER TABLE source_deal_pnl_breakdown ALTER COLUMN deal_id NVARCHAR(200) --NULL
END