IF NOT EXISTS ( SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'source_deal_pnl_eff' AND COLUMN_NAME = 'source_deal_pnl_id' AND DATA_TYPE = 'bigint')
BEGIN
	ALTER TABLE source_deal_pnl_eff ALTER COLUMN source_deal_pnl_id BIGINT NOT NULL
	PRINT 'Table source_deal_pnl_eff Column source_deal_pnl_id datatype changed to BIGINT'
END
ELSE
	PRINT 'Table source_deal_pnl_eff Column source_deal_pnl_id datatype already BIGINT'

