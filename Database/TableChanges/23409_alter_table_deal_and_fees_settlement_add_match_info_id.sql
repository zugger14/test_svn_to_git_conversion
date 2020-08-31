IF COL_LENGTH('source_deal_settlement', 'match_info_id') IS NULL
BEGIN
	ALTER TABLE source_deal_settlement ADD match_info_id INT
END
GO
IF COL_LENGTH('index_fees_breakdown_settlement', 'match_info_id') IS NULL
BEGIN
	ALTER TABLE index_fees_breakdown_settlement ADD match_info_id INT
END
GO
IF COL_LENGTH('source_deal_settlement_tou', 'match_info_id') IS NULL
BEGIN
	ALTER TABLE source_deal_settlement_tou ADD match_info_id INT
END
GO
IF COL_LENGTH('stmt_adjustments', 'match_info_id') IS NULL
BEGIN
	ALTER TABLE stmt_adjustments ADD match_info_id INT
END