IF NOT EXISTS(SELECT 1 FROM sys.tables  t INNER JOIN sys.columns c ON c.object_id = t.object_id where t.name = 'source_deal_pnl_detail_options' AND c.name = 'Attribute_type')
BEGIN
	ALTER TABLE source_deal_pnl_detail_options
	ADD Attribute_type VARCHAR(1)
END
ELSE 
	PRINT 'Column already added'
	

