IF NOT EXISTS (SELECT 'x' FROM information_schema.columns WHERE table_name LIKE 'source_deal_header' AND column_name LIKE 'verified_by')
	ALTER TABLE source_deal_header ADD verified_by VARCHAR(50) NULL 
ELSE
	PRINT 'COLUMN verified_by ALREADY EXISTS'
	
IF NOT EXISTS (SELECT 'x' FROM information_schema.columns WHERE table_name LIKE 'source_deal_header' AND column_name LIKE 'verified_date')
	ALTER TABLE source_deal_header ADD verified_date DATETIME
ELSE
	PRINT 'COLUMN verified_date ALREADY EXISTS'	
	

IF NOT EXISTS (SELECT 'x' FROM information_schema.columns WHERE table_name LIKE 'source_deal_header' AND column_name LIKE 'risk_sign_off_by')
	ALTER TABLE source_deal_header ADD risk_sign_off_by VARCHAR(50) NULL 
ELSE
	PRINT 'COLUMN risk_sign_off_by ALREADY EXISTS'
	
IF NOT EXISTS (SELECT 'x' FROM information_schema.columns WHERE table_name LIKE 'source_deal_header' AND column_name LIKE 'risk_sign_off_date')
	ALTER TABLE source_deal_header ADD risk_sign_off_date DATETIME
ELSE
	PRINT 'COLUMN risk_sign_off_date ALREADY EXISTS'		
	
	
IF NOT EXISTS (SELECT 'x' FROM information_schema.columns WHERE table_name LIKE 'source_deal_header' AND column_name LIKE 'back_office_sign_off_by')
	ALTER TABLE source_deal_header ADD back_office_sign_off_by VARCHAR(50) NULL 
ELSE
	PRINT 'COLUMN back_office_sign_off_by ALREADY EXISTS'
	
IF NOT EXISTS (SELECT 'x' FROM information_schema.columns WHERE table_name LIKE 'source_deal_header' AND column_name LIKE 'back_office_sign_off_date')
	ALTER TABLE source_deal_header ADD back_office_sign_off_date DATETIME
ELSE
	PRINT 'COLUMN back_office_sign_off_date ALREADY EXISTS'			
	
