IF COL_LENGTH('source_deal_settlement', 'source_deal_settlement_id') IS NULL
BEGIN
	ALTER TABLE source_deal_settlement ADD source_deal_settlement_id INT IDENTITY(1, 1)
END