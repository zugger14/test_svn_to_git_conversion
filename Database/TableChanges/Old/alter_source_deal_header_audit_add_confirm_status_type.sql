IF NOT EXISTS (SELECT 'x' FROM INFORMATION_SCHEMA.columns WHERE table_name LIKE 'source_deal_header_audit' AND column_name LIKE 'confirm_status_type')
BEGIN
	ALTER TABLE source_deal_header_audit ADD confirm_status_type INT 
	PRINT 'Column confirm_status_type added to table source_deal_header_audit'
END
ELSE
BEGIN
	PRINT 'Column confirm_status_type exists in table source_deal_header_audit'
END