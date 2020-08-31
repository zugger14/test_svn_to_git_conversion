IF COL_LENGTH('maintain_whatif_criteria', 'use_market_value') IS NULL
BEGIN
	ALTER TABLE dbo.maintain_whatif_criteria ADD use_market_value CHAR(1)
	PRINT 'Column ''use_market_value'' added.'
END
ELSE 
	PRINT 'Column ''use_market_value'' already exists.'