IF NOT EXISTS(SELECT 1 FROM sys.tables  t INNER JOIN sys.columns c ON c.object_id = t.object_id where t.name = 'source_deal_pnl_detail_options' AND c.name = 'method')
BEGIN
	ALTER TABLE source_deal_pnl_detail_options
	ADD method VARCHAR(100)
END
ELSE 
	PRINT 'Column already added'
