IF NOT EXISTS (SELECT 'x' FROM information_schema.columns WHERE table_name LIKE 'source_deal_header_audit' AND column_name LIKE 'verified_by')
	ALTER TABLE source_deal_header_audit ADD verified_by VARCHAR(50) NULL 
ELSE
	PRINT 'COLUMN verified_by ALREADY EXISTS'
	
IF NOT EXISTS (SELECT 'x' FROM information_schema.columns WHERE table_name LIKE 'source_deal_header_audit' AND column_name LIKE 'verified_date')
	ALTER TABLE source_deal_header_audit ADD verified_date DATETIME
ELSE
	PRINT 'COLUMN verified_date ALREADY EXISTS'	