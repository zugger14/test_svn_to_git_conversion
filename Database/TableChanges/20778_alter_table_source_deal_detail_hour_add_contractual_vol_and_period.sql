IF NOT EXISTS(SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'source_deal_detail_hour' AND COLUMN_NAME = 'contractual_volume')
BEGIN
	ALTER TABLE source_deal_detail_hour ADD contractual_volume NUMERIC(38, 20)
END

IF NOT EXISTS(SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'source_deal_detail_hour' AND COLUMN_NAME = 'period')
BEGIN
	ALTER TABLE source_deal_detail_hour ADD [period] INT
END