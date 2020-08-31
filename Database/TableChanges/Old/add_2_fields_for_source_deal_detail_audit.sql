IF NOT EXISTS(SELECT 'X' FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'source_deal_detail_audit' AND COLUMN_NAME = 'settlement_currency')
BEGIN
	ALTER TABLE source_deal_detail_audit ADD settlement_currency int NULL
END
IF NOT EXISTS(SELECT 'X' FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'source_deal_detail_audit' AND COLUMN_NAME = 'standard_yearly_volume')
BEGIN
	ALTER TABLE source_deal_detail_audit ADD standard_yearly_volume float NULL
END