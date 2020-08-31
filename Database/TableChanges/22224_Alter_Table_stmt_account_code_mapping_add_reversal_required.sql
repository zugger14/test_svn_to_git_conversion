IF COL_LENGTH('stmt_account_code_mapping', 'reversal_required') IS NULL
BEGIN
	ALTER TABLE stmt_account_code_mapping
	ADD reversal_required CHAR(1)
	PRINT 'Column ''reversal_required'' added.'
END
ELSE PRINT 'Column ''reversal_required'' already exists.'
GO


IF COL_LENGTH('stmt_account_code_mapping', 'is_hide') IS NULL
BEGIN
	ALTER TABLE stmt_account_code_mapping
	ADD is_hide CHAR(1)
	PRINT 'Column ''is_hide'' added.'
END
ELSE PRINT 'Column ''is_hide'' already exists.'
GO
