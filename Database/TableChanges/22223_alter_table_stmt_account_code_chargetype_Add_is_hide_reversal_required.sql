IF COL_LENGTH('stmt_account_code_chargetype', 'is_hide') IS NULL
BEGIN
	ALTER TABLE stmt_account_code_chargetype
	ADD is_hide CHAR(1)
	PRINT 'Column ''is_hide'' added.'
END
ELSE PRINT 'Column ''is_hide'' already exists.'
GO