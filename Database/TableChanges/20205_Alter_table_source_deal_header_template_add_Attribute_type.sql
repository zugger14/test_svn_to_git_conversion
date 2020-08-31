
IF NOT EXISTS(SELECT 1 FROM sys.tables  t INNER JOIN sys.columns c ON c.object_id = t.object_id where t.name = 'source_deal_header_template' AND c.name = 'Attribute_type')
BEGIN
	ALTER TABLE source_deal_header_template
	ADD Attribute_type VARCHAR(1)
END
ELSE 
	PRINT 'Column already added'
	

