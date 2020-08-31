IF COL_LENGTH('source_deal_cva', 'dva_counterparty_id') IS NULL
BEGIN
	ALTER TABLE source_deal_cva
	ADD dva_counterparty_id INT
END
ELSE
	PRINT 'Column dva_counterparty does not exist.'