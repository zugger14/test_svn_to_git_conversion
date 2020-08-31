IF NOT EXISTS (SELECT 'x' FROM INFORMATION_SCHEMA.columns WHERE table_name LIKE 'source_deal_header_template' AND column_name LIKE 'model_id')
BEGIN
	ALTER TABLE source_deal_header_template ADD model_id INT 
	PRINT 'Column model_id added to table source_deal_header_template'
END
ELSE
BEGIN
	PRINT 'Column model_id exists in table source_deal_header_template'
END