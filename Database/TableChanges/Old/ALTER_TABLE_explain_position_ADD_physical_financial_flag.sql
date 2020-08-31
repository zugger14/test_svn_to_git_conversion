IF COL_LENGTH('explain_position', 'physical_financial_flag') IS NULL
BEGIN
	ALTER TABLE explain_position ADD physical_financial_flag varchar(1)
	PRINT 'Column explain_position.physical_financial_flag added.'
END
ELSE
BEGIN
	PRINT 'Column explain_position.physical_financial_flag already exists.'
END
GO

IF COL_LENGTH('explain_mtm', 'physical_financial_flag') IS NULL
BEGIN
	ALTER TABLE explain_mtm ADD physical_financial_flag varchar(1)
	PRINT 'Column explain_mtm.physical_financial_flag added.'
END
ELSE
BEGIN
	PRINT 'Column explain_mtm.physical_financial_flag already exists.'
END
GO