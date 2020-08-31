IF NOT EXISTS(SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'counterparty_contract_rate_schedule' AND  COLUMN_NAME = 'RANK')
BEGIN
	ALTER TABLE counterparty_contract_rate_schedule
	ADD RANK INT
	PRINT 'Column Inserted Successfully.'	
END
ELSE 
	PRINT 'Column already exists.'	


