IF COL_LENGTH('transportation_rate_category','contract_type') IS NULL
BEGIN
	ALTER TABLE transportation_rate_category 
	ADD contract_type CHAR(1) NULL
	PRINT 'Added column ''contract_type'''
END
ELSE
PRINT 'column ''contract_type'' already exists'