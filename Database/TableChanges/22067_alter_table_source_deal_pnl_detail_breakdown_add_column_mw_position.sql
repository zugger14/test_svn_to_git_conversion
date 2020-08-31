IF COL_LENGTH('source_deal_pnl','mw_position') IS NULL
BEGIN
	ALTER TABLE source_deal_pnl ADD mw_position FLOAT
END
GO
IF COL_LENGTH('source_deal_pnl_detail','mw_position') IS NULL
BEGIN
	ALTER TABLE source_deal_pnl_detail ADD mw_position FLOAT
END
GO
IF COL_LENGTH('index_fees_breakdown','mw_position') IS NULL
BEGIN
	ALTER TABLE index_fees_breakdown ADD mw_position FLOAT
END